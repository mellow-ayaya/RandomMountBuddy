import csv
import os
import sys
import glob
import re

# --- Determine the script's directory ---
if getattr(sys, 'frozen', False):
    SCRIPT_DIR = os.path.dirname(sys.executable)
else:
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

print(f"Script running from: {SCRIPT_DIR}")
print(f"Looking for input CSV files and creating output files in this directory.\n")

# --- Configuration: Define filename prefixes ---
MOUNT_PREFIX = "Mount"
MOUNT_X_DISPLAY_PREFIX = "MountXDisplay"
CREATURE_DISPLAY_INFO_PREFIX = "CreatureDisplayInfo"
CREATURE_MODEL_DATA_PREFIX = "CreatureModelData"
LISTFILE_PREFIX = "community-listfile"

OUTPUT_LUA_FILENAME = "GeneratedMountModelGroups_WithPaths.lua"
FAMILY_DEFINITIONS_FILENAME = "ManualFamilyDefinitions.lua"

# Output file paths
OUTPUT_LUA_FILE = os.path.join(SCRIPT_DIR, OUTPUT_LUA_FILENAME)
FAMILY_DEFINITIONS_FILE = os.path.join(SCRIPT_DIR, FAMILY_DEFINITIONS_FILENAME)

# --- Helper function to find files by prefix ---
def find_file_by_prefix(directory, prefix):
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

# --- Find CSV files ---
print("Looking for CSV files...")
MOUNT_FILE = find_file_by_prefix(SCRIPT_DIR, MOUNT_PREFIX)
MOUNT_X_DISPLAY_FILE = find_file_by_prefix(SCRIPT_DIR, MOUNT_X_DISPLAY_PREFIX)
CREATURE_DISPLAY_INFO_FILE = find_file_by_prefix(SCRIPT_DIR, CREATURE_DISPLAY_INFO_PREFIX)
CREATURE_MODEL_DATA_FILE = find_file_by_prefix(SCRIPT_DIR, CREATURE_MODEL_DATA_PREFIX)
LISTFILE_CSV = find_file_by_prefix(SCRIPT_DIR, LISTFILE_PREFIX)

# Check required files
files_to_check = [
    (MOUNT_PREFIX, MOUNT_FILE),
    (MOUNT_X_DISPLAY_PREFIX, MOUNT_X_DISPLAY_FILE),
    (CREATURE_DISPLAY_INFO_PREFIX, CREATURE_DISPLAY_INFO_FILE),
    (CREATURE_MODEL_DATA_PREFIX, CREATURE_MODEL_DATA_FILE)
]

missing_files = []
for prefix, filepath in files_to_check:
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
    print(f"\nPlease ensure the required CSV files are in the script directory.")
    input("Press Enter to exit.")
    sys.exit(1)

print()

# --- Helper Function to Read CSV ---
def read_csv_to_dict(filepath, key_column_name, process_func=None):
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
                print(f"ERROR: Key column '{key_column_name}' not found in {os.path.basename(filepath)}")
                return None

            for row_num, row in enumerate(reader, 1):
                if not row or len(row) <= key_column_index:
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
                    row_dict = {h: (row[i] if i < len(row) else None) for i, h in enumerate(header)}
                    data_dict[key] = row_dict

    except Exception as e:
        print(f"ERROR: Could not read CSV {os.path.basename(filepath)}. Error: {e}")
        return None

    return data_dict

# --- Processing functions ---
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

# --- Load listfile ---
def load_listfile(filepath):
    id_to_path = {}
    if not filepath or not os.path.exists(filepath):
        return {}

    print(f"Loading listfile: {os.path.basename(filepath)}")

    loaded_count = 0
    try:
        with open(filepath, mode='r', encoding='utf-8-sig') as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            for row in reader:
                if len(row) >= 2:
                    try:
                        file_data_id = row[0].strip()
                        file_path = row[1].strip()
                        if file_data_id.isdigit() and ('/' in file_path or '\\' in file_path):
                            id_to_path[file_data_id] = file_path
                            loaded_count += 1
                    except:
                        continue
        print(f"Loaded {loaded_count} entries from listfile")
    except Exception as e:
        print(f"ERROR loading listfile: {e}")
        return {}
    return id_to_path

# --- Main processing ---
print("Loading CSV data...")

file_id_to_path_map = load_listfile(LISTFILE_CSV)

mounts_data = read_csv_to_dict(MOUNT_FILE, 'ID')
if mounts_data is None: sys.exit(1)
print(f"Loaded {len(mounts_data)} mount entries")

mount_x_display_data = read_csv_to_dict(MOUNT_X_DISPLAY_FILE, 'MountID', process_mount_x_display_row)
if mount_x_display_data is None: sys.exit(1)
print(f"Loaded {len(mount_x_display_data)} MountXDisplay entries")

creature_display_info_data = read_csv_to_dict(CREATURE_DISPLAY_INFO_FILE, 'ID', process_creature_display_info_row)
if creature_display_info_data is None: sys.exit(1)
print(f"Loaded {len(creature_display_info_data)} CreatureDisplayInfo entries")

creature_model_data_map = read_csv_to_dict(CREATURE_MODEL_DATA_FILE, 'ID', process_creature_model_data_row)
if creature_model_data_map is None: sys.exit(1)
print(f"Loaded {len(creature_model_data_map)} CreatureModelData entries")

print("\nLinking data and processing mounts...")

mount_to_model_final = {}
model_to_mounts_map = {}
unresolved_mounts = []

for mount_id_str, mount_details in mounts_data.items():
    mount_name = mount_details.get('Name_lang', 'Unknown Mount Name')
    creature_display_info_ids = mount_x_display_data.get(mount_id_str)

    if not creature_display_info_ids:
        unresolved_mounts.append(f"MountID {mount_id_str} ({mount_name}): No MountXDisplay entry")
        continue

    if not isinstance(creature_display_info_ids, list):
        creature_display_info_ids = [creature_display_info_ids]

    found_model = False
    for cdi_id in creature_display_info_ids:
        if found_model:
            break

        model_data_id = creature_display_info_data.get(cdi_id)
        if not model_data_id:
            continue

        numeric_file_data_id = creature_model_data_map.get(model_data_id)
        if not numeric_file_data_id:
            continue

        # Resolve to path if possible, otherwise keep numeric ID
        resolved_model = file_id_to_path_map.get(numeric_file_data_id, numeric_file_data_id)
        mount_to_model_final[mount_id_str] = resolved_model
        found_model = True

        # Track which mounts use each model
        if resolved_model not in model_to_mounts_map:
            model_to_mounts_map[resolved_model] = []
        model_to_mounts_map[resolved_model].append((mount_name, mount_id_str))

    if not found_model:
        unresolved_mounts.append(f"MountID {mount_id_str} ({mount_name}): Could not resolve to model")

print(f"Processed {len(mount_to_model_final)} mounts into model groups")
if unresolved_mounts:
    print(f"Could not resolve {len(unresolved_mounts)} mounts (showing first 5):")
    for unresolved in unresolved_mounts[:5]:
        print(f"  - {unresolved}")

# --- Generate Mount Model Groups Lua ---
print(f"\nGenerating {OUTPUT_LUA_FILENAME}...")

# Calculate spacing for comment alignment
mount_lines = []
max_line_length = 0

for mount_id_str, model_identifier in sorted(mount_to_model_final.items(), key=lambda item: int(item[0])):
    mount_name = mounts_data.get(mount_id_str, {}).get('Name_lang', 'Unknown Mount')
    escaped_model = str(model_identifier).replace("\\", "\\\\")
    line_content = f"    [{mount_id_str}] = \"{escaped_model}\","
    mount_lines.append((line_content, mount_name))
    max_line_length = max(max_line_length, len(line_content))

target_comment_column = max_line_length + 1

try:
    with open(OUTPUT_LUA_FILE, 'w', encoding='utf-8') as f:
        f.write("-- Generated Mount Model Groups\n")
        f.write("-- Mapping: MountID to ModelGroupIdentifier (Model Path or FileDataID if path not resolved)\n\n")
        f.write("if not RandomMountBuddy_PreloadData then RandomMountBuddy_PreloadData = {} end\n\n")
        f.write("RandomMountBuddy_PreloadData.MountToModelPath = {\n")

        for line_content, mount_name in mount_lines:
            spaces_needed = target_comment_column - len(line_content)
            spacing = " " * max(1, spaces_needed)
            f.write(f"{line_content}{spacing}-- {mount_name}\n")

        f.write("}\n")
    print(f"✓ Created: {OUTPUT_LUA_FILENAME}")
except Exception as e:
    print(f"ERROR writing {OUTPUT_LUA_FILENAME}: {e}")

# --- Generate Manual Family Definitions ---
print(f"Generating {FAMILY_DEFINITIONS_FILENAME}...")

try:
    with open(FAMILY_DEFINITIONS_FILE, 'w', encoding='utf-8') as f:
        f.write("-- Manual Family Definitions\n")
        f.write("if not RandomMountBuddy_PreloadData then RandomMountBuddy_PreloadData = {} end\n\n")
        f.write("RandomMountBuddy_PreloadData.FamilyDefinitions = {\n")

        for model_path in sorted(model_to_mounts_map.keys()):
            # Only include entries where path was resolved (contains '/')
            if '/' in str(model_path):
                mount_list = model_to_mounts_map[model_path]
                escaped_path = str(model_path).replace("\\", "\\\\")

                f.write(f"\t[\"{escaped_path}\"] = {{\n")
                f.write(f"\t\tfamilyName = \"UnknownFamily\",\n")
                f.write(f"\t\tsuperGroup = nil,\n")
                f.write(f"\t\ttraits = {{ hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false }},\n")
                f.write(f"\t\t-- Mounts using this model:\n")

                for mount_name, mount_id_str in sorted(mount_list):
                    f.write(f"\t\t--   {mount_name} (MountID: {mount_id_str})\n")

                f.write(f"\t}},\n")

        f.write("}\n")
    print(f"✓ Created: {FAMILY_DEFINITIONS_FILENAME}")
except Exception as e:
    print(f"ERROR writing {FAMILY_DEFINITIONS_FILENAME}: {e}")

print("\nProcessing complete!")
input("Press Enter to exit.")