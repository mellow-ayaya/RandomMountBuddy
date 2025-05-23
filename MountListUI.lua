-- MountListUI.lua - Refactored for Lua 5.1
-- Main UI controller for mount list interface
local addonName, addonTable = ...
local addon = RandomMountBuddy -- Assuming RandomMountBuddy is the global addon table
print("RMB_DEBUG: MountListUI.lua (Refactored) START.")
-- ============================================================================
-- MAIN UI CONTROLLER
-- ============================================================================
-- Initialize all UI systems
function addon:InitializeMountUI()
	print("RMB_UI: Initializing mount UI systems...")
	-- Initialize all subsystems
	self:InitializeMountDataManager()
	self:InitializeMountTooltips()
	self:InitializeMountPreview()
	-- Initialize UI state
	self.fmCurrentPage = 1
	self.fmItemsPerPage = self.fmItemsPerPage or 15
	print("RMB_UI: Mount UI system initialized")
end

-- ============================================================================
-- MAIN UI BUILDING FUNCTION (Greatly Simplified)
-- ============================================================================
function addon:BuildFamilyManagementArgs()
	print("RMB_UI: BuildFamilyManagementArgs called (Refactored)")
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
	local allDisplayableGroups = self.MountDataManager:GetDisplayableGroups()
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
	-- Add column headers
	local headerComponents = self.MountUIComponents:CreateColumnHeaders(displayOrder)
	for k, v in pairs(headerComponents) do
		pageArgs[k] = v
	end

	-- Assuming CreateColumnHeaders handles its own internal ordering and the overall
	-- 'displayOrder' here is for the next major block. If headers consume more than
	-- one logical "slot", this might need adjustment based on CreateColumnHeaders' behavior.
	displayOrder = displayOrder + 1
	-- Calculate page bounds
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)
	print("RMB_UI: Building page " .. currentPage .. " (" .. startIndex .. "-" .. endIndex .. " of " .. totalGroups .. ")")
	-- Build group entries
	local groupEntryOrder = displayOrder -- Use a separate order counter for main group entries
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

			-- Build complete group entry using components
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

	-- Add pagination controls
	-- Pass the current groupEntryOrder so pagination controls can be ordered after the group entries
	local paginationComponents = self.MountUIComponents:CreatePaginationControls(currentPage, totalPages, groupEntryOrder)
	for k, v in pairs(paginationComponents) do
		pageArgs[k] = v
	end

	-- The next available order slot would be groupEntryOrder + number of pagination controls
	-- if manual_refresh_button was to follow them directly.
	-- However, manual_refresh_button uses a high fixed order.
	-- Add refresh button
	pageArgs["manual_refresh_button"] = {
		order = 9999, -- High order to place it at the end
		type = "execute",
		name = "Refresh List",
		func = function()
			self.MountDataManager:InvalidateCache("manual_refresh")
			self:PopulateFamilyManagementUI()
		end,
		width = 3.6,
	}
	print("RMB_UI: Built UI with " .. (endIndex - startIndex + 1) .. " group entries")
	return pageArgs
end

-- ============================================================================
-- EXPANDED DETAILS BUILDER (Simplified)
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
	if not familyNamesInSG or #familyNamesInSG == 0 then -- # is fine if familyNamesInSG is an array
		return { no_families = { order = 1, type = "description", name = "No families found in this supergroup.", width = "full" } }
	end

	-- Sort families for consistent display
	local sortedFamilies = {}
	for _, familyName in ipairs(familyNamesInSG) do -- ipairs is fine for arrays
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

		-- Process only if there are mounts (Replaces goto continue)
		if not (collectedCount == 0 and uncollectedCount == 0) then
			-- Create family display name
			local familyDisplayName = self:CreateFamilyDisplayName(familyName, collectedCount, uncollectedCount)
			-- Is family expanded?
			local isFamilyExpanded = self:IsGroupExpanded(familyName)
			-- Build family entry
			-- MountUIComponents:BuildFamilyEntry is expected to set internal orders based on `displayOrder`
			local familyEntry = self.MountUIComponents:BuildFamilyEntry(familyName, familyDisplayName, isFamilyExpanded,
				displayOrder)
			-- Add family entry to details
			for k, v in pairs(familyEntry) do
				detailsArgs["fam_" .. familyName .. "_" .. k] = v
			end

			displayOrder = displayOrder + 2 -- Increment for the family entry block
			-- Add mount details if family is expanded
			if isFamilyExpanded then
				detailsArgs["fam_" .. familyName .. "_mountsheader"] = {
					order = displayOrder,
					type = "header",
					name = "Mounts",
					width = "full",
				}
				displayOrder = displayOrder + 1     -- Increment for the "Mounts" header
				local mountListBaseOrder = displayOrder -- Base order for mount list items
				-- Build mount list
				-- MountUIComponents:BuildMountList is expected to set internal orders based on `mountListBaseOrder`
				local mountEntries = self.MountUIComponents:BuildMountList(familyName, "familyName", mountListBaseOrder)
				local mountItemCount = 0
				for k, v_mount_entry in pairs(mountEntries) do -- pairs is fine for dictionaries
					detailsArgs["fam_" .. familyName .. "_" .. k] = v_mount_entry
					mountItemCount = mountItemCount + 1
				end

				-- Advance displayOrder by the estimated number of "slots" consumed by mountEntries.
				-- Original code used (#mountEntries * 2). We use mountItemCount * 2.
				-- This assumes each "item" in mountEntries effectively takes 2 order slots,
				-- and BuildMountList sets its children's orders accordingly.
				if mountItemCount > 0 then
					displayOrder = mountListBaseOrder + (mountItemCount * 2)
				end

				-- If mountItemCount is 0, displayOrder remains as it was after the header.
			end
		end

		-- End of loop iteration (was ::continue:: point)
	end

	-- Add bottom border
	detailsArgs["supergroup_bottom_border"] = {
		order = displayOrder, -- Use the final displayOrder
		type = "header",
		name = "",
		width = "full",
	}
	return detailsArgs
end

function addon:BuildFamilyDetails(groupKey, startOrder, showUncollected)
	local detailsArgs = {}
	-- Build mount list for this family
	-- MountUIComponents:BuildMountList is expected to set internal orders based on `startOrder`
	local mountEntries = self.MountUIComponents:BuildMountList(groupKey, "familyName", startOrder)
	if not mountEntries or not next(mountEntries) then -- next() is a robust way to check for empty table
		return { no_mounts = { order = 1, type = "description", name = "No mounts in this family.", width = "full" } }
	end

	local maxOrderUsed = startOrder - 1 -- Initialize to be less than any valid order
	-- Add all mount entries
	for k, v_entry in pairs(mountEntries) do
		detailsArgs[k] = v_entry
		if v_entry.order and v_entry.order > maxOrderUsed then
			maxOrderUsed = v_entry.order
		end
	end

	-- Add bottom border, ensuring it's after all mount entries
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
	-- Check if single mount family
	if collectedCount + uncollectedCount == 1 then
		if collectedCount == 1 then
			return familyName .. " (Mount)"
		else
			return "|cff9d9d9d" .. familyName .. " (Mount)|r"
		end
	end

	-- Multi-mount family
	local displayName = familyName .. " (" .. collectedCount
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
	print("RMB_UI: PopulateFamilyManagementUI called (Refactored)")
	if not self.fmArgsRef then
		print("RMB_UI_ERROR: self.fmArgsRef is nil! Options.lua problem.")
		return
	end

	-- Measure performance
	local startTime = debugprofilestop() -- WoW API function
	-- Build new UI arguments using optimized system
	local newPageContentArgs = self:BuildFamilyManagementArgs()
	-- Update the options table
	wipe(self.fmArgsRef) -- WoW API function or common utility
	for k, v in pairs(newPageContentArgs) do
		self.fmArgsRef[k] = v
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then -- Check LibStub exists and get library safely
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
	else
		print("RMB_UI_ERROR: AceConfigRegistry missing or LibStub not available.")
	end

	-- Clean up tooltips
	if GameTooltip and GameTooltip.Hide then GameTooltip:Hide() end -- WoW API

	if _G["AceConfigDialogTooltip"] and _G["AceConfigDialogTooltip"].Hide then
		_G["AceConfigDialogTooltip"]:Hide()
	end

	-- Performance logging
	local endTime = debugprofilestop() -- WoW API function
	local elapsed = endTime - startTime
	if elapsed > 50 then
		print(string.format("RMB_PERF: UI build took %.2fms", elapsed))
	end

	print("RMB_UI: UI populated successfully")
end

-- ============================================================================
-- WEIGHT MANAGEMENT (Moved from original file)
-- ============================================================================
function addon:DecrementGroupWeight(groupKey)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_WEIGHT: DB or profile not available")
		return
	end

	local currentWeight = self:GetGroupWeight(groupKey)
	local newWeight = math.max(0, currentWeight - 1)
	if newWeight ~= currentWeight then
		self.db.profile.groupWeights[groupKey] = newWeight
		print("RMB_WEIGHT: Decremented " .. tostring(groupKey) .. " to " .. tostring(newWeight))
		self:PopulateFamilyManagementUI()
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
		self.db.profile.groupWeights[groupKey] = newWeight
		print("RMB_WEIGHT: Incremented " .. tostring(groupKey) .. " to " .. tostring(newWeight))
		self:PopulateFamilyManagementUI()
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
	self:PopulateFamilyManagementUI()
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
		return false -- Return false if unable to perform action
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
-- PAGINATION FUNCTIONS (Simplified)
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
		self:PopulateFamilyManagementUI()
	end
end

function addon:FMG_GoToPage(pageNumber)
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self.MountDataManager:GetDisplayableGroups()
	if not allGroups then return end -- Guard against nil

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	local targetPage = tonumber(pageNumber)
	if targetPage and targetPage >= 1 and targetPage <= totalPages then
		self.fmCurrentPage = targetPage
		self:PopulateFamilyManagementUI()
	end
end

function addon:FMG_NextPage()
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self.MountDataManager:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	if self.fmCurrentPage < totalPages then
		self:CollapseAllExpanded() -- Consider if this should only happen if page actually changes
		self:FMG_GoToPage(self.fmCurrentPage + 1)
	end
end

function addon:FMG_PrevPage()
	if not self.RMB_DataReadyForUI then return end

	if self.fmCurrentPage > 1 then
		self:CollapseAllExpanded() -- Consider if this should only happen if page actually changes
		self:FMG_GoToPage(self.fmCurrentPage - 1)
	end
end

function addon:FMG_GoToFirstPage()
	if not self.RMB_DataReadyForUI then return end -- Added guard

	self:CollapseAllExpanded()
	self:FMG_GoToPage(1)
end

function addon:FMG_GoToLastPage()
	if not self.RMB_DataReadyForUI then return end -- Added guard

	local allGroups = self.MountDataManager:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	self:CollapseAllExpanded()
	self:FMG_GoToPage(totalPages)
end

-- ============================================================================
-- LEGACY COMPATIBILITY FUNCTIONS
-- ============================================================================
-- These functions maintain compatibility with existing code
function addon:GetDisplayableGroups()
	-- Ensure MountDataManager exists and has the method
	if self.MountDataManager and self.MountDataManager.GetDisplayableGroups then
		return self.MountDataManager:GetDisplayableGroups()
	end

	return {} -- Return an empty table if not available
end

function addon:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	if self.MountDataManager and self.MountDataManager.GetRandomMountFromGroup then
		return self.MountDataManager:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	end

	return nil -- Or appropriate default
end

function addon:GetGroupTypeFromKey(groupKey)
	if self.MountDataManager and self.MountDataManager.GetGroupTypeFromKey then
		return self.MountDataManager:GetGroupTypeFromKey(groupKey)
	end

	return nil
end

function addon:GetMountPreviewTooltip(groupKey, groupType)
	if self.MountTooltips and self.MountTooltips.GetMountPreviewTooltip then
		return self.MountTooltips:GetMountPreviewTooltip(groupKey, groupType)
	end

	return nil
end

function addon:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	if self.MountPreview and self.MountPreview.ShowMountPreview then
		return self.MountPreview:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	end

	-- This function might not have a sensible default return, or could return false
end

-- Trigger UI refresh
function addon:TriggerFamilyManagementUIRefresh()
	if self.MountDataManager and self.MountDataManager.InvalidateCache then
		self.MountDataManager:InvalidateCache("manual_refresh")
	else
		print("RMB_WARN: MountDataManager or InvalidateCache not found for TriggerFamilyManagementUIRefresh")
	end

	self:PopulateFamilyManagementUI()
end

print("RMB_DEBUG: MountListUI.lua (Refactored) END.")
