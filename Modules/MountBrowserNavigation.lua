-- MountBrowserNavigation.lua
-- Navigation, grid loading, and card layout management
-- Extracted from MountBrowser.lua for better code organization
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- CONSTANTS
-- ============================================================================
local CARD_WIDTH = 220
local CARD_HEIGHT = 260
local CARD_SPACING = 10
local CARDS_PER_ROW = 5
local GRID_HEIGHT = 800
-- ============================================================================
-- VIEW CACHE MANAGEMENT
-- ============================================================================
-- ============================================================================
-- Save the current view state to cache
function MountBrowser:SaveViewToCache(viewKey, cards)
	if not viewKey or not cards then return end

	local cacheEntry = {
		cards = {},
		timestamp = GetTime(),
	}
	-- Save card states (position, data, model state)
	for i, card in ipairs(cards) do
		if card.data then
			cacheEntry.cards[i] = {
				data = card.data,
				modelLoaded = card.modelLoaded,
				repMount = card.repMount,
				cameraSettings = card.cameraSettings,
			}
		end
	end

	self.viewCache[viewKey] = cacheEntry
	addon:DebugUI("Saved view cache for: " .. viewKey)
end

function MountBrowser:TryRestoreFromCache(viewKey, cards)
	if not viewKey or not self.viewCache[viewKey] then
		return false
	end

	local cache = self.viewCache[viewKey]
	if not cache or not cache.cards then
		return false
	end

	local restored = 0
	-- Restore cached card states
	for i, cachedCard in pairs(cache.cards) do
		if cards[i] and cachedCard and cachedCard.data then
			local card = cards[i]
			-- Restore data without clearing model
			card.data = cachedCard.data
			card.repMount = cachedCard.repMount
			card.cameraSettings = cachedCard.cameraSettings
			-- Update UI elements
			card.nameLabel:SetText(cachedCard.data.displayName or cachedCard.data.key)
			-- If model was loaded, mark it as loaded (don't clear)
			if cachedCard.modelLoaded and card.actor then
				card.modelLoaded = true
			end

			restored = restored + 1
		end
	end

	if restored > 0 then
		addon:DebugUI("Restored " .. restored .. " cards from cache: " .. viewKey)
		return true
	end

	return false
end

-- GRID LAYOUT
-- ============================================================================
function MountBrowser:LayoutCards(cards)
	local scrollChild = self.mainFrame.scrollChild
	-- Clear load queue when changing views
	self:ClearLoadQueue()
	-- Clear existing cards
	for _, card in ipairs(self.cardPool) do
		-- Always hide cards not in current view
		local isInView = false
		for _, viewCard in ipairs(cards) do
			if card == viewCard then
				isInView = true
				break
			end
		end

		if not isInView then
			card:Hide()
			card:ClearAllPoints()
			card.modelLoaded = false
			card.currentDataKey = nil -- Clear data tracking
			card.traitButtonsPositioned = false
			card.lastTraitKey = nil
			-- Clear the actor model
			if card.actor then
				pcall(function()
					card.actor:ClearModel()
				end)
			end
		end
	end

	-- Calculate grid dimensions
	local numCards = #cards
	local numRows = math.ceil(numCards / CARDS_PER_ROW)
	local contentHeight = (numRows * CARD_HEIGHT) + ((numRows + 1) * CARD_SPACING)
	-- Update scroll child height
	local finalHeight = math.max(contentHeight, GRID_HEIGHT - 90)
	addon:DebugUI("LayoutCards setting scrollChild height to: " ..
		tostring(finalHeight) .. " (" .. tostring(numCards) .. " cards, " .. tostring(numRows) .. " rows)")
	scrollChild:SetHeight(finalHeight)
	-- Position cards in grid (but don't show yet)
	local cardIndex = 1
	local xOffset = -10
	local yOffset = 10 -- Originally meant to bring the top edge of the cards in line with the top edge of the scroll bar, now it just looks neat
	local cardsToCreate = {}
	for row = 0, numRows - 1 do
		for col = 0, CARDS_PER_ROW - 1 do
			if cardIndex <= numCards then
				local card = cards[cardIndex]
				local x = xOffset + CARD_SPACING + (col * (CARD_WIDTH + CARD_SPACING))
				local y = yOffset + -CARD_SPACING - (row * (CARD_HEIGHT + CARD_SPACING))
				card:ClearAllPoints()
				card:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", x, y)
				-- Don't show yet - add to creation queue
				table.insert(cardsToCreate, { card = card })
				cardIndex = cardIndex + 1
			end
		end
	end

	-- Reset scroll to top
	addon:DebugUI("LayoutCards resetting scroll to 0")
	self.mainFrame.scrollFrame:SetVerticalScroll(0)
	-- Start batched creation
	self:ShowCards(cardsToCreate)
end

-- ============================================================================
-- LEVEL LOADING
-- ============================================================================
-- Load Level 1: Main grid (supergroups + standalone families)
function MountBrowser:LoadMainGrid()
	if not addon.SuperGroupManager or not addon.MountDataManager then
		addon:DebugUI("Cannot load main grid - managers not available")
		return
	end

	-- Update title
	self.mainFrame.title:SetText("Random Mount Buddy")
	self.mainFrame.backButton:Hide()
	-- Clear navigation stack
	self.navigationStack = {}
	-- Build list of items to display
	local items = {}
	-- Add all supergroups
	local supergroups = addon.SuperGroupManager:GetAllSuperGroups()
	for _, sg in ipairs(supergroups) do
		table.insert(items, {
			key = sg.name,
			displayName = sg.displayName or sg.name,
			type = "supergroup",
		})
	end

	-- Add standalone families (use dynamic list that includes trait-separated families)
	local standaloneFamilies = {}
	if addon.processedData then
		-- Check if families should be kept together (inverted logic)
		local groupTogether = addon:GetSetting("browserGroupFamiliesTogether")
		if groupTogether == nil then
			groupTogether = false -- Default to separated (matches summon pool)
		end

		if not groupTogether then
			-- Use dynamic standalone families (includes trait-separated families)
			if addon.processedData.dynamicStandaloneFamilies then
				standaloneFamilies = addon.processedData.dynamicStandaloneFamilies
			elseif addon.processedData.standaloneFamilyNames then
				-- Fallback to original static list
				standaloneFamilies = addon.processedData.standaloneFamilyNames
			end
		else
			-- Keep families together - use only original standalone families (no trait separation)
			if addon.processedData.standaloneFamilyNames then
				standaloneFamilies = addon.processedData.standaloneFamilyNames
			end
		end
	end

	for familyName, _ in pairs(standaloneFamilies) do
		table.insert(items, {
			key = familyName,
			displayName = familyName,
			type = "familyName",
		})
	end

	-- Sort items using current sort mode
	if self.Sort then
		items = self.Sort:SortItems(items)
	else
		-- Fallback to alphabetical if sort system not initialized
		table.sort(items, function(a, b) return a.displayName < b.displayName end)
	end

	-- Apply capability filters
	if self:HasActiveFilters() and not self:AllFiltersActive() then
		local filteredItems = {}
		for _, item in ipairs(items) do
			if self:PassesCapabilityFilter(item) then
				table.insert(filteredItems, item)
			end
		end

		items = filteredItems
		addon:DebugUI("RMB_CAP_FILTER: Filtered main grid - showing " .. #items .. " items")
	end

	-- Apply search filter
	if self.Search and self.Search:IsActive() then
		local searchFilteredItems = {}
		for _, item in ipairs(items) do
			if self.Search:ItemMatchesSearch(item.type, item.key, nil) then
				table.insert(searchFilteredItems, item)
			end
		end

		items = searchFilteredItems
		addon:DebugUI("BROWSER_SEARCH: Filtered main grid - showing " .. #items .. " items")
	end

	-- Prepare cards with data
	local cardsData = {}
	for i, item in ipairs(items) do
		if i <= #self.cardPool then
			local card = self.cardPool[i]
			-- Store data on card without updating yet
			card.data = item
			table.insert(cardsData, {
				card = card,
				data = item,
			})
		end
	end

	-- Layout cards immediately (positioning is cheap)
	local cards = {}
	for _, cardData in ipairs(cardsData) do
		table.insert(cards, cardData.card)
	end

	self:LayoutCards(cards)
	-- NEW APPROACH: Only update visible cards initially to prevent opening FPS spike
	-- CheckVisibleCards will update cards as they scroll into view
	-- Restore scroll position if needed (before visibility check so cards update at correct position)
	if self.savedMainScrollPosition then
		addon:DebugUI("Scheduling scroll position restore to: " .. tostring(self.savedMainScrollPosition))
		C_Timer.After(MountBrowser.TIMING.NAVIGATION_UPDATE_DELAY, function()
			if self.mainFrame and self.mainFrame.scrollFrame then
				addon:DebugUI("Restoring scroll position to: " .. tostring(self.savedMainScrollPosition))
				self.mainFrame.scrollFrame:SetVerticalScroll(self.savedMainScrollPosition)
				self.savedMainScrollPosition = nil
				-- Trigger visibility check after scroll restore
				MountBrowser:CheckVisibleCards()
			end
		end)
	else
		addon:DebugUI("No saved scroll position to restore")
	end

	-- Start visibility checking - this will update only visible cards
	self:StartVisibilityCheck()
end

-- Load Level 2: Family grid (families in a supergroup)
function MountBrowser:LoadFamilyGrid(supergroupName, skipStackPush)
	if not addon.SuperGroupManager then return end

	-- Save main grid scroll position if not already navigating
	if #self.navigationStack == 0 and self.mainFrame and self.mainFrame.scrollFrame then
		self.savedMainScrollPosition = self.mainFrame.scrollFrame:GetVerticalScroll()
	end

	-- Update title to supergroup name
	self.mainFrame.title:SetText(supergroupName)
	self.mainFrame.backButton:Show()
	-- Add current state to navigation stack (unless called from NavigateBack)
	if not skipStackPush then
		table.insert(self.navigationStack, {
			level = "supergroup",
			supergroupName = supergroupName,
		})
	end

	-- Get families in supergroup (use dynamic grouping that respects trait strictness)
	local families = {}
	-- Check if families should be kept together (inverted logic)
	local groupTogether = addon:GetSetting("browserGroupFamiliesTogether")
	if groupTogether == nil then
		groupTogether = false -- Default to separated (matches summon pool)
	end

	if addon.GetSuperGroupFamilies and not groupTogether then
		-- Use the helper function that respects dynamic grouping (trait separation)
		families = addon:GetSuperGroupFamilies(supergroupName)
	elseif addon.processedData and not groupTogether and addon.processedData.dynamicSuperGroupMap and addon.processedData.dynamicSuperGroupMap[supergroupName] then
		-- Fallback to dynamic map directly (trait separation)
		families = addon.processedData.dynamicSuperGroupMap[supergroupName]
	elseif addon.processedData and addon.processedData.superGroupMap and addon.processedData.superGroupMap[supergroupName] then
		-- Use original map (no trait separation) when keeping families together OR as last resort
		families = addon.processedData.superGroupMap[supergroupName]
	end

	-- Build items list
	local items = {}
	for _, familyName in ipairs(families) do
		-- Check if families should be kept together (inverted logic)
		local groupTogether = addon:GetSetting("browserGroupFamiliesTogether")
		if groupTogether == nil then
			groupTogether = false
		end

		-- Double-check this family isn't standalone due to trait strictness
		local isStandalone = false
		if not groupTogether then
			-- When keeping families separated (default), check dynamic standalone families
			if addon.IsFamilyStandalone then
				isStandalone = addon:IsFamilyStandalone(familyName)
			elseif addon.processedData and addon.processedData.dynamicStandaloneFamilies then
				isStandalone = addon.processedData.dynamicStandaloneFamilies[familyName] == true
			end
		end

		-- When keeping families together, families never appear as standalone (they stay in supergroups)
		-- Only include if not standalone
		if not isStandalone then
			table.insert(items, {
				key = familyName,
				displayName = familyName,
				type = "familyName",
				parentSupergroup = supergroupName, -- Pass supergroup for camera inheritance
			})
		end
	end

	-- Sort items using current sort mode
	if self.Sort then
		items = self.Sort:SortItems(items)
	else
		-- Fallback to alphabetical if sort system not initialized
		table.sort(items, function(a, b) return a.displayName < b.displayName end)
	end

	-- Apply capability filters
	if self:HasActiveFilters() and not self:AllFiltersActive() then
		local filteredItems = {}
		for _, item in ipairs(items) do
			if self:PassesCapabilityFilter(item) then
				table.insert(filteredItems, item)
			end
		end

		items = filteredItems
		addon:DebugUI("RMB_CAP_FILTER: Filtered family grid - showing " .. #items .. " families")
	end

	-- Apply search filter (skip if supergroup matched by name)
	if self.Search and self.Search:IsActive() then
		-- If the supergroup itself matched by name, show ALL families (don't filter)
		local supergroupMatchedByName = self.Search:ItemMatchedByName("supergroup", supergroupName)
		if not supergroupMatchedByName then
			local searchFilteredItems = {}
			for _, item in ipairs(items) do
				if self.Search:ItemMatchesSearch(item.type, item.key, supergroupName) then
					table.insert(searchFilteredItems, item)
				end
			end

			items = searchFilteredItems
			addon:DebugUI("BROWSER_SEARCH: Filtered family grid - showing " .. #items .. " families")
		else
			addon:DebugUI("BROWSER_SEARCH: Supergroup matched by name, showing all families")
		end
	end

	-- Prepare cards with data
	local cardsData = {}
	for i, item in ipairs(items) do
		if i <= #self.cardPool then
			local card = self.cardPool[i]
			-- Store data on card without updating yet
			card.data = item
			table.insert(cardsData, {
				card = card,
				data = item,
			})
		end
	end

	-- Layout cards immediately (positioning is cheap)
	local cards = {}
	for _, cardData in ipairs(cardsData) do
		table.insert(cards, cardData.card)
	end

	self:LayoutCards(cards)
	-- Only update visible cards initially to prevent FPS spike
	-- Start visibility checking - this will update only visible cards
	self:StartVisibilityCheck()
end

-- Load Level 3: Mount grid (mounts in a family)
function MountBrowser:LoadMountGrid(familyName, fromSupergroup, skipStackPush)
	if not addon.MountDataManager then return end

	-- Save main grid scroll position if navigating from main grid (no supergroup = standalone family)
	if not fromSupergroup and #self.navigationStack == 0 and self.mainFrame and self.mainFrame.scrollFrame then
		self.savedMainScrollPosition = self.mainFrame.scrollFrame:GetVerticalScroll()
	end

	-- Update title to family name
	self.mainFrame.title:SetText(familyName)
	self.mainFrame.backButton:Show()
	-- Add current state to navigation stack (unless called from NavigateBack)
	if not skipStackPush then
		table.insert(self.navigationStack, {
			level = "family",
			familyName = familyName,
			fromSupergroup = fromSupergroup,
		})
	end

	-- Get mounts in family (both collected and uncollected)
	local mounts = {}
	-- Add collected mounts
	if addon.processedData and addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName] then
		local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
		for _, mountID in ipairs(mountIDs) do
			local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
			if mountInfo then
				-- Add mountID to the info
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

	-- Add uncollected mounts
	if addon.processedData and addon.processedData.familyToUncollectedMountIDsMap and
			addon.processedData.familyToUncollectedMountIDsMap[familyName] then
		local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[familyName]
		for _, mountID in ipairs(mountIDs) do
			local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
			if mountInfo then
				-- Add mountID to the info
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

	-- Build items list
	local items = {}
	for _, mount in ipairs(mounts) do
		table.insert(items, {
			key = "mount_" .. mount.mountID, -- Use mount_ID format for proper weight lookup
			displayName = mount.name,
			type = "mount",
			mountData = mount,
			parentFamily = familyName, -- Pass family context for camera inheritance
		})
	end

	-- Sort items using current sort mode
	if self.Sort then
		items = self.Sort:SortItems(items)
	else
		-- Fallback to alphabetical if sort system not initialized
		table.sort(items, function(a, b) return a.displayName < b.displayName end)
	end

	-- Apply capability filters
	if self:HasActiveFilters() and not self:AllFiltersActive() then
		local filteredItems = {}
		for _, item in ipairs(items) do
			if self:PassesCapabilityFilter(item) then
				table.insert(filteredItems, item)
			end
		end

		items = filteredItems
		addon:DebugUI("RMB_CAP_FILTER: Filtered mount grid - showing " .. #items .. " mounts")
	end

	-- Apply search filter (skip if family matched by name)
	if self.Search and self.Search:IsActive() then
		-- If the family itself matched by name, show ALL mounts (don't filter)
		local familyMatchedByName = self.Search:ItemMatchedByName("familyName", familyName)
		if not familyMatchedByName then
			local searchFilteredItems = {}
			for _, item in ipairs(items) do
				if self.Search:ItemMatchesSearch(item.type, item.key, familyName) then
					table.insert(searchFilteredItems, item)
				end
			end

			items = searchFilteredItems
			addon:DebugUI("BROWSER_SEARCH: Filtered mount grid - showing " .. #items .. " mounts")
		else
			addon:DebugUI("BROWSER_SEARCH: Family matched by name, showing all mounts")
		end
	end

	-- Prepare cards with data
	local cardsData = {}
	for i, item in ipairs(items) do
		if i <= #self.cardPool then
			local card = self.cardPool[i]
			-- Store data on card without updating yet
			card.data = item
			table.insert(cardsData, {
				card = card,
				data = item,
			})
		end
	end

	-- Layout cards immediately (positioning is cheap)
	local cards = {}
	for _, cardData in ipairs(cardsData) do
		table.insert(cards, cardData.card)
	end

	self:LayoutCards(cards)
	-- Only update visible cards initially to prevent FPS spike
	-- Start visibility checking - this will update only visible cards
	self:StartVisibilityCheck()
end

-- ============================================================================
-- NAVIGATION
-- ============================================================================
-- Handle card click
function MountBrowser:OnCardClick(card)
	if not card.data then return end

	local data = card.data
	if data.type == "supergroup" then
		-- Navigate to family grid
		self:LoadFamilyGrid(data.key)
	elseif data.type == "familyName" then
		-- Check if this family has only 1 mount total (individual mount - don't navigate)
		local mountCount = 0
		if addon.processedData then
			-- Count collected mounts
			if addon.processedData.familyToMountIDsMap then
				local mountIDs = addon.processedData.familyToMountIDsMap[data.key]
				if mountIDs then
					mountCount = mountCount + #mountIDs
				end
			end

			-- Count uncollected mounts
			if addon.processedData.familyToUncollectedMountIDsMap then
				local uncollectedMountIDs = addon.processedData.familyToUncollectedMountIDsMap[data.key]
				if uncollectedMountIDs then
					mountCount = mountCount + #uncollectedMountIDs
				end
			end
		end

		-- If only 1 mount total, don't navigate (nothing to show inside)
		if mountCount <= 1 then
			addon:DebugUI("Skipping navigation for individual mount family: " .. data.key)
			return
		end

		-- Check if we're in a supergroup or main
		local fromSupergroup = nil
		if #self.navigationStack > 0 then
			local lastNav = self.navigationStack[#self.navigationStack]
			-- If we're in a supergroup view, use that as context
			if lastNav.level == "supergroup" then
				fromSupergroup = lastNav.supergroupName
			end
		end

		-- Navigate to mount grid
		self:LoadMountGrid(data.key, fromSupergroup)
	elseif data.type == "mount" then
		-- Individual mount - could open preview or do nothing
		addon:DebugUI("Clicked mount: " .. data.key)
	end
end

-- Handle card summoning (Ctrl/Shift + left click)
function MountBrowser:SummonFromCard(card)
	if not card.data then return end

	if not addon.MountSummon or not addon.MountSummon.SummonMount then
		addon:DebugUI("MountSummon system not available")
		return
	end

	local data = card.data
	if data.type == "supergroup" then
		-- Summon random mount from supergroup (ignore weights)
		local allMounts = {}
		-- Get all families in supergroup
		local families = {}
		if addon.GetSuperGroupFamilies then
			families = addon:GetSuperGroupFamilies(data.key)
		elseif addon.processedData and addon.processedData.superGroupMap then
			families = addon.processedData.superGroupMap[data.key] or {}
		end

		-- Collect all mounts from all families
		for _, familyName in ipairs(families) do
			if addon.processedData and addon.processedData.familyToMountIDsMap then
				local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
				if mountIDs then
					for _, mountID in ipairs(mountIDs) do
						table.insert(allMounts, mountID)
					end
				end
			end
		end

		-- Pick random mount
		if #allMounts > 0 then
			local randomIndex = math.random(1, #allMounts)
			local mountID = allMounts[randomIndex]
			addon:DebugUI("Summoning random mount from supergroup " .. data.key .. ": " .. mountID)
			addon.MountSummon:SummonMount(mountID)
		else
			addon:DebugUI("No collected mounts found in supergroup: " .. data.key)
		end
	elseif data.type == "familyName" then
		-- Summon random mount from family (ignore weights)
		local allMounts = {}
		if addon.processedData and addon.processedData.familyToMountIDsMap then
			local mountIDs = addon.processedData.familyToMountIDsMap[data.key]
			if mountIDs then
				for _, mountID in ipairs(mountIDs) do
					table.insert(allMounts, mountID)
				end
			end
		end

		-- Pick random mount
		if #allMounts > 0 then
			local randomIndex = math.random(1, #allMounts)
			local mountID = allMounts[randomIndex]
			addon:DebugUI("Summoning random mount from family " .. data.key .. ": " .. mountID)
			addon.MountSummon:SummonMount(mountID)
		else
			-- No collected mounts - check if this is a single-mount family that's uncollected
			local uncollectedMounts = {}
			if addon.processedData and addon.processedData.familyToUncollectedMountIDsMap then
				local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap[data.key]
				if uncollectedIDs then
					for _, mountID in ipairs(uncollectedIDs) do
						table.insert(uncollectedMounts, mountID)
					end
				end
			end

			-- If this is a single-mount family with only an uncollected mount, show error
			if #uncollectedMounts == 1 then
				UIErrorsFrame:AddMessage("Can't summon uncollected mount.", 1.0, 0.1, 0.1, 1.0)
				addon:DebugUI("Cannot summon uncollected single-mount family: " .. data.key)
			else
				addon:DebugUI("No collected mounts found in family: " .. data.key)
			end
		end
	elseif data.type == "mount" then
		-- Summon specific mount - check if collected first
		local mountID = tonumber(string.match(data.key, "^mount_(%d+)$"))
		if mountID then
			-- Check if mount is collected
			local _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
			if isCollected then
				addon:DebugUI("Summoning specific mount: " .. mountID)
				addon.MountSummon:SummonMount(mountID)
			else
				-- Show error message for uncollected mount
				UIErrorsFrame:AddMessage("Can't summon uncollected mount.", 1.0, 0.1, 0.1, 1.0)
				addon:DebugUI("Cannot summon uncollected mount: " .. mountID)
			end
		end
	end
end

-- Navigate back
-- Navigate back one level
function MountBrowser:NavigateBack()
	if #self.navigationStack == 0 then
		-- Already at main, do nothing
		return
	end

	-- Remove current level from stack
	local currentLevel = table.remove(self.navigationStack)
	-- Determine where to go based on what's left in the stack
	if #self.navigationStack == 0 then
		-- Stack is empty, go back to main
		self:LoadMainGrid()
	else
		-- Look at the previous level
		local previousLevel = self.navigationStack[#self.navigationStack]
		if previousLevel.level == "supergroup" then
			-- Go back to supergroup view
			self:LoadFamilyGrid(previousLevel.supergroupName, true) -- skipStackPush = true
		elseif previousLevel.level == "family" then
			-- Go back to family view
			self:LoadMountGrid(previousLevel.familyName, previousLevel.fromSupergroup, true) -- skipStackPush = true
		else
			-- Fallback: go to main
			self:LoadMainGrid()
		end
	end
end

-- ============================================================================
