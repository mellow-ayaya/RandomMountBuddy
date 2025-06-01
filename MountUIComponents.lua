-- MountUIComponents.lua - Enhanced with Conditional Weight Control Buttons
-- Added visual warnings when FavoriteSync auto-sync is enabled
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountUIComponents.lua (Enhanced Conditional Controls) START.")
-- ============================================================================
-- UI COMPONENT BUILDER CLASS
-- ============================================================================
local MountUIComponents = {}
addon.MountUIComponents = MountUIComponents
-- Weight display mapping
local WeightDisplayMapping = {
	[0] = { text = "         Never", color = "ff3e00" }, -- Red
	[1] = { text = "     Occasional", color = "9d9d9d" }, -- Grey
	[2] = { text = "    Uncommon", color = "cbcbcb" },   -- Grey
	[3] = { text = "        Normal", color = "ffffff" }, -- White
	[4] = { text = "       Common", color = "1eff00" },  -- Green
	[5] = { text = "         Often", color = "0070dd" }, -- Blue
	[6] = { text = "        Always", color = "ff8000" }, -- Orange
}
-- ============================================================================
-- FAVORITE SYNC DETECTION HELPERS
-- ============================================================================
-- Check if favorite sync will affect this group
function MountUIComponents:IsFavoriteSyncActive()
	return addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") or false
end

function MountUIComponents:ShouldWarnAboutSync(groupKey, groupType)
	if not self:IsFavoriteSyncActive() then
		return false
	end

	-- Always warn for individual mounts since they could be favorites
	if groupType == "mountID" or (type(groupKey) == "string" and groupKey:match("^mount_")) then
		return true
	end

	-- Warn for families and supergroups if family/supergroup sync is enabled
	if groupType == "familyName" and addon.FavoriteSync:GetSetting("syncFamilyWeights") then
		return true
	end

	if groupType == "superGroup" and addon.FavoriteSync:GetSetting("syncSuperGroupWeights") then
		return true
	end

	return false
end

function MountUIComponents:GetSyncWarningTooltip(groupKey, groupType)
	if not self:ShouldWarnAboutSync(groupKey, groupType) then
		return nil
	end

	local warnings = {}
	table.insert(warnings, "|cffffcc00 FavoriteSync Active|r")
	if groupType == "mountID" or (type(groupKey) == "string" and groupKey:match("^mount_")) then
		table.insert(warnings,
			"Manual weight changes may be overridden if this mount is marked as favorite/non-favorite in your Mount Journal.")
	elseif groupType == "familyName" then
		table.insert(warnings,
			"Manual weight changes may be overridden if this family contains favorite mounts and 'Sync Family Weights' is enabled.")
	elseif groupType == "superGroup" then
		table.insert(warnings,
			"Manual weight changes may be overridden if this supergroup contains favorite mounts and 'Sync SuperGroup Weights' is enabled.")
	end

	table.insert(warnings, "")
	table.insert(warnings,
		"|cff888888Disable FavoriteSync or adjust its settings in the main options to prevent automatic changes.|r")
	return table.concat(warnings, "\n")
end

-- ============================================================================
-- ENHANCED WEIGHT CONTROL HELPERS
-- ============================================================================
function MountUIComponents:GetEnhancedWeightControlProps(groupKey, groupType)
	local shouldWarn = self:ShouldWarnAboutSync(groupKey, groupType)
	local warningTooltip = self:GetSyncWarningTooltip(groupKey, groupType)
	-- Choose button images based on sync status
	local decrementImage = shouldWarn and "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled" or
			"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
	local incrementImage = shouldWarn and "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled" or
			"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"
	return {
		shouldWarn = shouldWarn,
		warningTooltip = warningTooltip,
		decrementImage = decrementImage,
		incrementImage = incrementImage,
	}
end

-- ============================================================================
-- INDENTATION HELPER FUNCTIONS
-- ============================================================================
-- Calculate indentation widths based on nesting level
local function GetLayoutWidths(nestingLevel)
	-- All nesting levels use identical layout values - no indentation differences
	local layout = {
		previewWidth = 0.3,
		nameIndent = 0.05,
		nameWidth = 1.12,
		nameSpacerAfter = 0.08,
		controlsWidth = 0.5,
		traitsWidth = 1.00,
		expandWidth = 0.3,
	}
	return layout
end

-- ============================================================================
-- COMPLETE ENTRY BUILDERS - MAINTAINS ORIGINAL ORDER
-- ============================================================================
-- Build a complete group entry (main level - supergroup or standalone family)
function MountUIComponents:BuildGroupEntry(groupData, isExpanded, expandedDetails)
	local groupKey = groupData.key
	local nestingLevel = 0 -- Top level
	local layout = GetLayoutWidths(nestingLevel)
	-- Get traits and display info safely
	local shouldShowTraits = false
	local traits = {}
	if addon.MountDataManager and addon.MountDataManager.ShouldShowTraits then
		shouldShowTraits = addon.MountDataManager:ShouldShowTraits(groupKey, groupData.type)
		if shouldShowTraits and addon.MountDataManager.GetFamilyTraits then
			traits = addon.MountDataManager:GetFamilyTraits(groupKey) or {}
		end
	end

	-- Check if single mount family
	local totalMountCount = (groupData.mountCount or 0) + (groupData.uncollectedCount or 0)
	local isSingleMountFamily = (groupData.type == "familyName" and totalMountCount == 1)
	-- Get display name safely
	local displayName = groupData.displayName or groupKey
	if addon.MountDataManager and addon.MountDataManager.GetGroupDisplayName then
		displayName = addon.MountDataManager:GetGroupDisplayName(groupData)
	else
		displayName = self:CreateFallbackDisplayName(groupData)
	end

	-- Get enhanced weight control properties
	local weightProps = self:GetEnhancedWeightControlProps(groupKey, groupData.type)
	-- Build entry components - MAINTAIN EXACT SAME ORDER AS ORIGINAL
	local entry = {
		-- Order 0.2: Preview button
		previewButton = {
			order = 0.2,
			type = "execute",
			name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
			desc = function()
				return addon:GetMountPreviewTooltip(groupKey, groupData.type)
			end,
			func = function(info)
				local includeUncollected = addon:GetSetting("showUncollectedMounts")
				local mountID, mountName, isUncollected = addon:GetRandomMountFromGroup(
					groupKey, groupData.type, includeUncollected)
				if mountID then
					addon:ShowMountPreview(mountID, mountName, groupKey, groupData.type, isUncollected)
				else
					print("RMB_PREVIEW: No mount available to preview from this group")
				end
			end,
			width = layout.previewWidth,
		},

		-- Order 0.3: Spacer before name
		spacerBeforeName = {
			order = 0.3,
			type = "description",
			name = " ",
			width = layout.nameIndent,
		},

		-- Order 1: Group name
		group_name = {
			order = 1,
			type = "description",
			name = displayName,
			width = layout.nameWidth,
			fontSize = "medium",
		},

		-- Order 1.1: Spacer after name
		spaceAfterName = {
			order = 1.1,
			type = "description",
			name = " ",
			width = layout.nameSpacerAfter,
		},

		-- Order 2: Weight decrement (ENHANCED)
		weightDecrement = {
			order = 2,
			type = "execute",
			name = "",
			func = function()
				addon:DecrementGroupWeight(groupKey)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight(groupKey) == 0 end,
			width = 0.05,
			image = weightProps.decrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Decrease weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		-- Order 3: Weight display (ENHANCED)
		weightDisplay = {
			order = 3,
			type = "description",
			name = function()
				local weightStr = self:GetWeightDisplayString(addon:GetGroupWeight(groupKey))
				-- Add sync warning indicator
				if weightProps.shouldWarn then
					return weightStr .. "\n|cffffd700 [Auto Sync On]|r"
				end

				return weightStr
			end,
			width = layout.controlsWidth,
			desc = function()
				if weightProps.warningTooltip then
					return "Current weight setting\n\n" .. weightProps.warningTooltip
				end

				return "Current weight setting"
			end,
		},

		-- Order 4: Weight increment (ENHANCED)
		weightIncrement = {
			order = 4,
			type = "execute",
			name = "",
			func = function()
				addon:IncrementGroupWeight(groupKey)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight(groupKey) == 6 end,
			width = 0.05,
			image = weightProps.incrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Increase weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		-- Order 6: Spacer for toggles
		spacerToggles = {
			order = 6,
			type = "description",
			name = " ",
			width = 0.11,
		},

		-- Order 6 (alternate): Spacer when no toggles
		spacerNoToggles = {
			order = 6,
			type = "description",
			name = " ",
			hidden = shouldShowTraits,
			width = layout.traitsWidth,
		},

		-- Order 7-7.3: Interactive trait toggles
		toggleMinorArmor = {
			order = 7,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_GreenArmor:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Small armor or ornaments"
				local originalTraits = addon:GetOriginalTraits(groupKey)
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				local isOverridden = (originalTraits.hasMinorArmor ~= effectiveTraits.hasMinorArmor)
				if isOverridden then
					return baseDesc .. "\n\n|cffffd700Modified from original|r"
				end

				return baseDesc
			end,
			get = function()
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				return effectiveTraits.hasMinorArmor or false
			end,
			set = function(info, value)
				addon:SetFamilyTrait(groupKey, "hasMinorArmor", value)
				-- Invalidate data manager cache
				if addon.MountDataManager then
					addon.MountDataManager:InvalidateTraitCache(groupKey)
				end

				-- Refresh UI to show changes
				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false, -- Now enabled!
		},

		toggleMajorArmor = {
			order = 7.1,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_BlueArmor:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Bulky armor or many ornaments"
				local originalTraits = addon:GetOriginalTraits(groupKey)
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				local isOverridden = (originalTraits.hasMajorArmor ~= effectiveTraits.hasMajorArmor)
				if isOverridden then
					return baseDesc .. "\n\n|cffffd700Modified from original|r"
				end

				return baseDesc
			end,
			get = function()
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				return effectiveTraits.hasMajorArmor or false
			end,
			set = function(info, value)
				addon:SetFamilyTrait(groupKey, "hasMajorArmor", value)
				if addon.MountDataManager then
					addon.MountDataManager:InvalidateTraitCache(groupKey)
				end

				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},

		toggleModelVariant = {
			order = 7.2,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Green:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Updated texture/slightly different model"
				local originalTraits = addon:GetOriginalTraits(groupKey)
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				local isOverridden = (originalTraits.hasModelVariant ~= effectiveTraits.hasModelVariant)
				if isOverridden then
					return baseDesc .. "\n\n|cffffd700Modified from original|r"
				end

				return baseDesc
			end,
			get = function()
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				return effectiveTraits.hasModelVariant or false
			end,
			set = function(info, value)
				addon:SetFamilyTrait(groupKey, "hasModelVariant", value)
				if addon.MountDataManager then
					addon.MountDataManager:InvalidateTraitCache(groupKey)
				end

				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},

		toggleUniqueEffect = {
			order = 7.3,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Blue:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Unique variant, stands out from the rest"
				local originalTraits = addon:GetOriginalTraits(groupKey)
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				local isOverridden = (originalTraits.isUniqueEffect ~= effectiveTraits.isUniqueEffect)
				if isOverridden then
					return baseDesc .. "\n\n|cffffd700Modified from original|r"
				end

				return baseDesc
			end,
			get = function()
				local effectiveTraits = addon:GetEffectiveTraits(groupKey)
				return effectiveTraits.isUniqueEffect or false
			end,
			set = function(info, value)
				addon:SetFamilyTrait(groupKey, "isUniqueEffect", value)
				if addon.MountDataManager then
					addon.MountDataManager:InvalidateTraitCache(groupKey)
				end

				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},
		spacerReset = {
			order = 7.4,
			type = "description",
			name = " ",
			width = 0.01,
		},
		resetTraits = {
			order = 7.5,
			type = "execute",
			name = "",
			desc = "Reset traits to original values",
			func = function()
				if groupData.type == "superGroup" then
					return
				end

				addon:ResetFamilyTraits(groupKey)
				if addon.MountDataManager then
					addon.MountDataManager:InvalidateTraitCache(groupKey)
				end

				if addon.PopulateFamilyManagementUI then
					addon:PopulateFamilyManagementUI()
				end
			end,
			width = 0.08,
			hidden = function()
				return not shouldShowTraits or
						groupData.type == "superGroup" or
						not addon:HasTraitOverrides(groupKey)
			end,
			image = "Interface\\BUTTONS\\UI-RefreshButton",
			imageWidth = 15,
			imageHeight = 15,
		},
		-- Spacer when no reset
		spacerNoReset = {
			order = 7.6,
			type = "description",
			name = "",
			width = 0.08,
			hidden = function()
				return not (not shouldShowTraits or
					groupData.type == "superGroup" or
					not addon:HasTraitOverrides(groupKey))
			end,
			image = "Interface\\AddOns\\RandomMountBuddy\\Media\\Empty",
			imageWidth = 15,
			imageHeight = 15,
		},
		-- Order 8: Expand/collapse button
		expandCollapse = {
			order = 8,
			type = "execute",
			name = "",
			func = function() addon:ToggleExpansionState(groupKey) end,
			width = layout.expandWidth,
			hidden = isSingleMountFamily,
			image = isExpanded and "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonUpLargev11" or
					"Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonDownLargev11",
			imageWidth = 40,
			imageHeight = 20,
		},
	}
	-- Add expanded content header if needed
	if isExpanded then
		entry.expandedHeader = {
			order = 10,
			type = "header",
			name = "Families & Mounts in " .. groupKey,
			width = "full",
		}
		-- Add expanded details
		if expandedDetails then
			for k, v in pairs(expandedDetails) do
				entry[k] = v
				if v.order then
					v.order = v.order + 10
				end
			end
		end
	end

	return entry
end

-- Build family entry within a supergroup (nesting level 1)
function MountUIComponents:BuildFamilyEntry(familyName, familyDisplayName, isExpanded, order)
	local nestingLevel = 1 -- Nested within supergroup
	local layout = GetLayoutWidths(nestingLevel)
	-- Get family data safely
	local shouldShowTraits = false
	local traits = {}
	if addon.MountDataManager and addon.MountDataManager.ShouldShowTraits then
		shouldShowTraits = addon.MountDataManager:ShouldShowTraits(familyName, "familyName")
		if shouldShowTraits and addon.MountDataManager.GetFamilyTraits then
			traits = addon.MountDataManager:GetFamilyTraits(familyName) or {}
		end
	end

	-- Calculate if this is a single-mount family
	local collectedCount = 0
	local uncollectedCount = 0
	if addon.processedData then
		-- Get collected mount count
		if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName] then
			collectedCount = #addon.processedData.familyToMountIDsMap[familyName]
		end

		-- Get uncollected mount count if showing uncollected is enabled
		if addon:GetSetting("showUncollectedMounts") then
			if addon.processedData.familyToUncollectedMountIDsMap and addon.processedData.familyToUncollectedMountIDsMap[familyName] then
				uncollectedCount = #addon.processedData.familyToUncollectedMountIDsMap[familyName]
			end
		end
	end

	local totalMountCount = collectedCount + uncollectedCount
	local isSingleMountFamily = (totalMountCount == 1)
	-- The familyDisplayName passed in should already have the proper [F] or [M] indicator
	local displayName = familyDisplayName
	-- Get enhanced weight control properties for families
	local weightProps = self:GetEnhancedWeightControlProps(familyName, "familyName")
	-- MAINTAIN EXACT SAME ORDER AS TOP LEVEL, JUST ADJUST WIDTHS
	local entry = {
		-- Preview button
		preview = {
			order = order,
			type = "execute",
			name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
			desc = function()
				return addon:GetMountPreviewTooltip(familyName, "familyName")
			end,
			func = function()
				local includeUncollected = addon:GetSetting("showUncollectedMounts")
				local mountID, mountName, isUncollected = addon:GetRandomMountFromGroup(familyName, "familyName",
					includeUncollected)
				if mountID then
					addon:ShowMountPreview(mountID, mountName, familyName, "familyName", isUncollected)
				else
					print("RMB_PREVIEW: No mount available to preview from this family")
				end
			end,
			width = layout.previewWidth,
		},

		-- Spacer before name
		spacerBeforeName = {
			order = order + 0.1,
			type = "description",
			name = " ",
			width = layout.nameIndent,
		},

		-- Family name (UPDATED to use displayName with indicator)
		name = {
			order = order + 0.2,
			type = "description",
			name = displayName,
			width = layout.nameWidth,
			fontSize = "small",
		},

		-- Spacer after name
		spacerAfterName = {
			order = order + 0.3,
			type = "description",
			name = " ",
			width = layout.nameSpacerAfter,
		},

		-- Weight controls - SAME ORDER AS ORIGINAL (ENHANCED)
		weightDecrement = {
			order = order + 0.4,
			type = "execute",
			name = "",
			func = function()
				addon:DecrementGroupWeight(familyName)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight(familyName) == 0 end,
			width = 0.05,
			image = weightProps.decrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Decrease weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		weightDisplay = {
			order = order + 0.5,
			type = "description",
			name = function()
				local weightStr = self:GetWeightDisplayString(addon:GetGroupWeight(familyName))
				-- Add sync warning indicator
				if weightProps.shouldWarn then
					return weightStr .. "\n|cffffd700 [Auto Sync On]|r"
				end

				return weightStr
			end,
			width = layout.controlsWidth,
			desc = function()
				if weightProps.warningTooltip then
					return "Current weight setting\n\n" .. weightProps.warningTooltip
				end

				return "Current weight setting"
			end,
		},

		weightIncrement = {
			order = order + 0.6,
			type = "execute",
			name = "",
			func = function()
				addon:IncrementGroupWeight(familyName)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight(familyName) == 6 end,
			width = 0.05,
			image = weightProps.incrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Increase weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		-- Spacer for toggles
		spacerToggles = {
			order = order + 0.65,
			type = "description",
			name = " ",
			width = 0.11,
		},

		-- Spacer when no toggles
		spacerNoToggles = {
			order = order + 0.65,
			type = "description",
			name = " ",
			width = layout.traitsWidth,
			hidden = shouldShowTraits,
		},

		-- Trait toggles - SAME ORDER AS TOP LEVEL (unchanged for now)
		toggleMinorArmor = {
			order = order + 0.7,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_GreenArmor:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Small armor or ornaments"
				if addon.GetOriginalTraits and addon.GetEffectiveTraits then
					local originalTraits = addon:GetOriginalTraits(familyName)
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					local isOverridden = (originalTraits.hasMinorArmor ~= effectiveTraits.hasMinorArmor)
					if isOverridden then
						return baseDesc .. "\n\n|cffffd700Modified from original|r"
					end
				end

				return baseDesc
			end,
			get = function()
				if addon.GetEffectiveTraits then
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					return effectiveTraits.hasMinorArmor or false
				end

				return traits.hasMinorArmor or false
			end,
			set = function(info, value)
				if addon.SetFamilyTrait then
					addon:SetFamilyTrait(familyName, "hasMinorArmor", value)
					if addon.MountDataManager and addon.MountDataManager.InvalidateTraitCache then
						addon.MountDataManager:InvalidateTraitCache(familyName)
					end

					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},

		toggleMajorArmor = {
			order = order + 0.71,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_BlueArmor:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Bulky armor or ornaments"
				if addon.GetOriginalTraits and addon.GetEffectiveTraits then
					local originalTraits = addon:GetOriginalTraits(familyName)
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					local isOverridden = (originalTraits.hasMajorArmor ~= effectiveTraits.hasMajorArmor)
					if isOverridden then
						return baseDesc .. "\n\n|cffffd700Modified from original|r"
					end
				end

				return baseDesc
			end,
			get = function()
				if addon.GetEffectiveTraits then
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					return effectiveTraits.hasMajorArmor or false
				end

				return traits.hasMajorArmor or false
			end,
			set = function(info, value)
				if addon.SetFamilyTrait then
					addon:SetFamilyTrait(familyName, "hasMajorArmor", value)
					if addon.MountDataManager and addon.MountDataManager.InvalidateTraitCache then
						addon.MountDataManager:InvalidateTraitCache(familyName)
					end

					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},

		toggleModelVariant = {
			order = order + 0.72,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Green:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Updated texture/slightly different model"
				if addon.GetOriginalTraits and addon.GetEffectiveTraits then
					local originalTraits = addon:GetOriginalTraits(familyName)
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					local isOverridden = (originalTraits.hasModelVariant ~= effectiveTraits.hasModelVariant)
					if isOverridden then
						return baseDesc .. "\n\n|cffffd700Modified from original|r"
					end
				end

				return baseDesc
			end,
			get = function()
				if addon.GetEffectiveTraits then
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					return effectiveTraits.hasModelVariant or false
				end

				return traits.hasModelVariant or false
			end,
			set = function(info, value)
				if addon.SetFamilyTrait then
					addon:SetFamilyTrait(familyName, "hasModelVariant", value)
					if addon.MountDataManager and addon.MountDataManager.InvalidateTraitCache then
						addon.MountDataManager:InvalidateTraitCache(familyName)
					end

					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},

		toggleUniqueEffect = {
			order = order + 0.73,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Blue:18:18:0:-2|t",
			desc = function()
				local baseDesc = "Unique variant, stands out from the rest"
				if addon.GetOriginalTraits and addon.GetEffectiveTraits then
					local originalTraits = addon:GetOriginalTraits(familyName)
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					local isOverridden = (originalTraits.isUniqueEffect ~= effectiveTraits.isUniqueEffect)
					if isOverridden then
						return baseDesc .. "\n\n|cffffd700Modified from original|r"
					end
				end

				return baseDesc
			end,
			get = function()
				if addon.GetEffectiveTraits then
					local effectiveTraits = addon:GetEffectiveTraits(familyName)
					return effectiveTraits.isUniqueEffect or false
				end

				return traits.isUniqueEffect or false
			end,
			set = function(info, value)
				if addon.SetFamilyTrait then
					addon:SetFamilyTrait(familyName, "isUniqueEffect", value)
					if addon.MountDataManager and addon.MountDataManager.InvalidateTraitCache then
						addon.MountDataManager:InvalidateTraitCache(familyName)
					end

					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end
			end,
			width = 0.25,
			hidden = not shouldShowTraits,
			disabled = false,
		},
		spacerReset = {
			order = order + 0.74,
			type = "description",
			name = " ",
			width = 0.01,
		},
		-- Reset traits button for families
		resetTraits = {
			order = order + 0.75,
			type = "execute",
			name = "",
			desc = "Reset traits to original values",
			func = function()
				if addon.ResetFamilyTraits then
					addon:ResetFamilyTraits(familyName)
					if addon.MountDataManager and addon.MountDataManager.InvalidateTraitCache then
						addon.MountDataManager:InvalidateTraitCache(familyName)
					end

					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end
			end,
			width = 0.08,
			hidden = function()
				return not shouldShowTraits or not (addon.HasTraitOverrides and addon:HasTraitOverrides(familyName))
			end,
			image = "Interface\\BUTTONS\\UI-RefreshButton",
			imageWidth = 15,
			imageHeight = 15,
		},
		-- Spacer when no reset
		spacerNoReset = {
			order = order + 0.76,
			type = "description",
			name = "",
			width = 0.08,
			hidden = function()
				return shouldShowTraits and (addon.HasTraitOverrides and addon:HasTraitOverrides(familyName))
			end,
			image = "Interface\\AddOns\\RandomMountBuddy\\Media\\Empty",
			imageWidth = 15,
			imageHeight = 15,
		},
		-- Expand button
		expand = {
			order = order + 0.8,
			type = "execute",
			name = "",
			func = function() addon:ToggleExpansionState(familyName) end,
			width = layout.expandWidth,
			hidden = isSingleMountFamily,
			image = isExpanded and "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonUpLargev11" or
					"Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonDownLargev11",
			imageWidth = 40,
			imageHeight = 20,
		},

		-- Line break
		linebreak = {
			order = order + 0.9,
			type = "description",
			name = "",
			width = "full",
		},
	}
	return entry
end

-- Build individual mount entry (nesting level 2)
function MountUIComponents:BuildMountEntry(mountData, order, familyPrefix)
	local nestingLevel = 2 -- Nested within family
	local layout = GetLayoutWidths(nestingLevel)
	local mountID = mountData.id
	local mountName = mountData.name
	local isCollected = mountData.isCollected
	-- Create display name with [M] indicator and proper indentation prefix
	local mountIndicator = "|cff1eff00[M]|r" -- Green
	local nameColor = isCollected and "ffffff" or "9d9d9d"
	local collectionStatus = isCollected and "" or ""
	local displayName = "|cff" .. nameColor .. " " .. mountIndicator .. " " .. mountName .. collectionStatus .. "|r"
	-- Get enhanced weight control properties for individual mounts
	local weightProps = self:GetEnhancedWeightControlProps("mount_" .. mountID, "mountID")
	-- MAINTAIN EXACT SAME ORDER AS TOP LEVEL, JUST ADJUST WIDTHS
	local entry = {
		-- Preview button
		preview = {
			order = order,
			type = "execute",
			name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
			desc = function()
				return addon:GetMountPreviewTooltip("mount_" .. mountID, "mountID")
			end,
			func = function()
				addon:ShowMountPreview(mountID, mountName, nil, nil, not isCollected)
			end,
			width = layout.previewWidth,
		},

		-- Spacer before name
		spacerBeforeName = {
			order = order + 0.1,
			type = "description",
			name = " ",
			width = layout.nameIndent,
		},

		-- Mount name
		name = {
			order = order + 0.2,
			type = "description",
			name = displayName,
			fontSize = "small",
			width = layout.nameWidth,
		},

		-- Spacer after name
		spacerAfterName = {
			order = order + 0.3,
			type = "description",
			name = " ",
			width = layout.nameSpacerAfter,
		},

		-- Weight controls - SAME ORDER AS ORIGINAL (ENHANCED)
		weightDecrement = {
			order = order + 0.4,
			type = "execute",
			name = "",
			func = function()
				addon:DecrementGroupWeight("mount_" .. mountID)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight("mount_" .. mountID) == 0 end,
			width = 0.05,
			image = weightProps.decrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Decrease weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		weightDisplay = {
			order = order + 0.5,
			type = "description",
			name = function()
				local weightStr = self:GetWeightDisplayString(addon:GetGroupWeight("mount_" .. mountID))
				if not isCollected then
					-- Add gray color wrap if it's not already colored
					if not weightStr:find("|cff") then
						weightStr = "|cff9d9d9d" .. weightStr .. "|r"
					end
				end

				-- Add sync warning indicator
				if weightProps.shouldWarn then
					return weightStr .. "\n|cffffd700 [Auto Sync On]|r"
				end

				return weightStr
			end,
			width = layout.controlsWidth,
			desc = function()
				if weightProps.warningTooltip then
					return "Current weight setting\n\n" .. weightProps.warningTooltip
				end

				return "Current weight setting"
			end,
		},

		weightIncrement = {
			order = order + 0.6,
			type = "execute",
			name = "",
			func = function()
				addon:IncrementGroupWeight("mount_" .. mountID)
				-- Show brief reminder if sync is active
				if weightProps.shouldWarn then
					print("RMB: Weight changed. Note: FavoriteSync may override this change.")
				end
			end,
			disabled = function() return addon:GetGroupWeight("mount_" .. mountID) == 6 end,
			width = 0.05,
			image = weightProps.incrementImage,
			imageWidth = 16,
			imageHeight = 20,
			desc = function()
				local baseDesc = "Increase weight"
				if weightProps.warningTooltip then
					return baseDesc .. "\n\n" .. weightProps.warningTooltip
				end

				return baseDesc
			end,
		},

		-- Spacer for traits (mounts don't have traits but need spacing)
		spacerToggles = {
			order = order + 0.7,
			type = "description",
			name = " ",
			width = layout.traitsWidth,
		},

		-- Line break
		linebreak = {
			order = order + 0.8,
			type = "description",
			name = "",
			width = "full",
		},
	}
	return entry
end

-- ============================================================================
-- PAGINATION COMPONENTS (unchanged)
-- ============================================================================
-- Enhanced pagination with smart page range display and centering
function MountUIComponents:CreateSmartPaginationControls(currentPage, totalPages, order)
	if totalPages <= 1 then
		return {}
	end

	-- Calculate which pages to show in the middle section
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
				desc = isCurrentPage and "Current page" or (""),
				func = function() addon:FMG_GoToPage(pageNum) end,
				width = pageButtonWidth,
				image = "Interface\\AddOns\\RandomMountBuddy\\Media\\Empty",
				imageWidth = 1,
				imageHeight = 1,
			}
		end

		buttonOrder = buttonOrder + 1
	end

	return {
		smart_pagination = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			args = paginationArgs,
		},
	}
end

-- Calculate which page numbers to show in navigation
function MountUIComponents:CalculatePageRange(currentPage, totalPages)
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

-- ============================================================================
-- HEADER COMPONENTS (unchanged)
-- ============================================================================
function MountUIComponents:CreateColumnHeaders(order)
	return {
		column_headers_group = {
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
					name = "   |cffffd700Super Group/Family/Mount name|r",
					width = 1.1,
				},
				summonchanceHeader = {
					order = 3,
					type = "description",
					name = "           |cffffd700Summon Chance|r",
					width = 0.8,
				},
				traitsHeader = {
					order = 4,
					type = "description",
					name = "                           |cffffd700Traits|r",
					width = 0.8,
				},
				spacerHeader = {
					order = 5,
					type = "description",
					name = " ",
					width = 0.35,
				},
				expandHeader = {
					order = 6,
					type = "description",
					name = "  |cffffd700Expand|r",
					width = 0.3,
				},
			},
		},
	}
end

-- ============================================================================
-- UTILITY FUNCTIONS (unchanged)
-- ============================================================================
-- Get weight display string
function MountUIComponents:GetWeightDisplayString(weight)
	local w = tonumber(weight) or 1
	if w < 0 or w > 6 then w = 1 end

	local info = WeightDisplayMapping[w]
	if not info then
		return "|cffffffffError|r"
	end

	return "|cff" .. info.color .. info.text .. "|r"
end

-- Create fallback display name when MountDataManager isn't available
function MountUIComponents:CreateFallbackDisplayName(groupData)
	local collectedCount = groupData.mountCount or 0
	local uncollectedCount = groupData.uncollectedCount or 0
	local totalMounts = collectedCount + uncollectedCount
	-- Define color codes for indicators
	local superGroupIndicator = "|cffa335ee[G]|r" -- Purple
	local familyIndicator = "|cff0070dd[F]|r"    -- Blue
	local mountIndicator = "|cff1eff00[M]|r"     -- Green
	if groupData.type == "superGroup" then
		-- Supergroups always get [G] indicator
		if collectedCount > 0 and uncollectedCount > 0 then
			return superGroupIndicator .. " " .. groupData.displayName .. " (" .. collectedCount ..
					" + |cff9d9d9d" .. uncollectedCount .. "|r)"
		elseif collectedCount > 0 then
			return superGroupIndicator .. " " .. groupData.displayName .. " (" .. collectedCount .. ")"
		else
			return "|cff9d9d9d" .. superGroupIndicator .. " " .. groupData.displayName .. " (" .. uncollectedCount .. ")|r"
		end
	elseif groupData.type == "familyName" then
		-- Families get [F] for multi-mount or [M] for single-mount
		local indicator = (totalMounts == 1) and mountIndicator or familyIndicator
		if totalMounts == 1 then
			-- Single mount family - use [M] indicator
			if collectedCount == 1 then
				return indicator .. " " .. groupData.displayName .. ""
			else
				return "|cff9d9d9d" .. indicator .. " " .. groupData.displayName .. "|r"
			end
		else
			-- Multi-mount family - use [F] indicator
			if collectedCount > 0 and uncollectedCount > 0 then
				return indicator .. " " .. groupData.displayName .. " (" .. collectedCount ..
						" + |cff9d9d9d" .. uncollectedCount .. "|r)"
			elseif collectedCount > 0 then
				return indicator .. " " .. groupData.displayName .. " (" .. collectedCount .. ")"
			else
				return "|cff9d9d9d" .. indicator .. " " .. groupData.displayName .. " (" .. uncollectedCount .. ")|r"
			end
		end
	else
		-- Fallback for unknown types
		return groupData.displayName or groupData.key
	end
end

-- Create mount list for family or supergroup
function MountUIComponents:BuildMountList(groupKey, groupType, startOrder)
	local mountList = {}
	local order = startOrder
	local showUncollected = addon:GetSetting("showUncollectedMounts")
	-- Get collected mounts
	local mountIDs = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[groupKey] or {}
	for _, mountID in ipairs(mountIDs) do
		if addon.processedData.allCollectedMountFamilyInfo and
				addon.processedData.allCollectedMountFamilyInfo[mountID] then
			local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
			table.insert(mountList, {
				id = mountID,
				name = mountInfo.name or ("ID:" .. mountID),
				isCollected = true,
			})
		end
	end

	-- Get uncollected mounts if enabled
	if showUncollected then
		local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[groupKey] or {}
		for _, mountID in ipairs(uncollectedIDs) do
			if addon.processedData.allUncollectedMountFamilyInfo and
					addon.processedData.allUncollectedMountFamilyInfo[mountID] then
				local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
				table.insert(mountList, {
					id = mountID,
					name = mountInfo.name or ("ID:" .. mountID),
					isCollected = false,
				})
			end
		end
	end

	-- Sort alphabetically
	table.sort(mountList, function(a, b)
		return (a.name or "") < (b.name or "")
	end)
	-- Build UI entries
	local entries = {}
	for _, mountData in ipairs(mountList) do
		local mountEntry = self:BuildMountEntry(mountData, order)
		for k, v in pairs(mountEntry) do
			entries["mount_" .. mountData.id .. "_" .. k] = v
		end

		order = order + 2 -- Leave space between mounts
	end

	return entries
end

print("RMB_DEBUG: MountUIComponents.lua (Enhanced Conditional Controls) END.")
