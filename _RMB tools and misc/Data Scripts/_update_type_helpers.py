import csv
import os
import glob
import re
import shutil
from collections import OrderedDict

# --- Configuration ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ADDON_DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(SCRIPT_DIR)), "Data")

# Expected filename prefixes
MOUNT_TYPE_PREFIX = "MountType"
MOUNT_PREFIX = "Mount"

# Addon data files to update
ADDON_MOUNT_TYPE_FILE = os.path.join(ADDON_DATA_DIR, "MountType.lua")
ADDON_MOUNT_ID_MAPPING_FILE = os.path.join(ADDON_DATA_DIR, "MountID_to_MountTypeID.lua")

print(f"Script directory: {SCRIPT_DIR}")
print(f"Addon data directory: {ADDON_DATA_DIR}")
print()

# --- Helper Functions ---
def find_file_by_prefix(directory, prefix):
    """Find the most recent file matching the prefix pattern"""
    pattern = os.path.join(directory, f"{prefix}*.csv")
    matches = glob.glob(pattern)

    if not matches:
        return None
    elif len(matches) == 1:
        return matches[0]
    else:
        sorted_matches = sorted(matches)
        print(f"WARNING: Multiple files found matching '{prefix}*.csv':")
        for match in sorted_matches:
            print(f"  - {os.path.basename(match)}")
        print(f"Using: {os.path.basename(sorted_matches[0])}")
        return sorted_matches[0]

def extract_game_version(filepath):
    """Extract version like '11.1.7.61406' from filename"""
    filename = os.path.basename(filepath)
    version_match = re.search(r'\.(\d+\.\d+\.\d+\.\d+)\.', filename)
    if version_match:
        return version_match.group(1)
    return None

def read_csv_specific_columns(filepath, key_col_name, value_col_names=[], all_rows=False):
    """Read CSV file with specific column handling"""
    data_accumulator = [] if all_rows else {}
    try:
        with open(filepath, mode='r', encoding='utf-8-sig') as csvfile:
            reader = csv.reader(csvfile)
            try:
                header = next(reader)
            except StopIteration:
                print(f"ERROR: CSV file is empty or has no header - {filepath}")
                return None

            try:
                key_col_index = header.index(key_col_name)
            except ValueError:
                print(f"ERROR: Key column '{key_col_name}' not found in header of {filepath}. Header: {header}")
                return None

            value_col_indices = {}
            if value_col_names:
                try:
                    value_col_indices = {name: header.index(name) for name in value_col_names}
                except ValueError as e:
                    print(f"ERROR: One of the value column names not found in header of {filepath}. Error: {e}. Header: {header}")
                    return None

            for row_num, row in enumerate(reader, 2):
                if not row: continue
                if len(row) <= key_col_index:
                    continue

                key = row[key_col_index]

                if all_rows:
                    row_dict = {h: (row[i].strip() if i < len(row) else None) for i, h in enumerate(header)}
                    data_accumulator.append(row_dict)
                else:
                    if value_col_names:
                        row_data = {name: (row[idx].strip() if idx < len(row) else None) for name, idx in value_col_indices.items()}
                        data_accumulator[key] = row_data
                    else:
                        row_dict = {h: (row[i].strip() if i < len(row) else None) for i, h in enumerate(header)}
                        data_accumulator[key] = row_dict
    except FileNotFoundError:
        print(f"ERROR: File not found - {filepath}")
        return None
    except Exception as e:
        print(f"ERROR: Could not read CSV {filepath}. Error: {e}")
        return None
    return data_accumulator

def backup_file(filepath, game_version):
    """Create a backup of the file in backup.{game_version} directory"""
    if os.path.exists(filepath):
        # Create backup directory
        backup_dir = os.path.join(SCRIPT_DIR, f"backup.{game_version}")
        os.makedirs(backup_dir, exist_ok=True)

        # Create backup file path
        filename = os.path.basename(filepath)
        backup_path = os.path.join(backup_dir, filename)

        shutil.copy2(filepath, backup_path)
        print(f"✓ Created backup: backup.{game_version}/{filename}")
        return backup_path
    return None

def archive_csv_files(csv_files, game_version):
    """Archive CSV files to archive directory"""
    print(f"\nArchiving processed CSV files...")
    ARCHIVE_DIR = os.path.join(SCRIPT_DIR, f"Archive.{game_version}")
    os.makedirs(ARCHIVE_DIR, exist_ok=True)

    archived_count = 0
    for file_path in csv_files:
        if file_path and os.path.exists(file_path):
            try:
                archive_path = os.path.join(ARCHIVE_DIR, os.path.basename(file_path))
                shutil.move(file_path, archive_path)
                print(f"✓ Archived: {os.path.basename(file_path)}")
                archived_count += 1
            except Exception as e:
                print(f"✗ Failed to archive {os.path.basename(file_path)}: {e}")

    if archived_count > 0:
        print(f"✓ Archived {archived_count} CSV files to Archive.{game_version}")
    else:
        print("No CSV files were archived")

# --- Lua File Parsing Functions ---
def parse_existing_mount_type_traits(filepath):
    """Parse existing MountType.lua to get existing mount type traits"""
    existing_traits = OrderedDict()

    if not os.path.exists(filepath):
        print(f"Mount type file not found: {filepath}")
        return existing_traits

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the MountTypeTraits_Input_Helper table
        traits_table_match = re.search(r'MountTypeTraits_Input_Helper\s*=\s*{(.*?)^}', content, re.MULTILINE | re.DOTALL)
        if traits_table_match:
            table_content = traits_table_match.group(1)

            # Parse individual mount type entries
            # This regex handles multi-line mount type definitions
            type_pattern = r'\[(\d+)\]\s*=\s*{([^}]*(?:{[^}]*}[^}]*)*)}'
            type_entries = re.findall(type_pattern, table_content, re.DOTALL)

            for mount_type_id, definition_content in type_entries:
                # Parse the definition content
                definition = {}

                # Extract comments
                comments = []
                comment_matches = re.findall(r'--\s*(.+)', definition_content)
                for comment in comment_matches:
                    comments.append(comment.strip())
                definition['comments'] = comments

                # Extract boolean traits
                trait_pattern = r'(\w+)\s*=\s*(true|false)'
                traits = {}
                for trait_match in re.finditer(trait_pattern, definition_content):
                    trait_name, trait_value = trait_match.groups()
                    traits[trait_name] = trait_value == 'true'
                definition['traits'] = traits

                existing_traits[mount_type_id] = definition

        print(f"Parsed {len(existing_traits)} existing mount type traits")

    except Exception as e:
        print(f"ERROR parsing mount type traits: {e}")

    return existing_traits

def parse_existing_mount_mappings(filepath):
    """Parse existing MountID_to_MountTypeID.lua to get existing mount ID mappings"""
    existing_mappings = OrderedDict()

    if not os.path.exists(filepath):
        print(f"Mount ID mapping file not found: {filepath}")
        return existing_mappings

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the MountIDtoMountTypeID table
        mapping_table_match = re.search(r'MountIDtoMountTypeID\s*=\s*{(.*?)^}', content, re.MULTILINE | re.DOTALL)
        if mapping_table_match:
            table_content = mapping_table_match.group(1)
            # Parse individual mount mapping entries
            mapping_entries = re.findall(r'\[(\d+)\]\s*=\s*(\d+)(?:,?\s*--\s*(.*))?', table_content)
            for mount_id, mount_type_id, comment in mapping_entries:
                existing_mappings[mount_id] = {
                    'mount_type_id': mount_type_id,
                    'comment': comment.strip() if comment else None
                }

        print(f"Parsed {len(existing_mappings)} existing mount ID mappings")

    except Exception as e:
        print(f"ERROR parsing mount ID mappings: {e}")

    return existing_mappings

# --- Update Functions ---
def update_mount_type_traits(filepath, existing_traits, new_mount_types, game_version):
    """Update the mount type traits file with new entries"""
    if not new_mount_types:
        print("No new mount type traits to add")
        return

    # Create backup
    backup_file(filepath, game_version)

    try:
        # Read the current file
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Generate new entries
        new_entries = []
        added_count = 0

        for mt_data in sorted(new_mount_types, key=lambda x: int(x.get('ID', '0'))):
            mt_id = mt_data.get('ID', 'UNKNOWN_ID')

            if mt_id not in existing_traits:
                mt_type_name = mt_data.get('Type', 'UnknownType')

                # Check for capabilities
                caps_to_check = [f'Capability_{i}' for i in range(24)]
                cap_comments = []
                for cap_name in caps_to_check:
                    val = mt_data.get(cap_name)
                    if val and val != '0':
                        cap_comments.append(f"{cap_name}={val}")

                entry_lines = [
                    f'\t[{mt_id}] = {{',
                    f'\t\t-- TypeName: "{mt_type_name}"'
                ]

                if cap_comments:
                    entry_lines.append(f'\t\t-- Relevant Caps: {", ".join(cap_comments)}')
                else:
                    entry_lines.append(f'\t\t-- Relevant Caps: (None or all zero)')

                entry_lines.extend([
                    f'\t\tisGround = false,',
                    f'\t\tisAquatic = false,',
                    f'\t\tisSteadyFly = false,',
                    f'\t\tisSkyriding = false,',
                    f'\t\tisUnused = true,',
                    f'\t}},'
                ])

                new_entries.extend(entry_lines)
                new_entries.append('')  # Empty line between entries
                added_count += 1

        if new_entries:
            # Find the end of the MountTypeTraits_Input_Helper table
            table_pattern = r'(MountTypeTraits_Input_Helper\s*=\s*{.*?)(^})'

            def replace_func(match):
                table_start = match.group(1)
                table_end = match.group(2)

                # Add new entries before the closing brace
                new_content = table_start.rstrip() + '\n'
                if not table_start.rstrip().endswith(','):
                    new_content = new_content.rstrip() + ',\n'

                # Removed the version comment line
                new_content += '\n'.join(new_entries)
                new_content += table_end

                return new_content

            updated_content = re.sub(table_pattern, replace_func, content, flags=re.MULTILINE | re.DOTALL)

            # Write the updated content
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(updated_content)

            print(f"✓ Updated {os.path.basename(filepath)} with {added_count} new mount type traits")

    except Exception as e:
        print(f"ERROR updating mount type traits: {e}")
        # Restore backup if available
        backup_path = os.path.join(SCRIPT_DIR, f"backup.{game_version}", os.path.basename(filepath))
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, filepath)
            print("✓ Restored from backup due to error")

def update_mount_id_mappings(filepath, existing_mappings, new_mount_mappings, game_version):
    """Update the mount ID mappings file with new entries"""
    if not new_mount_mappings:
        print("No new mount ID mappings to add")
        return

    # Create backup
    backup_file(filepath, game_version)

    try:
        # Read the current file
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Combine existing and new mappings
        all_mappings = existing_mappings.copy()
        added_count = 0

        for mount_id_str, data in new_mount_mappings.items():
            if mount_id_str not in all_mappings:
                mount_type_id = data.get('MountTypeID', '0')
                mount_name = data.get('Name_lang', 'Unknown Mount')
                all_mappings[mount_id_str] = {
                    'mount_type_id': mount_type_id if mount_type_id else '0',
                    'comment': mount_name
                }
                added_count += 1

        # Sort by mount ID
        sorted_mappings = OrderedDict(sorted(all_mappings.items(), key=lambda x: int(x[0])))

        # Generate new table content
        new_table_lines = []
        max_line_length = 0

        # First pass: calculate max line length for alignment
        for mount_id, data in sorted_mappings.items():
            mount_type_id = data['mount_type_id']
            line_content = f"    [{mount_id}] = {mount_type_id},"
            max_line_length = max(max_line_length, len(line_content))

        target_comment_column = max_line_length + 4

        # Second pass: generate aligned lines
        for mount_id, data in sorted_mappings.items():
            mount_type_id = data['mount_type_id']
            line_content = f"    [{mount_id}] = {mount_type_id},"

            if data.get('comment'):
                spaces_needed = target_comment_column - len(line_content)
                spacing = " " * max(1, spaces_needed)
                line_content += f"{spacing}-- {data['comment']}"

            new_table_lines.append(line_content)

        # Replace the table in the content
        new_table_content = "MountIDtoMountTypeID = {\n" + "\n".join(new_table_lines) + "\n}"

        # Find and replace the existing table
        table_pattern = r'MountIDtoMountTypeID\s*=\s*{.*?^}'
        updated_content = re.sub(table_pattern, new_table_content, content, flags=re.MULTILINE | re.DOTALL)

        # Write the updated content (removed version comment addition)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(updated_content)

        print(f"✓ Updated {os.path.basename(filepath)} with {added_count} new mount ID mappings")

    except Exception as e:
        print(f"ERROR updating mount ID mappings: {e}")
        # Restore backup if available
        backup_path = os.path.join(SCRIPT_DIR, f"backup.{game_version}", os.path.basename(filepath))
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, filepath)
            print("✓ Restored from backup due to error")

# --- Main Processing ---
def main():
    print("=== Lua Mount Type Data Updater ===\n")

    # Find CSV files
    print("Looking for CSV files...")
    MOUNT_TYPE_CSV = find_file_by_prefix(SCRIPT_DIR, MOUNT_TYPE_PREFIX)
    MOUNT_CSV = find_file_by_prefix(SCRIPT_DIR, MOUNT_PREFIX)

    # Check required files
    missing_files = []
    if MOUNT_TYPE_CSV is None:
        missing_files.append(f"{MOUNT_TYPE_PREFIX}*.csv")
    else:
        print(f"Found MountType file: {os.path.basename(MOUNT_TYPE_CSV)}")

    if MOUNT_CSV is None:
        missing_files.append(f"{MOUNT_PREFIX}*.csv")
    else:
        print(f"Found Mount file: {os.path.basename(MOUNT_CSV)}")

    if missing_files:
        print(f"\nERROR: Required files not found:")
        for missing in missing_files:
            print(f"  - {missing}")
        input("Press Enter to exit.")
        return

    # Extract game version
    game_version = extract_game_version(MOUNT_TYPE_CSV) or extract_game_version(MOUNT_CSV)
    if not game_version:
        print("WARNING: Could not extract game version from filenames. Using 'unknown'")
        game_version = "unknown"
    else:
        print(f"Detected game version: {game_version}")

    print()

    # Load CSV data
    print("Reading CSV data...")
    mount_type_data_all_rows = read_csv_specific_columns(MOUNT_TYPE_CSV, 'ID', all_rows=True)
    mount_data_for_type_mapping = read_csv_specific_columns(MOUNT_CSV, 'ID', value_col_names=['MountTypeID', 'Name_lang'])

    if not mount_type_data_all_rows or not mount_data_for_type_mapping:
        print("ERROR: Failed to read CSV data")
        input("Press Enter to exit.")
        return

    print(f"Loaded {len(mount_type_data_all_rows)} mount type entries")
    print(f"Loaded {len(mount_data_for_type_mapping)} mount entries")

    # Parse existing addon data
    print("\nParsing existing addon data...")
    existing_mount_type_traits = parse_existing_mount_type_traits(ADDON_MOUNT_TYPE_FILE)
    existing_mount_mappings = parse_existing_mount_mappings(ADDON_MOUNT_ID_MAPPING_FILE)

    # Find new entries
    print("Analyzing for new entries...")

    # New mount types
    new_mount_types = []
    for mt_data in mount_type_data_all_rows:
        mt_id = mt_data.get('ID', 'UNKNOWN_ID')
        if mt_id not in existing_mount_type_traits:
            new_mount_types.append(mt_data)

    # New mount mappings
    new_mount_mappings = {}
    for mount_id_str, data in mount_data_for_type_mapping.items():
        if mount_id_str not in existing_mount_mappings:
            new_mount_mappings[mount_id_str] = data

    print(f"Found {len(new_mount_types)} new mount types")
    print(f"Found {len(new_mount_mappings)} new mount ID mappings")

    # Archive CSV files regardless of whether updates are needed
    files_to_archive = [MOUNT_TYPE_CSV, MOUNT_CSV]
    archive_csv_files(files_to_archive, game_version)

    if not new_mount_types and not new_mount_mappings:
        print("\n✓ No updates needed! Your addon data is already up to date.")
        print("✓ CSV files have been archived.")
        input("Press Enter to exit.")
        return

    # Confirm updates
    print(f"\nPreparing to update addon files:")
    if new_mount_types:
        print(f"  - {len(new_mount_types)} new mount type traits will be added to {os.path.basename(ADDON_MOUNT_TYPE_FILE)}")
    if new_mount_mappings:
        print(f"  - {len(new_mount_mappings)} new mount ID mappings will be added to {os.path.basename(ADDON_MOUNT_ID_MAPPING_FILE)}")

    print(f"\nBackups will be created in backup.{game_version}/")
    response = input("Continue with updates? (y/N): ").strip().lower()
    if response != 'y':
        print("Update cancelled.")
        return

    # Perform updates
    print("\nUpdating addon files...")

    if new_mount_types:
        update_mount_type_traits(ADDON_MOUNT_TYPE_FILE, existing_mount_type_traits, new_mount_types, game_version)

    if new_mount_mappings:
        update_mount_id_mappings(ADDON_MOUNT_ID_MAPPING_FILE, existing_mount_mappings, new_mount_mappings, game_version)

    print(f"\n✓ Update complete!")
    print(f"✓ Your addon files have been successfully updated with new mount type data")
    input("Press Enter to exit.")

if __name__ == "__main__":
    main()