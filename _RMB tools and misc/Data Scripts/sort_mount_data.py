#!/usr/bin/env python3
"""
Sort RandomMountBuddy mount data file.
Sorts by family name alphabetically, then by mount ID numerically within each family.
Automatically processes MountData.lua when double-clicked.
"""

import re
import sys
from pathlib import Path
from collections import defaultdict


def parse_mount_assignment(line):
    """Parse a mount assignment line and return (mount_id, family_name, full_line) or None."""
    # Match pattern: [number] = "Family Name",  -- Optional comment
    match = re.match(r'\s*\[(\d+)\]\s*=\s*"([^"]+)",?\s*(--.*)?$', line)
    if match:
        mount_id = int(match.group(1))
        family_name = match.group(2)
        return mount_id, family_name, line
    return None


def parse_family_definition(line):
    """Parse a family definition line and return (family_name, full_line) or None."""
    # Match pattern: ["Family Name"] = {
    match = re.match(r'\s*\["([^"]+)"\]\s*=\s*{', line)
    if match:
        family_name = match.group(1)
        return family_name, line
    return None


def sort_mount_data(input_file, output_file=None):
    """
    Sort mount data file by section names alphabetically, then family names, then mount IDs.

    Args:
        input_file: Path to input file
        output_file: Path to output file (defaults to input_file if None)
    """
    if output_file is None:
        output_file = input_file

    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    result_lines = []
    in_mount_to_family = False
    in_family_definitions = False

    # For MountToFamily: collect all sections
    all_mount_sections = []  # [(section_name, section_header, section_mounts), ...]
    current_section_name = None
    current_section_header = []
    current_section_mounts = defaultdict(list)

    # For FamilyDefinitions: collect all sections
    all_family_sections = []  # [(section_name, section_header, section_families), ...]
    current_family_section_name = None
    current_family_section_header = []
    current_section_families = []
    current_family_lines = []
    current_family_name = None

    i = 0
    while i < len(lines):
        line = lines[i]

        # Detect start of MountToFamily section
        if 'RandomMountBuddy_PreloadData.MountToFamily' in line:
            in_mount_to_family = True
            result_lines.append(line)
            i += 1
            continue

        # Detect start of FamilyDefinitions section
        if 'RandomMountBuddy_PreloadData.FamilyDefinitions' in line:
            in_family_definitions = True
            result_lines.append(line)
            i += 1
            continue

        # Handle MountToFamily section
        if in_mount_to_family:
            # Check for section header lines
            if line.strip().startswith('--'):
                # Check if this is a separator line (contains ===)
                if '=' in line:
                    # If we already have a section with mounts, this is a new section starting
                    if current_section_name and current_section_mounts:
                        all_mount_sections.append((current_section_name, current_section_header, current_section_mounts))
                        current_section_header = []
                        current_section_mounts = defaultdict(list)
                        current_section_name = None

                    # Start/continue building header
                    current_section_header.append(line)
                # Or if it's a section name line (no ===)
                else:
                    # Extract section name
                    match = re.search(r'--\s+([A-Za-z][A-Za-z\s&\(\)]+)', line)
                    if match and not current_section_name:
                        current_section_name = match.group(1).strip()
                    current_section_header.append(line)

            # Check for mount assignment
            elif '[' in line and ']' in line and '=' in line and '"' in line:
                parsed = parse_mount_assignment(line)
                if parsed:
                    mount_id, family_name, full_line = parsed
                    current_section_mounts[family_name].append((mount_id, full_line))
                else:
                    current_section_header.append(line)

            # Check for end of section
            elif line.strip() == '...' or (line.strip().startswith('}') and not in_family_definitions):
                # Save current section
                if current_section_name and (current_section_header or current_section_mounts):
                    all_mount_sections.append((current_section_name, current_section_header, current_section_mounts))

                # Sort all sections alphabetically and output
                all_mount_sections.sort(key=lambda x: x[0].lower())
                for section_name, section_header, section_mounts in all_mount_sections:
                    flush_mount_section(result_lines, section_header, section_mounts)

                # Reset
                all_mount_sections = []
                current_section_name = None
                current_section_header = []
                current_section_mounts = defaultdict(list)

                in_mount_to_family = False
                result_lines.append(line)

            # Other lines (comments, blank lines)
            else:
                if line.strip() != '':
                    current_section_header.append(line)

        # Handle FamilyDefinitions section
        elif in_family_definitions:
            # Check for section header comment (like "-- Bears")
            if line.strip().startswith('--') and not line.strip().startswith('----'):
                # Extract section name
                section_name_match = re.search(r'--\s+([A-Za-z][A-Za-z\s]+)', line)
                if section_name_match:
                    # Save previous section if exists
                    if current_family_section_name and (current_family_section_header or current_section_families):
                        # Save last family if exists
                        if current_family_name and current_family_lines:
                            current_section_families.append((current_family_name, current_family_lines))
                            current_family_name = None
                            current_family_lines = []

                        all_family_sections.append((current_family_section_name, current_family_section_header, current_section_families))
                        current_family_section_header = []
                        current_section_families = []

                    # Start new section
                    current_family_section_name = section_name_match.group(1).strip()
                    current_family_section_header.append(line)

            # Check for family definition start
            elif '["' in line and '"] = {':
                parsed = parse_family_definition(line)
                if parsed:
                    # Save previous family if exists
                    if current_family_name and current_family_lines:
                        current_section_families.append((current_family_name, current_family_lines))

                    # Start new family
                    family_name, full_line = parsed
                    current_family_name = family_name
                    current_family_lines = [full_line]

            # Lines belonging to current family definition
            elif current_family_name:
                current_family_lines.append(line)
                # Check if family definition is complete
                if line.strip() == '},':
                    current_section_families.append((current_family_name, current_family_lines))
                    current_family_name = None
                    current_family_lines = []

            # Check for end of section
            elif line.strip() == '...' or (line.strip().startswith('}') and 'FamilyDefinitions' not in line):
                # Save current section
                if current_family_section_name and (current_family_section_header or current_section_families):
                    # Save last family if exists
                    if current_family_name and current_family_lines:
                        current_section_families.append((current_family_name, current_family_lines))

                    all_family_sections.append((current_family_section_name, current_family_section_header, current_section_families))

                # Sort all sections alphabetically and output
                all_family_sections.sort(key=lambda x: x[0].lower())
                for section_name, section_header, section_families in all_family_sections:
                    flush_family_section(result_lines, section_header, section_families)

                # Reset
                all_family_sections = []
                current_family_section_name = None
                current_family_section_header = []
                current_section_families = []

                in_family_definitions = False
                result_lines.append(line)

            # Other lines
            else:
                if line.strip() != '':
                    current_family_section_header.append(line)

        # Outside special sections
        else:
            result_lines.append(line)

        i += 1

    # Write output
    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(result_lines)

    print(f"✓ Sorted {len(result_lines)} lines")
    return output_file


def flush_mount_section(result_lines, section_header, section_mounts):
    """Add a mount section with families sorted alphabetically and mounts by ID."""
    # Add section header, but skip blank lines
    for line in section_header:
        if line.strip() != '':  # Skip blank lines
            result_lines.append(line)

    # Sort families alphabetically
    sorted_families = sorted(section_mounts.keys())

    # Add mounts for each family
    for family_name in sorted_families:
        # Sort mounts by ID within this family
        mounts = sorted(section_mounts[family_name], key=lambda x: x[0])
        for mount_id, line in mounts:
            result_lines.append(line)


def flush_family_section(result_lines, section_header, section_families):
    """Add a family definitions section with families sorted alphabetically."""
    # Add section header
    for line in section_header:
        result_lines.append(line)

    # Sort families alphabetically by name
    sorted_families = sorted(section_families, key=lambda x: x[0])

    # Add each family's definition
    for family_name, family_lines in sorted_families:
        for line in family_lines:
            result_lines.append(line)
        # Add blank line after each family definition
        if family_lines and not family_lines[-1].endswith('\n\n'):
            result_lines.append('\n')


def main():
    """Main entry point."""
    # Get script directory
    script_dir = Path(__file__).parent.absolute()

    # If no arguments provided (double-clicked), use project structure
    if len(sys.argv) == 1:
        # Script is in: D:\Projects\RandomMountBuddy\_RMB tools and misc\Data Scripts\
        # Target is in: D:\Projects\RandomMountBuddy\Data\MountData.lua
        # Relative path: ..\..\Data\MountData.lua

        input_file = script_dir / '..' / '..' / 'Data' / 'MountData.lua'
        input_file = input_file.resolve()  # Resolve to absolute path

        if not input_file.exists():
            print("Error: MountData.lua not found")
            print(f"Expected location: {input_file}")
            print(f"\nMake sure the script is in: RandomMountBuddy\\_RMB tools and misc\\Data Scripts\\")
            print(f"And MountData.lua is in: RandomMountBuddy\\Data\\")
            input("Press Enter to exit...")
            sys.exit(1)

        # Output to same file (overwrite)
        output_file = input_file

        print(f"Auto-mode: Sorting MountData.lua")
        print(f"File: {input_file}")
        print(f"Mode: Overwrite (sorting in place)")
        print()

    elif len(sys.argv) < 2:
        print("Usage: python sort_mount_data.py [input_file] [output_file]")
        print("\nIf no arguments provided, will look for:")
        print("  ..\\..\\Data\\MountData.lua (relative to script location)")
        sys.exit(1)
    else:
        input_file = Path(sys.argv[1])
        output_file = Path(sys.argv[2]) if len(sys.argv) > 2 else None

        if not input_file.exists():
            print(f"Error: Input file '{input_file}' not found")
            sys.exit(1)

        print(f"Sorting mount data: {input_file}")
        if output_file:
            print(f"Output will be written to: {output_file}")
        else:
            print(f"File will be modified in place")

    try:
        sorted_file = sort_mount_data(input_file, output_file)
        print(f"✓ Successfully sorted: {sorted_file}")

        # If auto-mode (double-clicked), wait for user
        if len(sys.argv) == 1:
            input("\nPress Enter to exit...")
    except Exception as e:
        print(f"\n✗ Error: {e}")
        if len(sys.argv) == 1:
            input("\nPress Enter to exit...")
        sys.exit(1)


if __name__ == '__main__':
    main()