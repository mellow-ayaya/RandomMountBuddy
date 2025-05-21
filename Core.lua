-- Core.lua
local addonNameFromToc, addonTableProvidedByWoW = ...
RandomMountBuddy = addonTableProvidedByWoW
local dbDefaults = {
	profile = {
		overrideBlizzardButton = true,
		-- Summoning
		contextualSummoning = true,
		-- Class Spells
		useTravelFormWhileMoving = true,
		keepTravelFormActive = true,
		useGhostWolfWhileMoving = true,
		keepGhostWolfActive = true,
		useZenFlightWhileMoving = true,
		keepZenFlightActive = true,
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
		fmItemsPerPage = 15,
	},
}
print("RMB_DEBUG: Core.lua START. Addon Name: " .. tostring(addonNameFromToc) .. ". Time: " .. tostring(time()))
local LibAceAddon = LibStub("AceAddon-3.0")
local LibAceDB = LibStub("AceDB-3.0")
local LibAceConsole = LibStub("AceConsole-3.0")
local LibAceEvent = LibStub("AceEvent-3.0")
local LibAceConfigRegistry = LibStub("AceConfigRegistry-3.0")
if not LibAceAddon then
	print("RMB_DEBUG: FATAL - AceAddon-3.0 not found!")
	return
end

if not LibAceDB then print("RMB_DEBUG: WARNING - AceDB-3.0 not found!") end

if not LibAceConsole then print("RMB_DEBUG: WARNING - AceConsole-3.0 not found!") end

if not LibAceEvent then print("RMB_DEBUG: WARNING - AceEvent-3.0 not found!") end

if not LibAceConfigRegistry then print("RMB_DEBUG: WARNING - AceConfigRegistry-3.0 not found!") end

local addon
local success, result = pcall(function()
	LibAceAddon:NewAddon(RandomMountBuddy, addonNameFromToc, "AceEvent-3.0", "AceConsole-3.0")
	addon = RandomMountBuddy
end)
if not success then
	print("RMB_DEBUG: ERROR during NewAddon: " .. tostring(result)); return
end

print("RMB_DEBUG: NewAddon SUCCEEDED. Addon valid: " ..
	tostring(addon and addon.GetName and addon:GetName() or "Unknown/Error"))
addon.RMB_DataReadyForUI = false -- Flag
addon.fmCurrentPage = 1          -- Initialize current page here
addon.fmItemsPerPage = 15        -- Initialize items per page here (will be loaded from DB in OnInitialize)
BINDING_HEADER_RANDOMMOUNTBUDDY = "Random Mount Buddy"
BINDING_NAME_CLICK_RMBSmartButton_LeftButton = "Smart Mount/Travel Form"
function addon:GetFamilyInfoForMountID(mountID)
	if not mountID then return nil end; local id = tonumber(mountID); if not id then return nil end

	local modelPath = self.MountToModelPath and self.MountToModelPath[id]; if not modelPath then return nil end

	local familyDef = self.FamilyDefinitions and self.FamilyDefinitions[modelPath]; if not familyDef then return nil end

	return {
		familyName = familyDef.familyName,
		superGroup = familyDef.superGroup,
		traits = familyDef.traits or {},
		modelPath =
				modelPath,
	}
end

function addon:InitializeProcessedData()
	local eventNameForLog = self.lastProcessingEventName or "Manual Call or Unknown Event"
	print("RMB_DEBUG_DATA: Initializing Processed Data (Event: " .. eventNameForLog .. ")...")
	-- Initialize with additional data structures for uncollected mounts
	self.processedData = {
		superGroupMap = {},
		standaloneFamilyNames = {},
		familyToMountIDsMap = {},
		superGroupToMountIDsMap = {},
		allCollectedMountFamilyInfo = {},
		-- New tables for uncollected mounts
		familyToUncollectedMountIDsMap = {},
		superGroupToUncollectedMountIDsMap = {},
		allUncollectedMountFamilyInfo = {},
	}
	if not C_MountJournal or not C_MountJournal.GetMountIDs then
		print("RMB_DEBUG_DATA: C_MountJournal API missing!"); return
	end

	local allMountIDs = C_MountJournal.GetMountIDs(); if not allMountIDs then
		print("RMB_DEBUG_DATA: GetMountIDs nil"); return
	end

	print("RMB_DEBUG_DATA: GetMountIDs found " .. #allMountIDs .. " IDs.")
	local collectedCount, uncollectedCount, processedCount, scannedCount = 0, 0, 0, 0
	for _, mountID in ipairs(allMountIDs) do
		scannedCount = scannedCount + 1
		local name, _, _, _, isUsable, _, isFavorite, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
		if type(name) == "string" and type(isCollected) == "boolean" then
			if scannedCount <= 10 then
				print("RMB_DATA_SCAN: ID:" ..
					tostring(mountID) .. ",N:" .. tostring(name) .. ",C:" .. tostring(isCollected) ..
					",U:" .. tostring(isUsable))
			end

			local familyInfo = self:GetFamilyInfoForMountID(mountID)
			if familyInfo and familyInfo.familyName then
				processedCount = processedCount + 1
				-- Create common mount info regardless of collection status
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
						if not self.processedData.superGroupMap[sg] then
							self.processedData.superGroupMap[sg] = {}
						end

						local found = false
						for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do
							if eFN == fn then
								found = true
								break
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
						-- Ensure supergroup exists in the map
						if not self.processedData.superGroupMap[sg] then
							self.processedData.superGroupMap[sg] = {}
						end

						-- Make sure family is in supergroup list (if not already added by a collected mount)
						local found = false
						for _, eFN in ipairs(self.processedData.superGroupMap[sg]) do
							if eFN == fn then
								found = true
								break
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
		else
			if scannedCount <= 10 then
				print("RMB_DATA_SCAN_WARN: Bad data for ID " ..
					tostring(mountID) .. ", NameType:" .. type(name) .. ", CollType:" .. type(isCollected))
			end
		end
	end

	print("RMB_DEBUG_DATA: Scanned:" ..
		scannedCount .. ", APICollected:" .. collectedCount .. ", APIUncollected:" .. uncollectedCount ..
		", ProcessedFamilyInfo:" .. processedCount)
	local sgC = 0; for k in pairs(self.processedData.superGroupMap) do sgC = sgC + 1 end

	print("RMB_DEBUG_DATA: SuperGroups:" .. sgC)
	local fnC = 0; for k in pairs(self.processedData.standaloneFamilyNames) do fnC = fnC + 1 end

	print("RMB_DEBUG_DATA: StandaloneFams:" .. fnC)
	print("RMB_DEBUG_DATA: Init COMPLETE.")
	self.RMB_DataReadyForUI = true; print("RMB_DEBUG_DATA: Set RMB_DataReadyForUI to true.")
	self:PopulateFamilyManagementUI() -- Populate UI now that data is ready
	self:RebuildMountGrouping()
end

function addon:OnPlayerLoginAttemptProcessData(eventArg)
	print("RMB_EVENT_DEBUG: Handler OnPlayerLoginAttemptProcessData received Event '" .. tostring(eventArg) .. "'.")
	self.lastProcessingEventName = eventArg; self:InitializeProcessedData(); self.lastProcessingEventName = nil
	self:UnregisterEvent("PLAYER_LOGIN"); print("RMB_EVENT_DEBUG: Unregistered PLAYER_LOGIN.")
end

function addon:OnInitialize()
	print("RMB_DEBUG: OnInitialize CALLED.")
	if RandomMountBuddy_PreloadData then
		self.MountToModelPath = RandomMountBuddy_PreloadData.MountToModelPath or {}; self.FamilyDefinitions =
				RandomMountBuddy_PreloadData.FamilyDefinitions or {}; RandomMountBuddy_PreloadData = nil; print(
			"RMB_DEBUG: PreloadData processed.")
	else
		self.MountToModelPath = {}; self.FamilyDefinitions = {}; print("RMB_DEBUG: PreloadData nil.")
	end

	local mtpC = 0; for _ in pairs(self.MountToModelPath) do mtpC = mtpC + 1 end; print(
		"RMB_DEBUG: MountToModelPath entries: " .. mtpC)
	local fdC = 0; for _ in pairs(self.FamilyDefinitions) do fdC = fdC + 1 end; print(
		"RMB_DEBUG: FamilyDefinitions entries: " .. fdC)
	self.processedData = { superGroupMap = {}, standaloneFamilyNames = {}, familyToMountIDsMap = {}, superGroupToMountIDsMap = {}, allCollectedMountFamilyInfo = {} }
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
	if LibAceDB then
		self.db = LibAceDB:New("RandomMountBuddy_SavedVars", dbDefaults, true); print("RMB_DEBUG: AceDB:New done.");
		if self.db and self.db.profile then
			print("RMB_DEBUG: Initial 'overrideBlizzardButton': " .. tostring(self.db.profile.overrideBlizzardButton))
			if self.db.profile.fmItemsPerPage then
				self.fmItemsPerPage = self.db.profile.fmItemsPerPage; print("RMB_DEBUG: Loaded fmItemsPerPage: " ..
					tostring(self.fmItemsPerPage))
			end
		else
			print("RMB_DEBUG: self.db.profile nil!")
		end
	else
		print("RMB_DEBUG: LibAceDB missing.")
	end

	if LibAceConsole then
		self:RegisterChatCommand("rmb", "SlashCommandHandler"); self:RegisterChatCommand("randommountbuddy",
			"SlashCommandHandler"); print("RMB_DEBUG: Slash commands registered.")
	else
		print("RMB_DEBUG: LibAceConsole missing.")
	end

	if self.RegisterEvent then
		self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLoginAttemptProcessData"); print(
			"RMB_DEBUG: Registered for PLAYER_LOGIN.")
	else
		print("RMB_DEBUG: self:RegisterEvent missing!")
	end

	if LibAceConsole then
		self:RegisterChatCommand("rmm", function()
			print("RMB_SECURE: 'rmm' slash command executed from Core.lua")
			if self.ClickSecureButton then
				self:ClickSecureButton()
			else
				print("RMB_SECURE_ERROR: ClickSecureButton method not found!")
			end
		end)
		print("RMB_DEBUG: Registered 'rmm' slash command from Core.lua")
	end

	-- Initialize mount pools data structure
	self.mountPools = {
		flying = { superGroups = {}, families = {}, mountsByFamily = {} },
		ground = { superGroups = {}, families = {}, mountsByFamily = {} },
		underwater = { superGroups = {}, families = {}, mountsByFamily = {} },
	}
	print("RMB_DEBUG: OnInitialize END.")
end

-- Helper function to count table entries
function addon:CountTableEntries(tbl)
	local count = 0
	if tbl then
		for _ in pairs(tbl) do
			count = count + 1
		end
	end

	return count
end

function addon:OnEnable()
	print("RMB_DEBUG: OnEnable CALLED.")
	-- Initialize the mount UI system
	self:InitializeMountUI()
	print("RMB_DEBUG: OnEnable - About to initialize secure handlers")
	if self.InitializeSecureHandlers then
		self:InitializeSecureHandlers()
		print("RMB_DEBUG: OnEnable - Secure handlers initialization called")
	else
		print("RMB_DEBUG_ERROR: InitializeSecureHandlers function not found!")
	end

	print("RMB_DEBUG: OnEnable END.")
end

function addon:GetFavoriteMountsForOptions()
	print("RMB_DEBUG_CORE: GetFavoriteMountsForOptions (placeholder)"); return { p = { order = 1, type = "description", name = "MI list placeholder." } }
end

-- Add this function to Core.lua
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
	-- First pass: Process all mounts to identify which families have distinguishing traits
	local familiesWithDistinguishingTraits = {}
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local traits = mountInfo.traits or {}
		-- Check if this family has any "distinguishing" traits
		if (treatMinorArmorAsDistinct and traits.hasMinorArmor) or
				(treatMajorArmorAsDistinct and traits.hasMajorArmor) or
				(treatModelVariantsAsDistinct and traits.hasModelVariant) or
				(treatUniqueEffectsAsDistinct and traits.isUniqueEffect) then
			familiesWithDistinguishingTraits[familyName] = true
		end
	end

	-- Second pass: Create the new grouping structure
	for mountID, mountInfo in pairs(self.processedData.allCollectedMountFamilyInfo) do
		local familyName = mountInfo.familyName
		local superGroup = mountInfo.superGroup
		-- Check if this family should be standalone based on traits
		local shouldBeStandalone = familiesWithDistinguishingTraits[familyName] or false
		if superGroup and not shouldBeStandalone then
			-- Keep in supergroup
			if not newSuperGroupMap[superGroup] then
				newSuperGroupMap[superGroup] = {}
			end

			-- Add family to supergroup if not already there
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
		"Families in SuperGroups:", familiesInSGCount,
		"Standalone Families:", standaloneCount)
	-- Update the UI
	self:PopulateFamilyManagementUI()
end

function addon:GetSetting(key)
	if not (self.db and self.db.profile) then return dbDefaults.profile[key] end; local v = self.db.profile[key]; if v == nil and dbDefaults.profile[key] ~= nil then
		return
				dbDefaults.profile[key]
	end; return v
end

function addon:SetSetting(key, value)
	if not (self.db and self.db.profile) then return end; self.db.profile[key] = value; print("RMB_SETTING: K:'" ..
		key .. "',V:'" .. tostring(value) .. "'")
end

print("RMB_DEBUG: Core.lua END.")
