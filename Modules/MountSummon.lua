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
	-- Initialize individual mount tracking (session-only, not persisted)
	self.individualMountTracking = {}
	-- Initialize rule deterministic tracking (session-only, not persisted)
	self.rulesDeterministicCache = {}
	-- Structure: [ruleID] = {
	--   type = "pool" or "specific",
	--   poolName = "flying",  -- for pool-based rules only
	--   unavailableGroups = {},  -- for pool-based rules (counts until available)
	--   unavailableMounts = {},  -- for specific mount rules { [mountID] = bannedUntil timestamp }
	--   recentSummons = {},  -- for specific mount rules { [mountID] = { timestamp1, timestamp2, ... } }
	--   pendingSummon = nil  -- { ruleID, mountID, timestamp }
	-- }
	-- Track summon source to prevent double processing
	self.currentSummonSource = nil -- "rule" or "normal" or nil
	-- Pool rebuild retry tracking (for NPC blocking on reload)
	self.poolRebuildScheduled = false
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
			if event == "UNIT_SPELLCAST_START" then
				local unit, castGUID, spellID = ...
				if unit == "player" then
					-- Check if this is a mount summon spell
					local isMountSpell, mountID = self:IsMountSummonSpell(spellID)
					if isMountSpell and mountID then
						addon:DebugSummon("Mount cast STARTED - Spell: " .. spellID .. ", Mount: " .. mountID)
						-- Clean expired summon history for this mount
						self:CleanExpiredSummonHistory(mountID)
						-- Store pending summon now that we know cast actually started
						self:StorePendingSummonFromCastStart(mountID)
					end
				end
			elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
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
						-- Check if this is a mount summon spell
						local isMountSpell, mountID = self:IsMountSummonSpell(spellID)
						if isMountSpell and mountID then
							addon:DebugSummon("Mount cast COMPLETED - Spell: " .. spellID .. ", Mount: " .. mountID)
							-- Process the ban since the cast completed successfully
							self:ProcessSuccessfulMountSummon(mountID)
						end
					end
				end
			end
		end)
	end

	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	addon:DebugCore("Registered for flight style change and mount summon tracking events")
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
	-- Create session-only cache (not persisted to database)
	-- This ensures bans clear on reload/logout
	self.deterministicCache = {
		flying = { unavailableGroups = {}, pendingSummon = nil },
		ground = { unavailableGroups = {}, pendingSummon = nil },
		underwater = { unavailableGroups = {}, pendingSummon = nil },
		groundUsable = { unavailableGroups = {}, pendingSummon = nil },
	}
	addon:DebugSummon("System initialized (session-only cache)")
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

-- Count groups in pool ignoring weights (for rule deterministic mode)
-- Rules should consider ALL groups with usable mounts, regardless of weight settings
-- Works directly with mountsByFamily to bypass weight-based pool structure filtering
function MountSummon:GetTotalGroupsInPoolIgnoreWeights(poolName)
	local pool = self.mountPools[poolName]
	if not pool then return 0 end

	-- Build list of ALL families that have usable mounts, regardless of pool structure
	local allFamilies = {}
	for familyName, mounts in pairs(pool.mountsByFamily) do
		if mounts and #mounts > 0 then
			-- Check if family has any usable mounts
			local hasUsableMounts = false
			for _, mountID in ipairs(mounts) do
				local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					hasUsableMounts = true
					break
				end
			end

			if hasUsableMounts then
				table.insert(allFamilies, familyName)
			end
		end
	end

	-- Group families by supergroup
	local superGroups = {}
	local standaloneFamilies = 0
	for _, familyName in ipairs(allFamilies) do
		local superGroup = addon:GetDynamicSuperGroup(familyName)
		if superGroup then
			superGroups[superGroup] = true
		else
			standaloneFamilies = standaloneFamilies + 1
		end
	end

	-- Count total groups (unique supergroups + standalone families)
	local totalGroups = standaloneFamilies
	for _ in pairs(superGroups) do
		totalGroups = totalGroups + 1
	end

	addon:DebugSummon("Pool " .. poolName .. " (ignore weights): " .. totalGroups .. " groups (" ..
		#allFamilies .. " total families)")
	return totalGroups
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
-- Calculate unavailability duration for a group
function MountSummon:CalculateUnavailabilityDuration(poolName, groupKey, groupType)
	local totalGroups = self:GetTotalGroupsInPool(poolName) -- Now uses fixed counting
	-- SAFEGUARD: Don't use deterministic mode for very small pools
	if totalGroups < 5 then
		-- Special case: pool of 4 gets ban duration of 1
		if totalGroups == 4 then
			addon:DebugSummon("Pool " .. poolName .. " has 4 groups, ban duration: 1")
			return 1
		end

		addon:DebugSummon("Pool " .. poolName .. " has only " .. totalGroups ..
			" selectable groups, disabling deterministic summoning")
		return 0
	end

	-- Get the group's weight
	local groupWeight = addon:GetGroupWeight(groupKey)
	-- Individual formulas per weight with different multipliers and caps
	local multiplier, cap
	if groupWeight == 1 then
		multiplier = 0.47
		cap = 20
	elseif groupWeight == 2 then
		multiplier = 0.4
		cap = 16
	elseif groupWeight == 3 then
		multiplier = 0.34
		cap = 12
	elseif groupWeight == 4 then
		multiplier = 0.2
		cap = 8
	elseif groupWeight == 5 then
		multiplier = 0.1
		cap = 4
	elseif groupWeight == 6 then
		-- Weight 6 (Always) should never be banned
		return 0
	else
		-- Default to weight 3 for any unexpected values
		multiplier = 0.34
		cap = 12
	end

	-- Calculate ban duration
	local banDuration = math.floor(totalGroups * multiplier)
	banDuration = math.min(cap, banDuration)
	banDuration = math.max(1, banDuration)
	addon:DebugSummon("Pool " .. poolName .. " (" .. totalGroups .. " selectable groups) - " ..
		"Weight " .. groupWeight .. " group '" .. groupKey ..
		"' banned for " .. banDuration .. " summons")
	return banDuration
end

-- Filter pool to remove unavailable groups
function MountSummon:FilterPoolForDeterministic(pool, poolName)
	if not self:IsDeterministicModeEnabled() then
		return pool -- Return original pool if deterministic mode disabled
	end

	local deterministicCache = self.deterministicCache
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

	local deterministicCache = self.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache then
		addon:DebugSummon("No cache for pool " .. poolName)
		return
	end

	if not cache.unavailableGroups then
		cache.unavailableGroups = {}
	end

	-- Add 1 to duration because decrement happens BEFORE filtering on next summon
	-- Without this, "ban for 2" actually means unavailable for only 1 summon
	cache.unavailableGroups[groupKey] = duration + 1
	addon:DebugSummon("Marked " ..
		groupKey .. " unavailable for " .. duration .. " summons in " .. poolName .. " pool")
end

-- Decrement unavailability counters for all groups in a pool
function MountSummon:DecrementUnavailabilityCounters(poolName)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local deterministicCache = self.deterministicCache
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

	local deterministicCache = self.deterministicCache
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

-- Store pending summon when cast starts (prevents spam-click overwrites)
function MountSummon:StorePendingSummonFromCastStart(mountID)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	-- Skip normal cache processing if this is a rule summon
	-- Rule summons use their own cache system
	if self.currentSummonSource == "rule" then
		addon:DebugSummon("Skipping normal cache for rule summon")
		return
	end

	local poolName, groupName, groupType = self:FindMountPoolAndGroup(mountID)
	if poolName and groupName and groupType then
		local deterministicCache = self.deterministicCache
		local cache = deterministicCache and deterministicCache[poolName]
		if cache then
			cache.pendingSummon = {
				groupKey = groupName,
				groupType = groupType,
				mountID = mountID,
				timestamp = GetTime(),
			}
			addon:DebugSummon("Stored pending summon from cast start - Group: " .. groupName .. ", Mount: " .. mountID)
		end
	end
end

-- Helper to find which pool/group a mount belongs to (reverse lookup)
function MountSummon:FindMountPoolAndGroup(mountID)
	-- We need to determine which pool was used for this summon
	-- Check the mount's capabilities and current context to deduce the likely pool
	local context = self:GetCurrentContext()
	local traits = self:GetEffectiveMountTypeTraits(mountID)
	-- Determine most likely pool based on context and mount capabilities
	local likelyPool = "unified" -- Default fallback
	if context.isUnderwater and traits.isAquatic then
		likelyPool = "underwater"
	elseif (context.canFly or context.canDragonride) and (traits.isSteadyFly or traits.isSkyriding) then
		likelyPool = "flying"
	elseif traits.isGround and not (traits.isSteadyFly or traits.isSkyriding) then
		likelyPool = "ground"
	elseif traits.isGround then
		likelyPool = "groundUsable"
	end

	-- Find the mount in the likely pool
	local pool = self.mountPools[likelyPool]
	if pool then
		for familyName, mounts in pairs(pool.mountsByFamily) do
			for _, mID in ipairs(mounts) do
				if mID == mountID then
					-- Found the family, determine if it's in a supergroup
					local superGroup = addon:GetDynamicSuperGroup(familyName)
					if superGroup then
						return likelyPool, superGroup, "superGroup"
					else
						return likelyPool, familyName, "family"
					end
				end
			end
		end
	end

	-- Fallback: search all pools if not found in likely pool
	for poolName, pool in pairs(self.mountPools) do
		if poolName ~= likelyPool then -- Skip the one we already checked
			for familyName, mounts in pairs(pool.mountsByFamily) do
				for _, mID in ipairs(mounts) do
					if mID == mountID then
						local superGroup = addon:GetDynamicSuperGroup(familyName)
						if superGroup then
							return poolName, superGroup, "superGroup"
						else
							return poolName, familyName, "family"
						end
					end
				end
			end
		end
	end

	addon:DebugSummon("Could not find pool/group for mount ID: " .. mountID)
	return nil, nil, nil
end

-- Process the actual ban when cast completes successfully
function MountSummon:ProcessSuccessfulMountSummon(mountID)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	-- Check which system initiated this summon
	local isRuleSummon = self.currentSummonSource == "rule"
	-- Process normal pool summons (skip if this is a rule summon)
	if not isRuleSummon then
		local deterministicCache = self.deterministicCache
		if deterministicCache then
			for poolName, cache in pairs(deterministicCache) do
				local pendingSummon = cache and cache.pendingSummon
				if pendingSummon and pendingSummon.mountID and pendingSummon.mountID == mountID then
					addon:DebugSummon("Processing successful summon for pool: " .. poolName)
					self:ProcessSuccessfulSummon(poolName)
					break
				end
			end
		end
	end

	-- Process rule-based summons (only if this is a rule summon)
	if isRuleSummon and self.rulesDeterministicCache then
		for ruleID, ruleCache in pairs(self.rulesDeterministicCache) do
			local pendingSummon = ruleCache and ruleCache.pendingSummon
			if pendingSummon and pendingSummon.mountID and pendingSummon.mountID == mountID then
				addon:DebugSummon("Processing successful summon for rule: " .. ruleID)
				self:ProcessSuccessfulRuleSummon(ruleID)
				break
			end
		end
	end

	-- Clear summon source flag
	self.currentSummonSource = nil
end

-- Process successful summon
function MountSummon:ProcessSuccessfulSummon(poolName)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local cache = self.deterministicCache and self.deterministicCache[poolName]
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
	-- Record individual mount summon for time-based tracking
	if pending.mountID then
		local mountKey = "mount_" .. pending.mountID
		local mountWeight = addon:GetGroupWeight(mountKey)
		-- If mount has no specific weight, get from family/group
		if not mountWeight or mountWeight == 0 then
			mountWeight = addon:GetGroupWeight(pending.groupKey)
		end

		-- Default to weight 3 if somehow still nil
		if not mountWeight then
			mountWeight = 3
		end

		self:RecordIndividualMountSummon(pending.mountID, mountWeight)
	end

	-- Don't decrement immediately - let the next summon attempt handle it
	-- The decrement should happen BEFORE filtering, not after successful summon
	-- Clear pending summon
	cache.pendingSummon = nil
	addon:DebugSummon("Processed successful summon for " .. pending.groupKey)
end

-- ============================================================================
-- INDIVIDUAL MOUNT TRACKING (TIME-BASED BANS)
-- ============================================================================
-- Clean expired summon history for a mount (removes timestamps older than 31 minutes)
function MountSummon:CleanExpiredSummonHistory(mountID)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local tracking = self.individualMountTracking[mountID]
	if not tracking or not tracking.recentSummons then
		return
	end

	local currentTime = GetTime()
	local cleaned = {}
	for _, timestamp in ipairs(tracking.recentSummons) do
		-- Keep timestamps less than 31 minutes old
		if (currentTime - timestamp) < 1860 then -- 31 minutes in seconds
			table.insert(cleaned, timestamp)
		end
	end

	tracking.recentSummons = cleaned
	if #cleaned == 0 and not tracking.bannedUntil then
		-- No data left, clean up the entry entirely
		self.individualMountTracking[mountID] = nil
	end
end

-- Get the summon threshold for individual mount bans based on weight
function MountSummon:GetIndividualBanThreshold(mountWeight)
	if mountWeight == 6 then
		return 999 -- Never ban weight 6 (Always) mounts
	elseif mountWeight == 5 then
		return 6
	elseif mountWeight == 4 then
		return 4
	else
		-- Weight 1, 2, 3, or default
		return 2
	end
end

-- Record an individual mount summon and potentially ban it
function MountSummon:RecordIndividualMountSummon(mountID, mountWeight)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	-- Weight 6 mounts are never tracked/banned
	if mountWeight == 6 then
		return
	end

	-- Initialize tracking for this mount if needed
	if not self.individualMountTracking[mountID] then
		self.individualMountTracking[mountID] = {
			recentSummons = {},
			bannedUntil = nil,
		}
	end

	local tracking = self.individualMountTracking[mountID]
	local currentTime = GetTime()
	-- Don't record summons while mount is already banned
	if tracking.bannedUntil and currentTime < tracking.bannedUntil then
		local mountName = C_MountJournal.GetMountInfoByID(mountID)
		addon:DebugSummon("Mount " .. (mountName or mountID) .. " summoned via fallback, already banned until " ..
			math.floor(tracking.bannedUntil - currentTime) .. "s from now")
		return
	end

	-- Add current summon timestamp
	table.insert(tracking.recentSummons, currentTime)
	-- Keep only last 10 summons
	if #tracking.recentSummons > 10 then
		table.remove(tracking.recentSummons, 1)
	end

	local mountName = C_MountJournal.GetMountInfoByID(mountID)
	local threshold = self:GetIndividualBanThreshold(mountWeight)
	-- Log the tracking
	addon:DebugSummon("Tracked individual mount summon: " .. (mountName or mountID) ..
		" (" .. #tracking.recentSummons .. "/" .. threshold .. " summons, weight: " .. mountWeight .. ")")
	-- Check if we should ban this mount
	if #tracking.recentSummons >= threshold then
		-- Ban for 30 minutes from now
		tracking.bannedUntil = currentTime + 1800 -- 30 minutes
		addon:DebugSummon("Mount " .. (mountName or mountID) .. " BANNED for 30 minutes (triggered after " ..
			#tracking.recentSummons .. " summons within 30min)")
	end
end

-- Check if a mount is currently individually banned
function MountSummon:IsMountIndividuallyBanned(mountID)
	if not self:IsDeterministicModeEnabled() then
		return false
	end

	local tracking = self.individualMountTracking[mountID]
	if not tracking or not tracking.bannedUntil then
		return false
	end

	local currentTime = GetTime()
	if currentTime < tracking.bannedUntil then
		return true
	else
		-- Ban expired, clear it
		tracking.bannedUntil = nil
		return false
	end
end

-- Count how many mounts in a family are currently banned (optionally filtered by mount type)
function MountSummon:GetBannedMountCountInFamily(pool, familyName, mountTypeFilter)
	if not self:IsDeterministicModeEnabled() then
		return 0
	end

	local familyMounts = pool.mountsByFamily[familyName] or {}
	local bannedCount = 0
	for _, mountID in ipairs(familyMounts) do
		if self:IsMountIndividuallyBanned(mountID) then
			-- If type filter specified, only count if mount matches the type
			if mountTypeFilter then
				local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					local matchesType = false
					if mountTypeFilter == "skyriding" and traits.isSkyriding then
						matchesType = true
					elseif mountTypeFilter == "steadyflight" and traits.isSteadyFly then
						matchesType = true
					end

					if matchesType then
						bannedCount = bannedCount + 1
					end
				end
			else
				-- No filter, count all banned mounts
				bannedCount = bannedCount + 1
			end
		end
	end

	return bannedCount
end

-- Clear all individual bans for mounts in a family
function MountSummon:ClearFamilyIndividualBans(pool, familyName)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local familyMounts = pool.mountsByFamily[familyName] or {}
	local clearedCount = 0
	for _, mountID in ipairs(familyMounts) do
		local tracking = self.individualMountTracking[mountID]
		if tracking then
			local hadBan = tracking.bannedUntil ~= nil
			local hadHistory = tracking.recentSummons and #tracking.recentSummons > 0
			-- Clear ban
			tracking.bannedUntil = nil
			-- Clear summon history (fresh start after failsafe)
			tracking.recentSummons = {}
			if hadBan or hadHistory then
				clearedCount = clearedCount + 1
			end
		end
	end

	if clearedCount > 0 then
		addon:DebugSummon("Cleared " .. clearedCount .. " individual mount bans AND summon history in family: " .. familyName)
	end
end

-- Reset all individual mount tracking (called on weight changes, pool rebuilds, etc.)
function MountSummon:ResetAllIndividualBans()
	if self.individualMountTracking then
		local totalTracked = 0
		for _ in pairs(self.individualMountTracking) do
			totalTracked = totalTracked + 1
		end

		if totalTracked > 0 then
			addon:DebugSummon("Resetting all individual mount tracking (" .. totalTracked .. " mounts tracked)")
		end

		self.individualMountTracking = {}
	end
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
	-- Cancel any scheduled retry since we're building now
	if self.poolRebuildScheduled then
		addon:DebugSummon("Cancelling scheduled pool rebuild retry (manual rebuild triggered)")
		self.poolRebuildScheduled = false
	end

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

	local playerLevel = UnitLevel("player")
	addon:DebugSummon("Processed " .. mountsProcessed .. " mounts into context pools (player level: " .. playerLevel .. ")")
	-- Only treat mountsProcessed == 0 as NPC blocking if:
	-- 1. Player is high enough level to mount (level 10+ for ground mounts)
	-- 2. We have collected mounts but none were processed as usable
	--
	-- Skip NPC blocking detection for low-level characters since they legitimately
	-- can't use mounts yet (level restriction shows all mounts as isUsable = false)
	if mountsProcessed == 0 and playerLevel >= 10 then
		addon:DebugSummon(
			"WARNING: 0 mounts processed at level " ..
			playerLevel .. " - likely near NPC blocking mounting. Scheduling retry in 2 seconds...")
		if not self.poolRebuildScheduled then
			self.poolRebuildScheduled = true
			C_Timer.After(2.0, function()
				self.poolRebuildScheduled = false
				if addon.RMB_DataReadyForUI and addon.processedData and addon.processedData.allCollectedMountFamilyInfo then
					addon:DebugSummon("Retry: Rebuilding pools after NPC blocking delay")
					self:BuildMountPools()
				end
			end)
		end
	elseif mountsProcessed == 0 and playerLevel < 10 then
		addon:DebugSummon("No usable mounts at level " .. playerLevel .. " - this is expected (mounts unlock at level 10)")
	end

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
	-- Clear any very old pending summons (older than 10 seconds) as they're likely stale
	if self:IsDeterministicModeEnabled() then
		local deterministicCache = self.deterministicCache
		if deterministicCache then
			local currentTime = GetTime()
			for poolName, cache in pairs(deterministicCache) do
				if cache and cache.pendingSummon then
					local pendingSummon = cache.pendingSummon
					-- Check if timestamp field exists and is a valid number
					local timestamp = pendingSummon and pendingSummon["timestamp"]
					if timestamp and type(timestamp) == "number" then
						local age = currentTime - timestamp
						if age > 10.0 then
							addon:DebugSummon("Clearing very old pending summon (age: " ..
								string.format("%.1f", age) .. "s) for pool: " .. poolName)
							cache.pendingSummon = nil
						end
					else
						-- If no timestamp or invalid timestamp, this is legacy data - clear it
						addon:DebugSummon("Clearing pending summon with no/invalid timestamp for pool: " .. poolName)
						cache.pendingSummon = nil
					end
				end
			end
		end
	end

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

	local deterministicCache = self.deterministicCache
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

	-- TARGET MOUNT: Check if we should summon target's mount
	if addon:GetSetting("summonTargetMount") then
		-- Check if we have a valid player target
		if UnitExists("target") and UnitIsPlayer("target") then
			addon:DebugSummon("Checking target for mount...")
			-- Scan target's buffs to find a mount aura
			local targetMountID = nil
			local targetMountName = nil
			for i = 1, 40 do
				-- Use modern API to get buff data
				local auraData = C_UnitAuras.GetBuffDataByIndex("target", i)
				if not auraData then break end -- No more buffs

				local buffSpellID = auraData.spellId
				if buffSpellID then
					-- Check if this spell ID matches any mount in the journal
					local allMountIDs = C_MountJournal.GetMountIDs()
					for _, mountID in ipairs(allMountIDs) do
						local mountName, mountSpellID, _, _, isUsable, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(
							mountID)
						if mountSpellID == buffSpellID then
							-- Found a match - this is a mount buff
							targetMountID = mountID
							targetMountName = mountName
							if not isCollected then
								-- Player doesn't own this mount
								addon:DebugSummon("Target's mount not collected:", mountName)
								UIErrorsFrame:AddMessage("Unable to summon " .. mountName .. ": not collected.", 1.0, 0.1, 0.1, 1.0)
								-- Fall through to normal summoning
								break
							elseif not isUsable then
								-- Player owns it but can't use it (faction/class/level restriction)
								addon:DebugSummon("Target's mount not usable:", mountName)
								UIErrorsFrame:AddMessage("Unable to summon " .. mountName .. ": not usable on this character.", 1.0, 0.1,
									0.1, 1.0)
								-- Fall through to normal summoning
								break
							else
								-- Mount is collected AND usable - summon it!
								addon:DebugSummon("Found target's mount (collected and usable) - summoning:", mountName)
								return self:SummonMount(mountID)
							end
						end
					end

					-- If we found and processed a mount, stop scanning
					if targetMountID then break end
				end
			end

			if not targetMountID then
				addon:DebugSummon("Target has no mount buff")
				-- Fall through to normal summoning
			end
		end
	end

	-- MOUNT RULES: Check if current state matches any rules
	if addon.MountRules then
		local specificMountID, specificPoolName = addon.MountRules:GetMountForCurrentLocation()
		if specificMountID then
			-- Summon the specific mount for this location
			addon:DebugSummon("Zone-specific mount found, summoning mount ID:", specificMountID)
			self.currentSummonSource = "rule" -- Mark as rule summon
			return self:SummonMount(specificMountID)
		elseif specificPoolName then
			-- Use the specific pool for this location
			addon:DebugSummon("Zone-specific pool found, using pool:", specificPoolName)
			self.currentSummonSource = "rule" -- Mark as rule summon
			local mountID, mountName = self:SelectMountFromPoolWithFilter(specificPoolName, nil)
			if mountID then
				return self:SummonMount(mountID)
			else
				addon:DebugSummon("No mounts available in zone-specific pool:", specificPoolName)
				self.currentSummonSource = nil -- Clear flag on failure
				-- Fall through to normal logic
			end
		end
	end

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
					-- Show user message explaining the likely cause
					UIErrorsFrame:AddMessage(
						"Login/Reload near some NPCs causes temporary mount restriction. Please move away to be able to mount again.",
						1.0, 0.8, 0.0, 1.0)
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
		-- Check if this is likely due to NPC restriction
		-- If pools are populated but no mounts are eligible, and player is high enough level
		local playerLevel = UnitLevel("player")
		local poolsHaveMounts = self:ArePoolsInitialized()
		addon:DebugSummon("NPC restriction check - pools initialized: " .. tostring(poolsHaveMounts) ..
			", player level: " .. playerLevel ..
			", in combat: " .. tostring(InCombatLockdown()))
		if poolsHaveMounts and playerLevel >= 10 and not InCombatLockdown() then
			-- Pools exist but no eligible mounts - likely NPC restriction
			addon:DebugSummon("Likely NPC restriction - showing message to player")
			UIErrorsFrame:AddMessage("Mount restricted area", 1.0, 0.1, 0.1, 1.0)
		end

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
	addon:DebugSummon("SelectSpecificMountType (IGNORE WEIGHTS, family-first) for", mountType, "in", poolName, "pool")
	-- Pre-filter pool to only families that have mounts matching mountType
	local filteredPool = {
		superGroups = {},
		families = {},
		mountsByFamily = pool.mountsByFamily,
		mountWeights = pool.mountWeights,
	}
	-- Include ALL supergroups that have at least one family with matching mounts (ignore weights)
	for sgName, families in pairs(pool.superGroups) do
		local hasMatchingFamily = false
		for _, familyName in ipairs(families) do
			if self:FamilyHasMatchingMountsIgnoreWeights(pool, familyName, mountType) then
				hasMatchingFamily = true
				break
			end
		end

		if hasMatchingFamily then
			filteredPool.superGroups[sgName] = families
		end
	end

	-- Include ALL standalone families that have matching mounts (ignore weights)
	for familyName, _ in pairs(pool.families) do
		if self:FamilyHasMatchingMountsIgnoreWeights(pool, familyName, mountType) then
			filteredPool.families[familyName] = true
		end
	end

	if not next(filteredPool.superGroups) and not next(filteredPool.families) then
		addon:DebugSummon("No eligible " .. mountType .. " mounts found even ignoring weights")
		return nil, nil
	end

	-- Build list of ALL groups (ignoring weights)
	local allGroups = {}
	for sgName, _ in pairs(filteredPool.superGroups) do
		table.insert(allGroups, { name = sgName, type = "superGroup" })
	end

	for familyName, _ in pairs(filteredPool.families) do
		table.insert(allGroups, { name = familyName, type = "family" })
	end

	-- Randomize group order
	for i = #allGroups, 2, -1 do
		local j = math.random(i)
		allGroups[i], allGroups[j] = allGroups[j], allGroups[i]
	end

	-- Try each group until we find one with matching mounts
	for _, group in ipairs(allGroups) do
		local eligibleFamilies = {}
		if group.type == "superGroup" then
			for _, familyName in ipairs(filteredPool.superGroups[group.name] or {}) do
				if self:FamilyHasMatchingMountsIgnoreWeights(pool, familyName, mountType) then
					table.insert(eligibleFamilies, { name = familyName })
				end
			end
		else
			table.insert(eligibleFamilies, { name = group.name })
		end

		-- Randomize family order
		for i = #eligibleFamilies, 2, -1 do
			local j = math.random(i)
			eligibleFamilies[i], eligibleFamilies[j] = eligibleFamilies[j], eligibleFamilies[i]
		end

		-- Try each family
		for _, family in ipairs(eligibleFamilies) do
			local eligibleMounts = {}
			for _, mountID in ipairs(pool.mountsByFamily[family.name] or {}) do
				local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					local matchesType = false
					if mountType == "skyriding" and traits.isSkyriding then
						matchesType = true
					elseif mountType == "steadyflight" and traits.isSteadyFly then
						matchesType = true
					end

					if matchesType then
						-- Still respect explicit mount weight 0
						local mountKey = "mount_" .. mountID
						local mountWeight = addon:GetGroupWeight(mountKey)
						if mountWeight ~= 0 then
							table.insert(eligibleMounts, {
								id = mountID,
								name = name,
							})
						end
					end
				end
			end

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

-- Helper for ignore-weights version
function MountSummon:FamilyHasMatchingMountsIgnoreWeights(pool, familyName, mountType)
	local familyMounts = pool.mountsByFamily[familyName] or {}
	for _, mountID in ipairs(familyMounts) do
		local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			local traits = self:GetEffectiveMountTypeTraits(mountID)
			local matchesType = false
			if mountType == "skyriding" and traits.isSkyriding then
				matchesType = true
			elseif mountType == "steadyflight" and traits.isSteadyFly then
				matchesType = true
			end

			if matchesType then
				-- Still respect explicit mount weight 0
				local mountKey = "mount_" .. mountID
				local mountWeight = addon:GetGroupWeight(mountKey)
				if mountWeight ~= 0 then
					return true
				end
			end
		end
	end

	return false
end

-- Updated method that works with already-filtered pools:
function MountSummon:SelectMountFromFilteredPool(pool, poolName, mountTypeFilter)
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

	-- Step 3: Select mount from family (with optional type filter)
	local mountID, mountName = self:SelectMountFromPoolFamily(pool, familyName, mountTypeFilter)
	return mountID, mountName
end

function MountSummon:SelectSpecificMountTypeFromFilteredPool(pool, poolName, mountType)
	addon:DebugCore("=== " .. mountType .. " selection in " .. poolName .. " (family-first) ===")
	-- Pre-filter pool to only families that have mounts matching mountType
	-- This prevents deadlocks where we pick a family with no matching mounts
	local filteredPool = {
		superGroups = {},
		families = {},
		mountsByFamily = pool.mountsByFamily, -- Keep all mount lists
		mountWeights = pool.mountWeights,
	}
	-- Filter supergroups - only include if at least one family has matching mounts
	for sgName, families in pairs(pool.superGroups) do
		local hasMatchingFamily = false
		for _, familyName in ipairs(families) do
			if self:FamilyHasMatchingMounts(pool, familyName, mountType) then
				hasMatchingFamily = true
				break
			end
		end

		if hasMatchingFamily then
			filteredPool.superGroups[sgName] = families
		else
			addon:DebugSummon("Filtering out supergroup " .. sgName .. " (no families with " .. mountType .. " mounts)")
		end
	end

	-- Filter standalone families - only include if has matching mounts
	for familyName, _ in pairs(pool.families) do
		if self:FamilyHasMatchingMounts(pool, familyName, mountType) then
			filteredPool.families[familyName] = true
		else
			addon:DebugSummon("Filtering out family " .. familyName .. " (no " .. mountType .. " mounts)")
		end
	end

	-- Count available groups
	local totalSG = 0
	local totalFam = 0
	for _ in pairs(filteredPool.superGroups) do totalSG = totalSG + 1 end

	for _ in pairs(filteredPool.families) do totalFam = totalFam + 1 end

	addon:DebugCore("After type filtering: " .. totalSG .. " SG, " .. totalFam .. " families")
	if totalSG == 0 and totalFam == 0 then
		addon:DebugCore("FAILED - No groups with " .. mountType .. " mounts")
		return nil, nil
	end

	-- Now use standard selection path with the pre-filtered pool
	return self:SelectMountFromFilteredPool(filteredPool, poolName, mountType)
end

-- Helper function to check if a family has any mounts matching the mount type
function MountSummon:FamilyHasMatchingMounts(pool, familyName, mountType)
	local familyMounts = pool.mountsByFamily[familyName] or {}
	for _, mountID in ipairs(familyMounts) do
		local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			local traits = self:GetEffectiveMountTypeTraits(mountID)
			local matchesType = false
			if mountType == "skyriding" and traits.isSkyriding then
				matchesType = true
			elseif mountType == "steadyflight" and traits.isSteadyFly then
				matchesType = true
			end

			if matchesType then
				-- Check if mount has valid weight
				local mountKey = "mount_" .. mountID
				local mountWeight = addon:GetGroupWeight(mountKey)
				if mountWeight ~= 0 then
					if mountWeight == 0 then
						mountWeight = addon:GetGroupWeight(familyName)
					end

					if mountWeight and mountWeight > 0 then
						return true -- Found at least one matching mount
					end
				end
			end
		end
	end

	return false
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
	-- Reset individual bans if deterministic mode is toggled
	if key == "useDeterministicSummoning" then
		self:ResetAllIndividualBans()
	end

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
	self:ResetAllIndividualBans() -- Clear individual mount tracking on pool refresh
	self:BuildMountPools()
end

-- ============================================================================
-- RULE DETERMINISTIC MODE
-- ============================================================================
-- Main entry point for deterministic rule selection
function MountSummon:SelectMountFromRuleDeterministic(rule)
	if not rule then
		return nil, nil
	end

	addon:DebugSummon("=== Deterministic rule selection: Rule ID " .. rule.id .. " ===")
	if rule.actionType == "pool" then
		return self:SelectMountFromRulePool(rule)
	elseif rule.actionType == "specific" then
		return self:SelectMountFromRuleSpecific(rule)
	else
		addon:DebugSummon("Unknown rule action type:", rule.actionType)
		return nil, nil
	end
end

-- Select mount from pool-based rule with group-level deterministic banning
function MountSummon:SelectMountFromRulePool(rule)
	local poolName = rule.poolName
	-- Handle custom pools (ridealong, passenger, etc.)
	if addon.MountRules.CUSTOM_POOLS and addon.MountRules.CUSTOM_POOLS[poolName] then
		addon:DebugSummon("Custom pool detected, treating as specific mount list")
		-- Treat custom pools like specific mount rules
		local customMountIDs = addon.MountRules.CUSTOM_POOLS[poolName].mountIDs
		return self:SelectMountFromRuleSpecific({
			id = rule.id,
			actionType = "specific",
			mountIDs = customMountIDs,
		})
	end

	-- Get the actual mount pool
	local originalPool = self.mountPools[poolName]
	if not originalPool then
		addon:DebugSummon("Invalid pool name for rule:", poolName)
		return nil, nil
	end

	-- Initialize rule cache if needed
	if not self.rulesDeterministicCache[rule.id] then
		self.rulesDeterministicCache[rule.id] = {
			type = "pool",
			poolName = poolName,
			unavailableGroups = {},
			pendingSummon = nil,
		}
	end

	local ruleCache = self.rulesDeterministicCache[rule.id]
	-- Validate cache type matches current rule action (handle rule modifications)
	if ruleCache.type ~= "pool" then
		addon:DebugSummon("Rule " .. rule.id .. " cache type mismatch (was " .. (ruleCache.type or "nil") ..
			", expected pool), resetting cache")
		self.rulesDeterministicCache[rule.id] = {
			type = "pool",
			poolName = poolName,
			unavailableGroups = {},
			pendingSummon = nil,
		}
		ruleCache = self.rulesDeterministicCache[rule.id]
	end

	-- Decrement unavailability counters
	self:DecrementRuleUnavailabilityCounters(rule.id)
	-- Pass the pool and banned groups to selection (no pre-filtering needed)
	-- SelectFromPoolIgnoreWeights will check bans during group selection
	local mountID, mountName = self:SelectFromPoolIgnoreWeights(originalPool, poolName, ruleCache.unavailableGroups)
	if mountID then
		-- Find which group this mount belongs to
		local groupKey, groupType = self:FindMountGroupInPool(originalPool, mountID)
		if groupKey and groupType then
			-- Store pending summon for this rule
			ruleCache.pendingSummon = {
				ruleID = rule.id,
				groupKey = groupKey,
				groupType = groupType,
				mountID = mountID,
				timestamp = GetTime(),
			}
			addon:DebugSummon("Stored pending rule summon - Rule ID: " .. rule.id ..
				", Group: " .. groupKey .. ", Mount: " .. mountID)
		end
	end

	return mountID, mountName
end

-- Filter pool for rule-specific deterministic banning (group-based)
function MountSummon:FilterPoolForRuleDeterministic(pool, ruleID)
	local ruleCache = self.rulesDeterministicCache[ruleID]
	if not ruleCache or not ruleCache.unavailableGroups then
		return pool -- Return original if no cache
	end

	local filteredPool = {
		superGroups = {},
		families = {},
		mountsByFamily = pool.mountsByFamily,
		mountWeights = pool.mountWeights,
	}
	-- Filter supergroups
	for sgName, families in pairs(pool.superGroups) do
		local unavailableCount = ruleCache.unavailableGroups[sgName]
		if not unavailableCount or unavailableCount <= 0 then
			filteredPool.superGroups[sgName] = families
		else
			addon:DebugSummon("Supergroup " .. sgName .. " unavailable for rule " .. ruleID ..
				" (" .. unavailableCount .. " summons remaining)")
		end
	end

	-- Filter standalone families
	for familyName, _ in pairs(pool.families) do
		local unavailableCount = ruleCache.unavailableGroups[familyName]
		if not unavailableCount or unavailableCount <= 0 then
			filteredPool.families[familyName] = true
		else
			addon:DebugSummon("Family " .. familyName .. " unavailable for rule " .. ruleID ..
				" (" .. unavailableCount .. " summons remaining)")
		end
	end

	return filteredPool
end

-- Decrement unavailability counters for a rule
function MountSummon:DecrementRuleUnavailabilityCounters(ruleID)
	local ruleCache = self.rulesDeterministicCache[ruleID]
	if not ruleCache or not ruleCache.unavailableGroups then
		return
	end

	local decremented = false
	for groupKey, count in pairs(ruleCache.unavailableGroups) do
		if count > 0 then
			ruleCache.unavailableGroups[groupKey] = count - 1
			decremented = true
			if count - 1 == 0 then
				addon:DebugSummon("Group " .. groupKey .. " now available for rule " .. ruleID)
			end
		end
	end

	if decremented then
		addon:DebugSummon("Decremented unavailability counters for rule " .. ruleID)
	end
end

-- Find which group a mount belongs to in a pool
-- Works directly with GetDynamicSuperGroup to bypass weight-filtered pool structure
function MountSummon:FindMountGroupInPool(pool, mountID)
	-- Check all families in the pool
	for familyName, mounts in pairs(pool.mountsByFamily) do
		for _, mID in ipairs(mounts) do
			if mID == mountID then
				-- Found the family, check if it's in a supergroup
				local superGroup = addon:GetDynamicSuperGroup(familyName)
				if superGroup then
					-- Return the supergroup (don't check pool.superGroups which may be empty)
					return superGroup, "superGroup"
				else
					-- Standalone family
					return familyName, "family"
				end
			end
		end
	end

	return nil, nil
end

-- Select mount from pool ignoring weights (all groups equal chance)
-- Works directly with mountsByFamily to bypass weight-based pool structure filtering
-- bannedGroups parameter allows filtering out deterministically banned groups
function MountSummon:SelectFromPoolIgnoreWeights(pool, poolName, bannedGroups)
	addon:DebugSummon("Selecting from pool (ignore weights):", poolName)
	-- Build list of ALL families that have usable mounts, regardless of pool structure
	-- This bypasses the weight-based filtering that happens in ApplyFamilyAndSuperGroupWeights
	local allFamilies = {}
	for familyName, mounts in pairs(pool.mountsByFamily) do
		if mounts and #mounts > 0 then
			-- Check if family has any usable mounts
			local hasUsableMounts = false
			for _, mountID in ipairs(mounts) do
				local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
				if isUsable then
					hasUsableMounts = true
					break
				end
			end

			if hasUsableMounts then
				table.insert(allFamilies, familyName)
			end
		end
	end

	if #allFamilies == 0 then
		addon:DebugSummon("No families with usable mounts in pool")
		return nil, nil
	end

	-- Group families by supergroup
	local superGroupFamilies = {}
	local standaloneFamilies = {}
	for _, familyName in ipairs(allFamilies) do
		local superGroup = addon:GetDynamicSuperGroup(familyName)
		if superGroup then
			if not superGroupFamilies[superGroup] then
				superGroupFamilies[superGroup] = {}
			end

			table.insert(superGroupFamilies[superGroup], familyName)
		else
			table.insert(standaloneFamilies, familyName)
		end
	end

	-- Build list of selectable groups (supergroups + standalone families)
	-- Filter out banned groups if bannedGroups table provided
	local allGroups = {}
	for sgName, families in pairs(superGroupFamilies) do
		-- Check if this supergroup is banned
		if not bannedGroups or not bannedGroups[sgName] or bannedGroups[sgName] <= 0 then
			table.insert(allGroups, { name = sgName, type = "superGroup", families = families })
		else
			addon:DebugSummon("Supergroup " .. sgName .. " unavailable (" ..
				bannedGroups[sgName] .. " summons remaining)")
		end
	end

	for _, familyName in ipairs(standaloneFamilies) do
		-- Check if this family is banned
		if not bannedGroups or not bannedGroups[familyName] or bannedGroups[familyName] <= 0 then
			table.insert(allGroups, { name = familyName, type = "family" })
		else
			addon:DebugSummon("Family " .. familyName .. " unavailable (" ..
				bannedGroups[familyName] .. " summons remaining)")
		end
	end

	if #allGroups == 0 then
		addon:DebugSummon("No valid groups in pool (all banned or empty)")
		return nil, nil
	end

	-- Randomly select a group
	local selectedGroup = allGroups[math.random(#allGroups)]
	-- Select mount from the chosen group
	if selectedGroup.type == "superGroup" then
		-- Randomly select a family from the supergroup
		local familyName = selectedGroup.families[math.random(#selectedGroup.families)]
		return self:SelectMountFromFamilyIgnoreWeights(pool, familyName)
	else
		return self:SelectMountFromFamilyIgnoreWeights(pool, selectedGroup.name)
	end
end

-- Select mount from supergroup ignoring weights
function MountSummon:SelectMountFromSuperGroupIgnoreWeights(pool, sgName)
	local families = pool.superGroups[sgName]
	if not families or #families == 0 then
		return nil, nil
	end

	-- Collect all valid families
	local validFamilies = {}
	for _, familyName in ipairs(families) do
		if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
			table.insert(validFamilies, familyName)
		end
	end

	if #validFamilies == 0 then
		return nil, nil
	end

	-- Randomly select a family
	local familyName = validFamilies[math.random(#validFamilies)]
	return self:SelectMountFromFamilyIgnoreWeights(pool, familyName)
end

-- Select mount from family ignoring weights
function MountSummon:SelectMountFromFamilyIgnoreWeights(pool, familyName)
	local familyMounts = pool.mountsByFamily[familyName]
	if not familyMounts or #familyMounts == 0 then
		return nil, nil
	end

	-- Collect all usable mounts
	local usableMounts = {}
	for _, mountID in ipairs(familyMounts) do
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			table.insert(usableMounts, mountID)
		end
	end

	if #usableMounts == 0 then
		return nil, nil
	end

	-- Randomly select a mount
	local mountID = usableMounts[math.random(#usableMounts)]
	local mountName = C_MountJournal.GetMountInfoByID(mountID)
	return mountID, mountName
end

-- Select mount from specific mount list with individual mount banning (30min logic)
function MountSummon:SelectMountFromRuleSpecific(rule)
	local mountIDs = rule.mountIDs
	if not mountIDs or #mountIDs == 0 then
		addon:DebugSummon("Rule has no mount IDs")
		return nil, nil
	end

	-- Build list of valid usable mounts (collected, usable, not hidden by faction)
	local validMounts = {}
	for _, mountID in ipairs(mountIDs) do
		local name, spellID, icon, isActive, isUsable, sourceType, isFavorite,
		isFactionSpecific, faction, shouldHideOnChar, isCollected =
				C_MountJournal.GetMountInfoByID(mountID)
		if name and not shouldHideOnChar and isUsable then
			table.insert(validMounts, mountID)
		end
	end

	local validCount = #validMounts
	addon:DebugSummon("Rule has " .. validCount .. " valid mounts (out of " .. #mountIDs .. " total)")
	-- Only use deterministic banning if we have at least 5 valid mounts
	if validCount < 5 then
		addon:DebugSummon("Rule has < 5 valid mounts, using random selection")
		if validCount == 0 then
			return nil, nil
		end

		-- Random selection without banning
		local mountID = validMounts[math.random(validCount)]
		local mountName = C_MountJournal.GetMountInfoByID(mountID)
		return mountID, mountName
	end

	-- Initialize rule cache if needed
	if not self.rulesDeterministicCache[rule.id] then
		self.rulesDeterministicCache[rule.id] = {
			type = "specific",
			unavailableMounts = {},
			recentSummons = {},
			pendingSummon = nil,
		}
	end

	local ruleCache = self.rulesDeterministicCache[rule.id]
	-- Validate cache type matches current rule action (handle rule modifications)
	if ruleCache.type ~= "specific" then
		addon:DebugSummon("Rule " .. rule.id .. " cache type mismatch (was " .. (ruleCache.type or "nil") ..
			", expected specific), resetting cache")
		self.rulesDeterministicCache[rule.id] = {
			type = "specific",
			unavailableMounts = {},
			recentSummons = {},
			pendingSummon = nil,
		}
		ruleCache = self.rulesDeterministicCache[rule.id]
	end

	-- Clean expired ban timers
	local currentTime = GetTime()
	for mountID, bannedUntil in pairs(ruleCache.unavailableMounts) do
		if currentTime >= bannedUntil then
			ruleCache.unavailableMounts[mountID] = nil
			addon:DebugSummon("Mount " .. mountID .. " ban expired for rule " .. rule.id)
		end
	end

	-- Clean expired summon history (older than 31 minutes)
	for mountID, summons in pairs(ruleCache.recentSummons) do
		local cleaned = {}
		for _, timestamp in ipairs(summons) do
			if (currentTime - timestamp) < 1860 then -- 31 minutes
				table.insert(cleaned, timestamp)
			end
		end

		if #cleaned > 0 then
			ruleCache.recentSummons[mountID] = cleaned
		else
			ruleCache.recentSummons[mountID] = nil
		end
	end

	-- Check if >50% of valid mounts are banned
	local bannedCount = 0
	for _, mountID in ipairs(validMounts) do
		if ruleCache.unavailableMounts[mountID] then
			bannedCount = bannedCount + 1
		end
	end

	local bannedPercent = bannedCount / validCount
	addon:DebugSummon("Rule " .. rule.id .. " has " .. bannedCount .. "/" .. validCount ..
		" mounts banned (" .. math.floor(bannedPercent * 100) .. "%)")
	-- Reset if >50% are banned
	if bannedPercent > 0.5 then
		addon:DebugSummon("RESET: >50% of mounts banned for rule " .. rule.id .. ", clearing all bans and summon history")
		ruleCache.unavailableMounts = {}
		ruleCache.recentSummons = {}
		bannedCount = 0
	end

	-- Build list of available mounts (valid and not banned)
	local availableMounts = {}
	for _, mountID in ipairs(validMounts) do
		if not ruleCache.unavailableMounts[mountID] then
			table.insert(availableMounts, mountID)
		end
	end

	addon:DebugSummon("Rule " .. rule.id .. " has " .. #availableMounts .. " available mounts")
	-- Fallback if all mounts somehow banned (shouldn't happen after >50% reset)
	if #availableMounts == 0 then
		addon:DebugSummon("All mounts banned for rule " .. rule.id .. ", falling back to random from all valid")
		availableMounts = validMounts
	end

	-- Randomly select from available mounts
	local selectedMount = availableMounts[math.random(#availableMounts)]
	local mountName = C_MountJournal.GetMountInfoByID(selectedMount)
	-- Store pending summon
	ruleCache.pendingSummon = {
		ruleID = rule.id,
		mountID = selectedMount,
		timestamp = currentTime,
	}
	addon:DebugSummon("Selected mount " .. (mountName or selectedMount) .. " from rule " .. rule.id)
	return selectedMount, mountName
end

-- Process successful summon from a rule
function MountSummon:ProcessSuccessfulRuleSummon(ruleID)
	if not self:IsDeterministicModeEnabled() then
		return
	end

	local ruleCache = self.rulesDeterministicCache[ruleID]
	if not ruleCache or not ruleCache.pendingSummon then
		return
	end

	local pending = ruleCache.pendingSummon
	if ruleCache.type == "pool" then
		-- Pool-based rule: ban the group
		if not pending.groupKey or not pending.groupType then
			addon:DebugSummon("Invalid pending summon data for pool rule")
			ruleCache.pendingSummon = nil
			return
		end

		self:MarkRuleGroupUnavailable(ruleID, pending.groupKey, pending.groupType)
	elseif ruleCache.type == "specific" then
		-- Specific mount rule: record summon and potentially ban mount
		if not pending.mountID then
			addon:DebugSummon("Invalid pending summon data for specific rule")
			ruleCache.pendingSummon = nil
			return
		end

		self:RecordRuleMountSummon(ruleID, pending.mountID)
	end

	-- Clear pending summon
	ruleCache.pendingSummon = nil
	addon:DebugSummon("Processed successful rule summon for rule " .. ruleID)
end

-- Mark a group unavailable for a rule (pool-based)
function MountSummon:MarkRuleGroupUnavailable(ruleID, groupKey, groupType)
	local ruleCache = self.rulesDeterministicCache[ruleID]
	if not ruleCache then
		return
	end

	-- Get pool to calculate ban duration
	local poolName = ruleCache.poolName
	local pool = self.mountPools[poolName]
	if not pool then
		addon:DebugSummon("Cannot find pool for rule group ban")
		return
	end

	-- Calculate ban duration (simpler than normal - no weights)
	-- Use weight-ignoring count since rules should work regardless of weight settings
	local totalGroups = self:GetTotalGroupsInPoolIgnoreWeights(poolName)
	-- Safeguard: Don't use deterministic for very small pools
	if totalGroups < 5 then
		if totalGroups == 4 then
			ruleCache.unavailableGroups[groupKey] = 1
			addon:DebugSummon("Rule " .. ruleID .. " pool has 4 groups, ban duration: 1")
		else
			addon:DebugSummon("Rule " .. ruleID .. " pool has only " .. totalGroups ..
				" groups, skipping ban")
		end

		return
	end

	-- Ban duration = floor(totalGroups * 0.4), capped at 12
	local banDuration = math.floor(totalGroups * 0.4)
	banDuration = math.min(12, banDuration)
	banDuration = math.max(1, banDuration)
	ruleCache.unavailableGroups[groupKey] = banDuration
	addon:DebugSummon("Rule " .. ruleID .. " (" .. totalGroups .. " groups) - " ..
		groupType .. " '" .. groupKey .. "' banned for " .. banDuration .. " summons")
end

-- Clean up orphaned rule cache entries (for deleted rules)
function MountSummon:CleanupOrphanedRuleCaches()
	if not self.rulesDeterministicCache or not addon.MountRules then
		return
	end

	-- Get list of valid rule IDs
	local validRuleIDs = {}
	local data = addon.db and addon.db.profile and addon.db.profile.zoneSpecificMounts
	if data and data.rules then
		for _, rule in ipairs(data.rules) do
			validRuleIDs[rule.id] = true
		end
	end

	-- Remove cache entries for non-existent rules
	local removedCount = 0
	for ruleID, _ in pairs(self.rulesDeterministicCache) do
		if not validRuleIDs[ruleID] then
			self.rulesDeterministicCache[ruleID] = nil
			removedCount = removedCount + 1
		end
	end

	if removedCount > 0 then
		addon:DebugSummon("Cleaned up " .. removedCount .. " orphaned rule cache entries")
	end
end

-- Record a mount summon for a specific mount rule (30min logic)
function MountSummon:RecordRuleMountSummon(ruleID, mountID)
	local ruleCache = self.rulesDeterministicCache[ruleID]
	if not ruleCache then
		return
	end

	local currentTime = GetTime()
	-- Don't record if mount is already banned
	if ruleCache.unavailableMounts[mountID] and currentTime < ruleCache.unavailableMounts[mountID] then
		local mountName = C_MountJournal.GetMountInfoByID(mountID)
		addon:DebugSummon("Mount " .. (mountName or mountID) .. " summoned via fallback for rule " ..
			ruleID .. ", already banned")
		return
	end

	-- Initialize summon history for this mount if needed
	if not ruleCache.recentSummons[mountID] then
		ruleCache.recentSummons[mountID] = {}
	end

	-- Add current summon timestamp
	local summons = ruleCache.recentSummons[mountID]
	table.insert(summons, currentTime)
	-- Keep only last 10 summons
	if #summons > 10 then
		table.remove(summons, 1)
	end

	local mountName = C_MountJournal.GetMountInfoByID(mountID)
	-- For specific mount rules, we use a fixed threshold of 2 summons
	-- (same as weight 1-3 mounts in normal logic)
	local threshold = 2
	addon:DebugSummon("Tracked rule " .. ruleID .. " mount summon: " .. (mountName or mountID) ..
		" (" .. #summons .. "/" .. threshold .. " summons)")
	-- Check if we should ban this mount
	if #summons >= threshold then
		-- Ban for 30 minutes from now
		ruleCache.unavailableMounts[mountID] = currentTime + 1800 -- 30 minutes
		addon:DebugSummon("Mount " .. (mountName or mountID) .. " BANNED for 30 minutes in rule " ..
			ruleID .. " (triggered after " .. #summons .. " summons within 30min)")
	end
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
function MountSummon:SelectMountFromPoolFamily(pool, familyName, mountTypeFilter)
	-- Get mounts in this family for this pool
	local familyMounts = pool.mountsByFamily[familyName] or {}
	if #familyMounts == 0 then
		addon:DebugSummon("Family has no mounts in this pool:", familyName)
		return nil, nil
	end

	-- Check if individual bans should apply to this family
	local useIndividualBans = false
	local usableMountCount = 0
	if self:IsDeterministicModeEnabled() then
		-- Count usable mounts first (that match type filter if provided)
		for _, mountID in ipairs(familyMounts) do
			local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
			if isUsable then
				-- Check mount type if filter specified
				local matchesType = true
				if mountTypeFilter then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					if mountTypeFilter == "skyriding" and not traits.isSkyriding then
						matchesType = false
					elseif mountTypeFilter == "steadyflight" and not traits.isSteadyFly then
						matchesType = false
					end
				end

				if matchesType then
					usableMountCount = usableMountCount + 1
				end
			end
		end

		-- Only use individual bans if family has 3+ usable mounts (matching type filter)
		if usableMountCount >= 3 then
			useIndividualBans = true
			-- Check failsafes: >50% banned or all banned
			if usableMountCount > 4 then
				local bannedCount = self:GetBannedMountCountInFamily(pool, familyName, mountTypeFilter)
				local bannedPercent = bannedCount / usableMountCount
				if bannedPercent > 0.5 or bannedCount == usableMountCount then
					addon:DebugSummon("Family " .. familyName .. " has " .. bannedCount .. "/" ..
						usableMountCount .. " mounts banned (" .. math.floor(bannedPercent * 100) ..
						"%), clearing family bans")
					self:ClearFamilyIndividualBans(pool, familyName)
					useIndividualBans = false -- Don't filter after clearing
				end
			else
				-- Family has 3-4 mounts, only check "all banned" condition
				local bannedCount = self:GetBannedMountCountInFamily(pool, familyName, mountTypeFilter)
				if bannedCount == usableMountCount then
					addon:DebugSummon("All " .. usableMountCount .. " mounts in family " .. familyName ..
						" are banned, clearing family bans")
					self:ClearFamilyIndividualBans(pool, familyName)
					useIndividualBans = false
				end
			end
		else
			if usableMountCount > 0 then
				addon:DebugSummon("Family " .. familyName .. " has only " .. usableMountCount ..
					" usable mounts" .. (mountTypeFilter and (" matching " .. mountTypeFilter) or "") ..
					", skipping individual bans")
			end
		end
	end

	-- Build list of eligible mounts (only those with weight > 0 and matching type)
	local eligibleMounts = {}
	local totalWeight = 0
	local priority6Mounts = {}
	for _, mountID in ipairs(familyMounts) do
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		-- Double-check mount is still usable
		if isUsable then
			-- Check mount type if filter specified
			local matchesType = true
			if mountTypeFilter then
				local traits = self:GetEffectiveMountTypeTraits(mountID)
				if mountTypeFilter == "skyriding" and not traits.isSkyriding then
					matchesType = false
				elseif mountTypeFilter == "steadyflight" and not traits.isSteadyFly then
					matchesType = false
				end
			end

			if matchesType then
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
						-- Check if individually banned
						local isBanned = useIndividualBans and self:IsMountIndividuallyBanned(mountID)
						if mountWeight == 6 then
							-- Priority 6 mounts get special handling (never individually banned)
							table.insert(priority6Mounts, {
								id = mountID,
								name = name,
							})
						elseif not isBanned then
							-- Regular mount, not banned
							local probWeight = self:MapWeightToProbability(mountWeight)
							table.insert(eligibleMounts, {
								id = mountID,
								name = name,
								weight = probWeight,
							})
							totalWeight = totalWeight + probWeight
						else
							addon:DebugSummon("Skipping individually banned mount:", name)
						end
					else
						addon:DebugSummon("Mount " .. name .. " and family have weight 0, skipping")
					end
				else
					addon:DebugSummon("Skipping mount " .. name .. " with weight 0")
				end
			end
		end
	end

	-- Handle priority 6 mounts first - if any exist, ONLY consider them
	if #priority6Mounts > 0 then
		local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
		addon:DebugSummon("Selected priority 6 mount:", selectedMount.name)
		return selectedMount.id, selectedMount.name
	end

	-- If no eligible mounts (all banned), rebuild list ignoring individual bans
	if (#eligibleMounts == 0 or totalWeight == 0) and useIndividualBans then
		addon:DebugSummon("All non-priority6 mounts individually banned, ignoring bans for this selection")
		eligibleMounts = {}
		totalWeight = 0
		for _, mountID in ipairs(familyMounts) do
			local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
			if isUsable then
				-- Check type filter
				local matchesType = true
				if mountTypeFilter then
					local traits = self:GetEffectiveMountTypeTraits(mountID)
					if mountTypeFilter == "skyriding" and not traits.isSkyriding then
						matchesType = false
					elseif mountTypeFilter == "steadyflight" and not traits.isSteadyFly then
						matchesType = false
					end
				end

				if matchesType then
					local mountKey = "mount_" .. mountID
					local mountWeight = addon:GetGroupWeight(mountKey)
					if mountWeight ~= 0 then
						if mountWeight == 0 then
							mountWeight = addon:GetGroupWeight(familyName)
						end

						if mountWeight > 0 and mountWeight ~= 6 then
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

	-- If no eligible mounts, return nil
	if #eligibleMounts == 0 or totalWeight == 0 then
		addon:DebugSummon("No eligible mounts found in family" ..
			(mountTypeFilter and (" matching " .. mountTypeFilter) or ""))
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

-- Select a mount from a specific family (for zone-specific family rules)
-- This selects from all mounts in the family, regardless of pool
function MountSummon:SelectMountFromFamily(familyName)
	-- Get all mounts in this family from processed data
	if not addon.processedData or not addon.processedData.families or not addon.processedData.families[familyName] then
		addon:DebugSummon("Family not found:", familyName)
		return nil, nil
	end

	local familyMounts = addon.processedData.families[familyName].mounts or {}
	if #familyMounts == 0 then
		addon:DebugSummon("Family has no mounts:", familyName)
		return nil, nil
	end

	-- Build list of eligible mounts (only usable ones with weight > 0)
	local eligibleMounts = {}
	local totalWeight = 0
	local priority6Mounts = {}
	for _, mountID in ipairs(familyMounts) do
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			-- Get mount weight
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
				end
			end
		end
	end

	-- Handle priority 6 mounts first
	if #priority6Mounts > 0 then
		local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
		addon:DebugSummon("Selected priority 6 mount from family:", selectedMount.name)
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
			addon:DebugSummon("Selected mount from family:", mount.name)
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
