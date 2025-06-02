-- FamilyAssignment.lua - Family to Supergroup Assignment Management
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("FamilyAssignment.lua START.")
-- ============================================================================
-- FAMILY ASSIGNMENT CLASS
-- ============================================================================
local FamilyAssignment = {}
addon.FamilyAssignment = FamilyAssignment
-- Initialize the Family Assignment system
function FamilyAssignment:Initialize()
	addon:DebugSupergr("Initializing Family Assignment system...")
	-- UI state for family assignment
	self.uiState = {
		currentPage = 1,
		searchTerm = "",
	}
	-- Initialize dynamic content reference
	self.familyListArgsRef = {}
	addon:DebugSupergr("Family Assignment system initialized")
end

-- ============================================================================
-- FAMILY ASSIGNMENT OPERATIONS
-- ============================================================================
-- Get all families with their current supergroup assignments
function FamilyAssignment:GetAllFamilyAssignments()
	local familyAssignments = {}
	-- Ensure data is ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSupergr("Data not ready for GetAllFamilyAssignments")
		return familyAssignments
	end

	addon:DebugSupergr("GetAllFamilyAssignments - Data is ready, processing...")
	-- Get all unique families from collected mounts
	local allFamilies = {}
	if addon.processedData.allCollectedMountFamilyInfo then
		for _, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
			allFamilies[mountInfo.familyName] = true
		end

		addon:DebugSupergr("Found families from collected mounts: " .. addon:CountTableEntries(allFamilies))
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

		addon:DebugSupergr("Added " .. uncollectedFamilyCount .. " new families from uncollected mounts")
	end

	-- FIXED: Also include separated families
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local newFamilyName = separationData.familyName
			if newFamilyName and not allFamilies[newFamilyName] then
				allFamilies[newFamilyName] = true
				addon:DebugSupergr("Added separated family: " .. newFamilyName)
			end
		end
	end

	addon:DebugSupergr("Total unique families to process: " .. addon:CountTableEntries(allFamilies))
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
				addon:DebugSupergr("Family '" ..
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
	addon:DebugSupergr("GetAllFamilyAssignments returning " .. #familyAssignments .. " family assignments")
	return familyAssignments
end

-- Assign family to supergroup
function FamilyAssignment:AssignFamilyToSuperGroup(familyName, targetSG)
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
	addon:DebugSupergr("Assigning " .. familyName .. " - Original: " .. tostring(originalSG) ..
		", Target: " .. tostring(targetSG) .. ", IsSeparated: " .. tostring(isSeparatedFamily))
	if targetSG == nil or targetSG == "" or targetSG == "<Standalone>" then
		-- Assign to standalone (set intended assignment to standalone)
		if originalSG == nil then
			-- Already originally standalone, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
			addon:DebugSupergr("Cleared override for " .. familyName .. " (originally standalone)")
		else
			-- Force to standalone (override original assignment)
			addon.db.profile.superGroupOverrides[familyName] = false
			addon:DebugSupergr("Set " .. familyName .. " intended assignment to standalone")
		end
	else
		-- Assign to specific supergroup (set intended assignment)
		if targetSG == originalSG then
			-- Same as original assignment, remove any override
			addon.db.profile.superGroupOverrides[familyName] = nil
			addon:DebugSupergr("Cleared override for " .. familyName .. " (matches original assignment)")
		else
			-- Override to new supergroup (set intended assignment)
			addon.db.profile.superGroupOverrides[familyName] = targetSG
			addon:DebugSupergr("Set " .. familyName .. " intended assignment to " .. targetSG)
		end
	end

	-- ENHANCED: Handle weight synchronization for separated families
	if isSeparatedFamily and separatedMountID then
		local mountKey = "mount_" .. separatedMountID
		local familyWeight = addon:GetGroupWeight(familyName)
		local mountWeight = addon:GetGroupWeight(mountKey)
		-- Ensure family and mount weights are synchronized
		if familyWeight ~= mountWeight then
			addon:DebugSupergr("Synchronizing weights for separated family - Family: " ..
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

-- ============================================================================
-- SEPARATED FAMILY INTEGRATION
-- ============================================================================
-- ENHANCED: Add helper method to check if a family is from a separated mount
function FamilyAssignment:IsSeparatedFamily(familyName)
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
function FamilyAssignment:GetSeparatedFamilyInfo(familyName)
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

-- ENHANCED: Add helper method to check separated family compatibility
function FamilyAssignment:ValidateSeparatedFamilyIntegrity()
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
				addon:DebugSupergr("Fixed weight sync for " .. familyName .. " -> " .. syncWeight)
			end
		end
	end

	if #issues > 0 then
		addon:DebugSupergr("Found " .. #issues .. " separated family integrity issues")
		for _, issue in ipairs(issues) do
			addon:DebugSupergr("ISSUE: " .. issue)
		end
	end

	if fixedIssues > 0 then
		addon:DebugSupergr("Auto-fixed " .. fixedIssues .. " weight synchronization issues")
	end

	return #issues == 0, issues
end

-- ============================================================================
-- UI HELPER FUNCTIONS
-- ============================================================================
-- Get available supergroups for assignment dropdown
function FamilyAssignment:GetAvailableSuperGroups()
	local availableSGs = {}
	-- FIXED: Use prefixed keys to force Ace sorting order
	-- Start with standalone
	availableSGs["0_<Standalone>"] = "Standalone"
	-- Add custom supergroups first (prefix with 1_)
	local allSGs = addon.SuperGroupManager:GetAllSuperGroups()
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

-- ============================================================================
-- UI BUILDING AND MANAGEMENT
-- ============================================================================
-- Populate family assignment UI (same pattern as PopulateFamilyManagementUI)
function FamilyAssignment:PopulateFamilyAssignmentUI()
	addon:DebugSupergr("PopulateFamilyAssignmentUI called")
	if not addon.sgFamilyArgsRef then
		addon:DebugSupergr("addon.sgFamilyArgsRef is nil! Options.lua problem.")
		return
	end

	local startTime = debugprofilestop()
	-- ENHANCED: Validate separated family compatibility before building UI
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		local separatedCount = addon:CountTableEntries(addon.db.profile.separatedMounts)
		if separatedCount > 0 then
			addon:DebugSupergr("Validating compatibility with " .. separatedCount .. " separated families")
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

-- Build family assignment page content
function FamilyAssignment:BuildFamilyAssignmentArgs()
	addon:DebugSupergr("BuildFamilyAssignmentArgs called")
	local args = {}
	local order = 1
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
		name = "|cffffd700  Search:|r",
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
				self:PopulateFamilyAssignmentUI()
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
	local itemsPerPage = 14
	local totalItems = #filteredFamilies
	local totalPages = math.max(1, math.ceil(totalItems / itemsPerPage))
	local currentPage = math.max(1, math.min(self.uiState.currentPage or 1, totalPages))
	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalItems)
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
					name = "     |cffffd700Family Name|r",
					width = 2,
				},
				assignmentHeader = {
					order = 3,
					type = "description",
					name = "   |cffffd700Supergroup Assignment|r",
					width = 1.0,
				},
				resetHeader = {
					order = 4,
					type = "description",
					name = "     |cffffd700  Reset|r",
					width = 0.4,
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

					-- UPDATED: Family name (simplified, no status indicators)
					family_name = {
						order = 2,
						type = "description",
						name = function()
							local indicator = (familyInfo.totalCount == 1) and "|cff1eff00[M]|r" or "|cff0070dd[F]|r"
							-- Only show count if there's more than one mount
							local countText = ""
							if familyInfo.totalCount > 1 then
								countText = " (" .. familyInfo.collectedCount
								if familyInfo.uncollectedCount > 0 then
									countText = countText .. " + |cff9d9d9d" .. familyInfo.uncollectedCount .. "|r"
								end

								countText = countText .. ")"
							end

							-- Show override indicator next to name
							local overrideText = ""
							if familyInfo.hasUserOverride then
								overrideText = " |cffffd700*|r"
							end

							return indicator .. " " .. familyInfo.familyName .. overrideText .. countText
						end,
						width = 2,
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
									addon.SuperGroupManager:PopulateSuperGroupManagementUI()
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

					-- NEW: Reset to default button
					reset_button = {
						order = 4,
						type = "execute",
						name = "Reset",
						desc = function()
							local defaultAssignment = familyInfo.originalSuperGroup or "Standalone"
							return "Reset to default assignment: " .. defaultAssignment ..
									(familyInfo.hasUserOverride and "\n|cffffd700(Will remove current override)|r" or "\n|cff888888(Already at default)|r")
						end,
						func = function()
							-- Reset to original assignment by removing override
							if addon.db and addon.db.profile and addon.db.profile.superGroupOverrides then
								addon.db.profile.superGroupOverrides[familyInfo.familyName] = nil
							end

							-- Trigger rebuild
							addon:RebuildMountGrouping()
							-- Refresh all UIs
							addon.SuperGroupManager:PopulateSuperGroupManagementUI()
							self:PopulateFamilyAssignmentUI()
							if addon.PopulateFamilyManagementUI then
								addon:PopulateFamilyManagementUI()
							end

							local defaultAssignment = familyInfo.originalSuperGroup or "Standalone"
							addon:AlwaysPrint("Reset " .. familyInfo.familyName .. " to default: " .. defaultAssignment)
						end,
						disabled = function()
							return not familyInfo.hasUserOverride
						end,
						width = 0.4,
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

	addon:DebugSupergr("Built family assignment UI with " .. #filteredFamilies .. " families")
	return args
end

-- ============================================================================
-- PAGINATION CONTROLS
-- ============================================================================
-- Add the page range calculation function
function FamilyAssignment:CalculatePageRange(currentPage, totalPages)
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

-- NEW: Create pagination controls matching MountSeparationManager style
function FamilyAssignment:CreateFamilyAssignmentPaginationControls(currentPage, totalPages, order)
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
-- INITIALIZATION
-- ============================================================================
-- Initialize Family Assignment system when addon loads
function addon:InitializeFamilyAssignment()
	if not self.FamilyAssignment then
		addon:DebugSupergr("ERROR - FamilyAssignment not found!")
		return
	end

	self.FamilyAssignment:Initialize()
	addon:DebugSupergr("FamilyAssignment integration complete")
end

addon:DebugCore("FamilyAssignment.lua END.")
