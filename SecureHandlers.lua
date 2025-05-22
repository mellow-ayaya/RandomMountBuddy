-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Function to detect if the player is falling (used for Zen Flight)
function addonTable:IsPlayerFalling()
	-- In WoW, we can check if the player is falling with this API
	return IsFalling()
end

-- Prevent infinite recursion
addonTable.isUpdatingMacros = false
-- Function to update all shapeshift form macros based on settings
function addonTable:UpdateShapeshiftMacros()
	-- Prevent recursion
	if addonTable.isUpdatingMacros then return end

	addonTable.isUpdatingMacros = true
	-- Skip if in combat
	if InCombatLockdown() then
		addonTable.isUpdatingMacros = false
		return
	end

	-- Get settings
	local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
	local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
	local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
	local useGhostWolfWhileMoving = RandomMountBuddy:GetSetting("useGhostWolfWhileMoving")
	local useZenFlightWhileMoving = RandomMountBuddy:GetSetting("useZenFlightWhileMoving")
	local useSlowFallWhileFalling = RandomMountBuddy:GetSetting("useSlowFallWhileFalling")
	local useSlowFallOnOthers = RandomMountBuddy:GetSetting("useSlowFallOnOthers")
	local useLevitateWhileFalling = RandomMountBuddy:GetSetting("useLevitateWhileFalling")
	local useLevitateOnOthers = RandomMountBuddy:GetSetting("useLevitateOnOthers")
	local useSmartFormSwitching = RandomMountBuddy:GetSetting("useSmartFormSwitching")
	-- Get Travel Form name
	local travelFormName = "Travel Form" -- Default
	local spellInfo = C_Spell.GetSpellInfo(783)
	if type(spellInfo) == "table" and spellInfo.name then
		travelFormName = spellInfo.name
	end

	-- Get Cat Form name
	local catFormName = "Cat Form"                    -- Default
	local catFormSpellInfo = C_Spell.GetSpellInfo(768) -- Cat Form spell ID
	if type(catFormSpellInfo) == "table" and catFormSpellInfo.name then
		catFormName = catFormSpellInfo.name
		print("RMB_SECURE: Found Cat Form spell: " .. catFormName)
	end

	-- Get Ghost Wolf name
	local ghostWolfName = "Ghost Wolf" -- Default
	local gwSpellInfo = C_Spell.GetSpellInfo(2645)
	if type(gwSpellInfo) == "table" and gwSpellInfo.name then
		ghostWolfName = gwSpellInfo.name
	end

	-- Get Zen Flight name
	local zenFlightName = "Zen Flight" -- Default
	local zfSpellInfo = C_Spell.GetSpellInfo(125883)
	if type(zfSpellInfo) == "table" and zfSpellInfo.name then
		zenFlightName = zfSpellInfo.name
	end

	-- Get Slow Fall name
	local slowFallName = "Slow Fall" -- Default
	local sfSpellInfo = C_Spell.GetSpellInfo(130)
	if type(sfSpellInfo) == "table" and sfSpellInfo.name then
		slowFallName = sfSpellInfo.name
	end

	-- Get Levitate name
	local levitateName = "Levitate" -- Default
	local levSpellInfo = C_Spell.GetSpellInfo(1706)
	if type(levSpellInfo) == "table" and levSpellInfo.name then
		levitateName = levSpellInfo.name
	end

	-- Set target logic for Slow Fall
	local slowFallTarget = "@player"
	if useSlowFallOnOthers then
		slowFallTarget = "@target,help,exists][@mouseover,help,exists][@player"
	end

	-- Set target logic for Levitate
	local levitateTarget = "@player"
	if useLevitateOnOthers then
		levitateTarget = "@target,help,exists][@mouseover,help,exists][@player"
	end

	-- Update druid buttons if they exist
	if self.travelButton then
		-- Check if smart form switching is enabled
		if useSmartFormSwitching then
			-- Apply the keep active setting to both forms
			if keepTravelFormActive then
				-- Don't switch out of forms
				self.travelButton:SetAttribute("type", "macro")
				self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName)
			else
				-- Can switch out of forms
				self.travelButton:SetAttribute("type", "macro")
				self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName)
			end
		else
			-- For Travel Form, use the standard macro pattern with noform
			if keepTravelFormActive then
				self.travelButton:SetAttribute("type", "macro")
				self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName)
			else
				self.travelButton:SetAttribute("type", "macro")
				self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName)
			end
		end
	end

	-- Update shaman Ghost Wolf button if they exist
	if self.ghostWolfButton then
		-- For Ghost Wolf button, use separate setting for keeping active
		if keepGhostWolfActive then
			self.ghostWolfButton:SetAttribute("type", "macro")
			self.ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName)
		else
			self.ghostWolfButton:SetAttribute("type", "macro")
			self.ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName)
		end
	end

	-- Update monk Zen Flight button if it exists - with proper concatenation
	if self.zenFlightButton then
		-- For Zen Flight, use simple single cast like other spells
		self.zenFlightButton:SetAttribute("type", "macro")
		if keepZenFlightActive then
			self.zenFlightButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] !]] .. zenFlightName)
		else
			self.zenFlightButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] ]] .. zenFlightName)
		end

		print("RMB_SECURE: Set Zen Flight button macro with spell name: " .. zenFlightName)
	end

	-- Update mage Slow Fall button if it exists
	if self.slowFallButton then
		self.slowFallButton:SetAttribute("type", "macro")
		self.slowFallButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. slowFallTarget .. "] " .. slowFallName)
		print("RMB_SECURE: Set Slow Fall button macro with spell name: " .. slowFallName)
	end

	-- Update priest Levitate button if it exists
	if self.levitateButton then
		self.levitateButton:SetAttribute("type", "macro")
		self.levitateButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. levitateTarget .. "] " .. levitateName)
		print("RMB_SECURE: Set Levitate button macro with spell name: " .. levitateName)
	end

	-- Update the smartButton macro based on class
	if self.smartButton and self.updateFrame then
		local _, playerClass = UnitClass("player")
		if playerClass == "DRUID" and (self.updateFrame.lastMoving or (IsIndoors() and useSmartFormSwitching)) then
			local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
			if (self.updateFrame.lastMoving and useTravelFormWhileMoving) or (IsIndoors() and useSmartFormSwitching) then
				if useSmartFormSwitching then
					-- Smart form switching macro
					if keepTravelFormActive then
						self.smartButton:SetAttribute("type", "macro")
						self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName)
					else
						self.smartButton:SetAttribute("type", "macro")
						self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName)
					end
				else
					if keepTravelFormActive then
						self.smartButton:SetAttribute("type", "macro")
						self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName)
					else
						self.smartButton:SetAttribute("type", "macro")
						self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName)
					end
				end
			end
		elseif playerClass == "SHAMAN" and (self.updateFrame.lastMoving or IsIndoors()) then
			if (self.updateFrame.lastMoving or IsIndoors()) and useGhostWolfWhileMoving then
				if keepGhostWolfActive then
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName)
				else
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName)
				end
			end
		elseif playerClass == "MONK" and (self.updateFrame.lastMoving or self.updateFrame.lastFalling) then
			if useZenFlightWhileMoving then
				-- Moving or falling Monk - use simple single cast like other spells
				local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
				self.smartButton:SetAttribute("type", "macro")
				if keepZenFlightActive then
					self.smartButton:SetAttribute("macrotext", [[
	/dismount [mounted]
	/stopmacro [mounted]
	/run RMB:SRM(true)
	/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
	/cast [falling] !]] .. zenFlightName)
				else
					self.smartButton:SetAttribute("macrotext", [[
	/dismount [mounted]
	/stopmacro [mounted]
	/run RMB:SRM(true)
	/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
	/cast [falling] ]] .. zenFlightName)
				end
			end
		elseif playerClass == "MAGE" and self.updateFrame.lastFalling then
			if useSlowFallWhileFalling then
				self.smartButton:SetAttribute("type", "macro")
				self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. slowFallTarget .. "] " .. slowFallName)
			end
		elseif playerClass == "PRIEST" and self.updateFrame.lastFalling then
			if useLevitateWhileFalling then
				self.smartButton:SetAttribute("type", "macro")
				self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. levitateTarget .. "] " .. levitateName)
			end
		end
	end

	-- Update the combat macros
	-- Create Druid combat macro using standard pattern
	if useSmartFormSwitching then
		if keepTravelFormActive then
			self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName
		else
			self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName
		end
	else
		if keepTravelFormActive then
			self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName
		else
			self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName
		end
	end

	-- Create simplified macro for shamans - use keepGhostWolfActive setting
	if useGhostWolfWhileMoving then
		if keepGhostWolfActive then
			self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName
		else
			self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName
		end
	else
		-- If Ghost Wolf setting is disabled, still provide the same functionality
		-- This maintains consistent behavior in the special dungeon
		self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName
	end

	-- Create Monk combat macro - simplified
	if RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
		if RandomMountBuddy:GetSetting("keepZenFlightActive") then
			addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast !]] .. zenFlightName
		else
			addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. zenFlightName
		end
	else
		-- Keep simple
		addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
	end

	-- Create Mage combat macro for Slow Fall
	if useSlowFallWhileFalling then
		if useSlowFallOnOthers then
			self.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@target,help,exists][@mouseover,help,exists][@player] ]] .. slowFallName
		else
			self.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@player] ]] .. slowFallName
		end
	else
		self.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
	end

	-- Create Priest combat macro for Levitate
	if useLevitateWhileFalling then
		if useLevitateOnOthers then
			self.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@target,help,exists][@mouseover,help,exists][@player] ]] .. levitateName
		else
			self.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@player] ]] .. levitateName
		end
	else
		self.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
	end

	-- Update the combat macro for the current class
	local _, playerClass = UnitClass("player")
	if playerClass == "DRUID" then
		self.combatMacro = self.druidCombatMacro
	elseif playerClass == "SHAMAN" then
		self.combatMacro = self.shamanCombatMacro
	elseif playerClass == "MONK" then
		self.combatMacro = self.monkCombatMacro
	elseif playerClass == "MAGE" then
		self.combatMacro = self.mageCombatMacro
	elseif playerClass == "PRIEST" then
		self.combatMacro = self.priestCombatMacro
	end

	addonTable.isUpdatingMacros = false
	print("RMB_SECURE: Updated shapeshift macros")
end

-- Create secure action buttons and register keybindings
function addonTable:SetupSecureHandlers()
	-- Create a frame to handle initialization
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	-- Prepare for button creation
	local travelButton, ghostWolfButton, zenFlightButton, slowFallButton, levitateButton, mountButton, visibleButton, smartButton, updateFrame
	-- Initialize on addon load
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		print("RMB_SECURE: Initializing secure handlers...")
		-- Create Travel Form button (for druids)
		travelButton = CreateFrame("Button", "RMBTravelFormButton", UIParent, "SecureActionButtonTemplate")
		travelButton:SetSize(1, 1)
		travelButton:SetPoint("CENTER")
		-- Get exact spell information for Travel Form
		local spellInfo = C_Spell.GetSpellInfo(783)      -- Travel Form spell ID
		local travelFormName = "Travel Form"             -- Default
		-- Get Cat Form name
		local catFormName = "Cat Form"                   -- Default
		local catFormSpellInfo = C_Spell.GetSpellInfo(768) -- Cat Form spell ID
		if type(catFormSpellInfo) == "table" and catFormSpellInfo.name then
			catFormName = catFormSpellInfo.name
			print("RMB_SECURE: Found Cat Form spell: " .. catFormName)
		end

		local useSmartFormSwitching = RandomMountBuddy:GetSetting("useSmartFormSwitching")
		if type(spellInfo) == "table" and spellInfo.name then
			travelFormName = spellInfo.name
			print("RMB_SECURE: Found Travel Form spell: " .. travelFormName)
			-- Check for smart form switching
			if useSmartFormSwitching then
				-- Smart form switching with proper form respecting
				if RandomMountBuddy:GetSetting("keepTravelFormActive") then
					travelButton:SetAttribute("type", "macro")
					travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName)
				else
					travelButton:SetAttribute("type", "macro")
					travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName)
				end
			else
				-- Use the standard macro pattern from the beginning
				if RandomMountBuddy:GetSetting("keepTravelFormActive") then
					travelButton:SetAttribute("type", "macro")
					travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName)
				else
					travelButton:SetAttribute("type", "macro")
					travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName)
				end
			end
		else
			print("RMB_SECURE: Travel Form spell info not found or invalid format")
		end

		travelButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create Ghost Wolf button (for shamans)
		ghostWolfButton = CreateFrame("Button", "RMBGhostWolfButton", UIParent, "SecureActionButtonTemplate")
		ghostWolfButton:SetSize(1, 1)
		ghostWolfButton:SetPoint("CENTER")
		-- Get exact spell information for Ghost Wolf
		local gwSpellInfo = C_Spell.GetSpellInfo(2645) -- Ghost Wolf spell ID
		local ghostWolfName = "Ghost Wolf"           -- Default
		if type(gwSpellInfo) == "table" and gwSpellInfo.name then
			ghostWolfName = gwSpellInfo.name
			print("RMB_SECURE: Found Ghost Wolf spell: " .. ghostWolfName)
			-- For Ghost Wolf, use the standard macro pattern with specific setting
			if RandomMountBuddy:GetSetting("keepGhostWolfActive") then
				ghostWolfButton:SetAttribute("type", "macro")
				ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName)
			else
				ghostWolfButton:SetAttribute("type", "macro")
				ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName)
			end
		else
			print("RMB_SECURE: Ghost Wolf spell info not found or invalid format")
		end

		ghostWolfButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create Zen Flight button (for monks)
		zenFlightButton = CreateFrame("Button", "RMBZenFlightButton", UIParent, "SecureActionButtonTemplate")
		zenFlightButton:SetSize(1, 1)
		zenFlightButton:SetPoint("CENTER")
		zenFlightButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Get exact spell information for Zen Flight
		local zfSpellInfo = C_Spell.GetSpellInfo(125883) -- Zen Flight spell ID
		local zenFlightName = "Zen Flight"             -- Default
		if type(zfSpellInfo) == "table" and zfSpellInfo.name then
			zenFlightName = zfSpellInfo.name
			zenFlightButton:SetAttribute("type", "macro")
			if RandomMountBuddy:GetSetting("keepZenFlightActive") then
				zenFlightButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast !]] .. zenFlightName)
			else
				zenFlightButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. zenFlightName)
			end
		else
			print("RMB_SECURE: Zen Flight spell info not found or invalid format")
		end

		-- Create Slow Fall button (for mages)
		slowFallButton = CreateFrame("Button", "RMBSlowFallButton", UIParent, "SecureActionButtonTemplate")
		slowFallButton:SetSize(1, 1)
		slowFallButton:SetPoint("CENTER")
		slowFallButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Get exact spell information for Slow Fall
		local sfSpellInfo = C_Spell.GetSpellInfo(130) -- Slow Fall spell ID
		local slowFallName = "Slow Fall"            -- Default
		local useSlowFallOnOthers = RandomMountBuddy:GetSetting("useSlowFallOnOthers")
		local slowFallTarget = useSlowFallOnOthers
				and "@target,help,exists][@mouseover,help,exists][@player"
				or "@player"
		if type(sfSpellInfo) == "table" and sfSpellInfo.name then
			slowFallName = sfSpellInfo.name
			print("RMB_SECURE: Found Slow Fall spell: " .. slowFallName)
			-- Set Slow Fall button macro
			slowFallButton:SetAttribute("type", "macro")
			slowFallButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. slowFallTarget .. "] " .. slowFallName)
		else
			print("RMB_SECURE: Slow Fall spell info not found or invalid format")
		end

		-- Create Levitate button (for priests)
		levitateButton = CreateFrame("Button", "RMBLevitateButton", UIParent, "SecureActionButtonTemplate")
		levitateButton:SetSize(1, 1)
		levitateButton:SetPoint("CENTER")
		levitateButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Get exact spell information for Levitate
		local levSpellInfo = C_Spell.GetSpellInfo(1706) -- Levitate spell ID
		local levitateName = "Levitate"               -- Default
		local useLevitateOnOthers = RandomMountBuddy:GetSetting("useLevitateOnOthers")
		local levitateTarget = useLevitateOnOthers
				and "@target,help,exists][@mouseover,help,exists][@player"
				or "@player"
		if type(levSpellInfo) == "table" and levSpellInfo.name then
			levitateName = levSpellInfo.name
			print("RMB_SECURE: Found Levitate spell: " .. levitateName)
			-- Set Levitate button macro
			levitateButton:SetAttribute("type", "macro")
			levitateButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. levitateTarget .. "] " .. levitateName)
		else
			print("RMB_SECURE: Levitate spell info not found or invalid format")
		end

		-- Create mount summon button
		mountButton = CreateFrame("Button", "RMBMountButton", UIParent, "SecureActionButtonTemplate")
		mountButton:SetSize(1, 1)
		mountButton:SetPoint("CENTER")
		mountButton:SetAttribute("type", "macro")
		mountButton:SetAttribute("macrotext", "/run RMB:SRM(true)")
		mountButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create invisible button
		visibleButton = CreateFrame("Button", "RMBVisibleButton", UIParent)
		visibleButton:SetSize(1, 1)
		visibleButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
		visibleButton:SetAlpha(0)
		-- Make draggable (though invisible)
		visibleButton:SetMovable(true)
		visibleButton:RegisterForDrag("LeftButton")
		visibleButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
		visibleButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		-- On click - decide which secure button to click based on class and movement/falling
		visibleButton:SetScript("OnClick", function()
			local _, playerClass = UnitClass("player")
			local isMoving = IsPlayerMoving()
			local isFalling = addonTable:IsPlayerFalling()
			local useSmartFormSwitching = RandomMountBuddy:GetSetting("useSmartFormSwitching")
			local isIndoors = IsIndoors()
			-- Add debug output for clicks
			print("RMB_SECURE_DEBUG: Click - Class: " .. playerClass ..
				", Moving: " .. tostring(isMoving) ..
				", Falling: " .. tostring(isFalling) ..
				", Indoors: " .. tostring(isIndoors) ..
				", SmartForm: " .. tostring(useSmartFormSwitching) ..
				", InCombat: " .. tostring(InCombatLockdown()))
			if playerClass == "DRUID" and ((isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving")) or
						(isIndoors and useSmartFormSwitching)) and not InCombatLockdown() then
				-- Druid moving or indoors - use form
				travelButton:Click()
				print("RMB_SECURE: Clicked Travel/Cat Form button" ..
					(useSmartFormSwitching and " (with smart form switching)" or ""))
			elseif playerClass == "SHAMAN" and ((isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving")) or
						(isIndoors and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving"))) and not InCombatLockdown() then
				-- Shaman moving or indoors - use Ghost Wolf
				ghostWolfButton:Click()
				print("RMB_SECURE: Clicked Ghost Wolf button")
			elseif playerClass == "MONK" and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") and not InCombatLockdown() then
				-- Monk moving or falling - use Zen Flight
				zenFlightButton:Click()
				print("RMB_SECURE: Clicked Zen Flight button")
			elseif playerClass == "MAGE" and isFalling and RandomMountBuddy:GetSetting("useSlowFallWhileFalling") then
				-- Mage falling - use Slow Fall
				slowFallButton:Click()
				print("RMB_SECURE: Clicked Slow Fall button")
			elseif playerClass == "PRIEST" and isFalling and RandomMountBuddy:GetSetting("useLevitateWhileFalling") then
				-- Priest falling - use Levitate
				levitateButton:Click()
				print("RMB_SECURE: Clicked Levitate button")
			else
				-- Otherwise use mount button
				mountButton:Click()
				print("RMB_SECURE: Clicked mount button")
			end
		end)
		-- Add tooltip
		visibleButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Random Mount Buddy")
			GameTooltip:AddLine("Click to summon a mount or cast shapeshift form", 1, 1, 1)
			GameTooltip:Show()
		end)
		visibleButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		-- Simple smart button for keybinding - movement & falling aware
		local _, playerClass = UnitClass("player")
		local isDruid = (playerClass == "DRUID")
		local isShaman = (playerClass == "SHAMAN")
		local isMonk = (playerClass == "MONK")
		local isMage = (playerClass == "MAGE")
		local isPriest = (playerClass == "PRIEST")
		-- Create the smart button for any class
		smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
		smartButton:SetSize(1, 1)
		smartButton:SetPoint("CENTER")
		smartButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Initially set to mount for all classes
		smartButton:SetAttribute("type", "macro")
		smartButton:SetAttribute("macrotext", "/run RMB:SRM(true)")
		-- Setup combat macros based on class
		local combatMacro = "" -- Initialize variable
		if isDruid then
			-- Create Druid combat macro with standard pattern
			if useSmartFormSwitching then
				if RandomMountBuddy:GetSetting("keepTravelFormActive") then
					addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName
				else
					addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName
				end
			else
				if RandomMountBuddy:GetSetting("keepTravelFormActive") then
					addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName
				else
					addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName
				end
			end

			addonTable.combatMacro = addonTable.druidCombatMacro
			print("RMB_SECURE: Created Druid combat macro" .. (useSmartFormSwitching and " with smart form switching" or ""))
		elseif isShaman then
			-- Create Shaman combat macro using standard pattern
			if RandomMountBuddy:GetSetting("keepGhostWolfActive") then
				addonTable.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName
			else
				addonTable.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName
			end

			addonTable.combatMacro = addonTable.shamanCombatMacro
			print("RMB_SECURE: Created standard Shaman combat macro")
		elseif isMonk then
			-- Create Monk combat macro with proper concatenation
			if RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
				if RandomMountBuddy:GetSetting("keepZenFlightActive") then
					addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast !]] .. zenFlightName
				else
					addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. zenFlightName
				end
			else
				addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
			end

			addonTable.combatMacro = addonTable.monkCombatMacro
			print("RMB_SECURE: Created Monk combat macro")
		elseif isMage then
			-- Create Mage combat macro
			if RandomMountBuddy:GetSetting("useSlowFallWhileFalling") then
				if RandomMountBuddy:GetSetting("useSlowFallOnOthers") then
					addonTable.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@target,help,exists][@mouseover,help,exists][@player] ]] .. slowFallName
				else
					addonTable.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@player] ]] .. slowFallName
				end
			else
				addonTable.mageCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
			end

			addonTable.combatMacro = addonTable.mageCombatMacro
			print("RMB_SECURE: Created Mage combat macro")
		elseif isPriest then
			-- Create Priest combat macro
			if RandomMountBuddy:GetSetting("useLevitateWhileFalling") then
				if RandomMountBuddy:GetSetting("useLevitateOnOthers") then
					addonTable.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@target,help,exists][@mouseover,help,exists][@player] ]] .. levitateName
				else
					addonTable.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] [@player] ]] .. levitateName
				end
			else
				addonTable.priestCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
			end

			addonTable.combatMacro = addonTable.priestCombatMacro
			print("RMB_SECURE: Created Priest combat macro")
		else
			-- Simple combat macro for other classes
			addonTable.combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
]]
		end

		-- Create a frame to monitor player movement and falling
		updateFrame = CreateFrame("Frame")
		updateFrame.elapsed = 0
		updateFrame.lastMoving = false
		updateFrame.lastFalling = false
		-- Update the button's attributes based on movement and falling
		updateFrame:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			-- Check movement and falling state every 0.1 seconds
			if self.elapsed > 0.1 then
				self.elapsed = 0
				-- Skip in combat
				if InCombatLockdown() then return end

				-- Check if player is moving or falling
				local isMoving = IsPlayerMoving()
				local isFalling = addonTable:IsPlayerFalling()
				local isIndoors = IsIndoors()
				-- Only update if state changed
				if isMoving ~= self.lastMoving or isFalling ~= self.lastFalling then
					self.lastMoving = isMoving
					self.lastFalling = isFalling
					-- Update button based on class and movement/falling
					if isDruid and ((isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving")) or
								(isIndoors and useSmartFormSwitching)) then
						-- Moving Druid or indoors - check if using smart form switching
						smartButton:SetAttribute("type", "macro")
						if useSmartFormSwitching then
							if RandomMountBuddy:GetSetting("keepTravelFormActive") then
								smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName)
							else
								smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName)
							end
						else
							-- Standard Travel Form logic
							local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
							if keepTravelFormActive then
								smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName)
							else
								smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName)
							end
						end
					elseif isShaman and ((isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving")) or
								(isIndoors and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving"))) then
						-- Moving Shaman or indoors - use the standard macro pattern
						local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
						smartButton:SetAttribute("type", "macro")
						if keepGhostWolfActive then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName)
						end
					elseif isMonk and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
						-- Moving or falling Monk - use simple single cast like other spells
						local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
						smartButton:SetAttribute("type", "macro")
						if keepZenFlightActive then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast !]] .. zenFlightName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. zenFlightName)
						end
					elseif isMage and isFalling and RandomMountBuddy:GetSetting("useSlowFallWhileFalling") then
						-- Falling Mage - use Slow Fall with target logic
						local useSlowFallOnOthers = RandomMountBuddy:GetSetting("useSlowFallOnOthers")
						local targetLogic = useSlowFallOnOthers
								and "@target,help,exists][@mouseover,help,exists][@player"
								or "@player"
						smartButton:SetAttribute("type", "macro")
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. targetLogic .. "] " .. slowFallName)
					elseif isPriest and isFalling and RandomMountBuddy:GetSetting("useLevitateWhileFalling") then
						-- Falling Priest - use Levitate with target logic
						local useLevitateOnOthers = RandomMountBuddy:GetSetting("useLevitateOnOthers")
						local targetLogic = useLevitateOnOthers
								and "@target,help,exists][@mouseover,help,exists][@player"
								or "@player"
						smartButton:SetAttribute("type", "macro")
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. targetLogic .. "] " .. levitateName)
					else
						-- Not moving/falling or class without shapeshift
						smartButton:SetAttribute("type", "macro")
						smartButton:SetAttribute("macrotext", "/run RMB:SRM(true)")
					end
				end
			end
		end)
		-- Register for combat
		updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		-- Handle combat events
		updateFrame:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				-- Skip if already in combat lockdown
				if InCombatLockdown() then return end

				-- In combat, set to combat macro
				smartButton:SetAttribute("type", "macro")
				smartButton:SetAttribute("macrotext", addonTable.combatMacro)
			elseif event == "PLAYER_REGEN_ENABLED" then
				-- Skip if in combat lockdown
				if InCombatLockdown() then return end

				-- Out of combat, use movement-based approach
				local isMoving = IsPlayerMoving()
				local isFalling = addonTable:IsPlayerFalling()
				local isIndoors = IsIndoors()
				if isDruid and ((isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving")) or
							(isIndoors and useSmartFormSwitching)) then
					-- Moving Druid or indoors - check for smart form switching
					smartButton:SetAttribute("type", "macro")
					if useSmartFormSwitching then
						if RandomMountBuddy:GetSetting("keepTravelFormActive") then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming,noform:3][outdoors,noform:3] ]] .. travelFormName .. [[
/cast [indoors,noform:1] ]] .. catFormName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [swimming][outdoors] ]] .. travelFormName .. [[
/cast [indoors] ]] .. catFormName)
						end
					else
						-- Standard Travel Form logic
						local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
						if keepTravelFormActive then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:3] ]] .. travelFormName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. travelFormName)
						end
					end
				elseif isShaman and ((isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving")) or
							(isIndoors and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving"))) then
					-- Moving Shaman or indoors - use the standard macro pattern
					local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
					smartButton:SetAttribute("type", "macro")
					if keepGhostWolfActive then
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [noform:1] ]] .. ghostWolfName)
					else
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast ]] .. ghostWolfName)
					end
				elseif isMonk and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
					-- Moving or falling Monk - use simple single cast like other spells
					local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
					smartButton:SetAttribute("type", "macro")
					if keepZenFlightActive then
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] !]] .. zenFlightName) -- not this one
					else
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] ]] .. zenFlightName)
					end
				elseif isMage and isFalling and RandomMountBuddy:GetSetting("useSlowFallWhileFalling") then
					-- Falling Mage - use Slow Fall with target logic
					local useSlowFallOnOthers = RandomMountBuddy:GetSetting("useSlowFallOnOthers")
					local targetLogic = useSlowFallOnOthers
							and "@target,help,exists][@mouseover,help,exists][@player"
							or "@player"
					smartButton:SetAttribute("type", "macro")
					smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. targetLogic .. "] " .. slowFallName)
				elseif isPriest and isFalling and RandomMountBuddy:GetSetting("useLevitateWhileFalling") then
					-- Falling Priest - use Levitate with target logic
					local useLevitateOnOthers = RandomMountBuddy:GetSetting("useLevitateOnOthers")
					local targetLogic = useLevitateOnOthers
							and "@target,help,exists][@mouseover,help,exists][@player"
							or "@player"
					smartButton:SetAttribute("type", "macro")
					smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RMB:SRM(true)
/run UIErrorsFrame:Hide() C_Timer.After(0, function() UIErrorsFrame:Clear() UIErrorsFrame:Show() end)
/cast [falling] []] .. targetLogic .. "] " .. levitateName)
				else
					-- Not moving/falling or class without shapeshift
					smartButton:SetAttribute("type", "macro")
					smartButton:SetAttribute("macrotext", "/run RMB:SRM(true)")
				end
			end
		end)
		-- Print debug info about class handler setup
		if isDruid then
			local useSmartFormSwitching = RandomMountBuddy:GetSetting("useSmartFormSwitching")
			print("RMB_SECURE: Set up smart button for Druid" .. (useSmartFormSwitching and " with smart form switching" or ""))
		elseif isShaman then
			print("RMB_SECURE: Set up smart button for Shaman")
		elseif isMonk then
			print("RMB_SECURE: Set up smart button for Monk with Zen Flight")
		elseif isMage then
			print("RMB_SECURE: Set up smart button for Mage with Slow Fall")
		elseif isPriest then
			print("RMB_SECURE: Set up smart button for Priest with Levitate")
		else
			print("RMB_SECURE: Set up simple mount button")
		end

		-- Store references
		addonTable.travelButton = travelButton
		addonTable.ghostWolfButton = ghostWolfButton
		addonTable.zenFlightButton = zenFlightButton
		addonTable.slowFallButton = slowFallButton
		addonTable.levitateButton = levitateButton
		addonTable.mountButton = mountButton
		addonTable.visibleButton = visibleButton
		addonTable.smartButton = smartButton
		addonTable.updateFrame = updateFrame
		-- Also store references on the main addon object
		RandomMountBuddy.travelButton = travelButton
		RandomMountBuddy.ghostWolfButton = ghostWolfButton
		RandomMountBuddy.zenFlightButton = zenFlightButton
		RandomMountBuddy.slowFallButton = slowFallButton
		RandomMountBuddy.levitateButton = levitateButton
		RandomMountBuddy.mountButton = mountButton
		RandomMountBuddy.visibleButton = visibleButton
		RandomMountBuddy.smartButton = smartButton
		RandomMountBuddy.updateFrame = updateFrame
		-- Create click method on the main addon object
		RandomMountBuddy.ClickMountButton = function(self)
			if self.visibleButton then
				self.visibleButton:Click()
				return true
			end

			return false
		end
		-- Expose the UpdateShapeshiftMacros function directly to prevent recursion
		RandomMountBuddy.UpdateShapeshiftMacros = addonTable.UpdateShapeshiftMacros
		-- Hook into the SetSetting function to update macros when settings change
		local originalSetSetting = RandomMountBuddy.SetSetting
		RandomMountBuddy.SetSetting = function(self, key, value)
			-- Call original function
			originalSetSetting(self, key, value)
			-- Update macros if relevant settings changed
			if key == "keepTravelFormActive" or key == "useTravelFormWhileMoving" or
					key == "useGhostWolfWhileMoving" or key == "useZenFlightWhileMoving" or
					key == "keepGhostWolfActive" or key == "keepZenFlightActive" or
					key == "useSlowFallWhileFalling" or key == "useSlowFallOnOthers" or
					key == "useLevitateWhileFalling" or key == "useLevitateOnOthers" or
					key == "useSmartFormSwitching" then
				addonTable:UpdateShapeshiftMacros()
			end
		end
		-- Initialize shapeshift macros
		addonTable:UpdateShapeshiftMacros()
		print("RMB_SECURE: Secure handlers initialized")
		-- Unregister the event
		self:UnregisterEvent("ADDON_LOADED")
		-- Show the button
		visibleButton:Show()
	end)
end

-- Initialize
addonTable:SetupSecureHandlers()
print("RMB_DEBUG: SecureHandlers.lua END.")
