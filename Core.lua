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
		fmItemsPerPage = 15, -- Default items per page
	},
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

-- Mapping of weight values to descriptive text and WoW color codes (ffRRGGBB)
local WeightDisplayMapping = {
	[0] = { text = "         Never", color = "9d9d9d" }, -- White
	[1] = { text = "     Occasional", color = "9d9d9d" }, -- Grey
	[2] = { text = "    Uncommon", color = "9d9d9d" },   -- Grey
	[3] = { text = "        Normal", color = "ffffff" }, -- White
	[4] = { text = "       Common", color = "1eff00" },  -- Green
	[5] = { text = "         Often", color = "0070dd" }, -- Blue
	[6] = { text = "        Always", color = "ff8000" }, -- Orange
}
print("RMB_DEBUG: NewAddon SUCCEEDED. Addon valid: " ..
	tostring(addon and addon.GetName and addon:GetName() or "Unknown/Error"))
addon.RMB_DataReadyForUI = false -- Flag
addon.fmCurrentPage = 1          -- Initialize current page here
addon.fmItemsPerPage = 15        -- Initialize items per page here (will be loaded from DB in OnInitialize)
function addon:GetFamilyInfoForMountID(mountID)
	if not mountID then return nil end; local id = tonumber(mountID); if not id then return nil end

	local modelPath = self.MountToModelPath and self.MountToModelPath[id]; if not modelPath then return nil end

	local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]; if not familyDef then return nil end

	return {
		familyName = familyDef.familyName,
		superGroup = familyDef.superGroup,
		traits = familyDef.traits or {},
		modelPath =
				modelPath,
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
		allCollectedMountFamilyInfo = {},
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
						modelPath = familyInfo.modelPath,
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

-- --- New Weight Adjustment Helper Methods ---
-- These functions are called by the - and + buttons in the options UI
function addon:DecrementGroupWeight(groupKey)
	-- Check for valid DB profile before attempting to access/modify
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_SET:DecGW Error: DB or profile not available.");
		return
	end;

	local currentWeight = self:GetGroupWeight(groupKey); -- Use the existing getter method
	local newWeight = math.max(0, currentWeight - 1);   -- Ensure weight doesn't go below 0
	-- Only update and trigger a UI refresh if the weight actually changed
	if newWeight ~= currentWeight then
		self.db.profile.groupWeights[groupKey] = newWeight;
		print("RMB_SET:SetGW K:'" .. tostring(groupKey) .. "',W:" .. tostring(newWeight));
		-- Trigger a UI refresh so the displayed weight number updates immediately
		self:PopulateFamilyManagementUI();
	else
		-- Optional: print a message if already at min
		print("RMB_SET:DecGW K:'" .. tostring(groupKey) .. "' already at min weight (" .. tostring(currentWeight) .. ").");
	end
end

function addon:IncrementGroupWeight(groupKey)
	-- Check for valid DB profile before attempting to access/modify
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_SET:IncGW Error: DB or profile not available.");
		return
	end;

	local currentWeight = self:GetGroupWeight(groupKey); -- Use the existing getter method
	local newWeight = math.min(6, currentWeight + 1);   -- Ensure weight doesn't go above 6
	-- Only update and trigger a UI refresh if the weight actually changed
	if newWeight ~= currentWeight then
		self.db.profile.groupWeights[groupKey] = newWeight;
		print("RMB_SET:SetGW K:'" .. tostring(groupKey) .. "',W:" .. tostring(newWeight));
		-- Trigger a UI refresh so the displayed weight number updates immediately
		self:PopulateFamilyManagementUI();
	else
		-- Optional: print a message if already at max
		print("RMB_SET:IncGW K:'" .. tostring(groupKey) .. "' already at max weight (" .. tostring(currentWeight) .. ").");
	end
end

function addon:GetWeightDisplayString(weight)
	-- Ensure the weight is a number and within bounds, default to 1 if not valid
	local w = tonumber(weight) or 1
	if w < 0 or w > 6 then w = 1 end

	local info = WeightDisplayMapping[w]
	-- Should not happen if w is constrained, but good practice
	if not info then
		return "|cffffffffError|r" -- Return a default error string if lookup fails
	end

	local displayText = info.text
	local colorCode = info.color -- This is the ffRRGGBB part
	-- REMOVE the conditional logic that added the number prefix
	-- We now always just use the descriptive text
	local fullText = displayText
	-- Format the text with the WoW color code
	return "|cff" .. colorCode .. fullText .. "|r"
end

-- Add these helper functions for getting mount information
-- Gets a random mount from a group (for previewing or summoning)
function addon:GetRandomMountFromGroup(groupKey, groupType)
	if not groupKey or not groupType then return nil end

	local mountIDs = {}
	if groupType == "familyName" then
		-- For a family, get mount IDs directly
		mountIDs = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[groupKey] or {}
	elseif groupType == "superGroup" then
		-- For a supergroup, get mount IDs from the supergroup map
		mountIDs = self.processedData.superGroupToMountIDsMap and self.processedData.superGroupToMountIDsMap[groupKey] or {}
	end

	-- Filter out any non-collected mounts (should not be necessary, but as a safety check)
	local collectedMounts = {}
	for _, mountID in ipairs(mountIDs) do
		if self.processedData.allCollectedMountFamilyInfo and self.processedData.allCollectedMountFamilyInfo[mountID] then
			table.insert(collectedMounts, mountID)
		end
	end

	-- If no collected mounts, return nil
	if #collectedMounts == 0 then return nil end

	-- Pick a random mount from the list
	local randomIndex = math.random(1, #collectedMounts)
	local selectedMountID = collectedMounts[randomIndex]
	-- Get mount name and other info
	local mountInfo = self.processedData.allCollectedMountFamilyInfo[selectedMountID]
	local mountName = mountInfo and mountInfo.name or ("Mount ID " .. selectedMountID)
	return selectedMountID, mountName
end

-- Function to get tooltip text for a group
function addon:GetMountPreviewTooltip(groupKey, groupType)
	-- Get a random mount from the specified group
	local mountID, mountName = self:GetRandomMountFromGroup(groupKey, groupType)
	if not mountID then
		-- No mounts found in this group
		return "No collected mounts found"
	end

	-- Return a simple tooltip text
	return "Preview: " .. mountName .. "\n(Click to summon)"
end

-- Function to determine group type from key
function addon:GetGroupTypeFromKey(groupKey)
	if self.processedData.superGroupMap and self.processedData.superGroupMap[groupKey] then
		return "superGroup"
	else
		return "familyName"
	end
end

function addon:ShowMountPreview(mountID, mountName, groupKey, groupType)
	-- Create the model frame if it doesn't exist yet
	if not self.modelPreviewFrame then
		-- Create a modal dialog frame
		self.modelPreviewFrame = CreateFrame("Frame", "RMB_ModelPreview", UIParent, "BackdropTemplate")
		local frame = self.modelPreviewFrame
		-- Make it a good size and position
		frame:SetSize(350, 350)
		frame:SetPoint("CENTER")
		frame:SetFrameStrata("DIALOG")
		-- Add a background
		frame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile = true,
			tileSize = 32,
			edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
		-- Add title text
		frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.title:SetPoint("TOP", 0, -15)
		-- Add model display area
		frame.model = CreateFrame("PlayerModel", nil, frame)
		frame.model:SetPoint("TOP", 0, -40)
		frame.model:SetPoint("BOTTOM", 0, 40)
		frame.model:SetPoint("LEFT", 20, 0)
		frame.model:SetPoint("RIGHT", -20, 0)
		-- Add close button
		frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		frame.closeButton:SetPoint("TOPRIGHT", -4, -4)
		frame.closeButton:SetScript("OnClick", function() frame:Hide() end)
		-- Add "Next Mount" button
		frame.nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.nextButton:SetSize(120, 22)
		frame.nextButton:SetPoint("BOTTOMRIGHT", -20, 15)
		frame.nextButton:SetText("Next Mount")
		-- Add "Summon" button
		frame.summonButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.summonButton:SetSize(120, 22)
		frame.summonButton:SetPoint("BOTTOMLEFT", 20, 15)
		frame.summonButton:SetText("Summon")
		print("RMB_MODEL: Created model preview frame")
	end

	-- Update the frame with the current mount info
	local frame = self.modelPreviewFrame
	-- Store the group info for "Next Mount" button
	frame.groupKey = groupKey
	frame.groupType = groupType
	-- Store the current mount ID for "Summon" button
	frame.currentMountID = mountID
	-- Set the title
	frame.title:SetText(mountName)
	-- Set the model
	local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
	if creatureDisplayID then
		frame.model:SetDisplayInfo(creatureDisplayID)
		frame.model:SetCamDistanceScale(1.5)
		frame.model:SetPosition(0, 0, 0)
	end

	-- Set up the Next Mount button
	frame.nextButton:SetScript("OnClick", function()
		local nextMountID, nextMountName = self:GetRandomMountFromGroup(groupKey, groupType)
		if nextMountID then
			self:ShowMountPreview(nextMountID, nextMountName, groupKey, groupType)
		end
	end)
	-- Set up the Summon button
	frame.summonButton:SetScript("OnClick", function()
		if frame.currentMountID then
			C_MountJournal.SummonByID(frame.currentMountID)
			frame:Hide()
		end
	end)
	-- Show the frame
	frame:Show()
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

function addon:BuildFamilyManagementArgs()
	print("RMB_DEBUG_UI: BuildFamilyManagementArgs called. Page: " ..
		tostring(self.fmCurrentPage) ..
		", ItemsPerPage: " .. tostring(self.fmItemsPerPage) .. ", DataReady:" .. tostring(self.RMB_DataReadyForUI))
	local pageArgs = {}
	local displayOrder = 1
	-- Manual Refresh Button (will be placed last)
	-- Calculate totalPages needed for button disabled state and LastPage func
	local allDisplayableGroups = self:GetDisplayableGroups()
	if not allDisplayableGroups then allDisplayableGroups = {} end

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

	pageArgs["manual_refresh_button"] = {
		order = 9999, -- Placeholder order, will be adjusted later
		type = "execute",
		name = "Refresh List",
		func = function()
			self:PopulateFamilyManagementUI()
		end,
		width = "full",
	};
	if not self.RMB_DataReadyForUI then
		pageArgs.loading_placeholder = {
			order = displayOrder,
			type = "description",
			name = "Mount data is loading or not yet processed. This list will appear after login finishes.",
		}; displayOrder = displayOrder + 1
		pageArgs["manual_refresh_button"].order = displayOrder + 1;
		return pageArgs
	end

	local allDisplayableGroups = self:GetDisplayableGroups()
	if not allDisplayableGroups then allDisplayableGroups = {} end

	if #allDisplayableGroups == 0 then
		pageArgs["no_groups_msg"] = {
			order = displayOrder,
			type = "description",
			name = "No mount groups found (0 collected or no matches).",
		}; displayOrder = displayOrder + 1
		pageArgs["manual_refresh_button"].order = displayOrder + 1;
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

	-- Pagination Controls Group (Top)
	pageArgs["pagination_controls_group_top"] = {
		order = displayOrder,
		type = "group",
		inline = true,
		name = "",
		width = "full",
		args = {
			first_button = {
				order = 1,
				type = "execute",
				name = "<<",
				disabled = (currentPage <= 1),
				func = function() self:FMG_GoToFirstPage() end,
				width = 0.5,
			},
			prev_button = {
				order = 2,
				type = "execute",
				name = "<",
				disabled = (currentPage <= 1),
				func = function() self:FMG_PrevPage() end,
				width = 0.5,
			},
			page_info = {
				order = 3,
				type = "description",
				name = string.format("                                    %d / %d", currentPage, totalPages),
				width = 1.6,
			},
			next_button = {
				order = 4,
				type = "execute",
				name = ">",
				disabled = (currentPage >= totalPages),
				func = function() self:FMG_NextPage() end,
				width = 0.5,
			},
			last_button = {
				order = 5,
				type = "execute",
				name = ">>",
				disabled = (currentPage >= totalPages),
				func = function() self:FMG_GoToLastPage() end,
				width = 0.5,
			},
		},
	}; displayOrder = displayOrder + 1
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)
	print(string.format("RMB_DEBUG_PAGING: currentPage: %s, itemsPerPage: %s, totalGroups: %s",
		tostring(currentPage), tostring(itemsPerPage), tostring(totalGroups)));
	print(string.format("RMB_DEBUG_PAGING: Calculated startIndex: %s, endIndex: %s",
		tostring(startIndex), tostring(endIndex)));
	-- Safety Check
	if type(startIndex) ~= "number" or type(endIndex) ~= "number" then
		print("RMB_DEBUG_ERROR: PAGING ERROR! startIndex or endIndex is not a number. Cannot build list.");
		pageArgs["paging_error_msg"] = {
			order = displayOrder,
			type = "description",
			name = "Error calculating items for this page. Please reload UI.",
		};
		pageArgs["manual_refresh_button"].order = displayOrder + 1;
		return pageArgs;
	end

	local groupEntryOrder = displayOrder
	for i = startIndex, endIndex do
		local groupInfo = allDisplayableGroups[i]
		if groupInfo then
			local groupKey = groupInfo.key
			local isExpanded = self:IsGroupExpanded(groupKey)
			-- Special handling for standalone families with exactly one mount
			local isSingleMountFamily = false
			local mountName = nil
			-- Check if this is a standalone family (not in a superGroup)
			if groupInfo.type == "familyName" then
				-- First, find the model path for this family name
				local familyModelPath = nil
				for modelPath, familyDef in pairs(self.FamilyDefinitions or {}) do
					if familyDef.familyName == groupKey then
						familyModelPath = modelPath
						break
					end
				end

				-- Now count how many mount IDs use this model path
				local mountCount = 0
				if familyModelPath then
					for _, mountModelPath in pairs(self.MountToModelPath or {}) do
						if mountModelPath == familyModelPath then
							mountCount = mountCount + 1
							-- If we find more than one, we can break early
							if mountCount > 1 then
								break
							end
						end
					end
				end

				-- It's a single-mount family if there's only one mount that uses this model path
				isSingleMountFamily = (mountCount == 1)
				if isSingleMountFamily and groupInfo.mountCount == 1 then
					-- Get the mount name for display
					local mIDs = self.processedData.familyToMountIDsMap and
							self.processedData.familyToMountIDsMap[groupKey]
					if mIDs and #mIDs == 1 then
						local mountID = mIDs[1]
						if self.processedData.allCollectedMountFamilyInfo and
								self.processedData.allCollectedMountFamilyInfo[mountID] then
							mountName = self.processedData.allCollectedMountFamilyInfo[mountID].name
						end
					end
				else
					-- Not a single mount family, or has more than one collected
					isSingleMountFamily = false
				end
			end

			-- Construct the display name differently for single mount families
			local groupDisplayName
			if isSingleMountFamily then
				groupDisplayName = groupInfo.displayName .. " (Mount)"
			else
				groupDisplayName = groupInfo.displayName .. " (" .. groupInfo.mountCount .. ")"
			end

			local detailArgsForThisGroup = (isExpanded and self:GetExpandedGroupDetailsArgs(groupKey, groupInfo.type)) or
					{}
			pageArgs["entry_" .. groupKey] = {
				order = groupEntryOrder,
				type = "group",
				name = "",
				inline = true,
				handler = self,
				args = {
					group_name = {
						order = 2,
						type = "description",
						name = groupDisplayName,
						width = 1.4,
						fontSize = "medium",
					},
					enabledToggle = {
						order = 3,
						type = "toggle",
						name = "Enabled",
						get = function() return self:IsGroupEnabled(groupKey) end,
						set = function(i, v) self:SetGroupEnabled(groupKey, v) end,
						width = 0.5,
					},
					-- Weight controls
					weightDecrement = {
						order = 4,
						type = "execute",
						name = "-",
						func = function() self:DecrementGroupWeight(groupKey) end,
						width = 0.1,
						disabled = function() return self:GetGroupWeight(groupKey) == 0 end,
					},
					weightDisplay = {
						order = 5,
						type = "description",
						name = self:GetWeightDisplayString(self:GetGroupWeight(groupKey)),
						width = 0.5,
					},
					weightIncrement = {
						order = 6,
						type = "execute",
						name = "+",
						func = function() self:IncrementGroupWeight(groupKey) end,
						width = 0.1,
						disabled = function() return self:GetGroupWeight(groupKey) == 6 end,
					},
					expandCollapse = {
						order = 8,
						type = "execute",
						name = isExpanded and "Collapse" or "Expand",
						func = function() self:ToggleExpansionState(groupKey) end,
						width = 0.5,
						hidden = isSingleMountFamily, -- Hide the expand button for single mount families
					},
					previewButton = {
						order = 9,
						type = "execute",
						name = "Preview",
						desc = function() return self:GetMountPreviewTooltip(groupKey, groupInfo.type) end,
						func = function(info)
							local mountID, mountName = self:GetRandomMountFromGroup(groupKey, groupInfo.type)
							if mountID then
								-- Instead of summoning, show in our preview window
								self:ShowMountPreview(mountID, mountName, groupKey, groupInfo.type)
							else
								print("RMB_PREVIEW: No mount available to preview from this group")
							end
						end,
						width = 0.5,
					},
					-- The critical change is here - we're not putting expanded content in a group
					-- but instead directly adding the header and details
					expandedHeader = {
						order = 10,
						type = "header",
						name = isExpanded and ("Families in " .. groupKey) or "",
						hidden = not isExpanded,
						width = "full",
					},
				},
			}
			-- If expanded, add the details directly to the args table
			if isExpanded and detailArgsForThisGroup then
				for k, v in pairs(detailArgsForThisGroup) do
					pageArgs["entry_" .. groupKey].args[k] = v
					-- Adjust the order to come after the header
					if v.order then
						v.order = v.order + 10
					end
				end
			end

			groupEntryOrder = groupEntryOrder + 1
		end
	end

	-- Bottom pagination controls
	if totalPages > 1 then
		pageArgs["pagination_controls_group_bottom"] = {
			order = groupEntryOrder,
			type = "group",
			inline = true,
			name = "",
			width = "full",
			args = {
				first_button_b = {
					order = 1,
					type = "execute",
					name = "<<",
					disabled = (currentPage <= 1),
					func = function() self:FMG_GoToFirstPage() end,
					width = 0.5,
				},
				prev_button_b = {
					order = 2,
					type = "execute",
					name = "<",
					disabled = (currentPage <= 1),
					func = function() self:FMG_PrevPage() end,
					width = 0.5,
				},
				page_info_b = {
					order = 3,
					type = "description",
					name = string.format("                                    %d / %d", currentPage, totalPages),
					width = 1.6,
				},
				next_button_b = {
					order = 4,
					type = "execute",
					name = ">",
					disabled = (currentPage >= totalPages),
					func = function() self:FMG_NextPage() end,
					width = 0.5,
				},
				last_button_b = {
					order = 5,
					type = "execute",
					name = ">>",
					disabled = (currentPage >= totalPages),
					func = function() self:FMG_GoToLastPage() end,
					width = 0.5,
				},
			},
		}
		groupEntryOrder = groupEntryOrder + 1
	end

	-- Adjust the manual refresh button order
	pageArgs["manual_refresh_button"].order = groupEntryOrder
	print("RMB_DEBUG_UI: BuildFamilyManagementArgs finished page " ..
		currentPage .. ", added items for " .. (endIndex - startIndex + 1) .. " groups.")
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

function addon:CollapseAllExpanded()
	print("RMB_DEBUG_UI: Collapsing all expanded groups")
	if not (self.db and self.db.profile and self.db.profile.expansionStates) then
		print("RMB_UI: ExpStates DB ERR")
		return
	end

	-- Iterate through all expansion states and set them to false (collapsed)
	local changed = false
	for groupKey, state in pairs(self.db.profile.expansionStates) do
		if state == true then
			self.db.profile.expansionStates[groupKey] = false
			changed = true
		end
	end

	-- Only refresh UI if we actually collapsed something
	if changed then
		print("RMB_UI: Collapsed expanded groups, refreshing UI")
	end

	-- We don't call PopulateFamilyManagementUI() here because
	-- this function is called from navigation functions that already refresh the UI
	return changed
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
	if not self.RMB_DataReadyForUI then return end

	local allG = self:GetDisplayableGroups()
	local ipp = self:FMG_GetItemsPerPage()
	local tP = math.max(1, math.ceil(#allG / ipp))
	if self.fmCurrentPage < tP then
		self:CollapseAllExpanded()
		self:FMG_GoToPage(self.fmCurrentPage + 1)
	end
end

function addon:FMG_PrevPage()
	if not self.RMB_DataReadyForUI then return end

	if self.fmCurrentPage > 1 then
		self:CollapseAllExpanded()
		self:FMG_GoToPage(self.fmCurrentPage - 1)
	end
end

function addon:FMG_GoToFirstPage()
	self:CollapseAllExpanded()
	self:FMG_GoToPage(1)
end

function addon:FMG_GoToLastPage()
	local allGroups = self:GetDisplayableGroups();
	local ipp = self:FMG_GetItemsPerPage();
	local totalPages = math.max(1, math.ceil(#allGroups / ipp));
	self:CollapseAllExpanded()
	self:FMG_GoToPage(totalPages)
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
			-- We don't add any header here now, since it's in the parent function
			-- Sort the family names for consistent display
			local sortedFams = {}; for _, fn in ipairs(familyNamesInSG) do table.insert(sortedFams, fn) end; table.sort(
				sortedFams);
			print("RMB_DEBUG_UI_DETAILS: Processing Families for SG: " .. tostring(groupKey));
			-- For each family in this supergroup, we'll create a row of controls
			for fidx, fn in ipairs(sortedFams) do
				local mc = self.processedData.familyToMountIDsMap and #(self.processedData.familyToMountIDsMap[fn] or {}) or
						0;
				-- Check if this is a single-mount family (just like in BuildFamilyManagementArgs)
				local isSingleMountFamily = false
				if mc == 1 then
					-- Find the model path for this family name
					local familyModelPath = nil
					for modelPath, familyDef in pairs(self.FamilyDefinitions or {}) do
						if familyDef.familyName == fn then
							familyModelPath = modelPath
							break
						end
					end

					-- Count how many mount IDs use this model path
					local mountCount = 0
					if familyModelPath then
						for _, mountModelPath in pairs(self.MountToModelPath or {}) do
							if mountModelPath == familyModelPath then
								mountCount = mountCount + 1
								-- If we find more than one, we can break early
								if mountCount > 1 then
									break
								end
							end
						end
					end

					-- It's a single-mount family if there's only one mount that uses this model path
					isSingleMountFamily = (mountCount == 1)
				end

				-- Create display name
				local familyDisplayName
				if isSingleMountFamily then
					familyDisplayName = fn .. " (Mount)"
				else
					familyDisplayName = fn .. " (" .. mc .. ")"
				end

				-- Make sure to align each family's controls properly in a row
				-- Family name
				detailsArgs["fam_" .. fn .. "_name"] = {
					order = displayOrder,
					type = "description",
					name = familyDisplayName,
					width = 1.4,
					fontSize = "medium",
				}
				displayOrder = displayOrder + 1
				-- Enabled toggle
				detailsArgs["fam_" .. fn .. "_enabled"] = {
					order = displayOrder,
					type = "toggle",
					name = "Enabled",
					get = function() return self:IsGroupEnabled(fn) end,
					set = function(i, v) self:SetGroupEnabled(fn, v) end,
					width = 0.5,
				}
				displayOrder = displayOrder + 1
				-- Weight controls
				detailsArgs["fam_" .. fn .. "_weightDec"] = {
					order = displayOrder,
					type = "execute",
					name = "-",
					func = function() self:DecrementGroupWeight(fn) end,
					width = 0.1,
					disabled = function() return self:GetGroupWeight(fn) == 0 end,
				}
				displayOrder = displayOrder + 1
				detailsArgs["fam_" .. fn .. "_weightDisp"] = {
					order = displayOrder,
					type = "description",
					name = self:GetWeightDisplayString(self:GetGroupWeight(fn)),
					width = 0.5,
				}
				displayOrder = displayOrder + 1
				detailsArgs["fam_" .. fn .. "_weightInc"] = {
					order = displayOrder,
					type = "execute",
					name = "+",
					func = function() self:IncrementGroupWeight(fn) end,
					width = 0.1,
					disabled = function() return self:GetGroupWeight(fn) == 6 end,
				}
				displayOrder = displayOrder + 1
				-- Expand/Collapse button
				local isFamExpanded = self:IsGroupExpanded(fn)
				detailsArgs["fam_" .. fn .. "_expand"] = {
					order = displayOrder,
					type = "execute",
					name = isFamExpanded and "Collapse" or "Expand",
					func = function() self:ToggleExpansionState(fn) end,
					width = 0.5,
					hidden = isSingleMountFamily, -- Hide for single-mount families
				}
				displayOrder = displayOrder + 1
				-- Preview button
				detailsArgs["fam_" .. fn .. "_preview"] = {
					order = displayOrder,
					type = "execute",
					name = "Preview",
					desc = function() return self:GetMountPreviewTooltip(fn, "familyName") end,
					func = function()
						local mountID, mountName = self:GetRandomMountFromGroup(fn, "familyName")
						if mountID then
							print("RMB_PREVIEW: Summoning " .. mountName .. " (ID: " .. mountID .. ")")
							-- Summon the mount
							C_MountJournal.SummonByID(mountID)
						else
							print("RMB_PREVIEW: No mount available to summon from this group")
						end
					end,
					width = 0.5,
				}
				displayOrder = displayOrder + 1
				-- Add a line break after each family
				detailsArgs["fam_" .. fn .. "_linebreak"] = {
					order = displayOrder,
					type = "description",
					name = "",
					width = "full",
				}
				displayOrder = displayOrder + 1
				-- If expanded, add mount details after this family
				if isFamExpanded then
					-- Add mount details header
					detailsArgs["fam_" .. fn .. "_mountsheader"] = {
						order = displayOrder,
						type = "header",
						name = "Collected Mounts",
						width = "full",
					}
					displayOrder = displayOrder + 1
					-- Add mount list
					local mIDs = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[fn]
					if mIDs and #mIDs > 0 then
						local mountList = {}
						for _, mountID in ipairs(mIDs) do
							local mountName = "ID:" .. mountID
							if self.processedData.allCollectedMountFamilyInfo and self.processedData.allCollectedMountFamilyInfo[mountID] then
								mountName = self.processedData.allCollectedMountFamilyInfo[mountID].name or mountName
							end

							table.insert(mountList, {
								id = mountID,
								name = mountName,
							})
						end

						table.sort(mountList, function(a, b) return (a.name or "") < (b.name or "") end)
						for _, mountData in ipairs(mountList) do
							detailsArgs["fam_" .. fn .. "_mount_" .. mountData.id] = {
								order = displayOrder,
								type = "description",
								name = "  - " .. mountData.name,
								fontSize = "medium",
								width = "full",
							}
							displayOrder = displayOrder + 1
						end
					else
						detailsArgs["fam_" .. fn .. "_nomounts"] = {
							order = displayOrder,
							type = "description",
							name = "No collected mounts in this family.",
							width = "full",
						}
						displayOrder = displayOrder + 1
					end

					-- Add a spacer after the mount list
					detailsArgs["fam_" .. fn .. "_aftermounts"] = {
						order = displayOrder,
						type = "description",
						name = "",
						width = "full",
					}
					displayOrder = displayOrder + 1
					-- Add a bottom border header line
					detailsArgs["fam_" .. fn .. "_bottomborder"] = {
						order = displayOrder,
						type = "header",
						name = "",
						width = "full",
					}
					displayOrder = displayOrder + 1
				end
			end

			-- Add a bottom border for the supergroup after all families are listed
			-- This ensures there's always a bottom border, even if no families are expanded
			detailsArgs["supergroup_bottom_border"] = {
				order = displayOrder,
				type = "header",
				name = "",
				width = "full",
			}
			displayOrder = displayOrder + 1
		else
			detailsArgs.nf = { order = 1, type = "description", name = "No families/mounts.", width = "full" }
		end
	elseif groupType == "familyName" then
		local mIDs = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[groupKey];
		if mIDs and #mIDs > 0 then
			-- No header needed here either, handled in parent
			local ml = {};
			for _, mid in ipairs(mIDs) do
				local n = "ID:" .. mid;
				if self.processedData.allCollectedMountFamilyInfo and self.processedData.allCollectedMountFamilyInfo[mid] then
					n = self.processedData.allCollectedMountFamilyInfo[mid].name or n
				end;

				table.insert(ml, {
					id = mid,
					name = n,
				})
			end;

			table.sort(ml, function(a, b) return (a.name or "") < (b.name or "") end);
			print("RMB_DEBUG_UI_DETAILS: Processing Mounts for FN: " .. tostring(groupKey));
			for _, md in ipairs(ml) do
				detailsArgs["md_" .. md.id] = {
					order = displayOrder,
					type = "description",
					name = "  - " .. md.name,
					fontSize = "medium",
					width = "full",
				};
				displayOrder = displayOrder + 1;
			end

			-- Add a bottom border header line after the mount list
			detailsArgs["bottom_border"] = {
				order = displayOrder,
				type = "header",
				name = "",
				width = "full",
			};
			displayOrder = displayOrder + 1;
		else
			detailsArgs.nm = { order = 1, type = "description", name = "No collected mounts.", width = "full" }
		end
	else
		detailsArgs.ut = { order = 1, type = "description", name = "Unknown group type.", width = "full" }
	end;

	-- Add a placeholder if nothing was added
	if displayOrder == 1 then
		detailsArgs.nd = { order = 1, type = "description", name = "No details available.", width = "full" }
	end;

	print("RMB_DEBUG_UI_DETAILS: GetExpandedGroupDetailsArgs returns " .. (displayOrder - 1) .. " items for detailsArgs.")
	return detailsArgs
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
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then return 3 end; local w = self.db.profile
			.groupWeights[gk]; if w == nil then return 3 end; return tonumber(w) or 3
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

function addon:SetupModelPreviewSystem()
	-- Create a simple model frame
	if not self.modelPreviewFrame then
		self.modelPreviewFrame = CreateFrame("PlayerModel", "RMB_ModelPreview", UIParent, "BackdropTemplate")
		local frame = self.modelPreviewFrame
		-- Make it a good size
		frame:SetSize(250, 250)
		frame:SetPoint("CENTER", UIParent, "CENTER", 2000, 0) -- Off-screen initially
		frame:Hide()
		-- Add a background
		frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		frame:SetBackdropColor(0, 0, 0, 0.8)
		print("RMB_MODEL: Created model preview frame")
	end

	-- Create a simple update frame - this avoids all hooks
	if not self.modelUpdateFrame then
		self.modelUpdateFrame = CreateFrame("Frame")
		self.modelUpdateFrame.elapsed = 0
		self.modelUpdateFrame:SetScript("OnUpdate", function(frame, elapsed)
			-- Throttle checks to every 0.1 seconds
			frame.elapsed = frame.elapsed + elapsed
			if frame.elapsed < 0.1 then
				return
			end

			frame.elapsed = 0
			-- Check for tooltip existence
			if GameTooltip:IsShown() then
				-- Safely get tooltip text
				local tooltipText = nil
				-- Use GetText() safely by checking for textLeft1
				if GameTooltip.TextLeft1 and GameTooltip.TextLeft1:GetText() then
					tooltipText = GameTooltip.TextLeft1:GetText()
				end

				-- Only process if this is a preview tooltip
				if tooltipText and tooltipText:find("^Preview: ") then
					-- Extract mount name
					local mountName = tooltipText:match("^Preview: ([^%\n]+)")
					if mountName then
						-- Trim the mount name
						mountName = mountName:gsub("^%s*(.-)%s*$", "%1")
						-- Find mount ID by name
						local mountID = nil
						for _, id in ipairs(C_MountJournal.GetMountIDs()) do
							local name = C_MountJournal.GetMountInfoByID(id)
							if name == mountName then
								mountID = id
								break
							end
						end

						-- Show model if mount found
						if mountID then
							local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
							if creatureDisplayID then
								local tooltipOwner = GameTooltip:GetOwner()
								if tooltipOwner then
									local modelFrame = self.modelPreviewFrame
									modelFrame:ClearAllPoints()
									modelFrame:SetPoint("LEFT", tooltipOwner, "RIGHT", 10, 0)
									modelFrame:SetDisplayInfo(creatureDisplayID)
									modelFrame:SetCamDistanceScale(1.5)
									modelFrame:SetPosition(0, 0, 0)
									modelFrame:Show()
								end
							end
						end
					end
				end
			else
				-- Hide model when tooltip disappears
				if self.modelPreviewFrame:IsShown() then
					self.modelPreviewFrame:Hide()
				end
			end
		end)
		print("RMB_MODEL: Created model update frame")
	end

	print("RMB_MODEL: Model preview system initialized")
end

-- Update your OnEnable to only call the new system
function addon:OnEnable()
	print("RMB_DEBUG: OnEnable CALLED.")
	-- We don't need to set up anything special at load time
	-- The preview window is created on-demand when needed
end

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
