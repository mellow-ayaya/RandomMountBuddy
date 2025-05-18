-- HierarchicalMountSelection.lua
local addonName, addonTable = ...
local addon = RandomMountBuddy -- Reference to the addon from global
print("RMB_DEBUG: HierarchicalMountSelection.lua START.")
-- Constants for mount types
local MOUNT_TYPE_GROUND = 1
local MOUNT_TYPE_FLYING = 2
local MOUNT_TYPE_UNDERWATER = 3
local MOUNT_TYPE_DRAGONRIDING = 4
-- =============================
-- DYNAMIC GROUPING FUNCTIONS
-- =============================
-- Function to rebuild mount grouping based on trait settings
function addon:RebuildMountGrouping()
	-- Create temporary tables for the new organization
	local newSuperGroupMap = {}
	local newStandaloneFamilies = {}
	-- Get trait settings
	local treatMinorArmorAsDistinct = self:GetSetting("treatMinorArmorAsDistinct")
	local treatMajorArmorAsDistinct = self:GetSetting("treatMajorArmorAsDistinct")
	local treatModelVariantsAsDistinct = self:GetSetting("treatModelVariantsAsDistinct")
	local treatUniqueEffectsAsDistinct = self:GetSetting("treatUniqueEffectsAsDistinct")
	print("RMB_DYNAMIC: Rebuilding groups with settings - MinorArmor:",
		treatMinorArmorAsDistinct, "MajorArmor:", treatMajorArmorAsDistinct,
		"ModelVariants:", treatModelVariantsAsDistinct, "UniqueEffects:", treatUniqueEffectsAsDistinct)
	-- First pass: Process all mounts to identify which families should be standalone
	local familiesWithDistinguishingTraits = {}
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = mountInfo.superGroup
		local traits = mountInfo.traits or {}
		-- Skip families that don't have a supergroup (they're already standalone)
		if superGroup then
			-- Check if this family has any "distinguishing" traits
			if (treatMinorArmorAsDistinct and traits.hasMinorArmor) or
					(treatMajorArmorAsDistinct and traits.hasMajorArmor) or
					(treatModelVariantsAsDistinct and traits.hasModelVariant) or
					(treatUniqueEffectsAsDistinct and traits.isUniqueEffect) then
				familiesWithDistinguishingTraits[familyName] = true
			end
		end
	end

	-- Second pass: Build the new grouping structure
	-- First add all original supergroups and families
	for sg, families in pairs(self.processedData.superGroupMap or {}) do
		newSuperGroupMap[sg] = {}
		-- Only add families that don't have distinguishing traits
		for _, familyName in ipairs(families) do
			if not familiesWithDistinguishingTraits[familyName] then
				table.insert(newSuperGroupMap[sg], familyName)
			else
				print("RMB_DYNAMIC: Removing family", familyName, "from supergroup", sg)
			end
		end

		-- If the supergroup is now empty, remove it
		if #newSuperGroupMap[sg] == 0 then
			newSuperGroupMap[sg] = nil
			print("RMB_DYNAMIC: Removed empty supergroup", sg)
		end
	end

	-- Add all standalone families (original ones and newly distinguished ones)
	for family, _ in pairs(self.processedData.standaloneFamilyNames or {}) do
		newStandaloneFamilies[family] = true
	end

	-- Add families with distinguishing traits to standalone list
	for family, _ in pairs(familiesWithDistinguishingTraits) do
		newStandaloneFamilies[family] = true
		print("RMB_DYNAMIC: Added distinguished family as standalone:", family)
	end

	-- Create lookup maps for quick access
	local familyToSuperGroup = {}
	for sg, families in pairs(newSuperGroupMap) do
		for _, familyName in ipairs(families) do
			familyToSuperGroup[familyName] = sg
		end
	end

	-- Store the new structure
	self.processedData.dynamicSuperGroupMap = newSuperGroupMap
	self.processedData.dynamicStandaloneFamilies = newStandaloneFamilies
	self.processedData.dynamicFamilyToSuperGroup = familyToSuperGroup
	-- Log counts for debugging
	local sgCount = 0
	local familiesInSGCount = 0
	for sg, families in pairs(newSuperGroupMap) do
		sgCount = sgCount + 1
		familiesInSGCount = familiesInSGCount + #families
	end

	local standaloneCount = 0
	for _ in pairs(newStandaloneFamilies) do
		standaloneCount = standaloneCount + 1
	end

	print("RMB_DYNAMIC: Rebuilt mount grouping - SuperGroups:", sgCount,
		"Families in SuperGroups:", familiesInSGCount,
		"Standalone Families:", standaloneCount)
	-- Update the UI
	self:PopulateFamilyManagementUI()
end

-- Helper function to get dynamic supergroup for a family
function addon:GetDynamicSuperGroup(familyName)
	if not familyName then return nil end

	-- Use the pre-calculated map if available
	if self.processedData.dynamicFamilyToSuperGroup then
		return self.processedData.dynamicFamilyToSuperGroup[familyName]
	end

	-- Otherwise, check if we have dynamic grouping data
	if not self.processedData.dynamicSuperGroupMap then
		-- Fall back to original supergroup map
		if self.processedData.superGroupMap then
			for sg, families in pairs(self.processedData.superGroupMap) do
				for _, fn in ipairs(families) do
					if fn == familyName then
						return sg
					end
				end
			end
		end

		return nil
	end

	-- Check if family is explicitly marked as standalone in dynamic grouping
	if self.processedData.dynamicStandaloneFamilies and self.processedData.dynamicStandaloneFamilies[familyName] then
		local foundInSuperGroup = false
		-- Double-check that it's not in any supergroup
		for sg, families in pairs(self.processedData.dynamicSuperGroupMap) do
			for _, fn in ipairs(families) do
				if fn == familyName then
					foundInSuperGroup = true
					return sg
				end
			end
		end

		if not foundInSuperGroup then
			return nil
		end
	end

	-- Find supergroup in dynamic mapping
	for sg, families in pairs(self.processedData.dynamicSuperGroupMap) do
		for _, fn in ipairs(families) do
			if fn == familyName then
				return sg
			end
		end
	end

	return nil
end

-- =============================
-- HIERARCHICAL MOUNT SELECTION
-- =============================
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

-- First level: select a supergroup or standalone family
function addon:SelectMountGroup(context)
	print("RMB_SUMMON: Selecting mount group (supergroup or standalone family)")
	-- Build a list of eligible groups
	local eligibleGroups = {}
	local totalWeight = 0
	-- Track priority 6 groups separately
	local priority6Groups = {}
	local hasPriority6Groups = false
	-- Get all supergroups
	local superGroupMap = self.processedData.dynamicSuperGroupMap or self.processedData.superGroupMap
	for sgName, _ in pairs(superGroupMap or {}) do
		local groupWeight = self:GetGroupWeight(sgName)
		if groupWeight > 0 then
			-- Check if this is priority 6
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
	end

	-- Get all standalone families
	local standaloneFamilies = self.processedData.dynamicStandaloneFamilies or self.processedData.standaloneFamilyNames
	for familyName, _ in pairs(standaloneFamilies or {}) do
		local groupWeight = self:GetGroupWeight(familyName)
		if groupWeight > 0 then
			-- Check if this is priority 6
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
	end

	-- Handle priority 6 groups
	if hasPriority6Groups then
		local selectedGroup = priority6Groups[math.random(#priority6Groups)]
		print("RMB_SUMMON: Selected priority 6 group:", selectedGroup.name, selectedGroup.type)
		return selectedGroup.name, selectedGroup.type
	end

	-- If no eligible groups, return nil
	if #eligibleGroups == 0 or totalWeight == 0 then
		print("RMB_SUMMON: No eligible groups found")
		return nil, nil
	end

	-- Weighted random selection
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
	print("RMB_SUMMON_ERROR: Failed to select a group, using first")
	return eligibleGroups[1].name, eligibleGroups[1].type
end

-- Second level: select a family within a supergroup
function addon:SelectFamilyFromSuperGroup(superGroupName, context)
	print("RMB_SUMMON: Selecting family from supergroup:", superGroupName)
	-- Build a list of eligible families
	local eligibleFamilies = {}
	local totalWeight = 0
	-- Track priority 6 families separately
	local priority6Families = {}
	local hasPriority6Families = false
	-- Get families in this supergroup
	local superGroupMap = self.processedData.dynamicSuperGroupMap or self.processedData.superGroupMap
	local families = superGroupMap[superGroupName] or {}
	for _, familyName in ipairs(families) do
		local familyWeight = self:GetGroupWeight(familyName)
		if familyWeight > 0 then
			-- Check if this is priority 6
			if familyWeight == 6 then
				table.insert(priority6Families, {
					name = familyName,
					weight = 100,
				})
				hasPriority6Families = true
			else
				-- Regular weighted family
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
	print("RMB_SUMMON_ERROR: Failed to select a family, using first")
	return eligibleFamilies[1].name
end

-- Third level: select a mount from a family
function addon:SelectMountFromFamily(familyName, context)
	print("RMB_SUMMON: Selecting mount from family:", familyName)
	-- Get all mounts in this family
	local familyMounts = self.processedData.familyToMountIDsMap and self.processedData.familyToMountIDsMap[familyName] or
			{}
	-- Check if this is a single-mount family
	local isSingleMountFamily = (#familyMounts == 1)
	-- For single-mount families, we'll use the family's weight as the mount's weight
	if isSingleMountFamily then
		print("RMB_SUMMON: Detected single-mount family:", familyName)
		local mountID = familyMounts[1]
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if not isUsable then
			print("RMB_SUMMON_DEBUG: Mount not usable:", name)
			return nil, nil
		end

		-- Check if mount type is suitable for context
		local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		local isFlyingMount = (mountType == 247 or mountType == 248)
		local isDragonridingMount = (mountType == 402)
		local isUnderwaterMount = (mountType == 231 or mountType == 254)
		if context then
			if context.isUnderwater and not isUnderwaterMount then
				print("RMB_SUMMON_DEBUG: Skipping non-underwater mount in underwater context:", name)
				return nil, nil
			elseif not context.canFly and isFlyingMount and not context.canDragonride then
				print("RMB_SUMMON_DEBUG: Skipping flying mount in no-fly zone:", name)
				return nil, nil
			elseif not context.canDragonride and isDragonridingMount then
				print("RMB_SUMMON_DEBUG: Skipping dragonriding mount in non-dragonriding zone:", name)
				return nil, nil
			end
		end

		-- For single-mount families, use the family's weight (which the user can set in the UI)
		-- This bypasses the mount's weight which is not accessible in the UI for single-mount families
		local familyWeight = self:GetGroupWeight(familyName)
		-- If the family weight is 0, check if we should use a default weight instead
		if familyWeight == 0 then
			-- Check if we should use a default non-zero weight for single-mount families
			-- You can adjust this value based on your preference
			familyWeight = 3 -- Use a default of Normal priority
			print("RMB_SUMMON: Using default weight for single-mount family:", familyWeight)
		end

		print("RMB_SUMMON: Auto-selecting mount from single-mount family:", name, "Weight:", familyWeight)
		return mountID, name
	end

	-- For multi-mount families, proceed with normal selection
	-- Build a list of eligible mounts
	local eligibleMounts = {}
	local totalWeight = 0
	-- Track priority 6 mounts separately
	local priority6Mounts = {}
	local hasPriority6Mounts = false
	for _, mountID in ipairs(familyMounts) do
		-- Check if mount is usable in current context
		local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if not isUsable then
			print("RMB_SUMMON_DEBUG: Mount not usable:", name)
		else
			-- Get mount type and check if it's suitable for the context
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
			local isFlyingMount = (mountType == 247 or mountType == 248)
			local isDragonridingMount = (mountType == 402)
			local isUnderwaterMount = (mountType == 231 or mountType == 254)
			local isEligible = true
			if context then
				if context.isUnderwater and not isUnderwaterMount then
					print("RMB_SUMMON_DEBUG: Skipping non-underwater mount in underwater context:", name)
					isEligible = false
				elseif not context.canFly and isFlyingMount and not context.canDragonride then
					print("RMB_SUMMON_DEBUG: Skipping flying mount in no-fly zone:", name)
					isEligible = false
				elseif not context.canDragonride and isDragonridingMount then
					print("RMB_SUMMON_DEBUG: Skipping dragonriding mount in non-dragonriding zone:", name)
					isEligible = false
				end
			end

			if isEligible then
				-- Check mount weight
				local mountKey = "mount_" .. mountID
				local mountWeight = self:GetGroupWeight(mountKey)
				if mountWeight > 0 then
					-- Check if this is priority 6
					if mountWeight == 6 then
						table.insert(priority6Mounts, {
							id = mountID,
							name = name,
							weight = 100,
						})
						hasPriority6Mounts = true
					else
						-- Regular weighted mount
						local probWeight = self:MapWeightToProbability(mountWeight)
						table.insert(eligibleMounts, {
							id = mountID,
							name = name,
							weight = probWeight,
						})
						totalWeight = totalWeight + probWeight
					end

					print("RMB_SUMMON: Added eligible mount from family:", name, "Weight:", mountWeight)
				end
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
	print("RMB_SUMMON_ERROR: Failed to select a mount, using first")
	return eligibleMounts[1].id, eligibleMounts[1].name
end

-- Main hierarchical mount selection function
function addon:HierarchicalMountSelection(context)
	-- Stage 1: Select a group (supergroup or standalone family)
	local groupName, groupType = self:SelectMountGroup(context)
	if not groupName then
		print("RMB_SUMMON: No eligible groups available")
		return nil, nil
	end

	-- Stage 2: If supergroup, select a family from it
	local familyName
	if groupType == "superGroup" then
		familyName = self:SelectFamilyFromSuperGroup(groupName, context)
		if not familyName then
			print("RMB_SUMMON: No eligible families in supergroup:", groupName)
			return nil, nil
		end
	else
		-- For standalone families, use the group name
		familyName = groupName
	end

	-- Stage 3: Select a mount from the family
	local mountID, mountName = self:SelectMountFromFamily(familyName, context)
	if not mountID then
		print("RMB_SUMMON: No eligible mounts in family:", familyName)
		return nil, nil
	end

	return mountID, mountName
end

-- Determine the current player context for contextual summoning
function addon:GetCurrentContext()
	local context = {
		canFly = false,
		canDragonride = false,
		isUnderwater = false,
		inZone = nil,
	}
	-- Check if player can fly in current zone
	context.canFly = IsFlyableArea()
	-- Check if Dragonriding is enabled in current zone using modern API
	if IsAdvancedFlyableArea then
		context.canDragonride = IsAdvancedFlyableArea()
	else
		-- Fallback for older WoW versions that don't have IsAdvancedFlyableArea
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

	-- Get current zone for potential zone-specific rules
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID then
		context.inZone = mapID
	end

	-- Check if player is underwater
	context.isUnderwater = IsSubmerged()
	print("RMB_CONTEXT: Current context:",
		"canFly =", context.canFly,
		"canDragonride =", context.canDragonride,
		"isUnderwater =", context.isUnderwater,
		"zone =", context.inZone)
	return context
end

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
	-- Determine current context if needed
	local context = nil
	if useContext and self:GetSetting("contextualSummoning") then
		context = self:GetCurrentContext()
	end

	-- Use hierarchical selection
	local mountID, mountName = self:HierarchicalMountSelection(context)
	if mountID then
		return self:SummonMount(mountID)
	else
		print("RMB_SUMMON: No eligible mounts found for summoning")
		return false
	end
end

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

-- Initialize the mount summoning system
function addon:InitializeMountSummoning()
	-- Hook the random favorite button
	self:HookRandomFavoriteButton()
	-- Register slash command for testing
	self:RegisterChatCommand("randommount", function()
		self:SummonRandomMount(true)
	end)
	print("RMB_SUMMON: Mount summoning system initialized.")
end

-- Add this to the addon's OnEnable function
local originalOnEnable = addon.OnEnable
addon.OnEnable = function(self)
	-- Call the original OnEnable
	originalOnEnable(self)
	-- Initialize mount summoning
	self:InitializeMountSummoning()
	-- Set a callback to rebuild grouping when settings are initialized
	C_Timer.After(2, function()
		self:RebuildMountGrouping()
	end)
end
-- Add this to perform rebuild when data is processed
local originalInitializeProcessedData = addon.InitializeProcessedData
addon.InitializeProcessedData = function(self)
	-- Call the original function
	originalInitializeProcessedData(self)
	-- Rebuild grouping after data is processed
	self:RebuildMountGrouping()
end
print("RMB_DEBUG: HierarchicalMountSelection.lua END.")
