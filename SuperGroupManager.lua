-- SuperGroupManager.lua - Supergroup Customization Interface
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: SuperGroupManager.lua START.")
-- ============================================================================
-- SUPERGROUP MANAGER CLASS
-- ============================================================================
local SuperGroupManager = {}
addon.SuperGroupManager = SuperGroupManager
-- Initialize the SuperGroup Manager
function SuperGroupManager:Initialize()
	print("RMB_SUPERGROUP: Initializing SuperGroup Manager...")
	-- UI state for the manager
	self.uiState = {
		currentPage = 1,
		searchTerm = "",
		selectedFamilies = {},
		pendingSummon = { source = nil, target = nil },
	}
	-- Initialize dynamic content references
	self.existingListArgsRef = {}
	self.familyListArgsRef = {}
	-- Populate initial content (will be empty until data is ready)
	self:PopulateExistingSuperGroupsList()
	self:PopulateFamilyAssignmentList()
	print("RMB_SUPERGROUP: SuperGroup Manager initialized")
end

-- References for dynamic UI content (same pattern as Family & Groups)
SuperGroupManager.existingListArgsRef = {}
SuperGroupManager.familyListArgsRef = {}
-- UI population functions (similar to PopulateFamilyManagementUI)
function SuperGroupManager:PopulateExistingSuperGroupsList()
	print("RMB_SUPERGROUP: Populating existing supergroups list")
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
	print("RMB_SUPERGROUP: Populating family assignment list")
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
							print("RMB: " .. message)
							-- Refresh the list to show changes
							addon.SuperGroupManager:PopulateFamilyAssignmentList()
						else
							print("RMB Error: " .. message)
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
						print("RMB_PREVIEW: No mount available to preview from this family")
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
	print("RMB_SUPERGROUP: PopulateSuperGroupManagementUI called")
	if not addon.sgMgmtArgsRef then
		print("RMB_SUPERGROUP_ERROR: addon.sgMgmtArgsRef is nil! Options.lua problem.")
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
	print(string.format("RMB_SUPERGROUP: UI build took %.2fms", endTime - startTime))
end

function SuperGroupManager:PopulateFamilyAssignmentUI()
	print("RMB_SUPERGROUP: PopulateFamilyAssignmentUI called")
	if not addon.sgFamilyArgsRef then
		print("RMB_SUPERGROUP_ERROR: addon.sgFamilyArgsRef is nil! Options.lua problem.")
		return
	end

	local startTime = debugprofilestop()
	-- Build new UI arguments
	local newArgs = self:BuildFamilyAssignmentArgs()
	-- Update the options table
	wipe(addon.sgFamilyArgsRef)
	for k, v in pairs(newArgs) do
		addon.sgFamilyArgsRef[k] = v
	end

	-- Notify AceConfig of changes
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
	end

	local endTime = debugprofilestop()
	print(string.format("RMB_SUPERGROUP: Family assignment UI build took %.2fms", endTime - startTime))
end

-- Build supergroup management page content
function SuperGroupManager:BuildSuperGroupManagementArgs()
	print("RMB_SUPERGROUP: BuildSuperGroupManagementArgs called")
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
	args.create_name = {
		order = order,
		type = "input",
		name = "Supergroup Name",
		desc = "Internal name for the supergroup (no spaces, used for identification)",
		get = function() return self.pendingCreateName or "" end,
		set = function(info, value) self.pendingCreateName = value end,
		width = 1.0,
	}
	order = order + 1
	args.create_display = {
		order = order,
		type = "input",
		name = "Display Name",
		desc = "Friendly name shown in the interface",
		get = function() return self.pendingCreateDisplay or "" end,
		set = function(info, value) self.pendingCreateDisplay = value end,
		width = 1.0,
	}
	order = order + 1
	args.create_button = {
		order = order,
		type = "execute",
		name = "Create Supergroup",
		desc = "Create the new supergroup",
		func = function()
			local name = self.pendingCreateName or ""
			local display = self.pendingCreateDisplay or ""
			local success, message = self:CreateSuperGroup(name, display)
			if success then
				self.pendingCreateName = ""
				self.pendingCreateDisplay = ""
				print("RMB: " .. message)
				-- Refresh UI
				self:PopulateSuperGroupManagementUI()
			else
				print("RMB Error: " .. message)
			end
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
			width = sgInfo.isRenamed and not sgInfo.isCustom and 1.8 or 1.2, -- Wider if showing original name
		}
		-- Rename input and buttons
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

			args[keyBase .. "_delete"] = {
				order = order + 0.3,
				type = "execute",
				name = "Delete",
				desc = "Delete this supergroup (families will become standalone)",
				func = function()
					StaticPopup_Show("RMB_DELETE_SUPERGROUP_CONFIRM", sgInfo.displayName, nil, sgInfo.name)
				end,
				width = 0.4,
			}
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

	print("RMB_SUPERGROUP: Built management UI with " .. #allSGs .. " supergroups")
	return args
end

-- Build family assignment page content
function SuperGroupManager:BuildFamilyAssignmentArgs()
	print("RMB_SUPERGROUP: BuildFamilyAssignmentArgs called")
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

	-- Pagination
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

	-- Family entries
	args.family_header = {
		order = order,
		type = "header",
		name = "Family Assignments (Showing " .. math.min(itemsPerPage, totalItems) .. " of " .. totalItems .. ")",
	}
	order = order + 1
	for i = startIndex, endIndex do
		local familyInfo = filteredFamilies[i]
		if familyInfo then
			local keyBase = "family_" .. familyInfo.familyName:gsub("[^%w]", "_")
			-- Family name and info
			args[keyBase .. "_name"] = {
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
			-- Supergroup assignment dropdown
			args[keyBase .. "_assign"] = {
				order = order + 0.1,
				type = "select",
				name = "",
				desc = "Assign to supergroup (* indicates override from original)",
				values = function() return self:GetAvailableSuperGroups() end,
				get = function() return familyInfo.currentSuperGroup or "<Standalone>" end,
				set = function(info, value)
					local success, message = self:AssignFamilyToSuperGroup(familyInfo.familyName, value)
					if success then
						print("RMB: " .. message)
						self:PopulateFamilyAssignmentUI()
					else
						print("RMB Error: " .. message)
					end
				end,
				width = 1.0,
			}
			-- Preview button
			args[keyBase .. "_preview"] = {
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
						print("RMB_PREVIEW: No mount available to preview from this family")
					end
				end,
				width = 0.2,
			}
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

	-- Pagination controls
	if totalPages > 1 then
		args.pagination_prev = {
			order = order,
			type = "execute",
			name = "<< Previous",
			desc = "Previous page",
			func = function()
				if currentPage > 1 then
					self.uiState.currentPage = currentPage - 1
					self:PopulateFamilyAssignmentUI()
				end
			end,
			disabled = function() return currentPage <= 1 end,
			width = 0.5,
		}
		args.pagination_next = {
			order = order + 0.1,
			type = "execute",
			name = "Next >>",
			desc = "Next page",
			func = function()
				if currentPage < totalPages then
					self.uiState.currentPage = currentPage + 1
					self:PopulateFamilyAssignmentUI()
				end
			end,
			disabled = function() return currentPage >= totalPages end,
			width = 0.5,
		}
	end

	print("RMB_SUPERGROUP: Built family assignment UI with " .. #filteredFamilies .. " families")
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
		print("RMB_SUPERGROUP: Data not ready for GetAllSuperGroups")
		return allSuperGroups
	end

	print("RMB_SUPERGROUP: GetAllSuperGroups - Data is ready, processing...")
	-- Add original supergroups (if not deleted)
	if addon.processedData.superGroupMap then
		print("RMB_SUPERGROUP: Found " ..
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
				print("RMB_SUPERGROUP: Added original supergroup: " .. sgName)
			else
				print("RMB_SUPERGROUP: Skipped deleted supergroup: " .. sgName)
			end
		end
	else
		print("RMB_SUPERGROUP: No original supergroups found in processedData")
	end

	-- Add custom supergroups
	if addon.db and addon.db.profile and addon.db.profile.superGroupDefinitions then
		print("RMB_SUPERGROUP: Found " ..
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
				print("RMB_SUPERGROUP: Added custom supergroup: " .. sgName)
			end
		end
	else
		print("RMB_SUPERGROUP: No custom supergroup definitions found")
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
				print("RMB_SUPERGROUP: Added deleted supergroup for restore: " .. sgName)
			end
		end
	end

	-- Sort alphabetically
	table.sort(allSuperGroups, function(a, b)
		return a.displayName < b.displayName
	end)
	print("RMB_SUPERGROUP: GetAllSuperGroups returning " .. #allSuperGroups .. " supergroups")
	return allSuperGroups
end

-- Create new supergroup
function SuperGroupManager:CreateSuperGroup(name, displayName)
	if not name or name:trim() == "" then
		return false, "Supergroup name cannot be empty"
	end

	if not displayName or displayName:trim() == "" then
		displayName = name
	end

	-- Check for name conflicts
	if self:SuperGroupExists(name) then
		return false, "A supergroup with this name already exists"
	end

	-- Initialize database structures if needed
	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	-- Create the supergroup
	addon.db.profile.superGroupDefinitions[name] = {
		displayName = displayName,
		isCustom = true,
		isRenamed = false,
	}
	print("RMB_SUPERGROUP: Created custom supergroup: " .. name .. " (" .. displayName .. ")")
	-- Trigger rebuild
	addon:RebuildMountGrouping()
	return true, "Supergroup created successfully"
end

-- Rename supergroup
function SuperGroupManager:RenameSuperGroup(sgName, newDisplayName)
	if not sgName or not newDisplayName or newDisplayName:trim() == "" then
		return false, "Display name cannot be empty"
	end

	-- Get the original name for comparison
	local originalName = self:GetOriginalSuperGroupName(sgName)
	local trimmedNewName = newDisplayName:trim()
	-- Initialize database structures if needed
	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	-- Check if we're renaming back to the original name
	if trimmedNewName == originalName then
		-- Renaming back to original - remove any custom definition
		if addon.db.profile.superGroupDefinitions[sgName] then
			-- If it's a custom supergroup, keep the definition but clear rename flag
			if addon.db.profile.superGroupDefinitions[sgName].isCustom then
				addon.db.profile.superGroupDefinitions[sgName].displayName = originalName
				addon.db.profile.superGroupDefinitions[sgName].isRenamed = false
			else
				-- For original supergroups, remove the definition entirely
				addon.db.profile.superGroupDefinitions[sgName] = nil
			end
		end

		print("RMB_SUPERGROUP: Restored original name for supergroup: " .. sgName)
	else
		-- Renaming to a different name - update or create definition
		if not addon.db.profile.superGroupDefinitions[sgName] then
			addon.db.profile.superGroupDefinitions[sgName] = {}
		end

		addon.db.profile.superGroupDefinitions[sgName].displayName = trimmedNewName
		addon.db.profile.superGroupDefinitions[sgName].isRenamed = true
		print("RMB_SUPERGROUP: Renamed supergroup: " .. sgName .. " to " .. trimmedNewName)
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

	print("RMB_SUPERGROUP: Restored original name for: " .. sgName)
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

		print("RMB_SUPERGROUP: Deleted custom supergroup: " .. sgName)
	else
		-- For original supergroups, mark as deleted
		addon.db.profile.deletedSuperGroups[sgName] = true
		print("RMB_SUPERGROUP: Marked original supergroup as deleted: " .. sgName)
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
			print("RMB_SUPERGROUP: Cleared assignments for " .. #clearedFamilies .. " families")
		end
	end

	-- Trigger rebuild
	addon:RebuildMountGrouping()
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
		print("RMB_SUPERGROUP: Cleaned up rename data during restoration of: " .. sgName)
	end

	print("RMB_SUPERGROUP: Restored supergroup: " .. sgName)
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
		print("RMB_SUPERGROUP: Merged " .. sourceSG .. " into " .. targetSG .. " (" .. movedFamilies .. " families moved)")
		return true, "Merged " .. movedFamilies .. " families from " .. sourceSG .. " to " .. targetSG
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
		print("RMB_SUPERGROUP: Data not ready for GetAllFamilyAssignments")
		return familyAssignments
	end

	print("RMB_SUPERGROUP: GetAllFamilyAssignments - Data is ready, processing...")
	-- Get all unique families from collected mounts
	local allFamilies = {}
	if addon.processedData.allCollectedMountFamilyInfo then
		for _, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
			allFamilies[mountInfo.familyName] = true
		end

		print("RMB_SUPERGROUP: Found families from collected mounts: " .. addon:CountTableEntries(allFamilies))
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

		print("RMB_SUPERGROUP: Added " .. uncollectedFamilyCount .. " new families from uncollected mounts")
	end

	print("RMB_SUPERGROUP: Total unique families to process: " .. addon:CountTableEntries(allFamilies))
	-- Build assignment data for each family
	for familyName, _ in pairs(allFamilies) do
		local currentSG = addon:GetEffectiveSuperGroup(familyName)
		local originalSG = addon:GetDynamicSuperGroup(familyName) -- Before overrides
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
				currentSuperGroup = currentSG,
				originalSuperGroup = originalSG,
				isOverridden = (currentSG ~= originalSG),
				collectedCount = collectedCount,
				uncollectedCount = uncollectedCount,
				totalCount = collectedCount + uncollectedCount,
			})
		end
	end

	-- Sort alphabetically
	table.sort(familyAssignments, function(a, b)
		return a.familyName < b.familyName
	end)
	print("RMB_SUPERGROUP: GetAllFamilyAssignments returning " .. #familyAssignments .. " family assignments")
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

	-- Get original assignment to determine if this is an override
	local originalSG = addon:GetDynamicSuperGroup(familyName)
	if targetSG == nil or targetSG == "" or targetSG == "<Standalone>" then
		-- Assign to standalone
		if originalSG == nil then
			-- Already standalone originally, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
		else
			-- Force to standalone
			addon.db.profile.superGroupOverrides[familyName] = false
		end

		print("RMB_SUPERGROUP: Assigned " .. familyName .. " to standalone")
	else
		-- Assign to specific supergroup
		if targetSG == originalSG then
			-- Same as original, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
		else
			-- Override to new supergroup
			addon.db.profile.superGroupOverrides[familyName] = targetSG
		end

		print("RMB_SUPERGROUP: Assigned " .. familyName .. " to " .. targetSG)
	end

	-- Trigger rebuild
	addon:RebuildMountGrouping()
	return true, "Family assignment updated"
end

-- Get available supergroups for assignment dropdown
function SuperGroupManager:GetAvailableSuperGroups()
	local availableSGs = {
		["<Standalone>"] = "Standalone (No Supergroup)",
	}
	-- Add all existing supergroups
	local allSGs = self:GetAllSuperGroups()
	for _, sgInfo in ipairs(allSGs) do
		if not sgInfo.isDeleted then
			availableSGs[sgInfo.name] = sgInfo.displayName
		end
	end

	return availableSGs
end

-- ============================================================================
-- IMPORT/EXPORT OPERATIONS
-- ============================================================================
-- Export current supergroup configuration
function SuperGroupManager:ExportConfiguration()
	local config = {
		version = "1.0",
		timestamp = time(),
		superGroupOverrides = {},
		superGroupDefinitions = {},
		deletedSuperGroups = {},
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

	-- Validate configuration
	if not config.superGroupOverrides or not config.superGroupDefinitions or not config.deletedSuperGroups then
		return false, "Configuration is missing required data"
	end

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

	local importStats = { overrides = 0, definitions = 0, deletions = 0 }
	if importMode == "replace" then
		-- Clear existing configuration
		wipe(addon.db.profile.superGroupOverrides)
		wipe(addon.db.profile.superGroupDefinitions)
		wipe(addon.db.profile.deletedSuperGroups)
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

	-- Trigger rebuild
	addon:RebuildMountGrouping()
	local message = string.format("Imported %d family assignments, %d supergroup definitions, and %d deletions",
		importStats.overrides, importStats.definitions, importStats.deletions)
	print("RMB_SUPERGROUP: " .. message)
	return true, message
end

-- Reset to defaults (clear all customizations)
function SuperGroupManager:ResetToDefaults(resetType)
	resetType = resetType or "all"
	if not addon.db or not addon.db.profile then
		return false, "Database not available"
	end

	local resetStats = { overrides = 0, definitions = 0, deletions = 0 }
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
		-- Clear all customizations including renames
		if addon.db.profile.superGroupDefinitions then
			wipe(addon.db.profile.superGroupDefinitions)
		end
	end

	-- Trigger rebuild
	addon:RebuildMountGrouping()
	local message = string.format(
		"Reset %d family assignments, %d custom supergroups, and restored %d deleted supergroups",
		resetStats.overrides, resetStats.definitions, resetStats.deletions)
	print("RMB_SUPERGROUP: " .. message)
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
-- INITIALIZATION
-- ============================================================================
-- Initialize SuperGroup Manager when addon loads
function addon:InitializeSuperGroupManager()
	if not self.SuperGroupManager then
		print("RMB_SUPERGROUP: ERROR - SuperGroupManager not found!")
		return
	end

	self.SuperGroupManager:Initialize()
	print("RMB_SUPERGROUP: Integration complete")
end

print("RMB_DEBUG: SuperGroupManager.lua END.")
