-- ZoneSpecificMounts.lua - Manager for zone-specific mount summoning rules
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("ZoneSpecificMounts.lua START.")
-- ============================================================================
-- ZONE SPECIFIC MOUNTS MANAGER CLASS
-- ============================================================================
local ZoneSpecificMounts = {}
addon.ZoneSpecificMounts = ZoneSpecificMounts
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
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function ZoneSpecificMounts:Initialize()
	addon:DebugOptions("Initializing Zone Specific Mounts Manager...")
	-- Initialize database structure if it doesn't exist
	if not addon.db.profile.zoneSpecificMounts then
		addon.db.profile.zoneSpecificMounts = {
			rules = {},
			nextRuleID = 1,
		}
	end

	-- Migrate old format if needed
	self:MigrateOldFormat()
	addon:DebugOptions("Zone Specific Mounts Manager initialized")
end

-- Migrate from old zone-keyed format to new priority-based format
function ZoneSpecificMounts:MigrateOldFormat()
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
-- ZONE RULE MANAGEMENT
-- ============================================================================
-- Add a new zone-specific mount rule
function ZoneSpecificMounts:AddRule(ruleType, actionType, locationID, locationType, instanceType, mountIDs, poolName)
	local data = addon.db.profile.zoneSpecificMounts
	-- Validate rule type
	if ruleType ~= "location" and ruleType ~= "instance_type" then
		return false, "Invalid rule type. Must be 'location' or 'instance_type'"
	end

	-- Validate action type
	if actionType ~= "specific" and actionType ~= "pool" then
		return false, "Invalid action type. Must be 'specific' or 'pool'"
	end

	-- Create the rule
	local rule = {
		id = data.nextRuleID,
		priority = #data.rules + 1,
		ruleType = ruleType,
		timestamp = time(),
		actionType = actionType,
	}
	-- Validate and set based on rule type
	if ruleType == "location" then
		if not locationID or locationID <= 0 then
			return false, "Invalid location ID"
		end

		if not locationType or (locationType ~= "mapid" and locationType ~= "instanceid" and locationType ~= "parentzone") then
			return false, "Invalid location type. Must be 'mapid', 'instanceid', or 'parentzone'"
		end

		rule.locationID = locationID
		rule.locationType = locationType
		-- Get location name
		if locationType == "mapid" or locationType == "parentzone" then
			local mapInfo = C_Map.GetMapInfo(locationID)
			rule.locationName = mapInfo and mapInfo.name or ("Location " .. locationID)
		elseif locationType == "instanceid" then
			local instanceName = EJ_GetInstanceInfo(locationID)
			rule.locationName = instanceName or ("Instance " .. locationID)
		end
	elseif ruleType == "instance_type" then
		if not instanceType then
			return false, "Instance type not specified"
		end

		if not INSTANCE_TYPES[instanceType] then
			return false, "Invalid instance type"
		end

		rule.instanceType = instanceType
		rule.instanceTypeName = INSTANCE_TYPES[instanceType]
	end

	-- Set action based on action type
	if actionType == "specific" then
		-- mountIDs should be an array now
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
	elseif actionType == "pool" then
		if not poolName or (poolName ~= "flying" and poolName ~= "ground" and poolName ~= "underwater" and poolName ~= "groundUsable") then
			return false, "Invalid pool name. Must be 'flying', 'ground', 'underwater', or 'groundUsable'"
		end

		rule.poolName = poolName
	end

	-- Add rule and increment ID
	table.insert(data.rules, rule)
	data.nextRuleID = data.nextRuleID + 1
	addon:DebugOptions("Added rule:", "Type:", ruleType, "Priority:", rule.priority)
	return true, "Rule added successfully"
end

-- Remove a rule by ID
function ZoneSpecificMounts:RemoveRule(ruleID)
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
function ZoneSpecificMounts:MoveRuleUp(ruleID)
	local data = addon.db.profile.zoneSpecificMounts
	for i, rule in ipairs(data.rules) do
		if rule.id == ruleID then
			if i == 1 then
				return false, "Rule is already at highest priority"
			end

			-- Swap with previous rule
			data.rules[i], data.rules[i - 1] = data.rules[i - 1], data.rules[i]
			-- Recalculate priorities
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
function ZoneSpecificMounts:MoveRuleDown(ruleID)
	local data = addon.db.profile.zoneSpecificMounts
	for i, rule in ipairs(data.rules) do
		if rule.id == ruleID then
			if i == #data.rules then
				return false, "Rule is already at lowest priority"
			end

			-- Swap with next rule
			data.rules[i], data.rules[i + 1] = data.rules[i + 1], data.rules[i]
			-- Recalculate priorities
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
function ZoneSpecificMounts:GetAllRules()
	return addon.db.profile.zoneSpecificMounts.rules or {}
end

-- ============================================================================
-- ZONE DETECTION & MOUNT SELECTION
-- ============================================================================
-- Check current location and instance against all rules
-- Returns first matching rule in priority order (top to bottom)
function ZoneSpecificMounts:GetMatchingRules()
	local data = addon.db.profile.zoneSpecificMounts
	if not data or not data.rules or #data.rules == 0 then
		return nil
	end

	-- Get current location info
	local mapID = C_Map.GetBestMapForUnit("player")
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID =
			GetInstanceInfo()
	local parentMapID = mapID and C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).parentMapID or nil
	-- Check rules in priority order (first match wins)
	for _, rule in ipairs(data.rules) do
		local matches = false
		if rule.ruleType == "location" then
			if rule.locationType == "mapid" and mapID == rule.locationID then
				matches = true
			elseif rule.locationType == "instanceid" and instanceID == rule.locationID then
				matches = true
			elseif rule.locationType == "parentzone" and parentMapID == rule.locationID then
				matches = true
			end
		elseif rule.ruleType == "instance_type" then
			-- Match instance type (difficulty)
			if difficultyID == rule.instanceType then
				matches = true
			end
		end

		if matches then
			addon:DebugSummon("Matched rule:", "ID:", rule.id, "Priority:", rule.priority, "Type:", rule.ruleType)
			return rule
		end
	end

	return nil
end

-- Get mount ID or pool based on matching rule
function ZoneSpecificMounts:GetMountForCurrentLocation()
	local rule = self:GetMatchingRules()
	if not rule then
		return nil, nil
	end

	addon:DebugSummon("Zone-specific rule found:", "Action:", rule.actionType)
	if rule.actionType == "specific" then
		-- Rule has multiple mount IDs - randomly select one
		if not rule.mountIDs or #rule.mountIDs == 0 then
			addon:DebugSummon("Rule has no mount IDs")
			return nil, nil
		end

		-- Build list of usable mounts
		local usableMounts = {}
		for _, mountID in ipairs(rule.mountIDs) do
			local mountName, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
			if isUsable then
				table.insert(usableMounts, mountID)
			end
		end

		if #usableMounts == 0 then
			addon:DebugSummon("None of the rule's mounts are usable")
			return nil, nil
		end

		-- Randomly select from usable mounts
		local selectedMount = usableMounts[math.random(#usableMounts)]
		addon:DebugSummon("Selected mount ID from rule:", selectedMount)
		return selectedMount, nil
	elseif rule.actionType == "pool" then
		-- Return pool name for selection
		return nil, rule.poolName
	end

	return nil, nil
end

-- ============================================================================
-- UI HELPER FUNCTIONS
-- ============================================================================
-- Get a human-readable description of a rule
function ZoneSpecificMounts:GetRuleDescription(rule)
	local desc = ""
	-- Rule match criteria
	if rule.ruleType == "location" then
		if rule.locationType == "mapid" then
			desc = "|cff00ffffMap:|r " .. (rule.locationName or "Unknown")
		elseif rule.locationType == "instanceid" then
			desc = "|cff00ffffInstance:|r " .. (rule.locationName or "Unknown")
		elseif rule.locationType == "parentzone" then
			desc = "|cff00ffffParent Zone:|r " .. (rule.locationName or "Unknown")
		end

		desc = desc .. " (ID: " .. rule.locationID .. ")"
	elseif rule.ruleType == "instance_type" then
		desc = "|cffff9900Instance Type:|r " .. (rule.instanceTypeName or "Unknown")
	end

	-- Action
	desc = desc .. "\n"
	if rule.actionType == "specific" then
		-- Handle both old single mountID and new mountIDs array
		local mountNames = {}
		if rule.mountIDs then
			-- New format: multiple mounts
			for i, name in ipairs(rule.mountNames or {}) do
				table.insert(mountNames, name)
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
			desc = desc .. "|cff00ff00Action:|r Summon " .. #mountNames .. " mounts:\n"
			for i, name in ipairs(mountNames) do
				desc = desc .. "  • " .. name
				if i < #mountNames then
					desc = desc .. "\n"
				end
			end
		end
	elseif rule.actionType == "pool" then
		local poolDisplayNames = {
			flying = "Flying Pool",
			ground = "Ground Only",
			underwater = "Underwater Pool",
			groundUsable = "Ground + Flying",
		}
		desc = desc .. "|cff00ff00Action:|r Use " .. (poolDisplayNames[rule.poolName] or rule.poolName)
	end

	return desc
end

-- Validate all rules (called during addon initialization or data refresh)
function ZoneSpecificMounts:ValidateRules()
	local rules = self:GetAllRules()
	local invalidRules = {}
	for _, rule in ipairs(rules) do
		local isValid = true
		local reason = ""
		if rule.actionType == "specific" then
			-- Check if any mounts still exist
			local validMounts = 0
			-- Handle both old and new formats
			if rule.mountIDs then
				-- New format: array of mount IDs
				for _, mountID in ipairs(rule.mountIDs) do
					local mountName = C_MountJournal.GetMountInfoByID(mountID)
					if mountName then
						validMounts = validMounts + 1
					end
				end
			elseif rule.mountID then
				-- Old format: single mount ID
				local mountName = C_MountJournal.GetMountInfoByID(rule.mountID)
				if mountName then
					validMounts = 1
				end
			end

			if validMounts == 0 then
				isValid = false
				reason = "No valid mounts in rule"
			end
		end

		if not isValid then
			table.insert(invalidRules, {
				id = rule.id,
				reason = reason,
			})
		end
	end

	return invalidRules
end

-- Clean up invalid rules
function ZoneSpecificMounts:CleanupInvalidRules()
	local invalidRules = self:ValidateRules()
	local removedCount = 0
	for _, invalidRule in ipairs(invalidRules) do
		self:RemoveRule(invalidRule.id)
		removedCount = removedCount + 1
		addon:DebugOptions("Removed invalid rule ID:", invalidRule.id, "-", invalidRule.reason)
	end

	return removedCount
end

-- Get current location info for display
function ZoneSpecificMounts:GetCurrentLocationInfo()
	local mapID = C_Map.GetBestMapForUnit("player")
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID =
			GetInstanceInfo()
	local info = {}
	if mapID then
		local mapInfo = C_Map.GetMapInfo(mapID)
		if mapInfo then
			info.mapName = mapInfo.name
			info.mapID = mapID
			if mapInfo.parentMapID and mapInfo.parentMapID > 0 then
				local parentInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
				if parentInfo then
					info.parentName = parentInfo.name
					info.parentID = mapInfo.parentMapID
				end
			end
		end
	end

	if instanceID and instanceID ~= 0 then
		info.instanceName = instanceName
		info.instanceID = instanceID
		info.instanceType = difficultyID
		info.instanceTypeName = INSTANCE_TYPES[difficultyID] or "Unknown"
	end

	return info
end

-- ============================================================================
-- UI BUILDING FUNCTIONS
-- ============================================================================
-- Populate the Zone-Specific Mounts UI
function ZoneSpecificMounts:PopulateZoneSpecificUI()
	addon:DebugOptions("Populating Zone-Specific Mounts UI...")
	-- Clear existing args
	for k in pairs(addon.zoneSpecificArgsRef) do
		addon.zoneSpecificArgsRef[k] = nil
	end

	local order = 0
	local function getOrder()
		order = order + 1
		return order
	end

	-- Header and description
	addon.zoneSpecificArgsRef.header = {
		order = getOrder(),
		type = "header",
		name = "Zone-Specific Mount Rules",
	}
	addon.zoneSpecificArgsRef.description = {
		order = getOrder(),
		type = "description",
		name = "|cffffd700Zone-Specific Mount Rules|r\n\n" ..
				"Rules are checked from top to bottom. First matching rule wins.\n\n" ..
				"|cff00ff00Multiple Mounts:|r Enter multiple mount IDs separated by semicolons (e.g., 1792;1234;5678) to randomly pick from that list.",
		fontSize = "medium",
	}
	-- Current location info
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
	-- Add Rule Section
	addon.zoneSpecificArgsRef.addRuleHeader = {
		order = getOrder(),
		type = "header",
		name = "Add New Rule",
	}
	-- ROW 1: Location type and conditional location/instance fields
	addon.zoneSpecificArgsRef.newRuleType = {
		order = getOrder(),
		type = "select",
		name = "Location Type",
		desc = "Choose how to match this rule",
		width = 1.4,
		values = {
			location = "Map/Parent Zone/Instance ID",
			instance_type = "Instance Type",
		},
		sorting = {
			"location",
			"instance_type",
		},
		get = function()
			return addon.ZoneSpecificMounts_TempRuleType
		end,
		set = function(info, value)
			addon.ZoneSpecificMounts_TempRuleType = value
			-- Rebuild the UI to show/hide conditional fields
			self:PopulateZoneSpecificUI()
		end,
	}
	-- LOCATION-BASED FIELDS (same row as rule type)
	if addon.ZoneSpecificMounts_TempRuleType == "location" then
		addon.zoneSpecificArgsRef.newLocationID = {
			order = getOrder(),
			type = "input",
			name = "Location ID",
			desc = "Enter Map ID, Instance ID, or Parent Zone ID",
			width = 0.7,
			get = function()
				return tostring(addon.ZoneSpecificMounts_TempLocationID or "")
			end,
			set = function(info, value)
				local id = tonumber(value)
				if id and id > 0 then
					addon.ZoneSpecificMounts_TempLocationID = id
				else
					addon.ZoneSpecificMounts_TempLocationID = nil
				end
			end,
		}
		addon.zoneSpecificArgsRef.newLocationType = {
			order = getOrder(),
			type = "select",
			name = "ID Type",
			desc = "What kind of ID is this?",
			width = 0.7,
			values = {
				mapid = "Map ID",
				parentzone = "Parent Zone ID",
				instanceid = "Instance ID",
			},
			sorting = {
				"mapid",
				"parentzone",
				"instanceid",
			},
			get = function()
				return addon.ZoneSpecificMounts_TempLocationType
			end,
			set = function(info, value)
				addon.ZoneSpecificMounts_TempLocationType = value
			end,
		}
	end

	-- INSTANCE TYPE FIELDS (same row as rule type)
	if addon.ZoneSpecificMounts_TempRuleType == "instance_type" then
		-- Build instance type values and sorting
		local instanceTypeValues = {}
		local instanceTypeSorting = {}
		for id, name in pairs(INSTANCE_TYPES) do
			instanceTypeValues[id] = name
			table.insert(instanceTypeSorting, id)
		end

		-- Sort by ID number
		table.sort(instanceTypeSorting)
		addon.zoneSpecificArgsRef.newInstanceType = {
			order = getOrder(),
			type = "select",
			name = "Instance Type",
			desc = "Choose instance difficulty/type",
			width = 1.4,
			values = instanceTypeValues,
			sorting = instanceTypeSorting,
			get = function()
				return addon.ZoneSpecificMounts_TempInstanceType
			end,
			set = function(info, value)
				addon.ZoneSpecificMounts_TempInstanceType = value
			end,
		}
	end

	-- SPACER to force new row
	addon.zoneSpecificArgsRef.spacer1 = {
		order = getOrder(),
		type = "description",
		name = "",
		width = "full",
	}
	-- ROW 2: Action type and conditional mount/pool fields
	addon.zoneSpecificArgsRef.newActionType = {
		order = getOrder(),
		type = "select",
		name = "Action",
		desc = "What to summon when rule matches",
		width = 1.4,
		values = {
			specific = "Specific Mount",
			pool = "Specific Pool",
		},
		sorting = {
			"specific",
			"pool",
		},
		get = function()
			return addon.ZoneSpecificMounts_TempActionType
		end,
		set = function(info, value)
			addon.ZoneSpecificMounts_TempActionType = value
			-- Rebuild to show/hide conditional fields
			self:PopulateZoneSpecificUI()
		end,
	}
	-- Mount ID input (only if specific mount selected)
	if addon.ZoneSpecificMounts_TempActionType == "specific" then
		addon.zoneSpecificArgsRef.newMountID = {
			order = getOrder(),
			type = "input",
			name = "Mount ID(s)",
			desc = "Enter mount ID(s). Use semicolons to separate multiple: 1792;1234;5678",
			width = 1.4,
			get = function()
				return tostring(addon.ZoneSpecificMounts_TempMountID or "")
			end,
			set = function(info, value)
				-- Store the raw string (will be parsed when adding rule)
				addon.ZoneSpecificMounts_TempMountID = value
			end,
		}
	end

	-- Pool dropdown (only if pool selected, same row as action type)
	if addon.ZoneSpecificMounts_TempActionType == "pool" then
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
				return addon.ZoneSpecificMounts_TempPoolName
			end,
			set = function(info, value)
				addon.ZoneSpecificMounts_TempPoolName = value
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
	-- ROW 3: Add button alone
	addon.zoneSpecificArgsRef.addButton = {
		order = getOrder(),
		type = "execute",
		name = "Add Rule",
		desc = "Add this rule to the list",
		width = "full",
		func = function()
			local ruleType = addon.ZoneSpecificMounts_TempRuleType
			local actionType = addon.ZoneSpecificMounts_TempActionType
			local locationID = addon.ZoneSpecificMounts_TempLocationID
			local locationType = addon.ZoneSpecificMounts_TempLocationType
			local instanceType = addon.ZoneSpecificMounts_TempInstanceType
			local mountID = addon.ZoneSpecificMounts_TempMountID
			local poolName = addon.ZoneSpecificMounts_TempPoolName
			-- Validate
			if not ruleType then
				addon:AlwaysPrint("Please select a rule type")
				return
			end

			if ruleType == "location" then
				if not locationID then
					addon:AlwaysPrint("Please enter a location ID")
					return
				end

				if not locationType then
					addon:AlwaysPrint("Please select an ID type")
					return
				end
			elseif ruleType == "instance_type" then
				if not instanceType then
					addon:AlwaysPrint("Please select an instance type")
					return
				end
			end

			if not actionType then
				addon:AlwaysPrint("Please select an action")
				return
			end

			if actionType == "specific" then
				if not mountID or mountID == "" then
					addon:AlwaysPrint("Please enter at least one mount ID")
					return
				end

				-- Parse semicolon or comma-separated mount IDs
				local mountIDList = {}
				-- Replace commas with semicolons for consistent parsing
				local cleanInput = mountID:gsub(",", ";")
				-- Split on semicolons
				for idStr in cleanInput:gmatch("[^;]+") do
					-- Trim whitespace and convert to number
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

				mountID = mountIDList
			end

			if actionType == "pool" and not poolName then
				addon:AlwaysPrint("Please select a pool")
				return
			end

			-- For specific mounts, mountID is already an array from parsing
			-- For pools, it's nil
			local success, message = self:AddRule(
				ruleType, actionType, locationID, locationType,
				instanceType, mountID, poolName
			)
			if success then
				addon:AlwaysPrint(message)
				-- Clear temp variables
				addon.ZoneSpecificMounts_TempRuleType = nil
				addon.ZoneSpecificMounts_TempActionType = nil
				addon.ZoneSpecificMounts_TempLocationID = nil
				addon.ZoneSpecificMounts_TempLocationType = nil
				addon.ZoneSpecificMounts_TempInstanceType = nil
				addon.ZoneSpecificMounts_TempMountID = nil
				addon.ZoneSpecificMounts_TempPoolName = nil
				-- Refresh UI
				self:PopulateZoneSpecificUI()
			else
				addon:AlwaysPrint("Error: " .. message)
			end
		end,
	}
	-- List of existing rules
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
			addon.zoneSpecificArgsRef[ruleKey] = {
				order = getOrder(),
				type = "group",
				name = "#" .. rule.priority .. " - " .. (rule.locationName or rule.instanceTypeName or "Unknown"),
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

	addon:DebugOptions("Zone-Specific Mounts UI populated successfully")
end

function addon:InitializeZoneSpecificMounts()
	if not self.ZoneSpecificMounts then
		addon:DebugOptions("ERROR - ZoneSpecificMounts not found!")
		return
	end

	self.ZoneSpecificMounts:Initialize()
	-- Populate the UI after initialization
	if self.ZoneSpecificMounts.PopulateZoneSpecificUI then
		self.ZoneSpecificMounts:PopulateZoneSpecificUI()
	end

	addon:DebugOptions("ZoneSpecificMounts integration complete")
end

addon:DebugCore("ZoneSpecificMounts.lua END.")
return ZoneSpecificMounts
