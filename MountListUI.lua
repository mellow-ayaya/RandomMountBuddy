-- MountListUI.lua different anchor
-- UI components for Random Mount Buddy
local addonName, addonTable = ...
local addon = RandomMountBuddy -- Reference to the addon from global
print("RMB_DEBUG: MountListUI.lua START.")
-- Mapping of weight values to descriptive text and WoW color codes (ffRRGGBB)
local WeightDisplayMapping = {
	[0] = { text = "         Never", color = "ff3e00" }, -- White
	[1] = { text = "     Occasional", color = "9d9d9d" }, -- Grey
	[2] = { text = "    Uncommon", color = "9d9d9d" },   -- Grey
	[3] = { text = "        Normal", color = "ffffff" }, -- White
	[4] = { text = "       Common", color = "1eff00" },  -- Green
	[5] = { text = "         Often", color = "0070dd" }, -- Blue
	[6] = { text = "        Always", color = "ff8000" }, -- Orange
}
-- --- Weight Adjustment Helper Methods ---
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
function addon:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	print("RMB_DEBUG_MOUNT: GetRandomMountFromGroup called for " .. tostring(groupKey) ..
		", type: " .. tostring(groupType) .. ", includeUncollected: " .. tostring(includeUncollected))
	if not groupKey then
		print("RMB_DEBUG_MOUNT: No groupKey provided")
		return nil
	end

	-- Default to including uncollected if not specified
	if includeUncollected == nil then
		includeUncollected = self:GetSetting("showUncollectedMounts")
	end

	-- Check if it's a direct mount ID reference (prefixed with "mount_")
	if type(groupKey) == "string" and string.match(groupKey, "^mount_(%d+)$") then
		local mountID = tonumber(string.match(groupKey, "^mount_(%d+)$"))
		print("RMB_DEBUG_MOUNT: Direct mount ID: " .. tostring(mountID))
		-- Check collected mounts first
		if mountID and self.processedData.allCollectedMountFamilyInfo and
				self.processedData.allCollectedMountFamilyInfo[mountID] then
			local mountInfo = self.processedData.allCollectedMountFamilyInfo[mountID]
			print("RMB_DEBUG_MOUNT: Found collected mount: " .. tostring(mountInfo.name))
			return mountID, mountInfo.name, false
		end

		-- If not found in collected and we should include uncollected, check there
		if includeUncollected and mountID and self.processedData.allUncollectedMountFamilyInfo and
				self.processedData.allUncollectedMountFamilyInfo[mountID] then
			local mountInfo = self.processedData.allUncollectedMountFamilyInfo[mountID]
			print("RMB_DEBUG_MOUNT: Found uncollected mount: " .. tostring(mountInfo.name))
			return mountID, mountInfo.name, true
		end

		print("RMB_DEBUG_MOUNT: No mount found for ID: " .. tostring(mountID))
		return nil
	end

	-- If no groupType provided, try to determine it
	if not groupType then
		groupType = self:GetGroupTypeFromKey(groupKey)
		print("RMB_DEBUG_MOUNT: Determined group type: " .. tostring(groupType))
	end

	-- Arrays to store mounts
	local collectedMounts = {}
	local uncollectedMounts = {}
	if groupType == "familyName" then
		print("RMB_DEBUG_MOUNT: Processing as family: " .. tostring(groupKey))
		-- For a family, get mount IDs directly
		local collectedIDs = self.processedData.familyToMountIDsMap and
				self.processedData.familyToMountIDsMap[groupKey] or {}
		print("RMB_DEBUG_MOUNT: Found " .. #collectedIDs .. " collected mounts in family")
		for _, mountID in ipairs(collectedIDs) do
			if self.processedData.allCollectedMountFamilyInfo and
					self.processedData.allCollectedMountFamilyInfo[mountID] then
				local info = self.processedData.allCollectedMountFamilyInfo[mountID]
				table.insert(collectedMounts, {
					id = mountID,
					name = info.name or ("Mount ID " .. mountID),
					isUncollected = false,
				})
			end
		end

		if includeUncollected then
			local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
					self.processedData.familyToUncollectedMountIDsMap[groupKey] or {}
			print("RMB_DEBUG_MOUNT: Found " .. #uncollectedIDs .. " uncollected mounts in family")
			for _, mountID in ipairs(uncollectedIDs) do
				if self.processedData.allUncollectedMountFamilyInfo and
						self.processedData.allUncollectedMountFamilyInfo[mountID] then
					local info = self.processedData.allUncollectedMountFamilyInfo[mountID]
					table.insert(uncollectedMounts, {
						id = mountID,
						name = info.name or ("Mount ID " .. mountID),
						isUncollected = true,
					})
				end
			end
		end
	elseif groupType == "superGroup" then
		print("RMB_DEBUG_MOUNT: Processing as supergroup: " .. tostring(groupKey))
		-- For a supergroup, get mount IDs from the supergroup map
		local collectedIDs = self.processedData.superGroupToMountIDsMap and
				self.processedData.superGroupToMountIDsMap[groupKey] or {}
		print("RMB_DEBUG_MOUNT: Found " .. #collectedIDs .. " collected mounts in supergroup")
		for _, mountID in ipairs(collectedIDs) do
			if self.processedData.allCollectedMountFamilyInfo and
					self.processedData.allCollectedMountFamilyInfo[mountID] then
				local info = self.processedData.allCollectedMountFamilyInfo[mountID]
				table.insert(collectedMounts, {
					id = mountID,
					name = info.name or ("Mount ID " .. mountID),
					isUncollected = false,
				})
			end
		end

		if includeUncollected then
			local uncollectedIDs = self.processedData.superGroupToUncollectedMountIDsMap and
					self.processedData.superGroupToUncollectedMountIDsMap[groupKey] or {}
			print("RMB_DEBUG_MOUNT: Found " .. #uncollectedIDs .. " uncollected mounts in supergroup")
			for _, mountID in ipairs(uncollectedIDs) do
				if self.processedData.allUncollectedMountFamilyInfo and
						self.processedData.allUncollectedMountFamilyInfo[mountID] then
					local info = self.processedData.allUncollectedMountFamilyInfo[mountID]
					table.insert(uncollectedMounts, {
						id = mountID,
						name = info.name or ("Mount ID " .. mountID),
						isUncollected = true,
					})
				end
			end
		end
	end

	print("RMB_DEBUG_MOUNT: Final counts - Collected: " .. #collectedMounts ..
		", Uncollected: " .. #uncollectedMounts)
	-- Prioritize collected mounts if any exist
	if #collectedMounts > 0 then
		-- Pick a random collected mount
		local randomIndex = math.random(1, #collectedMounts)
		local selectedMount = collectedMounts[randomIndex]
		print("RMB_DEBUG_MOUNT: Selected collected mount: " .. tostring(selectedMount.name))
		return selectedMount.id, selectedMount.name, false
	elseif includeUncollected and #uncollectedMounts > 0 then
		-- If no collected mounts and we're including uncollected, pick a random uncollected mount
		local randomIndex = math.random(1, #uncollectedMounts)
		local selectedMount = uncollectedMounts[randomIndex]
		print("RMB_DEBUG_MOUNT: Selected uncollected mount: " .. tostring(selectedMount.name))
		return selectedMount.id, selectedMount.name, true
	end

	print("RMB_DEBUG_MOUNT: No mounts found for selection")
	return nil
end

-- Create a function to show the model next to the tooltip
function addon:ShowModelNextToTooltip()
	if not self.lastTooltipMount or not self.lastTooltipMount.id then
		return
	end

	-- Create model frame if it doesn't exist
	if not self.tooltipModelFrame then
		self.tooltipModelFrame = CreateFrame("PlayerModel", "RMB_TooltipModel", UIParent)
		self.tooltipModelFrame:SetSize(150, 150)
		self.tooltipModelFrame:SetFrameStrata("TOOLTIP")
		self.tooltipModelFrame:SetFrameLevel(7)
		-- Add a border/background for visibility
		local bg = CreateFrame("Frame", nil, self.tooltipModelFrame, "BackdropTemplate")
		bg:SetAllPoints()
		bg:SetFrameStrata("TOOLTIP")
		bg:SetFrameLevel(1)
		bg:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		bg:SetBackdropColor(0, 0, 0, 0.7)
		-- Hide when tooltip is hidden
		self.tooltipModelFrame:SetScript("OnUpdate", function(self)
			-- Check if any relevant tooltip is visible
			local tooltipVisible = false
			if GameTooltip:IsShown() then
				tooltipVisible = true
			elseif _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"]:IsVisible() then
				tooltipVisible = true
			end

			if not tooltipVisible and self:IsShown() then
				self:Hide()
			end
		end)
		print("RMB_DEBUG: Created tooltip model frame")
	end

	-- Find the tooltip that's currently showing
	local tooltip = nil
	if GameTooltip:IsShown() then
		tooltip = GameTooltip
	elseif _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"]:IsVisible() then
		tooltip = _G["AceConfigDialogTooltip"]
	end

	if not tooltip then
		print("RMB_DEBUG: No tooltip found to attach model to")
		return
	end

	-- Set the model's mount
	local mountID = self.lastTooltipMount.id
	local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
	if creatureDisplayID then
		self.tooltipModelFrame:SetDisplayInfo(creatureDisplayID)
		self.tooltipModelFrame:SetCamDistanceScale(1.5)
		self.tooltipModelFrame:SetPosition(0, 0, 0)
		-- Position the model next to the tooltip
		self.tooltipModelFrame:ClearAllPoints()
		self.tooltipModelFrame:SetPoint("LEFT", tooltip, "RIGHT", 0, 0)
		self.tooltipModelFrame:Show()
		print("RMB_DEBUG: Showing model for " .. self.lastTooltipMount.name)
	else
		print("RMB_DEBUG: No display ID found for mount: " .. tostring(mountID))
	end
end

-- Function to determine group type from key
function addon:GetGroupTypeFromKey(groupKey)
	if not groupKey then return nil end

	-- First check if it's a direct mount reference
	if type(groupKey) == "string" and string.match(groupKey, "^mount_(%d+)$") then
		return "mountID"
	end

	-- Then check if it's a supergroup
	if self.processedData.superGroupMap and self.processedData.superGroupMap[groupKey] then
		return "superGroup"
	end

	-- Check if it's a family within any supergroup
	if self.processedData.superGroupMap then
		for sgName, families in pairs(self.processedData.superGroupMap) do
			for _, famName in ipairs(families) do
				if famName == groupKey then
					return "familyName"
				end
			end
		end
	end

	-- Check if it's a standalone family
	if self.processedData.standaloneFamilyNames and self.processedData.standaloneFamilyNames[groupKey] then
		return "familyName"
	end

	-- If we still haven't found a match, check if there are any mounts with this family name
	if self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[groupKey] and
			#self.processedData.familyToMountIDsMap[groupKey] > 0 then
		return "familyName"
	end

	-- If we got here, we don't know what this is
	print("RMB_DEBUG_WARN: Unable to determine group type for key: " .. tostring(groupKey))
	return nil
end

-- Direct replacement for ShowMountPreview function
-- Update the ShowMountPreview function to handle uncollected mounts
function addon:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	-- Create the model frame if it doesn't exist yet
	if not self.previewDialog then
		-- Create a modal dialog frame
		self.previewDialog = CreateFrame("Frame", "RMB_PreviewDialog", UIParent, "BackdropTemplate")
		local frame = self.previewDialog
		-- Make it a good size and position
		frame:SetSize(350, 350)
		frame:SetPoint("CENTER")
		frame:SetFrameStrata("DIALOG")
		-- To make it draggable
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
		frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		-- Add a background
		frame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile = true,
			tileSize = 32,
			edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		})
		-- Create title text
		frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		frame.title:SetPoint("TOP", 0, -15)
		-- Create model display
		frame.model = CreateFrame("PlayerModel", nil, frame)
		frame.model:SetPoint("TOP", 0, -40)
		frame.model:SetPoint("BOTTOM", 0, 40)
		frame.model:SetPoint("LEFT", 20, 0)
		frame.model:SetPoint("RIGHT", -20, 0)
		-- Create close button
		frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		frame.closeButton:SetPoint("TOPRIGHT", -4, -4)
		frame.closeButton:SetScript("OnClick", function() frame:Hide() end)
		-- Create Next button
		frame.nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.nextButton:SetSize(120, 22)
		frame.nextButton:SetPoint("BOTTOMRIGHT", -20, 15)
		frame.nextButton:SetText("Next Mount")
		-- Create Summon button
		frame.summonButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.summonButton:SetSize(120, 22)
		frame.summonButton:SetPoint("BOTTOMLEFT", 20, 15)
		frame.summonButton:SetText("Summon")
		print("RMB_MODEL: Created preview dialog frame")
	end

	-- Update the frame with the current mount info
	local frame = self.previewDialog
	-- Store the group info for "Next Mount" button
	frame.groupKey = groupKey
	frame.groupType = groupType
	-- Store the current mount ID for "Summon" button
	frame.currentMountID = mountID
	frame.isUncollected = isUncollected
	-- Set the title with proper color
	if frame.title then
		if isUncollected then
			frame.title:SetText("|cff9d9d9d" .. (mountName or "") .. " (Uncollected)|r")
		else
			frame.title:SetText(mountName or "")
		end
	end

	-- Set the model
	if frame.model then
		local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
		if creatureDisplayID then
			frame.model:SetDisplayInfo(creatureDisplayID)
			frame.model:SetCamDistanceScale(1.5)
			frame.model:SetPosition(0, 0, 0)
		else
			print("RMB_DEBUG_PREVIEW: No display ID found for mount: " .. tostring(mountID))
		end
	end

	-- Set up the Next Mount button if we have group info
	if frame.nextButton then
		if groupKey and groupType then
			frame.nextButton:Enable()
			frame.nextButton:SetScript("OnClick", function()
				local nextMountID, nextMountName, nextIsUncollected =
						self:GetRandomMountFromGroup(groupKey, groupType, true)
				if nextMountID then
					self:ShowMountPreview(nextMountID, nextMountName, groupKey, groupType, nextIsUncollected)
				end
			end)
		else
			-- Disable the Next button for individual mounts
			frame.nextButton:Disable()
		end
	end

	-- Set up the Summon button
	if frame.summonButton then
		if isUncollected then
			frame.summonButton:SetText("Cannot Summon")
			frame.summonButton:Disable()
		else
			frame.summonButton:SetText("Summon")
			frame.summonButton:Enable()
			frame.summonButton:SetScript("OnClick", function()
				if frame.currentMountID then
					C_MountJournal.SummonByID(frame.currentMountID)
					frame:Hide()
				end
			end)
		end
	end

	-- Show the frame
	frame:Show()
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
		width = 3.6,
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
			intro = {
				order = 0,
				type = "description",
				name =
				"Mounts mounts mountsMounts mounts mountsMounts mounts mountsMounts mounts mountsMounts mounts mounts",
				width = 3.5,
				fontSize = "normal",
			},
			first_button = {
				order = 1,
				type = "execute",
				name = "<<",
				disabled = (currentPage <= 1),
				func = function() self:FMG_GoToFirstPage() end,
				width = 0.5,
			},
			spacerFirstPrev = {
				order = 1.5,
				type = "description",
				name = " ",
				width = 0.1,
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
				name = string.format("                              %d / %d", currentPage, totalPages),
				width = 1.4,
			},
			next_button = {
				order = 4,
				type = "execute",
				name = ">",
				disabled = (currentPage >= totalPages),
				func = function() self:FMG_NextPage() end,
				width = 0.5,
			},
			spacerNextLast = {
				order = 4.5,
				type = "description",
				name = " ",
				width = 0.1,
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
				-- Calculate total mounts in this family (collected + uncollected)
				local totalMountCount = (groupInfo.mountCount or 0) + (groupInfo.uncollectedCount or 0)
				-- It's a single-mount family ONLY if the total count is exactly 1
				isSingleMountFamily = (totalMountCount == 1)
				if isSingleMountFamily then
					-- Get the mount name if it's collected
					if groupInfo.mountCount == 1 then
						local mIDs = self.processedData.familyToMountIDsMap and
								self.processedData.familyToMountIDsMap[groupKey]
						if mIDs and #mIDs == 1 then
							local mountID = mIDs[1]
							if self.processedData.allCollectedMountFamilyInfo and
									self.processedData.allCollectedMountFamilyInfo[mountID] then
								mountName = self.processedData.allCollectedMountFamilyInfo[mountID].name
							end
						end

						-- Get the mount name if it's uncollected
					elseif groupInfo.uncollectedCount == 1 then
						local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
								self.processedData.familyToUncollectedMountIDsMap[groupKey]
						if uncollectedIDs and #uncollectedIDs == 1 then
							local mountID = uncollectedIDs[1]
							if self.processedData.allUncollectedMountFamilyInfo and
									self.processedData.allUncollectedMountFamilyInfo[mountID] then
								mountName = self.processedData.allUncollectedMountFamilyInfo[mountID].name
							end
						end
					end
				end
			end

			-- Construct the display name differently for single mount families
			local groupDisplayName
			if isSingleMountFamily then
				-- If it's a single mount family, check if it's collected or uncollected
				if groupInfo.mountCount == 1 then
					groupDisplayName = groupInfo.displayName .. " (Mount)"
				else -- Must be uncollected
					groupDisplayName = "|cff9d9d9d" .. groupInfo.displayName .. " (Mount)|r"
				end
			else
				-- It's a multi-mount family or supergroup - display counts with proper colors
				local collectedCount = groupInfo.mountCount or 0
				local uncollectedCount = groupInfo.uncollectedCount or 0
				-- Format the display differently based on collection status
				if collectedCount > 0 and uncollectedCount > 0 then
					-- Some collected, some uncollected
					groupDisplayName = groupInfo.displayName .. " (" .. collectedCount
					if uncollectedCount > 0 then
						groupDisplayName = groupDisplayName .. " + |cff9d9d9d" .. uncollectedCount .. "|r"
					end

					groupDisplayName = groupDisplayName .. ")"
				elseif collectedCount > 0 then
					-- All collected
					groupDisplayName = groupInfo.displayName .. " (" .. collectedCount .. ")"
				else
					-- All uncollected
					groupDisplayName = "|cff9d9d9d" .. groupInfo.displayName .. " (" .. uncollectedCount .. ")|r"
				end
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
						order = 1,
						type = "description",
						name = groupDisplayName,
						width = 1.38,
						fontSize = "medium",
					},
					-- Weight controls
					weightDecrement = {
						order = 2,
						type = "execute",
						name = "-",
						func = function() self:DecrementGroupWeight(groupKey) end,
						width = 0.1,
						disabled = function() return self:GetGroupWeight(groupKey) == 0 end,
					},
					weightDisplay = {
						order = 3,
						type = "description",
						name = self:GetWeightDisplayString(self:GetGroupWeight(groupKey)),
						width = 0.5,
					},
					weightIncrement = {
						order = 4,
						type = "execute",
						name = "+",
						func = function() self:IncrementGroupWeight(groupKey) end,
						width = 0.1,
						disabled = function() return self:GetGroupWeight(groupKey) == 6 end,
					},
					spacerWeightPreview = {
						order = 5,
						type = "description",
						name = " ",
						width = 0.42,
					},
					spacerHiddenExpand = {
						order = 6,
						type = "description",
						name = " ",
						width = 0.50,
						hidden = not isSingleMountFamily,
					},
					expandCollapse = {
						order = 7,
						type = "execute",
						name = isExpanded and "Collapse" or "Expand",
						func = function() self:ToggleExpansionState(groupKey) end,
						width = 0.5,
						hidden = isSingleMountFamily,
					},
					spacerExpandPreview = {
						order = 8,
						type = "description",
						name = " ",
						width = 0.1,
					},
					previewButton = {
						order = 9,
						type = "execute",
						name = "Preview",
						desc = function() return self:GetMountPreviewTooltip(groupKey, groupInfo.type) end,
						func = function(info)
							-- Pass the include uncollected setting to ensure we match what the tooltip shows
							local includeUncollected = self:GetSetting("showUncollectedMounts")
							local mountID, mountName, isUncollected = self:GetRandomMountFromGroup(groupKey,
								groupInfo.type,
								includeUncollected)
							if mountID then
								-- Show preview with the uncollected flag
								self:ShowMountPreview(mountID, mountName, groupKey, groupInfo.type, isUncollected)
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
						name = isExpanded and ("Families & Mounts in " .. groupKey) or "",
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
				spacerFirstPrev = {
					order = 1.5,
					type = "description",
					name = " ",
					width = 0.1,
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
					name = string.format("                              %d / %d", currentPage, totalPages),
					width = 1.4,
				},
				next_button_b = {
					order = 4,
					type = "execute",
					name = ">",
					disabled = (currentPage >= totalPages),
					func = function() self:FMG_NextPage() end,
					width = 0.5,
				},
				spacerNextLast = {
					order = 4.5,
					type = "description",
					name = " ",
					width = 0.1,
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
	if LibStub("AceConfigRegistry-3.0") then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
	else
		print(
			"RMB_DEBUG_UI_ERROR: AceConfigRegistry missing.")
	end

	-- Force tooltip cleanup - this can help with stuck tooltips
	GameTooltip:Hide()
	if _G["AceConfigDialogTooltip"] then
		_G["AceConfigDialogTooltip"]:Hide()
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
	end

	local o = {}
	local showUncollected = self:GetSetting("showUncollectedMounts")
	for sgn, fl in pairs(self.processedData.superGroupMap) do
		-- Count collected mounts in this supergroup
		local mcCollected = self.processedData.superGroupToMountIDsMap and
				#(self.processedData.superGroupToMountIDsMap[sgn] or {}) or 0
		-- Count uncollected mounts if setting enabled
		local mcUncollected = 0
		if showUncollected then
			mcUncollected = self.processedData.superGroupToUncollectedMountIDsMap and
					#(self.processedData.superGroupToUncollectedMountIDsMap[sgn] or {}) or 0
		end

		-- Add supergroup if it has any mounts (collected or uncollected if enabled)
		if mcCollected > 0 or (showUncollected and mcUncollected > 0) then
			table.insert(o, {
				key = sgn,
				type = "superGroup",
				displayName = sgn,
				mountCount = mcCollected,
				uncollectedCount = mcUncollected,
				familiesInGroup = #(fl or {}),
			})
		end
	end

	for fn, _ in pairs(self.processedData.standaloneFamilyNames) do
		-- Count collected mounts in this family
		local mcCollected = self.processedData.familyToMountIDsMap and
				#(self.processedData.familyToMountIDsMap[fn] or {}) or 0
		-- Count uncollected mounts if setting enabled
		local mcUncollected = 0
		if showUncollected then
			mcUncollected = self.processedData.familyToUncollectedMountIDsMap and
					#(self.processedData.familyToUncollectedMountIDsMap[fn] or {}) or 0
		end

		-- Add family if it has any mounts (collected or uncollected if enabled)
		if mcCollected > 0 or (showUncollected and mcUncollected > 0) then
			table.insert(o, {
				key = fn,
				type = "familyName",
				displayName = fn,
				mountCount = mcCollected,
				uncollectedCount = mcUncollected,
			})
		end
	end

	table.sort(o, function(a, b) return (a.displayName or "") < (b.displayName or "") end)
	print("RMB_UI: GetDisplayableGroups returns " .. #o)
	if #o > 0 and #o <= 5 then
		for i = 1, #o do
			print("RMB_UI: Gp: " ..
				tostring(o[i].displayName) .. " C:" .. tostring(o[i].mountCount) ..
				" UC:" .. tostring(o[i].uncollectedCount) .. " T:" .. tostring(o[i].type))
		end
	end

	return o
end

function addon:GetExpandedGroupDetailsArgs(groupKey, groupType)
	print("RMB_DEBUG_UI_DETAILS: GetExpandedGroupDetailsArgs for " .. tostring(groupKey) ..
		" (" .. tostring(groupType) .. ")")
	local detailsArgs = {} -- Table to hold args for the details section
	local displayOrder = 1 -- Ordering for items within detailsArgs
	local showUncollected = self:GetSetting("showUncollectedMounts")
	if not self.processedData then
		print("RMB_DEBUG_UI_DETAILS: No processed data."); return {}
	end

	if groupType == "superGroup" then
		local familyNamesInSG = self.processedData.superGroupMap and self.processedData.superGroupMap[groupKey]
		if familyNamesInSG and #familyNamesInSG > 0 then
			-- Sort the family names for consistent display
			local sortedFams = {}; for _, fn_iter in ipairs(familyNamesInSG) do table.insert(sortedFams, fn_iter) end -- fn_iter to avoid conflict with fn if it was in wider scope

			table.sort(sortedFams)
			print("RMB_DEBUG_UI_DETAILS: Processing Families for SG: " .. tostring(groupKey))
			-- For each family in this supergroup, we'll create a row of controls
			for fidx, fn in ipairs(sortedFams) do
				-- Count collected and uncollected mounts
				local mcCollected = self.processedData.familyToMountIDsMap and
						#(self.processedData.familyToMountIDsMap[fn] or {}) or 0
				local mcUncollected = 0
				if showUncollected then
					mcUncollected = self.processedData.familyToUncollectedMountIDsMap and
							#(self.processedData.familyToUncollectedMountIDsMap[fn] or {}) or 0
				end

				-- Process this family only if there are mounts to show (replaces goto continue)
				if mcCollected > 0 or mcUncollected > 0 then
					-- Check if this is a single-mount family
					local isSingleMountFamily = false
					local isOnlyMountUncollected = false
					if mcCollected + mcUncollected == 1 then
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
						-- If there are no collected but one uncollected, the only mount is uncollected
						isOnlyMountUncollected = (mcCollected == 0 and mcUncollected == 1)
					end

					-- Create display name with appropriate styling
					local familyDisplayName
					if isSingleMountFamily then
						if isOnlyMountUncollected then
							familyDisplayName = "|cff9d9d9d" .. fn .. " (Mount)|r"
						else
							familyDisplayName = fn .. " (Mount)"
						end
					else
						local uncollectedText = ""
						if mcUncollected > 0 then
							uncollectedText = " |cff9d9d9d+" .. mcUncollected .. "|r"
						end

						familyDisplayName = fn .. " (" .. mcCollected .. uncollectedText .. ")"
					end

					-- Make sure to align each family's controls properly in a row
					-- Family name
					detailsArgs["fam_" .. fn .. "_name"] = {
						order = displayOrder,
						type = "description",
						name = "> " .. familyDisplayName,
						width = 1.38,
						fontSize = "medium",
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
						name = function() return self:GetWeightDisplayString(self:GetGroupWeight(fn)) end,
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
					detailsArgs["fam_" .. fn .. "_spacerWeightPreview"] = {
						order = displayOrder,
						type = "description",
						name = " ",
						width = 0.42,
					}
					detailsArgs["fam_" .. fn .. "_spacerHiddenExpand"] = {
						order = displayOrder,
						type = "description",
						name = " ",
						width = 0.50,
						hidden = not isSingleMountFamily,
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
						hidden = isSingleMountFamily,
					}
					displayOrder = displayOrder + 1
					detailsArgs["fam_" .. fn .. "_spacerExpandPreview"] = {
						order = displayOrder,
						type = "description",
						name = " ",
						width = 0.1,
					}
					displayOrder = displayOrder + 1
					-- Preview button
					detailsArgs["fam_" .. fn .. "_preview"] = {
						order = displayOrder,
						type = "execute",
						name = "Preview",
						desc = function()
							-- Add a tooltip function here
							return self:GetMountPreviewTooltip(fn, "familyName")
						end,
						func = function()
							local includeUncollected = self:GetSetting("showUncollectedMounts")
							local mountID, mountName, isUncollected = self:GetRandomMountFromGroup(fn, "familyName",
								includeUncollected)
							if mountID then
								self:ShowMountPreview(mountID, mountName, fn, "familyName", isUncollected)
							else
								print("RMB_PREVIEW: No mount available to preview from this family")
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
							name = "Mounts",
							width = "full",
						}
						displayOrder = displayOrder + 1
						-- Process mounts
						local mountList = {}
						-- Add collected mounts
						local mIDs = self.processedData.familyToMountIDsMap and
								self.processedData.familyToMountIDsMap[fn]
						if mIDs and #mIDs > 0 then
							for _, mountID in ipairs(mIDs) do
								local mountName = "ID:" .. mountID
								if self.processedData.allCollectedMountFamilyInfo and
										self.processedData.allCollectedMountFamilyInfo[mountID] then
									mountName = self.processedData.allCollectedMountFamilyInfo[mountID].name or mountName
								end

								table.insert(mountList, {
									id = mountID,
									name = mountName,
									isCollected = true,
								})
							end
						end

						-- Add uncollected mounts if enabled
						if showUncollected then
							local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
									self.processedData.familyToUncollectedMountIDsMap[fn]
							if uncollectedIDs and #uncollectedIDs > 0 then
								for _, mountID in ipairs(uncollectedIDs) do
									local mountName = "ID:" .. mountID
									if self.processedData.allUncollectedMountFamilyInfo and
											self.processedData.allUncollectedMountFamilyInfo[mountID] then
										mountName = self.processedData.allUncollectedMountFamilyInfo[mountID].name or
												mountName
									end

									table.insert(mountList, {
										id = mountID,
										name = mountName,
										isCollected = false,
									})
								end
							end
						end

						-- Sort all mounts alphabetically
						table.sort(mountList, function(a, b) return (a.name or "") < (b.name or "") end)
						if #mountList > 0 then
							for _, mountData in ipairs(mountList) do
								local mountID = mountData.id
								-- Create a display name with appropriate color based on collection status
								local nameColor = mountData.isCollected and "ffffff" or "9d9d9d"
								local collectionStatus = mountData.isCollected and "" or ""
								-- Mount name
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_name"] = {
									order = displayOrder,
									type = "description",
									name = "|cff" .. nameColor .. "  >> " .. mountData.name .. collectionStatus .. "|r",
									fontSize = "medium",
									width = 1.38,
								}
								displayOrder = displayOrder + 1
								-- Weight decrement button
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_weightDec"] = {
									order = displayOrder,
									type = "execute",
									name = "-",
									func = function() self:DecrementGroupWeight("mount_" .. mountID) end,
									width = 0.1,
									disabled = function() return self:GetGroupWeight("mount_" .. mountID) == 0 end,
								}
								displayOrder = displayOrder + 1
								-- Weight display - apply gray color for uncollected mounts
								local weightDisplayFunc = function()
									local weightStr = self:GetWeightDisplayString(self:GetGroupWeight("mount_" .. mountID))
									if not mountData.isCollected then
										-- Add gray color wrap if it's not already colored
										if not weightStr:find("|cff") then
											weightStr = "|cff9d9d9d" .. weightStr .. "|r"
										end
									end

									return weightStr
								end
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_weightDisp"] = {
									order = displayOrder,
									type = "description",
									name = weightDisplayFunc,
									width = 0.5,
								}
								displayOrder = displayOrder + 1
								-- Weight increment button
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_weightInc"] = {
									order = displayOrder,
									type = "execute",
									name = "+",
									func = function() self:IncrementGroupWeight("mount_" .. mountID) end,
									width = 0.1,
									disabled = function() return self:GetGroupWeight("mount_" .. mountID) == 6 end,
								}
								displayOrder = displayOrder + 1
								-- Spacer
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_spacer"] = {
									order = displayOrder,
									type = "description",
									name = "",
									width = 0.42,
								}
								displayOrder = displayOrder + 1
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_spacerHiddenExpand"] = {
									order = displayOrder,
									type = "description",
									name = "",
									width = 0.60,
								}
								displayOrder = displayOrder + 1
								-- Preview button (for all mounts)
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_preview"] = {
									order = displayOrder,
									type = "execute",
									name = mountData.isCollected and "Preview" or "Preview",
									-- Use the same tooltip function as level 1 mounts
									desc = function()
										return self:GetMountPreviewTooltip("mount_" .. mountID, "mountID")
									end,
									func = function()
										-- Store the exact mount ID and name in local variables to avoid closure issues
										local thisID = mountID
										local thisName = mountData.name
										local isUncollected = not mountData.isCollected
										-- Use these local variables directly
										print("RMB_DEBUG_MOUNT_PREVIEW: Direct preview for " .. thisName)
										self:ShowMountPreview(thisID, thisName, nil, nil, isUncollected)
									end,
									width = 0.5,
								}
								displayOrder = displayOrder + 1
								-- Line break after each mount
								detailsArgs["mount_" .. fn .. "_" .. mountID .. "_linebreak"] = {
									order = displayOrder,
									type = "description",
									name = "",
									width = "full",
								}
								displayOrder = displayOrder + 1
							end
						else
							detailsArgs["fam_" .. fn .. "_nomounts"] = {
								order = displayOrder,
								type = "description",
								name = "No mounts in this family.",
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
					end -- if isFamExpanded
				end -- if mcCollected > 0 or mcUncollected > 0 (end of replaced goto block)

				-- ::continue:: label removed, loop continues to next iteration.
			end -- end for fidx, fn

			-- Add a bottom border for the supergroup after all families are listed
			-- This ensures there's always a bottom border, even if no families are expanded
			-- (or if all families were empty and skipped)
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
		-- Process mounts in a standalone family
		local mountList = {}
		-- Add collected mounts
		local mIDs = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[groupKey]
		if mIDs and #mIDs > 0 then
			for _, mountID in ipairs(mIDs) do
				local mountName = "ID:" .. mountID
				if self.processedData.allCollectedMountFamilyInfo and
						self.processedData.allCollectedMountFamilyInfo[mountID] then
					mountName = self.processedData.allCollectedMountFamilyInfo[mountID].name or mountName
				end

				table.insert(mountList, {
					id = mountID,
					name = mountName,
					isCollected = true,
				})
			end
		end

		-- Add uncollected mounts if enabled
		if showUncollected then
			local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
					self.processedData.familyToUncollectedMountIDsMap[groupKey]
			if uncollectedIDs and #uncollectedIDs > 0 then
				for _, mountID in ipairs(uncollectedIDs) do
					local mountName = "ID:" .. mountID
					if self.processedData.allUncollectedMountFamilyInfo and
							self.processedData.allUncollectedMountFamilyInfo[mountID] then
						mountName = self.processedData.allUncollectedMountFamilyInfo[mountID].name or mountName
					end

					table.insert(mountList, {
						id = mountID,
						name = mountName,
						isCollected = false,
					})
				end
			end
		end

		-- Sort all mounts alphabetically
		table.sort(mountList, function(a, b) return (a.name or "") < (b.name or "") end)
		if #mountList > 0 then
			for _, mountData in ipairs(mountList) do
				local mountID = mountData.id
				-- Create a display name with appropriate color based on collection status
				local nameColor = mountData.isCollected and "ffffff" or "9d9d9d"
				local collectionStatus = mountData.isCollected and "" or " (Mount)"
				-- Mount name
				detailsArgs["mount_" .. mountID .. "_name"] = {
					order = displayOrder,
					type = "description",
					name = "|cff" .. nameColor .. "  > " .. mountData.name .. collectionStatus .. "|r",
					fontSize = "medium",
					width = 1.38,
				}
				displayOrder = displayOrder + 1
				-- Weight decrement button
				detailsArgs["mount_" .. mountID .. "_weightDec"] = {
					order = displayOrder,
					type = "execute",
					name = "-",
					func = function() self:DecrementGroupWeight("mount_" .. mountID) end,
					width = 0.1,
					disabled = function() return self:GetGroupWeight("mount_" .. mountID) == 0 end,
				}
				displayOrder = displayOrder + 1
				-- Weight display
				detailsArgs["mount_" .. mountID .. "_weightDisp"] = {
					order = displayOrder,
					type = "description",
					name = function() return self:GetWeightDisplayString(self:GetGroupWeight("mount_" .. mountID)) end,
					width = 0.5,
				}
				displayOrder = displayOrder + 1
				-- Weight increment button
				detailsArgs["mount_" .. mountID .. "_weightInc"] = {
					order = displayOrder,
					type = "execute",
					name = "+",
					func = function() self:IncrementGroupWeight("mount_" .. mountID) end,
					width = 0.1,
					disabled = function() return self:GetGroupWeight("mount_" .. mountID) == 6 end,
				}
				displayOrder = displayOrder + 1
				-- Spacer
				detailsArgs["mount_" .. mountID .. "_spacer"] = {
					order = displayOrder,
					type = "description",
					name = "",
					width = 0.42,
				}
				detailsArgs["mount_" .. mountID .. "_spacerHiddenExpand"] = {
					order = displayOrder,
					type = "description",
					name = "",
					width = 0.60,
				}
				displayOrder = displayOrder + 1
				-- Preview button (for collected mounts only)
				detailsArgs["mount_" .. mountID .. "_preview"] = {
					order = displayOrder,
					type = "execute",
					name = "Preview",
					-- Use a SIMPLE STRING for tooltip
					desc = function()
						return self:GetMountPreviewTooltip("mount_" .. mountID, "mountID")
					end,
					func = function()
						-- Store the exact mount ID and name in local variables to avoid closure issues
						local thisID = mountID
						local thisName = mountData.name
						local isUncollected = not mountData.isCollected
						-- Use these local variables directly
						print("RMB_DEBUG_MOUNT_PREVIEW: Direct preview for " .. thisName)
						self:ShowMountPreview(thisID, thisName, nil, nil, isUncollected)
					end,
					width = 0.5,
				}
				displayOrder = displayOrder + 1
				-- Line break after each mount
				detailsArgs["mount_" .. mountID .. "_linebreak"] = {
					order = displayOrder,
					type = "description",
					name = "",
					width = "full",
				}
				displayOrder = displayOrder + 1
			end

			-- Add a bottom border header line after the mount list
			detailsArgs["bottom_border"] = {
				order = displayOrder,
				type = "header",
				name = "",
				width = "full",
			}
			displayOrder = displayOrder + 1
		else
			detailsArgs.nm = { order = 1, type = "description", name = "No mounts in this family.", width = "full" }
		end
	else
		detailsArgs.ut = { order = 1, type = "description", name = "Unknown group type.", width = "full" }
	end

	-- Add a placeholder if nothing was added
	if displayOrder == 1 then
		detailsArgs.nd = { order = 1, type = "description", name = "No details available.", width = "full" }
	end

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

function addon:FixPreviewConsistency()
	print("RMB_DEBUG: Setting up refreshing preview system")
	-- Create a table to temporarily store mount selections during a tooltip session
	self.currentPreviewSelection = {}
	-- Replace the GetRandomMountFromGroup function to handle consistency during a single hover
	self.originalGetRandomMountFromGroup = self.GetRandomMountFromGroup
	self.GetRandomMountFromGroup = function(self, groupKey, groupType)
		-- Generate a consistent key for this group
		local cacheKey = groupKey .. (groupType or "")
		-- If we already have a mount selected for this tooltip session, return it
		if self.currentPreviewSelection.key == cacheKey and
				self.currentPreviewSelection.id and
				self.currentPreviewSelection.name then
			return self.currentPreviewSelection.id, self.currentPreviewSelection.name
		end

		-- Get a new random mount
		local mountID, mountName = self.originalGetRandomMountFromGroup(self, groupKey, groupType)
		-- Store this selection for the current tooltip session
		if mountID then
			self.currentPreviewSelection = {
				key = cacheKey,
				id = mountID,
				name = mountName,
			}
		end

		return mountID, mountName
	end
	-- Hook tooltip hiding to reset the selection when tooltip closes
	-- This ensures a new random mount next time
	GameTooltip:HookScript("OnHide", function()
		-- Clear the current preview selection when a tooltip is hidden
		-- This will force a new random mount the next time
		self.currentPreviewSelection = {}
	end)
	-- Also hook AceGUI tooltip
	if LibStub and LibStub("AceGUI-3.0", true) then
		local AceGUI = LibStub("AceGUI-3.0")
		if AceGUI and AceGUI.tooltip then
			AceGUI.tooltip:HookScript("OnHide", function()
				self.currentPreviewSelection = {}
			end)
		end
	end

	-- Also hook AceConfigDialog tooltip
	if LibStub and LibStub("AceConfigDialog-3.0", true) then
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		if AceConfigDialog and AceConfigDialog.tooltip then
			AceConfigDialog.tooltip:HookScript("OnHide", function()
				self.currentPreviewSelection = {}
			end)
		end
	end

	print("RMB_DEBUG: Refreshing preview system installed")
end

-- Helper function to check if any tooltip is visible
function addon:IsAnyTooltipVisible()
	-- Check various tooltip objects
	if GameTooltip:IsShown() then
		return true
	end

	-- Check Ace tooltips
	if _G["AceGUITooltip"] and _G["AceGUITooltip"]:IsVisible() then
		return true
	end

	if _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"]:IsVisible() then
		return true
	end

	return false
end

-- Function to show model for current tooltip
function addon:ShowModelForTooltip()
	-- Make sure we have a valid mount to show
	if not self.lastPreviewMount or not self.lastPreviewMount.mountID then
		return
	end

	local mountID = self.lastPreviewMount.mountID
	local mountName = self.lastPreviewMount.mountName
	-- Get display ID for the mount
	local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
	if not creatureDisplayID then
		return
	end

	-- Find the tooltip owner (try several tooltip objects)
	local tooltipOwner = nil
	if GameTooltip:IsShown() then
		tooltipOwner = GameTooltip:GetOwner()
	elseif _G["AceGUITooltip"] and _G["AceGUITooltip"]:IsVisible() then
		tooltipOwner = _G["AceGUITooltip"]:GetOwner()
	elseif _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"]:IsVisible() then
		tooltipOwner = _G["AceConfigDialogTooltip"]:GetOwner()
	end

	if not tooltipOwner then
		return
	end

	-- Position and show the model
	local frame = self.modelPreviewFrame
	frame:ClearAllPoints()
	frame:SetPoint("LEFT", tooltipOwner, "RIGHT", 10, 0)
	frame:SetDisplayInfo(creatureDisplayID)
	frame:SetCamDistanceScale(1.5)
	frame:SetPosition(0, 0, 0)
	frame:Show()
	print("RMB_MODEL: Showing tooltip model for " .. mountName)
end

-- Modify the existing GetMountPreviewTooltip function to store the mount
function addon:GetMountPreviewTooltip(groupKey, groupType)
	print("RMB_DEBUG_TOOLTIP: Getting tooltip for " .. tostring(groupKey))
	-- Always include uncollected mounts in tooltip if setting is enabled
	local includeUncollected = self:GetSetting("showUncollectedMounts")
	local mountID, mountName, isUncollected = self:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	if not mountID then
		print("RMB_DEBUG_TOOLTIP: No mounts found for " .. tostring(groupKey))
		return "No mounts found in this group"
	end

	-- Store the mount ID and call our OnShow hook
	self.currentTooltipMount = mountID
	-- Return tooltip text with uncollected indicator if needed
	if isUncollected then
		print("RMB_DEBUG_TOOLTIP: Returning uncollected tooltip for " .. tostring(mountName))
		return "|cff9d9d9dMount: " .. mountName .. " (Uncollected)|r\n(Click to open Preview Window)"
	else
		print("RMB_DEBUG_TOOLTIP: Returning collected tooltip for " .. tostring(mountName))
		return "Mount: " .. mountName .. "\n(Click to open Preview Window)"
	end
end

-- Create a tooltip with a model attached
function addon:InitializeModelTooltip()
	-- First create the backdrop frame
	local bg = CreateFrame("Frame", "RMB_ModelTooltipBG", UIParent, "BackdropTemplate")
	bg:SetSize(160, 160)
	bg:SetFrameStrata("TOOLTIP")
	bg:SetFrameLevel(1) -- Set to lowest frame level
	bg:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	bg:SetBackdropColor(0, 0, 0, 0.7) -- Semi-transparent
	bg:Hide()
	-- Now create the model frame with a higher frame level
	local frame = CreateFrame("PlayerModel", "RMB_ModelTooltip", UIParent)
	frame:SetSize(150, 150)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetFrameLevel(10) -- Higher frame level means it renders on top
	frame:Hide()
	-- Link them together
	self.modelTooltipBG = bg
	self.modelTooltip = frame
	-- When showing one, show the other and position them together
	GameTooltip:HookScript("OnShow", function(tooltip)
		if self.currentTooltipMount then
			-- Set up the model
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(self.currentTooltipMount))
			if creatureDisplayID then
				frame:SetDisplayInfo(creatureDisplayID)
				frame:SetCamDistanceScale(1.5)
				frame:SetPosition(0, 0, 0)
				-- Position model
				frame:ClearAllPoints()
				frame:SetPoint("LEFT", tooltip, "RIGHT", 0, 0)
				-- Position backdrop behind model
				bg:ClearAllPoints()
				bg:SetPoint("CENTER", frame, "CENTER", 0, 0)
				-- Show both
				bg:Show()
				frame:Show()
				print("RMB_DEBUG: Showing model for mount ID: " .. self.currentTooltipMount)
			end
		else
			bg:Hide()
			frame:Hide()
		end
	end)
	-- Hide both on tooltip hide
	GameTooltip:HookScript("OnHide", function()
		bg:Hide()
		frame:Hide()
		-- Clear the current mount
		self.currentTooltipMount = nil
	end)
	-- Same for AceConfigDialog tooltip
	if LibStub and LibStub("AceConfigDialog-3.0", true) then
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		if AceConfigDialog and AceConfigDialog.tooltip then
			AceConfigDialog.tooltip:HookScript("OnShow", function(tooltip)
				if self.currentTooltipMount then
					local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(self.currentTooltipMount))
					if creatureDisplayID then
						frame:SetDisplayInfo(creatureDisplayID)
						frame:SetCamDistanceScale(1.5)
						frame:SetPosition(0, 0, 0)
						frame:SetFacing(0.5) -- Adjust this value to change the angle
						frame:ClearAllPoints()
						frame:SetPoint("LEFT", tooltip, "RIGHT", 0, 0)
						bg:ClearAllPoints()
						bg:SetPoint("CENTER", frame, "CENTER", 0, 0)
						bg:Show()
						frame:Show()
					end
				else
					bg:Hide()
					frame:Hide()
				end
			end)
			AceConfigDialog.tooltip:HookScript("OnHide", function()
				bg:Hide()
				frame:Hide()
				self.currentTooltipMount = nil
			end)
		end
	end

	print("RMB_DEBUG: Model tooltip initialized")
end

function addon:InitializeMountUI()
	-- Storage for current tooltip mount
	self.currentTooltipMount = nil
	-- Initialize model tooltip
	self:InitializeModelTooltip()
	print("RMB_DEBUG: Mount UI system initialized")
end

print("RMB_DEBUG: MountListUI.lua END.")
