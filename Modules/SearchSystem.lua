-- SearchSystem.lua - Modular Search Implementation
-- Handles all search functionality for mount groups and individual mounts
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("SearchSystem.lua START.")
-- ============================================================================
-- SEARCH SYSTEM CLASS
-- ============================================================================
local SearchSystem = {}
addon.SearchSystem = SearchSystem
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function SearchSystem:Initialize()
	addon:DebugUI("Initializing search system...")
	-- Search state
	self.searchActive = false
	self.searchTerm = ""
	self.searchResults = {}
	-- Search configuration
	self.minSearchLength = 1
	self.maxResults = 50
	addon:DebugUI("Search system initialized")
end

-- ============================================================================
-- SEARCH EXECUTION
-- ============================================================================
function SearchSystem:ExecuteSearch(searchTerm)
	local cleanTerm = (searchTerm or ""):trim():lower()
	-- Reset if empty search
	if cleanTerm == "" then
		self:ClearSearch()
		return
	end

	-- Check minimum length
	if #cleanTerm < self.minSearchLength then
		addon:DebugUI("Search term too short: " .. cleanTerm)
		return
	end

	addon:DebugUI("Executing search for: '" .. cleanTerm .. "'")
	-- Get all available groups
	local allGroups = addon:GetDisplayableGroups() or {}
	local results = {}
	local resultCount = 0
	-- Search through groups
	for _, groupData in ipairs(allGroups) do
		if resultCount >= self.maxResults then
			addon:DebugUI("Hit max results limit (" .. self.maxResults .. ")")
			break
		end

		-- Validate group data structure
		if groupData and groupData.key and groupData.type then
			if self:GroupMatchesSearch(groupData, cleanTerm) then
				table.insert(results, groupData)
				resultCount = resultCount + 1
				addon:DebugUI("Match found - " .. (groupData.displayName or groupData.key))
			end
		else
			addon:AlwaysPrint(" Invalid group data structure encountered")
		end
	end

	-- Sort results by relevance
	table.sort(results, function(a, b)
		return self:GetSearchRelevanceScore(a, cleanTerm) > self:GetSearchRelevanceScore(b, cleanTerm)
	end)
	-- Update search state
	self.searchActive = true
	self.searchTerm = searchTerm or ""
	self.searchResults = results
	addon:DebugUI("Found " .. #results .. " results for '" .. cleanTerm .. "'")
	-- Trigger UI refresh
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
		addon:DebugUI("UI refresh triggered after search")
	else
		addon:AlwaysPrint("PopulateFamilyManagementUI not available")
	end
end

-- ============================================================================
-- SEARCH MATCHING LOGIC
-- ============================================================================
function SearchSystem:GroupMatchesSearch(groupData, searchTerm)
	if not groupData or not searchTerm then
		return false
	end

	-- Check group/family name (remove color codes first)
	local displayName = self:StripColorCodes(groupData.displayName or groupData.key or ""):lower()
	if displayName:find(searchTerm, 1, true) then
		return true
	end

	-- For families, also check individual mount names
	if groupData.type == "familyName" then
		return self:FamilyHasMountMatching(groupData.key, searchTerm)
	end

	-- For supergroups, check family names and mount names within
	if groupData.type == "superGroup" then
		return self:SuperGroupHasMatching(groupData.key, searchTerm)
	end

	return false
end

function SearchSystem:FamilyHasMountMatching(familyName, searchTerm)
	-- Check collected mounts
	local mountIDs = addon.processedData.familyToMountIDsMap and
			addon.processedData.familyToMountIDsMap[familyName] or {}
	for _, mountID in ipairs(mountIDs) do
		local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
		if mountInfo and mountInfo.name then
			if mountInfo.name:lower():find(searchTerm, 1, true) then
				return true
			end
		end
	end

	-- Check uncollected mounts if enabled
	if addon:GetSetting("showUncollectedMounts") then
		local uncollectedIDs = addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[familyName] or {}
		for _, mountID in ipairs(uncollectedIDs) do
			local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
			if mountInfo and mountInfo.name then
				if mountInfo.name:lower():find(searchTerm, 1, true) then
					return true
				end
			end
		end
	end

	return false
end

function SearchSystem:SuperGroupHasMatching(superGroupName, searchTerm)
	-- Get families in this supergroup
	local familyNames = addon.processedData.dynamicSuperGroupMap and
			addon.processedData.dynamicSuperGroupMap[superGroupName] or
			(addon.processedData.superGroupMap and addon.processedData.superGroupMap[superGroupName]) or {}
	-- Check each family name
	for _, familyName in ipairs(familyNames) do
		-- Check family name itself
		if familyName:lower():find(searchTerm, 1, true) then
			return true
		end

		-- Check mounts in this family
		if self:FamilyHasMountMatching(familyName, searchTerm) then
			return true
		end
	end

	return false
end

-- ============================================================================
-- SEARCH RELEVANCE SCORING
-- ============================================================================
function SearchSystem:GetSearchRelevanceScore(groupData, searchTerm)
	local score = 0
	local displayName = self:StripColorCodes(groupData.displayName or groupData.key):lower()
	-- Exact match gets highest score
	if displayName == searchTerm then
		score = score + 100
	end

	-- Starts with search term gets high score
	if displayName:sub(1, #searchTerm) == searchTerm then
		score = score + 50
	end

	-- Contains search term gets medium score
	if displayName:find(searchTerm, 1, true) then
		score = score + 25
	end

	-- Bonus for shorter names (more specific matches)
	score = score + math.max(0, 50 - #displayName)
	-- Bonus for collected items
	if groupData.mountCount and groupData.mountCount > 0 then
		score = score + 10
	end

	return score
end

-- ============================================================================
-- SEARCH STATE MANAGEMENT
-- ============================================================================
function SearchSystem:ClearSearch()
	addon:DebugUI("Clearing search")
	-- Reset state
	self.searchActive = false
	self.searchTerm = ""
	self.searchResults = {}
	-- Trigger UI refresh
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
		addon:DebugUI("UI refresh triggered after clearing search")
	else
		addon:AlwaysPrint("PopulateFamilyManagementUI not available")
	end
end

function SearchSystem:IsSearchActive()
	return self.searchActive
end

function SearchSystem:GetSearchTerm()
	return self.searchTerm
end

function SearchSystem:GetSearchResults()
	return self.searchResults or {}
end

function SearchSystem:GetSearchResultCount()
	return #(self.searchResults or {})
end

-- ============================================================================
-- UI INTEGRATION HELPERS
-- ============================================================================
function SearchSystem:GetSearchStatus()
	if not self.searchActive then
		return nil
	end

	local resultCount = self:GetSearchResultCount()
	local statusText = string.format("Found %d result%s", resultCount, resultCount == 1 and "" or "s")
	if resultCount >= self.maxResults then
		statusText = statusText .. string.format(" (showing first %d)", self.maxResults)
	end

	return statusText .. " for '" .. self.searchTerm .. "'"
end

function SearchSystem:ShouldShowAllResults()
	-- When searching, show all results on one page (up to maxResults)
	return self.searchActive
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
function SearchSystem:StripColorCodes(text)
	if not text then return "" end

	-- Remove WoW color codes like |cffFFFFFF and |r
	return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

-- ============================================================================
-- INTEGRATION WITH CORE ADDON
-- ============================================================================
function addon:InitializeSearchSystem()
	if not self.SearchSystem then
		addon:DebugUI("ERROR - SearchSystem not found!")
		return
	end

	self.SearchSystem:Initialize()
	addon:DebugUI("Integration complete")
end

-- Public interface methods for other modules
function addon:StartSearch(searchTerm)
	if self.SearchSystem then
		self.SearchSystem:ExecuteSearch(searchTerm)
	end
end

function addon:ClearSearch()
	if self.SearchSystem then
		self.SearchSystem:ClearSearch()
	end
end

function addon:IsSearchActive()
	return self.SearchSystem and self.SearchSystem:IsSearchActive() or false
end

function addon:GetSearchResults()
	return self.SearchSystem and self.SearchSystem:GetSearchResults() or {}
end

function addon:GetSearchStatus()
	return self.SearchSystem and self.SearchSystem:GetSearchStatus() or nil
end

addon:DebugCore("SearchSystem.lua END.")
