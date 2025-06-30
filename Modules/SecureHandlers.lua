-- SecureHandlers.lua - Simplified Zone-Based Approach
local addonName, addonTable = ...
addonTable:DebugCore("SecureHandlers.lua START (Simplified Version).")
-- Create SecureHandlers class to avoid global pollution
local SecureHandlers = {}
RandomMountBuddy.SecureHandlers = SecureHandlers
-- Cache frequently accessed settings and spell info
local settingsCache = {}
local spellCache = {}
local lastCacheTime = 0
local CACHE_DURATION = 1 -- Cache for 1 second
-- Cooldown tracking to prevent spam
local actionCooldowns = {
	visibleButton = 0,
}
local G99_LOCALIZED_NAME = nil
local G99_SPELL_ID = 1215279
-- Function to get localized G99 spell name
local function getLocalizedG99Name()
	if not G99_LOCALIZED_NAME then
		local spellInfo = C_Spell.GetSpellInfo(G99_SPELL_ID)
		if spellInfo and spellInfo.name then
			G99_LOCALIZED_NAME = spellInfo.name
			addonTable:DebugCore("G99: Cached localized spell name:", G99_LOCALIZED_NAME)
		else
			-- Fallback for different locales or if spell not found
			G99_LOCALIZED_NAME = "G-99 Breakneck" -- English fallback
			addonTable:DebugCore("G99: Using English fallback name")
		end
	end

	return G99_LOCALIZED_NAME
end

-- Common macro templates to reduce duplication
local MACRO_TEMPLATES = {
	prefix =
	"/run RMB:SRM(true)\n/run UIErrorsFrame:SuppressMessagesThisFrame()\n/stopmacro [mounted]",

	-- Regular zones: Handle forms, then regular mount
	regularZone = "/cancelform [form:2]\n/run RMB:SRM(true)",

	druidSmart = {
		keepActive = "/cast [swimming,noform:3][outdoors,noform:3] %s\n/cast [indoors,noform:2] %s",
		normal = "/cast [swimming][outdoors] %s\n/cast [indoors] %s",
	},

	druidStandard = {
		keepActive = "/cast [noform:3] %s",
		normal = "/cast %s",
	},

	shaman = {
		keepActive = "/cast [noform:1] %s",
		normal = "/cancelform [form:1]\n/cast %s",
	},

	falling = {
		single = "/cast %s",
		keepActive = "/cast !%s",
		withTarget = "/cast [%s] %s",
	},
}
local function getUndermineZoneMacro()
	local g99Name = getLocalizedG99Name()
	-- Add form cancellation logic that's smart about travel forms
	local macro = "/cancelform [form:2]\n" .. -- Cancel bear/cat/moonkin but not travel form
			"/cast " .. g99Name .. "\n" ..
			"/run RMB:SRM(true)"
	addonTable:DebugCore("G99: Built Undermine macro with form handling and spell:", g99Name)
	return macro
end
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
			addonTable:DebugCore("Warning - Spell ID " .. spellID .. " not found, using default: " .. defaultName)
		end
	end

	return spellCache[spellID]
end

-- Function to check cooldowns and prevent spam
local function isActionOnCooldown(actionType, cooldownDuration)
	local currentTime = GetTime()
	cooldownDuration = cooldownDuration or 0.5
	if currentTime - (actionCooldowns[actionType] or 0) < cooldownDuration then
		return true
	end

	actionCooldowns[actionType] = currentTime
	return false
end

-- Function to build macro text efficiently
local function buildMacro(parts)
	local result = table.concat(parts, "\n")
	if #result > 255 then
		addonTable:AlwaysPrint("Macro length is " .. #result .. " characters (limit: 255)")
	end

	return result
end

-- Function to detect if the player is falling
function addonTable:IsPlayerFalling()
	return IsFalling()
end

-- Prevent infinite recursion
addonTable.isUpdatingMacros = false
-- SIMPLIFIED: Get mount macro based on current zone
local function getMountMacroForCurrentZone()
	local locationID = C_Map.GetBestMapForUnit("player")
	-- Undermine zones: Try G99 first, then regular mount
	if locationID == 2346 or locationID == 2406 then
		addonTable:DebugCore("Mount macro: Using Undermine macro (G99 + fallback)")
		return getUndermineZoneMacro()
	else
		addonTable:DebugCore("Mount macro: Using regular zone macro")
		return MACRO_TEMPLATES.regularZone
	end
end

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

-- SIMPLIFIED: Update all shapeshift form macros based on settings
function addonTable:UpdateShapeshiftMacros()
	-- Prevent recursion with better checking
	if self.isUpdatingMacros then
		addonTable:DebugCore("Prevented recursion in UpdateShapeshiftMacros")
		return
	end

	self.isUpdatingMacros = true
	-- Skip if in combat
	if InCombatLockdown() then
		addonTable:DebugCore("Skipped macro update due to combat lockdown")
		self.isUpdatingMacros = false
		return
	end

	-- Use pcall to catch any errors and prevent infinite loops
	local success, errorMsg = pcall(function()
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
		addonTable:DebugCore("Error in UpdateShapeshiftMacros: " .. tostring(errorMsg))
	end

	self.isUpdatingMacros = false
	if success then
		addonTable:DebugCore("Updated shapeshift macros")
	end
end

-- SIMPLIFIED: Helper function to update individual button macros
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
	end

	-- Update mage Slow Fall button
	if self.slowFallButton then
		local macro = buildFallingMacro(slowFallName, false, slowFallTarget)
		self.slowFallButton:SetAttribute("type", "macro")
		self.slowFallButton:SetAttribute("macrotext", macro)
	end

	-- Update priest Levitate button
	if self.levitateButton then
		local macro = buildFallingMacro(levitateName, false, levitateTarget)
		self.levitateButton:SetAttribute("type", "macro")
		self.levitateButton:SetAttribute("macrotext", macro)
	end

	-- SIMPLIFIED: Update mount button and smart button with zone-appropriate macro
	local mountMacro = getMountMacroForCurrentZone()
	if self.mountButton then
		self.mountButton:SetAttribute("type", "macro")
		self.mountButton:SetAttribute("macrotext", mountMacro)
	end

	if self.smartButton then
		self:updateSmartButton(travelFormName, catFormName, ghostWolfName, zenFlightName,
			slowFallName, levitateName, settings, slowFallTarget, levitateTarget, mountMacro)
	end
end

-- SIMPLIFIED: Smart button update
function addonTable:updateSmartButton(travelFormName, catFormName, ghostWolfName, zenFlightName,
		slowFallName, levitateName, settings, slowFallTarget, levitateTarget, mountMacro)
	if not self.smartButton or not self.updateFrame then return end

	-- Handle shapeshift logic for different classes
	local _, playerClass = UnitClass("player")
	local isMoving = self.updateFrame.lastMoving
	local isFalling = self.updateFrame.lastFalling
	local isIndoors = IsIndoors()
	-- Default to mount macro (which handles G99 automatically based on zone)
	local macro = mountMacro
	if playerClass == "DRUID" and ((isMoving and settings.useTravelFormWhileMoving) or
				(isIndoors and settings.useSmartFormSwitching)) then
		macro = buildDruidMacro(travelFormName, catFormName,
			settings.useSmartFormSwitching, settings.keepTravelFormActive)
		addonTable:DebugCore("Smart button: Using Druid macro")
	elseif playerClass == "SHAMAN" and ((isMoving or isIndoors) and settings.useGhostWolfWhileMoving) then
		macro = buildShamanMacro(ghostWolfName, settings.keepGhostWolfActive)
		addonTable:DebugCore("Smart button: Using Shaman macro")
	elseif playerClass == "MONK" and (isMoving or isFalling) and settings.useZenFlightWhileMoving then
		macro = buildFallingMacro(zenFlightName, settings.keepZenFlightActive)
		addonTable:DebugCore("Smart button: Using Monk macro")
	elseif playerClass == "MAGE" and isFalling and settings.useSlowFallWhileFalling then
		macro = buildFallingMacro(slowFallName, false, slowFallTarget)
		addonTable:DebugCore("Smart button: Using Mage macro")
	elseif playerClass == "PRIEST" and isFalling and settings.useLevitateWhileFalling then
		macro = buildFallingMacro(levitateName, false, levitateTarget)
		addonTable:DebugCore("Smart button: Using Priest macro")
	else
		addonTable:DebugCore("Smart button: Using zone-appropriate mount macro")
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
			MACRO_TEMPLATES.regularZone -- Simple fallback
	self.mageCombatMacro = settings.useSlowFallWhileFalling and
			buildFallingMacro(slowFallName, false, slowFallTarget) or
			MACRO_TEMPLATES.regularZone
	self.priestCombatMacro = settings.useLevitateWhileFalling and
			buildFallingMacro(levitateName, false, levitateTarget) or
			MACRO_TEMPLATES.regularZone
	-- Set the current combat macro using localized zone macro
	local _, playerClass = UnitClass("player")
	local combatMacros = {
		DRUID = self.druidCombatMacro,
		SHAMAN = self.shamanCombatMacro,
		MONK = self.monkCombatMacro,
		MAGE = self.mageCombatMacro,
		PRIEST = self.priestCombatMacro,
	}
	self.combatMacro = combatMacros[playerClass] or getMountMacroForCurrentZone()
	addonTable:DebugCore("Combat macro set for", playerClass or "unknown", "class")
end

-- Optimized secure handlers setup
function addonTable:SetupSecureHandlers()
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		addonTable:DebugCore("Initializing secure handlers...")
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
		-- Setup zone change event handling
		addonTable:setupZoneChangeHandling()
		-- Initialize macros
		addonTable:UpdateShapeshiftMacros()
		addonTable:DebugCore("Secure handlers initialized")
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
		-- Set default mount macro (will be updated by updateButtonMacros)
		if config.name == "mountButton" then
			-- Clear the spell name cache to ensure fresh lookup
			G99_LOCALIZED_NAME = nil
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext", getMountMacroForCurrentZone())
			addonTable:DebugCore("Mount button: Created with localized zone-appropriate macro")
		end

		buttons[config.name] = button
	end

	return buttons
end

-- SIMPLIFIED: Visible button creation
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
	-- SIMPLIFIED: Enhanced click handler that just delegates to smart button
	visibleButton:SetScript("OnClick", function()
		-- Prevent spam clicking
		if isActionOnCooldown("visibleButton", 0.5) then
			return
		end

		local success, err = pcall(function()
			addonTable:DebugCore("Visible button: Delegating to smart button")
			-- Always just click the smart button - it has the zone-appropriate logic
			if addonTable.smartButton then
				addonTable.smartButton:Click()
			else
				addonTable:DebugCore("Visible button: ERROR - Smart button not found!")
			end
		end)
		if not success then
			addonTable:DebugCore("Visible button click error:", err)
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

-- Smart button creation with optimized update handler
function addonTable:createSmartButton()
	local smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
	smartButton:SetSize(1, 1)
	smartButton:SetPoint("CENTER")
	smartButton:RegisterForClicks("AnyUp", "AnyDown")
	smartButton:SetAttribute("type", "macro")
	smartButton:SetAttribute("macrotext", getMountMacroForCurrentZone())
	-- Optimized update frame with reduced frequency
	local updateFrame = CreateFrame("Frame")
	updateFrame.elapsed = 0
	updateFrame.lastMoving = false
	updateFrame.lastFalling = false
	updateFrame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < 0.05 then return end -- Single throttle

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
				"@target,help,exists][@mouseover,help,exists][@player" or "@player",
				getMountMacroForCurrentZone() -- Pass current zone macro
			)
		end
	end)
	-- Enhanced combat event handling
	updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	updateFrame:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			-- Entering combat - set combat macro immediately
			if not InCombatLockdown() then -- Safety check
				smartButton:SetAttribute("type", "macro")
				smartButton:SetAttribute("macrotext", addonTable.combatMacro or getMountMacroForCurrentZone())
				addonTable:DebugCore("Combat: Set combat macro")
			end
		elseif event == "PLAYER_REGEN_ENABLED" then
			-- Leaving combat - update macro IMMEDIATELY, no delay
			if not InCombatLockdown() then
				-- Force immediate macro update
				self.lastMoving = nil -- Force movement update
				self.lastFalling = nil -- Force falling update
				-- Clear spell name cache in case it changed during combat
				G99_LOCALIZED_NAME = nil
				-- Immediately update to current zone macro
				local currentZoneMacro = getMountMacroForCurrentZone()
				smartButton:SetAttribute("type", "macro")
				smartButton:SetAttribute("macrotext", currentZoneMacro)
				addonTable:DebugCore("Combat: Immediately updated to post-combat macro")
				-- Also force a full macro update after a brief moment for other buttons
				C_Timer.After(0.05, function()
					if not InCombatLockdown() then
						addonTable:UpdateShapeshiftMacros()
					end
				end)
			end
		end
	end)
	self.smartButton = smartButton
	self.updateFrame = updateFrame
	RandomMountBuddy.smartButton = smartButton
	RandomMountBuddy.updateFrame = updateFrame
end

-- SIMPLIFIED: Zone change event handling
function addonTable:setupZoneChangeHandling()
	local zoneUpdateFrame = CreateFrame("Frame")
	zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	zoneUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	zoneUpdateFrame:RegisterEvent("SPELLS_CHANGED") -- In case G99 spell changes
	zoneUpdateFrame:SetScript("OnEvent", function(self, event)
		addonTable:DebugCore("Zone/spell change event:", event, "- Updating macros")
		-- Clear cached spell name on any relevant event
		if event == "SPELLS_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
			G99_LOCALIZED_NAME = nil
			addonTable:DebugCore("Cleared G99 spell name cache")
		end

		-- Update macros with appropriate delay
		local delay = (event == "SPELLS_CHANGED") and 0.5 or 1.0
		C_Timer.After(delay, function()
			if not InCombatLockdown() then
				addonTable:UpdateShapeshiftMacros()
			end
		end)
	end)
end

-- Enhanced setting change handler
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
		addonTable:DebugCore("Setting changed notification received for:", key, "->", value)
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
	addonTable:DebugCore("InitializeSecureHandlers called from Core.lua")
	addonTable:SetupSecureHandlers()
	addonTable:setupSecureReferences()
end

-- Initialize
addonTable:SetupSecureHandlers()
addonTable:DebugCore("SecureHandlers.lua END (Simplified Version).")
