-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Create a function to update Travel Form macros based on the setting
function addonTable:UpdateTravelFormMacros()
	-- Skip if in combat
	if InCombatLockdown() then return end

	-- Get the setting
	local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
	-- Get localized spell name
	local travelFormName = "Travel Form" -- Default
	local spellInfo = C_Spell.GetSpellInfo(783)
	if type(spellInfo) == "table" and spellInfo.name then
		travelFormName = spellInfo.name
	end

	-- Update the travel button macro
	if self.travelButton then
		if keepTravelFormActive then
			self.travelButton:SetAttribute("type", "macro")
			self.travelButton:SetAttribute("macrotext", "/cast [noform:3] " .. travelFormName)
		else
			self.travelButton:SetAttribute("type", "macro")
			self.travelButton:SetAttribute("macrotext", "/cast " .. travelFormName)
		end
	end

	-- Update the smartButton macro if moving
	if self.smartButton and self.updateFrame and self.updateFrame.lastMoving then
		local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
		if self.updateFrame.lastMoving and useTravelFormWhileMoving then
			if keepTravelFormActive then
				self.smartButton:SetAttribute("type", "macro")
				self.smartButton:SetAttribute("macrotext", "/cast [noform:3] " .. travelFormName)
			else
				self.smartButton:SetAttribute("type", "macro")
				self.smartButton:SetAttribute("macrotext", "/cast " .. travelFormName)
			end
		end
	end

	-- Update the combat macro
	if keepTravelFormActive then
		self.combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/cast [noform:3] ]] .. travelFormName .. [[
/stopmacro [form]
/run RandomMountBuddy:SummonRandomMount(true)
]]
	else
		self.combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/cast ]] .. travelFormName .. [[
/stopmacro [form]
/run RandomMountBuddy:SummonRandomMount(true)
]]
	end

	-- Update smartButton with the new combat macro if it exists
	if self.smartButton and self.updateFrame then
		-- Apply the updated combat macro if currently in combat
		if InCombatLockdown() and self.updateFrame:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self.smartButton:SetAttribute("type", "macro")
			self.smartButton:SetAttribute("macrotext", self.combatMacro)
		end
	end

	print("RMB_SECURE: Updated Travel Form macros. Keep form active: " .. tostring(keepTravelFormActive))
end

-- Create secure action buttons and register keybindings
function addonTable:SetupSecureHandlers()
	-- Create a frame to handle initialization
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	-- Prepare for button creation
	local travelButton, mountButton, visibleButton, smartButton, updateFrame
	-- Initialize on addon load
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		print("RMB_SECURE: Initializing secure handlers...")
		-- Create Travel Form button (for druids)
		travelButton = CreateFrame("Button", "RMBTravelFormButton", UIParent, "SecureActionButtonTemplate")
		travelButton:SetSize(1, 1)
		travelButton:SetPoint("CENTER")
		-- Get exact spell information
		local spellInfo = C_Spell.GetSpellInfo(783) -- Travel Form spell ID
		local travelFormName = "Travel Form"      -- Default
		if type(spellInfo) == "table" and spellInfo.name then
			travelFormName = spellInfo.name
			print("RMB_SECURE: Found Travel Form spell: " .. travelFormName)
			-- Check keepTravelFormActive setting
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", "/cast [noform:3] " .. travelFormName)
			else
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", "/cast " .. travelFormName)
			end
		else
			print("RMB_SECURE: Travel Form spell info not found or invalid format")
			-- Use fallback
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", "/cast [noform:3] Travel Form")
			else
				travelButton:SetAttribute("type", "macro")
				travelButton:SetAttribute("macrotext", "/cast Travel Form")
			end
		end

		-- Register for clicks
		travelButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create mount summon button
		mountButton = CreateFrame("Button", "RMBMountButton", UIParent, "SecureActionButtonTemplate")
		mountButton:SetSize(1, 1)
		mountButton:SetPoint("CENTER")
		mountButton:SetAttribute("type", "macro")
		mountButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
		mountButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create invisible button (previously visibleButton)
		visibleButton = CreateFrame("Button", "RMBVisibleButton", UIParent)
		visibleButton:SetSize(1, 1)                                      -- Make it tiny (1x1 pixel)
		visibleButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0) -- Move off-screen
		visibleButton:SetAlpha(0)                                        -- Make completely transparent
		-- Make draggable
		visibleButton:SetMovable(true)
		visibleButton:RegisterForDrag("LeftButton")
		visibleButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
		visibleButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		-- On click - decide which secure button to click
		visibleButton:SetScript("OnClick", function()
			-- Check if druid and moving and option enabled
			local _, playerClass = UnitClass("player")
			local isDruid = (playerClass == "DRUID")
			local isMoving = IsPlayerMoving()
			local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
			if isDruid and isMoving and useTravelFormWhileMoving and not InCombatLockdown() then
				-- Use Travel Form button
				travelButton:Click()
				print("RMB_SECURE: Clicked Travel Form button")
			else
				-- Use mount button
				mountButton:Click()
				print("RMB_SECURE: Clicked mount button")
			end
		end)
		-- Add tooltip
		visibleButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Random Mount Buddy")
			GameTooltip:AddLine("Click to summon a mount or cast Travel Form", 1, 1, 1)
			GameTooltip:Show()
		end)
		visibleButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		-- Simple smart button for keybinding - movement aware
		local _, playerClass = UnitClass("player")
		local isDruid = (playerClass == "DRUID")
		if isDruid then
			-- Create the smart button
			smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
			smartButton:SetSize(1, 1)
			smartButton:SetPoint("CENTER")
			smartButton:RegisterForClicks("AnyUp", "AnyDown")
			-- Create combat fallback macro based on keepTravelFormActive setting
			local combatMacro
			if RandomMountBuddy:GetSetting("keepTravelFormActive") then
				combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/cast [noform:3] ]] .. travelFormName .. [[
/stopmacro [form]
/run RandomMountBuddy:SummonRandomMount(true)
]]
			else
				combatMacro = [[
/dismount [mounted]
/stopmacro [mounted]
/cast ]] .. travelFormName .. [[
/stopmacro [form]
/run RandomMountBuddy:SummonRandomMount(true)
]]
			end

			-- Store combat macro for future updates
			addonTable.combatMacro = combatMacro
			-- Initially set to mount
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
			-- Create a frame to monitor player movement
			updateFrame = CreateFrame("Frame")
			updateFrame.elapsed = 0
			updateFrame.lastMoving = false
			-- Update the button's attributes based on movement
			updateFrame:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = self.elapsed + elapsed
				-- Check movement state every 0.1 seconds
				if self.elapsed > 0.1 then
					self.elapsed = 0
					-- Skip in combat
					if InCombatLockdown() then return end

					-- Check if player is moving and option is enabled
					local isMoving = IsPlayerMoving()
					local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
					-- Only update if state changed
					if isMoving ~= self.lastMoving then
						self.lastMoving = isMoving
						-- Update button based on movement
						if isMoving and useTravelFormWhileMoving then
							local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
							smartButton:SetAttribute("type", "macro")
							if keepTravelFormActive then
								smartButton:SetAttribute("macrotext", "/cast [noform:3] " .. travelFormName)
							else
								smartButton:SetAttribute("macrotext", "/cast " .. travelFormName)
							end
						else
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
					local useTravelFormWhileMoving = RandomMountBuddy:GetSetting("useTravelFormWhileMoving")
					if isMoving and useTravelFormWhileMoving then
						local keepTravelFormActive = RandomMountBuddy:GetSetting("keepTravelFormActive")
						smartButton:SetAttribute("type", "macro")
						if keepTravelFormActive then
							smartButton:SetAttribute("macrotext", "/cast [noform:3] " .. travelFormName)
						else
							smartButton:SetAttribute("macrotext", "/cast " .. travelFormName)
						end
					else
						smartButton:SetAttribute("type", "macro")
						smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
					end
				end
			end)
			print("RMB_SECURE: Set up smart button")
		else
			-- For non-druids, just use the mount button
			smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
			smartButton:SetSize(1, 1)
			smartButton:SetPoint("CENTER")
			smartButton:RegisterForClicks("AnyUp", "AnyDown")
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
			print("RMB_SECURE: Set up simple mount button for non-druids")
		end

		-- Store references
		addonTable.travelButton = travelButton
		addonTable.mountButton = mountButton
		addonTable.visibleButton = visibleButton
		addonTable.smartButton = smartButton
		addonTable.updateFrame = updateFrame
		-- Also store references on the main addon object
		RandomMountBuddy.travelButton = travelButton
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
			-- Update macros if the relevant setting changed
			if key == "keepTravelFormActive" or key == "useTravelFormWhileMoving" then
				addonTable:UpdateTravelFormMacros()
			end
		end
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
