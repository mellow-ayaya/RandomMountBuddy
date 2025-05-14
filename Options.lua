-- Options.lua (Call dynamic function at table definition time)

local currentAddonName = ...
print("RMB_OPTIONS: Options.lua START. Addon Name: " .. tostring(currentAddonName))

local addon = RandomMountBuddy
if not addon then
    print("RMB_OPTIONS: CRITICAL ERROR - RandomMountBuddy global is nil at Options.lua top!")
    return
end
if type(addon.GetSetting) ~= "function" then print("RMB_OPTIONS: WARNING - addon.GetSetting is not a function.") end
if not addon.GetFavoriteMountsForOptions then -- Check if the function exists on addon
    print("RMB_OPTIONS: CRITICAL ERROR - addon.GetFavoriteMountsForOptions method does not exist on addon object!")
    -- Define a dummy one to prevent further errors if it's missing, though it should exist
    addon.GetFavoriteMountsForOptions = function()
        print("RMB_OPTIONS_ERROR: Dummy GetFavoriteMountsForOptions called because original was missing!")
        return { error_msg = { order = 1, type = "description", name = "Error: Mount list function missing." } }
    end
end


local LibAceConfig = LibStub("AceConfig-3.0")
local LibAceConfigDialog = LibStub("AceConfigDialog-3.0")

if not (LibAceConfig and LibAceConfigDialog) then
    print("RMB_OPTIONS: CRITICAL ERROR - AceConfig or AceConfigDialog not found!")
    return
end

-- Call the function from Core.lua HERE to get the table for mount_list_container.args
-- This ensures 'addon' is valid at this point.
print("RMB_OPTIONS: Attempting to call addon:GetFavoriteMountsForOptions() to build mount list args...")
local favoriteMountsArgsTable = addon:GetFavoriteMountsForOptions() -- Get the table directly

if type(favoriteMountsArgsTable) ~= "table" then
    print("RMB_OPTIONS_ERROR: addon:GetFavoriteMountsForOptions() did NOT return a table! Type: " ..
    tostring(type(favoriteMountsArgsTable)))
    favoriteMountsArgsTable = { error_in_data = { order = 1, type = "description", name = "Error generating mount list." } }
end
print("RMB_OPTIONS: favoriteMountsArgsTable created, type: " .. tostring(type(favoriteMountsArgsTable)))


local optionsTable = {
    name = addon:GetName() and (addon:GetName() .. " Settings") or "Random Mount Buddy Settings", -- Title for the options panel
    handler = addon,
    type = "group",
    args = {
        main = {
            type = "group",
            name = "Main Settings",
            order = 1,
            args = {
                generalHeader = { order = 1, type = "header", name = "General" },
                desc_main = { order = 2, type = "description", name = "Configure the core behavior of Random Mount Buddy.", fontSize = "medium" },
                overrideBlizzardButton = {
                    order = 3,
                    type = "toggle",
                    name = "Override Blizzard's Random Button",
                    desc = "If checked, RMB will take over 'Summon Random Favorite Mount'.",
                    get = function(info) return addon:GetSetting("overrideBlizzardButton") end,
                    set = function(info, value) addon:SetSetting("overrideBlizzardButton", value) end,
                },
                useSuperGrouping = {
                    order = 4,
                    type = "toggle",
                    name = "Use Super-Grouping",
                    desc = "Group mounts by 'superGroup' by default. If unchecked, groups by 'familyName'.",
                    get = function(info) return addon:GetSetting("useSuperGrouping") end,
                    set = function(info, value) addon:SetSetting("useSuperGrouping", value) end,
                },
                contextualSummoning = {
                    order = 5,
                    type = "toggle",
                    name = "Enable Contextual Summoning",
                    desc = "Automatically filter mounts based on current location/situation.",
                    get = function(info) return addon:GetSetting("contextualSummoning") end,
                    set = function(info, value) addon:SetSetting("contextualSummoning", value) end,
                },
                traitStrictnessHeader = { order = 10, type = "header", name = "Trait-Based Strictness (if Super-Grouping is enabled)" },
                desc_trait_strictness = { order = 11, type = "description", name = "If 'Use Super-Grouping' is enabled, these settings determine if a mount 'breaks out' of its superGroup.", fontSize = "medium" },
                treatMinorArmorAsDistinct = {
                    order = 12,
                    type = "toggle",
                    name = "Treat Minor Armor as Distinct",
                    get = function(info) return addon:GetSetting("treatMinorArmorAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatMinorArmorAsDistinct", value) end,
                    disabled = function() return not (addon and addon:GetSetting("useSuperGrouping")) end,
                },
                treatMajorArmorAsDistinct = {
                    order = 13,
                    type = "toggle",
                    name = "Treat Major Armor as Distinct",
                    get = function(info) return addon:GetSetting("treatMajorArmorAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatMajorArmorAsDistinct", value) end,
                    disabled = function() return not (addon and addon:GetSetting("useSuperGrouping")) end,
                },
                treatModelVariantsAsDistinct = {
                    order = 14,
                    type = "toggle",
                    name = "Treat Model Variants as Distinct",
                    get = function(info) return addon:GetSetting("treatModelVariantsAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatModelVariantsAsDistinct", value) end,
                    disabled = function() return not (addon and addon:GetSetting("useSuperGrouping")) end,
                },
                treatUniqueEffectsAsDistinct = {
                    order = 15,
                    type = "toggle",
                    name = "Treat Unique Effects/Skins as Distinct",
                    get = function(info) return addon:GetSetting("treatUniqueEffectsAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatUniqueEffectsAsDistinct", value) end,
                    disabled = function() return not (addon and addon:GetSetting("useSuperGrouping")) end,
                },
            },
        },

        familyManagement = {
            type = "group",
            name = "Family & Group Management",
            order = 2,
            args = { desc_family = { order = 1, type = "description", name = "Customize families, super-groups, traits. (Coming Soon!)" } },
        },
        groupWeights = {
            type = "group",
            name = "Group Weights",
            order = 3,
            args = { desc_weights = { order = 1, type = "description", name = "Assign weights to groups. (Coming Soon!)" } },
        },
        mountInspector = {
            type = "group",
            name = "Mount Inspector",
            order = 4,
            args = {
                header_inspector = { order = 1, type = "header", name = "Favorite Mounts Overview" },
                desc_inspector = { order = 2, type = "description", name = "Lists your favorite mounts and their assigned family name.", fontSize = "medium" },
                mount_list_container = {
                    order = 3,
                    type = "group",
                    name = " ",
                    inline = true,
                    args = favoriteMountsArgsTable, -- Assign the pre-generated table here
                },
            },
        },
    }
}
print("RMB_OPTIONS: Full options table defined.")

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
