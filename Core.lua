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
        treatUniqueEffectsOrSkin = true,
        expansionStates = {},
        groupWeights = {},
        groupEnabledStates = {},
        familyOverrides = {},
        fmItemsPerPage = 5, -- Default items per page
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
addon.fmCurrentPage = 1          -- Initialize current page here
addon.fmItemsPerPage = 5         -- Initialize items per page here (will be loaded from DB in OnInitialize)


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
    local eventNameForLog = self.lastProcessingEventName or "Manual Call or Unknown Event"
    print("RMB_DEBUG_DATA: Initializing Processed Data (Event: " .. eventNameForLog .. ")...")
    self.processedData = {
        superGroupMap = {},
        standaloneFamilyNames = {},
        familyToMountIDsMap = {},
        superGroupToMountIDsMap = {},
        allCollectedMountFamilyInfo = {}
    }

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
        local name, _, _, _, isUsable, _, isFavorite, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

        if type(name) == "string" and type(isCollected) == "boolean" then
            if scannedCount <= 10 then
                print("RMB_DATA_SCAN: ID:" ..
                    tostring(mountID) .. ",N:" .. tostring(name) .. ",C:" .. tostring(isCollected) ..
                    ",U:" .. tostring(isUsable))
            end
            if isCollected == true then
                collectedCount = collectedCount + 1; local familyInfo = self:GetFamilyInfoForMountID(mountID)
                if familyInfo and familyInfo.familyName then
                    processedCount = processedCount + 1
                    self.processedData.allCollectedMountFamilyInfo[mountID] = {
                        name = name,
                        isUsable = isUsable,
                        isFavorite =
                            isFavorite,
                        familyName = familyInfo.familyName,
                        superGroup = familyInfo.superGroup,
                        traits =
                            familyInfo.traits,
                        modelPath = familyInfo.modelPath
                    }
                    local fn, sg = familyInfo.familyName, familyInfo.superGroup
                    if not self.processedData.familyToMountIDsMap[fn] then self.processedData.familyToMountIDsMap[fn] = {} end; table
                        .insert(self.processedData.familyToMountIDsMap[fn], mountID)
                    if sg then
                        if not self.processedData.superGroupMap[sg] then self.processedData.superGroupMap[sg] = {} end
                        local found = false; for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do
                            if eFN == fn then
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
                    tostring(mountID) .. ", NameType:" .. type(name) .. ", CollType:" .. type(isCollected))
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
            print("RMB_DEBUG: Initial 'overrideBlizzardButton': " .. tostring(self.db.profile.overrideBlizzardButton))
            if self.db.profile.fmItemsPerPage then
                self.fmItemsPerPage = self.db.profile.fmItemsPerPage; print("RMB_DEBUG: Loaded fmItemsPerPage: " ..
                    tostring(self.fmItemsPerPage))
            end
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

-- BuildFamilyManagementArgs: Builds the args table for the page based on current state and pagination
function addon:BuildFamilyManagementArgs()
    print("RMB_DEBUG_UI: BuildFamilyManagementArgs called. Page: " ..
        tostring(self.fmCurrentPage) ..
        ", ItemsPerPage: " .. tostring(self.fmItemsPerPage) .. ", DataReady:" .. tostring(self.RMB_DataReadyForUI))
    local pageArgs = {}
    local displayOrder = 1
    --[[
    pageArgs["fmg_header"] = { order = displayOrder, type = "header", name = "Family & Group Configuration" }; displayOrder =
        displayOrder + 1
--]]
    -- Manual Refresh Button (always present as part of the built args)
    pageArgs["manual_refresh_button"] = {
        order = 9999,
        type = "execute",
        name = "Refresh List",
        func = function()
            self:PopulateFamilyManagementUI()
        end,
        width = "full"
    }; displayOrder = displayOrder + 1
    --[[
    pageArgs["items_per_page_input"] = {
        order = displayOrder,
        type = "input",
        name = "Items Per Page:",
        get = function()
            return
                tostring(self:FMG_GetItemsPerPage())
        end,
        set = function(i, v) self:FMG_SetItemsPerPage(v) end,
        width = "half"
    }; displayOrder =
        displayOrder + 1
--]]
    if not self.RMB_DataReadyForUI then
        pageArgs.loading_placeholder = {
            order = displayOrder,
            type = "description",
            name =
            "Mount data is loading or not yet processed. This list will appear after login finishes."
        }; displayOrder =
            displayOrder + 1
        return pageArgs
    end

    local allDisplayableGroups = self:GetDisplayableGroups()
    if not allDisplayableGroups then allDisplayableGroups = {} end

    if #allDisplayableGroups == 0 then
        pageArgs["no_groups_msg"] = {
            order = displayOrder,
            type = "description",
            name =
            "No mount groups found (0 collected or no matches)."
        }; displayOrder = displayOrder + 1
        return pageArgs
    end

    local totalGroups = #allDisplayableGroups
    local itemsPerPage = self:FMG_GetItemsPerPage()
    local totalPages = math.max(1, math.ceil(totalGroups / itemsPerPage))
    local currentPage = self.fmCurrentPage or 1
    if currentPage > totalPages then
        currentPage = totalPages; self.fmCurrentPage = totalPages;
    end
    if currentPage < 1 then
        currentPage = 1; self.fmCurrentPage = currentPage;
    end



    -- Pagination Controls Group
    pageArgs["pagination_controls_group"] = {
        order = displayOrder,
        type = "group",
        inline = true,
        name = " ",
        width = "full",
        args = {
            first_button = {
                order = 1,
                type = "execute",
                name = "<<",
                disabled = (currentPage <= 1),
                func = function()
                    self:FMG_PrevPage()
                end,
                width = 0.5,
            },
            prev_button = {
                order = 2,
                type = "execute",
                name = "<",
                disabled = (currentPage <= 1),
                func = function()
                    self:FMG_PrevPage()
                end,
                width = 0.5,
            },
            page_info = {
                order = 3,
                type = "description",
                name = string.format("                                     %d / %d", currentPage, totalPages),
                width = 1.5,
            },
            next_button = {
                order = 4,
                type = "execute",
                name = ">",
                disabled = (currentPage >= totalPages),
                func = function()
                    self:FMG_NextPage()
                end,
                width = 0.5,
            },
            last_button = {
                order = 5,
                type = "execute",
                name = ">>",
                disabled = (currentPage >= totalPages),
                func = function()
                    self:FMG_NextPage()
                end,
                width = 0.5,
            },
        }
    }; displayOrder = displayOrder + 1


    -- Determine slice of groups for current page and build their entries
    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)

    local groupEntryOrder = displayOrder
    for i = startIndex, endIndex do
        local groupInfo = allDisplayableGroups[i]
        if groupInfo then
            local groupKey = groupInfo.key; local isExpanded = self:IsGroupExpanded(groupKey)
            local groupDisplayName = groupInfo.displayName .. " (" .. groupInfo.mountCount .. " mounts)"
            local detailArgsForThisGroup = (isExpanded and self:GetExpandedGroupDetailsArgs(groupKey, groupInfo.type)) or
                {}

            pageArgs["entry_" .. groupKey] = {
                order = groupEntryOrder,
                type = "group",
                name = groupDisplayName,
                inline = true,
                handler = self,
                args = {
                    expandCollapse = {
                        order = 1,
                        type = "execute",
                        name = isExpanded and "-" or "+",
                        func = function()
                            self:ToggleExpansionState(groupKey)
                        end,
                        width = 0.3,
                    },
                    group_name = {
                        order = 2,
                        type = "description",
                        name = groupDisplayName,
                        width = 1,
                    },
                    enabledToggle = {
                        order = 3,
                        type = "toggle",
                        name = "Enabled",
                        get = function()
                            return self
                                :IsGroupEnabled(groupKey)
                        end,
                        set = function(i, v) self:SetGroupEnabled(groupKey, v) end,
                        width = "normal"
                    },
                    weightControl = {
                        order = 4,
                        type = "range",
                        name = "Weight",
                        min = 0,
                        max = 6,
                        step = 1,
                        get = function()
                            return
                                self:GetGroupWeight(groupKey)
                        end,
                        set = function(i, v) self:SetGroupWeight(groupKey, v) end,
                        width = "normal"
                    },
                    detailsContainer = { order = 100, type = "group", name = " ", inline = true, hidden = not isExpanded, width = "full", args = detailArgsForThisGroup }
                }
            }
            groupEntryOrder = groupEntryOrder + 1
        end
    end
    print("RMB_DEBUG_UI: BuildFamilyManagementArgs finished page " ..
        currentPage .. ", added " .. (groupEntryOrder - displayOrder) .. " entries.")
    return pageArgs
end

function addon:PopulateFamilyManagementUI()
    print("RMB_DEBUG_UI: PopulateFamilyManagementUI called.")
    if not self.fmArgsRef then
        print(
            "RMB_DEBUG_UI_ERROR: self.fmArgsRef (the options table for familyManagement.args) is nil! Options.lua problem.")
        return
    end

    local newPageContentArgs = self:BuildFamilyManagementArgs()

    wipe(self.fmArgsRef)
    for k, v in pairs(newPageContentArgs) do self.fmArgsRef[k] = v end

    print("RMB_DEBUG_UI: self.fmArgsRef has been updated with new page content. Notifying AceConfigRegistry.")
    if LibAceConfigRegistry then
        LibAceConfigRegistry:NotifyChange(addonNameFromToc)
    else
        print(
            "RMB_DEBUG_UI_ERROR: AceConfigRegistry missing.")
    end
end

function addon:TriggerFamilyManagementUIRefresh()
    print("RMB_DEBUG_UI: Manual Refresh Triggered."); self:PopulateFamilyManagementUI()
end

function addon:FMG_SetItemsPerPage(items)
    local numItems = tonumber(items); if numItems and numItems >= 5 and numItems <= 50 then
        print("RMB_PAGING: Set IPP to " .. numItems); self.fmItemsPerPage = numItems; if self.db and self.db.profile then
            self.db.profile.fmItemsPerPage =
                numItems
        end; self.fmCurrentPage = 1; self:PopulateFamilyManagementUI()
    else
        print("RMB_PAGING: Invalid IPP: " .. tostring(items))
    end
end

function addon:FMG_GetItemsPerPage() return self.fmItemsPerPage or 5 end

function addon:FMG_GoToPage(pN)
    if not self.RMB_DataReadyForUI then
        print("RMB_PAGING: Data not ready."); return
    end
    local allGroups = self:GetDisplayableGroups(); if not allGroups then allGroups = {} end; local ipp = self
        :FMG_GetItemsPerPage(); local tP = math.max(1, math.ceil(#allGroups / ipp)); local tN = tonumber(pN);
    if tN and tN >= 1 and tN <= tP then
        if self.fmCurrentPage ~= tN then
            self.fmCurrentPage = tN; print("RMB_PAGING: Navigating to page " .. self.fmCurrentPage); self
                :PopulateFamilyManagementUI()
        else
            print("RMB_PAGING: Already on page " .. tN .. ". Refreshing current page view.")
        end
    else
        print(
            "RMB_PAGING: Invalid page " .. tostring(pN))
    end
end

function addon:FMG_NextPage()
    if not self.RMB_DataReadyForUI then return end; local allG = self:GetDisplayableGroups(); local ipp = self
        :FMG_GetItemsPerPage(); local tP = math.max(1, math.ceil(#allG / ipp)); if self.fmCurrentPage < tP then
        self
            :FMG_GoToPage(self.fmCurrentPage + 1)
    end
end

function addon:FMG_PrevPage()
    if not self.RMB_DataReadyForUI then return end; if self.fmCurrentPage > 1 then
        self:FMG_GoToPage(self.fmCurrentPage -
            1)
    end
end

function addon:GetDisplayableGroups()
    if not (self.processedData and self.processedData.superGroupMap) then
        print("RMB_UI: GetDisplayableGroups-procData ERR"); return {}
    end; local o = {};
    for sgn, fl in pairs(self.processedData.superGroupMap) do
        local mc = self.processedData.superGroupToMountIDsMap and
            #(self.processedData.superGroupToMountIDsMap[sgn] or {}) or
            0; if mc > 0 then
            table.insert(o,
                { key = sgn, type = "superGroup", displayName = sgn, mountCount = mc, familiesInGroup = #(fl or {}) })
        end
    end
    for fn, _ in pairs(self.processedData.standaloneFamilyNames) do
        local mc = self.processedData.familyToMountIDsMap and #(self.processedData.familyToMountIDsMap[fn] or {}) or 0; if mc > 0 then
            table.insert(o, { key = fn, type = "familyName", displayName = fn, mountCount = mc })
        end
    end
    table.sort(o, function(a, b) return (a.displayName or "") < (b.displayName or "") end); print(
        "RMB_UI: GetDisplayableGroups returns " .. #o);
    if #o > 0 and #o <= 5 then
        for i = 1, #o do
            print("RMB_UI: Gp: " ..
                tostring(o[i].displayName) .. " C:" .. tostring(o[i].mountCount) .. " T:" .. tostring(o[i].type))
        end
    end
    return o
end

function addon:GetExpandedGroupDetailsArgs(groupKey, groupType)
    print("RMB_DEBUG_UI_DETAILS: GetExpandedGroupDetailsArgs for " .. tostring(groupKey) ..
        " (" .. tostring(groupType) .. ")")
    local detailsArgs = {} -- Table to hold args for the details section
    local displayOrder = 1 -- Ordering for items within detailsArgs

    if not self.processedData then
        print("RMB_DEBUG_UI_DETAILS: No processed data."); return {}
    end

    if groupType == "superGroup" then
        local familyNamesInSG = self.processedData.superGroupMap and self.processedData.superGroupMap[groupKey]
        if familyNamesInSG and #familyNamesInSG > 0 then
            detailsArgs.h = { order = displayOrder, type = "header", name = "Families in " .. groupKey .. ":" }; displayOrder =
                displayOrder + 1;
            local sortedFams = {}; for _, fn in ipairs(familyNamesInSG) do table.insert(sortedFams, fn) end; table.sort(
                sortedFams);
            print("RMB_DEBUG_UI_DETAILS: Processing Families for SG: " .. tostring(groupKey));
            for _, fn in ipairs(sortedFams) do
                local mc = self.processedData.familyToMountIDsMap and #(self.processedData.familyToMountIDsMap[fn] or {}) or
                    0;
                detailsArgs["fd_" .. fn] = {
                    order = displayOrder,
                    type = "description",
                    name = "  - " ..
                        fn .. " (" .. mc .. " mounts)",
                    fontSize = "medium"
                };
                displayOrder = displayOrder + 1;
            end
        else
            detailsArgs.nf = { order = 1, type = "description", name = "No families/mounts." }
        end
    elseif groupType == "familyName" then
        local mIDs = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[gk];
        if mIDs and #mIDs > 0 then
            detailsArgs.h = { order = displayOrder, type = "header", name = "Collected in " .. gk .. ":" }; displayOrder =
                displayOrder + 1;
            local ml = {}; for _, mid in ipairs(mIDs) do
                local n = "ID:" .. mid; if self.processedData.allCollectedMountFamilyInfo and self.processedData.allCollectedMountFamilyInfo[mid] then
                    n =
                        self.processedData.allCollectedMountFamilyInfo[mid].name or n
                end; table.insert(ml, {
                    id = mid,
                    name =
                        n
                })
            end; table.sort(ml, function(a, b) return (a.name or "") < (b.name or "") end);
            print("RMB_DEBUG_UI_DETAILS: Processing Mounts for FN: " .. tostring(gk));
            for _, md in ipairs(ml) do
                detailsArgs["md_" .. md.id] = {
                    order = displayOrder,
                    type = "description",
                    name = "  - " .. md.name,
                    fontSize =
                    "medium"
                };
                displayOrder = displayOrder + 1;
            end
        else
            detailsArgs.nm = { order = 1, type = "description", name = "No collected." }
        end
    else
        detailsArgs.ut = { order = 1, type = "description", name = "Unknown group." }
    end;

    -- Add a placeholder if nothing was added
    if displayOrder == 1 then detailsArgs.nd = { order = 1, type = "description", name = "No details available." } end;

    print("RMB_DEBUG_UI_DETAILS: GetExpandedGroupDetailsArgs returns " .. (displayOrder - 1) .. " items for detailsArgs.")
    return detailsArgs -- Return the populated table
end

function addon:ToggleExpansionState(groupKey)
    if not (self.db and self.db.profile and self.db.profile.expansionStates) then
        print("RMB_UI: ExpStates DB ERR"); return
    end;
    self.db.profile.expansionStates[groupKey] = not self.db.profile.expansionStates[groupKey]
    print("RMB_UI:ToggleExp for '" .. tostring(groupKey) .. "' to " ..
        tostring(self.db.profile.expansionStates[groupKey]))
    -- After changing expansion state, we need to repopulate the UI for the current page to update the expanded item
    self:PopulateFamilyManagementUI()
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
    if not (self.db and self.db.profile and self.db.profile.groupWeights) then return end;
    local nw = tonumber(w); if nw == nil or nw < 0 or nw > 6 then
        print("RMB_SET: Invalid W for " .. tostring(gk)); return
    end;
    self.db.profile.groupWeights[gk] = nw; print("RMB_SET:SetGW K:'" .. tostring(gk) .. "',W:" .. tostring(nw))
    -- NO NotifyChange here; AceConfig widget should update itself via its get method
end

function addon:IsGroupEnabled(gk)
    if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then return true end; local ie = self.db
        .profile.groupEnabledStates[gk]; if ie == nil then return true end; return ie == true
end

function addon:SetGroupEnabled(gk, e)
    if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then return end;
    local be = (e == true); self.db.profile.groupEnabledStates[gk] = be;
    print("RMB_SET:SetGE K:'" .. tostring(gk) .. "',E:" .. tostring(be))
    -- NO NotifyChange here
end

function addon:OnEnable() print("RMB_DEBUG: OnEnable CALLED.") end

function addon:GetFavoriteMountsForOptions()
    print("RMB_DEBUG_CORE: GetFavoriteMountsForOptions (placeholder)"); return { p = { order = 1, type = "description", name = "MI list placeholder." } }
end

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
