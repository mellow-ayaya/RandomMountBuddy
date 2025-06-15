import csv
import os
import glob

# --- Configuration ---
# Get the directory where the script itself is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Define expected filename prefixes (the scripts will find files starting with these names)
MOUNT_TYPE_PREFIX = "MountType"
MOUNT_PREFIX = "Mount"

# Define output filenames (they will be in the same directory as the script)
HELPER_MOUNT_TYPE_TRAIT_ASSIGNMENT_LUA_FILENAME = "MountType.lua"
OUTPUT_MOUNTID_TO_MOUNTTYPEID_LUA_FILENAME = "MountID_to_MountTypeID.lua"

# Construct full paths for output files
HELPER_MOUNT_TYPE_TRAIT_ASSIGNMENT_LUA = os.path.join(SCRIPT_DIR, HELPER_MOUNT_TYPE_TRAIT_ASSIGNMENT_LUA_FILENAME)
OUTPUT_MOUNTID_TO_MOUNTTYPEID_LUA = os.path.join(SCRIPT_DIR, OUTPUT_MOUNTID_TO_MOUNTTYPEID_LUA_FILENAME)

# --- Helper function to find files by prefix ---
def find_file_by_prefix(directory, prefix):
    """
    Find the first CSV file in the directory that starts with the given prefix.
    Returns the full path if found, None otherwise.
    """
    pattern = os.path.join(directory, f"{prefix}*.csv")
    matches = glob.glob(pattern)

    if not matches:
        return None
    elif len(matches) == 1:
        return matches[0]
    else:
        # Multiple matches found, pick the first one alphabetically and warn user
        sorted_matches = sorted(matches)
        print(f"WARNING: Multiple files found matching '{prefix}*.csv':")
        for match in sorted_matches:
            print(f"  - {os.path.basename(match)}")
        print(f"Using: {os.path.basename(sorted_matches[0])}")
        return sorted_matches[0]

# --- Find the actual CSV files ---
print("Looking for CSV files in script directory...")
MOUNT_TYPE_CSV = find_file_by_prefix(SCRIPT_DIR, MOUNT_TYPE_PREFIX)
MOUNT_CSV = find_file_by_prefix(SCRIPT_DIR, MOUNT_PREFIX)

# Check if required files were found
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
    print(f"\nPlease ensure the required CSV files are in the script directory: {SCRIPT_DIR}")
    input("Press Enter to exit.")
    exit(1)

print()  # Empty line for readability

# --- Helper to read CSV (simplified as we know specific columns) ---
def read_csv_specific_columns(filepath, key_col_name, value_col_names=[], all_rows=False):
    """
    Reads specific columns from a CSV.
    If all_rows is True, returns a list of dicts (each dict is a row).
    Otherwise, returns a dict mapping key_col_name to a dict of value_col_names
    (or the full row dict if value_col_names is empty).
    """
    data_accumulator = [] if all_rows else {}
    try:
        with open(filepath, mode='r', encoding='utf-8-sig') as csvfile: # utf-8-sig handles potential BOM
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

            for row_num, row in enumerate(reader, 2): # Start row_num from 2 (since header is row 1)
                if not row: continue # Skip empty rows
                if len(row) <= key_col_index:
                    # print(f"Warning: Row {row_num} in {filepath} is too short for key column '{key_col_name}'. Skipping.")
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

# --- Part 1: Generate Helper for MountType Trait Assignment ---
print(f"Processing {os.path.basename(MOUNT_TYPE_CSV)} for helper output...")
mount_type_data_all_rows = read_csv_specific_columns(MOUNT_TYPE_CSV, 'ID', all_rows=True)

if mount_type_data_all_rows:
    try:
        with open(HELPER_MOUNT_TYPE_TRAIT_ASSIGNMENT_LUA, 'w', encoding='utf-8') as f_helper:
            f_helper.write("-- Helper for assigning custom traits to MountTypeIDs\n")
            f_helper.write("-- Manually create a Lua table: MountTypeTraits = { [MountTypeID] = {isGround=bool, isAquatic=bool,... derivedMovementType=\"YOUR_TYPE\"} }\n\n")
            f_helper.write("MountTypeTraits_Input_Helper = {\n")

            sorted_mount_types = sorted(mount_type_data_all_rows, key=lambda x: int(x.get('ID', '0')))

            for mt_data in sorted_mount_types:
                mt_id = mt_data.get('ID', 'UNKNOWN_ID')
                mt_type_name = mt_data.get('Type', 'UnknownType')

                # Displaying a few capability flags as comments. You'll need to investigate their meanings.
                # These are just examples, refer to wow.tools for actual capability meanings.
                caps_to_check = [f'Capability_{i}' for i in range(24)] # Check for Capability_0 to Capability_23
                cap_comments = []
                for cap_name in caps_to_check:
                    val = mt_data.get(cap_name)
                    if val and val != '0': # Only show non-zero capabilities to reduce noise
                        cap_comments.append(f"{cap_name}={val}")

                f_helper.write(f"\t[{mt_id}] = {{\n")
                f_helper.write(f"\t\t-- TypeName: \"{mt_type_name}\"\n")
                if cap_comments:
                    f_helper.write(f"\t\t-- Relevant Caps: {', '.join(cap_comments)}\n")
                else:
                    f_helper.write(f"\t\t-- Relevant Caps: (None or all zero)\n")
                f_helper.write(f"\t\tisGround = false,\n")
                f_helper.write(f"\t\tisAquatic = false,\n")
                f_helper.write(f"\t\tisSteadyFly = false,\n")
                f_helper.write(f"\t\tisSkyriding = false,\n")
                f_helper.write(f"\t\tisUnused = true,\n")
                f_helper.write(f"\t}},\n")
            f_helper.write("}\n\n")
            f_helper.write("-- END OF HELPER --\n")
        print(f"Successfully wrote MountType helper to {HELPER_MOUNT_TYPE_TRAIT_ASSIGNMENT_LUA_FILENAME}")
    except Exception as e:
        print(f"ERROR writing MountType helper file: {e}")
else:
    print(f"Could not load data from {os.path.basename(MOUNT_TYPE_CSV)} or file was empty/invalid.")

# --- Part 2: Generate MountID to MountTypeID Mapping ---
print(f"\nProcessing {os.path.basename(MOUNT_CSV)} for MountID to MountTypeID mapping...")
# We need 'ID' (MountID) and 'MountTypeID' from Mount.csv
# Also 'Name_lang' for comments
mount_data_for_type_mapping = read_csv_specific_columns(MOUNT_CSV, 'ID', value_col_names=['MountTypeID', 'Name_lang'])

if mount_data_for_type_mapping:
    try:
        with open(OUTPUT_MOUNTID_TO_MOUNTTYPEID_LUA, 'w', encoding='utf-8') as f_out:
            f_out.write("-- MountID_to_MountTypeID\n")
            f_out.write("-- Generated mapping of MountID to MountTypeID\n")
            f_out.write("MountIDtoMountTypeID = {\n")

            # Sort by MountID (as integer) for consistent output
            for mount_id_str, data in sorted(mount_data_for_type_mapping.items(), key=lambda item: int(item[0])):
                mount_type_id = data.get('MountTypeID', '0') # Default to '0' if missing
                mount_name_comment = data.get('Name_lang', 'Unknown Mount')

                f_out.write(f"    [{mount_id_str}] = {mount_type_id if mount_type_id else '0'}, -- {mount_name_comment}\n")

            f_out.write("}\n")
        print(f"Successfully wrote MountID to MountTypeID mapping to {OUTPUT_MOUNTID_TO_MOUNTTYPEID_LUA_FILENAME}")
    except Exception as e:
        print(f"ERROR writing MountID to MountTypeID mapping file: {e}")
else:
    print(f"Could not load data from {os.path.basename(MOUNT_CSV)} for MountID to MountTypeID mapping or file was empty/invalid.")

print("\nScript finished.")
input("Press Enter to exit.")