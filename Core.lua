-- Core.lua
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
local LibAceConfigRegistry = LibStub("AceConfigRegistry-3.0")

if not LibAceAddon then
    print("RMB_DEBUG: FATAL - AceAddon-3.0 not found!")
    return
end
if not LibAceDB then print("RMB_DEBUG: WARNING - AceDB-3.0 not found!") end
if not LibAceConsole then print("RMB_DEBUG: WARNING - AceConsole-3.0 not found!") end
if not LibAceEvent then print("RMB_DEBUG: WARNING - AceEvent-3.0 not found!") end
if not LibAceConfigRegistry then print("RMB_DEBUG: WARNING - AceConfigRegistry-3.0 not found!") end

local addon
local success, result = pcall(function()
    LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0")
    addon = RandomMountBuddy
end)

if not success then
    print("RMB_DEBUG: ERROR during NewAddon: " .. tostring(result)); return
end
print("RMB_DEBUG: NewAddon SUCCEEDED. Addon valid: " ..
    tostring(addon and addon.GetName and addon:GetName() or "Unknown/Error"))

addon.RMB_DataReadyForUI = false -- Flag

function addon:GetFamilyInfoForMountID(mountID)
    if not mountID then return nil end; local id = tonumber(mountID); if not id then return nil end
    local modelPath = self.MountToModelPath and self.MountToModelPath[id]; if not modelPath then return nil end
    local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]; if not familyDef then return nil end
    return {
        familyName = familyDef.familyName,
        superGroup = familyDef.superGroup,
        traits = familyDef.traits or {},
        modelPath =
            modelPath
    }
end

function addon:InitializeProcessedData()
    local eventName = self.lastProcessingEventName or "UnknownEvent"
    print("RMB_DEBUG_DATA: Initializing Processed Data (Event: " .. eventName .. ")...")
    self.processedData = { superGroupMap = {}, standaloneFamilyNames = {}, familyToMountIDsMap = {}, superGroupToMountIDsMap = {}, allCollectedMountFamilyInfo = {} }
    if not C_MountJournal or not C_MountJournal.GetMountIDs then
        print("RMB_DEBUG_DATA: C_MountJournal API missing!"); return
    end
    local allMountIDs = C_MountJournal.GetMountIDs(); if not allMountIDs then
        print("RMB_DEBUG_DATA: GetMountIDs nil"); return
    end
    print("RMB_DEBUG_DATA: GetMountIDs found " .. #allMountIDs .. " IDs.")

    local collectedCount, processedCount, scannedCount = 0, 0, 0
    for _, mountID in ipairs(allMountIDs) do
        scannedCount = scannedCount + 1
        local name, _, _, _, isUsable, _, isFav, _, _, _, isColl = C_MountJournal.GetMountInfoByID(mountID)
        if type(name) == "string" and type(isColl) == "boolean" then
            if scannedCount <= 10 then
                print("RMB_DATA_SCAN: ID:" ..
                    tostring(mountID) ..
                    ",N:" .. tostring(name) .. ",C:" .. tostring(isColl) .. ",U:" .. tostring(isUsable))
            end
            if isColl then
                collectedCount = collectedCount + 1; local familyInfo = self:GetFamilyInfoForMountID(mountID)
                if familyInfo and familyInfo.familyName then
                    processedCount = processedCount + 1
                    self.processedData.allCollectedMountFamilyInfo[mountID] = {
                        name = name,
                        isUsable = isUsable,
                        isFavorite =
                            isFav,
                        familyName = familyInfo.familyName,
                        superGroup = familyInfo.superGroup,
                        traits = familyInfo
                            .traits,
                        modelPath = familyInfo.modelPath
                    }
                    local fn, sg = familyInfo.familyName, familyInfo.superGroup
                    if not self.processedData.familyToMountIDsMap[fn] then self.processedData.familyToMountIDsMap[fn] = {} end; table
                        .insert(self.processedData.familyToMountIDsMap[fn], mountID)
                    if sg then
                        if not self.processedData.superGroupMap[sg] then self.processedData.superGroupMap[sg] = {} end
                        local found = false; for _, e in ipairs(self.processedData.superGroupMap[sg]) do
                            if e == fn then
                                found = true; break
                            end
                        end; if not found then table.insert(self.processedData.superGroupMap[sg], fn) end
                        if not self.processedData.superGroupToMountIDsMap[sg] then self.processedData.superGroupToMountIDsMap[sg] = {} end; table
                            .insert(self.processedData.superGroupToMountIDsMap[sg], mountID)
                    else
                        self.processedData.standaloneFamilyNames[fn] = true
                    end
                end
            end
        else
            if scannedCount <= 10 then
                print("RMB_DATA_SCAN_WARN: Bad data for ID " ..
                    tostring(mountID) .. ", NameType:" .. type(name) .. ", CollType:" .. type(isColl))
            end
        end
    end
    print("RMB_DEBUG_DATA: Scanned:" ..
        scannedCount .. ", APICollected:" .. collectedCount .. ", ProcessedFamilyInfo:" .. processedCount)
    local sgC = 0; for k in pairs(self.processedData.superGroupMap) do sgC = sgC + 1 end; print(
        "RMB_DEBUG_DATA: SuperGroups:" .. sgC)
    local fnC = 0; for k in pairs(self.processedData.standaloneFamilyNames) do fnC = fnC + 1 end; print(
        "RMB_DEBUG_DATA: StandaloneFams:" .. fnC)
    print("RMB_DEBUG_DATA: Init COMPLETE.")

    self.RMB_DataReadyForUI = true; print("RMB_DEBUG_DATA: Set RMB_DataReadyForUI to true.")
    self:PopulateFamilyManagementUI() -- Populate UI now that data is ready
end

function addon:OnPlayerLoginAttemptProcessData(eventArg)
    print("RMB_EVENT_DEBUG: Handler OnPlayerLoginAttemptProcessData received Event '" .. tostring(eventArg) .. "'.")
    self.lastProcessingEventName = eventArg; self:InitializeProcessedData(); self.lastProcessingEventName = nil
    self:UnregisterEvent("PLAYER_LOGIN"); print("RMB_EVENT_DEBUG: Unregistered PLAYER_LOGIN.")
end

function addon:OnInitialize()
    print("RMB_DEBUG: OnInitialize CALLED.")
    if RandomMountBuddy_PreloadData then
        self.MountToModelPath = RandomMountBuddy_PreloadData.MountToModelPath or {}; self.FamilyDefinitions =
            RandomMountBuddy_PreloadData.FamilyDefinitions or {}; RandomMountBuddy_PreloadData = nil; print(
            "RMB_DEBUG: PreloadData processed.")
    else
        self.MountToModelPath = {}; self.FamilyDefinitions = {}; print("RMB_DEBUG: PreloadData nil.")
    end
    local mtpC = 0; for _ in pairs(self.MountToModelPath) do mtpC = mtpC + 1 end; print(
        "RMB_DEBUG: MountToModelPath entries: " .. mtpC)
    local fdC = 0; for _ in pairs(self.FamilyDefinitions) do fdC = fdC + 1 end; print(
        "RMB_DEBUG: FamilyDefinitions entries: " .. fdC)

    self.processedData = { superGroupMap = {}, standaloneFamilyNames = {}, familyToMountIDsMap = {}, superGroupToMountIDsMap = {}, allCollectedMountFamilyInfo = {} }
    print("RMB_DEBUG: OnInitialize - Initialized empty self.processedData.")
    self.RMB_DataReadyForUI = false

    if LibAceDB then
        self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true); print("RMB_DEBUG: AceDB:New done.");
        if self.db and self.db.profile then
            print("RMB_DEBUG: Initial 'overrideBlizzardButton': " ..
                tostring(self.db.profile.overrideBlizzardButton))
        else
            print("RMB_DEBUG: self.db.profile nil!")
        end
    else
        print("RMB_DEBUG: LibAceDB missing.")
    end
    if LibAceConsole then
        self:RegisterChatCommand("rmb", "SlashCommandHandler"); self:RegisterChatCommand("randommountbuddy",
            "SlashCommandHandler"); print("RMB_DEBUG: Slash commands registered.")
    else
        print("RMB_DEBUG: LibAceConsole missing.")
    end
    if self.RegisterEvent then
        self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLoginAttemptProcessData"); print(
            "RMB_DEBUG: Registered for PLAYER_LOGIN.")
    else
        print("RMB_DEBUG: self:RegisterEvent missing!")
    end
    print("RMB_DEBUG: OnInitialize END.")
end

function addon:BuildFamilyManagementArgs()
    print("RMB_DEBUG_UI: BuildFamilyManagementArgs called. DataReadyForUI = " .. tostring(self.RMB_DataReadyForUI))
    local pageArgs = {}
    local displayOrder = 1
    pageArgs["fmg_header"] = { order = displayOrder, type = "header", name = "Configure Group Weights & Enabled States" }; displayOrder =
    displayOrder + 1
    pageArgs["fmg_desc"] = { order = displayOrder, type = "description", name = "Weights (0-6). Expand [+] for details." }; displayOrder =
    displayOrder + 1

    if not self.RMB_DataReadyForUI then
        pageArgs.loading_placeholder = { order = displayOrder, type = "description", name = "Mount data loading..." }
        return pageArgs
    end

    local displayableGroups = self:GetDisplayableGroups()
    if not displayableGroups or #displayableGroups == 0 then
        pageArgs["no_groups_msg"] = { order = displayOrder, type = "description", name = "No mount groups found." }
        return pageArgs
    end

    local groupEntryOrder = displayOrder
    for _, groupInfo in ipairs(displayableGroups) do
        local groupKey = groupInfo.key; local isExpanded = self:IsGroupExpanded(groupKey)
        local groupDisplayName = groupInfo.displayName .. " (" .. groupInfo.mountCount .. " mounts)"

        local detailArgsForThisGroup = {} -- Default to empty
        if isExpanded then
            detailArgsForThisGroup = self:GetExpandedGroupDetailsArgs(groupKey, groupInfo.type)
        end

        pageArgs["entry_" .. groupKey] = {
            order = groupEntryOrder,
            type = "group",
            name = groupDisplayName,
            inline = true,
            handler = self,
            args = {
                expandCollapse = { order = 1, type = "execute", name = isExpanded and "[-] Collapse" or "[+] Expand", func = function()
                    self:ToggleExpansionState(groupKey) end, width = "normal" },
                enabledToggle = { order = 2, type = "toggle", name = "Enabled", get = function() return self
                    :IsGroupEnabled(groupKey) end, set = function(i, v) self:SetGroupEnabled(groupKey, v) end, width = "normal" },
                weightControl = { order = 3, type = "range", name = "Weight", min = 0, max = 6, step = 1, get = function() return
                    self:GetGroupWeight(groupKey) end, set = function(i, v) self:SetGroupWeight(groupKey, v) end, width = "normal" },
                detailsContainer = {
                    order = 100,
                    type = "group",
                    name = " ",
                    inline = true,
                    hidden = not isExpanded,
                    width = "full",
                    args = detailArgsForThisGroup -- Assign the pre-built table
                }
            }
        }
        groupEntryOrder = groupEntryOrder + 1
    end
    return pageArgs
end

-- PopulateFamilyManagementUI (remains the same, it calls BuildFamilyManagementArgs and NotifyChange)
function addon:PopulateFamilyManagementUI()
    print("RMB_DEBUG_UI: PopulateFamilyManagementUI called.")
    if not self.fmArgsRef then
        print("RMB_DEBUG_UI_ERROR: self.fmArgsRef nil!"); return
    end

    if not self.RMB_DataReadyForUI then
        print("RMB_DEBUG_UI: Data not ready, populating with 'loading' message.")
        wipe(self.fmArgsRef)
        self.fmArgsRef.refresh_button_placeholder = { order = 0, type = "execute", name = "Refresh List (Data Not Ready)", func = function()
            self:PopulateFamilyManagementUI() end }
        self.fmArgsRef.loading_or_refresh_placeholder = { order = 1, type = "description", name =
        "Data not yet processed. Click Refresh or wait." }
    else
        local newArgsForPage = self:BuildFamilyManagementArgs()
        wipe(self.fmArgsRef)
        for key, value in pairs(newArgsForPage) do self.fmArgsRef[key] = value end
    end
    print("RMB_DEBUG_UI: Updated self.fmArgsRef. Notifying AceConfigRegistry.")
    if LibAceConfigRegistry then LibAceConfigRegistry:NotifyChange(addonNameFromToc) end
end

function addon:TriggerFamilyManagementUIRefresh() -- Called by button in Options.lua
    print("RMB_DEBUG_UI: TriggerFamilyManagementUIRefresh (button) called.")
    self:PopulateFamilyManagementUI()
end

-- Core.lua (Revised GetDisplayableGroups only)

function addon:GetDisplayableGroups()
    print("RMB_DEBUG_UI: GetDisplayableGroups called.")
    if not (self.processedData and self.processedData.superGroupMap and self.processedData.standaloneFamilyNames and
            self.processedData.superGroupToMountIDsMap and self.processedData.familyToMountIDsMap) then
        print("RMB_DEBUG_UI: GetDisplayableGroups - self.processedData or its sub-tables not yet fully initialized.")
        return {} -- Return empty table
    end

    local displayGroupsOutput = {}

    -- 1. Add SuperGroups
    for sgName, familyNameList in pairs(self.processedData.superGroupMap) do
        local mountCount = 0 -- Default to 0
        if self.processedData.superGroupToMountIDsMap[sgName] then
            mountCount = #(self.processedData.superGroupToMountIDsMap[sgName])
        end

        if mountCount > 0 then
            table.insert(displayGroupsOutput, {
                key = sgName,
                type = "superGroup",
                displayName = sgName or "Unknown SuperGroup", -- Safety for displayName
                mountCount = mountCount,                      -- This should now always be a number
                familiesInGroup = #(familyNameList or {})
            })
            -- else
            -- print("RMB_DEBUG_UI: Skipping SuperGroup '" .. tostring(sgName) .. "' due to 0 mountCount.")
        end
    end

    -- 2. Add Standalone FamilyNames
    for familyName, _ in pairs(self.processedData.standaloneFamilyNames) do
        local mountCount = 0 -- Default to 0
        if self.processedData.familyToMountIDsMap[familyName] then
            mountCount = #(self.processedData.familyToMountIDsMap[familyName])
        end

        if mountCount > 0 then
            table.insert(displayGroupsOutput, {
                key = familyName,
                type = "familyName",
                displayName = familyName or "Unknown FamilyName", -- Safety for displayName
                mountCount = mountCount                           -- This should now always be a number
            })
            -- else
            -- print("RMB_DEBUG_UI: Skipping Standalone Family '" .. tostring(familyName) .. "' due to 0 mountCount.")
        end
    end

    table.sort(displayGroupsOutput, function(a, b)
        return (a.displayName or "") < (b.displayName or "")
    end)

    print("RMB_DEBUG_UI: GetDisplayableGroups returning " .. #displayGroupsOutput .. " groups.")
    if #displayGroupsOutput > 0 and #displayGroupsOutput <= 5 then -- Debug first few entries
        for i = 1, #displayGroupsOutput do
            local group = displayGroupsOutput[i]
            print("RMB_DEBUG_UI:   Group: " ..
                tostring(group.displayName) .. ", Count: " .. tostring(group.mountCount) .. ", Type: " ..
                tostring(group.type))
        end
    end
    return displayGroupsOutput
end

function addon:GetExpandedGroupDetailsArgs(gk, gt)
    local da = {}; local o = 1; if not self.processedData then return { e = { o = 1, t = "d", n = "Details unavail." } } end
    if gt == "superGroup" then
        local f = self.processedData.superGroupMap and self.processedData.superGroupMap[gk]; if f and #f > 0 then
            da.h = { o = o, t = "h", n = "Fams in " .. gk .. ":" }; o = o + 1; local sf = {}; for _, fn in ipairs(f) do
                table.insert(sf, fn)
            end; table.sort(sf); for _, fn in ipairs(sf) do
                local mc = self.processedData.familyToMountIDsMap and #(self.processedData.familyToMountIDsMap[fn] or {}) or
                    0; da["fd_" .. fn] = { o = o, t = "d", n = "  - " .. fn .. " (" .. mc .. " mounts)", fs = "medium" }; o =
                    o + 1
            end
        else
            da.nf = { o = 1, t = "d", n = "No fams/mounts." }
        end
    elseif gt == "familyName" then
        local m = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[gk]; if m and #m > 0 then
            da.h = { o = o, t = "h", n = "Collected in " .. gk .. ":" }; o = o + 1; local ml = {}; for _, mid in ipairs(m) do
                local n = "ID:" .. mid; if self.processedData.allCollectedMountFamilyInfo and self.processedData.allCollectedMountFamilyInfo[mid] then
                    n =
                        self.processedData.allCollectedMountFamilyInfo[mid].name or n
                end; table.insert(ml, {
                    id = mid,
                    name =
                        n
                })
            end; table.sort(ml, function(a, b) return (a.name or "") < (b.name or "") end); for _, md in ipairs(ml) do
                da["md_" .. md.id] = { o = o, t = "d", n = "  - " .. md.name, fs = "medium" }; o = o + 1
            end
        else
            da.nm = { o = 1, t = "d", n = "No collected." }
        end
    else
        da.ut = { o = 1, t = "d", n = "Unknown group." }
    end; if o == 1 then da.nd = { o = 1, t = "d", n = "No details." } end; return da
end

function addon:ToggleExpansionState(gk)
    if not (self.db and self.db.profile and self.db.profile.expansionStates) then return end; self.db.profile.expansionStates[gk] = not
        self.db.profile.expansionStates[gk]; print("RMB_UI:ToggleExp " ..
        tostring(gk) .. "=" .. tostring(self.db.profile.expansionStates[gk])); if LibAceConfigRegistry then
        LibAceConfigRegistry:NotifyChange(addonNameFromToc)
    end
end

function addon:IsGroupExpanded(gk)
    if not (self.db and self.db.profile and self.db.profile.expansionStates) then return false end; return self.db
        .profile.expansionStates[gk] == true
end

function addon:GetGroupWeight(gk)
    if not (self.db and self.db.profile and self.db.profile.groupWeights) then return 1 end; local w = self.db.profile
    .groupWeights[gk]; if w == nil then return 1 end; return tonumber(w) or 1
end

function addon:SetGroupWeight(gk, w)
    if not (self.db and self.db.profile and self.db.profile.groupWeights) then return end
    local nw = tonumber(w); if nw == nil or nw < 0 or nw > 6 then
        print("RMB_SET: Invalid W for " .. tostring(gk)); return
    end
    self.db.profile.groupWeights[gk] = nw; print("RMB_SET:SetGW K:'" .. tostring(gk) .. "',W:" .. tostring(nw))
    -- if LibAceConfigRegistry then LibAceConfigRegistry:NotifyChange(addonNameFromToc) end -- COMMENTED OUT
end

function addon:IsGroupEnabled(gk)
    if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then return true end; local ie = self.db
    .profile.groupEnabledStates[gk]; if ie == nil then return true end; return ie == true
end

function addon:SetGroupEnabled(gk, e)
    if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then return end
    local be = (e == true); self.db.profile.groupEnabledStates[gk] = be
    print("RMB_SET:SetGE K:'" .. tostring(gk) .. "',E:" .. tostring(be))
    -- if LibAceConfigRegistry then LibAceConfigRegistry:NotifyChange(addonNameFromToc) end -- COMMENTED OUT
end

function addon:OnEnable() print("RMB_DEBUG: OnEnable CALLED.") end

function addon:GetFavoriteMountsForOptions()
    print("RMB_DEBUG_CORE: GetFavoriteMountsForOptions (placeholder)"); return { p = { order = 1, type = "description", name = "MI list placeholder." } }
end -- Corrected placeholder slightly

function addon:GetSetting(key)
    if not (self.db and self.db.profile) then return dbDefaults.profile[key] end; local v = self.db.profile[key]; if v == nil and dbDefaults.profile[key] ~= nil then
        return
            dbDefaults.profile[key]
    end; return v
end

function addon:SetSetting(key, value)
    if not (self.db and self.db.profile) then return end; self.db.profile[key] = value; print("RMB_SETTING: K:'" ..
        key .. "',V:'" .. tostring(value) .. "'")
end

print("RMB_DEBUG: Core.lua END.")
