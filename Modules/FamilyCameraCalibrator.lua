-- FamilyCameraCalibrator.lua
-- Developer tool for calibrating camera positions for mount families and supergroups
local addonName, addon = ...
-- Create the calibrator object
local FamilyCameraCalibrator = {}
addon.FamilyCameraCalibrator = FamilyCameraCalibrator
-- Constants
local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 600  -- Reduced from 700 since preview is smaller
local PREVIEW_HEIGHT = 200 -- Match browser card preview height
local PREVIEW_WIDTH = 220  -- Match browser card preview width
-- Camera settings are now managed in MountBrowser.lua
-- Access them via addon.DefaultCameraSettings and addon.CameraOverrides
-- Step sizes for adjustments
local STEP_SIZES = {
	fine = 0.01,
	normal = 0.1,
	coarse = 1.0,
}
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function FamilyCameraCalibrator:Initialize()
	if self.initialized then return end

	addon:DebugUI("Initializing Camera Calibrator...")
	-- Current state
	self.currentGroup = nil
	self.currentType = nil
	self.currentStepSize = "normal"
	self.currentCamera = {
		x = addon.DefaultCameraSettings.x,
		y = addon.DefaultCameraSettings.y,
		z = addon.DefaultCameraSettings.z,
		yaw = addon.DefaultCameraSettings.yaw,
		pitch = addon.DefaultCameraSettings.pitch,
		roll = addon.DefaultCameraSettings.roll,
	}
	-- Create the main window
	self:CreateMainWindow()
	self.initialized = true
	addon:DebugUI("Camera Calibrator initialized")
end

-- ============================================================================
-- MAIN WINDOW CREATION
-- ============================================================================
function FamilyCameraCalibrator:CreateMainWindow()
	local frame = CreateFrame("Frame", "RMB_CameraCalibrator", UIParent, "BackdropTemplate")
	frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	-- Background
	frame:SetBackdrop({
		bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 8, right = 8, top = 8, bottom = 8 },
	})
	-- Title
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.title:SetPoint("TOP", 0, -15)
	frame.title:SetText("Camera Calibrator (Dev Tool)")
	-- Close button
	frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.closeButton:SetPoint("TOPRIGHT", -5, -5)
	-- Create group selector dropdown
	self:CreateGroupSelector(frame)
	-- Create preview area
	self:CreatePreviewArea(frame)
	-- Create camera value display
	self:CreateValueDisplay(frame)
	-- Create control buttons
	self:CreateControlButtons(frame)
	-- Create action buttons
	self:CreateActionButtons(frame)
	-- Register for ESC key
	tinsert(UISpecialFrames, "RMB_CameraCalibrator")
	self.mainFrame = frame
	frame:Hide()
end

-- ============================================================================
-- GROUP SELECTOR
-- ============================================================================
function FamilyCameraCalibrator:CreateGroupSelector(parent)
	-- Label
	local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", 20, -50)
	label:SetText("Select Group:")
	-- Dropdown button
	local dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	dropdown:SetSize(250, 25)
	dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
	dropdown:SetText("Choose Supergroup or Family...")
	dropdown:SetScript("OnClick", function(self)
		FamilyCameraCalibrator:ShowGroupMenu(self)
	end)
	parent.groupDropdown = dropdown
end

function FamilyCameraCalibrator:ShowGroupMenu(anchorFrame)
	-- Create or reuse popup menu frame
	if not self.groupMenu then
		self:CreateGroupMenuFrame()
	end

	-- Clear existing buttons
	if self.groupMenu.buttons then
		for _, btn in ipairs(self.groupMenu.buttons) do
			btn:Hide()
		end
	end

	self.groupMenu.buttons = {}
	-- Build menu items - combine supergroups and standalone families
	local items = {}
	local allGroups = {}
	-- Collect supergroups
	if addon.SuperGroupManager then
		local supergroups = addon.SuperGroupManager:GetAllSuperGroups()
		for _, sg in ipairs(supergroups) do
			table.insert(allGroups, {
				text = sg.displayName or sg.name,
				groupKey = sg.name,
				groupType = "supergroup",
				sortKey = (sg.displayName or sg.name):lower(),
			})
		end
	end

	-- Collect standalone families
	if addon.processedData and addon.processedData.standaloneFamilyNames then
		for familyName, _ in pairs(addon.processedData.standaloneFamilyNames) do
			table.insert(allGroups, {
				text = familyName,
				groupKey = familyName,
				groupType = "familyName",
				sortKey = familyName:lower(),
			})
		end
	end

	-- Sort all groups alphabetically
	table.sort(allGroups, function(a, b) return a.sortKey < b.sortKey end)
	-- Add sorted groups to items
	for _, group in ipairs(allGroups) do
		table.insert(items, {
			text = group.text,
			groupKey = group.groupKey,
			groupType = group.groupType,
		})
	end

	-- Populate menu
	self:PopulateGroupMenu(items)
	-- Position and show
	self.groupMenu:ClearAllPoints()
	self.groupMenu:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2)
	self.groupMenu:Show()
end

function FamilyCameraCalibrator:CreateGroupMenuFrame()
	local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	menu:SetSize(250, 400)
	menu:SetFrameStrata("FULLSCREEN_DIALOG")
	menu:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	menu:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
	menu:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	menu:Hide()
	-- Create invisible blocker to catch clicks outside menu
	local blocker = CreateFrame("Frame", nil, UIParent)
	blocker:SetFrameStrata("FULLSCREEN_DIALOG")
	blocker:SetFrameLevel(menu:GetFrameLevel() - 1)
	blocker:SetAllPoints(UIParent)
	blocker:EnableMouse(true)
	blocker:Hide()
	blocker:SetScript("OnMouseDown", function(self)
		menu:Hide()
	end)
	menu:SetScript("OnShow", function(self)
		blocker:Show()
	end)
	menu:SetScript("OnHide", function(self)
		blocker:Hide()
	end)
	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 8, -8)
	scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
	-- Scroll child
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(210, 1) -- Height will be set dynamically
	scrollFrame:SetScrollChild(scrollChild)
	menu.scrollFrame = scrollFrame
	menu.scrollChild = scrollChild
	menu.buttons = {}
	menu.blocker = blocker
	self.groupMenu = menu
end

function FamilyCameraCalibrator:PopulateGroupMenu(items)
	local menu = self.groupMenu
	local scrollChild = menu.scrollChild
	local yOffset = 0
	local buttonHeight = 20
	local spacing = 2
	for i, item in ipairs(items) do
		local btn = CreateFrame("Button", nil, scrollChild)
		btn:SetSize(210, buttonHeight)
		btn:SetPoint("TOPLEFT", 0, -yOffset)
		local text = btn:CreateFontString(nil, "OVERLAY", item.isTitle and "GameFontNormalLarge" or "GameFontHighlight")
		text:SetPoint("LEFT", 5, 0)
		text:SetJustifyH("LEFT")
		text:SetText(item.text)
		btn.fontString = text -- Store reference for callbacks
		if not item.isTitle then
			-- Interactive button
			btn:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
			btn:SetScript("OnClick", function()
				self:SelectGroup(item.groupKey, item.groupType)
				menu:Hide()
			end)
			btn:SetScript("OnEnter", function(self)
				self.fontString:SetTextColor(1, 1, 0)
			end)
			btn:SetScript("OnLeave", function(self)
				self.fontString:SetTextColor(1, 1, 1)
			end)
		else
			-- Title (not clickable)
			text:SetTextColor(1, 0.82, 0)
			btn:SetScript("OnEnter", nil)
			btn:SetScript("OnLeave", nil)
		end

		table.insert(menu.buttons, btn)
		yOffset = yOffset + buttonHeight + spacing
	end

	-- Update scroll child height
	scrollChild:SetHeight(math.max(yOffset, 400))
end

function FamilyCameraCalibrator:SelectGroup(groupKey, groupType)
	self.currentGroup = groupKey
	self.currentType = groupType
	-- Update dropdown text
	self.mainFrame.groupDropdown:SetText(groupKey)
	-- Load camera settings for this group
	self:LoadCameraSettings(groupKey, groupType)
	-- Update preview
	self:UpdatePreview()
	addon:DebugUI("Selected group: " .. groupKey .. " (" .. groupType .. ")")
end

-- ============================================================================
-- PREVIEW AREA
-- ============================================================================
function FamilyCameraCalibrator:CreatePreviewArea(parent)
	-- Preview container
	local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	container:SetPoint("TOP", parent.groupDropdown, "BOTTOM", 0, -20)
	container:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT + 20) -- Add padding
	container:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 8, right = 8, top = 8, bottom = 8 },
	})
	container:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
	container:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	-- ModelScene for 3D preview - exact browser card size
	local modelScene = CreateFrame("ModelScene", nil, container)
	modelScene:SetPoint("TOPLEFT", 10, -10)
	modelScene:SetSize(PREVIEW_WIDTH, PREVIEW_HEIGHT)
	-- Set camera (will be updated when group is selected)
	modelScene:SetCameraPosition(addon.DefaultCameraSettings.x, addon.DefaultCameraSettings.y,
		addon.DefaultCameraSettings.z)
	modelScene:SetCameraOrientationByYawPitchRoll(addon.DefaultCameraSettings.yaw, addon.DefaultCameraSettings.pitch,
		addon.DefaultCameraSettings.roll)
	-- Create actor
	local actor = modelScene:CreateActor()
	parent.previewContainer = container
	parent.modelScene = modelScene
	parent.actor = actor
end

function FamilyCameraCalibrator:UpdatePreview()
	if not self.currentGroup or not self.mainFrame.actor then
		return
	end

	-- Get a representative mount for this group
	local repMount = self:GetRepresentativeMount(self.currentGroup, self.currentType)
	if not repMount then
		addon:DebugUI("No representative mount found for " .. self.currentGroup)
		return
	end

	-- Load the model
	local mountID = repMount.mountID
	if mountID then
		-- Try GetMountInfoExtraByID first
		local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
		-- Fallback for class-restricted mounts: try GetAllCreatureDisplayIDsForMountID
		if not creatureDisplayID then
			local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mountID)
			if allDisplayIDs and #allDisplayIDs > 0 then
				creatureDisplayID = allDisplayIDs[1]
				addon:DebugUI("Using fallback displayID for mount " .. mountID)
			end
		end

		if creatureDisplayID then
			local success, err = pcall(function()
				self.mainFrame.actor:SetModelByCreatureDisplayID(creatureDisplayID)
			end)
			if success then
				addon:DebugUI("Loaded model for " .. (repMount.name or "mount") ..
					(repMount.isUncollected and " (uncollected)" or ""))
			else
				addon:DebugUI("Failed to load model for " .. (repMount.name or "mount") .. ": " .. tostring(err))
			end
		else
			addon:DebugUI("No display ID found for mount " .. mountID)
		end
	end

	-- Update camera with current settings
	self:ApplyCameraSettings()
end

function FamilyCameraCalibrator:GetRepresentativeMount(key, type)
	if not addon.processedData then return nil end

	local mounts = {}
	if type == "supergroup" then
		-- Get all mounts from all families in supergroup
		if addon.processedData.superGroupMap and addon.processedData.superGroupMap[key] then
			local families = addon.processedData.superGroupMap[key]
			for _, familyName in ipairs(families) do
				-- Try collected mounts first
				if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName] then
					local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
						if mountInfo then
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							mountWithID.isUncollected = false
							table.insert(mounts, mountWithID)
						end
					end
				end

				-- If no collected mounts, try uncollected
				if #mounts == 0 and addon.processedData.familyToUncollectedMountIDsMap and
						addon.processedData.familyToUncollectedMountIDsMap[familyName] then
					local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[familyName]
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
						if mountInfo then
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							mountWithID.isUncollected = true
							table.insert(mounts, mountWithID)
						end
					end
				end
			end
		end
	elseif type == "familyName" then
		-- Get all mounts in family
		-- Try collected mounts first
		if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[key] then
			local mountIDs = addon.processedData.familyToMountIDsMap[key]
			for _, mountID in ipairs(mountIDs) do
				local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
				if mountInfo then
					local mountWithID = {}
					for k, v in pairs(mountInfo) do
						mountWithID[k] = v
					end

					mountWithID.mountID = mountID
					mountWithID.isUncollected = false
					table.insert(mounts, mountWithID)
				end
			end
		end

		-- If no collected mounts, try uncollected
		if #mounts == 0 and addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[key] then
			local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[key]
			for _, mountID in ipairs(mountIDs) do
				local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
				if mountInfo then
					local mountWithID = {}
					for k, v in pairs(mountInfo) do
						mountWithID[k] = v
					end

					mountWithID.mountID = mountID
					mountWithID.isUncollected = true
					table.insert(mounts, mountWithID)
				end
			end
		end
	end

	if #mounts == 0 then return nil end

	-- Prefer collected mounts
	for _, mount in ipairs(mounts) do
		if not mount.isUncollected then
			return mount
		end
	end

	-- Fall back to first uncollected if no collected mounts
	return mounts[1]
end

-- ============================================================================
-- CAMERA VALUE DISPLAY
-- ============================================================================
function FamilyCameraCalibrator:CreateValueDisplay(parent)
	local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	container:SetPoint("TOPLEFT", parent.previewContainer, "TOPRIGHT", 10, 0)
	container:SetSize(180, PREVIEW_HEIGHT + 20) -- Match preview container height
	container:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
	container:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	-- Title
	local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -10)
	title:SetText("Values")
	-- Value labels
	local labels = {}
	local yOffset = -40
	local spacing = 30
	for _, param in ipairs({ "x", "y", "z", "yaw", "pitch", "roll" }) do
		local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("TOPLEFT", 10, yOffset)
		label:SetJustifyH("LEFT")
		label:SetText(param:upper() .. ": 0.00")
		labels[param] = label
		yOffset = yOffset - spacing
	end

	parent.valueLabels = labels
	self:UpdateValueDisplay()
end

function FamilyCameraCalibrator:UpdateValueDisplay()
	if not self.mainFrame or not self.mainFrame.valueLabels then return end

	local cam = self.currentCamera
	local labels = self.mainFrame.valueLabels
	labels.x:SetText(string.format("X: %.2f", cam.x))
	labels.y:SetText(string.format("Y: %.2f", cam.y))
	labels.z:SetText(string.format("Z: %.2f", cam.z))
	labels.yaw:SetText(string.format("YAW: %.2f", cam.yaw))
	labels.pitch:SetText(string.format("PITCH: %.2f", cam.pitch))
	labels.roll:SetText(string.format("ROLL: %.2f", cam.roll))
end

-- ============================================================================
-- CONTROL BUTTONS
-- ============================================================================
function FamilyCameraCalibrator:CreateControlButtons(parent)
	local yStart = parent.previewContainer:GetBottom() - 1100
	local buttonWidth = 80
	local buttonHeight = 25
	local spacing = 10
	-- Step size selector
	local stepLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	stepLabel:SetPoint("TOPLEFT", 20, yStart)
	stepLabel:SetText("Step Size:")
	local stepButtons = {}
	local stepSizes = { "fine", "normal", "coarse" }
	local xOffset = 90
	for i, size in ipairs(stepSizes) do
		local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		btn:SetSize(70, 22)
		btn:SetPoint("TOPLEFT", stepLabel, "TOPLEFT", xOffset, 0)
		btn:SetText(size:sub(1, 1):upper() .. size:sub(2))
		btn:SetScript("OnClick", function()
			self:SetStepSize(size)
			self:UpdateStepButtons()
		end)
		stepButtons[size] = btn
		xOffset = xOffset + 75
	end

	parent.stepButtons = stepButtons
	self:UpdateStepButtons()
	-- Control button grid
	yStart = yStart - 40
	local controls = {
		{ param = "x", label = "X" },
		{ param = "yaw", label = "YAW" },
		{ param = "z", label = "Z" },
		{ param = "pitch", label = "PITCH" },
		{ param = "y", label = "Y" },
		{ param = "roll", label = "ROLL" },
	}
	for i, control in ipairs(controls) do
		local row = math.floor((i - 1) / 2)
		local col = (i - 1) % 2
		local xBase = 20 + (col * 280)
		local yPos = yStart - (row * 45)
		-- Label
		local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("TOPLEFT", xBase, yPos)
		label:SetText(control.label .. ":")
		-- Minus button
		local minusBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		minusBtn:SetSize(50, buttonHeight)
		minusBtn:SetPoint("TOPLEFT", xBase + 70, yPos + 3)
		minusBtn:SetText("-")
		minusBtn:SetScript("OnClick", function()
			self:AdjustCamera(control.param, -1)
		end)
		-- Plus button
		local plusBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		plusBtn:SetSize(50, buttonHeight)
		plusBtn:SetPoint("LEFT", minusBtn, "RIGHT", 5, 0)
		plusBtn:SetText("+")
		plusBtn:SetScript("OnClick", function()
			self:AdjustCamera(control.param, 1)
		end)
	end
end

function FamilyCameraCalibrator:SetStepSize(size)
	self.currentStepSize = size
	addon:DebugUI("Step size set to: " .. size .. " (" .. STEP_SIZES[size] .. ")")
end

function FamilyCameraCalibrator:UpdateStepButtons()
	if not self.mainFrame or not self.mainFrame.stepButtons then return end

	for size, btn in pairs(self.mainFrame.stepButtons) do
		if size == self.currentStepSize then
			btn:LockHighlight()
		else
			btn:UnlockHighlight()
		end
	end
end

function FamilyCameraCalibrator:AdjustCamera(param, direction)
	local step = STEP_SIZES[self.currentStepSize] * direction
	self.currentCamera[param] = self.currentCamera[param] + step
	self:ApplyCameraSettings()
	self:UpdateValueDisplay()
	addon:DebugUI(string.format("Adjusted %s by %.2f (now %.2f)", param, step, self.currentCamera[param]))
end

function FamilyCameraCalibrator:ApplyCameraSettings()
	if not self.mainFrame or not self.mainFrame.modelScene then return end

	local cam = self.currentCamera
	self.mainFrame.modelScene:SetCameraPosition(cam.x, cam.y, cam.z)
	self.mainFrame.modelScene:SetCameraOrientationByYawPitchRoll(cam.yaw, cam.pitch, cam.roll)
end

-- ============================================================================
-- ACTION BUTTONS
-- ============================================================================
function FamilyCameraCalibrator:CreateActionButtons(parent)
	-- Reset button
	local resetBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	resetBtn:SetSize(120, 25)
	resetBtn:SetPoint("BOTTOMLEFT", 20, 15)
	resetBtn:SetText("Reset to Default")
	resetBtn:SetScript("OnClick", function()
		self:ResetToDefault()
	end)
	-- Load Preset button
	local loadPresetBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	loadPresetBtn:SetSize(120, 25)
	loadPresetBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
	loadPresetBtn:SetText("Load Preset")
	loadPresetBtn:SetScript("OnClick", function()
		self:LoadPreset()
	end)
	-- Copy values button
	local copyBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	copyBtn:SetSize(120, 25)
	copyBtn:SetPoint("LEFT", loadPresetBtn, "RIGHT", 10, 0)
	copyBtn:SetText("Copy Values")
	copyBtn:SetScript("OnClick", function()
		self:CopyValues()
	end)
	-- Save button
	local saveBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	saveBtn:SetSize(120, 25)
	saveBtn:SetPoint("BOTTOMRIGHT", -20, 15)
	saveBtn:SetText("Save Settings")
	saveBtn:SetScript("OnClick", function()
		self:SaveSettings()
	end)
end

function FamilyCameraCalibrator:ResetToDefault()
	for param, value in pairs(addon.DefaultCameraSettings) do
		self.currentCamera[param] = value
	end

	self:ApplyCameraSettings()
	self:UpdateValueDisplay()
	addon:Print("Camera reset to default settings")
end

function FamilyCameraCalibrator:LoadPreset()
	if not self.currentGroup then
		addon:Print("No group selected")
		return
	end

	-- Get preset camera settings for current group using inheritance
	local preset = addon.MountBrowser:GetCameraSettings(self.currentGroup, self.currentType)
	-- Check if we actually found a preset (not just the default)
	if preset == addon.DefaultCameraSettings then
		addon:Print("No preset found for " .. self.currentGroup .. " - would use defaults")
		return
	end

	-- Load the preset values
	for param, value in pairs(preset) do
		self.currentCamera[param] = value
	end

	self:ApplyCameraSettings()
	self:UpdateValueDisplay()
	addon:Print("Loaded preset for " .. self.currentGroup)
end

function FamilyCameraCalibrator:CopyValues()
	if not self.currentGroup then
		addon:Print("No group selected")
		return
	end

	local cam = self.currentCamera
	local output = string.format(
		'["%s"] = { x = %.2f, y = %.2f, z = %.2f, yaw = %.4f, pitch = %.4f, roll = %.4f },',
		self.currentGroup, cam.x, cam.y, cam.z, cam.yaw, cam.pitch, cam.roll
	)
	-- Print to chat so user can copy it
	print(output)
end

function FamilyCameraCalibrator:SaveSettings()
	if not self.currentGroup or not self.currentType then
		addon:Print("No group selected")
		return
	end

	-- Save to CameraOverrides table
	local groupKey = self.currentGroup
	local cam = self.currentCamera
	-- Create a new table with the current camera settings
	addon.CameraOverrides[groupKey] = {
		x = cam.x,
		y = cam.y,
		z = cam.z,
		yaw = cam.yaw,
		pitch = cam.pitch,
		roll = cam.roll,
	}
	addon:Print(string.format("Camera settings saved for %s (%s)", groupKey, self.currentType))
	-- Also copy values to chat for backup/sharing
	self:CopyValues()
end

-- ============================================================================
-- CAMERA SETTINGS MANAGEMENT
-- ============================================================================
function FamilyCameraCalibrator:LoadCameraSettings(groupKey, groupType)
	-- Load preset camera settings for this group (with inheritance)
	local preset = addon.MountBrowser:GetCameraSettings(groupKey, groupType)
	-- Load the preset values (could be from override or default)
	for param, value in pairs(preset) do
		self.currentCamera[param] = value
	end

	self:UpdateValueDisplay()
	-- Inform user if a preset was found
	if preset ~= addon.DefaultCameraSettings then
		addon:DebugUI("Loaded preset for " .. groupKey)
	else
		addon:DebugUI("Using default camera for " .. groupKey)
	end
end

-- ============================================================================
-- PUBLIC INTERFACE
-- ============================================================================
function FamilyCameraCalibrator:Show()
	if not self.initialized then
		self:Initialize()
	end

	if not self.mainFrame then return end

	self.mainFrame:Show()
end

function FamilyCameraCalibrator:Hide()
	if self.mainFrame then
		self.mainFrame:Hide()
	end
end

function FamilyCameraCalibrator:Toggle()
	if self.mainFrame and self.mainFrame:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end
