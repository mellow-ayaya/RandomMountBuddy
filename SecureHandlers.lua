-- SecureHandlers.lua - Refactored Version with Zone Ability Support
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Create SecureHandlers class to avoid global pollution
local SecureHandlers = {}
RandomMountBuddy.SecureHandlers = SecureHandlers
-- Cache frequently accessed settings and spell info
local settingsCache = {}
local spellCache = {}
local lastCacheTime = 0
local CACHE_DURATION = 1 -- Cache for 1 second
-- Zone-specific configuration for G-99 abilities using location IDs
local G99_ZONES = {
	[2346] = 1215279, -- Undermine - Original G-99 zone
	[2406] = 1215279, -- Nerub-ar Palace - Raid zone
	-- Add more location IDs here as needed
}
-- Cache system for zone abilities
local zoneAbilityCache = {
	currentLocationID = nil,
	cachedSpellID = nil,
	hasZoneAbility = false,
	lastUpdateTime = 0,
}
-- Common macro templates to reduce duplication
local MACRO_TEMPLATES = {
	prefix = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)]],

	druidSmart = {
		keepActive = "/cast [swimming,noform:3][outdoors,noform:3] %s\n/cast [indoors,noform:1] %s",
		normal = "/cast [swimming][outdoors] %s\n/cast [indoors] %s",
	},

	druidStandard = {
		keepActive = "/cast [noform:3] %s",
		normal = "/cast %s",
	},

	shaman = {
		keepActive = "/cast [noform:1] %s",
		normal = "/cast %s",
	},

	falling = {
		single = "/cast %s",
		keepActive = "/cast !%s",
		withTarget = "/cast [%s] %s",
	},
}
-- Function to safely get cached settings
local function getCachedSetting(key)
	local currentTime = GetTime()
	if currentTime - lastCacheTime > CACHE_DURATION then
		settingsCache = {}
		lastCacheTime = currentTime
	end

	if settingsCache[key] == nil then
		settingsCache[key] = RandomMountBuddy:GetSetting(key)
	end

	return settingsCache[key]
end

-- Function to safely get spell info with caching
local function getCachedSpellInfo(spellID, defaultName)
	if not spellCache[spellID] then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if type(spellInfo) == "table" and spellInfo.name then
			spellCache[spellID] = spellInfo.name
		else
			spellCache[spellID] = defaultName
			print("RMB_SECURE: Warning - Spell ID " .. spellID .. " not found, using default: " .. defaultName)
		end
	end

	return spellCache[spellID]
end

-- Function to build macro text efficiently
local function buildMacro(parts)
	local result = table.concat(parts, "\n")
	if #result > 255 then
		print("RMB_WARNING: Macro length is " .. #result .. " characters (limit: 255)")
	end

	return result
end

-- Function to get current location ID for zone ability detection
local function getCurrentLocationID()
	local mapInfo = C_Map.GetBestMapForUnit("player")
	return mapInfo
end

-- Function to find G-99 ability by location ID
local function findG99AbilityForLocation()
	local locationID = getCurrentLocationID()
	if not locationID then
		return nil
	end

	local spellID = G99_ZONES[locationID]
	if spellID then
		-- Verify the spell actually exists and has the right name
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo and spellInfo.name and
				(spellInfo.name:find("G%-99") or spellInfo.name:find("Breakneck")) then
			return spellID
		end
	end

	return nil
end

-- Function to update zone ability cache
local function updateZoneAbilityCache(forceRefresh)
	if InCombatLockdown() then
		return
	end

	local currentLocationID = getCurrentLocationID()
	local currentTime = GetTime()
	-- Only refresh if location changed, forced refresh, or cache is old
	if not forceRefresh and
			zoneAbilityCache.currentLocationID == currentLocationID and
			(currentTime - zoneAbilityCache.lastUpdateTime) < 30 then
		return
	end

	local zoneAbilitySpellID = findG99AbilityForLocation()
	-- Update cache
	zoneAbilityCache.currentLocationID = currentLocationID
	zoneAbilityCache.cachedSpellID = zoneAbilitySpellID
	zoneAbilityCache.hasZoneAbility = (zoneAbilitySpellID ~= nil)
	zoneAbilityCache.lastUpdateTime = currentTime
end

-- Function to detect if the player is falling
function addonTable:IsPlayerFalling()
	return IsFalling()
end

-- Prevent infinite recursion
addonTable.isUpdatingMacros = false
-- Optimized macro builders
local function buildDruidMacro(travelFormName, catFormName, useSmartFormSwitching, keepTravelFormActive)
	local parts = { MACRO_TEMPLATES.prefix }
	if useSmartFormSwitching then
		local template = keepTravelFormActive and MACRO_TEMPLATES.druidSmart.keepActive or MACRO_TEMPLATES.druidSmart.normal
		table.insert(parts, string.format(template, travelFormName, catFormName))
	else
		local template = keepTravelFormActive and MACRO_TEMPLATES.druidStandard.keepActive or
				MACRO_TEMPLATES.druidStandard.normal
		table.insert(parts, string.format(template, travelFormName))
	end

	return buildMacro(parts)
end

local function buildShamanMacro(ghostWolfName, keepGhostWolfActive)
	local parts = { MACRO_TEMPLATES.prefix }
	local template = keepGhostWolfActive and MACRO_TEMPLATES.shaman.keepActive or MACRO_TEMPLATES.shaman.normal
	table.insert(parts, string.format(template, ghostWolfName))
	return buildMacro(parts)
end

local function buildFallingMacro(spellName, keepActive, targetLogic)
	local parts = { MACRO_TEMPLATES.prefix }
	if targetLogic then
		table.insert(parts, string.format(MACRO_TEMPLATES.falling.withTarget, targetLogic, spellName))
	else
		local template = keepActive and MACRO_TEMPLATES.falling.keepActive or MACRO_TEMPLATES.falling.single
		table.insert(parts, string.format(template, spellName))
	end

	return buildMacro(parts)
end

-- Function to build zone ability aware mount macro
local function buildMountMacro()
	-- Update zone ability cache first
	updateZoneAbilityCache(false)
	if zoneAbilityCache.hasZoneAbility then
		-- Don't use macro for zone abilities - they need direct spell casting
		return "/run RMB:SRM(true)" -- Fallback to RMB if zone ability button fails
	else
		-- Use the clean interface from Core.lua
		local action = RandomMountBuddy:GetSmartButtonAction()
		if action then
			return action
		else
			return "/run RMB:SRM(true)" -- Fallback
		end
	end
end

-- Function to update all shapeshift form macros based on settings
function addonTable:UpdateShapeshiftMacros()
	-- Prevent recursion with better checking
	if self.isUpdatingMacros then
		print("RMB_SECURE: Prevented recursion in UpdateShapeshiftMacros")
		return
	end

	self.isUpdatingMacros = true
	-- Skip if in combat
	if InCombatLockdown() then
		print("RMB_SECURE: Skipped macro update due to combat lockdown")
		self.isUpdatingMacros = false
		return
	end

	-- Use pcall to catch any errors and prevent infinite loops
	local success, errorMsg = pcall(function()
		-- Update zone ability cache
		updateZoneAbilityCache(true)
		-- Cache all spell names at once
		local travelFormName = getCachedSpellInfo(783, "Travel Form")
		local catFormName = getCachedSpellInfo(768, "Cat Form")
		local ghostWolfName = getCachedSpellInfo(2645, "Ghost Wolf")
		local zenFlightName = getCachedSpellInfo(125883, "Zen Flight")
		local slowFallName = getCachedSpellInfo(130, "Slow Fall")
		local levitateName = getCachedSpellInfo(1706, "Levitate")
		-- Cache all settings at once
		local settings = {
			keepTravelFormActive = getCachedSetting("keepTravelFormActive"),
			keepGhostWolfActive = getCachedSetting("keepGhostWolfActive"),
			keepZenFlightActive = getCachedSetting("keepZenFlightActive"),
			useGhostWolfWhileMoving = getCachedSetting("useGhostWolfWhileMoving"),
			useZenFlightWhileMoving = getCachedSetting("useZenFlightWhileMoving"),
			useSlowFallWhileFalling = getCachedSetting("useSlowFallWhileFalling"),
			useSlowFallOnOthers = getCachedSetting("useSlowFallOnOthers"),
			useLevitateWhileFalling = getCachedSetting("useLevitateWhileFalling"),
			useLevitateOnOthers = getCachedSetting("useLevitateOnOthers"),
			useSmartFormSwitching = getCachedSetting("useSmartFormSwitching"),
			useTravelFormWhileMoving = getCachedSetting("useTravelFormWhileMoving"),
		}
		-- Set target logic for spells
		local slowFallTarget = settings.useSlowFallOnOthers and
				"@target,help,exists][@mouseover,help,exists][@player" or "@player"
		local levitateTarget = settings.useLevitateOnOthers and
				"@target,help,exists][@mouseover,help,exists][@player" or "@player"
		-- Update button macros using helper functions
		self:updateButtonMacros(travelFormName, catFormName, ghostWolfName, zenFlightName,
			slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
		-- Build combat macros
		self:buildCombatMacros(travelFormName, catFormName, ghostWolfName, zenFlightName,
			slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
	end)
	if not success then
		print("RMB_SECURE: Error in UpdateShapeshiftMacros: " .. tostring(errorMsg))
	end

	self.isUpdatingMacros = false
	if success then
		print("RMB_SECURE: Updated shapeshift macros")
	end
end

-- Helper function to update individual button macros
function addonTable:updateButtonMacros(travelFormName, catFormName, ghostWolfName, zenFlightName,
		slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
	-- Update druid Travel Form button
	if self.travelButton then
		local macro = buildDruidMacro(travelFormName, catFormName,
			settings.useSmartFormSwitching, settings.keepTravelFormActive)
		self.travelButton:SetAttribute("type", "macro")
		self.travelButton:SetAttribute("macrotext", macro)
	end

	-- Update shaman Ghost Wolf button
	if self.ghostWolfButton then
		local macro = buildShamanMacro(ghostWolfName, settings.keepGhostWolfActive)
		self.ghostWolfButton:SetAttribute("type", "macro")
		self.ghostWolfButton:SetAttribute("macrotext", macro)
	end

	-- Update monk Zen Flight button
	if self.zenFlightButton then
		local macro = buildFallingMacro(zenFlightName, settings.keepZenFlightActive)
		self.zenFlightButton:SetAttribute("type", "macro")
		self.zenFlightButton:SetAttribute("macrotext", macro)
		print("RMB_SECURE: Set Zen Flight button macro with spell name: " .. zenFlightName)
	end

	-- Update mage Slow Fall button
	if self.slowFallButton then
		local macro = buildFallingMacro(slowFallName, false, slowFallTarget)
		self.slowFallButton:SetAttribute("type", "macro")
		self.slowFallButton:SetAttribute("macrotext", macro)
		print("RMB_SECURE: Set Slow Fall button macro with spell name: " .. slowFallName)
	end

	-- Update priest Levitate button
	if self.levitateButton then
		local macro = buildFallingMacro(levitateName, false, levitateTarget)
		self.levitateButton:SetAttribute("type", "macro")
		self.levitateButton:SetAttribute("macrotext", macro)
		print("RMB_SECURE: Set Levitate button macro with spell name: " .. levitateName)
	end

	-- Update mount button with zone ability awareness
	if self.mountButton then
		local macro = buildMountMacro()
		self.mountButton:SetAttribute("type", "macro")
		self.mountButton:SetAttribute("macrotext", macro)
	end

	-- Update smart button based on current state
	self:updateSmartButton(travelFormName, catFormName, ghostWolfName, zenFlightName,
		slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
end

-- Helper function to update smart button with zone ability support
function addonTable:updateSmartButton(travelFormName, catFormName, ghostWolfName, zenFlightName,
		slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
	if not self.smartButton or not self.updateFrame then return end

	-- Check for zone abilities first
	updateZoneAbilityCache(false)
	if zoneAbilityCache.hasZoneAbility then
		self.smartButton:SetAttribute("type", "spell")
		self.smartButton:SetAttribute("spell", zoneAbilityCache.cachedSpellID)
		return
	end

	local _, playerClass = UnitClass("player")
	local isMoving = self.updateFrame.lastMoving
	local isFalling = self.updateFrame.lastFalling
	local isIndoors = IsIndoors()
	-- Use clean interface instead of hardcoded macro
	local macro = RandomMountBuddy:GetSmartButtonAction() -- Default from clean interface
	if playerClass == "DRUID" and ((isMoving and settings.useTravelFormWhileMoving) or
				(isIndoors and settings.useSmartFormSwitching)) then
		macro = buildDruidMacro(travelFormName, catFormName,
			settings.useSmartFormSwitching, settings.keepTravelFormActive)
	elseif playerClass == "SHAMAN" and ((isMoving or isIndoors) and settings.useGhostWolfWhileMoving) then
		macro = buildShamanMacro(ghostWolfName, settings.keepGhostWolfActive)
	elseif playerClass == "MONK" and (isMoving or isFalling) and settings.useZenFlightWhileMoving then
		macro = buildFallingMacro(zenFlightName, settings.keepZenFlightActive)
	elseif playerClass == "MAGE" and isFalling and settings.useSlowFallWhileFalling then
		macro = buildFallingMacro(slowFallName, false, slowFallTarget)
	elseif playerClass == "PRIEST" and isFalling and settings.useLevitateWhileFalling then
		macro = buildFallingMacro(levitateName, false, levitateTarget)
	end

	self.smartButton:SetAttribute("type", "macro")
	self.smartButton:SetAttribute("macrotext", macro)
end

-- Helper function to build combat macros
function addonTable:buildCombatMacros(travelFormName, catFormName, ghostWolfName, zenFlightName,
		slowFallName, levitateName, settings, slowFallTarget, levitateTarget)
	-- Build class-specific combat macros
	self.druidCombatMacro = buildDruidMacro(travelFormName, catFormName,
		settings.useSmartFormSwitching, settings.keepTravelFormActive)
	self.shamanCombatMacro = settings.useGhostWolfWhileMoving and
			buildShamanMacro(ghostWolfName, settings.keepGhostWolfActive) or
			buildShamanMacro(ghostWolfName, true) -- Fallback for dungeon compatibility
	self.monkCombatMacro = settings.useZenFlightWhileMoving and
			buildFallingMacro(zenFlightName, settings.keepZenFlightActive) or
			MACRO_TEMPLATES.prefix -- Simple fallback
	self.mageCombatMacro = settings.useSlowFallWhileFalling and
			buildFallingMacro(slowFallName, false, slowFallTarget) or
			MACRO_TEMPLATES.prefix
	self.priestCombatMacro = settings.useLevitateWhileFalling and
			buildFallingMacro(levitateName, false, levitateTarget) or
			MACRO_TEMPLATES.prefix
	-- Set the current combat macro
	local _, playerClass = UnitClass("player")
	local combatMacros = {
		DRUID = self.druidCombatMacro,
		SHAMAN = self.shamanCombatMacro,
		MONK = self.monkCombatMacro,
		MAGE = self.mageCombatMacro,
		PRIEST = self.priestCombatMacro,
	}
	self.combatMacro = combatMacros[playerClass] or MACRO_TEMPLATES.prefix
end

-- Optimized secure handlers setup
function addonTable:SetupSecureHandlers()
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		print("RMB_SECURE: Initializing secure handlers...")
		-- Create all secure buttons
		local buttons = addonTable:createSecureButtons()
		-- Store button references
		for name, button in pairs(buttons) do
			addonTable[name] = button
			RandomMountBuddy[name] = button
		end

		-- Create visible button with optimized click handler
		addonTable:createVisibleButton()
		-- Create smart button with optimized update handler
		addonTable:createSmartButton()
		-- Setup zone ability event handling
		addonTable:setupZoneAbilityHandling()
		-- Initialize macros
		addonTable:UpdateShapeshiftMacros()
		print("RMB_SECURE: Secure handlers initialized")
		self:UnregisterEvent("ADDON_LOADED")
		if addonTable.visibleButton then
			addonTable.visibleButton:Show()
		end
	end)
end

-- Helper function to create all secure buttons
function addonTable:createSecureButtons()
	local buttons = {}
	local buttonConfigs = {
		{ name = "travelButton", globalName = "RMBTravelFormButton" },
		{ name = "ghostWolfButton", globalName = "RMBGhostWolfButton" },
		{ name = "zenFlightButton", globalName = "RMBZenFlightButton" },
		{ name = "slowFallButton", globalName = "RMBSlowFallButton" },
		{ name = "levitateButton", globalName = "RMBLevitateButton" },
		{ name = "mountButton", globalName = "RMBMountButton" },
	}
	for _, config in ipairs(buttonConfigs) do
		local button = CreateFrame("Button", config.globalName, UIParent, "SecureActionButtonTemplate")
		button:SetSize(1, 1)
		button:SetPoint("CENTER")
		button:RegisterForClicks("AnyUp", "AnyDown")
		if config.name == "mountButton" then
			button:SetAttribute("type", "macro")
			-- Use clean interface instead of hardcoded macro
			local mountMacro = RandomMountBuddy:GetSmartButtonAction()
			button:SetAttribute("macrotext", mountMacro)
		end

		buttons[config.name] = button
	end

	return buttons
end

-- Optimized visible button creation with zone ability support
function addonTable:createVisibleButton()
	local visibleButton = CreateFrame("Button", "RMBVisibleButton", UIParent)
	visibleButton:SetSize(1, 1)
	visibleButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	visibleButton:SetAlpha(0)
	visibleButton:SetMovable(true)
	visibleButton:RegisterForDrag("LeftButton")
	-- Optimized drag handlers
	visibleButton:SetScript("OnDragStart", visibleButton.StartMoving)
	visibleButton:SetScript("OnDragStop", visibleButton.StopMovingOrSizing)
	-- Updated click handler with clean module interface
	local _, playerClass = UnitClass("player")
	visibleButton:SetScript("OnClick", function()
		-- Check for zone abilities first
		updateZoneAbilityCache(false)
		if zoneAbilityCache.hasZoneAbility and not InCombatLockdown() then
			-- Create temporary secure button for zone ability
			local zoneButton = CreateFrame("Button", "RMBTempZoneButton", UIParent, "SecureActionButtonTemplate")
			zoneButton:SetAttribute("type", "spell")
			zoneButton:SetAttribute("spell", zoneAbilityCache.cachedSpellID)
			zoneButton:Click()
			zoneButton:Hide()
			print("RMB_SECURE: Used zone ability " .. zoneAbilityCache.cachedSpellID)
			return
		end

		local isMoving = IsPlayerMoving()
		local isFalling = addonTable:IsPlayerFalling()
		local isIndoors = IsIndoors()
		local inCombat = InCombatLockdown()
		-- Use lookup table for button selection
		local buttonActions = {
			DRUID = function()
				return (isMoving and getCachedSetting("useTravelFormWhileMoving")) or
						(isIndoors and getCachedSetting("useSmartFormSwitching"))
						and not inCombat and addonTable.travelButton
			end,
			SHAMAN = function()
				return ((isMoving or isIndoors) and getCachedSetting("useGhostWolfWhileMoving"))
						and not inCombat and addonTable.ghostWolfButton
			end,
			MONK = function()
				return ((isMoving or isFalling) and getCachedSetting("useZenFlightWhileMoving"))
						and not inCombat and addonTable.zenFlightButton
			end,
			MAGE = function()
				return (isFalling and getCachedSetting("useSlowFallWhileFalling"))
						and addonTable.slowFallButton
			end,
			PRIEST = function()
				return (isFalling and getCachedSetting("useLevitateWhileFalling"))
						and addonTable.levitateButton
			end,
		}
		local actionFunc = buttonActions[playerClass]
		local targetButton = actionFunc and actionFunc() or addonTable.mountButton
		if targetButton then
			targetButton:Click()
			print("RMB_SECURE: Clicked " .. (targetButton == addonTable.mountButton and "mount" or "form") .. " button")
		end
	end)
	-- Tooltip handlers
	visibleButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Random Mount Buddy")
		GameTooltip:AddLine("Click to summon a mount or cast shapeshift form", 1, 1, 1)
		GameTooltip:Show()
	end)
	visibleButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.visibleButton = visibleButton
	RandomMountBuddy.visibleButton = visibleButton
end

-- Optimized smart button creation with zone ability support
function addonTable:createSmartButton()
	local smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
	smartButton:SetSize(1, 1)
	smartButton:SetPoint("CENTER")
	smartButton:RegisterForClicks("AnyUp", "AnyDown")
	smartButton:SetAttribute("type", "macro")
	smartButton:SetAttribute("macrotext", "/run RMB:SRM(true)")
	-- Optimized update frame with reduced frequency
	local updateFrame = CreateFrame("Frame")
	updateFrame.elapsed = 0
	updateFrame.lastMoving = false
	updateFrame.lastFalling = false
	updateFrame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < 0.2 then return end -- Single throttle: 0.2 seconds

		self.elapsed = 0
		if InCombatLockdown() then return end

		local isMoving = IsPlayerMoving()
		local isFalling = addonTable:IsPlayerFalling()
		if isMoving ~= self.lastMoving or isFalling ~= self.lastFalling then
			self.lastMoving = isMoving
			self.lastFalling = isFalling
			-- Force settings cache refresh
			settingsCache = {}
			-- Update the smart button
			addonTable:updateSmartButton(
				getCachedSpellInfo(783, "Travel Form"),
				getCachedSpellInfo(768, "Cat Form"),
				getCachedSpellInfo(2645, "Ghost Wolf"),
				getCachedSpellInfo(125883, "Zen Flight"),
				getCachedSpellInfo(130, "Slow Fall"),
				getCachedSpellInfo(1706, "Levitate"),
				{
					keepTravelFormActive = getCachedSetting("keepTravelFormActive"),
					keepGhostWolfActive = getCachedSetting("keepGhostWolfActive"),
					keepZenFlightActive = getCachedSetting("keepZenFlightActive"),
					useGhostWolfWhileMoving = getCachedSetting("useGhostWolfWhileMoving"),
					useZenFlightWhileMoving = getCachedSetting("useZenFlightWhileMoving"),
					useSlowFallWhileFalling = getCachedSetting("useSlowFallWhileFalling"),
					useSlowFallOnOthers = getCachedSetting("useSlowFallOnOthers"),
					useLevitateWhileFalling = getCachedSetting("useLevitateWhileFalling"),
					useLevitateOnOthers = getCachedSetting("useLevitateOnOthers"),
					useSmartFormSwitching = getCachedSetting("useSmartFormSwitching"),
					useTravelFormWhileMoving = getCachedSetting("useTravelFormWhileMoving"),
				},
				getCachedSetting("useSlowFallOnOthers") and
				"@target,help,exists][@mouseover,help,exists][@player" or "@player",
				getCachedSetting("useLevitateOnOthers") and
				"@target,help,exists][@mouseover,help,exists][@player" or "@player"
			)
		end
	end)
	-- Combat event handling
	updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	updateFrame:SetScript("OnEvent", function(self, event)
		if InCombatLockdown() then return end

		if event == "PLAYER_REGEN_DISABLED" then
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", addonTable.combatMacro or "/run RMB:SRM(true)")
		elseif event == "PLAYER_REGEN_ENABLED" then
			-- Reset to normal operation after combat
			C_Timer.After(0.1, function()
				if not InCombatLockdown() then
					self.lastMoving = nil -- Force update
					self.lastFalling = nil
				end
			end)
		end
	end)
	self.smartButton = smartButton
	self.updateFrame = updateFrame
	RandomMountBuddy.smartButton = smartButton
	RandomMountBuddy.updateFrame = updateFrame
end

-- Setup zone ability event handling
function addonTable:setupZoneAbilityHandling()
	local zoneUpdateFrame = CreateFrame("Frame")
	zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	zoneUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	zoneUpdateFrame:SetScript("OnEvent", function(self, event)
		if event == "ZONE_CHANGED_NEW_AREA" then
			-- Update immediately on zone change to prevent G-99 sticking
			updateZoneAbilityCache(true)
			addonTable:UpdateShapeshiftMacros()
		elseif event == "PLAYER_ENTERING_WORLD" then
			C_Timer.After(3, function()
				updateZoneAbilityCache(true)
				addonTable:UpdateShapeshiftMacros()
			end)
		end
	end)
end

-- FIXED: Use notification system instead of direct hook
function SecureHandlers:OnSettingChanged(key, value)
	-- Only update for relevant settings
	local relevantSettings = {
		keepTravelFormActive = true,
		useTravelFormWhileMoving = true,
		useGhostWolfWhileMoving = true,
		useZenFlightWhileMoving = true,
		keepGhostWolfActive = true,
		keepZenFlightActive = true,
		useSlowFallWhileFalling = true,
		useSlowFallOnOthers = true,
		useLevitateWhileFalling = true,
		useLevitateOnOthers = true,
		useSmartFormSwitching = true,
	}
	if relevantSettings[key] then
		print("RMB_SECURE: Setting changed notification received for:", key, "->", value)
		-- Clear cache and update
		settingsCache = {}
		-- Use C_Timer to avoid any potential recursion
		C_Timer.After(0.01, function()
			if not InCombatLockdown() then
				addonTable:UpdateShapeshiftMacros()
			end
		end)
	end
end

-- Setup basic references and initialization
function addonTable:setupSecureReferences()
	-- Safe wrapper for clicking mount button
	RandomMountBuddy.ClickSecureButton = function(self)
		if self.ClickMountButton then
			return self:ClickMountButton()
		end

		return false
	end
	RandomMountBuddy.ClickMountButton = function(self)
		if self.visibleButton then
			self.visibleButton:Click()
			return true
		end

		return false
	end
	-- Direct reference to avoid recursion
	RandomMountBuddy.UpdateShapeshiftMacros = addonTable.UpdateShapeshiftMacros
end

-- Initialize
function RandomMountBuddy:InitializeSecureHandlers()
	print("RMB_SECURE: InitializeSecureHandlers called from Core.lua")
	addonTable:SetupSecureHandlers()
	addonTable:setupSecureReferences()
end

-- Initialize
addonTable:SetupSecureHandlers()
print("RMB_DEBUG: SecureHandlers.lua END.")
