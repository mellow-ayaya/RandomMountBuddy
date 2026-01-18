-- MountBrowserFilters.lua
-- Nested flyout filter system for Mount Browser
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- FILTER MANAGER
-- ============================================================================
local MountBrowserFilters = {}
MountBrowser.Filters = MountBrowserFilters
-- ============================================================================
-- FILTER DEFINITIONS
-- ============================================================================
-- Define all available filters organized by category
MountBrowserFilters.filterDefinitions = {
	capabilities = {
		displayName = "Capabilities",
		options = {
			{ key = "groundOnly", label = "Ground Only" },
			{ key = "flying", label = "Flying" },
			{ key = "swimming", label = "Swimming" },
		},
	},
	sources = {
		displayName = "Sources",
		options = {
			{ key = 1, label = "Drop" },
			{ key = 2, label = "Quest" },
			{ key = 3, label = "Vendor" },
			{ key = 4, label = "World Quest" },
			{ key = 5, label = "Achievement" },
			{ key = 6, label = "Profession" },
			{ key = 7, label = "World Event" },
			{ key = 8, label = "Promotion" },
			{ key = 9, label = "Trading Card Game" },
			{ key = 10, label = "Black Market" },
		},
	},
	traits = {
		displayName = "Traits",
		options = {
			{ key = "isUniqueEffect", label = "Unique" },
			{ key = "noTraits", label = "No Traits" },
		},
	},
	weights = {
		displayName = "Weight Balance",
		options = {
			{ key = "Never", label = "Never" },
			{ key = "Occasional", label = "Occasional" },
			{ key = "Uncommon", label = "Uncommon" },
			{ key = "Normal", label = "Normal" },
			{ key = "Common", label = "Common" },
			{ key = "Often", label = "Often" },
			{ key = "Always", label = "Always" },
		},
	},
}
-- Category order for display
MountBrowserFilters.categoryOrder = { "capabilities", "sources", "traits", "weights" }
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountBrowserFilters:Initialize()
	addon:DebugUI("Initializing flyout filter system...")
	-- Initialize filter state
	self.filterState = {}
	for _, categoryKey in ipairs(self.categoryOrder) do
		self.filterState[categoryKey] = {}
		local category = self.filterDefinitions[categoryKey]
		for _, option in ipairs(category.options) do
			self.filterState[categoryKey][option.key] = option.default or false
		end
	end

	-- UI state
	self.categoryMenuFrame = nil
	self.optionsMenuFrame = nil
	self.currentCategory = nil
	self.closeTimer = nil
	addon:DebugUI("Flyout filter system initialized")
end

-- ============================================================================
-- FILTER BUTTON CREATION
-- ============================================================================
function MountBrowserFilters:CreateFilterButton(parent)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(24, 24)
	button:SetText("|TInterface\\AddOns\\RandomMountBuddy\\media\\filter.tga:16:16:0:-2|t") -- Filters main button
	button:SetNormalFontObject("GameFontNormal")
	-- Active filter count badge
	button.badge = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLargeOutline")
	button.badge:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 4)
	button.badge:SetTextColor(0, 1, 0, 1) -- Green
	button.badge:Hide()
	-- Click handler
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "RightButton" then
			-- Right-click: Reset all filters
			MountBrowserFilters:ResetAllFilters()
		else
			-- Left-click: Toggle menu
			MountBrowserFilters:ToggleCategoryMenu(self)
		end
	end)
	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Filter")
		GameTooltip:AddLine("Click to open filter menu", 1, 1, 1)
		-- Show right-click hint only when filters are active
		if MountBrowserFilters:GetTotalActiveFilterCount() > 0 then
			GameTooltip:AddLine("Right click to reset filters", 0, 1, 0) -- Green
		end

		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	self.mainButton = button
	return button
end

-- ============================================================================
-- CATEGORY MENU (FIRST LEVEL)
-- ============================================================================
function MountBrowserFilters:CreateCategoryMenu(parent)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetSize(150, #self.categoryOrder * 24 + 8) -- Base size, will expand when needed
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(parent:GetFrameLevel() + 10)
	-- Backdrop - solid gray background
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid color base
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Dark gray with slight transparency
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	-- Create category buttons
	frame.categoryButtons = {}
	for i, categoryKey in ipairs(self.categoryOrder) do
		local category = self.filterDefinitions[categoryKey]
		local btn = self:CreateCategoryButton(frame, categoryKey, category.displayName, i)
		frame.categoryButtons[categoryKey] = btn
	end

	-- Create reset filters button (invisible text-only style)
	frame.resetButton = CreateFrame("Button", nil, frame)
	frame.resetButton:SetSize(142, 22)
	frame.resetButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 4)
	-- Create separator line above reset button
	frame.resetSeparator = frame:CreateTexture(nil, "ARTWORK")
	frame.resetSeparator:SetColorTexture(0.4, 0.4, 0.4, 1)
	frame.resetSeparator:SetHeight(1)
	frame.resetSeparator:SetPoint("BOTTOMLEFT", frame.resetButton, "TOPLEFT", 4, 2)
	frame.resetSeparator:SetPoint("BOTTOMRIGHT", frame.resetButton, "TOPRIGHT", -4, 2)
	-- Create text label
	frame.resetButton.label = frame.resetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.resetButton.label:SetAllPoints()
	frame.resetButton.label:SetText("Reset Filters")
	frame.resetButton.label:SetJustifyH("CENTER")
	frame.resetButton.label:SetTextColor(0, 1, 0, 1) -- Green
	-- Hover effect
	frame.resetButton:SetScript("OnEnter", function(self)
		self.label:SetTextColor(0.5, 1, 0.5, 1) -- Brighter green on hover
		MountBrowserFilters:CancelCloseTimer()
	end)
	frame.resetButton:SetScript("OnLeave", function(self)
		self.label:SetTextColor(0, 1, 0, 1) -- Normal green
		MountBrowserFilters:StartCloseTimer()
	end)
	-- Click handler
	frame.resetButton:SetScript("OnClick", function()
		MountBrowserFilters:ResetAllFilters()
	end)
	-- Hide by default (shown when filters are active)
	frame.resetButton:Hide()
	frame.resetSeparator:Hide()
	-- Mouse tracking
	frame:SetScript("OnEnter", function() self:CancelCloseTimer() end)
	frame:SetScript("OnLeave", function() self:StartCloseTimer() end)
	frame:Hide()
	self.categoryMenuFrame = frame
	return frame
end

function MountBrowserFilters:CreateCategoryButton(parent, categoryKey, label, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(142, 22)
	button:SetPoint("TOP", parent, "TOP", 0, -4 - (index - 1) * 24)
	-- Background
	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetAllPoints()
	button.bg:SetColorTexture(0.2, 0.2, 0.2, 0)
	-- Label
	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.text:SetPoint("LEFT", button, "LEFT", 8, 0)
	button.text:SetText(label)
	button.text:SetJustifyH("LEFT")
	-- Arrow
	button.arrow = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.arrow:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	button.arrow:SetText(">")
	-- Active count indicator
	button.count = button:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
	button.count:SetPoint("RIGHT", button.arrow, "LEFT", -4, 0)
	button.count:SetTextColor(0, 1, 0, 1)
	button.count:Hide()
	-- Hover highlight
	button:SetScript("OnEnter", function(self)
		self.bg:SetColorTexture(0.3, 0.3, 0.3, 1)
		MountBrowserFilters:ShowOptionsMenu(categoryKey, self)
		MountBrowserFilters:CancelCloseTimer()
	end)
	button:SetScript("OnLeave", function(self)
		self.bg:SetColorTexture(0.2, 0.2, 0.2, 0)
		MountBrowserFilters:StartCloseTimer()
	end)
	button.categoryKey = categoryKey
	return button
end

-- ============================================================================
-- OPTIONS MENU (SECOND LEVEL)
-- ============================================================================
function MountBrowserFilters:CreateOptionsMenu(parent)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(parent:GetFrameLevel() + 1)
	-- Backdrop - solid gray background
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8", -- Solid color base
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Dark gray with slight transparency
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	-- Mouse tracking
	frame:SetScript("OnEnter", function() self:CancelCloseTimer() end)
	frame:SetScript("OnLeave", function() self:StartCloseTimer() end)
	frame:Hide()
	self.optionsMenuFrame = frame
	return frame
end

function MountBrowserFilters:ShowOptionsMenu(categoryKey, anchorButton)
	if not self.optionsMenuFrame then
		self:CreateOptionsMenu(self.categoryMenuFrame)
	end

	local frame = self.optionsMenuFrame
	local category = self.filterDefinitions[categoryKey]
	-- Clear existing checkboxes
	if frame.checkboxes then
		for _, checkbox in ipairs(frame.checkboxes) do
			checkbox:Hide()
			checkbox:SetParent(nil)
		end
	end

	frame.checkboxes = {}
	-- Clear existing utility buttons
	if frame.allButton then frame.allButton:Hide() end

	if frame.noneButton then frame.noneButton:Hide() end

	if frame.separator then frame.separator:Hide() end

	-- Calculate frame size (add space for All/None buttons + separator)
	local numOptions = #category.options
	local frameHeight = numOptions * 24 + 8 + 30 -- +30 for buttons and separator
	frame:SetSize(180, frameHeight)
	-- Position to the right of anchor button
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", anchorButton, "TOPRIGHT", 4, 0)
	-- Create All/None buttons (invisible text-only style)
	if not frame.allButton then
		frame.allButton = CreateFrame("Button", nil, frame)
		frame.allButton:SetSize(82, 20)
		-- Create text label
		frame.allButton.label = frame.allButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.allButton.label:SetAllPoints()
		frame.allButton.label:SetText("All")
		frame.allButton.label:SetJustifyH("CENTER")
		-- Add subtle hover effect
		frame.allButton:SetScript("OnEnter", function(self)
			self.label:SetTextColor(1, 1, 0.6, 1) -- Slight yellow tint on hover
			MountBrowserFilters:CancelCloseTimer()
		end)
		frame.allButton:SetScript("OnLeave", function(self)
			self.label:SetTextColor(1, 0.82, 0, 1) -- Reset to normal color
			MountBrowserFilters:StartCloseTimer()
		end)
	end

	frame.allButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -4)
	frame.allButton:SetScript("OnClick", function()
		MountBrowserFilters:SelectAllInCategory(categoryKey)
	end)
	frame.allButton:Show()
	if not frame.noneButton then
		frame.noneButton = CreateFrame("Button", nil, frame)
		frame.noneButton:SetSize(82, 20)
		-- Create text label
		frame.noneButton.label = frame.noneButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.noneButton.label:SetAllPoints()
		frame.noneButton.label:SetText("None")
		frame.noneButton.label:SetJustifyH("CENTER")
		-- Add subtle hover effect
		frame.noneButton:SetScript("OnEnter", function(self)
			self.label:SetTextColor(1, 1, 0.6, 1) -- Slight yellow tint on hover
			MountBrowserFilters:CancelCloseTimer()
		end)
		frame.noneButton:SetScript("OnLeave", function(self)
			self.label:SetTextColor(1, 0.82, 0, 1) -- Reset to normal color
			MountBrowserFilters:StartCloseTimer()
		end)
	end

	frame.noneButton:SetPoint("LEFT", frame.allButton, "RIGHT", 4, 0)
	frame.noneButton:SetScript("OnClick", function()
		MountBrowserFilters:ClearAllInCategory(categoryKey)
	end)
	frame.noneButton:Show()
	-- Create separator line
	if not frame.separator then
		frame.separator = frame:CreateTexture(nil, "ARTWORK")
		frame.separator:SetColorTexture(0.4, 0.4, 0.4, 1)
		frame.separator:SetHeight(1)
	end

	frame.separator:SetPoint("TOPLEFT", frame.allButton, "BOTTOMLEFT", -2, -4)
	frame.separator:SetPoint("TOPRIGHT", frame.noneButton, "BOTTOMRIGHT", 2, -4)
	frame.separator:Show()
	-- Create checkboxes for this category (offset by button height)
	local yOffset = 30 -- Space for All/None buttons + separator
	for i, option in ipairs(category.options) do
		local checkbox = self:CreateFilterCheckbox(frame, categoryKey, option, i, yOffset)
		table.insert(frame.checkboxes, checkbox)
	end

	self.currentCategory = categoryKey
	frame:Show()
end

function MountBrowserFilters:CreateFilterCheckbox(parent, categoryKey, option, index, yOffset)
	yOffset = yOffset or 0
	local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	checkbox:SetSize(20, 20)
	checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -4 - yOffset - (index - 1) * 24)
	-- Label
	checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
	checkbox.text:SetText(option.label)
	-- Set initial state
	checkbox:SetChecked(self.filterState[categoryKey][option.key])
	-- Click handler
	checkbox:SetScript("OnClick", function(self)
		local isChecked = self:GetChecked()
		MountBrowserFilters:SetFilter(categoryKey, option.key, isChecked)
	end)
	-- Mouse tracking for auto-close (no visual hover)
	checkbox:SetScript("OnEnter", function(self)
		MountBrowserFilters:CancelCloseTimer()
	end)
	checkbox:SetScript("OnLeave", function(self)
		MountBrowserFilters:StartCloseTimer()
	end)
	checkbox.categoryKey = categoryKey
	checkbox.optionKey = option.key
	return checkbox
end

-- ============================================================================
-- MENU MANAGEMENT
-- ============================================================================
function MountBrowserFilters:ToggleCategoryMenu(anchorButton)
	if not self.categoryMenuFrame then
		self:CreateCategoryMenu(anchorButton)
	end

	local frame = self.categoryMenuFrame
	if frame:IsShown() then
		self:CloseMenus()
	else
		-- Position below the button
		frame:ClearAllPoints()
		frame:SetPoint("TOP", anchorButton, "BOTTOM", 0, -4)
		-- Show/hide reset button based on active filters
		if self:GetTotalActiveFilterCount() > 0 then
			frame.resetButton:Show()
			frame.resetSeparator:Show()
		else
			frame.resetButton:Hide()
			frame.resetSeparator:Hide()
		end

		frame:Show()
		-- Update category button counts
		self:UpdateCategoryBadges()
	end
end

function MountBrowserFilters:CloseMenus()
	if self.categoryMenuFrame then
		self.categoryMenuFrame:Hide()
	end

	if self.optionsMenuFrame then
		self.optionsMenuFrame:Hide()
	end

	self:CancelCloseTimer()
end

-- ============================================================================
-- MOUSE TRACKING & AUTO-CLOSE
-- ============================================================================
function MountBrowserFilters:StartCloseTimer()
	self:CancelCloseTimer()
	self.closeTimer = C_Timer.NewTimer(0.2, function()
		-- Check if mouse is over any menu component
		if not self:IsMouseOverMenus() then
			self:CloseMenus()
		end
	end)
end

function MountBrowserFilters:CancelCloseTimer()
	if self.closeTimer then
		self.closeTimer:Cancel()
		self.closeTimer = nil
	end
end

function MountBrowserFilters:IsMouseOverMenus()
	-- Check main button
	if self.mainButton and self.mainButton:IsMouseOver() then
		return true
	end

	-- Check category menu
	if self.categoryMenuFrame and self.categoryMenuFrame:IsShown() and self.categoryMenuFrame:IsMouseOver() then
		return true
	end

	-- Check options menu
	if self.optionsMenuFrame and self.optionsMenuFrame:IsShown() and self.optionsMenuFrame:IsMouseOver() then
		return true
	end

	return false
end

-- ============================================================================
-- FILTER STATE MANAGEMENT
-- ============================================================================
function MountBrowserFilters:SetFilter(categoryKey, optionKey, value)
	self.filterState[categoryKey][optionKey] = value
	-- Update UI
	self:UpdateCategoryBadges()
	self:UpdateMainButtonBadge()
	self:UpdateResetButtonVisibility()
	-- Apply filters
	MountBrowser:RefreshCurrentView()
	addon:DebugUI(string.format("Filter set: %s.%s = %s", categoryKey, optionKey, tostring(value)))
end

function MountBrowserFilters:GetFilter(categoryKey, optionKey)
	return self.filterState[categoryKey] and self.filterState[categoryKey][optionKey] or false
end

function MountBrowserFilters:SelectAllInCategory(categoryKey)
	local category = self.filterDefinitions[categoryKey]
	if not category then return end

	-- Set all options in this category to true
	for _, option in ipairs(category.options) do
		self.filterState[categoryKey][option.key] = true
	end

	-- Update all checkboxes in the current menu
	if self.optionsMenuFrame and self.optionsMenuFrame.checkboxes then
		for _, checkbox in ipairs(self.optionsMenuFrame.checkboxes) do
			if checkbox.categoryKey == categoryKey then
				checkbox:SetChecked(true)
			end
		end
	end

	-- Update UI and apply filters
	self:UpdateCategoryBadges()
	self:UpdateMainButtonBadge()
	self:UpdateResetButtonVisibility()
	MountBrowser:RefreshCurrentView()
	addon:DebugUI("Selected all filters in category: " .. categoryKey)
end

function MountBrowserFilters:ClearAllInCategory(categoryKey)
	local category = self.filterDefinitions[categoryKey]
	if not category then return end

	-- Set all options in this category to false
	for _, option in ipairs(category.options) do
		self.filterState[categoryKey][option.key] = false
	end

	-- Update all checkboxes in the current menu
	if self.optionsMenuFrame and self.optionsMenuFrame.checkboxes then
		for _, checkbox in ipairs(self.optionsMenuFrame.checkboxes) do
			if checkbox.categoryKey == categoryKey then
				checkbox:SetChecked(false)
			end
		end
	end

	-- Update UI and apply filters
	self:UpdateCategoryBadges()
	self:UpdateMainButtonBadge()
	self:UpdateResetButtonVisibility()
	MountBrowser:RefreshCurrentView()
	addon:DebugUI("Cleared all filters in category: " .. categoryKey)
end

function MountBrowserFilters:ResetAllFilters()
	-- Clear all filters in all categories
	for _, categoryKey in ipairs(self.categoryOrder) do
		local category = self.filterDefinitions[categoryKey]
		for _, option in ipairs(category.options) do
			-- Set to default value if specified, otherwise false
			self.filterState[categoryKey][option.key] = option.default or false
		end
	end

	-- Update all checkboxes if menu is open
	if self.optionsMenuFrame and self.optionsMenuFrame.checkboxes then
		for _, checkbox in ipairs(self.optionsMenuFrame.checkboxes) do
			local defaultValue = false
			local category = self.filterDefinitions[checkbox.categoryKey]
			for _, option in ipairs(category.options) do
				if option.key == checkbox.optionKey then
					defaultValue = option.default or false
					break
				end
			end

			checkbox:SetChecked(defaultValue)
		end
	end

	-- Update UI and apply filters
	self:UpdateCategoryBadges()
	self:UpdateMainButtonBadge()
	self:UpdateResetButtonVisibility() -- Update reset button visibility before closing
	-- Close menus after updating
	self:CloseMenus()
	MountBrowser:RefreshCurrentView()
	addon:DebugUI("Reset all filters to defaults")
end

function MountBrowserFilters:GetActiveFilterCount(categoryKey)
	if not self.filterState[categoryKey] then return 0 end

	local count = 0
	for _, value in pairs(self.filterState[categoryKey]) do
		if value then
			count = count + 1
		end
	end

	return count
end

function MountBrowserFilters:GetTotalActiveFilterCount()
	local total = 0
	for _, categoryKey in ipairs(self.categoryOrder) do
		total = total + self:GetActiveFilterCount(categoryKey)
	end

	return total
end

-- ============================================================================
-- UI UPDATES
-- ============================================================================
function MountBrowserFilters:UpdateMainButtonBadge()
	if not self.mainButton then return end

	local count = self:GetTotalActiveFilterCount()
	if count > 0 then
		self.mainButton.badge:SetText(tostring(count))
		self.mainButton.badge:Show()
	else
		self.mainButton.badge:Hide()
	end
end

function MountBrowserFilters:UpdateCategoryBadges()
	if not self.categoryMenuFrame or not self.categoryMenuFrame.categoryButtons then return end

	for categoryKey, button in pairs(self.categoryMenuFrame.categoryButtons) do
		local count = self:GetActiveFilterCount(categoryKey)
		if count > 0 then
			button.count:SetText(string.format("(%d)", count))
			button.count:Show()
		else
			button.count:Hide()
		end
	end
end

function MountBrowserFilters:UpdateResetButtonVisibility()
	if not self.categoryMenuFrame or not self.categoryMenuFrame.resetButton then return end

	local hasActiveFilters = self:GetTotalActiveFilterCount() > 0
	local baseHeight = #self.categoryOrder * 24 + 8
	if hasActiveFilters then
		self.categoryMenuFrame.resetButton:Show()
		self.categoryMenuFrame.resetSeparator:Show()
		self.categoryMenuFrame:SetHeight(baseHeight + 30) -- Add space for reset button
	else
		self.categoryMenuFrame.resetButton:Hide()
		self.categoryMenuFrame.resetSeparator:Hide()
		self.categoryMenuFrame:SetHeight(baseHeight) -- Shrink to base size
	end
end

-- ============================================================================
-- FILTERING LOGIC
-- ============================================================================
function MountBrowserFilters:ShouldShowMount(mountInfo)
	-- Check capability filters
	if self:GetActiveFilterCount("capabilities") > 0 then
		local matchesCapability = false
		-- Get mount capabilities from type traits
		local mountID = mountInfo.mountID
		if not mountID then
			addon:DebugUI("RMB_FILTER: mountInfo has no mountID for capability check")
			return false
		end

		local typeTraits = addon.MountSummon and addon.MountSummon:GetMountTypeTraits(mountID)
		if not typeTraits then
			addon:DebugUI("RMB_FILTER: Mount " .. mountID .. " has no type traits")
			return false
		end

		-- Derive capability flags
		local isGround = typeTraits.isGround or false
		local isFlying = (typeTraits.isSteadyFly or typeTraits.isSkyriding) or false
		local isSwimming = typeTraits.isAquatic or false
		-- Check filters
		if self.filterState.capabilities.groundOnly then
			-- Special case: mount must be ground-only (no flying/swimming)
			if isGround and not isFlying and not isSwimming then
				matchesCapability = true
			end
		end

		if self.filterState.capabilities.flying and isFlying then
			matchesCapability = true
		end

		if self.filterState.capabilities.swimming and isSwimming then
			matchesCapability = true
		end

		if not matchesCapability then
			addon:DebugUI("RMB_FILTER: Mount " ..
				mountID ..
				" filtered out by capability (ground=" ..
				tostring(isGround) .. ", flying=" .. tostring(isFlying) .. ", swimming=" .. tostring(isSwimming) .. ")")
			return false
		end
	end

	-- Check source filters
	if self:GetActiveFilterCount("sources") > 0 then
		local mountID = mountInfo.mountID
		if mountID then
			local _, _, _, _, _, sourceType = C_MountJournal.GetMountInfoByID(mountID)
			local matchesSource = false
			-- Debug logging
			if not sourceType then
				addon:DebugUI("RMB_FILTER: Mount " .. mountID .. " has no sourceType from API")
			end

			-- Check if mount's source matches any enabled source filter
			if sourceType and self.filterState.sources[sourceType] then
				matchesSource = true
			end

			if not matchesSource then
				addon:DebugUI("RMB_FILTER: Mount " ..
					mountID .. " filtered out by source (sourceType=" .. tostring(sourceType) .. ")")
				return false
			end
		else
			-- No mount ID, can't determine source, filter out
			addon:DebugUI("RMB_FILTER: mountInfo has no mountID field")
			return false
		end
	end

	-- Check trait filters
	if self:GetActiveFilterCount("traits") > 0 then
		local matchesTrait = false
		local traits = mountInfo.traits or {}
		-- Check specific traits
		if traits.isUniqueEffect and self.filterState.traits.isUniqueEffect then
			matchesTrait = true
		end

		-- Check "no traits" - mount has no traits and "noTraits" filter is enabled
		if not matchesTrait and self.filterState.traits.noTraits then
			local hasAnyTrait = traits.isUniqueEffect
			if not hasAnyTrait then
				matchesTrait = true
			end
		end

		if not matchesTrait then
			return false
		end
	end

	-- Check weight filters
	if self:GetActiveFilterCount("weights") > 0 then
		local mountID = mountInfo.mountID
		if not mountID then
			addon:DebugUI("RMB_FILTER: mountInfo has no mountID for weight check")
			return false
		end

		-- Get mount's weight
		local groupKey = "mount_" .. mountID
		local mountWeight = addon:GetGroupWeight(groupKey)
		-- If mount has no specific weight, use family weight
		if mountWeight == 0 and mountInfo.familyName then
			mountWeight = addon:GetGroupWeight(mountInfo.familyName)
		end

		-- Map weight to chance name
		local weightToChanceMap = {
			[0] = "Never",
			[1] = "Occasional",
			[2] = "Uncommon",
			[3] = "Normal",
			[4] = "Common",
			[5] = "Often",
			[6] = "Always",
		}
		local chanceName = weightToChanceMap[mountWeight] or "Normal"
		-- Debug logging
		addon:DebugUI("RMB_FILTER: Mount " .. mountID .. " weight=" .. mountWeight .. " (" .. chanceName .. ")")
		-- Check if this mount's chance matches any enabled weight filter
		if not self.filterState.weights[chanceName] then
			addon:DebugUI("RMB_FILTER: Mount " .. mountID .. " filtered out by weight (" .. chanceName .. " not selected)")
			return false
		end
	end

	return true
end

-- ============================================================================
-- CLEANUP
-- ============================================================================
function MountBrowserFilters:OnHide()
	self:CloseMenus()
end
