import csv
import os
import sys
import glob
import re
import shutil
from collections import OrderedDict

# --- Configuration ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ADDON_DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(SCRIPT_DIR)), "Data")

# Expected filename prefixes
MOUNT_PREFIX = "Mount"
MOUNT_X_DISPLAY_PREFIX = "MountXDisplay"
CREATURE_DISPLAY_INFO_PREFIX = "CreatureDisplayInfo"
CREATURE_MODEL_DATA_PREFIX = "CreatureModelData"
LISTFILE_PREFIX = "community-listfile"

# Addon data files to update
ADDON_MOUNT_MODEL_FILE = os.path.join(ADDON_DATA_DIR, "GeneratedMountModelGroups_WithPaths.lua")
ADDON_FAMILY_DEFINITIONS_FILE = os.path.join(ADDON_DATA_DIR, "ManualFamilyDefinitions.lua")

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

def read_csv_to_dict(filepath, key_column_name, process_func=None):
    """Read CSV file into dictionary"""
    data_dict = {}
    if not os.path.exists(filepath):
        print(f"ERROR: Input file not found - {filepath}")
        return None
    try:
        with open(filepath, mode='r', encoding='utf-8-sig') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader)
            try:
                key_column_index = header.index(key_column_name)
            except ValueError:
                print(f"ERROR: Key column '{key_column_name}' not found in header of {os.path.basename(filepath)}. Header: {header}")
                return None

            for row_num, row in enumerate(reader, 1):
                if not row: continue
                if len(row) <= key_column_index:
                    continue
                key = row[key_column_index]
                if process_func:
                    try:
                        processed_key, processed_value = process_func(header, row, key_column_index)
                        if processed_key is not None:
                            if processed_key in data_dict:
                                if isinstance(data_dict[processed_key], list):
                                    data_dict[processed_key].append(processed_value)
                                else:
                                    data_dict[processed_key] = [data_dict[processed_key], processed_value]
                            else:
                                data_dict[processed_key] = processed_value
                    except Exception as e:
                        print(f"ERROR processing row {row_num} in {os.path.basename(filepath)}: {e}")
                else:
                    row_dict = {}
                    for i in range(len(header)):
                        if i < len(row):
                            row_dict[header[i]] = row[i]
                        else:
                            row_dict[header[i]] = None
                    data_dict[key] = row_dict
    except Exception as e:
        print(f"ERROR: Could not read CSV {os.path.basename(filepath)}. Error: {e}")
        return None
    return data_dict

def process_mount_x_display_row(header, row, key_column_index):
    mount_id_col = header.index('MountID')
    creature_display_info_id_col = header.index('CreatureDisplayInfoID')
    return row[mount_id_col], row[creature_display_info_id_col]

def process_creature_display_info_row(header, row, key_column_index):
    model_id_col = header.index('ModelID')
    return row[key_column_index], row[model_id_col]

def process_creature_model_data_row(header, row, key_column_index):
    file_data_id_col = header.index('FileDataID')
    return row[key_column_index], str(row[file_data_id_col])

def load_listfile(filepath):
    """Load listfile mapping FileDataID to paths"""
    id_to_path = {}
    if not filepath or not os.path.exists(filepath):
        return {}

    print(f"Loading listfile: {os.path.basename(filepath)}")
    loaded_count = 0
    try:
        with open(filepath, mode='r', encoding='utf-8-sig') as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            for row in reader:
                if not row or len(row) < 2: continue
                try:
                    file_data_id = row[0].strip()
                    file_path = row[1].strip()
                    if not file_data_id.isdigit():
                        continue
                    if '/' not in file_path and '\\' not in file_path:
                        continue
                    id_to_path[file_data_id] = file_path
                    loaded_count += 1
                except (IndexError, ValueError):
                    continue
        print(f"Loaded {loaded_count} entries from listfile")
    except Exception as e:
        print(f"ERROR loading listfile: {e}")
        return {}
    return id_to_path

def archive_csv_files(csv_files, game_version):
    """Archive CSV files to archive directory"""
    print(f"\nArchiving processed CSV files...")
    ARCHIVE_DIR = os.path.join(SCRIPT_DIR, f"Archive.{game_version}")
    os.makedirs(ARCHIVE_DIR, exist_ok=True)

    archived_count = 0
    kept_count = 0

    for file_path in csv_files:
        if file_path and os.path.exists(file_path):
            try:
                filename = os.path.basename(file_path)
                # Keep Mount.csv for other processing, archive the rest
                if filename.startswith("Mount.") and not any(prefix in filename for prefix in ["MountXDisplay", "MountType"]):
                    print(f"✓ Keeping: {filename} (for mount type processing)")
                    kept_count += 1
                else:
                    archive_path = os.path.join(ARCHIVE_DIR, filename)
                    shutil.move(file_path, archive_path)
                    print(f"✓ Archived: {filename}")
                    archived_count += 1
            except Exception as e:
                print(f"✗ Failed to archive {os.path.basename(file_path)}: {e}")

    if archived_count > 0:
        print(f"✓ Archived {archived_count} CSV files to Archive.{game_version}")
    if kept_count > 0:
        print(f"✓ Kept {kept_count} CSV files for other processing")
    if archived_count == 0 and kept_count == 0:
        print("No CSV files were processed")

# --- Lua File Parsing Functions ---
def parse_existing_mount_model_mappings(filepath):
    """Parse existing mount model mappings from Lua file"""
    existing_mappings = OrderedDict()

    if not os.path.exists(filepath):
        print(f"Mount model file not found: {filepath}")
        return existing_mappings

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the MountToModelPath table
        mount_table_match = re.search(r'MountToModelPath\s*=\s*{(.*?)^}', content, re.MULTILINE | re.DOTALL)
        if mount_table_match:
            table_content = mount_table_match.group(1)
            # Parse individual mount entries
            mount_entries = re.findall(r'\[(\d+)\]\s*=\s*"([^"]+)"(?:,?\s*--\s*(.*))?', table_content)
            for mount_id, model_path, comment in mount_entries:
                existing_mappings[mount_id] = {
                    'model_path': model_path,
                    'comment': comment.strip() if comment else None
                }

        print(f"Parsed {len(existing_mappings)} existing mount model mappings")

    except Exception as e:
        print(f"ERROR parsing mount model mappings: {e}")

    return existing_mappings

def parse_existing_family_definitions(filepath):
    """Parse existing family definitions from Lua file"""
    existing_definitions = OrderedDict()

    if not os.path.exists(filepath):
        print(f"Family definitions file not found: {filepath}")
        return existing_definitions

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the FamilyDefinitions table
        family_table_match = re.search(r'FamilyDefinitions\s*=\s*{(.*?)^}', content, re.MULTILINE | re.DOTALL)
        if family_table_match:
            table_content = family_table_match.group(1)

            # Parse individual family entries
            # This regex handles multi-line family definitions
            family_pattern = r'\["([^"]+)"\]\s*=\s*{([^}]*(?:{[^}]*}[^}]*)*)}'
            family_entries = re.findall(family_pattern, table_content, re.DOTALL)

            for model_path, definition_content in family_entries:
                # Parse the definition content
                definition = {}

                # Extract familyName
                family_name_match = re.search(r'familyName\s*=\s*"([^"]*)"', definition_content)
                if family_name_match:
                    definition['familyName'] = family_name_match.group(1)

                # Extract superGroup
                super_group_match = re.search(r'superGroup\s*=\s*(?:"([^"]*)"|nil)', definition_content)
                if super_group_match:
                    definition['superGroup'] = super_group_match.group(1) if super_group_match.group(1) else None

                # Extract traits
                traits_match = re.search(r'traits\s*=\s*{([^}]+)}', definition_content)
                if traits_match:
                    traits_content = traits_match.group(1)
                    traits = {}
                    for trait_match in re.finditer(r'(\w+)\s*=\s*(true|false)', traits_content):
                        trait_name, trait_value = trait_match.groups()
                        traits[trait_name] = trait_value == 'true'
                    definition['traits'] = traits

                # Extract mount comments
                mount_comments = []
                comment_matches = re.findall(r'--\s*(.+)', definition_content)
                for comment in comment_matches:
                    if 'MountID:' in comment or 'Mounts using this model:' in comment:
                        mount_comments.append(comment.strip())

                definition['mount_comments'] = mount_comments
                existing_definitions[model_path] = definition

        print(f"Parsed {len(existing_definitions)} existing family definitions")

    except Exception as e:
        print(f"ERROR parsing family definitions: {e}")

    return existing_definitions

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

def update_mount_model_mappings(filepath, existing_mappings, new_mappings, game_version):
    """Update the mount model mappings file with new entries"""
    if not new_mappings:
        print("No new mount model mappings to add")
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

        for mount_id, data in new_mappings.items():
            if mount_id not in all_mappings:
                all_mappings[mount_id] = {
                    'model_path': data['model_path'],
                    'comment': data['mount_name']
                }
                added_count += 1

        # Sort by mount ID
        sorted_mappings = OrderedDict(sorted(all_mappings.items(), key=lambda x: int(x[0])))

        # Generate new table content
        new_table_lines = []
        max_line_length = 0

        # First pass: calculate max line length for alignment
        for mount_id, data in sorted_mappings.items():
            model_path = data['model_path'].replace("\\", "\\\\")
            line_content = f"    [{mount_id}] = \"{model_path}\","
            max_line_length = max(max_line_length, len(line_content))

        target_comment_column = max_line_length + 1

        # Second pass: generate aligned lines
        for mount_id, data in sorted_mappings.items():
            model_path = data['model_path'].replace("\\", "\\\\")
            line_content = f"    [{mount_id}] = \"{model_path}\","

            if data.get('comment'):
                spaces_needed = target_comment_column - len(line_content)
                spacing = " " * max(1, spaces_needed)
                line_content += f"{spacing}-- {data['comment']}"

            new_table_lines.append(line_content)

        # Replace the table in the content
        new_table_content = "RandomMountBuddy_PreloadData.MountToModelPath = {\n" + "\n".join(new_table_lines) + "\n}"

        # Find and replace the existing table
        table_pattern = r'RandomMountBuddy_PreloadData\.MountToModelPath\s*=\s*{.*?^}'
        updated_content = re.sub(table_pattern, new_table_content, content, flags=re.MULTILINE | re.DOTALL)

        # Write the updated content (removed version comment addition)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(updated_content)

        print(f"✓ Updated {os.path.basename(filepath)} with {added_count} new mount model mappings")

    except Exception as e:
        print(f"ERROR updating mount model mappings: {e}")
        # Restore backup if available
        backup_path = os.path.join(SCRIPT_DIR, f"backup.{game_version}", os.path.basename(filepath))
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, filepath)
            print("✓ Restored from backup due to error")

def update_family_definitions(filepath, existing_definitions, new_model_paths, mounts_data, game_version):
    """Update the family definitions file with new entries"""
    if not new_model_paths:
        print("No new family definitions to add")
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

        for model_path, details in sorted(new_model_paths.items()):
            if model_path not in existing_definitions and '/' in str(model_path):
                mount_list = details["mounts"]
                lua_key = model_path.replace("\\", "\\\\")

                entry_lines = [
                    f'\t["{lua_key}"] = {{',
                    f'\t\tfamilyName = "UnknownFamily",',
                    f'\t\tsuperGroup = nil,',
                    f'\t\ttraits = {{ hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false }},',
                    f'\t\t-- Mounts using this model:'
                ]

                for mount_name, mount_id_str in sorted(mount_list):
                    entry_lines.append(f'\t\t--   {mount_name} (MountID: {mount_id_str})')

                entry_lines.append('\t},')
                new_entries.extend(entry_lines)
                new_entries.append('')  # Empty line between entries
                added_count += 1

        if new_entries:
            # Find the end of the FamilyDefinitions table
            table_pattern = r'(RandomMountBuddy_PreloadData\.FamilyDefinitions\s*=\s*{.*?)(^})'

            def replace_func(match):
                table_start = match.group(1)
                table_end = match.group(2)

                # Add new entries before the closing brace
                new_content = table_start.rstrip() + '\n'
                if not table_start.rstrip().endswith(','):
                    new_content = new_content.rstrip() + ',\n'

                new_content += '\n'.join(new_entries)
                new_content += table_end

                return new_content

            updated_content = re.sub(table_pattern, replace_func, content, flags=re.MULTILINE | re.DOTALL)

            # Write the updated content
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(updated_content)

            print(f"✓ Updated {os.path.basename(filepath)} with {added_count} new family definitions")

    except Exception as e:
        print(f"ERROR updating family definitions: {e}")
        # Restore backup if available
        backup_path = os.path.join(SCRIPT_DIR, f"backup.{game_version}", os.path.basename(filepath))
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, filepath)
            print("✓ Restored from backup due to error")

# --- Main Processing ---
def main():
    print("=== Lua Mount Data Updater ===\n")

    # Find CSV files
    print("Looking for CSV files...")
    MOUNT_FILE = find_file_by_prefix(SCRIPT_DIR, MOUNT_PREFIX)
    MOUNT_X_DISPLAY_FILE = find_file_by_prefix(SCRIPT_DIR, MOUNT_X_DISPLAY_PREFIX)
    CREATURE_DISPLAY_INFO_FILE = find_file_by_prefix(SCRIPT_DIR, CREATURE_DISPLAY_INFO_PREFIX)
    CREATURE_MODEL_DATA_FILE = find_file_by_prefix(SCRIPT_DIR, CREATURE_MODEL_DATA_PREFIX)
    LISTFILE_CSV = find_file_by_prefix(SCRIPT_DIR, LISTFILE_PREFIX)

    # Check required files
    required_files = [
        (MOUNT_PREFIX, MOUNT_FILE),
        (MOUNT_X_DISPLAY_PREFIX, MOUNT_X_DISPLAY_FILE),
        (CREATURE_DISPLAY_INFO_PREFIX, CREATURE_DISPLAY_INFO_FILE),
        (CREATURE_MODEL_DATA_PREFIX, CREATURE_MODEL_DATA_FILE)
    ]

    missing_files = []
    for prefix, filepath in required_files:
        if filepath is None:
            missing_files.append(f"{prefix}*.csv")
        else:
            print(f"Found {prefix} file: {os.path.basename(filepath)}")

    if LISTFILE_CSV is None:
        print(f"Listfile ({LISTFILE_PREFIX}*.csv) not found - paths will not be resolved to strings")
    else:
        print(f"Found listfile: {os.path.basename(LISTFILE_CSV)}")

    if missing_files:
        print(f"\nERROR: Required files not found:")
        for missing in missing_files:
            print(f"  - {missing}")
        input("Press Enter to exit.")
        return

    # Extract game version
    csv_files = [f for f in [MOUNT_FILE, MOUNT_X_DISPLAY_FILE, CREATURE_DISPLAY_INFO_FILE, CREATURE_MODEL_DATA_FILE, LISTFILE_CSV] if f]
    game_version = None
    for file_path in csv_files:
        game_version = extract_game_version(file_path)
        if game_version:
            break

    if not game_version:
        print("WARNING: Could not extract game version from filenames. Using 'unknown'")
        game_version = "unknown"
    else:
        print(f"Detected game version: {game_version}")

    print()

    # Load CSV data
    print("Loading CSV data...")
    file_id_to_path_map = load_listfile(LISTFILE_CSV)

    mounts_data = read_csv_to_dict(MOUNT_FILE, 'ID')
    if mounts_data is None: return
    print(f"Loaded {len(mounts_data)} mount entries")

    mount_x_display_data = read_csv_to_dict(MOUNT_X_DISPLAY_FILE, 'MountID', process_mount_x_display_row)
    if mount_x_display_data is None: return
    print(f"Loaded {len(mount_x_display_data)} MountXDisplay entries")

    creature_display_info_data = read_csv_to_dict(CREATURE_DISPLAY_INFO_FILE, 'ID', process_creature_display_info_row)
    if creature_display_info_data is None: return
    print(f"Loaded {len(creature_display_info_data)} CreatureDisplayInfo entries")

    creature_model_data_map = read_csv_to_dict(CREATURE_MODEL_DATA_FILE, 'ID', process_creature_model_data_row)
    if creature_model_data_map is None: return
    print(f"Loaded {len(creature_model_data_map)} CreatureModelData entries")

    # Process mount data
    print("\nLinking data and processing mounts...")
    mount_to_model_group_final = {}
    model_id_to_mount_details_list = {}

    for mount_id_str, mount_details in mounts_data.items():
        mount_name = mount_details.get('Name_lang', 'Unknown Mount Name')
        creature_display_info_ids_for_mount = mount_x_display_data.get(mount_id_str)
        if not creature_display_info_ids_for_mount:
            continue
        if not isinstance(creature_display_info_ids_for_mount, list):
            creature_display_info_ids_for_mount = [creature_display_info_ids_for_mount]

        found_model_for_this_mount = False
        for cdi_id in creature_display_info_ids_for_mount:
            if found_model_for_this_mount: break
            model_data_id = creature_display_info_data.get(cdi_id)
            if not model_data_id: continue
            numeric_model_file_data_id = creature_model_data_map.get(model_data_id)
            if not numeric_model_file_data_id: continue

            actual_model_path_or_id = file_id_to_path_map.get(numeric_model_file_data_id, numeric_model_file_data_id)
            mount_to_model_group_final[mount_id_str] = actual_model_path_or_id
            found_model_for_this_mount = True

            if numeric_model_file_data_id not in model_id_to_mount_details_list:
                model_id_to_mount_details_list[numeric_model_file_data_id] = {"path": actual_model_path_or_id, "mounts": []}
            model_id_to_mount_details_list[numeric_model_file_data_id]["mounts"].append((mount_name, mount_id_str))

    print(f"Processed {len(mount_to_model_group_final)} mounts into model groups")

    # Parse existing addon data
    print("\nParsing existing addon data...")
    existing_mount_mappings = parse_existing_mount_model_mappings(ADDON_MOUNT_MODEL_FILE)
    existing_family_definitions = parse_existing_family_definitions(ADDON_FAMILY_DEFINITIONS_FILE)

    # Find new entries
    print("Analyzing for new entries...")

    # New mount model mappings
    new_mount_mappings = {}
    for mount_id_str, model_path in mount_to_model_group_final.items():
        if mount_id_str not in existing_mount_mappings:
            new_mount_mappings[mount_id_str] = {
                'model_path': model_path,
                'mount_name': mounts_data.get(mount_id_str, {}).get('Name_lang', 'Unknown Mount')
            }

    # New model paths that need family definitions
    new_model_paths = {}
    for numeric_model_id, details in model_id_to_mount_details_list.items():
        model_path = details["path"]
        # Only include paths that were actually resolved (not just numeric IDs)
        if model_path != numeric_model_id and '/' in str(model_path) and model_path not in existing_family_definitions:
            new_model_paths[model_path] = details

    print(f"Found {len(new_mount_mappings)} new mount model mappings")
    print(f"Found {len(new_model_paths)} new model paths needing family definitions")

    # Archive CSV files regardless of whether updates are needed
    files_to_archive = [f for f in [MOUNT_FILE, MOUNT_X_DISPLAY_FILE, CREATURE_DISPLAY_INFO_FILE, CREATURE_MODEL_DATA_FILE, LISTFILE_CSV] if f]
    archive_csv_files(files_to_archive, game_version)

    if not new_mount_mappings and not new_model_paths:
        print("\n✓ No updates needed! Your addon data is already up to date.")
        print("✓ CSV files have been archived.")
        input("Press Enter to exit.")
        return

    # Confirm updates
    print(f"\nPreparing to update addon files:")
    if new_mount_mappings:
        print(f"  - {len(new_mount_mappings)} new mount model mappings will be added to {os.path.basename(ADDON_MOUNT_MODEL_FILE)}")
    if new_model_paths:
        print(f"  - {len(new_model_paths)} new family definitions will be added to {os.path.basename(ADDON_FAMILY_DEFINITIONS_FILE)}")

    print(f"\nBackups will be created in backup.{game_version}/")
    response = input("Continue with updates? (y/N): ").strip().lower()
    if response != 'y':
        print("Update cancelled.")
        return

    # Perform updates
    print("\nUpdating addon files...")

    if new_mount_mappings:
        update_mount_model_mappings(ADDON_MOUNT_MODEL_FILE, existing_mount_mappings, new_mount_mappings, game_version)

    if new_model_paths:
        update_family_definitions(ADDON_FAMILY_DEFINITIONS_FILE, existing_family_definitions, new_model_paths, mounts_data, game_version)

    print(f"\n✓ Update complete!")
    print(f"✓ Your addon files have been successfully updated with new mount data")
    input("Press Enter to exit.")

if __name__ == "__main__":
    main()