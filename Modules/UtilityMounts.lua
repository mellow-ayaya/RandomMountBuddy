-- UtilityMounts.lua
-- Displays clickable icons for utility mounts anchored to the ESC menu
local addonName, addon = ...
local UtilityMounts = {}
addon.UtilityMounts = UtilityMounts
-- ============================================================================
-- UTILITY MOUNT DEFINITIONS
-- ============================================================================
-- Trait color codes
local TRAIT_COLORS = {
	repair = "|cFFFFD700",      -- Gold/Yellow
	vendor = "|cFF00FF00",      -- Green
	transmog = "|cFFB366FF",    -- Bright purple
	auctionHouse = "|cFFFF8C00", -- Orange (second rarest)
	mailbox = "|cFF00CCFF",     -- Blue (rarest)
}
-- Static list of utility mounts in display order
-- Format: { mountID, traits = { trait1, trait2, ... }, faction }
-- faction: nil = both, "Alliance" = Alliance only, "Horde" = Horde only
UtilityMounts.UTILITY_MOUNTS = {
	{ mountID = 280, traits = { "repair", "vendor" }, faction = "Alliance" },
	{ mountID = 284, traits = { "repair", "vendor" }, faction = "Horde" },
	{ mountID = 460, traits = { "repair", "vendor", "transmog" }, faction = nil },
	{ mountID = 2237, traits = { "repair", "vendor", "transmog" }, faction = nil },
	{ mountID = 1039, traits = { "repair", "vendor", "auctionHouse" }, faction = nil },
	{ mountID = 2265, traits = { "mailbox", "auctionHouse" }, faction = nil },
}
-- Trait display names
local TRAIT_NAMES = {
	repair = "Repair",
	vendor = "Vendor",
	transmog = "Transmog",
	auctionHouse = "Auction House",
	mailbox = "Mailbox",
}
-- Helper function to build colored description from traits
local function BuildTraitDescription(traits)
	local parts = {}
	for _, trait in ipairs(traits) do
		local color = TRAIT_COLORS[trait] or "|cFFFFFFFF"
		local name = TRAIT_NAMES[trait] or trait
		table.insert(parts, color .. name .. "|r")
	end

	return table.concat(parts, " ")
end

-- Public method to get trait description for a mount
function UtilityMounts:GetMountTraitDescription(mountID)
	for _, mountData in ipairs(self.UTILITY_MOUNTS) do
		if mountData.mountID == mountID then
			return BuildTraitDescription(mountData.traits)
		end
	end

	return ""
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function UtilityMounts:Initialize()
	addon:DebugPrint("UTILITY", "Initializing utility mounts system...")
	-- Create the main container frame
	self.frame = CreateFrame("Frame", "RMB_UtilityMountsFrame", UIParent)
	self.frame:SetFrameStrata("FULLSCREEN")
	self.mountButtons = {}
	-- Hook the game menu to update when it's shown
	self:HookGameMenu()
	-- Build initial display
	self:RefreshDisplay()
	addon:DebugPrint("UTILITY", "Utility mounts initialized")
end

-- ============================================================================
-- GAME MENU HOOKING
-- ============================================================================
function UtilityMounts:HookGameMenu()
	-- Hook into GameMenuFrame show/hide
	if not self.gameMenuHooked then
		GameMenuFrame:HookScript("OnShow", function()
			self:UpdatePosition() -- Update position when showing
			self:Show()
		end)
		GameMenuFrame:HookScript("OnHide", function()
			self:Hide()
		end)
		self.gameMenuHooked = true
		addon:DebugPrint("UTILITY", "Game menu hooks installed")
	end
end

-- ============================================================================
-- DISPLAY MANAGEMENT
-- ============================================================================
function UtilityMounts:RefreshDisplay()
	if not addon:GetSetting("utilityMounts_enabled") then
		self:Hide()
		return
	end

	-- Clear existing buttons
	for _, button in ipairs(self.mountButtons) do
		button:Hide()
		button:SetParent(nil)
	end

	wipe(self.mountButtons)
	-- Get player faction
	local playerFactionGroup = UnitFactionGroup("player") -- Returns "Alliance" or "Horde"
	-- Get enabled mounts from settings
	local enabledMounts = addon:GetSetting("utilityMounts_enabledMounts") or {}
	local iconSize = addon:GetSetting("utilityMounts_iconSize") or 32
	-- Filter and create buttons for available mounts
	local buttonIndex = 0
	for i, mountData in ipairs(self.UTILITY_MOUNTS) do
		local mountID = mountData.mountID
		-- Check if mount is enabled in settings
		if enabledMounts[mountID] ~= false then -- Default to enabled if not explicitly disabled
			-- Check faction restriction
			local factionMatch = true
			if mountData.faction and mountData.faction ~= playerFactionGroup then
				factionMatch = false
			end

			-- Check if player owns the mount
			local mountName, spellID, icon, isActive, isUsable, sourceType, isFavorite,
			isFactionSpecific, faction, shouldHideOnChar, isCollected =
					C_MountJournal.GetMountInfoByID(mountID)
			-- Only proceed if API call succeeded and mount is collected
			if mountName and factionMatch and isCollected then
				buttonIndex = buttonIndex + 1
				local button = self:CreateMountButton(mountID, mountData, iconSize, buttonIndex)
				if button then
					table.insert(self.mountButtons, button)
				end
			end
		end
	end

	-- Update positioning
	self:UpdatePosition()
	-- Show or hide based on whether we have buttons
	if #self.mountButtons > 0 and GameMenuFrame:IsShown() then
		self:Show()
	else
		self:Hide()
	end

	addon:DebugPrint("UTILITY", "Display refreshed - " .. #self.mountButtons .. " utility mounts shown")
end

function UtilityMounts:CreateMountButton(mountID, mountData, size, index)
	-- Get mount info from API (localized name)
	local mountName, spellID, icon = C_MountJournal.GetMountInfoByID(mountID)
	-- Validate API response
	if not mountName or not icon then
		addon:DebugPrint("UTILITY", "ERROR: Failed to get mount info for mountID " .. tostring(mountID))
		return nil
	end

	local button = CreateFrame("Button", "RMB_UtilityMount_" .. mountID, self.frame)
	button:SetSize(size, size)
	-- Create icon texture
	local texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture(icon)
	button.texture = texture
	-- Click handler - summon mount
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "LeftButton" then
			UtilityMounts:SummonMount(mountID)
		end
	end)
	-- Build colored trait description
	local traitDescription = BuildTraitDescription(mountData.traits)
	-- Tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(mountName, 1, 1, 1)
		GameTooltip:AddLine(traitDescription, nil, nil, nil, true)
		GameTooltip:AddLine(" ") -- Blank line
		GameTooltip:AddLine("Click to summon", 0, 1, 0)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	-- Store mount ID for reference
	button.mountID = mountID
	button.index = index
	return button
end

function UtilityMounts:UpdatePosition()
	if #self.mountButtons == 0 then
		return
	end

	local anchor = addon:GetSetting("utilityMounts_anchor") or "BOTTOM"
	local iconSize = addon:GetSetting("utilityMounts_iconSize") or 32
	local spacing = 4
	-- Position relative to GameMenuFrame
	local menuFrame = GameMenuFrame
	if not menuFrame then
		return
	end

	-- Calculate total width/height needed
	local numButtons = #self.mountButtons
	if anchor == "BOTTOM" then
		-- Horizontal layout at bottom
		local totalWidth = (iconSize * numButtons) + (spacing * (numButtons - 1))
		local startX = -(totalWidth / 2) + (iconSize / 2)
		for i, button in ipairs(self.mountButtons) do
			button:ClearAllPoints()
			button:SetPoint("TOP", menuFrame, "BOTTOM", startX + ((i - 1) * (iconSize + spacing)), -2)
		end
	elseif anchor == "TOP" then
		-- Horizontal layout at top
		local totalWidth = (iconSize * numButtons) + (spacing * (numButtons - 1))
		local startX = -(totalWidth / 2) + (iconSize / 2)
		for i, button in ipairs(self.mountButtons) do
			button:ClearAllPoints()
			button:SetPoint("BOTTOM", menuFrame, "TOP", startX + ((i - 1) * (iconSize + spacing)), 10)
		end
	elseif anchor == "LEFT" then
		-- Vertical layout on left - anchor to top
		for i, button in ipairs(self.mountButtons) do
			button:ClearAllPoints()
			button:SetPoint("TOPRIGHT", menuFrame, "TOPLEFT", -2, -((i - 1) * (iconSize + spacing)))
		end
	elseif anchor == "RIGHT" then
		-- Vertical layout on right - anchor to top
		for i, button in ipairs(self.mountButtons) do
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", menuFrame, "TOPRIGHT", 2, -((i - 1) * (iconSize + spacing)))
		end
	end
end

function UtilityMounts:Show()
	if addon:GetSetting("utilityMounts_enabled") and #self.mountButtons > 0 then
		self.frame:Show()
	end
end

function UtilityMounts:Hide()
	self.frame:Hide()
end

-- ============================================================================
-- MOUNT SUMMONING
-- ============================================================================
function UtilityMounts:SummonMount(mountID)
	addon:DebugPrint("UTILITY", "Summoning utility mount: " .. mountID)
	-- Dismount first
	if IsMounted() then
		Dismount()
		-- Wait a moment for dismount to complete
		C_Timer.After(0.1, function()
			C_MountJournal.SummonByID(mountID)
		end)
	else
		-- Summon immediately if not mounted
		C_MountJournal.SummonByID(mountID)
	end
end

-- ============================================================================
-- SETTINGS HELPERS
-- ============================================================================
function UtilityMounts:GetMountList()
	-- Returns the full list of utility mounts for settings UI
	return self.UTILITY_MOUNTS
end

function UtilityMounts:IsMountEnabled(mountID)
	local enabledMounts = addon:GetSetting("utilityMounts_enabledMounts") or {}
	return enabledMounts[mountID] ~= false -- Default to enabled
end

function UtilityMounts:SetMountEnabled(mountID, enabled)
	local enabledMounts = addon:GetSetting("utilityMounts_enabledMounts") or {}
	enabledMounts[mountID] = enabled
	addon:SetSetting("utilityMounts_enabledMounts", enabledMounts)
	self:RefreshDisplay()
end

-- ============================================================================
-- COLLECTION UPDATE CALLBACK
-- ============================================================================
function UtilityMounts:OnMountCollectionChanged()
	addon:DebugPrint("UTILITY", "Mount collection changed, refreshing utility mounts display")
	self:RefreshDisplay()
end
