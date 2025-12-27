--[[
    Random Mount Buddy - Minimap & Addon Compartment Module
    Handles minimap icon (via LibDataBroker/LibDBIcon) and addon compartment integration
]] --
local addonName, addonTable = ...
local addon = RandomMountBuddy
-- LibDataBroker for minimap icon
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)
-- Module for Minimap Button functionality
local MinimapButton = {}
addon.MinimapButton = MinimapButton
-- Initialize the minimap icon and addon compartment
function MinimapButton:Initialize()
	addon:DebugCore("MinimapButton: Initializing...")
	-- Check if required libraries are available
	if not LDB then
		addon:DebugCore("MinimapButton: LibDataBroker-1.1 not found, minimap icon disabled")
		return
	end

	-- Create LibDataBroker object
	self.dataObject = LDB:NewDataObject(addonName, {
		type = "launcher",
		text = "RMB",
		icon = "Interface\\AddOns\\RandomMountBuddy\\Media\\icon.tga",
		OnClick = function(_, button)
			MinimapButton:OnClick(button)
		end,
		OnTooltipShow = function(tooltip)
			MinimapButton:OnTooltipShow(tooltip)
		end,
	})
	if not self.dataObject then
		addon:DebugCore("MinimapButton: Failed to create LibDataBroker object")
		return
	end

	-- Initialize minimap icon if LibDBIcon is available
	if LDBIcon then
		-- Initialize saved variables for minimap icon position
		if not addon.db.profile.minimapIcon then
			addon.db.profile.minimapIcon = {}
		end

		-- Sync minimapIcon.hide with showMinimapButton setting
		local shouldShow = addon:GetSetting("showMinimapButton")
		addon.db.profile.minimapIcon.hide = not shouldShow
		-- Register with LibDBIcon
		LDBIcon:Register(addonName, self.dataObject, addon.db.profile.minimapIcon)
		addon:DebugCore("MinimapButton: LibDBIcon registered with hide =", addon.db.profile.minimapIcon.hide)
		-- Update visibility based on settings
		self:UpdateMinimapButtonVisibility()
	else
		addon:DebugCore("MinimapButton: LibDBIcon-1.0 not found, minimap icon disabled")
	end

	-- Register addon compartment
	addon:DebugCore("MinimapButton: Initialization complete")
end

-- Handle clicks on the minimap button
function MinimapButton:OnClick(button)
	if button == "LeftButton" then
		-- Left click: Open mount browser
		addon:DebugCore("MinimapButton: Left click - opening mount browser")
		if addon.MountBrowser and addon.MountBrowser.Toggle then
			addon.MountBrowser:Toggle()
		end
	elseif button == "RightButton" then
		-- Right click: Open options
		addon:DebugCore("MinimapButton: Right click - opening options")
		MinimapButton:OpenOptions()
	elseif button == "MiddleButton" then

	end
end

-- Show tooltip for minimap button
function MinimapButton:OnTooltipShow(tooltip)
	if not tooltip then return end

	tooltip:AddLine("|cff00ff00Random Mount Buddy|r", 1, 1, 1)
	tooltip:AddDoubleLine("|cffffd700Left Click:|r", "|cff00ff00Open Mount Browser|r", 1, 1, 1, 1, 1, 1)
	tooltip:AddDoubleLine("|cffffd700Right Click:|r", "|cff00ff00Open Options|r", 1, 1, 1, 1, 1, 1)
end

-- Open addon options
function MinimapButton:OpenOptions()
	-- Use Settings API (available in Dragonflight+)
	if Settings and Settings.OpenToCategory then
		Settings.OpenToCategory("Random Mount Buddy")
	end
end

-- Update minimap button visibility based on settings
function MinimapButton:UpdateMinimapButtonVisibility()
	if not LDBIcon or not addon.db or not addon.db.profile then return end

	local shouldShow = addon:GetSetting("showMinimapButton")
	addon:DebugCore("MinimapButton: Updating visibility - shouldShow:", shouldShow)
	-- Sync minimapIcon.hide with the setting
	if addon.db.profile.minimapIcon then
		addon.db.profile.minimapIcon.hide = not shouldShow
	end

	if shouldShow then
		LDBIcon:Show(addonName)
	else
		LDBIcon:Hide(addonName)
	end
end

-- Refresh both minimap and compartment visibility
function MinimapButton:RefreshVisibility()
	self:UpdateMinimapButtonVisibility()
end

return MinimapButton
