-- MountBrowserCapabilities.lua
-- Mount movement capability detection and filtering system
-- Extracted from MountBrowser.lua for better code organization
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- CONSTANTS
-- ============================================================================
local CAPABILITY_ICON_SIZE = 24
local CAPABILITY_ICON_SPACING = 4
local CAPABILITY_ICON_RIGHT_OFFSET = 8
local CAPABILITY_ICON_TOP_OFFSET = 8
-- Texture paths
local TEXTURE_GROUND = "Interface\\AddOns\\RandomMountBuddy\\media\\ground"
local TEXTURE_FLIGHT_NORMAL = "Interface\\AddOns\\RandomMountBuddy\\media\\flying"
local TEXTURE_FLIGHT_EDGE = "Interface\\AddOns\\RandomMountBuddy\\media\\swapflightstyles"
local TEXTURE_SWIMMING = "Interface\\AddOns\\RandomMountBuddy\\media\\swimming"
-- ============================================================================
-- MOVEMENT CAPABILITY SYSTEM
-- ============================================================================
-- Get capabilities for a single mount ID
function MountBrowser:GetMountCapabilities(mountID)
	if not mountID then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	-- Use the existing MountSummon system to get mount type traits
	if not addon.MountSummon or not addon.MountSummon.GetMountTypeTraits then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	local typeTraits = addon.MountSummon:GetMountTypeTraits(mountID)
	if not typeTraits then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	-- Check individual flight capabilities
	local canFly = typeTraits.isSteadyFly or false
	local canSkyride = typeTraits.isSkyriding or false
	-- Merged flight capability (true if either flying or skyriding)
	local hasFlight = canFly or canSkyride
	-- Edge case: can do one but not both (show alternate icon)
	local isEdgeCase = hasFlight and (canFly ~= canSkyride)
	-- Map the existing trait fields to our capability format
	local capabilities = {
		ground = typeTraits.isGround or false,
		flight = hasFlight,
		flightEdgeCase = isEdgeCase,
		swimming = typeTraits.isAquatic or false,
		-- Store individual flags for tooltip/debugging
		_canFly = canFly,
		_canSkyride = canSkyride,
	}
	return capabilities
end

-- Get cumulative capabilities for a family
function MountBrowser:GetFamilyCapabilities(familyName)
	if not familyName then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	local capabilities = {
		ground = false,
		flight = false,
		flightEdgeCase = false,
		swimming = false,
	}
	-- Helper function to check if a mount has been separated from this family
	local function isMountSeparatedFromFamily(mountID, checkFamilyName)
		if not addon.db.profile.separatedMounts then
			return false
		end

		local separationData = addon.db.profile.separatedMounts[mountID]
		if separationData and separationData.originalFamily == checkFamilyName then
			-- This mount was separated from this family
			return true
		end

		return false
	end

	-- Check all collected mounts in this family (excluding separated mounts)
	local collectedMounts = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[familyName] or {}
	for _, mountID in ipairs(collectedMounts) do
		if not isMountSeparatedFromFamily(mountID, familyName) then
			local mountCaps = self:GetMountCapabilities(mountID)
			capabilities.ground = capabilities.ground or mountCaps.ground
			capabilities.flight = capabilities.flight or mountCaps.flight
			capabilities.flightEdgeCase = capabilities.flightEdgeCase or mountCaps.flightEdgeCase
			capabilities.swimming = capabilities.swimming or mountCaps.swimming
		end
	end

	-- Also check uncollected mounts if showing them (excluding separated mounts)
	if addon:GetSetting("browserShowUncollectedMounts") then
		local uncollectedMounts = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[familyName] or {}
		for _, mountID in ipairs(uncollectedMounts) do
			if not isMountSeparatedFromFamily(mountID, familyName) then
				local mountCaps = self:GetMountCapabilities(mountID)
				capabilities.ground = capabilities.ground or mountCaps.ground
				capabilities.flight = capabilities.flight or mountCaps.flight
				capabilities.flightEdgeCase = capabilities.flightEdgeCase or mountCaps.flightEdgeCase
				capabilities.swimming = capabilities.swimming or mountCaps.swimming
			end
		end
	end

	return capabilities
end

-- Get cumulative capabilities for a supergroup
function MountBrowser:GetSupergroupCapabilities(supergroupName)
	if not supergroupName then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	local capabilities = {
		ground = false,
		flight = false,
		flightEdgeCase = false,
		swimming = false,
	}
	-- Helper function to check if a mount's family has been separated from this supergroup
	local function isMountSeparated(mountID)
		-- Get mount's family
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID] or
				addon.processedData.allUncollectedMountFamilyInfo[mountID]
		if not mountInfo then
			return false
		end

		local familyName = mountInfo.familyName
		-- Check if this family is in the standalone list (separated from supergroups)
		if addon.processedData.dynamicStandaloneFamilies and
				addon.processedData.dynamicStandaloneFamilies[familyName] then
			return true
		end

		return false
	end

	-- Check all collected mounts (excluding separated families)
	local collectedMounts = addon.processedData.superGroupToMountIDsMap and
			addon.processedData.superGroupToMountIDsMap[supergroupName] or {}
	for _, mountID in ipairs(collectedMounts) do
		if not isMountSeparated(mountID) then
			local mountCaps = self:GetMountCapabilities(mountID)
			capabilities.ground = capabilities.ground or mountCaps.ground
			capabilities.flight = capabilities.flight or mountCaps.flight
			capabilities.flightEdgeCase = capabilities.flightEdgeCase or mountCaps.flightEdgeCase
			capabilities.swimming = capabilities.swimming or mountCaps.swimming
		end
	end

	-- Also check uncollected (excluding separated families)
	if addon:GetSetting("browserShowUncollectedMounts") then
		local uncollectedMounts = addon.processedData.superGroupToUncollectedMountIDsMap and
				addon.processedData.superGroupToUncollectedMountIDsMap[supergroupName] or {}
		for _, mountID in ipairs(uncollectedMounts) do
			if not isMountSeparated(mountID) then
				local mountCaps = self:GetMountCapabilities(mountID)
				capabilities.ground = capabilities.ground or mountCaps.ground
				capabilities.flight = capabilities.flight or mountCaps.flight
				capabilities.flightEdgeCase = capabilities.flightEdgeCase or mountCaps.flightEdgeCase
				capabilities.swimming = capabilities.swimming or mountCaps.swimming
			end
		end
	end

	return capabilities
end

-- Get capabilities based on data type
function MountBrowser:GetCapabilitiesForCard(data)
	if not data then
		return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
	end

	if data.type == "supergroup" then
		return self:GetSupergroupCapabilities(data.key)
	elseif data.type == "familyName" then
		return self:GetFamilyCapabilities(data.key)
	elseif data.type == "mount" then
		local mountID = tonumber(string.match(data.key, "^mount_(%d+)$"))
		if mountID then
			return self:GetMountCapabilities(mountID)
		end
	end

	return { ground = true, flight = false, flightEdgeCase = false, swimming = false }
end

-- ============================================================================
-- CAPABILITY ICON MANAGEMENT
-- ============================================================================
-- Create capability icons on a card
function MountBrowser:CreateCapabilityIcons(card)
	if not card.capabilityIcons then
		card.capabilityIcons = {}
		card.capabilityIconFrames = {} -- Store frames for tooltip support
		-- Define icons with their default textures and tooltip text
		-- Define icons with their default textures and tooltip text
		local iconDefinitions = {
			{
				key = "ground",
				texture = TEXTURE_GROUND,
				tooltip = "Ground Mount",
				tooltipDesc = "Can be used on the ground",
			},
			{
				key = "flight",
				texture = TEXTURE_FLIGHT_NORMAL,
				tooltip = "Flying Mount",
				tooltipDesc = "Can be used for flying and ground travel",
				tooltipEdgeCase = "Limited Flight: Can use EITHER steady flying OR skyriding (not both)",
			},
			{
				key = "swimming",
				texture = TEXTURE_SWIMMING,
				tooltip = "Aquatic Mount",
				tooltipDesc = "Can be used underwater",
			},
		}
		for i, iconDefTable in ipairs(iconDefinitions) do
			-- Create local copy for proper closure capture
			local iconDef = iconDefTable
			-- Create a frame for the icon (to support tooltips)
			local iconFrame = CreateFrame("Frame", nil, card)
			local adjustmentY = -3
			iconFrame:SetSize(CAPABILITY_ICON_SIZE, CAPABILITY_ICON_SIZE)
			local xOffset = -CAPABILITY_ICON_RIGHT_OFFSET
			local yOffset = -(CAPABILITY_ICON_TOP_OFFSET + (i - 1) * (CAPABILITY_ICON_SIZE + CAPABILITY_ICON_SPACING)) +
					adjustmentY
			iconFrame:SetPoint("TOPRIGHT", card, "TOPRIGHT", xOffset, yOffset)
			-- Create icon texture on the frame
			local icon = iconFrame:CreateTexture(nil, "OVERLAY", nil, 7)
			icon:SetAllPoints(iconFrame)
			icon:SetTexture(iconDef.texture)
			-- Use utility to set up dynamic tooltip
			MountBrowser:SetupDynamicTooltip(iconFrame, {
				textFunc = function(self)
					-- Check if this is the edge case flight icon
					if iconDef.key == "flight" and card.capabilityIconData and card.capabilityIconData.isEdgeCase then
						return iconDef.tooltipEdgeCase or iconDef.tooltip
					else
						return iconDef.tooltip, iconDef.tooltipDesc
					end
				end,
				anchor = "ANCHOR_LEFT",
			})
			-- START WITH MOUSE DISABLED to prevent tooltip spam on first scroll
			-- Mouse will be re-enabled during UpdateCapabilityIcons when card is visible and not scrolling
			iconFrame:EnableMouse(false)
			iconFrame:Show()
			card.capabilityIcons[iconDef.key] = icon
			card.capabilityIconFrames[iconDef.key] = iconFrame
		end
	end
end

-- Update capability icon visibility
-- Update capability icon visibility
function MountBrowser:UpdateCapabilityIcons(card, data)
	if not card.capabilityIcons then
		self:CreateCapabilityIcons(card)
	end

	local capabilities = self:GetCapabilitiesForCard(data)
	-- Store capability data on card for tooltip access
	if not card.capabilityIconData then
		card.capabilityIconData = {}
	end

	card.capabilityIconData.isEdgeCase = capabilities.flightEdgeCase
	-- Determine which icons should actually be visible based on WoW conventions
	local shouldShowIcon = {
		ground = capabilities.ground and not capabilities.flight, -- Hide ground if flying exists
		flight = capabilities.flight,                           -- Show flight only if mount has it
		swimming = capabilities.swimming,                       -- Show aquatic only if mount has it
	}
	-- Create ordered list of icons to display (in priority order)
	local iconOrder = { "ground", "flight", "swimming" }
	local visibleIconPosition = 0 -- Track position for flowing icons
	for _, capType in ipairs(iconOrder) do
		local icon = card.capabilityIcons[capType]
		local iconFrame = card.capabilityIconFrames and card.capabilityIconFrames[capType]
		-- Special handling for flight icon - swap texture if edge case
		if capType == "flight" then
			if capabilities.flight and capabilities.flightEdgeCase then
				-- Edge case: only flying OR only skyriding - use alternate icon
				icon:SetTexture(TEXTURE_FLIGHT_EDGE)
			else
				-- Normal case: both flying and skyriding - use regular icon
				icon:SetTexture(TEXTURE_FLIGHT_NORMAL)
			end
		end

		-- Check if this icon should be shown
		if shouldShowIcon[capType] then
			-- Icon should be visible and enabled
			icon:SetDesaturated(false)
			icon:SetVertexColor(1, 1, 1, 1) -- Normal color, full alpha
			if iconFrame then
				-- Reposition icon to flow from top to bottom without gaps
				local adjustmentY = -3
				local xOffset = -CAPABILITY_ICON_RIGHT_OFFSET
				local yOffset = -(CAPABILITY_ICON_TOP_OFFSET + visibleIconPosition * (CAPABILITY_ICON_SIZE + CAPABILITY_ICON_SPACING)) +
						adjustmentY
				iconFrame:ClearAllPoints()
				iconFrame:SetPoint("TOPRIGHT", card, "TOPRIGHT", xOffset, yOffset)
				if addon:GetSetting("browserShowCapabilityIndicators") then
					iconFrame:Show()
					-- Only re-enable mouse interaction if we're not actively scrolling
					if not self.isActivelyScrolling then
						iconFrame:EnableMouse(true) -- Re-enable tooltips after scrolling stops
					end
				else
					iconFrame:Hide()
				end

				-- Increment position for next visible icon
				visibleIconPosition = visibleIconPosition + 1
			end
		else
			-- Icon should not be shown - hide it completely
			if iconFrame then
				iconFrame:Hide()
			end
		end
	end
end

-- Disable mouse interaction on capability icon frames during scrolling (keeps them visible)
function MountBrowser:DisableCapabilityIconMouseDuringScroll()
	for _, card in ipairs(self.cardPool) do
		if card.capabilityIconFrames then
			for _, iconFrame in pairs(card.capabilityIconFrames) do
				iconFrame:EnableMouse(false)
			end
		end
	end
end

-- ============================================================================
-- CAPABILITY FILTERING
-- ============================================================================
-- Check if any capability filters are active
function MountBrowser:HasActiveFilters()
	-- Check both legacy capability filters and new comprehensive filters
	local hasCapabilityFilters = self.capabilityFilters.groundOnly or
			self.capabilityFilters.ground or
			self.capabilityFilters.flying or
			self.capabilityFilters.swimming
	-- Check comprehensive filter system
	local hasComprehensiveFilters = false
	if self.Filters and self.Filters.GetTotalActiveFilterCount then
		hasComprehensiveFilters = self.Filters:GetTotalActiveFilterCount() > 0
	end

	return hasCapabilityFilters or hasComprehensiveFilters
end

-- Check if all filters are active (equivalent to none)
function MountBrowser:AllFiltersActive()
	return self.capabilityFilters.groundOnly and
			self.capabilityFilters.ground and
			self.capabilityFilters.flying and
			self.capabilityFilters.swimming
end

-- Check if a supergroup or family contains at least one mount that passes filters
function MountBrowser:ContainsMatchingMount(key, itemType)
	if not self.Filters or not self.Filters.ShouldShowMount then
		return true -- No comprehensive filters, show everything
	end

	local mountsToCheck = {}
	if itemType == "supergroup" then
		-- Get all families in supergroup
		local families = {}
		if addon.GetSuperGroupFamilies then
			families = addon:GetSuperGroupFamilies(key)
		elseif addon.processedData and addon.processedData.dynamicSuperGroupMap then
			families = addon.processedData.dynamicSuperGroupMap[key] or {}
		elseif addon.processedData and addon.processedData.superGroupMap then
			families = addon.processedData.superGroupMap[key] or {}
		end

		-- Collect all mounts from all families
		for _, familyName in ipairs(families) do
			-- Add collected mounts
			if addon.processedData and addon.processedData.familyToMountIDsMap then
				local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
				if mountIDs then
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
						if mountInfo then
							-- Add mountID field to mountInfo
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							table.insert(mountsToCheck, mountWithID)
						end
					end
				end
			end

			-- Add uncollected mounts
			if addon.processedData and addon.processedData.familyToUncollectedMountIDsMap then
				local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[familyName]
				if mountIDs then
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
						if mountInfo then
							-- Add mountID field to mountInfo
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							table.insert(mountsToCheck, mountWithID)
						end
					end
				end
			end
		end
	elseif itemType == "familyName" then
		-- Add collected mounts from family
		if addon.processedData and addon.processedData.familyToMountIDsMap then
			local mountIDs = addon.processedData.familyToMountIDsMap[key]
			if mountIDs then
				for _, mountID in ipairs(mountIDs) do
					local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
					if mountInfo then
						-- Add mountID field to mountInfo
						local mountWithID = {}
						for k, v in pairs(mountInfo) do
							mountWithID[k] = v
						end

						mountWithID.mountID = mountID
						table.insert(mountsToCheck, mountWithID)
					end
				end
			end
		end

		-- Add uncollected mounts from family
		if addon.processedData and addon.processedData.familyToUncollectedMountIDsMap then
			local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[key]
			if mountIDs then
				for _, mountID in ipairs(mountIDs) do
					local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
					if mountInfo then
						-- Add mountID field to mountInfo
						local mountWithID = {}
						for k, v in pairs(mountInfo) do
							mountWithID[k] = v
						end

						mountWithID.mountID = mountID
						table.insert(mountsToCheck, mountWithID)
					end
				end
			end
		end
	end

	-- Check if at least ONE mount passes the comprehensive filters
	for _, mountInfo in ipairs(mountsToCheck) do
		if self.Filters:ShouldShowMount(mountInfo) then
			return true -- Found at least one matching mount
		end
	end

	return false -- No mounts match the filters
end

-- Check if an item passes the filters (capability + comprehensive filters)
function MountBrowser:PassesCapabilityFilter(data)
	-- Check if there are any comprehensive filters active
	local hasComprehensiveFilters = false
	if self.Filters and self.Filters.GetTotalActiveFilterCount then
		hasComprehensiveFilters = self.Filters:GetTotalActiveFilterCount() > 0
	end

	-- Check if there are capability filters active
	local hasCapFilters = self.capabilityFilters.groundOnly or
			self.capabilityFilters.ground or
			self.capabilityFilters.flying or
			self.capabilityFilters.swimming
	local allCapFiltersActive = self.capabilityFilters.groundOnly and
			self.capabilityFilters.ground and
			self.capabilityFilters.flying and
			self.capabilityFilters.swimming
	-- For individual mounts, use comprehensive filter system
	if data.type == "mount" and data.mountData and self.Filters and self.Filters.ShouldShowMount then
		-- Check comprehensive filters (sources, traits, weights, capabilities)
		if not self.Filters:ShouldShowMount(data.mountData) then
			return false
		end

		return true -- Passed comprehensive filters
	end

	-- For supergroups and families, first check their own weight
	if hasComprehensiveFilters and (data.type == "supergroup" or data.type == "familyName") then
		-- Check if weight filters are active
		if self.Filters and self.Filters.GetActiveFilterCount and self.Filters:GetActiveFilterCount("weights") > 0 then
			local groupWeight = addon:GetGroupWeight(data.key) or 3
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
			local chanceName = weightToChanceMap[groupWeight] or "Normal"
			-- Check if the family/supergroup's own weight matches the filter
			local groupWeightMatches = false
			if self.Filters.filterState and self.Filters.filterState.weights then
				groupWeightMatches = self.Filters.filterState.weights[chanceName] or false
			end

			-- If group weight doesn't match, hide it entirely (even if it contains matching mounts)
			if not groupWeightMatches then
				addon:DebugUI("RMB_FILTER: " ..
					data.type .. " " .. data.key .. " filtered out by own weight (" .. chanceName .. ")")
				return false
			end
		end

		-- Then check if it contains any matching mounts (for other filters)
		if not self:ContainsMatchingMount(data.key, data.type) then
			return false -- No mounts in this group match the filters
		end
	end

	-- Also apply capability filters to supergroups/families
	if hasCapFilters and not allCapFiltersActive then
		-- Get capabilities for this item
		local capabilities = self:GetCapabilitiesForCard(data)
		-- OR logic: item passes if it matches ANY active capability filter
		local passesCapability = false
		-- Special case: ground-only filter (must have ONLY ground, no other capabilities)
		if self.capabilityFilters.groundOnly then
			if capabilities.ground and
					not capabilities.flight and
					not capabilities.swimming then
				passesCapability = true
			end
		end

		if self.capabilityFilters.ground and capabilities.ground then
			passesCapability = true
		end

		if self.capabilityFilters.flying and capabilities.flight then
			passesCapability = true
		end

		if self.capabilityFilters.swimming and capabilities.swimming then
			passesCapability = true
		end

		if not passesCapability then
			return false
		end
	end

	return true
end

-- Refresh the current view with filters applied
function MountBrowser:RefreshCurrentView()
	-- Clear representative mount cache when filters change
	-- This forces new representative mounts to be selected from filtered results
	self.representativeMountCache = {}
	addon:DebugUI("Cleared representative mount cache due to filter change")
	-- Determine what view we're in based on navigation stack
	if #self.navigationStack == 0 then
		-- Main grid
		self:LoadMainGrid()
	else
		local currentNav = self.navigationStack[#self.navigationStack]
		if currentNav.level == "supergroup" then
			-- Family grid within a supergroup
			self:LoadFamilyGrid(currentNav.supergroupName, true) -- skipStackPush = true
		elseif currentNav.level == "family" then
			-- Mount grid within a family
			self:LoadMountGrid(currentNav.familyName, currentNav.fromSupergroup, true) -- skipStackPush = true
		end
	end

	-- Force update all visible cards to refresh collection status with new filter state
	-- This ensures collection counts update immediately when filters change
	C_Timer.After(0.1, function()
		if self.RefreshAllCards then
			self:RefreshAllCards()
		end
	end)
end
