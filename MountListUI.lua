-- MountListUI.lua - Properly Integrated with MountUIComponents and Clean Architecture
-- Main UI controller for mount list interface
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountListUI.lua (Properly Integrated) START.")
-- ============================================================================
-- MAIN UI CONTROLLER
-- ============================================================================
function addon:InitializeMountUI()
	print("RMB_UI: Initializing mount UI systems...")
	-- Initialize UI state
	self.fmCurrentPage = 1
	self.fmItemsPerPage = self.fmItemsPerPage or 15
	print("RMB_UI: Mount UI system initialized")
end

-- ============================================================================
-- MAIN UI BUILDING FUNCTION
-- ============================================================================
function addon:BuildFamilyManagementArgs()
	print("RMB_UI: BuildFamilyManagementArgs called (Properly Integrated)")
	local pageArgs = {}
	local displayOrder = 1
	-- Check if data is ready
	if not self.RMB_DataReadyForUI then
		pageArgs.loading_placeholder = {
			order = displayOrder,
			type = "description",
			name = "Mount data is loading or not yet processed. This list will appear after login finishes.",
		}
		return pageArgs
	end

	-- Get displayable groups from data manager
	local allDisplayableGroups = self:GetDisplayableGroups()
	if not allDisplayableGroups or #allDisplayableGroups == 0 then
		pageArgs["no_groups_msg"] = {
			order = displayOrder,
			type = "description",
			name = "No mount groups found (0 collected or no matches).",
		}
		return pageArgs
	end

	-- Calculate pagination
	local totalGroups = #allDisplayableGroups
	local itemsPerPage = self:FMG_GetItemsPerPage()
	local totalPages = math.max(1, math.ceil(totalGroups / itemsPerPage))
	local currentPage = math.max(1, math.min(self.fmCurrentPage or 1, totalPages))
	self.fmCurrentPage = currentPage
	-- Add column headers using MountUIComponents
	if self.MountUIComponents then
		local headerComponents = self.MountUIComponents:CreateColumnHeaders(displayOrder)
		for k, v in pairs(headerComponents) do
			pageArgs[k] = v
		end

		displayOrder = displayOrder + 1
	else
		print("RMB_UI_ERROR: MountUIComponents not available")
		return pageArgs
	end

	-- Calculate page bounds
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)
	print("RMB_UI: Building page " .. currentPage .. " (" .. startIndex .. "-" .. endIndex .. " of " .. totalGroups .. ")")
	-- Build group entries
	local groupEntryOrder = displayOrder
	for i = startIndex, endIndex do
		local groupData = allDisplayableGroups[i]
		if groupData then
			local groupKey = groupData.key
			local isExpanded = self:IsGroupExpanded(groupKey)
			-- Get expanded details if needed
			local expandedDetails = nil
			if isExpanded then
				expandedDetails = self:GetExpandedGroupDetailsArgs(groupKey, groupData.type)
			end

			-- Build complete group entry using MountUIComponents
			local groupEntry = self.MountUIComponents:BuildGroupEntry(groupData, isExpanded, expandedDetails)
			pageArgs["entry_" .. groupKey] = {
				order = groupEntryOrder,
				type = "group",
				name = "",
				inline = true,
				handler = self,
				args = groupEntry,
			}
			groupEntryOrder = groupEntryOrder + 1
		end
	end

	-- Add pagination controls using MountUIComponents
	if self.MountUIComponents then
		local paginationComponents = self.MountUIComponents:CreatePaginationControls(currentPage, totalPages, groupEntryOrder)
		for k, v in pairs(paginationComponents) do
			pageArgs[k] = v
		end
	end

	-- Add refresh button
	pageArgs["manual_refresh_button"] = {
		order = 9999,
		type = "execute",
		name = "Refresh List",
		func = function()
			self:TriggerFamilyManagementUIRefresh()
		end,
		width = 3.6,
	}
	print("RMB_UI: Built UI with " .. (endIndex - startIndex + 1) .. " group entries")
	return pageArgs
end

-- ============================================================================
-- EXPANDED DETAILS BUILDER
-- ============================================================================
function addon:GetExpandedGroupDetailsArgs(groupKey, groupType)
	print("RMB_UI_DETAILS: GetExpandedGroupDetailsArgs for " .. tostring(groupKey) .. " (" .. tostring(groupType) .. ")")
	local detailsArgs = {}
	local displayOrder = 1
	local showUncollected = self:GetSetting("showUncollectedMounts")
	if not self.processedData then
		return { no_data = { order = 1, type = "description", name = "No processed data available.", width = "full" } }
	end

	if groupType == "superGroup" then
		-- Build supergroup details (families within the supergroup)
		detailsArgs = self:BuildSuperGroupDetails(groupKey, displayOrder, showUncollected)
	elseif groupType == "familyName" then
		-- Build family details (individual mounts)
		detailsArgs = self:BuildFamilyDetails(groupKey, displayOrder, showUncollected)
	else
		detailsArgs.unknown_type = {
			order = 1,
			type = "description",
			name = "Unknown group type: " .. tostring(groupType),
			width = "full",
		}
	end

	return detailsArgs
end

function addon:BuildSuperGroupDetails(groupKey, startOrder, showUncollected)
	local detailsArgs = {}
	local displayOrder = startOrder
	-- Get families in this supergroup
	local familyNamesInSG = self.processedData.superGroupMap and self.processedData.superGroupMap[groupKey]
	if not familyNamesInSG or #familyNamesInSG == 0 then
		return { no_families = { order = 1, type = "description", name = "No families found in this supergroup.", width = "full" } }
	end

	-- Sort families for consistent display
	local sortedFamilies = {}
	for _, familyName in ipairs(familyNamesInSG) do
		table.insert(sortedFamilies, familyName)
	end

	table.sort(sortedFamilies)
	-- Build each family entry
	for _, familyName in ipairs(sortedFamilies) do
		-- Count mounts in this family
		local collectedCount = (self.processedData.familyToMountIDsMap and
			self.processedData.familyToMountIDsMap[familyName] and
			#(self.processedData.familyToMountIDsMap[familyName])) or 0
		local uncollectedCount = 0
		if showUncollected then
			uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
				self.processedData.familyToUncollectedMountIDsMap[familyName] and
				#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
		end

		-- Process only if there are mounts
		if collectedCount > 0 or uncollectedCount > 0 then
			-- Create family display name
			local familyDisplayName = self:CreateFamilyDisplayName(familyName, collectedCount, uncollectedCount)
			-- Is family expanded?
			local isFamilyExpanded = self:IsGroupExpanded(familyName)
			-- Build family entry using MountUIComponents
			if self.MountUIComponents then
				local familyEntry = self.MountUIComponents:BuildFamilyEntry(familyName, familyDisplayName, isFamilyExpanded,
					displayOrder)
				-- Add family entry to details
				for k, v in pairs(familyEntry) do
					detailsArgs["fam_" .. familyName .. "_" .. k] = v
				end
			end

			displayOrder = displayOrder + 2
			-- Add mount details if family is expanded
			if isFamilyExpanded then
				detailsArgs["fam_" .. familyName .. "_mountsheader"] = {
					order = displayOrder,
					type = "header",
					name = "Mounts",
					width = "full",
				}
				displayOrder = displayOrder + 1
				-- Build mount list using MountUIComponents
				if self.MountUIComponents then
					local mountEntries = self.MountUIComponents:BuildMountList(familyName, "familyName", displayOrder)
					local mountItemCount = 0
					for k, v_mount_entry in pairs(mountEntries) do
						detailsArgs["fam_" .. familyName .. "_" .. k] = v_mount_entry
						mountItemCount = mountItemCount + 1
					end

					if mountItemCount > 0 then
						displayOrder = displayOrder + (mountItemCount * 2)
					end
				end

				detailsArgs["fam_" .. familyName .. "_separator"] = {
					order = displayOrder,
					type = "header",
					name = "",
					width = "full",
				}
				displayOrder = displayOrder + 1
			end
		end
	end

	-- Add bottom border
	detailsArgs["supergroup_bottom_border"] = {
		order = displayOrder,
		type = "header",
		name = "",
		width = "full",
	}
	return detailsArgs
end

function addon:BuildFamilyDetails(groupKey, startOrder, showUncollected)
	local detailsArgs = {}
	-- Build mount list using MountUIComponents
	if not self.MountUIComponents then
		return { no_components = { order = 1, type = "description", name = "MountUIComponents not available.", width = "full" } }
	end

	local mountEntries = self.MountUIComponents:BuildMountList(groupKey, "familyName", startOrder)
	if not mountEntries or not next(mountEntries) then
		return { no_mounts = { order = 1, type = "description", name = "No mounts in this family.", width = "full" } }
	end

	local maxOrderUsed = startOrder - 1
	-- Add all mount entries
	for k, v_entry in pairs(mountEntries) do
		detailsArgs[k] = v_entry
		if v_entry.order and v_entry.order > maxOrderUsed then
			maxOrderUsed = v_entry.order
		end
	end

	-- Add bottom border
	detailsArgs["bottom_border"] = {
		order = maxOrderUsed + 1,
		type = "header",
		name = "",
		width = "full",
	}
	return detailsArgs
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
function addon:CreateFamilyDisplayName(familyName, collectedCount, uncollectedCount)
	local totalMounts = collectedCount + uncollectedCount
	-- Define color codes for indicators
	local familyIndicator = "|cff0070dd[F]|r" -- Blue
	local mountIndicator = "|cff1eff00[M]|r" -- Green
	-- Check if single mount family
	if totalMounts == 1 then
		-- Single mount family - use [M] indicator
		if collectedCount == 1 then
			return mountIndicator .. " " .. familyName .. ""
		else
			return "|cff9d9d9d" .. mountIndicator .. " " .. familyName .. "|r"
		end
	end

	-- Multi-mount family - use [F] indicator
	local displayName = familyIndicator .. " " .. familyName .. " (" .. collectedCount
	if uncollectedCount > 0 then
		displayName = displayName .. " |cff9d9d9d+" .. uncollectedCount .. "|r"
	end

	displayName = displayName .. ")"
	return displayName
end

-- ============================================================================
-- UI REFRESH AND POPULATION
-- ============================================================================
function addon:PopulateFamilyManagementUI()
	print("RMB_UI: PopulateFamilyManagementUI called (Properly Integrated)")
	if not self.fmArgsRef then
		print("RMB_UI_ERROR: self.fmArgsRef is nil! Options.lua problem.")
		return
	end

	-- Measure performance
	local startTime = debugprofilestop()
	-- Build new UI arguments
	local newPageContentArgs = self:BuildFamilyManagementArgs()
	-- Update the options table
	wipe(self.fmArgsRef)
	for k, v in pairs(newPageContentArgs) do
		self.fmArgsRef[k] = v
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
	else
		print("RMB_UI_ERROR: AceConfigRegistry missing or LibStub not available.")
	end

	-- Clean up tooltips
	if GameTooltip and GameTooltip.Hide then GameTooltip:Hide() end

	if _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"].Hide then
		_G["AceConfigDialogTooltip"]:Hide()
	end

	-- Performance logging
	local endTime = debugprofilestop()
	local elapsed = endTime - startTime
	if elapsed > 50 then
		print(string.format("RMB_PERF: UI build took %.2fms", elapsed))
	end

	print("RMB_UI: UI populated successfully")
end

-- ============================================================================
-- WEIGHT MANAGEMENT
-- ============================================================================
function addon:DecrementGroupWeight(groupKey)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_WEIGHT: DB or profile not available")
		return
	end

	local currentWeight = self:GetGroupWeight(groupKey)
	local newWeight = math.max(0, currentWeight - 1)
	if newWeight ~= currentWeight then
		-- Use SetGroupWeight which handles syncing
		self:SetGroupWeight(groupKey, newWeight)
		print("RMB_WEIGHT: Decremented " .. tostring(groupKey) .. " to " .. tostring(newWeight))
		self:TriggerFamilyManagementUIRefresh()
	end
end

function addon:IncrementGroupWeight(groupKey)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_WEIGHT: DB or profile not available")
		return
	end

	local currentWeight = self:GetGroupWeight(groupKey)
	local newWeight = math.min(6, currentWeight + 1)
	if newWeight ~= currentWeight then
		-- Use SetGroupWeight which handles syncing
		self:SetGroupWeight(groupKey, newWeight)
		print("RMB_WEIGHT: Incremented " .. tostring(groupKey) .. " to " .. tostring(newWeight))
		self:TriggerFamilyManagementUIRefresh()
	end
end

-- ============================================================================
-- EXPANSION STATE MANAGEMENT
-- ============================================================================
function addon:ToggleExpansionState(groupKey)
	if not (self.db and self.db.profile and self.db.profile.expansionStates) then
		print("RMB_UI: ExpStates DB ERR")
		return
	end

	self.db.profile.expansionStates[groupKey] = not self.db.profile.expansionStates[groupKey]
	print("RMB_UI: Toggled expansion for '" .. tostring(groupKey) .. "' to " ..
		tostring(self.db.profile.expansionStates[groupKey]))
	self:TriggerFamilyManagementUIRefresh()
end

function addon:IsGroupExpanded(groupKey)
	if not (self.db and self.db.profile and self.db.profile.expansionStates) then
		return false
	end

	return self.db.profile.expansionStates[groupKey] == true
end

function addon:CollapseAllExpanded()
	print("RMB_UI: Collapsing all expanded groups")
	if not (self.db and self.db.profile and self.db.profile.expansionStates) then
		return false
	end

	local changed = false
	for groupKey, state in pairs(self.db.profile.expansionStates) do
		if state == true then
			self.db.profile.expansionStates[groupKey] = false
			changed = true
		end
	end

	return changed
end

-- ============================================================================
-- PAGINATION FUNCTIONS
-- ============================================================================
function addon:FMG_GetItemsPerPage()
	return self.fmItemsPerPage or 15
end

function addon:FMG_SetItemsPerPage(items)
	local numItems = tonumber(items)
	if numItems and numItems >= 5 and numItems <= 50 then
		self.fmItemsPerPage = numItems
		if self.db and self.db.profile then
			self.db.profile.fmItemsPerPage = numItems
		end

		self.fmCurrentPage = 1
		self:TriggerFamilyManagementUIRefresh()
	end
end

function addon:FMG_GoToPage(pageNumber)
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	local targetPage = tonumber(pageNumber)
	if targetPage and targetPage >= 1 and targetPage <= totalPages then
		self.fmCurrentPage = targetPage
		self:TriggerFamilyManagementUIRefresh()
	end
end

function addon:FMG_NextPage()
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	if self.fmCurrentPage < totalPages then
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
	if not self.RMB_DataReadyForUI then return end

	self:CollapseAllExpanded()
	self:FMG_GoToPage(1)
end

function addon:FMG_GoToLastPage()
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	self:CollapseAllExpanded()
	self:FMG_GoToPage(totalPages)
end

-- ============================================================================
-- CLEAN MODULE INTERFACE FUNCTIONS
-- ============================================================================
function addon:GetDisplayableGroups()
	if self.MountDataManager and self.MountDataManager.GetDisplayableGroups then
		return self.MountDataManager:GetDisplayableGroups()
	end

	print("RMB_UI_ERROR: MountDataManager not available for GetDisplayableGroups")
	return {}
end

function addon:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	if self.MountDataManager and self.MountDataManager.GetRandomMountFromGroup then
		return self.MountDataManager:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	end

	print("RMB_UI_ERROR: MountDataManager not available for GetRandomMountFromGroup")
	return nil
end

function addon:GetGroupTypeFromKey(groupKey)
	if self.MountDataManager and self.MountDataManager.GetGroupTypeFromKey then
		return self.MountDataManager:GetGroupTypeFromKey(groupKey)
	end

	print("RMB_UI_ERROR: MountDataManager not available for GetGroupTypeFromKey")
	return nil
end

function addon:GetMountPreviewTooltip(groupKey, groupType)
	if self.MountTooltips and self.MountTooltips.GetMountPreviewTooltip then
		return self.MountTooltips:GetMountPreviewTooltip(groupKey, groupType)
	end

	print("RMB_UI_ERROR: MountTooltips not available for GetMountPreviewTooltip")
	return "Tooltip not available"
end

function addon:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	if self.MountPreview and self.MountPreview.ShowMountPreview then
		return self.MountPreview:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	end

	print("RMB_UI_ERROR: MountPreview not available for ShowMountPreview")
	return false
end

function addon:TriggerFamilyManagementUIRefresh()
	print("RMB_UI: Manual refresh triggered")
	if self.MountDataManager and self.MountDataManager.InvalidateCache then
		self.MountDataManager:InvalidateCache("manual_refresh")
	else
		print("RMB_UI_WARN: MountDataManager or InvalidateCache not found for refresh")
	end

	self:PopulateFamilyManagementUI()
end

print("RMB_DEBUG: MountListUI.lua (Properly Integrated) END.")
