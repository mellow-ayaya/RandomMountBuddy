-- MountSummon.lua - Updated with Weight 6 (Always) Priority Logic
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountSummon.lua START (Updated Weight 6 Logic).")
-- ============================================================================
-- MOUNT SUMMON CLASS
-- ============================================================================
local MountSummon = {}
addon.MountSummon = MountSummon
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountSummon:Initialize()
	print("RMB_SUMMON: Initializing mount summoning system...")
	-- Flight style tracking
	self.isInSkyridingMode = false
	-- Initialize mount pools
	self.mountPools = {
		flying = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		ground = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		underwater = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
	}
	-- Zone-specific configuration for G-99 abilities using location IDs
	self.G99_ZONES = {
		[2346] = 1215279, -- Undermine - Original G-99 zone
		[2406] = 1218373, -- Nerub-ar Palace - Raid zone
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
	print("RMB_SUMMON: Initialized successfully")
end

function MountSummon:OnMountCollectionChanged()
	print("RMB_SUMMON: Mount collection changed, rebuilding pools...")
	-- Rebuild pools if data is ready
	if addon.RMB_DataReadyForUI and addon.processedData then
		self:BuildMountPools()
		print("RMB_SUMMON: Mount pools rebuilt successfully")
	else
		print("RMB_SUMMON: Skipping pool rebuild - data not ready")
	end
end

-- ============================================================================
-- MOUNT TYPE & CAPABILITY DETECTION
-- ============================================================================
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

-- Check if a mount can fly (either steady flying or skyriding)
function MountSummon:CanMountFly(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isSteadyFly or traits.isSkyriding
end

-- Check if a mount can do dragonriding/skyriding
function MountSummon:CanMountSkyriding(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isSkyriding
end

-- Check if a mount can swim underwater
function MountSummon:CanMountSwim(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isAquatic
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
		print("RMB_DEBUG: Flight style check - Player is in SKYRIDING mode")
		return true
	elseif steadySpellInfo then
		-- If "Switch to Dragonriding" spell is known, player is in steady flight mode
		self.isInSkyridingMode = false
		print("RMB_DEBUG: Flight style check - Player is in STEADY FLIGHT mode")
		return false
	else
		-- If neither spell is known, default to steady flight
		self.isInSkyridingMode = false
		print("RMB_DEBUG: Flight style check - Could not determine style, defaulting to STEADY FLIGHT")
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
						print("RMB_DEBUG: Switched TO skyriding mode")
					elseif spellID == 460002 then -- Switch TO steady flight
						self.isInSkyridingMode = false
						print("RMB_DEBUG: Switched TO steady flight mode")
					else
						-- Check if this is a mount summon spell (NEW)
						local isMountSpell, mountID = self:IsMountSummonSpell(spellID)
						if isMountSpell and mountID then
							print("RMB_DETERMINISTIC: Detected successful mount summon - Spell: " .. spellID .. ", Mount: " .. mountID)
							-- Find which pool this summon was from by checking pending summons
							local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
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
	print("RMB_DEBUG: Registered for flight style change and mount summon events")
end

-- ============================================================================
-- CONTEXT DETECTION
-- ============================================================================
-- Determine the current player context for contextual summoning
function MountSummon:GetCurrentContext()
	local context = {
		canFly = false,
		canDragonride = false,
		isUnderwater = false,
		inZone = nil,
		isInSkyridingMode = self.isInSkyridingMode,
	}
	-- Check if player can fly in current zone
	context.canFly = IsFlyableArea()
	-- Check if Dragonriding is enabled in current zone
	if IsAdvancedFlyableArea then
		context.canDragonride = IsAdvancedFlyableArea()
	else
		-- Fallback for older WoW versions
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID then
			local dragonIslesZones = {
				[2022] = true, -- Waking Shores
				[2023] = true, -- Ohn'ahran Plains
				[2024] = true, -- Azure Span
				[2025] = true, -- Thaldraszus
				[2151] = true, -- Forbidden Reach
				[2133] = true, -- Zaralek Cavern
				[2200] = true, -- Emerald Dream
			}
			context.canDragonride = dragonIslesZones[mapID] or false
		end
	end

	-- Get current zone
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		context.inZone = mapID
	end

	-- Check if player is underwater
	context.isUnderwater = IsSubmerged()
	print("RMB_CONTEXT: Current context:",
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
	print("RMB_DETERMINISTIC: Initializing deterministic summoning system...")
	-- Ensure cache structure exists
	if not addon.db or not addon.db.profile then
		print("RMB_DETERMINISTIC: No database available, skipping initialization")
		return
	end

	if not addon.db.profile.deterministicCache then
		addon.db.profile.deterministicCache = {
			flying = { unavailableGroups = {}, pendingSummon = nil },
			ground = { unavailableGroups = {}, pendingSummon = nil },
			underwater = { unavailableGroups = {}, pendingSummon = nil },
		}
	end

	print("RMB_DETERMINISTIC: System initialized")
end

-- Check if deterministic mode is enabled
function MountSummon:IsDeterministicModeEnabled()
	return addon:GetSetting("useDeterministicSummoning") == true
end

-- Get total available groups count for a pool (before filtering)
function MountSummon:GetTotalGroupsInPool(poolName)
	local pool = self.mountPools[poolName]
	if not pool then return 0 end

	local totalGroups = 0
	-- Count supergroups
	for _ in pairs(pool.superGroups) do
		totalGroups = totalGroups + 1
	end

	-- Count standalone families
	for _ in pairs(pool.families) do
		totalGroups = totalGroups + 1
	end

	return totalGroups
end

-- Calculate unavailability duration for a group
function MountSummon:CalculateUnavailabilityDuration(poolName, groupKey, groupType)
	local totalGroups = self:GetTotalGroupsInPool(poolName)
	local baseDuration = math.floor(totalGroups * 0.7) - 4
	baseDuration = math.max(2, math.min(20, baseDuration)) -- Cap at 20, min 2
	-- Don't apply to small pools (same logic as before)
	if baseDuration <= 0 then
		print("RMB_DETERMINISTIC: Pool " .. poolName .. " has " .. totalGroups ..
			" groups, too small for deterministic summoning")
		return 0
	end

	-- Get the group's weight to adjust ban duration
	local groupWeight = addon:GetGroupWeight(groupKey)
	-- Linear scaling: reduce ban by 20% per weight level above 1
	local reduction = (groupWeight - 1) * 0.2
	local adjustedDuration = math.floor(baseDuration * (1 - reduction))
	-- Always at least 1 summon ban
	adjustedDuration = math.max(1, adjustedDuration)
	print("RMB_DETERMINISTIC: Pool " .. poolName .. " (" .. totalGroups .. " groups) - " ..
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
			print("RMB_DETERMINISTIC: Filtered out supergroup " .. sgName ..
				" (unavailable for " .. unavailableCount .. " more summons)")
		end
	end

	-- Filter standalone families
	for familyName, _ in pairs(pool.families) do
		local unavailableCount = cache.unavailableGroups[familyName]
		if not unavailableCount or unavailableCount <= 0 then
			filteredPool.families[familyName] = true
		else
			print("RMB_DETERMINISTIC: Filtered out family " .. familyName ..
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
		print("RMB_DETERMINISTIC: Duration is 0, not marking group unavailable")
		return
	end

	local deterministicCache = addon.db and addon.db.profile and addon.db.profile.deterministicCache
	local cache = deterministicCache and deterministicCache[poolName]
	if not cache then
		print("RMB_DETERMINISTIC: No cache for pool " .. poolName)
		return
	end

	if not cache.unavailableGroups then
		cache.unavailableGroups = {}
	end

	cache.unavailableGroups[groupKey] = duration
	print("RMB_DETERMINISTIC: Marked " ..
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
		print("RMB_DETERMINISTIC: " .. groupKey .. " is now available again in " .. poolName .. " pool")
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
	print("RMB_DETERMINISTIC: Stored pending summon - Group: " .. groupKey .. ", Mount: " .. mountID)
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
		print("RMB_DETERMINISTIC: Invalid pending summon data")
		cache.pendingSummon = nil
		return
	end

	-- Mark the group unavailable
	self:MarkGroupUnavailable(poolName, pending.groupKey, pending.groupType)
	-- Decrement all counters
	self:DecrementUnavailabilityCounters(poolName)
	-- Clear pending summon
	cache.pendingSummon = nil
	print("RMB_DETERMINISTIC: Processed successful summon for " .. pending.groupKey)
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
	print("RMB_SUMMON: Building context-based mount pools")
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
				local canFly = self:CanMountFly(mountID)
				local canSwim = self:CanMountSwim(mountID)
				local traits = self:GetMountTypeTraits(mountID)
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
					-- FIXED: Only add to ground pool if it CAN'T fly (ground-only mounts)
					self:AddMountToPool("ground", mountID, name, familyName, superGroup, mountWeight)
				end
			else
				print("RMB_SUMMON_DEBUG: Mount " .. name .. " explicitly excluded (weight 0)")
			end
		end
	end

	print("RMB_SUMMON: Processed " .. mountsProcessed .. " mounts into context pools")
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
	--print("RMB_SUMMON_DEBUG: Added " .. mountName .. " to " .. poolName .. " pool for family " .. familyName)
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
				print("RMB_SUMMON_DEBUG: Family " .. familyName .. " in " .. poolName ..
					" pool has no usable mounts and weight 0, skipping")
			end
		end

		-- Add standalone families to the pool
		for familyName in pairs(familiesWithUsableMounts) do
			local superGroup = addon:GetDynamicSuperGroup(familyName)
			if not superGroup then
				pool.families[familyName] = true
				--print("RMB_SUMMON_DEBUG: Added standalone family " .. familyName .. " to " .. poolName .. " pool")
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
							--print("RMB_SUMMON_DEBUG: Added family " .. familyName ..
							--	" to supergroup " .. superGroup .. " in " .. poolName .. " pool")
						else
							print("RMB_SUMMON_DEBUG: Family " .. familyName ..
								" in supergroup " .. superGroup ..
								" has weight 0, not adding to " .. poolName .. " pool")
						end
					end
				else
					print("RMB_SUMMON_DEBUG: Supergroup " .. superGroup ..
						" has weight 0, not adding to " .. poolName .. " pool")
				end
			end
		end
	end
end

-- Validate mount pools to remove empty groups
function MountSummon:ValidateMountPools()
	print("RMB_SUMMON: Validating mount pools to remove empty groups")
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
			print("RMB_SUMMON: Removing invalid supergroup from " .. poolName .. " pool: " .. sgName)
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
			print("RMB_SUMMON: Removing invalid family from " .. poolName .. " pool: " .. familyName)
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

		print("RMB_SUMMON: " .. poolName .. " pool has " .. superGroupCount ..
			" supergroups with " .. familiesInSuperGroups .. " families, " ..
			standaloneFamilies .. " standalone families, and " ..
			totalMounts .. " total mounts")
	end
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
		print("RMB_SUMMON_ERROR: No mount ID provided.")
		return false
	end

	local name = C_MountJournal.GetMountInfoByID(mountID)
	print("RMB_SUMMON: Summoning mount:", name, "ID:", mountID)
	-- Use Blizzard's function to summon the mount
	C_MountJournal.SummonByID(mountID)
	return true
end

-- Main function to pick and summon a random mount
function MountSummon:SummonRandomMount(useContext)
	print("RMB_SUMMON: SummonRandomMount called with useContext:", useContext)
	-- Determine which pool to use based on context
	local poolName = "unified" -- Default to unified pool
	local mountTypeFilter = nil -- No specific type filter by default
	if useContext and addon:GetSetting("contextualSummoning") then
		local context = self:GetCurrentContext()
		if context.isUnderwater then
			-- Underwater context
			poolName = "underwater"
			print("RMB_SUMMON: Using underwater pool based on context")
		elseif context.canFly then
			-- Flying context - determine which type
			poolName = "flying"
			if context.isInSkyridingMode and context.canDragonride then
				-- Player is in skyriding mode and can dragonride in this zone
				mountTypeFilter = "skyriding"
				print("RMB_SUMMON: Using flying pool with skyriding filter based on context")
			else
				-- Player is in steady flight mode or can't dragonride here
				mountTypeFilter = "steadyflight"
				print("RMB_SUMMON: Using flying pool with steady flight filter based on context")
			end
		else
			-- Ground-only context
			poolName = "ground"
			print("RMB_SUMMON: Using ground pool based on context")
		end
	else
		print("RMB_SUMMON: Using unified pool (contextual summoning disabled)")
	end

	-- Select mount from the appropriate pool with proper deterministic integration
	local mountID, mountName = self:SelectMountFromPoolWithFilter(poolName, mountTypeFilter)
	if mountID then
		return self:SummonMount(mountID)
	else
		print("RMB_SUMMON: No eligible mounts found in " .. poolName .. " pool" ..
			(mountTypeFilter and (" with " .. mountTypeFilter .. " filter") or ""))
		return false
	end
end

-- New method that integrates deterministic filtering with mount type filtering:
function MountSummon:SelectMountFromPoolWithFilter(poolName, mountTypeFilter)
	local originalPool = self.mountPools[poolName]
	if not originalPool then
		print("RMB_SUMMON_ERROR: Invalid pool name:", poolName)
		return nil, nil
	end

	-- Apply deterministic filtering first
	local pool = self:FilterPoolForDeterministic(originalPool, poolName)
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
		print("RMB_DETERMINISTIC: No available groups after filtering, falling back to random mode")
		pool = originalPool -- Fall back to original pool
	end

	-- If no mount type filter, use normal selection
	if not mountTypeFilter then
		return self:SelectMountFromFilteredPool(pool, poolName)
	end

	-- Apply mount type filtering for contextual summoning
	return self:SelectSpecificMountTypeFromFilteredPool(pool, poolName, mountTypeFilter)
end

-- Updated method that works with already-filtered pools:
function MountSummon:SelectMountFromFilteredPool(pool, poolName)
	-- Step 1: Select group (supergroup or standalone family)
	local groupName, groupType = self:SelectGroupFromPool(pool)
	if not groupName then
		print("RMB_SUMMON: No groups available in", poolName, "pool")
		return nil, nil
	end

	-- Step 2: Select family
	local familyName
	if groupType == "superGroup" then
		familyName = self:SelectFamilyFromPoolSuperGroup(pool, groupName)
		if not familyName then
			print("RMB_SUMMON: No families available in supergroup", groupName)
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

-- Updated SelectSpecificMountTypeFromFilteredPool that works with deterministic filtering:
function MountSummon:SelectSpecificMountTypeFromFilteredPool(pool, poolName, mountType)
	print("RMB_SUMMON: SelectSpecificMountTypeFromFilteredPool for", mountType, "in", poolName, "pool")
	-- Build list of eligible groups with proper deterministic filtering already applied
	local eligibleGroups = {}
	local priority6Groups = {}
	-- Add supergroups from filtered pool
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

	-- Add standalone families from filtered pool
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
			-- Get all families in this supergroup from the filtered pool
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
						local traits = self:GetMountTypeTraits(mountID)
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

									print("RMB_SUMMON: Added eligible " .. mountType .. " mount from "
										.. family.name .. ":", name, "Weight:", mountWeight)
								end
							end
						end
					end
				end

				-- If eligible mounts found in this family, make a selection
				if #priority6Mounts > 0 then
					-- Priority 6 mounts take precedence
					local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
					print("RMB_SUMMON: Selected priority 6 " .. mountType .. " mount:", selectedMount.name,
						"from family:", family.name,
						group.type == "superGroup" and ("in supergroup: " .. group.name) or "")
					-- Store pending summon for deterministic tracking
					self:StorePendingSummon(poolName, group.name, group.type, selectedMount.id)
					return selectedMount.id, selectedMount.name
				elseif #eligibleMounts > 0 and totalWeight > 0 then
					-- Weighted random selection from regular mounts
					local roll = math.random(1, totalWeight)
					local currentSum = 0
					for _, mount in ipairs(eligibleMounts) do
						currentSum = currentSum + mount.weight
						if roll <= currentSum then
							print("RMB_SUMMON: Selected " .. mountType .. " mount:", mount.name,
								"from family:", family.name,
								group.type == "superGroup" and ("in supergroup: " .. group.name) or "")
							-- Store pending summon for deterministic tracking
							self:StorePendingSummon(poolName, group.name, group.type, mount.id)
							return mount.id, mount.name
						end
					end

					-- Fallback
					local fallbackMount = eligibleMounts[1]
					self:StorePendingSummon(poolName, group.name, group.type, fallbackMount.id)
					return fallbackMount.id, fallbackMount.name
				end
			end
		end
	end

	-- If we got here, no eligible mounts were found
	print("RMB_SUMMON: No eligible " .. mountType .. " mounts found in any group")
	return nil, nil
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
		print("RMB_SUMMON: Not hooking random favorite button (setting disabled).")
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
		print("RMB_SUMMON: Successfully hooked random favorite mount button.")
	else
		print("RMB_SUMMON_ERROR: Could not find random favorite mount button to hook.")
	end
end

-- ============================================================================
-- PUBLIC INTERFACE METHODS
-- ============================================================================
-- Called when data is ready
function MountSummon:OnDataReady()
	print("RMB_SUMMON: Data ready, building mount pools")
	self:BuildMountPools()
end

-- Called when settings change
function MountSummon:OnSettingChanged(key, value)
	-- Refresh mount pools if needed
	if key == "contextualSummoning" or
			key:find("treat") and key:find("AsDistinct") then
		print("RMB_SUMMON: Setting changed, refreshing mount pools")
		self:BuildMountPools()
	end
end

-- Refresh mount pools when needed
function MountSummon:RefreshMountPools()
	print("RMB_SUMMON: Refreshing mount pools")
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
		print("RMB_SUMMON: ERROR - MountSummon not found!")
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

	print("RMB_SUMMON: Integration complete")
end

print("RMB_DEBUG: MountSummon.lua END (Updated Weight 6 Logic).")
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

					print("RMB_SUMMON: Added eligible supergroup:", sgName, "Weight:", groupWeight)
				end
			else
				print("RMB_SUMMON: Skipping supergroup with no valid families:", sgName)
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

				print("RMB_SUMMON: Added eligible standalone family:", familyName, "Weight:", groupWeight)
			end
		else
			print("RMB_SUMMON: Skipping family with no valid mounts:", familyName)
		end
	end

	-- UPDATED: Handle priority 6 groups first - if any exist, ONLY consider them
	if #priority6Groups > 0 then
		local selectedGroup = priority6Groups[math.random(#priority6Groups)]
		print("RMB_SUMMON: Selected priority 6 group:", selectedGroup.name, selectedGroup.type)
		return selectedGroup.name, selectedGroup.type
	end

	-- Handle regular groups only if no priority 6 groups exist
	if #eligibleGroups == 0 or totalWeight == 0 then
		print("RMB_SUMMON: No eligible groups found")
		return nil, nil
	end

	-- Weighted selection
	local roll = math.random(1, totalWeight)
	print("RMB_SUMMON: Group selection roll:", roll, "out of", totalWeight)
	local currentSum = 0
	for _, group in ipairs(eligibleGroups) do
		currentSum = currentSum + group.weight
		if roll <= currentSum then
			print("RMB_SUMMON: Selected group:", group.name, group.type)
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
		print("RMB_SUMMON: Supergroup has no families in this pool:", superGroupName)
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

				print("RMB_SUMMON: Added eligible family from supergroup:", familyName, "Weight:", familyWeight)
			end
		end
	end

	-- UPDATED: Handle priority 6 families first - if any exist, ONLY consider them
	if #priority6Families > 0 then
		local selectedFamily = priority6Families[math.random(#priority6Families)]
		print("RMB_SUMMON: Selected priority 6 family:", selectedFamily.name)
		return selectedFamily.name
	end

	-- If no eligible families, return nil
	if #eligibleFamilies == 0 or totalWeight == 0 then
		print("RMB_SUMMON: No eligible families found in supergroup")
		return nil
	end

	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	print("RMB_SUMMON: Family selection roll:", roll, "out of", totalWeight)
	local currentSum = 0
	for _, family in ipairs(eligibleFamilies) do
		currentSum = currentSum + family.weight
		if roll <= currentSum then
			print("RMB_SUMMON: Selected family:", family.name)
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
		print("RMB_SUMMON: Family has no mounts in this pool:", familyName)
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

					print("RMB_SUMMON: Added eligible mount from family:", name, "Weight:", mountWeight)
				else
					print("RMB_SUMMON_DEBUG: Mount " .. name .. " and family have weight 0, skipping")
				end
			else
				print("RMB_SUMMON_DEBUG: Skipping mount " .. name .. " with weight 0")
			end
		end
	end

	-- UPDATED: Handle priority 6 mounts first - if any exist, ONLY consider them
	if #priority6Mounts > 0 then
		local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
		print("RMB_SUMMON: Selected priority 6 mount:", selectedMount.name)
		return selectedMount.id, selectedMount.name
	end

	-- If no eligible mounts, return nil
	if #eligibleMounts == 0 or totalWeight == 0 then
		print("RMB_SUMMON: No eligible mounts found in family")
		return nil, nil
	end

	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	print("RMB_SUMMON: Mount selection roll:", roll, "out of", totalWeight)
	local currentSum = 0
	for _, mount in ipairs(eligibleMounts) do
		currentSum = currentSum + mount.weight
		if roll <= currentSum then
			print("RMB_SUMMON: Selected mount:", mount.name)
			return mount.id, mount.name
		end
	end

	-- Fallback
	return eligibleMounts[1].id, eligibleMounts[1].name
end

-- Updated SelectSpecificMountTypeFromPool to also handle Weight 6 priority
function MountSummon:SelectSpecificMountTypeFromPool(poolName, mountType)
	local pool = self.mountPools[poolName]
	if not pool then
		print("RMB_SUMMON_ERROR: Invalid pool name:", poolName)
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
						local traits = self:GetMountTypeTraits(mountID)
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

									print("RMB_SUMMON: Added eligible " .. mountType .. " mount from "
										.. family.name .. ":", name, "Weight:", mountWeight)
								end
							end
						end
					end
				end

				-- If eligible mounts found in this family, make a selection
				if #priority6Mounts > 0 then
					-- Priority 6 mounts take precedence
					local selectedMount = priority6Mounts[math.random(#priority6Mounts)]
					print("RMB_SUMMON: Selected priority 6 " .. mountType .. " mount:", selectedMount.name,
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
							print("RMB_SUMMON: Selected " .. mountType .. " mount:", mount.name,
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
	print("RMB_SUMMON: No eligible " .. mountType .. " mounts found in any group")
	return nil, nil
end
