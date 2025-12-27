-- MountBrowserSort.lua
-- Sort functionality for Mount Browser
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- SORT MANAGER
-- ============================================================================
local MountBrowserSort = {}
MountBrowser.Sort = MountBrowserSort
-- ============================================================================
-- SORT MODE DEFINITIONS
-- ============================================================================
MountBrowserSort.sortModes = {
	{ key = "name_asc", label = "Az", tooltip = "Sort by Name (A-Z)" },
	{ key = "name_desc", label = "Za", tooltip = "Sort by Name (Z-A)" },
	{ key = "weight_asc", label = "06", tooltip = "Sort by Weight (0-6)" },
	{ key = "weight_desc", label = "60", tooltip = "Sort by Weight (6-0)" },
}
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountBrowserSort:Initialize()
	addon:DebugUI("Initializing sort system...")
	-- Get saved sort mode or default to name ascending
	self.currentSortMode = addon:GetSetting("browserSortMode") or "name_asc"
	-- UI state
	self.sortMenuFrame = nil
	addon:DebugUI("Sort system initialized with mode: " .. self.currentSortMode)
end

-- ============================================================================
-- SORT BUTTON CREATION
-- ============================================================================
function MountBrowserSort:CreateSortButton(parent)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(24, 24)
	-- Set initial text based on current mode
	self:UpdateButtonText(button)
	button:SetNormalFontObject("GameFontNormalSmall")
	-- Click handler - toggle dropdown menu
	button:SetScript("OnClick", function(self)
		MountBrowserSort:ToggleSortMenu(self)
	end)
	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText("Sort Order")
		-- Show current mode
		local currentMode = MountBrowserSort:GetCurrentModeInfo()
		if currentMode then
			GameTooltip:AddLine(currentMode.tooltip, 0, 1, 0) -- Green
		end

		GameTooltip:AddLine(" ", 1, 1, 1)
		GameTooltip:AddLine("Click to open sort menu", 1, 1, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	self.sortButton = button
	return button
end

-- ============================================================================
-- SORT MENU (DROPDOWN)
-- ============================================================================
function MountBrowserSort:CreateSortMenu(parent)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetSize(150, #self.sortModes * 24 + 8)
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(parent:GetFrameLevel() + 10)
	-- Backdrop - solid gray background (matching filter style)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(0.2, 0.2, 0.2, 0.95) -- Dark gray
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	-- Create sort mode buttons
	frame.modeButtons = {}
	for i, mode in ipairs(self.sortModes) do
		local btn = CreateFrame("Button", nil, frame)
		btn:SetSize(142, 20)
		btn:SetPoint("TOP", frame, "TOP", 0, -4 - ((i - 1) * 24))
		-- Background
		btn.bg = btn:CreateTexture(nil, "BACKGROUND")
		btn.bg:SetAllPoints()
		btn.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
		-- Text
		btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		btn.text:SetPoint("LEFT", btn, "LEFT", 8, 0)
		btn.text:SetText(mode.tooltip)
		btn.text:SetJustifyH("LEFT")
		-- Hover effect
		btn:SetScript("OnEnter", function(self)
			self.bg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
		end)
		btn:SetScript("OnLeave", function(self)
			self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
		end)
		-- Click handler
		btn:SetScript("OnClick", function(self)
			MountBrowserSort:SetSortMode(mode.key)
			MountBrowserSort:HideSortMenu()
		end)
		frame.modeButtons[i] = btn
	end

	frame:Hide()
	self.sortMenuFrame = frame
	return frame
end

function MountBrowserSort:ToggleSortMenu(anchor)
	if not self.sortMenuFrame then
		self:CreateSortMenu(anchor:GetParent())
	end

	if self.sortMenuFrame:IsShown() then
		self:HideSortMenu()
	else
		self:ShowSortMenu(anchor)
	end
end

function MountBrowserSort:ShowSortMenu(anchor)
	if not self.sortMenuFrame then
		self:CreateSortMenu(anchor:GetParent())
	end

	-- Position menu below button
	self.sortMenuFrame:ClearAllPoints()
	self.sortMenuFrame:SetPoint("TOP", anchor, "BOTTOM", 0, -2)
	self.sortMenuFrame:Show()
	-- Highlight current selection
	for i, mode in ipairs(self.sortModes) do
		local btn = self.sortMenuFrame.modeButtons[i]
		if mode.key == self.currentSortMode then
			btn.text:SetTextColor(0, 1, 0) -- Green for selected
		else
			btn.text:SetTextColor(1, 1, 1) -- White for unselected
		end
	end
end

function MountBrowserSort:HideSortMenu()
	if self.sortMenuFrame then
		self.sortMenuFrame:Hide()
	end
end

function MountBrowserSort:OnHide()
	-- Called when browser is hidden
	self:HideSortMenu()
end

-- ============================================================================
-- SORT MODE MANAGEMENT
-- ============================================================================
function MountBrowserSort:GetCurrentModeInfo()
	for _, mode in ipairs(self.sortModes) do
		if mode.key == self.currentSortMode then
			return mode
		end
	end

	return self.sortModes[1] -- Fallback to first mode
end

function MountBrowserSort:SetSortMode(modeKey)
	if self.currentSortMode == modeKey then
		return -- Already using this mode
	end

	self.currentSortMode = modeKey
	-- Save to settings
	addon:SetSetting("browserSortMode", self.currentSortMode)
	-- Update button text
	if self.sortButton then
		self:UpdateButtonText(self.sortButton)
	end

	addon:DebugUI("Sort mode changed to: " .. self.currentSortMode)
	-- Trigger re-sort of current view
	if MountBrowser.mainFrame and MountBrowser.mainFrame:IsShown() then
		MountBrowser:RefreshCurrentView()
	end
end

function MountBrowserSort:UpdateButtonText(button)
	local currentMode = self:GetCurrentModeInfo()
	if currentMode then
		button:SetText(currentMode.label)
	end
end

function MountBrowserSort:GetCurrentSortMode()
	return self.currentSortMode
end

-- ============================================================================
-- SORT COMPARISON FUNCTIONS
-- ============================================================================
function MountBrowserSort:SortItems(items)
	local sortMode = self.currentSortMode
	addon:DebugUI("Sorting " .. #items .. " items with mode: " .. sortMode)
	if sortMode == "name_asc" then
		-- Sort A-Z
		table.sort(items, function(a, b)
			return (a.displayName or a.key) < (b.displayName or b.key)
		end)
	elseif sortMode == "name_desc" then
		-- Sort Z-A
		table.sort(items, function(a, b)
			return (a.displayName or a.key) > (b.displayName or b.key)
		end)
	elseif sortMode == "weight_asc" then
		-- Sort by weight 0-6 (then by name for ties)
		table.sort(items, function(a, b)
			local weightA = addon:GetGroupWeight(a.key) or 3
			local weightB = addon:GetGroupWeight(b.key) or 3
			if weightA == weightB then
				-- Same weight, sort by name
				return (a.displayName or a.key) < (b.displayName or b.key)
			end

			return weightA < weightB
		end)
	elseif sortMode == "weight_desc" then
		-- Sort by weight 6-0 (then by name for ties)
		table.sort(items, function(a, b)
			local weightA = addon:GetGroupWeight(a.key) or 3
			local weightB = addon:GetGroupWeight(b.key) or 3
			if weightA == weightB then
				-- Same weight, sort by name
				return (a.displayName or a.key) < (b.displayName or b.key)
			end

			return weightA > weightB
		end)
	end

	return items
end

-- ============================================================================
