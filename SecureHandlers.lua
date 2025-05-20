-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
-- Create secure action buttons and register keybindings
function addonTable:SetupSecureHandlers()
	-- Create a frame to handle initialization
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	-- Prepare for button creation
	local travelButton, mountButton, visibleButton, combinedButton
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
			travelButton:SetAttribute("type", "spell")
			travelButton:SetAttribute("spell", travelFormName)
		else
			print("RMB_SECURE: Travel Form spell info not found or invalid format")
			-- Use fallback
			travelButton:SetAttribute("type", "spell")
			travelButton:SetAttribute("spell", "Travel Form")
		end

		-- Register for clicks
		travelButton:RegisterForClicks("AnyUp", "AnyDown")
		-- Create mount summon button via macro
		mountButton = CreateFrame("Button", "RMBMountButton", UIParent, "SecureActionButtonTemplate")
		mountButton:SetSize(1, 1)
		mountButton:SetPoint("CENTER")
		mountButton:SetAttribute("type", "macro")
		mountButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
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
		-- On click - decide which secure button to click
		visibleButton:SetScript("OnClick", function()
			-- Check if druid and moving
			local _, playerClass = UnitClass("player")
			local isDruid = (playerClass == "DRUID")
			local isMoving = IsPlayerMoving()
			if isDruid and isMoving and not InCombatLockdown() then
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
		-- DIRECT APPROACH: Create a direct command button for the keybind
		local _, playerClass = UnitClass("player")
		local isDruid = (playerClass == "DRUID")
		if isDruid then
			-- For druids, we'll create a new combined secure action button
			-- This will handle both the Travel Form and mount summoning
			-- We'll create it with a secure action type that works directly
			-- Create a new secure macro text for the summon mount function
			local mountMacro = "/script RandomMountBuddy:SummonRandomMount(true)"
			-- Create a custom CombinedButtonPreClick handler
			-- This detects if the player is moving and sets the button attributes accordingly
			visibleButton:HookScript("PreClick", function(self)
				if InCombatLockdown() then return end

				local isMoving = IsPlayerMoving()
				print("RMB_DEBUG: PreClick check - Moving: " .. tostring(isMoving))
				-- Update combined button attributes based on movement state
				if isMoving then
					combinedButton:SetAttribute("type", "spell")
					combinedButton:SetAttribute("spell", travelFormName)
					print("RMB_DEBUG: Combined button set to cast Travel Form")
				else
					combinedButton:SetAttribute("type", "macro")
					combinedButton:SetAttribute("macrotext", mountMacro)
					print("RMB_DEBUG: Combined button set to summon mount")
				end
			end)
			-- Create the combined button
			combinedButton = CreateFrame("Button", "RMBCombinedButton", UIParent, "SecureActionButtonTemplate")
			combinedButton:SetSize(1, 1)
			combinedButton:SetPoint("CENTER")
			combinedButton:RegisterForClicks("AnyUp", "AnyDown")
			-- Initial setup - we'll update this in the PreClick hook
			combinedButton:SetAttribute("type", "spell")
			combinedButton:SetAttribute("spell", travelFormName)
			print("RMB_SECURE: Created druid combined button with dynamic attributes")
		else
			-- For non-druids, just duplicate the mount button's functionality
			combinedButton = CreateFrame("Button", "RMBCombinedButton", UIParent, "SecureActionButtonTemplate")
			combinedButton:SetSize(1, 1)
			combinedButton:SetPoint("CENTER")
			combinedButton:RegisterForClicks("AnyUp", "AnyDown")
			combinedButton:SetAttribute("type", "macro")
			combinedButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
			print("RMB_SECURE: Created non-druid combined button")
		end

		-- Add slash command to test the combined button
		SLASH_TESTCOMBINED1 = "/testcombined"
		SlashCmdList["TESTCOMBINED"] = function()
			print("RMB_DEBUG: Testing combined button - Current attributes:")
			print("Type: " .. (combinedButton:GetAttribute("type") or "nil"))
			if combinedButton:GetAttribute("type") == "spell" then
				print("Spell: " .. (combinedButton:GetAttribute("spell") or "nil"))
			elseif combinedButton:GetAttribute("type") == "macro" then
				print("Macro: " .. (combinedButton:GetAttribute("macrotext") or "nil"))
			end

			-- Try to click it
			if not InCombatLockdown() then
				print("RMB_DEBUG: Updating attributes based on movement")
				local isMoving = IsPlayerMoving()
				print("RMB_DEBUG: Moving: " .. tostring(isMoving))
				if isDruid and isMoving then
					combinedButton:SetAttribute("type", "spell")
					combinedButton:SetAttribute("spell", travelFormName)
					print("RMB_DEBUG: Set to cast Travel Form")
				else
					combinedButton:SetAttribute("type", "macro")
					combinedButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
					print("RMB_DEBUG: Set to summon mount")
				end
			else
				print("RMB_DEBUG: In combat, can't update attributes")
			end

			print("RMB_DEBUG: Clicking combined button")
			combinedButton:Click()
		end
		-- Store references
		addonTable.travelButton = travelButton
		addonTable.mountButton = mountButton
		addonTable.visibleButton = visibleButton
		addonTable.combinedButton = combinedButton
		-- Also store references on the main addon object
		RandomMountBuddy.travelButton = travelButton
		RandomMountBuddy.mountButton = mountButton
		RandomMountBuddy.visibleButton = visibleButton
		RandomMountBuddy.combinedButton = combinedButton
		-- Create click method on the main addon object
		RandomMountBuddy.ClickMountButton = function(self)
			-- Update combined button attributes based on current state
			if not InCombatLockdown() and isDruid then
				local isMoving = IsPlayerMoving()
				if isMoving then
					self.combinedButton:SetAttribute("type", "spell")
					self.combinedButton:SetAttribute("spell", travelFormName)
				else
					self.combinedButton:SetAttribute("type", "macro")
					self.combinedButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
				end
			end

			if self.combinedButton then
				self.combinedButton:Click()
				return true
			end

			return false
		end
		-- Register slash command for testing
		SLASH_RANDOMMOUNTBUTTON1 = "/rmount"
		SlashCmdList["RANDOMMOUNTBUTTON"] = function()
			if visibleButton then
				visibleButton:Click()
				print("RMB_SECURE: Button clicked via slash command")
			else
				print("RMB_SECURE: Button not found")
			end
		end
		-- Add a test slash command for Travel Form button
		SLASH_TRAVELFORM1 = "/tform"
		SlashCmdList["TRAVELFORM"] = function()
			print("RMB_DEBUG: Testing Travel Form button...")
			if _G["RMBTravelFormButton"] then
				print("RMB_DEBUG: Travel Form button found, clicking")
				_G["RMBTravelFormButton"]:Click()
			else
				print("RMB_DEBUG: Travel Form button not found in global scope")
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
