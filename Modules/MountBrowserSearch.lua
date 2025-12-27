-- MountBrowserSearch.lua
-- Search system specifically for the Mount Browser
-- Handles hierarchical search with result tracking and display
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- BROWSER SEARCH SYSTEM
-- ============================================================================
local MountBrowserSearch = {}
MountBrowser.Search = MountBrowserSearch
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function MountBrowserSearch:Initialize()
	addon:DebugUI("Initializing browser search system...")
	-- Search state
	self.active = false
	self.searchTerm = ""
	self.results = {
		supergroups = {}, -- Supergroups that match (by name or contain matching families/mounts)
		families = {},  -- Families that match (by name or contain matching mounts)
		mounts = {},    -- Individual mounts that match
		hierarchy = {}, -- Full hierarchy: supergroup -> families -> mounts
	}
	-- Configuration
	self.minSearchLength = 1
	self.maxDisplayResults = 12 -- Max results to show in tooltip list
	addon:DebugUI("Browser search system initialized")
end

-- ============================================================================
-- SEARCH EXECUTION
-- ============================================================================
function MountBrowserSearch:Execute(searchTerm)
	local cleanTerm = (searchTerm or ""):trim():lower()
	-- Reset if empty
	if cleanTerm == "" then
		self:Clear()
		return
	end

	-- Check minimum length
	if #cleanTerm < self.minSearchLength then
		addon:DebugUI("Browser search term too short: " .. cleanTerm)
		return
	end

	addon:DebugUI("Executing browser search for: '" .. cleanTerm .. "'")
	-- Clear representative mount cache to force selection from search results
	if MountBrowser.representativeMountCache then
		MountBrowser.representativeMountCache = {}
		addon:DebugUI("Cleared representative mount cache for search")
	end

	-- Clear card current data keys to force full updates with new search highlights
	if MountBrowser.cardPool then
		for _, card in ipairs(MountBrowser.cardPool) do
			card.currentDataKey = nil
		end

		addon:DebugUI("Cleared card data keys for search update")
	end

	-- Clear previous results
	self.results = {
		supergroups = {},
		families = {},
		mounts = {},
		hierarchy = {},
	}
	-- Build hierarchical search results
	self:BuildHierarchicalResults(cleanTerm)
	-- Update state
	self.active = true
	self.searchTerm = searchTerm or ""
	-- Show clear search button
	if MountBrowser.mainFrame and MountBrowser.mainFrame.clearSearchButton then
		MountBrowser.mainFrame.clearSearchButton:Show()
	end

	addon:DebugUI(string.format("Browser search found: %d supergroups, %d families, %d mounts",
		#self.results.supergroups, #self.results.families, #self.results.mounts))
	-- Trigger browser refresh
	if MountBrowser.LoadMainGrid then
		MountBrowser:LoadMainGrid()
	end
end

-- ============================================================================
-- HIERARCHICAL SEARCH
-- ============================================================================
function MountBrowserSearch:BuildHierarchicalResults(searchTerm)
	if not addon.processedData then return end

	-- Search through all supergroups
	if addon.SuperGroupManager then
		local supergroups = addon.SuperGroupManager:GetAllSuperGroups()
		for _, sg in ipairs(supergroups) do
			self:ProcessSupergroup(sg, searchTerm)
		end
	end

	-- Search through standalone families
	local standaloneFamilies = addon.processedData.dynamicStandaloneFamilies or
			addon.processedData.standaloneFamilyNames or {}
	for familyName, _ in pairs(standaloneFamilies) do
		self:ProcessFamily(familyName, nil, searchTerm)
	end
end

function MountBrowserSearch:ProcessSupergroup(supergroup, searchTerm)
	local sgName = supergroup.name
	local sgDisplayName = (supergroup.displayName or sgName):lower()
	-- Track matching families and mounts in this supergroup
	local matchingFamilies = {}
	local matchingMounts = {}
	-- Get families in this supergroup
	local families = addon:GetSuperGroupFamilies(sgName)
	-- Check each family
	for _, familyName in ipairs(families) do
		local familyMatches = self:ProcessFamily(familyName, sgName, searchTerm)
		if familyMatches.matchedFamily or #familyMatches.matchedMounts > 0 then
			table.insert(matchingFamilies, {
				name = familyName,
				matchedByName = familyMatches.matchedFamily,
				mounts = familyMatches.matchedMounts,
			})
			-- Add mounts to supergroup's mount list
			for _, mount in ipairs(familyMatches.matchedMounts) do
				table.insert(matchingMounts, mount)
			end
		end
	end

	-- Check if supergroup name matches
	local sgNameMatches = sgDisplayName:find(searchTerm, 1, true) ~= nil
	-- Include supergroup if it matches by name OR contains matching content
	if sgNameMatches or #matchingFamilies > 0 then
		table.insert(self.results.supergroups, {
			name = sgName,
			displayName = supergroup.displayName or sgName,
			matchedByName = sgNameMatches,
			families = matchingFamilies,
			totalMatches = #matchingMounts,
		})
		-- Store in hierarchy
		if not self.results.hierarchy[sgName] then
			self.results.hierarchy[sgName] = {}
		end

		for _, familyData in ipairs(matchingFamilies) do
			self.results.hierarchy[sgName][familyData.name] = familyData.mounts
		end
	end
end

function MountBrowserSearch:ProcessFamily(familyName, supergroupName, searchTerm)
	local result = {
		matchedFamily = false,
		matchedMounts = {},
	}
	-- Check if family name matches
	local familyNameLower = familyName:lower()
	if familyNameLower:find(searchTerm, 1, true) then
		result.matchedFamily = true
	end

	-- Search through mounts in this family
	local mountIDs = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[familyName] or {}
	for _, mountID in ipairs(mountIDs) do
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
		if mountInfo and mountInfo.name then
			if mountInfo.name:lower():find(searchTerm, 1, true) then
				table.insert(result.matchedMounts, {
					mountID = mountID,
					name = mountInfo.name,
				})
				table.insert(self.results.mounts, {
					mountID = mountID,
					name = mountInfo.name,
					familyName = familyName,
					supergroupName = supergroupName,
				})
			end
		end
	end

	-- Also check uncollected mounts if enabled
	if addon:GetSetting("showUncollectedMounts") then
		local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[familyName] or {}
		for _, mountID in ipairs(uncollectedIDs) do
			local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
			if mountInfo and mountInfo.name then
				if mountInfo.name:lower():find(searchTerm, 1, true) then
					table.insert(result.matchedMounts, {
						mountID = mountID,
						name = mountInfo.name,
					})
					table.insert(self.results.mounts, {
						mountID = mountID,
						name = mountInfo.name,
						familyName = familyName,
						supergroupName = supergroupName,
					})
				end
			end
		end
	end

	-- Add to standalone families list if it matched and isn't in a supergroup
	if not supergroupName and (result.matchedFamily or #result.matchedMounts > 0) then
		table.insert(self.results.families, {
			name = familyName,
			matchedByName = result.matchedFamily,
			mounts = result.matchedMounts,
			totalMatches = #result.matchedMounts,
		})
		-- Store in hierarchy for standalone families (use special key)
		if not self.results.hierarchy["__standalone__"] then
			self.results.hierarchy["__standalone__"] = {}
		end

		self.results.hierarchy["__standalone__"][familyName] = result.matchedMounts
	end

	return result
end

-- ============================================================================
-- FILTERING HELPERS
-- ============================================================================
-- Check if an item should be displayed based on search results
function MountBrowserSearch:ItemMatchesSearch(itemType, itemKey, parentContext)
	if not self.active then
		return true -- No search active, show everything
	end

	if itemType == "supergroup" then
		-- Check if this supergroup has matches
		for _, sg in ipairs(self.results.supergroups) do
			if sg.name == itemKey then
				return true
			end
		end

		return false
	elseif itemType == "familyName" then
		-- Check if in standalone families
		for _, fam in ipairs(self.results.families) do
			if fam.name == itemKey then
				return true
			end
		end

		-- Check if in a supergroup's results
		if parentContext then
			local sgResults = self.results.hierarchy[parentContext]
			if sgResults and sgResults[itemKey] then
				return true
			end
		end

		return false
	elseif itemType == "mount" then
		-- Extract mount ID from key (format: "mount_12345")
		local mountID = tonumber(string.match(itemKey, "^mount_(%d+)$"))
		if not mountID then return false end

		-- Check if this mount is in results
		for _, mount in ipairs(self.results.mounts) do
			if mount.mountID == mountID then
				-- If parent context provided, verify it matches
				if parentContext then
					return mount.familyName == parentContext
				end

				return true
			end
		end

		return false
	end

	return true
end

-- Get matching families for a supergroup
function MountBrowserSearch:GetMatchingFamilies(supergroupName)
	if not self.active then return nil end

	local sgResults = self.results.hierarchy[supergroupName]
	if not sgResults then return nil end

	local families = {}
	for familyName, _ in pairs(sgResults) do
		table.insert(families, familyName)
	end

	return families
end

-- Get matching mounts for a family
function MountBrowserSearch:GetMatchingMounts(familyName, supergroupName)
	if not self.active then return nil end

	-- Try supergroup context first
	if supergroupName then
		local sgResults = self.results.hierarchy[supergroupName]
		if sgResults and sgResults[familyName] then
			return sgResults[familyName]
		end
	end

	-- Try standalone families
	local standaloneResults = self.results.hierarchy["__standalone__"]
	if standaloneResults and standaloneResults[familyName] then
		return standaloneResults[familyName]
	end

	return nil
end

-- ============================================================================
-- RESULT DISPLAY HELPERS
-- ============================================================================
-- Get formatted result text for displaying on a card
function MountBrowserSearch:GetCardResultText(itemType, itemKey)
	if not self.active then return nil end

	local matches = {}
	local totalCount = 0
	if itemType == "supergroup" then
		-- Find this supergroup's results
		for _, sg in ipairs(self.results.supergroups) do
			if sg.name == itemKey then
				totalCount = sg.totalMatches
				-- Collect all mount names from all families
				for _, familyData in ipairs(sg.families) do
					for _, mount in ipairs(familyData.mounts) do
						table.insert(matches, mount.name)
					end
				end

				break
			end
		end
	elseif itemType == "familyName" then
		-- Find this family's results
		local familyData = nil
		-- Check standalone families
		for _, fam in ipairs(self.results.families) do
			if fam.name == itemKey then
				familyData = fam
				break
			end
		end

		-- Check supergroup families if not found
		if not familyData then
			for _, sg in ipairs(self.results.supergroups) do
				for _, fam in ipairs(sg.families) do
					if fam.name == itemKey then
						familyData = fam
						break
					end
				end

				if familyData then break end
			end
		end

		if familyData then
			totalCount = #familyData.mounts
			for _, mount in ipairs(familyData.mounts) do
				table.insert(matches, mount.name)
			end
		end
	end

	if totalCount == 0 then return nil end

	-- Format the text
	local resultText = string.format("|cffffd700%d result%s:|r",
		totalCount, totalCount == 1 and "" or "s")
	-- Add up to maxDisplayResults mount names
	local displayCount = math.min(#matches, self.maxDisplayResults)
	for i = 1, displayCount do
		resultText = resultText .. "\n" .. matches[i]
	end

	-- Add "..." if there are more
	if #matches > self.maxDisplayResults then
		resultText = resultText .. " ..."
	end

	return resultText
end

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================
function MountBrowserSearch:Clear()
	addon:DebugUI("Clearing browser search")
	-- Clear representative mount cache when clearing search
	if MountBrowser.representativeMountCache then
		MountBrowser.representativeMountCache = {}
		addon:DebugUI("Cleared representative mount cache for search clear")
	end

	-- Clear card current data keys to force full updates (remove highlights)
	if MountBrowser.cardPool then
		for _, card in ipairs(MountBrowser.cardPool) do
			card.currentDataKey = nil
		end

		addon:DebugUI("Cleared card data keys for highlight removal")
	end

	self.active = false
	self.searchTerm = ""
	self.results = {
		supergroups = {},
		families = {},
		mounts = {},
		hierarchy = {},
	}
	-- Hide clear search button
	if MountBrowser.mainFrame and MountBrowser.mainFrame.clearSearchButton then
		MountBrowser.mainFrame.clearSearchButton:Hide()
	end

	-- Trigger browser refresh
	if MountBrowser.LoadMainGrid then
		MountBrowser:LoadMainGrid()
	end
end

function MountBrowserSearch:IsActive()
	return self.active
end

function MountBrowserSearch:GetSearchTerm()
	return self.searchTerm
end

function MountBrowserSearch:GetTotalResults()
	return #self.results.supergroups + #self.results.families + #self.results.mounts
end

-- Check if an item matched by its own name (vs only by children)
-- If an item matched by name, we should show ALL its contents, not filter them
function MountBrowserSearch:ItemMatchedByName(itemType, itemKey)
	if not self.active then
		return false
	end

	if itemType == "supergroup" then
		for _, sg in ipairs(self.results.supergroups) do
			if sg.name == itemKey then
				return sg.matchedByName == true
			end
		end
	elseif itemType == "familyName" then
		-- Check standalone families
		for _, fam in ipairs(self.results.families) do
			if fam.name == itemKey then
				return fam.matchedByName == true
			end
		end

		-- Check families within supergroups
		for _, sg in ipairs(self.results.supergroups) do
			for _, fam in ipairs(sg.families) do
				if fam.name == itemKey then
					return fam.matchedByName == true
				end
			end
		end
	end

	return false
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
function MountBrowserSearch:StripColorCodes(text)
	if not text then return "" end

	return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end
