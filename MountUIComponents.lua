-- MountUIComponents.lua - Fixed for Clean Module Architecture
-- Reusable UI component builders for mount interface
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountUIComponents.lua (Fixed) START.")
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
-- CORE COMPONENT BUILDERS
-- ============================================================================
-- Create preview button component
function MountUIComponents:CreatePreviewButton(groupKey, groupType, order)
	return {
		order = order or 0.2,
		type = "execute",
		name = "|TInterface\\UIEditorIcons\\UIEditorIcons:20:20:0:-1|t",
		desc = function()
			-- Use clean module interface
			return addon:GetMountPreviewTooltip(groupKey, groupType)
		end,
		func = function(info)
			local includeUncollected = addon:GetSetting("showUncollectedMounts")
			local mountID, mountName, isUncollected = addon:GetRandomMountFromGroup(
				groupKey, groupType, includeUncollected)
			if mountID then
				addon:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
			else
				print("RMB_PREVIEW: No mount available to preview from this group")
			end
		end,
		width = 0.3,
	}
end

-- Create weight control components
function MountUIComponents:CreateWeightControls(groupKey, startOrder)
	local order = startOrder or 2
	return {
		weightDecrement = {
			order = order,
			type = "execute",
			name = "",
			func = function() addon:DecrementGroupWeight(groupKey) end,
			disabled = function() return addon:GetGroupWeight(groupKey) == 0 end,
			width = 0.05,
			image = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up",
			imageWidth = 16,
			imageHeight = 20,
		},
		weightDisplay = {
			order = order + 1,
			type = "description",
			name = function()
				return self:GetWeightDisplayString(addon:GetGroupWeight(groupKey))
			end,
			width = 0.5,
		},
		weightIncrement = {
			order = order + 2,
			type = "execute",
			name = "",
			func = function() addon:IncrementGroupWeight(groupKey) end,
			disabled = function() return addon:GetGroupWeight(groupKey) == 6 end,
			width = 0.05,
			image = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
			imageWidth = 16,
			imageHeight = 20,
		},
	}
end

-- Create trait toggle components
function MountUIComponents:CreateTraitToggles(groupKey, groupType, traits, shouldShow, startOrder)
	local order = startOrder or 7
	-- If traits shouldn't be shown, return spacer
	if not shouldShow then
		return {
			spacerNoToggles = {
				order = order,
				type = "description",
				name = " ",
				width = 1.2,
			},
		}
	end

	-- Return actual trait toggles
	return {
		toggleMinorArmor = {
			order = order,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_GreenArmor:20:20:0:-2|t",
			desc = "Small armor or ornaments",
			get = function() return traits.hasMinorArmor or false end,
			set = function() end, -- Read-only for now
			width = 0.30,
			disabled = true,
		},
		toggleMajorArmor = {
			order = order + 0.1,
			type = "toggle",
			name = "|TInterface\\ICONS\\Garrison_BlueArmor:20:20:0:-2|t",
			desc = "Bulky armor or many ornaments",
			get = function() return traits.hasMajorArmor or false end,
			set = function() end,
			width = 0.30,
			disabled = true,
		},
		toggleModelVariant = {
			order = order + 0.2,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Green:20:20:0:-2|t",
			desc = "Updated texture/slightly different model",
			get = function() return traits.hasModelVariant or false end,
			set = function() end,
			width = 0.30,
			disabled = true,
		},
		toggleUniqueEffect = {
			order = order + 0.3,
			type = "toggle",
			name = "|TInterface\\ICONS\\INV_10_GearUpgrade_Flightstone_Blue:20:20:0:-2|t",
			desc = "Unique variant, stands out from the rest",
			get = function() return traits.isUniqueEffect or false end,
			set = function() end,
			width = 0.30,
			disabled = true,
		},
	}
end

-- Create spacing components
function MountUIComponents:CreateSpacers(startOrder)
	local order = startOrder or 0.3
	return {
		spacerBeforeName = {
			order = order,
			type = "description",
			name = " ",
			width = 0.05,
		},
		spaceAfterName = {
			order = order + 0.8,
			type = "description",
			name = " ",
			width = 0.08,
		},
		spacerToggles = {
			order = order + 3.7,
			type = "description",
			name = " ",
			width = 0.12,
		},
	}
end

-- Create expand/collapse button
function MountUIComponents:CreateExpandButton(groupKey, isExpanded, isSingleMount, order)
	return {
		order = order or 8,
		type = "execute",
		name = "",
		func = function() addon:ToggleExpansionState(groupKey) end,
		width = 0.3,
		hidden = isSingleMount,
		image = isExpanded and "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonUpLargev11" or
				"Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonDownLargev11",
		imageWidth = 40,
		imageHeight = 20,
	}
end

-- ============================================================================
-- COMPLETE GROUP ENTRY BUILDER
-- ============================================================================
-- Build a complete group entry (main level - supergroup or standalone family)
function MountUIComponents:BuildGroupEntry(groupData, isExpanded, expandedDetails)
	local groupKey = groupData.key
	-- Get traits and display info safely
	local shouldShowTraits = false
	local traits = {}
	-- Use MountDataManager if available, otherwise fallback
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
		-- Fallback display name creation
		displayName = self:CreateFallbackDisplayName(groupData)
	end

	-- Build entry components
	local entry = {
		previewButton = self:CreatePreviewButton(groupKey, groupData.type, 0.2),
		group_name = {
			order = 1,
			type = "description",
			name = displayName,
			width = 1.0,
			fontSize = "medium",
		},
		expandCollapse = self:CreateExpandButton(groupKey, isExpanded, isSingleMountFamily, 8),
	}
	-- Add spacers
	local spacers = self:CreateSpacers(0.3)
	for k, v in pairs(spacers) do
		entry[k] = v
	end

	-- Add weight controls
	local weightControls = self:CreateWeightControls(groupKey, 2)
	for k, v in pairs(weightControls) do
		entry[k] = v
	end

	-- Add trait toggles
	local traitToggles = self:CreateTraitToggles(groupKey, groupData.type, traits, shouldShowTraits, 7)
	for k, v in pairs(traitToggles) do
		entry[k] = v
	end

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

-- ============================================================================
-- EXPANDED DETAILS BUILDERS
-- ============================================================================
-- Build family entry within a supergroup
function MountUIComponents:BuildFamilyEntry(familyName, familyDisplayName, isExpanded, order)
	-- Get family data safely
	local shouldShowTraits = false
	local traits = {}
	if addon.MountDataManager and addon.MountDataManager.ShouldShowTraits then
		shouldShowTraits = addon.MountDataManager:ShouldShowTraits(familyName, "familyName")
		if shouldShowTraits and addon.MountDataManager.GetFamilyTraits then
			traits = addon.MountDataManager:GetFamilyTraits(familyName) or {}
		end
	end

	local entry = {
		preview = self:CreatePreviewButton(familyName, "familyName", order),
		spacerBeforeName = {
			order = order + 0.1,
			type = "description",
			name = " ",
			width = 0.05,
		},
		name = {
			order = order + 0.2,
			type = "description",
			name = "> " .. familyDisplayName,
			width = 1.0,
			fontSize = "small",
		},
		spacerAfterName = {
			order = order + 0.3,
			type = "description",
			name = " ",
			width = 0.08,
		},
		expand = {
			order = order + 0.9,
			type = "execute",
			name = "",
			func = function() addon:ToggleExpansionState(familyName) end,
			width = 0.3,
			hidden = false,
			image = isExpanded and "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonUpLargev11" or
					"Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonDownLargev11",
			imageWidth = 40,
			imageHeight = 20,
		},
		linebreak = {
			order = order + 1,
			type = "description",
			name = "",
			width = "full",
		},
	}
	-- Add weight controls
	local weightControls = self:CreateWeightControls(familyName, order + 0.4)
	for k, v in pairs(weightControls) do
		entry["weight_" .. k] = v
	end

	-- Add trait toggles or spacer
	local traitToggles = self:CreateTraitToggles(familyName, "familyName", traits, shouldShowTraits, order + 0.7)
	for k, v in pairs(traitToggles) do
		entry["trait_" .. k] = v
	end

	return entry
end

-- Build individual mount entry
function MountUIComponents:BuildMountEntry(mountData, order, familyPrefix)
	local mountID = mountData.id
	local mountName = mountData.name
	local isCollected = mountData.isCollected
	-- Create display name with color
	local nameColor = isCollected and "ffffff" or "9d9d9d"
	local collectionStatus = isCollected and "" or ""
	local displayName = "|cff" .. nameColor .. "  >> " .. mountName .. collectionStatus .. "|r"
	local entry = {
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
			width = 0.3,
		},
		spacerBeforeName = {
			order = order + 0.1,
			type = "description",
			name = " ",
			width = 0.05,
		},
		name = {
			order = order + 0.2,
			type = "description",
			name = displayName,
			fontSize = "small",
			width = 1.0,
		},
		spacerAfterName = {
			order = order + 0.3,
			type = "description",
			name = " ",
			width = 0.08,
		},
		spacerToggles = {
			order = order + 0.7,
			type = "description",
			name = " ",
			width = 1.2, -- No traits for individual mounts
		},
		linebreak = {
			order = order + 1,
			type = "description",
			name = "",
			width = "full",
		},
	}
	-- Add weight controls
	local weightControls = self:CreateWeightControls("mount_" .. mountID, order + 0.4)
	for k, v in pairs(weightControls) do
		entry["weight_" .. k] = v
		-- Apply gray color for uncollected mounts
		if k == "weightDisplay" and not isCollected then
			local originalFunc = v.name
			v.name = function()
				local weightStr = originalFunc()
				if not weightStr:find("|cff") then
					return "|cff9d9d9d" .. weightStr .. "|r"
				end

				return weightStr
			end
		end
	end

	return entry
end

-- ============================================================================
-- PAGINATION COMPONENTS
-- ============================================================================
function MountUIComponents:CreatePaginationControls(currentPage, totalPages, order)
	if totalPages <= 1 then
		return {}
	end

	return {
		pagination_controls = {
			order = order,
			type = "group",
			inline = true,
			name = "",
			width = "full",
			args = {
				first_button = {
					order = 1,
					type = "execute",
					name = "<<",
					disabled = (currentPage <= 1),
					func = function() addon:FMG_GoToFirstPage() end,
					width = 0.5,
				},
				prev_button = {
					order = 2,
					type = "execute",
					name = "<",
					disabled = (currentPage <= 1),
					func = function() addon:FMG_PrevPage() end,
					width = 0.5,
				},
				page_info = {
					order = 3,
					type = "description",
					name = string.format("                                    %d / %d", currentPage, totalPages),
					width = 1.6,
				},
				next_button = {
					order = 4,
					type = "execute",
					name = ">",
					disabled = (currentPage >= totalPages),
					func = function() addon:FMG_NextPage() end,
					width = 0.5,
				},
				last_button = {
					order = 5,
					type = "execute",
					name = ">>",
					disabled = (currentPage >= totalPages),
					func = function() addon:FMG_GoToLastPage() end,
					width = 0.5,
				},
			},
		},
	}
end

-- ============================================================================
-- HEADER COMPONENTS
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
					name = "     |cffffd700Summon Chance|r",
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
-- UTILITY FUNCTIONS
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
	-- Special handling for single mount families
	if groupData.type == "familyName" and (collectedCount + uncollectedCount) == 1 then
		if collectedCount == 1 then
			return groupData.displayName .. " (Mount)"
		else
			return "|cff9d9d9d" .. groupData.displayName .. " (Mount)|r"
		end
	else
		-- Multi-mount family or supergroup
		if collectedCount > 0 and uncollectedCount > 0 then
			return groupData.displayName .. " (" .. collectedCount ..
					" + |cff9d9d9d" .. uncollectedCount .. "|r)"
		elseif collectedCount > 0 then
			return groupData.displayName .. " (" .. collectedCount .. ")"
		else
			return "|cff9d9d9d" .. groupData.displayName .. " (" .. uncollectedCount .. ")|r"
		end
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

print("RMB_DEBUG: MountUIComponents.lua (Fixed) END.")
