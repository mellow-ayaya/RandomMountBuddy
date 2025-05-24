-- Core.lua - Updated for Refactored Mount System
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW
local dbDefaults = {
	profile = {
		overrideBlizzardButton = true,
		-- Summoning
		contextualSummoning = true,
		-- Class Spells
		-- Druid
		useTravelFormWhileMoving = true,
		keepTravelFormActive = true,
		useSmartFormSwitching = true,
		-- Shaman
		useGhostWolfWhileMoving = true,
		keepGhostWolfActive = true,
		-- Mage Spells
		useSlowFallWhileFalling = true,
		useSlowFallOnOthers = false,
		-- Monk
		useZenFlightWhileMoving = true,
		keepZenFlightActive = true,
		-- Priest Spells
		useLevitateWhileFalling = true,
		useLevitateOnOthers = false,
		-- Mount list related
		-- Mount traits
		treatMinorArmorAsDistinct = false,
		treatMajorArmorAsDistinct = false,
		treatModelVariantsAsDistinct = false,
		treatUniqueEffectsOrSkin = true,
		-- Mount list options
		useSuperGrouping = true,
		showUncollectedMounts = true,
		--
		expansionStates = {},
		groupWeights = {},
		groupEnabledStates = {},
		familyOverrides = {},
		fmItemsPerPage = 14,
	},
}
print("RMB_DEBUG: Core.lua START (Refactored). Addon Name: " ..
	tostring(addonNameFromToc) .. ". Time: " .. tostring(time()))
-- Library initialization
local LibAceAddon = LibStub("AceAddon-3.0")
local LibAceDB = LibStub("AceDB-3.0")
local LibAceConsole = LibStub("AceConsole-3.0")
local LibAceEvent = LibStub("AceEvent-3.0")
local LibAceConfigRegistry = LibStub("AceConfigRegistry-3.0")
if not LibAceAddon then
	print("RMB_DEBUG: FATAL - AceAddon-3.0 not found!")
	return
end

-- Additional library checks
if not LibAceDB then print("RMB_DEBUG: WARNING - AceDB-3.0 not found!") end

if not LibAceConsole then print("RMB_DEBUG: WARNING - AceConsole-3.0 not found!") end

if not LibAceEvent then print("RMB_DEBUG: WARNING - AceEvent-3.0 not found!") end

if not LibAceConfigRegistry then print("RMB_DEBUG: WARNING - AceConfigRegistry-3.0 not found!") end

-- Create addon object
local addon
local success, result = pcall(function()
	LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0")
	addon = RandomMountBuddy
end)
if not success then
	print("RMB_DEBUG: ERROR during NewAddon: " .. tostring(result))
	return
end

print("RMB_DEBUG: NewAddon SUCCEEDED. Addon valid: " ..
	tostring(addon and addon.GetName and addon:GetName() or "Unknown/Error"))
-- Initialize addon state
addon.RMB_DataReadyForUI = false
addon.fmCurrentPage = 1
addon.fmItemsPerPage = 15
-- Keybinding headers
BINDING_HEADER_RANDOMMOUNTBUDDY = "Random Mount Buddy"
BINDING_NAME_CLICK_RMBSmartButton_LeftButton = "Smart Mount/Travel Form"
-- Add shortcuts
RMB = RandomMountBuddy
function RMB:SRM(useContext)
	return self:SummonRandomMount(useContext)
end

-- ============================================================================
-- FAMILY INFO AND DATA PROCESSING
-- ============================================================================
function addon:GetFamilyInfoForMountID(mountID)
	if not mountID then return nil end

	local id = tonumber(mountID)
	if not id then return nil end

	local modelPath = self.MountToModelPath and self.MountToModelPath[id]
	if not modelPath then return nil end

	local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]
	if not familyDef then return nil end

	return {
		familyName = familyDef.familyName,
		superGroup = familyDef.superGroup,
		traits = familyDef.traits or {},
		modelPath = modelPath,
	}
end

function addon:InitializeProcessedData()
	local eventNameForLog = self.lastProcessingEventName or "Manual Call or Unknown Event"
	print("RMB_DEBUG_DATA: Initializing Processed Data (Event: " .. eventNameForLog .. ")...")
	-- Initialize data structures (including uncollected mounts)
	self.processedData = {
		superGroupMap = {},
		standaloneFamilyNames = {},
		familyToMountIDsMap = {},
		superGroupToMountIDsMap = {},
		allCollectedMountFamilyInfo = {},
		-- Uncollected mount structures
		familyToUncollectedMountIDsMap = {},
		superGroupToUncollectedMountIDsMap = {},
		allUncollectedMountFamilyInfo = {},
	}
	-- Check API availability
	if not C_MountJournal or not C_MountJournal.GetMountIDs then
		print("RMB_DEBUG_DATA: C_MountJournal API missing!")
		return
	end

	local allMountIDs = C_MountJournal.GetMountIDs()
	if not allMountIDs then
		print("RMB_DEBUG_DATA: GetMountIDs nil")
		return
	end

	print("RMB_DEBUG_DATA: GetMountIDs found " .. #allMountIDs .. " IDs.")
	-- Process all mounts
	local collectedCount, uncollectedCount, processedCount, scannedCount = 0, 0, 0, 0
	for _, mountID in ipairs(allMountIDs) do
		scannedCount = scannedCount + 1
		local name, _, _, _, isUsable, _, isFavorite, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
		if type(name) == "string" and type(isCollected) == "boolean" then
			if scannedCount <= 10 then
				print("RMB_DATA_SCAN: ID:" .. tostring(mountID) .. ",N:" .. tostring(name) ..
					",C:" .. tostring(isCollected) .. ",U:" .. tostring(isUsable))
			end

			local familyInfo = self:GetFamilyInfoForMountID(mountID)
			if familyInfo and familyInfo.familyName then
				processedCount = processedCount + 1
				-- Create common mount info
				local mountFamilyInfo = {
					name = name,
					isUsable = isUsable,
					isFavorite = isFavorite,
					familyName = familyInfo.familyName,
					superGroup = familyInfo.superGroup,
					traits = familyInfo.traits,
					modelPath = familyInfo.modelPath,
				}
				local fn, sg = familyInfo.familyName, familyInfo.superGroup
				-- Process based on collection status
				if isCollected == true then
					collectedCount = collectedCount + 1
					self.processedData.allCollectedMountFamilyInfo[mountID] = mountFamilyInfo
					-- Add to collected mount maps
					if not self.processedData.familyToMountIDsMap[fn] then
						self.processedData.familyToMountIDsMap[fn] = {}
					end

					table.insert(self.processedData.familyToMountIDsMap[fn], mountID)
					if sg then
						-- Add to supergroup
						if not self.processedData.superGroupMap[sg] then
							self.processedData.superGroupMap[sg] = {}
						end

						local found = false
						for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do
							if eFN == fn then
								found = true; break
							end
						end

						if not found then
							table.insert(self.processedData.superGroupMap[sg], fn)
						end

						if not self.processedData.superGroupToMountIDsMap[sg] then
							self.processedData.superGroupToMountIDsMap[sg] = {}
						end

						table.insert(self.processedData.superGroupToMountIDsMap[sg], mountID)
					else
						self.processedData.standaloneFamilyNames[fn] = true
					end
				else
					-- Handle uncollected mounts
					uncollectedCount = uncollectedCount + 1
					self.processedData.allUncollectedMountFamilyInfo[mountID] = mountFamilyInfo
					-- Add to uncollected mount maps
					if not self.processedData.familyToUncollectedMountIDsMap[fn] then
						self.processedData.familyToUncollectedMountIDsMap[fn] = {}
					end

					table.insert(self.processedData.familyToUncollectedMountIDsMap[fn], mountID)
					if sg then
						-- Ensure supergroup exists
						if not self.processedData.superGroupMap[sg] then
							self.processedData.superGroupMap[sg] = {}
						end

						-- Make sure family is in supergroup list
						local found = false
						for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do
							if eFN == fn then
								found = true; break
							end
						end

						if not found then
							table.insert(self.processedData.superGroupMap[sg], fn)
						end

						if not self.processedData.superGroupToUncollectedMountIDsMap[sg] then
							self.processedData.superGroupToUncollectedMountIDsMap[sg] = {}
						end

						table.insert(self.processedData.superGroupToUncollectedMountIDsMap[sg], mountID)
					else
						self.processedData.standaloneFamilyNames[fn] = true
					end
				end
			end
		end
	end

	print("RMB_DEBUG_DATA: Scanned:" .. scannedCount .. ", APICollected:" .. collectedCount ..
		", APIUncollected:" .. uncollectedCount .. ", ProcessedFamilyInfo:" .. processedCount)
	local sgC = 0; for k in pairs(self.processedData.superGroupMap) do sgC = sgC + 1 end

	print("RMB_DEBUG_DATA: SuperGroups:" .. sgC)
	local fnC = 0; for k in pairs(self.processedData.standaloneFamilyNames) do fnC = fnC + 1 end

	print("RMB_DEBUG_DATA: StandaloneFams:" .. fnC)
	print("RMB_DEBUG_DATA: Init COMPLETE.")
	self.RMB_DataReadyForUI = true
	print("RMB_DEBUG_DATA: Set RMB_DataReadyForUI to true.")
	-- Rebuild mount grouping for trait-based filtering
	self:RebuildMountGrouping()
	-- Notify all modules that data is ready
	self:NotifyModulesDataReady()
	-- Initialize UI last
	if self.PopulateFamilyManagementUI then
		self:PopulateFamilyManagementUI()
	end
end

-- ============================================================================
-- INITIALIZATION FUNCTIONS
-- ============================================================================
function addon:OnInitialize()
	print("RMB_DEBUG: OnInitialize CALLED.")
	-- Load preload data
	if RandomMountBuddy_PreloadData then
		self.MountToModelPath = RandomMountBuddy_PreloadData.MountToModelPath or {}
		self.FamilyDefinitions = RandomMountBuddy_PreloadData.FamilyDefinitions or {}
		RandomMountBuddy_PreloadData = nil
		print("RMB_DEBUG: PreloadData processed.")
	else
		self.MountToModelPath = {}
		self.FamilyDefinitions = {}
		print("RMB_DEBUG: PreloadData nil.")
	end

	-- Log data counts
	local mtpC = 0
	for _ in pairs(self.MountToModelPath) do mtpC = mtpC + 1 end

	print("RMB_DEBUG: MountToModelPath entries: " .. mtpC)
	local fdC = 0
	for _ in pairs(self.FamilyDefinitions) do fdC = fdC + 1 end

	print("RMB_DEBUG: FamilyDefinitions entries: " .. fdC)
	-- Initialize empty processed data
	self.processedData = {
		superGroupMap = {},
		standaloneFamilyNames = {},
		familyToMountIDsMap = {},
		superGroupToMountIDsMap = {},
		allCollectedMountFamilyInfo = {},
	}
	print("RMB_DEBUG: OnInitialize - Initialized empty self.processedData.")
	self.RMB_DataReadyForUI = false
	-- Load mount type data
	self.mountTypeTraits = MountTypeTraits_Input_Helper or {}
	self.mountIDtoTypeID = MountIDtoMountTypeID or {}
	-- Clear global tables to save memory
	MountTypeTraits_Input_Helper = nil
	MountIDtoMountTypeID = nil
	print("RMB_DEBUG: Mount type data loaded. Types: " .. self:CountTableEntries(self.mountTypeTraits) ..
		", ID mappings: " .. self:CountTableEntries(self.mountIDtoTypeID))
	-- Initialize database
	if LibAceDB then
		self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true)
		print("RMB_DEBUG: AceDB:New done.")
		if self.db and self.db.profile then
			print("RMB_DEBUG: Initial 'overrideBlizzardButton': " .. tostring(self.db.profile.overrideBlizzardButton))
			if self.db.profile.fmItemsPerPage then
				self.fmItemsPerPage = self.db.profile.fmItemsPerPage
				print("RMB_DEBUG: Loaded fmItemsPerPage: " .. tostring(self.fmItemsPerPage))
			end
		else
			print("RMB_DEBUG: self.db.profile nil!")
		end
	else
		print("RMB_DEBUG: LibAceDB missing.")
	end

	-- Register slash commands
	if LibAceConsole then
		self:RegisterChatCommand("rmb", "SlashCommandHandler")
		self:RegisterChatCommand("randommountbuddy", "SlashCommandHandler")
		self:RegisterChatCommand("rmm", function()
			print("RMB_SECURE: 'rmm' slash command executed from Core.lua")
			if self.ClickSecureButton then
				self:ClickSecureButton()
			else
				print("RMB_SECURE_ERROR: ClickSecureButton method not found!")
			end
		end)
		print("RMB_DEBUG: Slash commands registered.")
	else
		print("RMB_DEBUG: LibAceConsole missing.")
	end

	-- Register events
	if self.RegisterEvent then
		self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLoginAttemptProcessData")
		print("RMB_DEBUG: Registered for PLAYER_LOGIN.")
	else
		print("RMB_DEBUG: self:RegisterEvent missing!")
	end

	-- Initialize mount pools
	self.mountPools = {
		flying = { superGroups = {}, families = {}, mountsByFamily = {} },
		ground = { superGroups = {}, families = {}, mountsByFamily = {} },
		underwater = { superGroups = {}, families = {}, mountsByFamily = {} },
	}
	print("RMB_DEBUG: OnInitialize END.")
end

function addon:OnEnable()
	print("RMB_DEBUG: OnEnable CALLED.")
	-- Initialize all mount system modules in proper dependency order
	self:InitializeAllMountModules()
	-- Initialize secure handlers last (they depend on mount modules)
	if self.InitializeSecureHandlers then
		self:InitializeSecureHandlers()
		print("RMB_DEBUG: OnEnable - Secure handlers initialization called")
	else
		print("RMB_DEBUG_ERROR: InitializeSecureHandlers function not found!")
	end

	print("RMB_DEBUG: OnEnable END.")
end

-- NEW: Centralized module initialization
function addon:InitializeAllMountModules()
	print("RMB_DEBUG: Initializing all mount system modules...")
	-- Initialize in dependency order
	if self.InitializeMountDataManager then
		self:InitializeMountDataManager()
	end

	if self.InitializeMountTooltips then
		self:InitializeMountTooltips()
	end

	if self.InitializeMountPreview then
		self:InitializeMountPreview()
	end

	if self.InitializeMountSummon then
		self:InitializeMountSummon()
	end

	-- UI components come last as they depend on everything else
	if self.InitializeMountUI then
		self:InitializeMountUI()
	end

	print("RMB_DEBUG: All mount modules initialized")
end

function addon:OnPlayerLoginAttemptProcessData(eventArg)
	print("RMB_EVENT_DEBUG: Handler OnPlayerLoginAttemptProcessData received Event '" .. tostring(eventArg) .. "'.")
	self.lastProcessingEventName = eventArg
	self:InitializeProcessedData()
	self.lastProcessingEventName = nil
	self:UnregisterEvent("PLAYER_LOGIN")
	print("RMB_EVENT_DEBUG: Unregistered PLAYER_LOGIN.")
end

-- ============================================================================
-- DYNAMIC GROUPING SYSTEM
-- ============================================================================
function addon:RebuildMountGrouping()
	-- Create temporary tables for the new organization
	local newSuperGroupMap = {}
	local newStandaloneFamilies = {}
	-- Get trait settings
	local treatMinorArmorAsDistinct = self:GetSetting("treatMinorArmorAsDistinct")
	local treatMajorArmorAsDistinct = self:GetSetting("treatMajorArmorAsDistinct")
	local treatModelVariantsAsDistinct = self:GetSetting("treatModelVariantsAsDistinct")
	local treatUniqueEffectsAsDistinct = self:GetSetting("treatUniqueEffectsAsDistinct")
	print("RMB_DYNAMIC: Rebuilding groups with settings - MinorArmor:", treatMinorArmorAsDistinct,
		"MajorArmor:", treatMajorArmorAsDistinct, "ModelVariants:", treatModelVariantsAsDistinct,
		"UniqueEffects:", treatUniqueEffectsAsDistinct)
	-- First pass: identify families with distinguishing traits
	local familiesWithDistinguishingTraits = {}
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local traits = mountInfo.traits or {}
		if (treatMinorArmorAsDistinct and traits.hasMinorArmor) or
				(treatMajorArmorAsDistinct and traits.hasMajorArmor) or
				(treatModelVariantsAsDistinct and traits.hasModelVariant) or
				(treatUniqueEffectsAsDistinct and traits.isUniqueEffect) then
			familiesWithDistinguishingTraits[familyName] = true
		end
	end

	-- Second pass: create the new grouping structure
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = mountInfo.superGroup
		local shouldBeStandalone = familiesWithDistinguishingTraits[familyName] or false
		if superGroup and not shouldBeStandalone then
			-- Keep in supergroup
			if not newSuperGroupMap[superGroup] then
				newSuperGroupMap[superGroup] = {}
			end

			local found = false
			for _, familyInGroup in ipairs(newSuperGroupMap[superGroup] or {}) do
				if familyInGroup == familyName then
					found = true
					break
				end
			end

			if not found then
				table.insert(newSuperGroupMap[superGroup], familyName)
			end
		else
			-- Make standalone
			newStandaloneFamilies[familyName] = true
		end
	end

	-- Replace the original grouping with the new one
	self.processedData.dynamicSuperGroupMap = newSuperGroupMap
	self.processedData.dynamicStandaloneFamilies = newStandaloneFamilies
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
		"Families in SuperGroups:", familiesInSGCount, "Standalone Families:", standaloneCount)
	-- Invalidate data manager cache since grouping changed
	if self.MountDataManager then
		self.MountDataManager:InvalidateCache("grouping_changed")
	end

	-- Update the UI
	if self.PopulateFamilyManagementUI then
		self:PopulateFamilyManagementUI()
	end
end

function addon:GetDynamicSuperGroup(familyName)
	if not familyName then return nil end

	-- Check if we have dynamic grouping data
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
		return nil
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

-- ============================================================================
-- SETTINGS MANAGEMENT
-- ============================================================================
function addon:GetSetting(key)
	if not (self.db and self.db.profile) then
		return dbDefaults.profile[key]
	end

	local v = self.db.profile[key]
	if v == nil and dbDefaults.profile[key] ~= nil then
		return dbDefaults.profile[key]
	end

	return v
end

function addon:SetSetting(key, value)
	if not (self.db and self.db.profile) then return end

	self.db.profile[key] = value
	print("RMB_SETTING: K:'" .. key .. "',V:'" .. tostring(value) .. "'")
	-- Notify all modules of setting changes
	self:NotifyModulesSettingChanged(key, value)
	-- Trigger grouping rebuild for trait-related settings
	if key:find("treat") and key:find("AsDistinct") then
		self:RebuildMountGrouping()
	end
end

function addon:NotifyModulesSettingChanged(key, value)
	if self.MountDataManager and self.MountDataManager.OnSettingChanged then
		self.MountDataManager:OnSettingChanged(key, value)
	end

	if self.MountSummon and self.MountSummon.OnSettingChanged then
		self.MountSummon:OnSettingChanged(key, value)
	end

	if self.MountTooltips and self.MountTooltips.OnSettingChanged then
		self.MountTooltips:OnSettingChanged(key, value)
	end

	if self.MountPreview and self.MountPreview.OnSettingChanged then
		self.MountPreview:OnSettingChanged(key, value)
	end
end

-- ============================================================================
-- SINGLE MOUNT FAMILY HELPERS
-- ============================================================================
function addon:IsSingleMountFamily(familyName)
	if not familyName or not self.processedData then
		return false, nil
	end

	-- Count collected mounts
	local collectedCount = (self.processedData.familyToMountIDsMap and
		self.processedData.familyToMountIDsMap[familyName] and
		#(self.processedData.familyToMountIDsMap[familyName])) or 0
	-- Count uncollected mounts
	local uncollectedCount = 0
	if self:GetSetting("showUncollectedMounts") then
		uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
			self.processedData.familyToUncollectedMountIDsMap[familyName] and
			#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
	end

	local totalCount = collectedCount + uncollectedCount
	if totalCount == 1 then
		-- Find the single mount ID
		local mountID = nil
		if collectedCount == 1 then
			mountID = self.processedData.familyToMountIDsMap[familyName][1]
		else
			mountID = self.processedData.familyToUncollectedMountIDsMap[familyName][1]
		end

		return true, mountID
	end

	return false, nil
end

function addon:GetMountFamilyFromMountKey(mountKey)
	-- Extract mount ID from "mount_123" format
	local mountID = mountKey:match("^mount_(%d+)$")
	if not mountID then
		return nil
	end

	mountID = tonumber(mountID)
	if not mountID then
		return nil
	end

	-- Find which family this mount belongs to
	if self.processedData.allCollectedMountFamilyInfo and
			self.processedData.allCollectedMountFamilyInfo[mountID] then
		return self.processedData.allCollectedMountFamilyInfo[mountID].familyName
	end

	if self.processedData.allUncollectedMountFamilyInfo and
			self.processedData.allUncollectedMountFamilyInfo[mountID] then
		return self.processedData.allUncollectedMountFamilyInfo[mountID].familyName
	end

	return nil
end

-- ============================================================================
-- WEIGHT AND GROUP MANAGEMENT
-- ============================================================================
function addon:GetGroupWeight(gk)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		return 0
	end

	local w = self.db.profile.groupWeights[gk]
	if w == nil then return 0 end

	return tonumber(w) or 0
end

function addon:SetGroupWeight(gk, w)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then return end

	local nw = tonumber(w)
	if nw == nil or nw < 0 or nw > 6 then
		print("RMB_SET: Invalid W for " .. tostring(gk))
		return
	end

	self.db.profile.groupWeights[gk] = nw
	print("RMB_SET:SetGW K:'" .. tostring(gk) .. "',W:" .. tostring(nw))
	-- Handle weight syncing for single-mount families
	self:SyncWeightForSingleMountFamily(gk, nw)
	-- Notify modules of weight changes (important for caches)
	self:NotifyModulesSettingChanged("groupWeights", nw)
end

function addon:SyncWeightForSingleMountFamily(groupKey, weight)
	local refreshNeeded = false
	-- Case 1: Family weight changed, sync to mount
	if not groupKey:match("^mount_") then
		local isSingleMount, mountID = self:IsSingleMountFamily(groupKey)
		if isSingleMount and mountID then
			local mountKey = "mount_" .. mountID
			-- Check if weight is actually different
			local currentMountWeight = self.db.profile.groupWeights[mountKey] or 0
			if currentMountWeight ~= weight then
				self.db.profile.groupWeights[mountKey] = weight
				print("RMB_SYNC: Family '" .. groupKey .. "' synced weight " .. weight .. " to mount '" .. mountKey .. "'")
				refreshNeeded = true
			end
		end
	else
		-- Case 2: Mount weight changed, sync to family (if it's a single-mount family)
		local familyName = self:GetMountFamilyFromMountKey(groupKey)
		if familyName then
			local isSingleMount, mountID = self:IsSingleMountFamily(familyName)
			if isSingleMount and mountID then
				-- Extract mount ID from groupKey to verify it matches
				local currentMountID = tonumber(groupKey:match("^mount_(%d+)$"))
				if currentMountID == mountID then
					-- Check if weight is actually different
					local currentFamilyWeight = self.db.profile.groupWeights[familyName] or 0
					if currentFamilyWeight ~= weight then
						self.db.profile.groupWeights[familyName] = weight
						print("RMB_SYNC: Mount '" .. groupKey .. "' synced weight " .. weight .. " to family '" .. familyName .. "'")
						refreshNeeded = true
					end
				end
			end
		end
	end

	-- If we synced something, trigger all the same refreshes that normal weight changes use
	if refreshNeeded then
		-- Invalidate data manager cache (important for weight-based operations)
		if self.MountDataManager and self.MountDataManager.InvalidateCache then
			self.MountDataManager:InvalidateCache("weight_sync")
		end

		-- Refresh mount pools so changes take effect immediately in summoning
		if self.RefreshMountPools then
			self:RefreshMountPools()
			print("RMB_SYNC: Refreshed mount pools for immediate sync effect")
		end
	end
end

function addon:IsGroupEnabled(gk)
	if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then
		return true
	end

	local ie = self.db.profile.groupEnabledStates[gk]
	if ie == nil then return true end

	return ie == true
end

function addon:SetGroupEnabled(gk, e)
	if not (self.db and self.db.profile and self.db.profile.groupEnabledStates) then return end

	local be = (e == true)
	self.db.profile.groupEnabledStates[gk] = be
	print("RMB_SET:SetGE K:'" .. tostring(gk) .. "',E:" .. tostring(be))
end

-- ============================================================================
-- CLEAN PUBLIC INTERFACE
-- ============================================================================
-- Main summoning interface
function addon:SummonRandomMount(useContext)
	if not self.RMB_DataReadyForUI then
		print("RMB_SUMMON: Data not ready for summoning")
		return false
	end

	if not self.MountSummon then
		print("RMB_ERROR: MountSummon module not initialized")
		return false
	end

	return self.MountSummon:SummonRandomMount(useContext)
end

-- Shorthand alias
function addon:SRM(useContext)
	return self:SummonRandomMount(useContext)
end

-- Clean method for refreshing mount pools
function addon:RefreshMountPools()
	print("RMB_POOLS: Refreshing mount pools from Core.lua")
	-- Rebuild dynamic grouping if needed
	self:RebuildMountGrouping()
	-- Refresh the mount pools if the module exists
	if self.MountSummon and self.MountSummon.RefreshMountPools then
		self.MountSummon:RefreshMountPools()
	end
end

-- Clean interface for secure handlers
function addon:GetSmartButtonAction()
	if self.MountSummon and self.MountSummon.GetSmartButtonAction then
		return self.MountSummon:GetSmartButtonAction()
	end

	return "/run RMB:SRM(true)" -- Fallback
end

function addon:NotifyModulesDataReady()
	print("RMB_DEBUG: Notifying modules that data is ready...")
	-- Notify each module that data is ready
	if self.MountDataManager and self.MountDataManager.OnDataReady then
		self.MountDataManager:OnDataReady()
		print("RMB_DEBUG: Notified MountDataManager")
	end

	if self.MountSummon and self.MountSummon.OnDataReady then
		self.MountSummon:OnDataReady()
		print("RMB_DEBUG: Notified MountSummon - this builds mount pools!")
	end

	if self.MountTooltips and self.MountTooltips.OnDataReady then
		self.MountTooltips:OnDataReady()
		print("RMB_DEBUG: Notified MountTooltips")
	end

	if self.MountPreview and self.MountPreview.OnDataReady then
		self.MountPreview:OnDataReady()
		print("RMB_DEBUG: Notified MountPreview")
	end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
function addon:CountTableEntries(tbl)
	local count = 0
	if tbl then
		for _ in pairs(tbl) do
			count = count + 1
		end
	end

	return count
end

function addon:GetFavoriteMountsForOptions()
	print("RMB_DEBUG_CORE: GetFavoriteMountsForOptions (placeholder)")
	return {
		p = {
			order = 1,
			type = "description",
			name = "MI list placeholder.",
		},
	}
end

print("RMB_DEBUG: Core.lua END (Refactored).")
