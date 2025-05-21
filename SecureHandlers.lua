-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Function to detect if the player is falling (used for Zen Flight)
function addonTable:IsPlayerFalling()
	-- In WoW, we can check if the player is falling with this API
	return IsFalling()
end

-- Function to update all shapeshift form macros based on settings
function addonTable:UpdateShapeshiftMacros()
	-- Skip if in combat
	if InCombatLockdown() then return end

	-- Get settings
	local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
	local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
	local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
	local useGhostWolfWhileMoving = RandomMountBuddy:GetSetting("useGhostWolfWhileMoving")
	local useZenFlightWhileMoving = RandomMountBuddy:GetSetting("useZenFlightWhileMoving")
	-- Get Travel Form name
	local travelFormName = "Travel Form" -- Default
	local spellInfo = C_Spell.GetSpellInfo(783)
	if type(spellInfo) == "table" and spellInfo.name then
		travelFormName = spellInfo.name
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

	-- Update druid buttons if they exist
	if self.travelButton then
		-- For Travel Form, use the standard macro pattern with noform
		if keepTravelFormActive then
			self.travelButton:SetAttribute("type", "macro")
			self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName)
		else
			self.travelButton:SetAttribute("type", "macro")
			self.travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName)
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
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName)
		else
			self.ghostWolfButton:SetAttribute("type", "macro")
			self.ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName)
		end
	end

	-- Update monk Zen Flight button if it exists - with proper concatenation
	if self.zenFlightButton then
		-- For Zen Flight, construct macrotext correctly with proper concatenation
		local fallingPart
		local castPart
		if keepZenFlightActive then
			-- With ! prefix
			fallingPart = "/cast [falling,nocombat] !" .. zenFlightName
			castPart = "/cast !" .. zenFlightName
		else
			-- Without ! prefix
			fallingPart = "/cast [falling,nocombat] " .. zenFlightName
			castPart = "/cast " .. zenFlightName
		end

		-- Now build the full macro with proper concatenation
		local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
		self.zenFlightButton:SetAttribute("type", "macro")
		self.zenFlightButton:SetAttribute("macrotext", macroText)
		print("RMB_SECURE: Set Zen Flight button macro with spell name: " .. zenFlightName)
	end

	-- Update the smartButton macro based on class
	if self.smartButton and self.updateFrame then
		local _, playerClass = UnitClass("player")
		if playerClass == "DRUID" and self.updateFrame.lastMoving then
			local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
			if self.updateFrame.lastMoving and useTravelFormWhileMoving then
				if keepTravelFormActive then
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName)
				else
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName)
				end
			end
		elseif playerClass == "SHAMAN" and self.updateFrame.lastMoving then
			if self.updateFrame.lastMoving and useGhostWolfWhileMoving then
				if keepGhostWolfActive then
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName)
				else
					self.smartButton:SetAttribute("type", "macro")
					self.smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName)
				end
			end
		elseif playerClass == "MONK" and (self.updateFrame.lastMoving or self.updateFrame.lastFalling) then
			if useZenFlightWhileMoving then
				-- Use proper string concatenation for Zen Flight
				local fallingPart
				local castPart
				if keepZenFlightActive then
					-- With ! prefix
					fallingPart = "/cast [falling,nocombat] !" .. zenFlightName
					castPart = "/cast !" .. zenFlightName
				else
					-- Without ! prefix
					fallingPart = "/cast [falling,nocombat] " .. zenFlightName
					castPart = "/cast " .. zenFlightName
				end

				-- Build the full macro
				local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
				self.smartButton:SetAttribute("type", "macro")
				self.smartButton:SetAttribute("macrotext", macroText)
			end
		end
	end

	-- Update the combat macros
	-- Create Druid combat macro using standard pattern
	if keepTravelFormActive then
		self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName
	else
		self.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName
	end

	-- Create simplified macro for shamans - use keepGhostWolfActive setting
	if useGhostWolfWhileMoving then
		if keepGhostWolfActive then
			self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName
		else
			self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName
		end
	else
		-- If Ghost Wolf setting is disabled, still provide the same functionality
		-- This maintains consistent behavior in the special dungeon
		self.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName
	end

	-- Create Monk combat macro - with proper concatenation
	if useZenFlightWhileMoving then
		if keepZenFlightActive then
			-- With ! prefix
			self.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast !]] .. zenFlightName
		else
			-- Without ! prefix
			self.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. zenFlightName
		end
	else
		-- If Zen Flight setting is disabled, just try to mount
		self.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
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
	end

	print("RMB_SECURE: Updated shapeshift macros")
end

-- Create secure action buttons and register keybindings
function addonTable:SetupSecureHandlers()
	-- Create a frame to handle initialization
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	-- Prepare for button creation
	local travelButton, ghostWolfButton, zenFlightButton, mountButton, visibleButton, smartButton, updateFrame
	-- Initialize on addon load
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		print("RMB_SECURE: Initializing secure handlers...")
		-- Create Travel Form button (for druids)
		travelButton = CreateFrame("Button", "RMBTravelFormButton", UIParent, "SecureActionButtonTemplate")
		travelButton:SetSize(1, 1)
		travelButton:SetPoint("CENTER")
		-- Get exact spell information for Travel Form
		local spellInfo = C_Spell.GetSpellInfo(783) -- Travel Form spell ID
		local travelFormName = "Travel Form"      -- Default
		if type(spellInfo) == "table" and spellInfo.name then
			travelFormName = spellInfo.name
			print("RMB_SECURE: Found Travel Form spell: " .. travelFormName)
			-- Use the standard macro pattern from the beginning
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName)
			else
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName)
			end
		else
			print("RMB_SECURE: Travel Form spell info not found or invalid format")
			-- Use fallback with standard macro pattern
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] Travel Form]])
			else
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast Travel Form]])
			end
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
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName)
			else
				ghostWolfButton:SetAttribute("type", "macro")
				ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName)
			end
		else
			print("RMB_SECURE: Ghost Wolf spell info not found or invalid format")
			-- Use fallback
			if RandomMountBuddy:GetSetting("keepGhostWolfActive") then
				ghostWolfButton:SetAttribute("type", "macro")
				ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] Ghost Wolf]])
			else
				ghostWolfButton:SetAttribute("type", "macro")
				ghostWolfButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast Ghost Wolf]])
			end
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
			print("RMB_SECURE: Found Zen Flight spell: " .. zenFlightName)
			-- For Zen Flight, properly construct the macro with concatenation
			local fallingPart
			local castPart
			if RandomMountBuddy:GetSetting("keepZenFlightActive") then
				-- With ! prefix
				fallingPart = "/cast [falling,nocombat] !" .. zenFlightName
				castPart = "/cast !" .. zenFlightName
			else
				-- Without ! prefix
				fallingPart = "/cast [falling,nocombat] " .. zenFlightName
				castPart = "/cast " .. zenFlightName
			end

			-- Build the full macro
			local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
			zenFlightButton:SetAttribute("type", "macro")
			zenFlightButton:SetAttribute("macrotext", macroText)
		else
			print("RMB_SECURE: Zen Flight spell info not found or invalid format")
			-- Use fallback with standard concatenation
			local fallingPart
			local castPart
			if RandomMountBuddy:GetSetting("keepZenFlightActive") then
				-- With ! prefix
				fallingPart = "/cast [falling,nocombat] !Zen Flight"
				castPart = "/cast !Zen Flight"
			else
				-- Without ! prefix
				fallingPart = "/cast [falling,nocombat] Zen Flight"
				castPart = "/cast Zen Flight"
			end

			-- Build the full macro
			local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
			zenFlightButton:SetAttribute("type", "macro")
			zenFlightButton:SetAttribute("macrotext", macroText)
		end

		-- Create mount summon button
		mountButton = CreateFrame("Button", "RMBMountButton", UIParent, "SecureActionButtonTemplate")
		mountButton:SetSize(1, 1)
		mountButton:SetPoint("CENTER")
		mountButton:SetAttribute("type", "macro")
		mountButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
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
			-- Add debug output for clicks
			print("RMB_SECURE_DEBUG: Click - Class: " .. playerClass ..
				", Moving: " .. tostring(isMoving) ..
				", Falling: " .. tostring(isFalling) ..
				", Setting: " .. tostring(RandomMountBuddy:GetSetting("useZenFlightWhileMoving")) ..
				", InCombat: " .. tostring(InCombatLockdown()))
			if playerClass == "DRUID" and isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving") and not InCombatLockdown() then
				-- Druid moving - use Travel Form
				travelButton:Click()
				print("RMB_SECURE: Clicked Travel Form button")
			elseif playerClass == "SHAMAN" and isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving") and not InCombatLockdown() then
				-- Shaman moving - use Ghost Wolf
				ghostWolfButton:Click()
				print("RMB_SECURE: Clicked Ghost Wolf button")
			elseif playerClass == "MONK" and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") and not InCombatLockdown() then
				-- Monk moving or falling - use Zen Flight
				zenFlightButton:Click()
				print("RMB_SECURE: Clicked Zen Flight button")
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
		-- Create the smart button for any class
		smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
		smartButton:SetSize(1, 1)
		smartButton:SetPoint("CENTER")
		smartButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Initially set to mount for all classes
		smartButton:SetAttribute("type", "macro")
		smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
		-- Setup combat macros based on class
		local combatMacro = "" -- Initialize variable
		if isDruid then
			-- Create Druid combat macro with standard pattern
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName
			else
				addonTable.druidCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName
			end

			addonTable.combatMacro = addonTable.druidCombatMacro
			print("RMB_SECURE: Created Druid combat macro with standard pattern")
		elseif isShaman then
			-- Create Shaman combat macro using standard pattern
			if RandomMountBuddy:GetSetting("keepGhostWolfActive") then
				addonTable.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName
			else
				addonTable.shamanCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
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
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast !]] .. zenFlightName
				else
					addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. zenFlightName
				end
			else
				addonTable.monkCombatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
]]
			end

			addonTable.combatMacro = addonTable.monkCombatMacro
			print("RMB_SECURE: Created Monk combat macro")
		else
			-- Simple combat macro for other classes
			addonTable.combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
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
				-- Only update if state changed
				if isMoving ~= self.lastMoving or isFalling ~= self.lastFalling then
					self.lastMoving = isMoving
					self.lastFalling = isFalling
					-- Update button based on class and movement/falling
					if isDruid and isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving") then
						-- Moving Druid - use the standard macro pattern
						local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
						smartButton:SetAttribute("type", "macro")
						if keepTravelFormActive then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName)
						end
					elseif isShaman and isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving") then
						-- Moving Shaman - use the standard macro pattern
						local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
						smartButton:SetAttribute("type", "macro")
						if keepGhostWolfActive then
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName)
						else
							smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName)
						end
					elseif isMonk and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
						-- Moving or falling Monk - properly construct the macro
						local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
						smartButton:SetAttribute("type", "macro")
						-- Build the Zen Flight macro with proper concatenation
						local fallingPart
						local castPart
						if keepZenFlightActive then
							-- With ! prefix
							fallingPart = "/cast [falling,nocombat] !" .. zenFlightName
							castPart = "/cast !" .. zenFlightName
						else
							-- Without ! prefix
							fallingPart = "/cast [falling,nocombat] " .. zenFlightName
							castPart = "/cast " .. zenFlightName
						end

						-- Build the full macro
						local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
						smartButton:SetAttribute("macrotext", macroText)
					else
						-- Not moving/falling or class without shapeshift
						smartButton:SetAttribute("type", "macro")
						smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
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
				if isDruid and isMoving and RandomMountBuddy:GetSetting("useTravelFormWhileMoving") then
					-- Moving Druid - use the standard macro pattern
					local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
					smartButton:SetAttribute("type", "macro")
					if keepTravelFormActive then
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:3] ]] .. travelFormName)
					else
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. travelFormName)
					end
				elseif isShaman and isMoving and RandomMountBuddy:GetSetting("useGhostWolfWhileMoving") then
					-- Moving Shaman - use the standard macro pattern
					local keepGhostWolfActive = RandomMountBuddy:GetSetting("keepGhostWolfActive")
					smartButton:SetAttribute("type", "macro")
					if keepGhostWolfActive then
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast [noform:1] ]] .. ghostWolfName)
					else
						smartButton:SetAttribute("macrotext", [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
/cast ]] .. ghostWolfName)
					end
				elseif isMonk and (isMoving or isFalling) and RandomMountBuddy:GetSetting("useZenFlightWhileMoving") then
					-- Moving or falling Monk - properly construct the macro
					local keepZenFlightActive = RandomMountBuddy:GetSetting("keepZenFlightActive")
					smartButton:SetAttribute("type", "macro")
					-- Build the Zen Flight macro with proper concatenation
					local fallingPart
					local castPart
					if keepZenFlightActive then
						-- With ! prefix
						fallingPart = "/cast [falling,nocombat] !" .. zenFlightName
						castPart = "/cast !" .. zenFlightName
					else
						-- Without ! prefix
						fallingPart = "/cast [falling,nocombat] " .. zenFlightName
						castPart = "/cast " .. zenFlightName
					end

					-- Build the full macro
					local macroText = [[
/dismount [mounted]
/stopmacro [mounted]
/run RandomMountBuddy:SummonRandomMount(true)
/run UIErrorsFrame:Clear()
]] .. fallingPart .. [[

]] .. castPart
					smartButton:SetAttribute("macrotext", macroText)
				else
					-- Not moving/falling or class without shapeshift
					smartButton:SetAttribute("type", "macro")
					smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
				end
			end
		end)
		-- Print debug info about class handler setup
		if isDruid then
			print("RMB_SECURE: Set up smart button for Druid")
		elseif isShaman then
			print("RMB_SECURE: Set up smart button for Shaman")
		elseif isMonk then
			print("RMB_SECURE: Set up smart button for Monk with Zen Flight")
		else
			print("RMB_SECURE: Set up simple mount button")
		end

		-- Store references
		addonTable.travelButton = travelButton
		addonTable.ghostWolfButton = ghostWolfButton
		addonTable.zenFlightButton = zenFlightButton
		addonTable.mountButton = mountButton
		addonTable.visibleButton = visibleButton
		addonTable.smartButton = smartButton
		addonTable.updateFrame = updateFrame
		-- Also store references on the main addon object
		RandomMountBuddy.travelButton = travelButton
		RandomMountBuddy.ghostWolfButton = ghostWolfButton
		RandomMountBuddy.zenFlightButton = zenFlightButton
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
		-- Hook into the SetSetting function to update macros when settings change
		local originalSetSetting = RandomMountBuddy.SetSetting
		RandomMountBuddy.SetSetting = function(self, key, value)
			-- Call original function
			originalSetSetting(self, key, value)
			-- Update macros if relevant settings changed
			if key == "keepTravelFormActive" or key == "useTravelFormWhileMoving" or
					key == "useGhostWolfWhileMoving" or key == "useZenFlightWhileMoving" or
					key == "keepGhostWolfActive" or key == "keepZenFlightActive" then
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
