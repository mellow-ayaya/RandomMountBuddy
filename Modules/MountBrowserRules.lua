-- MountBrowserRules.lua
-- Zone-specific rules tab for Mount Browser
local addonName, addon = ...
-- Module for Rules tab functionality
local Rules = {}
addon.MountBrowserRules = Rules
-- Create the Rules tab frame and all its UI elements
function Rules:CreateRulesFrame(parentFrame, mountBrowser)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetPoint("TOPLEFT", parentFrame.scrollFrame, "TOPLEFT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", parentFrame.scrollFrame, "BOTTOMRIGHT", 0, 0)
	frame:Hide() -- Hidden by default
	-- Create a scrollable content frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 10, -10)
	scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild:SetWidth(scrollFrame:GetWidth())
	scrollChild:SetHeight(2000) -- Will be adjusted as we add content
	-- Temporary state for new rule
	-- Supports both single condition (backward compatible) and multiple conditions
	local newRule = {
		-- Multiple conditions support (new format)
		conditions = {
			{
				ruleType = "keybind", -- First condition defaults to keybind
				-- Condition-specific fields will be added dynamically
			},
		},
		-- Action (shared between all conditions)
		actionType = "specific", -- "specific" or "pool"
		mountIDs = "",
		poolName = "flying",
	}
	-- Add a header
	local rulesHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	rulesHeader:SetPoint("TOPLEFT", 20, -10)
	rulesHeader:SetText("About Rules")
	rulesHeader:SetTextColor(1, 0.82, 0) -- Gold color to match other headers
	-- Then the description below it
	local descText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	descText:SetPoint("TOPLEFT", 20, -35) -- 25px below header
	descText:SetPoint("TOPRIGHT", -40, -35)
	descText:SetText(
		"|cffffffffRules override the addon's fancy summoning system, disregarding the weight and favorite status. Instead, a random useable mount is summoned from your specified list using WoW's default logic.|r " ..
		"|cff00ff00New:|r |cffffffffthe Improved Randomness setting now works with rules that use mount pools and rules with 5 or more specific mount IDs.|r" ..
		"\n|cff9d9d9dExample uses: Summon Chauffeured mounts below level 10. Summon passenger mounts when grouped with friends. Bind utility mounts to one of the 4 summoning RandomMountBuddy keybinds (e.g., Grand Expedition Yak on keybind 2).|r")
	descText:SetJustifyH("LEFT")
	descText:SetWordWrap(true)
	-- Create a two-column layout at the top
	local topLeftContainer = CreateFrame("Frame", nil, scrollChild)
	topLeftContainer:SetPoint("TOPLEFT", 20, -90)
	topLeftContainer:SetWidth((scrollFrame:GetWidth() - 60) / 2)
	topLeftContainer:SetHeight(200)
	local topRightContainer = CreateFrame("Frame", nil, scrollChild)
	topRightContainer:SetPoint("TOPLEFT", topLeftContainer, "TOPRIGHT", 200, 0)
	topRightContainer:SetPoint("TOPRIGHT", -40, -90)
	topRightContainer:SetHeight(200)
	local yOffset = -320 -- Start below the two-column section
	-- Helper to create section headers
	local function CreateHeader(text, color)
		color = color or { r = 1, g = 0.82, b = 0 } -- Gold default
		local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		header:SetPoint("TOPLEFT", 20, yOffset)
		header:SetText(text)
		header:SetTextColor(color.r, color.g, color.b)
		yOffset = yOffset - 35
		return header
	end

	-- Helper to create dropdown using UIDropDownMenu
	local function CreateDropDown(parent, width, anchorPoint, relativeFrame, relativePoint, xOff, yOff)
		local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_SetWidth(dropdown, width)
		dropdown:SetPoint(anchorPoint, relativeFrame, relativePoint, xOff, yOff)
		return dropdown
	end

	-- Current Location Info (Top Right)
	local locHeader = topRightContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	locHeader:SetPoint("TOPLEFT", 0, 0)
	locHeader:SetText("Current Location Information")
	locHeader:SetTextColor(1, 0.82, 0)
	local locationText = topRightContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	locationText:SetPoint("TOPLEFT", 0, -30)
	locationText:SetPoint("RIGHT", 0, 0)
	locationText:SetJustifyH("LEFT")
	locationText:SetWordWrap(true)
	locationText:SetSpacing(2)
	-- Update location info
	local function UpdateLocationInfo()
		if addon.MountRules and addon.MountRules.GetCurrentLocationInfo then
			local info = addon.MountRules:GetCurrentLocationInfo()
			if info then
				local text = "\n"
				if info.mapName then
					text = text .. "Map: " .. info.mapName .. " (ID: " .. info.mapID .. ")\n"
				end

				if info.parentName then
					text = text .. "Parent Zone: " .. info.parentName .. " (ID: " .. info.parentID .. ")\n"
				end

				if info.instanceName then
					text = text .. "Instance: " .. info.instanceName .. " (ID: " .. info.instanceID .. ")\n"
					text = text .. "Instance Type: " .. info.instanceTypeName
				end

				if text == "" then
					text = "Not in a valid location"
				end

				locationText:SetText(text)
			else
				locationText:SetText("Location information unavailable")
			end
		else
			locationText:SetText("Location system not initialized")
		end
	end

	UpdateLocationInfo()
	-- Refresh button at bottom of page
	local refreshBtn = CreateFrame("Button", nil, topRightContainer, "UIPanelButtonTemplate")
	refreshBtn:SetPoint("TOP", topRightContainer, "BOTTOM", -10, 5)
	refreshBtn:SetSize(300, 30)
	refreshBtn:SetText("Refresh Location Information")
	refreshBtn:SetScript("OnClick", function()
		UpdateLocationInfo()
	end)
	yOffset = yOffset - 10
	-- Existing Rules Section
	CreateHeader("Existing Rules")
	local rulesContainer = CreateFrame("Frame", nil, scrollChild)
	rulesContainer:SetPoint("TOPLEFT", 20, yOffset + 10)
	rulesContainer:SetPoint("TOPRIGHT", -25, yOffset + 10)
	rulesContainer:SetHeight(800)
	-- Function to refresh rules display
	local function RefreshRulesList()
		-- Clear existing rule frames
		if rulesContainer.ruleFrames then
			for _, rf in ipairs(rulesContainer.ruleFrames) do
				rf:Hide()
				rf:SetParent(nil)
			end
		end

		rulesContainer.ruleFrames = {}
		if not addon.MountRules or not addon.MountRules.GetAllRules then
			return
		end

		local rules = addon.MountRules:GetAllRules()
		if not rules or #rules == 0 then
			local noRules = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			noRules:SetPoint("TOPLEFT", rulesContainer, "TOPLEFT", 20, -10)
			noRules:SetText("No rules defined. Rules are checked from top to bottom - first matching rule wins.")
			noRules:SetTextColor(0.7, 0.7, 0.7)
			table.insert(rulesContainer.ruleFrames, noRules)
			return
		end

		-- Display each rule
		local ruleY = -5
		for i, rule in ipairs(rules) do
			local ruleFrame = CreateFrame("Frame", nil, rulesContainer, "BackdropTemplate")
			ruleFrame:SetPoint("TOPLEFT", 0, ruleY)
			ruleFrame:SetPoint("TOPRIGHT", 0, ruleY)
			-- Don't set initial height - will be calculated based on content
			ruleFrame:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8X8",
				edgeFile = "Interface\\Buttons\\WHITE8X8",
				edgeSize = 1,
			})
			ruleFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
			ruleFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
			-- Priority number
			local priority = ruleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
			priority:SetPoint("LEFT", 10, 0)
			priority:SetText("#" .. i)
			priority:SetTextColor(0.6, 0.6, 0.6)
			-- Get full rule description and split into conditions and action
			local fullDesc = ""
			if addon.MountRules.GetRuleDescription then
				fullDesc = addon.MountRules:GetRuleDescription(rule)
			else
				fullDesc = "Rule " .. rule.id
			end

			-- Split description to separate conditions from action
			-- Action line starts with "|cff00ff00Action:|r"
			local conditionText = ""
			local actionText = ""
			local lines = {}
			for line in fullDesc:gmatch("[^\n]+") do
				table.insert(lines, line)
			end

			-- Find where action starts
			local actionIndex = nil
			for i, line in ipairs(lines) do
				if line:match("|cff00ff00Action:|r") then
					actionIndex = i
					break
				end
			end

			-- Build condition text (all lines before action)
			if actionIndex then
				for i = 1, actionIndex - 1 do
					conditionText = conditionText .. lines[i]
					if i < actionIndex - 1 then
						conditionText = conditionText .. "\n"
					end
				end

				-- Build action text (action line and any after)
				for i = actionIndex, #lines do
					actionText = actionText .. lines[i]
					if i < #lines then
						actionText = actionText .. "\n"
					end
				end
			else
				-- No action found (shouldn't happen), show everything as condition
				conditionText = fullDesc
			end

			-- Split condition text into separate lines
			local conditionLines = {}
			for line in conditionText:gmatch("[^\n]+") do
				table.insert(conditionLines, line)
			end

			-- Create separate font strings for each condition line
			local conditionStrings = {}
			local numConditions = #conditionLines
			local currentY = 12 + ((numConditions - 1) * 10) -- Start higher for multi-condition rules
			for i, lineText in ipairs(conditionLines) do
				local condLine = ruleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				condLine:SetPoint("TOPLEFT", priority, "TOPRIGHT", 15, currentY)
				condLine:SetPoint("RIGHT", -160, currentY)
				condLine:SetJustifyH("LEFT")
				condLine:SetWordWrap(true)
				condLine:SetMaxLines(1) -- Each line can only be 1 line, will ellipse if too long
				condLine:SetNonSpaceWrap(false)
				condLine:SetText(lineText)
				table.insert(conditionStrings, condLine)
				-- Move down for next line
				currentY = currentY - 20 -- Fixed 20px spacing between lines
			end

			-- Calculate action Y position (below last condition)
			local actionY = currentY - 5 -- 5px gap after conditions
			-- Action text (below conditions)
			local actionDesc = ruleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			actionDesc:SetPoint("TOPLEFT", priority, "TOPRIGHT", 15, actionY)
			actionDesc:SetPoint("RIGHT", -160, actionY)
			actionDesc:SetJustifyH("LEFT")
			actionDesc:SetWordWrap(true)
			actionDesc:SetMaxLines(2) -- Action can wrap to 2 lines before ellipsing
			actionDesc:SetNonSpaceWrap(false)
			actionDesc:SetText(actionText)
			-- Simple height calculation: base height + 20px per additional condition
			local totalHeight = 70 + (numConditions - 1) * 20
			ruleFrame:SetHeight(totalHeight)
			-- Delete button
			local deleteBtn = CreateFrame("Button", nil, ruleFrame, "UIPanelButtonTemplate")
			deleteBtn:SetPoint("RIGHT", -10, 0)
			deleteBtn:SetSize(80, 22)
			deleteBtn:SetText("Delete")
			deleteBtn:SetScript("OnClick", function()
				if addon.MountRules and addon.MountRules.RemoveRule then
					addon.MountRules:RemoveRule(rule.id)
					RefreshRulesList()
					-- Refresh Interface Options panel
					if addon.MountRules.PopulateZoneSpecificUI then
						addon.MountRules:PopulateZoneSpecificUI()
					end
				end
			end)
			-- Move up button (always visible, left column)
			local upBtn = CreateFrame("Button", nil, ruleFrame, "UIPanelButtonTemplate")
			upBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -40, 0)              -- Left column position
			upBtn:SetSize(30, 22)
			upBtn:SetText("|TInterface\\BUTTONS\\Arrow-Up-Up.blp:16:16:1:0|t") -- Up button
			-- Disable if first rule
			if i == 1 then
				upBtn:Disable()
			else
				upBtn:Enable()
			end

			upBtn:SetScript("OnClick", function()
				if addon.MountRules and addon.MountRules.MoveRuleUp then
					addon.MountRules:MoveRuleUp(rule.id)
					RefreshRulesList()
					-- Refresh Interface Options panel
					if addon.MountRules.PopulateZoneSpecificUI then
						addon.MountRules:PopulateZoneSpecificUI()
					end
				end
			end)
			-- Move down button (always visible, right column)
			local downBtn = CreateFrame("Button", nil, ruleFrame, "UIPanelButtonTemplate")
			downBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -5, 0)                  -- Right column position
			downBtn:SetSize(30, 22)
			downBtn:SetText("|TInterface\\BUTTONS\\Arrow-Down-Up.blp:16:16:2:-6|t") -- Down button
			-- Disable if last rule
			if i == #rules then
				downBtn:Disable()
			else
				downBtn:Enable()
			end

			downBtn:SetScript("OnClick", function()
				if addon.MountRules and addon.MountRules.MoveRuleDown then
					addon.MountRules:MoveRuleDown(rule.id)
					RefreshRulesList()
					-- Refresh Interface Options panel
					if addon.MountRules.PopulateZoneSpecificUI then
						addon.MountRules:PopulateZoneSpecificUI()
					end
				end
			end)
			table.insert(rulesContainer.ruleFrames, ruleFrame)
			ruleY = ruleY - (totalHeight + 5) -- Use calculated height + small spacing
		end

		rulesContainer:SetHeight(math.max(400, math.abs(ruleY)))
	end

	RefreshRulesList()
	yOffset = yOffset - 420
	-- Add New Rule Section (Top Left) - with full form
	local addNewHeader = topLeftContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	addNewHeader:SetPoint("TOPLEFT", 0, 0)
	addNewHeader:SetText("Add New Rule")
	addNewHeader:SetTextColor(1, 0.82, 0)
	-- Container for the form
	local addRuleContainer = CreateFrame("Frame", nil, topLeftContainer)
	addRuleContainer:SetPoint("TOPLEFT", 0, -30)
	addRuleContainer:SetPoint("TOPRIGHT", 0, -30)
	addRuleContainer:SetHeight(160)
	local yOffset = 0
	-- Forward declaration for RebuildAddRuleUI
	local RebuildAddRuleUI
	-- Helper function to create dropdowns
	local function CreateDropDown(parent, width, point, relativeTo, relativePoint, x, y)
		local dropdown = CreateFrame("Frame", "RMBRulesDropdown" .. math.random(1000000), parent, "UIDropDownMenuTemplate")
		dropdown:SetPoint(point, relativeTo, relativePoint, x, y)
		UIDropDownMenu_SetWidth(dropdown, width)
		return dropdown
	end

	-- CONDITIONS SECTION HEADER
	local conditionsHeader = addRuleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	conditionsHeader:SetPoint("TOPLEFT", 0, yOffset)
	-- conditionsHeader:SetText("Conditions")
	-- conditionsHeader:SetTextColor(0.7, 0.7, 1)
	-- yOffset = yOffset - 25
	-- Scrollable container for conditions
	local conditionsScrollFrame = CreateFrame("ScrollFrame", nil, addRuleContainer, "UIPanelScrollFrameTemplate")
	conditionsScrollFrame:SetPoint("TOPLEFT", 0, yOffset)
	conditionsScrollFrame:SetPoint("TOPRIGHT", -20, yOffset)
	conditionsScrollFrame:SetHeight(120) -- Fixed visible height
	-- Scroll bar configuration
	local scrollBar = conditionsScrollFrame.ScrollBar or _G[conditionsScrollFrame:GetName() .. "ScrollBar"]
	if scrollBar then
		-- Adjust scroll bar position (offset from right edge)
		scrollBar:ClearAllPoints()
		scrollBar:SetPoint("TOPRIGHT", conditionsScrollFrame, "TOPRIGHT", -2, -34)
		scrollBar:SetPoint("BOTTOMRIGHT", conditionsScrollFrame, "BOTTOMRIGHT", -2, 16)
		-- Hide initially - will be shown if content exceeds visible height
		scrollBar:Hide()
		-- Adjust scroll step sizes
		conditionsScrollFrame:SetScript("OnMouseWheel", function(self, delta)
			local current = self:GetVerticalScroll()
			local maxScroll = self:GetVerticalScrollRange()
			local step = 30 -- Pixels to scroll per wheel tick
			if delta > 0 then -- Scroll up
				self:SetVerticalScroll(math.max(0, current - step))
			else           -- Scroll down
				self:SetVerticalScroll(math.min(maxScroll, current + step))
			end
		end)
	end

	-- Create scroll child (the actual container for condition rows)
	local conditionsContainer = CreateFrame("Frame", nil, conditionsScrollFrame)
	conditionsScrollFrame:SetScrollChild(conditionsContainer)
	conditionsContainer:SetWidth(addRuleContainer:GetWidth() - 30)
	conditionsContainer:SetHeight(100)    -- Will be adjusted based on content
	conditionsContainer.conditionRows = {} -- Store condition row frames
	-- Function to rebuild condition rows
	local function RebuildConditionRows()
		-- Clear existing rows
		for _, row in ipairs(conditionsContainer.conditionRows) do
			row:Hide()
			row:SetParent(nil)
		end

		conditionsContainer.conditionRows = {}
		local rowY = 0
		-- Create a row for each condition
		for conditionIndex, condition in ipairs(newRule.conditions) do
			-- Condition row container
			local conditionRow = CreateFrame("Frame", nil, conditionsContainer)
			conditionRow:SetPoint("TOPLEFT", 0, rowY)
			conditionRow:SetPoint("TOPRIGHT", 0, rowY)
			conditionRow:SetHeight(60)
			conditionRow.elements = {} -- Track elements for cleanup
			conditionRow.conditionIndex = conditionIndex
			table.insert(conditionsContainer.conditionRows, conditionRow)
			-- Condition type label
			local ruleTypeLabel = conditionRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			ruleTypeLabel:SetPoint("TOPLEFT", 0, 0)
			if conditionIndex == 1 then
				ruleTypeLabel:SetText("Condition Type:")
			else
				ruleTypeLabel:SetText("     ") -- Indent for additional conditions
			end

			table.insert(conditionRow.elements, ruleTypeLabel)
			-- Condition type dropdown
			local ruleTypeDropdown = CreateDropDown(conditionRow, 200, "TOPLEFT", conditionRow, "TOPLEFT", -15, -15)
			-- Set display text based on condition type
			local displayText = "Select..."
			if condition.ruleType == "keybind" then
				displayText = "Specific Keybind"
			elseif condition.ruleType == "location" then
				displayText = "Map/Parent Zone/Instance ID"
			elseif condition.ruleType == "instance_type" then
				displayText = "Instance Type"
			elseif condition.ruleType == "character_level" then
				displayText = "Character Level"
			elseif condition.ruleType == "group_state" then
				displayText = "Group Status"
			elseif condition.ruleType == "social" then
				displayText = "In a Group with.."
			elseif condition.ruleType == "preset" then
				displayText = "Quick Presets"
			end

			UIDropDownMenu_SetText(ruleTypeDropdown, displayText)
			UIDropDownMenu_Initialize(ruleTypeDropdown, function(self, level)
				local info1 = UIDropDownMenu_CreateInfo()
				info1.text = "Specific Keybind"
				info1.value = "keybind"
				info1.func = function()
					condition.ruleType = "keybind"
					UIDropDownMenu_SetText(ruleTypeDropdown, info1.text)
					RebuildAddRuleUI()
				end
				info1.checked = (condition.ruleType == "keybind")
				UIDropDownMenu_AddButton(info1)
				local info2 = UIDropDownMenu_CreateInfo()
				info2.text = "Map/Parent Zone/Instance ID"
				info2.value = "location"
				info2.func = function()
					condition.ruleType = "location"
					UIDropDownMenu_SetText(ruleTypeDropdown, info2.text)
					RebuildAddRuleUI()
				end
				info2.checked = (condition.ruleType == "location")
				UIDropDownMenu_AddButton(info2)
				local info3 = UIDropDownMenu_CreateInfo()
				info3.text = "Instance Type"
				info3.value = "instance_type"
				info3.func = function()
					condition.ruleType = "instance_type"
					UIDropDownMenu_SetText(ruleTypeDropdown, info3.text)
					RebuildAddRuleUI()
				end
				info3.checked = (condition.ruleType == "instance_type")
				UIDropDownMenu_AddButton(info3)
				local info4 = UIDropDownMenu_CreateInfo()
				info4.text = "Character Level"
				info4.value = "character_level"
				info4.func = function()
					condition.ruleType = "character_level"
					UIDropDownMenu_SetText(ruleTypeDropdown, info4.text)
					RebuildAddRuleUI()
				end
				info4.checked = (condition.ruleType == "character_level")
				UIDropDownMenu_AddButton(info4)
				local info5 = UIDropDownMenu_CreateInfo()
				info5.text = "Group Status"
				info5.value = "group_state"
				info5.func = function()
					condition.ruleType = "group_state"
					UIDropDownMenu_SetText(ruleTypeDropdown, info5.text)
					RebuildAddRuleUI()
				end
				info5.checked = (condition.ruleType == "group_state")
				UIDropDownMenu_AddButton(info5)
				local info6 = UIDropDownMenu_CreateInfo()
				info6.text = "In a Group with.."
				info6.value = "social"
				info6.func = function()
					condition.ruleType = "social"
					UIDropDownMenu_SetText(ruleTypeDropdown, info6.text)
					RebuildAddRuleUI()
				end
				info6.checked = (condition.ruleType == "social")
				UIDropDownMenu_AddButton(info6)
				-- Only show Quick Presets option for the first condition
				-- (presets set both condition and action, so additional conditions don't make sense)
				if conditionIndex == 1 then
					local info7 = UIDropDownMenu_CreateInfo()
					info7.text = "Quick Presets"
					info7.value = "preset"
					info7.func = function()
						condition.ruleType = "preset"
						UIDropDownMenu_SetText(ruleTypeDropdown, info7.text)
						RebuildAddRuleUI()
					end
					info7.checked = (condition.ruleType == "preset")
					UIDropDownMenu_AddButton(info7)
				end
			end)
			table.insert(conditionRow.elements, ruleTypeDropdown)
			-- Conditional fields container for this condition (positioned to the RIGHT)
			local conditionalFields = CreateFrame("Frame", nil, conditionRow)
			if conditionIndex > 1 then
				conditionalFields:SetPoint("TOPLEFT", 230, 0)
			else
				conditionalFields:SetPoint("TOPLEFT", 230, 0) -- Align with label level
			end

			conditionalFields:SetPoint("TOPRIGHT", 0, 0)
			conditionalFields:SetHeight(40)
			conditionalFields.elements = {}
			conditionRow.conditionalFields = conditionalFields
			-- Remove button for conditions 2+ (positioned on the right)
			if conditionIndex > 1 then
				local removeBtn = CreateFrame("Button", nil, conditionRow, "UIPanelCloseButton")
				removeBtn:SetSize(22, 22)
				removeBtn:SetPoint("TOPLEFT", 455, -23)
				removeBtn:SetScript("OnClick", function()
					table.remove(newRule.conditions, conditionIndex)
					RebuildConditionRows()
					RebuildAddRuleUI()
				end)
				table.insert(conditionRow.elements, removeBtn)
			end

			rowY = rowY - 45
			-- Add "AND" label between conditions
			if conditionIndex < #newRule.conditions then
				local andLabel = conditionsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				andLabel:SetPoint("TOPLEFT", 0, rowY)
				andLabel:SetText("And...")
				table.insert(conditionsContainer.conditionRows, andLabel) -- Track for cleanup
				rowY = rowY
			end
		end

		-- Add Condition button (only show if < 4 conditions)
		if #newRule.conditions < 4 then
			local addConditionBtn = CreateFrame("Button", nil, conditionsContainer, "UIPanelButtonTemplate")
			addConditionBtn:SetPoint("TOPLEFT", 3, rowY)
			addConditionBtn:SetSize(445, 25)
			addConditionBtn:SetText("Add another condition")
			addConditionBtn:SetScript("OnClick", function()
				table.insert(newRule.conditions, {
					-- No default ruleType - will show "Select..."
				})
				RebuildConditionRows()
				RebuildAddRuleUI()
			end)
			table.insert(conditionsContainer.conditionRows, addConditionBtn)
			rowY = rowY - 30
		end

		-- Update scroll child height based on content
		local contentHeight = math.abs(rowY) + 10
		conditionsContainer:SetHeight(contentHeight)
		-- Show/hide scrollbar based on whether content exceeds visible height
		local scrollBar = conditionsScrollFrame.ScrollBar or _G[conditionsScrollFrame:GetName() .. "ScrollBar"]
		if scrollBar then
			if contentHeight > conditionsScrollFrame:GetHeight() then
				scrollBar:Show()
			else
				scrollBar:Hide()
			end
		end
	end

	-- Initial build
	RebuildConditionRows()
	yOffset = yOffset - 120 -- Move past conditions scroll frame (120px height + 10px padding)
	-- ACTION SECTION HEADER
	local actionHeader = addRuleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	actionHeader:SetPoint("TOPLEFT", 0, yOffset)
	-- actionHeader:SetText("Action")
	-- actionHeader:SetTextColor(0.7, 1, 0.7)
	-- yOffset = yOffset - 25
	-- Container for action UI
	local actionContainer = CreateFrame("Frame", nil, addRuleContainer)
	actionContainer:SetPoint("TOPLEFT", 0, yOffset)
	actionContainer:SetPoint("TOPRIGHT", 0, yOffset)
	actionContainer:SetHeight(100)
	local actionY = 0
	local actionTypeLabel = actionContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	actionTypeLabel:SetPoint("TOPLEFT", actionContainer, "TOPLEFT", 0, actionY)
	actionTypeLabel:SetText("Action Type:")
	actionY = actionY - 15
	local actionTypeDropdown = CreateDropDown(actionContainer, 200, "TOPLEFT", actionContainer, "TOPLEFT", -15, actionY)
	UIDropDownMenu_SetText(actionTypeDropdown, "Specific Mount(s)")
	UIDropDownMenu_Initialize(actionTypeDropdown, function(self, level)
		local info1 = UIDropDownMenu_CreateInfo()
		info1.text = "Specific Mount(s)"
		info1.value = "specific"
		info1.func = function()
			newRule.actionType = "specific"
			UIDropDownMenu_SetText(actionTypeDropdown, info1.text)
			RebuildAddRuleUI()
		end
		info1.checked = (newRule.actionType == "specific")
		UIDropDownMenu_AddButton(info1)
		local info2 = UIDropDownMenu_CreateInfo()
		info2.text = "Pool"
		info2.value = "pool"
		info2.func = function()
			newRule.actionType = "pool"
			UIDropDownMenu_SetText(actionTypeDropdown, info2.text)
			RebuildAddRuleUI()
		end
		info2.checked = (newRule.actionType == "pool")
		UIDropDownMenu_AddButton(info2)
	end)
	-- Conditional fields container for action-specific settings (positioned to the RIGHT of dropdown)
	local conditionalFieldsAction = CreateFrame("Frame", nil, actionContainer)
	conditionalFieldsAction:SetPoint("TOPLEFT", actionContainer, "TOPLEFT", 200, 0) -- Align with label level
	conditionalFieldsAction:SetPoint("TOPRIGHT", actionContainer, "TOPRIGHT", 0, 0)
	conditionalFieldsAction:SetHeight(60)
	-- Helper function to build condition-specific fields
	local function BuildConditionFields(conditionalFields, condition)
		local fieldX = 0 -- Track horizontal position
		-- KEYBIND FIELDS
		if condition.ruleType == "keybind" then
			local keybindLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			keybindLabel:SetPoint("TOPLEFT", fieldX, 0)
			keybindLabel:SetText("Keybind:")
			table.insert(conditionalFields.elements, keybindLabel)
			local keybindDropdown = CreateDropDown(conditionalFields, 200, "TOPLEFT", conditionalFields, "TOPLEFT", fieldX - 15,
				-15)
			local keybindText = "Select..."
			if condition.keybindNumber then
				local keybindNames = {
					[1] = "RandomMountBuddy Summon",
					[2] = "RandomMountBuddy Summon 2",
					[3] = "RandomMountBuddy Summon 3",
					[4] = "RandomMountBuddy Summon 4",
				}
				keybindText = keybindNames[condition.keybindNumber] or "Select..."
			end

			UIDropDownMenu_SetText(keybindDropdown, keybindText)
			UIDropDownMenu_Initialize(keybindDropdown, function(self, level)
				local keybinds = {
					{ value = 1, text = "RandomMountBuddy Summon" },
					{ value = 2, text = "RandomMountBuddy Summon 2" },
					{ value = 3, text = "RandomMountBuddy Summon 3" },
					{ value = 4, text = "RandomMountBuddy Summon 4" },
				}
				for _, kb in ipairs(keybinds) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = kb.text
					info.value = kb.value
					info.func = function()
						condition.keybindNumber = kb.value
						UIDropDownMenu_SetText(keybindDropdown, kb.text)
					end
					info.checked = (condition.keybindNumber == kb.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, keybindLabel)
			table.insert(conditionalFields.elements, keybindDropdown)
			-- LOCATION-BASED FIELDS
		elseif condition.ruleType == "location" then
			-- ID Type dropdown
			local idTypeLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			idTypeLabel:SetPoint("TOPLEFT", fieldX, 0)
			idTypeLabel:SetText("ID Type:")
			table.insert(conditionalFields.elements, idTypeLabel)
			local idTypeDropdown = CreateDropDown(conditionalFields, 95, "TOPLEFT", conditionalFields, "TOPLEFT", fieldX - 15,
				-15)
			UIDropDownMenu_SetText(idTypeDropdown, "Select...")
			UIDropDownMenu_Initialize(idTypeDropdown, function(self, level)
				local info1 = UIDropDownMenu_CreateInfo()
				info1.text = "Map ID"
				info1.value = "mapid"
				info1.func = function()
					condition.locationType = "mapid"
					UIDropDownMenu_SetText(idTypeDropdown, info1.text)
				end
				info1.checked = (condition.locationType == "mapid")
				UIDropDownMenu_AddButton(info1)
				local info2 = UIDropDownMenu_CreateInfo()
				info2.text = "Parent Zone ID"
				info2.value = "parentzone"
				info2.func = function()
					condition.locationType = "parentzone"
					UIDropDownMenu_SetText(idTypeDropdown, info2.text)
				end
				info2.checked = (condition.locationType == "parentzone")
				UIDropDownMenu_AddButton(info2)
				local info3 = UIDropDownMenu_CreateInfo()
				info3.text = "Instance ID"
				info3.value = "instanceid"
				info3.func = function()
					condition.locationType = "instanceid"
					UIDropDownMenu_SetText(idTypeDropdown, info3.text)
				end
				info3.checked = (condition.locationType == "instanceid")
				UIDropDownMenu_AddButton(info3)
			end)
			table.insert(conditionalFields.elements, idTypeDropdown)
			-- Update display text
			if condition.locationType == "mapid" then
				UIDropDownMenu_SetText(idTypeDropdown, "Map ID")
			elseif condition.locationType == "parentzone" then
				UIDropDownMenu_SetText(idTypeDropdown, "Parent Zone ID")
			elseif condition.locationType == "instanceid" then
				UIDropDownMenu_SetText(idTypeDropdown, "Instance ID")
			end

			fieldX = fieldX + 120
			-- Location ID input
			local locationIDLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			locationIDLabel:SetPoint("TOPLEFT", fieldX, 0)
			locationIDLabel:SetText("Location ID(s):")
			table.insert(conditionalFields.elements, locationIDLabel)
			local locationIDBox = CreateFrame("EditBox", nil, conditionalFields, "InputBoxTemplate")
			locationIDBox:SetSize(95, 20)
			locationIDBox:SetPoint("TOPLEFT", fieldX + 3, -22)
			locationIDBox:SetAutoFocus(false)
			locationIDBox:SetMaxLetters(50)
			locationIDBox:SetText(condition.locationID or "")
			locationIDBox:SetScript("OnTextChanged", function(self)
				condition.locationID = self:GetText()
			end)
			table.insert(conditionalFields.elements, locationIDBox)
			-- INSTANCE TYPE FIELDS
		elseif condition.ruleType == "instance_type" then
			local instanceTypeLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			instanceTypeLabel:SetPoint("TOPLEFT", fieldX, 0)
			instanceTypeLabel:SetText("Instance Type:")
			table.insert(conditionalFields.elements, instanceTypeLabel)
			local instanceTypeDropdown = CreateDropDown(conditionalFields, 200, "TOPLEFT", conditionalFields, "TOPLEFT",
				fieldX - 15, -15)
			UIDropDownMenu_SetText(instanceTypeDropdown, "Select...")
			UIDropDownMenu_Initialize(instanceTypeDropdown, function(self, level)
				local types = {
					{ value = 1, text = "Normal Dungeon" },
					{ value = 2, text = "Heroic Dungeon" },
					{ value = 23, text = "Mythic Dungeon" },
					{ value = 8, text = "Mythic+ Dungeon" },
					{ value = 14, text = "Normal Raid" },
					{ value = 15, text = "Heroic Raid" },
					{ value = 16, text = "Mythic Raid" },
				}
				for _, iType in ipairs(types) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = iType.text
					info.value = iType.value
					info.func = function()
						condition.instanceType = iType.value
						condition.instanceTypeName = iType.text
						UIDropDownMenu_SetText(instanceTypeDropdown, iType.text)
					end
					info.checked = (condition.instanceType == iType.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, instanceTypeLabel)
			table.insert(conditionalFields.elements, instanceTypeDropdown)
			-- Set display text if value is already set
			if condition.instanceType then
				local typeNames = {
					[1] = "Normal Dungeon",
					[2] = "Heroic Dungeon",
					[23] = "Mythic Dungeon",
					[8] = "Mythic+ Dungeon",
					[14] = "Normal Raid",
					[15] = "Heroic Raid",
					[16] = "Mythic Raid",
				}
				UIDropDownMenu_SetText(instanceTypeDropdown, typeNames[condition.instanceType] or "Select...")
			end

			-- CHARACTER LEVEL FIELDS
		elseif condition.ruleType == "character_level" then
			local operatorLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			operatorLabel:SetPoint("TOPLEFT", fieldX, 0)
			operatorLabel:SetText("Operator:")
			table.insert(conditionalFields.elements, operatorLabel)
			local operatorDropdown = CreateDropDown(conditionalFields, 80, "TOPLEFT", conditionalFields, "TOPLEFT", fieldX - 15,
				-15)
			UIDropDownMenu_SetText(operatorDropdown, "Select...")
			UIDropDownMenu_Initialize(operatorDropdown, function(self, level)
				local operators = {
					{ value = ">=", text = ">=" },
					{ value = "<=", text = "<=" },
					{ value = ">", text = ">" },
					{ value = "<", text = "<" },
					{ value = "==", text = "=" },
				}
				for _, op in ipairs(operators) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = op.text
					info.value = op.value
					info.func = function()
						condition.levelOperator = op.value
						UIDropDownMenu_SetText(operatorDropdown, op.text)
					end
					info.checked = (condition.levelOperator == op.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, operatorLabel)
			table.insert(conditionalFields.elements, operatorDropdown)
			-- Set display text if value is already set
			if condition.levelOperator then
				UIDropDownMenu_SetText(operatorDropdown, condition.levelOperator)
			end

			fieldX = fieldX + 100
			-- Level input
			local levelLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			levelLabel:SetPoint("TOPLEFT", fieldX + 10, 0)
			levelLabel:SetText("Level:")
			table.insert(conditionalFields.elements, levelLabel)
			local levelBox = CreateFrame("EditBox", nil, conditionalFields, "InputBoxTemplate")
			levelBox:SetSize(105, 20)
			levelBox:SetPoint("TOPLEFT", fieldX + 12, -22)
			levelBox:SetAutoFocus(false)
			levelBox:SetMaxLetters(3)
			levelBox:SetNumeric(true)
			levelBox:SetText(condition.level or "")
			levelBox:SetScript("OnTextChanged", function(self)
				local value = tonumber(self:GetText())
				condition.level = value
			end)
			table.insert(conditionalFields.elements, levelBox)
			-- GROUP STATE FIELDS
		elseif condition.ruleType == "group_state" then
			local groupStateLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			groupStateLabel:SetPoint("TOPLEFT", fieldX, 0)
			groupStateLabel:SetText("Group State:")
			table.insert(conditionalFields.elements, groupStateLabel)
			local groupStateDropdown = CreateDropDown(conditionalFields, 200, "TOPLEFT", conditionalFields, "TOPLEFT",
				fieldX - 15, -15)
			UIDropDownMenu_SetText(groupStateDropdown, "Select...")
			UIDropDownMenu_Initialize(groupStateDropdown, function(self, level)
				local states = {
					{ value = "in_group", text = "In Group" },
					{ value = "not_in_group", text = "Not In Group" },
					{ value = "in_party", text = "In Party" },
					{ value = "not_in_party", text = "Not In Party" },
					{ value = "in_raid", text = "In Raid" },
					{ value = "not_in_raid", text = "Not In Raid" },
				}
				for _, state in ipairs(states) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = state.text
					info.value = state.value
					info.func = function()
						condition.groupState = state.value
						condition.groupStateName = state.text
						UIDropDownMenu_SetText(groupStateDropdown, state.text)
					end
					info.checked = (condition.groupState == state.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, groupStateLabel)
			table.insert(conditionalFields.elements, groupStateDropdown)
			-- Set display text if value is already set
			if condition.groupState then
				local stateNames = {
					in_group = "In Group",
					not_in_group = "Not In Group",
					in_party = "In Party",
					not_in_party = "Not In Party",
					in_raid = "In Raid",
					not_in_raid = "Not In Raid",
				}
				UIDropDownMenu_SetText(groupStateDropdown, stateNames[condition.groupState] or "Select...")
			end

			-- SOCIAL FIELDS
		elseif condition.ruleType == "social" then
			local socialTypeLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			socialTypeLabel:SetPoint("TOPLEFT", fieldX, 0)
			socialTypeLabel:SetText("In a Group with...")
			table.insert(conditionalFields.elements, socialTypeLabel)
			local socialTypeDropdown = CreateDropDown(conditionalFields, 200, "TOPLEFT", conditionalFields, "TOPLEFT",
				fieldX - 15, -15)
			UIDropDownMenu_SetText(socialTypeDropdown, "Select...")
			UIDropDownMenu_Initialize(socialTypeDropdown, function(self, level)
				local types = {
					{ value = "bnet_friend_in_party", text = "Any BNet Friend" },
					{ value = "friend_in_party", text = "Any In-Game Friend" },
					{ value = "guild_member_in_party", text = "Any Guild Member" },
					{ value = "character_whitelist", text = "Specific Player(s)" },
				}
				for _, sType in ipairs(types) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = sType.text
					info.value = sType.value
					info.func = function()
						condition.socialType = sType.value
						condition.socialTypeName = sType.text
						UIDropDownMenu_SetText(socialTypeDropdown, sType.text)
						RebuildAddRuleUI() -- Rebuild to show/hide character names field
					end
					info.checked = (condition.socialType == sType.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, socialTypeLabel)
			table.insert(conditionalFields.elements, socialTypeDropdown)
			-- Set display text if value is already set
			if condition.socialType then
				local typeNames = {
					bnet_friend_in_party = "BNet Friend",
					friend_in_party = "WoW Friend",
					guild_member_in_party = "Guild Member",
					character_whitelist = "Character Whitelist",
				}
				UIDropDownMenu_SetText(socialTypeDropdown, typeNames[condition.socialType] or "Select...")
			end

			-- Character names input (only for whitelist)
			if condition.socialType == "character_whitelist" then
				fieldX = fieldX + 180
				local characterNamesLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				characterNamesLabel:SetPoint("TOPLEFT", fieldX, 0)
				characterNamesLabel:SetText("Names:")
				table.insert(conditionalFields.elements, characterNamesLabel)
				local characterNamesBox = CreateFrame("EditBox", nil, conditionalFields, "InputBoxTemplate")
				characterNamesBox:SetSize(150, 20)
				characterNamesBox:SetPoint("TOPLEFT", fieldX + 8, -15)
				characterNamesBox:SetAutoFocus(false)
				characterNamesBox:SetMaxLetters(200)
				characterNamesBox:SetText(condition.characterNames or "")
				characterNamesBox:SetScript("OnTextChanged", function(self)
					condition.characterNames = self:GetText()
				end)
				table.insert(conditionalFields.elements, characterNamesBox)
			end

			-- PRESET FIELDS (Quick Presets)
		elseif condition.ruleType == "preset" then
			local presetLabel = conditionalFields:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			presetLabel:SetPoint("TOPLEFT", fieldX, 0)
			presetLabel:SetText("Preset:")
			table.insert(conditionalFields.elements, presetLabel)
			local presetDropdown = CreateDropDown(conditionalFields, 200, "TOPLEFT", conditionalFields, "TOPLEFT", fieldX - 15,
				-15)
			UIDropDownMenu_SetText(presetDropdown, "Select...")
			UIDropDownMenu_Initialize(presetDropdown, function(self, level)
				local presets = {
					{ value = "m_plus_portal", text = "M+ Portal Flying" },
					{ value = "class_hall", text = "Class Halls Flying" },
					{ value = "chauffeur", text = "Chauffeured <lvl 10" },
				}
				for _, preset in ipairs(presets) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = preset.text
					info.value = preset.value
					info.func = function()
						condition.presetType = preset.value
						UIDropDownMenu_SetText(presetDropdown, preset.text)
						-- Auto-populate preset values for both condition AND action
						if preset.value == "m_plus_portal" then
							-- Condition: Instance ID 2678 (M+ portal)
							condition.ruleType = "location"
							condition.locationID = "2678"
							condition.locationType = "instanceid"
							-- Action: Flying pool
							newRule.actionType = "pool"
							newRule.poolName = "flying"
						elseif preset.value == "class_hall" then
							-- Condition: Multiple instance IDs (class halls)
							condition.ruleType = "location"
							condition.locationID = "1519;1540;1514;1469;1479"
							condition.locationType = "instanceid"
							-- Action: Flying pool
							newRule.actionType = "pool"
							newRule.poolName = "flying"
						elseif preset.value == "chauffeur" then
							-- Condition: Character level < 10
							condition.ruleType = "character_level"
							condition.levelOperator = "<"
							condition.level = 10
							-- Action: Chauffeur mounts (IDs: 679=Chauffeured Mechano-Hog, 678=Chauffeured Chopper)
							newRule.actionType = "specific"
							newRule.mountIDs = "679;678"
						end

						RebuildAddRuleUI()
					end
					info.checked = (condition.presetType == preset.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFields.elements, presetLabel)
			table.insert(conditionalFields.elements, presetDropdown)
		end
	end

	-- Function to rebuild conditional UI
	RebuildAddRuleUI = function()
		-- Rebuild condition rows (this handles adding/removing conditions)
		-- Each row already has its own conditionalFields container
		-- Clear and rebuild fields for each condition row
		for _, conditionRow in ipairs(conditionsContainer.conditionRows) do
			if conditionRow.conditionalFields and conditionRow.conditionIndex then
				local conditionalFields = conditionRow.conditionalFields
				local condition = newRule.conditions[conditionRow.conditionIndex]
				-- Clear existing fields
				if conditionalFields.elements then
					for _, element in ipairs(conditionalFields.elements) do
						element:Hide()
						element:SetParent(nil)
					end
				end

				conditionalFields.elements = {}
				-- Build fields based on condition type
				if condition and condition.ruleType then
					BuildConditionFields(conditionalFields, condition)
				end
			end
		end

		-- Clear action-specific fields
		if conditionalFieldsAction.elements then
			for _, element in ipairs(conditionalFieldsAction.elements) do
				element:Hide()
				element:SetParent(nil)
			end
		end

		conditionalFieldsAction.elements = {}
		local actionFieldY = 0
		-- ACTION-SPECIFIC FIELDS
		-- MOUNT ID FIELD (if specific action)
		if newRule.actionType == "specific" then
			local mountIDLabel = conditionalFieldsAction:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			mountIDLabel:SetPoint("TOPLEFT", conditionalFieldsAction, "TOPLEFT", 35, 0)
			mountIDLabel:SetText("Mount ID(s):")
			table.insert(conditionalFieldsAction.elements, mountIDLabel)
			local mountIDBox = CreateFrame("EditBox", nil, conditionalFieldsAction, "InputBoxTemplate")
			mountIDBox:SetSize(205, 20)
			mountIDBox:SetPoint("TOPLEFT", conditionalFieldsAction, "TOPLEFT", 40, -17)
			mountIDBox:SetAutoFocus(false)
			mountIDBox:SetMaxLetters(200)
			mountIDBox:SetText(newRule.mountIDs or "")
			mountIDBox:SetScript("OnTextChanged", function(self)
				newRule.mountIDs = self:GetText()
			end)
			table.insert(conditionalFieldsAction.elements, mountIDBox)
			-- POOL NAME FIELD (if pool action)
		elseif newRule.actionType == "pool" then
			local poolNameLabel = conditionalFieldsAction:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			poolNameLabel:SetPoint("TOPLEFT", conditionalFieldsAction, "TOPLEFT", 35, 0)
			poolNameLabel:SetText("Pool Name:")
			table.insert(conditionalFieldsAction.elements, poolNameLabel)
			local poolNameDropdown = CreateDropDown(conditionalFieldsAction, 200, "TOPLEFT", conditionalFieldsAction, "TOPLEFT",
				15, -15)
			UIDropDownMenu_SetText(poolNameDropdown, "Flying Pool")
			UIDropDownMenu_Initialize(poolNameDropdown, function(self, level)
				local pools = addon.MountRules and addon.MountRules.GetAvailablePools and addon.MountRules:GetAvailablePools() or
						{
							{ value = "flying", text = "Flying Pool" },
							{ value = "ground", text = "Ground Only" },
							{ value = "groundUsable", text = "Ground + Flying" },
							{ value = "underwater", text = "Underwater Pool" },
						}
				for _, pool in ipairs(pools) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = pool.text
					info.value = pool.value
					info.func = function()
						newRule.poolName = pool.value
						UIDropDownMenu_SetText(poolNameDropdown, pool.text)
					end
					info.checked = (newRule.poolName == pool.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFieldsAction.elements, poolNameDropdown)
			-- Update pool dropdown text
			local poolTexts = {
				flying = "Flying Pool",
				ground = "Ground Only",
				groundUsable = "Ground + Flying",
				underwater = "Underwater Pool",
				passenger = "Passenger Mounts (flying only)",
				ridealong = "Ride Along Mounts (flying only)",
				passenger_ridealong = "Passenger + Ride Along (flying only)",
			}
			UIDropDownMenu_SetText(poolNameDropdown, poolTexts[newRule.poolName] or "Flying Pool")
			actionFieldY = actionFieldY - 40
		end

		conditionalFieldsAction:SetHeight(math.max(60, math.abs(actionFieldY)))
	end
	-- Initial build
	RebuildAddRuleUI()
	-- Add Rule button positioned below the form (adjusted to be right below form content)
	local addRuleBtn = CreateFrame("Button", nil, addRuleContainer, "UIPanelButtonTemplate")
	addRuleBtn:SetPoint("TOP", addRuleContainer, "BOTTOM", -35, -5)
	addRuleBtn:SetSize(445, 30)
	addRuleBtn:SetText("Add Rule")
	addRuleBtn:SetScript("OnClick", function()
		if not addon.MountRules or not addon.MountRules.AddRule then
			addon:AlwaysPrint("Zone-Specific Mounts system not initialized")
			return
		end

		-- Validate each condition
		for i, condition in ipairs(newRule.conditions) do
			if condition.ruleType == "location" then
				if not condition.locationID or condition.locationID == "" then
					addon:AlwaysPrint("Condition " .. i .. ": Please enter a location ID")
					return
				end

				if not condition.locationType then
					addon:AlwaysPrint("Condition " .. i .. ": Please select an ID type")
					return
				end
			elseif condition.ruleType == "instance_type" then
				if condition.instanceType == nil then
					addon:AlwaysPrint("Condition " .. i .. ": Please select an instance type")
					return
				end
			elseif condition.ruleType == "group_state" then
				if not condition.groupState then
					addon:AlwaysPrint("Condition " .. i .. ": Please select a group state")
					return
				end
			elseif condition.ruleType == "character_level" then
				if not condition.levelOperator then
					addon:AlwaysPrint("Condition " .. i .. ": Please select an operator")
					return
				end

				if not condition.level then
					addon:AlwaysPrint("Condition " .. i .. ": Please enter a level")
					return
				end
			elseif condition.ruleType == "keybind" then
				if not condition.keybindNumber then
					addon:AlwaysPrint("Condition " .. i .. ": Please select a keybind")
					return
				end
			elseif condition.ruleType == "social" then
				if not condition.socialType then
					addon:AlwaysPrint("Condition " .. i .. ": Please select a social condition")
					return
				end

				if condition.socialType == "character_whitelist" then
					if not condition.characterNames or condition.characterNames == "" then
						addon:AlwaysPrint("Condition " .. i .. ": Please enter at least one character name")
						return
					end
				end
			elseif condition.ruleType == "preset" then
				-- Presets auto-populate, so no validation needed
			end
		end

		-- Validate action
		local mountIDList = nil
		if newRule.actionType == "specific" then
			if not newRule.mountIDs or newRule.mountIDs == "" then
				addon:AlwaysPrint("Please enter at least one mount ID")
				return
			end

			-- Parse semicolon or comma-separated mount IDs
			mountIDList = {}
			local cleanInput = newRule.mountIDs:gsub(",", ";")
			for idStr in cleanInput:gmatch("[^;]+") do
				local trimmed = idStr:match("^%s*(.-)%s*$")
				local id = tonumber(trimmed)
				if id and id > 0 then
					table.insert(mountIDList, id)
				end
			end

			if #mountIDList == 0 then
				addon:AlwaysPrint("Please enter at least one valid mount ID")
				return
			end
		elseif newRule.actionType == "pool" then
			if not newRule.poolName then
				addon:AlwaysPrint("Please select a pool")
				return
			end
		end

		-- Add the rule - build rule object with conditions array
		local data = addon.db.profile.zoneSpecificMounts
		if not data then
			addon:AlwaysPrint("Error: Zone-Specific Mounts data not initialized")
			return
		end

		-- Build the rule object
		local rule = {
			id = data.nextRuleID,
			priority = #data.rules + 1,
			timestamp = time(),
			conditions = {}, -- Copy conditions array
			actionType = newRule.actionType,
		}
		-- Copy each condition and add display names
		for _, condition in ipairs(newRule.conditions) do
			local conditionCopy = {}
			for k, v in pairs(condition) do
				conditionCopy[k] = v
			end

			-- Add display names for GetRuleDescription
			if condition.ruleType == "keybind" then
				local keybindNames = {
					[1] = "RandomMountBuddy Summon",
					[2] = "RandomMountBuddy Summon 2",
					[3] = "RandomMountBuddy Summon 3",
					[4] = "RandomMountBuddy Summon 4",
				}
				conditionCopy.keybindName = keybindNames[condition.keybindNumber] or "Unknown"
			elseif condition.ruleType == "location" then
				-- Set location name based on ID (use first ID for display)
				local firstID
				if type(condition.locationID) == "string" then
					firstID = tonumber(condition.locationID:match("^[^;]+"))
				elseif type(condition.locationID) == "number" then
					firstID = condition.locationID
				end

				if firstID and condition.locationType == "mapid" then
					local mapInfo = C_Map.GetMapInfo(firstID)
					conditionCopy.locationName = (mapInfo and mapInfo.name) or ("Map " .. firstID)
				elseif firstID and condition.locationType == "instanceid" then
					conditionCopy.locationName = GetRealZoneText(firstID) or ("Instance " .. firstID)
				elseif firstID and condition.locationType == "parentzone" then
					conditionCopy.locationName = "Parent Zone " .. firstID
				end

				-- Parse IDs into array (defensive: always create array, even if empty)
				local locationIDs = {}
				if condition.locationID then
					if type(condition.locationID) == "string" then
						-- Parse semicolon-separated IDs
						for id in condition.locationID:gmatch("[^;]+") do
							local trimmed = id:match("^%s*(.-)%s*$")
							local numID = tonumber(trimmed)
							if numID then
								table.insert(locationIDs, numID)
							end
						end
					elseif type(condition.locationID) == "number" then
						-- Single numeric ID
						table.insert(locationIDs, condition.locationID)
					elseif type(condition.locationID) == "table" then
						-- Already an array (shouldn't happen, but handle it)
						locationIDs = condition.locationID
					end
				end

				conditionCopy.locationIDs = locationIDs
			elseif condition.ruleType == "character_level" then
				-- Build display name for character level
				conditionCopy.levelDisplayName = "Level " .. (condition.levelOperator or ">=") .. " " .. (condition.level or "?")
				-- Normalize field name: UI uses 'levelOperator', but evaluation code expects 'operator'
				conditionCopy.operator = condition.levelOperator
			elseif condition.ruleType == "instance_type" then
				-- Display name already set when dropdown selected (instanceTypeName)
			elseif condition.ruleType == "group_state" then
				-- Display name already set when dropdown selected (groupStateName)
			elseif condition.ruleType == "social" then
				-- Display name already set when dropdown selected (socialTypeName)
				-- Parse character names for whitelist type (defensive: always create array, even if empty)
				if condition.socialType == "character_whitelist" then
					local names = {}
					if condition.characterNames and condition.characterNames ~= "" then
						for name in condition.characterNames:gmatch("[^;,]+") do
							local trimmed = name:match("^%s*(.-)%s*$")
							if trimmed ~= "" then
								table.insert(names, trimmed)
							end
						end
					end

					-- Always set characterNames array, even if empty (prevents nil errors in evaluation)
					conditionCopy.characterNames = names
				end
			end

			table.insert(rule.conditions, conditionCopy)
		end

		-- Add action fields
		if newRule.actionType == "specific" then
			rule.mountIDs = mountIDList
			-- Look up and store mount names for display
			rule.mountNames = {}
			for _, mountID in ipairs(mountIDList) do
				local mountName = C_MountJournal.GetMountInfoByID(mountID)
				if mountName then
					table.insert(rule.mountNames, mountName)
				else
					table.insert(rule.mountNames, "Mount ID " .. mountID)
				end
			end
		elseif newRule.actionType == "pool" then
			rule.poolName = newRule.poolName
		end

		-- Insert rule
		table.insert(data.rules, rule)
		data.nextRuleID = data.nextRuleID + 1
		-- Debug output
		addon:DebugOptions("Created multi-condition rule:")
		addon:DebugOptions("  ID:", rule.id, "Priority:", rule.priority)
		addon:DebugOptions("  Conditions:", #rule.conditions)
		for i, cond in ipairs(rule.conditions) do
			addon:DebugOptions("    Condition", i .. ":", cond.ruleType)
			if cond.ruleType == "keybind" then
				addon:DebugOptions("      Keybind:", cond.keybindNumber, "(" .. (cond.keybindName or "?") .. ")")
			elseif cond.ruleType == "location" then
				addon:DebugOptions("      Location:", cond.locationID, "Type:", cond.locationType)
				if cond.locationIDs then
					addon:DebugOptions("      Parsed IDs:", table.concat(cond.locationIDs, ", "))
				end
			end
		end

		addon:DebugOptions("  Action:", rule.actionType)
		local success = true
		local message = "Rule added successfully"
		if success then
			addon:AlwaysPrint(message)
			-- Clear the form - reset to single default condition
			newRule.conditions = {
				{
					ruleType = "keybind", -- Default condition type
				},
			}
			newRule.mountIDs = ""
			newRule.poolName = "flying"
			RebuildConditionRows()
			RebuildAddRuleUI()
			RefreshRulesList()
			-- Refresh Interface Options panel
			if addon.MountRules and addon.MountRules.PopulateZoneSpecificUI then
				addon.MountRules:PopulateZoneSpecificUI()
			end
		else
			addon:AlwaysPrint("Error: " .. (message or "Unknown error occurred"))
		end
	end)
	-- Update scroll child height
	scrollChild:SetHeight(math.abs(yOffset) + 20)
	-- Store refresh function for external use
	frame.RefreshRules = RefreshRulesList
	frame.UpdateLocation = UpdateLocationInfo
	parentFrame.rulesFrame = frame
end
