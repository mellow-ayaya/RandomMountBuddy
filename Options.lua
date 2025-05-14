-- Options.lua (Using AddToBlizOptions and full spec structure)

local currentAddonName = ... -- This will be "RandomMountBuddy"
print("RMB_OPTIONS: Options.lua START. Addon Name: " .. tostring(currentAddonName))

local addon = RandomMountBuddy
if not addon then
    print("RMB_OPTIONS: CRITICAL ERROR - RandomMountBuddy global is nil!")
    return
end

local LibAceConfig = LibStub("AceConfig-3.0")
local LibAceConfigDialog = LibStub("AceConfigDialog-3.0") -- We need this for AddToBlizOptions

if not (LibAceConfig and LibAceConfigDialog) then
    print("RMB_OPTIONS: CRITICAL ERROR - AceConfig or AceConfigDialog not found!")
    return
end

-- Define the full options table as per your original specification
local optionsTable = {
    name = addon:GetName() .. " Settings", -- Title for the options panel
    handler = addon,                       -- The addon object will handle get/set methods
    type = "group",
    args = {
        -- Main Page (from your spec)
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
                    disabled = function() return not addon:GetSetting("useSuperGrouping") end,
                },
                treatMajorArmorAsDistinct = {
                    order = 13,
                    type = "toggle",
                    name = "Treat Major Armor as Distinct",
                    get = function(info) return addon:GetSetting("treatMajorArmorAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatMajorArmorAsDistinct", value) end,
                    disabled = function() return not addon:GetSetting("useSuperGrouping") end,
                },
                treatModelVariantsAsDistinct = {
                    order = 14,
                    type = "toggle",
                    name = "Treat Model Variants as Distinct",
                    get = function(info) return addon:GetSetting("treatModelVariantsAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatModelVariantsAsDistinct", value) end,
                    disabled = function() return not addon:GetSetting("useSuperGrouping") end,
                },
                treatUniqueEffectsAsDistinct = {
                    order = 15,
                    type = "toggle",
                    name = "Treat Unique Effects/Skins as Distinct",
                    get = function(info) return addon:GetSetting("treatUniqueEffectsAsDistinct") end,
                    set = function(info, value) addon:SetSetting("treatUniqueEffectsAsDistinct", value) end,
                    disabled = function() return not addon:GetSetting("useSuperGrouping") end,
                },
            },
        },
        -- Placeholder for Family & Group Management Page
        familyManagement = {
            type = "group",
            name = "Family & Group Management",
            order = 2,
            args = { desc_family = { order = 1, type = "description", name = "Customize families, super-groups, traits. (Coming Soon!)" } },
        },
        -- Placeholder for Group Weights Page
        groupWeights = {
            type = "group",
            name = "Group Weights",
            order = 3,
            args = { desc_weights = { order = 1, type = "description", name = "Assign weights to groups. (Coming Soon!)" } },
        },
    }
}
print("RMB_OPTIONS: Full options table defined.")

-- Register the options table with AceConfig
LibAceConfig:RegisterOptionsTable(currentAddonName, optionsTable) -- No 'true' needed here if slash command handled by AceConsole in Core.lua
print("RMB_OPTIONS: Options table registered with AceConfig.")

-- Add the options to the Blizzard Interface Options panel
-- This is the crucial change:
local panel, categoryID = LibAceConfigDialog:AddToBlizOptions(currentAddonName, addon:GetName()) -- Use addon's proper name for display
if panel then
    addon.optionsPanelObject = { frame = panel, id = categoryID or panel.name }                  -- Store for slash command
    -- For WoW 10.0+, categoryID is preferred for Settings.OpenToCategory
    -- panel.name is a fallback if categoryID is nil (older WoW/Ace versions)
    print("RMB_OPTIONS: Added to Blizzard Interface Options. Panel Name/ID: " ..
        tostring(addon.optionsPanelObject.id or addon.optionsPanelObject.frame.name))
else
    print("RMB_OPTIONS: FAILED to add to Blizzard Interface Options.")
end

print("RMB_OPTIONS: Options.lua END.")
