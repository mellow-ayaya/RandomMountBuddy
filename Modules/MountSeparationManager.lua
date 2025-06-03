-- MountSeparationManager.lua
local addonName, addonTable = ...
local addon = RandomMountBuddy
local MountSeparationManager = {}
addon.MountSeparationManager = MountSeparationManager
function MountSeparationManager:Initialize()
	addon:DebugSeparation("Initializing Mount Separation Manager...")
	-- UI state
	self.uiState = {
		searchTerm = "",
		currentPage = 1,
		itemsPerPage = 14,
		selectedMountForSeparation = "",
		customSeparationName = "",
	}
	self.separationArgsRef = {}
end

-- Separate a mount from its family
function MountSeparationManager:SeparateMount(mountID, customName)
	if not mountID then
		return false, "Invalid mount ID"
	end

	-- Get current mount info
	local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID] or
			addon.processedData.allUncollectedMountFamilyInfo[mountID]
	if not mountInfo then
		return false, "Mount not found"
	end

	-- Check if already separated
	if addon.db.profile.separatedMounts and addon.db.profile.separatedMounts[mountID] then
		return false, "Mount is already separated"
	end

	local originalFamily = mountInfo.familyName
	local mountName = mountInfo.name or ("Mount " .. mountID)
	-- Generate new family name - FIX: Better handling of blank names
	local newFamilyName
	if customName and customName:trim() ~= "" then
		newFamilyName = self:SanitizeFamilyName(customName:trim())
	else
		-- Auto-generate from mount name
		newFamilyName = self:SanitizeFamilyName(mountName)
	end

	-- Check for name conflicts and make unique if needed
	local baseName = newFamilyName
	local counter = 1
	while self:DoesFamilyNameExist(newFamilyName) do
		newFamilyName = baseName .. " (" .. counter .. ")"
		counter = counter + 1
	end

	-- Initialize database if needed
	if not addon.db.profile.separatedMounts then
		addon.db.profile.separatedMounts = {}
	end

	-- Store separation data
	addon.db.profile.separatedMounts[mountID] = {
		familyName = newFamilyName,
		originalFamily = originalFamily,
		customTraits = {}, -- Will be populated below
		separatedAt = time(),
	}
	-- FIX: Preserve original traits from the mount
	local originalTraits = {}
	if mountInfo.traits then
		-- Copy original traits
		for traitName, traitValue in pairs(mountInfo.traits) do
			originalTraits[traitName] = traitValue
		end

		addon:DebugSeparation("Preserved original traits for mount " .. mountID .. ": " ..
			table.concat({ "hasMinorArmor=" .. tostring(originalTraits.hasMinorArmor or false),
				"hasMajorArmor=" .. tostring(originalTraits.hasMajorArmor or false),
				"hasModelVariant=" .. tostring(originalTraits.hasModelVariant or false),
				"isUniqueEffect=" .. tostring(originalTraits.isUniqueEffect or false) }, ", "))
	end

	-- Store the original traits in the separation data for reference
	addon.db.profile.separatedMounts[mountID].originalTraits = originalTraits
	-- FIX: Initialize weights for the new family and mount
	-- Initialize database structures if needed
	if not addon.db.profile.groupWeights then
		addon.db.profile.groupWeights = {}
	end

	-- Get the mount's current weight or use a default
	local mountKey = "mount_" .. mountID
	local currentMountWeight = addon.db.profile.groupWeights[mountKey] or 3 -- Default to "Normal" (3)
	-- Set both family and mount weights to ensure they're in sync
	addon.db.profile.groupWeights[newFamilyName] = currentMountWeight
	addon.db.profile.groupWeights[mountKey] = currentMountWeight
	addon:DebugSeparation("Set initial weights - Family '" ..
		newFamilyName .. "' and Mount '" .. mountKey .. "' both set to " .. currentMountWeight)
	addon:DebugSeparation("Separated mount '" ..
		mountName .. "' from family '" .. originalFamily .. "' into new family '" .. newFamilyName .. "'")
	-- FIX: Trigger complete data reinitialization instead of just rebuild
	addon.lastProcessingEventName = "mount_separation"
	addon:InitializeProcessedData()
	addon.lastProcessingEventName = nil
	-- ENHANCED: Notify SuperGroupManager of the change
	if addon.SuperGroupManager then
		addon:DebugSeparation("Notifying SuperGroupManager of separation")
		-- Use a brief delay to ensure data processing is complete
		C_Timer.After(0.1, function()
			addon.SuperGroupManager:RefreshAllUIs()
		end)
	end

	return true, "Mount separated successfully into family: " .. newFamilyName
end

-- Reunite a separated mount with its original family
function MountSeparationManager:ReuniteSeparatedMount(mountID)
	if not (addon.db.profile.separatedMounts and addon.db.profile.separatedMounts[mountID]) then
		return false, "Mount is not separated"
	end

	local separationData = addon.db.profile.separatedMounts[mountID]
	local originalFamily = separationData.originalFamily
	local separatedFamilyName = separationData.familyName
	-- ENHANCED: Clear any supergroup assignments for the separated family
	if addon.db.profile.superGroupOverrides and addon.db.profile.superGroupOverrides[separatedFamilyName] then
		addon:DebugSeparation("Clearing supergroup override for reunited family: " .. separatedFamilyName)
		addon.db.profile.superGroupOverrides[separatedFamilyName] = nil
	end

	-- ENHANCED: Clear weight settings for the separated family (keep mount weight)
	if addon.db.profile.groupWeights and addon.db.profile.groupWeights[separatedFamilyName] then
		addon:DebugSeparation("Clearing weight for separated family: " .. separatedFamilyName)
		addon.db.profile.groupWeights[separatedFamilyName] = nil
	end

	-- Remove separation data
	addon.db.profile.separatedMounts[mountID] = nil
	-- Clean up empty table if needed
	if not next(addon.db.profile.separatedMounts) then
		addon.db.profile.separatedMounts = {}
	end

	addon:DebugSeparation("Reunited mount " .. mountID .. " with original family '" .. originalFamily .. "'")
	-- FIX: Trigger complete data reinitialization instead of just rebuild
	addon.lastProcessingEventName = "mount_reunification"
	addon:InitializeProcessedData()
	addon.lastProcessingEventName = nil
	-- ENHANCED: Notify SuperGroupManager of the change
	if addon.SuperGroupManager then
		addon:DebugSeparation("Notifying SuperGroupManager of reunification")
		-- Use a brief delay to ensure data processing is complete
		C_Timer.After(0.1, function()
			addon.SuperGroupManager:RefreshAllUIs()
		end)
	end

	return true, "Mount reunited with original family: " .. originalFamily
end

-- ENHANCED: Add helper method to check if a family is from a separated mount
function MountSeparationManager:IsSeparatedFamily(familyName)
	if not (addon.db and addon.db.profile and addon.db.profile.separatedMounts) then
		return false, nil
	end

	for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
		if separationData.familyName == familyName then
			return true, tonumber(mountID)
		end
	end

	return false, nil
end

-- ENHANCED: Add method to get separated family info for SuperGroupManager
function MountSeparationManager:GetSeparatedFamilyInfo(familyName)
	local isSeparated, mountID = self:IsSeparatedFamily(familyName)
	if not isSeparated then
		return nil
	end

	local separationData = addon.db.profile.separatedMounts[tostring(mountID)]
	if not separationData then
		return nil
	end

	return {
		mountID = mountID,
		originalFamily = separationData.originalFamily,
		separatedAt = separationData.separatedAt,
		originalTraits = separationData.originalTraits,
		customTraits = separationData.customTraits,
	}
end

-- Get all separable mounts (mounts in families with more than 1 mount)
function MountSeparationManager:GetSeparableMounts()
	local separableMounts = {}
	if not addon.processedData then
		return separableMounts
	end

	-- Check collected mounts
	for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo or {}) do
		local familyName = mountInfo.familyName
		local familySize = #(addon.processedData.familyToMountIDsMap[familyName] or {})
		-- Only include mounts from families with more than 1 mount
		if familySize > 1 and not (addon.db.profile.separatedMounts and addon.db.profile.separatedMounts[mountID]) then
			table.insert(separableMounts, {
				mountID = mountID,
				mountName = mountInfo.name or ("Mount " .. mountID),
				familyName = familyName,
				familySize = familySize,
				isCollected = true,
			})
		end
	end

	-- Check uncollected mounts if enabled
	if addon:GetSetting("showUncollectedMounts") then
		for mountID, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo or {}) do
			local familyName = mountInfo.familyName
			local familySize = (#(addon.processedData.familyToMountIDsMap[familyName] or {}) +
				#(addon.processedData.familyToUncollectedMountIDsMap[familyName] or {}))
			if familySize > 1 and not (addon.db.profile.separatedMounts and addon.db.profile.separatedMounts[mountID]) then
				table.insert(separableMounts, {
					mountID = mountID,
					mountName = mountInfo.name or ("Mount " .. mountID),
					familyName = familyName,
					familySize = familySize,
					isCollected = false,
				})
			end
		end
	end

	-- Sort alphabetically by mount name, then by family name
	table.sort(separableMounts, function(a, b)
		if a.mountName == b.mountName then
			return a.familyName < b.familyName
		end

		return a.mountName < b.mountName
	end)
	return separableMounts
end

-- Get filtered separable mounts based on search
function MountSeparationManager:GetFilteredSeparableMounts()
	local allMounts = self:GetSeparableMounts()
	local searchTerm = self.uiState.searchTerm or ""
	if searchTerm == "" then
		return allMounts
	end

	local filteredMounts = {}
	local lowerSearchTerm = searchTerm:lower()
	for _, mountData in ipairs(allMounts) do
		local mountNameLower = mountData.mountName:lower()
		local familyNameLower = mountData.familyName:lower()
		if mountNameLower:find(lowerSearchTerm, 1, true) or familyNameLower:find(lowerSearchTerm, 1, true) then
			table.insert(filteredMounts, mountData)
		end
	end

	return filteredMounts
end

-- Get all currently separated mounts
function MountSeparationManager:GetSeparatedMounts()
	local separatedMounts = {}
	if not (addon.db.profile.separatedMounts) then
		return separatedMounts
	end

	for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
		local mountIDNum = tonumber(mountID)
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountIDNum] or
				addon.processedData.allUncollectedMountFamilyInfo[mountIDNum]
		if mountInfo then
			table.insert(separatedMounts, {
				mountID = mountIDNum,
				mountName = mountInfo.name or ("Mount " .. mountID),
				newFamilyName = separationData.familyName,
				originalFamily = separationData.originalFamily,
				separatedAt = separationData.separatedAt,
				isCollected = addon.processedData.allCollectedMountFamilyInfo[mountIDNum] ~= nil,
			})
		end
	end

	-- Sort by mount name alphabetically
	table.sort(separatedMounts, function(a, b)
		return a.mountName < b.mountName
	end)
	return separatedMounts
end

-- Pagination functions
function MountSeparationManager:GetCurrentPage()
	return self.uiState.currentPage or 1
end

function MountSeparationManager:SetCurrentPage(page)
	self.uiState.currentPage = page or 1
end

function MountSeparationManager:GetItemsPerPage()
	return self.uiState.itemsPerPage or 14
end

function MountSeparationManager:GoToPage(pageNumber)
	local filteredMounts = self:GetFilteredSeparableMounts()
	local totalPages = math.max(1, math.ceil(#filteredMounts / self:GetItemsPerPage()))
	local targetPage = tonumber(pageNumber)
	if targetPage and targetPage >= 1 and targetPage <= totalPages then
		self:SetCurrentPage(targetPage)
		self:PopulateSeparationManagementUI()
		addon:DebugSeparation("Jumped to page " .. targetPage)
	end
end

function MountSeparationManager:NextPage()
	local filteredMounts = self:GetFilteredSeparableMounts()
	local totalPages = math.max(1, math.ceil(#filteredMounts / self:GetItemsPerPage()))
	local currentPage = self:GetCurrentPage()
	if currentPage < totalPages then
		self:SetCurrentPage(currentPage + 1)
		self:PopulateSeparationManagementUI()
	end
end

function MountSeparationManager:PrevPage()
	local currentPage = self:GetCurrentPage()
	if currentPage > 1 then
		self:SetCurrentPage(currentPage - 1)
		self:PopulateSeparationManagementUI()
	end
end

-- Helper functions
function MountSeparationManager:SanitizeFamilyName(name)
	if not name then return "" end

	local sanitized = name:trim()
	sanitized = sanitized:gsub("[^%w%s%-_%(%)%[%]]", "") -- Allow letters, numbers, spaces, hyphens, underscores, parentheses, brackets
	return sanitized
end

function MountSeparationManager:DoesFamilyNameExist(familyName)
	-- Check existing families
	if addon.processedData.familyToMountIDsMap[familyName] then
		return true
	end

	-- Check separated mount families
	if addon.db.profile.separatedMounts then
		for _, separationData in pairs(addon.db.profile.separatedMounts) do
			if separationData.familyName == familyName then
				return true
			end
		end
	end

	return false
end

-- Create pagination controls specific to separation manager
function MountSeparationManager:CreateSeparationPaginationControls(currentPage, totalPages, order)
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
			-- Add page number button - FIXED: Explicitly convert pageNum to string
			local isCurrentPage = (pageNum == currentPage)
			paginationArgs["page_" .. pageNum] = {
				order = buttonOrder,
				type = "execute",
				name = isCurrentPage and ("|cffffd700" .. tostring(pageNum) .. "|r") or tostring(pageNum),
				desc = isCurrentPage and "Current page" or "", -- FIXED: Use empty string instead of concatenation
				func = function() self:GoToPage(pageNum) end,
				width = pageButtonWidth,
				image = "Interface\\AddOns\\RandomMountBuddy\\Media\\Empty",
				imageWidth = 1,
				imageHeight = 1,
			}
		end

		buttonOrder = buttonOrder + 1
	end

	return {
		separation_pagination = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			args = paginationArgs,
		},
	}
end

-- Add the page range calculation function
function MountSeparationManager:CalculatePageRange(currentPage, totalPages)
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

-- UI Building function
function MountSeparationManager:BuildSeparationManagementArgs()
	local args = {}
	local order = 1
	args.description = {
		order = order,
		type = "description",
		name ="",
		fontSize = "medium",
	}
	order = order + 1
	-- Search section
	args.search_description = {
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
		desc = "Search mount names or family names",
		get = function() return self.uiState.searchTerm or "" end,
		set = function(info, value)
			self.uiState.searchTerm = value or ""
			self.uiState.currentPage = 1 -- Reset to first page
			self:PopulateSeparationManagementUI()
		end,
		width = 1,
	}
	order = order + 1
	args.spacer_custom_name = {
		order = order,
		type = "description",
		name = " ",
		width = 0.2,
	}
	order = order + 1
	-- Custom name input section
	args.custom_name_description = {
		order = order,
		type = "description",
		name = "|cffffd700   Custom Separate Name:|r",
		width = 0.8,
	}
	order = order + 1
	args.custom_name_input = {
		order = order,
		type = "input",
		name = "",
		desc = "Optional: Custom family name for separated mount (leave empty for auto-generated name)",
		get = function() return self.uiState.customSeparationName or "" end,
		set = function(info, value) self.uiState.customSeparationName = value end,
		width = 1,
	}
	order = order + 1
	-- Get filtered mounts for current page
	local filteredMounts = self:GetFilteredSeparableMounts()
	local totalMounts = #filteredMounts
	if totalMounts == 0 then
		local message = "No separable mounts found"
		if self.uiState.searchTerm and self.uiState.searchTerm ~= "" then
			message = "No mounts found matching search: " .. self.uiState.searchTerm
		end

		args.no_mounts_msg = {
			order = order,
			type = "description",
			name = message,
		}
		order = order + 1
	else
		-- Add column headers
		if addon.MountUIComponents then
			--[[args.separable_mounts_header = {
				order = order,
				type = "header",
				name = "Separable Mounts (" .. totalMounts .. " total)",
			}
			order = order + 1
			--]]
			-- Custom column headers for separation interface
			args.column_headers_group = {
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
					mountHeader = {
						order = 2,
						type = "description",
						name = "               |cffffd700Mount Name|r",
						width = 1.0,
					},
					familyHeader = {
						order = 3,
						type = "description",
						name = "       |cffffd700Current Family|r",
						width = 1.5,
					},
					actionHeader = {
						order = 4,
						type = "description",
						name = "   |cffffd700Action|r",
						width = 0.4,
					},
				},
			}
			order = order + 1
		end

		-- Pagination
		local itemsPerPage = self:GetItemsPerPage()
		local totalPages = math.max(1, math.ceil(totalMounts / itemsPerPage))
		local currentPage = math.max(1, math.min(self:GetCurrentPage(), totalPages))
		local startIndex = (currentPage - 1) * itemsPerPage + 1
		local endIndex = math.min(startIndex + itemsPerPage - 1, totalMounts)
		-- Build mount entries for current page
		for i = startIndex, endIndex do
			local mountData = filteredMounts[i]
			if mountData then
				local keyBase = "mount_" .. mountData.mountID
				-- Create mount entry
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
								return addon:GetMountPreviewTooltip("mount_" .. mountData.mountID, "mountID")
							end,
							func = function()
								addon:ShowMountPreview(mountData.mountID, mountData.mountName, nil, nil, not mountData.isCollected)
							end,
							width = 0.3,
						},

						-- Mount name
						mount_name = {
							order = 2,
							type = "description",
							name = function()
								local nameColor = mountData.isCollected and "ffffff" or "9d9d9d"
								return "|cff" .. nameColor .. mountData.mountName .. "|r"
							end,
							width = 1.0,
						},

						-- Current family
						current_family = {
							order = 3,
							type = "description",
							name = function()
								local nameColor = mountData.isCollected and "ffffff" or "9d9d9d"
								return "|cff" .. nameColor .. mountData.familyName .. " (" .. mountData.familySize .. " mounts)|r"
							end,
							width = 1.0,
						},

						spacer_fam_sep = {
							order = 3.5,
							type = "description",
							name = "",
							width = 0.35,
						},

						-- Separate button
						separate_button = {
							order = 4,
							type = "execute",
							name = "Separate",
							desc = "Separate this mount into its own family",
							func = function()
								local success, message = self:SeparateMount(mountData.mountID, self.uiState.customSeparationName)
								if success then
									self.uiState.customSeparationName = ""
									addon:AlwaysPrint(" " .. message)
									self:PopulateSeparationManagementUI()
									-- Also refresh the main Mount List UI
									if addon.PopulateFamilyManagementUI then
										addon:PopulateFamilyManagementUI()
									end
								else
									addon:AlwaysPrint(" " .. message)
								end
							end,
							width = 0.6,
						},
					},
				}
				order = order + 1
			end
		end

		-- Add pagination controls
		if totalPages > 1 and addon.MountUIComponents then
			local paginationComponents = self:CreateSeparationPaginationControls(
				currentPage, totalPages, order)
			for k, v in pairs(paginationComponents) do
				args[k] = v
			end

			order = order + 1
		end
	end

	-- Currently Separated Mounts Section
	args.separated_header = {
		order = order,
		type = "header",
		name = "Currently Separated Mounts (" .. #self:GetSeparatedMounts() .. ")",
	}
	order = order + 1
	local separatedMounts = self:GetSeparatedMounts()
	if #separatedMounts == 0 then
		args.no_separated = {
			order = order,
			type = "description",
			name = "No mounts have been separated from their families.",
		}
	else
		-- Column headers for separated mounts
		args.separated_column_headers = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			width = "full",
			args = {
				previewHeader2 = {
					order = 1,
					type = "description",
					name = "  |cffffd700Preview|r",
					width = 0.3,
				},
				mountHeader2 = {
					order = 2,
					type = "description",
					name = "   |cffffd700Mount -> New Family|r",
					width = 1.8,
				},
				actionHeader2 = {
					order = 3,
					type = "description",
					name = "   |cffffd700Action|r",
					width = 0.4,
				},
			},
		}
		order = order + 1
		for _, mountData in ipairs(separatedMounts) do
			local keyBase = "separated_" .. mountData.mountID
			-- Separated mount entry
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
							return addon:GetMountPreviewTooltip("mount_" .. mountData.mountID, "mountID")
						end,
						func = function()
							addon:ShowMountPreview(mountData.mountID, mountData.mountName, nil, nil, not mountData.isCollected)
						end,
						width = 0.3,
					},

					-- Mount info display
					info = {
						order = 2,
						type = "description",
						name = function()
							local status = mountData.isCollected and "" or "|cff9d9d9d"
							local endColor = mountData.isCollected and "" or "|r"
							return status .. "|cff1eff00[M]|r " .. mountData.mountName ..
									" -> " .. mountData.newFamilyName ..
									" |cff888888(was: " .. mountData.originalFamily .. ")|r" .. endColor
						end,
						width = 1.8,
					},

					-- Reunite button
					reunite = {
						order = 3,
						type = "execute",
						name = "Reunite",
						desc = "Return this mount to its original family",
						func = function()
							local success, message = self:ReuniteSeparatedMount(mountData.mountID)
							if success then
								addon:AlwaysPrint(" " .. message)
								self:PopulateSeparationManagementUI()
								-- Also refresh the main Mount List UI
								if addon.PopulateFamilyManagementUI then
									addon:PopulateFamilyManagementUI()
								end
							else
								addon:AlwaysPrint(" " .. message)
							end
						end,
						width = 0.4,
					},
				},
			}
			order = order + 1
		end
	end

	return args
end

function MountSeparationManager:PopulateSeparationManagementUI()
	if not addon.separationArgsRef then
		return
	end

	local startTime = debugprofilestop()
	local newArgs = self:BuildSeparationManagementArgs()
	wipe(addon.separationArgsRef)
	for k, v in pairs(newArgs) do
		addon.separationArgsRef[k] = v
	end

	-- Notify AceConfig
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
	end

	local endTime = debugprofilestop()
	addon:DebugSeparation(string.format(" UI build took %.2fms", endTime - startTime))
end

-- Add OnDataReady method
function MountSeparationManager:OnDataReady()
	addon:DebugSeparation("Data ready, populating UI...")
	self:PopulateSeparationManagementUI()
end

-- Initialize when addon loads
function addon:InitializeMountSeparationManager()
	if not self.MountSeparationManager then
		return
	end

	self.MountSeparationManager:Initialize()
	addon:DebugSeparation("Mount Separation Manager initialized")
end
