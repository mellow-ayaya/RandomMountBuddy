-- FilterSystem.lua - Advanced Mount Filtering System.
-- Handles comprehensive filtering for mount groups and individual mounts
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("FilterSystem.lua START.")
-- ============================================================================
-- FILTER SYSTEM CLASS
-- ============================================================================
local FilterSystem = {}
addon.FilterSystem = FilterSystem
-- ============================================================================
-- FILTER DEFINITIONS AND CONSTANTS
-- ============================================================================
FilterSystem.MOUNT_SOURCES = {
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
FilterSystem.MOUNT_TYPES = {
	"Ground",
	"Steady Flight",
	"Skyriding",
	"Aquatic",
}
FilterSystem.MOUNT_TRAITS = {
	"hasMinorArmor",
	"hasMajorArmor",
	"hasModelVariant",
	"isUniqueEffect",
	"noTraits", -- Added for families with no traits
}
FilterSystem.SUMMON_CHANCES = {
	"Never",
	"Occasional",
	"Uncommon",
	"Normal",
	"Common",
	"Often",
	"Always",
}
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function FilterSystem:Initialize()
	addon:DebugUI("Initializing filter system...")
	-- Try to initialize database immediately if possible
	if addon.db and addon.db.profile then
		self:InitializeFilterDatabase()
	else
		addon:DebugUI("Database not ready during init, will initialize later")
	end

	-- Filter state tracking
	self.filtersActive = false
	self.lastFilteredResults = {}
	addon:DebugUI("Filter system initialized")
end

function FilterSystem:InitializeFilterDatabase()
	if not addon.db or not addon.db.profile then
		addon:DebugUI("Database not ready, deferring filter DB init")
		return false
	end

	if not addon.db.profile.filterSettings then
		addon:DebugUI("Creating new filter settings structure")
		addon.db.profile.filterSettings = {
			mountSources = {},
			mountTypes = {},
			mountTraits = {},
			summonChances = {},
			-- Note: showUncollected uses the existing addon setting, not stored here
		}
		-- Initialize all filters as DISABLED by default (unchecked)
		for sourceId, sourceName in pairs(self.MOUNT_SOURCES) do
			addon.db.profile.filterSettings.mountSources[sourceId] = false
		end

		for _, typeName in ipairs(self.MOUNT_TYPES) do
			addon.db.profile.filterSettings.mountTypes[typeName] = false
		end

		for _, traitName in ipairs(self.MOUNT_TRAITS) do
			addon.db.profile.filterSettings.mountTraits[traitName] = false
		end

		for _, chanceName in ipairs(self.SUMMON_CHANCES) do
			addon.db.profile.filterSettings.summonChances[chanceName] = false
		end

		addon:DebugUI("Initialized default filter settings (all disabled)")
	else
		addon:DebugUI("Filter settings already exist")
	end

	return true
end

-- ============================================================================
-- FILTER STATE MANAGEMENT
-- ============================================================================
function FilterSystem:GetFilterSetting(category, key)
	if not addon.db or not addon.db.profile or not addon.db.profile.filterSettings then
		return false -- Default to disabled if DB not ready
	end

	local categorySettings = addon.db.profile.filterSettings[category]
	if not categorySettings then
		return false
	end

	-- Additional safety check - make sure categorySettings is a table
	if type(categorySettings) ~= "table" then
		addon:DebugUI("Category " ..
			category .. " is not a table (it's " .. type(categorySettings) .. "), returning false")
		return false
	end

	local value = categorySettings[key]
	if value == nil then
		return false -- Default to disabled if not set
	end

	return value
end

function FilterSystem:SetFilterSetting(category, key, value)
	if not addon.db or not addon.db.profile then
		addon:DebugUI("Cannot save filter setting - database not ready")
		return
	end

	self:InitializeFilterDatabase()
	if not addon.db.profile.filterSettings[category] then
		addon.db.profile.filterSettings[category] = {}
	end

	-- Additional safety check - make sure the category is a table
	if type(addon.db.profile.filterSettings[category]) ~= "table" then
		addon:DebugFilter("Category " .. category .. " is not a table, recreating it")
		addon.db.profile.filterSettings[category] = {}
	end

	addon.db.profile.filterSettings[category][key] = value
	addon:DebugUI("Set " .. category .. "[" .. tostring(key) .. "] = " .. tostring(value))
	-- Trigger filter refresh
	self:ApplyFilters()
end

function FilterSystem:AreFiltersActive()
	if not addon.db or not addon.db.profile or not addon.db.profile.filterSettings then
		return false
	end

	local settings = addon.db.profile.filterSettings
	-- Check if any filter category has enabled filters
	for sourceId, _ in pairs(self.MOUNT_SOURCES) do
		local sourceSetting = settings.mountSources and settings.mountSources[sourceId]
		if sourceSetting == true then
			return true
		end
	end

	for _, typeName in ipairs(self.MOUNT_TYPES) do
		local typeSetting = settings.mountTypes and settings.mountTypes[typeName]
		if typeSetting == true then
			return true
		end
	end

	for _, traitName in ipairs(self.MOUNT_TRAITS) do
		local traitSetting = settings.mountTraits and settings.mountTraits[traitName]
		if traitSetting == true then
			return true
		end
	end

	for _, chanceName in ipairs(self.SUMMON_CHANCES) do
		local chanceSetting = settings.summonChances and settings.summonChances[chanceName]
		if chanceSetting == true then
			return true
		end
	end

	return false
end

-- ============================================================================
-- MOUNT FILTERING LOGIC
-- ============================================================================
function FilterSystem:MountPassesFilters(mountID, mountInfo, isUncollected)
	if not self:AreFiltersActive() then
		return true
	end

	-- Check uncollected setting first - use the existing addon setting directly
	if isUncollected and not addon:GetSetting("showUncollectedMounts") then
		return false
	end

	-- Get mount details for filtering
	local name, _, _, _, isUsable, sourceType = C_MountJournal.GetMountInfoByID(mountID)
	if not name then
		return false
	end

	-- Check if source category has any enabled filters
	local sourceFiltersActive = self:CategoryHasEnabledFilters("mountSources")
	if sourceFiltersActive then
		-- If source filters are active, mount must match at least one enabled source
		if not sourceType or not self:GetFilterSetting("mountSources", sourceType) then
			return false
		end
	end

	-- Check mount type filters
	local typeFiltersActive = self:CategoryHasEnabledFilters("mountTypes")
	if typeFiltersActive then
		if not self:MountPassesTypeFilters(mountID) then
			return false
		end
	end

	-- Check trait filters
	local traitFiltersActive = self:CategoryHasEnabledFilters("mountTraits")
	if traitFiltersActive then
		if not self:MountPassesTraitFilters(mountInfo) then
			return false
		end
	end

	-- Check summon chance filters
	local chanceFiltersActive = self:CategoryHasEnabledFilters("summonChances")
	if chanceFiltersActive then
		if not self:MountPassesSummonChanceFilters(mountID, mountInfo) then
			return false
		end
	end

	return true
end

-- Helper function to check if a category has any enabled filters
function FilterSystem:CategoryHasEnabledFilters(category)
	if not addon.db or not addon.db.profile or not addon.db.profile.filterSettings then
		return false
	end

	local categorySettings = addon.db.profile.filterSettings[category]
	if not categorySettings or type(categorySettings) ~= "table" then
		return false
	end

	-- Check if any filter in this category is enabled
	for key, value in pairs(categorySettings) do
		if value == true then
			return true
		end
	end

	return false
end

function FilterSystem:MountPassesTypeFilters(mountID)
	-- Get mount type capabilities
	local typeTraits = addon.MountSummon and addon.MountSummon:GetMountTypeTraits(mountID)
	if not typeTraits then
		return false -- If we can't determine type, filter it out when type filters are active
	end

	-- Check if mount matches any enabled type filter (OR logic within category)
	local matchesAnyEnabledType = false
	-- Check Ground
	if typeTraits.isGround and self:GetFilterSetting("mountTypes", "Ground") then
		matchesAnyEnabledType = true
	end

	-- Check Steady Flight
	if typeTraits.isSteadyFly and self:GetFilterSetting("mountTypes", "Steady Flight") then
		matchesAnyEnabledType = true
	end

	-- Check Skyriding
	if typeTraits.isSkyriding and self:GetFilterSetting("mountTypes", "Skyriding") then
		matchesAnyEnabledType = true
	end

	-- Check Aquatic
	if typeTraits.isAquatic and self:GetFilterSetting("mountTypes", "Aquatic") then
		matchesAnyEnabledType = true
	end

	return matchesAnyEnabledType
end

function FilterSystem:MountPassesTraitFilters(mountInfo)
	if not mountInfo then
		-- If no mount info, check if "noTraits" filter is enabled
		return self:GetFilterSetting("mountTraits", "noTraits")
	end

	local traits = mountInfo.traits or {}
	-- Check if mount matches any enabled trait filter (OR logic within category)
	local matchesAnyEnabledTrait = false
	-- Check specific traits
	for _, traitName in ipairs({ "hasMinorArmor", "hasMajorArmor", "hasModelVariant", "isUniqueEffect" }) do
		if traits[traitName] and self:GetFilterSetting("mountTraits", traitName) then
			matchesAnyEnabledTrait = true
			break
		end
	end

	-- Check "no traits" - mount has no traits and "noTraits" filter is enabled
	if not matchesAnyEnabledTrait then
		local hasAnyTrait = traits.hasMinorArmor or traits.hasMajorArmor or traits.hasModelVariant or traits.isUniqueEffect
		if not hasAnyTrait and self:GetFilterSetting("mountTraits", "noTraits") then
			matchesAnyEnabledTrait = true
		end
	end

	return matchesAnyEnabledTrait
end

function FilterSystem:MountPassesSummonChanceFilters(mountID, mountInfo)
	local groupKey = "mount_" .. mountID
	local mountWeight = addon:GetGroupWeight(groupKey)
	-- If mount has no specific weight, use family weight
	if mountWeight == 0 and mountInfo and mountInfo.familyName then
		mountWeight = addon:GetGroupWeight(mountInfo.familyName)
	end

	-- Map weight to chance name
	local weightToChanceMap = {
		[0] = "Never",
		[1] = "Occasional",
		[2] = "Uncommon",
		[3] = "Normal",
		[4] = "Common",
		[5] = "Often",
		[6] = "Always",
	}
	local chanceName = weightToChanceMap[mountWeight] or "Normal"
	-- Check if this mount's chance matches any enabled chance filter (OR logic within category)
	return self:GetFilterSetting("summonChances", chanceName)
end

-- ============================================================================
-- GROUP FILTERING LOGIC
-- ============================================================================
function FilterSystem:GroupPassesFilters(groupData)
	if not self:AreFiltersActive() then
		return true
	end

	local groupKey = groupData.key
	local groupType = groupData.type
	-- For groups, check if they contain any mounts that pass filters
	-- OR if the group itself has a weight that matches active summon chance filters
	if groupType == "familyName" then
		return self:FamilyPassesFilters(groupKey)
	elseif groupType == "superGroup" then
		return self:SuperGroupPassesFilters(groupKey)
	end

	return true
end

function FilterSystem:FamilyPassesFilters(familyName)
	-- Check if summon chance filters are active
	local chanceFiltersActive = self:CategoryHasEnabledFilters("summonChances")
	if chanceFiltersActive then
		-- First check if the family itself matches any enabled summon chance filter
		-- This ensures families with specific weights show up even if their mounts have different weights
		local familyWeight = addon:GetGroupWeight(familyName)
		local weightToChanceMap = {
			[0] = "Never",
			[1] = "Occasional",
			[2] = "Uncommon",
			[3] = "Normal",
			[4] = "Common",
			[5] = "Often",
			[6] = "Always",
		}
		local familyChanceName = weightToChanceMap[familyWeight] or "Normal"
		-- If family weight matches an enabled filter, family passes regardless of individual mounts
		if self:GetFilterSetting("summonChances", familyChanceName) then
			return true
		end
	end

	-- Check collected mounts
	local mountIDs = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[familyName] or {}
	for _, mountID in ipairs(mountIDs) do
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
		if mountInfo and self:MountPassesFilters(mountID, mountInfo, false) then
			return true
		end
	end

	-- Check uncollected mounts if showing uncollected
	if addon:GetSetting("showUncollectedMounts") then
		local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[familyName] or {}
		for _, mountID in ipairs(uncollectedIDs) do
			local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
			if mountInfo and self:MountPassesFilters(mountID, mountInfo, true) then
				return true
			end
		end
	end

	return false
end

function FilterSystem:SuperGroupPassesFilters(superGroupName)
	-- Check if summon chance filters are active
	local chanceFiltersActive = self:CategoryHasEnabledFilters("summonChances")
	if chanceFiltersActive then
		-- First check if the supergroup itself matches any enabled summon chance filter
		-- This ensures supergroups with specific weights show up even if their families/mounts have different weights
		local superGroupWeight = addon:GetGroupWeight(superGroupName)
		local weightToChanceMap = {
			[0] = "Never",
			[1] = "Occasional",
			[2] = "Uncommon",
			[3] = "Normal",
			[4] = "Common",
			[5] = "Often",
			[6] = "Always",
		}
		local superGroupChanceName = weightToChanceMap[superGroupWeight] or "Normal"
		-- If supergroup weight matches an enabled filter, supergroup passes regardless of families/mounts
		if self:GetFilterSetting("summonChances", superGroupChanceName) then
			return true
		end
	end

	-- Get families in this supergroup
	local familyNames = addon.processedData.dynamicSuperGroupMap and
			addon.processedData.dynamicSuperGroupMap[superGroupName] or
			(addon.processedData.superGroupMap and addon.processedData.superGroupMap[superGroupName]) or {}
	-- Check if any family in the supergroup passes filters
	for _, familyName in ipairs(familyNames) do
		if self:FamilyPassesFilters(familyName) then
			return true
		end
	end

	return false
end

-- ============================================================================
-- FILTER APPLICATION
-- ============================================================================
function FilterSystem:ApplyFilters()
	self.filtersActive = self:AreFiltersActive()
	-- Trigger UI refresh
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
		addon:DebugUI("UI refresh triggered after filter change")
	end
end

function FilterSystem:GetFilteredGroups(allGroups)
	if not self:AreFiltersActive() then
		return allGroups
	end

	local filteredGroups = {}
	for i, groupData in ipairs(allGroups or {}) do
		if self:GroupPassesFilters(groupData) then
			table.insert(filteredGroups, groupData)
		end
	end

	addon:DebugUI("Filtered " .. #allGroups .. " groups down to " .. #filteredGroups)
	return filteredGroups
end

-- ============================================================================
-- FILTER RESET FUNCTIONALITY
-- ============================================================================
function FilterSystem:ResetAllFilters()
	if not addon.db or not addon.db.profile then
		return
	end

	-- Reset all filters to disabled state (unchecked)
	local settings = addon.db.profile.filterSettings
	for sourceId, _ in pairs(self.MOUNT_SOURCES) do
		settings.mountSources[sourceId] = false
	end

	for _, typeName in ipairs(self.MOUNT_TYPES) do
		settings.mountTypes[typeName] = false
	end

	for _, traitName in ipairs(self.MOUNT_TRAITS) do
		settings.mountTraits[traitName] = false
	end

	for _, chanceName in ipairs(self.SUMMON_CHANCES) do
		settings.summonChances[chanceName] = false
	end

	addon:DebugUI("Reset all filters")
	self:ApplyFilters()
end

-- ============================================================================
-- UI HELPER FUNCTIONS
-- ============================================================================
function FilterSystem:GetFilterStatus()
	if not self:AreFiltersActive() then
		return nil
	end

	local activeFilters = {}
	-- Collect active source filters
	local activeSources = {}
	for sourceId, sourceName in pairs(self.MOUNT_SOURCES) do
		if self:GetFilterSetting("mountSources", sourceId) then
			table.insert(activeSources, sourceName)
		end
	end

	if #activeSources > 0 then
		table.insert(activeFilters, table.concat(activeSources, ", "))
	end

	-- Collect active type filters
	local activeTypes = {}
	for _, typeName in ipairs(self.MOUNT_TYPES) do
		if self:GetFilterSetting("mountTypes", typeName) then
			table.insert(activeTypes, typeName)
		end
	end

	if #activeTypes > 0 then
		table.insert(activeFilters, table.concat(activeTypes, ", "))
	end

	-- Collect active trait filters
	local activeTraits = {}
	local traitLabels = {
		hasMinorArmor = "Minor Armor",
		hasMajorArmor = "Major Armor",
		hasModelVariant = "Model Variant",
		isUniqueEffect = "Unique Effect",
		noTraits = "No Traits",
	}
	for _, traitName in ipairs(self.MOUNT_TRAITS) do
		if self:GetFilterSetting("mountTraits", traitName) then
			table.insert(activeTraits, traitLabels[traitName] or traitName)
		end
	end

	if #activeTraits > 0 then
		table.insert(activeFilters, table.concat(activeTraits, ", "))
	end

	-- Collect active chance filters
	local activeChances = {}
	for _, chanceName in ipairs(self.SUMMON_CHANCES) do
		if self:GetFilterSetting("summonChances", chanceName) then
			table.insert(activeChances, chanceName)
		end
	end

	if #activeChances > 0 then
		table.insert(activeFilters, table.concat(activeChances, ", "))
	end

	-- Build final status string - show as much detail as possible
	if #activeFilters > 0 then
		-- Just show everything, let the UI handle wrapping
		return "filtering by: " .. table.concat(activeFilters, "; ")
	end

	return nil
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================
function FilterSystem:OnDataReady()
	addon:DebugUI("Data ready, initializing filter database")
	local success = self:InitializeFilterDatabase()
	if not success then
		addon:DebugUI("Filter database initialization failed - will retry later")
	end
end

function FilterSystem:OnSettingChanged(key, value)
	-- Handle setting changes that might affect filters
	if key == "showUncollectedMounts" then
		-- The uncollected mount setting changed, trigger filter refresh
		self:ApplyFilters()
	end
end

-- ============================================================================
-- INTEGRATION WITH CORE ADDON
-- ============================================================================
function addon:InitializeFilterSystem()
	if not self.FilterSystem then
		addon:DebugUI("ERROR - FilterSystem not found!")
		return
	end

	self.FilterSystem:Initialize()
	addon:DebugUI("Integration complete")
end

-- Public interface methods for other modules
function addon:ApplyFilters()
	if self.FilterSystem then
		self.FilterSystem:ApplyFilters()
	end
end

function addon:AreFiltersActive()
	return self.FilterSystem and self.FilterSystem:AreFiltersActive() or false
end

function addon:GetFilteredGroups(allGroups)
	if self.FilterSystem then
		return self.FilterSystem:GetFilteredGroups(allGroups)
	end

	return allGroups
end

function addon:GetFilterStatus()
	return self.FilterSystem and self.FilterSystem:GetFilterStatus() or nil
end

function addon:ResetAllFilters()
	if self.FilterSystem then
		self.FilterSystem:ResetAllFilters()
	end
end

addon:DebugCore("FilterSystem.lua END.")
