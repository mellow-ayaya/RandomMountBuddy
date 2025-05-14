-- Core.lua (Full version with enhanced DB/Settings logging)
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW -- Make the addon's table global

-- Define dbDefaults at a scope accessible by OnInitialize and GetSetting/SetSetting
local dbDefaults = {
    profile = {
        overrideBlizzardButton = true,
        useSuperGrouping = true,
        contextualSummoning = true,
        treatMinorArmorAsDistinct = false,
        treatMajorArmorAsDistinct = false,
        treatModelVariantsAsDistinct = false,
        treatUniqueEffectsAsDistinct = true,
        familyOverrides = {}, -- For future UI: e.g., familyOverrides["Classic Wolf"] = { superGroup = "My Custom Pack" }
        groupWeights = {},    -- For future UI: e.g., groupWeights["Wolf Pack"] = 2
    }
}

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

local addon -- Will be assigned after NewAddon
local success, result = pcall(function()
    LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0")
    addon = RandomMountBuddy -- RandomMountBuddy (the global) is now the AceAddon object
end)

if not success then
    print("RMB_DEBUG: ERROR during AceAddon:NewAddon call! Error: " .. tostring(result))
    return
else
    print("RMB_DEBUG: AceAddon:NewAddon call SUCCEEDED.")
    if not (addon and addon.GetName) then
        print("RMB_DEBUG: Addon object invalid after NewAddon (GetName method missing).")
        return
    end
    print("RMB_DEBUG: Addon object valid. Name from GetName(): " .. tostring(addon:GetName()))
end

function addon:OnInitialize()
    print("RMB_DEBUG: OnInitialize CALLED.")

    -- Load Data
    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.MountToModelPath then
        self.MountToModelPath = RandomMountBuddy_PreloadData.MountToModelPath
        local count = 0
        if type(self.MountToModelPath) == "table" then for _ in pairs(self.MountToModelPath) do count = count + 1 end end
        print("RMB_DEBUG: OnInitialize - MountToModelPath loaded (" .. count .. " entries).")
    else
        self.MountToModelPath = {}
        print("RMB_DEBUG: OnInitialize - WARNING! MountToModelPath data not found.")
    end

    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.FamilyDefinitions then
        self.FamilyDefinitions = RandomMountBuddy_PreloadData.FamilyDefinitions
        local count = 0
        if type(self.FamilyDefinitions) == "table" then for _ in pairs(self.FamilyDefinitions) do count = count + 1 end end
        print("RMB_DEBUG: OnInitialize - FamilyDefinitions loaded (" ..
            count ..
            " entries). Test for 'creature/direwolf/ridingdirewolf.m2': " ..
            tostring(self.FamilyDefinitions and self.FamilyDefinitions["creature/direwolf/ridingdirewolf.m2"]))
    else
        self.FamilyDefinitions = {}
        print("RMB_DEBUG: OnInitialize - WARNING! FamilyDefinitions data not found.")
    end
    RandomMountBuddy_PreloadData = nil -- Clear the global staging table
    print("RMB_DEBUG: OnInitialize - RandomMountBuddy_PreloadData cleared.")

    -- Init AceDB
    if LibAceDB then
        -- dbDefaults is defined at the top of this file
        self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true) -- true for defaultProfileOnly (account-wide)
        print("RMB_DEBUG: OnInitialize - AceDB:New call completed.")
        if self.db and self.db.profile then
            print("RMB_DEBUG: OnInitialize - self.db.profile exists. Current 'overrideBlizzardButton' from DB on init: " ..
                tostring(self.db.profile.overrideBlizzardButton))
        else
            print("RMB_DEBUG: OnInitialize - self.db OR self.db.profile is NIL after AceDB:New!")
        end
    else
        print("RMB_DEBUG: OnInitialize - LibAceDB not available, skipping AceDB initialization.")
    end

    -- Options are registered by Options.lua.
    -- It will store the panel object from AddToBlizOptions on self.optionsPanelObject

    -- Register Slash Command
    if LibAceConsole then
        self:RegisterChatCommand("rmb", "SlashCommandHandler")
        self:RegisterChatCommand("randommountbuddy", "SlashCommandHandler")
        print("RMB_DEBUG: OnInitialize - Slash commands registered.")
    else
        print("RMB_DEBUG: OnInitialize - LibAceConsole not available, skipping slash command registration.")
    end
    print("RMB_DEBUG: OnInitialize END.")
    if self.db and LibAceDB.GetBlizzardDB then -- GetBlizzardDB is an internal AceDB func but can give clues
        local blizzardSideTable = LibAceDB:GetBlizzardDB("RandomMountBuddy_SavedVars")
        print("RMB_DEBUG: OnInitialize - AceDB's GetBlizzardDB for RandomMountBuddy_SavedVars returns type: " ..
            tostring(type(blizzardSideTable)))
        if type(blizzardSideTable) == "table" then
            print("RMB_DEBUG: OnInitialize - Blizzard-side table for SVars has 'profile' key? Type: " ..
                tostring(type(blizzardSideTable.profile)))
        end
    end
end

function addon:SlashCommandHandler(input)
    input = input and input:trim() or ""
    print("RMB_DEBUG: Slash command used with input: [" .. input .. "]")

    if self.optionsPanelObject then
        local idToOpen = self.optionsPanelObject.id
        local frameToOpen = self.optionsPanelObject.frame
        print("RMB_DEBUG: Trying to open options. ID: " ..
            tostring(idToOpen) .. ", Frame type: " .. tostring(type(frameToOpen)))

        if idToOpen then
            local success, err = pcall(Settings.OpenToCategory, idToOpen)
            if success then
                print("RMB_DEBUG: Attempted Settings.OpenToCategory('" .. tostring(idToOpen) .. "')")
            else
                print("RMB_DEBUG: ERROR with Settings.OpenToCategory('" .. tostring(idToOpen) .. "'): " .. tostring(err))
                if frameToOpen then
                    print("RMB_DEBUG: Falling back to InterfaceOptionsFrame_OpenToCategory with frame object.")
                    InterfaceOptionsFrame_OpenToCategory(frameToOpen)
                else
                    print("RMB_DEBUG: No valid ID or frame to open options panel.")
                end
            end
        elseif frameToOpen then
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
    -- You could add a check here to see what self.db.profile contains after a reload,
    -- before any GetSetting calls from AceConfig fill it.
    -- For example:
    -- if self.db and self.db.profile then
    --     print("RMB_DEBUG: OnEnable - 'overrideBlizzardButton' from DB: " .. tostring(self.db.profile.overrideBlizzardButton))
    -- end
end

function addon:GetMountFamilyName(mountID)
    if not mountID then return "Unknown ID" end

    local modelPath = self.MountToModelPath and self.MountToModelPath[tonumber(mountID)]
    if not modelPath then
        -- Try to get display info directly if model path unknown
        local creatureName, _, _, _, _, _, _, _, _, _, _, _, isFavorite, _, _, _, _, _ = C_MountJournal.GetMountInfoByID(
        mountID)
        if creatureName then return creatureName .. " (No model path in data)" end
        return "Unknown (ID: " .. mountID .. ")"
    end

    local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]
    if not familyDef or not familyDef.familyName then
        local creatureName, _, _, _, _, _, _, _, _, _, _, _, isFavorite, _, _, _, _, _ = C_MountJournal.GetMountInfoByID(
        mountID)
        if creatureName then return creatureName .. " (No family def for: " .. modelPath .. ")" end
        return "No Family Def (Path: " .. modelPath .. ")"
    end
    return familyDef.familyName
end

function addon:GetFavoriteMountsForOptions()
    print("RMB_DEBUG: GetFavoriteMountsForOptions called")
    local mountArgs = {}
    local displayOrder = 1

    local allMountIDs = C_MountJournal.GetMountIDs()
    if not allMountIDs then
        print("RMB_DEBUG: GetMountIDs returned nil")
        mountArgs["no_mounts_api"] = {
            order = displayOrder,
            type = "description",
            name = "Could not retrieve mount list from WoW API."
        }
        return mountArgs
    end

    print("RMB_DEBUG: Total mounts known by API: " .. #allMountIDs)
    local favoriteCount = 0

    for i, mountID in ipairs(allMountIDs) do
        local creatureName, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountTypeID =
        C_MountJournal.GetMountInfoByID(mountID)

        if isCollected and isFavorite then
            favoriteCount = favoriteCount + 1
            local familyName = self:GetMountFamilyName(mountID) -- Use the helper
            local mountKey = "mount_" .. tostring(mountID)      -- Unique key for AceConfig

            mountArgs[mountKey] = {
                order = displayOrder,
                type = "description", -- Simple display
                -- For description type, 'name' is the main text.
                -- We can format it. Using a simple approach here.
                -- Using a non-breaking space (ASCII 255 or specific UTF-8) might be better if spacing is an issue, or use multiple description lines.
                name = string.format("|cFFD1D1D1%s:|r %s", creatureName or ("ID " .. mountID),
                    familyName or "Unknown Family"),
                -- fontSize = "medium" -- Optional: if you want them larger
            }
            displayOrder = displayOrder + 1
        end
    end

    if favoriteCount == 0 then
        mountArgs["no_favorites"] = {
            order = displayOrder,
            type = "description",
            name = "You have no mounts marked as favorite, or none are collected."
        }
    end

    print("RMB_DEBUG: Processed favorites. Found: " ..
    favoriteCount .. ". Returning " .. displayOrder - 1 .. " AceConfig args.")
    return mountArgs
end

-- Getter/Setter for AceConfig options (used by Options.lua)
function addon:GetSetting(key)
    if not self.db then
        print("RMB_DEBUG: GetSetting - self.db is NIL! Key: " .. tostring(key) .. ". Returning initial default.")
        return dbDefaults.profile[key] -- Fallback to initial defaults
    end
    if not self.db.profile then
        print("RMB_DEBUG: GetSetting - self.db.profile is NIL! Key: " .. tostring(key) .. ". Returning initial default.")
        return dbDefaults.profile[key] -- Fallback to initial defaults
    end

    local value = self.db.profile[key]
    print("RMB_DEBUG: GetSetting - Key: '" ..
        tostring(key) .. "', Value from DB: " .. tostring(value) .. ", Type: " .. tostring(type(value)))

    -- If value is nil in the DB (e.g., new setting not yet saved), AceConfig expects the default value from the options table,
    -- which eventually comes from your initial dbDefaults.
    if value == nil and dbDefaults.profile[key] ~= nil then
        print("RMB_DEBUG: GetSetting - Key: '" ..
            tostring(key) ..
            "' was nil in DB profile, returning initial default from dbDefaults: " .. tostring(dbDefaults.profile[key]))
        return dbDefaults.profile[key]
    end
    -- If the key genuinely has no default in dbDefaults.profile either (e.g. a new ad-hoc key), 'value' (which would be nil) is correct to return.
    return value
end

function addon:SetSetting(key, value)
    if not self.db then
        print("RMB_DEBUG: SetSetting - self.db is NIL! Cannot set Key: " .. tostring(key))
        return
    end
    if not self.db.profile then
        print("RMB_DEBUG: SetSetting - self.db.profile is NIL! Cannot set Key: " .. tostring(key))
        return
    end

    print("RMB_DEBUG: SetSetting - Key: '" ..
        tostring(key) .. "', Attempting to set New Value: " .. tostring(value) .. ", Type: " .. tostring(type(value)))
    self.db.profile[key] = value
    print("RMB_DEBUG: SetSetting - self.db.profile['" .. key .. "'] is now: " .. tostring(self.db.profile[key]))
end

print("RMB_DEBUG: Core.lua END.")
