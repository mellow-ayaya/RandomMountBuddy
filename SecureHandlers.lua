-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Create secure action buttons and register keybindings
function addonTable:SetupSecureHandlers()
	-- Create a frame to handle initialization
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	-- Prepare for button creation
	local travelButton, mountButton, visibleButton, smartButton, combatButton, stateHandler, updateFrame
	-- Initialize on addon load
	eventFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
		if addonNameLoaded ~= "RandomMountBuddy" then return end

		print("RMB_SECURE: Initializing secure handlers...")
		-- Get spell information for druid forms
		local travelFormName, catFormName = "Travel Form", "Cat Form"
		local travelFormInfo = C_Spell.GetSpellInfo(783) -- Travel Form ID
		local catFormInfo = C_Spell.GetSpellInfo(768)  -- Cat Form ID
		if type(travelFormInfo) == "table" and travelFormInfo.name then
			travelFormName = travelFormInfo.name
			print("RMB_SECURE: Found Travel Form spell: " .. travelFormName)
		end

		if type(catFormInfo) == "table" and catFormInfo.name then
			catFormName = catFormInfo.name
			print("RMB_SECURE: Found Cat Form spell: " .. catFormName)
		end

		-- Create Travel Form button (for druids)
		travelButton = CreateFrame("Button", "RMBTravelFormButton", UIParent, "SecureActionButtonTemplate")
		travelButton:SetSize(1, 1)
		travelButton:SetPoint("CENTER")
		travelButton:SetAttribute("type", "spell")
		travelButton:SetAttribute("spell", travelFormName)
		travelButton:RegisterForClicks("AnyUp")
		-- Create mount summon button
		mountButton = CreateFrame("Button", "RMBMountButton", UIParent, "SecureActionButtonTemplate")
		mountButton:SetSize(1, 1)
		mountButton:SetPoint("CENTER")
		mountButton:SetAttribute("type", "macro")
		mountButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
		mountButton:RegisterForClicks("AnyUp")
		-- Create visible button
		visibleButton = CreateFrame("Button", "RMBVisibleButton", UIParent)
		visibleButton:SetSize(40, 40)
		visibleButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		-- Set appearance
		local texture = visibleButton:CreateTexture(nil, "ARTWORK")
		texture:SetAllPoints()
		texture:SetTexture("Interface\\Icons\\Ability_Mount_RidingHorse")
		visibleButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
		-- Make draggable
		visibleButton:SetMovable(true)
		visibleButton:RegisterForDrag("LeftButton")
		visibleButton:SetScript("OnDragStart", function(self) self:StartMoving() end)
		visibleButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		-- On click handler for visible button
		visibleButton:SetScript("OnClick", function()
			local _, playerClass = UnitClass("player")
			local isDruid = (playerClass == "DRUID")
			local isMoving = IsPlayerMoving()
			if isDruid and isMoving and not InCombatLockdown() then
				travelButton:Click()
				print("RMB_SECURE: Clicked Travel Form button")
			else
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
		-- Check if player is a druid
		local _, playerClass = UnitClass("player")
		local isDruid = (playerClass == "DRUID")
		if isDruid then
			-- 1. CREATE OUT OF COMBAT BUTTON (movement-aware)
			smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
			smartButton:SetSize(1, 1)
			smartButton:SetPoint("CENTER")
			smartButton:RegisterForClicks("AnyUp")
			-- Initially set to mount
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
			-- 2. CREATE COMBAT BUTTON (indoor/outdoor aware)
			combatButton = CreateFrame("Button", "RMBCombatButton", UIParent, "SecureActionButtonTemplate")
			combatButton:SetSize(1, 1)
			combatButton:SetPoint("CENTER")
			combatButton:RegisterForClicks("AnyUp")
			-- Simple combat macro for indoor/outdoor forms
			local combatMacro = [[
/dismount [mounted]
/cast [indoors] ]] .. catFormName .. [[
/cast [outdoors] ]] .. travelFormName
			combatButton:SetAttribute("type", "macro")
			combatButton:SetAttribute("macrotext", combatMacro)
			-- 3. CREATE STATE HANDLER (for switching between combat/non-combat)
			stateHandler = CreateFrame("Button", "RMBStateHandler", UIParent,
				"SecureHandlerStateTemplate, SecureActionButtonTemplate")
			stateHandler:SetSize(1, 1)
			stateHandler:SetPoint("CENTER")
			stateHandler:RegisterForClicks("AnyUp")
			-- Set frame references
			stateHandler:SetFrameRef("outCombatButton", smartButton)
			stateHandler:SetFrameRef("inCombatButton", combatButton)
			-- Set up the state driver for combat
			stateHandler:SetAttribute("_onstate-combat", [[
                local outCombatButton = self:GetFrameRef("outCombatButton")
                local inCombatButton = self:GetFrameRef("inCombatButton")

                if newstate == "1" then
                    -- In combat
                    self:SetAttribute("type", "click")
                    self:SetAttribute("clickbutton", inCombatButton)
                else
                    -- Out of combat
                    self:SetAttribute("type", "click")
                    self:SetAttribute("clickbutton", outCombatButton)
                end
            ]])
			-- Set initial state
			stateHandler:SetAttribute("type", "click")
			stateHandler:SetAttribute("clickbutton", smartButton)
			-- Register the state driver for combat
			RegisterStateDriver(stateHandler, "combat", "[combat] 1; 0")
			-- 4. CREATE MOVEMENT TRACKER (for out of combat)
			updateFrame = CreateFrame("Frame")
			updateFrame.elapsed = 0
			updateFrame.lastMoving = false
			updateFrame:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = self.elapsed + elapsed
				if self.elapsed > 0.1 then
					self.elapsed = 0
					-- Skip in combat
					if InCombatLockdown() then return end

					-- Check movement state
					local isMoving = IsPlayerMoving()
					if isMoving ~= self.lastMoving then
						self.lastMoving = isMoving
						-- Update button based on movement
						if isMoving then
							smartButton:SetAttribute("type", "spell")
							smartButton:SetAttribute("spell", travelFormName)
						else
							smartButton:SetAttribute("type", "macro")
							smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
						end
					end
				end
			end)
			print("RMB_SECURE: Set up smart keybinding system for druids")
		else
			-- For non-druids, just create a simple button that summons a mount
			stateHandler = CreateFrame("Button", "RMBStateHandler", UIParent, "SecureActionButtonTemplate")
			stateHandler:SetSize(1, 1)
			stateHandler:SetPoint("CENTER")
			stateHandler:RegisterForClicks("AnyUp")
			stateHandler:SetAttribute("type", "macro")
			stateHandler:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
			print("RMB_SECURE: Set up simple mount button for non-druids")
		end

		-- Store references
		addonTable.travelButton = travelButton
		addonTable.mountButton = mountButton
		addonTable.visibleButton = visibleButton
		addonTable.smartButton = smartButton
		addonTable.combatButton = combatButton
		addonTable.stateHandler = stateHandler
		addonTable.updateFrame = updateFrame
		-- Also store references on the main addon object
		RandomMountBuddy.travelButton = travelButton
		RandomMountBuddy.mountButton = mountButton
		RandomMountBuddy.visibleButton = visibleButton
		RandomMountBuddy.smartButton = smartButton
		RandomMountBuddy.combatButton = combatButton
		RandomMountBuddy.stateHandler = stateHandler
		RandomMountBuddy.updateFrame = updateFrame
		-- Set up click method on the main addon object
		RandomMountBuddy.ClickMountButton = function(self)
			if self.visibleButton then
				self.visibleButton:Click()
				return true
			end

			return false
		end
		-- Test slash command for the smart button
		SLASH_SMARTBUTTON1 = "/smartbutton"
		SlashCmdList["SMARTBUTTON"] = function()
			if _G["RMBStateHandler"] then
				local isMoving = IsPlayerMoving()
				local inCombat = UnitAffectingCombat("player")
				local isMounted = IsMounted()
				local isIndoors = IsIndoors()
				print("RMB_DEBUG: State - Moving:", isMoving, "Combat:", inCombat,
					"Mounted:", isMounted, "Indoors:", isIndoors)
				_G["RMBStateHandler"]:Click()
			else
				print("RMB_DEBUG: State handler not found")
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
