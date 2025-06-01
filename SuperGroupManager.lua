-- SuperGroupManager.lua - Supergroup Customization Interface
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
	addon:DebugSupergr(" Initializing SuperGroup Manager...")
	-- UI state for the manager
	self.uiState = {
		currentPage = 1,
		searchTerm = "",
		selectedFamilies = {},
		pendingSummon = { source = nil, target = nil },
	}
	-- Initialize validation system
	self.lastValidationReport = nil
	-- ADDED: Refresh flag system for popup callbacks
	self.needsRefresh = false
	self.refreshTimer = nil
	-- Initialize dynamic content references
	self.existingListArgsRef = {}
	self.familyListArgsRef = {}
	addon:DebugSupergr(" Validation system initialized")
	-- Start refresh polling
	self:StartRefreshPolling()
	-- Populate initial content (will be empty until data is ready)
	self:PopulateExistingSuperGroupsList()
	self:PopulateFamilyAssignmentList()
	addon:DebugSupergr(" SuperGroup Manager initialized")
end

-- Add this new function to SuperGroupManager.lua:
function SuperGroupManager:StartRefreshPolling()
	-- Check for refresh needs every 0.5 seconds
	if not self.refreshTimer then
		self.refreshTimer = C_Timer.NewTicker(0.5, function()
			if self.needsRefresh then
				self.needsRefresh = false
				addon:DebugSupergr(" Polling detected refresh needed")
				-- Refresh all UIs
				self:PopulateSuperGroupManagementUI()
				self:PopulateFamilyAssignmentUI()
				-- Also refresh main UI
				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end

				addon:DebugSupergr(" Refresh completed via polling")
			end
		end)
	end
end

-- Add this new function to SuperGroupManager.lua:
function SuperGroupManager:RequestRefresh()
	addon:DebugSupergr(" Refresh requested, will process on next poll")
	self.needsRefresh = true
end

-- References for dynamic UI content (same pattern as Family & Groups)
SuperGroupManager.existingListArgsRef = {}
SuperGroupManager.familyListArgsRef = {}
-- UI population functions (similar to PopulateFamilyManagementUI)
function SuperGroupManager:PopulateExistingSuperGroupsList()
	addon:DebugSupergr(" Populating existing supergroups list")
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

function SuperGroupManager:PopulateFamilyAssignmentList()
	addon:DebugSupergr(" Populating family assignment list")
	-- Clear existing content
	wipe(self.familyListArgsRef)
	if not addon.SuperGroupManager then
		self.familyListArgsRef.error = {
			order = 1,
			type = "description",
			name = "SuperGroup Manager not initialized",
		}
		return
	end

	local allFamilies = self:GetAllFamilyAssignments()
	local searchTerm = self.uiState.searchTerm or ""
	local filteredFamilies = {}
	-- Apply search filter
	for _, familyInfo in ipairs(allFamilies) do
		if searchTerm == "" or familyInfo.familyName:lower():find(searchTerm:lower(), 1, true) then
			table.insert(filteredFamilies, familyInfo)
		end
	end

	-- Pagination
	local itemsPerPage = 20
	local totalItems = #filteredFamilies
	local totalPages = math.max(1, math.ceil(totalItems / itemsPerPage))
	local currentPage = self.uiState.currentPage or 1
	currentPage = math.max(1, math.min(currentPage, totalPages))
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalItems)
	local order = 1
	-- Add pagination info
	if totalPages > 1 then
		self.familyListArgsRef.pagination_info = {
			order = order,
			type = "description",
			name = string.format("Page %d of %d (%d families)", currentPage, totalPages, totalItems),
			width = "full",
		}
		order = order + 1
	end

	-- Add family entries for current page
	for i = startIndex, endIndex do
		local familyInfo = filteredFamilies[i]
		if familyInfo then
			local keyBase = "family_" .. familyInfo.familyName:gsub("[^%w]", "_")
			-- Family name and info
			self.familyListArgsRef[keyBase .. "_name"] = {
				order = order,
				type = "description",
				name = function()
					local indicator = (familyInfo.totalCount == 1) and "|cff1eff00[M]|r" or "|cff0070dd[F]|r"
					local countText = "(" .. familyInfo.collectedCount
					if familyInfo.uncollectedCount > 0 then
						countText = countText .. " + |cff9d9d9d" .. familyInfo.uncollectedCount .. "|r"
					end

					countText = countText .. ")"
					local overrideIndicator = familyInfo.isOverridden and " |cffffd700*|r" or ""
					return indicator .. " " .. familyInfo.familyName .. " " .. countText .. overrideIndicator
				end,
				width = 1.5,
			}
			-- Current supergroup assignment dropdown
			self.familyListArgsRef[keyBase .. "_assign"] = {
				order = order + 0.1,
				type = "select",
				name = "",
				desc = "Assign to supergroup (* indicates override from original)",
				values = function()
					if not addon.SuperGroupManager then return {} end

					return addon.SuperGroupManager:GetAvailableSuperGroups()
				end,
				get = function()
					return familyInfo.currentSuperGroup or "<Standalone>"
				end,
				set = function(info, value)
					if addon.SuperGroupManager then
						local success, message = addon.SuperGroupManager:AssignFamilyToSuperGroup(familyInfo.familyName, value)
						if success then
							addon:AlwaysPrint(" " .. message)
							-- Refresh the list to show changes
							addon.SuperGroupManager:PopulateFamilyAssignmentList()
						else
							addon:AlwaysPrint(" " .. message)
						end
					end
				end,
				width = 1.0,
			}
			-- Preview button
			self.familyListArgsRef[keyBase .. "_preview"] = {
				order = order + 0.2,
				type = "execute",
				name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
				desc = function()
					return addon:GetMountPreviewTooltip(familyInfo.familyName, "familyName")
				end,
				func = function()
					local includeUncollected = addon:GetSetting("showUncollectedMounts")
					local mountID, mountName, isUncollected = addon:GetRandomMountFromGroup(
						familyInfo.familyName, "familyName", includeUncollected)
					if mountID then
						addon:ShowMountPreview(mountID, mountName, familyInfo.familyName, "familyName", isUncollected)
					else
						addon:DebugUI("No mount available to preview from this family")
					end
				end,
				width = 0.2,
			}
			-- Line break
			self.familyListArgsRef[keyBase .. "_break"] = {
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
		self.familyListArgsRef.pagination_controls = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			args = {
				prev_button = {
					order = 1,
					type = "execute",
					name = "<< Prev",
					desc = "Previous page",
					func = function()
						if currentPage > 1 then
							addon.SuperGroupManager.uiState.currentPage = currentPage - 1
							addon.SuperGroupManager:PopulateFamilyAssignmentList()
						end
					end,
					disabled = function() return currentPage <= 1 end,
					width = 0.5,
				},

				next_button = {
					order = 2,
					type = "execute",
					name = "Next >>",
					desc = "Next page",
					func = function()
						if currentPage < totalPages then
							addon.SuperGroupManager.uiState.currentPage = currentPage + 1
							addon.SuperGroupManager:PopulateFamilyAssignmentList()
						end
					end,
					disabled = function() return currentPage >= totalPages end,
					width = 0.5,
				},
			},
		}
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
	end
end

-- Populate supergroup management UI (same pattern as PopulateFamilyManagementUI)
function SuperGroupManager:PopulateSuperGroupManagementUI()
	addon:DebugSupergr(" PopulateSuperGroupManagementUI called")
	if not addon.sgMgmtArgsRef then
		addon:DebugSupergr("addon.sgMgmtArgsRef is nil! Options.lua problem.")
		return
	end

	local startTime = debugprofilestop()
	-- Build new UI arguments
	local newArgs = self:BuildSuperGroupManagementArgs()
	-- Update the options table (same pattern as Family & Groups)
	wipe(addon.sgMgmtArgsRef)
	for k, v in pairs(newArgs) do
		addon.sgMgmtArgsRef[k] = v
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
	end

	local endTime = debugprofilestop()
	addon:DebugSupergr(string.format(" UI build took %.2fms", endTime - startTime))
end

-- Add the page range calculation function (same as MountSeparationManager)
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

-- ENHANCED: Update PopulateFamilyAssignmentUI to validate compatibility
function SuperGroupManager:PopulateFamilyAssignmentUI()
	addon:DebugSupergr(" PopulateFamilyAssignmentUI called")
	if not addon.sgFamilyArgsRef then
		addon:DebugSupergr("addon.sgFamilyArgsRef is nil! Options.lua problem.")
		return
	end

	local startTime = debugprofilestop()
	-- ENHANCED: Validate separated family compatibility before building UI
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		local separatedCount = addon:CountTableEntries(addon.db.profile.separatedMounts)
		if separatedCount > 0 then
			addon:DebugSupergr(" Validating compatibility with " .. separatedCount .. " separated families")
			self:ValidateSeparatedFamilyIntegrity()
		end
	end

	-- Build new UI arguments
	local newArgs = self:BuildFamilyAssignmentArgs()
	-- Update the options table
	wipe(addon.sgFamilyArgsRef)
	for k, v in pairs(newArgs) do
		addon.sgFamilyArgsRef[k] = v
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
	end

	local endTime = debugprofilestop()
	addon:DebugSupergr(string.format(" Family assignment UI build took %.2fms", endTime - startTime))
end

-- Build supergroup management page content
function SuperGroupManager:BuildSuperGroupManagementArgs()
	addon:DebugSupergr(" BuildSuperGroupManagementArgs called")
	local args = {}
	local order = 1
	-- Header
	args.header_mgmt = {
		order = order,
		type = "header",
		name = "Create, Rename, Delete & Merge Supergroups",
	}
	order = order + 1
	args.desc_mgmt = {
		order = order,
		type = "description",
		name =
		"Manage your supergroup structure. Create custom supergroups, rename existing ones, or merge similar groups together.",
		fontSize = "medium",
	}
	order = order + 1
	-- Create New Supergroup Section
	args.create_header = {
		order = order,
		type = "header",
		name = "Create New Supergroup",
	}
	order = order + 1
	args.create_desc = {
		order = order,
		type = "description",
		name = "Enter a name for your new supergroup. You can use letters, numbers, spaces, hyphens, and underscores.",
		fontSize = "medium",
	}
	order = order + 1
	args.create_name = {
		order = order,
		type = "input",
		name = "Supergroup Name",
		desc = "Name for your custom supergroup (e.g., 'My Favorite Dragons')",
		get = function() return self.pendingCreateName or "" end,
		set = function(info, value) self.pendingCreateName = value end,
		width = 1.5,
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

			return "|cff00ff00✓ Available|r" .. (sanitized ~= inputName:trim() and (" (internal: " .. sanitized .. ")") or "")
		end,
		width = 1.5,
	}
	order = order + 1
	args.create_button = {
		order = order,
		type = "execute",
		name = "Create Supergroup",
		desc = "Create the new supergroup",
		func = function()
			local name = self.pendingCreateName or ""
			local success, message = self:CreateSuperGroup(name)
			if success then
				self.pendingCreateName = ""
				addon:AlwaysPrint(" " .. message)
				self:PopulateSuperGroupManagementUI()
			else
				addon:AlwaysPrint(" " .. message)
			end
		end,
		disabled = function()
			local name = self.pendingCreateName or ""
			if name:trim() == "" then return true end

			local hasConflict, _ = self:DoesNameConflict(name)
			return hasConflict or self:SanitizeSuperGroupName(name) == ""
		end,
		width = 0.8,
	}
	order = order + 1
	-- Existing Supergroups Section
	args.existing_header = {
		order = order,
		type = "header",
		name = "Existing Supergroups (" .. #self:GetAllSuperGroups() .. " total)",
	}
	order = order + 1
	-- Add supergroup entries
	-- Add supergroup entries with better conflict checking on renames
	local allSGs = self:GetAllSuperGroups()
	for _, sgInfo in ipairs(allSGs) do
		local keyBase = "sg_" .. sgInfo.name:gsub("[^%w]", "_")
		-- Supergroup name display with original name info
		args[keyBase .. "_name"] = {
			order = order,
			type = "description",
			name = function()
				local indicator = sgInfo.isCustom and "|cff00ff00[Custom]|r" or
						sgInfo.isDeleted and "|cffff0000[Deleted]|r" or
						sgInfo.isRenamed and "|cffffff00[Renamed]|r" or
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
			width = sgInfo.isRenamed and not sgInfo.isCustom and 1.8 or 1.2,
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
					width = 0.6,
				}
			end

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
						addon:AlwaysPrint(" Confirm deletion of '" .. sgInfo.displayName .. "'")
						-- Refresh UI to show confirmation buttons
						self:PopulateSuperGroupManagementUI()
						-- Auto-cancel after 10 seconds
						C_Timer.After(10, function()
							if self.deleteConfirmation and self.deleteConfirmation[sgInfo.name] then
								self.deleteConfirmation[sgInfo.name] = nil
								self:PopulateSuperGroupManagementUI()
								addon:AlwaysPrint(" Delete confirmation timed out for '" .. sgInfo.displayName .. "'")
							end
						end)
					end,
					width = 0.4,
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
					width = 0.4,
				}
				-- Visual separator
				args[keyBase .. "_separator"] = {
					order = order + 0.31,
					type = "description",
					name = " |cffff9900→|r ",
					width = 0.1,
				}
				-- Confirm button
				args[keyBase .. "_confirm"] = {
					order = order + 0.32,
					type = "execute",
					name = "|cffff0000Confirm|r",
					desc = "Confirm deletion of '" .. sgInfo.displayName .. "'",
					func = function()
						-- Actually delete the supergroup
						local success, message = self:DeleteSuperGroup(sgInfo.name)
						if success then
							addon:AlwaysPrint(" " .. message)
							self.deleteConfirmation[sgInfo.name] = nil
							-- Refresh all UIs
							self:PopulateSuperGroupManagementUI()
							self:PopulateFamilyAssignmentUI()
							if addon.PopulateFamilyManagementUI then
								addon:PopulateFamilyManagementUI()
							end
						else
							addon:AlwaysPrint(" " .. message)
							-- Clear confirmation mode on error
							self.deleteConfirmation[sgInfo.name] = nil
							self:PopulateSuperGroupManagementUI()
						end
					end,
					width = 0.25,
				}
				-- Cancel button
				args[keyBase .. "_cancel"] = {
					order = order + 0.33,
					type = "execute",
					name = "Cancel",
					desc = "Cancel deletion",
					func = function()
						-- Exit confirmation mode
						self.deleteConfirmation[sgInfo.name] = nil
						self:PopulateSuperGroupManagementUI()
						addon:AlwaysPrint(" Delete cancelled for '" .. sgInfo.displayName .. "'")
					end,
					width = 0.25,
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
				width = 0.4,
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

	addon:DebugSupergr(" Built management UI with " .. #allSGs .. " supergroups")
	return args
end

-- Build family assignment page content
function SuperGroupManager:BuildFamilyAssignmentArgs()
	addon:DebugSupergr(" BuildFamilyAssignmentArgs called")
	local args = {}
	local order = 1
	-- Header
	args.header_assign = {
		order = order,
		type = "header",
		name = "Assign Families to Supergroups",
	}
	order = order + 1
	args.desc_assign = {
		order = order,
		type = "description",
		name =
		"Move families between supergroups or make them standalone. Use search and bulk operations to manage large collections efficiently.",
		fontSize = "medium",
	}
	order = order + 1
	-- Search section
	args.search_label = {
		order = order,
		type = "description",
		name = "|cffffd700Search:|r",
		width = 0.3,
	}
	order = order + 1
	args.search_input = {
		order = order,
		type = "input",
		name = "",
		desc = "Search family names (press Enter to search)",
		get = function() return self.uiState.searchTerm or "" end,
		set = function(info, value)
			self.uiState.searchTerm = value or ""
			self.uiState.currentPage = 1 -- Reset to first page
			self:PopulateFamilyAssignmentUI()
		end,
		width = 1.0,
	}
	order = order + 1
	-- Family assignment list
	local allFamilies = self:GetAllFamilyAssignments()
	local searchTerm = self.uiState.searchTerm or ""
	local filteredFamilies = {}
	-- Apply search filter
	for _, familyInfo in ipairs(allFamilies) do
		if searchTerm == "" or familyInfo.familyName:lower():find(searchTerm:lower(), 1, true) then
			table.insert(filteredFamilies, familyInfo)
		end
	end

	-- FIXED: Use same pagination style as MountSeparationManager
	local itemsPerPage = 20
	local totalItems = #filteredFamilies
	local totalPages = math.max(1, math.ceil(totalItems / itemsPerPage))
	local currentPage = math.max(1, math.min(self.uiState.currentPage or 1, totalPages))
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalItems)
	-- Page info
	if totalPages > 1 then
		args.page_info = {
			order = order,
			type = "description",
			name = string.format("Page %d of %d (%d families)", currentPage, totalPages, totalItems),
			width = "full",
		}
		order = order + 1
	end

	-- Enhanced Legend/Help section
	args.legend_header = {
		order = order,
		type = "header",
		name = "Status Indicators",
	}
	order = order + 1
	args.legend_desc = {
		order = order,
		type = "description",
		name = "|cffffd700*|r = User Override Active (you've manually changed this assignment)\n" ..
				"|cffff9900⚡|r = Separated by Trait Settings (intended supergroup overridden by trait strictness)\n" ..
				"|cff1eff00[M]|r = Single Mount Family  |cff0070dd[F]|r = Multi Mount Family\n\n" ..
				"|cff00ff00How it works:|r Assignments set your intended supergroup structure. Trait strictness settings can still separate families with distinguishing traits from their intended supergroups.\n" ..
				"|cff888888Example: Assign a unique-effect family to 'Dragons' supergroup. If 'Unique Effects as Distinct' is enabled, it will show as assigned to Dragons but remain separated.|r",
		fontSize = "medium",
		width = "full",
	}
	order = order + 1
	-- Family entries header
	args.family_header = {
		order = order,
		type = "header",
		name = "Family Assignments (Showing " .. math.min(itemsPerPage, totalItems) .. " of " .. totalItems .. ")",
	}
	order = order + 1
	-- ENHANCED: Add column headers for better organization
	if totalItems > 0 then
		args.column_headers = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			width = "full",
			args = {
				previewHeader = {
					order = 1,
					type = "description",
					name = "  |cffffd700Preview|r",
					width = 0.3,
				},
				familyHeader = {
					order = 2,
					type = "description",
					name = "   |cffffd700Family Name|r",
					width = 1.5,
				},
				assignmentHeader = {
					order = 3,
					type = "description",
					name = "   |cffffd700Supergroup Assignment|r",
					width = 1.0,
				},
			},
		}
		order = order + 1
	end

	-- Build family entries for current page
	for i = startIndex, endIndex do
		local familyInfo = filteredFamilies[i]
		if familyInfo then
			local keyBase = "family_" .. familyInfo.familyName:gsub("[^%w]", "_")
			-- ENHANCED: Create comprehensive family entry
			args[keyBase .. "_entry"] = {
				order = order,
				type = "group",
				inline = true,
				name = "",
				args = {
					-- Preview button
					preview = {
						order = 1,
						type = "execute",
						name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
						desc = function()
							return addon:GetMountPreviewTooltip(familyInfo.familyName, "familyName")
						end,
						func = function()
							local includeUncollected = addon:GetSetting("showUncollectedMounts")
							local mountID, mountName, isUncollected = addon:GetRandomMountFromGroup(
								familyInfo.familyName, "familyName", includeUncollected)
							if mountID then
								addon:ShowMountPreview(mountID, mountName, familyInfo.familyName, "familyName", isUncollected)
							else
								addon:DebugUI("No mount available to preview from this family")
							end
						end,
						width = 0.3,
					},

					-- ENHANCED: Family name with comprehensive status indicators
					family_name = {
						order = 2,
						type = "description",
						name = function()
							local indicator = (familyInfo.totalCount == 1) and "|cff1eff00[M]|r" or "|cff0070dd[F]|r"
							local countText = "(" .. familyInfo.collectedCount
							if familyInfo.uncollectedCount > 0 then
								countText = countText .. " + |cff9d9d9d" .. familyInfo.uncollectedCount .. "|r"
							end

							countText = countText .. ")"
							-- Status indicators
							local statusIndicators = {}
							if familyInfo.hasUserOverride then
								table.insert(statusIndicators, "|cffffd700*|r") -- User override
							end

							if familyInfo.isSeparatedByStrictness then
								table.insert(statusIndicators, "|cffff9900⚡|r") -- Separated by strictness
							end

							local statusText = #statusIndicators > 0 and (" " .. table.concat(statusIndicators, "")) or ""
							return indicator .. " " .. familyInfo.familyName .. " " .. countText .. statusText
						end,
						width = 1.5,
					},

					-- ENHANCED: Supergroup assignment dropdown with better tooltips
					assignment = {
						order = 3,
						type = "select",
						name = "",
						desc = function()
							local baseDesc = "Set intended supergroup assignment\n"
							local statusLines = {}
							if familyInfo.hasUserOverride then
								table.insert(statusLines, "|cffffd700* User Override Active|r")
							end

							if familyInfo.isSeparatedByStrictness then
								table.insert(statusLines,
									"|cffff9900⚡ " .. (familyInfo.separationReason or "Separated by trait settings") .. "|r")
								table.insert(statusLines,
									"|cff888888This family is assigned to the supergroup shown, but trait strictness keeps it separated.|r")
								table.insert(statusLines,
									"|cff888888Disable relevant trait strictness to reunite it with the supergroup.|r")
							end

							if familyInfo.originalSuperGroup and familyInfo.originalSuperGroup ~= familyInfo.displaySuperGroup then
								table.insert(statusLines, "|cff888888Originally: " .. familyInfo.originalSuperGroup .. "|r")
							end

							return baseDesc .. (#statusLines > 0 and ("\n" .. table.concat(statusLines, "\n")) or "")
						end,
						values = function() return self:GetAvailableSuperGroups() end,
						get = function()
							-- Convert actual supergroup to prefixed key for display
							local actualSG = familyInfo.displaySuperGroup or "<Standalone>"
							-- Find the matching prefixed key
							local availableSGs = self:GetAvailableSuperGroups()
							for prefixedKey, displayName in pairs(availableSGs) do
								-- Extract the actual supergroup name from the prefixed key
								local extractedSG = prefixedKey:match("^%d+_%d*_?(.+)$") or prefixedKey:match("^%d+_(.+)$")
								if extractedSG == actualSG then
									return prefixedKey
								end
							end

							-- Fallback
							return "0_<Standalone>"
						end,
						set = function(info, prefixedValue)
							-- Extract actual supergroup name from prefixed key
							local actualSG = prefixedValue:match("^%d+_%d*_?(.+)$") or prefixedValue:match("^%d+_(.+)$")
							if actualSG then
								local success, message = self:AssignFamilyToSuperGroup(familyInfo.familyName, actualSG)
								if success then
									addon:AlwaysPrint(" " .. message)
									-- Refresh all UIs
									self:PopulateSuperGroupManagementUI()
									self:PopulateFamilyAssignmentUI()
									if addon.PopulateFamilyManagementUI then
										addon:PopulateFamilyManagementUI()
									end
								else
									addon:AlwaysPrint(" " .. message)
								end
							end
						end,
						width = 1.0,
					},
				},
			}
			order = order + 1
		end
	end

	-- FIXED: Use same pagination style as MountSeparationManager
	if totalPages > 1 then
		local paginationComponents = self:CreateFamilyAssignmentPaginationControls(
			currentPage, totalPages, order)
		for k, v in pairs(paginationComponents) do
			args[k] = v
		end

		order = order + 1
	end

	addon:DebugSupergr(" Built family assignment UI with " .. #filteredFamilies .. " families")
	return args
end

-- NEW: Create pagination controls matching MountSeparationManager style
function SuperGroupManager:CreateFamilyAssignmentPaginationControls(currentPage, totalPages, order)
	if totalPages <= 1 then
		return {}
	end

	-- Calculate which pages to show (reuse the logic from MountUIComponents)
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
			-- Add page number button - THIS IS THE KEY CHANGE
			local isCurrentPage = (pageNum == currentPage)
			paginationArgs["page_" .. pageNum] = {
				order = buttonOrder,
				type = "execute",
				name = isCurrentPage and ("|cffffd700" .. pageNum .. "|r") or tostring(pageNum),
				desc = isCurrentPage and "Current page" or "",
				func = function()
					self.uiState.currentPage = pageNum
					self:PopulateFamilyAssignmentUI()
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
		family_assignment_pagination = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			args = paginationArgs,
		},
	}
end

-- ============================================================================
-- SUPERGROUP CRUD OPERATIONS
-- ============================================================================
-- Get all supergroups (original + custom, excluding deleted)
function SuperGroupManager:GetAllSuperGroups()
	local allSuperGroups = {}
	-- Ensure data is ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSupergr(" Data not ready for GetAllSuperGroups")
		return allSuperGroups
	end

	addon:DebugSupergr(" GetAllSuperGroups - Data is ready, processing...")
	-- Add original supergroups (if not deleted)
	if addon.processedData.superGroupMap then
		addon:DebugSupergr(" Found " ..
			addon:CountTableEntries(addon.processedData.superGroupMap) .. " original supergroups")
		for sgName, _ in pairs(addon.processedData.superGroupMap) do
			if not addon:IsSuperGroupDeleted(sgName) then
				table.insert(allSuperGroups, {
					name = sgName,
					displayName = addon:GetSuperGroupDisplayName(sgName),
					isCustom = false,
					isRenamed = addon:IsSuperGroupRenamed(sgName),
					isDeleted = false,
				})
				addon:DebugSupergr(" Added original supergroup: " .. sgName)
			else
				addon:DebugSupergr(" Skipped deleted supergroup: " .. sgName)
			end
		end
	else
		addon:DebugSupergr(" No original supergroups found in processedData")
	end

	-- Add custom supergroups
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		addon:DebugSupergr(" Found " ..
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
				addon:DebugSupergr(" Added custom supergroup: " .. sgName)
			end
		end
	else
		addon:DebugSupergr(" No custom supergroup definitions found")
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
				addon:DebugSupergr(" Added deleted supergroup for restore: " .. sgName)
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
	addon:DebugSupergr(" GetAllSuperGroups returning " .. #allSuperGroups .. " supergroups")
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
	addon:DebugSupergr(" Created custom supergroup: '" .. displayName .. "' (internal: " .. internalName .. ")")
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

		addon:DebugSupergr(" Restored original name for supergroup: " .. sgName)
	else
		-- Renaming to a different name - update or create definition
		if not addon.db.profile.superGroupDefinitions[sgName] then
			addon.db.profile.superGroupDefinitions[sgName] = {}
		end

		addon.db.profile.superGroupDefinitions[sgName].displayName = trimmedNewName
		addon.db.profile.superGroupDefinitions[sgName].isRenamed = true
		addon:DebugSupergr(" Renamed supergroup: " .. sgName .. " to '" .. trimmedNewName .. "'")
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

	addon:DebugSupergr(" Restored original name for: " .. sgName)
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

		addon:DebugSupergr(" Deleted custom supergroup: " .. sgName)
	else
		-- For original supergroups, mark as deleted
		addon.db.profile.deletedSuperGroups[sgName] = true
		addon:DebugSupergr(" Marked original supergroup as deleted: " .. sgName)
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
			addon:DebugSupergr(" Cleared assignments for " .. #clearedFamilies .. " families")
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
		addon:DebugSupergr(" Cleaned up rename data during restoration of: " .. sgName)
	end

	addon:DebugSupergr(" Restored supergroup: " .. sgName)
	-- Trigger rebuild
	addon:RebuildMountGrouping()
	return true, "Supergroup restored to original state"
end

-- Merge supergroups
function SuperGroupManager:MergeSuperGroups(sourceSG, targetSG)
	if not sourceSG or not targetSG or sourceSG == targetSG then
		return false, "Invalid supergroup selection"
	end

	if not self:SuperGroupExists(sourceSG) or not self:SuperGroupExists(targetSG) then
		return false, "One or both supergroups do not exist"
	end

	-- Get display names for better user feedback
	local sourceDisplayName = addon:GetSuperGroupDisplayName(sourceSG)
	local targetDisplayName = addon:GetSuperGroupDisplayName(targetSG)
	-- Initialize database structures if needed
	if not addon.db.profile.superGroupOverrides then
		addon.db.profile.superGroupOverrides = {}
	end

	local movedFamilies = 0
	-- Find all families currently in source supergroup and move them to target
	local allFamilyNames = {}
	-- Collect all family names
	if addon.processedData and addon.processedData.allCollectedMountFamilyInfo then
		for _, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
			allFamilyNames[mountInfo.familyName] = true
		end
	end

	if addon.processedData and addon.processedData.allUncollectedMountFamilyInfo then
		for _, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
			allFamilyNames[mountInfo.familyName] = true
		end
	end

	-- Check each family to see if it's currently in the source supergroup
	for familyName, _ in pairs(allFamilyNames) do
		local currentSG = addon:GetEffectiveSuperGroup(familyName)
		if currentSG == sourceSG then
			-- Move this family to target supergroup
			addon.db.profile.superGroupOverrides[familyName] = targetSG
			movedFamilies = movedFamilies + 1
		end
	end

	-- Delete the source supergroup
	local deleteSuccess, deleteMessage = self:DeleteSuperGroup(sourceSG)
	if deleteSuccess then
		addon:DebugSupergr(" Merged '" ..
			sourceDisplayName .. "' into '" .. targetDisplayName .. "' (" .. movedFamilies .. " families moved)")
		return true,
				"Merged " .. movedFamilies .. " families from '" .. sourceDisplayName .. "' to '" .. targetDisplayName .. "'"
	else
		return false, "Merge failed: " .. deleteMessage
	end
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

-- ============================================================================
-- FAMILY ASSIGNMENT OPERATIONS
-- ============================================================================
-- Get all families with their current supergroup assignments
function SuperGroupManager:GetAllFamilyAssignments()
	local familyAssignments = {}
	-- Ensure data is ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSupergr(" Data not ready for GetAllFamilyAssignments")
		return familyAssignments
	end

	addon:DebugSupergr(" GetAllFamilyAssignments - Data is ready, processing...")
	-- Get all unique families from collected mounts
	local allFamilies = {}
	if addon.processedData.allCollectedMountFamilyInfo then
		for _, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
			allFamilies[mountInfo.familyName] = true
		end

		addon:DebugSupergr(" Found families from collected mounts: " .. addon:CountTableEntries(allFamilies))
	end

	-- Add families from uncollected mounts
	if addon.processedData.allUncollectedMountFamilyInfo then
		local uncollectedFamilyCount = 0
		for _, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
			if not allFamilies[mountInfo.familyName] then
				uncollectedFamilyCount = uncollectedFamilyCount + 1
			end

			allFamilies[mountInfo.familyName] = true
		end

		addon:DebugSupergr(" Added " .. uncollectedFamilyCount .. " new families from uncollected mounts")
	end

	-- FIXED: Also include separated families
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local newFamilyName = separationData.familyName
			if newFamilyName and not allFamilies[newFamilyName] then
				allFamilies[newFamilyName] = true
				addon:DebugSupergr(" Added separated family: " .. newFamilyName)
			end
		end
	end

	addon:DebugSupergr(" Total unique families to process: " .. addon:CountTableEntries(allFamilies))
	-- Build assignment data for each family
	for familyName, _ in pairs(allFamilies) do
		local originalSG = addon:GetOriginalSuperGroup(familyName) -- Before any changes
		local effectiveSG = addon:GetEffectiveSuperGroup(familyName) -- Final result after all processing
		-- FIXED: Determine intended supergroup (what user wants, regardless of trait strictness)
		local intendedSG = originalSG                              -- Start with original
		local hasUserOverride = false
		-- Check if there's a user override (this becomes the intended assignment)
		if addon.db and addon.db.profile and addon.db.profile.superGroupOverrides then
			local override = addon.db.profile.superGroupOverrides[familyName]
			if override ~= nil then
				hasUserOverride = true
				if override == false then
					intendedSG = nil -- User explicitly wants it standalone
				else
					intendedSG = override -- User assigned to specific supergroup
				end
			end
		end

		-- FIXED: Check if trait strictness is separating this family from its intended assignment
		local isSeparatedByStrictness = false
		local separationReason = nil
		-- If intended assignment differs from effective assignment, check if it's due to trait strictness
		if intendedSG ~= effectiveSG then
			-- Check if this family has distinguishing traits that would cause separation
			local effectiveTraits = addon:GetEffectiveTraits(familyName)
			local treatMinorArmorAsDistinct = addon:GetSetting("treatMinorArmorAsDistinct")
			local treatMajorArmorAsDistinct = addon:GetSetting("treatMajorArmorAsDistinct")
			local treatModelVariantsAsDistinct = addon:GetSetting("treatModelVariantsAsDistinct")
			local treatUniqueEffectsAsDistinct = addon:GetSetting("treatUniqueEffectsAsDistinct")
			if (treatMinorArmorAsDistinct and effectiveTraits.hasMinorArmor) or
					(treatMajorArmorAsDistinct and effectiveTraits.hasMajorArmor) or
					(treatModelVariantsAsDistinct and effectiveTraits.hasModelVariant) or
					(treatUniqueEffectsAsDistinct and effectiveTraits.isUniqueEffect) then
				isSeparatedByStrictness = true
				separationReason = addon:GetFamilySeparationReason(familyName)
				addon:DebugSupergr(" Family '" ..
					familyName .. "' separated by trait strictness from intended: " .. tostring(intendedSG))
			end
		end

		-- Display the intended assignment (what the user wants)
		local displaySuperGroup = intendedSG
		-- Count mounts in this family
		local collectedCount = (addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[familyName] and
			#(addon.processedData.familyToMountIDsMap[familyName])) or 0
		local uncollectedCount = 0
		if addon:GetSetting("showUncollectedMounts") then
			uncollectedCount = (addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[familyName] and
				#(addon.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
		end

		-- Only include families that should be shown
		if addon:ShouldShowFamily(familyName) then
			table.insert(familyAssignments, {
				familyName = familyName,
				-- Supergroup relationships
				originalSuperGroup = originalSG,   -- What it was originally
				intendedSuperGroup = intendedSG,   -- What user wants (intended assignment)
				effectiveSuperGroup = effectiveSG, -- Final result after all processing
				displaySuperGroup = displaySuperGroup, -- What to show in UI (intended)
				-- Status flags
				isSeparatedByStrictness = isSeparatedByStrictness,
				hasUserOverride = hasUserOverride,
				separationReason = separationReason,
				-- Mount counts
				collectedCount = collectedCount,
				uncollectedCount = uncollectedCount,
				totalCount = collectedCount + uncollectedCount,
			})
		end
	end

	-- Sort alphabetically with custom supergroups first
	table.sort(familyAssignments, function(a, b)
		-- Get supergroup info for both families
		local aSGIsCustom = false
		local bSGIsCustom = false
		if a.displaySuperGroup and addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
			local aSGDef = addon.db.profile.superGroupDefinitions[a.displaySuperGroup]
			aSGIsCustom = aSGDef and aSGDef.isCustom or false
		end

		if b.displaySuperGroup and addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
			local bSGDef = addon.db.profile.superGroupDefinitions[b.displaySuperGroup]
			bSGIsCustom = bSGDef and bSGDef.isCustom or false
		end

		-- Custom supergroup families come first
		if aSGIsCustom and not bSGIsCustom then
			return true
		elseif not aSGIsCustom and bSGIsCustom then
			return false
		else
			-- Within same category, sort alphabetically by family name
			return a.familyName < b.familyName
		end
	end)
	addon:DebugSupergr(" GetAllFamilyAssignments returning " .. #familyAssignments .. " family assignments")
	return familyAssignments
end

-- Assign family to supergroup
function SuperGroupManager:AssignFamilyToSuperGroup(familyName, targetSG)
	if not familyName then
		return false, "Invalid family name"
	end

	-- Initialize database structures if needed
	if not addon.db.profile.superGroupOverrides then
		addon.db.profile.superGroupOverrides = {}
	end

	-- ENHANCED: Check if this is a separated family
	local isSeparatedFamily = false
	local separatedMountID = nil
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			if separationData.familyName == familyName then
				isSeparatedFamily = true
				separatedMountID = tonumber(mountID)
				break
			end
		end
	end

	-- Get the family's relationships
	local originalSG = addon:GetOriginalSuperGroup(familyName)
	addon:DebugSupergr(" Assigning " .. familyName .. " - Original: " .. tostring(originalSG) ..
		", Target: " .. tostring(targetSG) .. ", IsSeparated: " .. tostring(isSeparatedFamily))
	if targetSG == nil or targetSG == "" or targetSG == "<Standalone>" then
		-- Assign to standalone (set intended assignment to standalone)
		if originalSG == nil then
			-- Already originally standalone, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
			addon:DebugSupergr(" Cleared override for " .. familyName .. " (originally standalone)")
		else
			-- Force to standalone (override original assignment)
			addon.db.profile.superGroupOverrides[familyName] = false
			addon:DebugSupergr(" Set " .. familyName .. " intended assignment to standalone")
		end
	else
		-- Assign to specific supergroup (set intended assignment)
		if targetSG == originalSG then
			-- Same as original assignment, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
			addon:DebugSupergr(" Cleared override for " .. familyName .. " (matches original assignment)")
		else
			-- Override to new supergroup (set intended assignment)
			addon.db.profile.superGroupOverrides[familyName] = targetSG
			addon:DebugSupergr(" Set " .. familyName .. " intended assignment to " .. targetSG)
		end
	end

	-- ENHANCED: Handle weight synchronization for separated families
	if isSeparatedFamily and separatedMountID then
		local mountKey = "mount_" .. separatedMountID
		local familyWeight = addon:GetGroupWeight(familyName)
		local mountWeight = addon:GetGroupWeight(mountKey)
		-- Ensure family and mount weights are synchronized
		if familyWeight ~= mountWeight then
			addon:DebugSupergr(" Synchronizing weights for separated family - Family: " ..
				familyWeight .. ", Mount: " .. mountWeight)
			-- Use the higher weight to avoid downgrading
			local syncWeight = math.max(familyWeight, mountWeight)
			addon:SetGroupWeight(familyName, syncWeight)
			addon:SetGroupWeight(mountKey, syncWeight)
		end
	end

	-- Trigger rebuild - this will apply the intended assignment, then trait strictness
	addon:RebuildMountGrouping()
	-- ENHANCED: Also refresh mount pools if they exist
	if addon.MountSummon and addon.MountSummon.RefreshMountPools then
		addon.MountSummon:RefreshMountPools()
	end

	-- Check if the assignment was overridden by trait strictness
	local effectiveSG = addon:GetEffectiveSuperGroup(familyName)
	if targetSG ~= "<Standalone>" and targetSG ~= effectiveSG then
		-- Family was assigned but separated by trait strictness
		return true, "Family assigned to " .. targetSG .. " (currently separated by trait strictness settings)"
	elseif targetSG == "<Standalone>" and effectiveSG ~= nil then
		-- Family was set to standalone but trait strictness might have placed it elsewhere
		return true, "Family set to standalone"
	else
		return true, "Family assignment updated"
	end
end

-- ENHANCED: Add helper method to check separated family compatibility
function SuperGroupManager:ValidateSeparatedFamilyIntegrity()
	if not (addon.db and addon.db.profile and addon.db.profile.separatedMounts) then
		return true
	end

	local issues = {}
	local fixedIssues = 0
	for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
		local familyName = separationData.familyName
		local mountIDNum = tonumber(mountID)
		-- Check if the separated family exists in processed data
		local familyExists = false
		if addon.processedData then
			-- Check collected mounts
			if addon.processedData.familyToMountIDsMap and
					addon.processedData.familyToMountIDsMap[familyName] then
				for _, id in ipairs(addon.processedData.familyToMountIDsMap[familyName]) do
					if id == mountIDNum then
						familyExists = true
						break
					end
				end
			end

			-- Check uncollected mounts
			if not familyExists and addon.processedData.familyToUncollectedMountIDsMap and
					addon.processedData.familyToUncollectedMountIDsMap[familyName] then
				for _, id in ipairs(addon.processedData.familyToUncollectedMountIDsMap[familyName]) do
					if id == mountIDNum then
						familyExists = true
						break
					end
				end
			end
		end

		if not familyExists then
			table.insert(issues, "Separated mount " .. mountID .. " family '" .. familyName .. "' not found in processed data")
		end

		-- Check weight synchronization
		if familyExists then
			local mountKey = "mount_" .. mountID
			local familyWeight = addon:GetGroupWeight(familyName)
			local mountWeight = addon:GetGroupWeight(mountKey)
			if familyWeight ~= mountWeight then
				-- Auto-fix weight synchronization
				local syncWeight = math.max(familyWeight, mountWeight, 3) -- At least Normal weight
				addon:SetGroupWeight(familyName, syncWeight)
				addon:SetGroupWeight(mountKey, syncWeight)
				fixedIssues = fixedIssues + 1
				addon:DebugSupergr(" Fixed weight sync for " .. familyName .. " -> " .. syncWeight)
			end
		end
	end

	if #issues > 0 then
		addon:DebugSupergr(" Found " .. #issues .. " separated family integrity issues")
		for _, issue in ipairs(issues) do
			addon:DebugSupergr(" ISSUE: " .. issue)
		end
	end

	if fixedIssues > 0 then
		addon:DebugSupergr(" Auto-fixed " .. fixedIssues .. " weight synchronization issues")
	end

	return #issues == 0, issues
end

-- Get available supergroups for assignment dropdown
function SuperGroupManager:GetAvailableSuperGroups()
	local availableSGs = {}
	-- FIXED: Use prefixed keys to force Ace sorting order
	-- Start with standalone
	availableSGs["0_<Standalone>"] = "Standalone (No Supergroup)"
	-- Add custom supergroups first (prefix with 1_)
	local allSGs = self:GetAllSuperGroups()
	local customCounter = 1
	local originalCounter = 1
	for _, sgInfo in ipairs(allSGs) do
		if not sgInfo.isDeleted then
			if sgInfo.isCustom then
				-- Custom groups get 1_ prefix
				local key = string.format("1_%03d_%s", customCounter, sgInfo.name)
				local displayText = "|cff00ff00[Custom]|r " .. sgInfo.displayName
				availableSGs[key] = displayText
				customCounter = customCounter + 1
			end
		end
	end

	-- Then add original supergroups (prefix with 2_)
	for _, sgInfo in ipairs(allSGs) do
		if not sgInfo.isDeleted then
			if not sgInfo.isCustom then
				-- Original groups get 2_ prefix
				local key = string.format("2_%03d_%s", originalCounter, sgInfo.name)
				availableSGs[key] = sgInfo.displayName
				originalCounter = originalCounter + 1
			end
		end
	end

	return availableSGs
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
-- IMPORT/EXPORT OPERATIONS
-- ============================================================================
-- Export current supergroup configuration
function SuperGroupManager:ExportConfiguration()
	local config = {
		version = "1.1", -- Bumped version to indicate separated mounts support
		timestamp = time(),
		superGroupOverrides = {},
		superGroupDefinitions = {},
		deletedSuperGroups = {},
		separatedMounts = {}, -- ENHANCED: Include separated mounts
	}
	-- Copy current configuration
	if addon.db and addon.db.profile then
		if addon.db.profile.superGroupOverrides then
			for k, v in pairs(addon.db.profile.superGroupOverrides) do
				config.superGroupOverrides[k] = v
			end
		end

		if addon.db.profile.superGroupDefinitions then
			for k, v in pairs(addon.db.profile.superGroupDefinitions) do
				config.superGroupDefinitions[k] = {}
				for kk, vv in pairs(v) do
					config.superGroupDefinitions[k][kk] = vv
				end
			end
		end

		if addon.db.profile.deletedSuperGroups then
			for k, v in pairs(addon.db.profile.deletedSuperGroups) do
				config.deletedSuperGroups[k] = v
			end
		end

		-- ENHANCED: Export separated mounts data
		if addon.db.profile.separatedMounts then
			for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
				config.separatedMounts[mountID] = {}
				for kk, vv in pairs(separationData) do
					config.separatedMounts[mountID][kk] = vv
				end
			end
		end
	end

	-- Convert to string
	local serialized = self:SerializeTable(config)
	return serialized
end

-- Import supergroup configuration
function SuperGroupManager:ImportConfiguration(configString, importMode)
	importMode = importMode or "replace"
	if not configString or configString:trim() == "" then
		return false, "Configuration string is empty"
	end

	-- Deserialize
	local success, config = pcall(self.DeserializeTable, self, configString)
	if not success or not config then
		return false, "Invalid configuration format"
	end

	-- Validate configuration - support both old and new formats
	if not config.superGroupOverrides or not config.superGroupDefinitions or not config.deletedSuperGroups then
		return false, "Configuration is missing required data"
	end

	-- Check version for compatibility
	local configVersion = config.version or "1.0"
	local hasSeparatedMounts = config.separatedMounts ~= nil
	addon:DebugImport(" Importing configuration version " .. configVersion ..
		(hasSeparatedMounts and " (with separated mounts)" or " (no separated mounts)"))
	-- Initialize database structures if needed
	if not addon.db.profile.superGroupOverrides then
		addon.db.profile.superGroupOverrides = {}
	end

	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	if not addon.db.profile.deletedSuperGroups then
		addon.db.profile.deletedSuperGroups = {}
	end

	-- ENHANCED: Initialize separated mounts if needed
	if not addon.db.profile.separatedMounts then
		addon.db.profile.separatedMounts = {}
	end

	local importStats = {
		overrides = 0,
		definitions = 0,
		deletions = 0,
		separatedMounts = 0, -- ENHANCED: Track separated mounts
	}
	if importMode == "replace" then
		-- Clear existing configuration
		wipe(addon.db.profile.superGroupOverrides)
		wipe(addon.db.profile.superGroupDefinitions)
		wipe(addon.db.profile.deletedSuperGroups)
		-- ENHANCED: Clear separated mounts in replace mode
		wipe(addon.db.profile.separatedMounts)
		addon:DebugImport("Cleared existing configuration for replace mode")
	end

	-- Import overrides
	for familyName, assignment in pairs(config.superGroupOverrides) do
		addon.db.profile.superGroupOverrides[familyName] = assignment
		importStats.overrides = importStats.overrides + 1
	end

	-- Import definitions
	for sgName, definition in pairs(config.superGroupDefinitions) do
		addon.db.profile.superGroupDefinitions[sgName] = {}
		for k, v in pairs(definition) do
			addon.db.profile.superGroupDefinitions[sgName][k] = v
		end

		importStats.definitions = importStats.definitions + 1
	end

	-- Import deletions
	for sgName, isDeleted in pairs(config.deletedSuperGroups) do
		addon.db.profile.deletedSuperGroups[sgName] = isDeleted
		if isDeleted then
			importStats.deletions = importStats.deletions + 1
		end
	end

	-- ENHANCED: Import separated mounts if present
	if hasSeparatedMounts then
		for mountID, separationData in pairs(config.separatedMounts) do
			-- Validate separated mount data before importing
			if separationData.familyName and separationData.originalFamily then
				addon.db.profile.separatedMounts[mountID] = {}
				for k, v in pairs(separationData) do
					addon.db.profile.separatedMounts[mountID][k] = v
				end

				importStats.separatedMounts = importStats.separatedMounts + 1
			else
				addon:DebugImport(" Skipped invalid separated mount data for mount " .. mountID)
			end
		end
	end

	-- Trigger complete data rebuild since separated mounts affect the data structure
	if importStats.separatedMounts > 0 then
		addon:DebugImport("Rebuilding data due to separated mounts import...")
		addon.lastProcessingEventName = "import_with_separated_mounts"
		addon:InitializeProcessedData()
		addon.lastProcessingEventName = nil
	else
		-- Regular rebuild for supergroup changes
		addon:RebuildMountGrouping()
	end

	-- ENHANCED: Build comprehensive import message
	local message = string.format(
		"Imported %d family assignments, %d supergroup definitions, %d deletions",
		importStats.overrides, importStats.definitions, importStats.deletions
	)
	if importStats.separatedMounts > 0 then
		message = message .. string.format(", and %d separated mounts", importStats.separatedMounts)
	end

	addon:DebugSupergr(" " .. message)
	return true, message
end

-- Reset to defaults (clear all customizations) - ENHANCED to reset everything
function SuperGroupManager:ResetToDefaults(resetType)
	resetType = resetType or "all"
	if not addon.db or not addon.db.profile then
		return false, "Database not available"
	end

	local resetStats = {
		overrides = 0,
		definitions = 0,
		deletions = 0,
		separatedMounts = 0, -- ENHANCED: Track separated mounts
		groupWeights = 0,  -- ENHANCED: Track weight settings
		traitOverrides = 0, -- ENHANCED: Track trait overrides
	}
	if resetType == "all" or resetType == "assignments" then
		-- Clear family assignments
		if addon.db.profile.superGroupOverrides then
			resetStats.overrides = addon:CountTableEntries(addon.db.profile.superGroupOverrides)
			wipe(addon.db.profile.superGroupOverrides)
		end
	end

	if resetType == "all" or resetType == "custom" then
		-- Clear custom supergroups only
		if addon.db.profile.superGroupDefinitions then
			for sgName, definition in pairs(addon.db.profile.superGroupDefinitions) do
				if definition.isCustom then
					addon.db.profile.superGroupDefinitions[sgName] = nil
					resetStats.definitions = resetStats.definitions + 1
				end
			end
		end
	end

	if resetType == "all" or resetType == "deletions" then
		-- Clear deleted supergroups (restore all)
		if addon.db.profile.deletedSuperGroups then
			resetStats.deletions = addon:CountTableEntries(addon.db.profile.deletedSuperGroups)
			wipe(addon.db.profile.deletedSuperGroups)
		end
	end

	if resetType == "all" then
		-- ENHANCED: Clear ALL customizations for complete reset
		addon:DebugImport("Performing complete reset of all saved variables...")
		-- Clear all supergroup customizations including renames
		if addon.db.profile.superGroupDefinitions then
			wipe(addon.db.profile.superGroupDefinitions)
		end

		-- ENHANCED: Clear separated mounts
		if addon.db.profile.separatedMounts then
			resetStats.separatedMounts = addon:CountTableEntries(addon.db.profile.separatedMounts)
			wipe(addon.db.profile.separatedMounts)
			addon:DebugImport("Cleared " .. resetStats.separatedMounts .. " separated mounts")
		end

		-- ENHANCED: Clear all group weights (mount, family, and supergroup weights)
		if addon.db.profile.groupWeights then
			resetStats.groupWeights = addon:CountTableEntries(addon.db.profile.groupWeights)
			wipe(addon.db.profile.groupWeights)
			addon:DebugImport("Cleared " .. resetStats.groupWeights .. " weight settings")
		end

		-- ENHANCED: Clear all trait overrides
		if addon.db.profile.traitOverrides then
			resetStats.traitOverrides = addon:CountTableEntries(addon.db.profile.traitOverrides)
			wipe(addon.db.profile.traitOverrides)
			addon:DebugImport("Cleared " .. resetStats.traitOverrides .. " trait overrides")
		end
	end

	-- ENHANCED: Trigger complete data rebuild if separated mounts were cleared
	if resetStats.separatedMounts > 0 then
		addon:DebugImport("Rebuilding data due to separated mounts reset...")
		addon.lastProcessingEventName = "reset_with_separated_mounts"
		addon:InitializeProcessedData()
		addon.lastProcessingEventName = nil
	else
		-- Regular rebuild for other changes
		addon:RebuildMountGrouping()
	end

	-- ENHANCED: Build comprehensive reset message
	local message = string.format(
		"Reset %d family assignments, %d custom supergroups, and restored %d deleted supergroups",
		resetStats.overrides, resetStats.definitions, resetStats.deletions
	)
	if resetType == "all" then
		local additionalResets = {}
		if resetStats.separatedMounts > 0 then
			table.insert(additionalResets, resetStats.separatedMounts .. " separated mounts")
		end

		if resetStats.groupWeights > 0 then
			table.insert(additionalResets, resetStats.groupWeights .. " weight settings")
		end

		if resetStats.traitOverrides > 0 then
			table.insert(additionalResets, resetStats.traitOverrides .. " trait overrides")
		end

		if #additionalResets > 0 then
			message = message .. "; also cleared " .. table.concat(additionalResets, ", ")
		end
	end

	addon:DebugSupergr(" " .. message)
	return true, message
end

-- Reset mount separation only (reunite all separated mounts)
function SuperGroupManager:ResetMountSeparationOnly()
	if not addon.db or not addon.db.profile then
		return false, "Database not available"
	end

	if not addon.db.profile.separatedMounts then
		return false, "No separated mounts to reset"
	end

	local separatedCount = addon:CountTableEntries(addon.db.profile.separatedMounts)
	if separatedCount == 0 then
		return false, "No separated mounts found"
	end

	addon:DebugImport(" Resetting " .. separatedCount .. " separated mounts...")
	-- Clear separated mount family weight settings (but keep individual mount weights)
	local clearedFamilyWeights = 0
	if addon.db.profile.groupWeights then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.groupWeights[separatedFamilyName] then
				addon.db.profile.groupWeights[separatedFamilyName] = nil
				clearedFamilyWeights = clearedFamilyWeights + 1
			end
		end
	end

	-- Clear separated family supergroup overrides
	local clearedOverrides = 0
	if addon.db.profile.superGroupOverrides then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.superGroupOverrides[separatedFamilyName] then
				addon.db.profile.superGroupOverrides[separatedFamilyName] = nil
				clearedOverrides = clearedOverrides + 1
			end
		end
	end

	-- Clear separated family trait overrides
	local clearedTraitOverrides = 0
	if addon.db.profile.traitOverrides then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.traitOverrides[separatedFamilyName] then
				addon.db.profile.traitOverrides[separatedFamilyName] = nil
				clearedTraitOverrides = clearedTraitOverrides + 1
			end
		end
	end

	-- Clear the separated mounts data
	wipe(addon.db.profile.separatedMounts)
	addon:DebugImport(" Cleared separated mounts and " .. clearedFamilyWeights ..
		" family weights, " .. clearedOverrides .. " supergroup overrides, " ..
		clearedTraitOverrides .. " trait overrides")
	-- Trigger complete data rebuild
	addon.lastProcessingEventName = "reset_mount_separation"
	addon:InitializeProcessedData()
	addon.lastProcessingEventName = nil
	-- Refresh all UIs
	self:RefreshAllUIs()
	local message = string.format(
		"Reset %d separated mounts and reunited them with their original families",
		separatedCount
	)
	if clearedFamilyWeights > 0 or clearedOverrides > 0 or clearedTraitOverrides > 0 then
		message = message .. string.format(
			" (also cleared %d family weights, %d supergroup assignments, %d trait overrides)",
			clearedFamilyWeights, clearedOverrides, clearedTraitOverrides
		)
	end

	addon:DebugImport(" " .. message)
	return true, message
end

-- ============================================================================
-- SERIALIZATION HELPERS
-- ============================================================================
-- Simple table serialization
function SuperGroupManager:SerializeTable(tbl)
	local function serialize(o)
		if type(o) == "number" then
			return tostring(o)
		elseif type(o) == "string" then
			return string.format("%q", o)
		elseif type(o) == "boolean" then
			return tostring(o)
		elseif type(o) == "table" then
			local result = "{"
			for k, v in pairs(o) do
				if type(k) == "string" then
					result = result .. "[" .. string.format("%q", k) .. "]="
				else
					result = result .. "[" .. k .. "]="
				end

				result = result .. serialize(v) .. ","
			end

			result = result .. "}"
			return result
		else
			return "nil"
		end
	end

	return serialize(tbl)
end

-- Simple table deserialization
function SuperGroupManager:DeserializeTable(str)
	local func = loadstring("return " .. str)
	if func then
		return func()
	else
		return nil
	end
end

-- ============================================================================
-- DATA VALIDATION AND REPAIR SYSTEM
-- ============================================================================
-- Main validation function that runs all checks
function SuperGroupManager:RunDataValidation(autoFix)
	if not addon.RMB_DataReadyForUI then
		return false, "Data not ready for validation"
	end

	addon:DebugValidation(" Starting comprehensive data validation...")
	local startTime = debugprofilestop()
	local report = {
		weightSyncIssues = {},
		orphanedSettings = {},
		nameConflicts = {},
		totalIssues = 0,
		totalFixed = 0,
	}
	-- Run all validation checks
	self:ValidateWeightSynchronization(report, autoFix)
	self:ValidateOrphanedSettings(report, autoFix)
	self:ValidateSeparatedFamilyNames(report, autoFix)
	local endTime = debugprofilestop()
	addon:DebugValidation(string.format(" Completed in %.2fms - %d issues found, %d fixed",
		endTime - startTime, report.totalIssues, report.totalFixed))
	return true, report
end

-- ADD: Helper method to check if validation can run
function SuperGroupManager:CanRunValidation()
	if not addon.RMB_DataReadyForUI then
		return false, "Mount data is not ready yet"
	end

	if not addon.processedData then
		return false, "Processed data not available"
	end

	if not (addon.db and addon.db.profile) then
		return false, "Database not available"
	end

	return true, nil
end

-- ADD: Enhanced RefreshAllUIs method to handle validation fixes
function SuperGroupManager:RefreshAllUIs()
	addon:DebugSupergr(" Refreshing all UIs after validation fixes")
	-- Validate separated family integrity first
	self:ValidateSeparatedFamilyIntegrity()
	-- Refresh SuperGroup Management UIs
	self:PopulateSuperGroupManagementUI()
	self:PopulateFamilyAssignmentUI()
	-- Refresh main Family & Groups UI
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

	addon:DebugSupergr(" All UI refresh completed")
end

-- ADD: Method to clear validation report (useful for UI)
function SuperGroupManager:ClearValidationReport()
	self.lastValidationReport = nil
	addon:DebugSupergr(" Validation report cleared")
end

-- ADD: Method to get validation statistics for display
function SuperGroupManager:GetValidationStats()
	local canRun, reason = self:CanRunValidation()
	if not canRun then
		return {
			canRun = false,
			reason = reason,
			estimatedIssues = 0,
		}
	end

	-- Quick count of potential issues without full validation
	local potentialIssues = 0
	-- Count weight settings that might be problematic
	if addon.db.profile.groupWeights then
		for groupKey, weight in pairs(addon.db.profile.groupWeights) do
			local numWeight = tonumber(weight)
			if not numWeight or numWeight < 0 or numWeight > 6 then
				potentialIssues = potentialIssues + 1
			end
		end
	end

	-- Count separated mounts (potential for conflicts)
	if addon.db.profile.separatedMounts then
		potentialIssues = potentialIssues + addon:CountTableEntries(addon.db.profile.separatedMounts)
	end

	return {
		canRun = true,
		reason = nil,
		estimatedIssues = potentialIssues,
		hasReport = self.lastValidationReport ~= nil,
	}
end

-- ============================================================================
-- 1. WEIGHT SYNCHRONIZATION VALIDATION
-- ============================================================================
function SuperGroupManager:ValidateWeightSynchronization(report, autoFix)
	addon:DebugValidation(" Checking weight synchronization...")
	if not (addon.db and addon.db.profile and addon.db.profile.groupWeights) then
		return
	end

	local weightSettings = addon.db.profile.groupWeights
	local issuesFound = 0
	local issuesFixed = 0
	-- Check 1: Single-mount families where family weight ≠ mount weight
	addon:DebugValidation(" Checking single-mount family weight sync...")
	for familyName, _ in pairs(addon.processedData.familyToMountIDsMap or {}) do
		local isSingleMount, mountID = addon:IsSingleMountFamily(familyName)
		if isSingleMount and mountID then
			local familyWeight = weightSettings[familyName]
			local mountKey = "mount_" .. mountID
			local mountWeight = weightSettings[mountKey]
			-- Only check if both weights exist and differ
			if familyWeight and mountWeight and familyWeight ~= mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "single_mount_desync",
					familyName = familyName,
					mountID = mountID,
					familyWeight = familyWeight,
					mountWeight = mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Use the higher weight to avoid downgrading
					local syncWeight = math.max(familyWeight, mountWeight)
					weightSettings[familyName] = syncWeight
					weightSettings[mountKey] = syncWeight
					issue.fixedWeight = syncWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Fixed single-mount sync: " .. familyName .. " -> " .. syncWeight)
				end
			end
		end
	end

	-- Check 2: Separated families where separated family weight ≠ mount weight
	addon:DebugValidation(" Checking separated family weight sync...")
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local familyName = separationData.familyName
			local familyWeight = weightSettings[familyName]
			local mountKey = "mount_" .. mountID
			local mountWeight = weightSettings[mountKey]
			-- Only check if both weights exist and differ
			if familyWeight and mountWeight and familyWeight ~= mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "separated_mount_desync",
					familyName = familyName,
					mountID = tonumber(mountID),
					familyWeight = familyWeight,
					mountWeight = mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Use the higher weight to avoid downgrading
					local syncWeight = math.max(familyWeight, mountWeight)
					weightSettings[familyName] = syncWeight
					weightSettings[mountKey] = syncWeight
					issue.fixedWeight = syncWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Fixed separated family sync: " .. familyName .. " -> " .. syncWeight)
				end
			end
		end
	end

	-- Check 3: Invalid weight ranges (outside 0-6)
	addon:DebugValidation(" Checking weight ranges...")
	for groupKey, weight in pairs(weightSettings) do
		local numWeight = tonumber(weight)
		if not numWeight or numWeight < 0 or numWeight > 6 then
			issuesFound = issuesFound + 1
			local issue = {
				type = "invalid_weight_range",
				groupKey = groupKey,
				invalidWeight = weight,
			}
			table.insert(report.weightSyncIssues, issue)
			if autoFix then
				-- Fix to default weight (3 = Normal)
				weightSettings[groupKey] = 3
				issue.fixedWeight = 3
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				addon:DebugValidation(" Fixed invalid weight: " .. groupKey .. " " .. tostring(weight) .. " -> 3")
			end
		end
	end

	-- Check 4: Separated mounts missing family or mount weights
	addon:DebugValidation(" Checking missing separated mount weights...")
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local familyName = separationData.familyName
			local mountKey = "mount_" .. mountID
			local familyWeight = weightSettings[familyName]
			local mountWeight = weightSettings[mountKey]
			-- Check if either weight is missing
			if not familyWeight or not mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "missing_separated_weights",
					familyName = familyName,
					mountID = tonumber(mountID),
					missingFamilyWeight = not familyWeight,
					missingMountWeight = not mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Set both to default weight (3 = Normal) if missing
					local defaultWeight = 3
					if not familyWeight then
						weightSettings[familyName] = defaultWeight
					end

					if not mountWeight then
						weightSettings[mountKey] = defaultWeight
					end

					issue.fixedWeight = defaultWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Fixed missing separated weights: " .. familyName .. " -> " .. defaultWeight)
				end
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation(" Weight sync check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- ============================================================================
-- 2. ORPHANED SETTINGS CLEANUP
-- ============================================================================
function SuperGroupManager:ValidateOrphanedSettings(report, autoFix)
	addon:DebugValidation(" Checking for orphaned settings...")
	if not (addon.db and addon.db.profile) then
		return
	end

	local issuesFound = 0
	local issuesFixed = 0
	-- Get list of all valid families and mounts
	local validFamilies = {}
	local validMounts = {}
	-- Collect valid families from processed data
	if addon.processedData then
		-- From collected mounts
		if addon.processedData.allCollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
				validFamilies[mountInfo.familyName] = true
				validMounts["mount_" .. mountID] = true
			end
		end

		-- From uncollected mounts
		if addon.processedData.allUncollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
				validFamilies[mountInfo.familyName] = true
				validMounts["mount_" .. mountID] = true
			end
		end
	end

	-- Add separated families as valid
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			validFamilies[separationData.familyName] = true
			validMounts["mount_" .. mountID] = true
		end
	end

	-- Check 1: Orphaned weight settings
	addon:DebugValidation(" Checking orphaned weight settings...")
	if addon.db.profile.groupWeights then
		for groupKey, weight in pairs(addon.db.profile.groupWeights) do
			local isValid = false
			-- Check if it's a valid mount
			if groupKey:match("^mount_") then
				isValid = validMounts[groupKey]
			else
				-- Check if it's a valid family or supergroup
				isValid = validFamilies[groupKey] or
						(addon.processedData.superGroupMap and addon.processedData.superGroupMap[groupKey]) or
						(addon.processedData.dynamicSuperGroupMap and addon.processedData.dynamicSuperGroupMap[groupKey])
			end

			if not isValid then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_weight",
					groupKey = groupKey,
					weight = weight,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.groupWeights[groupKey] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Removed orphaned weight: " .. groupKey)
				end
			end
		end
	end

	-- Check 2: Orphaned supergroup overrides
	addon:DebugValidation(" Checking orphaned supergroup overrides...")
	if addon.db.profile.superGroupOverrides then
		for familyName, override in pairs(addon.db.profile.superGroupOverrides) do
			if not validFamilies[familyName] then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_supergroup_override",
					familyName = familyName,
					override = override,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.superGroupOverrides[familyName] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Removed orphaned supergroup override: " .. familyName)
				end
			end
		end
	end

	-- Check 3: Orphaned trait overrides
	addon:DebugValidation(" Checking orphaned trait overrides...")
	if addon.db.profile.traitOverrides then
		for familyName, traits in pairs(addon.db.profile.traitOverrides) do
			if not validFamilies[familyName] then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_trait_override",
					familyName = familyName,
					traits = traits,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.traitOverrides[familyName] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation(" Removed orphaned trait override: " .. familyName)
				end
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation(" Orphaned settings check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- ============================================================================
-- 3. SEPARATED FAMILY NAME CONFLICT VALIDATION
-- ============================================================================
function SuperGroupManager:ValidateSeparatedFamilyNames(report, autoFix)
	addon:DebugValidation(" Checking separated family name conflicts...")
	if not (addon.db and addon.db.profile and addon.db.profile.separatedMounts) then
		return
	end

	local issuesFound = 0
	local issuesFixed = 0
	-- Get all original family names
	local originalFamilies = {}
	if addon.processedData then
		if addon.processedData.allCollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
				-- Skip mounts that are separated
				if not addon.db.profile.separatedMounts[mountID] then
					originalFamilies[mountInfo.familyName] = true
				end
			end
		end

		if addon.processedData.allUncollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
				-- Skip mounts that are separated
				if not addon.db.profile.separatedMounts[mountID] then
					originalFamilies[mountInfo.familyName] = true
				end
			end
		end
	end

	-- Get all separated family names and check for conflicts
	local separatedFamilies = {}
	local duplicateSeparatedNames = {}
	for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
		local familyName = separationData.familyName
		-- Check 1: Conflict with original families
		if originalFamilies[familyName] then
			issuesFound = issuesFound + 1
			local issue = {
				type = "separated_conflicts_original",
				mountID = tonumber(mountID),
				conflictingName = familyName,
				originalFamily = separationData.originalFamily,
			}
			table.insert(report.nameConflicts, issue)
			if autoFix then
				-- Generate a unique name
				local newName = self:GenerateUniqueSeparatedFamilyName(familyName, originalFamilies, separatedFamilies)
				-- Update the separation data
				separationData.familyName = newName
				-- Update any weight settings
				if addon.db.profile.groupWeights then
					local oldWeight = addon.db.profile.groupWeights[familyName]
					if oldWeight then
						addon.db.profile.groupWeights[familyName] = nil
						addon.db.profile.groupWeights[newName] = oldWeight
					end
				end

				-- Update any supergroup overrides
				if addon.db.profile.superGroupOverrides then
					local oldOverride = addon.db.profile.superGroupOverrides[familyName]
					if oldOverride then
						addon.db.profile.superGroupOverrides[familyName] = nil
						addon.db.profile.superGroupOverrides[newName] = oldOverride
					end
				end

				-- Update any trait overrides
				if addon.db.profile.traitOverrides then
					local oldTraits = addon.db.profile.traitOverrides[familyName]
					if oldTraits then
						addon.db.profile.traitOverrides[familyName] = nil
						addon.db.profile.traitOverrides[newName] = oldTraits
					end
				end

				issue.newName = newName
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				separatedFamilies[newName] = true
				addon:DebugValidation(" Fixed name conflict: " .. familyName .. " -> " .. newName)
			end
		else
			-- Track this separated family name
			if separatedFamilies[familyName] then
				-- Check 2: Duplicate separated family names
				if not duplicateSeparatedNames[familyName] then
					duplicateSeparatedNames[familyName] = {}
				end

				table.insert(duplicateSeparatedNames[familyName], mountID)
			else
				separatedFamilies[familyName] = true
			end
		end
	end

	-- Handle duplicate separated family names
	for familyName, mountIDs in pairs(duplicateSeparatedNames) do
		-- Keep the first mount, rename the others
		for i = 2, #mountIDs do
			local mountID = mountIDs[i]
			issuesFound = issuesFound + 1
			local issue = {
				type = "duplicate_separated_names",
				mountID = tonumber(mountID),
				duplicateName = familyName,
			}
			table.insert(report.nameConflicts, issue)
			if autoFix then
				local separationData = addon.db.profile.separatedMounts[mountID]
				local newName = self:GenerateUniqueSeparatedFamilyName(familyName, originalFamilies, separatedFamilies)
				-- Update separation data
				separationData.familyName = newName
				-- Update settings (same as above)
				if addon.db.profile.groupWeights then
					local oldWeight = addon.db.profile.groupWeights[familyName]
					if oldWeight then
						addon.db.profile.groupWeights[newName] = oldWeight
					end
				end

				issue.newName = newName
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				separatedFamilies[newName] = true
				addon:DebugValidation(" Fixed duplicate separated name: " .. familyName .. " -> " .. newName)
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation(" Name conflict check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- Helper function to generate unique separated family names
function SuperGroupManager:GenerateUniqueSeparatedFamilyName(baseName, originalFamilies, separatedFamilies)
	local newName = baseName .. "_Separated"
	local counter = 1
	while originalFamilies[newName] or separatedFamilies[newName] do
		newName = baseName .. "_Separated_" .. counter
		counter = counter + 1
	end

	return newName
end

-- ============================================================================
-- VALIDATION REPORT FORMATTING
-- ============================================================================
function SuperGroupManager:FormatValidationReport(report)
	local lines = {}
	table.insert(lines, "|cffffd700=== Data Validation Report ===|r")
	table.insert(lines, string.format("Total Issues Found: %d", report.totalIssues))
	table.insert(lines, string.format("Total Issues Fixed: %d", report.totalFixed))
	table.insert(lines, "")
	-- Weight Sync Issues
	if #report.weightSyncIssues > 0 then
		table.insert(lines, "|cff00ff00Weight Synchronization Issues:|r")
		for _, issue in ipairs(report.weightSyncIssues) do
			if issue.type == "single_mount_desync" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Single-mount family '%s' weight mismatch: Family=%d, Mount=%d",
					status, issue.familyName, issue.familyWeight, issue.mountWeight))
				if issue.fixed then
					table.insert(lines, string.format("    → Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "separated_mount_desync" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Separated family '%s' weight mismatch: Family=%d, Mount=%d",
					status, issue.familyName, issue.familyWeight, issue.mountWeight))
				if issue.fixed then
					table.insert(lines, string.format("    → Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "invalid_weight_range" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Invalid weight for '%s': %s",
					status, issue.groupKey, tostring(issue.invalidWeight)))
				if issue.fixed then
					table.insert(lines, string.format("    → Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "missing_separated_weights" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				local missing = {}
				if issue.missingFamilyWeight then table.insert(missing, "family") end

				if issue.missingMountWeight then table.insert(missing, "mount") end

				table.insert(lines, string.format("  %s Missing %s weights for separated family '%s'",
					status, table.concat(missing, " and "), issue.familyName))
				if issue.fixed then
					table.insert(lines, string.format("    → Set to weight %d", issue.fixedWeight))
				end
			end
		end

		table.insert(lines, "")
	end

	-- Orphaned Settings
	if #report.orphanedSettings > 0 then
		table.insert(lines, "|cff00ff00Orphaned Settings:|r")
		for _, issue in ipairs(report.orphanedSettings) do
			local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
			if issue.type == "orphaned_weight" then
				table.insert(lines, string.format("  %s Orphaned weight setting: '%s' = %s",
					status, issue.groupKey, tostring(issue.weight)))
			elseif issue.type == "orphaned_supergroup_override" then
				table.insert(lines, string.format("  %s Orphaned supergroup override: '%s' → %s",
					status, issue.familyName, tostring(issue.override)))
			elseif issue.type == "orphaned_trait_override" then
				table.insert(lines, string.format("  %s Orphaned trait override: '%s'",
					status, issue.familyName))
			end
		end

		table.insert(lines, "")
	end

	-- Name Conflicts
	if #report.nameConflicts > 0 then
		table.insert(lines, "|cff00ff00Name Conflicts:|r")
		for _, issue in ipairs(report.nameConflicts) do
			local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
			if issue.type == "separated_conflicts_original" then
				table.insert(lines, string.format("  %s Separated family name conflicts with original: '%s'",
					status, issue.conflictingName))
				if issue.fixed then
					table.insert(lines, string.format("    → Renamed to '%s'", issue.newName))
				end
			elseif issue.type == "duplicate_separated_names" then
				table.insert(lines, string.format("  %s Duplicate separated family name: '%s'",
					status, issue.duplicateName))
				if issue.fixed then
					table.insert(lines, string.format("    → Renamed to '%s'", issue.newName))
				end
			end
		end

		table.insert(lines, "")
	end

	if report.totalIssues == 0 then
		table.insert(lines, "|cff00ff00No issues found! Your data is clean.|r")
	end

	return table.concat(lines, "\n")
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Initialize SuperGroup Manager when addon loads
function addon:InitializeSuperGroupManager()
	if not self.SuperGroupManager then
		addon:DebugSupergr(" ERROR - SuperGroupManager not found!")
		return
	end

	self.SuperGroupManager:Initialize()
	addon:DebugSupergr(" Integration complete")
end

addon:DebugCore("SuperGroupManager.lua END.")
