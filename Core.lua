-- Core.lua - Enhanced with Better Uncollected Mount Handling
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW
local dbDefaults = {
	profile = {
		overrideBlizzardButton = true,
		-- Summoning
		contextualSummoning = true,
		useDeterministicSummoning = false,
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
		showAllUncollectedGroups = true,
		filtersExpanded = false,
		filterSettings = nil,
		--
		expansionStates = {},
		defaultGroupWeight = 3,
		groupWeights = {},
		groupEnabledStates = {},
		familyOverrides = {},
		fmItemsPerPage = 14,
	},
}
print("RMB_DEBUG: Core.lua START (Enhanced Uncollected). Addon Name: " ..
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
addon.fmItemsPerPage = 14
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
	-- Initialize deterministic cache if not exists
	if not self.db.profile.deterministicCache then
		self.db.profile.deterministicCache = {
			flying = {
				unavailableGroups = {},
				pendingSummon = nil,
			},
			ground = {
				unavailableGroups = {},
				pendingSummon = nil,
			},
			underwater = {
				unavailableGroups = {},
				pendingSummon = nil,
			},
		}
	end

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
	self:InitializeBulkPrioritySystem()
	-- Load mount type data
	self.mountTypeTraits = MountTypeTraits_Input_Helper or {}
	self.mountIDtoTypeID = MountIDtoMountTypeID or {}
	-- Register for mount collection events
	self:RegisterMountCollectionEvents()
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

	if self.InitializeSearchSystem then
		self:InitializeSearchSystem()
	end

	if self.InitializeFilterSystem then
		self:InitializeFilterSystem()
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
-- MOUNT COLLECTION DETECTION
-- ============================================================================
function addon:RegisterMountCollectionEvents()
	print("RMB_EVENTS: Registering mount collection event handlers...")
	-- Register for mount collection events
	if self.RegisterEvent then
		self:RegisterEvent("NEW_MOUNT_ADDED", "OnNewMountAdded")
		print("RMB_EVENTS: Registered for mount collection events")
	else
		print("RMB_EVENTS_ERROR: Cannot register events - RegisterEvent not available")
	end
end

-- Event handler methods
function addon:OnNewMountAdded(eventName, mountID)
	print("RMB_EVENTS: NEW_MOUNT_ADDED - Mount ID:", mountID)
	self:HandleMountCollectionChange("new_mount", mountID)
end

-- Method to handle all mount collection changes:
function addon:HandleMountCollectionChange(changeType, mountID)
	print("RMB_EVENTS: Handling mount collection change:", changeType, mountID or "")
	-- Avoid processing during combat or loading
	if InCombatLockdown() then
		print("RMB_EVENTS: Deferring mount collection update - in combat")
		-- Could queue this for after combat if needed
		return
	end

	-- Use a brief delay to batch multiple rapid changes
	if self.mountCollectionUpdateTimer then
		self.mountCollectionUpdateTimer:Cancel()
	end

	self.mountCollectionUpdateTimer = C_Timer.NewTimer(1.5, function()
		self:RefreshMountDataAndUI(changeType, mountID)
	end)
end

-- Method to actually refresh the data and UI:
function addon:RefreshMountDataAndUI(changeType, mountID)
	print("RMB_EVENTS: Refreshing mount data and UI due to:", changeType)
	local startTime = debugprofilestop()
	-- Step 1: Reprocess mount data
	print("RMB_EVENTS: Reprocessing mount data...")
	self.lastProcessingEventName = changeType
	self:InitializeProcessedData() -- This rebuilds all the processed data
	self.lastProcessingEventName = nil
	-- Step 2: Rebuild mount pools
	if self.MountSummon and self.MountSummon.BuildMountPools then
		print("RMB_EVENTS: Rebuilding mount pools...")
		self.MountSummon:BuildMountPools()
	end

	-- Step 3: Invalidate data manager caches
	if self.MountDataManager and self.MountDataManager.InvalidateCache then
		print("RMB_EVENTS: Invalidating data manager cache...")
		self.MountDataManager:InvalidateCache("mount_collection_changed")
	end

	-- Step 4: Refresh UI
	if self.PopulateFamilyManagementUI then
		print("RMB_EVENTS: Refreshing family management UI...")
		self:PopulateFamilyManagementUI()
	end

	-- Step 5: Notify other modules
	self:NotifyModulesDataReady()
	local endTime = debugprofilestop()
	local elapsed = endTime - startTime
	print(string.format("RMB_EVENTS: Mount collection refresh completed in %.2fms", elapsed))
	-- Show user feedback for new mounts
	if changeType == "new_mount" and mountID then
		local mountName = C_MountJournal.GetMountInfoByID(mountID)
		if mountName then
			print("RMB: New mount added to collection: " .. mountName)
			-- Could show a more prominent message here if desired
		end
	end
end

-- ============================================================================
-- ENHANCED DYNAMIC GROUPING SYSTEM
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
	-- ENHANCED: Consider both collected AND uncollected mounts for trait analysis
	local familiesWithDistinguishingTraits = {}
	-- Check collected mounts
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

	-- ENHANCED: Also check uncollected mounts for traits
	if self.processedData.allUncollectedMountFamilyInfo then
		for mountID, mountInfo in pairs(self.processedData.allUncollectedMountFamilyInfo) do
			local familyName = mountInfo.familyName
			local traits = mountInfo.traits or {}
			if (treatMinorArmorAsDistinct and traits.hasMinorArmor) or
					(treatMajorArmorAsDistinct and traits.hasMajorArmor) or
					(treatModelVariantsAsDistinct and traits.hasModelVariant) or
					(treatUniqueEffectsAsDistinct and traits.isUniqueEffect) then
				familiesWithDistinguishingTraits[familyName] = true
			end
		end
	end

	-- Second pass: create the new grouping structure using ALL mounts (collected + uncollected)
	local allFamiliesProcessed = {}
	-- Process collected mounts
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = mountInfo.superGroup
		local shouldBeStandalone = familiesWithDistinguishingTraits[familyName] or false
		if not allFamiliesProcessed[familyName] then
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

			allFamiliesProcessed[familyName] = true
		end
	end

	-- ENHANCED: Also process uncollected mounts
	if self.processedData.allUncollectedMountFamilyInfo then
		for mountID, mountInfo in pairs(self.processedData.allUncollectedMountFamilyInfo) do
			local familyName = mountInfo.familyName
			local superGroup = mountInfo.superGroup
			local shouldBeStandalone = familiesWithDistinguishingTraits[familyName] or false
			if not allFamiliesProcessed[familyName] then
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

				allFamiliesProcessed[familyName] = true
			end
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
-- ENHANCED GROUP FILTERING FOR UNCOLLECTED MOUNTS
-- ============================================================================
-- Check if a family should be visible based on uncollected mount settings
function addon:ShouldShowFamily(familyName)
	local showUncollected = self:GetSetting("showUncollectedMounts")
	-- Count collected and uncollected mounts in this family
	local collectedCount = (self.processedData.familyToMountIDsMap and
		self.processedData.familyToMountIDsMap[familyName] and
		#(self.processedData.familyToMountIDsMap[familyName])) or 0
	local uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
		self.processedData.familyToUncollectedMountIDsMap[familyName] and
		#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
	local totalMounts = collectedCount + uncollectedCount
	-- Rule 1: If showing uncollected is disabled AND this is a single-mount family with only uncollected mount, hide it
	if not showUncollected and totalMounts == 1 and collectedCount == 0 then
		return false
	end

	-- Rule 2: If showing uncollected is disabled AND family has only uncollected mounts (any count), hide it
	if not showUncollected and collectedCount == 0 and uncollectedCount > 0 then
		-- Check the new setting for families with only uncollected mounts
		local showAllUncollected = self:GetSetting("showAllUncollectedGroups")
		return showAllUncollected
	end

	-- Rule 3: If showing uncollected is enabled, check the "all uncollected groups" setting
	if showUncollected and collectedCount == 0 and uncollectedCount > 0 then
		local showAllUncollected = self:GetSetting("showAllUncollectedGroups")
		return showAllUncollected
	end

	-- Show if family has any collected mounts
	return collectedCount > 0
end

-- Check if a supergroup should be visible based on uncollected mount settings
function addon:ShouldShowSuperGroup(superGroupName)
	-- Get families in this supergroup (using dynamic grouping)
	local familiesInSG = self:GetSuperGroupFamilies(superGroupName)
	if not familiesInSG or #familiesInSG == 0 then
		return false
	end

	local showUncollected = self:GetSetting("showUncollectedMounts")
	local showAllUncollected = self:GetSetting("showAllUncollectedGroups")
	local hasVisibleFamilies = false
	local totalCollectedInSG = 0
	local totalUncollectedInSG = 0
	-- Check each family in the supergroup
	for _, familyName in ipairs(familiesInSG) do
		-- Skip families that have been moved to standalone
		if not self:IsFamilyStandalone(familyName) then
			local collectedCount = (self.processedData.familyToMountIDsMap and
				self.processedData.familyToMountIDsMap[familyName] and
				#(self.processedData.familyToMountIDsMap[familyName])) or 0
			local uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
				self.processedData.familyToUncollectedMountIDsMap[familyName] and
				#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
			totalCollectedInSG = totalCollectedInSG + collectedCount
			totalUncollectedInSG = totalUncollectedInSG + uncollectedCount
			-- Check if this family should be visible
			if self:ShouldShowFamily(familyName) then
				hasVisibleFamilies = true
			end
		end
	end

	-- If no visible families, don't show the supergroup
	if not hasVisibleFamilies then
		return false
	end

	-- If supergroup has only uncollected mounts, check the setting
	if totalCollectedInSG == 0 and totalUncollectedInSG > 0 then
		return showUncollected and showAllUncollected
	end

	-- Show if supergroup has any collected mounts
	return totalCollectedInSG > 0
end

-- Check if a family has been moved to standalone due to trait settings
function addon:IsFamilyStandalone(familyName)
	-- First check dynamic standalone families
	if self.processedData.dynamicStandaloneFamilies then
		return self.processedData.dynamicStandaloneFamilies[familyName] == true
	end

	-- Fallback: check if family has no supergroup in original mapping
	if self.processedData.standaloneFamilyNames then
		return self.processedData.standaloneFamilyNames[familyName] == true
	end

	return false
end

-- Get families that should be displayed in a supergroup (respects dynamic grouping)
function addon:GetSuperGroupFamilies(superGroupKey)
	-- First try to use dynamic grouping if available
	if self.processedData.dynamicSuperGroupMap then
		return self.processedData.dynamicSuperGroupMap[superGroupKey] or {}
	end

	-- Fallback to original grouping
	if self.processedData.superGroupMap then
		return self.processedData.superGroupMap[superGroupKey] or {}
	end

	return {}
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

	-- Trigger UI refresh for uncollected mount settings
	if key == "showUncollectedMounts" or key == "showAllUncollectedGroups" then
		if self.PopulateFamilyManagementUI then
			self:PopulateFamilyManagementUI()
		end
	end
end

function addon:NotifyModulesSettingChanged(key, value)
	if self.MountDataManager and self.MountDataManager.OnSettingChanged then
		self.MountDataManager:OnSettingChanged(key, value)
	end

	if self.MountSummon and self.MountSummon.OnSettingChanged then
		self.MountSummon:OnSettingChanged(key, value)
	end

	if self.FilterSystem and self.FilterSystem.OnSettingChanged then
		self.FilterSystem:OnSettingChanged(key, value)
	end

	if self.MountTooltips and self.MountTooltips.OnSettingChanged then
		self.MountTooltips:OnSettingChanged(key, value)
	end

	if self.MountPreview and self.MountPreview.OnSettingChanged then
		self.MountPreview:OnSettingChanged(key, value)
	end

	-- FIXED: Add secure handler notifications
	if self.SecureHandlers and self.SecureHandlers.OnSettingChanged then
		self.SecureHandlers:OnSettingChanged(key, value)
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
		return 3 -- Default to "Normal" instead of "Never"
	end

	local w = self.db.profile.groupWeights[gk]
	if w == nil then return 3 end -- Default to "Normal" for unset groups

	return tonumber(w) or 3
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
-- BULK PRIORITY CHANGE FUNCTIONS (Add to Core.lua)
-- ============================================================================
-- Initialize bulk priority system
function addon:InitializeBulkPrioritySystem()
	self.pendingBulkOperation = nil
	print("RMB_BULK: Bulk priority system initialized")
end

-- Get all group keys currently visible on the page
function addon:GetCurrentPageGroupKeys()
	if not self.RMB_DataReadyForUI or not self.processedData then
		return {}
	end

	local groupKeys = {}
	-- Get displayable groups (same logic as UI)
	local allDisplayableGroups
	if self:IsSearchActive() then
		allDisplayableGroups = self:GetSearchResults()
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	else
		allDisplayableGroups = self:GetDisplayableGroups()
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	end

	if not allDisplayableGroups or #allDisplayableGroups == 0 then
		return {}
	end

	-- Apply pagination
	local totalGroups = #allDisplayableGroups
	local itemsPerPage = self:FMG_GetItemsPerPage()
	local currentPage = math.max(1, math.min(self.fmCurrentPage or 1, math.max(1, math.ceil(totalGroups / itemsPerPage))))
	-- Don't paginate search results
	if self:IsSearchActive() then
		itemsPerPage = math.min(totalGroups, 100)
		currentPage = 1
	end

	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, totalGroups)
	-- Collect all group keys for current page
	for i = startIndex, endIndex do
		local groupData = allDisplayableGroups[i]
		if groupData then
			-- Add the main group
			table.insert(groupKeys, {
				key = groupData.key,
				type = groupData.type,
			})
			-- If it's a supergroup, also add all families within it
			if groupData.type == "superGroup" then
				local familiesInSG = self:GetSuperGroupFamilies(groupData.key)
				for _, familyName in ipairs(familiesInSG) do
					if not self:IsFamilyStandalone(familyName) then
						table.insert(groupKeys, {
							key = familyName,
							type = "familyName",
						})
						-- Add all mounts in this family
						local mountIDs = self.processedData.familyToMountIDsMap and
								self.processedData.familyToMountIDsMap[familyName] or {}
						for _, mountID in ipairs(mountIDs) do
							table.insert(groupKeys, {
								key = "mount_" .. mountID,
								type = "mountID",
							})
						end

						-- Also add uncollected mounts if showing them
						if self:GetSetting("showUncollectedMounts") then
							local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
									self.processedData.familyToUncollectedMountIDsMap[familyName] or {}
							for _, mountID in ipairs(uncollectedIDs) do
								table.insert(groupKeys, {
									key = "mount_" .. mountID,
									type = "mountID",
								})
							end
						end
					end
				end
			elseif groupData.type == "familyName" then
				-- Add all mounts in this standalone family
				local mountIDs = self.processedData.familyToMountIDsMap and
						self.processedData.familyToMountIDsMap[groupData.key] or {}
				for _, mountID in ipairs(mountIDs) do
					table.insert(groupKeys, {
						key = "mount_" .. mountID,
						type = "mountID",
					})
				end

				-- Also add uncollected mounts if showing them
				if self:GetSetting("showUncollectedMounts") then
					local uncollectedIDs = self.processedData.familyToUncollectedMountIDsMap and
							self.processedData.familyToUncollectedMountIDsMap[groupData.key] or {}
					for _, mountID in ipairs(uncollectedIDs) do
						table.insert(groupKeys, {
							key = "mount_" .. mountID,
							type = "mountID",
						})
					end
				end
			end
		end
	end

	return groupKeys
end

-- Get all group keys in the entire database
function addon:GetAllDatabaseGroupKeys()
	if not self.RMB_DataReadyForUI or not self.processedData then
		return {}
	end

	local groupKeys = {}
	-- Add all supergroups
	local superGroupMap = self.processedData.dynamicSuperGroupMap or self.processedData.superGroupMap or {}
	for sgName, _ in pairs(superGroupMap) do
		table.insert(groupKeys, {
			key = sgName,
			type = "superGroup",
		})
	end

	-- Add all families (both standalone and those in supergroups)
	local allFamilies = {}
	-- Collect families from supergroups
	for _, familiesInSG in pairs(superGroupMap) do
		for _, familyName in ipairs(familiesInSG) do
			allFamilies[familyName] = true
		end
	end

	-- Collect standalone families
	local standaloneFamilies = self.processedData.dynamicStandaloneFamilies or self.processedData.standaloneFamilyNames or
			{}
	for familyName, _ in pairs(standaloneFamilies) do
		allFamilies[familyName] = true
	end

	-- Add all families
	for familyName, _ in pairs(allFamilies) do
		table.insert(groupKeys, {
			key = familyName,
			type = "familyName",
		})
	end

	-- Add all individual mounts (collected)
	if self.processedData.allCollectedMountFamilyInfo then
		for mountID, _ in pairs(self.processedData.allCollectedMountFamilyInfo) do
			table.insert(groupKeys, {
				key = "mount_" .. mountID,
				type = "mountID",
			})
		end
	end

	-- Add all individual uncollected mounts if they exist
	if self.processedData.allUncollectedMountFamilyInfo then
		for mountID, _ in pairs(self.processedData.allUncollectedMountFamilyInfo) do
			table.insert(groupKeys, {
				key = "mount_" .. mountID,
				type = "mountID",
			})
		end
	end

	return groupKeys
end

-- Apply bulk priority change to a list of group keys
function addon:ApplyBulkPriorityChange(groupKeys, newPriority, skipConfirmation)
	if not groupKeys or #groupKeys == 0 then
		print("RMB_BULK: No groups to update")
		return
	end

	-- Validate priority
	local priority = tonumber(newPriority)
	if not priority or priority < 0 or priority > 6 then
		print("RMB_BULK: Invalid priority value:", newPriority)
		return
	end

	print("RMB_BULK: ApplyBulkPriorityChange called - " ..
		#groupKeys .. " items, priority " .. priority .. ", skipConfirmation: " .. tostring(skipConfirmation))
	-- For large operations, store the data and show a confirmation message instead of StaticPopup
	if not skipConfirmation and #groupKeys > 50 then
		local priorityNames = {
			[0] = "Never",
			[1] = "Occasional",
			[2] = "Uncommon",
			[3] = "Normal",
			[4] = "Common",
			[5] = "Often",
			[6] = "Always",
		}
		-- Store the pending operation
		self.pendingBulkOperation = {
			groupKeys = groupKeys,
			priority = priority,
			priorityName = priorityNames[priority] or tostring(priority),
		}
		print("RMB_BULK: Storing pending bulk operation for " ..
			#groupKeys .. " items to " .. (priorityNames[priority] or tostring(priority)))
		-- Trigger UI refresh to show the confirmation option
		if self.PopulateFamilyManagementUI then
			self:PopulateFamilyManagementUI()
		end

		return
	end

	-- Perform the bulk update directly (no confirmation needed)
	print("RMB_BULK: Performing direct bulk update (no confirmation)")
	self:PerformBulkPriorityUpdate(groupKeys, priority)
end

-- Execute the pending bulk operation
function addon:ExecutePendingBulkOperation()
	if not self.pendingBulkOperation then
		print("RMB_BULK: No pending operation to execute")
		return
	end

	local operation = self.pendingBulkOperation
	self.pendingBulkOperation = nil -- Clear it first
	print("RMB_BULK: Executing pending bulk operation - " ..
		#operation.groupKeys .. " items to priority " .. operation.priority)
	self:PerformBulkPriorityUpdate(operation.groupKeys, operation.priority)
	-- Refresh UI to remove confirmation section and show updated weights
	if self.PopulateFamilyManagementUI then
		self:PopulateFamilyManagementUI()
	end
end

-- Cancel the pending bulk operation
function addon:CancelPendingBulkOperation()
	if self.pendingBulkOperation then
		print("RMB_BULK: Cancelling pending bulk operation")
		self.pendingBulkOperation = nil
		-- Refresh UI to remove confirmation buttons
		if self.PopulateFamilyManagementUI then
			self:PopulateFamilyManagementUI()
		end
	end
end

-- Actually perform the bulk priority update
function addon:PerformBulkPriorityUpdate(groupKeys, priority)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		print("RMB_BULK: Database not available")
		return
	end

	local updateCount = 0
	local syncNeeded = false
	print("RMB_BULK: Starting bulk priority update - " .. #groupKeys .. " items to priority " .. priority)
	-- Disable weight syncing temporarily to avoid redundant operations
	local originalSyncFunction = self.SyncWeightForSingleMountFamily
	self.SyncWeightForSingleMountFamily = function() end
	-- Update all weights
	for _, groupInfo in ipairs(groupKeys) do
		local currentWeight = self.db.profile.groupWeights[groupInfo.key] or 0
		if currentWeight ~= priority then
			self.db.profile.groupWeights[groupInfo.key] = priority
			updateCount = updateCount + 1
			-- Check if this change needs syncing (single-mount families)
			if not groupInfo.key:match("^mount_") then
				local isSingleMount, mountID = self:IsSingleMountFamily(groupInfo.key)
				if isSingleMount then
					syncNeeded = true
				end
			else
				local familyName = self:GetMountFamilyFromMountKey(groupInfo.key)
				if familyName then
					local isSingleMount = self:IsSingleMountFamily(familyName)
					if isSingleMount then
						syncNeeded = true
					end
				end
			end
		end
	end

	-- Restore syncing function
	self.SyncWeightForSingleMountFamily = originalSyncFunction
	-- Perform all syncing at once if needed
	if syncNeeded then
		self:PerformBulkWeightSync(groupKeys, priority)
	end

	print("RMB_BULK: Updated " .. updateCount .. " items to priority " .. priority)
	-- Always refresh after bulk update
	self:NotifyModulesSettingChanged("groupWeights", priority)
	-- Refresh mount pools
	if self.MountSummon and self.MountSummon.RefreshMountPools then
		self.MountSummon:RefreshMountPools()
	end

	-- Show completion message
	print("RMB_BULK: Bulk priority update completed - " .. updateCount .. " items updated")
end

-- Perform weight syncing for single-mount families after bulk update
function addon:PerformBulkWeightSync(groupKeys, priority)
	if not (self.db and self.db.profile and self.db.profile.groupWeights) then
		return
	end

	local syncCount = 0
	-- Track families and mounts we've already processed to avoid duplicates
	local processedFamilies = {}
	local processedMounts = {}
	for _, groupInfo in ipairs(groupKeys) do
		-- Case 1: Family weight changed, sync to mount (if single-mount family)
		if not groupInfo.key:match("^mount_") and not processedFamilies[groupInfo.key] then
			processedFamilies[groupInfo.key] = true
			local isSingleMount, mountID = self:IsSingleMountFamily(groupInfo.key)
			if isSingleMount and mountID then
				local mountKey = "mount_" .. mountID
				if not processedMounts[mountKey] then
					processedMounts[mountKey] = true
					local currentMountWeight = self.db.profile.groupWeights[mountKey] or 0
					if currentMountWeight ~= priority then
						self.db.profile.groupWeights[mountKey] = priority
						syncCount = syncCount + 1
					end
				end
			end
		end

		-- Case 2: Mount weight changed, sync to family (if single-mount family)
		if groupInfo.key:match("^mount_") and not processedMounts[groupInfo.key] then
			processedMounts[groupInfo.key] = true
			local familyName = self:GetMountFamilyFromMountKey(groupInfo.key)
			if familyName and not processedFamilies[familyName] then
				local isSingleMount, mountID = self:IsSingleMountFamily(familyName)
				if isSingleMount and mountID then
					local currentMountID = tonumber(groupInfo.key:match("^mount_(%d+)$"))
					if currentMountID == mountID then
						processedFamilies[familyName] = true
						local currentFamilyWeight = self.db.profile.groupWeights[familyName] or 0
						if currentFamilyWeight ~= priority then
							self.db.profile.groupWeights[familyName] = priority
							syncCount = syncCount + 1
						end
					end
				end
			end
		end
	end

	if syncCount > 0 then
		print("RMB_BULK: Synced weights for " .. syncCount .. " single-mount family pairs")
	end
end

-- Create StaticPopup for bulk confirmation
StaticPopupDialogs["RMB_BULK_PRIORITY_CONFIRM"] = {
	text = "Set priority for %d items to '%s'?\n\nThis will update supergroups, families, and individual mounts.",
	button1 = "Yes",
	button2 = "Cancel",
	OnAccept = function(self, data)
		print("RMB_BULK: StaticPopup OnAccept called")
		if data then
			print("RMB_BULK: Data exists - groupKeys: " ..
				tostring(data.groupKeys and #data.groupKeys) .. ", priority: " .. tostring(data.priority))
			if data.groupKeys and data.priority then
				print("RMB_BULK: Calling PerformBulkPriorityUpdate from popup")
				addon:PerformBulkPriorityUpdate(data.groupKeys, data.priority)
				print("RMB_BULK: PerformBulkPriorityUpdate completed, triggering UI refresh")
				-- Use a more immediate refresh approach
				addon:PopulateFamilyManagementUI()
			else
				print("RMB_BULK: ERROR - Missing data in popup callback")
			end
		else
			print("RMB_BULK: ERROR - No data passed to popup callback")
		end
	end,
	OnCancel = function()
		print("RMB_BULK: Bulk priority change cancelled")
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
-- ============================================================================
-- DISPLAYABLE GROUPS LOGIC WITH ENHANCED FILTERING
-- ============================================================================
function addon:GetDisplayableGroups()
	if not self.RMB_DataReadyForUI or not self.processedData then
		print("RMB_DISPLAYABLE: Data not ready")
		return {}
	end

	local displayableGroups = {}
	local showUncollected = self:GetSetting("showUncollectedMounts")
	local showAllUncollected = self:GetSetting("showAllUncollectedGroups")
	print("RMB_DISPLAYABLE: Building displayable groups with settings - showUncollected:", showUncollected,
		"showAllUncollected:", showAllUncollected)
	-- Add supergroups (using dynamic grouping)
	local superGroupMap = self.processedData.dynamicSuperGroupMap or self.processedData.superGroupMap or {}
	for sgName, familiesInSG in pairs(superGroupMap) do
		if self:ShouldShowSuperGroup(sgName) then
			-- Count mounts in this supergroup
			local totalCollected, totalUncollected = 0, 0
			for _, familyName in ipairs(familiesInSG) do
				-- Skip families that have been moved to standalone
				if not self:IsFamilyStandalone(familyName) then
					local collectedCount = (self.processedData.familyToMountIDsMap and
						self.processedData.familyToMountIDsMap[familyName] and
						#(self.processedData.familyToMountIDsMap[familyName])) or 0
					local uncollectedCount = 0
					if showUncollected then
						uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
							self.processedData.familyToUncollectedMountIDsMap[familyName] and
							#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
					end

					totalCollected = totalCollected + collectedCount
					totalUncollected = totalUncollected + uncollectedCount
				end
			end

			if totalCollected > 0 or totalUncollected > 0 then
				table.insert(displayableGroups, {
					key = sgName,
					type = "superGroup",
					displayName = sgName,
					mountCount = totalCollected,
					uncollectedCount = totalUncollected,
				})
			end
		end
	end

	-- Add standalone families (using dynamic grouping)
	local standaloneFamilies = self.processedData.dynamicStandaloneFamilies or self.processedData.standaloneFamilyNames or
			{}
	for familyName, _ in pairs(standaloneFamilies) do
		if self:ShouldShowFamily(familyName) then
			local collectedCount = (self.processedData.familyToMountIDsMap and
				self.processedData.familyToMountIDsMap[familyName] and
				#(self.processedData.familyToMountIDsMap[familyName])) or 0
			local uncollectedCount = 0
			if showUncollected then
				uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
					self.processedData.familyToUncollectedMountIDsMap[familyName] and
					#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
			end

			if collectedCount > 0 or uncollectedCount > 0 then
				table.insert(displayableGroups, {
					key = familyName,
					type = "familyName",
					displayName = familyName,
					mountCount = collectedCount,
					uncollectedCount = uncollectedCount,
				})
			end
		end
	end

	-- Also add families that are still in supergroups but should be shown (edge case handling)
	if self.processedData.superGroupMap then
		for sgName, familiesInOriginalSG in pairs(self.processedData.superGroupMap) do
			for _, familyName in ipairs(familiesInOriginalSG) do
				-- Check if this family is standalone in dynamic grouping but wasn't added yet
				if self:IsFamilyStandalone(familyName) and self:ShouldShowFamily(familyName) then
					-- Check if we already added this family
					local alreadyAdded = false
					for _, group in ipairs(displayableGroups) do
						if group.key == familyName and group.type == "familyName" then
							alreadyAdded = true
							break
						end
					end

					if not alreadyAdded then
						local collectedCount = (self.processedData.familyToMountIDsMap and
							self.processedData.familyToMountIDsMap[familyName] and
							#(self.processedData.familyToMountIDsMap[familyName])) or 0
						local uncollectedCount = 0
						if showUncollected then
							uncollectedCount = (self.processedData.familyToUncollectedMountIDsMap and
								self.processedData.familyToUncollectedMountIDsMap[familyName] and
								#(self.processedData.familyToUncollectedMountIDsMap[familyName])) or 0
						end

						if collectedCount > 0 or uncollectedCount > 0 then
							table.insert(displayableGroups, {
								key = familyName,
								type = "familyName",
								displayName = familyName,
								mountCount = collectedCount,
								uncollectedCount = uncollectedCount,
							})
						end
					end
				end
			end
		end
	end

	-- Sort groups alphabetically
	table.sort(displayableGroups, function(a, b)
		return (a.displayName or a.key) < (b.displayName or b.key)
	end)
	local totalGroups = #displayableGroups
	local collectedGroups = 0
	local uncollectedOnlyGroups = 0
	for _, group in ipairs(displayableGroups) do
		if group.mountCount > 0 then
			collectedGroups = collectedGroups + 1
		elseif group.uncollectedCount > 0 then
			uncollectedOnlyGroups = uncollectedOnlyGroups + 1
		end
	end

	print("RMB_DISPLAYABLE: Built " ..
		totalGroups ..
		" displayable groups (" .. collectedGroups .. " with collected, " .. uncollectedOnlyGroups .. " uncollected-only)")
	return displayableGroups
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

	if self.FilterSystem and self.FilterSystem.OnDataReady then
		self.FilterSystem:OnDataReady()
		print("RMB_DEBUG: Notified FilterSystem")
	end

	if self.MountTooltips and self.MountTooltips.OnDataReady then
		self.MountTooltips:OnDataReady()
		print("RMB_DEBUG: Notified MountTooltips")
	end

	if self.MountPreview and self.MountPreview.OnDataReady then
		self.MountPreview:OnDataReady()
		print("RMB_DEBUG: Notified MountPreview")
	end

	-- Also notify about mount collection changes
	if self.MountDataManager and self.MountDataManager.OnMountCollectionChanged then
		self.MountDataManager:OnMountCollectionChanged()
	end

	if self.MountSummon and self.MountSummon.OnMountCollectionChanged then
		self.MountSummon:OnMountCollectionChanged()
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

print("RMB_DEBUG: Core.lua END (Enhanced Uncollected).")
