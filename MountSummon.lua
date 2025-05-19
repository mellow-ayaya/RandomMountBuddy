-- MountSummon.lua
local addonName, addonTable = ...
local addon = RandomMountBuddy -- Reference to the addon from global
print("RMB_DEBUG: MountSummon.lua START.")
local isInSkyridingMode = false
-- Function to check which flight style the player is using
function addon:CheckCurrentFlightStyle()
	-- Check for "Switch to Steady Flight" (460002) spell - if present, player is in skyriding mode
	-- Check for "Switch to Dragonriding" (460003) spell - if present, player is in steady flight mode
	local steadySpellID = 460003   -- Switch TO skyriding (player is currently in steady flight)
	local skyridingSpellID = 460002 -- Switch TO steady flight (player is currently in skyriding)
	-- Use C_Spell.GetSpellInfo to check if the player knows these spells
	local skyridingSpellInfo = C_Spell.GetSpellInfo(skyridingSpellID)
	local steadySpellInfo = C_Spell.GetSpellInfo(steadySpellID)
	if skyridingSpellInfo then
		-- If "Switch to Steady Flight" spell is known, player is in skyriding mode
		isInSkyridingMode = true
		print("RMB_DEBUG: Flight style check - Player is in SKYRIDING mode")
		return true
	elseif steadySpellInfo then
		-- If "Switch to Dragonriding" spell is known, player is in steady flight mode
		isInSkyridingMode = false
		print("RMB_DEBUG: Flight style check - Player is in STEADY FLIGHT mode")
		return false
	else
		-- If neither spell is known, default to steady flight
		isInSkyridingMode = false
		print("RMB_DEBUG: Flight style check - Could not determine style, defaulting to STEADY FLIGHT")
		return false
	end
end

-- Register for events to track flight style changes
function addon:RegisterFlightStyleEvents()
	if not self.eventFrame then
		self.eventFrame = CreateFrame("Frame")
		self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
			if event == "UNIT_SPELLCAST_SUCCEEDED" then
				local unit, castGUID, spellID = ...
				if unit == "player" then
					if spellID == 460003 then -- Switch TO skyriding
						isInSkyridingMode = true
						print("RMB_DEBUG: Switched TO skyriding mode")
					elseif spellID == 460002 then -- Switch TO steady flight
						isInSkyridingMode = false
						print("RMB_DEBUG: Switched TO steady flight mode")
					end
				end
			end
		end)
	end

	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	print("RMB_DEBUG: Registered for flight style change events")
end

-- =============================
-- MOUNT TYPE & CAPABILITY DETECTION
-- =============================
-- Get mount type traits for a given mount ID
function addon:GetMountTypeTraits(mountID)
	-- Get the mount's type ID
	local typeID = self.mountIDtoTypeID[mountID]
	if not typeID then
		-- If mount ID not in our mapping, get it from API
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		typeID = mountType
	end

	-- Get traits for this type
	local traits = self.mountTypeTraits[typeID]
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
function addon:CanMountFly(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isSteadyFly or traits.isSkyriding
end

-- Check if a mount can do dragonriding/skyriding
function addon:CanMountSkyriding(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isSkyriding
end

-- Check if a mount can swim underwater
function addon:CanMountSwim(mountID)
	local traits = self:GetMountTypeTraits(mountID)
	return traits.isAquatic
end

-- =============================
-- CONTEXT DETECTION
-- =============================
-- Determine the current player context for contextual summoning
function addon:GetCurrentContext()
	local context = {
		canFly = false,
		canDragonride = false,
		isUnderwater = false,
		inZone = nil,
		isInSkyridingMode = false,
	}
	-- Check if player can fly in current zone
	context.canFly = IsFlyableArea()
	-- Check if Dragonriding is available (zone check for backward compatibility)
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

	-- Check current flight style (regardless of zone)
	context.isInSkyridingMode = isInSkyridingMode or self:CheckCurrentFlightStyle()
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

-- Add this after BuildMountPools
function addon:ValidateMountPools()
	print("RMB_POOLS: Validating mount pools to remove empty groups")
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
			print("RMB_POOLS: Removing invalid supergroup from " .. poolName .. " pool: " .. sgName)
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
			print("RMB_POOLS: Removing invalid family from " .. poolName .. " pool: " .. familyName)
			pool.families[familyName] = nil
		end
	end

	-- Log updated pool stats
	self:LogPoolStats()
end

-- =============================
-- MOUNT POOL MANAGEMENT
-- =============================
-- Build mount pools for different contexts
function addon:BuildMountPools()
	print("RMB_POOLS: Building context-based mount pools")
	-- Reset the pools
	self.mountPools = {
		flying = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		ground = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
		underwater = { superGroups = {}, families = {}, mountsByFamily = {}, mountWeights = {} },
	}
	-- Process all collected mounts
	local mountsProcessed = 0
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = self:GetDynamicSuperGroup(familyName)
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			mountsProcessed = mountsProcessed + 1
			-- Determine effective weight using priority:
			-- 1. Mount-specific weight (most specific, always wins)
			-- 2. Family weight (medium specific)
			-- 3. Supergroup weight (least specific)
			local mountKey = "mount_" .. mountID
			local mountWeight = self:GetGroupWeight(mountKey)
			-- Mount weight of 0 means explicitly excluded, no matter what family/supergroup says
			if mountWeight ~= 0 then
				-- Get mount capabilities
				local canFly = self:CanMountFly(mountID)
				local canSwim = self:CanMountSwim(mountID)
				local traits = self:GetMountTypeTraits(mountID)
				-- Add to flying pool if it can fly
				if canFly then
					self:AddMountToPool("flying", mountID, name, familyName, superGroup, mountWeight)
				end

				-- Add to ground pool if it's a ground mount
				if traits.isGround then
					self:AddMountToPool("ground", mountID, name, familyName, superGroup, mountWeight)
				end

				-- Add to underwater pool if it can swim
				if canSwim then
					self:AddMountToPool("underwater", mountID, name, familyName, superGroup, mountWeight)
				end
			else
				print("RMB_POOLS_DEBUG: Mount " .. name .. " explicitly excluded (weight 0)")
			end
		end
	end

	print("RMB_POOLS: Processed " .. mountsProcessed .. " mounts into context pools")
	-- Now handle family and supergroup-level weights
	self:ApplyFamilyAndSuperGroupWeights()
	-- Log pool sizes
	self:LogPoolStats()
	-- Validate pools
	self:ValidateMountPools()
end

-- Helper to add a mount to a specific pool
-- Modified AddMountToPool function
function addon:AddMountToPool(poolName, mountID, mountName, familyName, superGroup, mountWeight)
	local pool = self.mountPools[poolName]
	-- Store the mount's weight
	pool.mountWeights[mountID] = mountWeight
	-- Add to mountsByFamily
	if not pool.mountsByFamily[familyName] then
		pool.mountsByFamily[familyName] = {}
	end

	table.insert(pool.mountsByFamily[familyName], mountID)
	print("RMB_POOLS_DEBUG: Added " .. mountName .. " to " .. poolName .. " pool for family " .. familyName)
	-- Note: We'll handle families and supergroups in ApplyFamilyAndSuperGroupWeights
	-- to properly handle weight inheritance
end

-- Apply family and supergroup weights after all mounts are processed
function addon:ApplyFamilyAndSuperGroupWeights()
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
			local familyWeight = self:GetGroupWeight(familyName)
			if familyHasUsableMounts or familyWeight > 0 then
				familiesWithUsableMounts[familyName] = true
			else
				print("RMB_POOLS_DEBUG: Family " .. familyName .. " in " .. poolName ..
					" pool has no usable mounts and weight 0, skipping")
			end
		end

		-- Add standalone families to the pool
		for familyName in pairs(familiesWithUsableMounts) do
			local superGroup = self:GetDynamicSuperGroup(familyName)
			if not superGroup then
				pool.families[familyName] = true
				print("RMB_POOLS_DEBUG: Added standalone family " .. familyName .. " to " .. poolName .. " pool")
			end
		end

		-- Add supergroups and their families
		for familyName in pairs(familiesWithUsableMounts) do
			local superGroup = self:GetDynamicSuperGroup(familyName)
			if superGroup then
				local superGroupWeight = self:GetGroupWeight(superGroup)
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
						local familyWeight = self:GetGroupWeight(familyName)
						if familyWeight > 0 then
							table.insert(pool.superGroups[superGroup], familyName)
							print("RMB_POOLS_DEBUG: Added family " .. familyName ..
								" to supergroup " .. superGroup .. " in " .. poolName .. " pool")
						else
							print("RMB_POOLS_DEBUG: Family " .. familyName ..
								" in supergroup " .. superGroup ..
								" has weight 0, not adding to " .. poolName .. " pool")
						end
					end
				else
					print("RMB_POOLS_DEBUG: Supergroup " .. superGroup ..
						" has weight 0, not adding to " .. poolName .. " pool")
				end
			end
		end
	end
end

-- Log statistics about the mount pools
function addon:LogPoolStats()
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

		print("RMB_POOLS: " .. poolName .. " pool has " .. superGroupCount ..
			" supergroups with " .. familiesInSuperGroups .. " families, " ..
			standaloneFamilies .. " standalone families, and " ..
			totalMounts .. " total mounts")
	end
end

-- Refresh mount pools when settings change
function addon:RefreshMountPools()
	print("RMB_POOLS: Refreshing mount pools")
	-- Rebuild dynamic grouping if needed
	self:RebuildMountGrouping()
	-- Rebuild the mount pools
	self:BuildMountPools()
end

-- Map user-facing weights (0-6) to actual probability weights
function addon:MapWeightToProbability(userWeight)
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

-- =============================
-- POOL-BASED MOUNT SELECTION
-- =============================
-- Select a mount from a specific pool
function addon:SelectMountFromPool(poolName)
	local pool = self.mountPools[poolName]
	if not pool then
		print("RMB_SUMMON_ERROR: Invalid pool name:", poolName)
		return nil, nil
	end

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
	return self:SelectMountFromPoolFamily(pool, familyName)
end

-- Select a group from a pool
-- Select a group from a pool
function addon:SelectGroupFromPool(pool)
	-- Build list of eligible groups
	local eligibleGroups = {}
	local totalWeight = 0
	local priority6Groups = {}
	local hasPriority6Groups = false
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
				local groupWeight = self:GetGroupWeight(sgName)
				if groupWeight > 0 then
					if groupWeight == 6 then
						table.insert(priority6Groups, {
							name = sgName,
							type = "superGroup",
							weight = 100,
						})
						hasPriority6Groups = true
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
			local groupWeight = self:GetGroupWeight(familyName)
			if groupWeight > 0 then
				if groupWeight == 6 then
					table.insert(priority6Groups, {
						name = familyName,
						type = "family",
						weight = 100,
					})
					hasPriority6Groups = true
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

	-- Handle priority 6 groups
	if hasPriority6Groups then
		local selectedGroup = priority6Groups[math.random(#priority6Groups)]
		print("RMB_SUMMON: Selected priority 6 group:", selectedGroup.name, selectedGroup.type)
		return selectedGroup.name, selectedGroup.type
	end

	-- Handle regular groups
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

-- Select a family from a supergroup in a specific pool
function addon:SelectFamilyFromPoolSuperGroup(pool, superGroupName)
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
	local hasPriority6Families = false
	for _, familyName in ipairs(families) do
		-- Make sure family has mounts in this pool
		if pool.mountsByFamily[familyName] and #pool.mountsByFamily[familyName] > 0 then
			local familyWeight = self:GetGroupWeight(familyName)
			if familyWeight > 0 then
				if familyWeight == 6 then
					table.insert(priority6Families, {
						name = familyName,
						weight = 100,
					})
					hasPriority6Families = true
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

	-- Handle priority 6 families
	if hasPriority6Families then
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

-- Select a mount from a family in a specific pool
function addon:SelectMountFromPoolFamily(pool, familyName)
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
	local hasPriority6Mounts = false
	for _, mountID in ipairs(familyMounts) do
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		-- Double-check mount is still usable
		if isUsable then
			-- Get mount weight - if it's explicitly set to 0, EXCLUDE this mount
			local mountKey = "mount_" .. mountID
			local mountWeight = self:GetGroupWeight(mountKey)
			-- Skip mounts with explicit 0 weight
			if mountWeight ~= 0 then
				-- If mount has no specific weight, use family weight
				if mountWeight == 0 then
					mountWeight = self:GetGroupWeight(familyName)
				end

				-- Only include if mount has weight > 0
				if mountWeight > 0 then
					if mountWeight == 6 then
						table.insert(priority6Mounts, {
							id = mountID,
							name = name,
							weight = 100,
						})
						hasPriority6Mounts = true
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

	-- Handle priority 6 mounts
	if hasPriority6Mounts then
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

-- =============================
-- MOUNT SUMMONING
-- =============================
-- Summon a specific mount by ID
function addon:SummonMount(mountID)
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
function addon:SummonRandomMount(useContext)
	-- Determine which pool to use
	local poolName = "ground" -- Default to ground
	if useContext and self:GetSetting("contextualSummoning") then
		local context = self:GetCurrentContext()
		if context.isUnderwater then
			poolName = "underwater"
		elseif context.canFly then
			if context.isInSkyridingMode and context.canDragonride then
				-- If player is in skyriding mode and can dragonride in this zone
				-- Only use skyriding mounts
				poolName = "flying"
				-- Filter only skyriding mounts
				local mountID, mountName = self:SelectSpecificMountTypeFromPool(poolName, "skyriding")
				if mountID then
					return self:SummonMount(mountID)
				end
			else
				-- If in steady flight mode or can't dragonride here
				-- Only use steady flight mounts
				poolName = "flying"
				-- Filter only steady flight mounts
				local mountID, mountName = self:SelectSpecificMountTypeFromPool(poolName, "steadyflight")
				if mountID then
					return self:SummonMount(mountID)
				end
			end

			-- Fallback to any flying mount if specific type selection failed
			poolName = "flying"
		else
			poolName = "ground"
		end

		print("RMB_SUMMON: Using " .. poolName .. " mount pool based on context")
	else
		print("RMB_SUMMON: Using general ground mount pool (contextual summoning disabled)")
	end

	-- Select mount from the appropriate pool
	local mountID, mountName = self:SelectMountFromPool(poolName)
	if mountID then
		return self:SummonMount(mountID)
	else
		print("RMB_SUMMON: No eligible mounts found in " .. poolName .. " pool")
		return false
	end
end

-- New function to select only specific mount types (steady flight or skyriding)
-- Refactored function to select specific mount types while respecting weight hierarchy
function addon:SelectSpecificMountTypeFromPool(poolName, mountType)
	local pool = self.mountPools[poolName]
	if not pool then
		print("RMB_SUMMON_ERROR: Invalid pool name:", poolName)
		return nil, nil
	end

	-- Build list of eligible groups first (respecting the hierarchy)
	local eligibleGroups = {}
	-- Add supergroups with weight > 0
	for sgName, families in pairs(pool.superGroups) do
		local superGroupWeight = self:GetGroupWeight(sgName)
		if superGroupWeight > 0 then
			-- This supergroup is eligible
			table.insert(eligibleGroups, {
				name = sgName,
				type = "superGroup",
				weight = self:MapWeightToProbability(superGroupWeight),
			})
		end
	end

	-- Add standalone families with weight > 0
	for familyName, _ in pairs(pool.families) do
		local familyWeight = self:GetGroupWeight(familyName)
		if familyWeight > 0 then
			-- This standalone family is eligible
			table.insert(eligibleGroups, {
				name = familyName,
				type = "family",
				weight = self:MapWeightToProbability(familyWeight),
			})
		end
	end

	-- If no eligible groups, return nil
	if #eligibleGroups == 0 then
		print("RMB_SUMMON: No eligible groups found for " .. mountType .. " mount selection")
		return nil, nil
	end

	-- Try each eligible group until we find one with matching mount type
	-- Randomize the order to prevent always checking the same groups first
	-- Shuffle the groups randomly (Lua 5.1 compatible)
	for i = #eligibleGroups, 2, -1 do
		local j = math.random(i)
		eligibleGroups[i], eligibleGroups[j] = eligibleGroups[j], eligibleGroups[i]
	end

	for groupIndex, group in ipairs(eligibleGroups) do
		local eligibleFamilies = {}
		if group.type == "superGroup" then
			-- Get all families in this supergroup
			for _, familyName in ipairs(pool.superGroups[group.name] or {}) do
				local familyWeight = self:GetGroupWeight(familyName)
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
				weight = group.weight,
			})
		end

		-- If no eligible families in this group, skip to next group
		if #eligibleFamilies == 0 then
			-- Skip to next iteration (no goto in Lua 5.1)
		else
			-- Randomize family order (Lua 5.1 compatible)
			for i = #eligibleFamilies, 2, -1 do
				local j = math.random(i)
				eligibleFamilies[i], eligibleFamilies[j] = eligibleFamilies[j], eligibleFamilies[i]
			end

			-- Try each family until we find one with matching mount type
			for _, family in ipairs(eligibleFamilies) do
				local eligibleMounts = {}
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
							local mountWeight = self:GetGroupWeight(mountKey)
							-- Skip mounts with explicit weight 0
							if mountWeight ~= 0 then
								-- If mount has no specific weight, use family weight
								if mountWeight == nil or mountWeight == 0 then
									mountWeight = self:GetGroupWeight(family.name)
								end

								-- Only include if weight > 0
								if mountWeight > 0 then
									local probWeight = self:MapWeightToProbability(mountWeight)
									table.insert(eligibleMounts, {
										id = mountID,
										name = name,
										weight = probWeight,
									})
									totalWeight = totalWeight + probWeight
									print("RMB_SUMMON: Added eligible " .. mountType .. " mount from "
										.. family.name .. ":", name, "Weight:", mountWeight)
								end
							end
						end
					end
				end

				-- If eligible mounts found in this family, make a selection
				if #eligibleMounts > 0 and totalWeight > 0 then
					-- Weighted random selection
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

-- =============================
-- INTEGRATION WITH BLIZZARD UI
-- =============================
-- Hook into Blizzard's Random Favorite Mount button
function addon:HookRandomFavoriteButton()
	-- Only hook if the setting is enabled
	if not self:GetSetting("overrideBlizzardButton") then
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
				addon:SummonRandomMount(true)
				-- Return true to indicate we handled the click
				return true
			end
		end)
		print("RMB_SUMMON: Successfully hooked random favorite mount button.")
	else
		print("RMB_SUMMON_ERROR: Could not find random favorite mount button to hook.")
	end
end

-- =============================
-- INITIALIZATION
-- =============================
-- Initialize the mount summoning system
function addon:InitializeMountSummoning()
	print("RMB_SUMMON: Initializing mount summoning system")
	-- Initialize pools after data is loaded
	self:BuildMountPools()
	-- Hook the random favorite button
	self:HookRandomFavoriteButton()
	-- Register slash command for testing
	self:RegisterChatCommand("randommount", function()
		self:SummonRandomMount(true)
	end)
	print("RMB_SUMMON: Mount summoning system initialized")
end

-- =============================
-- HOOKS AND CALLBACKS
-- =============================
-- Add this to the addon's OnEnable function
local originalOnEnable = addon.OnEnable
addon.OnEnable = function(self)
	-- Call the original OnEnable
	originalOnEnable(self)
	-- Check flight style
	self:CheckCurrentFlightStyle()
	-- Register for flight style events
	self:RegisterFlightStyleEvents()
	-- Initialize mount summoning
	self:InitializeMountSummoning()
end
-- Add this to perform rebuild when data is processed
local originalInitializeProcessedData = addon.InitializeProcessedData
addon.InitializeProcessedData = function(self)
	-- Call the original function
	originalInitializeProcessedData(self)
	-- Rebuild grouping after data is processed
	self:RebuildMountGrouping()
	-- Build mount pools
	self:BuildMountPools()
end
print("RMB_DEBUG: MountSummon.lua END.")
