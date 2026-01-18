-- FavoriteSync.lua - Favorite Mount Synchronization System
local addonName, addonTable = ...
local addon = RandomMountBuddy
addon:DebugCore("FavoriteSync.lua START (Optimized).")
-- ============================================================================
-- FAVORITE SYNC CLASS
-- ============================================================================
local FavoriteSync = {}
addon.FavoriteSync = FavoriteSync
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function FavoriteSync:Initialize()
	addon:DebugSync("Initializing favorite mount synchronization system...")
	-- Track favorite changes
	self.lastFavoriteHash = nil
	self.syncInProgress = false
	-- Track if we've done the initial login sync
	self.hasPerformedLoginSync = false
	-- Track journal hook status
	self.journalHooked = false
	self.mountJournalHooked = false
	-- Clean up any existing periodic timers (in case of reload)
	if self.favoriteCheckTimer then
		self.favoriteCheckTimer:Cancel()
		self.favoriteCheckTimer = nil
		addon:DebugSync("Cleaned up old periodic timer")
	end

	-- Register for mount journal events (but not PLAYER_LOGIN - we'll use OnDataReady instead)
	self:RegisterFavoriteEvents()
	addon:DebugSync("Initialized successfully")
end

-- ============================================================================
-- SETTINGS MANAGEMENT
-- ============================================================================
function FavoriteSync:GetSetting(key)
	local value = addon:GetSetting("favoriteSync_" .. key)
	-- Ensure weight values are always integers
	if key == "favoriteWeight" or key == "nonFavoriteWeight" then
		local numValue = tonumber(value)
		if numValue then
			return math.max(0, math.min(6, math.floor(numValue)))
		else
			-- Fallback values if conversion fails
			return key == "favoriteWeight" and 4 or 3
		end
	end

	return value
end

function FavoriteSync:SetSetting(key, value)
	addon:SetSetting("favoriteSync_" .. key, value)
end

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================
function FavoriteSync:RegisterFavoriteEvents()
	if not self.eventFrame then
		self.eventFrame = CreateFrame("Frame")
		self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
			if event == "ADDON_LOADED" then
				local addonName = ...
				if addonName == "Blizzard_Collections" or addonName == "RandomMountBuddy" then
					-- Hook the mount journal when it's available
					self:HookMountJournal()
				end
			end
		end)
	end

	-- Only register ADDON_LOADED (not PLAYER_LOGIN - we'll handle that in OnDataReady)
	self.eventFrame:RegisterEvent("ADDON_LOADED")
	-- Try to hook immediately if journal is already loaded
	self:HookMountJournal()
	addon:DebugSync("Registered for essential events (ADDON_LOADED)")
end

-- Hook the Mount Journal to detect when users close it
function FavoriteSync:HookMountJournal()
	-- Try multiple approaches to hook the mount journal
	if CollectionsJournal and not self.journalHooked then
		-- Hook the main Collections Journal frame
		CollectionsJournal:HookScript("OnHide", function()
			-- Check if the mount tab was active when journal was closed
			if PanelTemplates_GetSelectedTab(CollectionsJournal) == 1 then -- Mount tab is usually tab 1
				addon:DebugSync("Mount Journal closed, checking for favorite changes")
				self:OnMountJournalClosed()
			end
		end)
		self.journalHooked = true
		addon:DebugSync("Successfully hooked Collections Journal OnHide")
	end

	-- Also try to hook the mount journal frame directly if it exists
	if MountJournal and not self.mountJournalHooked then
		-- Hook when mount journal specifically is hidden
		MountJournal:HookScript("OnHide", function()
			addon:DebugSync("MountJournal frame hidden, checking for favorite changes")
			self:OnMountJournalClosed()
		end)
		self.mountJournalHooked = true
		addon:DebugSync("Successfully hooked MountJournal OnHide")
	end

	-- Fallback: Try to hook when Collections Journal becomes available
	if not CollectionsJournal and not MountJournal then
		-- Use a one-time timer to try again later
		C_Timer.After(2, function()
			self:HookMountJournal()
		end)
	end
end

-- Handle when mount journal is closed
function FavoriteSync:OnMountJournalClosed()
	if not self:GetSetting("enableFavoriteSync") then
		return
	end

	-- Only check for changes if we have processed data
	if not addon.RMB_DataReadyForUI then
		addon:DebugSync("Data not ready, skipping favorite check")
		return
	end

	-- Prevent duplicate calls (since we hook both frames)
	if self.checkingFavorites then
		addon:DebugSync("Already checking favorites, skipping duplicate call")
		return
	end

	self.checkingFavorites = true
	-- Small delay to let WoW API update, then check for changes
	C_Timer.After(0.1, function()
		self.checkingFavorites = false
		-- SIMPLIFIED: Only use comprehensive weight check
		local syncNeeded = self:AreWeightsMisaligned()
		if syncNeeded then
			addon:DebugSync("Weight misalignment detected, correcting")
			-- Always use optimized bulk sync for journal changes
			self:SyncFavoriteMounts(true)
		else
			addon:DebugSync("All weights properly aligned")
		end
	end)
end

-- Add the missing AreWeightsMisaligned function (restore from old code):
-- Check if current weights are misaligned with favorite status
function FavoriteSync:AreWeightsMisaligned()
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	local favoriteWeight = self:GetSetting("favoriteWeight")
	local nonFavoriteWeight = self:GetSetting("nonFavoriteWeight")
	local weightMode = self:GetSetting("favoriteWeightMode")
	addon:DebugSync("Checking weight alignment for " ..
		#favoriteMounts .. " favorites and " .. #nonFavoriteMounts .. " non-favorites")
	-- Check if any favorites have wrong weight
	for _, mount in ipairs(favoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		local needsUpdate = false
		if weightMode == "set" then
			needsUpdate = (currentWeight ~= favoriteWeight)
		elseif weightMode == "minimum" then
			needsUpdate = (currentWeight < favoriteWeight)
		end

		if needsUpdate then
			addon:DebugSync("Favorite mount " ..
				mount.name .. " has weight " .. currentWeight .. ", should be " .. favoriteWeight)
			return true -- Found misalignment
		end
	end

	-- Check if any non-favorites have wrong weight
	for _, mount in ipairs(nonFavoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		-- For non-favorites, always use "set" mode (exact weight)
		if currentWeight ~= nonFavoriteWeight then
			addon:DebugSync("Non-favorite mount " ..
				mount.name .. " has weight " .. currentWeight .. ", should be " .. nonFavoriteWeight)
			return true -- Found misalignment
		end
	end

	-- Also check family and supergroup alignment if those options are enabled
	local syncFamilies = self:GetSetting("syncFamilyWeights")
	local syncSuperGroups = self:GetSetting("syncSuperGroupWeights")
	if syncFamilies or syncSuperGroups then
		-- Analyze which families and supergroups contain favorites
		local familiesWithFavorites, superGroupsWithFavorites = self:AnalyzeFavoriteHierarchy(favoriteMounts)
		if syncFamilies then
			-- Get all families to check both with and without favorites
			local allFamilies = {}
			if addon.processedData and addon.processedData.familyToMountIDsMap then
				for familyName, _ in pairs(addon.processedData.familyToMountIDsMap) do
					allFamilies[familyName] = true
				end
			end

			-- Check family weights (both with and without favorites)
			for familyName, _ in pairs(allFamilies) do
				local targetWeight
				if familiesWithFavorites[familyName] then
					targetWeight = favoriteWeight
				else
					targetWeight = nonFavoriteWeight
				end

				local currentWeight = addon:GetGroupWeight(familyName)
				local needsUpdate = false
				if weightMode == "set" then
					needsUpdate = (currentWeight ~= targetWeight)
				elseif weightMode == "minimum" then
					needsUpdate = (currentWeight < targetWeight)
				end

				if needsUpdate then
					addon:DebugSync("Family " .. familyName ..
						(familiesWithFavorites[familyName] and " with favorites " or " without favorites ") ..
						"has weight " .. currentWeight .. ", should be " .. targetWeight)
					return true
				end
			end
		end

		if syncSuperGroups then
			-- Get all supergroups to check both with and without favorites
			local allSuperGroups = {}
			if addon.processedData then
				local superGroupMap = addon.processedData.dynamicSuperGroupMap or addon.processedData.superGroupMap
				if superGroupMap then
					for sgName, _ in pairs(superGroupMap) do
						allSuperGroups[sgName] = true
					end
				end
			end

			-- Check supergroup weights (both with and without favorites)
			for superGroupName, _ in pairs(allSuperGroups) do
				local targetWeight
				if superGroupsWithFavorites[superGroupName] then
					targetWeight = favoriteWeight
				else
					targetWeight = nonFavoriteWeight
				end

				local currentWeight = addon:GetGroupWeight(superGroupName)
				local needsUpdate = false
				if weightMode == "set" then
					needsUpdate = (currentWeight ~= targetWeight)
				elseif weightMode == "minimum" then
					needsUpdate = (currentWeight < targetWeight)
				end

				if needsUpdate then
					addon:DebugSync("SuperGroup " .. superGroupName ..
						(superGroupsWithFavorites[superGroupName] and " with favorites " or " without favorites ") ..
						"has weight " .. currentWeight .. ", should be " .. targetWeight)
					return true
				end
			end
		end
	end

	addon:DebugSync("All weights properly aligned")
	return false -- All weights are aligned
end

-- ============================================================================
-- FAVORITE DETECTION
-- ============================================================================
function FavoriteSync:GetAllFavoriteMounts()
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSync("Data not ready - RMB_DataReadyForUI: " ..
			tostring(addon.RMB_DataReadyForUI) .. ", processedData exists: " ..
			tostring(addon.processedData ~= nil))
		return {}, {}
	end

	local favoriteMounts = {}
	local nonFavoriteMounts = {}
	-- Check collected mounts - refresh favorite status from API
	local mountCount = 0
	for mountID, mountInfo in pairs(addon.processedData.allCollectedMountFamilyInfo) do
		mountCount = mountCount + 1
		-- Get fresh favorite status from WoW API
		local name, _, _, _, isUsable, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
		-- Process ALL collected mounts, regardless of usability
		if isFavorite then
			table.insert(favoriteMounts, {
				id = mountID,
				name = name or mountInfo.name,
				familyName = mountInfo.familyName,
				superGroup = mountInfo.superGroup,
			})
		else
			table.insert(nonFavoriteMounts, {
				id = mountID,
				name = name or mountInfo.name,
				familyName = mountInfo.familyName,
				superGroup = mountInfo.superGroup,
			})
		end
	end

	addon:DebugSync("Processed " .. mountCount .. " total mounts, found " ..
		#favoriteMounts .. " favorite mounts and " .. #nonFavoriteMounts .. " non-favorite mounts")
	return favoriteMounts, nonFavoriteMounts
end

function FavoriteSync:CreateFavoriteHash()
	local favoriteMounts, _ = self:GetAllFavoriteMounts()
	-- Create a simple hash of favorite mount IDs to detect changes
	local ids = {}
	for _, mount in ipairs(favoriteMounts) do
		table.insert(ids, tostring(mount.id))
	end

	table.sort(ids)
	local hash = table.concat(ids, ",")
	addon:DebugSync("Created hash from " .. #ids .. " favorites: " .. string.sub(hash, 1, 50) .. "...")
	return hash
end

-- ============================================================================
-- OPTIMIZED BULK SYNC SYSTEM (NEW)
-- ============================================================================
-- Set weight directly without triggering notifications (for bulk operations)
function FavoriteSync:SetWeightDirectly(groupKey, weight)
	if not (addon.db and addon.db.profile and addon.db.profile.groupWeights) then
		return
	end

	local nw = tonumber(weight)
	if nw == nil or nw < 0 or nw > 6 then
		return
	end

	-- Direct database update - no notifications, no syncing
	addon.db.profile.groupWeights[groupKey] = nw
end

-- Optimized version of SyncFavoriteMounts that batches all updates
function FavoriteSync:SyncFavoriteMountsOptimized(forceSync)
	if self.syncInProgress then
		addon:DebugSync("Sync already in progress, skipping")
		return false
	end

	-- Since we're calling this from OnDataReady or manual triggers, data should always be ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSync("ERROR - Data not ready when sync was called")
		return false
	end

	if not forceSync and not self:HasFavoritesChanged() then
		addon:DebugSync("No changes detected in favorites")
		return false
	end

	self.syncInProgress = true
	addon:DebugSync("Starting OPTIMIZED favorite mount synchronization..." ..
		(forceSync and " (FORCED)" or ""))
	local startTime = debugprofilestop()
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	if #favoriteMounts == 0 then
		addon:DebugSync("No favorite mounts found, aborting sync")
		self.syncInProgress = false
		return false
	end

	local favoriteWeight = self:GetSetting("favoriteWeight")
	local nonFavoriteWeight = self:GetSetting("nonFavoriteWeight")
	local syncFamilies = self:GetSetting("syncFamilyWeights")
	local syncSuperGroups = self:GetSetting("syncSuperGroupWeights")
	local weightMode = self:GetSetting("favoriteWeightMode")
	-- Analyze hierarchy ONCE
	local familiesWithFavorites, superGroupsWithFavorites = self:AnalyzeFavoriteHierarchy(favoriteMounts)
	addon:DebugSync("Analysis complete - " ..
		self:CountTableEntries(familiesWithFavorites) .. " families with favorites, " ..
		self:CountTableEntries(superGroupsWithFavorites) .. " supergroups with favorites")
	local counters = {
		mountsUpdated = 0,
		familiesUpdated = 0,
		superGroupsUpdated = 0,
		mountsSkipped = 0,
	}
	-- BATCH UPDATE APPROACH - No individual notifications!
	addon:DebugSync("Starting batch weight updates...")
	-- Step 1: Update ALL favorite mounts at once
	for _, mount in ipairs(favoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		local shouldUpdate = false
		if weightMode == "set" then
			shouldUpdate = (currentWeight ~= favoriteWeight)
		elseif weightMode == "minimum" then
			shouldUpdate = (currentWeight < favoriteWeight)
		end

		if shouldUpdate then
			self:SetWeightDirectly(mountKey, favoriteWeight)
			counters.mountsUpdated = counters.mountsUpdated + 1
		else
			counters.mountsSkipped = counters.mountsSkipped + 1
		end
	end

	-- Step 2: Update ALL non-favorite mounts at once
	addon:DebugSync("Step 2: Processing " ..
		#nonFavoriteMounts .. " non-favorite mounts, target weight: " .. nonFavoriteWeight)
	local step2Updated = 0
	for _, mount in ipairs(nonFavoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		if currentWeight ~= nonFavoriteWeight then
			self:SetWeightDirectly(mountKey, nonFavoriteWeight)
			counters.mountsUpdated = counters.mountsUpdated + 1
			step2Updated = step2Updated + 1
		else
			counters.mountsSkipped = counters.mountsSkipped + 1
		end
	end

	addon:DebugSync("Step 2 complete: Updated " .. step2Updated .. " non-favorite mounts to weight " .. nonFavoriteWeight)
	-- Step 3: Update ALL families with favorites at once
	if syncFamilies then
		-- Get all families that exist
		local allFamilies = {}
		if addon.processedData and addon.processedData.familyToMountIDsMap then
			for familyName, _ in pairs(addon.processedData.familyToMountIDsMap) do
				allFamilies[familyName] = true
			end
		end

		for familyName, _ in pairs(allFamilies) do
			local targetWeight
			if familiesWithFavorites[familyName] then
				targetWeight = favoriteWeight
			else
				targetWeight = nonFavoriteWeight
			end

			local currentWeight = addon:GetGroupWeight(familyName)
			local shouldUpdate = false
			if weightMode == "set" then
				shouldUpdate = (currentWeight ~= targetWeight)
			elseif weightMode == "minimum" then
				shouldUpdate = (currentWeight < targetWeight)
			end

			if shouldUpdate then
				self:SetWeightDirectly(familyName, targetWeight)
				counters.familiesUpdated = counters.familiesUpdated + 1
			end
		end
	end

	-- Step 4: Update ALL supergroups with favorites at once
	if syncSuperGroups then
		local allSuperGroups = {}
		if addon.processedData then
			local superGroupMap = addon.processedData.dynamicSuperGroupMap or addon.processedData.superGroupMap
			if superGroupMap then
				for sgName, _ in pairs(superGroupMap) do
					allSuperGroups[sgName] = true
				end
			end
		end

		for superGroupName, _ in pairs(allSuperGroups) do
			local targetWeight
			if superGroupsWithFavorites[superGroupName] then
				targetWeight = favoriteWeight
			else
				targetWeight = nonFavoriteWeight
			end

			local currentWeight = addon:GetGroupWeight(superGroupName)
			local shouldUpdate = false
			if weightMode == "set" then
				shouldUpdate = (currentWeight ~= targetWeight)
			elseif weightMode == "minimum" then
				shouldUpdate = (currentWeight < targetWeight)
			end

			if shouldUpdate then
				self:SetWeightDirectly(superGroupName, targetWeight)
				counters.superGroupsUpdated = counters.superGroupsUpdated + 1
			end
		end
	end

	-- SINGLE notification at the very end
	local endTime = debugprofilestop()
	local elapsed = endTime - startTime
	-- Update settings
	self:SetSetting("lastSyncTime", time())
	addon:DebugSync("Batch updates completed in " .. string.format("%.2fms", elapsed))
	addon:DebugSync("Updated " .. counters.mountsUpdated .. " mounts, " ..
		counters.familiesUpdated .. " families, " .. counters.superGroupsUpdated .. " supergroups")
	addon:DebugSync("Skipped " .. counters.mountsSkipped .. " mounts (already correct weight)")
	self.syncInProgress = false
	-- ONE notification for everything
	self:NotifyOtherSystems()
	-- Show user feedback
	self:ShowSyncCompletedMessage(counters)
	return true
end

-- ============================================================================
-- SMART SYNC ROUTING (NEW) - Choose which sync method to use
-- ============================================================================
function FavoriteSync:SyncFavoriteMounts(forceSync)
	if self.syncInProgress then
		addon:DebugSync("Sync already in progress, skipping")
		return false
	end

	-- Data readiness check
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		addon:DebugSync("ERROR - Data not ready when sync was called")
		return false
	end

	-- If not forced, check if sync is needed
	if not forceSync then
		local syncNeeded = self:AreWeightsMisaligned()
		if not syncNeeded then
			addon:DebugSync("No weight misalignments detected")
			return false
		end
	end

	-- Always use optimized bulk sync (it's fast and comprehensive)
	return self:SyncFavoriteMountsOptimized(true)
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
-- Analyze which families and supergroups contain favorite mounts
function FavoriteSync:AnalyzeFavoriteHierarchy(favoriteMounts)
	local familiesWithFavorites = {}
	local superGroupsWithFavorites = {}
	-- Mark families that contain favorites
	for _, mount in ipairs(favoriteMounts) do
		if mount.familyName then
			familiesWithFavorites[mount.familyName] = true
		end
	end

	-- Mark supergroups that contain families with favorites
	for familyName, _ in pairs(familiesWithFavorites) do
		-- Get the supergroup for this family (using dynamic grouping)
		local superGroup = addon:GetDynamicSuperGroup(familyName)
		if superGroup then
			superGroupsWithFavorites[superGroup] = true
		end
	end

	return familiesWithFavorites, superGroupsWithFavorites
end

-- Utility function
function FavoriteSync:CountTableEntries(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count = count + 1
	end

	return count
end

function FavoriteSync:NotifyOtherSystems()
	-- Invalidate data manager cache
	if addon.MountDataManager and addon.MountDataManager.InvalidateCache then
		addon.MountDataManager:InvalidateCache("favorite_sync")
	end

	-- Refresh mount pools
	if addon.MountSummon and addon.MountSummon.RefreshMountPools then
		addon.MountSummon:RefreshMountPools()
	end

	-- Refresh UI
	if addon.PopulateFamilyManagementUI then
		addon:PopulateFamilyManagementUI()
	end
end

function FavoriteSync:ShowSyncCompletedMessage(counters)
	if counters.mountsUpdated > 0 or counters.familiesUpdated > 0 or counters.superGroupsUpdated > 0 then
		addon:DebugOptions("Favorite mount sync completed - Updated " .. counters.mountsUpdated ..
			" mounts, " .. counters.familiesUpdated .. " families, " ..
			counters.superGroupsUpdated .. " supergroups")
		-- Add verification after sync
		C_Timer.After(1, function()
			self:VerifySyncResults()
		end)
	end
end

-- ============================================================================
-- VERIFICATION AND TESTING
-- ============================================================================
-- Verify sync results
function FavoriteSync:VerifySyncResults()
	addon:DebugSync("Verifying sync results...")
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	local favoriteWeight = self:GetSetting("favoriteWeight")
	local nonFavoriteWeight = self:GetSetting("nonFavoriteWeight")
	local correctFavorites = 0
	local incorrectFavorites = 0
	-- Check favorite mounts
	for _, mount in ipairs(favoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		if currentWeight == favoriteWeight then
			correctFavorites = correctFavorites + 1
		else
			incorrectFavorites = incorrectFavorites + 1
			addon:DebugSync("WARNING - Favorite mount " .. mount.name ..
				" has weight " .. currentWeight .. ", expected " .. favoriteWeight)
		end
	end

	local correctNonFavorites = 0
	local incorrectNonFavorites = 0
	-- Check non-favorite mounts
	for _, mount in ipairs(nonFavoriteMounts) do
		local mountKey = "mount_" .. mount.id
		local currentWeight = addon:GetGroupWeight(mountKey)
		if currentWeight == nonFavoriteWeight then
			correctNonFavorites = correctNonFavorites + 1
		else
			incorrectNonFavorites = incorrectNonFavorites + 1
			addon:DebugSync("WARNING - Non-favorite mount " .. mount.name ..
				" has weight " .. currentWeight .. ", expected " .. nonFavoriteWeight)
		end
	end

	addon:DebugSync("Verification Results:")
	addon:DebugSync("Favorites: " .. correctFavorites .. " correct, " .. incorrectFavorites .. " incorrect")
	addon:DebugSync("Non-favorites: " .. correctNonFavorites .. " correct, " .. incorrectNonFavorites .. " incorrect")
	return (incorrectFavorites == 0) and (incorrectNonFavorites == 0)
end

-- Test functions
function FavoriteSync:TestLoginSyncTiming()
	addon:DebugSync("Testing login sync timing...")
	addon:DebugSync("hasPerformedLoginSync = " .. tostring(self.hasPerformedLoginSync))
	addon:DebugSync("enableFavoriteSync = " .. tostring(self:GetSetting("enableFavoriteSync")))
	addon:DebugSync("syncOnLogin = " .. tostring(self:GetSetting("syncOnLogin")))
	addon:DebugSync("RMB_DataReadyForUI = " .. tostring(addon.RMB_DataReadyForUI))
	addon:DebugSync("processedData exists = " .. tostring(addon.processedData ~= nil))
	-- Reset the login sync flag to simulate a fresh login
	addon:DebugSync("Resetting login sync flag and simulating OnDataReady...")
	self.hasPerformedLoginSync = false
	self:OnDataReady()
end

-- ============================================================================
-- MANUAL SYNC FUNCTIONS
-- ============================================================================
function FavoriteSync:ManualSync()
	addon:DebugSync("Manual sync requested")
	return self:SyncFavoriteMounts(true) -- Force sync
end

-- ============================================================================
-- STATISTICS AND INFO
-- ============================================================================
function FavoriteSync:GetSyncStatistics()
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	local lastSyncTime = self:GetSetting("lastSyncTime")
	return {
		favoriteMountCount = #favoriteMounts,
		nonFavoriteMountCount = #nonFavoriteMounts,
		totalMountCount = #favoriteMounts + #nonFavoriteMounts,
		lastSyncTime = lastSyncTime,
		lastSyncTimeFormatted = lastSyncTime > 0 and date("%Y-%m-%d %H:%M:%S", lastSyncTime) or "Never",
		isEnabled = self:GetSetting("enableFavoriteSync"),
	}
end

-- ============================================================================
-- INTEGRATION HOOKS
-- ============================================================================
function FavoriteSync:OnDataReady()
	addon:DebugSync("Data ready notification received")
	-- Initialize favorite hash now that data is available
	if addon.RMB_DataReadyForUI then
		self.lastFavoriteHash = self:CreateFavoriteHash()
		addon:DebugSync("Initialized baseline favorite hash")
		-- Check if we should perform login sync
		if not self.hasPerformedLoginSync then
			self.hasPerformedLoginSync = true -- Mark that we've attempted it
			if self:GetSetting("enableFavoriteSync") and self:GetSetting("syncOnLogin") then
				-- SIMPLIFIED: Use comprehensive weight check instead of sampling
				addon:DebugSync("Checking if login sync needed...")
				local syncNeeded = self:AreWeightsMisaligned()
				if syncNeeded then
					addon:DebugSync("Login sync needed, performing sync")
					-- Schedule the sync with a small delay to ensure everything is fully loaded
					C_Timer.After(2, function()
						self:SyncFavoriteMounts(true) -- Force sync on login
					end)
				else
					addon:DebugSync("Login sync not needed - all weights properly aligned")
				end
			else
				addon:DebugSync("Login sync disabled or favorite sync disabled")
			end
		end
	end
end

function FavoriteSync:OnSettingChanged(key, value)
	if key:find("favoriteSync_") then
		if key == "favoriteSync_enableFavoriteSync" and value then
			-- If favorite sync was just enabled, schedule a sync
			C_Timer.After(3, function()
				if self:GetSetting("enableFavoriteSync") then
					self:SyncFavoriteMounts(true)
				end
			end)
		end
	end
end

-- ============================================================================
-- INITIALIZATION FUNCTION
-- ============================================================================
function addon:InitializeFavoriteSync()
	if not self.FavoriteSync then
		addon:DebugSync("ERROR - FavoriteSync not found!")
		return
	end

	self.FavoriteSync:Initialize()
	addon:DebugSync("Integration complete")
end

addon:DebugCore("FavoriteSync.lua END (Optimized).")
