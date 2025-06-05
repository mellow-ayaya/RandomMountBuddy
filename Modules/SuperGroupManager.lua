-- SuperGroupManager.lua - Supergroup Creation, Editing, and Management.
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("SuperGroupManager.lua START.")
-- ============================================================================
-- SUPERGROUP MANAGER CLASS
-- ============================================================================
local SuperGroupManager = {}
addon.SuperGroupManager = SuperGroupManager
-- Initialize the SuperGroup Manager
function SuperGroupManager:Initialize()
	addon:DebugSupergr("Initializing SuperGroup Manager...")
	-- UI state for the manager
	self.uiState = {
		currentPage = 1,
		searchTerm = "",
		itemsPerPage = 14,
		selectedFamilies = {},
	}
	-- ADDED: Refresh flag system for popup callbacks
	self.needsRefresh = false
	self.refreshTimer = nil
	-- Initialize dynamic content references
	self.existingListArgsRef = {}
	-- Start refresh polling
	self:StartRefreshPolling()
	-- Populate initial content (will be empty until data is ready)
	self:PopulateExistingSuperGroupsList()
	addon:DebugSupergr("SuperGroup Manager initialized")
end

function SuperGroupManager:StartRefreshPolling()
	-- Check for refresh needs every 0.5 seconds
	if not self.refreshTimer then
		self.refreshTimer = C_Timer.NewTicker(0.5, function()
			if self.needsRefresh then
				self.needsRefresh = false
				-- Refresh all UIs
				self:PopulateSuperGroupManagementUI()
				-- Also refresh main UI
				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end
		end)
	end
end

function SuperGroupManager:RequestRefresh()
	addon:DebugSupergr("Refresh requested, will process on next poll")
	self.needsRefresh = true
end

-- References for dynamic UI content (same pattern as Mount List)
SuperGroupManager.existingListArgsRef = {}
-- NEW: Pagination helper methods
function SuperGroupManager:GetCurrentPage()
	return self.uiState.currentPage or 1
end

function SuperGroupManager:SetCurrentPage(page)
	self.uiState.currentPage = page or 1
end

function SuperGroupManager:GetItemsPerPage()
	return self.uiState.itemsPerPage or 20
end

function SuperGroupManager:GoToPage(pageNumber)
	local filteredSGs = self:GetFilteredSuperGroups()
	local totalPages = math.max(1, math.ceil(#filteredSGs / self:GetItemsPerPage()))
	local targetPage = tonumber(pageNumber)
	if targetPage and targetPage >= 1 and targetPage <= totalPages then
		self:SetCurrentPage(targetPage)
		self:PopulateSuperGroupManagementUI()
		addon:DebugSupergr("Jumped to page " .. targetPage)
	end
end

function SuperGroupManager:NextPage()
	local filteredSGs = self:GetFilteredSuperGroups()
	local totalPages = math.max(1, math.ceil(#filteredSGs / self:GetItemsPerPage()))
	local currentPage = self:GetCurrentPage()
	if currentPage < totalPages then
		self:SetCurrentPage(currentPage + 1)
		self:PopulateSuperGroupManagementUI()
	end
end

function SuperGroupManager:PrevPage()
	local currentPage = self:GetCurrentPage()
	if currentPage > 1 then
		self:SetCurrentPage(currentPage - 1)
		self:PopulateSuperGroupManagementUI()
	end
end

-- NEW: Search and filtering methods
function SuperGroupManager:GetFilteredSuperGroups()
	local allSGs = self:GetAllSuperGroups()
	local searchTerm = self.uiState.searchTerm or ""
	if searchTerm == "" then
		return allSGs
	end

	local filteredSGs = {}
	local lowerSearchTerm = searchTerm:lower()
	for _, sgInfo in ipairs(allSGs) do
		local displayName = sgInfo.displayName:lower()
		local originalName = sgInfo.name:lower()
		if displayName:find(lowerSearchTerm, 1, true) or originalName:find(lowerSearchTerm, 1, true) then
			table.insert(filteredSGs, sgInfo)
		end
	end

	return filteredSGs
end

-- NEW: Pagination controls creation
function SuperGroupManager:CreateSuperGroupPaginationControls(currentPage, totalPages, order)
	if totalPages <= 1 then
		return {}
	end

	-- Calculate which pages to show
	local pageRange = self:CalculatePageRange(currentPage, totalPages)
	local paginationArgs = {}
	local buttonOrder = 1
	local pageButtonWidth = 0.15
	local maxButtons = 23
	-- Add centering spacer if we have fewer than maxButtons pages
	if totalPages < maxButtons then
		local missingPages = maxButtons - totalPages
		local spacerWidth = (missingPages / 2) * pageButtonWidth
		paginationArgs["centering_spacer"] = {
			order = buttonOrder,
			type = "description",
			name = "",
			width = spacerWidth,
		}
		buttonOrder = buttonOrder + 1
	end

	-- Add page number buttons
	for _, pageNum in ipairs(pageRange) do
		if pageNum == "..." then
			-- Add ellipsis
			paginationArgs["ellipsis_" .. buttonOrder] = {
				order = buttonOrder,
				type = "description",
				name = "...",
				width = 0.1,
			}
		else
			-- Add page number button
			local isCurrentPage = (pageNum == currentPage)
			paginationArgs["page_" .. pageNum] = {
				order = buttonOrder,
				type = "execute",
				name = isCurrentPage and ("|cffffd700" .. pageNum .. "|r") or tostring(pageNum),
				desc = isCurrentPage and "Current page" or "",
				func = function()
					self:GoToPage(pageNum)
				end,
				width = pageButtonWidth,
				image = "Interface\\AddOns\\RandomMountBuddy\\Media\\Empty",
				imageWidth = 1,
				imageHeight = 1,
			}
		end

		buttonOrder = buttonOrder + 1
	end

	return {
		supergroup_pagination = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			args = paginationArgs,
		},
	}
end

-- NEW: Page range calculation function
function SuperGroupManager:CalculatePageRange(currentPage, totalPages)
	local maxButtons = 23 -- Maximum page buttons to show
	local range = {}
	if totalPages <= maxButtons then
		-- Show all pages if total is small
		for i = 1, totalPages do
			table.insert(range, i)
		end
	else
		-- Smart range calculation for larger page counts
		local halfRange = math.floor((maxButtons - 3) / 2) -- Reserve space for 1, ..., last
		-- Always show page 1
		table.insert(range, 1)
		-- Calculate start and end of middle range
		local rangeStart = math.max(2, currentPage - halfRange)
		local rangeEnd = math.min(totalPages - 1, currentPage + halfRange)
		-- Adjust range if it's too close to beginning or end
		if rangeStart <= 3 then
			rangeEnd = math.min(totalPages - 1, maxButtons - 1)
			rangeStart = 2
		elseif rangeEnd >= totalPages - 2 then
			rangeStart = math.max(2, totalPages - maxButtons + 2)
			rangeEnd = totalPages - 1
		end

		-- Add ellipsis before middle range if needed
		if rangeStart > 2 then
			table.insert(range, "...")
		end

		-- Add middle range
		for i = rangeStart, rangeEnd do
			table.insert(range, i)
		end

		-- Add ellipsis after middle range if needed
		if rangeEnd < totalPages - 1 then
			table.insert(range, "...")
		end

		-- Always show last page (if different from first)
		if totalPages > 1 then
			table.insert(range, totalPages)
		end
	end

	return range
end

-- UI population functions (similar to PopulateFamilyManagementUI)
function SuperGroupManager:PopulateExistingSuperGroupsList()
	addon:DebugSupergr("Populating existing supergroups list")
	-- Clear existing content
	wipe(self.existingListArgsRef)
	if not addon.SuperGroupManager then
		self.existingListArgsRef.error = {
			order = 1,
			type = "description",
			name = "SuperGroup Manager not initialized",
		}
		return
	end

	local allSGs = self:GetAllSuperGroups()
	local order = 1
	for _, sgInfo in ipairs(allSGs) do
		local keyBase = "sg_" .. sgInfo.name:gsub("[^%w]", "_")
		-- Supergroup name display
		self.existingListArgsRef[keyBase .. "_name"] = {
			order = order,
			type = "description",
			name = function()
				local indicator = sgInfo.isCustom and "|cff00ff00[Custom]|r" or
						sgInfo.isDeleted and "|cffff0000[Deleted]|r" or
						sgInfo.isRenamed and "|cffffff00[Renamed]|r" or
						"|cffa335ee[G]|r"
				return indicator .. " " .. sgInfo.displayName
			end,
			width = 1.2,
		}
		-- Rename button
		if not sgInfo.isDeleted then
			self.existingListArgsRef[keyBase .. "_rename"] = {
				order = order + 0.1,
				type = "input",
				name = "",
				desc = "New display name",
				get = function() return "" end,
				set = function(info, value)
					if value and value:trim() ~= "" then
						local success, message = addon.SuperGroupManager:RenameSuperGroup(sgInfo.name, value)
						print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
						-- Refresh the list
						addon.SuperGroupManager:PopulateExistingSuperGroupsList()
						-- Notify AceConfig of changes
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
						end
					end
				end,
				width = 0.8,
			}
			self.existingListArgsRef[keyBase .. "_rename_btn"] = {
				order = order + 0.2,
				type = "execute",
				name = "Rename",
				desc = "Rename this supergroup",
				func = function()
					-- The actual rename happens in the input's set function
				end,
				width = 0.4,
			}
		end

		-- Delete/Restore button
		if sgInfo.isDeleted then
			self.existingListArgsRef[keyBase .. "_restore"] = {
				order = order + 0.3,
				type = "execute",
				name = "Restore",
				desc = "Restore this deleted supergroup",
				func = function()
					local success, message = addon.SuperGroupManager:RestoreSuperGroup(sgInfo.name)
					print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
					-- Refresh the list
					addon.SuperGroupManager:PopulateExistingSuperGroupsList()
					-- Notify AceConfig of changes
					if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
						LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
					end
				end,
				width = 0.4,
			}
		else
			self.existingListArgsRef[keyBase .. "_delete"] = {
				order = order + 0.3,
				type = "execute",
				name = "Delete",
				desc = "Delete this supergroup (families will become standalone)",
				func = function()
					StaticPopup_Show("RMB_DELETE_SUPERGROUP_CONFIRM", sgInfo.displayName, nil, sgInfo.name)
				end,
				width = 0.4,
			}
		end

		-- Line break
		self.existingListArgsRef[keyBase .. "_break"] = {
			order = order + 0.9,
			type = "description",
			name = "",
			width = "full",
		}
		order = order + 1
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
	end
end

-- Populate supergroup management UI (same pattern as PopulateFamilyManagementUI)
function SuperGroupManager:PopulateSuperGroupManagementUI()
	if not addon.sgMgmtArgsRef then
		addon:DebugSupergr("addon.sgMgmtArgsRef is nil! Options.lua problem.")
		return
	end

	-- Build new UI arguments
	local newArgs = self:BuildSuperGroupManagementArgs()
	-- Update the options table (same pattern as Mount List)
	wipe(addon.sgMgmtArgsRef)
	for k, v in pairs(newArgs) do
		addon.sgMgmtArgsRef[k] = v
	end

	-- Notify AceConfig with specific registration name
	local registryLib = LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true)
	if registryLib then
		C_Timer.After(0.05, function()
			registryLib:NotifyChange("RandomMountBuddy_SuperGroupMgmt")
			registryLib:NotifyChange("RandomMountBuddy")
		end)
	else
		addon:DebugSupergr("AceConfigRegistry not available")
	end
end

-- Build supergroup management page content
function SuperGroupManager:BuildSuperGroupManagementArgs()
	addon:DebugSupergr("BuildSuperGroupManagementArgs called")
	local args = {}
	local order = 1
	args.desc_mgmt = {
		order = order,
		type = "description",
		name = "",
		fontSize = "medium",
	}
	order = order + 1
	-- Search Section
	args.search_label = {
		order = order,
		type = "description",
		name = "|cffffd700  Search:|r",
		width = 0.3,
	}
	order = order + 1
	args.search_input = {
		order = order,
		type = "input",
		name = "",
		desc = "Search supergroup names (press Enter to search)",
		get = function() return self.uiState.searchTerm or "" end,
		set = function(info, value)
			self.uiState.searchTerm = value or ""
			self.uiState.currentPage = 1 -- Reset to first page
			self:PopulateSuperGroupManagementUI()
		end,
		width = 1,
	}
	order = order + 1
	-- Show clear button only when there's a search term
	local hasSearchTerm = (self.uiState.searchTerm or "") ~= ""
	if hasSearchTerm then
		args.search_reset = {
			order = order,
			type = "execute",
			name = "Clear",
			desc = "Clear search term",
			func = function()
				self.uiState.searchTerm = ""
				self.uiState.currentPage = 1
				self:PopulateSuperGroupManagementUI()
			end,
			width = 0.4,
		}
	else
		args.spacer_no_search_reset = {
			order = order,
			type = "description",
			name = " ",
			width = 0.4,
		}
	end

	order = order + 1
	args.spacer_search_create = {
		order = order,
		type = "description",
		name = " ",
		width = 0.1,
	}
	order = order + 1
	-- Creation Section
	args.create_label = {
		order = order,
		type = "description",
		name = "|cffffd700Create New SG:|r",
		width = 0.5,
	}
	order = order + 1
	args.create_name = {
		order = order,
		type = "input",
		name = "",
		desc = "Name for your custom supergroup (e.g., 'My Favorite Dragons')",
		get = function() return self.pendingCreateName or "" end,
		set = function(info, value) self.pendingCreateName = value end,
		width = 1,
	}
	order = order + 1
	args.create_button = {
		order = order,
		type = "execute",
		name = "+",
		desc = "Create the new supergroup",
		func = function()
			local name = self.pendingCreateName or ""
			local success, message = self:CreateSuperGroup(name)
			if success then
				self.pendingCreateName = ""
				addon:AlwaysPrint("" .. message)
				self:PopulateSuperGroupManagementUI()
			else
				addon:AlwaysPrint("" .. message)
			end
		end,
		disabled = function()
			local name = self.pendingCreateName or ""
			if name:trim() == "" then return true end

			local hasConflict, _ = self:DoesNameConflict(name)
			return hasConflict or self:SanitizeSuperGroupName(name) == ""
		end,
		width = 0.35,
	}
	order = order + 1
	args.spacer_create_preview = {
		order = order,
		type = "description",
		name = "",
		width = 2.3,
	}
	order = order + 1
	-- Show sanitized preview
	args.create_preview = {
		order = order,
		type = "description",
		name = function()
			local inputName = self.pendingCreateName or ""
			if inputName:trim() == "" then
				return ""
			end

			local sanitized = self:SanitizeSuperGroupName(inputName)
			if sanitized == "" then
				return "|cffff0000Invalid characters. Use letters, numbers, spaces, hyphens, or underscores.|r"
			end

			-- Check for conflicts
			local hasConflict, conflictMessage = self:DoesNameConflict(inputName)
			if hasConflict then
				return "|cffff0000" .. conflictMessage .. "|r"
			end

			return "|cff00ff00 Available|r" .. (sanitized ~= inputName:trim() and (" (internal: " .. sanitized .. ")") or "")
		end,
		width = 1.2,
	}
	order = order + 1
	-- Existing Supergroups Section with Pagination
	local allSGs = self:GetFilteredSuperGroups()
	local totalSGs = #allSGs
	local searchTerm = self.uiState.searchTerm or ""
	if totalSGs == 0 then
		local message = "No supergroups found"
		if searchTerm ~= "" then
			message = "No supergroups found matching search: " .. searchTerm
		end

		args.no_supergroups_msg = {
			order = order,
			type = "description",
			name = message,
		}
		order = order + 1
	else
		-- Add column headers for better organization
		args.column_headers = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			width = "full",
			args = {
				nameHeader = {
					order = 1,
					type = "description",
					name = "       |cffffd700Supergroup Name|r",
					width = 1.0,
				},
				renameHeader = {
					order = 2,
					type = "description",
					name = "          |cffffd700Rename|r",
					width = 1.7,
				},
				actionsHeader = {
					order = 3,
					type = "description",
					name = "|cffffd700Actions|r",
					width = 0.5,
				},
			},
		}
		order = order + 1
		-- Apply pagination
		local itemsPerPage = self:GetItemsPerPage()
		local totalPages = math.max(1, math.ceil(totalSGs / itemsPerPage))
		local currentPage = math.max(1, math.min(self:GetCurrentPage(), totalPages))
		local startIndex = (currentPage - 1) * itemsPerPage + 1
		local endIndex = math.min(startIndex + itemsPerPage - 1, totalSGs)
		-- Add supergroup entries for current page
		for i = startIndex, endIndex do
			local sgInfo = allSGs[i]
			if sgInfo then
				local keyBase = "sg_" .. sgInfo.name:gsub("[^%w]", "_")
				-- Supergroup name display with original name info
				args[keyBase .. "_name"] = {
					order = order,
					type = "description",
					name = function()
						local indicator = sgInfo.isCustom and "|cff00ff00[Custom]|r" or
								sgInfo.isDeleted and "|cffff0000[Deleted]|r" or
								"|cffa335ee[G]|r"
						local displayText = indicator .. " " .. sgInfo.displayName
						-- Show original name if it's been renamed
						if sgInfo.isRenamed and not sgInfo.isCustom then
							local originalName = self:GetOriginalSuperGroupName(sgInfo.name)
							if originalName ~= sgInfo.displayName then
								displayText = displayText .. " |cff888888(was: " .. originalName .. ")|r"
							end
						end

						return displayText
					end,
					width = 1,
				}
				-- Rename input with validation
				if not sgInfo.isDeleted then
					args[keyBase .. "_rename"] = {
						order = order + 0.1,
						type = "input",
						name = "",
						desc = "New display name",
						get = function() return "" end,
						set = function(info, value)
							if value and value:trim() ~= "" then
								local success, message = self:RenameSuperGroup(sgInfo.name, value)
								print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
								if success then
									self:PopulateSuperGroupManagementUI()
								end
							end
						end,
						width = 0.6,
					}
					-- Show validation for rename input
					args[keyBase .. "_rename_validation"] = {
						order = order + 0.12,
						type = "description",
						name = function()
							-- This would need to track per-supergroup input state for real-time validation
							-- For now, validation happens on submit
							return ""
						end,
						width = 0.1,
					}
					-- Restore original name button (only for renamed original supergroups)
					if sgInfo.isRenamed and not sgInfo.isCustom then
						args[keyBase .. "_restore_name"] = {
							order = order + 0.15,
							type = "execute",
							name = "Restore Name",
							desc = "Restore original supergroup name",
							func = function()
								local success, message = self:RestoreOriginalName(sgInfo.name)
								print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
								if success then
									self:PopulateSuperGroupManagementUI()
								end
							end,
							width = 0.8,
						}
					else
						-- Spacer when restore name button is absent
						args[keyBase .. "_restore_name_spacer"] = {
							order = order + 0.15,
							type = "description",
							name = "",
							width = 0.8,
						}
					end

					args[keyBase .. "_spacer_restore_delete"] = {
						order = order + 0.16,
						type = "description",
						name = "",
						width = 0.1,
					}
					-- Check if this supergroup is in confirmation mode
					local inConfirmMode = self.deleteConfirmation and self.deleteConfirmation[sgInfo.name]
					if not inConfirmMode then
						-- Normal state - show delete button
						args[keyBase .. "_delete"] = {
							order = order + 0.3,
							type = "execute",
							name = "Delete",
							desc = "Delete this supergroup (families will become standalone)",
							func = function()
								-- Enter confirmation mode
								if not self.deleteConfirmation then
									self.deleteConfirmation = {}
								end

								self.deleteConfirmation[sgInfo.name] = true
								addon:AlwaysPrint("Confirm deletion of '" .. sgInfo.displayName .. "'")
								-- Refresh UI to show confirmation buttons
								self:PopulateSuperGroupManagementUI()
								-- Auto-cancel after 10 seconds
								C_Timer.After(10, function()
									if self.deleteConfirmation and self.deleteConfirmation[sgInfo.name] then
										self.deleteConfirmation[sgInfo.name] = nil
										self:PopulateSuperGroupManagementUI()
										addon:AlwaysPrint("Delete confirmation timed out for '" .. sgInfo.displayName .. "'")
									end
								end)
							end,
							width = 0.45,
						}
					else
						-- Confirmation mode - show delete button (disabled) and confirm/cancel buttons
						args[keyBase .. "_delete_disabled"] = {
							order = order + 0.3,
							type = "execute",
							name = "|cff666666Delete|r",
							desc = "Confirming deletion...",
							func = function() end, -- Do nothing
							disabled = true,
							width = 0.45,
						}
						-- Confirm button
						args[keyBase .. "_confirm"] = {
							order = order + 0.32,
							type = "execute",
							name = "|TInterface\\BUTTONS\\UI-CheckBox-Check:18:18:0:-2|t",
							desc = "Confirm deletion of '" .. sgInfo.displayName .. "'",
							func = function()
								-- Actually delete the supergroup
								local success, message = self:DeleteSuperGroup(sgInfo.name)
								if success then
									addon:AlwaysPrint("" .. message)
									self.deleteConfirmation[sgInfo.name] = nil
									-- FIXED: Don't call multiple immediate refreshes - DeleteSuperGroup already requests refresh
									-- The polling system will handle the refresh automatically
								else
									addon:AlwaysPrint("" .. message)
									-- Clear confirmation mode on error
									self.deleteConfirmation[sgInfo.name] = nil
									-- Only refresh this UI on error since DeleteSuperGroup didn't complete
									self:PopulateSuperGroupManagementUI()
								end
							end,
							width = 0.3,
						}
						-- Cancel button
						args[keyBase .. "_cancel"] = {
							order = order + 0.33,
							type = "execute",
							name = "|TInterface\\BUTTONS\\UI-StopButton:18:18:0:-2|t",
							desc = "Cancel deletion",
							func = function()
								-- Exit confirmation mode
								self.deleteConfirmation[sgInfo.name] = nil
								self:PopulateSuperGroupManagementUI()
								addon:AlwaysPrint("Delete cancelled for '" .. sgInfo.displayName .. "'")
							end,
							width = 0.3,
						}
					end
				else
					-- Restore deleted supergroup button
					args[keyBase .. "_restore"] = {
						order = order + 0.3,
						type = "execute",
						name = "Restore",
						desc = "Restore this deleted supergroup to original state",
						func = function()
							local success, message = self:RestoreSuperGroup(sgInfo.name)
							print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
							if success then
								self:PopulateSuperGroupManagementUI()
							end
						end,
						width = 0.6,
					}
				end

				-- Line break
				args[keyBase .. "_break"] = {
					order = order + 0.9,
					type = "description",
					name = "",
					width = "full",
				}
				order = order + 1
			end
		end

		-- Add pagination controls
		if totalPages > 1 then
			local paginationComponents = self:CreateSuperGroupPaginationControls(
				currentPage, totalPages, order)
			for k, v in pairs(paginationComponents) do
				args[k] = v
			end

			order = order + 1
		end
	end

	addon:DebugSupergr("Built management UI with " .. totalSGs .. " supergroups")
	return args
end

-- ============================================================================
-- SUPERGROUP CRUD OPERATIONS
-- ============================================================================
-- Get all supergroups (original + custom, excluding deleted)
function SuperGroupManager:GetAllSuperGroups()
	local allSuperGroups = {}
	-- Ensure data is ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSupergr("Data not ready for GetAllSuperGroups")
		return allSuperGroups
	end

	addon:DebugSupergr("GetAllSuperGroups - Data is ready, processing...")
	-- Add original supergroups (if not deleted)
	if addon.processedData.superGroupMap then
		addon:DebugSupergr("Found " .. addon:CountTableEntries(addon.processedData.superGroupMap) .. " original supergroups")
		for sgName, _ in pairs(addon.processedData.superGroupMap) do
			if not addon:IsSuperGroupDeleted(sgName) then
				table.insert(allSuperGroups, {
					name = sgName,
					displayName = addon:GetSuperGroupDisplayName(sgName),
					isCustom = false,
					isRenamed = addon:IsSuperGroupRenamed(sgName),
					isDeleted = false,
				})
				addon:DebugSupergr("Added original supergroup: " .. sgName)
			else
				addon:DebugSupergr("Skipped deleted supergroup: " .. sgName)
			end
		end
	else
		addon:DebugSupergr("No original supergroups found in processedData")
	end

	-- Add custom supergroups
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		addon:DebugSupergr("Found " ..
			addon:CountTableEntries(addon.db.profile.superGroupDefinitions) .. " supergroup definitions")
		for sgName, definition in pairs(addon.db.profile.superGroupDefinitions) do
			if definition.isCustom then
				table.insert(allSuperGroups, {
					name = sgName,
					displayName = definition.displayName or sgName,
					isCustom = true,
					isRenamed = false,
					isDeleted = false,
				})
				addon:DebugSupergr("Added custom supergroup: " .. sgName)
			end
		end
	else
		addon:DebugSupergr("No custom supergroup definitions found")
	end

	-- Add deleted supergroups (for restore functionality)
	if addon.db and addon.db.profile and addon.db.profile.deletedSuperGroups then
		for sgName, isDeleted in pairs(addon.db.profile.deletedSuperGroups) do
			if isDeleted then
				table.insert(allSuperGroups, {
					name = sgName,
					displayName = sgName,
					isCustom = false,
					isRenamed = false,
					isDeleted = true,
				})
				addon:DebugSupergr("Added deleted supergroup for restore: " .. sgName)
			end
		end
	end

	-- Sort alphabetically
	table.sort(allSuperGroups, function(a, b)
		-- Custom groups always come first
		if a.isCustom and not b.isCustom then
			return true
		elseif not a.isCustom and b.isCustom then
			return false
		else
			-- Within same category, sort alphabetically by display name
			return a.displayName < b.displayName
		end
	end)
	addon:DebugSupergr("GetAllSuperGroups returning " .. #allSuperGroups .. " supergroups")
	return allSuperGroups
end

-- Sanitize user input for internal supergroup key
function SuperGroupManager:SanitizeSuperGroupName(userInput)
	if not userInput then return "" end

	local sanitized = userInput:trim()
	-- Replace spaces with underscores, remove special characters except hyphens and underscores
	sanitized = sanitized:gsub("[^%w%s%-_]", "") -- Keep alphanumeric, spaces, hyphens, underscores
	sanitized = sanitized:gsub("%s+", "_")      -- Replace spaces with underscores
	sanitized = sanitized:gsub("_+", "_")       -- Collapse multiple underscores
	sanitized = sanitized:gsub("^_+", "")       -- Remove leading underscores
	sanitized = sanitized:gsub("_+$", "")       -- Remove trailing underscores
	return sanitized
end

-- Check if a name conflicts with existing supergroups (internal names OR display names)
function SuperGroupManager:DoesNameConflict(nameToCheck, excludeSuperGroup)
	if not nameToCheck or nameToCheck:trim() == "" then
		return true, "Name cannot be empty"
	end

	local trimmedName = nameToCheck:trim()
	local sanitizedName = self:SanitizeSuperGroupName(trimmedName)
	-- Check against original supergroup internal names
	if addon.processedData and addon.processedData.superGroupMap then
		for sgName, _ in pairs(addon.processedData.superGroupMap) do
			if sgName ~= excludeSuperGroup then
				-- Check both exact match and sanitized match
				if sgName:lower() == trimmedName:lower() or
						sgName:lower() == sanitizedName:lower() then
					return true, "Name conflicts with existing supergroup: " .. sgName
				end
			end
		end
	end

	-- Check against original supergroup display names (in case they were renamed)
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		for sgName, definition in pairs(addon.db.profile.superGroupDefinitions) do
			if sgName ~= excludeSuperGroup and definition.displayName then
				if definition.displayName:lower() == trimmedName:lower() then
					return true, "Name conflicts with existing supergroup display name: " .. definition.displayName
				end
			end
		end
	end

	-- Check against custom supergroup internal names
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		for sgName, definition in pairs(addon.db.profile.superGroupDefinitions) do
			if sgName ~= excludeSuperGroup and definition.isCustom then
				-- Check internal name
				if sgName:lower() == sanitizedName:lower() then
					return true, "Name conflicts with existing custom supergroup: " .. (definition.displayName or sgName)
				end
			end
		end
	end

	return false, nil -- No conflict
end

-- Updated CreateSuperGroup with simplified input
function SuperGroupManager:CreateSuperGroup(userInputName)
	if not userInputName or userInputName:trim() == "" then
		return false, "Supergroup name cannot be empty"
	end

	local displayName = userInputName:trim()
	local internalName = self:SanitizeSuperGroupName(displayName)
	-- Validate the sanitized name
	if internalName == "" then
		return false, "Name contains only invalid characters. Use letters, numbers, spaces, hyphens, or underscores."
	end

	-- Check for conflicts
	local hasConflict, conflictMessage = self:DoesNameConflict(displayName)
	if hasConflict then
		return false, conflictMessage
	end

	-- Initialize database structures if needed
	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	-- Create the supergroup
	addon.db.profile.superGroupDefinitions[internalName] = {
		displayName = displayName, -- Store exactly what user typed
		isCustom = true,
		isRenamed = false,       -- Not renamed since it starts with user's preferred name
	}
	addon:DebugSupergr("Created custom supergroup: '" .. displayName .. "' (internal: " .. internalName .. ")")
	-- Trigger rebuild
	addon:RebuildMountGrouping()
	return true, "Supergroup '" .. displayName .. "' created successfully"
end

-- Rename supergroup
function SuperGroupManager:RenameSuperGroup(sgName, newDisplayName)
	if not sgName or not newDisplayName or newDisplayName:trim() == "" then
		return false, "Display name cannot be empty"
	end

	local trimmedNewName = newDisplayName:trim()
	-- Check for conflicts (excluding the current supergroup being renamed)
	local hasConflict, conflictMessage = self:DoesNameConflict(trimmedNewName, sgName)
	if hasConflict then
		return false, conflictMessage
	end

	-- Get the original name for comparison
	local originalName = self:GetOriginalSuperGroupName(sgName)
	-- Initialize database structures if needed
	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	-- Check if we're renaming back to the original name
	if trimmedNewName == originalName then
		-- Renaming back to original - remove any custom definition for original supergroups
		if addon.db.profile.superGroupDefinitions[sgName] then
			if addon.db.profile.superGroupDefinitions[sgName].isCustom then
				-- For custom supergroups, update the display name
				addon.db.profile.superGroupDefinitions[sgName].displayName = trimmedNewName
				addon.db.profile.superGroupDefinitions[sgName].isRenamed = false
			else
				-- For original supergroups, remove the definition entirely to show original name
				addon.db.profile.superGroupDefinitions[sgName] = nil
			end
		end

		addon:DebugSupergr("Restored original name for supergroup: " .. sgName)
	else
		-- Renaming to a different name - update or create definition
		if not addon.db.profile.superGroupDefinitions[sgName] then
			addon.db.profile.superGroupDefinitions[sgName] = {}
		end

		addon.db.profile.superGroupDefinitions[sgName].displayName = trimmedNewName
		addon.db.profile.superGroupDefinitions[sgName].isRenamed = true
		addon:DebugSupergr("Renamed supergroup: " .. sgName .. " to '" .. trimmedNewName .. "'")
	end

	-- Trigger UI refresh
	if addon.MountDataManager and addon.MountDataManager.InvalidateCache then
		addon.MountDataManager:InvalidateCache("supergroup_renamed")
	end

	return true, "Supergroup renamed successfully"
end

-- Add new helper function to get original supergroup name
function SuperGroupManager:GetOriginalSuperGroupName(sgName)
	-- For original supergroups, the original name is the sgName itself
	if addon.processedData and addon.processedData.superGroupMap and
			addon.processedData.superGroupMap[sgName] then
		return sgName
	end

	-- For custom supergroups, there is no "original" name, return the current name
	return sgName
end

-- Add function to restore original name
function SuperGroupManager:RestoreOriginalName(sgName)
	if not sgName then
		return false, "Invalid supergroup name"
	end

	-- Get the original name
	local originalName = self:GetOriginalSuperGroupName(sgName)
	-- Check if this is actually a renamed original supergroup
	if not (addon.processedData and addon.processedData.superGroupMap and
				addon.processedData.superGroupMap[sgName]) then
		return false, "Cannot restore name - this is not an original supergroup"
	end

	-- Remove any custom definition (this restores the original name)
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions[sgName] = nil
	end

	addon:DebugSupergr("Restored original name for: " .. sgName)
	-- Trigger UI refresh
	if addon.MountDataManager and addon.MountDataManager.InvalidateCache then
		addon.MountDataManager:InvalidateCache("supergroup_name_restored")
	end

	return true, "Original name restored"
end

-- Delete supergroup
function SuperGroupManager:DeleteSuperGroup(sgName)
	if not sgName then
		return false, "Invalid supergroup name"
	end

	-- Initialize database structures if needed
	if not addon.db.profile.deletedSuperGroups then
		addon.db.profile.deletedSuperGroups = {}
	end

	-- Check if it's a custom supergroup
	local isCustom = addon:IsSuperGroupCustom(sgName)
	if isCustom then
		-- For custom supergroups, remove completely
		if addon.db.profile.superGroupDefinitions then
			addon.db.profile.superGroupDefinitions[sgName] = nil
		end

		addon:DebugSupergr("Deleted custom supergroup: " .. sgName)
	else
		-- For original supergroups, mark as deleted
		addon.db.profile.deletedSuperGroups[sgName] = true
		addon:DebugSupergr("Marked original supergroup as deleted: " .. sgName)
	end

	-- Remove any family assignments to this supergroup
	if addon.db.profile.superGroupOverrides then
		local clearedFamilies = {}
		for familyName, assignedSG in pairs(addon.db.profile.superGroupOverrides) do
			if assignedSG == sgName then
				addon.db.profile.superGroupOverrides[familyName] = nil
				table.insert(clearedFamilies, familyName)
			end
		end

		if #clearedFamilies > 0 then
			addon:DebugSupergr("Cleared assignments for " .. #clearedFamilies .. " families")
		end
	end

	-- Trigger rebuild
	addon:RebuildMountGrouping()
	-- FIXED: Just request refresh, don't do it directly
	self:RequestRefresh()
	return true, "Supergroup deleted successfully"
end

-- Restore deleted supergroup
function SuperGroupManager:RestoreSuperGroup(sgName)
	if not sgName then
		return false, "Invalid supergroup name"
	end

	if not addon.db.profile.deletedSuperGroups then
		return false, "Supergroup is not deleted"
	end

	if not addon.db.profile.deletedSuperGroups[sgName] then
		return false, "Supergroup is not deleted"
	end

	-- Remove from deleted list
	addon.db.profile.deletedSuperGroups[sgName] = nil
	-- Clean up any rename flags - restoration should return to original state
	if addon.db.profile.superGroupDefinitions and
			addon.db.profile.superGroupDefinitions[sgName] and
			not addon.db.profile.superGroupDefinitions[sgName].isCustom then
		-- For original supergroups, remove the definition entirely to restore original name
		addon.db.profile.superGroupDefinitions[sgName] = nil
		addon:DebugSupergr("Cleaned up rename data during restoration of: " .. sgName)
	end

	addon:DebugSupergr("Restored supergroup: " .. sgName)
	-- Trigger rebuild
	addon:RebuildMountGrouping()
	return true, "Supergroup restored to original state"
end

-- Helper function to check if supergroup exists
function SuperGroupManager:SuperGroupExists(sgName)
	-- Check original supergroups (not deleted)
	if addon.processedData and addon.processedData.superGroupMap and
			addon.processedData.superGroupMap[sgName] and
			not addon:IsSuperGroupDeleted(sgName) then
		return true
	end

	-- Check custom supergroups
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions and
			addon.db.profile.superGroupDefinitions[sgName] and
			addon.db.profile.superGroupDefinitions[sgName].isCustom then
		return true
	end

	return false
end

function SuperGroupManager:ValidateNameInput(inputName, excludeSuperGroup)
	if not inputName or inputName:trim() == "" then
		return false, "Name cannot be empty", ""
	end

	local sanitized = self:SanitizeSuperGroupName(inputName)
	if sanitized == "" then
		return false, "Invalid characters. Use letters, numbers, spaces, hyphens, or underscores.", ""
	end

	local hasConflict, conflictMessage = self:DoesNameConflict(inputName, excludeSuperGroup)
	if hasConflict then
		return false, conflictMessage, sanitized
	end

	return true, "Available", sanitized
end

-- ============================================================================
-- UI REFRESH COORDINATION
-- ============================================================================
-- Enhanced RefreshAllUIs method to handle refreshes across modules
function SuperGroupManager:RefreshAllUIs()
	addon:DebugSupergr("SuperGroupManager: Refreshing all UIs")
	-- Refresh SuperGroup Management UI
	self:PopulateSuperGroupManagementUI()
	-- Refresh Family Assignment UI
	if addon.FamilyAssignment and addon.FamilyAssignment.PopulateFamilyAssignmentUI then
		addon.FamilyAssignment:PopulateFamilyAssignmentUI()
	end

	-- Refresh main Mount List UI
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
	end

	-- Refresh Mount Separation UI if it exists
	if addon.MountSeparationManager and addon.MountSeparationManager.PopulateSeparationManagementUI then
		addon.MountSeparationManager:PopulateSeparationManagementUI()
	end

	-- Refresh mount pools to ensure changes take effect in summoning
	if addon.MountSummon and addon.MountSummon.RefreshMountPools then
		addon.MountSummon:RefreshMountPools()
	end

	addon:DebugSupergr("SuperGroupManager: All UI refresh completed")
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Initialize SuperGroup Manager when addon loads
function addon:InitializeSuperGroupManager()
	if not self.SuperGroupManager then
		addon:DebugSupergr("ERROR - SuperGroupManager not found!")
		return
	end

	self.SuperGroupManager:Initialize()
	addon:DebugSupergr("SuperGroupManager integration complete")
end

addon:DebugCore("SuperGroupManager.lua END.")
