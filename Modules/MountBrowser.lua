-- MountBrowser.lua
-- Visual grid-based browser for mount families to aid in categorization
local addonName, addon = ...
-- Create the browser object
local MountBrowser = {}
addon.MountBrowser = MountBrowser
-- Constants
local GRID_WIDTH = 1240
local GRID_HEIGHT = 800
local CARD_WIDTH = 220
local CARD_HEIGHT = 260
local CARD_SPACING = 10
local CARDS_PER_ROW = 5
local PREVIEW_HEIGHT = 200
-- Weight display configuration (matches MountUIComponents)
local WeightDisplayMapping = {

	[0] = { text = "Never", color = "ff3e00" },     -- Red

	[1] = { text = "Occasional", color = "9d9d9d" }, -- Grey

	[2] = { text = "Uncommon", color = "cbcbcb" },  -- Light Grey

	[3] = { text = "Normal", color = "ffffff" },    -- White

	[4] = { text = "Common", color = "1eff00" },    -- Green

	[5] = { text = "Often", color = "0070dd" },     -- Blue

	[6] = { text = "Always", color = "ff8000" },    -- Orange

}
-- ============================================================================
-- MOUNT BROWSER UTILITIES
-- Consolidated UI patterns for tooltips, hover states, and scroll optimization
-- ============================================================================
-- ============================================================================
-- CONSTANTS
-- ============================================================================
-- Timing constants for various UI operations
MountBrowser.TIMING = {

	SCROLL_SETTLE_DELAY = 0.3,    -- Delay after scroll stops before re-enabling mouse

	BATCH_PROCESS_DELAY = 0.001,  -- Delay between batches when loading models

	NAVIGATION_UPDATE_DELAY = 0.1, -- Delay for navigation updates

}
-- Visual state constants
MountBrowser.VISUAL_STATES = {

	CARD_BORDER_DEFAULT = { r = 0.4, g = 0.4, b = 0.4, a = 1 },

	CARD_BORDER_HOVER = { r = 0.8, g = 0.8, b = 0.8, a = 1 },

	BUTTON_BG_DEFAULT = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },

	BUTTON_BG_HOVER = { r = 0.3, g = 0.3, b = 0.3, a = 0.8 },

	TRAIT_BG_DEFAULT = { r = 0, g = 0, b = 0, a = 0 },

	TRAIT_BG_HOVER = { r = 0.3, g = 0.3, b = 0.3, a = 0.5 },

}
-- ============================================================================
-- TOOLTIP UTILITIES
-- ============================================================================
--[[

	Sets up a simple tooltip that shows static text



	@param frame - The frame to attach tooltip to

	@param config - Configuration table:

		text: Main tooltip text (required)

		desc: Optional description line

		anchor: Tooltip anchor point (default: "ANCHOR_TOP")

		color: Optional color table {r, g, b} for text (default: white)

		wrap: Whether to wrap text (default: true)

]]
function MountBrowser:SetupSimpleTooltip(frame, config)
	if not frame or not config or not config.text then return end

	local anchor = config.anchor or "ANCHOR_TOP"
	local wrap = config.wrap ~= false -- Default true
	local r, g, b = 1, 1, 1
	if config.color then
		r, g, b = config.color.r, config.color.g, config.color.b
	end

	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, anchor)
		GameTooltip:SetText(config.text, r, g, b, 1, wrap)
		if config.desc then
			GameTooltip:AddLine(config.desc, nil, nil, nil, true)
		end

		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

--[[

	Sets up a dynamic tooltip that generates text via callback



	@param frame - The frame to attach tooltip to

	@param config - Configuration table:

		textFunc: Function that returns text (can return text, desc table)

		anchor: Tooltip anchor point (default: "ANCHOR_TOP")

		wrap: Whether to wrap text (default: true)

]]
function MountBrowser:SetupDynamicTooltip(frame, config)
	if not frame or not config or not config.textFunc then return end

	local anchor = config.anchor or "ANCHOR_TOP"
	local wrap = config.wrap ~= false
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, anchor)
		local text, desc = config.textFunc(self)
		if text then
			GameTooltip:SetText(text, 1, 1, 1, 1, wrap)
			if desc then
				if type(desc) == "table" then
					for _, line in ipairs(desc) do
						GameTooltip:AddLine(line, nil, nil, nil, true)
					end
				else
					GameTooltip:AddLine(desc, nil, nil, nil, true)
				end
			end

			GameTooltip:Show()
		end
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

-- ============================================================================
-- HOVER STATE UTILITIES
-- ============================================================================
--[[

	Sets up hover highlighting for backdrop borders



	@param frame - Frame with backdrop

	@param config - Configuration table (optional):

		defaultColor: {r, g, b, a} for default state

		hoverColor: {r, g, b, a} for hover state

]]
function MountBrowser:SetupBackdropHover(frame, config)
	if not frame or not frame.SetBackdropBorderColor then return end

	config = config or {}
	local defaultColor = config.defaultColor or MountBrowser.VISUAL_STATES.CARD_BORDER_DEFAULT
	local hoverColor = config.hoverColor or MountBrowser.VISUAL_STATES.CARD_BORDER_HOVER
	local existingOnEnter = frame:GetScript("OnEnter")
	local existingOnLeave = frame:GetScript("OnLeave")
	frame:SetScript("OnEnter", function(self)
		self:SetBackdropBorderColor(hoverColor.r, hoverColor.g, hoverColor.b, hoverColor.a)
		if existingOnEnter then existingOnEnter(self) end
	end)
	frame:SetScript("OnLeave", function(self)
		self:SetBackdropBorderColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
		if existingOnLeave then existingOnLeave(self) end
	end)
end

--[[

	Sets up hover highlighting for texture-based backgrounds



	@param frame - Frame containing a .bg texture

	@param config - Configuration table (optional):

		defaultColor: {r, g, b, a} for default state

		hoverColor: {r, g, b, a} for hover state

]]
function MountBrowser:SetupTextureHover(frame, config)
	if not frame or not frame.bg then return end

	config = config or {}
	local defaultColor = config.defaultColor or MountBrowser.VISUAL_STATES.BUTTON_BG_DEFAULT
	local hoverColor = config.hoverColor or MountBrowser.VISUAL_STATES.BUTTON_BG_HOVER
	local existingOnEnter = frame:GetScript("OnEnter")
	local existingOnLeave = frame:GetScript("OnLeave")
	frame:SetScript("OnEnter", function(self)
		self.bg:SetColorTexture(hoverColor.r, hoverColor.g, hoverColor.b, hoverColor.a)
		if existingOnEnter then existingOnEnter(self) end
	end)
	frame:SetScript("OnLeave", function(self)
		self.bg:SetColorTexture(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
		if existingOnLeave then existingOnLeave(self) end
	end)
end

-- ============================================================================
-- COMBINED SETUP UTILITIES
-- ============================================================================
--[[

	Sets up a complete interactive element with tooltip and hover state

	Handles both backdrop and texture-based backgrounds automatically



	@param frame - The frame to configure

	@param config - Configuration table:

		-- Tooltip configuration

		tooltip: Static tooltip text OR

		tooltipFunc: Function returning dynamic tooltip text

		tooltipDesc: Optional static description

		tooltipAnchor: Anchor point (default: "ANCHOR_TOP")



		-- Visual configuration

		hoverType: "backdrop" or "texture" (auto-detected if not specified)

		defaultColor: {r, g, b, a} for default state

		hoverColor: {r, g, b, a} for hover state



		-- Scroll optimization

		disableMouseOnCreate: Start with mouse disabled (default: false)

]]
function MountBrowser:SetupInteractiveElement(frame, config)
	if not frame or not config then return end

	-- Determine hover type
	local hoverType = config.hoverType
	if not hoverType then
		if frame.SetBackdropBorderColor then
			hoverType = "backdrop"
		elseif frame.bg then
			hoverType = "texture"
		end
	end

	-- Set up hover state first
	if hoverType == "backdrop" then
		self:SetupBackdropHover(frame, {

			defaultColor = config.defaultColor,

			hoverColor = config.hoverColor,

		})
	elseif hoverType == "texture" then
		self:SetupTextureHover(frame, {

			defaultColor = config.defaultColor,

			hoverColor = config.hoverColor,

		})
	end

	-- Set up tooltip
	if config.tooltip then
		self:SetupSimpleTooltip(frame, {

			text = config.tooltip,

			desc = config.tooltipDesc,

			anchor = config.tooltipAnchor or "ANCHOR_TOP",

		})
	elseif config.tooltipFunc then
		self:SetupDynamicTooltip(frame, {

			textFunc = config.tooltipFunc,

			anchor = config.tooltipAnchor or "ANCHOR_TOP",

		})
	end

	-- Scroll optimization
	if config.disableMouseOnCreate then
		frame:EnableMouse(false)
	end
end

-- ============================================================================
-- SCROLL OPTIMIZATION UTILITIES
-- ============================================================================
--[[

	Disables mouse interaction on a frame or table of frames

	Used during scrolling to prevent tooltip spam and performance issues



	@param elements - Single frame or table of frames

]]
function MountBrowser:DisableMouseOnElements(elements)
	if not elements then return end

	if type(elements) == "table" and not elements.EnableMouse then
		-- It's a table of frames
		for _, frame in pairs(elements) do
			if frame and frame.EnableMouse then
				frame:EnableMouse(false)
			end
		end
	elseif elements.EnableMouse then
		-- It's a single frame
		elements:EnableMouse(false)
	end
end

--[[

	Re-enables mouse interaction on a frame or table of frames

	Used after scrolling settles



	@param elements - Single frame or table of frames

]]
function MountBrowser:EnableMouseOnElements(elements)
	if not elements then return end

	if type(elements) == "table" and not elements.EnableMouse then
		-- It's a table of frames
		for _, frame in pairs(elements) do
			if frame and frame.EnableMouse then
				frame:EnableMouse(true)
			end
		end
	elseif elements.EnableMouse then
		-- It's a single frame
		elements:EnableMouse(true)
	end
end

--[[

	Helper to disable mouse on all interactive elements of a card

	Handles capability icons, type icon, and trait buttons



	@param card - The card frame containing interactive elements

]]
function MountBrowser:DisableCardMouseInteractions(card)
	if not card then return end

	-- Disable capability icon frames
	if card.capabilityIconFrames then
		self:DisableMouseOnElements(card.capabilityIconFrames)
	end

	-- Disable type icon frame
	if card.typeIconFrame then
		card.typeIconFrame:EnableMouse(false)
	end

	-- Disable trait buttons
	if card.traitButtons then
		self:DisableMouseOnElements(card.traitButtons)
	end
end

--[[

	Helper to re-enable mouse on all interactive elements of a card

	Only enables when not actively scrolling



	@param card - The card frame containing interactive elements

]]
function MountBrowser:EnableCardMouseInteractions(card)
	if not card or self.isActivelyScrolling then return end

	-- Enable capability icon frames
	if card.capabilityIconFrames then
		self:EnableMouseOnElements(card.capabilityIconFrames)
	end

	-- Enable type icon frame
	if card.typeIconFrame then
		card.typeIconFrame:EnableMouse(true)
	end

	-- Enable trait buttons
	if card.traitButtons then
		self:EnableMouseOnElements(card.traitButtons)
	end
end

-- ============================================================================
-- COLOR UTILITIES
-- ============================================================================
--[[

	Creates a color table from RGBA values

	Convenience function for readability

]]
function MountBrowser:CreateColor(r, g, b, a)
	return { r = r, g = g, b = b, a = a or 1 }
end

--[[

	Applies a color to a backdrop border

]]
function MountBrowser:SetBackdropBorderColor(frame, color)
	if frame and frame.SetBackdropBorderColor and color then
		frame:SetBackdropBorderColor(color.r, color.g, color.b, color.a or 1)
	end
end

--[[

	Applies a color to a texture

]]
function MountBrowser:SetTextureColor(texture, color)
	if texture and texture.SetColorTexture and color then
		texture:SetColorTexture(color.r, color.g, color.b, color.a or 1)
	end
end

-- ============================================================================
-- MOUNT BROWSER MAIN CODE
-- ============================================================================
-- Initialize the browser
-- Create settings content frame
-- Switch between Browse and Settings tabs
function MountBrowser:SwitchTab(tabName)
	if not self.mainFrame then return end

	local frame = self.mainFrame
	frame.currentTab = tabName
	if tabName == "browser" then
		-- Show browse content, hide settings
		frame.scrollFrame:Show()
		if frame.settingsFrame then
			frame.settingsFrame:Hide()
		end

		if frame.rulesFrame then
			frame.rulesFrame:Hide()
		end

		-- Show filter buttons
		if frame.filterButton then frame.filterButton:Show() end

		-- Show sort button
		if frame.sortButton then frame.sortButton:Show() end

		-- Show search UI
		if frame.searchBox then frame.searchBox:Show() end

		if frame.searchLabel then frame.searchLabel:Show() end

		if frame.clearSearchButton then
			if self.Search and self.Search.active then
				frame.clearSearchButton:Show()
			else
				frame.clearSearchButton:Hide()
			end
		end

		-- Update tab selection using PanelTemplates
		PanelTemplates_SetTab(frame, 1)
		-- Show back button only if we're in a nested view
		if #self.navigationStack > 0 then
			frame.backButton:Show()
		else
			frame.backButton:Hide()
		end

		-- Restart visibility checking for model loading
		self:StartVisibilityCheck()
		-- Check if grid structure refresh is needed (from settings changes like grouping toggle)
		if self.needsGridRefresh then
			self.needsGridRefresh = false -- Clear flag
			addon:DebugUI("Grid refresh needed from settings change, reloading view")
			-- Delay by 1 frame to prevent graphics engine overload
			C_Timer.After(0.05, function()
				if frame.scrollFrame:IsShown() then
					-- Reload grid structure based on current view
					if #self.navigationStack == 0 then
						-- At main grid
						self:LoadMainGrid()
					else
						-- In a nested view - refresh it
						self:RefreshCurrentView()
					end
				end
			end)
		elseif self.needsVisualRefresh then
			-- Visual settings changed (icons, etc.) - refresh card display
			self.needsVisualRefresh = false -- Clear flag
			addon:DebugUI("Visual refresh needed from settings change, refreshing cards")
			-- Delay slightly to prevent overlap with visibility check
			C_Timer.After(0.05, function()
				if frame.scrollFrame:IsShown() then
					self:RefreshAllCards()
				end
			end)
		end

		-- Note: For normal tab switches with no settings changes,
		-- StartVisibilityCheck() above handles card updates
	elseif tabName == "settings" then
		-- Show settings, hide browse content
		frame.scrollFrame:Hide()
		if frame.settingsFrame then
			frame.settingsFrame:Show()
		end

		if frame.rulesFrame then
			frame.rulesFrame:Hide()
		end

		-- Stop visibility checking (saves CPU cycles)
		self:StopVisibilityCheck()
		-- Clear any ongoing model loading to prevent background processing
		-- and potential crashes when switching back to Browse
		self:ClearLoadQueue()
		-- Hide filter buttons (don't apply to settings)
		if frame.filterButton then frame.filterButton:Hide() end

		-- Hide sort button
		if frame.sortButton then frame.sortButton:Hide() end

		-- Hide search UI
		if frame.searchBox then frame.searchBox:Hide() end

		if frame.searchLabel then frame.searchLabel:Hide() end

		if frame.clearSearchButton then frame.clearSearchButton:Hide() end

		-- Update tab selection using PanelTemplates
		PanelTemplates_SetTab(frame, 2)
		-- Hide back button in settings
		frame.backButton:Hide()
	elseif tabName == "rules" then
		-- Show rules, hide browse content and settings
		frame.scrollFrame:Hide()
		if frame.settingsFrame then
			frame.settingsFrame:Hide()
		end

		if frame.rulesFrame then
			frame.rulesFrame:Show()
		end

		-- Stop visibility checking (saves CPU cycles)
		self:StopVisibilityCheck()
		-- Clear any ongoing model loading
		self:ClearLoadQueue()
		-- Hide filter buttons (don't apply to rules)
		if frame.filterButton then frame.filterButton:Hide() end

		-- Hide sort button
		if frame.sortButton then frame.sortButton:Hide() end

		-- Hide search UI
		if frame.searchBox then frame.searchBox:Hide() end

		if frame.searchLabel then frame.searchLabel:Hide() end

		if frame.clearSearchButton then frame.clearSearchButton:Hide() end

		-- Update tab selection using PanelTemplates
		PanelTemplates_SetTab(frame, 3)
		-- Hide back button in rules
		frame.backButton:Hide()
	end
end

-- Refresh all visible cards (called when settings change)
function MountBrowser:RefreshAllCards()
	-- Ensure we're not in scrolling state so all updates apply
	local wasScrolling = self.isActivelyScrolling
	self.isActivelyScrolling = false
	-- Collect visible cards that need refreshing
	local cardsToUpdate = {}
	for _, card in ipairs(self.cardPool) do
		if card:IsVisible() and card.data then
			-- Force update by clearing current data key
			card.currentDataKey = nil
			table.insert(cardsToUpdate, card)
		end
	end

	addon:DebugUI("RefreshAllCards: Batching " .. #cardsToUpdate .. " cards for update.")
	-- Use batched updates to prevent frame drops
	if #cardsToUpdate > 0 then
		self:BatchUpdateCards(cardsToUpdate)
	end

	-- Restore scrolling state (should stay false anyway)
	self.isActivelyScrolling = wasScrolling
end

function MountBrowser:Initialize()
	if self.initialized then return end

	-- Create the main frame
	self:CreateMainFrame()
	-- Create card pool (40 cards for max supergroups + standalone families)
	self.cardPool = {}
	for i = 1, 300 do
		local card = self:CreateCard(self.mainFrame.scrollChild)
		table.insert(self.cardPool, card)
		card:Hide()
	end

	-- Navigation stack for back button
	self.navigationStack = {}
	-- Scroll position memory for main grid
	self.savedMainScrollPosition = nil
	-- Progressive loading system
	self.loadQueue = {}
	self.loadDelay = 0.05      -- 50ms between each model load (prevent graphics engine overload)
	self.maxConcurrentLoads = 3 -- Limit simultaneous loads
	self.currentLoads = 0
	-- Scroll throttling
	self.lastScrollTime = 0
	self.scrollThrottle = 0.2 -- 200ms between visibility checks during rapid scrolling
	self.isLoading = false
	self.isActivelyScrolling = false
	self.scrollStopCounter = 0
	self.buttonsHiddenForScroll = false
	-- View cache system (prevents flicker when going back to main menu)
	self.viewCache = {

		main = nil,  -- Cache for main menu

		current = nil, -- Track current view level

	}
	-- Initialize browser search system
	if self.Search then
		self.Search:Initialize()
	end

	-- Representative mount cache (prevents re-randomization on every scroll)
	-- Cache key format: "supergroup:GroupName" or "family:FamilyName" or "mount:123"
	self.representativeMountCache = {}
	-- Movement capability filters
	self.capabilityFilters = {

		groundOnly = false, -- Special filter: ground ONLY (no flying/swimming)

		ground = false,

		flying = false, -- Merged flying + skyriding

		swimming = false,

	}
	-- Combat state tracking
	self.queuedShow = false
	-- Register combat events
	self.mainFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.mainFrame:SetScript("OnEvent", function(_, event)
		self:OnEvent(event)
	end)
	self.initialized = true
	addon:DebugUI("Mount Browser initialized")
end

-- Create the main frame
function MountBrowser:CreateMainFrame()
	local frame = CreateFrame("Frame", "RMB_FamilyBrowser", UIParent, "BackdropTemplate")
	frame:SetSize(GRID_WIDTH, GRID_HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	-- Background
	-- Main border (9-slice atlas that auto-tiles)
	frame.Border = frame:CreateTexture(nil, "BORDER")
	frame.Border:SetAllPoints()
	frame.Border:SetAtlas("ui-frame-thewarwithin-border", true)
	-- Top embellishment
	frame.TopEmbellishment = frame:CreateTexture(nil, "OVERLAY")
	frame.TopEmbellishment:SetSize(550, 40) -- Adjust size as needed
	frame.TopEmbellishment:SetPoint("TOP", 0, -15)
	frame.TopEmbellishment:SetAtlas("ui-frame-thewarwithin-embellishmentbottom")
	frame.TopEmbellishment:SetTexCoord(0, 1, 1, 0) -- Flip for top
	-- Layer 1: Tiled background
	frame.bgTile = frame:CreateTexture(nil, "BACKGROUND", nil, -2)
	frame.bgTile:SetPoint("TOPLEFT", 8, -8)
	frame.bgTile:SetPoint("BOTTOMRIGHT", -8, 8)
	frame.bgTile:SetAtlas("collections-background-tile")
	frame.bgTile:SetHorizTile(true)
	frame.bgTile:SetVertTile(true)
	-- Layer 2: Shadow overlay
	frame.bgShadow = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
	frame.bgShadow:SetPoint("TOPLEFT", 8, -8)
	frame.bgShadow:SetPoint("BOTTOMRIGHT", -8, 8)
	frame.bgShadow:SetAtlas("collections-background-shadow-large")
	frame.bgShadow:SetTexCoord(1, 0, 1, 0)
	-- Or: frame.bgShadow:SetAtlas("collections-background-shadow-small")
	-- Layer 3: Corner decorations (4 corners)
	local cornerSize = 64 -- Adjust if needed
	-- Top-left
	frame.cornerTL = frame:CreateTexture(nil, "ARTWORK")
	frame.cornerTL:SetSize(cornerSize, cornerSize)
	frame.cornerTL:SetPoint("TOPLEFT", 8, -8)
	frame.cornerTL:SetAtlas("collections-background-corner")
	-- Top-right (flip horizontally)
	frame.cornerTR = frame:CreateTexture(nil, "ARTWORK")
	frame.cornerTR:SetSize(cornerSize, cornerSize)
	frame.cornerTR:SetPoint("TOPRIGHT", -8, -8)
	frame.cornerTR:SetAtlas("collections-background-corner")
	frame.cornerTR:SetTexCoord(1, 0, 0, 1) -- Flip horizontal
	-- Bottom-left (flip vertically)
	frame.cornerBL = frame:CreateTexture(nil, "ARTWORK")
	frame.cornerBL:SetSize(cornerSize, cornerSize)
	frame.cornerBL:SetPoint("BOTTOMLEFT", 8, 8)
	frame.cornerBL:SetAtlas("collections-background-corner")
	frame.cornerBL:SetTexCoord(0, 1, 1, 0) -- Flip vertical
	-- Bottom-right (flip both)
	frame.cornerBR = frame:CreateTexture(nil, "ARTWORK")
	frame.cornerBR:SetSize(cornerSize, cornerSize)
	frame.cornerBR:SetPoint("BOTTOMRIGHT", -8, 8)
	frame.cornerBR:SetAtlas("collections-background-corner")
	frame.cornerBR:SetTexCoord(1, 0, 1, 0) -- Flip both
	-- Title
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.title:SetPoint("TOP", 0, -16)
	frame.title:SetText("Random Mount Buddy")
	-- Tab system
	frame.currentTab = "browser" -- Default tab
	-- Browse tab button
	frame.browseTab = CreateFrame("Button", nil, frame, "PanelTopTabButtonTemplate")
	frame.browseTab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 50, -48)
	frame.browseTab:SetText("Browser")
	frame.browseTab:SetScript("OnClick", function()
		self:SwitchTab("browser")
	end)
	-- Settings tab button
	frame.settingsTab = CreateFrame("Button", nil, frame, "PanelTopTabButtonTemplate")
	frame.settingsTab:SetPoint("LEFT", frame.browseTab, "RIGHT", -15, 0)
	frame.settingsTab:SetText("Settings")
	frame.settingsTab:SetScript("OnClick", function()
		self:SwitchTab("settings")
	end)
	-- Rules tab button
	frame.rulesTab = CreateFrame("Button", nil, frame, "PanelTopTabButtonTemplate")
	frame.rulesTab:SetPoint("LEFT", frame.settingsTab, "RIGHT", -15, 0)
	frame.rulesTab:SetText("Rules")
	frame.rulesTab:SetScript("OnClick", function()
		self:SwitchTab("rules")
	end)
	-- Initialize tab system for PanelTemplates
	frame.numTabs = 3
	PanelTemplates_SetNumTabs(frame, 3)
	PanelTemplates_SetTab(frame, 1) -- Select browse tab by default
	-- Close button
	frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.closeButton:SetPoint("TOPRIGHT", -15, -15)
	-- Search box (only visible on Browser tab)
	frame.searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	frame.searchBox:SetSize(146, 20)
	frame.searchBox:SetPoint("RIGHT", frame.closeButton, "LEFT", -45, -10)
	frame.searchBox:SetAutoFocus(false)
	frame.searchBox:SetMaxLetters(50)
	frame.searchBox:SetFontObject("ChatFontNormal")
	-- Placeholder text setup
	frame.searchBox.placeholder = frame.searchBox:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
	frame.searchBox.placeholder:SetAllPoints(frame.searchBox)
	frame.searchBox.placeholder:SetJustifyH("LEFT")
	frame.searchBox.placeholder:SetTextColor(0.5, 0.5, 0.5, 1) -- Gray color
	frame.searchBox.placeholder:SetText("Search...")
	-- Search timer for auto-search delay
	frame.searchBox.searchTimer = nil
	-- Function to update placeholder visibility
	local function UpdatePlaceholder(box)
		local text = box:GetText()
		local hasFocus = box:HasFocus()
		-- Show placeholder only when: empty, not focused, and no active search
		if text == "" and not hasFocus and (not self.Search or not self.Search:IsActive()) then
			box.placeholder:Show()
		else
			box.placeholder:Hide()
		end
	end

	-- OnTextChanged - auto-search with delay
	frame.searchBox:SetScript("OnTextChanged", function(box, userInput)
		if not userInput then return end -- Ignore programmatic changes

		-- Cancel existing timer
		if box.searchTimer then
			box.searchTimer:Cancel()
		end

		-- Hide placeholder when typing
		UpdatePlaceholder(box)
		local searchTerm = box:GetText():trim()
		-- If empty, clear search immediately
		if searchTerm == "" then
			if self.Search then
				self.Search:Clear()
			end

			return
		end

		-- Start new timer for auto-search (0.4 second delay)
		box.searchTimer = C_Timer.NewTimer(0.4, function()
			if self.Search then
				self.Search:Execute(searchTerm)
			end
		end)
	end)
	-- OnEditFocusGained - hide placeholder
	frame.searchBox:SetScript("OnEditFocusGained", function(box)
		UpdatePlaceholder(box)
	end)
	-- OnEditFocusLost - show placeholder if needed
	frame.searchBox:SetScript("OnEditFocusLost", function(box)
		UpdatePlaceholder(box)
	end)
	-- OnEnterPressed - execute search immediately (bypass delay)
	frame.searchBox:SetScript("OnEnterPressed", function(box)
		-- Cancel pending timer
		if box.searchTimer then
			box.searchTimer:Cancel()
			box.searchTimer = nil
		end

		local searchTerm = box:GetText():trim()
		if self.Search then
			if searchTerm ~= "" then
				self.Search:Execute(searchTerm)
			else
				self.Search:Clear()
			end
		end

		box:ClearFocus()
	end)
	-- Store update function for external access
	frame.searchBox.UpdatePlaceholder = UpdatePlaceholder
	-- Initialize placeholder visibility
	UpdatePlaceholder(frame.searchBox)
	-- Clear search button (text-only, no background)
	frame.clearSearchButton = CreateFrame("Button", nil, frame)
	frame.clearSearchButton:SetSize(20, 20)
	frame.clearSearchButton:SetPoint("LEFT", frame.searchBox, "RIGHT", -25, 0)
	frame.clearSearchButton:SetFrameLevel(frame.searchBox:GetFrameLevel() + 1) -- Appear above search box
	-- Texture display
	frame.clearSearchButton.text = frame.clearSearchButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.clearSearchButton.text:SetAllPoints()
	frame.clearSearchButton.text:SetText("|TInterface\\BUTTONS\\UI-RefreshButton.blp:16:16:0:-2|t")
	-- Highlight overlay for hover effect
	frame.clearSearchButton.highlight = frame.clearSearchButton:CreateTexture(nil, "HIGHLIGHT")
	frame.clearSearchButton.highlight:SetAllPoints()
	frame.clearSearchButton.highlight:SetColorTexture(1, 1, 1, 0.3) -- White overlay at 30% opacity
	frame.clearSearchButton:Hide()                                 -- Initially hidden
	frame.clearSearchButton:SetScript("OnClick", function()
		if self.Search then
			self.Search:Clear()
			frame.searchBox:SetText("")
			frame.searchBox:ClearFocus()
			UpdatePlaceholder(frame.searchBox)
		end
	end)
	-- Tooltip for search box
	self:SetupSimpleTooltip(frame.searchBox, {
		text = "Type to search...",
		anchor = "ANCHOR_TOP",
	})
	-- Back button
	frame.backButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.backButton:SetSize(100, 20)
	frame.backButton:SetPoint("BOTTOM", 0, 27)
	frame.backButton:SetText("Back")
	frame.backButton:SetScript("OnClick", function()
		self:NavigateBack()
	end)
	-- Use utility to set up tooltip
	self:SetupSimpleTooltip(frame.backButton, {

		text = "You can also right click anywhere in the scroll area to go back!",

		anchor = "ANCHOR_BOTTOM",

	})
	frame.backButton:Hide()
	-- Sort button (initialize sort system first)
	if self.Sort and self.Sort.Initialize then
		self.Sort:Initialize()
	end

	frame.sortButton = self.Sort:CreateSortButton(frame)
	frame.sortButton:SetPoint("RIGHT", frame.searchBox, "LEFT", -7, 0)
	-- Flyout filter button
	if self.Filters and self.Filters.Initialize then
		self.Filters:Initialize()
	end

	frame.filterButton = self.Filters:CreateFilterButton(frame)
	frame.filterButton:SetPoint("RIGHT", frame.closeButton, "LEFT", -20, -10)
	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(GRID_WIDTH - 100, 0) -- Width only, height auto-calculated
	scrollFrame:SetPoint("TOP", frame, "TOP", 0, -50)
	scrollFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, 50)
	frame.scrollFrame = scrollFrame
	-- Scroll bar
	local scrollBar = scrollFrame.ScrollBar
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 5, -40)
	scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 5, 40)
	-- Scroll child
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(GRID_WIDTH - 60, GRID_HEIGHT - 80)
	scrollFrame:SetScrollChild(scrollChild)
	-- Enable mouse wheel scrolling with throttled visibility checks
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		-- Mark this as mouse wheel scroll to avoid triggering scrollbar logic
		MountBrowser.isMouseWheelScrolling = true
		local newScroll = self:GetVerticalScroll() - (delta * 100)
		newScroll = math.max(0, math.min(newScroll, self:GetVerticalScrollRange()))
		self:SetVerticalScroll(newScroll)
		-- NOTE: SetVerticalScroll triggers OnVerticalScroll, which will clear isMouseWheelScrolling
		-- Force scrollbar visual update (WoW's template might not auto-update)
		if self.ScrollBar then
			self.ScrollBar:SetValue(newScroll)
		end

		-- Throttle visibility checks during rapid scrolling
		local currentTime = GetTime()
		if currentTime - MountBrowser.lastScrollTime > MountBrowser.scrollThrottle then
			-- Clear queue on rapid scroll to prevent model overload
			MountBrowser:ClearLoadQueue()
			MountBrowser:CheckVisibleCards()
			MountBrowser.lastScrollTime = currentTime
		end
	end)
	-- Add scroll value change handler to detect scrollbar dragging
	-- This handler solves the scrolling freeze issue by hiding trait buttons during scroll
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		-- Track last scroll position to detect spurious events from model loading
		MountBrowser.lastScrollPosition = MountBrowser.lastScrollPosition or 0
		local scrollDelta = math.abs(offset - MountBrowser.lastScrollPosition)
		-- Ignore tiny scroll changes (<5px) - these are from model loading changing content height
		-- Model loading can cause scroll child height to change by ~0.001px, triggering spurious events
		if scrollDelta < 5 and not MountBrowser.isMouseWheelScrolling then
			return
		end

		MountBrowser.lastScrollPosition = offset
		-- Only apply scrollbar drag optimizations when NOT scrolling via mouse wheel
		-- This allows the template to update the scrollbar thumb for mouse wheel scrolling
		if not MountBrowser.isMouseWheelScrolling then
			-- Mark as actively scrolling (scrollbar drag only)
			MountBrowser.isActivelyScrolling = true
			-- Hide all trait buttons during scrolling
			-- WoW's button frames perform expensive operations (hit detection, event handling)
			-- even when not being updated. Hiding them eliminates this overhead.
			if not MountBrowser.buttonsHiddenForScroll then
				for _, card in ipairs(MountBrowser.cardPool) do
					for _, button in pairs(card.traitButtons) do
						-- Disable mouse instead of hiding to keep buttons visible
						button:EnableMouse(false)
					end
				end

				-- Disable mouse on capability icons (keeps icons visible)
				MountBrowser:DisableCapabilityIconMouseDuringScroll()
				-- Disable mouse on type icon (keeps icon visible)
				MountBrowser:DisableTypeIconMouseDuringScroll()
				MountBrowser.buttonsHiddenForScroll = true
			end

			-- NOTE: CheckVisibleCards is NOT called during drag to prevent FPS drops
			-- Models will load when scrolling stops instead
			-- This makes scrollbar dragging smooth at the cost of slightly delayed model loading
			-- Increment counter to invalidate old timers
			MountBrowser.scrollStopCounter = MountBrowser.scrollStopCounter + 1
			local currentCounter = MountBrowser.scrollStopCounter
			-- Set timer to detect when scrolling stops
			C_Timer.After(MountBrowser.TIMING.SCROLL_SETTLE_DELAY, function()
				if MountBrowser.scrollStopCounter == currentCounter then
					MountBrowser.isActivelyScrolling = false
					MountBrowser.buttonsHiddenForScroll = false
					-- CRITICAL FIX: Re-evaluate traits for cards that loaded during scrolling
					-- Clear trait flags but keep currentDataKey to use fast path (no model reload)
					local updatedCount = 0
					for _, card in ipairs(MountBrowser.cardPool) do
						if card:IsVisible() and card.data then
							-- Clear trait positioning to force re-evaluation
							card.traitButtonsPositioned = false
							card.lastTraitKey = nil
							-- Directly update card (will use fast path since currentDataKey matches)
							MountBrowser:UpdateCard(card, card.data)
							updatedCount = updatedCount + 1
						end
					end

					addon:DebugUI("SCROLL_SETTLE: Updated traits for " .. updatedCount .. " cards (fast path)")
					-- Still call CheckVisibleCards for mouse re-enabling and any cards that need full updates
					MountBrowser:CheckVisibleCards()
				end
			end)
		else
			-- Clear the flag immediately so next scroll event is clean
			-- This prevents race conditions from async timers
			MountBrowser.isMouseWheelScrolling = false
		end
	end)
	-- Right-click anywhere in scroll frame to go back
	scrollFrame:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			MountBrowser:NavigateBack()
		end
	end)
	frame.scrollChild = scrollChild
	-- Also enable right-click on scroll child for better coverage
	scrollChild:EnableMouse(true)
	scrollChild:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			MountBrowser:NavigateBack()
		end
	end)
	-- ScrollFrame textures
	frame.scrollBg = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	frame.scrollBg:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", -2, 0)
	frame.scrollBg:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 2, 0)
	frame.scrollBg:SetAtlas("CreditsScreen-Background-5")
	frame.scrollBg:SetHorizTile(true)
	frame.scrollBg:SetVertTile(true)
	frame.scrollBg:SetVertexColor(0.8, 0.6, 0.6, 1)
	-- ScrollFrame shadow
	frame.scrollBgShadow = frame:CreateTexture(nil, "ARTWORK", nil, 2)
	frame.scrollBgShadow:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
	frame.scrollBgShadow:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	frame.scrollBgShadow:SetAtlas("collections-background-shadow-large") -- Try large first
	frame.scrollBgShadow:SetTexCoord(1, 0, 1, 0)
	frame.scrollBgShadow:SetVertexColor(1, 0.5, 0.5, 0.7)
	-- ScrollFrame border
	frame.scrollBr = frame:CreateTexture(nil, "ARTWORK", nil, 3)
	frame.scrollBr:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", -8, 6)
	frame.scrollBr:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 8, -6)
	frame.scrollBr:SetAtlas("CampCollection-frame")
	frame.scrollBr:SetVertexColor(1, 0.8, 0.8, 1)
	-- Register for ESC key without blocking game controls
	-- Create settings content frame
	addon.MountBrowserSettings:CreateSettingsFrame(frame, self)
	addon.MountBrowserRules:CreateRulesFrame(frame, self)
	tinsert(UISpecialFrames, "RMB_FamilyBrowser")
	-- Ensure ESC key handling works properly
	frame:SetPropagateKeyboardInput(true)
	frame:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:SetPropagateKeyboardInput(false)
			MountBrowser:Hide()
		else
			self:SetPropagateKeyboardInput(true)
		end
	end)
	self.mainFrame = frame
	addon:DebugUI("Mount Browser main frame created")
	return frame
end

-- Lightweight function to re-enable button/icon mouse interaction after scrolling
-- Does NOT recalculate data - just restores interactivity
function MountBrowser:RefreshButtonInteractivity()
	for _, card in ipairs(self.cardPool) do
		if card:IsVisible() and card.data then
			-- Re-enable visible trait buttons
			if card.traitButtons then
				for _, button in pairs(card.traitButtons) do
					if button:IsShown() then
						button:EnableMouse(true)
					end
				end
			end

			-- Re-enable visible capability icon frames
			if card.capabilityIconFrames then
				for _, iconFrame in pairs(card.capabilityIconFrames) do
					if iconFrame:IsShown() then
						iconFrame:EnableMouse(true)
					end
				end
			end
		end
	end
end

-- Batched card update system to prevent freeze on initial load
-- Updates cards in small batches with delays between each batch
function MountBrowser:BatchUpdateCards(cardsData, batchSize, callback)
	batchSize = batchSize or 10 -- Default: 10 cards per batch
	local currentIndex = 1
	local totalCards = #cardsData
	local function processBatch()
		local endIndex = math.min(currentIndex + batchSize - 1, totalCards)
		-- Process this batch
		for i = currentIndex, endIndex do
			local cardData = cardsData[i]
			if cardData and cardData.card and cardData.data then
				self:UpdateCard(cardData.card, cardData.data)
			end
		end

		currentIndex = endIndex + 1
		-- Schedule next batch or finish
		if currentIndex <= totalCards then
			C_Timer.After(MountBrowser.TIMING.BATCH_PROCESS_DELAY, processBatch)
		else
			-- All batches complete
			if callback then
				callback()
			end
		end
	end



	-- Start processing
	processBatch()
end

-- Update visibility check to run periodically
-- ============================================================================
-- VIEW CACHE MANAGEMENT
-- PUBLIC INTERFACE
-- ============================================================================
-- Combat event handler
function MountBrowser:OnEvent(event)
	if event == "PLAYER_REGEN_DISABLED" then
		-- Combat started - close browser
		if self.mainFrame and self.mainFrame:IsShown() then
			self:Hide()
			addon:AlwaysPrint("Mount Browser closed due to combat")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- Combat ended - show if queued
		if self.queuedShow then
			self.queuedShow = false
			self:Show()
		end
	end
end

function MountBrowser:Show()
	if not self.initialized then
		self:Initialize()
	end

	if not self.mainFrame then return end

	-- Combat protection
	if InCombatLockdown() then
		self.queuedShow = true
		addon:AlwaysPrint("Cannot open Mount Browser during combat. Will open automatically when combat ends.")
		return
	end

	-- Ensure we're not in scrolling state
	self.isActivelyScrolling = false
	self.buttonsHiddenForScroll = false
	-- CRITICAL FIX: Re-evaluate traits for any cards that were loaded during scrolling
	-- This can happen if browser was previously opened and immediately closed during scroll
	for _, card in ipairs(self.cardPool) do
		if card:IsVisible() and card.data then
			-- Clear trait positioning to force re-evaluation (keeps currentDataKey for fast path)
			card.traitButtonsPositioned = false
			card.lastTraitKey = nil
		end
	end

	-- Clear representative mount cache for fresh randomization on each open
	self.representativeMountCache = {}
	addon:DebugUI("Cleared representative mount cache")
	-- Show frame immediately (instant feedback)
	self.mainFrame:Show()
	-- Ensure filter buttons are visible (browser opens on Browse tab)
	if self.mainFrame.filterButton then self.mainFrame.filterButton:Show() end

	-- Delay grid loading by 1 frame to prevent graphics overload
	-- This makes opening feel instant while giving the engine time to process
	C_Timer.After(0.05, function()
		if self.mainFrame and self.mainFrame:IsShown() then
			self:LoadMainGrid()
		end
	end)
end

function MountBrowser:Hide()
	if self.mainFrame then
		self.mainFrame:Hide()
		-- Clear show queue
		self.queuedShow = false
	end

	-- Clear load queue and creation queue
	self:ClearLoadQueue()
	-- Reset model loaded flags and data tracking
	for _, card in ipairs(self.cardPool) do
		-- Clear the 3D model from the actor to release graphics resources
		-- This prevents graphics engine overload on rapid open/close cycles
		if card.actor then
			pcall(function()
				card.actor:ClearModel()
			end)
		end

		card.modelLoaded = false
		card.currentDataKey = nil -- Clear data tracking
		card.traitButtonsPositioned = false
		card.lastTraitKey = nil
		-- Disable mouse on all trait buttons to ensure clean state
		if card.traitButtons then
			for _, button in pairs(card.traitButtons) do
				button:EnableMouse(false)
			end
		end

		-- Disable mouse on all capability icon frames
		if card.capabilityIconFrames then
			for _, iconFrame in pairs(card.capabilityIconFrames) do
				iconFrame:EnableMouse(false)
			end
		end
	end

	-- Card creation is now immediate
	-- Stop visibility checking
	self:StopVisibilityCheck()
	-- Close filter flyout menus
	if self.Filters then
		self.Filters:OnHide()
	end

	-- Close sort menu
	if self.Sort then
		self.Sort:OnHide()
	end
end

function MountBrowser:RefreshCurrentView()
	-- Refresh the current view to apply new sort order
	-- Determine what view we're in based on navigation stack
	if #self.navigationStack == 0 then
		-- Main grid
		self:LoadMainGrid()
	elseif #self.navigationStack == 1 then
		local nav = self.navigationStack[1]
		if nav.level == "supergroup" then
			-- Family grid (supergroup view)
			self:LoadFamilyGrid(nav.supergroupName, true) -- skipStackPush = true
		elseif nav.level == "family" then
			-- Mount grid (family view)
			self:LoadMountGrid(nav.familyName, nav.fromSupergroup, true) -- skipStackPush = true
		end
	elseif #self.navigationStack >= 2 then
		-- We're in a mount grid view (inside a family)
		local nav = self.navigationStack[#self.navigationStack]
		if nav.level == "family" then
			self:LoadMountGrid(nav.familyName, nav.fromSupergroup, true) -- skipStackPush = true
		end
	end
end

function MountBrowser:Toggle()
	if self.mainFrame and self.mainFrame:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end
