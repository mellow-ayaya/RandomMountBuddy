-- MountTooltips.lua
-- Tooltip management and generation for mount interface
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountTooltips.lua START.")
-- ============================================================================
-- TOOLTIP MANAGER CLASS
-- ============================================================================
local MountTooltips = {}
addon.MountTooltips = MountTooltips
-- ============================================================================
-- TOOLTIP GENERATION
-- ============================================================================
function MountTooltips:Initialize()
	print("RMB_TOOLTIPS: Initializing tooltip system...")
	-- Tooltip cache to prevent repeated lookups
	self.tooltipCache = {}
	self.cacheTimeout = 30 -- 30 second cache
	print("RMB_TOOLTIPS: Initialized successfully")
end

-- Main tooltip generation function
function MountTooltips:GetMountPreviewTooltip(groupKey, groupType)
	print("RMB_TOOLTIPS: Getting tooltip for " .. tostring(groupKey) .. " (" .. tostring(groupType) .. ")")
	-- Check cache first
	local cacheKey = groupKey .. "_" .. (groupType or "")
	local cached = self.tooltipCache[cacheKey]
	if cached and (GetTime() - cached.timestamp) < self.cacheTimeout then
		addon.currentTooltipMount = cached.mountID
		return cached.tooltip
	end

	-- Generate new tooltip
	local tooltip, mountID = self:GenerateTooltip(groupKey, groupType)
	-- Cache the result
	self.tooltipCache[cacheKey] = {
		tooltip = tooltip,
		mountID = mountID,
		timestamp = GetTime(),
	}
	-- Set current tooltip mount for model display
	addon.currentTooltipMount = mountID
	return tooltip
end

function MountTooltips:GenerateTooltip(groupKey, groupType)
	-- Always include uncollected mounts in tooltip if setting is enabled
	local includeUncollected = addon:GetSetting("showUncollectedMounts")
	-- Get a consistent random mount for this tooltip session
	local mountID, mountName, isUncollected
	if addon.MountPreview then
		mountID, mountName, isUncollected = addon.MountPreview:GetConsistentRandomMount(
			groupKey, groupType, includeUncollected)
	else
		-- Fallback if preview system not loaded
		mountID, mountName, isUncollected = addon.MountDataManager:GetRandomMountFromGroup(
			groupKey, groupType, includeUncollected)
	end

	if not mountID then
		print("RMB_TOOLTIPS: No mounts found for " .. tostring(groupKey))
		return "No mounts found in this group", nil
	end

	-- Generate tooltip text
	local tooltip = self:FormatTooltipText(mountID, mountName, isUncollected, groupKey, groupType)
	print("RMB_TOOLTIPS: Generated tooltip for " .. tostring(mountName))
	return tooltip, mountID
end

function MountTooltips:FormatTooltipText(mountID, mountName, isUncollected, groupKey, groupType)
	local lines = {}
	-- Mount name with collection status
	if isUncollected then
		table.insert(lines, "|cff9d9d9dMount: " .. mountName .. " (Uncollected)|r")
	else
		table.insert(lines, "Mount: " .. mountName)
	end

	-- Add group information if available
	if groupKey and groupType then
		if groupType == "superGroup" then
			table.insert(lines, "From: " .. groupKey .. " (Super Group)")
		elseif groupType == "familyName" then
			table.insert(lines, "Family: " .. groupKey)
		end
	end

	-- Add mount details if available
	local mountDetails = self:GetMountDetails(mountID)
	if mountDetails then
		if mountDetails.mountType then
			table.insert(lines, "Type: " .. mountDetails.mountType)
		end

		if mountDetails.source then
			table.insert(lines, "Source: " .. mountDetails.source)
		end
	end

	-- Action hint
	table.insert(lines, "|cff00ff00(Click to open Preview Window)|r")
	return table.concat(lines, "\n")
end

-- ============================================================================
-- MOUNT DETAILS LOOKUP
-- ============================================================================
function MountTooltips:GetMountDetails(mountID)
	if not mountID then return nil end

	-- Try to get mount information from WoW API
	local name, spellID, icon, active, isUsable, sourceType, isFavorite,
	isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID =
			C_MountJournal.GetMountInfoByID(mountID)
	if not name then return nil end

	local details = {
		name = name,
		spellID = spellID,
		icon = icon,
		isUsable = isUsable,
		sourceType = sourceType,
		isFavorite = isFavorite,
		isCollected = isCollected,
	}
	-- Get mount type information
	if addon.mountIDtoTypeID and addon.mountIDtoTypeID[mountID] then
		local typeID = addon.mountIDtoTypeID[mountID]
		if addon.mountTypeTraits and addon.mountTypeTraits[typeID] then
			local traits = addon.mountTypeTraits[typeID]
			if traits.isGround then
				details.mountType = "Ground"
			elseif traits.isSteadyFly or traits.isSkyriding then
				details.mountType = "Flying"
			elseif traits.isAquatic then
				details.mountType = "Aquatic"
			end
		end
	end

	-- Convert source type to readable string
	if sourceType then
		details.source = self:GetSourceTypeString(sourceType)
	end

	return details
end

function MountTooltips:GetSourceTypeString(sourceType)
	local sourceStrings = {
		[1] = "Drop",
		[2] = "Quest",
		[3] = "Vendor",
		[4] = "World Quest",
		[5] = "Achievement",
		[6] = "Profession",
		[7] = "World Event",
		[8] = "Promotion",
		[9] = "Trading Card Game",
		[10] = "Black Market",
	}
	return sourceStrings[sourceType] or "Unknown"
end

-- ============================================================================
-- ADVANCED TOOLTIP FEATURES
-- ============================================================================
-- Generate tooltip with family/group statistics
function MountTooltips:GetDetailedTooltip(groupKey, groupType)
	local tooltip = self:GetMountPreviewTooltip(groupKey, groupType)
	-- Add group statistics
	local stats = self:GetGroupStatistics(groupKey, groupType)
	if stats then
		tooltip = tooltip .. "\n\n" .. stats
	end

	return tooltip
end

function MountTooltips:GetGroupStatistics(groupKey, groupType)
	if not groupKey or not groupType then return nil end

	local lines = {}
	if groupType == "familyName" then
		-- Family statistics
		local collectedCount = addon.processedData.familyToMountIDsMap and
				#(addon.processedData.familyToMountIDsMap[groupKey] or {}) or 0
		local uncollectedCount = 0
		if addon:GetSetting("showUncollectedMounts") and
				addon.processedData.familyToUncollectedMountIDsMap then
			uncollectedCount = #(addon.processedData.familyToUncollectedMountIDsMap[groupKey] or {})
		end

		table.insert(lines, "|cff888888Family Statistics:|r")
		table.insert(lines, "Collected: " .. collectedCount)
		if uncollectedCount > 0 then
			table.insert(lines, "Uncollected: " .. uncollectedCount)
		end
	elseif groupType == "superGroup" then
		-- Supergroup statistics
		local collectedCount = addon.processedData.superGroupToMountIDsMap and
				#(addon.processedData.superGroupToMountIDsMap[groupKey] or {}) or 0
		local uncollectedCount = 0
		if addon:GetSetting("showUncollectedMounts") and
				addon.processedData.superGroupToUncollectedMountIDsMap then
			uncollectedCount = #(addon.processedData.superGroupToUncollectedMountIDsMap[groupKey] or {})
		end

		-- Count families
		local familyCount = 0
		if addon.processedData.superGroupMap and addon.processedData.superGroupMap[groupKey] then
			familyCount = #addon.processedData.superGroupMap[groupKey]
		end

		table.insert(lines, "|cff888888Super Group Statistics:|r")
		table.insert(lines, "Families: " .. familyCount)
		table.insert(lines, "Collected Mounts: " .. collectedCount)
		if uncollectedCount > 0 then
			table.insert(lines, "Uncollected Mounts: " .. uncollectedCount)
		end
	end

	return #lines > 0 and table.concat(lines, "\n") or nil
end

-- ============================================================================
-- TOOLTIP CACHING MANAGEMENT
-- ============================================================================
function MountTooltips:ClearCache()
	self.tooltipCache = {}
	print("RMB_TOOLTIPS: Cleared tooltip cache")
end

function MountTooltips:InvalidateGroup(groupKey, groupType)
	if not groupKey then return end

	local cacheKey = groupKey .. "_" .. (groupType or "")
	self.tooltipCache[cacheKey] = nil
	print("RMB_TOOLTIPS: Invalidated cache for " .. cacheKey)
end

function MountTooltips:CleanExpiredCache()
	local currentTime = GetTime()
	local cleaned = 0
	for key, cached in pairs(self.tooltipCache) do
		if (currentTime - cached.timestamp) >= self.cacheTimeout then
			self.tooltipCache[key] = nil
			cleaned = cleaned + 1
		end
	end

	if cleaned > 0 then
		print("RMB_TOOLTIPS: Cleaned " .. cleaned .. " expired cache entries")
	end
end

-- ============================================================================
-- SPECIAL TOOLTIP TYPES
-- ============================================================================
-- Generate tooltip for individual mount (mount_ID format)
function MountTooltips:GetMountTooltip(mountKey)
	local mountID = tonumber(string.match(mountKey, "^mount_(%d+)$"))
	if not mountID then return "Invalid mount reference" end

	-- Get mount info
	local isCollected = addon.processedData.allCollectedMountFamilyInfo and
			addon.processedData.allCollectedMountFamilyInfo[mountID] ~= nil
	local isUncollected = addon.processedData.allUncollectedMountFamilyInfo and
			addon.processedData.allUncollectedMountFamilyInfo[mountID] ~= nil
	if not isCollected and not isUncollected then
		return "Mount not found"
	end

	local mountInfo = isCollected and addon.processedData.allCollectedMountFamilyInfo[mountID] or
			addon.processedData.allUncollectedMountFamilyInfo[mountID]
	local mountName = mountInfo.name or ("Mount ID " .. mountID)
	-- Set current tooltip mount for model display
	addon.currentTooltipMount = mountID
	return self:FormatTooltipText(mountID, mountName, not isCollected, nil, "mountID")
end

-- Generate simple tooltip without random selection
function MountTooltips:GetStaticTooltip(text, mountID)
	if mountID then
		addon.currentTooltipMount = mountID
	end

	return text or "No information available"
end

-- ============================================================================
-- INTEGRATION HELPERS
-- ============================================================================
-- Called when settings change to invalidate relevant caches
function MountTooltips:OnSettingChanged(key, value)
	if key == "showUncollectedMounts" then
		self:ClearCache()
	end
end

-- Periodic maintenance
function MountTooltips:DoMaintenance()
	self:CleanExpiredCache()
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Auto-initialize when addon loads
function addon:InitializeMountTooltips()
	if not self.MountTooltips then
		print("RMB_TOOLTIPS: ERROR - MountTooltips not found!")
		return
	end

	self.MountTooltips:Initialize()
	-- Set up periodic maintenance
	C_Timer.NewTicker(60, function() -- Every 60 seconds
		self.MountTooltips:DoMaintenance()
	end)
	print("RMB_TOOLTIPS: Integration complete")
end

print("RMB_DEBUG: MountTooltips.lua END.")
