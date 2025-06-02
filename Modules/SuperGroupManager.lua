-- SuperGroupManager.lua - Supergroup Creation, Editing, and Management
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
	-- ADDED: Refresh flag system for popup callbacks
	self.needsRefresh = false
	self.refreshTimer = nil
	-- Initialize dynamic content references
	self.existingListArgsRef = {}
	-- Start refresh polling
	self:StartRefreshPolling()
	-- Populate initial content (will be empty until data is ready)
	self:PopulateExistingSuperGroupsList()
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

-- References for dynamic UI content (same pattern as Mount List)
SuperGroupManager.existingListArgsRef = {}
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
	-- Update the options table (same pattern as Mount List)
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
					name = " |cffff9900->|r ",
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
							if addon.FamilyAssignment then
								addon.FamilyAssignment:PopulateFamilyAssignmentUI()
							end

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
		addon:DebugSupergr(" Found " .. addon:CountTableEntries(addon.processedData.superGroupMap) .. " original supergroups")
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
	addon:DebugSupergr(" SuperGroupManager: Refreshing all UIs")
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

	addon:DebugSupergr(" SuperGroupManager: All UI refresh completed")
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
	addon:DebugSupergr(" SuperGroupManager integration complete")
end

addon:DebugCore("SuperGroupManager.lua END.")
