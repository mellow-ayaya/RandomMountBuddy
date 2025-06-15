import requests
import time
import os
import sys
from datetime import datetime
import re
from urllib.parse import urlparse, unquote

# Configuration
DOWNLOAD_DELAY = 1.5  # seconds between downloads - be respectful
USER_AGENT = "WoW Data Processing Tool (Personal/Educational Use)"
TIMEOUT = 60  # seconds

# Get script directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# File definitions: (URL, expected_filename_prefix)
FILES_TO_DOWNLOAD = [
    ("https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv", "listfile"),
    ("https://wago.tools/db2/Mount/csv", "Mount"),
    ("https://wago.tools/db2/CreatureDisplayInfo/csv", "CreatureDisplayInfo"),
    ("https://wago.tools/db2/CreatureModelData/csv", "CreatureModelData"),
    ("https://wago.tools/db2/MountXDisplay/csv", "MountXDisplay"),
    ("https://wago.tools/db2/MountType/csv", "MountType"),
]

def get_filename_from_response(response, fallback_prefix):
    """
    Get the filename from the response headers or URL.
    Falls back to a default name if none found.
    """
    # Try to get filename from Content-Disposition header
    content_disposition = response.headers.get('Content-Disposition', '')
    if 'filename=' in content_disposition:
        # Extract filename from header like: attachment; filename="Mount.11.1.7.61406.csv"
        filename_match = re.search(r'filename[^;=\n]*=["\']?([^"\';\n]*)', content_disposition)
        if filename_match:
            return filename_match.group(1).strip()

    # Try to get filename from URL path
    parsed_url = urlparse(response.url)
    url_filename = os.path.basename(unquote(parsed_url.path))
    if url_filename and url_filename.endswith('.csv'):
        return url_filename

    # Fallback to prefix with timestamp
    timestamp = datetime.now().strftime("%Y%m%d")
    return f"{fallback_prefix}.{timestamp}.csv"

def download_file(url, filename_prefix):
    """Download a file from URL with proper error handling and naming"""

    headers = {
        'User-Agent': USER_AGENT,
        'Accept': 'text/csv,application/csv,text/plain,*/*'
    }

    try:
        print(f"Downloading {filename_prefix} from {url}...")

        response = requests.get(url, headers=headers, timeout=TIMEOUT)
        response.raise_for_status()

        # Get the filename from response (should include version if server provides it)
        filename = get_filename_from_response(response, filename_prefix)
        filepath = os.path.join(SCRIPT_DIR, filename)

        # Write the content to file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(response.text)

        file_size = len(response.text)
        print(f"✓ Downloaded {filename} ({file_size:,} characters)")

        return True, filename

    except requests.exceptions.RequestException as e:
        print(f"✗ Failed to download {filename_prefix}: {e}")
        return False, None
    except Exception as e:
        print(f"✗ Unexpected error downloading {filename_prefix}: {e}")
        return False, None

def check_existing_files():
    """Check for existing files and warn user"""
    existing_files = []

    for _, prefix in FILES_TO_DOWNLOAD:
        pattern = f"{prefix}*.csv"
        import glob
        matches = glob.glob(os.path.join(SCRIPT_DIR, pattern))
        if matches:
            for match in matches:
                existing_files.append(os.path.basename(match))

    if existing_files:
        print("Existing files found:")
        for file in existing_files:
            print(f"  - {file}")

        response = input("\nDo you want to continue and potentially overwrite files? (y/N): ")
        if response.lower() not in ['y', 'yes']:
            print("Download cancelled.")
            return False

    return True

def main():
    """Main download process"""
    print("WoW Data File Downloader")
    print("=" * 50)
    print(f"Download directory: {SCRIPT_DIR}")
    print(f"Files to download: {len(FILES_TO_DOWNLOAD)}")
    print()

    # Check for existing files
    if not check_existing_files():
        return

    print("Starting downloads...")
    print()

    successful_downloads = []
    failed_downloads = []

    for i, (url, prefix) in enumerate(FILES_TO_DOWNLOAD, 1):
        print(f"[{i}/{len(FILES_TO_DOWNLOAD)}] ", end="")

        success, filename = download_file(url, prefix)

        if success:
            successful_downloads.append(filename)
        else:
            failed_downloads.append(prefix)

        # Add delay between downloads (except for the last one)
        if i < len(FILES_TO_DOWNLOAD):
            time.sleep(DOWNLOAD_DELAY)

    # Summary
    print()
    print("Download Summary")
    print("=" * 50)

    if successful_downloads:
        print(f"✓ Successfully downloaded {len(successful_downloads)} files:")
        for filename in successful_downloads:
            print(f"  - {filename}")

    if failed_downloads:
        print(f"\n✗ Failed to download {len(failed_downloads)} files:")
        for prefix in failed_downloads:
            print(f"  - {prefix}")
        print("\nYou may need to download these manually.")

    if successful_downloads and not failed_downloads:
        print(f"\n🎉 All files downloaded successfully!")
        print("You can now run your processing scripts.")
    elif successful_downloads:
        print(f"\n⚠️  Partial success. {len(successful_downloads)} files downloaded, {len(failed_downloads)} failed.")
    else:
        print(f"\n❌ All downloads failed. Please check your internet connection.")

    print()
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()