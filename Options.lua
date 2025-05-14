-- Options.lua (Modify-in-Place strategy for FamilyManagement)

local currentAddonName = ...
print("RMB_OPTIONS: Options.lua START. Addon Name: " .. tostring(currentAddonName))

local addon = RandomMountBuddy
if not addon then
    print("RMB_OPTIONS: CRITICAL ERROR - RandomMountBuddy global is nil at Options.lua top!")
    return
end

-- Early check for functions that will be called by UI elements or the Populate function
if type(addon.PopulateFamilyManagementUI) ~= "function" then
    print(
    "RMB_OPTIONS_WARN: Critical addon method 'PopulateFamilyManagementUI' is missing! Family Management page refresh will fail.")
end
if type(addon.GetFavoriteMountsForOptions) ~= "function" then
    print("RMB_OPTIONS_WARN: Addon method 'GetFavoriteMountsForOptions' is missing! Mount Inspector page may fail.")
    addon.GetFavoriteMountsForOptions = function() return { mi_error = { order = 1, type = "description", name = "Inspector Func Error" } } end
end

local LibAceConfig = LibStub("AceConfig-3.0")
local LibAceConfigDialog = LibStub("AceConfigDialog-3.0")

if not (LibAceConfig and LibAceConfigDialog) then
    print("RMB_OPTIONS: CRITICAL ERROR - AceConfig or AceConfigDialog not found!")
    return
end

-- For Mount Inspector (pre-generated)
local favoriteMountsArgsTable = addon:GetFavoriteMountsForOptions()
if type(favoriteMountsArgsTable) ~= "table" then
    print("RMB_OPTIONS_ERROR: GetFavoriteMountsForOptions() did NOT return a table for Mount Inspector! Type: " ..
    tostring(type(favoriteMountsArgsTable)))
    favoriteMountsArgsTable = { inspector_data_error = { order = 1, type = "description", name = "Error generating Mount Inspector list." } }
end
print("RMB_OPTIONS: favoriteMountsArgsTable (for Mount Inspector) generated.")

-- KEY: Define familyManagement.args as an empty table initially.
-- Core.lua will get a reference to this table and populate it.
local initialFamilyManagementArgs = {
    -- This refresh button will call a function in Core.lua that repopulates this table
    initial_refresh_button = {
        order = 0, -- Show at the very top
        type = "execute",
        name = "Load / Refresh Mount Groups",
        func = function()
            print("RMB_OPTIONS_UI: Initial Refresh button clicked from Options.lua.")
            if addon.PopulateFamilyManagementUI then
                addon:PopulateFamilyManagementUI()
            else
                print("RMB_OPTIONS_UI_ERROR: PopulateFamilyManagementUI function missing on addon object.")
            end
        end,
        width = "full"
    },
    initial_status_message = {
        order = 1,
        type = "description",
        name = "Click 'Load / Refresh Mount Groups' to display the list once data is ready."
    }
}
-- Store this reference on the addon object so Core.lua can modify it.
addon.fmArgsRef = initialFamilyManagementArgs
print("RMB_OPTIONS: Stored reference to initialFamilyManagementArgs on addon.fmArgsRef.")


local optionsTable = {
    name = addon:GetName() and (addon:GetName() .. " Settings") or "Random Mount Buddy Settings",
    handler = addon,
    type = "group",
    args = {
        main = {
            type = "group",
            name = "Main Settings",
            order = 1,
            args = { -- Condensed main args for brevity; ensure your full ones are here
                generalHeader = { order = 1, type = "header", name = "General" },
                overrideBlizzardButton = { order = 3, type = "toggle", name = "Override Blizzard", get = function() return
                    addon:GetSetting("overrideBlizzardButton") end, set = function(i, v) addon:SetSetting(
                    "overrideBlizzardButton", v) end },
                useSuperGrouping = { order = 4, type = "toggle", name = "Use Super-Grouping", get = function() return
                    addon:GetSetting("useSuperGrouping") end, set = function(i, v) addon:SetSetting("useSuperGrouping", v) end },
                contextualSummoning = { order = 5, type = "toggle", name = "Contextual Summoning", get = function() return
                    addon:GetSetting("contextualSummoning") end, set = function(i, v) addon:SetSetting(
                    "contextualSummoning", v) end },
                traitStrictnessHeader = { order = 10, type = "header", name = "Trait Strictness" },
                treatMinorArmorAsDistinct = { order = 12, type = "toggle", name = "Minor Armor Distinct", get = function() return
                    addon:GetSetting("treatMinorArmorAsDistinct") end, set = function(i, v) addon:SetSetting(
                    "treatMinorArmorAsDistinct", v) end, disabled = function() return not addon:GetSetting(
                    "useSuperGrouping") end },
                treatMajorArmorAsDistinct = { order = 13, type = "toggle", name = "Major Armor Distinct", get = function() return
                    addon:GetSetting("treatMajorArmorAsDistinct") end, set = function(i, v) addon:SetSetting(
                    "treatMajorArmorAsDistinct", v) end, disabled = function() return not addon:GetSetting(
                    "useSuperGrouping") end },
                treatModelVariantsAsDistinct = { order = 14, type = "toggle", name = "Model Variants Distinct", get = function() return
                    addon:GetSetting("treatModelVariantsAsDistinct") end, set = function(i, v) addon:SetSetting(
                    "treatModelVariantsAsDistinct", v) end, disabled = function() return not addon:GetSetting(
                    "useSuperGrouping") end },
                treatUniqueEffectsAsDistinct = { order = 15, type = "toggle", name = "Unique Effects Distinct", get = function() return
                    addon:GetSetting("treatUniqueEffectsAsDistinct") end, set = function(i, v) addon:SetSetting(
                    "treatUniqueEffectsAsDistinct", v) end, disabled = function() return not addon:GetSetting(
                    "useSuperGrouping") end },
            }
        },
        familyManagement = {
            type = "group",
            name = "Family & Group Management",
            order = 2,
            args = initialFamilyManagementArgs, -- Assign the table directly
        },
        mountInspector = {
            type = "group",
            name = "Mount Inspector",
            order = 3,
            args = {
                header_inspector = { order = 1, type = "header", name = "Favorite Mounts Overview" },
                desc_inspector = { order = 2, type = "description", name = "Lists favorite mounts and their assigned family name.", fontSize = "medium" },
                mount_list_container = { order = 3, type = "group", name = " ", inline = true, args = favoriteMountsArgsTable, },
            },
        },
        groupWeights = {
            type = "group",
            name = "Group Weights",
            order = 4,
            args = { desc_weights = { order = 1, type = "description", name = "Assign weights to groups. (Placeholder)" } },
        },
    }
}
print("RMB_OPTIONS: Full options table defined with initial static args for FamilyManagement.")

LibAceConfig:RegisterOptionsTable(currentAddonName, optionsTable)
print("RMB_OPTIONS: Options table registered with AceConfig.")

local panel, categoryID = LibAceConfigDialog:AddToBlizOptions(currentAddonName,
    addon:GetName() and addon:GetName() or currentAddonName)
if panel then
    addon.optionsPanelObject = { frame = panel, id = categoryID or panel.name }
    print("RMB_OPTIONS: Added to Blizzard Interface Options. Panel Name/ID: " ..
    tostring(addon.optionsPanelObject.id or addon.optionsPanelObject.frame.name))
else
    print("RMB_OPTIONS: FAILED to add to Blizzard Interface Options.")
end

print("RMB_OPTIONS: Options.lua END.")
