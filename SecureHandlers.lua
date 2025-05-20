-- SecureHandlers.lua
local addonName, addonTable = ...
print("RMB_DEBUG: SecureHandlers.lua START.")
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
		mountButton:RegisterForClicks("AnyUp", "AnyDown")
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
		-- SIMPLIFIED APPROACH: Create a smart button that directly switches between Travel Form and mounting
		local _, playerClass = UnitClass("player")
		local isDruid = (playerClass == "DRUID")
		if isDruid then
			-- Create simple smart button
			-- Create simple smart button
			smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
			smartButton:SetSize(1, 1)
			smartButton:SetPoint("CENTER")
			smartButton:RegisterForClicks("AnyUp", "AnyDown")
			-- Set initial state to mount (instead of Travel Form)
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
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

					-- Check if player is moving
					local isMoving = IsPlayerMoving()
					-- Only update if state changed
					if isMoving ~= self.lastMoving then
						self.lastMoving = isMoving
						-- Update button based on movement
						if isMoving then
							print("RMB_SMART: Moving - switching to Travel Form")
							smartButton:SetAttribute("type", "spell")
							smartButton:SetAttribute("spell", travelFormName)
						else
							print("RMB_SMART: Stationary - switching to mount")
							smartButton:SetAttribute("type", "macro")
							smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
						end
					end
				end
			end)
			print("RMB_SECURE: Set up smart button with movement tracking for druids")
		else
			-- For non-druids, just set to use the mount button
			smartButton = CreateFrame("Button", "RMBSmartButton", UIParent, "SecureActionButtonTemplate")
			smartButton:SetSize(1, 1)
			smartButton:SetPoint("CENTER")
			smartButton:RegisterForClicks("AnyUp", "AnyDown")
			smartButton:SetAttribute("type", "macro")
			smartButton:SetAttribute("macrotext", "/script RandomMountBuddy:SummonRandomMount(true)")
			print("RMB_SECURE: Set up mount-only button for non-druids")
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
				print("RMB_DEBUG: Clicked visible button")
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
		-- Add a test slash command for the smart button
		SLASH_SMARTBUTTON1 = "/smartbutton"
		SlashCmdList["SMARTBUTTON"] = function()
			print("RMB_DEBUG: Testing smart button...")
			if _G["RMBSmartButton"] then
				local isMoving = IsPlayerMoving()
				print("RMB_DEBUG: Smart button found, clicking. isMoving:", isMoving)
				_G["RMBSmartButton"]:Click()
			else
				print("RMB_DEBUG: Smart button not found in global scope")
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
