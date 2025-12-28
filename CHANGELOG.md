# 1.1.21 - 2025-12-28
- Removed extra line from Utility mounts tooltip

# 1.1.20 - 2025-12-28
- Improved description on for 'Show Uniques in Groups' toggle (previously called Unique Mounts in Groups)
- 'Show Uniques in Groups' is now correctly toggled on by default
- The checkboxes for toggling whether uncollected mounts and groups appear in the Mount Browser work as intended now.
- Added a new feature: Utility mounts anchored to the bottom of the esc menu, enabled by default.
- Squeakers successfully made it out of the nil group (oopsie)
- 1.1.10 also included a new notification that warns you if you haven't set a keybind for RMB yet, which can be disabled with /rmb kbnotification.

# 1.1.10 - 2025-12-27
- Traits overhauled into a much simpler version: specific mounts are labelled as unique. If you want to see the unique mounts more often, enable the new setting "Favor Unique Mounts".
- Updated icon for Unique trait.
- Updated most text/descriptions and UI relating to traits.
- Large scale update on which mounts are considered unique. Users can still adjust this from their end.
- Fixed a bug that was making the Unique trait icon not show in the Mount Browser sometimes.
- Removed the settings for Mount List from the Main tab since they are present in the filter tab anyway.
- Cleaned up old test file.
- Actually disabled rules in the old menu now (for realsies this time).

# 1.1.00 - 2025-12-27
- Added a new UI element to serve as main menu and mount previewer: Mount Browser. It contains all the functionality of the existing options (except Advanced Settings) but looks much nicer.
- Revamped rules, changed name from ZoneSpecificMounts.lua to MountRules.lua to match the new scope.
- Rules moved out of the Advanced Settings, they can be found in the Mount Browser as well.
- New rules conditionals for whether you're in a group, and whether you're in a group with a friend, BNet friend or guildie.
- Added 2 default rules, enabled by default: flying pool for M+ portal room and for class halls (to avoid having to remount after porting outside).
- Added toggle-able minimap button and addon compartment icon.
- Improved verbiage and descriptions in the main menu as well as the Advanced Settings guide.
- Added recommendation to keep certain settings enabled for the intended experience.
- Added a dev tool to help with the browser's camera settings for different mounts.
- Massive families and groups updates due to the huge help of viewing several mounts at once via the Browser + dev tool.

# 1.0.24 - 2025-12-09
- Background changes to data structure to hopefully make adding new mounts easier.
- Moved Antoran Charhound & Gloomhound to the new Antoran Flying Hound family.
- Moved Falcosaur family under Raptor group
- Moved Farseer's Felscorned and Archmage's Felscorned mounts into the same family as the original
- Fixed issue with preview sometimes showing the wrong mount

# 1.0.23 - 2025-12-08
- Added rules to the Advanced menu, which allow you to specify a mount or multiple mounts to use in a specific map/zone/instance, or in a specific instance type.
- Fixed mount preview listing all mount as Ground type.
- Fixed Dread Ravens typo.
- Fixed Flying Horses typo.
- Split Hawks group into Elemental Hawks and Hawks due to having different models.
- Assigned Great ravens to Hawks group.
- Merged Peafowls intro Hawks group.
- Renamed Ravens to Ground Ravens for clarity
- Assigned Geargrinder and Meatwagon to Grinders group.
- Assigned Lana'thel's Crimson Cascade to Elementals.
- Moved Antoran Charhound & Gloomhound to Plaguebats group.
- Added Cinderbees to Bee group.
- Updated Readme.
- TOC push, 12.0 ready

# 1.0.22 - 2025-12-01
- Changed Voidwing Dragonhawk from standalone mount to the Infused Dragonhawk family.

# 1.0.21 - 2025-10-30
- Updated Bonesteed of Triumph, Bloodshed, Plague and Oblivion to non flying. Yay...

# 1.0.20 - 2025-10-19
- Moved Highmountain Eagles to Eagle family, under Birds (flying idle) supergroup.
- Renamed old Eagle family and supergroup (which used to contain Ohuna mounts) to Ohuna and Ohunas respectively.
- Changed Lucky Yun from no supergroup to Oxes supergroup.
- Added Astral Aurochs to Oxes supergroup.
- Added some data for upcoming mounts.
- Resolved UI misalignment that happened when expanding a mount group/family.
- TOC push

# 1.0.19 - 2025-09-19
- TOC push

# 1.0.18 - 2025-09-19
- Fixed mount list refresh spam that was happening on low level characters even when not learning a new mount.
- Added (hopefully) all mounts up until 11.2.5 to families and supergroups.
- Changed Stormcrows from supergroup to family.
- Added Albatross, Stormcrows, Rogue classhall mount, Parrots and upcoming Eagles to Birds (flying idle) supergroup.

# 1.0.17 - 2025-07-17
- Fixed mount pool refresh not always happening on weight changes.

# 1.0.16 - 2025-07-17
- Added Jelly to Jellyfishes group (whoops) and as a result, toggled on Heavy Armor checkbox for Aurelids.
- Changed logic for Improved randomness so that when enabled, it no longer gets confused if the user spams the mount button.

# 1.0.15 - 2025-07-17
- Added auto detection for mounts that haven't been manually added, they can be summoned and interacted with normally. Traits and Advanced settings are not supported for these mounts because it would probably break stuff when I manually add them to the addon (which should only be a few days at most).
- Updated data files so that the latest mounts are supported.

# 1.0.14 - 2025-06-30
- Fixed occasionally summoning a random mount instead of G99.

# 1.0.13 - 2025-06-30
- Attempted fix for rarely being unable to summon mounts after teleporting, added debug in case issue persists.
- Tidied up old comments that still said "New:", "Updated:", "Fixed:" etc, for changes that were made a while back.

# 1.0.12 - 2025-06-29
- Fixed not being able to summon during and after the Tindral fight.

# 1.0.11 - 2025-06-23
- Changelog.md format update
- Packaging fix (oops..)

# 1.0.10 - 2025-06-23
- Fixed annoying class spell triggering when trying to dismount in midair and updated error hiding command.
- Changed default for Keep Zen Flight active from true to false, since it doesn't behave like Travel/Cat form and Ghost Wolf.
- TOC update.

# 1.0.9 - 2025-06-15
- Added comments in ManualFamilyDefinitions to help categorize mounts in the future.
- Improved Curseforge packaging.

# 1.0.8 - 2025-06-15
- Fixed Adjust all weights dropdown in Mount list.
-Made sparate mounts UI in the Advanced menu more consistent.

# 1.0.7 - 2025-06-15
- Changed Contextual summoning Off behavior: it no longer tries to summon ground mounts in flying areas.
- Aquatic mounts will always be summoned underwater with regardless of the Contextual summoning checkbox, falling back on a random mount if no aquatic mounts are available.

# 1.0.6 - 2025-06-09
- Curseforge push attempt #3

# 1.0.5 - 2025-06-08
- Curseforge push attempt #2

# 1.0.4 - 2025-06-08
- Curseforge release

# 1.0.3 - 2025-06-06
- Added more slash commands: /rmb s - summon mount, /rmb & /rmb help show all "regular" slash commands, /rmb config to open UI.

# 1.0.2 - 2025-06-06
- Updated keybind name to make the keybind actually work.

# 1.0.1 - 2025-06-05
- Cleaned up unused files.

# 1.0.0 - 2025-06-05
- Initial Release