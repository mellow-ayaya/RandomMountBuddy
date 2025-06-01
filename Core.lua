-- Core.lua - Enhanced with Better Uncollected Mount Handling
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW
local dbDefaults = {
	profile = {
		useSuperGrouping = true,
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
		showUncollectedMounts = true,
		showAllUncollectedGroups = false,
		filterSettings = nil,
		defaultGroupWeight = 3,
		groupWeights = {},
		traitOverrides = {},
		groupEnabledStates = {},
		familyOverrides = {},
		fmItemsPerPage = 14,
		-- FavoriteSync settings
		favoriteSync_enableFavoriteSync = true,
		favoriteSync_syncOnLogin = true,
		favoriteSync_favoriteWeight = 4,
		favoriteSync_nonFavoriteWeight = 2,
		favoriteSync_syncFamilyWeights = true,
		favoriteSync_syncSuperGroupWeights = true,
		favoriteSync_favoriteWeightMode = "set",
		favoriteSync_lastSyncTime = 0,
		-- Supergroup customization
		superGroupOverrides = {}, -- { ["FamilyName"] = "SuperGroupName" or false or nil }
		superGroupDefinitions = {}, -- { ["SGName"] = { displayName="...", isCustom=true/false, isRenamed=true/false } }
		deletedSuperGroups = {},  -- { ["SGName"] = true }
		-- Mount customization
		separatedMounts = {},     -- { [mountID] = { familyName="Separated_Mount_123", customTraits={}, originalFamily="Dragons" } }
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

function addon:InitializeUIState()
	print("RMB_UI_STATE: Initializing fresh UI state...")
	-- Initialize memory-only UI state (resets on every reload)
	self.uiState = {
		-- Filter panel expansion state (should not persist)
		filtersExpanded = false,

		-- Group expansion states (should not persist)
		expansionStates = {},

		-- Current page (could persist but better UX to reset)
		currentPage = 1,
	}
	print("RMB_UI_STATE: Fresh UI state initialized")
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
	self:ProcessSeparatedMounts()
	-- Rebuild mount grouping for trait-based filtering
	self:RebuildMountGrouping()
	-- Handle supergroup data migration for addon updates
	self:MigrateSuperGroupData()
	-- Notify all modules that data is ready
	self:NotifyModulesDataReady()
	-- Initialize UI last
	if self.PopulateFamilyManagementUI then
		self:PopulateFamilyManagementUI()
	end
end

function addon:ProcessSeparatedMounts()
	if not (self.db and self.db.profile and self.db.profile.separatedMounts) then
		return
	end

	local separationCount = self:CountTableEntries(self.db.profile.separatedMounts)
	if separationCount == 0 then
		return
	end

	print("RMB_SEPARATION: Processing " .. separationCount .. " separated mounts")
	-- First pass: Remove all separated mounts from their original families
	for mountID, separationData in pairs(self.db.profile.separatedMounts) do
		local mountIDNum = tonumber(mountID)
		if mountIDNum then
			local originalFamilyName = separationData.originalFamily
			-- Remove from original family (collected)
			if originalFamilyName and self.processedData.familyToMountIDsMap[originalFamilyName] then
				for i = #self.processedData.familyToMountIDsMap[originalFamilyName], 1, -1 do
					if self.processedData.familyToMountIDsMap[originalFamilyName][i] == mountIDNum then
						table.remove(self.processedData.familyToMountIDsMap[originalFamilyName], i)
						print("RMB_SEPARATION: Removed collected mount " ..
							mountIDNum .. " from original family " .. originalFamilyName)
						break -- Important: break after removing to avoid processing the same mount multiple times
					end
				end

				-- Clean up empty family
				if #self.processedData.familyToMountIDsMap[originalFamilyName] == 0 then
					self.processedData.familyToMountIDsMap[originalFamilyName] = nil
					print("RMB_SEPARATION: Cleaned up empty collected family: " .. originalFamilyName)
				end
			end

			-- Remove from original family (uncollected)
			if originalFamilyName and self.processedData.familyToUncollectedMountIDsMap[originalFamilyName] then
				for i = #self.processedData.familyToUncollectedMountIDsMap[originalFamilyName], 1, -1 do
					if self.processedData.familyToUncollectedMountIDsMap[originalFamilyName][i] == mountIDNum then
						table.remove(self.processedData.familyToUncollectedMountIDsMap[originalFamilyName], i)
						print("RMB_SEPARATION: Removed uncollected mount " ..
							mountIDNum .. " from original family " .. originalFamilyName)
						break
					end
				end

				-- Clean up empty family
				if #self.processedData.familyToUncollectedMountIDsMap[originalFamilyName] == 0 then
					self.processedData.familyToUncollectedMountIDsMap[originalFamilyName] = nil
					print("RMB_SEPARATION: Cleaned up empty uncollected family: " .. originalFamilyName)
				end
			end

			-- Remove from supergroup mappings
			if self.processedData.superGroupToMountIDsMap then
				for sgName, mountIds in pairs(self.processedData.superGroupToMountIDsMap) do
					for i = #mountIds, 1, -1 do
						if mountIds[i] == mountIDNum then
							table.remove(mountIds, i)
							break
						end
					end
				end
			end

			if self.processedData.superGroupToUncollectedMountIDsMap then
				for sgName, mountIds in pairs(self.processedData.superGroupToUncollectedMountIDsMap) do
					for i = #mountIds, 1, -1 do
						if mountIds[i] == mountIDNum then
							table.remove(mountIds, i)
							break
						end
					end
				end
			end
		end
	end

	-- Second pass: Create new families for separated mounts
	for mountID, separationData in pairs(self.db.profile.separatedMounts) do
		local mountIDNum = tonumber(mountID)
		if mountIDNum then
			local newFamilyName = separationData.familyName
			-- Determine if mount is collected or uncollected
			local isCollected = self.processedData.allCollectedMountFamilyInfo[mountIDNum] ~= nil
			if isCollected then
				-- Create new collected family (ensure it doesn't already exist)
				if not self.processedData.familyToMountIDsMap[newFamilyName] then
					self.processedData.familyToMountIDsMap[newFamilyName] = {}
				end

				-- Only add if not already present (avoid duplicates)
				local alreadyExists = false
				for _, existingMountID in ipairs(self.processedData.familyToMountIDsMap[newFamilyName]) do
					if existingMountID == mountIDNum then
						alreadyExists = true
						break
					end
				end

				if not alreadyExists then
					table.insert(self.processedData.familyToMountIDsMap[newFamilyName], mountIDNum)
					print("RMB_SEPARATION: Added collected mount " .. mountIDNum .. " to new family " .. newFamilyName)
				end

				-- Update mount info
				if self.processedData.allCollectedMountFamilyInfo[mountIDNum] then
					self.processedData.allCollectedMountFamilyInfo[mountIDNum].familyName = newFamilyName
					self.processedData.allCollectedMountFamilyInfo[mountIDNum].superGroup = nil -- Start as standalone
					-- Apply preserved original traits if no custom traits are set
					if separationData.originalTraits and not (separationData.customTraits and next(separationData.customTraits)) then
						self.processedData.allCollectedMountFamilyInfo[mountIDNum].traits = separationData.originalTraits
						print("RMB_SEPARATION: Applied original traits to separated collected mount " .. mountIDNum)
					elseif separationData.customTraits and next(separationData.customTraits) then
						self.processedData.allCollectedMountFamilyInfo[mountIDNum].traits = separationData.customTraits
						print("RMB_SEPARATION: Applied custom traits to separated collected mount " .. mountIDNum)
					end
				end
			else
				-- Create new uncollected family
				if not self.processedData.familyToUncollectedMountIDsMap[newFamilyName] then
					self.processedData.familyToUncollectedMountIDsMap[newFamilyName] = {}
				end

				-- Only add if not already present
				local alreadyExists = false
				for _, existingMountID in ipairs(self.processedData.familyToUncollectedMountIDsMap[newFamilyName]) do
					if existingMountID == mountIDNum then
						alreadyExists = true
						break
					end
				end

				if not alreadyExists then
					table.insert(self.processedData.familyToUncollectedMountIDsMap[newFamilyName], mountIDNum)
					print("RMB_SEPARATION: Added uncollected mount " .. mountIDNum .. " to new family " .. newFamilyName)
				end

				-- Update mount info
				if self.processedData.allUncollectedMountFamilyInfo[mountIDNum] then
					self.processedData.allUncollectedMountFamilyInfo[mountIDNum].familyName = newFamilyName
					self.processedData.allUncollectedMountFamilyInfo[mountIDNum].superGroup = nil
					-- Apply preserved original traits if no custom traits are set
					if separationData.originalTraits and not (separationData.customTraits and next(separationData.customTraits)) then
						self.processedData.allUncollectedMountFamilyInfo[mountIDNum].traits = separationData.originalTraits
						print("RMB_SEPARATION: Applied original traits to separated uncollected mount " .. mountIDNum)
					elseif separationData.customTraits and next(separationData.customTraits) then
						self.processedData.allUncollectedMountFamilyInfo[mountIDNum].traits = separationData.customTraits
						print("RMB_SEPARATION: Applied custom traits to separated uncollected mount " .. mountIDNum)
					end
				end
			end

			-- Add to standalone families
			self.processedData.standaloneFamilyNames[newFamilyName] = true
			print("RMB_SEPARATION: Added " .. newFamilyName .. " to standalone families")
		end
	end

	print("RMB_SEPARATION: Separation processing completed")
end

-- ============================================================================
-- INITIALIZATION FUNCTIONS
-- ============================================================================
function addon:OnInitialize()
	print("RMB_DEBUG: OnInitialize CALLED.")
	self:InitializeUIState()
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
		self:CleanupLegacyUIState()
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

-- Centralized module initialization
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

	if self.InitializeMountSeparationManager then
		self:InitializeMountSeparationManager()
	end

	if self.InitializeFavoriteSync then
		self:InitializeFavoriteSync()
	end

	-- Initialize SuperGroupManager AFTER core systems are ready
	if self.InitializeSuperGroupManager then
		self:InitializeSuperGroupManager()
		print("RMB_DEBUG: SuperGroupManager initialized in proper order")
	end

	if self.InitializeMountSeparationManager then
		self:InitializeMountSeparationManager()
		print("RMB_DEBUG: MountSeparationManager initialized in proper order")
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
	-- FIX: First, preserve all separated families as standalone
	if self.db and self.db.profile and self.db.profile.separatedMounts then
		for mountID, separationData in pairs(self.db.profile.separatedMounts) do
			local newFamilyName = separationData.familyName
			if newFamilyName then
				newStandaloneFamilies[newFamilyName] = true
				print("RMB_DYNAMIC: Preserving separated family: " .. newFamilyName)
			end
		end
	end

	-- Get trait settings
	local treatMinorArmorAsDistinct = self:GetSetting("treatMinorArmorAsDistinct")
	local treatMajorArmorAsDistinct = self:GetSetting("treatMajorArmorAsDistinct")
	local treatModelVariantsAsDistinct = self:GetSetting("treatModelVariantsAsDistinct")
	local treatUniqueEffectsAsDistinct = self:GetSetting("treatUniqueEffectsAsDistinct")
	print("RMB_DYNAMIC: Rebuilding groups with settings - MinorArmor:", treatMinorArmorAsDistinct,
		"MajorArmor:", treatMajorArmorAsDistinct, "ModelVariants:", treatModelVariantsAsDistinct,
		"UniqueEffects:", treatUniqueEffectsAsDistinct)
	-- UPDATED: Use effective traits instead of original traits
	local familiesWithDistinguishingTraits = {}
	-- Get all unique families
	local allFamilies = {}
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		allFamilies[mountInfo.familyName] = true
	end

	if self.processedData.allUncollectedMountFamilyInfo then
		for mountID, mountInfo in pairs(self.processedData.allUncollectedMountFamilyInfo) do
			allFamilies[mountInfo.familyName] = true
		end
	end

	-- FIX: Include separated families
	if self.db and self.db.profile and self.db.profile.separatedMounts then
		for mountID, separationData in pairs(self.db.profile.separatedMounts) do
			allFamilies[separationData.familyName] = true
		end
	end

	-- Check each family using effective traits
	for familyName, _ in pairs(allFamilies) do
		local effectiveTraits = self:GetEffectiveTraits(familyName)
		if (treatMinorArmorAsDistinct and effectiveTraits.hasMinorArmor) or
				(treatMajorArmorAsDistinct and effectiveTraits.hasMajorArmor) or
				(treatModelVariantsAsDistinct and effectiveTraits.hasModelVariant) or
				(treatUniqueEffectsAsDistinct and effectiveTraits.isUniqueEffect) then
			familiesWithDistinguishingTraits[familyName] = true
			-- FIX: Add debug for separated families
			if self.db and self.db.profile and self.db.profile.separatedMounts then
				for mountID, separationData in pairs(self.db.profile.separatedMounts) do
					if separationData.familyName == familyName then
						print("RMB_DYNAMIC: Separated family '" ..
							familyName .. "' has distinguishing traits, will remain standalone")
						break
					end
				end
			end
		end
	end

	if self.processedData.allUncollectedMountFamilyInfo then
		for mountID, mountInfo in pairs(self.processedData.allUncollectedMountFamilyInfo) do
			allFamilies[mountInfo.familyName] = true
		end
	end

	-- FIX: Also include families from standaloneFamilyNames (including separated families)
	if self.processedData.standaloneFamilyNames then
		for familyName, _ in pairs(self.processedData.standaloneFamilyNames) do
			allFamilies[familyName] = true
		end
	end

	-- Check each family using effective traits
	for familyName, _ in pairs(allFamilies) do
		local effectiveTraits = self:GetEffectiveTraits(familyName)
		if (treatMinorArmorAsDistinct and effectiveTraits.hasMinorArmor) or
				(treatMajorArmorAsDistinct and effectiveTraits.hasMajorArmor) or
				(treatModelVariantsAsDistinct and effectiveTraits.hasModelVariant) or
				(treatUniqueEffectsAsDistinct and effectiveTraits.isUniqueEffect) then
			familiesWithDistinguishingTraits[familyName] = true
		end

		-- FIX: Separated families should always be standalone regardless of traits
		if self.db and self.db.profile and self.db.profile.separatedMounts then
			for mountID, separationData in pairs(self.db.profile.separatedMounts) do
				if separationData.familyName == familyName then
					-- Force separated families to be standalone
					newStandaloneFamilies[familyName] = true
					break
				end
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

	-- ============================================================================
	-- APPLY SUPERGROUP OVERRIDES (after trait-based regrouping)
	-- ============================================================================
	print("RMB_DYNAMIC: Applying supergroup overrides...")
	local overrideCount = 0
	-- Apply individual family overrides
	if self.db and self.db.profile and self.db.profile.superGroupOverrides then
		for familyName, overrideSG in pairs(self.db.profile.superGroupOverrides) do
			if overrideSG == false then
				-- Force family to be standalone
				newStandaloneFamilies[familyName] = true
				-- Remove from any supergroup
				for sgName, families in pairs(newSuperGroupMap) do
					for i = #families, 1, -1 do
						if families[i] == familyName then
							table.remove(families, i)
							print("RMB_DYNAMIC: Moved " .. familyName .. " from " .. sgName .. " to standalone (override)")
							overrideCount = overrideCount + 1
						end
					end
				end
			elseif type(overrideSG) == "string" and overrideSG ~= "" then
				-- Move family to specific supergroup
				-- Remove from current location first
				newStandaloneFamilies[familyName] = nil
				for sgName, families in pairs(newSuperGroupMap) do
					for i = #families, 1, -1 do
						if families[i] == familyName then
							table.remove(families, i)
						end
					end
				end

				-- Add to target supergroup
				if not newSuperGroupMap[overrideSG] then
					newSuperGroupMap[overrideSG] = {}
				end

				-- Check if family already in target supergroup
				local alreadyExists = false
				for _, existingFamily in ipairs(newSuperGroupMap[overrideSG]) do
					if existingFamily == familyName then
						alreadyExists = true
						break
					end
				end

				if not alreadyExists then
					table.insert(newSuperGroupMap[overrideSG], familyName)
					print("RMB_DYNAMIC: Moved " .. familyName .. " to " .. overrideSG .. " (override)")
					overrideCount = overrideCount + 1
				end
			end
		end
	end

	-- Handle deleted supergroups
	if self.db and self.db.profile and self.db.profile.deletedSuperGroups then
		for sgName, isDeleted in pairs(self.db.profile.deletedSuperGroups) do
			if isDeleted and newSuperGroupMap[sgName] then
				-- Move all families from deleted supergroup to standalone
				local familiesInDeletedSG = newSuperGroupMap[sgName]
				for _, familyName in ipairs(familiesInDeletedSG) do
					-- Only move to standalone if not already overridden
					if not (self.db.profile.superGroupOverrides and
								self.db.profile.superGroupOverrides[familyName]) then
						newStandaloneFamilies[familyName] = true
						print("RMB_DYNAMIC: Moved " .. familyName .. " to standalone (deleted supergroup: " .. sgName .. ")")
						overrideCount = overrideCount + 1
					end
				end

				-- Remove the deleted supergroup
				newSuperGroupMap[sgName] = nil
				print("RMB_DYNAMIC: Removed deleted supergroup: " .. sgName)
			end
		end
	end

	-- Clean up empty supergroups created by overrides
	local emptySuperGroups = {}
	for sgName, families in pairs(newSuperGroupMap) do
		if #families == 0 then
			table.insert(emptySuperGroups, sgName)
		end
	end

	for _, sgName in ipairs(emptySuperGroups) do
		newSuperGroupMap[sgName] = nil
		print("RMB_DYNAMIC: Removed empty supergroup: " .. sgName)
	end

	if overrideCount > 0 then
		print("RMB_DYNAMIC: Applied " .. overrideCount .. " supergroup overrides")
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
function addon:SetSetting(key, value)
	if not (self.db and self.db.profile) then return end

	-- Handle UI state that should be memory-only
	if key == "filtersExpanded" then
		-- Store in memory instead of database
		if self.uiState then
			self.uiState.filtersExpanded = value
		end

		print("RMB_SETTING: UI State - filtersExpanded:", value)
		return
	end

	-- Handle normal persistent settings
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

function addon:GetSetting(key)
	-- Handle UI state keys
	if key == "filtersExpanded" then
		return self.uiState and self.uiState.filtersExpanded or false
	end

	-- Handle normal persistent settings
	if not (self.db and self.db.profile) then
		return dbDefaults.profile[key]
	end

	local v = self.db.profile[key]
	if v == nil and dbDefaults.profile[key] ~= nil then
		return dbDefaults.profile[key]
	end

	return v
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

	-- ADD THESE LINES: Notify FavoriteSync
	if self.FavoriteSync and self.FavoriteSync.OnSettingChanged then
		self.FavoriteSync:OnSettingChanged(key, value)
	end

	-- Handle supergroup override changes
	if key == "superGroupOverrides" or key == "superGroupDefinitions" or key == "deletedSuperGroups" then
		print("RMB_SETTING: Supergroup configuration changed, triggering rebuild")
		self:RebuildMountGrouping()
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
		local familyName = self.processedData.allCollectedMountFamilyInfo[mountID].familyName
		-- Debug output for separated mounts
		if self.db and self.db.profile and self.db.profile.separatedMounts and self.db.profile.separatedMounts[mountID] then
			print("RMB_SYNC_DEBUG: Found separated mount " .. mountID .. " in family '" .. familyName .. "'")
		end

		return familyName
	end

	if self.processedData.allUncollectedMountFamilyInfo and
			self.processedData.allUncollectedMountFamilyInfo[mountID] then
		local familyName = self.processedData.allUncollectedMountFamilyInfo[mountID].familyName
		-- Debug output for separated mounts
		if self.db and self.db.profile and self.db.profile.separatedMounts and self.db.profile.separatedMounts[mountID] then
			print("RMB_SYNC_DEBUG: Found separated uncollected mount " .. mountID .. " in family '" .. familyName .. "'")
		end

		return familyName
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
				-- FIX: Add debug for separated mounts
				if self.db and self.db.profile and self.db.profile.separatedMounts and self.db.profile.separatedMounts[mountID] then
					print("RMB_SYNC: ^^^ This was a separated mount sync")
				end

				refreshNeeded = true
			end
		else
			-- Debug why sync didn't happen
			print("RMB_SYNC_DEBUG: Family '" ..
				groupKey .. "' - isSingleMount: " .. tostring(isSingleMount) .. ", mountID: " .. tostring(mountID))
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
						-- FIX: Add debug for separated mounts
						if self.db and self.db.profile and self.db.profile.separatedMounts and self.db.profile.separatedMounts[currentMountID] then
							print("RMB_SYNC: ^^^ This was a separated mount family sync")
						end

						refreshNeeded = true
					end
				end
			else
				-- Debug why sync didn't happen
				print("RMB_SYNC_DEBUG: Mount '" ..
					groupKey ..
					"' family '" ..
					familyName .. "' - isSingleMount: " .. tostring(isSingleMount) .. ", mountID: " .. tostring(mountID))
			end
		else
			print("RMB_SYNC_DEBUG: Could not find family for mount '" .. groupKey .. "'")
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

-- NEW FUNCTION: Get all group keys that match current filters/search (across all pages)
function addon:GetAllFilteredGroupKeys()
	if not self.RMB_DataReadyForUI or not self.processedData then
		return {}
	end

	local groupKeys = {}
	-- Get the same filtered groups that the UI uses (this respects search and filters)
	local allDisplayableGroups
	if self:IsSearchActive() then
		-- Search is active - get search results and apply filters to them
		allDisplayableGroups = self:GetSearchResults()
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	else
		-- No search active - get all groups and apply filters
		allDisplayableGroups = self:GetDisplayableGroups()
		if self:AreFiltersActive() then
			allDisplayableGroups = self:GetFilteredGroups(allDisplayableGroups)
		end
	end

	if not allDisplayableGroups or #allDisplayableGroups == 0 then
		return {}
	end

	-- Extract all group keys from ALL filtered groups (no pagination)
	for _, groupData in ipairs(allDisplayableGroups) do
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

	return groupKeys
end

-- MODIFIED FUNCTION: Update the bulk priority change logic
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
	-- For large operations, store the data and show a confirmation message
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

	-- FIXED: Sort groups with custom supergroups first, then alphabetically
	table.sort(displayableGroups, function(a, b)
		-- Get custom status for both groups
		local aIsCustom = false
		local bIsCustom = false
		if a.type == "superGroup" and self.db and self.db.profile and self.db.profile.superGroupDefinitions then
			local aDef = self.db.profile.superGroupDefinitions[a.key]
			aIsCustom = aDef and aDef.isCustom or false
		end

		if b.type == "superGroup" and self.db and self.db.profile and self.db.profile.superGroupDefinitions then
			local bDef = self.db.profile.superGroupDefinitions[b.key]
			bIsCustom = bDef and bDef.isCustom or false
		end

		-- Custom supergroups come first
		if aIsCustom and not bIsCustom then
			return true
		elseif not aIsCustom and bIsCustom then
			return false
		else
			-- Within same category (both custom or both non-custom), sort alphabetically
			return (a.displayName or a.key) < (b.displayName or b.key)
		end
	end)
	return displayableGroups
end

-- ============================================================================
-- TRAIT OVERRIDE SYSTEM
-- ============================================================================
-- Get effective traits for a family (original + user overrides)
function addon:GetEffectiveTraits(familyName)
	if not familyName then return {} end

	-- Start with original traits
	local originalTraits = {}
	local mountIDs = self.processedData.familyToMountIDsMap and
			self.processedData.familyToMountIDsMap[familyName]
	if not mountIDs or #mountIDs == 0 then
		mountIDs = self.processedData.familyToUncollectedMountIDsMap and
				self.processedData.familyToUncollectedMountIDsMap[familyName]
	end

	if mountIDs and #mountIDs > 0 then
		local mountID = mountIDs[1]
		local mountInfo = self.processedData.allCollectedMountFamilyInfo and
				self.processedData.allCollectedMountFamilyInfo[mountID]
		if not mountInfo then
			mountInfo = self.processedData.allUncollectedMountFamilyInfo and
					self.processedData.allUncollectedMountFamilyInfo[mountID]
		end

		if mountInfo and mountInfo.traits then
			originalTraits = mountInfo.traits
		end
	end

	-- Apply user overrides
	local effectiveTraits = {}
	for k, v in pairs(originalTraits) do
		effectiveTraits[k] = v
	end

	if self.db and self.db.profile and self.db.profile.traitOverrides then
		local overrides = self.db.profile.traitOverrides[familyName]
		if overrides then
			for k, v in pairs(overrides) do
				effectiveTraits[k] = v
			end
		end
	end

	return effectiveTraits
end

-- Set a trait for a family
function addon:SetFamilyTrait(familyName, traitName, value)
	if not (familyName and traitName) then return end

	if not (self.db and self.db.profile) then return end

	-- Initialize traitOverrides if needed
	if not self.db.profile.traitOverrides then
		self.db.profile.traitOverrides = {}
	end

	-- Initialize family overrides if needed
	if not self.db.profile.traitOverrides[familyName] then
		self.db.profile.traitOverrides[familyName] = {}
	end

	-- Get original trait value
	local originalTraits = self:GetOriginalTraits(familyName)
	local originalValue = originalTraits[traitName] or false
	-- If setting back to original value, remove override
	if value == originalValue then
		self.db.profile.traitOverrides[familyName][traitName] = nil
		-- Clean up empty override table
		local hasOverrides = false
		for _ in pairs(self.db.profile.traitOverrides[familyName]) do
			hasOverrides = true
			break
		end

		if not hasOverrides then
			self.db.profile.traitOverrides[familyName] = nil
		end
	else
		-- Store the override
		self.db.profile.traitOverrides[familyName][traitName] = value
	end

	print("RMB_TRAITS: Set " .. familyName .. "." .. traitName .. " = " .. tostring(value))
	-- Notify modules of trait changes
	self:NotifyModulesTraitChanged(familyName, traitName, value)
	-- Trigger regrouping since traits affect grouping
	self:RebuildMountGrouping()
end

-- Get original (unmodified) traits for a family
function addon:GetOriginalTraits(familyName)
	if not familyName then return {} end

	local originalTraits = {}
	-- FIX: Check if this is a separated family first
	if self.db and self.db.profile and self.db.profile.separatedMounts then
		for mountID, separationData in pairs(self.db.profile.separatedMounts) do
			if separationData.familyName == familyName then
				-- Return the preserved original traits
				if separationData.originalTraits then
					return separationData.originalTraits
				end

				break
			end
		end
	end

	-- Fall back to getting traits from mount data
	local mountIDs = self.processedData.familyToMountIDsMap and
			self.processedData.familyToMountIDsMap[familyName]
	if not mountIDs or #mountIDs == 0 then
		mountIDs = self.processedData.familyToUncollectedMountIDsMap and
				self.processedData.familyToUncollectedMountIDsMap[familyName]
	end

	if mountIDs and #mountIDs > 0 then
		local mountID = mountIDs[1]
		local mountInfo = self.processedData.allCollectedMountFamilyInfo and
				self.processedData.allCollectedMountFamilyInfo[mountID]
		if not mountInfo then
			mountInfo = self.processedData.allUncollectedMountFamilyInfo and
					self.processedData.allUncollectedMountFamilyInfo[mountID]
		end

		if mountInfo and mountInfo.traits then
			originalTraits = mountInfo.traits
		end
	end

	return originalTraits
end

-- Check if a family has trait overrides
function addon:HasTraitOverrides(familyName)
	if not (self.db and self.db.profile and self.db.profile.traitOverrides) then
		return false
	end

	local overrides = self.db.profile.traitOverrides[familyName]
	if not overrides then return false end

	for _ in pairs(overrides) do
		return true
	end

	return false
end

-- Reset traits for a family to original values
function addon:ResetFamilyTraits(familyName)
	if not (self.db and self.db.profile and self.db.profile.traitOverrides) then
		return
	end

	self.db.profile.traitOverrides[familyName] = nil
	print("RMB_TRAITS: Reset traits for " .. familyName .. " to original values")
	-- Notify modules
	self:NotifyModulesTraitChanged(familyName, "all", nil)
	-- Trigger regrouping
	self:RebuildMountGrouping()
end

-- New notification system for trait changes
function addon:NotifyModulesTraitChanged(familyName, traitName, value)
	print("RMB_TRAITS: Notifying modules of trait change for " .. familyName)
	-- Notify MountDataManager to invalidate cache
	if self.MountDataManager and self.MountDataManager.InvalidateTraitCache then
		self.MountDataManager:InvalidateTraitCache(familyName)
	end

	-- Notify MountSummon to rebuild pools since grouping might change
	if self.MountSummon and self.MountSummon.RefreshMountPools then
		-- Use a brief delay to avoid rebuilding pools multiple times during bulk trait changes
		if self.traitChangeTimer then
			self.traitChangeTimer:Cancel()
		end

		self.traitChangeTimer = C_Timer.NewTimer(0.5, function()
			self.MountSummon:RefreshMountPools()
			print("RMB_TRAITS: Refreshed mount pools after trait changes")
		end)
	end

	-- Other modules can be notified here as needed
	-- Example:
	-- if self.FilterSystem and self.FilterSystem.OnTraitChanged then
	--     self.FilterSystem:OnTraitChanged(familyName, traitName, value)
	-- end
end

-- Utility function to get trait override statistics (for debugging/admin)
function addon:GetTraitOverrideStats()
	if not (self.db and self.db.profile and self.db.profile.traitOverrides) then
		return {
			totalFamiliesWithOverrides = 0,
			totalOverrides = 0,
			familiesWithOverrides = {},
		}
	end

	local stats = {
		totalFamiliesWithOverrides = 0,
		totalOverrides = 0,
		familiesWithOverrides = {},
	}
	for familyName, overrides in pairs(self.db.profile.traitOverrides) do
		if overrides and next(overrides) then
			stats.totalFamiliesWithOverrides = stats.totalFamiliesWithOverrides + 1
			stats.familiesWithOverrides[familyName] = {}
			for traitName, value in pairs(overrides) do
				stats.totalOverrides = stats.totalOverrides + 1
				stats.familiesWithOverrides[familyName][traitName] = value
			end
		end
	end

	return stats
end

-- ============================================================================
-- SUPERGROUP OVERRIDE HELPER FUNCTIONS
-- ============================================================================
-- Get effective supergroup for a family (considers overrides)
function addon:GetEffectiveSuperGroup(familyName)
	if not familyName then return nil end

	-- Check for user override first
	if self.db and self.db.profile and self.db.profile.superGroupOverrides then
		local override = self.db.profile.superGroupOverrides[familyName]
		if override == false then
			return nil -- Explicitly standalone
		elseif type(override) == "string" and override ~= "" then
			-- Check if target supergroup is deleted
			if self.db.profile.deletedSuperGroups and
					self.db.profile.deletedSuperGroups[override] then
				return nil -- Target supergroup is deleted, treat as standalone
			end

			return override
		end
	end

	-- Fall back to dynamic grouping
	return self:GetDynamicSuperGroup(familyName)
end

-- Get display name for supergroup (considers custom names)
function addon:GetSuperGroupDisplayName(superGroupName)
	if not superGroupName then return nil end

	-- Check for custom display name
	if self.db and self.db.profile and self.db.profile.superGroupDefinitions then
		local customDef = self.db.profile.superGroupDefinitions[superGroupName]
		if customDef and customDef.displayName then
			return customDef.displayName
		end
	end

	-- Return original name
	return superGroupName
end

-- Check if supergroup is custom (user-created)
function addon:IsSuperGroupCustom(superGroupName)
	if not superGroupName or not self.db or not self.db.profile then
		return false
	end

	local customDef = self.db.profile.superGroupDefinitions[superGroupName]
	return customDef and customDef.isCustom == true
end

-- Check if supergroup has been renamed
function addon:IsSuperGroupRenamed(superGroupName)
	if not superGroupName or not self.db or not self.db.profile then
		return false
	end

	local customDef = self.db.profile.superGroupDefinitions[superGroupName]
	if not customDef then
		return false
	end

	-- Only consider it renamed if:
	-- 1. The isRenamed flag is true, AND
	-- 2. The display name is actually different from the original name
	if customDef.isRenamed then
		-- For original supergroups, the original name is the superGroupName itself
		if self.processedData and self.processedData.superGroupMap and
				self.processedData.superGroupMap[superGroupName] then
			return customDef.displayName ~= superGroupName
		end

		-- For custom supergroups, isRenamed should always be false anyway
		return customDef.isCustom ~= true
	end

	return false
end

-- Check if supergroup is deleted
function addon:IsSuperGroupDeleted(superGroupName)
	if not superGroupName or not self.db or not self.db.profile then
		return false
	end

	return self.db.profile.deletedSuperGroups[superGroupName] == true
end

-- Get the original supergroup (before any trait-based or user modifications)
function addon:GetOriginalSuperGroup(familyName)
	if not familyName then return nil end

	-- Look in the original supergroup map (before any dynamic changes)
	if self.processedData and self.processedData.superGroupMap then
		for sgName, families in pairs(self.processedData.superGroupMap) do
			for _, familyInSG in ipairs(families) do
				if familyInSG == familyName then
					return sgName
				end
			end
		end
	end

	return nil -- Family was originally standalone
end

-- Check if family is separated due to trait strictness settings
function addon:IsFamilySeparatedByStrictness(familyName)
	if not familyName then return false end

	local originalSG = self:GetOriginalSuperGroup(familyName)
	local dynamicSG = self:GetDynamicSuperGroup(familyName)
	-- If original had a supergroup but dynamic doesn't, it was separated by strictness
	return originalSG ~= nil and dynamicSG == nil
end

-- Get separation reason for display
function addon:GetFamilySeparationReason(familyName)
	if not self:IsFamilySeparatedByStrictness(familyName) then
		return nil
	end

	-- Check which trait settings caused the separation
	local effectiveTraits = self:GetEffectiveTraits(familyName)
	local reasons = {}
	if self:GetSetting("treatMinorArmorAsDistinct") and effectiveTraits.hasMinorArmor then
		table.insert(reasons, "Minor Armor")
	end

	if self:GetSetting("treatMajorArmorAsDistinct") and effectiveTraits.hasMajorArmor then
		table.insert(reasons, "Major Armor")
	end

	if self:GetSetting("treatModelVariantsAsDistinct") and effectiveTraits.hasModelVariant then
		table.insert(reasons, "Model Variant")
	end

	if self:GetSetting("treatUniqueEffectsAsDistinct") and effectiveTraits.isUniqueEffect then
		table.insert(reasons, "Unique Effect")
	end

	if #reasons > 0 then
		return "Separated due to: " .. table.concat(reasons, ", ")
	end

	return "Separated due to trait distinctness settings"
end

-- ============================================================================
-- SUPERGROUP MIGRATION HANDLING
-- ============================================================================
-- Handle supergroup data migration when addon updates
function addon:MigrateSuperGroupData()
	if not (self.db and self.db.profile) then
		return
	end

	print("RMB_MIGRATION: Checking supergroup data migration...")
	-- Clean up invalid overrides (families that no longer exist)
	if self.db.profile.superGroupOverrides then
		local invalidOverrides = {}
		for familyName, _ in pairs(self.db.profile.superGroupOverrides) do
			-- Check if family still exists in processed data
			local familyExists = false
			if self.processedData and self.processedData.allCollectedMountFamilyInfo then
				for _, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
					if mountInfo.familyName == familyName then
						familyExists = true
						break
					end
				end
			end

			if not familyExists and self.processedData and self.processedData.allUncollectedMountFamilyInfo then
				for _, mountInfo in pairs(self.processedData.allUncollectedMountFamilyInfo) do
					if mountInfo.familyName == familyName then
						familyExists = true
						break
					end
				end
			end

			if not familyExists then
				table.insert(invalidOverrides, familyName)
			end
		end

		-- Remove invalid overrides
		for _, familyName in ipairs(invalidOverrides) do
			self.db.profile.superGroupOverrides[familyName] = nil
			print("RMB_MIGRATION: Removed invalid override for non-existent family: " .. familyName)
		end
	end

	-- Mark new supergroups as known (so we can detect future new ones)
	if not self.db.profile.knownSuperGroups then
		self.db.profile.knownSuperGroups = {}
	end

	-- Update known supergroups list with current supergroups
	if self.processedData and self.processedData.superGroupMap then
		for sgName, _ in pairs(self.processedData.superGroupMap) do
			self.db.profile.knownSuperGroups[sgName] = true
		end
	end

	print("RMB_MIGRATION: Supergroup data migration completed")
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

	if self.FavoriteSync and self.FavoriteSync.OnDataReady then
		self.FavoriteSync:OnDataReady()
		print("RMB_DEBUG: Notified FavoriteSync")
	end

	-- Refresh SuperGroupManager UI when data is ready
	if self.SuperGroupManager then
		print("RMB_DEBUG: Refreshing SuperGroup Manager UI with fresh data...")
		-- Use a small delay to ensure all other modules are ready
		C_Timer.After(0.1, function()
			self.SuperGroupManager:PopulateSuperGroupManagementUI()
			self.SuperGroupManager:PopulateFamilyAssignmentUI()
			print("RMB_DEBUG: SuperGroup Manager UI refreshed")
		end)
	end

	-- Refresh MountSeparationManager UI when data is ready
	if self.MountSeparationManager and self.MountSeparationManager.OnDataReady then
		self.MountSeparationManager:OnDataReady()
		print("RMB_DEBUG: Notified MountSeparationManager")
	end

	-- Also notify about mount collection changes
	if self.MountDataManager and self.MountDataManager.OnMountCollectionChanged then
		self.MountDataManager:OnMountCollectionChanged()
	end

	if self.MountSummon and self.MountSummon.OnMountCollectionChanged then
		self.MountSummon:OnMountCollectionChanged()
	end
end

function addon:CleanupLegacyUIState()
	if not (self.db and self.db.profile) then
		return
	end

	-- Remove legacy UI state from saved variables
	if self.db.profile.filtersExpanded ~= nil then
		print("RMB_CLEANUP: Removing legacy filtersExpanded from saved variables")
		self.db.profile.filtersExpanded = nil
	end

	if self.db.profile.expansionStates ~= nil then
		print("RMB_CLEANUP: Removing legacy expansionStates from saved variables")
		self.db.profile.expansionStates = nil
	end

	print("RMB_CLEANUP: Legacy UI state cleanup completed")
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
