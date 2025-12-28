-- MountBrowserSettings.lua
-- Settings tab for Mount Browser
local addonName, addon = ...
-- Module for Settings tab functionality
local Settings = {}
addon.MountBrowserSettings = Settings
-- Create the Settings tab frame and all its UI elements
function Settings:CreateSettingsFrame(parentFrame, mountBrowser)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetPoint("TOPLEFT", parentFrame.scrollFrame, "TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", parentFrame.scrollFrame, "BOTTOMRIGHT", 0, 0)
	frame:Hide() -- Hidden by default, browse tab is default
	-- Create a scrollable content frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 10, -10)
	scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild:SetWidth(scrollFrame:GetWidth())
	scrollChild:SetHeight(2000) -- Will be adjusted as we add content
	-- Layout configuration
	local yOffset = -10
	local xOffset = 40                             -- Starting X position
	local rowStartX = 40                           -- Where rows begin
	local maxRowWidth = scrollChild:GetWidth() - 40 -- Calculated from scroll frame width (minus margins)
	local checkboxHeight = 35
	local sectionSpacing = 15
	local lastCheckboxWidth = 0
	-- Helper function to start a new row
	local function NewRow()
		xOffset = rowStartX
		yOffset = yOffset - checkboxHeight
	end

	-- Helper function to create section headers
	local function CreateHeader(text)
		-- Always start headers on new row
		xOffset = rowStartX
		yOffset = yOffset - 5 -- Small spacing before header
		local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		header:SetPoint("TOPLEFT", 20, yOffset)
		header:SetText(text)
		header:SetTextColor(1, 0.82, 0) -- Gold color
		yOffset = yOffset - 30
		xOffset = rowStartX
		return header
	end

	-- Helper function to create checkboxes with horizontal support
	-- width: approximate width in pixels (checkbox + text)
	local function CreateCheckbox(name, label, settingKey, tooltip, refreshOnChange, width, customCallback)
		width = width or 200 -- Default width if not specified
		-- Check if we need to wrap to next row
		if xOffset > rowStartX and (xOffset + width) > maxRowWidth then
			NewRow()
		end

		local cb = CreateFrame("CheckButton", nil, scrollChild, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", xOffset, yOffset)
		cb.Text:SetText(label)
		cb.Text:SetFontObject("GameFontHighlight")
		-- Set initial state
		cb:SetChecked(addon:GetSetting(settingKey))
		-- On click handler
		cb:SetScript("OnClick", function(self)
			local isChecked = self:GetChecked()
			addon:SetSetting(settingKey, isChecked)
			-- Refresh mount pools if needed
			if refreshOnChange and addon.RefreshMountPools then
				C_Timer.After(0.1, function()
					addon:RefreshMountPools()
				end)
			end

			-- Call custom callback if provided
			if customCallback then
				customCallback(isChecked)
			end
		end)
		-- Tooltip
		if tooltip then
			mountBrowser:SetupSimpleTooltip(cb, {
				text = label,
				desc = tooltip,
				anchor = "ANCHOR_TOP",
			})
		end

		-- Update xOffset for next checkbox
		xOffset = xOffset + width
		lastCheckboxWidth = width
		return cb
	end

	CreateHeader("General")
	CreateCheckbox(
		"minimapButton",
		"Show Minimap Button",
		"showMinimapButton",
		"Toggle minimap icon.",
		false,
		nil, -- Use default width
		function(isChecked)
			-- Update minimap button visibility
			if addon.MinimapButton and addon.MinimapButton.UpdateMinimapButtonVisibility then
				addon.MinimapButton:UpdateMinimapButtonVisibility()
			end
		end
	)
	CreateCheckbox(
		"debug",
		"Debug Messages",
		"enableDebugMode",
		"Detailed debug information in chat. Useful for troubleshooting.",
		false
	)
	NewRow()
	yOffset = yOffset - sectionSpacing
	-- ========== BROWSER DISPLAY SETTINGS ==========
	CreateHeader("Browser (first tab) Config")
	frame.collectionStatusCB = CreateCheckbox(
		"collectionStatus",
		"Collection Status",
		"browserShowCollectionStatus",
		"Display collection status (Collected/Uncollected or completion counts) on cards.",
		false,
		nil, -- Use default width
		function(isChecked)
			-- Mark that visual refresh is needed
			if mountBrowser then
				mountBrowser.needsVisualRefresh = true
			end
		end
	)
	frame.groupIndicatorsCB = CreateCheckbox(
		"groupIndicators",
		"Group Icons",
		"browserShowGroupIndicators",
		"Display grouping icons on cards (|TInterface\\AddOns\\RandomMountBuddy\\media\\mount.tga:16:16:0:0|t|TInterface\\AddOns\\RandomMountBuddy\\media\\family.tga:16:16:0:0|t|TInterface\\AddOns\\RandomMountBuddy\\media\\group.tga:16:16:0:0|t).",
		false,
		nil, -- Use default width
		function(isChecked)
			-- Mark that visual refresh is needed
			if mountBrowser then
				mountBrowser.needsVisualRefresh = true
			end
		end
	)
	frame.uniquenessCB = CreateCheckbox(
		"uniqueness",
		"Uniqueness Icons",
		"browserShowUniquenessIndicators",
		"Display uniqueness badges for mounts with distinct traits.",
		false,
		nil, -- Use default width
		function(isChecked)
			-- Mark that visual refresh is needed
			if mountBrowser then
				mountBrowser.needsVisualRefresh = true
			end
		end
	)
	frame.capabilitiesCB = CreateCheckbox(
		"capabilities",
		"Mount Type Icons",
		"browserShowCapabilityIndicators",
		"Display icons for mount types (ground, flying, swimming).",
		false,
		230,
		function(isChecked)
			-- Mark that visual refresh is needed
			if mountBrowser then
				mountBrowser.needsVisualRefresh = true
			end
		end
	)
	CreateCheckbox(
		"showUncollected",
		"Uncollected Mounts",
		"showUncollectedMounts",
		"uncollected mounts in the interface. When disabled, also hides single-mount families with only uncollected mounts.",
		true
	)
	CreateCheckbox(
		"showUncollectedGroups",
		"Uncollected Groups",
		"showAllUncollectedGroups",
		"families and supergroups that contain only uncollected mounts.",
		true
	)
	NewRow()
	yOffset = yOffset - sectionSpacing
	-- ========== SUMMON SETTINGS ==========
	CreateHeader("Summoning settings")
	CreateCheckbox(
		"contextual",
		"Contextual Summoning",
		"contextualSummoning",
		"Automatically filter mounts based on location/situation.",
		true
	)
	CreateCheckbox(
		"deterministic",
		"Improved Randomness",
		"useDeterministicSummoning",
		"Recently used mount groups become temporarily unavailable for better variety.",
		true
	)
	CreateCheckbox(
		"uniqueEffect",
		"Favor Unique Mounts",
		"treatUniqueEffectsAsDistinct",
		"Mounts labelled as Unique get their own independent chance to be summoned instead of sharing chances with similar mounts.\n|cff1eff00You can toggle which mounts are unique via the gem icon in Mount Browser (expand groups to see it).|r",
		true
	)
	frame.groupFamiliesCB = CreateCheckbox(
		"groupFamilies",
		"Unique Mounts in Groups",
		"browserGroupFamiliesTogether",
		"Displays mounts in their assigned groups regardless whether you enabled the Improved Unique Mount Chances setting.\n|cff00ff00Recommended to keep Enabled|r",
		false, -- Don't refresh immediately (will refresh on tab switch)
		200,
		function(isChecked)
			-- Set flag to refresh when returning to browse tab
			if mountBrowser then
				mountBrowser.needsGridRefresh = true
			end
		end
	)
	NewRow()
	yOffset = yOffset - sectionSpacing
	-- ========== FAVORITE SYNC SETTINGS ==========
	CreateHeader("Weight Sync Settings")
	-- Description
	local syncDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	syncDesc:SetPoint("TOPLEFT", 40, yOffset)
	syncDesc:SetPoint("TOPRIGHT", -40, yOffset)
	syncDesc:SetJustifyH("LEFT")
	syncDesc:SetText("Automatically adjust mount weights based on favorites in your Mount Journal.")
	syncDesc:SetWordWrap(true)
	syncDesc:SetHeight(30)
	yOffset = yOffset - 35
	-- Enable Favorite Sync checkbox
	CreateCheckbox(
		"enableSync",
		"Enable Weight Sync",
		"favoriteSync_enableFavoriteSync",
		"Automatically sync mount weights based on your favorite mounts in the Mount Journal.",
		true,
		200
	)
	CreateCheckbox(
		"syncOnLogin",
		"Sync on Login",
		"favoriteSync_syncOnLogin",
		"Automatically sync mount weights when you log in.",
		false,
		200
	)
	CreateCheckbox(
		"syncFamilyWeights",
		"Sync Family Weights",
		"favoriteSync_syncFamilyWeights",
		"Apply favorite Mount weights to entire mount families when they contain favorite mounts.\nFamilies contain all recolors of a mount.\n|cff00ff00Recommended to keep Enabled|r",
		false,
		200
	)
	CreateCheckbox(
		"syncSuperGroupWeights",
		"Sync Group Weights",
		"favoriteSync_syncSuperGroupWeights",
		"Apply favorite Mount weights to entire supergroups when they contain favorite mounts.\nGroups contain all recolors and variants of a mount.\n|cff00ff00Recommended to keep Enabled|r",
		false,
		200
	)
	NewRow()
	yOffset = yOffset - 10
	-- Helper function to create weight dropdowns
	local function CreateWeightDropdown(label, settingKey, tooltip, startYOffset)
		-- Create label
		local dropdownLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		dropdownLabel:SetPoint("TOPLEFT", xOffset, startYOffset)
		dropdownLabel:SetText(label)
		-- Create dropdown
		local dropdown = CreateFrame("Frame", nil, scrollChild, "UIDropDownMenuTemplate")
		dropdown:SetPoint("TOPLEFT", xOffset - 15, startYOffset - 20)
		UIDropDownMenu_SetWidth(dropdown, 150)
		-- Weight display mapping
		local weightLabels = {
			[0] = "Never",
			[1] = "Occasional",
			[2] = "Uncommon",
			[3] = "Normal",
			[4] = "Common",
			[5] = "Often",
			[6] = "Always",
		}
		-- Initialize dropdown
		UIDropDownMenu_Initialize(dropdown, function(self, level)
			for weight = 0, 6 do
				local weightInfo = UIDropDownMenu_CreateInfo()
				weightInfo.text = weight .. " - " .. weightLabels[weight]
				weightInfo.value = weight
				weightInfo.func = function()
					addon:SetSetting(settingKey, weight)
					UIDropDownMenu_SetSelectedValue(dropdown, weight)
					if addon.RefreshMountPools then
						C_Timer.After(0.1, function()
							addon:RefreshMountPools()
						end)
					end
				end
				weightInfo.checked = (addon:GetSetting(settingKey) == weight)
				UIDropDownMenu_AddButton(weightInfo)
			end
		end)
		-- Set initial value
		local currentWeight = addon:GetSetting(settingKey)
		UIDropDownMenu_SetSelectedValue(dropdown, currentWeight)
		UIDropDownMenu_SetText(dropdown, currentWeight .. " - " .. weightLabels[currentWeight])
		-- Tooltip
		if tooltip then
			mountBrowser:SetupSimpleTooltip(dropdown, {
				text = label,
				desc = tooltip,
				anchor = "ANCHOR_TOP",
			})
		end

		xOffset = xOffset + 200
		return dropdown
	end
	-- Save starting Y position for this row
	local rowStartY = yOffset
	-- Weight Mode dropdown (first position)
	local modeLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	modeLabel:SetPoint("TOPLEFT", xOffset, rowStartY)
	modeLabel:SetText("Weight Mode:")
	local modeDropdown = CreateFrame("Frame", nil, scrollChild, "UIDropDownMenuTemplate")
	modeDropdown:SetPoint("TOPLEFT", xOffset - 15, rowStartY - 20)
	UIDropDownMenu_SetWidth(modeDropdown, 150)
	-- Initialize dropdown
	UIDropDownMenu_Initialize(modeDropdown, function(self, level)
		-- "Set" option
		local setInfo = UIDropDownMenu_CreateInfo()
		setInfo.text = "Replace weights"
		setInfo.value = "set"
		setInfo.func = function()
			addon:SetSetting("favoriteSync_favoriteWeightMode", "set")
			UIDropDownMenu_SetSelectedValue(modeDropdown, "set")
			if addon.RefreshMountPools then
				C_Timer.After(0.1, function()
					addon:RefreshMountPools()
				end)
			end
		end
		setInfo.checked = (addon:GetSetting("favoriteSync_favoriteWeightMode") == "set")
		UIDropDownMenu_AddButton(setInfo)
		-- "Minimum" option
		local minInfo = UIDropDownMenu_CreateInfo()
		minInfo.text = "Only increase weights"
		minInfo.value = "minimum"
		minInfo.func = function()
			addon:SetSetting("favoriteSync_favoriteWeightMode", "minimum")
			UIDropDownMenu_SetSelectedValue(modeDropdown, "minimum")
			if addon.RefreshMountPools then
				C_Timer.After(0.1, function()
					addon:RefreshMountPools()
				end)
			end
		end
		minInfo.checked = (addon:GetSetting("favoriteSync_favoriteWeightMode") == "minimum")
		UIDropDownMenu_AddButton(minInfo)
	end)
	-- Set initial value
	UIDropDownMenu_SetSelectedValue(modeDropdown, addon:GetSetting("favoriteSync_favoriteWeightMode"))
	UIDropDownMenu_SetText(modeDropdown,
		addon:GetSetting("favoriteSync_favoriteWeightMode") == "set" and "Replace weights" or "Only increase weights")
	-- Tooltip for dropdown
	mountBrowser:SetupSimpleTooltip(modeDropdown, {
		text = "Sync Mode",
		desc =
		"Replace weights: Syncing will update all weights.|cff00ff00Use this if you don't care about modifying weights manually|r.\nOnly increase weights: Syncing will only change weights that are below the selected values.|cff00ff00Use this if you want to set specific mounts/families/groups to a higher weight|r.",
		anchor = "ANCHOR_TOP",
	})
	xOffset = xOffset + 200
	-- Favorite and Non-Favorite Weight dropdowns
	CreateWeightDropdown(
		"Non-Favorite Mounts Weight",
		"favoriteSync_nonFavoriteWeight",
		"Weight applied to mounts not marked as favorites. \nRecommended:0-2",
		rowStartY
	)
	CreateWeightDropdown(
		"Favorite Mounts Weight",
		"favoriteSync_favoriteWeight",
		"Weight applied to mounts marked as favorites.\nRecommended:3-5",
		rowStartY
	)
	-- Manual sync button (on same row)
	local syncButton = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
	syncButton:SetPoint("TOPLEFT", xOffset + 5, rowStartY - 22)
	syncButton:SetSize(160, 22)
	syncButton:SetText("Sync Now")
	syncButton:SetScript("OnClick", function()
		if addon.FavoriteSync and addon.FavoriteSync.ManualSync then
			addon.FavoriteSync:ManualSync()
			addon:AlwaysPrint("Favorite mount sync completed.")
		end
	end)
	mountBrowser:SetupSimpleTooltip(syncButton, {
		text = "Sync Now",
		desc = "Manually trigger favorite mount weight synchronization.",
		anchor = "ANCHOR_TOP",
	})
	-- Move to next row after all elements
	NewRow()
	yOffset = yOffset - 45
	-- ========== CLASS SETTINGS ==========
	CreateHeader("Class Settings")
	-- Druid
	local druidHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	druidHeader:SetPoint("TOPLEFT", xOffset, yOffset)
	druidHeader:SetText("Druid")
	druidHeader:SetTextColor(1, 0.49, 0.04) -- Druid orange
	yOffset = yOffset - 25
	CreateCheckbox(
		"travelFormMoving",
		"Travel Form while moving",
		"useTravelFormWhileMoving",
		"When using the Random Mount Buddy keybind, cast Travel form while moving.",
		false,
		200
	)
	CreateCheckbox(
		"keepTravelForm",
		"Don't Cancel Travel Form",
		"keepTravelFormActive",
		"Pressing the Random Mount Buddy keybind while in Travel Form won't cancel it.",
		false,
		200
	)
	CreateCheckbox(
		"smartFormSwitch",
		"Fallback to Cat Form",
		"useSmartFormSwitching",
		"When using the Random Mount Buddy keybind, if Travel Form cannot be casted, it will cast Cat Form instead.",
		false,
		200
	)
	-- Monk (same row as Druid)
	yOffset = yOffset + 25 -- Move back up to header level
	local monkHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	monkHeader:SetPoint("TOPLEFT", xOffset, yOffset)
	monkHeader:SetText("Monk")
	monkHeader:SetTextColor(0, 1, 0.59) -- Monk green
	yOffset = yOffset - 25
	CreateCheckbox(
		"zenFlightMoving",
		"Zen Flight while Moving",
		"useZenFlightWhileMoving",
		"When using the Random Mount Buddy keybind, cast Zen Flight while moving or falling. Will NOT cast in combat while falling.",
		false,
		200
	)
	CreateCheckbox(
		"keepZenFlight",
		"Don't Cancel Zen Flight",
		"keepZenFlightActive",
		"Pressing the Random Mount Buddy keybind while using Zen Flight won't cancel it",
		false,
		200
	)
	-- Start new row for Monk
	NewRow()
	yOffset = yOffset - 10
	-- Shaman
	local shamanHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	shamanHeader:SetPoint("TOPLEFT", xOffset, yOffset) -- Small spacing before header
	shamanHeader:SetText("Shaman")
	shamanHeader:SetTextColor(0, 0.44, 0.87)          -- Shaman blue
	yOffset = yOffset - 25
	CreateCheckbox(
		"ghostWolfMoving",
		"Ghost Wolf while moving",
		"useGhostWolfWhileMoving",
		"When using the Random Mount Buddy keybind, cast Ghost Wolf while moving and/or while in combat.",
		false,
		200
	)
	CreateCheckbox(
		"keepGhostWolf",
		"Don't Cancel Ghost Wolf",
		"keepGhostWolfActive",
		"Pressing the Random Mount Buddy keybind while in Ghost Wolf won't cancel it",
		false,
		400
	)
	-- Mage (same row as Sham)
	yOffset = yOffset + 25                          -- Move back up to header level
	local mageHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	mageHeader:SetPoint("TOPLEFT", xOffset, yOffset) -- Small spacing before header
	mageHeader:SetText("Mage")
	mageHeader:SetTextColor(0.25, 0.78, 0.92)       -- Mage cyan
	yOffset = yOffset - 25
	CreateCheckbox(
		"slowFallFalling",
		"Slow Fall while Falling",
		"useSlowFallWhileFalling",
		"When using the Random Mount Buddy keybind, cast Slow Fall while falling.",
		false,
		200
	)
	CreateCheckbox(
		"slowFallOthers",
		"Cast on Others",
		"useSlowFallOnOthers",
		"Try to cast on your target or mouseover first, before falling back to yourself",
		false,
		200
	)
	NewRow()
	-- Priest (next row)
	local priestHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	priestHeader:SetPoint("TOPLEFT", xOffset, yOffset) -- Small spacing before header
	priestHeader:SetText("Priest")
	priestHeader:SetTextColor(1, 1, 1)                -- Priest white
	yOffset = yOffset - 25
	CreateCheckbox(
		"levitateFalling",
		"Levitate while Falling",
		"useLevitateWhileFalling",
		"When using the Random Mount Buddy keybind, cast Levitate while falling.",
		false,
		200
	)
	CreateCheckbox(
		"levitateOthers",
		"Cast on Others",
		"useLevitateOnOthers",
		"Try to cast on your target or mouseover first, before falling back to yourself",
		false,
		200
	)
	-- Add some bottom padding
	NewRow()
	yOffset = yOffset - 30
	-- Update scroll child height
	scrollChild:SetHeight(math.abs(yOffset))
	parentFrame.settingsFrame = frame
end
