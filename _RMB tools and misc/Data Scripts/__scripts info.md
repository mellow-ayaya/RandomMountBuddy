## How to use RMB Data Scripts

1. Install Pyhton 3
2. Install reqeuests via cmd: pip install requests
3. Run _csv_download to automatically download the necessary files from Wago.tools: for _x_mount_info: Mount, MountXDisplay, CreatureDisplayInfo, CreatureModelData, community-listfile; for _x_mount_type: Mount, MountType
4. Run the _generate scripts if you want brand new files, or _update if you want to update the current ones



## Additional info

- The update scripts will probably only work if you run them from this path: RandomMountBuddy\_RMB tools and misc\Data Scripts in order to update the files from this path: RandomMountBuddy\Data
- After the update script finishes running it will move the files it used to the archive folder and any updated files to the backup folder; the _update_mount_info script won't move Mount.csv since _update_type_helpers needs it as well