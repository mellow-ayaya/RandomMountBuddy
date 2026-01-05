-- MountRules.lua - Manager for conditional mount summoning rules
-- Supports location-based, group state, and social condition rules
--
-- NOTE: This file handles the LOGIC and DATA MANAGEMENT for mount rules.
-- All UI changes for rules should be made in MountBrowserRules.lua instead.
-- MountBrowserRules.lua handles the visual interface for creating, editing, and managing rules.
--
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("MountRules.lua START.")
-- ============================================================================
-- MOUNT RULES MANAGER CLASS
-- ============================================================================
local MountRules = {}
addon.MountRules = MountRules
-- Instance type mapping (difficulty IDs from GetInstanceInfo)
local INSTANCE_TYPES = {
	[0] = "None",
	[1] = "Dungeon (Normal)",
	[2] = "Dungeon (Heroic)",
	[3] = "10 Player Raid (Normal)",
	[4] = "25 Player Raid (Normal)",
	[5] = "10 Player Raid (Heroic)",
	[6] = "25 Player Raid (Heroic)",
	[7] = "Legacy Looking for Raid",
	[8] = "Mythic Keystone",
	[9] = "40 Player Raid",
	[11] = "Scenario (Heroic)",
	[12] = "Scenario (Normal)",
	[14] = "Raid (Normal)",
	[15] = "Raid (Heroic)",
	[16] = "Raid (Mythic)",
	[17] = "Looking for Raid",
	[23] = "Dungeon (Mythic)",
	[24] = "Dungeon (Timewalking)",
	[25] = "PvP",
	[33] = "Raid (Timewalking)",
	[34] = "Island Expedition (PvP)",
	[35] = "Island Expedition (Normal)",
	[38] = "Island Expedition (Heroic)",
	[39] = "Island Expedition (Mythic)",
	[40] = "Warfront (Normal)",
	[45] = "Warfront (Heroic)",
	[147] = "Visions of N'Zoth",
	[152] = "Torghast",
	[167] = "Path of Ascension: Courage",
	[168] = "Path of Ascension: Loyalty",
	[169] = "Path of Ascension: Wisdom",
	[170] = "Path of Ascension: Humility",
	[205] = "Follower Dungeon",
	[208] = "Delve",
	[220] = "Story Raid",
}
-- Custom mount pools for rules
local CUSTOM_POOLS = {
	passenger = {
		name = "Passenger Mounts (flying only)",
		mountIDs = { 1287, 455, 960, 2597, 1698, 959, 2596, 407, 382 },
	},
	ridealong = {
		name = "Ride Along Mounts (flying only)",
		mountIDs = { 1591, 1563, 1589, 1590, 1588, 1744, 1792, 1830, 1795, 1818, 2090, 2091, 2144, 2324 },
	},
	passenger_ridealong = {
		name = "Passenger + Ride Along (flying only)",
		mountIDs = { 1287, 455, 960, 2597, 1698, 959, 2596, 407, 382, 1591, 1563, 1589, 1590, 1588, 1744, 1792, 1830, 1795, 1818, 2090, 2091, 2144, 2324 },
	},
}
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountRules:Initialize()
	addon:DebugOptions("Initializing Mount Rules Manager...")
	-- Initialize database structure if it doesn't exist
	if not addon.db.profile.zoneSpecificMounts then
		addon.db.profile.zoneSpecificMounts = {
			rules = {},
			nextRuleID = 1,
			defaultRulesInitialized = false,
		}
	end

	-- Migrate old format if needed
	self:MigrateOldFormat()
	-- Add default rules if missing (only on first initialization)
	if not addon.db.profile.zoneSpecificMounts.defaultRulesInitialized then
		self:InitializeDefaultRules()
		addon.db.profile.zoneSpecificMounts.defaultRulesInitialized = true
	end

	addon:DebugOptions("Mount Rules Manager initialized")
end

-- Initialize default rules if not present
function MountRules:InitializeDefaultRules()
	local data = addon.db.profile.zoneSpecificMounts
	if not data or not data.rules then
		return
	end

	-- Add default class hall flying rule
	addon:DebugOptions("Adding default rule: Flying Pool in M+ Portal room")
	-- Pass instance IDs as semicolon-separated string
	self:AddRule("location", "pool", "2678", "instanceid", "flying")
	-- Add default class hall flying rule
	addon:DebugOptions("Adding default rule: Flying Pool in Class Halls")
	-- Pass instance IDs as semicolon-separated string
	self:AddRule("location", "pool", "1519;1540;1514;1469;1479", "instanceid", "flying")
	-- Add chauffeur mount rule for low level characters
	addon:DebugOptions("Adding default rule: Chauffeured mounts for level < 10")
	self:AddRule("character_level", "specific", "<", 10, { 678, 679 })
end

-- Get available pool names for UI
function MountRules:GetAvailablePools()
	return {
		{ value = "flying", text = "Flying Pool" },
		{ value = "ground", text = "Ground Only" },
		{ value = "groundUsable", text = "Ground + Flying" },
		{ value = "underwater", text = "Underwater Pool" },
		{ value = "passenger", text = "Passenger Mounts (flying only)" },
		{ value = "ridealong", text = "Ride Along Mounts (flying only)" },
		{ value = "passenger_ridealong", text = "Passenger + Ride Along (flying only)" },
	}
end

-- Get mount IDs for custom pools
function MountRules:GetCustomPoolMounts(poolName)
	if CUSTOM_POOLS[poolName] then
		return CUSTOM_POOLS[poolName].mountIDs
	end

	return nil
end

-- Migrate from old zone-keyed format to new priority-based format
function MountRules:MigrateOldFormat()
	local data = addon.db.profile.zoneSpecificMounts
	-- Check if we have old format (direct zone keys instead of rules array)
	if data.rules then
		-- Already in new format, but check if rules need mountID -> mountIDs migration
		for _, rule in ipairs(data.rules) do
			if rule.actionType == "specific" and rule.mountID and not rule.mountIDs then
				-- Migrate single mountID to mountIDs array
				rule.mountIDs = { rule.mountID }
				rule.mountNames = { rule.mountName or "Unknown" }
				rule.mountID = nil
				rule.mountName = nil
				addon:DebugOptions("Migrated rule to use mountIDs array")
			end
		end

		return -- Already in new format
	end

	addon:DebugOptions("Migrating zone-specific mounts to new format...")
	local oldRules = {}
	for k, v in pairs(data) do
		if type(k) == "number" and type(v) == "table" then
			table.insert(oldRules, v)
		end
	end

	-- Convert to new format
	local newRules = {}
	local nextID = 1
	for _, oldRule in ipairs(oldRules) do
		local newRule = {
			id = nextID,
			priority = nextID,
			ruleType = "location",
			locationID = oldRule.zoneID,
			locationType = "mapid",
			locationName = oldRule.zoneName,
			timestamp = oldRule.timestamp or time(),
		}
		-- Convert action type
		if oldRule.type == "specific" then
			newRule.actionType = "specific"
			-- Convert single mount to array
			newRule.mountIDs = { oldRule.mountID }
			newRule.mountNames = { oldRule.mountName }
		elseif oldRule.type == "pool" then
			newRule.actionType = "pool"
			newRule.poolName = oldRule.poolName
		end

		table.insert(newRules, newRule)
		nextID = nextID + 1
	end

	-- Clear old data and set new format
	wipe(addon.db.profile.zoneSpecificMounts)
	addon.db.profile.zoneSpecificMounts = {
		rules = newRules,
		nextRuleID = nextID,
	}
	if #newRules > 0 then
		addon:DebugOptions("Migrated " .. #newRules .. " rules to new format")
	end
end

-- ============================================================================
-- RULE MANAGEMENT
-- ============================================================================
-- Add a new mount rule
-- Parameters can vary based on ruleType
function MountRules:AddRule(ruleType, actionType, ...)
	local data = addon.db.profile.zoneSpecificMounts
	-- Validate action type (common to all rules)
	if actionType ~= "specific" and actionType ~= "pool" then
		return false, "Invalid action type. Must be 'specific' or 'pool'"
	end

	-- Create the base rule
	local rule = {
		id = data.nextRuleID,
		priority = #data.rules + 1,
		ruleType = ruleType,
		timestamp = time(),
		actionType = actionType,
	}
	-- Process rule-specific parameters
	local success, errorMsg = self:ProcessRuleParameters(rule, ...)
	if not success then
		return false, errorMsg
	end

	-- Process action parameters
	local actionArgs = { ... }
	success, errorMsg = self:ProcessActionParameters(rule, actionType, actionArgs)
	if not success then
		return false, errorMsg
	end

	-- Add rule and increment ID
	table.insert(data.rules, rule)
	data.nextRuleID = data.nextRuleID + 1
	addon:DebugOptions("Added rule:", "Type:", ruleType, "Priority:", rule.priority)
	return true, "Rule added successfully"
end

-- Process parameters specific to each rule type
function MountRules:ProcessRuleParameters(rule, ...)
	local args = { ... }
	if rule.ruleType == "location" then
		local locationID, locationType = args[1], args[2]
		if not locationID then
			return false, "Location ID is required"
		end

		if not locationType or (locationType ~= "mapid" and locationType ~= "instanceid" and locationType ~= "parentzone") then
			return false, "Invalid location type. Must be 'mapid', 'instanceid', or 'parentzone'"
		end

		-- Support single ID or semicolon-separated list
		local locationIDs = {}
		if type(locationID) == "table" then
			-- Already an array
			locationIDs = locationID
		elseif type(locationID) == "string" then
			-- Parse semicolon-separated string
			for idStr in locationID:gmatch("[^;]+") do
				local trimmed = idStr:match("^%s*(.-)%s*$")
				local id = tonumber(trimmed)
				if id and id > 0 then
					table.insert(locationIDs, id)
				end
			end
		else
			-- Single number
			table.insert(locationIDs, locationID)
		end

		if #locationIDs == 0 then
			return false, "Invalid location ID"
		end

		rule.locationIDs = locationIDs
		rule.locationType = locationType
		-- Get location name (use first ID for the display name)
		local firstID = locationIDs[1]
		if locationType == "mapid" or locationType == "parentzone" then
			local mapInfo = C_Map.GetMapInfo(firstID)
			rule.locationName = mapInfo and mapInfo.name or ("Location " .. firstID)
		elseif locationType == "instanceid" then
			-- Use GetRealZoneText to get instance name
			local instanceName = GetRealZoneText(firstID)
			-- Fallback if GetRealZoneText returns nil or empty
			if not instanceName or instanceName == "" then
				instanceName = "Instance " .. firstID
			end

			rule.locationName = instanceName
		end

		return true
	elseif rule.ruleType == "instance_type" then
		local instanceType = args[1]
		if not instanceType then
			return false, "Instance type not specified"
		end

		if not INSTANCE_TYPES[instanceType] then
			return false, "Invalid instance type"
		end

		rule.instanceType = instanceType
		rule.instanceTypeName = INSTANCE_TYPES[instanceType]
		return true
	elseif rule.ruleType == "group_state" then
		local groupState = args[1]
		local validStates = {
			in_group = true,
			not_in_group = true,
			in_party = true,
			not_in_party = true,
			in_raid = true,
			not_in_raid = true,
		}
		if not groupState or not validStates[groupState] then
			return false,
					"Invalid group state. Must be one of: in_group, not_in_group, in_party, not_in_party, in_raid, not_in_raid"
		end

		rule.groupState = groupState
		rule.groupStateName = groupState:gsub("_", " "):gsub("(%a)([%w_']*)", function(a, b) return string.upper(a) .. b end)
		return true
	elseif rule.ruleType == "social" then
		local socialType, socialData = args[1], args[2]
		local validTypes = {
			bnet_friend_in_party = true,
			friend_in_party = true,
			character_whitelist = true,
			guild_member_in_party = true,
		}
		if not socialType or not validTypes[socialType] then
			return false,
					"Invalid social type. Must be one of: bnet_friend_in_party, friend_in_party, character_whitelist, guild_member_in_party"
		end

		rule.socialType = socialType
		if socialType == "character_whitelist" then
			if not socialData or type(socialData) ~= "table" or #socialData == 0 then
				return false, "Character whitelist requires a non-empty list of character names"
			end

			rule.characterNames = socialData
		end

		-- Generate display name
		if socialType == "bnet_friend_in_party" then
			rule.socialTypeName = "BNet Friend in Party"
		elseif socialType == "friend_in_party" then
			rule.socialTypeName = "Friend in Party"
		elseif socialType == "character_whitelist" then
			rule.socialTypeName = "Specific Players: " .. table.concat(socialData, ", ")
		elseif socialType == "guild_member_in_party" then
			rule.socialTypeName = "Guild Member in Party"
		end

		return true
	elseif rule.ruleType == "character_level" then
		local operator, level = args[1], args[2]
		if not operator then
			return false, "Operator is required"
		end

		local validOperators = { ["="] = true, ["<"] = true, ["<="] = true, [">"] = true, [">="] = true }
		if not validOperators[operator] then
			return false, "Invalid operator. Must be one of: =, <, <=, >, >="
		end

		if not level or type(level) ~= "number" or level < 1 or level > 80 then
			return false, "Level must be a number between 1 and 80"
		end

		rule.operator = operator
		rule.level = level
		rule.levelDisplayName = "Level " .. operator .. " " .. level
		return true
	elseif rule.ruleType == "keybind" then
		local keybindNumber = args[1]
		if not keybindNumber or type(keybindNumber) ~= "number" or keybindNumber < 1 or keybindNumber > 4 then
			return false, "Keybind number must be 1, 2, 3, or 4"
		end

		rule.keybindNumber = keybindNumber
		local keybindNames = {
			[1] = "RandomMountBuddy Summon",
			[2] = "RandomMountBuddy Summon 2",
			[3] = "RandomMountBuddy Summon 3",
			[4] = "RandomMountBuddy Summon 4",
		}
		rule.keybindName = keybindNames[keybindNumber] or ("Keybind " .. keybindNumber)
		return true
	end

	return false, "Invalid rule type: " .. tostring(rule.ruleType)
end

-- Process action parameters (mount IDs or pool name)
function MountRules:ProcessActionParameters(rule, actionType, args)
	if actionType == "specific" then
		-- Find mountIDs in args (could be at different positions depending on rule type)
		local mountIDs
		-- For location and instance_type rules, mountIDs come after the type-specific params
		if rule.ruleType == "location" then
			mountIDs = args[3] -- After locationID, locationType
		elseif rule.ruleType == "instance_type" then
			mountIDs = args[2] -- After instanceType
		elseif rule.ruleType == "group_state" then
			mountIDs = args[2] -- After groupState
		elseif rule.ruleType == "social" then
			mountIDs = args[3] -- After socialType, socialData
		elseif rule.ruleType == "character_level" then
			mountIDs = args[3] -- After operator, level
		elseif rule.ruleType == "keybind" then
			mountIDs = args[2] -- After keybindNumber
		end

		if not mountIDs or type(mountIDs) ~= "table" or #mountIDs == 0 then
			return false, "Invalid mount IDs for specific mount rule"
		end

		-- Verify all mounts exist and build names list
		rule.mountIDs = {}
		rule.mountNames = {}
		for _, mountID in ipairs(mountIDs) do
			if mountID and mountID > 0 then
				local mountName = C_MountJournal.GetMountInfoByID(mountID)
				if mountName then
					table.insert(rule.mountIDs, mountID)
					table.insert(rule.mountNames, mountName)
				else
					addon:DebugOptions("Warning: Mount ID " .. mountID .. " does not exist, skipping")
				end
			end
		end

		if #rule.mountIDs == 0 then
			return false, "None of the provided mount IDs are valid"
		end

		return true
	elseif actionType == "pool" then
		-- Find poolName in args
		local poolName
		if rule.ruleType == "location" then
			poolName = args[3] -- After locationID, locationType
		elseif rule.ruleType == "instance_type" then
			poolName = args[2] -- After instanceType
		elseif rule.ruleType == "group_state" then
			poolName = args[2] -- After groupState
		elseif rule.ruleType == "social" then
			poolName = args[3] -- After socialType, socialData
		elseif rule.ruleType == "character_level" then
			poolName = args[3] -- After operator, level
		elseif rule.ruleType == "keybind" then
			poolName = args[2] -- After keybindNumber
		end

		if not poolName then
			return false, "Pool name is required"
		end

		local validPools = {
			flying = true,
			ground = true,
			underwater = true,
			groundUsable = true,
			passenger = true,
			ridealong = true,
			passenger_ridealong = true,
		}
		if not validPools[poolName] then
			return false,
					"Invalid pool name. Must be one of: flying, ground, underwater, groundUsable, passenger, ridealong, passenger_ridealong"
		end

		rule.poolName = poolName
		return true
	end

	return false, "Invalid action type"
end

-- Remove a rule by ID
function MountRules:RemoveRule(ruleID)
	local data = addon.db.profile.zoneSpecificMounts
	for i, rule in ipairs(data.rules) do
		if rule.id == ruleID then
			table.remove(data.rules, i)
			-- Recalculate priorities
			for j, r in ipairs(data.rules) do
				r.priority = j
			end

			addon:DebugOptions("Removed rule ID:", ruleID)
			return true, "Rule removed successfully"
		end
	end

	return false, "Rule not found"
end

-- Move a rule up in priority
function MountRules:MoveRuleUp(ruleID)
	local data = addon.db.profile.zoneSpecificMounts
	for i, rule in ipairs(data.rules) do
		if rule.id == ruleID then
			if i == 1 then
				return false, "Rule is already at highest priority"
			end

			-- Swap with previous rule
			data.rules[i], data.rules[i - 1] = data.rules[i - 1], data.rules[i]
			-- Update priorities
			for j, r in ipairs(data.rules) do
				r.priority = j
			end

			addon:DebugOptions("Moved rule up:", ruleID)
			return true, "Rule moved up"
		end
	end

	return false, "Rule not found"
end

-- Move a rule down in priority
function MountRules:MoveRuleDown(ruleID)
	local data = addon.db.profile.zoneSpecificMounts
	for i, rule in ipairs(data.rules) do
		if rule.id == ruleID then
			if i == #data.rules then
				return false, "Rule is already at lowest priority"
			end

			-- Swap with next rule
			data.rules[i], data.rules[i + 1] = data.rules[i + 1], data.rules[i]
			-- Update priorities
			for j, r in ipairs(data.rules) do
				r.priority = j
			end

			addon:DebugOptions("Moved rule down:", ruleID)
			return true, "Rule moved down"
		end
	end

	return false, "Rule not found"
end

-- Get all rules in priority order
function MountRules:GetAllRules()
	return addon.db.profile.zoneSpecificMounts.rules or {}
end

-- ============================================================================
-- LOCATION INFORMATION
-- ============================================================================
-- Get current location information for display purposes
function MountRules:GetCurrentLocationInfo()
	local mapID = C_Map.GetBestMapForUnit("player")
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID =
			GetInstanceInfo()
	local info = {}
	-- Get map info
	if mapID then
		local mapInfo = C_Map.GetMapInfo(mapID)
		if mapInfo then
			info.mapID = mapID
			info.mapName = mapInfo.name
			-- Get parent zone info
			if mapInfo.parentMapID and mapInfo.parentMapID > 0 then
				local parentInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
				if parentInfo then
					info.parentID = mapInfo.parentMapID
					info.parentName = parentInfo.name
				end
			end
		end
	end

	-- Get instance info
	if instanceID and instanceID > 0 then
		info.instanceID = instanceID
		info.instanceName = instanceName
		info.instanceType = difficultyID
		info.instanceTypeName = INSTANCE_TYPES[difficultyID] or "Unknown"
	end

	return info
end

-- ============================================================================
-- CONDITION EVALUATION
-- ============================================================================
-- Check if a location rule matches
function MountRules:EvaluateLocationRule(rule)
	local mapID = C_Map.GetBestMapForUnit("player")
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID =
			GetInstanceInfo()
	local parentMapID = mapID and C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).parentMapID or nil
	-- Support both old single locationID and new locationIDs array
	local locationIDs = rule.locationIDs or (rule.locationID and { rule.locationID }) or {}
	if #locationIDs == 0 then
		addon:DebugSummon("  Location rule has no IDs - failing")
		return false
	end

	addon:DebugSummon("  Evaluating location rule:")
	addon:DebugSummon("    Type:", rule.locationType)
	addon:DebugSummon("    Rule IDs:", table.concat(locationIDs, ", "))
	addon:DebugSummon("    Current mapID:", mapID or "nil", "instanceID:", instanceID or "nil", "parentMapID:",
		parentMapID or "nil")
	-- Check if current location matches any of the IDs
	local currentID
	if rule.locationType == "mapid" then
		currentID = mapID
	elseif rule.locationType == "instanceid" then
		currentID = instanceID
	elseif rule.locationType == "parentzone" then
		currentID = parentMapID
	end

	addon:DebugSummon("    Checking currentID:", currentID or "nil")
	if currentID then
		for _, id in ipairs(locationIDs) do
			if currentID == id then
				addon:DebugSummon("    MATCH found! Current", currentID, "== Rule", id)
				return true
			end
		end
	end

	addon:DebugSummon("    No match found")
	return false
end

-- Check if an instance type rule matches
function MountRules:EvaluateInstanceTypeRule(rule)
	local instanceName, instanceType, difficultyID = GetInstanceInfo()
	return difficultyID == rule.instanceType
end

-- Check if a group state rule matches
function MountRules:EvaluateGroupStateRule(rule)
	local inGroup = IsInGroup()
	local inRaid = IsInRaid()
	local inParty = inGroup and not inRaid
	if rule.groupState == "in_group" then
		return inGroup
	elseif rule.groupState == "not_in_group" then
		return not inGroup
	elseif rule.groupState == "in_party" then
		return inParty
	elseif rule.groupState == "not_in_party" then
		return not inParty
	elseif rule.groupState == "in_raid" then
		return inRaid
	elseif rule.groupState == "not_in_raid" then
		return not inRaid
	end

	return false
end

-- Check if a party member is a BNet friend
function MountRules:IsPartyMemberBNetFriend(unit)
	local guid = UnitGUID(unit)
	if not guid then return false end

	-- Direct lookup - no iteration needed!
	local accountInfo = C_BattleNet.GetAccountInfoByGUID(guid)
	if accountInfo and accountInfo.isFriend then
		return true, accountInfo
	end

	return false
end

-- Check if a party member is an in-game friend
function MountRules:IsPartyMemberFriend(unit)
	local guid = UnitGUID(unit)
	if not guid then return false end

	-- Check in-game friends (requires name lookup)
	local name, realm = UnitFullName(unit)
	if name then
		local friendInfo = C_FriendList.GetFriendInfo(name)
		if friendInfo and friendInfo.guid == guid then
			return true, friendInfo
		end
	end

	return false
end

-- Check if a party member matches character whitelist
function MountRules:IsPartyMemberInWhitelist(unit, characterNames)
	local name, realm = UnitFullName(unit)
	if not name then return false end

	-- Construct full name
	local fullName = realm and (name .. "-" .. realm) or name
	-- Check against whitelist
	for _, whitelistedName in ipairs(characterNames) do
		if fullName == whitelistedName or name == whitelistedName then
			return true
		end
	end

	return false
end

-- Check if a social rule matches
function MountRules:EvaluateSocialRule(rule)
	-- Check if we're in a group
	if not IsInGroup() then
		return false
	end

	local numGroupMembers = GetNumGroupMembers()
	if numGroupMembers == 0 then
		return false
	end

	-- Determine if we're in raid or party
	local isRaid = IsInRaid()
	local unitPrefix = isRaid and "raid" or "party"
	-- Check each group member
	for i = 1, numGroupMembers do
		local unit = unitPrefix .. i
		if rule.socialType == "bnet_friend_in_party" then
			if self:IsPartyMemberBNetFriend(unit) then
				return true
			end
		elseif rule.socialType == "friend_in_party" then
			if self:IsPartyMemberFriend(unit) then
				return true
			end
		elseif rule.socialType == "character_whitelist" then
			-- Defensive: check if characterNames exists and is not empty
			if rule.characterNames and #rule.characterNames > 0 then
				if self:IsPartyMemberInWhitelist(unit, rule.characterNames) then
					return true
				end
			else
				addon:DebugSummon("  Character whitelist is empty or nil - rule fails")
				return false
			end
		elseif rule.socialType == "guild_member_in_party" then
			if UnitIsInMyGuild(unit) then
				return true
			end
		end
	end

	return false
end

-- Check if a character level rule matches
function MountRules:EvaluateCharacterLevelRule(rule)
	local playerLevel = UnitLevel("player")
	local targetLevel = rule.level
	if not targetLevel then
		addon:DebugOptions("Character level rule has no level specified")
		return false
	end

	-- Support both 'operator' (standard) and 'levelOperator' (UI/legacy field name)
	local operator = rule.operator or rule.levelOperator or "="
	if operator == "=" then
		return playerLevel == targetLevel
	elseif operator == "<" then
		return playerLevel < targetLevel
	elseif operator == "<=" then
		return playerLevel <= targetLevel
	elseif operator == ">" then
		return playerLevel > targetLevel
	elseif operator == ">=" then
		return playerLevel >= targetLevel
	end

	return false
end

-- Check if a keybind rule matches
function MountRules:EvaluateKeybindRule(rule)
	-- Get the active keybind number set by the macro
	local activeKeybind = RandomMountBuddy.activeKeybind or 1
	addon:DebugSummon("  Evaluating keybind rule: Rule keybind=" ..
		(rule.keybindNumber or "nil") .. ", Active keybind=" .. activeKeybind)
	local matches = rule.keybindNumber == activeKeybind
	addon:DebugSummon("  Keybind match result: " .. tostring(matches))
	return matches
end

-- Evaluate a single condition (helper function for multi-condition support)
function MountRules:EvaluateSingleCondition(condition)
	if condition.ruleType == "location" then
		return self:EvaluateLocationRule(condition)
	elseif condition.ruleType == "instance_type" then
		return self:EvaluateInstanceTypeRule(condition)
	elseif condition.ruleType == "group_state" then
		return self:EvaluateGroupStateRule(condition)
	elseif condition.ruleType == "social" then
		return self:EvaluateSocialRule(condition)
	elseif condition.ruleType == "character_level" then
		return self:EvaluateCharacterLevelRule(condition)
	elseif condition.ruleType == "keybind" then
		return self:EvaluateKeybindRule(condition)
	end

	return false
end

-- Evaluate multiple conditions with AND logic
function MountRules:EvaluateMultiConditionRule(rule)
	if not rule.conditions or #rule.conditions == 0 then
		return false
	end

	addon:DebugSummon("Evaluating multi-condition rule with " .. #rule.conditions .. " condition(s)")
	-- ALL conditions must match (AND logic)
	for i, condition in ipairs(rule.conditions) do
		addon:DebugSummon("  Condition " .. i .. ": Type=" .. (condition.ruleType or "unknown"))
		local matches = self:EvaluateSingleCondition(condition)
		if not matches then
			addon:DebugSummon("  Condition " .. i .. " did NOT match - rule fails")
			return false
		end

		addon:DebugSummon("  Condition " .. i .. " matched")
	end

	addon:DebugSummon("All conditions matched - rule succeeds")
	return true
end

-- Check current state against all rules
-- Returns first matching rule in priority order (top to bottom)
function MountRules:GetMatchingRules()
	local data = addon.db.profile.zoneSpecificMounts
	if not data or not data.rules or #data.rules == 0 then
		addon:DebugSummon("No mount rules configured")
		return nil
	end

	addon:DebugSummon("Checking " .. #data.rules .. " mount rule(s)")
	-- Check rules in priority order (first match wins)
	for _, rule in ipairs(data.rules) do
		addon:DebugSummon("Evaluating rule ID " .. rule.id .. " (Priority " .. rule.priority .. ")")
		local matches = false
		-- Check if this is a multi-condition rule (new format)
		if rule.conditions and #rule.conditions > 0 then
			addon:DebugSummon("  Multi-condition rule detected")
			matches = self:EvaluateMultiConditionRule(rule)
			-- Otherwise, single condition rule (backward compatible format)
		elseif rule.ruleType then
			addon:DebugSummon("  Single-condition rule: Type=" .. rule.ruleType)
			matches = self:EvaluateSingleCondition(rule)
		end

		if matches then
			addon:DebugSummon("Matched rule:", "ID:", rule.id, "Priority:", rule.priority)
			return rule
		end
	end

	addon:DebugSummon("No mount rules matched current conditions")
	return nil
end

-- Get mount ID or pool based on matching rule
function MountRules:GetMountForCurrentLocation()
	local rule = self:GetMatchingRules()
	if not rule then
		return nil, nil
	end

	addon:DebugSummon("Mount rule matched:", self:GetRuleDescription(rule))
	if rule.actionType == "specific" then
		-- Rule has multiple mount IDs - randomly select one
		if not rule.mountIDs or #rule.mountIDs == 0 then
			addon:DebugSummon("Rule has no mount IDs")
			return nil, nil
		end

		-- Build list of usable mounts from the rule
		-- Filter out mounts that should be hidden (wrong faction, etc)
		local usableMounts = {}
		for _, mountID in ipairs(rule.mountIDs) do
			local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected =
					C_MountJournal.GetMountInfoByID(mountID)
			if name and not shouldHideOnChar then
				-- Mount exists and is not hidden from this character
				table.insert(usableMounts, mountID)
			elseif shouldHideOnChar then
				addon:DebugSummon("Mount " ..
					(name or ("ID " .. mountID)) .. " hidden from this character (wrong faction/requirements)")
			end
		end

		if #usableMounts == 0 then
			addon:DebugSummon("None of the rule's " .. #rule.mountIDs .. " mount(s) are usable in current context")
			return nil, nil
		end

		-- Randomly select from usable mounts
		local selectedMount = usableMounts[math.random(#usableMounts)]
		local mountName = C_MountJournal.GetMountInfoByID(selectedMount)
		addon:DebugSummon("Rule matched: Selected mount '" ..
			(mountName or "unknown") .. "' (ID " .. selectedMount .. ") from " .. #usableMounts .. " usable mount(s)")
		return selectedMount, nil
	elseif rule.actionType == "pool" then
		-- Check if it's a custom pool (predefined mount list)
		if CUSTOM_POOLS[rule.poolName] then
			addon:DebugSummon("Custom pool found:", rule.poolName)
			-- Treat custom pools like specific mount lists
			local customMountIDs = CUSTOM_POOLS[rule.poolName].mountIDs
			-- Build list of usable mounts from the custom pool
			-- Filter out mounts that should be hidden (wrong faction, etc)
			local usableMounts = {}
			for _, mountID in ipairs(customMountIDs) do
				local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected =
						C_MountJournal.GetMountInfoByID(mountID)
				if name and not shouldHideOnChar then
					-- Mount exists and is not hidden from this character
					table.insert(usableMounts, mountID)
				elseif shouldHideOnChar then
					addon:DebugSummon("Mount " ..
						(name or ("ID " .. mountID)) .. " in custom pool hidden from this character (wrong faction/requirements)")
				end
			end

			if #usableMounts == 0 then
				addon:DebugSummon("None of the custom pool's " .. #customMountIDs .. " mount(s) are usable")
				return nil, nil
			end

			-- Randomly select from usable mounts
			local selectedMount = usableMounts[math.random(#usableMounts)]
			local mountName = C_MountJournal.GetMountInfoByID(selectedMount)
			addon:DebugSummon("Custom pool '" ..
				rule.poolName ..
				"': Selected mount '" ..
				(mountName or "unknown") .. "' (ID " .. selectedMount .. ") from " .. #usableMounts .. " usable mount(s)")
			return selectedMount, nil -- Return mountID, not poolName
		else
			-- Standard pool (flying/ground/underwater/groundUsable)
			addon:DebugSummon("Standard pool found:", rule.poolName)
			return nil, rule.poolName
		end
	end

	return nil, nil
end

-- ============================================================================
-- UI HELPER FUNCTIONS
-- ============================================================================
-- Get a human-readable description of a single condition (helper for GetRuleDescription)
function MountRules:GetSingleConditionDescription(condition)
	local desc = ""
	if condition.ruleType == "location" then
		local displayName = condition.locationName or "Unknown"
		-- For instance IDs, try to get fresh name using GetRealZoneText
		if condition.locationType == "instanceid" then
			local locationIDs = condition.locationIDs or { condition.locationID }
			-- Get names for up to 3 instances
			local names = {}
			local maxNamesToShow = 3
			for i = 1, math.min(#locationIDs, maxNamesToShow) do
				local instanceName = GetRealZoneText(locationIDs[i])
				if instanceName and instanceName ~= "" then
					table.insert(names, instanceName)
				else
					table.insert(names, "Instance " .. locationIDs[i])
				end
			end

			-- Build display name
			if #names > 0 then
				displayName = table.concat(names, ", ")
				-- Add "..." if there are more instances beyond what we showed
				if #locationIDs > maxNamesToShow then
					displayName = displayName .. ", ..."
				end
			end
		end

		if condition.locationType == "mapid" then
			desc = "|cff00ffffMap:|r " .. displayName
		elseif condition.locationType == "instanceid" then
			desc = "|cff00ffffInstance:|r " .. displayName
		elseif condition.locationType == "parentzone" then
			desc = "|cff00ffffParent Zone:|r " .. displayName
		end

		-- Display IDs (support both old single ID and new array)
		local locationIDs = condition.locationIDs or { condition.locationID }
		if #locationIDs > 1 then
			desc = desc .. " (IDs: " .. table.concat(locationIDs, ", ") .. ")"
		else
			desc = desc .. " (ID: " .. locationIDs[1] .. ")"
		end
	elseif condition.ruleType == "instance_type" then
		desc = "|cffff9900Instance Type:|r " .. (condition.instanceTypeName or "Unknown")
	elseif condition.ruleType == "group_state" then
		desc = "|cffff00ffGroup State:|r " .. (condition.groupStateName or "Unknown")
	elseif condition.ruleType == "social" then
		desc = "|cff00ff00Social:|r " .. (condition.socialTypeName or "Unknown")
	elseif condition.ruleType == "character_level" then
		desc = "|cffffcc00Character Level:|r " .. (condition.levelDisplayName or "Unknown")
	elseif condition.ruleType == "keybind" then
		desc = "|cffff6600Keybind:|r " .. (condition.keybindName or "Unknown")
	end

	return desc
end

-- Get a human-readable description of a rule
function MountRules:GetRuleDescription(rule)
	local desc = ""
	-- Check if this is a multi-condition rule
	if rule.conditions and #rule.conditions > 0 then
		-- Multi-condition rule - show all conditions with AND
		for i, condition in ipairs(rule.conditions) do
			-- Get description for this condition
			local conditionDesc = self:GetSingleConditionDescription(condition)
			desc = desc .. conditionDesc
			-- Add AND between conditions (except after last one)
			if i < #rule.conditions then
				desc = desc .. "\n|cffaaaaaa  AND|r "
			end
		end

		-- Single condition rule (backward compatible)
	elseif rule.ruleType then
		desc = self:GetSingleConditionDescription(rule)
	end

	-- Action (same for both formats)
	desc = desc .. "\n"
	if rule.actionType == "specific" then
		-- Handle both old single mountID and new mountIDs array
		local mountNames = {}
		if rule.mountIDs then
			-- New format: multiple mounts
			if rule.mountNames then
				-- Use stored names if available
				for i, name in ipairs(rule.mountNames) do
					table.insert(mountNames, name)
				end
			else
				-- Fallback: Look up names from IDs if mountNames not stored
				for _, mountID in ipairs(rule.mountIDs) do
					local mountName = C_MountJournal.GetMountInfoByID(mountID)
					if mountName then
						table.insert(mountNames, mountName)
					else
						table.insert(mountNames, "Mount ID " .. mountID)
					end
				end
			end
		elseif rule.mountID then
			-- Old format: single mount (for backwards compatibility)
			table.insert(mountNames, rule.mountName or "Unknown")
		end

		if #mountNames == 0 then
			desc = desc .. "|cff00ff00Action:|r Summon Unknown Mount"
		elseif #mountNames == 1 then
			desc = desc .. "|cff00ff00Action:|r Summon " .. mountNames[1]
		else
			desc = desc .. "|cff00ff00Action:|r Summon random from " .. #mountNames .. " mounts: "
			for i, name in ipairs(mountNames) do
				desc = desc .. name
				if i < #mountNames then
					desc = desc .. ", "
				end
			end
		end
	elseif rule.actionType == "pool" then
		local poolDisplayNames = {
			flying = "Flying Pool",
			ground = "Ground Only",
			groundUsable = "Ground + Flying",
			underwater = "Underwater Pool",
			passenger = "Passenger Mounts (flying only)",
			ridealong = "Ride Along Mounts (flying only)",
			passenger_ridealong = "Passenger + Ride Along (flying only)",
		}
		desc = desc .. "|cff00ff00Action:|r Use " .. (poolDisplayNames[rule.poolName] or rule.poolName)
	end

	return desc
end

-- ============================================================================
-- UI POPULATION
-- ============================================================================
function MountRules:PopulateZoneSpecificUI()
	addon:DebugOptions("Populating Mount Rules UI...")
	-- Clear existing dynamic args
	if addon.zoneSpecificArgsRef then
		wipe(addon.zoneSpecificArgsRef)
	else
		addon.zoneSpecificArgsRef = {}
	end

	-- Order counter for UI elements
	local order = 1
	local function getOrder()
		order = order + 1
		return order
	end

	-- HEADER
	addon.zoneSpecificArgsRef.header = {
		order = getOrder(),
		type = "header",
		name = "Mount Rules",
	}
	-- DESCRIPTION
	addon.zoneSpecificArgsRef.description = {
		order = getOrder(),
		type = "description",
		name =
				"Configure conditional mount summoning rules. Rules are evaluated in priority order (top to bottom), and the first matching rule is used.\n\n" ..
				"|cff00ffffSupported Rule Types:|r\n" ..
				"Location (map, instance, parent zone)\n" ..
				"Instance Type (dungeon, raid difficulty)\n" ..
				"Group State (in group, party, raid)\n" ..
				"Social (friends, specific players)\n" ..
				"Character Level (level comparisons)\n",
		fontSize = "medium",
	}
	-- CURRENT LOCATION INFO
	addon.zoneSpecificArgsRef.currentLocationHeader = {
		order = getOrder(),
		type = "header",
		name = "Current Location Information",
	}
	addon.zoneSpecificArgsRef.currentLocationInfo = {
		order = getOrder(),
		type = "description",
		name = function()
			local info = self:GetCurrentLocationInfo()
			local text = ""
			if info.mapName then
				text = text .. "|cff00ff00Map:|r " .. info.mapName .. " (ID: " .. info.mapID .. ")\n"
			end

			if info.parentName then
				text = text .. "|cff00ff00Parent Zone:|r " .. info.parentName .. " (ID: " .. info.parentID .. ")\n"
			end

			if info.instanceName then
				text = text .. "|cff00ff00Instance:|r " .. info.instanceName .. " (ID: " .. info.instanceID .. ")\n"
				text = text .. "|cff00ff00Type:|r " .. info.instanceTypeName
			end

			if text == "" then
				text = "|cffff9900Not in a valid location|r"
			end

			return text
		end,
		fontSize = "medium",
	}
	-- RULE CREATION SECTION
	addon.zoneSpecificArgsRef.newRuleHeader = {
		order = getOrder(),
		type = "header",
		name = "Add New Rule",
	}
	-- ROW 1: Rule Type and Action Type
	addon.zoneSpecificArgsRef.newRuleType = {
		order = getOrder(),
		type = "select",
		name = "Rule Type",
		desc = "What condition triggers this rule?",
		width = 1.4,
		values = {
			location = "Location",
			instance_type = "Instance Type",
			group_state = "Group State",
			social = "Social",
			character_level = "Character Level",
		},
		sorting = {
			"location",
			"instance_type",
			"group_state",
			"social",
			"character_level",
		},
		get = function()
			return addon.MountRules_TempRuleType
		end,
		set = function(info, value)
			addon.MountRules_TempRuleType = value
			-- Clear other temp variables when changing rule type
			addon.MountRules_TempLocationID = nil
			addon.MountRules_TempLocationType = nil
			addon.MountRules_TempInstanceType = nil
			addon.MountRules_TempGroupState = nil
			addon.MountRules_TempSocialType = nil
			addon.MountRules_TempCharacterNames = nil
			addon.MountRules_TempLevelOperator = nil
			addon.MountRules_TempLevel = nil
			self:PopulateZoneSpecificUI()
		end,
	}
	addon.zoneSpecificArgsRef.newActionType = {
		order = getOrder(),
		type = "select",
		name = "Action",
		desc = "What should happen when this rule matches?",
		width = 1.4,
		values = {
			specific = "Summon Specific Mount(s)",
			pool = "Use Specific Pool",
		},
		get = function()
			return addon.MountRules_TempActionType
		end,
		set = function(info, value)
			addon.MountRules_TempActionType = value
			-- Clear action-related temp variables
			addon.MountRules_TempMountID = nil
			addon.MountRules_TempPoolName = nil
			addon.MountRules_TempLevelOperator = nil
			addon.MountRules_TempLevel = nil
			addon.MountRules_TempModifierCombo = nil
			self:PopulateZoneSpecificUI()
		end,
	}
	-- Spacer to force new row
	addon.zoneSpecificArgsRef.spacer1 = {
		order = getOrder(),
		type = "description",
		name = "",
		width = "full",
	}
	-- ROW 2: Condition-specific fields (varies by rule type)
	if addon.MountRules_TempRuleType == "location" then
		-- Location ID input
		addon.zoneSpecificArgsRef.newLocationID = {
			order = getOrder(),
			type = "input",
			name = "Location ID",
			desc = "Enter the map ID, instance ID, or parent zone ID",
			width = 0.8,
			get = function()
				return tostring(addon.MountRules_TempLocationID or "")
			end,
			set = function(info, value)
				addon.MountRules_TempLocationID = tonumber(value)
			end,
		}
		-- Location type dropdown
		addon.zoneSpecificArgsRef.newLocationType = {
			order = getOrder(),
			type = "select",
			name = "ID Type",
			desc = "What type of location ID is this?",
			width = 0.9,
			values = {
				mapid = "Map ID",
				instanceid = "Instance ID",
				parentzone = "Parent Zone ID",
			},
			get = function()
				return addon.MountRules_TempLocationType
			end,
			set = function(info, value)
				addon.MountRules_TempLocationType = value
			end,
		}
	elseif addon.MountRules_TempRuleType == "instance_type" then
		-- Instance type dropdown
		addon.zoneSpecificArgsRef.newInstanceType = {
			order = getOrder(),
			type = "select",
			name = "Instance Type",
			desc = "Select the instance difficulty type",
			width = 1.7,
			values = INSTANCE_TYPES,
			get = function()
				return addon.MountRules_TempInstanceType
			end,
			set = function(info, value)
				addon.MountRules_TempInstanceType = value
			end,
		}
	elseif addon.MountRules_TempRuleType == "group_state" then
		-- Group state dropdown
		addon.zoneSpecificArgsRef.newGroupState = {
			order = getOrder(),
			type = "select",
			name = "Group State",
			desc = "Select the group state condition",
			width = 1.7,
			values = {
				in_group = "In Any Group",
				not_in_group = "Not in Group",
				in_party = "In Party",
				not_in_party = "Not in Party",
				in_raid = "In Raid",
				not_in_raid = "Not in Raid",
			},
			sorting = {
				"in_group",
				"not_in_group",
				"in_party",
				"not_in_party",
				"in_raid",
				"not_in_raid",
			},
			get = function()
				return addon.MountRules_TempGroupState
			end,
			set = function(info, value)
				addon.MountRules_TempGroupState = value
			end,
		}
	elseif addon.MountRules_TempRuleType == "social" then
		-- Social type dropdown
		addon.zoneSpecificArgsRef.newSocialType = {
			order = getOrder(),
			type = "select",
			name = "Social Condition",
			desc = "Select the social condition",
			width = 1.2,
			values = {
				bnet_friend_in_party = "BNet Friend in Party",
				friend_in_party = "In-Game Friend in Party",
				character_whitelist = "Specific Players",
			},
			sorting = {
				"bnet_friend_in_party",
				"friend_in_party",
				"character_whitelist",
			},
			get = function()
				return addon.MountRules_TempSocialType
			end,
			set = function(info, value)
				addon.MountRules_TempSocialType = value
				if value ~= "character_whitelist" then
					addon.MountRules_TempCharacterNames = nil
				end

				self:PopulateZoneSpecificUI()
			end,
		}
		-- Character names input (only for character_whitelist)
		if addon.MountRules_TempSocialType == "character_whitelist" then
			addon.zoneSpecificArgsRef.newCharacterNames = {
				order = getOrder(),
				type = "input",
				name = "Character Names",
				desc = "Enter character names separated by semicolons (e.g., Name-Realm;Alt-Realm)",
				width = 2.5,
				multiline = true,
				get = function()
					return addon.MountRules_TempCharacterNames or ""
				end,
				set = function(info, value)
					addon.MountRules_TempCharacterNames = value
				end,
			}
		end
	elseif addon.MountRules_TempRuleType == "character_level" then
		-- Operator dropdown
		addon.zoneSpecificArgsRef.newLevelOperator = {
			order = getOrder(),
			type = "select",
			name = "Operator",
			desc = "Select the comparison operator",
			width = 0.7,
			values = {
				["="] = "Equals (=)",
				["<"] = "Less Than (<)",
				["<="] = "Less Than or Equal (<=)",
				[">"] = "Greater Than (>)",
				[">="] = "Greater Than or Equal (>=)",
			},
			sorting = {
				"=",
				"<",
				"<=",
				">",
				">=",
			},
			get = function()
				return addon.MountRules_TempLevelOperator
			end,
			set = function(info, value)
				addon.MountRules_TempLevelOperator = value
			end,
		}
		-- Level input
		addon.zoneSpecificArgsRef.newLevel = {
			order = getOrder(),
			type = "input",
			name = "Level",
			desc = "Enter the character level (1-80)",
			width = 0.7,
			get = function()
				return tostring(addon.MountRules_TempLevel or "")
			end,
			set = function(info, value)
				local num = tonumber(value)
				if num and num >= 1 and num <= 80 then
					addon.MountRules_TempLevel = num
				end
			end,
		}
	end

	-- Mount ID input (only if specific action selected)
	if addon.MountRules_TempActionType == "specific" then
		addon.zoneSpecificArgsRef.newMountID = {
			order = getOrder(),
			type = "input",
			name = "Mount ID(s)",
			desc = "Enter one or more mount IDs (separate with semicolons or commas for multiple mounts)",
			width = 1.4,
			get = function()
				return tostring(addon.MountRules_TempMountID or "")
			end,
			set = function(info, value)
				addon.MountRules_TempMountID = value
			end,
		}
	end

	-- Pool dropdown (only if pool selected)
	if addon.MountRules_TempActionType == "pool" then
		addon.zoneSpecificArgsRef.newPoolName = {
			order = getOrder(),
			type = "select",
			name = "Pool Name",
			desc = "Choose which pool to use",
			width = 1.4,
			values = {
				flying = "Flying Pool",
				ground = "Ground Only",
				groundUsable = "Ground + Flying",
				underwater = "Underwater Pool",
			},
			sorting = {
				"flying",
				"ground",
				"groundUsable",
				"underwater",
			},
			get = function()
				return addon.MountRules_TempPoolName
			end,
			set = function(info, value)
				addon.MountRules_TempPoolName = value
			end,
		}
	end

	-- SPACER to force new row
	addon.zoneSpecificArgsRef.spacer2 = {
		order = getOrder(),
		type = "description",
		name = "",
		width = "full",
	}
	-- ROW 3: Add button
	addon.zoneSpecificArgsRef.addButton = {
		order = getOrder(),
		type = "execute",
		name = "Add Rule",
		desc = "Add this rule to the list",
		width = "full",
		func = function()
			local ruleType = addon.MountRules_TempRuleType
			local actionType = addon.MountRules_TempActionType
			-- Validate basic fields
			if not ruleType then
				addon:AlwaysPrint("Please select a rule type")
				return
			end

			if not actionType then
				addon:AlwaysPrint("Please select an action")
				return
			end

			-- Build arguments based on rule type
			local args = {}
			if ruleType == "location" then
				local locationID = addon.MountRules_TempLocationID
				local locationType = addon.MountRules_TempLocationType
				if not locationID then
					addon:AlwaysPrint("Please enter a location ID")
					return
				end

				if not locationType then
					addon:AlwaysPrint("Please select an ID type")
					return
				end

				table.insert(args, locationID)
				table.insert(args, locationType)
			elseif ruleType == "instance_type" then
				local instanceType = addon.MountRules_TempInstanceType
				if not instanceType then
					addon:AlwaysPrint("Please select an instance type")
					return
				end

				table.insert(args, instanceType)
			elseif ruleType == "group_state" then
				local groupState = addon.MountRules_TempGroupState
				if not groupState then
					addon:AlwaysPrint("Please select a group state")
					return
				end

				table.insert(args, groupState)
			elseif ruleType == "social" then
				local socialType = addon.MountRules_TempSocialType
				if not socialType then
					addon:AlwaysPrint("Please select a social condition")
					return
				end

				table.insert(args, socialType)
				if socialType == "character_whitelist" then
					local charNames = addon.MountRules_TempCharacterNames
					if not charNames or charNames == "" then
						addon:AlwaysPrint("Please enter at least one character name")
						return
					end

					-- Parse character names
					local namesList = {}
					local cleanInput = charNames:gsub(",", ";")
					for name in cleanInput:gmatch("[^;]+") do
						local trimmed = name:match("^%s*(.-)%s*$")
						if trimmed ~= "" then
							table.insert(namesList, trimmed)
						end
					end

					if #namesList == 0 then
						addon:AlwaysPrint("Please enter at least one valid character name")
						return
					end

					table.insert(args, namesList)
				else
					table.insert(args, nil) -- No extra data for other social types
				end
			elseif ruleType == "character_level" then
				local operator = addon.MountRules_TempLevelOperator
				local level = addon.MountRules_TempLevel
				if not operator then
					addon:AlwaysPrint("Please select an operator")
					return
				end

				if not level then
					addon:AlwaysPrint("Please enter a level")
					return
				end

				table.insert(args, operator)
				table.insert(args, level)
			end

			-- Add action parameters
			if actionType == "specific" then
				local mountID = addon.MountRules_TempMountID
				if not mountID or mountID == "" then
					addon:AlwaysPrint("Please enter at least one mount ID")
					return
				end

				-- Parse mount IDs
				local mountIDList = {}
				local cleanInput = mountID:gsub(",", ";")
				for idStr in cleanInput:gmatch("[^;]+") do
					local trimmed = idStr:match("^%s*(.-)%s*$")
					local id = tonumber(trimmed)
					if id and id > 0 then
						table.insert(mountIDList, id)
					end
				end

				if #mountIDList == 0 then
					addon:AlwaysPrint("Please enter at least one valid mount ID")
					return
				end

				table.insert(args, mountIDList)
			elseif actionType == "pool" then
				local poolName = addon.MountRules_TempPoolName
				if not poolName then
					addon:AlwaysPrint("Please select a pool")
					return
				end

				table.insert(args, poolName)
			end

			-- Add the rule
			local success, message = self:AddRule(ruleType, actionType, unpack(args))
			if success then
				addon:AlwaysPrint(message)
				-- Clear temp variables
				addon.MountRules_TempRuleType = nil
				addon.MountRules_TempActionType = nil
				addon.MountRules_TempLocationID = nil
				addon.MountRules_TempLocationType = nil
				addon.MountRules_TempInstanceType = nil
				addon.MountRules_TempGroupState = nil
				addon.MountRules_TempSocialType = nil
				addon.MountRules_TempCharacterNames = nil
				addon.MountRules_TempLevelOperator = nil
				addon.MountRules_TempLevel = nil
				addon.MountRules_TempModifierCombo = nil
				addon.MountRules_TempMountID = nil
				addon.MountRules_TempPoolName = nil
				addon.MountRules_TempLevelOperator = nil
				addon.MountRules_TempLevel = nil
				addon.MountRules_TempModifierCombo = nil
				-- Refresh UI
				self:PopulateZoneSpecificUI()
			else
				addon:AlwaysPrint("Error: " .. message)
			end
		end,
	}
	-- LIST OF EXISTING RULES
	addon.zoneSpecificArgsRef.existingRulesHeader = {
		order = getOrder(),
		type = "header",
		name = "Existing Rules (Priority Order)",
	}
	local rules = self:GetAllRules()
	if #rules == 0 then
		addon.zoneSpecificArgsRef.noRules = {
			order = getOrder(),
			type = "description",
			name = "|cff888888No rules configured yet.|r",
		}
	else
		for i, rule in ipairs(rules) do
			local ruleKey = "rule_" .. rule.id
			local ruleName = rule.locationName or rule.instanceTypeName or rule.groupStateName or rule.socialTypeName or
					"Unknown"
			addon.zoneSpecificArgsRef[ruleKey] = {
				order = getOrder(),
				type = "group",
				name = "#" .. rule.priority .. " - " .. ruleName,
				inline = true,
				args = {
					description = {
						order = 1,
						type = "description",
						name = self:GetRuleDescription(rule),
						fontSize = "medium",
					},
					moveUpButton = {
						order = 2,
						type = "execute",
						name = "",
						desc = "Move up (higher priority)",
						width = 0.3,
						disabled = (i == 1),
						func = function()
							local success, message = self:MoveRuleUp(rule.id)
							if success then
								self:PopulateZoneSpecificUI()
							else
								addon:AlwaysPrint(message)
							end
						end,
						image = "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonUpLargev12",
						imageWidth = 50,
						imageHeight = 20,
					},
					moveDownButton = {
						order = 3,
						type = "execute",
						name = "",
						desc = "Move down (lower priority)",
						width = 0.3,
						disabled = (i == #rules),
						func = function()
							local success, message = self:MoveRuleDown(rule.id)
							if success then
								self:PopulateZoneSpecificUI()
							else
								addon:AlwaysPrint(message)
							end
						end,
						image = "Interface\\AddOns\\RandomMountBuddy\\Media\\128RedButtonDownLargev11",
						imageWidth = 50,
						imageHeight = 20,
					},
					removeButton = {
						order = 4,
						type = "execute",
						name = "Remove",
						desc = "Delete this rule",
						width = 0.5,
						func = function()
							local success, message = self:RemoveRule(rule.id)
							if success then
								addon:AlwaysPrint("Rule removed")
								self:PopulateZoneSpecificUI()
							else
								addon:AlwaysPrint("Error: " .. message)
							end
						end,
					},
				},
			}
		end
	end

	-- Refresh the UI
	if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
		LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
	end

	addon:DebugOptions("Mount Rules UI populated successfully")
end

-- ============================================================================
-- INITIALIZATION HOOK
-- ============================================================================
function addon:InitializeMountRules()
	if not self.MountRules then
		addon:DebugOptions("ERROR - MountRules not found!")
		return
	end

	self.MountRules:Initialize()
	-- Populate the UI after initialization
	if self.MountRules.PopulateZoneSpecificUI then
		self.MountRules:PopulateZoneSpecificUI()
	end

	addon:DebugOptions("MountRules integration complete")
end

addon:DebugCore("MountRules.lua END.")
return MountRules
