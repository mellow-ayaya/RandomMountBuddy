-- Core.lua (Full version with fix for '...' in InitializeProcessedData logging)
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW

local dbDefaults = {
    profile = {
        overrideBlizzardButton = true,
        useSuperGrouping = true,
        contextualSummoning = true,
        treatMinorArmorAsDistinct = false,
        treatMajorArmorAsDistinct = false,
        treatModelVariantsAsDistinct = false,
        treatUniqueEffectsAsDistinct = true,
        expansionStates = {},
        groupWeights = {},
        groupEnabledStates = {},
        familyOverrides = {},
    }
}

print("RMB_DEBUG: Core.lua START. Addon Name: " .. tostring(addonNameFromToc) .. ". Time: " .. tostring(time()))

local LibAceAddon = LibStub("AceAddon-3.0")
local LibAceDB = LibStub("AceDB-3.0")
local LibAceConsole = LibStub("AceConsole-3.0")
local LibAceEvent = LibStub("AceEvent-3.0")

if not LibAceAddon then
    print("RMB_DEBUG: FATAL - AceAddon-3.0 not found!")
    return
end
if not LibAceDB then print("RMB_DEBUG: WARNING - AceDB-3.0 not found!") end
if not LibAceConsole then print("RMB_DEBUG: WARNING - AceConsole-3.0 not found!") end
if not LibAceEvent then print("RMB_DEBUG: WARNING - AceEvent-3.0 not found!") end

local addon
local success, result = pcall(function()
    LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0")
    addon = RandomMountBuddy
end)

if not success then
    print("RMB_DEBUG: ERROR during AceAddon:NewAddon call! Error: " .. tostring(result))
    return
else
    print("RMB_DEBUG: AceAddon:NewAddon call SUCCEEDED.")
    if not (addon and addon.GetName and addon.RegisterEvent) then
        print("RMB_DEBUG: Addon object invalid or AceEvent-3.0 not mixed in properly.")
        return
    end
    print("RMB_DEBUG: Addon object valid. Name: " ..
    tostring(addon:GetName()) .. ". AceEvent mixed in: " .. tostring(type(addon.RegisterEvent)))
end

function addon:GetFamilyInfoForMountID(mountID)
    if not mountID then return nil end
    local id = tonumber(mountID)
    if not id then return nil end
    local modelPath = self.MountToModelPath and self.MountToModelPath[id]
    if not modelPath then return nil end
    local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]
    if not familyDef then return nil end
    return {
        familyName = familyDef.familyName,
        superGroup = familyDef.superGroup,
        traits = familyDef.traits or {},
        modelPath = modelPath
    }
end

function addon:InitializeProcessedData()
    local eventNameForLog = self.lastProcessingEventName or "Manual Call or Unknown Event"
    print("RMB_DEBUG_DATA: Initializing Processed Data (Reason/Event: " .. eventNameForLog .. ")...")
    self.processedData = {
        superGroupMap = {},
        standaloneFamilyNames = {},
        familyToMountIDsMap = {},
        superGroupToMountIDsMap = {},
        allCollectedMountFamilyInfo = {}
    }

    if not C_MountJournal or not C_MountJournal.GetMountIDs or not C_MountJournal.GetMountInfoByID then
        print("RMB_DEBUG_DATA: C_MountJournal API not available at this time!")
        return
    end
    local allMountIDs = C_MountJournal.GetMountIDs()
    if not allMountIDs then
        print("RMB_DEBUG_DATA: C_MountJournal.GetMountIDs() returned nil.")
        return
    end
    print("RMB_DEBUG_DATA: C_MountJournal.GetMountIDs() returned " .. #allMountIDs .. " total IDs in the journal.")
    if #allMountIDs == 0 then print("RMB_DEBUG_DATA: No mount IDs returned by API.") end

    local actuallyCollectedCount = 0
    local processedWithFamilyInfoCount = 0
    local scannedApiEntries = 0

    for i, mountID in ipairs(allMountIDs) do
        scannedApiEntries = scannedApiEntries + 1
        local name, spellID, icon, isActive, isUsable, sourceType, isFavorite,
        isFactionSpecific, faction, shouldHideOnChar, isCollected, returnedMountID, isSteadyFlight =
            C_MountJournal.GetMountInfoByID(mountID)

        if type(name) == "string" and type(isCollected) == "boolean" then
            if scannedApiEntries <= 10 then
                print("RMB_DEBUG_DATA_MOUNT_SCAN: ID=" .. tostring(mountID) ..
                    ", Name=" .. tostring(name) ..
                    ", isCollected=" .. tostring(isCollected) .. " (Type: " .. type(isCollected) .. ")" ..
                    ", isUsable=" .. tostring(isUsable) .. " (Type: " .. type(isUsable) .. ")" ..
                    ", isFavorite=" .. tostring(isFavorite) .. " (Type: " .. type(isFavorite) .. ")")
            end
            if isCollected == true then
                actuallyCollectedCount = actuallyCollectedCount + 1
                local familyInfo = self:GetFamilyInfoForMountID(mountID)
                if familyInfo and familyInfo.familyName then
                    processedWithFamilyInfoCount = processedWithFamilyInfoCount + 1
                    self.processedData.allCollectedMountFamilyInfo[mountID] = {
                        name = name,
                        isUsable = isUsable,
                        isFavorite = isFavorite,
                        familyName = familyInfo.familyName,
                        superGroup = familyInfo.superGroup,
                        traits = familyInfo.traits,
                        modelPath = familyInfo.modelPath
                    }
                    local fn = familyInfo.familyName; local sg = familyInfo.superGroup
                    if not self.processedData.familyToMountIDsMap[fn] then self.processedData.familyToMountIDsMap[fn] = {} end
                    table.insert(self.processedData.familyToMountIDsMap[fn], mountID)
                    if sg then
                        if not self.processedData.superGroupMap[sg] then self.processedData.superGroupMap[sg] = {} end
                        local found = false; for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do if eFN == fn then
                                found = true; break;
                            end end; if not found then table.insert(self.processedData.superGroupMap[sg], fn) end
                        if not self.processedData.superGroupToMountIDsMap[sg] then self.processedData.superGroupToMountIDsMap[sg] = {} end
                        table.insert(self.processedData.superGroupToMountIDsMap[sg], mountID)
                    else
                        self.processedData.standaloneFamilyNames[fn] = true
                    end
                end
            end
        else
            if scannedApiEntries <= 10 then
                print("RMB_DEBUG_DATA_MOUNT_SCAN_WARN: GetMountInfoByID(" .. tostring(mountID) ..
                    ") returned unexpected data. Name type: " .. type(name) ..
                    ", isCollected type: " .. type(isCollected) ..
                    (type(name) == "string" and (", NameVal: " .. name) or ""))
            end
        end
    end
    print("RMB_DEBUG_DATA: Total mount API entries scanned: " .. scannedApiEntries)
    print("RMB_DEBUG_DATA: Total mounts determined as 'isCollected=true': " .. actuallyCollectedCount)
    print("RMB_DEBUG_DATA: Mounts with addon family info processed: " .. processedWithFamilyInfoCount)
    local sgC = 0; for _ in pairs(self.processedData.superGroupMap) do sgC = sgC + 1 end; print(
    "RMB_DEBUG_DATA: SuperGroups populated: " .. sgC)
    if sgC > 0 then
        local pSg = 0; for sgn, fl in pairs(self.processedData.superGroupMap) do if pSg < 2 then
                print("  SG: " ..
                sgn ..
                " (" ..
                #(self.processedData.superGroupToMountIDsMap[sgn] or {}) .. " mounts) - Fams: " .. table.concat(fl, ", ")); pSg =
                pSg + 1;
            else
                print("  ...more SG"); break;
            end end
    end
    local fnC = 0; for _ in pairs(self.processedData.standaloneFamilyNames) do fnC = fnC + 1 end; print(
    "RMB_DEBUG_DATA: StandaloneFamilies populated: " .. fnC)
    if fnC > 0 then
        local pFn = 0; for fn, _ in pairs(self.processedData.standaloneFamilyNames) do if pFn < 2 then
                print("  FN: " .. fn .. " (" .. #(self.processedData.familyToMountIDsMap[fn] or {}) .. " mounts)"); pFn =
                pFn + 1;
            else
                print("  ...more FN"); break;
            end end
    end
    print("RMB_DEBUG_DATA: Processed Data Initialized COMPLETE.")
    local ACRegistry = LibStub("AceConfigRegistry-3.0"); if ACRegistry then
        ACRegistry:NotifyChange(addonNameFromToc); print("RMB_DEBUG_DATA: Notified AceConfigRegistry.")
    end
end

function addon:OnPlayerLoginAttemptProcessData(eventArg, ...) -- 'eventArg' will be the event name string "PLAYER_LOGIN"
    print("RMB_EVENT_DEBUG: Handler OnPlayerLoginAttemptProcessData received Event '" .. tostring(eventArg) .. "'.")
    self.lastProcessingEventName = eventArg                   -- Store it for InitializeProcessedData to see
    self:InitializeProcessedData()
    self.lastProcessingEventName = nil                        -- Clear it after use
    self:UnregisterEvent("PLAYER_LOGIN")                      -- PLAYER_LOGIN only fires once, but good practice
    print("RMB_EVENT_DEBUG: Unregistered PLAYER_LOGIN after processing attempt.")
end

function addon:OnInitialize()
    print("RMB_DEBUG: OnInitialize CALLED.")
    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.MountToModelPath then self.MountToModelPath =
        RandomMountBuddy_PreloadData.MountToModelPath else self.MountToModelPath = {} end;
    if RandomMountBuddy_PreloadData and RandomMountBuddy_PreloadData.FamilyDefinitions then self.FamilyDefinitions =
        RandomMountBuddy_PreloadData.FamilyDefinitions else self.FamilyDefinitions = {} end;
    RandomMountBuddy_PreloadData = nil;
    local mtpCount = 0; for _ in pairs(self.MountToModelPath) do mtpCount = mtpCount + 1 end; print(
    "RMB_DEBUG: OnInitialize - MountToModelPath loaded (" .. mtpCount .. " entries).")
    local fdCount = 0; for _ in pairs(self.FamilyDefinitions) do fdCount = fdCount + 1 end; print(
    "RMB_DEBUG: OnInitialize - FamilyDefinitions loaded (" .. fdCount .. " entries).")
    print("RMB_DEBUG: OnInitialize - RandomMountBuddy_PreloadData cleared.");

    self.processedData = {
        superGroupMap = {},
        standaloneFamilyNames = {},
        familyToMountIDsMap = {},
        superGroupToMountIDsMap = {},
        allCollectedMountFamilyInfo = {}
    }
    print("RMB_DEBUG: OnInitialize - Initialized empty self.processedData.")

    if LibAceDB then
        self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true); print(
        "RMB_DEBUG: OnInitialize - AceDB:New call completed.");
        if self.db and self.db.profile then
            print("RMB_DEBUG: OnInitialize - self.db.profile exists. Initial 'overrideBlizzardButton': " ..
            tostring(self.db.profile.overrideBlizzardButton))
        else
            print("RMB_DEBUG: OnInitialize - self.db OR self.db.profile is NIL after AceDB:New!")
        end
    else
        print("RMB_DEBUG: OnInitialize - LibAceDB not available, skipping AceDB initialization.")
    end

    if LibAceConsole then
        self:RegisterChatCommand("rmb", "SlashCommandHandler"); self:RegisterChatCommand("randommountbuddy",
            "SlashCommandHandler"); print("RMB_DEBUG: OnInitialize - Slash commands registered.");
    else
        print("RMB_DEBUG: OnInitialize - LibAceConsole not available, skipping slash command registration.")
    end

    print("RMB_DEBUG: OnInitialize - Attempting to register PLAYER_LOGIN for OnPlayerLoginAttemptProcessData...")
    local regSuccess, regErr = pcall(function()
        self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLoginAttemptProcessData")
    end)
    if regSuccess then
        print("RMB_DEBUG: OnInitialize - Successfully registered for PLAYER_LOGIN.")
    else
        print("RMB_DEBUG: OnInitialize - FAILED to register for PLAYER_LOGIN. Error: " .. tostring(regErr))
    end

    print("RMB_DEBUG: OnInitialize END.")
end

function addon:SlashCommandHandler(input)
    input = input and input:trim() or ""
    print("RMB_DEBUG: Slash command used with input: [" .. input .. "]")
    if self.optionsPanelObject then
        local idToOpen = self.optionsPanelObject.id; local frameToOpen = self.optionsPanelObject.frame
        print("RMB_DEBUG: Trying to open options. ID: " ..
        tostring(idToOpen) .. ", Frame type: " .. tostring(type(frameToOpen)))
        if idToOpen then
            local s, e = pcall(Settings.OpenToCategory, idToOpen)
            if s then
                print("RMB_DEBUG: Attempted Settings.OpenToCategory('" .. tostring(idToOpen) .. "')")
            else
                print("RMB_DEBUG: ERROR Settings.OpenToCategory: " .. tostring(e)); if frameToOpen then
                    print("RMB_DEBUG: Fallback InterfaceOptionsFrame_OpenToCategory"); InterfaceOptionsFrame_OpenToCategory(
                    frameToOpen)
                else print("RMB_DEBUG: No valid ID/frame.") end
            end
        elseif frameToOpen then
            print("RMB_DEBUG: 'id' nil, fallback InterfaceOptionsFrame_OpenToCategory"); InterfaceOptionsFrame_OpenToCategory(
            frameToOpen)
        else
            print("RMB_DEBUG: Both 'id' and 'frame' nil.")
        end
    else
        print("RMB_DEBUG: self.optionsPanelObject is nil.")
    end
end

function addon:OnEnable()
    print("RMB_DEBUG: OnEnable CALLED.")
end

function addon:GetFavoriteMountsForOptions()
    print("RMB_DEBUG_CORE: GetFavoriteMountsForOptions called (placeholder)")
    return { placeholder = { order = 1, type = "description", name = "Mount Inspector list under construction." } }
end

function addon:GetSetting(key)
    if not (self.db and self.db.profile) then
        print("RMB_DEBUG: GetSetting - DB/profile nil. Key: " .. tostring(key)); return dbDefaults.profile[key]
    end
    local value = self.db.profile[key]
    -- print("RMB_DEBUG: GetSetting - Key:'"..tostring(key).."', Val:'"..tostring(value).."', Type:'"..tostring(type(value)).."'") -- Making this less spammy
    if value == nil and dbDefaults.profile[key] ~= nil then
        -- print("RMB_DEBUG: GetSetting - Key:'"..tostring(key).."' nil in DB, using default."); -- Less spammy
        return dbDefaults.profile[key]
    end
    return value
end

function addon:SetSetting(key, value)
    if not (self.db and self.db.profile) then
        print("RMB_DEBUG: SetSetting - DB/profile nil. Key: " .. tostring(key)); return
    end
    print("RMB_DEBUG: SetSetting - Key:'" ..
    tostring(key) .. "', NewVal:'" .. tostring(value) .. "', Type:'" .. tostring(type(value)) .. "'")
    self.db.profile[key] = value
    -- print("RMB_DEBUG: SetSetting - self.db.profile['"..key.."'] is now: "..tostring(self.db.profile[key])) -- Less spammy
end

print("RMB_DEBUG: Core.lua END.")
