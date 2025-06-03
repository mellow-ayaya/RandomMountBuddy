-- ConfigurationManager.lua - Import/Export and Data Validation
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("ConfigurationManager.lua START.")
-- ============================================================================
-- CONFIGURATION MANAGER CLASS
-- ============================================================================
local ConfigurationManager = {}
addon.ConfigurationManager = ConfigurationManager
-- Initialize the Configuration Manager
function ConfigurationManager:Initialize()
	addon:DebugSupergr("Initializing Configuration Manager...")
	-- Initialize validation system
	self.lastValidationReport = nil
	addon:DebugSupergr("Configuration Manager initialized")
end

-- ============================================================================
-- IMPORT/EXPORT OPERATIONS
-- ============================================================================
-- Export current supergroup configuration
function ConfigurationManager:ExportConfiguration()
	local config = {
		version = "1.1", -- Bumped version to indicate separated mounts support
		timestamp = time(),
		superGroupOverrides = {},
		superGroupDefinitions = {},
		deletedSuperGroups = {},
		separatedMounts = {}, -- ENHANCED: Include separated mounts
	}
	-- Copy current configuration
	if addon.db and addon.db.profile then
		if addon.db.profile.superGroupOverrides then
			for k, v in pairs(addon.db.profile.superGroupOverrides) do
				config.superGroupOverrides[k] = v
			end
		end

		if addon.db.profile.superGroupDefinitions then
			for k, v in pairs(addon.db.profile.superGroupDefinitions) do
				config.superGroupDefinitions[k] = {}
				for kk, vv in pairs(v) do
					config.superGroupDefinitions[k][kk] = vv
				end
			end
		end

		if addon.db.profile.deletedSuperGroups then
			for k, v in pairs(addon.db.profile.deletedSuperGroups) do
				config.deletedSuperGroups[k] = v
			end
		end

		-- ENHANCED: Export separated mounts data
		if addon.db.profile.separatedMounts then
			for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
				config.separatedMounts[mountID] = {}
				for kk, vv in pairs(separationData) do
					config.separatedMounts[mountID][kk] = vv
				end
			end
		end
	end

	-- Convert to string
	local serialized = self:SerializeTable(config)
	return serialized
end

-- Import supergroup configuration
function ConfigurationManager:ImportConfiguration(configString, importMode)
	importMode = importMode or "replace"
	if not configString or configString:trim() == "" then
		return false, "Configuration string is empty"
	end

	-- Deserialize
	local success, config = pcall(self.DeserializeTable, self, configString)
	if not success or not config then
		return false, "Invalid configuration format"
	end

	-- Validate configuration - support both old and new formats
	if not config.superGroupOverrides or not config.superGroupDefinitions or not config.deletedSuperGroups then
		return false, "Configuration is missing required data"
	end

	-- Check version for compatibility
	local configVersion = config.version or "1.0"
	local hasSeparatedMounts = config.separatedMounts ~= nil
	addon:DebugOptions("Importing configuration version " .. configVersion ..
		(hasSeparatedMounts and " (with separated mounts)" or " (no separated mounts)"))
	-- Initialize database structures if needed
	if not addon.db.profile.superGroupOverrides then
		addon.db.profile.superGroupOverrides = {}
	end

	if not addon.db.profile.superGroupDefinitions then
		addon.db.profile.superGroupDefinitions = {}
	end

	if not addon.db.profile.deletedSuperGroups then
		addon.db.profile.deletedSuperGroups = {}
	end

	-- ENHANCED: Initialize separated mounts if needed
	if not addon.db.profile.separatedMounts then
		addon.db.profile.separatedMounts = {}
	end

	local importStats = {
		overrides = 0,
		definitions = 0,
		deletions = 0,
		separatedMounts = 0, -- ENHANCED: Track separated mounts
	}
	if importMode == "replace" then
		-- Clear existing configuration
		wipe(addon.db.profile.superGroupOverrides)
		wipe(addon.db.profile.superGroupDefinitions)
		wipe(addon.db.profile.deletedSuperGroups)
		-- ENHANCED: Clear separated mounts in replace mode
		wipe(addon.db.profile.separatedMounts)
		addon:DebugOptions("Cleared existing configuration for replace mode")
	end

	-- Import overrides
	for familyName, assignment in pairs(config.superGroupOverrides) do
		addon.db.profile.superGroupOverrides[familyName] = assignment
		importStats.overrides = importStats.overrides + 1
	end

	-- Import definitions
	for sgName, definition in pairs(config.superGroupDefinitions) do
		addon.db.profile.superGroupDefinitions[sgName] = {}
		for k, v in pairs(definition) do
			addon.db.profile.superGroupDefinitions[sgName][k] = v
		end

		importStats.definitions = importStats.definitions + 1
	end

	-- Import deletions
	for sgName, isDeleted in pairs(config.deletedSuperGroups) do
		addon.db.profile.deletedSuperGroups[sgName] = isDeleted
		if isDeleted then
			importStats.deletions = importStats.deletions + 1
		end
	end

	-- ENHANCED: Import separated mounts if present
	if hasSeparatedMounts then
		for mountID, separationData in pairs(config.separatedMounts) do
			-- Validate separated mount data before importing
			if separationData.familyName and separationData.originalFamily then
				addon.db.profile.separatedMounts[mountID] = {}
				for k, v in pairs(separationData) do
					addon.db.profile.separatedMounts[mountID][k] = v
				end

				importStats.separatedMounts = importStats.separatedMounts + 1
			else
				addon:DebugOptions("Skipped invalid separated mount data for mount " .. mountID)
			end
		end
	end

	-- Trigger complete data rebuild since separated mounts affect the data structure
	if importStats.separatedMounts > 0 then
		addon:DebugOptions("Rebuilding data due to separated mounts import...")
		addon.lastProcessingEventName = "import_with_separated_mounts"
		addon:InitializeProcessedData()
		addon.lastProcessingEventName = nil
	else
		-- Regular rebuild for supergroup changes
		addon:RebuildMountGrouping()
	end

	-- ENHANCED: Build comprehensive import message
	local message = string.format(
		"Imported %d family assignments, %d supergroup definitions, %d deletions",
		importStats.overrides, importStats.definitions, importStats.deletions
	)
	if importStats.separatedMounts > 0 then
		message = message .. string.format(", and %d separated mounts", importStats.separatedMounts)
	end

	addon:DebugSupergr("" .. message)
	return true, message
end

-- Reset to defaults (clear all customizations) - ENHANCED to reset everything
function ConfigurationManager:ResetToDefaults(resetType)
	resetType = resetType or "all"
	if not addon.db or not addon.db.profile then
		return false, "Database not available"
	end

	local resetStats = {
		overrides = 0,
		definitions = 0,
		deletions = 0,
		separatedMounts = 0, -- ENHANCED: Track separated mounts
		groupWeights = 0,  -- ENHANCED: Track weight settings
		traitOverrides = 0, -- ENHANCED: Track trait overrides
	}
	if resetType == "all" or resetType == "assignments" then
		-- Clear family assignments
		if addon.db.profile.superGroupOverrides then
			resetStats.overrides = addon:CountTableEntries(addon.db.profile.superGroupOverrides)
			wipe(addon.db.profile.superGroupOverrides)
		end
	end

	if resetType == "all" or resetType == "custom" then
		-- Clear custom supergroups only
		if addon.db.profile.superGroupDefinitions then
			for sgName, definition in pairs(addon.db.profile.superGroupDefinitions) do
				if definition.isCustom then
					addon.db.profile.superGroupDefinitions[sgName] = nil
					resetStats.definitions = resetStats.definitions + 1
				end
			end
		end

		-- FIXED: Also restore deleted supergroups when resetting custom
		-- This makes "Reset Supergroup Manager" actually restore deleted supergroups
		if addon.db.profile.deletedSuperGroups then
			resetStats.deletions = addon:CountTableEntries(addon.db.profile.deletedSuperGroups)
			wipe(addon.db.profile.deletedSuperGroups)
		end
	end

	if resetType == "all" or resetType == "deletions" then
		-- Clear deleted supergroups (restore all) - this is now also handled by "custom" above
		if addon.db.profile.deletedSuperGroups and resetType == "deletions" then
			resetStats.deletions = addon:CountTableEntries(addon.db.profile.deletedSuperGroups)
			wipe(addon.db.profile.deletedSuperGroups)
		end
	end

	if resetType == "all" then
		-- ENHANCED: Clear ALL customizations for complete reset
		addon:DebugOptions("Performing complete reset of all saved variables...")
		-- Clear all supergroup customizations including renames
		if addon.db.profile.superGroupDefinitions then
			wipe(addon.db.profile.superGroupDefinitions)
		end

		-- ENHANCED: Clear separated mounts
		if addon.db.profile.separatedMounts then
			resetStats.separatedMounts = addon:CountTableEntries(addon.db.profile.separatedMounts)
			wipe(addon.db.profile.separatedMounts)
			addon:DebugOptions("Cleared " .. resetStats.separatedMounts .. " separated mounts")
		end

		-- ENHANCED: Clear all group weights (mount, family, and supergroup weights)
		if addon.db.profile.groupWeights then
			resetStats.groupWeights = addon:CountTableEntries(addon.db.profile.groupWeights)
			wipe(addon.db.profile.groupWeights)
			addon:DebugOptions("Cleared " .. resetStats.groupWeights .. " weight settings")
		end

		-- ENHANCED: Clear all trait overrides
		if addon.db.profile.traitOverrides then
			resetStats.traitOverrides = addon:CountTableEntries(addon.db.profile.traitOverrides)
			wipe(addon.db.profile.traitOverrides)
			addon:DebugOptions("Cleared " .. resetStats.traitOverrides .. " trait overrides")
		end
	end

	-- ENHANCED: Trigger complete data rebuild if separated mounts were cleared
	if resetStats.separatedMounts > 0 then
		addon:DebugOptions("Rebuilding data due to separated mounts reset...")
		addon.lastProcessingEventName = "reset_with_separated_mounts"
		addon:InitializeProcessedData()
		addon.lastProcessingEventName = nil
	else
		-- Regular rebuild for other changes
		addon:RebuildMountGrouping()
	end

	-- ENHANCED: Build comprehensive reset message
	local message = string.format(
		"Reset %d family assignments, %d custom supergroups, and restored %d deleted supergroups",
		resetStats.overrides, resetStats.definitions, resetStats.deletions
	)
	if resetType == "all" then
		local additionalResets = {}
		if resetStats.separatedMounts > 0 then
			table.insert(additionalResets, resetStats.separatedMounts .. " separated mounts")
		end

		if resetStats.groupWeights > 0 then
			table.insert(additionalResets, resetStats.groupWeights .. " weight settings")
		end

		if resetStats.traitOverrides > 0 then
			table.insert(additionalResets, resetStats.traitOverrides .. " trait overrides")
		end

		if #additionalResets > 0 then
			message = message .. "; also cleared " .. table.concat(additionalResets, ", ")
		end
	end

	addon:DebugSupergr("" .. message)
	return true, message
end

-- Reset mount separation only (reunite all separated mounts)
function ConfigurationManager:ResetMountSeparationOnly()
	if not addon.db or not addon.db.profile then
		return false, "Database not available"
	end

	if not addon.db.profile.separatedMounts then
		return false, "No separated mounts to reset"
	end

	local separatedCount = addon:CountTableEntries(addon.db.profile.separatedMounts)
	if separatedCount == 0 then
		return false, "No separated mounts found"
	end

	addon:DebugOptions("Resetting " .. separatedCount .. " separated mounts...")
	-- Clear separated mount family weight settings (but keep individual mount weights)
	local clearedFamilyWeights = 0
	if addon.db.profile.groupWeights then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.groupWeights[separatedFamilyName] then
				addon.db.profile.groupWeights[separatedFamilyName] = nil
				clearedFamilyWeights = clearedFamilyWeights + 1
			end
		end
	end

	-- Clear separated family supergroup overrides
	local clearedOverrides = 0
	if addon.db.profile.superGroupOverrides then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.superGroupOverrides[separatedFamilyName] then
				addon.db.profile.superGroupOverrides[separatedFamilyName] = nil
				clearedOverrides = clearedOverrides + 1
			end
		end
	end

	-- Clear separated family trait overrides
	local clearedTraitOverrides = 0
	if addon.db.profile.traitOverrides then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local separatedFamilyName = separationData.familyName
			if separatedFamilyName and addon.db.profile.traitOverrides[separatedFamilyName] then
				addon.db.profile.traitOverrides[separatedFamilyName] = nil
				clearedTraitOverrides = clearedTraitOverrides + 1
			end
		end
	end

	-- Clear the separated mounts data
	wipe(addon.db.profile.separatedMounts)
	addon:DebugOptions("Cleared separated mounts and " .. clearedFamilyWeights ..
		" family weights, " .. clearedOverrides .. " supergroup overrides, " ..
		clearedTraitOverrides .. " trait overrides")
	-- Trigger complete data rebuild
	addon.lastProcessingEventName = "reset_mount_separation"
	addon:InitializeProcessedData()
	addon.lastProcessingEventName = nil
	-- Refresh all UIs
	self:RefreshAllUIs()
	local message = string.format(
		"Reset %d separated mounts and reunited them with their original families",
		separatedCount
	)
	if clearedFamilyWeights > 0 or clearedOverrides > 0 or clearedTraitOverrides > 0 then
		message = message .. string.format(
			" (also cleared %d family weights, %d supergroup assignments, %d trait overrides)",
			clearedFamilyWeights, clearedOverrides, clearedTraitOverrides
		)
	end

	addon:DebugOptions("" .. message)
	return true, message
end

-- ============================================================================
-- SERIALIZATION HELPERS
-- ============================================================================
-- Simple table serialization
function ConfigurationManager:SerializeTable(tbl)
	local function serialize(o)
		if type(o) == "number" then
			return tostring(o)
		elseif type(o) == "string" then
			return string.format("%q", o)
		elseif type(o) == "boolean" then
			return tostring(o)
		elseif type(o) == "table" then
			local result = "{"
			for k, v in pairs(o) do
				if type(k) == "string" then
					result = result .. "[" .. string.format("%q", k) .. "]="
				else
					result = result .. "[" .. k .. "]="
				end

				result = result .. serialize(v) .. ","
			end

			result = result .. "}"
			return result
		else
			return "nil"
		end
	end

	return serialize(tbl)
end

-- Simple table deserialization
function ConfigurationManager:DeserializeTable(str)
	local func = loadstring("return " .. str)
	if func then
		return func()
	else
		return nil
	end
end

-- ============================================================================
-- DATA VALIDATION AND REPAIR SYSTEM
-- ============================================================================
-- Main validation function that runs all checks
function ConfigurationManager:RunDataValidation(autoFix)
	if not addon.RMB_DataReadyForUI then
		return false, "Data not ready for validation"
	end

	addon:DebugValidation("Starting comprehensive data validation...")
	local startTime = debugprofilestop()
	local report = {
		weightSyncIssues = {},
		orphanedSettings = {},
		nameConflicts = {},
		totalIssues = 0,
		totalFixed = 0,
	}
	-- Run all validation checks
	self:ValidateWeightSynchronization(report, autoFix)
	self:ValidateOrphanedSettings(report, autoFix)
	self:ValidateSeparatedFamilyNames(report, autoFix)
	local endTime = debugprofilestop()
	addon:DebugValidation(string.format(" Completed in %.2fms - %d issues found, %d fixed",
		endTime - startTime, report.totalIssues, report.totalFixed))
	return true, report
end

-- ADD: Helper method to check if validation can run
function ConfigurationManager:CanRunValidation()
	if not addon.RMB_DataReadyForUI then
		return false, "Mount data is not ready yet"
	end

	if not addon.processedData then
		return false, "Processed data not available"
	end

	if not (addon.db and addon.db.profile) then
		return false, "Database not available"
	end

	return true, nil
end

-- ADD: Method to clear validation report (useful for UI)
function ConfigurationManager:ClearValidationReport()
	self.lastValidationReport = nil
	addon:DebugSupergr("Validation report cleared")
end

-- ADD: Method to get validation statistics for display
function ConfigurationManager:GetValidationStats()
	local canRun, reason = self:CanRunValidation()
	if not canRun then
		return {
			canRun = false,
			reason = reason,
			estimatedIssues = 0,
		}
	end

	-- Quick count of potential issues without full validation
	local potentialIssues = 0
	-- Count weight settings that might be problematic
	if addon.db.profile.groupWeights then
		for groupKey, weight in pairs(addon.db.profile.groupWeights) do
			local numWeight = tonumber(weight)
			if not numWeight or numWeight < 0 or numWeight > 6 then
				potentialIssues = potentialIssues + 1
			end
		end
	end

	-- Count separated mounts (potential for conflicts)
	if addon.db.profile.separatedMounts then
		potentialIssues = potentialIssues + addon:CountTableEntries(addon.db.profile.separatedMounts)
	end

	return {
		canRun = true,
		reason = nil,
		estimatedIssues = potentialIssues,
		hasReport = self.lastValidationReport ~= nil,
	}
end

-- ============================================================================
-- 1. WEIGHT SYNCHRONIZATION VALIDATION
-- ============================================================================
function ConfigurationManager:ValidateWeightSynchronization(report, autoFix)
	addon:DebugValidation("Checking weight synchronization...")
	if not (addon.db and addon.db.profile and addon.db.profile.groupWeights) then
		return
	end

	local weightSettings = addon.db.profile.groupWeights
	local issuesFound = 0
	local issuesFixed = 0
	-- Check 1: Single-mount families where family weight ≠ mount weight
	addon:DebugValidation("Checking single-mount family weight sync...")
	for familyName, _ in pairs(addon.processedData.familyToMountIDsMap or {}) do
		local isSingleMount, mountID = addon:IsSingleMountFamily(familyName)
		if isSingleMount and mountID then
			local familyWeight = weightSettings[familyName]
			local mountKey = "mount_" .. mountID
			local mountWeight = weightSettings[mountKey]
			-- Only check if both weights exist and differ
			if familyWeight and mountWeight and familyWeight ~= mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "single_mount_desync",
					familyName = familyName,
					mountID = mountID,
					familyWeight = familyWeight,
					mountWeight = mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Use the higher weight to avoid downgrading
					local syncWeight = math.max(familyWeight, mountWeight)
					weightSettings[familyName] = syncWeight
					weightSettings[mountKey] = syncWeight
					issue.fixedWeight = syncWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Fixed single-mount sync: " .. familyName .. " -> " .. syncWeight)
				end
			end
		end
	end

	-- Check 2: Separated families where separated family weight ≠ mount weight
	addon:DebugValidation("Checking separated family weight sync...")
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local familyName = separationData.familyName
			local familyWeight = weightSettings[familyName]
			local mountKey = "mount_" .. mountID
			local mountWeight = weightSettings[mountKey]
			-- Only check if both weights exist and differ
			if familyWeight and mountWeight and familyWeight ~= mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "separated_mount_desync",
					familyName = familyName,
					mountID = tonumber(mountID),
					familyWeight = familyWeight,
					mountWeight = mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Use the higher weight to avoid downgrading
					local syncWeight = math.max(familyWeight, mountWeight)
					weightSettings[familyName] = syncWeight
					weightSettings[mountKey] = syncWeight
					issue.fixedWeight = syncWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Fixed separated family sync: " .. familyName .. " -> " .. syncWeight)
				end
			end
		end
	end

	-- Check 3: Invalid weight ranges (outside 0-6)
	addon:DebugValidation("Checking weight ranges...")
	for groupKey, weight in pairs(weightSettings) do
		local numWeight = tonumber(weight)
		if not numWeight or numWeight < 0 or numWeight > 6 then
			issuesFound = issuesFound + 1
			local issue = {
				type = "invalid_weight_range",
				groupKey = groupKey,
				invalidWeight = weight,
			}
			table.insert(report.weightSyncIssues, issue)
			if autoFix then
				-- Fix to default weight (3 = Normal)
				weightSettings[groupKey] = 3
				issue.fixedWeight = 3
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				addon:DebugValidation("Fixed invalid weight: " .. groupKey .. " " .. tostring(weight) .. " -> 3")
			end
		end
	end

	-- Check 4: Separated mounts missing family or mount weights
	addon:DebugValidation("Checking missing separated mount weights...")
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			local familyName = separationData.familyName
			local mountKey = "mount_" .. mountID
			local familyWeight = weightSettings[familyName]
			local mountWeight = weightSettings[mountKey]
			-- Check if either weight is missing
			if not familyWeight or not mountWeight then
				issuesFound = issuesFound + 1
				local issue = {
					type = "missing_separated_weights",
					familyName = familyName,
					mountID = tonumber(mountID),
					missingFamilyWeight = not familyWeight,
					missingMountWeight = not mountWeight,
				}
				table.insert(report.weightSyncIssues, issue)
				if autoFix then
					-- Set both to default weight (3 = Normal) if missing
					local defaultWeight = 3
					if not familyWeight then
						weightSettings[familyName] = defaultWeight
					end

					if not mountWeight then
						weightSettings[mountKey] = defaultWeight
					end

					issue.fixedWeight = defaultWeight
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Fixed missing separated weights: " .. familyName .. " -> " .. defaultWeight)
				end
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation("Weight sync check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- ============================================================================
-- 2. ORPHANED SETTINGS CLEANUP
-- ============================================================================
function ConfigurationManager:ValidateOrphanedSettings(report, autoFix)
	addon:DebugValidation("Checking for orphaned settings...")
	if not (addon.db and addon.db.profile) then
		return
	end

	local issuesFound = 0
	local issuesFixed = 0
	-- Get list of all valid families and mounts
	local validFamilies = {}
	local validMounts = {}
	-- Collect valid families from processed data
	if addon.processedData then
		-- From collected mounts
		if addon.processedData.allCollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
				validFamilies[mountInfo.familyName] = true
				validMounts["mount_" .. mountID] = true
			end
		end

		-- From uncollected mounts
		if addon.processedData.allUncollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
				validFamilies[mountInfo.familyName] = true
				validMounts["mount_" .. mountID] = true
			end
		end
	end

	-- Add separated families as valid
	if addon.db.profile.separatedMounts then
		for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
			validFamilies[separationData.familyName] = true
			validMounts["mount_" .. mountID] = true
		end
	end

	-- Check 1: Orphaned weight settings
	addon:DebugValidation("Checking orphaned weight settings...")
	if addon.db.profile.groupWeights then
		for groupKey, weight in pairs(addon.db.profile.groupWeights) do
			local isValid = false
			-- Check if it's a valid mount
			if groupKey:match("^mount_") then
				isValid = validMounts[groupKey]
			else
				-- Check if it's a valid family or supergroup
				isValid = validFamilies[groupKey] or
						(addon.processedData.superGroupMap and addon.processedData.superGroupMap[groupKey]) or
						(addon.processedData.dynamicSuperGroupMap and addon.processedData.dynamicSuperGroupMap[groupKey])
			end

			if not isValid then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_weight",
					groupKey = groupKey,
					weight = weight,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.groupWeights[groupKey] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Removed orphaned weight: " .. groupKey)
				end
			end
		end
	end

	-- Check 2: Orphaned supergroup overrides
	addon:DebugValidation("Checking orphaned supergroup overrides...")
	if addon.db.profile.superGroupOverrides then
		for familyName, override in pairs(addon.db.profile.superGroupOverrides) do
			if not validFamilies[familyName] then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_supergroup_override",
					familyName = familyName,
					override = override,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.superGroupOverrides[familyName] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Removed orphaned supergroup override: " .. familyName)
				end
			end
		end
	end

	-- Check 3: Orphaned trait overrides
	addon:DebugValidation("Checking orphaned trait overrides...")
	if addon.db.profile.traitOverrides then
		for familyName, traits in pairs(addon.db.profile.traitOverrides) do
			if not validFamilies[familyName] then
				issuesFound = issuesFound + 1
				local issue = {
					type = "orphaned_trait_override",
					familyName = familyName,
					traits = traits,
				}
				table.insert(report.orphanedSettings, issue)
				if autoFix then
					addon.db.profile.traitOverrides[familyName] = nil
					issue.fixed = true
					issuesFixed = issuesFixed + 1
					addon:DebugValidation("Removed orphaned trait override: " .. familyName)
				end
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation("Orphaned settings check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- ============================================================================
-- 3. SEPARATED FAMILY NAME CONFLICT VALIDATION
-- ============================================================================
function ConfigurationManager:ValidateSeparatedFamilyNames(report, autoFix)
	addon:DebugValidation("Checking separated family name conflicts...")
	if not (addon.db and addon.db.profile and addon.db.profile.separatedMounts) then
		return
	end

	local issuesFound = 0
	local issuesFixed = 0
	-- Get all original family names
	local originalFamilies = {}
	if addon.processedData then
		if addon.processedData.allCollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
				-- Skip mounts that are separated
				if not addon.db.profile.separatedMounts[mountID] then
					originalFamilies[mountInfo.familyName] = true
				end
			end
		end

		if addon.processedData.allUncollectedMountFamilyInfo then
			for mountID, mountInfo in pairs(addon.processedData.allUncollectedMountFamilyInfo) do
				-- Skip mounts that are separated
				if not addon.db.profile.separatedMounts[mountID] then
					originalFamilies[mountInfo.familyName] = true
				end
			end
		end
	end

	-- Get all separated family names and check for conflicts
	local separatedFamilies = {}
	local duplicateSeparatedNames = {}
	for mountID, separationData in pairs(addon.db.profile.separatedMounts) do
		local familyName = separationData.familyName
		-- Check 1: Conflict with original families
		if originalFamilies[familyName] then
			issuesFound = issuesFound + 1
			local issue = {
				type = "separated_conflicts_original",
				mountID = tonumber(mountID),
				conflictingName = familyName,
				originalFamily = separationData.originalFamily,
			}
			table.insert(report.nameConflicts, issue)
			if autoFix then
				-- Generate a unique name
				local newName = self:GenerateUniqueSeparatedFamilyName(familyName, originalFamilies, separatedFamilies)
				-- Update the separation data
				separationData.familyName = newName
				-- Update any weight settings
				if addon.db.profile.groupWeights then
					local oldWeight = addon.db.profile.groupWeights[familyName]
					if oldWeight then
						addon.db.profile.groupWeights[familyName] = nil
						addon.db.profile.groupWeights[newName] = oldWeight
					end
				end

				-- Update any supergroup overrides
				if addon.db.profile.superGroupOverrides then
					local oldOverride = addon.db.profile.superGroupOverrides[familyName]
					if oldOverride then
						addon.db.profile.superGroupOverrides[familyName] = nil
						addon.db.profile.superGroupOverrides[newName] = oldOverride
					end
				end

				-- Update any trait overrides
				if addon.db.profile.traitOverrides then
					local oldTraits = addon.db.profile.traitOverrides[familyName]
					if oldTraits then
						addon.db.profile.traitOverrides[familyName] = nil
						addon.db.profile.traitOverrides[newName] = oldTraits
					end
				end

				issue.newName = newName
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				separatedFamilies[newName] = true
				addon:DebugValidation("Fixed name conflict: " .. familyName .. " -> " .. newName)
			end
		else
			-- Track this separated family name
			if separatedFamilies[familyName] then
				-- Check 2: Duplicate separated family names
				if not duplicateSeparatedNames[familyName] then
					duplicateSeparatedNames[familyName] = {}
				end

				table.insert(duplicateSeparatedNames[familyName], mountID)
			else
				separatedFamilies[familyName] = true
			end
		end
	end

	-- Handle duplicate separated family names
	for familyName, mountIDs in pairs(duplicateSeparatedNames) do
		-- Keep the first mount, rename the others
		for i = 2, #mountIDs do
			local mountID = mountIDs[i]
			issuesFound = issuesFound + 1
			local issue = {
				type = "duplicate_separated_names",
				mountID = tonumber(mountID),
				duplicateName = familyName,
			}
			table.insert(report.nameConflicts, issue)
			if autoFix then
				local separationData = addon.db.profile.separatedMounts[mountID]
				local newName = self:GenerateUniqueSeparatedFamilyName(familyName, originalFamilies, separatedFamilies)
				-- Update separation data
				separationData.familyName = newName
				-- Update settings (same as above)
				if addon.db.profile.groupWeights then
					local oldWeight = addon.db.profile.groupWeights[familyName]
					if oldWeight then
						addon.db.profile.groupWeights[newName] = oldWeight
					end
				end

				issue.newName = newName
				issue.fixed = true
				issuesFixed = issuesFixed + 1
				separatedFamilies[newName] = true
				addon:DebugValidation("Fixed duplicate separated name: " .. familyName .. " -> " .. newName)
			end
		end
	end

	report.totalIssues = report.totalIssues + issuesFound
	report.totalFixed = report.totalFixed + issuesFixed
	addon:DebugValidation("Name conflict check complete - " .. issuesFound .. " issues, " .. issuesFixed .. " fixed")
end

-- Helper function to generate unique separated family names
function ConfigurationManager:GenerateUniqueSeparatedFamilyName(baseName, originalFamilies, separatedFamilies)
	local newName = baseName .. "_Separated"
	local counter = 1
	while originalFamilies[newName] or separatedFamilies[newName] do
		newName = baseName .. "_Separated_" .. counter
		counter = counter + 1
	end

	return newName
end

-- ============================================================================
-- VALIDATION REPORT FORMATTING
-- ============================================================================
function ConfigurationManager:FormatValidationReport(report)
	local lines = {}
	table.insert(lines, "|cffffd700=== Data Validation Report ===|r")
	table.insert(lines, string.format("Total Issues Found: %d", report.totalIssues))
	table.insert(lines, string.format("Total Issues Fixed: %d", report.totalFixed))
	table.insert(lines, "")
	-- Weight Sync Issues
	if #report.weightSyncIssues > 0 then
		table.insert(lines, "|cff00ff00Weight Synchronization Issues:|r")
		for _, issue in ipairs(report.weightSyncIssues) do
			if issue.type == "single_mount_desync" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Single-mount family '%s' weight mismatch: Family=%d, Mount=%d",
					status, issue.familyName, issue.familyWeight, issue.mountWeight))
				if issue.fixed then
					table.insert(lines, string.format("    -> Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "separated_mount_desync" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Separated family '%s' weight mismatch: Family=%d, Mount=%d",
					status, issue.familyName, issue.familyWeight, issue.mountWeight))
				if issue.fixed then
					table.insert(lines, string.format("    -> Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "invalid_weight_range" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				table.insert(lines, string.format("  %s Invalid weight for '%s': %s",
					status, issue.groupKey, tostring(issue.invalidWeight)))
				if issue.fixed then
					table.insert(lines, string.format("    -> Fixed to weight %d", issue.fixedWeight))
				end
			elseif issue.type == "missing_separated_weights" then
				local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
				local missing = {}
				if issue.missingFamilyWeight then table.insert(missing, "family") end

				if issue.missingMountWeight then table.insert(missing, "mount") end

				table.insert(lines, string.format("  %s Missing %s weights for separated family '%s'",
					status, table.concat(missing, " and "), issue.familyName))
				if issue.fixed then
					table.insert(lines, string.format("    -> Set to weight %d", issue.fixedWeight))
				end
			end
		end

		table.insert(lines, "")
	end

	-- Orphaned Settings
	if #report.orphanedSettings > 0 then
		table.insert(lines, "|cff00ff00Orphaned Settings:|r")
		for _, issue in ipairs(report.orphanedSettings) do
			local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
			if issue.type == "orphaned_weight" then
				table.insert(lines, string.format("  %s Orphaned weight setting: '%s' = %s",
					status, issue.groupKey, tostring(issue.weight)))
			elseif issue.type == "orphaned_supergroup_override" then
				table.insert(lines, string.format("  %s Orphaned supergroup override: '%s' -> %s",
					status, issue.familyName, tostring(issue.override)))
			elseif issue.type == "orphaned_trait_override" then
				table.insert(lines, string.format("  %s Orphaned trait override: '%s'",
					status, issue.familyName))
			end
		end

		table.insert(lines, "")
	end

	-- Name Conflicts
	if #report.nameConflicts > 0 then
		table.insert(lines, "|cff00ff00Name Conflicts:|r")
		for _, issue in ipairs(report.nameConflicts) do
			local status = issue.fixed and "|cff00ff00[FIXED]|r" or "|cffff0000[NEEDS FIX]|r"
			if issue.type == "separated_conflicts_original" then
				table.insert(lines, string.format("  %s Separated family name conflicts with original: '%s'",
					status, issue.conflictingName))
				if issue.fixed then
					table.insert(lines, string.format("    -> Renamed to '%s'", issue.newName))
				end
			elseif issue.type == "duplicate_separated_names" then
				table.insert(lines, string.format("  %s Duplicate separated family name: '%s'",
					status, issue.duplicateName))
				if issue.fixed then
					table.insert(lines, string.format("    -> Renamed to '%s'", issue.newName))
				end
			end
		end

		table.insert(lines, "")
	end

	if report.totalIssues == 0 then
		table.insert(lines, "|cff00ff00No issues found! Your data is clean.|r")
	end

	return table.concat(lines, "\n")
end

-- ============================================================================
-- UI REFRESH COORDINATION
-- ============================================================================
-- Method to refresh all UIs (coordinates with other modules)
function ConfigurationManager:RefreshAllUIs()
	addon:DebugSupergr("ConfigurationManager: Refreshing all UIs after validation fixes")
	-- Refresh SuperGroup Management UIs
	if addon.SuperGroupManager then
		addon.SuperGroupManager:PopulateSuperGroupManagementUI()
	end

	-- Refresh Family Assignment UI
	if addon.FamilyAssignment then
		addon.FamilyAssignment:PopulateFamilyAssignmentUI()
	end

	-- Refresh main Mount List UI
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
	end

	-- Refresh Mount Separation UI if it exists
	if addon.MountSeparationManager and addon.MountSeparationManager.PopulateSeparationManagementUI then
		addon.MountSeparationManager:PopulateSeparationManagementUI()
	end

	-- Refresh mount pools to ensure changes take effect in summoning
	if addon.MountSummon and addon.MountSummon.RefreshMountPools then
		addon.MountSummon:RefreshMountPools()
	end

	addon:DebugSupergr("ConfigurationManager: All UI refresh completed")
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Initialize Configuration Manager when addon loads
function addon:InitializeConfigurationManager()
	if not self.ConfigurationManager then
		addon:DebugSupergr("ERROR - ConfigurationManager not found!")
		return
	end

	self.ConfigurationManager:Initialize()
	addon:DebugSupergr("ConfigurationManager integration complete")
end

addon:DebugCore("ConfigurationManager.lua END.")
