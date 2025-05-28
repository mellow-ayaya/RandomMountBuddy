# 0.7.19
Traits can now be edited.

# 0.7.18
Moved uncollected mounts toggles to the filter menu.

# 0.7.17
Adjusted the expanded menus save state to behave as expected (reset between sessions).

# 0.7.16
Made the bulk weight controls only apply to the filtered mounts, for a more cohersive user experience.

# 0.7.15
Added element in the weight display to remind users that auto sync is on.

# 0.7.14
Fixed pagination moving upwards when there are less mounts listed than expected.

# 0.7.13
Fixed smart druid macro conditionals to prevent getting stuck in cat form.

# 0.7.12
Added syncing between favorited mounts and the addon's weight system.

# 0.7.11
Fixed hook issue between MountDataManager and SecureHandlers.
Fixed G99 not summoning in raid.
Fixed G99 sometimes trying to summon after changing zones from undermine to Dorn.

# 0.7.10
Fixed context summon.
Set the default weight for new mounts/families/groups to 3/Normal.
Added deterministic summon method.

# 0.7.9
Fixed Always weight to work as expected.
Added bulk weight change dropdown.

# 0.7.8
Added separate toggle for showing groups and families with no collected mounts.

# 0.7.7
Added filtering for the mount list.

# 0.7.6
Fixed misalignment of some elements in mount list.

# 0.7.5
Updated pagination.

# 0.7.4
Added search bar for mount list.

# 0.7.3
Added clear distinction between super groups, families and mounts by adding [G], [F] and [M] respectively before their names, with different colors.
Fixed Expand/Collapse button not hiding in all cases for individual mounts.

# 0.7.2
Fixed element order and missing headers in the mount list.

# 0.7.1
Finished integration of new modules from 0.7.0.

# 0.7.0
Split MountListUI into MountListUI, MountDataManager, MountPreview, MountTooltips, MountUIComponents.

# 0.6.13
Added functionality for trait checkboxes.

# 0.6.12
Rearranged Mount list elements again and added checkboxes to preview/edit the traits, actual implementation of toggles to follow.

# 0.6.11
Added G-99 Breakneck support for both areas.

# 0.6.10
Refactored SecureHandlers and removed falling macro conditional, which is now handled by lua.

# 0.6.9
Added support and toggles for Levitate and Slow Fall.
Added support for casting Ghost Wolf and Cat form while indoors.
Resolved issue with unknown macro conditional falling for Zen flight.

# 0.6.8
Added support and toggles for Ghost Wolf.
Added support and toggles for Zen Flight.

# 0.6.7
Added toggle for using travel form while moving and not cancelling travel form when it's already active.

# 0.6.6
Optimizations for keybind.

# 0.6.5
Keybind support now allows summoning a mount when sitting still or casting a spell (travel form, ghost wolf, zen flight) while moving.

# 0.6.4
Added semi functional keybind support.

# 0.6.3
Added flight style check for mounts that only support one flight style.

# 0.6.2
Added two more data files to help identify mount types for contextual summoning.
Added contextual summoning - no flying mounts in ground-only areas, no ground mounts in flying areas etc.

# 0.6.1
Added checkboxes that allow separating families from super groups based on tratis.

# 0.6.0
Added summoning by weight via slash command.

# 0.5.1
Mount list now uses mostly icons instead of regular buttons.
Options reformatted and checkbox for uncollected mounts added in main menu.
Moved general settings from the main settings submenu to the main menu.

# 0.5.0
Mount preview tooltip responsiveness improved

# 0.4.9
Moved UI functions from core to MountListUI

# 0.4.8
Improved family and groups menu element arrangement, added previewing for uncollected mounts.

# 0.4.7
Added support for uncollected mounts in the family and groups menu.

# 0.4.6
Improved preview by allowing it to anchor to the cursor again, plus allowing clicking on the preview button to create a separate window that can be dragged where desired + cycle through mounts + click to summon.

# 0.4.5
Added mount preview in the family & groups menu, via hovering over the preview button.
Rearranged elements in the UI.

# 0.4.5-click-to-preview
Added mount preview in the family & groups menu, it requires clicking on the preview button as opposed to showing in the tooltip.

# 0.4.4
Families that only contain one mount are now listed as Mountname (Mount) for easier identification, ie Wandering Ancient (Mount).

# 0.4.3
Family & Groups menu is much more compact and the families contained in groups are now clearly separated from the next group/family below.

# 0.4.2
UI update.

# 0.4.1
Fixed Expand/Collapse in Famiy menu.

# 0.4.0
The family list is now no longer causing huge FPS drops. Small UI redesign.

# 0.3.5
Added family lists in the UI, with options for weight and checkbox for enabling/disabling as well as a button for expanding the family to view the mounts inside.

# 0.3.0
Added data files loading and processing.
Added processing for user's mounts into the addon's internal categories.

# 0.2.0
Core and Options now work correctly and settings save between sessions.
Added Mount List in Options.

# 0.1.0
Alpha release