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
	local newRule = {
		ruleType = "location", -- "location", "instance_type", "group_state", "social", or "preset"
		locationType = "mapid", -- "mapid", "parentzone", "instanceid"
		locationID = nil,
		instanceType = nil,
		groupState = nil,      -- "in_group", "not_in_group", "in_party", "not_in_party", "in_raid", "not_in_raid"
		socialType = nil,      -- "bnet_friend_in_party", "friend_in_party", "character_whitelist", "guild_member_in_party"
		characterNames = "",   -- For character_whitelist
		presetType = nil,      -- "delve_flying", "friend_passengers"
		actionType = "specific", -- "specific" or "pool"
		mountIDs = "",
		poolName = "flying",
	}
	-- Create a two-column layout at the top
	local topLeftContainer = CreateFrame("Frame", nil, scrollChild)
	topLeftContainer:SetPoint("TOPLEFT", 20, -10)
	topLeftContainer:SetWidth((scrollFrame:GetWidth() - 60) / 2)
	topLeftContainer:SetHeight(200)
	local topRightContainer = CreateFrame("Frame", nil, scrollChild)
	topRightContainer:SetPoint("TOPLEFT", topLeftContainer, "TOPRIGHT", 200, 0)
	topRightContainer:SetPoint("TOPRIGHT", -40, -10)
	topRightContainer:SetHeight(200)
	local yOffset = -240 -- Start below the two-column section
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
	refreshBtn:SetPoint("TOP", topRightContainer, "BOTTOM", -10, 10)
	refreshBtn:SetSize(300, 30)
	refreshBtn:SetText("Refresh Location Information")
	refreshBtn:SetScript("OnClick", function()
		UpdateLocationInfo()
	end)
	-- Existing Rules Section
	CreateHeader("Existing Rules")
	local rulesContainer = CreateFrame("Frame", nil, scrollChild)
	rulesContainer:SetPoint("TOPLEFT", 20, yOffset)
	rulesContainer:SetPoint("TOPRIGHT", -25, yOffset)
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
			ruleFrame:SetHeight(60) -- Reduced from 80 for more compact display
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
			-- Get full rule description and split into condition and action
			local fullDesc = ""
			if addon.MountRules.GetRuleDescription then
				fullDesc = addon.MountRules:GetRuleDescription(rule)
			else
				fullDesc = "Rule " .. rule.id
			end

			-- Split description at first newline
			local condition, action = fullDesc:match("([^\n]+)\n?(.*)")
			if not condition then condition = fullDesc end

			if not action then action = "" end

			-- Condition text (top row)
			local condDesc = ruleFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			condDesc:SetPoint("TOPLEFT", priority, "TOPRIGHT", 15, 5)
			condDesc:SetPoint("RIGHT", -160, 5)
			condDesc:SetJustifyH("LEFT")
			condDesc:SetWordWrap(false)
			condDesc:SetText(condition)
			-- Action text (bottom row)
			local actionDesc = ruleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			actionDesc:SetPoint("TOPLEFT", priority, "TOPRIGHT", 15, -15)
			actionDesc:SetPoint("RIGHT", -160, -15)
			actionDesc:SetJustifyH("LEFT")
			actionDesc:SetWordWrap(false)
			actionDesc:SetText(action)
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
			-- Move up button (if not first)
			if i > 1 then
				local upBtn = CreateFrame("Button", nil, ruleFrame, "UIPanelButtonTemplate")
				upBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -5, 0)
				upBtn:SetSize(30, 22)
				upBtn:SetText("|TInterface\\BUTTONS\\Arrow-Up-Up.blp:16:16:1:0|t") -- Up button
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
			end

			-- Move down button (if not last)
			if i < #rules then
				local downBtn = CreateFrame("Button", nil, ruleFrame, "UIPanelButtonTemplate")
				if i > 1 then
					downBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -40, 0)
				else
					downBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -5, 0)
				end

				downBtn:SetSize(30, 22)
				downBtn:SetText("|TInterface\\BUTTONS\\Arrow-Down-Up.blp:16:16:2:-6|t") -- Down button
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
			end

			table.insert(rulesContainer.ruleFrames, ruleFrame)
			ruleY = ruleY - 65 -- Reduced spacing for more compact display
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
	-- Create two columns
	local leftColumn = CreateFrame("Frame", nil, addRuleContainer)
	leftColumn:SetPoint("TOPLEFT", 0, 0)
	leftColumn:SetWidth((topLeftContainer:GetWidth() - 20) / 2)
	leftColumn:SetHeight(1)
	local rightColumn = CreateFrame("Frame", nil, addRuleContainer)
	rightColumn:SetPoint("TOPLEFT", leftColumn, "TOPRIGHT", 20, 0)
	rightColumn:SetPoint("TOPRIGHT", 0, 0)
	rightColumn:SetHeight(1)
	local leftY = 0
	local rightY = 0
	-- Forward declaration for RebuildAddRuleUI
	local RebuildAddRuleUI
	-- LEFT COLUMN: Rule Type
	local ruleTypeLabel = leftColumn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ruleTypeLabel:SetPoint("TOPLEFT", leftColumn, "TOPLEFT", 0, leftY)
	ruleTypeLabel:SetText("Rule Type:")
	leftY = leftY - 20
	local ruleTypeDropdown = CreateDropDown(leftColumn, 180, "TOPLEFT", leftColumn, "TOPLEFT", -15, leftY)
	UIDropDownMenu_SetText(ruleTypeDropdown, "Map/Parent Zone/Instance ID")
	UIDropDownMenu_Initialize(ruleTypeDropdown, function(self, level)
		local info1 = UIDropDownMenu_CreateInfo()
		info1.text = "Map/Parent Zone/Instance ID"
		info1.value = "location"
		info1.func = function()
			newRule.ruleType = "location"
			UIDropDownMenu_SetText(ruleTypeDropdown, info1.text)
			RebuildAddRuleUI()
		end
		info1.checked = (newRule.ruleType == "location")
		UIDropDownMenu_AddButton(info1)
		local info2 = UIDropDownMenu_CreateInfo()
		info2.text = "Instance Type"
		info2.value = "instance_type"
		info2.func = function()
			newRule.ruleType = "instance_type"
			UIDropDownMenu_SetText(ruleTypeDropdown, info2.text)
			RebuildAddRuleUI()
		end
		info2.checked = (newRule.ruleType == "instance_type")
		UIDropDownMenu_AddButton(info2)
		local info3 = UIDropDownMenu_CreateInfo()
		info3.text = "Group State"
		info3.value = "group_state"
		info3.func = function()
			newRule.ruleType = "group_state"
			UIDropDownMenu_SetText(ruleTypeDropdown, info3.text)
			RebuildAddRuleUI()
		end
		info3.checked = (newRule.ruleType == "group_state")
		UIDropDownMenu_AddButton(info3)
		local info4 = UIDropDownMenu_CreateInfo()
		info4.text = "Social"
		info4.value = "social"
		info4.func = function()
			newRule.ruleType = "social"
			UIDropDownMenu_SetText(ruleTypeDropdown, info4.text)
			RebuildAddRuleUI()
		end
		info4.checked = (newRule.ruleType == "social")
		UIDropDownMenu_AddButton(info4)
		local info5 = UIDropDownMenu_CreateInfo()
		info5.text = "Quick Presets"
		info5.value = "preset"
		info5.func = function()
			newRule.ruleType = "preset"
			UIDropDownMenu_SetText(ruleTypeDropdown, info5.text)
			RebuildAddRuleUI()
		end
		info5.checked = (newRule.ruleType == "preset")
		UIDropDownMenu_AddButton(info5)
	end)
	leftY = leftY - 35
	-- Conditional fields container for rule-specific settings (left column)
	local conditionalFieldsLeft = CreateFrame("Frame", nil, leftColumn)
	conditionalFieldsLeft:SetPoint("TOPLEFT", leftColumn, "TOPLEFT", 0, leftY)
	conditionalFieldsLeft:SetPoint("TOPRIGHT", leftColumn, "TOPRIGHT", 0, leftY)
	conditionalFieldsLeft:SetHeight(200)
	-- RIGHT COLUMN: Action Type
	local actionTypeLabel = rightColumn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	actionTypeLabel:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 0, rightY)
	actionTypeLabel:SetText("Action:")
	rightY = rightY - 20
	local actionTypeDropdown = CreateDropDown(rightColumn, 180, "TOPLEFT", rightColumn, "TOPLEFT", -15, rightY)
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
	rightY = rightY - 35
	-- Conditional fields container for action-specific settings (right column)
	local conditionalFieldsRight = CreateFrame("Frame", nil, rightColumn)
	conditionalFieldsRight:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 0, rightY)
	conditionalFieldsRight:SetPoint("TOPRIGHT", rightColumn, "TOPRIGHT", 0, rightY)
	conditionalFieldsRight:SetHeight(200)
	-- Function to rebuild conditional UI
	RebuildAddRuleUI = function()
		-- Clear LEFT conditional fields (rule-specific)
		if conditionalFieldsLeft.elements then
			for _, element in ipairs(conditionalFieldsLeft.elements) do
				element:Hide()
				element:SetParent(nil)
			end
		end

		conditionalFieldsLeft.elements = {}
		-- Clear RIGHT conditional fields (action-specific)
		if conditionalFieldsRight.elements then
			for _, element in ipairs(conditionalFieldsRight.elements) do
				element:Hide()
				element:SetParent(nil)
			end
		end

		conditionalFieldsRight.elements = {}
		local leftFieldY = 0
		local rightFieldY = 0
		-- LEFT COLUMN: RULE-SPECIFIC FIELDS
		-- LOCATION-BASED FIELDS
		if newRule.ruleType == "location" then
			-- Location ID input
			local locationIDLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			locationIDLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			locationIDLabel:SetText("Location ID(s) (semicolon-separated):")
			table.insert(conditionalFieldsLeft.elements, locationIDLabel)
			leftFieldY = leftFieldY - 20
			local locationIDBox = CreateFrame("EditBox", nil, conditionalFieldsLeft, "InputBoxTemplate")
			locationIDBox:SetSize(190, 20)
			locationIDBox:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 8, leftFieldY)
			locationIDBox:SetAutoFocus(false)
			locationIDBox:SetMaxLetters(50) -- Increased from 10 to handle multiple IDs
			locationIDBox:SetText(newRule.locationID or "")
			locationIDBox:SetScript("OnTextChanged", function(self)
				local text = self:GetText()
				-- Keep as string to support both single IDs and semicolon-separated lists
				newRule.locationID = text
			end)
			table.insert(conditionalFieldsLeft.elements, locationIDBox)
			leftFieldY = leftFieldY - 25
			-- ID Type dropdown
			local idTypeLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			idTypeLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			idTypeLabel:SetText("ID Type:")
			table.insert(conditionalFieldsLeft.elements, idTypeLabel)
			leftFieldY = leftFieldY - 20
			local idTypeDropdown = CreateDropDown(conditionalFieldsLeft, 180, "TOPLEFT", conditionalFieldsLeft, "TOPLEFT", -15,
				leftFieldY)
			UIDropDownMenu_SetText(idTypeDropdown, "Map ID")
			UIDropDownMenu_Initialize(idTypeDropdown, function(self, level)
				local info1 = UIDropDownMenu_CreateInfo()
				info1.text = "Map ID"
				info1.value = "mapid"
				info1.func = function()
					newRule.locationType = "mapid"
					UIDropDownMenu_SetText(idTypeDropdown, info1.text)
				end
				info1.checked = (newRule.locationType == "mapid")
				UIDropDownMenu_AddButton(info1)
				local info2 = UIDropDownMenu_CreateInfo()
				info2.text = "Parent Zone ID"
				info2.value = "parentzone"
				info2.func = function()
					newRule.locationType = "parentzone"
					UIDropDownMenu_SetText(idTypeDropdown, info2.text)
				end
				info2.checked = (newRule.locationType == "parentzone")
				UIDropDownMenu_AddButton(info2)
				local info3 = UIDropDownMenu_CreateInfo()
				info3.text = "Instance ID"
				info3.value = "instanceid"
				info3.func = function()
					newRule.locationType = "instanceid"
					UIDropDownMenu_SetText(idTypeDropdown, info3.text)
				end
				info3.checked = (newRule.locationType == "instanceid")
				UIDropDownMenu_AddButton(info3)
			end)
			table.insert(conditionalFieldsLeft.elements, idTypeDropdown)
			-- Update display text
			if newRule.locationType == "mapid" then
				UIDropDownMenu_SetText(idTypeDropdown, "Map ID")
			elseif newRule.locationType == "parentzone" then
				UIDropDownMenu_SetText(idTypeDropdown, "Parent Zone ID")
			elseif newRule.locationType == "instanceid" then
				UIDropDownMenu_SetText(idTypeDropdown, "Instance ID")
			end

			leftFieldY = leftFieldY - 40
			-- INSTANCE TYPE FIELDS
		elseif newRule.ruleType == "instance_type" then
			local instanceTypeLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			instanceTypeLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			instanceTypeLabel:SetText("Instance Type:")
			table.insert(conditionalFieldsLeft.elements, instanceTypeLabel)
			leftFieldY = leftFieldY - 20
			-- Build instance type list from MountRules
			local instanceTypes = {
				[0] = "None",
				[1] = "Dungeon (Normal)",
				[2] = "Dungeon (Heroic)",
				[3] = "10 Player Raid (Normal)",
				[4] = "25 Player Raid (Normal)",
				[5] = "10 Player Raid (Heroic)",
				[6] = "25 Player Raid (Heroic)",
				[7] = "Legacy Looking for Raid",
				[8] = "Mythic Keystone",
				[9] = "40 Player Raid",
				[11] = "Scenario (Heroic)",
				[12] = "Scenario (Normal)",
				[14] = "Raid (Normal)",
				[15] = "Raid (Heroic)",
				[16] = "Raid (Mythic)",
				[17] = "Looking for Raid",
				[23] = "Dungeon (Mythic)",
				[24] = "Dungeon (Timewalking)",
				[25] = "PvP",
				[33] = "Raid (Timewalking)",
				[34] = "Island Expedition (PvP)",
				[35] = "Island Expedition (Normal)",
				[38] = "Island Expedition (Heroic)",
				[39] = "Island Expedition (Mythic)",
				[40] = "Warfront (Normal)",
				[45] = "Warfront (Heroic)",
				[147] = "Visions of N'Zoth",
				[152] = "Torghast",
				[167] = "Path of Ascension: Courage",
				[168] = "Path of Ascension: Loyalty",
				[169] = "Path of Ascension: Wisdom",
				[170] = "Path of Ascension: Humility",
				[205] = "Follower Dungeon",
				[208] = "Delve",
				[220] = "Story Raid",
			}
			local instanceTypeDropdown = CreateDropDown(conditionalFieldsLeft, 180, "TOPLEFT", conditionalFieldsLeft, "TOPLEFT",
				-15,
				leftFieldY)
			UIDropDownMenu_SetText(instanceTypeDropdown, instanceTypes[newRule.instanceType or 0])
			UIDropDownMenu_Initialize(instanceTypeDropdown, function(self, level)
				-- Sort by ID
				local sortedIDs = {}
				for id in pairs(instanceTypes) do
					table.insert(sortedIDs, id)
				end

				table.sort(sortedIDs)
				for _, id in ipairs(sortedIDs) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = instanceTypes[id]
					info.value = id
					info.func = function()
						newRule.instanceType = id
						UIDropDownMenu_SetText(instanceTypeDropdown, info.text)
					end
					info.checked = (newRule.instanceType == id)
					UIDropDownMenu_AddButton(info)
				end
			end)
			table.insert(conditionalFieldsLeft.elements, instanceTypeDropdown)
			-- GROUP STATE FIELDS
		elseif newRule.ruleType == "group_state" then
			-- Group state dropdown
			local groupStateLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			groupStateLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			groupStateLabel:SetText("Group State:")
			leftFieldY = leftFieldY - 20
			local groupStateDropdown = CreateDropDown(conditionalFieldsLeft, 180, "TOPLEFT", conditionalFieldsLeft, "TOPLEFT",
				-15,
				leftFieldY)
			local groupStateText = "Select..."
			if newRule.groupState then
				groupStateText = newRule.groupState:gsub("_", " "):gsub("(%a)([%w_']*)",
					function(a, b) return string.upper(a) .. b end)
			end

			UIDropDownMenu_SetText(groupStateDropdown, groupStateText)
			UIDropDownMenu_Initialize(groupStateDropdown, function(self, level)
				local states = {
					{ value = "in_group", text = "In Any Group" },
					{ value = "not_in_group", text = "Not in Group" },
					{ value = "in_party", text = "In Party" },
					{ value = "not_in_party", text = "Not in Party" },
					{ value = "in_raid", text = "In Raid" },
					{ value = "not_in_raid", text = "Not in Raid" },
				}
				for _, state in ipairs(states) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = state.text
					info.value = state.value
					info.func = function()
						newRule.groupState = state.value
						UIDropDownMenu_SetText(groupStateDropdown, state.text)
					end
					info.checked = (newRule.groupState == state.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			leftFieldY = leftFieldY - 35
			table.insert(conditionalFieldsLeft.elements, groupStateLabel)
			table.insert(conditionalFieldsLeft.elements, groupStateDropdown)
			-- SOCIAL FIELDS
		elseif newRule.ruleType == "social" then
			-- Social type dropdown
			local socialTypeLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			socialTypeLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			socialTypeLabel:SetText("Social Condition:")
			leftFieldY = leftFieldY - 20
			local socialTypeDropdown = CreateDropDown(conditionalFieldsLeft, 180, "TOPLEFT", conditionalFieldsLeft, "TOPLEFT",
				-15,
				leftFieldY)
			local socialDisplayNames = {
				bnet_friend_in_party = "BNet Friend in Party",
				friend_in_party = "In-Game Friend in Party",
				character_whitelist = "Specific Characters",
				guild_member_in_party = "Guild Member in Party",
			}
			local socialText = "Select..."
			if newRule.socialType and socialDisplayNames[newRule.socialType] then
				socialText = socialDisplayNames[newRule.socialType]
			end

			UIDropDownMenu_SetText(socialTypeDropdown, socialText)
			UIDropDownMenu_Initialize(socialTypeDropdown, function(self, level)
				local types = {
					{ value = "bnet_friend_in_party", text = "BNet Friend in Party" },
					{ value = "friend_in_party", text = "In-Game Friend in Party" },
					{ value = "character_whitelist", text = "Specific Characters" },
					{ value = "guild_member_in_party", text = "Guild Member in Party" },
				}
				for _, stype in ipairs(types) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = stype.text
					info.value = stype.value
					info.func = function()
						newRule.socialType = stype.value
						UIDropDownMenu_SetText(socialTypeDropdown, stype.text)
						RebuildAddRuleUI() -- Rebuild to show/hide character names field
					end
					info.checked = (newRule.socialType == stype.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			leftFieldY = leftFieldY - 35
			table.insert(conditionalFieldsLeft.elements, socialTypeLabel)
			table.insert(conditionalFieldsLeft.elements, socialTypeDropdown)
			-- Character names input (only for character_whitelist)
			if newRule.socialType == "character_whitelist" then
				local charNamesLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				charNamesLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
				charNamesLabel:SetText("Character Names (Name-Realm;Name2-Realm2):")
				leftFieldY = leftFieldY - 20
				local charNamesBox = CreateFrame("EditBox", nil, conditionalFieldsLeft, "InputBoxTemplate")
				charNamesBox:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 8, leftFieldY)
				charNamesBox:SetSize(460, 20)
				charNamesBox:SetAutoFocus(false)
				charNamesBox:SetText(newRule.characterNames or "")
				charNamesBox:SetScript("OnTextChanged", function(self)
					newRule.characterNames = self:GetText()
				end)
				charNamesBox:SetScript("OnEscapePressed", function(self)
					self:ClearFocus()
				end)
				leftFieldY = leftFieldY - 30
				table.insert(conditionalFieldsLeft.elements, charNamesLabel)
				table.insert(conditionalFieldsLeft.elements, charNamesBox)
			end

			leftFieldY = leftFieldY - 40
			-- PRESET FIELDS
		elseif newRule.ruleType == "preset" then
			-- Preset selector dropdown
			local presetLabel = conditionalFieldsLeft:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			presetLabel:SetPoint("TOPLEFT", conditionalFieldsLeft, "TOPLEFT", 0, leftFieldY)
			presetLabel:SetText("Select Preset:")
			leftFieldY = leftFieldY - 20
			local presetDropdown = CreateDropDown(conditionalFieldsLeft, 180, "TOPLEFT", conditionalFieldsLeft, "TOPLEFT", -15,
				leftFieldY)
			local presetDisplayNames = {
				m_portal_flying = "Flying Pool in M+ Portal room",
				class_hall_flying = "Flying Pool in Class Halls",
				friend_passengers = "Passengers with Friends",
			}
			local presetText = "Select..."
			if newRule.presetType and presetDisplayNames[newRule.presetType] then
				presetText = presetDisplayNames[newRule.presetType]
			end

			UIDropDownMenu_SetText(presetDropdown, presetText)
			UIDropDownMenu_Initialize(presetDropdown, function(self, level)
				local presets = {
					{ value = "m_portal_flying", text = "Flying Pool in M+ Portal room" },
					{ value = "class_hall_flying", text = "Flying in Class Halls" },
					{ value = "friend_passengers", text = "Passengers with Friends" },
				}
				for _, preset in ipairs(presets) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = preset.text
					info.value = preset.value
					info.func = function()
						newRule.presetType = preset.value
						UIDropDownMenu_SetText(presetDropdown, preset.text)
						-- Auto-populate fields based on preset
						if preset.value == "m_portal_flying" then
							newRule.ruleType = "location"
							newRule.locationID = "2678"
							newRule.locationType = "instanceid"
							newRule.actionType = "pool"
							newRule.poolName = "flying"
						elseif preset.value == "class_hall_flying" then
							newRule.ruleType = "location"
							newRule.locationID = "1519;1540;1514;1469;1479"
							newRule.locationType = "instanceid"
							newRule.actionType = "pool"
							newRule.poolName = "flying"
						elseif preset.value == "friend_passengers" then
							newRule.ruleType = "social"
							newRule.socialType = "bnet_friend_in_party"
							newRule.actionType = "pool"
							newRule.poolName = "passenger_ridealong"
						end

						RebuildAddRuleUI()
					end
					info.checked = (newRule.presetType == preset.value)
					UIDropDownMenu_AddButton(info)
				end
			end)
			leftFieldY = leftFieldY - 35
			table.insert(conditionalFieldsLeft.elements, presetLabel)
			table.insert(conditionalFieldsLeft.elements, presetDropdown)
			leftFieldY = leftFieldY - 40
		end

		-- RIGHT COLUMN: ACTION-SPECIFIC FIELDS
		-- MOUNT ID FIELD (if specific action)
		if newRule.actionType == "specific" then
			local mountIDLabel = conditionalFieldsRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			mountIDLabel:SetPoint("TOPLEFT", conditionalFieldsRight, "TOPLEFT", 0, rightFieldY)
			mountIDLabel:SetText("Mount ID(s) (semicolon-separated):")
			table.insert(conditionalFieldsRight.elements, mountIDLabel)
			rightFieldY = rightFieldY - 20
			local mountIDBox = CreateFrame("EditBox", nil, conditionalFieldsRight, "InputBoxTemplate")
			mountIDBox:SetSize(190, 20)
			mountIDBox:SetPoint("TOPLEFT", conditionalFieldsRight, "TOPLEFT", 8, rightFieldY)
			mountIDBox:SetAutoFocus(false)
			mountIDBox:SetMaxLetters(200)
			mountIDBox:SetText(newRule.mountIDs or "")
			mountIDBox:SetScript("OnTextChanged", function(self)
				newRule.mountIDs = self:GetText()
			end)
			table.insert(conditionalFieldsRight.elements, mountIDBox)
			rightFieldY = rightFieldY - 25
			-- POOL NAME FIELD (if pool action)
		elseif newRule.actionType == "pool" then
			local poolNameLabel = conditionalFieldsRight:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			poolNameLabel:SetPoint("TOPLEFT", conditionalFieldsRight, "TOPLEFT", 0, rightFieldY)
			poolNameLabel:SetText("Pool Name:")
			table.insert(conditionalFieldsRight.elements, poolNameLabel)
			rightFieldY = rightFieldY - 20
			local poolNameDropdown = CreateDropDown(conditionalFieldsRight, 180, "TOPLEFT", conditionalFieldsRight, "TOPLEFT",
				-15, rightFieldY)
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
			table.insert(conditionalFieldsRight.elements, poolNameDropdown)
			-- Update pool dropdown text
			local poolTexts = {
				flying = "Flying Pool",
				ground = "Ground Only",
				groundUsable = "Ground + Flying",
				underwater = "Underwater Pool",
				passenger = "Passenger Mounts",
				ridealong = "Ride Along Mounts",
				passenger_ridealong = "Passenger + Ride Along",
			}
			UIDropDownMenu_SetText(poolNameDropdown, poolTexts[newRule.poolName] or "Flying Pool")
			rightFieldY = rightFieldY - 40
		end

		conditionalFieldsLeft:SetHeight(math.max(200, math.abs(leftFieldY)))
		conditionalFieldsRight:SetHeight(math.max(200, math.abs(rightFieldY)))
	end
	-- Initial build
	RebuildAddRuleUI()
	-- Add Rule button positioned below the form (adjusted to be right below form content)
	local addRuleBtn = CreateFrame("Button", nil, addRuleContainer, "UIPanelButtonTemplate")
	addRuleBtn:SetPoint("TOP", addRuleContainer, "BOTTOM", -25, 0)
	addRuleBtn:SetSize(470, 30)
	addRuleBtn:SetText("Add Rule")
	addRuleBtn:SetScript("OnClick", function()
		if not addon.MountRules or not addon.MountRules.AddRule then
			addon:AlwaysPrint("Zone-Specific Mounts system not initialized")
			return
		end

		-- Validate based on ruleType
		if newRule.ruleType == "location" then
			if not newRule.locationID or newRule.locationID == "" then
				addon:AlwaysPrint("Please enter a location ID")
				return
			end

			if not newRule.locationType then
				addon:AlwaysPrint("Please select an ID type")
				return
			end
		elseif newRule.ruleType == "instance_type" then
			if newRule.instanceType == nil then
				addon:AlwaysPrint("Please select an instance type")
				return
			end
		elseif newRule.ruleType == "group_state" then
			if not newRule.groupState then
				addon:AlwaysPrint("Please select a group state")
				return
			end
		elseif newRule.ruleType == "social" then
			if not newRule.socialType then
				addon:AlwaysPrint("Please select a social condition")
				return
			end

			if newRule.socialType == "character_whitelist" then
				if not newRule.characterNames or newRule.characterNames == "" then
					addon:AlwaysPrint("Please enter at least one character name")
					return
				end
			end
		elseif newRule.ruleType == "preset" then
			if not newRule.presetType then
				addon:AlwaysPrint("Please select a preset")
				return
			end
		end

		-- Validate action
		if not newRule.actionType then
			addon:AlwaysPrint("Please select an action")
			return
		end

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

		-- Add the rule
		-- Build arguments based on rule type
		local success, message
		if newRule.ruleType == "location" then
			-- For location rules: AddRule(ruleType, actionType, locationID, locationType, mountIDs/poolName)
			if newRule.actionType == "specific" then
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.locationID,
					newRule.locationType,
					mountIDList
				)
			else -- pool
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.locationID,
					newRule.locationType,
					newRule.poolName
				)
			end
		elseif newRule.ruleType == "instance_type" then
			-- For instance_type rules: AddRule(ruleType, actionType, instanceType, mountIDs/poolName)
			if newRule.actionType == "specific" then
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.instanceType,
					mountIDList
				)
			else -- pool
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.instanceType,
					newRule.poolName
				)
			end
		elseif newRule.ruleType == "group_state" then
			-- For group_state rules: AddRule(ruleType, actionType, groupState, mountIDs/poolName)
			if newRule.actionType == "specific" then
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.groupState,
					mountIDList
				)
			else -- pool
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.groupState,
					newRule.poolName
				)
			end
		elseif newRule.ruleType == "social" then
			-- For social rules: AddRule(ruleType, actionType, socialType, socialData, mountIDs/poolName)
			local socialData = nil
			if newRule.socialType == "character_whitelist" then
				-- Parse character names
				socialData = {}
				local cleanInput = newRule.characterNames:gsub(",", ";")
				for name in cleanInput:gmatch("[^;]+") do
					local trimmed = name:match("^%s*(.-)%s*$")
					if trimmed ~= "" then
						table.insert(socialData, trimmed)
					end
				end

				if #socialData == 0 then
					addon:AlwaysPrint("Please enter at least one valid character name")
					return
				end
			end

			if newRule.actionType == "specific" then
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.socialType,
					socialData,
					mountIDList
				)
			else -- pool
				success, message = addon.MountRules:AddRule(
					newRule.ruleType,
					newRule.actionType,
					newRule.socialType,
					socialData,
					newRule.poolName
				)
			end
		end

		if success then
			addon:AlwaysPrint(message)
			-- Clear the form
			newRule.locationID = nil
			newRule.instanceType = 0
			newRule.groupState = nil
			newRule.socialType = nil
			newRule.characterNames = ""
			newRule.mountIDs = ""
			RebuildAddRuleUI()
			RefreshRulesList()
			-- Refresh Interface Options panel
			if addon.MountRules and addon.MountRules.PopulateZoneSpecificUI then
				addon.MountRules:PopulateZoneSpecificUI()
			end
		else
			addon:AlwaysPrint("Error: " .. message)
		end
	end)
	-- Update scroll child height
	scrollChild:SetHeight(math.abs(yOffset) + 20)
	-- Store refresh function for external use
	frame.RefreshRules = RefreshRulesList
	frame.UpdateLocation = UpdateLocationInfo
	parentFrame.rulesFrame = frame
end
