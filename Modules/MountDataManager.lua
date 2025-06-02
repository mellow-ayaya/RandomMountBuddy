-- MountDataManager.lua
-- Centralized data processing and caching for mount information
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("MountDataManager.lua START.")
-- ============================================================================
-- DATA MANAGER CLASS
-- ============================================================================
local MountDataManager = {}
addon.MountDataManager = MountDataManager
-- Initialize the data manager
function MountDataManager:Initialize()
	addon:DebugData(" Initializing...")
	-- Cache system
	self.cache = {
		familyTraits = {},
		displayNames = {},
		mountCounts = {},
		groupTypes = {},
		processedGroups = {},
		lastCacheTime = 0,

		-- Cache management
		clear = function(cache)
			cache.familyTraits = {}
			cache.displayNames = {}
			cache.mountCounts = {}
			cache.groupTypes = {}
			cache.processedGroups = {}
			cache.lastCacheTime = GetTime()
			addon:DebugData("RMB_CACHE: Cleared all data caches")
		end,

		isValid = function(cache)
			return (GetTime() - cache.lastCacheTime) < 300 -- 5 minute cache
		end,
	}
	-- Unified group system (replaces the multiple overlapping systems)
	self.unifiedGroups = {
		groups = {}, -- All groups by key
		byType = { -- Groups organized by type
			superGroup = {},
			familyName = {},
		},
		displayOrder = {}, -- Sorted array for UI display
		lastBuilt = 0,   -- When this was last built
	}
	addon:DebugData(" Initialized successfully")
end

function MountDataManager:OnMountCollectionChanged()
	addon:DebugData(" Mount collection changed, invalidating caches...")
	-- Clear all caches since mount collection has changed
	self:InvalidateCache("mount_collection_changed")
	-- Rebuild unified group system
	self:BuildUnifiedGroupSystem()
	addon:DebugData(" Cache invalidation completed")
end

-- ============================================================================
-- UNIFIED GROUP PROCESSING (replaces multiple family systems)
-- ============================================================================
function MountDataManager:BuildUnifiedGroupSystem()
	addon:DebugData(" Building unified group system...")
	if not addon.processedData then
		addon:DebugData(" No processed data available")
		return
	end

	-- Clear existing
	self.unifiedGroups.groups = {}
	self.unifiedGroups.byType = { superGroup = {}, familyName = {} }
	self.unifiedGroups.displayOrder = {}
	local showUncollected = addon:GetSetting("showUncollectedMounts")
	-- Use dynamic grouping if available, otherwise fall back to original
	local superGroupMap = addon.processedData.dynamicSuperGroupMap or addon.processedData.superGroupMap
	local standaloneFamilies = addon.processedData.dynamicStandaloneFamilies or addon.processedData.standaloneFamilyNames
	-- Process supergroups
	for sgName, familyList in pairs(superGroupMap or {}) do
		local collectedCount = addon.processedData.superGroupToMountIDsMap and
				#(addon.processedData.superGroupToMountIDsMap[sgName] or {}) or 0
		local uncollectedCount = 0
		if showUncollected and addon.processedData.superGroupToUncollectedMountIDsMap then
			uncollectedCount = #(addon.processedData.superGroupToUncollectedMountIDsMap[sgName] or {})
		end

		-- Only include if has mounts
		if collectedCount > 0 or (showUncollected and uncollectedCount > 0) then
			local groupData = {
				key = sgName,
				type = "superGroup",
				displayName = sgName,
				mountCount = collectedCount,
				uncollectedCount = uncollectedCount,
				familiesInGroup = #(familyList or {}),
				-- Pre-compute expensive values
				traits = {}, -- Supergroups don't have traits
				shouldShowTraits = false,
			}
			self.unifiedGroups.groups[sgName] = groupData
			table.insert(self.unifiedGroups.byType.superGroup, sgName)
			table.insert(self.unifiedGroups.displayOrder, groupData)
		end
	end

	-- Process standalone families
	for familyName, _ in pairs(standaloneFamilies or {}) do
		local collectedCount = addon.processedData.familyToMountIDsMap and
				#(addon.processedData.familyToMountIDsMap[familyName] or {}) or 0
		local uncollectedCount = 0
		if showUncollected and addon.processedData.familyToUncollectedMountIDsMap then
			uncollectedCount = #(addon.processedData.familyToUncollectedMountIDsMap[familyName] or {})
		end

		-- Only include if has mounts
		if collectedCount > 0 or (showUncollected and uncollectedCount > 0) then
			-- Pre-compute traits for this family
			local traits = self:GetFamilyTraits(familyName)
			local shouldShowTraits = self:ShouldShowTraits(familyName, "familyName")
			local groupData = {
				key = familyName,
				type = "familyName",
				displayName = familyName,
				mountCount = collectedCount,
				uncollectedCount = uncollectedCount,
				-- Pre-computed values
				traits = traits,
				shouldShowTraits = shouldShowTraits,
			}
			self.unifiedGroups.groups[familyName] = groupData
			table.insert(self.unifiedGroups.byType.familyName, familyName)
			table.insert(self.unifiedGroups.displayOrder, groupData)
		end
	end

	-- Sort display order
	table.sort(self.unifiedGroups.displayOrder, function(a, b)
		return (a.displayName or "") < (b.displayName or "")
	end)
	self.unifiedGroups.lastBuilt = GetTime()
	addon:DebugData(" Built unified group system - " ..
		#self.unifiedGroups.displayOrder .. " total groups")
end

-- Get all displayable groups (optimized version)
function MountDataManager:GetDisplayableGroups()
	-- Check if unified group system needs rebuilding
	if not self.unifiedGroups.lastBuilt or
			(GetTime() - self.unifiedGroups.lastBuilt) > 60 or
			#self.unifiedGroups.displayOrder == 0 then
		self:BuildUnifiedGroupSystem()
	end

	return self.unifiedGroups.displayOrder
end

-- Get specific group data
function MountDataManager:GetGroupData(groupKey)
	if not self.unifiedGroups.groups[groupKey] then
		-- Rebuild if group not found
		self:BuildUnifiedGroupSystem()
	end

	return self.unifiedGroups.groups[groupKey]
end

-- ============================================================================
-- TRAIT MANAGEMENT (cleaned up and cached)
-- ============================================================================
function MountDataManager:GetFamilyTraits(familyName)
	if not familyName then return {} end

	-- Check cache first
	local cacheKey = familyName .. "_effective"
	if self.cache.familyTraits[cacheKey] then
		return self.cache.familyTraits[cacheKey]
	end

	-- Use effective traits from addon (includes user overrides)
	local effectiveTraits = {}
	if addon.GetEffectiveTraits then
		effectiveTraits = addon:GetEffectiveTraits(familyName)
	else
		-- Fallback to original logic if GetEffectiveTraits not available
		local mountIDs = addon.processedData.familyToMountIDsMap and
				addon.processedData.familyToMountIDsMap[familyName]
		if not mountIDs or #mountIDs == 0 then
			mountIDs = addon.processedData.familyToUncollectedMountIDsMap and
					addon.processedData.familyToUncollectedMountIDsMap[familyName]
		end

		if mountIDs and #mountIDs > 0 then
			local mountID = mountIDs[1]
			local mountInfo = addon.processedData.allCollectedMountFamilyInfo and
					addon.processedData.allCollectedMountFamilyInfo[mountID]
			if not mountInfo then
				mountInfo = addon.processedData.allUncollectedMountFamilyInfo and
						addon.processedData.allUncollectedMountFamilyInfo[mountID]
			end

			if mountInfo and mountInfo.traits then
				effectiveTraits = mountInfo.traits
			end
		end
	end

	-- Cache and return
	self.cache.familyTraits[cacheKey] = effectiveTraits or {}
	return self.cache.familyTraits[cacheKey]
end

-- Add method to invalidate cache when traits change
function MountDataManager:InvalidateTraitCache(familyName)
	if familyName then
		local cacheKey = familyName .. "_effective"
		self.cache.familyTraits[cacheKey] = nil
		addon:DebugData(" Invalidated trait cache for " .. familyName)
	else
		-- Clear all trait caches
		for k, v in pairs(self.cache.familyTraits) do
			if k:find("_effective$") then
				self.cache.familyTraits[k] = nil
			end
		end

		addon:DebugData(" Invalidated all effective trait caches")
	end
end

function MountDataManager:ShouldShowTraits(groupKey, groupType)
	if groupType ~= "familyName" then
		return false -- Only families have traits
	end

	local cacheKey = groupKey .. "_" .. groupType
	if self.cache.groupTypes[cacheKey] ~= nil then
		return self.cache.groupTypes[cacheKey]
	end

	local shouldShow = false
	-- FIX: Check if this is a separated family first
	if addon.db and addon.db.profile and addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			if separationData.familyName == groupKey then
				shouldShow = true
				addon:DebugUI("Showing traits for separated family: " .. groupKey)
				self.cache.groupTypes[cacheKey] = shouldShow
				return shouldShow
			end
		end
	end

	-- Check if this family originally belonged to a supergroup
	local mountIDs = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[groupKey]
	if not mountIDs or #mountIDs == 0 then
		mountIDs = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[groupKey]
	end

	if mountIDs and #mountIDs > 0 then
		local mountID = mountIDs[1]
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo and
				addon.processedData.allCollectedMountFamilyInfo[mountID]
		if not mountInfo then
			mountInfo = addon.processedData.allUncollectedMountFamilyInfo and
					addon.processedData.allUncollectedMountFamilyInfo[mountID]
		end

		if mountInfo then
			-- Check if it has original superGroup OR if it's a separated family
			if mountInfo.superGroup then
				shouldShow = true
			end
		end
	end

	self.cache.groupTypes[cacheKey] = shouldShow
	return shouldShow
end

-- ============================================================================
-- DISPLAY NAME GENERATION (cached and optimized)
-- ============================================================================
function MountDataManager:GetGroupDisplayName(groupInfo)
	local cacheKey = groupInfo.key .. "_" .. groupInfo.type .. "_" ..
			(groupInfo.mountCount or 0) .. "_" .. (groupInfo.uncollectedCount or 0)
	if self.cache.displayNames[cacheKey] then
		return self.cache.displayNames[cacheKey]
	end

	local displayName
	local collectedCount = groupInfo.mountCount or 0
	local uncollectedCount = groupInfo.uncollectedCount or 0
	local totalMounts = collectedCount + uncollectedCount
	-- Define color codes for indicators
	local superGroupIndicator = "|cffa335ee[G]|r" -- Purple
	local familyIndicator = "|cff0070dd[F]|r"    -- Blue
	local mountIndicator = "|cff1eff00[M]|r"     -- Green
	if groupInfo.type == "superGroup" then
		-- Supergroups always get [G] indicator
		if collectedCount > 0 and uncollectedCount > 0 then
			displayName = superGroupIndicator .. " " .. groupInfo.displayName .. " (" .. collectedCount ..
					" + |cff9d9d9d" .. uncollectedCount .. "|r)"
		elseif collectedCount > 0 then
			displayName = superGroupIndicator .. " " .. groupInfo.displayName .. " (" .. collectedCount .. ")"
		else
			displayName = "|cff9d9d9d" ..
					superGroupIndicator .. " " .. groupInfo.displayName .. " (" .. uncollectedCount .. ")|r"
		end
	elseif groupInfo.type == "familyName" then
		-- Families get [F] for multi-mount or [M] for single-mount
		local indicator = (totalMounts == 1) and mountIndicator or familyIndicator
		if totalMounts == 1 then
			-- Single mount family - use [M] indicator
			if collectedCount == 1 then
				displayName = indicator .. " " .. groupInfo.displayName .. ""
			else
				displayName = "|cff9d9d9d" .. indicator .. " " .. groupInfo.displayName .. "|r"
			end
		else
			-- Multi-mount family - use [F] indicator
			if collectedCount > 0 and uncollectedCount > 0 then
				displayName = indicator .. " " .. groupInfo.displayName .. " (" .. collectedCount ..
						" + |cff9d9d9d" .. uncollectedCount .. "|r)"
			elseif collectedCount > 0 then
				displayName = indicator .. " " .. groupInfo.displayName .. " (" .. collectedCount .. ")"
			else
				displayName = "|cff9d9d9d" .. indicator .. " " .. groupInfo.displayName .. " (" .. uncollectedCount .. ")|r"
			end
		end
	else
		-- Fallback for unknown types
		displayName = groupInfo.displayName or groupInfo.key
	end

	-- Apply custom supergroup display names
	if groupInfo.type == "superGroup" and addon.db and addon.db.profile and
			addon.db.profile.superGroupDefinitions then
		local customDef = addon.db.profile.superGroupDefinitions[groupInfo.key]
		if customDef and customDef.displayName then
			-- Replace the base name with custom display name, but keep formatting
			local baseName = groupInfo.displayName
			local customName = customDef.displayName
			-- Update displayName by replacing the original name with custom name
			if groupInfo.type == "superGroup" then
				if collectedCount > 0 and uncollectedCount > 0 then
					displayName = superGroupIndicator .. " " .. customName .. " (" .. collectedCount ..
							" + |cff9d9d9d" .. uncollectedCount .. "|r)"
				elseif collectedCount > 0 then
					displayName = superGroupIndicator .. " " .. customName .. " (" .. collectedCount .. ")"
				else
					displayName = "|cff9d9d9d" ..
							superGroupIndicator .. " " .. customName .. " (" .. uncollectedCount .. ")|r"
				end
			end
		end
	end

	self.cache.displayNames[cacheKey] = displayName
	return displayName
end

-- ============================================================================
-- MOUNT SELECTION (optimized)
-- ============================================================================
function MountDataManager:GetRandomMountFromGroup(groupKey, groupType, includeUncollected)
	addon:DebugData(" GetRandomMountFromGroup called for " .. tostring(groupKey))
	if not groupKey then
		return nil
	end

	-- Default to including uncollected if not specified
	if includeUncollected == nil then
		includeUncollected = addon:GetSetting("showUncollectedMounts")
	end

	-- Check if it's a direct mount ID reference
	if type(groupKey) == "string" and string.match(groupKey, "^mount_(%d+)$") then
		local mountID = tonumber(string.match(groupKey, "^mount_(%d+)$"))
		return self:GetDirectMount(mountID, includeUncollected)
	end

	-- Determine group type if not provided
	if not groupType then
		groupType = self:GetGroupTypeFromKey(groupKey)
	end

	-- Get mounts based on group type
	local collectedMounts, uncollectedMounts = self:GetMountsForGroup(groupKey, groupType, includeUncollected)
	-- Select a mount (prioritize collected)
	if #collectedMounts > 0 then
		local randomIndex = math.random(1, #collectedMounts)
		local selectedMount = collectedMounts[randomIndex]
		return selectedMount.id, selectedMount.name, false
	elseif includeUncollected and #uncollectedMounts > 0 then
		local randomIndex = math.random(1, #uncollectedMounts)
		local selectedMount = uncollectedMounts[randomIndex]
		return selectedMount.id, selectedMount.name, true
	end

	return nil
end

function MountDataManager:GetDirectMount(mountID, includeUncollected)
	if not mountID then return nil end

	-- Check collected mounts first
	if addon.processedData.allCollectedMountFamilyInfo and
			addon.processedData.allCollectedMountFamilyInfo[mountID] then
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
		return mountID, mountInfo.name, false
	end

	-- Check uncollected if enabled
	if includeUncollected and addon.processedData.allUncollectedMountFamilyInfo and
			addon.processedData.allUncollectedMountFamilyInfo[mountID] then
		local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
		return mountID, mountInfo.name, true
	end

	return nil
end

function MountDataManager:GetMountsForGroup(groupKey, groupType, includeUncollected)
	local collectedMounts = {}
	local uncollectedMounts = {}
	if groupType == "familyName" then
		-- Get mounts from family
		local collectedIDs = addon.processedData.familyToMountIDsMap and
				addon.processedData.familyToMountIDsMap[groupKey] or {}
		for _, mountID in ipairs(collectedIDs) do
			if addon.processedData.allCollectedMountFamilyInfo and
					addon.processedData.allCollectedMountFamilyInfo[mountID] then
				local info = addon.processedData.allCollectedMountFamilyInfo[mountID]
				table.insert(collectedMounts, {
					id = mountID,
					name = info.name or ("Mount ID " .. mountID),
					isUncollected = false,
				})
			end
		end

		if includeUncollected then
			local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap and
					addon.processedData.familyToUncollectedMountIDsMap[groupKey] or {}
			for _, mountID in ipairs(uncollectedIDs) do
				if addon.processedData.allUncollectedMountFamilyInfo and
						addon.processedData.allUncollectedMountFamilyInfo[mountID] then
					local info = addon.processedData.allUncollectedMountFamilyInfo[mountID]
					table.insert(uncollectedMounts, {
						id = mountID,
						name = info.name or ("Mount ID " .. mountID),
						isUncollected = true,
					})
				end
			end
		end
	elseif groupType == "superGroup" then
		-- Get mounts from supergroup
		local collectedIDs = addon.processedData.superGroupToMountIDsMap and
				addon.processedData.superGroupToMountIDsMap[groupKey] or {}
		for _, mountID in ipairs(collectedIDs) do
			if addon.processedData.allCollectedMountFamilyInfo and
					addon.processedData.allCollectedMountFamilyInfo[mountID] then
				local info = addon.processedData.allCollectedMountFamilyInfo[mountID]
				table.insert(collectedMounts, {
					id = mountID,
					name = info.name or ("Mount ID " .. mountID),
					isUncollected = false,
				})
			end
		end

		if includeUncollected then
			local uncollectedIDs = addon.processedData.superGroupToUncollectedMountIDsMap and
					addon.processedData.superGroupToUncollectedMountIDsMap[groupKey] or {}
			for _, mountID in ipairs(uncollectedIDs) do
				if addon.processedData.allUncollectedMountFamilyInfo and
						addon.processedData.allUncollectedMountFamilyInfo[mountID] then
					local info = addon.processedData.allUncollectedMountFamilyInfo[mountID]
					table.insert(uncollectedMounts, {
						id = mountID,
						name = info.name or ("Mount ID " .. mountID),
						isUncollected = true,
					})
				end
			end
		end
	end

	return collectedMounts, uncollectedMounts
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
function MountDataManager:GetGroupTypeFromKey(groupKey)
	if not groupKey then return nil end

	-- Check if it's a direct mount reference
	if type(groupKey) == "string" and string.match(groupKey, "^mount_(%d+)$") then
		return "mountID"
	end

	-- Use unified group system
	local groupData = self:GetGroupData(groupKey)
	if groupData then
		return groupData.type
	end

	return nil
end

function MountDataManager:InvalidateCache(reason)
	addon:DebugData(" Invalidating cache - " .. tostring(reason))
	self.cache:clear()
	-- Also invalidate unified group system if settings changed
	if reason == "settings_changed" then
		self.unifiedGroups.lastBuilt = 0
	end
end

-- Hook into setting changes to invalidate cache
function MountDataManager:OnSettingChanged(key, value)
	-- Clear cache for settings that affect display
	if key == "showUncollectedMounts" or key == "useSuperGrouping" or
			key:find("treatMinorArmorAsDistinct") or key:find("treatMajorArmorAsDistinct") or
			key:find("treatModelVariantsAsDistinct") or key:find("treatUniqueEffectsAsDistinct") then
		self:InvalidateCache("settings_changed")
	end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Initialize when addon loads
function addon:InitializeMountDataManager()
	if not self.MountDataManager then
		addon:DebugData(" ERROR - MountDataManager not found!")
		return
	end

	self.MountDataManager:Initialize()
	addon:DebugData(" Integration complete")
end

addon:DebugCore("MountDataManager.lua END.")
