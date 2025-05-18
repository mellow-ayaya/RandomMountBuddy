-- MountSummoning.lua
local addonName, addonTable = ...
local addon = RandomMountBuddy -- Reference to the addon from global
print("RMB_DEBUG: MountSummoning.lua START.")
-- Constants for mount types
local MOUNT_TYPE_GROUND = 1
local MOUNT_TYPE_FLYING = 2
local MOUNT_TYPE_UNDERWATER = 3
local MOUNT_TYPE_DRAGONRIDING = 4
-- Function to get all eligible mounts based on current context
function addon:GetEligibleMounts(context)
	-- Start with all collected mounts that are usable
	local eligible = {}
	local totalWeight = 0
	local hasPriority6Mounts = false
	local priority6Mounts = {}
	-- If no context provided, use a default context
	context = context or {
		canFly = true,
		canDragonride = true,
		isUnderwater = false,
		inZone = nil, -- nil means any zone
	}
	-- Debug output
	print("RMB_SUMMON: Getting eligible mounts. Context:",
		"canFly =", context.canFly,
		"canDragonride =", context.canDragonride,
		"isUnderwater =", context.isUnderwater)
	-- Make sure we have processed data
	if not self.processedData or not self.processedData.allCollectedMountFamilyInfo then
		print("RMB_SUMMON_ERROR: Processed mount data not available!")
		return {}, 0
	end

	-- Count how many mounts we're checking
	local totalMounts = 0
	for _ in pairs(self.processedData.allCollectedMountFamilyInfo) do
		totalMounts = totalMounts + 1
	end

	print("RMB_SUMMON: Checking", totalMounts, "mounts for eligibility")
	-- First pass: find any priority 6 mounts
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		-- Basic eligibility check
		local name, spellID, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			-- Get the user weight (0-6)
			local mountKey = "mount_" .. mountID
			local mountWeight = self:GetGroupWeight(mountKey)
			local familyWeight = self:GetGroupWeight(mountInfo.familyName)
			local superGroupWeight = mountInfo.superGroup and self:GetGroupWeight(mountInfo.superGroup) or 0
			-- Check if any level has priority 6
			if mountWeight == 6 or familyWeight == 6 or superGroupWeight == 6 then
				-- Get the mount's type
				local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
				-- Determine mount capabilities
				local isFlyingMount = (mountType == 247 or mountType == 248)
				local isDragonridingMount = (mountType == 402)
				local isUnderwaterMount = (mountType == 231 or mountType == 254)
				local isEligible = true
				-- Check context-specific eligibility
				if context.isUnderwater and not isUnderwaterMount then
					isEligible = false
				elseif not context.canFly and isFlyingMount and not context.canDragonride then
					isEligible = false
				elseif not context.canDragonride and isDragonridingMount then
					isEligible = false
				end

				if isEligible then
					hasPriority6Mounts = true
					table.insert(priority6Mounts, {
						id = mountID,
						name = name,
						weight = 100, -- All priority 6 mounts have equal weight
					})
					print("RMB_SUMMON_DEBUG: Found priority 6 mount:", name)
				end
			end
		end
	end

	-- If we have priority 6 mounts, only use those
	if hasPriority6Mounts then
		print("RMB_SUMMON: Found", #priority6Mounts, "priority 6 mounts, using only these")
		-- Calculate total weight (same for all priority 6 mounts)
		totalWeight = #priority6Mounts * 100
		return priority6Mounts, totalWeight
	end

	-- If no priority 6 mounts, proceed with normal weighted selection
	-- Go through all collected mounts
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		-- Basic eligibility check - must be usable
		local name, spellID, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if not isUsable then
			print("RMB_SUMMON_DEBUG: Mount not usable:", name or mountID)
		else
			-- Get the mount's type
			local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
			-- Determine mount capabilities
			local isFlyingMount = (mountType == 247 or mountType == 248)  -- 247 = Flying, 248 = Flying+Ground
			local isDragonridingMount = (mountType == 402)                -- 402 = Dragonriding
			local isUnderwaterMount = (mountType == 231 or mountType == 254) -- Various underwater types
			print("RMB_SUMMON_DEBUG: Mount:", name, "ID:", mountID,
				"Type:", mountType,
				"Flying:", isFlyingMount,
				"Dragonriding:", isDragonridingMount,
				"Underwater:", isUnderwaterMount)
			local isEligible = true
			-- Check context-specific eligibility
			if context.isUnderwater and not isUnderwaterMount then
				print("RMB_SUMMON_DEBUG: Skipping non-underwater mount in underwater context:", name)
				isEligible = false
			elseif not context.canFly and isFlyingMount and not context.canDragonride then
				-- If can't fly and it's a flying-only mount (not dragonriding in dragonriding zone)
				print("RMB_SUMMON_DEBUG: Skipping flying mount in no-fly zone:", name)
				isEligible = false
			elseif not context.canDragonride and isDragonridingMount then
				-- If can't dragonride and it's a dragonriding mount
				print("RMB_SUMMON_DEBUG: Skipping dragonriding mount in non-dragonriding zone:", name)
				isEligible = false
			end

			-- If eligible by mount type, check weight
			if isEligible then
				-- Calculate weight for this mount
				local weight = self:CalculateMountWeight(mountID)
				if weight <= 0 then
					print("RMB_SUMMON_DEBUG: Skipping mount with zero weight:", name)
				else
					table.insert(eligible, {
						id = mountID,
						name = name,
						weight = weight,
					})
					totalWeight = totalWeight + weight
					print("RMB_SUMMON_DEBUG: Added eligible mount:", name, "Weight:", weight)
				end
			end
		end
	end

	-- Sort by weight descending for easier debugging
	table.sort(eligible, function(a, b) return a.weight > b.weight end)
	print("RMB_SUMMON: Found", #eligible, "eligible mounts with total weight", totalWeight)
	return eligible, totalWeight
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

-- Calculate the weight for a single mount based on its group and family
function addon:CalculateMountWeight(mountID)
	-- Default weight if nothing else is set (for testing, set to 0)
	local defaultWeight = 0
	-- Get family info for this mount
	local mountInfo = self.processedData.allCollectedMountFamilyInfo[mountID]
	if not mountInfo then
		print("RMB_WEIGHT: No info for mount ID", mountID)
		return 0 -- Not collected or no info
	end

	-- Check if mount is individually weighted
	local mountKey = "mount_" .. mountID
	local mountWeight = self:GetGroupWeight(mountKey)
	-- Debug info
	print("RMB_WEIGHT_DEBUG: Mount", mountInfo.name, "ID:", mountID)
	print("RMB_WEIGHT_DEBUG: - Mount-specific weight:", mountWeight)
	-- If mount has individual weight of 0, never use it
	if mountWeight == 0 then
		print("RMB_WEIGHT_DEBUG: - Weight 0, skipping mount")
		return 0
	end

	-- Check if its family has a weight set
	local familyName = mountInfo.familyName
	local familyWeight = self:GetGroupWeight(familyName)
	print("RMB_WEIGHT_DEBUG: - Family:", familyName, "weight:", familyWeight)
	-- Check if its supergroup has a weight set
	local superGroupWeight = nil
	if mountInfo.superGroup then
		superGroupWeight = self:GetGroupWeight(mountInfo.superGroup)
		print("RMB_WEIGHT_DEBUG: - SuperGroup:", mountInfo.superGroup, "weight:", superGroupWeight)
	end

	-- Determine the final weight, prioritizing the most specific setting
	-- Mount-specific weight overrides family weight, which overrides supergroup weight
	local finalUserWeight
	if mountWeight ~= defaultWeight then                              -- If not default weight
		finalUserWeight = mountWeight
	elseif familyWeight ~= defaultWeight then                         -- If not default weight
		finalUserWeight = familyWeight
	elseif superGroupWeight and superGroupWeight ~= defaultWeight then -- If not default weight
		finalUserWeight = superGroupWeight
	else
		finalUserWeight = defaultWeight
	end

	-- Map the user-facing weight to the actual probability weight
	local finalProbabilityWeight = self:MapWeightToProbability(finalUserWeight)
	print("RMB_WEIGHT_DEBUG: - User weight:", finalUserWeight, "-> Probability weight:", finalProbabilityWeight)
	return finalProbabilityWeight
end

-- Select a mount using weighted random selection
function addon:SelectRandomMount(context)
	local eligible, totalWeight = self:GetEligibleMounts(context)
	if #eligible == 0 then
		print("RMB_SUMMON: No eligible mounts found.")
		return nil
	end

	-- If only one mount is eligible, return it directly
	if #eligible == 1 then
		print("RMB_SUMMON: Only one eligible mount:", eligible[1].name)
		return eligible[1].id
	end

	-- Debug output of all eligible mounts and their weights
	print("RMB_SUMMON: Eligible mounts with weights:")
	for i, mount in ipairs(eligible) do
		print(i, mount.name, "Weight:", mount.weight)
	end

	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	print("RMB_SUMMON: Random roll:", roll, "out of", totalWeight)
	local currentSum = 0
	for _, mount in ipairs(eligible) do
		currentSum = currentSum + mount.weight
		print("RMB_SUMMON_DEBUG: Checking", mount.name, "Weight:", mount.weight, "Sum:", currentSum)
		if roll <= currentSum then
			print("RMB_SUMMON: Selected mount:", mount.name, "ID:", mount.id, "Weight:", mount.weight)
			return mount.id
		end
	end

	-- Fallback - should never happen unless there's a math error
	print("RMB_SUMMON_ERROR: Failed to select a mount! Using first eligible.")
	return eligible[1].id
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

-- Main function to pick and summon a random mount based on current context
function addon:SummonRandomMount(useContext)
	-- Determine current context if needed
	local context = nil
	if useContext and self:GetSetting("contextualSummoning") then
		context = self:GetCurrentContext()
	end

	-- Select and summon a mount
	local mountID = self:SelectRandomMount(context)
	if mountID then
		return self:SummonMount(mountID)
	end

	return false
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
end
print("RMB_DEBUG: MountSummoning.lua END.")
