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
	self.fmItemsPerPage = self.fmItemsPerPage or 14
	print("RMB_UI: Mount UI system initialized")
end

-- ============================================================================
-- MAIN UI BUILDING FUNCTION
-- ============================================================================
function addon:BuildFamilyManagementArgs()
	print("RMB_UI: BuildFamilyManagementArgs called (With Search and Filters)")
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

	-- SEARCH SECTION
	pageArgs.search_description = {
		order = displayOrder,
		type = "description",
		name = "|cffffd700  Search:|r",
		width = 0.34,
	}
	displayOrder = displayOrder + 1
	pageArgs.search_input = {
		order = displayOrder,
		type = "input",
		name = "",
		desc = "Type & press Enter or click OK to search.",
		get = function()
			return self.SearchSystem and self.SearchSystem:GetSearchTerm() or ""
		end,
		set = function(info, value)
			local searchTerm = value and value:trim() or ""
			if searchTerm ~= "" then
				self:StartSearch(searchTerm)
			else
				self:ClearSearch()
			end
		end,
		width = 1.02,
	}
	displayOrder = displayOrder + 1
	-- FILTER SECTION (to the right of search)
	pageArgs.filter_description = {
		order = displayOrder,
		type = "description",
		name = " ",
		width = 0.22,
	}
	displayOrder = displayOrder + 1
	pageArgs.filter_toggle = {
		order = displayOrder,
		type = "execute",
		name = "Filter",
		desc = "Click to show/hide filter options",
		func = function()
			-- Toggle filter panel visibility
			local isExpanded = self:GetSetting("filtersExpanded") or false
			self:SetSetting("filtersExpanded", not isExpanded)
			self:PopulateFamilyManagementUI()
		end,
		width = 0.5,
	}
	displayOrder = displayOrder + 1
	-- Reset button (only show when filters are active)
	if self:AreFiltersActive() then
		pageArgs.filter_reset = {
			order = displayOrder,
			type = "execute",
			name = "Reset Filter",
			desc = "Clear all active filters",
			func = function()
				self:ResetAllFilters()
			end,
			width = 0.3,
		}
		displayOrder = displayOrder + 1
	end

	-- Show filter status if active
	local filterStatus = self:GetFilterStatus()
	if filterStatus then
		pageArgs.filter_status = {
			order = displayOrder,
			type = "description",
			name = "  |cffff9900" .. filterStatus .. "|r",
			width = "full", -- Changed from 2.0 to use full available width
		}
		displayOrder = displayOrder + 1
	end

	-- Show search status if active
	local searchStatus = self:GetSearchStatus()
	if searchStatus then
		pageArgs.search_status = {
			order = displayOrder,
			type = "description",
			name = "  |cff00ff00" .. searchStatus .. "|r",
			width = 2.0,
		}
		displayOrder = displayOrder + 1
		pageArgs.search_clear = {
			order = displayOrder,
			type = "execute",
			name = "Clear Search",
			desc = "Clear search and return to filtered view",
			func = function()
				self:ClearSearch()
			end,
			width = 0.6,
		}
		displayOrder = displayOrder + 1
	end

	-- EXPANDABLE FILTER PANEL
	if self:GetSetting("filtersExpanded") then
		pageArgs.filter_panel = {
			order = displayOrder,
			type = "group",
			inline = true,
			name = "Filter Options",
			args = self:BuildFilterPanelArgs(),
		}
		displayOrder = displayOrder + 1
	end

	-- MOUNT GROUP SELECTION LOGIC (Updated to respect filters)
	local allDisplayableGroups
	local usingSearchResults = false
	if self:IsSearchActive() then
		-- Search is active - get search results and apply filters to them
		allDisplayableGroups = self:GetSearchResults()
		usingSearchResults = true
		-- Apply filters to search results
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	else
		-- No search active - get all groups and apply filters
		allDisplayableGroups = self:GetDisplayableGroups()
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	end

	if not allDisplayableGroups or #allDisplayableGroups == 0 then
		local message
		if usingSearchResults and self:AreFiltersActive() then
			message = "No mounts found matching your search and filter criteria."
		elseif usingSearchResults then
			message = "No mounts found matching your search. Try different keywords."
		elseif self:AreFiltersActive() then
			message = "No mounts match your current filter settings."
		else
			message = "No mount groups found (0 collected or no matches)."
		end

		pageArgs["no_groups_msg"] = {
			order = displayOrder,
			type = "description",
			name = message,
		}
		return pageArgs
	end

	-- PAGINATION LOGIC (rest remains the same)
	local totalGroups = #allDisplayableGroups
	local itemsPerPage = self:FMG_GetItemsPerPage()
	if usingSearchResults then
		itemsPerPage = math.min(totalGroups, 100)
	end

	local totalPages = math.max(1, math.ceil(totalGroups / itemsPerPage))
	local currentPage = math.max(1, math.min(self.fmCurrentPage or 1, totalPages))
	if usingSearchResults then
		currentPage = 1
		self.fmCurrentPage = 1
	end

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

	-- Calculate page bounds and build group entries (rest unchanged)
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)
	print("RMB_UI: Building page " .. currentPage .. " (" .. startIndex .. "-" .. endIndex .. " of " .. totalGroups .. ")")
	local groupEntryOrder = displayOrder
	for i = startIndex, endIndex do
		local groupData = allDisplayableGroups[i]
		if groupData then
			local groupKey = groupData.key
			local isExpanded = self:IsGroupExpanded(groupKey)
			local expandedDetails = nil
			if isExpanded then
				expandedDetails = self:GetExpandedGroupDetailsArgs(groupKey, groupData.type)
			end

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

	-- Add pagination controls (only if not searching)
	if not usingSearchResults and self.MountUIComponents then
		local paginationComponents = self.MountUIComponents:CreateSmartPaginationControls(currentPage, totalPages,
			groupEntryOrder)
		for k, v in pairs(paginationComponents) do
			pageArgs[k] = v
		end
	end

	print("RMB_UI: Built UI with " .. (endIndex - startIndex + 1) .. " group entries")
	return pageArgs
end

-- ADD this new function to MountListUI.lua:
function addon:BuildFilterPanelArgs()
	local filterArgs = {}
	local order = 1
	-- Mount Source Filters
	filterArgs.source_header = {
		order = order,
		type = "header",
		name = "Mount Source",
	}
	order = order + 1
	if self.FilterSystem then
		for sourceId, sourceName in pairs(self.FilterSystem.MOUNT_SOURCES) do
			filterArgs["source_" .. sourceId] = {
				order = order,
				type = "toggle",
				name = sourceName,
				desc = "Show mounts from " .. sourceName .. " (ID: " .. sourceId .. ")",
				get = function()
					local value = self.FilterSystem:GetFilterSetting("mountSources", sourceId)
					return value
				end,
				set = function(info, value)
					self.FilterSystem:SetFilterSetting("mountSources", sourceId, value)
				end,
				width = 0.8,
			}
			order = order + 1
		end
	end

	-- Mount Type Filters
	filterArgs.type_header = {
		order = order,
		type = "header",
		name = "Mount Type",
	}
	order = order + 1
	if self.FilterSystem then
		for _, typeName in ipairs(self.FilterSystem.MOUNT_TYPES) do
			filterArgs["type_" .. typeName:gsub(" ", "_")] = {
				order = order,
				type = "toggle",
				name = typeName,
				desc = "Show " .. typeName .. " mounts",
				get = function() return self.FilterSystem:GetFilterSetting("mountTypes", typeName) end,
				set = function(info, value) self.FilterSystem:SetFilterSetting("mountTypes", typeName, value) end,
				width = 0.8,
			}
			order = order + 1
		end
	end

	-- Mount Trait Filters
	filterArgs.trait_header = {
		order = order,
		type = "header",
		name = "Mount Traits",
	}
	order = order + 1
	local traitLabels = {
		hasMinorArmor = "Minor Armor",
		hasMajorArmor = "Major Armor",
		hasModelVariant = "Model Variant",
		isUniqueEffect = "Unique Effect",
		noTraits = "No Traits",
	}
	if self.FilterSystem then
		for _, traitName in ipairs(self.FilterSystem.MOUNT_TRAITS) do
			filterArgs["trait_" .. traitName] = {
				order = order,
				type = "toggle",
				name = traitLabels[traitName] or traitName,
				desc = "Show mounts with " .. (traitLabels[traitName] or traitName),
				get = function() return self.FilterSystem:GetFilterSetting("mountTraits", traitName) end,
				set = function(info, value) self.FilterSystem:SetFilterSetting("mountTraits", traitName, value) end,
				width = 0.8,
			}
			order = order + 1
		end
	end

	-- Summon Chance Filters
	filterArgs.chance_header = {
		order = order,
		type = "header",
		name = "Summon Chance",
	}
	order = order + 1
	if self.FilterSystem then
		for _, chanceName in ipairs(self.FilterSystem.SUMMON_CHANCES) do
			filterArgs["chance_" .. chanceName] = {
				order = order,
				type = "toggle",
				name = chanceName,
				desc = "Show mounts with " .. chanceName .. " summon chance",
				get = function() return self.FilterSystem:GetFilterSetting("summonChances", chanceName) end,
				set = function(info, value) self.FilterSystem:SetFilterSetting("summonChances", chanceName, value) end,
				width = 0.8,
			}
			order = order + 1
		end
	end

	-- Reset button (removed - now in main UI)
	-- filterArgs.reset_filters = { ... }
	return filterArgs
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
	return self.fmItemsPerPage or 14
end

function addon:FMG_SetItemsPerPage(items)
	local numItems = tonumber(items)
	-- Increased max limit to support more items per page
	if numItems and numItems >= 5 and numItems <= 100 then
		self.fmItemsPerPage = numItems
		if self.db and self.db.profile then
			self.db.profile.fmItemsPerPage = numItems
		end

		self.fmCurrentPage = 1          -- Reset to first page
		self:PopulateFamilyManagementUI() -- Refresh UI
		print("RMB_NAV: Items per page set to " .. numItems)
	else
		print("RMB_NAV: Invalid items per page value: " .. tostring(items))
	end
end

function addon:FMG_GoToPage(pageNumber)
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	local targetPage = tonumber(pageNumber)
	if targetPage and targetPage >= 1 and targetPage <= totalPages then
		-- Collapse any expanded groups when changing pages
		self:CollapseAllExpanded()
		self.fmCurrentPage = targetPage
		self:PopulateFamilyManagementUI()
		print("RMB_NAV: Jumped to page " .. targetPage)
	else
		print("RMB_NAV: Invalid page number: " .. tostring(pageNumber) .. " (valid range: 1-" .. totalPages .. ")")
	end
end

function addon:FMG_NextPage()
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	if self.fmCurrentPage < totalPages then
		self:CollapseAllExpanded()
		self.fmCurrentPage = self.fmCurrentPage + 1
		self:PopulateFamilyManagementUI()
		print("RMB_NAV: Next page -> " .. self.fmCurrentPage)
	end
end

function addon:FMG_PrevPage()
	if not self.RMB_DataReadyForUI then return end

	if self.fmCurrentPage > 1 then
		self:CollapseAllExpanded()
		self.fmCurrentPage = self.fmCurrentPage - 1
		self:PopulateFamilyManagementUI()
		print("RMB_NAV: Previous page -> " .. self.fmCurrentPage)
	end
end

function addon:FMG_GoToFirstPage()
	if not self.RMB_DataReadyForUI then return end

	if self.fmCurrentPage ~= 1 then
		self:CollapseAllExpanded()
		self:FMG_GoToPage(1)
	end
end

function addon:FMG_GoToLastPage()
	if not self.RMB_DataReadyForUI then return end

	local allGroups = self:GetDisplayableGroups()
	if not allGroups then return end

	local totalPages = math.max(1, math.ceil(#allGroups / self:FMG_GetItemsPerPage()))
	if self.fmCurrentPage ~= totalPages then
		self:CollapseAllExpanded()
		self:FMG_GoToPage(totalPages)
	end
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
