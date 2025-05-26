-- FavoriteSync.lua - Favorite Mount Synchronization System (Optimized)
local addonName, addonTable = ...
local addon = RandomMountBuddy
print("RMB_DEBUG: FavoriteSync.lua START (Optimized).")
-- ============================================================================
-- FAVORITE SYNC CLASS
-- ============================================================================
local FavoriteSync = {}
addon.FavoriteSync = FavoriteSync
-- ============================================================================
-- INITIALIZATION
-- ============================================================================
function FavoriteSync:Initialize()
	print("RMB_FAVORITE_SYNC: Initializing favorite mount synchronization system...")
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
		print("RMB_FAVORITE_SYNC: Cleaned up old periodic timer")
	end

	-- Register for mount journal events (but not PLAYER_LOGIN - we'll use OnDataReady instead)
	self:RegisterFavoriteEvents()
	print("RMB_FAVORITE_SYNC: Initialized successfully")
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
	print("RMB_FAVORITE_SYNC: Registered for essential events (ADDON_LOADED)")
end

-- Hook the Mount Journal to detect when users close it
function FavoriteSync:HookMountJournal()
	-- Try multiple approaches to hook the mount journal
	if CollectionsJournal and not self.journalHooked then
		-- Hook the main Collections Journal frame
		CollectionsJournal:HookScript("OnHide", function()
			-- Check if the mount tab was active when journal was closed
			if PanelTemplates_GetSelectedTab(CollectionsJournal) == 1 then -- Mount tab is usually tab 1
				print("RMB_FAVORITE_SYNC: Mount Journal closed, checking for favorite changes")
				self:OnMountJournalClosed()
			end
		end)
		self.journalHooked = true
		print("RMB_FAVORITE_SYNC: Successfully hooked Collections Journal OnHide")
	end

	-- Also try to hook the mount journal frame directly if it exists
	if MountJournal and not self.mountJournalHooked then
		-- Hook when mount journal specifically is hidden
		MountJournal:HookScript("OnHide", function()
			print("RMB_FAVORITE_SYNC: MountJournal frame hidden, checking for favorite changes")
			self:OnMountJournalClosed()
		end)
		self.mountJournalHooked = true
		print("RMB_FAVORITE_SYNC: Successfully hooked MountJournal OnHide")
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
		print("RMB_FAVORITE_SYNC: Data not ready, skipping favorite check")
		return
	end

	-- Prevent duplicate calls (since we hook both frames)
	if self.checkingFavorites then
		print("RMB_FAVORITE_SYNC: Already checking favorites, skipping duplicate call")
		return
	end

	self.checkingFavorites = true
	-- Small delay to let WoW API update, then check for changes
	C_Timer.After(0.1, function()
		self.checkingFavorites = false
		-- SIMPLIFIED: Only use comprehensive weight check
		local syncNeeded = self:AreWeightsMisaligned()
		if syncNeeded then
			print("RMB_FAVORITE_SYNC: Weight misalignment detected, correcting")
			-- Always use optimized bulk sync for journal changes
			self:SyncFavoriteMounts(true)
		else
			print("RMB_FAVORITE_SYNC: All weights properly aligned")
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
	print("RMB_FAVORITE_SYNC: Checking weight alignment for " ..
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
			print("RMB_FAVORITE_SYNC: Favorite mount " ..
				mount.name .. " has weight " .. currentWeight .. ", should be " .. favoriteWeight)
			return true -- Found misalignment
		end
	end

	-- Check if any non-favorites have wrong weight (if non-favorite weight is set to something other than default)
	if nonFavoriteWeight ~= 3 then
		for _, mount in ipairs(nonFavoriteMounts) do
			local mountKey = "mount_" .. mount.id
			local currentWeight = addon:GetGroupWeight(mountKey)
			-- For non-favorites, always use "set" mode (exact weight)
			if currentWeight ~= nonFavoriteWeight then
				print("RMB_FAVORITE_SYNC: Non-favorite mount " ..
					mount.name .. " has weight " .. currentWeight .. ", should be " .. nonFavoriteWeight)
				return true -- Found misalignment
			end
		end
	end

	-- Also check family and supergroup alignment if those options are enabled
	local syncFamilies = self:GetSetting("syncFamilyWeights")
	local syncSuperGroups = self:GetSetting("syncSuperGroupWeights")
	if syncFamilies or syncSuperGroups then
		-- Analyze which families and supergroups contain favorites
		local familiesWithFavorites, superGroupsWithFavorites = self:AnalyzeFavoriteHierarchy(favoriteMounts)
		if syncFamilies then
			-- Check family weights
			for familyName, _ in pairs(familiesWithFavorites) do
				local currentWeight = addon:GetGroupWeight(familyName)
				local needsUpdate = false
				if weightMode == "set" then
					needsUpdate = (currentWeight ~= favoriteWeight)
				elseif weightMode == "minimum" then
					needsUpdate = (currentWeight < favoriteWeight)
				end

				if needsUpdate then
					print("RMB_FAVORITE_SYNC: Family with favorites " ..
						familyName .. " has weight " .. currentWeight .. ", should be " .. favoriteWeight)
					return true
				end
			end
		end

		if syncSuperGroups then
			-- Check supergroup weights
			for superGroupName, _ in pairs(superGroupsWithFavorites) do
				local currentWeight = addon:GetGroupWeight(superGroupName)
				local needsUpdate = false
				if weightMode == "set" then
					needsUpdate = (currentWeight ~= favoriteWeight)
				elseif weightMode == "minimum" then
					needsUpdate = (currentWeight < favoriteWeight)
				end

				if needsUpdate then
					print("RMB_FAVORITE_SYNC: SuperGroup with favorites " ..
						superGroupName .. " has weight " .. currentWeight .. ", should be " .. favoriteWeight)
					return true
				end
			end
		end
	end

	print("RMB_FAVORITE_SYNC: All weights properly aligned")
	return false -- All weights are aligned
end

-- ============================================================================
-- FAVORITE DETECTION
-- ============================================================================
function FavoriteSync:GetAllFavoriteMounts()
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		print("RMB_FAVORITE_SYNC: Data not ready - RMB_DataReadyForUI: " ..
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
		if isUsable then -- Only process usable mounts
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
	end

	print("RMB_FAVORITE_SYNC: Processed " .. mountCount .. " total mounts, found " ..
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
	print("RMB_FAVORITE_SYNC: Created hash from " .. #ids .. " favorites: " .. string.sub(hash, 1, 50) .. "...")
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
		print("RMB_FAVORITE_SYNC: Sync already in progress, skipping")
		return false
	end

	-- Since we're calling this from OnDataReady or manual triggers, data should always be ready
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		print("RMB_FAVORITE_SYNC: ERROR - Data not ready when sync was called")
		return false
	end

	if not forceSync and not self:HasFavoritesChanged() then
		print("RMB_FAVORITE_SYNC: No changes detected in favorites")
		return false
	end

	self.syncInProgress = true
	print("RMB_FAVORITE_SYNC: Starting OPTIMIZED favorite mount synchronization..." ..
		(forceSync and " (FORCED)" or ""))
	local startTime = debugprofilestop()
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	if #favoriteMounts == 0 then
		print("RMB_FAVORITE_SYNC: No favorite mounts found, aborting sync")
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
	print("RMB_FAVORITE_SYNC: Analysis complete - " ..
		self:CountTableEntries(familiesWithFavorites) .. " families with favorites, " ..
		self:CountTableEntries(superGroupsWithFavorites) .. " supergroups with favorites")
	local counters = {
		mountsUpdated = 0,
		familiesUpdated = 0,
		superGroupsUpdated = 0,
		mountsSkipped = 0,
	}
	-- BATCH UPDATE APPROACH - No individual notifications!
	print("RMB_FAVORITE_SYNC: Starting batch weight updates...")
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

	-- Step 2: Update ALL non-favorite mounts at once (if needed)
	if nonFavoriteWeight ~= 3 then
		for _, mount in ipairs(nonFavoriteMounts) do
			local mountKey = "mount_" .. mount.id
			local currentWeight = addon:GetGroupWeight(mountKey)
			if currentWeight ~= nonFavoriteWeight then
				self:SetWeightDirectly(mountKey, nonFavoriteWeight)
				counters.mountsUpdated = counters.mountsUpdated + 1
			else
				counters.mountsSkipped = counters.mountsSkipped + 1
			end
		end
	else
		-- Count non-favorites as skipped since we're not changing them
		counters.mountsSkipped = counters.mountsSkipped + #nonFavoriteMounts
	end

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
				if nonFavoriteWeight ~= 3 then
					targetWeight = nonFavoriteWeight
				else
					targetWeight = nil -- Skip if non-favorite weight is default
				end
			end

			if targetWeight then
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
				if nonFavoriteWeight ~= 3 then
					targetWeight = nonFavoriteWeight
				else
					targetWeight = nil -- Skip if non-favorite weight is default
				end
			end

			if targetWeight then
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
	end

	-- SINGLE notification at the very end
	local endTime = debugprofilestop()
	local elapsed = endTime - startTime
	-- Update settings
	self:SetSetting("lastSyncTime", time())
	print("RMB_FAVORITE_SYNC: Batch updates completed in " .. string.format("%.2fms", elapsed))
	print("RMB_FAVORITE_SYNC: Updated " .. counters.mountsUpdated .. " mounts, " ..
		counters.familiesUpdated .. " families, " .. counters.superGroupsUpdated .. " supergroups")
	print("RMB_FAVORITE_SYNC: Skipped " .. counters.mountsSkipped .. " mounts (already correct weight)")
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
		print("RMB_FAVORITE_SYNC: Sync already in progress, skipping")
		return false
	end

	-- Data readiness check
	if not addon.RMB_DataReadyForUI or not addon.processedData then
		print("RMB_FAVORITE_SYNC: ERROR - Data not ready when sync was called")
		return false
	end

	-- If not forced, check if sync is needed
	if not forceSync then
		local syncNeeded = self:AreWeightsMisaligned()
		if not syncNeeded then
			print("RMB_FAVORITE_SYNC: No weight misalignments detected")
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
		print("RMB: Favorite mount sync completed - Updated " .. counters.mountsUpdated ..
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
	print("RMB_FAVORITE_SYNC: Verifying sync results...")
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
			print("RMB_FAVORITE_SYNC: WARNING - Favorite mount " .. mount.name ..
				" has weight " .. currentWeight .. ", expected " .. favoriteWeight)
		end
	end

	local correctNonFavorites = 0
	local incorrectNonFavorites = 0
	-- Check non-favorite mounts (only if non-favorite weight is not default)
	if nonFavoriteWeight ~= 3 then
		for _, mount in ipairs(nonFavoriteMounts) do
			local mountKey = "mount_" .. mount.id
			local currentWeight = addon:GetGroupWeight(mountKey)
			if currentWeight == nonFavoriteWeight then
				correctNonFavorites = correctNonFavorites + 1
			else
				incorrectNonFavorites = incorrectNonFavorites + 1
			end
		end
	end

	print("RMB_FAVORITE_SYNC: Verification Results:")
	print("  Favorites: " .. correctFavorites .. " correct, " .. incorrectFavorites .. " incorrect")
	if nonFavoriteWeight ~= 3 then
		print("  Non-favorites: " .. correctNonFavorites .. " correct, " .. incorrectNonFavorites .. " incorrect")
	else
		print("  Non-favorites: Not checked (weight set to default)")
	end

	return (incorrectFavorites == 0) and (incorrectNonFavorites == 0)
end

-- Test functions
function FavoriteSync:TestLoginSyncTiming()
	print("RMB_FAVORITE_SYNC: Testing login sync timing...")
	print("RMB_FAVORITE_SYNC: hasPerformedLoginSync = " .. tostring(self.hasPerformedLoginSync))
	print("RMB_FAVORITE_SYNC: enableFavoriteSync = " .. tostring(self:GetSetting("enableFavoriteSync")))
	print("RMB_FAVORITE_SYNC: syncOnLogin = " .. tostring(self:GetSetting("syncOnLogin")))
	print("RMB_FAVORITE_SYNC: RMB_DataReadyForUI = " .. tostring(addon.RMB_DataReadyForUI))
	print("RMB_FAVORITE_SYNC: processedData exists = " .. tostring(addon.processedData ~= nil))
	-- Reset the login sync flag to simulate a fresh login
	print("RMB_FAVORITE_SYNC: Resetting login sync flag and simulating OnDataReady...")
	self.hasPerformedLoginSync = false
	self:OnDataReady()
end

-- ============================================================================
-- MANUAL SYNC FUNCTIONS
-- ============================================================================
function FavoriteSync:ManualSync()
	print("RMB_FAVORITE_SYNC: Manual sync requested")
	return self:SyncFavoriteMounts(true) -- Force sync
end

function FavoriteSync:PreviewSync()
	print("RMB_FAVORITE_SYNC: Generating sync preview...")
	local favoriteMounts, nonFavoriteMounts = self:GetAllFavoriteMounts()
	if #favoriteMounts == 0 then
		return "No favorite mounts found to sync."
	end

	local favoriteWeight = self:GetSetting("favoriteWeight")
	local nonFavoriteWeight = self:GetSetting("nonFavoriteWeight")
	local syncFamilies = self:GetSetting("syncFamilyWeights")
	local syncSuperGroups = self:GetSetting("syncSuperGroupWeights")
	local preview = {}
	table.insert(preview, "Favorite Sync Preview:")
	table.insert(preview, "• " .. #favoriteMounts .. " favorite mounts → weight " .. favoriteWeight)
	if nonFavoriteWeight ~= 3 then
		table.insert(preview, "• " .. #nonFavoriteMounts .. " non-favorite mounts → weight " .. nonFavoriteWeight)
	end

	if syncFamilies then
		table.insert(preview, "• Family weights will be updated")
	end

	if syncSuperGroups then
		table.insert(preview, "• Supergroup weights will be updated")
	end

	table.insert(preview,
		"• Mode: " .. (self:GetSetting("favoriteWeightMode") == "set" and "Set exact weight" or "Set minimum weight"))
	-- Performance info for large collections
	local totalMounts = #favoriteMounts + (nonFavoriteWeight ~= 3 and #nonFavoriteMounts or 0)
	if totalMounts > 100 then
		table.insert(preview, "• Large collection detected - will use optimized bulk processing")
		table.insert(preview, "• Estimated time: < 1 second (optimized)")
	end

	return table.concat(preview, "\n")
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
	print("RMB_FAVORITE_SYNC: Data ready notification received")
	-- Initialize favorite hash now that data is available
	if addon.RMB_DataReadyForUI then
		self.lastFavoriteHash = self:CreateFavoriteHash()
		print("RMB_FAVORITE_SYNC: Initialized baseline favorite hash")
		-- Check if we should perform login sync
		if not self.hasPerformedLoginSync then
			self.hasPerformedLoginSync = true -- Mark that we've attempted it
			if self:GetSetting("enableFavoriteSync") and self:GetSetting("syncOnLogin") then
				-- SIMPLIFIED: Use comprehensive weight check instead of sampling
				print("RMB_FAVORITE_SYNC: Checking if login sync needed...")
				local syncNeeded = self:AreWeightsMisaligned()
				if syncNeeded then
					print("RMB_FAVORITE_SYNC: Login sync needed, performing sync")
					-- Schedule the sync with a small delay to ensure everything is fully loaded
					C_Timer.After(2, function()
						self:SyncFavoriteMounts(true) -- Force sync on login
					end)
				else
					print("RMB_FAVORITE_SYNC: Login sync not needed - all weights properly aligned")
				end
			else
				print("RMB_FAVORITE_SYNC: Login sync disabled or favorite sync disabled")
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
		print("RMB_FAVORITE_SYNC: ERROR - FavoriteSync not found!")
		return
	end

	self.FavoriteSync:Initialize()
	print("RMB_FAVORITE_SYNC: Integration complete")
end

print("RMB_DEBUG: FavoriteSync.lua END (Optimized).")
