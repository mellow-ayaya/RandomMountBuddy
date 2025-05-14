-- Core.lua (Restored, with slash command)
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW

print("RMB_DEBUG: Core.lua START. Addon Name: " .. tostring(addonNameFromToc) .. ". Time: " .. tostring(time()))

local LibAceAddon = LibStub("AceAddon-3.0")
local LibAceDB = LibStub("AceDB-3.0")
local LibAceConsole = LibStub("AceConsole-3.0") -- For slash command

if not LibAceAddon then
    print("RMB_DEBUG: FATAL - AceAddon-3.0 not found!")
    return
end
if not LibAceDB then print("RMB_DEBUG: WARNING - AceDB-3.0 not found!") end
if not LibAceConsole then print("RMB_DEBUG: WARNING - AceConsole-3.0 not found!") end

local addon
local success, result = pcall(function()
    LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0") -- AceConsole needed for self:RegisterChatCommand
    addon = RandomMountBuddy
end)

if not success then
    print("RMB_DEBUG: ERROR during AceAddon:NewAddon call! Error: " .. tostring(result))
    return
else
    print("RMB_DEBUG: AceAddon:NewAddon call SUCCEEDED.")
    if not (addon and addon.GetName) then
        print("RMB_DEBUG: Addon object invalid after NewAddon.")
        return
    end
    print("RMB_DEBUG: Addon object valid. Name from GetName(): " .. tostring(addon:GetName()))
end

function addon:OnInitialize()
    print("RMB_DEBUG: OnInitialize CALLED.")

    -- Load Data
    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.MountToModelPath then
        self.MountToModelPath = RandomMountBuddy_PreloadData.MountToModelPath
        print("RMB_DEBUG: OnInitialize - MountToModelPath loaded (" ..
            #(self.MountToModelPath or {}) .. " entries approx from raw table count if array-like).")
    else
        self.MountToModelPath = {}
        print("RMB_DEBUG: OnInitialize - WARNING! MountToModelPath data not found.")
    end

    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.FamilyDefinitions then
        self.FamilyDefinitions = RandomMountBuddy_PreloadData.FamilyDefinitions
        print("RMB_DEBUG: OnInitialize - FamilyDefinitions loaded. Test for 'creature/direwolf/ridingdirewolf.m2': " ..
            tostring(self.FamilyDefinitions and self.FamilyDefinitions["creature/direwolf/ridingdirewolf.m2"]))
    else
        self.FamilyDefinitions = {}
        print("RMB_DEBUG: OnInitialize - WARNING! FamilyDefinitions data not found.")
    end
    RandomMountBuddy_PreloadData = nil
    print("RMB_DEBUG: OnInitialize - RandomMountBuddy_PreloadData cleared.")

    -- Init AceDB
    if LibAceDB then
        local dbDefaults = {
            profile = {
                overrideBlizzardButton = true,
                useSuperGrouping = true,
                contextualSummoning = true,
                treatMinorArmorAsDistinct = false,
                treatMajorArmorAsDistinct = false,
                treatModelVariantsAsDistinct = false,
                treatUniqueEffectsAsDistinct = true,
                familyOverrides = {},
                groupWeights = {},
            }
        }
        self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true)
        print("RMB_DEBUG: OnInitialize - AceDB initialized.")
    end

    -- Options are registered by Options.lua.
    -- It will store the frame handle (category object from AddToBlizOptions) on self.optionsPanelObject

    -- Register Slash Command
    if LibAceConsole then
        self:RegisterChatCommand("rmb", "SlashCommandHandler")
        self:RegisterChatCommand("randommountbuddy", "SlashCommandHandler")
        print("RMB_DEBUG: OnInitialize - Slash commands registered.")
    end
    print("RMB_DEBUG: OnInitialize END.")
end

-- In Core.lua
function addon:SlashCommandHandler(input)
    input = input and input:trim() or ""
    print("RMB_DEBUG: Slash command used with input: [" .. input .. "]")

    if self.optionsPanelObject then
        local idToOpen = self.optionsPanelObject.id
        local frameToOpen = self.optionsPanelObject.frame

        print("RMB_DEBUG: Trying to open options. ID: " ..
        tostring(idToOpen) .. ", Frame type: " .. tostring(type(frameToOpen)))

        if idToOpen then
            -- Settings.OpenToCategory can take the string name/ID or the numerical ID if available.
            -- The 'id' we stored from AddToBlizOptions (which was categoryID or panel.name) is what we need.
            local success, err = pcall(Settings.OpenToCategory, idToOpen)
            if success then
                print("RMB_DEBUG: Attempted Settings.OpenToCategory('" .. tostring(idToOpen) .. "')")
            else
                print("RMB_DEBUG: ERROR with Settings.OpenToCategory('" .. tostring(idToOpen) .. "'): " .. tostring(err))
                -- Fallback if Settings.OpenToCategory fails or isn't suitable for the 'id' type
                if frameToOpen then
                    print("RMB_DEBUG: Falling back to InterfaceOptionsFrame_OpenToCategory with frame object.")
                    InterfaceOptionsFrame_OpenToCategory(frameToOpen)
                else
                    print("RMB_DEBUG: No valid ID or frame to open options panel.")
                end
            end
        elseif frameToOpen then
            -- Fallback if 'id' was somehow nil but 'frame' exists
            print("RMB_DEBUG: 'id' was nil, attempting InterfaceOptionsFrame_OpenToCategory with frame object.")
            InterfaceOptionsFrame_OpenToCategory(frameToOpen)
        else
            print("RMB_DEBUG: Both 'id' and 'frame' in optionsPanelObject are nil. Cannot open.")
        end
    else
        print("RMB_DEBUG: Options panel object not yet available (self.optionsPanelObject is nil).")
    end
end

function addon:OnEnable()
    print("RMB_DEBUG: OnEnable CALLED.")
end

-- Getter/Setter for AceConfig options (used by Options.lua)
function addon:GetSetting(key)
    if not (self.db and self.db.profile) then return nil end -- Or a default from initial spec
    return self.db.profile[key]
end

function addon:SetSetting(key, value)
    if not (self.db and self.db.profile) then return end
    self.db.profile[key] = value
    -- Potentially trigger updates if a setting change requires immediate action
    print("RMB_DEBUG: Setting changed - Key: " .. tostring(key) .. ", Value: " .. tostring(value))
end

print("RMB_DEBUG: Core.lua END.")
