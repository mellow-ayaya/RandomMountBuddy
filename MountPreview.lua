-- MountPreview.lua
-- Mount preview dialog and functionality
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: MountPreview.lua START.")
-- ============================================================================
-- MOUNT PREVIEW CLASS
-- ============================================================================
local MountPreview = {}
addon.MountPreview = MountPreview
-- ============================================================================
-- PREVIEW DIALOG CREATION AND MANAGEMENT
-- ============================================================================
function MountPreview:Initialize()
	print("RMB_PREVIEW: Initializing preview system...")
	-- Preview consistency system
	self.currentPreviewSelection = {}
	self.previewDialog = nil
	self:SetupPreviewConsistency()
	print("RMB_PREVIEW: Initialized successfully")
end

-- Create or update the preview dialog
function MountPreview:ShowMountPreview(mountID, mountName, groupKey, groupType, isUncollected)
	if not mountID then
		print("RMB_PREVIEW: No mount ID provided")
		return
	end

	-- Create dialog if it doesn't exist
	if not self.previewDialog then
		self:CreatePreviewDialog()
	end

	-- Update dialog with current mount
	self:UpdatePreviewDialog(mountID, mountName, groupKey, groupType, isUncollected)
	-- Show the dialog
	self.previewDialog:Show()
end

function MountPreview:CreatePreviewDialog()
	print("RMB_PREVIEW: Creating preview dialog...")
	-- Create main dialog frame
	local frame = CreateFrame("Frame", "RMB_PreviewDialog", UIParent, "BackdropTemplate")
	frame:SetSize(350, 350)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(100)
	-- Make it draggable
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	-- Add background
	frame:SetBackdrop({
		bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	-- Create title text
	frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.title:SetPoint("TOP", 0, -15)
	frame.title:SetText("Mount Preview")
	-- Create model display
	frame.model = CreateFrame("PlayerModel", nil, frame)
	frame.model:SetPoint("TOP", 0, -40)
	frame.model:SetPoint("BOTTOM", 0, 40)
	frame.model:SetPoint("LEFT", 20, 0)
	frame.model:SetPoint("RIGHT", -20, 0)
	-- Create close button
	frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.closeButton:SetPoint("TOPRIGHT", -4, -4)
	frame.closeButton:SetScript("OnClick", function() frame:Hide() end)
	-- Create Next button (Random Preview)
	frame.nextButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.nextButton:SetSize(120, 22)
	frame.nextButton:SetPoint("BOTTOMRIGHT", -20, 15)
	frame.nextButton:SetText("Random Preview")
	-- Create Summon button
	frame.summonButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.summonButton:SetSize(120, 22)
	frame.summonButton:SetPoint("BOTTOMLEFT", 20, 15)
	frame.summonButton:SetText("Summon")
	-- Hide on Escape key
	frame:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:Hide()
		end
	end)
	frame:EnableKeyboard(true)
	-- Store reference
	self.previewDialog = frame
	print("RMB_PREVIEW: Preview dialog created")
end

function MountPreview:UpdatePreviewDialog(mountID, mountName, groupKey, groupType, isUncollected)
	local frame = self.previewDialog
	if not frame then return end

	-- Store current mount info
	frame.currentMountID = mountID
	frame.currentMountName = mountName
	frame.groupKey = groupKey
	frame.groupType = groupType
	frame.isUncollected = isUncollected
	-- Update title with proper color
	if frame.title then
		if isUncollected then
			frame.title:SetText("|cff9d9d9d" .. (mountName or "Unknown Mount") .. " (Uncollected)|r")
		else
			frame.title:SetText(mountName or "Unknown Mount")
		end
	end

	-- Update model
	if frame.model then
		local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
		if creatureDisplayID then
			frame.model:SetDisplayInfo(creatureDisplayID)
			frame.model:SetCamDistanceScale(1.5)
			frame.model:SetPosition(0, 0, 0)
			frame.model:SetFacing(0.5)
		else
			print("RMB_PREVIEW: No display ID found for mount: " .. tostring(mountID))
		end
	end

	-- Update Next button
	if frame.nextButton then
		if groupKey and groupType then
			frame.nextButton:Enable()
			frame.nextButton:SetScript("OnClick", function()
				self:ShowNextRandomMount(groupKey, groupType)
			end)
		else
			frame.nextButton:Disable()
		end
	end

	-- Update Summon button
	if frame.summonButton then
		if isUncollected then
			frame.summonButton:SetText("Cannot Summon")
			frame.summonButton:Disable()
		else
			frame.summonButton:SetText("Summon")
			frame.summonButton:Enable()
			frame.summonButton:SetScript("OnClick", function()
				self:SummonCurrentMount()
			end)
		end
	end
end

-- ============================================================================
-- PREVIEW ACTIONS
-- ============================================================================
function MountPreview:ShowNextRandomMount(groupKey, groupType)
	local includeUncollected = addon:GetSetting("showUncollectedMounts")
	local mountID, mountName, isUncollected = addon.MountDataManager:GetRandomMountFromGroup(
		groupKey, groupType, includeUncollected)
	if mountID then
		self:UpdatePreviewDialog(mountID, mountName, groupKey, groupType, isUncollected)
	else
		print("RMB_PREVIEW: No mount available for next random preview")
	end
end

function MountPreview:SummonCurrentMount()
	local frame = self.previewDialog
	if not frame or not frame.currentMountID or frame.isUncollected then
		return
	end

	-- Summon the mount
	C_MountJournal.SummonByID(frame.currentMountID)
	-- Hide the dialog
	frame:Hide()
	print("RMB_PREVIEW: Summoned mount: " .. tostring(frame.currentMountName))
end

-- ============================================================================
-- PREVIEW CONSISTENCY SYSTEM
-- ============================================================================
function MountPreview:SetupPreviewConsistency()
	print("RMB_PREVIEW: Setting up preview consistency system...")
	-- Hook tooltip hiding to reset selection
	if GameTooltip then
		GameTooltip:HookScript("OnHide", function()
			self.currentPreviewSelection = {}
		end)
	end

	-- Hook AceGUI tooltip if available
	if LibStub and LibStub("AceGUI-3.0", true) then
		local AceGUI = LibStub("AceGUI-3.0")
		if AceGUI and AceGUI.tooltip then
			AceGUI.tooltip:HookScript("OnHide", function()
				self.currentPreviewSelection = {}
			end)
		end
	end

	-- Hook AceConfigDialog tooltip if available
	if LibStub and LibStub("AceConfigDialog-3.0", true) then
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		if AceConfigDialog and AceConfigDialog.tooltip then
			AceConfigDialog.tooltip:HookScript("OnHide", function()
				self.currentPreviewSelection = {}
			end)
		end
	end

	print("RMB_PREVIEW: Preview consistency system installed")
end

-- Get consistent random mount for tooltip/preview (prevents flickering)
function MountPreview:GetConsistentRandomMount(groupKey, groupType, includeUncollected)
	-- Generate cache key
	local cacheKey = groupKey .. "_" .. (groupType or "")
	-- Return cached selection if available
	if self.currentPreviewSelection.key == cacheKey and
			self.currentPreviewSelection.id and
			self.currentPreviewSelection.name then
		return self.currentPreviewSelection.id,
				self.currentPreviewSelection.name,
				self.currentPreviewSelection.isUncollected
	end

	-- Get new random mount
	local mountID, mountName, isUncollected = addon.MountDataManager:GetRandomMountFromGroup(
		groupKey, groupType, includeUncollected)
	-- Cache the selection
	if mountID then
		self.currentPreviewSelection = {
			key = cacheKey,
			id = mountID,
			name = mountName,
			isUncollected = isUncollected,
		}
	end

	return mountID, mountName, isUncollected
end

-- ============================================================================
-- TOOLTIP MODEL DISPLAY
-- ============================================================================
function MountPreview:InitializeTooltipModel()
	print("RMB_PREVIEW: Initializing tooltip model display...")
	-- Create backdrop frame
	local bg = CreateFrame("Frame", "RMB_ModelTooltipBG", UIParent, "BackdropTemplate")
	bg:SetSize(160, 160)
	bg:SetFrameStrata("TOOLTIP")
	bg:SetFrameLevel(1)
	bg:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	bg:SetBackdropColor(0, 0, 0, 0.7)
	bg:Hide()
	-- Create model frame
	local frame = CreateFrame("PlayerModel", "RMB_ModelTooltip", UIParent)
	frame:SetSize(150, 150)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetFrameLevel(10)
	frame:Hide()
	-- Store references
	self.modelTooltipBG = bg
	self.modelTooltip = frame
	-- Hook GameTooltip
	self:HookTooltipEvents()
	print("RMB_PREVIEW: Tooltip model display initialized")
end

function MountPreview:HookTooltipEvents()
	local bg = self.modelTooltipBG
	local frame = self.modelTooltip
	-- GameTooltip hooks
	if GameTooltip then
		GameTooltip:HookScript("OnShow", function(tooltip)
			self:ShowModelForTooltip(tooltip)
		end)
		GameTooltip:HookScript("OnHide", function()
			bg:Hide()
			frame:Hide()
			addon.currentTooltipMount = nil
		end)
	end

	-- AceConfigDialog tooltip hooks
	if LibStub and LibStub("AceConfigDialog-3.0", true) then
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		if AceConfigDialog and AceConfigDialog.tooltip then
			AceConfigDialog.tooltip:HookScript("OnShow", function(tooltip)
				self:ShowModelForTooltip(tooltip)
			end)
			AceConfigDialog.tooltip:HookScript("OnHide", function()
				bg:Hide()
				frame:Hide()
				addon.currentTooltipMount = nil
			end)
		end
	end
end

function MountPreview:ShowModelForTooltip(tooltip)
	if not addon.currentTooltipMount then
		self.modelTooltipBG:Hide()
		self.modelTooltip:Hide()
		return
	end

	local mountID = addon.currentTooltipMount
	local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
	if creatureDisplayID then
		local frame = self.modelTooltip
		local bg = self.modelTooltipBG
		-- Set up model
		frame:SetDisplayInfo(creatureDisplayID)
		frame:SetCamDistanceScale(1.5)
		frame:SetPosition(0, 0, 0)
		frame:SetFacing(0.5)
		-- Position next to tooltip
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", tooltip, "RIGHT", 0, 0)
		bg:ClearAllPoints()
		bg:SetPoint("CENTER", frame, "CENTER", 0, 0)
		-- Show both
		bg:Show()
		frame:Show()
		print("RMB_PREVIEW: Showing tooltip model for mount ID: " .. mountID)
	else
		self.modelTooltipBG:Hide()
		self.modelTooltip:Hide()
	end
end

-- ============================================================================
-- INTEGRATION HELPERS
-- ============================================================================
-- Called by other components to set current tooltip mount
function MountPreview:SetCurrentTooltipMount(mountID)
	addon.currentTooltipMount = mountID
end

-- Hide all preview elements
function MountPreview:HideAll()
	if self.previewDialog then
		self.previewDialog:Hide()
	end

	if self.modelTooltipBG then
		self.modelTooltipBG:Hide()
	end

	if self.modelTooltip then
		self.modelTooltip:Hide()
	end

	addon.currentTooltipMount = nil
	self.currentPreviewSelection = {}
end

-- Check if preview dialog is open
function MountPreview:IsPreviewOpen()
	return self.previewDialog and self.previewDialog:IsShown()
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================
-- Auto-initialize when addon loads
function addon:InitializeMountPreview()
	if not self.MountPreview then
		print("RMB_PREVIEW: ERROR - MountPreview not found!")
		return
	end

	self.MountPreview:Initialize()
	self.MountPreview:InitializeTooltipModel()
	print("RMB_PREVIEW: Integration complete")
end

print("RMB_DEBUG: MountPreview.lua END.")
