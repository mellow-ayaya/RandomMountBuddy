-- MountSummon.lua - Updated with Weight 6 (Always) Priority Logic
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("MountSummon.lua START (Updated Weight 6 Logic).")
-- ============================================================================
-- MOUNT SUMMON CLASS
-- ============================================================================
local MountSummon = {}
addon.MountSummon = MountSummon
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountSummon:Initialize()
	addon:DebugSummon("Initializing mount summoning system...")
	-- Flight style tracking
	self.isInSkyridingMode = false
	-- Initialize mount pools
	self.mountPools = {
		flying = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		ground = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		underwater = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		groundUsable = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
	}
	-- Zone-specific configuration for G-99 abilities using location IDs
	self.G99_ZONES = {
		[2346] = 1215279, -- Undermine - Original G-99 zone
		[2406] = 1215279, -- Undermine raid - Raid zone
		-- Add more location IDs here as needed
	}
	-- Cache system for zone abilities
	self.zoneAbilityCache = {
		currentLocationID = nil,
		cachedSpellID = nil,
		hasZoneAbility = false,
		lastUpdateTime = 0,
	}
	-- Initialize deterministic summoning
	self:InitializeDeterministicSystem()
	-- Set up flight style tracking
	self:CheckCurrentFlightStyle()
	self:RegisterFlightStyleEvents()
	addon:DebugSummon("Initialized successfully")
end

function MountSummon:OnMountCollectionChanged()
	addon:DebugSummon("Mount collection changed, rebuilding pools...")
	-- Rebuild pools if data is ready
	if addon.RMB_DataReadyForUI and addon.processedData then
		self:BuildMountPools()
		addon:DebugSummon("Mount pools rebuilt successfully")
	else
		addon:DebugSummon("Skipping pool rebuild - data not ready")
	end
end

-- ============================================================================
-- MOUNT TYPE & CAPABILITY DETECTION
-- ============================================================================
-- Get dynamic mount type traits that adjust based on current flight mode
function MountSummon:GetEffectiveMountTypeTraits(mountID)
	-- Get the base mount traits
	local baseTraits = self:GetMountTypeTraits(mountID)
	-- Get the mount's type ID to check for special cases
	local typeID = addon.mountIDtoTypeID[mountID]
	if not typeID then
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		typeID = mountType
	end

	-- Handle mount type 436 (and potentially others) with dynamic capabilities
	if typeID == 436 then
		-- Mount type 436: All capabilities in steady flight, limited in skyriding
		local effectiveTraits = {}
		for k, v in pairs(baseTraits) do
			effectiveTraits[k] = v
		end

		-- If in skyriding mode, aquatic capability is disabled
		if self.isInSkyridingMode then
			effectiveTraits.isAquatic = false
			addon:DebugSummon("Mount " .. mountID .. " (type 436): Aquatic disabled in skyriding mode")
		else
			-- In steady flight mode, all capabilities are available
			effectiveTraits.isAquatic = baseTraits.isAquatic
			addon:DebugSummon("Mount " .. mountID .. " (type 436): All capabilities available in steady flight mode")
		end

		return effectiveTraits
	end

	-- For all other mount types, return base traits unchanged
	return baseTraits
end

function MountSummon:CanMountFlyEffective(mountID)
	local traits = self:GetEffectiveMountTypeTraits(mountID)
	return traits.isSteadyFly or traits.isSkyriding
end

function MountSummon:CanMountSkyridingEffective(mountID)
	local traits = self:GetEffectiveMountTypeTraits(mountID)
	return traits.isSkyriding
end

function MountSummon:CanMountSwimEffective(mountID)
	local traits = self:GetEffectiveMountTypeTraits(mountID)
	return traits.isAquatic
end

-- Get mount type traits for a given mount ID
function MountSummon:GetMountTypeTraits(mountID)
	-- Get the mount's type ID
	local typeID = addon.mountIDtoTypeID[mountID]
	if not typeID then
		-- If mount ID not in our mapping, get it from API
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		typeID = mountType
	end

	-- Get traits for this type
	local traits = addon.mountTypeTraits[typeID]
	-- Return found traits or default
	return traits or {
		isGround = true, -- Default to ground mount
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	}
end

function MountSummon:IsPlayerTrulyUnderwater()
	-- Get breath timer info (index 2 = BREATH timer)
	local breathTimer, breathInitial, breathMax, breathScale, breathPaused = GetMirrorTimerInfo(2)
	local breathValue = GetMirrorTimerProgress("BREATH")
	-- Only consider truly underwater if:
	-- 1. Breath timer is active (type = "BREATH")
	-- 2. Breath value > 0
	-- 3. Breath is decreasing (scale < 0)
	local isBreathActive = (breathTimer == "BREATH" and breathValue > 0)
	local isBreathDecreasing = isBreathActive and breathScale and breathScale < 0
	addon:DebugSummon("Breath check - Timer: " .. tostring(breathTimer) ..
		", Value: " .. tostring(breathValue) ..
		", Scale: " .. tostring(breathScale) ..
		", Decreasing: " .. tostring(isBreathDecreasing))
	return isBreathDecreasing
end

-- Function to check current flight style using C_Spell.GetSpellInfo
function MountSummon:CheckCurrentFlightStyle()
	-- Check for "Switch to Steady Flight" (460002) spell - if present, player is in skyriding mode
	-- Check for "Switch to Dragonriding" (460003) spell - if present, player is in steady flight mode
	local steadySpellID = 460003   -- Switch TO skyriding (player is currently in steady flight)
	local skyridingSpellID = 460002 -- Switch TO steady flight (player is currently in skyriding)
	-- Use C_Spell.GetSpellInfo to check if the player knows these spells
	local skyridingSpellInfo = C_Spell.GetSpellInfo(skyridingSpellID)
	local steadySpellInfo = C_Spell.GetSpellInfo(steadySpellID)
	if skyridingSpellInfo then
		-- If "Switch to Steady Flight" spell is known, player is in skyriding mode
		self.isInSkyridingMode = true
		addon:DebugCore("Flight style check - Player is in SKYRIDING mode")
		return true
	elseif steadySpellInfo then
		-- If "Switch to Dragonriding" spell is known, player is in steady flight mode
		self.isInSkyridingMode = false
		addon:DebugCore("Flight style check - Player is in STEADY FLIGHT mode")
		return false
	else
		-- If neither spell is known, default to steady flight
		self.isInSkyridingMode = false
		addon:DebugCore("Flight style check - Could not determine style, defaulting to STEADY FLIGHT")
		return false
	end
end

-- Register for events to track flight style changes
function MountSummon:RegisterFlightStyleEvents()
	if not self.eventFrame then
		self.eventFrame = CreateFrame("Frame")
		self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
			if event == "UNIT_SPELLCAST_SUCCEEDED" then
				local unit, castGUID, spellID = ...
				if unit == "player" then
					-- Handle flight style changes (existing code)
					if spellID == 460003 then -- Switch TO skyriding
						self.isInSkyridingMode = true
						addon:DebugCore("Switched TO skyriding mode")
					elseif spellID == 460002 then -- Switch TO steady flight
						self.isInSkyridingMode = false
						addon:DebugCore("Switched TO steady flight mode")
					else
						-- Check if this is a mount summon spell (NEW)
						local isMountSpell, mountID = self:IsMountSummonSpell(spellID)
						if isMountSpell and mountID then
							addon:DebugSummon("Detected successful mount summon - Spell: " ..
								spellID .. ", Mount: " .. mountID)
							-- Find which pool this summon was from by checking pending summons
							local deterministicCache = addon.db and addon.db.profile and
									addon.db.profile.deterministicCache
							if deterministicCache then
								for poolName, cache in pairs(deterministicCache) do
									local pendingSummon = cache and cache.pendingSummon
									if pendingSummon and pendingSummon.mountID and pendingSummon.mountID == mountID then
										self:ProcessSuccessfulSummon(poolName)
										break
									end
								end
							end
						end
					end
				end
			end
		end)
	end

	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	addon:DebugCore("Registered for flight style change and mount summon events")
end

-- ============================================================================
-- CONTEXT DETECTION
-- ============================================================================
-- Determine the current player context for contextual summoning
function MountSummon:GetCurrentContext()
	-- Stability check to avoid transition state issues
	local currentTime = GetTime()
	if not self.lastContextCheck then
		self.lastContextCheck = currentTime
	end

	-- If context was checked very recently, use cached result
	if (currentTime - self.lastContextCheck) < 1.0 and self.cachedContext then
		addon:DebugSummon("Using cached context to avoid transition issues")
		return self.cachedContext
	end

	local context = {
		canFly = false,
		canDragonride = false,
		isUnderwater = false,
		inZone = nil,
		isInSkyridingMode = self.isInSkyridingMode,
	}
	-- Check if player can fly in current zone
	context.canFly = IsFlyableArea()
	-- Additional validation to catch transition states
	if context.canFly then
		local mapID = C_Map.GetBestMapForUnit("player")
		if not mapID then
			addon:DebugSummon("Map ID unavailable, assuming ground during transition")
			context.canFly = false
			context.canDragonride = false
		end
	end

	if IsAdvancedFlyableArea then
		context.canDragonride = IsAdvancedFlyableArea()
	end

	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		context.inZone = mapID
	end

	context.isUnderwater = self:IsPlayerTrulyUnderwater()
	-- Cache the result
	self.cachedContext = context
	self.lastContextCheck = currentTime
	addon:DebugSummon("Current context:",
		"canFly =", context.canFly,
		"canDragonride =", context.canDragonride,
		"isInSkyridingMode =", context.isInSkyridingMode,
		"isUnderwater =", context.isUnderwater,
		"zone =", context.inZone)
	return context
end

-- ============================================================================
-- DETERMINISTIC SUMMMON MODE
-- ============================================================================
-- Initialize deterministic summoning system
function MountSummon:InitializeDeterministicSystem()
	addon:DebugSummon("Initializing deterministic summoning system...")
	-- Ensure cache structure exists
	if not addon.db or not addon.db.profile then
		addon:DebugSummon("No database available, skipping initialization")
		return
	end

	if not addon.db.profile.deterministicCache then
		addon.db.profile.deterministicCache = {
			flying = { unavailableGroups = {}, pendingSummon = nil },
			ground = { unavailableGroups = {}, pendingSummon = nil },
			underwater = { unavailableGroups = {}, pendingSummon = nil },
		}
	end

	addon:DebugSummon("System initialized")
end

-- Check if deterministic mode is enabled
function MountSummon:IsDeterministicModeEnabled()
	return addon:GetSetting("useDeterministicSummoning") == true
end

-- Get total available groups count for a pool (only selectable ones)
function MountSummon:GetTotalGroupsInPool(poolName)
	return self:GetSelectableGroupsInPool(poolName)
end

-- Count only groups that are actually selectable (replaces the flawed original)
function MountSummon:GetSelectableGroupsInPool(poolName)
	local pool = self.mountPools[poolName]
	if not pool then return 0 end

	local selectableGroups = 0
	local totalDataGroups = 0
	-- Count what the old method would count (for comparison)
	for _ in pairs(pool.superGroups) do
		totalDataGroups = totalDataGroups + 1
	end

	for _ in pairs(pool.families) do
		totalDataGroups = totalDataGroups + 1
	end

	-- Count selectable supergroups (mirrors SelectGroupFromPool logic exactly)
	for sgName, families in pairs(pool.superGroups) do
		if #families > 0 then
			local sgHasValidFamilies = false
			for _, familyName in ipairs(families) do
				if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
					-- Check if family actually has selectable mounts
					if self:FamilyHasSelectableMounts(pool, familyName) then
						sgHasValidFamilies = true
						break
					end
				end
			end

			if sgHasValidFamilies then
				local groupWeight = addon:GetGroupWeight(sgName)
				if groupWeight > 0 then
					selectableGroups = selectableGroups + 1
					--print("RMB_DEBUG_COUNT: Selectable supergroup: " .. sgName .. " (weight: " .. groupWeight .. ")")
				else
					--print("RMB_DEBUG_COUNT: Skipped supergroup (weight 0): " .. sgName)
				end
			else
				--print("RMB_DEBUG_COUNT: Skipped supergroup (no valid families): " .. sgName)
			end
		else
			--print("RMB_DEBUG_COUNT: Skipped supergroup (no families): " .. sgName)
		end
	end

	-- Count selectable standalone families (mirrors SelectGroupFromPool logic exactly)
	for familyName, _ in pairs(pool.families) do
		if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
			local groupWeight = addon:GetGroupWeight(familyName)
			if groupWeight > 0 and self:FamilyHasSelectableMounts(pool, familyName) then
				selectableGroups = selectableGroups + 1
				--print("RMB_DEBUG_COUNT: Selectable standalone family: " .. familyName .. " (weight: " .. groupWeight .. ")")
			else
				if groupWeight <= 0 then
					--print("RMB_DEBUG_COUNT: Skipped standalone family (weight " .. groupWeight .. "): " .. familyName)
				else
					--print("RMB_DEBUG_COUNT: Skipped standalone family (no selectable mounts): " .. familyName)
				end
			end
		else
			--print("RMB_DEBUG_COUNT: Skipped standalone family (no mounts): " .. familyName)
		end
	end

	--print("RMB_DEBUG_COUNT: Pool " .. poolName .. " - Data structure groups: " .. totalDataGroups ..
	--	", Actually selectable: " .. selectableGroups)
	return selectableGroups
end

-- Check if a family has any selectable mounts (mirrors SelectMountFromPoolFamily logic)
function MountSummon:FamilyHasSelectableMounts(pool, familyName)
	local familyMounts = pool.mountsByFamily[familyName] or {}
	if #familyMounts == 0 then
		return false
	end

	-- Check if family has any selectable mounts (mirrors SelectMountFromPoolFamily logic exactly)
	for _, mountID in ipairs(familyMounts) do
		local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			local mountKey = "mount_" .. mountID
			local mountWeight = addon:GetGroupWeight(mountKey)
			-- Skip mounts with explicit 0 weight
			if mountWeight ~= 0 then
				-- If mount has no specific weight, use family weight
				if mountWeight == 0 then
					mountWeight = addon:GetGroupWeight(familyName)
				end

				-- If mount has weight > 0, this family is selectable
				if mountWeight > 0 then
					return true
				end
			end
		end
	end

	return false
end

-- Calculate unavailability duration for a group
function MountSummon:CalculateUnavailabilityDuration(poolName, groupKey, groupType)
	local totalGroups = self:GetTotalGroupsInPool(poolName) -- Now uses fixed counting
	-- SAFEGUARD: Don't use deterministic mode for very small pools
	if totalGroups < 3 then
		addon:DebugSummon("Pool " .. poolName .. " has only " .. totalGroups ..
			" selectable groups, disabling deterministic summoning")
		return 0
	end

	local baseDuration = math.floor(totalGroups * 0.7) - 4
	baseDuration = math.max(2, math.min(20, baseDuration))
	-- Get the group's weight to adjust ban duration
	local groupWeight = addon:GetGroupWeight(groupKey)
	local reduction = (groupWeight - 1) * 0.2
	local adjustedDuration = math.floor(baseDuration * (1 - reduction))
	-- Always at least 1 summon ban
	adjustedDuration = math.max(1, adjustedDuration)
	addon:DebugSummon("Pool " .. poolName .. " (" .. totalGroups .. " selectable groups) - " ..
		"Base: " .. baseDuration .. ", Weight " .. groupWeight .. " group '" .. groupKey ..
		"' banned for " .. adjustedDuration .. " summons")
	return adjustedDuration
end

-- Filter pool to remove unavailable groups
function MountSummon:FilterPoolForDeterministic(pool, poolName)
	if not self:IsDeterministicModeEnabled() then
		return pool -- Return original pool if deterministic mode disabled
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache or not cache.unavailableGroups then
		return pool -- Return original if no cache
	end

	self:DecrementUnavailabilityCounters(poolName)
	-- SAFEGUARD: Count how many groups would remain after filtering
	local availableGroupCount = 0
	-- Count available supergroups
	for sgName, families in pairs(pool.superGroups) do
		local unavailableCount = cache.unavailableGroups[sgName]
		if not unavailableCount or unavailableCount <= 0 then
			availableGroupCount = availableGroupCount + 1
		end
	end

	local bannedCount = 0
	for groupKey, count in pairs(cache.unavailableGroups) do
		if count and count > 0 then
			bannedCount = bannedCount + 1
			if bannedCount <= 5 then -- Log first 5
				addon:DebugSummon("Banned: " .. groupKey .. " for " .. count .. " more summons")
			end
		end
	end

	addon:DebugSummon("Total banned groups: " ..
		bannedCount .. " out of pool size: " .. self:GetSelectableGroupsInPool(poolName))
	-- Count available standalone families
	for familyName, _ in pairs(pool.families) do
		local unavailableCount = cache.unavailableGroups[familyName]
		if not unavailableCount or unavailableCount <= 0 then
			availableGroupCount = availableGroupCount + 1
		end
	end

	-- EMERGENCY SAFEGUARD: If filtering would leave us with very few groups, reduce ban durations
	if availableGroupCount <= 1 then
		addon:DebugSummon("WARNING - Only " .. availableGroupCount ..
			" groups would remain after filtering in " .. poolName .. " pool, clearing all bans")
		-- Clear all bans instead of just reducing them
		cache.unavailableGroups = {}
		addon:DebugSummon("Cleared all deterministic bans due to empty pool")
		-- Return the original unfiltered pool
		return pool
	end

	-- Create filtered pool
	local filteredPool = {
		superGroups = {},
		families = {},
		mountsByFamily = pool.mountsByFamily, -- Keep mount lists unchanged
		mountWeights = pool.mountWeights,   -- Keep weights unchanged
	}
	-- Filter supergroups
	for sgName, families in pairs(pool.superGroups) do
		local unavailableCount = cache.unavailableGroups[sgName]
		if not unavailableCount or unavailableCount <= 0 then
			filteredPool.superGroups[sgName] = families
		else
			addon:DebugSummon("Filtered out supergroup " .. sgName ..
				" (unavailable for " .. unavailableCount .. " more summons)")
		end
	end

	-- Filter standalone families
	for familyName, _ in pairs(pool.families) do
		local unavailableCount = cache.unavailableGroups[familyName]
		if not unavailableCount or unavailableCount <= 0 then
			filteredPool.families[familyName] = true
		else
			addon:DebugSummon("Filtered out family " .. familyName ..
				" (unavailable for " .. unavailableCount .. " more summons)")
		end
	end

	return filteredPool
end

-- Mark a group as unavailable
function MountSummon:MarkGroupUnavailable(poolName, groupKey, groupType)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local duration = self:CalculateUnavailabilityDuration(poolName, groupKey, groupType) -- Added parameters
	if duration <= 0 then
		addon:DebugSummon("Duration is 0, not marking group unavailable")
		return
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache then
		addon:DebugSummon("No cache for pool " .. poolName)
		return
	end

	if not cache.unavailableGroups then
		cache.unavailableGroups = {}
	end

	cache.unavailableGroups[groupKey] = duration
	addon:DebugSummon("Marked " ..
		groupKey .. " unavailable for " .. duration .. " summons in " .. poolName .. " pool")
end

-- Decrement unavailability counters for all groups in a pool
function MountSummon:DecrementUnavailabilityCounters(poolName)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache or not cache.unavailableGroups then
		return
	end

	local groupsToRemove = {}
	for groupKey, count in pairs(cache.unavailableGroups) do
		if count and count > 0 then
			cache.unavailableGroups[groupKey] = count - 1
			if cache.unavailableGroups[groupKey] <= 0 then
				table.insert(groupsToRemove, groupKey)
			end
		else
			table.insert(groupsToRemove, groupKey)
		end
	end

	-- Clean up groups that are no longer unavailable
	for _, groupKey in ipairs(groupsToRemove) do
		cache.unavailableGroups[groupKey] = nil
		addon:DebugSummon("" .. groupKey .. " is now available again in " .. poolName .. " pool")
	end
end

-- Store pending summon for tracking
function MountSummon:StorePendingSummon(poolName, groupKey, groupType, mountID)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache then
		return
	end

	cache.pendingSummon = {
		groupKey = groupKey,
		groupType = groupType,
		mountID = mountID,
		timestamp = GetTime(),
	}
	addon:DebugSummon("Stored pending summon - Group: " .. groupKey .. ", Mount: " .. mountID)
end

-- Process successful summon
function MountSummon:ProcessSuccessfulSummon(poolName)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local cache = addon.db.profile.deterministicCache and addon.db.profile.deterministicCache[poolName]
	if not cache or not cache.pendingSummon then
		return
	end

	local pending = cache.pendingSummon
	if not pending or not pending.groupKey or not pending.groupType then
		addon:DebugSummon("Invalid pending summon data")
		cache.pendingSummon = nil
		return
	end

	-- Mark the group unavailable
	self:MarkGroupUnavailable(poolName, pending.groupKey, pending.groupType)
	-- Don't decrement immediately - let the next summon attempt handle it
	-- The decrement should happen BEFORE filtering, not after successful summon
	-- Clear pending summon
	cache.pendingSummon = nil
	addon:DebugSummon("Processed successful summon for " .. pending.groupKey)
end

-- Check if a spell is a mount summon spell
function MountSummon:IsMountSummonSpell(spellID)
	-- Get all collected mounts and check if any match this spell ID
	if not addon.processedData or not addon.processedData.allCollectedMountFamilyInfo then
		return false
	end

	for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
		local _, spellIdFromMount = C_MountJournal.GetMountInfoByID(mountID)
		if spellIdFromMount == spellID then
			return true, mountID
		end
	end

	return false
end

-- ============================================================================
-- MOUNT POOL MANAGEMENT (unchanged from original, includes all helper functions)
-- ============================================================================
-- Build mount pools for different contexts
function MountSummon:BuildMountPools()
	addon:DebugSummon("Building context-based mount pools")
	-- Reset the pools
	for poolName, pool in pairs(self.mountPools) do
		pool.superGroups = {}
		pool.families = {}
		pool.mountsByFamily = {}
		pool.mountWeights = {}
	end

	-- Add unified pool for non-contextual summoning
	self.mountPools.unified = {
		superGroups = {},
		families = {},
		mountsByFamily = {},
		mountWeights = {},
	}
	-- Process all collected mounts
	local mountsProcessed = 0
	for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = addon:GetDynamicSuperGroup(familyName)
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			mountsProcessed = mountsProcessed + 1
			-- Determine effective weight
			local mountKey = "mount_" .. mountID
			local mountWeight = addon:GetGroupWeight(mountKey)
			-- Mount weight of 0 means explicitly excluded
			if mountWeight ~= 0 then
				-- Get mount capabilities
				local canFly = self:CanMountFlyEffective(mountID)
				local canSwim = self:CanMountSwimEffective(mountID)
				local traits = self:GetEffectiveMountTypeTraits(mountID)
				-- Always add to unified pool (for non-contextual summoning)
				self:AddMountToPool("unified", mountID, name, familyName, superGroup, mountWeight)
				-- Add to contextual pools based on EXCLUSIVE logic
				if canSwim then
					-- Add to underwater pool (regardless of other skills per spec)
					self:AddMountToPool("underwater", mountID, name, familyName, superGroup, mountWeight)
				end

				if canFly then
					-- Add to flying pool (regardless of other skills per spec)
					self:AddMountToPool("flying", mountID, name, familyName, superGroup, mountWeight)
				elseif traits.isGround then
					-- Only add to ground pool if it CAN'T fly (ground-only mounts)
					self:AddMountToPool("ground", mountID, name, familyName, superGroup, mountWeight)
				end

				-- Add to groundUsable pool if mount can be used on ground
				if traits.isGround then
					self:AddMountToPool("groundUsable", mountID, name, familyName, superGroup, mountWeight)
				end
			else
				addon:DebugSummon("Mount " .. name .. " explicitly excluded (weight 0)")
			end
		end
	end

	addon:DebugSummon("Processed " .. mountsProcessed .. " mounts into context pools")
	-- Apply family and supergroup weights to all pools
	self:ApplyFamilyAndSuperGroupWeights()
	-- Log pool sizes
	self:LogPoolStats()
	-- Validate pools
	self:ValidateMountPools()
end

-- Helper to add a mount to a specific pool
function MountSummon:AddMountToPool(poolName, mountID, mountName, familyName, superGroup, mountWeight)
	local pool = self.mountPools[poolName]
	-- Store the mount's weight
	pool.mountWeights[mountID] = mountWeight
	-- Add to mountsByFamily
	if not pool.mountsByFamily[familyName] then
		pool.mountsByFamily[familyName] = {}
	end

	table.insert(pool.mountsByFamily[familyName], mountID)
	--addon:DebugSummon("Added " .. mountName .. " to " .. poolName .. " pool for family " .. familyName)
	-- Note: We'll handle families and supergroups in ApplyFamilyAndSuperGroupWeights
	-- to properly handle weight inheritance
end

-- Apply family and supergroup weights after all mounts are processed
function MountSummon:ApplyFamilyAndSuperGroupWeights()
	-- Process all pools including the new unified pool
	for poolName, pool in pairs(self.mountPools) do
		-- First, determine which families have usable mounts
		local familiesWithUsableMounts = {}
		for familyName, mounts in pairs(pool.mountsByFamily) do
			-- Check if family has any mounts with weight > 0
			local familyHasUsableMounts = false
			for _, mountID in ipairs(mounts) do
				if pool.mountWeights[mountID] and pool.mountWeights[mountID] > 0 then
					familyHasUsableMounts = true
					break
				end
			end

			-- If family has no usable mounts, check if family weight > 0
			local familyWeight = addon:GetGroupWeight(familyName)
			if familyHasUsableMounts or familyWeight > 0 then
				familiesWithUsableMounts[familyName] = true
			else
				addon:DebugSummon("Family " .. familyName .. " in " .. poolName ..
					" pool has no usable mounts and weight 0, skipping")
			end
		end

		-- Add standalone families to the pool
		for familyName in pairs(familiesWithUsableMounts) do
			local superGroup = addon:GetDynamicSuperGroup(familyName)
			if not superGroup then
				pool.families[familyName] = true
				--addon:DebugSummon("Added standalone family " .. familyName .. " to " .. poolName .. " pool")
			end
		end

		-- Add supergroups and their families
		for familyName in pairs(familiesWithUsableMounts) do
			local superGroup = addon:GetDynamicSuperGroup(familyName)
			if superGroup then
				local superGroupWeight = addon:GetGroupWeight(superGroup)
				if superGroupWeight > 0 then
					if not pool.superGroups[superGroup] then
						pool.superGroups[superGroup] = {}
					end

					-- Check if family already in supergroup
					local found = false
					for _, existingFamily in ipairs(pool.superGroups[superGroup]) do
						if existingFamily == familyName then
							found = true
							break
						end
					end

					-- Add family to supergroup if not already there
					if not found then
						local familyWeight = addon:GetGroupWeight(familyName)
						if familyWeight > 0 then
							table.insert(pool.superGroups[superGroup], familyName)
							--addon:DebugSummon("Added family " .. familyName ..
							--	" to supergroup " .. superGroup .. " in " .. poolName .. " pool")
						else
							addon:DebugSummon("Family " .. familyName ..
								" in supergroup " .. superGroup ..
								" has weight 0, not adding to " .. poolName .. " pool")
						end
					end
				else
					addon:DebugSummon("Supergroup " .. superGroup ..
						" has weight 0, not adding to " .. poolName .. " pool")
				end
			end
		end
	end
end

-- Validate mount pools to remove empty groups
function MountSummon:ValidateMountPools()
	addon:DebugSummon("Validating mount pools to remove empty groups")
	for poolName, pool in pairs(self.mountPools) do
		-- Remove supergroups with no valid families
		local invalidSuperGroups = {}
		for sgName, families in pairs(pool.superGroups) do
			local hasValidFamilies = false
			for _, familyName in ipairs(families) do
				if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
					hasValidFamilies = true
					break
				end
			end

			if not hasValidFamilies then
				table.insert(invalidSuperGroups, sgName)
			end
		end

		-- Remove invalid supergroups
		for _, sgName in ipairs(invalidSuperGroups) do
			addon:DebugSummon("Removing invalid supergroup from " .. poolName .. " pool: " .. sgName)
			pool.superGroups[sgName] = nil
		end

		-- Remove families with no mounts
		local invalidFamilies = {}
		for familyName, _ in pairs(pool.families) do
			if not pool.mountsByFamily[familyName] or #pool.mountsByFamily[familyName] == 0 then
				table.insert(invalidFamilies, familyName)
			end
		end

		-- Remove invalid families
		for _, familyName in ipairs(invalidFamilies) do
			addon:DebugSummon("Removing invalid family from " .. poolName .. " pool: " .. familyName)
			pool.families[familyName] = nil
		end
	end

	-- Log updated pool stats
	self:LogPoolStats()
end

-- Log statistics about the mount pools
function MountSummon:LogPoolStats()
	for poolName, pool in pairs(self.mountPools) do
		local superGroupCount = 0
		local familiesInSuperGroups = 0
		local standaloneFamilies = 0
		local totalMounts = 0
		-- Count supergroups and their families
		for sgName, families in pairs(pool.superGroups) do
			superGroupCount = superGroupCount + 1
			familiesInSuperGroups = familiesInSuperGroups + #families
		end

		-- Count standalone families
		for _ in pairs(pool.families) do
			standaloneFamilies = standaloneFamilies + 1
		end

		-- Count total mounts
		for _, mounts in pairs(pool.mountsByFamily) do
			totalMounts = totalMounts + #mounts
		end

		addon:DebugSummon("" .. poolName .. " pool has " .. superGroupCount ..
			" supergroups with " .. familiesInSuperGroups .. " families, " ..
			standaloneFamilies .. " standalone families, and " ..
			totalMounts .. " total mounts")
	end
end

-- Helper function to check if pools have any content
function MountSummon:ArePoolsInitialized()
	-- Check if at least one pool has some groups
	for poolName, pool in pairs(self.mountPools) do
		local hasGroups = false
		for _ in pairs(pool.superGroups or {}) do
			hasGroups = true
			break
		end

		if not hasGroups then
			for _ in pairs(pool.families or {}) do
				hasGroups = true
				break
			end
		end

		if hasGroups then
			addon:DebugSummon("Pool validation: " .. poolName .. " has groups")
			return true
		end
	end

	addon:DebugSummon("Pool validation: No pools have groups")
	return false
end

-- Map user-facing weights (0-6) to actual probability weights
function MountSummon:MapWeightToProbability(userWeight)
	-- Map from user weights to probability weights
	local weightMap = {
		[0] = 0, -- 0%
		[1] = 5, -- ~5%
		[2] = 20, -- ~20%
		[3] = 50, -- ~50%
		[4] = 70, -- ~70%
		[5] = 90, -- ~90%
		[6] = 100, -- 100%
	}
	-- Ensure we have a valid weight
	userWeight = math.max(0, math.min(6, tonumber(userWeight) or 0))
	-- Return the mapped weight
	return weightMap[userWeight] or 0
end

-- ============================================================================
-- MOUNT SUMMONING
-- ============================================================================
-- Summon a specific mount by ID
function MountSummon:SummonMount(mountID)
	if not mountID then
		addon:AlwaysPrint(" No mount ID provided.")
		-- Clear any stale pending summon
		self:ClearPendingSummon()
		return false
	end

	local name = C_MountJournal.GetMountInfoByID(mountID)
	addon:DebugSummon("Summoning mount:", name, "ID:", mountID)
	-- Store the current time to detect failed summons
	self.lastSummonAttempt = GetTime()
	-- Use Blizzard's function to summon the mount
	C_MountJournal.SummonByID(mountID)
	-- Set up a timer to detect failed summons
	C_Timer.After(2.0, function()
		if not IsMounted() and (GetTime() - self.lastSummonAttempt) >= 1.8 then
			addon:DebugSummon("Summon appears to have failed, clearing pending summon")
			self:ClearPendingSummon()
		end
	end)
	return true
end

-- function to clear stale pending summons
function MountSummon:ClearPendingSummon()
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	if deterministicCache then
		for poolName, cache in pairs(deterministicCache) do
			if cache and cache.pendingSummon then
				addon:DebugSummon("Cleared stale pending summon for pool: " .. poolName)
				cache.pendingSummon = nil
			end
		end
	end
end

-- Main function to pick and summon a random mount
function MountSummon:SummonRandomMount(useContext)
	addon:DebugSummon("SummonRandomMount called with useContext:", useContext)
	-- Check if player is already mounted - if so, just dismount and return
	if IsMounted() then
		addon:DebugSummon("Player is mounted, dismounting instead of summoning new mount")
		Dismount() -- or C_MountJournal.Dismiss() in newer versions
		return true -- Return true to indicate successful action (dismounting)
	end

	-- Immediate validation if recent zone change + pools are empty
	if not self:ArePoolsInitialized() then
		local recentZoneChange = addon.lastZoneChangeTime and (GetTime() - addon.lastZoneChangeTime) < 3.0
		if recentZoneChange then
			addon:DebugSummon("IMMEDIATE: Recent zone change detected + empty pools - rebuilding now")
		else
			addon:DebugSummon("SAFETY: Pools not initialized, attempting to build them")
		end

		if addon.RMB_DataReadyForUI and addon.processedData then
			self:BuildMountPools()
			if not self:ArePoolsInitialized() then
				if recentZoneChange then
					addon:DebugSummon("IMMEDIATE: Pool building failed after zone change")
					-- Try full data refresh as last resort
					addon:RefreshMountDataAndUI("immediate_zone_validation", nil)
					-- Wait a moment and try again
					C_Timer.After(0.1, function()
						if self:ArePoolsInitialized() then
							addon:DebugSummon("IMMEDIATE: Recovery successful after data refresh")
							-- Could trigger another summon attempt here if desired
						end
					end)
				else
					addon:DebugSummon("SAFETY: Pool building failed")
				end

				return false
			else
				if recentZoneChange then
					addon:DebugSummon("IMMEDIATE: Successfully rebuilt pools after zone change")
				else
					addon:DebugSummon("SAFETY: Successfully built pools")
				end
			end
		else
			addon:DebugSummon("SAFETY: Cannot build pools - data not ready")
			return false
		end
	end

	-- Determine which pool to use based on context
	local poolName = "unified" -- Default to unified pool
	local mountTypeFilter = nil -- No specific type filter by default
	-- Always detect context, but respect contextual setting only for ground areas
	local context = self:GetCurrentContext()
	if context.isUnderwater then
		-- Always use underwater pool regardless of context setting
		poolName = "underwater"
		addon:DebugSummon("Using underwater pool")
	elseif context.canFly or context.canDragonride then
		-- Use flying pool if EITHER traditional flying OR dragonriding is available
		poolName = "flying"
		if context.isInSkyridingMode and context.canDragonride then
			mountTypeFilter = "skyriding"
			addon:DebugSummon("Using flying pool with skyriding filter (dragonriding area)")
		else
			mountTypeFilter = "steadyflight"
			addon:DebugSummon("Using flying pool with steady flight filter")
		end
	else
		-- Ground-only context - respect contextual summoning setting
		if useContext and addon:GetSetting("contextualSummoning") then
			poolName = "ground"
			addon:DebugSummon("Using ground pool (context enabled)")
		else
			poolName = "groundUsable"
			addon:DebugSummon("Using groundUsable pool (context disabled or not requested)")
		end
	end

	-- Select mount from the appropriate pool with proper deterministic integration
	local mountID, mountName = self:SelectMountFromPoolWithFilter(poolName, mountTypeFilter)
	-- Underwater fallback logic
	if not mountID and poolName == "underwater" then
		addon:DebugSummon("No underwater mounts available, attempting fallback...")
		self:ClearPendingSummon() -- Clear failed underwater attempt
		local context = self:GetCurrentContext()
		local fallbackPoolName, fallbackFilter
		if context.canFly then
			fallbackPoolName = "flying"
			if context.isInSkyridingMode and context.canDragonride then
				fallbackFilter = "skyriding"
			else
				fallbackFilter = "steadyflight"
			end
		else
			fallbackPoolName = addon:GetSetting("contextualSummoning") and "ground" or "groundUsable"
			fallbackFilter = nil
		end

		addon:DebugSummon("Falling back to " .. fallbackPoolName .. " pool" ..
			(fallbackFilter and (" with " .. fallbackFilter .. " filter") or ""))
		mountID, mountName = self:SelectMountFromPoolWithFilter(fallbackPoolName, fallbackFilter)
	end

	if mountID then
		return self:SummonMount(mountID)
	else
		addon:DebugSummon("No eligible mounts found in " .. poolName .. " pool" ..
			(mountTypeFilter and (" with " .. mountTypeFilter .. " filter") or ""))
		return false
	end
end

-- method that integrates deterministic filtering with mount type filtering:
function MountSummon:SelectMountFromPoolWithFilter(poolName, mountTypeFilter)
	addon:DebugSummon("=== Pool selection: " .. poolName ..
		(mountTypeFilter and (" + " .. mountTypeFilter) or " (no filter)") .. " ===")
	local originalPool = self.mountPools[poolName]
	if not originalPool then
		addon:AlwaysPrint(" Invalid pool name:", poolName)
		return nil, nil
	end

	-- Apply deterministic filtering first
	local pool = self:FilterPoolForDeterministic(originalPool, poolName)
	local isDeterministicFallback = false
	-- Check if filtering left us with no groups
	local hasGroups = false
	for _ in pairs(pool.superGroups) do
		hasGroups = true; break
	end

	if not hasGroups then
		for _ in pairs(pool.families) do
			hasGroups = true; break
		end
	end

	if not hasGroups then
		addon:DebugSummon("No available groups after filtering, falling back to random mode")
		pool = originalPool          -- Fall back to original pool
		isDeterministicFallback = true -- Flag that we're in fallback mode
	end

	-- If no mount type filter, use normal selection
	if not mountTypeFilter then
		return self:SelectMountFromFilteredPool(pool, poolName)
	end

	-- Apply mount type filtering for contextual summoning
	if isDeterministicFallback then
		-- When falling back from deterministic mode, ignore weights temporarily
		return self:SelectSpecificMountTypeFromFilteredPoolIgnoreWeights(pool, poolName, mountTypeFilter)
	else
		return self:SelectSpecificMountTypeFromFilteredPool(pool, poolName, mountTypeFilter)
	end
end

function MountSummon:SelectSpecificMountTypeFromFilteredPoolIgnoreWeights(pool, poolName, mountType)
	addon:DebugSummon("SelectSpecificMountType (IGNORE WEIGHTS) for", mountType, "in", poolName, "pool")
	-- Build list of ALL groups regardless of weight
	local allGroups = {}
	-- Add ALL supergroups
	for sgName, families in pairs(pool.superGroups) do
		table.insert(allGroups, {
			name = sgName,
			type = "superGroup",
		})
	end

	-- Add ALL standalone families
	for familyName, _ in pairs(pool.families) do
		table.insert(allGroups, {
			name = familyName,
			type = "family",
		})
	end

	-- Randomize group order
	for i = #allGroups, 2, -1 do
		local j = math.random(i)
		allGroups[i], allGroups[j] = allGroups[j], allGroups[i]
	end

	-- Try each group until we find one with matching mount type
	for _, group in ipairs(allGroups) do
		local eligibleFamilies = {}
		if group.type == "superGroup" then
			-- Get all families in this supergroup
			for _, familyName in ipairs(pool.superGroups[group.name] or {}) do
				table.insert(eligibleFamilies, { name = familyName })
			end
		else
			-- Just the standalone family
			table.insert(eligibleFamilies, { name = group.name })
		end

		-- Try each family until we find one with matching mount type
		for _, family in ipairs(eligibleFamilies) do
			local eligibleMounts = {}
			-- Get all mounts in this family
			for _, mountID in ipairs(pool.mountsByFamily[family.name] or {}) do
				local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					local isEligible = false
					-- Check if this mount matches the desired type
					if mountType == "skyriding" and traits.isSkyriding then
						isEligible = true
					elseif mountType == "steadyflight" and traits.isSteadyFly then
						isEligible = true
					end

					if isEligible then
						-- Still respect explicit mount weight 0 (never summon)
						local mountKey = "mount_" .. mountID
						local mountWeight = addon:GetGroupWeight(mountKey)
						if mountWeight ~= 0 then -- Only exclude if explicitly set to 0
							table.insert(eligibleMounts, {
								id = mountID,
								name = name,
							})
						end
					end
				end
			end

			-- If eligible mounts found, pick one randomly
			if #eligibleMounts > 0 then
				local selectedMount = eligibleMounts[math.random(#eligibleMounts)]
				addon:DebugSummon("Selected " .. mountType .. " mount (IGNORE WEIGHTS):", selectedMount.name)
				return selectedMount.id, selectedMount.name
			end
		end
	end

	addon:DebugSummon("No eligible " .. mountType .. " mounts found even ignoring weights")
	return nil, nil
end

-- Updated method that works with already-filtered pools:
function MountSummon:SelectMountFromFilteredPool(pool, poolName)
	-- Step 1: Select group (supergroup or standalone family)
	local groupName, groupType = self:SelectGroupFromPool(pool)
	if not groupName then
		addon:DebugSummon("No groups available in", poolName, "pool")
		return nil, nil
	end

	-- Step 2: Select family
	local familyName
	if groupType == "superGroup" then
		familyName = self:SelectFamilyFromPoolSuperGroup(pool, groupName)
		if not familyName then
			addon:DebugSummon("No families available in supergroup", groupName)
			return nil, nil
		end
	else
		familyName = groupName -- Standalone family
	end

	-- Step 3: Select mount from family
	local mountID, mountName = self:SelectMountFromPoolFamily(pool, familyName)
	-- Store pending summon for deterministic tracking
	if mountID then
		self:StorePendingSummon(poolName, groupName, groupType, mountID)
	end

	return mountID, mountName
end

function MountSummon:SelectSpecificMountTypeFromFilteredPool(pool, poolName, mountType)
	addon:DebugCore("=== " .. mountType .. " selection in " .. poolName .. " ===")
	-- Quick counts for debugging
	local totalSG = 0
	local totalFam = 0
	for _ in pairs(pool.superGroups) do totalSG = totalSG + 1 end

	for _ in pairs(pool.families) do totalFam = totalFam + 1 end

	addon:DebugCore("Pool has " .. totalSG .. " SG, " .. totalFam .. " families")
	-- Collect ALL eligible mounts first, then do weighted selection
	local allEligibleMounts = {}
	local priority6Mounts = {}
	-- Process supergroups
	for sgName, families in pairs(pool.superGroups) do
		local superGroupWeight = addon:GetGroupWeight(sgName)
		if superGroupWeight > 0 then
			for _, familyName in ipairs(families) do
				local familyWeight = addon:GetGroupWeight(familyName)
				if familyWeight > 0 then
					-- Check all mounts in this family
					for _, mountID in ipairs(pool.mountsByFamily[familyName] or {}) do
						local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
						if isUsable then
							local traits = self:GetEffectiveMountTypeTraits(mountID)
							local isEligible = false
							-- Check if this mount matches the desired type
							if mountType == "skyriding" and traits.isSkyriding then
								isEligible = true
							elseif mountType == "steadyflight" and traits.isSteadyFly then
								isEligible = true
							end

							if isEligible then
								local mountKey = "mount_" .. mountID
								local mountWeight = addon:GetGroupWeight(mountKey)
								-- Skip mounts with explicit weight 0
								if mountWeight ~= 0 then
									-- If mount has no specific weight, use family weight
									if mountWeight == nil or mountWeight == 0 then
										mountWeight = familyWeight
									end

									if mountWeight > 0 then
										local mountData = {
											id = mountID,
											name = name,
											groupName = sgName,
											groupType = "superGroup",
											weight = self:MapWeightToProbability(mountWeight),
											originalWeight = mountWeight,
										}
										if mountWeight == 6 then
											table.insert(priority6Mounts, mountData)
										else
											table.insert(allEligibleMounts, mountData)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- Process standalone families
	for familyName, _ in pairs(pool.families) do
		local familyWeight = addon:GetGroupWeight(familyName)
		if familyWeight > 0 then
			-- Check all mounts in this family
			for _, mountID in ipairs(pool.mountsByFamily[familyName] or {}) do
				local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					local isEligible = false
					-- Check if this mount matches the desired type
					if mountType == "skyriding" and traits.isSkyriding then
						isEligible = true
					elseif mountType == "steadyflight" and traits.isSteadyFly then
						isEligible = true
					end

					if isEligible then
						local mountKey = "mount_" .. mountID
						local mountWeight = addon:GetGroupWeight(mountKey)
						-- Skip mounts with explicit weight 0
						if mountWeight ~= 0 then
							-- If mount has no specific weight, use family weight
							if mountWeight == nil or mountWeight == 0 then
								mountWeight = familyWeight
							end

							if mountWeight > 0 then
								local mountData = {
									id = mountID,
									name = name,
									groupName = familyName,
									groupType = "family",
									weight = self:MapWeightToProbability(mountWeight),
									originalWeight = mountWeight,
								}
								if mountWeight == 6 then
									table.insert(priority6Mounts, mountData)
								else
									table.insert(allEligibleMounts, mountData)
								end
							end
						end
					end
				end
			end
		end
	end

	-- Log collection results
	addon:DebugSummon("Collected mounts: " .. (#allEligibleMounts + #priority6Mounts) ..
		" (P6:" .. #priority6Mounts .. ", Regular:" .. #allEligibleMounts .. ")")
	-- Choose which pool to select from (priority 6 first)
	local mountsToChooseFrom = #priority6Mounts > 0 and priority6Mounts or allEligibleMounts
	if #mountsToChooseFrom == 0 then
		addon:DebugCore("FAILED - No " .. mountType .. " mounts found")
		return nil, nil
	end

	-- Handle priority 6 mounts (random selection, no weights)
	if #priority6Mounts > 0 then
		local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
		addon:DebugSummon("SUCCESS - P6 " .. selectedMount.name)
		self:StorePendingSummon(poolName, selectedMount.groupName, selectedMount.groupType, selectedMount.id)
		return selectedMount.id, selectedMount.name
	end

	-- Weighted random selection for regular mounts
	local totalWeight = 0
	for _, mount in ipairs(allEligibleMounts) do
		totalWeight = totalWeight + mount.weight
	end

	if totalWeight <= 0 then
		addon:DebugCore("FAILED - Total weight is 0")
		return nil, nil
	end

	local roll = math.random(1, totalWeight)
	addon:DebugSummon("ROLL: " .. roll .. "/" .. totalWeight)
	local currentSum = 0
	for _, mount in ipairs(allEligibleMounts) do
		currentSum = currentSum + mount.weight
		if roll <= currentSum then
			addon:DebugSummon("SUCCESS - " .. mount.name .. " (weight: " .. mount.originalWeight .. ")")
			self:StorePendingSummon(poolName, mount.groupName, mount.groupType, mount.id)
			return mount.id, mount.name
		end
	end

	-- Fallback to first mount if something goes wrong
	local fallbackMount = allEligibleMounts[1]
	addon:DebugSummon("FALLBACK - " .. fallbackMount.name)
	self:StorePendingSummon(poolName, fallbackMount.groupName, fallbackMount.groupType, fallbackMount.id)
	return fallbackMount.id, fallbackMount.name
end

-- Remove the old SelectMountFromPool method and replace with:
function MountSummon:SelectMountFromPool(poolName)
	-- This is now just a wrapper for the new method
	return self:SelectMountFromPoolWithFilter(poolName, nil)
end

-- ============================================================================
-- INTEGRATION WITH BLIZZARD UI
-- ============================================================================
-- Hook into Blizzard's Random Favorite Mount button
function MountSummon:HookRandomFavoriteButton()
	-- Only hook if the setting is enabled
	if not addon:GetSetting("overrideBlizzardButton") then
		addon:DebugSummon("Not hooking random favorite button (setting disabled).")
		return
	end

	-- Look for the main mount journal random favorite button
	local randomFavoriteButton = MountJournal and MountJournal.SummonRandomFavoriteButton
	if randomFavoriteButton then
		-- Hook the OnClick script
		randomFavoriteButton:HookScript("OnClick", function(self, button, down)
			-- Only intercept left clicks
			if button == "LeftButton" then
				-- Prevent the original handler from running
				self:SetAttribute("macrotext", "")
				-- Call our random mount function
				addon.MountSummon:SummonRandomMount(true)
				-- Return true to indicate we handled the click
				return true
			end
		end)
		addon:DebugSummon("Successfully hooked random favorite mount button.")
	else
		addon:DebugSummon("Could not find random favorite mount button to hook.")
	end
end

-- ============================================================================
-- PUBLIC INTERFACE METHODS
-- ============================================================================
-- Called when data is ready
function MountSummon:OnDataReady()
	addon:DebugSummon("Data ready, building mount pools")
	self:BuildMountPools()
end

-- Called when settings change
function MountSummon:OnSettingChanged(key, value)
	-- Refresh mount pools if needed
	if key == "contextualSummoning" or
			key:find("treat") and key:find("AsDistinct") then
		addon:DebugSummon("Setting changed, refreshing mount pools")
		self:BuildMountPools()
	end
end

-- Refresh mount pools when needed
function MountSummon:RefreshMountPools()
	addon:DebugSummon("Refreshing mount pools")
	self:BuildMountPools()
end

-- Get action for smart button (used by SecureHandlers)
function MountSummon:GetSmartButtonAction()
	-- This could return different actions based on context
	-- For now, just return the basic mount summoning macro
	return "/run RMB:SRM(true)"
end

-- ============================================================================
-- AUTO-INITIALIZATION
-- ============================================================================
-- Auto-initialize when addon loads
function addon:InitializeMountSummon()
	if not self.MountSummon then
		addon:DebugSummon("ERROR - MountSummon not found!")
		return
	end

	self.MountSummon:Initialize()
	-- Hook the random favorite button
	self.MountSummon:HookRandomFavoriteButton()
	-- Register slash commands
	if self.RegisterChatCommand then
		self:RegisterChatCommand("randommount", function()
			self.MountSummon:SummonRandomMount(true)
		end)
	end

	addon:DebugSummon("Integration complete")
end

addon:DebugCore("MountSummon.lua END (Updated Weight 6 Logic).")
function MountSummon:SelectGroupFromPool(pool)
	-- Build list of eligible groups
	local eligibleGroups = {}
	local totalWeight = 0
	local priority6Groups = {}
	-- Add supergroups
	for sgName, families in pairs(pool.superGroups) do
		if #families > 0 then
			-- Additional check to verify families have mounts
			local sgHasValidFamilies = false
			for _, familyName in ipairs(families) do
				if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
					sgHasValidFamilies = true
					break
				end
			end

			if sgHasValidFamilies then
				local groupWeight = addon:GetGroupWeight(sgName)
				if groupWeight > 0 then
					if groupWeight == 6 then
						-- Priority 6 groups get special handling
						table.insert(priority6Groups, {
							name = sgName,
							type = "superGroup",
						})
					else
						-- Regular weighted group
						local probWeight = self:MapWeightToProbability(groupWeight)
						table.insert(eligibleGroups, {
							name = sgName,
							type = "superGroup",
							weight = probWeight,
						})
						totalWeight = totalWeight + probWeight
					end
				end
			else
				addon:DebugSummon("Skipping supergroup with no valid families:", sgName)
			end
		end
	end

	-- Add standalone families
	for familyName, _ in pairs(pool.families) do
		-- Make sure the family actually has mounts in this pool
		if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
			local groupWeight = addon:GetGroupWeight(familyName)
			if groupWeight > 0 then
				if groupWeight == 6 then
					-- Priority 6 groups get special handling
					table.insert(priority6Groups, {
						name = familyName,
						type = "family",
					})
				else
					-- Regular weighted group
					local probWeight = self:MapWeightToProbability(groupWeight)
					table.insert(eligibleGroups, {
						name = familyName,
						type = "family",
						weight = probWeight,
					})
					totalWeight = totalWeight + probWeight
				end
			end
		else
			addon:DebugSummon("Skipping family with no valid mounts:", familyName)
		end
	end

	-- Handle priority 6 groups first - if any exist, ONLY consider them
	if #priority6Groups > 0 then
		local selectedGroup = priority6Groups[math.random(#priority6Groups)]
		addon:DebugSummon("Selected priority 6 group:", selectedGroup.name, selectedGroup.type)
		return selectedGroup.name, selectedGroup.type
	end

	-- Handle regular groups only if no priority 6 groups exist
	if #eligibleGroups == 0 or totalWeight == 0 then
		addon:DebugSummon("No eligible groups found")
		return nil, nil
	end

	-- Weighted selection
	local roll = math.random(1, totalWeight)
	local currentSum = 0
	for _, group in ipairs(eligibleGroups) do
		currentSum = currentSum + group.weight
		if roll <= currentSum then
			addon:DebugSummon("Selected group:", group.name, group.type)
			return group.name, group.type
		end
	end

	-- Fallback
	return eligibleGroups[1].name, eligibleGroups[1].type
end

-- Select a family from a supergroup in a specific pool - UPDATED for Weight 6 Always logic
function MountSummon:SelectFamilyFromPoolSuperGroup(pool, superGroupName)
	-- Get families in this supergroup for this pool
	local families = pool.superGroups[superGroupName] or {}
	if #families == 0 then
		addon:DebugSummon("Supergroup has no families in this pool:", superGroupName)
		return nil
	end

	-- Build list of eligible families with weights
	local eligibleFamilies = {}
	local totalWeight = 0
	local priority6Families = {}
	for _, familyName in ipairs(families) do
		-- Make sure family has mounts in this pool
		if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
			local familyWeight = addon:GetGroupWeight(familyName)
			if familyWeight > 0 then
				if familyWeight == 6 then
					-- Priority 6 families get special handling
					table.insert(priority6Families, {
						name = familyName,
					})
				else
					local probWeight = self:MapWeightToProbability(familyWeight)
					table.insert(eligibleFamilies, {
						name = familyName,
						weight = probWeight,
					})
					totalWeight = totalWeight + probWeight
				end
			end
		end
	end

	-- Handle priority 6 families first - if any exist, ONLY consider them
	if #priority6Families > 0 then
		local selectedFamily = priority6Families[math.random(#priority6Families)]
		addon:DebugSummon("Selected priority 6 family:", selectedFamily.name)
		return selectedFamily.name
	end

	-- If no eligible families, return nil
	if #eligibleFamilies == 0 or totalWeight == 0 then
		addon:DebugSummon("No eligible families found in supergroup")
		return nil
	end

	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	addon:DebugSummon("Family selection roll:", roll, "out of", totalWeight)
	local currentSum = 0
	for _, family in ipairs(eligibleFamilies) do
		currentSum = currentSum + family.weight
		if roll <= currentSum then
			addon:DebugSummon("Selected family:", family.name)
			return family.name
		end
	end

	-- Fallback
	return eligibleFamilies[1].name
end

-- Select a mount from a family in a specific pool - UPDATED for Weight 6 Always logic
function MountSummon:SelectMountFromPoolFamily(pool, familyName)
	-- Get mounts in this family for this pool
	local familyMounts = pool.mountsByFamily[familyName] or {}
	if #familyMounts == 0 then
		addon:DebugSummon("Family has no mounts in this pool:", familyName)
		return nil, nil
	end

	-- Build list of eligible mounts (only those with weight > 0)
	local eligibleMounts = {}
	local totalWeight = 0
	local priority6Mounts = {}
	for _, mountID in ipairs(familyMounts) do
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		-- Double-check mount is still usable
		if isUsable then
			-- Get mount weight - if it's explicitly set to 0, EXCLUDE this mount
			local mountKey = "mount_" .. mountID
			local mountWeight = addon:GetGroupWeight(mountKey)
			-- Skip mounts with explicit 0 weight
			if mountWeight ~= 0 then
				-- If mount has no specific weight, use family weight
				if mountWeight == 0 then
					mountWeight = addon:GetGroupWeight(familyName)
				end

				-- Only include if mount has weight > 0
				if mountWeight > 0 then
					if mountWeight == 6 then
						-- Priority 6 mounts get special handling
						table.insert(priority6Mounts, {
							id = mountID,
							name = name,
						})
					else
						local probWeight = self:MapWeightToProbability(mountWeight)
						table.insert(eligibleMounts, {
							id = mountID,
							name = name,
							weight = probWeight,
						})
						totalWeight = totalWeight + probWeight
					end
				else
					addon:DebugSummon("Mount " .. name .. " and family have weight 0, skipping")
				end
			else
				addon:DebugSummon("Skipping mount " .. name .. " with weight 0")
			end
		end
	end

	-- Handle priority 6 mounts first - if any exist, ONLY consider them
	if #priority6Mounts > 0 then
		local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
		addon:DebugSummon("Selected priority 6 mount:", selectedMount.name)
		return selectedMount.id, selectedMount.name
	end

	-- If no eligible mounts, return nil
	if #eligibleMounts == 0 or totalWeight == 0 then
		addon:DebugSummon("No eligible mounts found in family")
		return nil, nil
	end

	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	local currentSum = 0
	for _, mount in ipairs(eligibleMounts) do
		currentSum = currentSum + mount.weight
		if roll <= currentSum then
			addon:DebugSummon("Selected mount:", mount.name)
			return mount.id, mount.name
		end
	end

	-- Fallback
	return eligibleMounts[1].id, eligibleMounts[1].name
end

function MountSummon:SelectSpecificMountTypeFromPool(poolName, mountType)
	local pool = self.mountPools[poolName]
	if not pool then
		addon:AlwaysPrint(" Invalid pool name:", poolName)
		return nil, nil
	end

	-- Build list of eligible groups first (respecting the hierarchy)
	local eligibleGroups = {}
	local priority6Groups = {}
	-- Add supergroups
	for sgName, families in pairs(pool.superGroups) do
		local superGroupWeight = addon:GetGroupWeight(sgName)
		if superGroupWeight > 0 then
			if superGroupWeight == 6 then
				table.insert(priority6Groups, {
					name = sgName,
					type = "superGroup",
				})
			else
				table.insert(eligibleGroups, {
					name = sgName,
					type = "superGroup",
					weight = self:MapWeightToProbability(superGroupWeight),
				})
			end
		end
	end

	-- Add standalone families
	for familyName, _ in pairs(pool.families) do
		local familyWeight = addon:GetGroupWeight(familyName)
		if familyWeight > 0 then
			if familyWeight == 6 then
				table.insert(priority6Groups, {
					name = familyName,
					type = "family",
				})
			else
				table.insert(eligibleGroups, {
					name = familyName,
					type = "family",
					weight = self:MapWeightToProbability(familyWeight),
				})
			end
		end
	end

	-- Combine priority 6 groups first, then regular groups
	local groupsToCheck = {}
	if #priority6Groups > 0 then
		-- If priority 6 groups exist, randomize and check them first
		for i = #priority6Groups, 2, -1 do
			local j = math.random(i)
			priority6Groups[i], priority6Groups[j] = priority6Groups[j], priority6Groups[i]
		end

		for _, group in ipairs(priority6Groups) do
			table.insert(groupsToCheck, group)
		end
	else
		-- If no priority 6 groups, randomize regular groups
		for i = #eligibleGroups, 2, -1 do
			local j = math.random(i)
			eligibleGroups[i], eligibleGroups[j] = eligibleGroups[j], eligibleGroups[i]
		end

		for _, group in ipairs(eligibleGroups) do
			table.insert(groupsToCheck, group)
		end
	end

	-- Try each group until we find one with matching mount type
	for _, group in ipairs(groupsToCheck) do
		local eligibleFamilies = {}
		if group.type == "superGroup" then
			-- Get all families in this supergroup
			for _, familyName in ipairs(pool.superGroups[group.name] or {}) do
				local familyWeight = addon:GetGroupWeight(familyName)
				if familyWeight > 0 then
					table.insert(eligibleFamilies, {
						name = familyName,
						weight = self:MapWeightToProbability(familyWeight),
					})
				end
			end
		else
			-- Just the standalone family
			table.insert(eligibleFamilies, {
				name = group.name,
				weight = group.weight or 100,
			})
		end

		-- If no eligible families in this group, skip
		if #eligibleFamilies > 0 then
			-- Randomize family order
			for i = #eligibleFamilies, 2, -1 do
				local j = math.random(i)
				eligibleFamilies[i], eligibleFamilies[j] = eligibleFamilies[j], eligibleFamilies[i]
			end

			-- Try each family until we find one with matching mount type
			for _, family in ipairs(eligibleFamilies) do
				local eligibleMounts = {}
				local priority6Mounts = {}
				local totalWeight = 0
				-- Get all mounts in this family
				for _, mountID in ipairs(pool.mountsByFamily[family.name] or {}) do
					local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
					-- Skip unusable mounts
					if isUsable then
						local traits = self:GetEffectiveMountTypeTraits(mountID)
						local isEligible = false
						-- Check if this mount matches the desired type
						if mountType == "skyriding" and traits.isSkyriding then
							isEligible = true
						elseif mountType == "steadyflight" and traits.isSteadyFly then
							isEligible = true
						end

						if isEligible then
							-- Get mount weight
							local mountKey = "mount_" .. mountID
							local mountWeight = addon:GetGroupWeight(mountKey)
							-- Skip mounts with explicit weight 0
							if mountWeight ~= 0 then
								-- If mount has no specific weight, use family weight
								if mountWeight == nil or mountWeight == 0 then
									mountWeight = addon:GetGroupWeight(family.name)
								end

								-- Only include if weight > 0
								if mountWeight > 0 then
									if mountWeight == 6 then
										table.insert(priority6Mounts, {
											id = mountID,
											name = name,
										})
									else
										local probWeight = self:MapWeightToProbability(mountWeight)
										table.insert(eligibleMounts, {
											id = mountID,
											name = name,
											weight = probWeight,
										})
										totalWeight = totalWeight + probWeight
									end
								end
							end
						end
					end
				end

				-- If eligible mounts found in this family, make a selection
				if #priority6Mounts > 0 then
					-- Priority 6 mounts take precedence
					local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
					addon:DebugSummon("Selected priority 6 " .. mountType .. " mount:", selectedMount.name,
						"from family:", family.name,
						group.type == "superGroup" and "in supergroup: " .. group.name or "")
					return selectedMount.id, selectedMount.name
				elseif #eligibleMounts > 0 and totalWeight > 0 then
					-- Weighted random selection from regular mounts
					local roll = math.random(1, totalWeight)
					local currentSum = 0
					for _, mount in ipairs(eligibleMounts) do
						currentSum = currentSum + mount.weight
						if roll <= currentSum then
							addon:DebugSummon("Selected " .. mountType .. " mount:", mount.name,
								"from family:", family.name,
								group.type == "superGroup" and "in supergroup: " .. group.name or "")
							return mount.id, mount.name
						end
					end

					-- Fallback
					return eligibleMounts[1].id, eligibleMounts[1].name
				end
			end
		end
	end

	-- If we got here, no eligible mounts were found
	addon:DebugSummon("No eligible " .. mountType .. " mounts found in any group")
	return nil, nil
end
