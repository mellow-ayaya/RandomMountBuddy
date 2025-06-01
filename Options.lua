-- Options.lua (Improved formatting and organization)
local PARENT_ADDON_INTERNAL_NAME = "RandomMountBuddy"  -- Used as the key for the parent category
local PARENT_ADDON_DISPLAY_NAME = "Random Mount Buddy" -- What the user sees for the top-level
print("RMB_OPTIONS: Options.lua START. Root Addon Name: " .. PARENT_ADDON_INTERNAL_NAME)
local addon = RandomMountBuddy
if not addon then
	print("RMB_OPTIONS: CRITICAL ERROR - RandomMountBuddy global (addon object) is nil!")
	return
end

local LibAceConfig = LibStub("AceConfig-3.0")
local LibAceConfigDialog = LibStub("AceConfigDialog-3.0")
if not (LibAceConfig and LibAceConfigDialog) then
	print("RMB_OPTIONS: CRITICAL ERROR - AceConfig or AceConfigDialog libraries not found!")
	return
end

-- Ensure necessary functions exist on the addon object for various pages
if type(addon.GetSetting) ~= "function" or type(addon.SetSetting) ~= "function" then
	print("RMB_OPTIONS_WARN: Core Get/SetSetting methods missing!")
end

if type(addon.BuildFamilyManagementArgs) ~= "function" then
	print("RMB_OPTIONS_WARN: addon.BuildFamilyManagementArgs is missing!")
	addon.BuildFamilyManagementArgs = function()
		return {
			err = {
				order = 1,
				type = "description",
				name = "Error: BuildFamilyManagementArgs missing!",
			},
		}
	end
end

if type(addon.GetFavoriteMountsForOptions) ~= "function" then
	print("RMB_OPTIONS_WARN: addon.GetFavoriteMountsForOptions is missing!")
	addon.GetFavoriteMountsForOptions = function()
		return {
			err = {
				order = 1,
				type = "description",
				name = "Error: GetFavoriteMountsForOptions missing!",
			},
		}
	end
end

if type(addon.PopulateFamilyManagementUI) ~= "function" then
	print("RMB_OPTIONS_WARN: addon.PopulateFamilyManagementUI is missing!")
end

--[[-----------------------------------------------------------------------------
    0. Create the Parent Category in Blizzard's Options
-------------------------------------------------------------------------------]]
-- We register a minimal options table for the parent itself. Its main purpose is to establish the category.
local rootOptions_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_RootConfig" -- Unique name for AceConfig registration
local rootOptionsTable = {
	name = PARENT_ADDON_DISPLAY_NAME,
	type = "group",
	args = {
		generalHeader = {
			order = 1,
			type = "header",
			name = "General Configuration",
		},

		contextualSummoning = {
			order = 5,
			type = "toggle",
			name = "Enable Contextual Summoning",
			desc = "Automatically filter mounts based on location/situation.",
			get = function() return addon:GetSetting("contextualSummoning") end,
			set = function(i, v)
				addon:SetSetting("contextualSummoning", v)
				-- ENHANCED: Refresh mount pools since this affects mount selection logic
				if addon.MountSummon and addon.MountSummon.RefreshMountPools then
					addon.MountSummon:RefreshMountPools()
					print("RMB_OPTIONS: Refreshed mount pools after contextual summoning change")
				end
			end,
		},

		useDeterministicSummoning = {
			order = 5.1,
			type = "toggle",
			name = "Use Deterministic Summoning",
			desc =
			"When enabled, recently used mount groups become temporarily unavailable, ensuring more variety in mount selection. Groups become unavailable for a duration based on your collection size.",
			get = function() return addon:GetSetting("useDeterministicSummoning") end,
			set = function(i, v)
				addon:SetSetting("useDeterministicSummoning", v)
				-- Reset cache when toggling mode
				if addon.db and addon.db.profile and addon.db.profile.deterministicCache then
					for poolName, cache in pairs(addon.db.profile.deterministicCache) do
						if cache then
							cache.unavailableGroups = {}
							cache.pendingSummon = nil
						end
					end

					print("RMB_DETERMINISTIC: Cache reset due to mode toggle")
				end

				-- ENHANCED: Refresh mount pools since this affects selection logic
				if addon.MountSummon and addon.MountSummon.RefreshMountPools then
					addon.MountSummon:RefreshMountPools()
					print("RMB_OPTIONS: Refreshed mount pools after deterministic summoning change")
				end
			end,
		},

		useTravelFormWhileMoving = {
			order = 7,
			type = "toggle",
			name = "Use Travel Form While Moving",
			desc = "If checked, the keybind will use Travel Form while moving (Druids only).",
			get = function() return addon:GetSetting("useTravelFormWhileMoving") end,
			set = function(i, v)
				addon:SetSetting("useTravelFormWhileMoving", v)
			end,
		},

		keepTravelFormActive = {
			order = 8,
			type = "toggle",
			name = "Keep Travel Form When Already Active",
			desc = "If checked, pressing the keybind while already in Travel Form won't cancel the form.",
			get = function() return addon:GetSetting("keepTravelFormActive") end,
			set = function(i, v) addon:SetSetting("keepTravelFormActive", v) end,
		},

		useSmartFormSwitching = {
			order = 8.5,
			type = "toggle",
			name = "Use Smart Form Switching",
			desc =
			"If checked, intelligently switches between Travel Form (outdoors/swimming) and Cat Form (indoors) based on context.",
			get = function() return addon:GetSetting("useSmartFormSwitching") end,
			set = function(i, v)
				addon:SetSetting("useSmartFormSwitching", v)
				-- Force an update of the macros if not in combat
				if not InCombatLockdown() then
					RandomMountBuddy:UpdateShapeshiftMacros()
				end
			end,
		},

		useGhostWolfWhileMoving = {
			order = 9,
			type = "toggle",
			name = "Use Ghost Wolf While Moving",
			desc = "If checked, the keybind will use Ghost Wolf while moving or in combat (Shamans only).",
			get = function() return addon:GetSetting("useGhostWolfWhileMoving") end,
			set = function(i, v) addon:SetSetting("useGhostWolfWhileMoving", v) end,
		},

		keepGhostWolfActive = {
			order = 9.1,
			type = "toggle",
			name = "Keep Ghost Wolf When Already Active",
			desc = "If checked, pressing the keybind while already in Ghost Wolf won't cancel the form.",
			get = function() return addon:GetSetting("keepGhostWolfActive") end,
			set = function(i, v) addon:SetSetting("keepGhostWolfActive", v) end,
		},

		useZenFlightWhileMoving = {
			order = 9.5,
			type = "toggle",
			name = "Use Zen Flight While Moving or Falling",
			desc =
			"If checked, the keybind will use Zen Flight while moving or falling (Monks only). Will not cast in combat while falling.",
			get = function() return addon:GetSetting("useZenFlightWhileMoving") end,
			set = function(i, v) addon:SetSetting("useZenFlightWhileMoving", v) end,
		},

		keepZenFlightActive = {
			order = 9.6,
			type = "toggle",
			name = "Keep Zen Flight When Already Active",
			desc = "If checked, pressing the keybind while already using Zen Flight won't cancel it.",
			get = function() return addon:GetSetting("keepZenFlightActive") end,
			set = function(i, v) addon:SetSetting("keepZenFlightActive", v) end,
		},

		useSlowFallWhileFalling = {
			order = 9.7,
			type = "toggle",
			name = "Use Slow Fall While Falling",
			desc = "If checked, the keybind will use Slow Fall while falling (Mages only).",
			get = function() return addon:GetSetting("useSlowFallWhileFalling") end,
			set = function(i, v) addon:SetSetting("useSlowFallWhileFalling", v) end,
		},

		useSlowFallOnOthers = {
			order = 9.8,
			type = "toggle",
			name = "Cast Slow Fall on Others",
			desc = "If checked, Slow Fall will try to cast on your target or mouseover first, before falling back to yourself.",
			get = function() return addon:GetSetting("useSlowFallOnOthers") end,
			set = function(i, v) addon:SetSetting("useSlowFallOnOthers", v) end,
		},

		useLevitateWhileFalling = {
			order = 9.9,
			type = "toggle",
			name = "Use Levitate While Falling",
			desc = "If checked, the keybind will use Levitate while falling (Priests only).",
			get = function() return addon:GetSetting("useLevitateWhileFalling") end,
			set = function(i, v) addon:SetSetting("useLevitateWhileFalling", v) end,
		},

		useLevitateOnOthers = {
			order = 10.0,
			type = "toggle",
			name = "Cast Levitate on Others",
			desc = "If checked, Levitate will try to cast on your target or mouseover first, before falling back to yourself.",
			get = function() return addon:GetSetting("useLevitateOnOthers") end,
			set = function(i, v) addon:SetSetting("useLevitateOnOthers", v) end,
		},

		traitStrictnessHeader = {
			order = 10.1,
			type = "header",
			name = "Trait-Based Strictness (if Super-Grouping is enabled)",
		},

		treatMinorArmorAsDistinct = {
			order = 12,
			type = "toggle",
			name = "Minor Armor as Distinct",
			desc = "Consider minor armor differences significant enough to treat as separate families",
			get = function() return addon:GetSetting("treatMinorArmorAsDistinct") end,
			set = function(i, v)
				addon:SetSetting("treatMinorArmorAsDistinct", v)
				-- ENHANCED: Explicitly refresh mount pools after trait changes
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after trait distinctness change")
					end
				end)
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
		},

		treatMajorArmorAsDistinct = {
			order = 13,
			type = "toggle",
			name = "Major Armor as Distinct",
			desc = "Consider major armor differences significant enough to treat as separate families",
			get = function() return addon:GetSetting("treatMajorArmorAsDistinct") end,
			set = function(i, v)
				addon:SetSetting("treatMajorArmorAsDistinct", v)
				-- ENHANCED: Explicitly refresh mount pools after trait changes
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after trait distinctness change")
					end
				end)
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
		},

		treatModelVariantsAsDistinct = {
			order = 14,
			type = "toggle",
			name = "Model Variants as Distinct",
			desc = "Consider model variants significant enough to treat as separate families",
			get = function() return addon:GetSetting("treatModelVariantsAsDistinct") end,
			set = function(i, v)
				addon:SetSetting("treatModelVariantsAsDistinct", v)
				-- ENHANCED: Explicitly refresh mount pools after trait changes
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after trait distinctness change")
					end
				end)
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
		},

		treatUniqueEffectsAsDistinct = {
			order = 15,
			type = "toggle",
			name = "Unique Effects/Skins as Distinct",
			desc = "Consider unique effects/skins significant enough to treat as separate families",
			get = function() return addon:GetSetting("treatUniqueEffectsAsDistinct") end,
			set = function(i, v)
				addon:SetSetting("treatUniqueEffectsAsDistinct", v)
				-- ENHANCED: Explicitly refresh mount pools after trait changes
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after trait distinctness change")
					end
				end)
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
		},

		groupDos = {
			order = 200,
			type = "group",
			inline = true,
			name = "",
			args = {
				displaySettingsHeader = {
					order = 9,
					type = "header",
					name = "Display Settings",
				},

				itemsPerPage = {
					order = 9.1,
					type = "select",
					name = "Items per Page",
					desc = "Number of groups to show per page in Family & Groups",
					values = {
						[14] = "14 (Default)",
						[30] = "30",
						[60] = "60",
						[90] = "90",
						[1000] = "All",
					},
					get = function()
						return addon:FMG_GetItemsPerPage()
					end,
					set = function(info, value)
						addon:FMG_SetItemsPerPage(value)
					end,
					width = 1.5,
				},

				currentTotalInfo = {
					order = 9.2,
					type = "description",
					name = function()
						if not addon.RMB_DataReadyForUI then
							return "Loading mount data..."
						end

						local allGroups = addon:GetDisplayableGroups() or {}
						local totalGroups = #allGroups
						local itemsPerPage = addon:FMG_GetItemsPerPage()
						local totalPages = math.max(1, math.ceil(totalGroups / itemsPerPage))
						return string.format("Currently: %d total groups across %d pages", totalGroups, totalPages)
					end,
					width = "full",
				},
			},
		},

		favoriteSyncHeader = {
			order = 16,
			type = "header",
			name = "Favorite Mount Synchronization",
		},

		enableFavoriteSync = {
			order = 17,
			type = "toggle",
			name = "Enable Favorite Sync",
			desc = "Automatically sync your WoW Mount Journal favorites with RMB mount weights",
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") or false
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("enableFavoriteSync", v)
				end

				-- ENHANCED: Refresh mount pools since this affects weight assignments
				C_Timer.After(0.2, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after FavoriteSync enable/disable")
					end

					-- Refresh the Family Management UI to show/hide sync warnings
					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end)
			end,
			width = "full",
		},

		syncOnLogin = {
			order = 18,
			type = "toggle",
			name = "Sync on Login",
			desc = "Automatically sync favorites when you log in (WARNING: May cause brief lag with large mount collections)",
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("syncOnLogin") or false
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("syncOnLogin", v)
				end
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = 1.2,
		},

		favoriteWeight = {
			order = 19,
			type = "select",
			name = "Favorite Mount Weight",
			desc = "What weight to assign to your favorite mounts",
			values = {
				[0] = "Never (0)",
				[1] = "Occasional (1)",
				[2] = "Uncommon (2)",
				[3] = "Normal (3)",
				[4] = "Common (4)",
				[5] = "Often (5)",
				[6] = "Always (6)",
			},
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("favoriteWeight") or 4
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("favoriteWeight", v)
				end

				-- ENHANCED: Refresh mount pools since this affects weights
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after favorite weight change")
					end
				end)
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = 1.2,
		},

		nonFavoriteWeight = {
			order = 20,
			type = "select",
			name = "Non-Favorite Mount Weight",
			desc = "What weight to assign to non-favorite mounts (set to Normal to leave unchanged)",
			values = {
				[0] = "Never (0)",
				[1] = "Occasional (1)",
				[2] = "Uncommon (2)",
				[3] = "Normal (3) - No Change",
				[4] = "Common (4)",
				[5] = "Often (5)",
				[6] = "Always (6)",
			},
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("nonFavoriteWeight") or 3
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("nonFavoriteWeight", v)
				end

				-- ENHANCED: Refresh mount pools since this affects weights
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after non-favorite weight change")
					end
				end)
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = 1.2,
		},

		favoriteWeightMode = {
			order = 21,
			type = "select",
			name = "Weight Mode",
			desc = "How to handle existing weights when syncing",
			values = {
				["set"] = "Set Exact Weight - Replace current weights",
				["minimum"] = "Set Minimum Weight - Only increase weights",
			},
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("favoriteWeightMode") or "set"
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("favoriteWeightMode", v)
				end

				-- ENHANCED: Refresh mount pools since this affects weight application
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after weight mode change")
					end
				end)
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = "full",
		},

		syncFamilyWeights = {
			order = 22,
			type = "toggle",
			name = "Sync Family Weights",
			desc = "Also update the weights of families that contain favorite mounts",
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("syncFamilyWeights") or false
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("syncFamilyWeights", v)
				end

				-- ENHANCED: Refresh mount pools since this affects family-level weights
				C_Timer.After(0.2, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after family sync setting change")
					end

					-- Refresh the Family Management UI to show/hide family-level sync warnings
					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end)
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = 1.2,
		},

		syncSuperGroupWeights = {
			order = 23,
			type = "toggle",
			name = "Sync SuperGroup Weights",
			desc = "Also update the weights of supergroups that contain favorite mounts",
			get = function()
				return addon.FavoriteSync and addon.FavoriteSync:GetSetting("syncSuperGroupWeights") or false
			end,
			set = function(i, v)
				if addon.FavoriteSync then
					addon.FavoriteSync:SetSetting("syncSuperGroupWeights", v)
				end

				-- ENHANCED: Refresh mount pools since this affects supergroup-level weights
				C_Timer.After(0.2, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						print("RMB_OPTIONS: Refreshed mount pools after supergroup sync setting change")
					end

					-- Refresh the Family Management UI to show/hide supergroup-level sync warnings
					if addon.PopulateFamilyManagementUI then
						addon:PopulateFamilyManagementUI()
					end
				end)
			end,
			disabled = function()
				return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
			end,
			width = 1.2,
		},

		favoriteSyncControlsGroup = {
			order = 24,
			type = "group",
			inline = true,
			name = "",
			args = {
				syncPreview = {
					order = 1,
					type = "description",
					name = function()
						if not addon.FavoriteSync then
							return "Favorite sync system not loaded."
						end

						if not addon.FavoriteSync:GetSetting("enableFavoriteSync") then
							return "Enable favorite sync to see preview."
						end

						return addon.FavoriteSync:PreviewSync() or "Error generating preview."
					end,
					width = "full",
					fontSize = "medium",
				},

				manualSyncButton = {
					order = 2,
					type = "execute",
					name = "Sync Now",
					desc = "Manually trigger favorite mount synchronization",
					func = function()
						if addon.FavoriteSync then
							addon.FavoriteSync:ManualSync()
						end
					end,
					disabled = function()
						return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
					end,
					width = 0.8,
				},

				syncStats = {
					order = 3,
					type = "description",
					name = function()
						if not addon.FavoriteSync then
							return ""
						end

						local stats = addon.FavoriteSync:GetSyncStatistics()
						return string.format("Stats: %d favorite, %d total mounts | Last sync: %s",
							stats.favoriteMountCount, stats.totalMountCount, stats.lastSyncTimeFormatted)
					end,
					width = "full",
				},
			},
		},
	},
}
LibAceConfig:RegisterOptionsTable(rootOptions_InternalName, rootOptionsTable)
local rootPanel, rootCategoryID = LibAceConfigDialog:AddToBlizOptions(rootOptions_InternalName, PARENT_ADDON_DISPLAY_NAME)
if not rootPanel then
	print("RMB_OPTIONS_ERROR: FAILED to create parent category '" ..
		PARENT_ADDON_DISPLAY_NAME .. "' in Blizzard Options.")
	return -- If parent can't be made, children will fail
else
	print("RMB_OPTIONS: Parent category '" ..
		PARENT_ADDON_DISPLAY_NAME ..
		"' created/found. ID/Name: " .. tostring(rootCategoryID or (rootPanel and rootPanel.name)))
end

-- The key used by AddToBlizOptions for 'parent' is the *display name* if a specific ID isn't returned or known.
local actualParentCategoryKey = rootCategoryID or (rootPanel and rootPanel.name) or PARENT_ADDON_DISPLAY_NAME
--[[-----------------------------------------------------------------------------
    1. Main Settings Page
-------------------------------------------------------------------------------]]
--[[
local mainSettings_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_MainSettings"
local mainSettings_DisplayName = "Main Settings"
local mainSettingsOptionsArgs = {
	generalHeader = {
		order = 1,
		type = "header",
		name = "General Configuration",
	},

	overrideBlizzardButton = {
		order = 3,
		type = "toggle",
		name = "Override Blizzard's Random Button",
		desc = "If checked, RMB will take over 'Summon Random Favorite Mount'.",
		get = function() return addon:GetSetting("overrideBlizzardButton") end,
		set = function(i, v) addon:SetSetting("overrideBlizzardButton", v) end,
	},

	useSuperGrouping = {
		order = 4,
		type = "toggle",
		name = "Use Super-Grouping",
		desc = "Group mounts by 'superGroup' by default.",
		get = function() return addon:GetSetting("useSuperGrouping") end,
		set = function(i, v) addon:SetSetting("useSuperGrouping", v) end,
	},

	contextualSummoning = {
		order = 5,
		type = "toggle",
		name = "Enable Contextual Summoning",
		desc = "Automatically filter mounts based on location/situation.",
		get = function() return addon:GetSetting("contextualSummoning") end,
		set = function(i, v) addon:SetSetting("contextualSummoning", v) end,
	},

	-- New checkbox for showing uncollected mounts
	showUncollectedMounts = {
		order = 6,
		type = "toggle",
		name = "Show Uncollected Mounts",
		desc = "If checked, uncollected mounts will be shown in the interface.",
		get = function() return addon:GetSetting("showUncollectedMounts") end,
		set = function(i, v)
			addon:SetSetting("showUncollectedMounts", v)
			-- Refresh the Family Management UI to reflect the new setting
			if addon.PopulateFamilyManagementUI then
				addon:PopulateFamilyManagementUI()
			else
				print("RMB_OPTIONS: Cannot refresh mount list - PopulateFamilyManagementUI missing")
			end
		end,
	},

	traitStrictnessHeader = {
		order = 10,
		type = "header",
		name = "Trait-Based Strictness (if Super-Grouping is enabled)",
	},

	treatMinorArmorAsDistinct = {
		order = 12,
		type = "toggle",
		name = "Minor Armor as Distinct",
		get = function() return addon:GetSetting("treatMinorArmorAsDistinct") end,
		set = function(i, v) addon:SetSetting("treatMinorArmorAsDistinct", v) end,
		disabled = function() return not addon:GetSetting("useSuperGrouping") end,
	},

	treatMajorArmorAsDistinct = {
		order = 13,
		type = "toggle",
		name = "Major Armor as Distinct",
		get = function() return addon:GetSetting("treatMajorArmorAsDistinct") end,
		set = function(i, v) addon:SetSetting("treatMajorArmorAsDistinct", v) end,
		disabled = function() return not addon:GetSetting("useSuperGrouping") end,
	},

	treatModelVariantsAsDistinct = {
		order = 14,
		type = "toggle",
		name = "Model Variants as Distinct",
		get = function() return addon:GetSetting("treatModelVariantsAsDistinct") end,
		set = function(i, v) addon:SetSetting("treatModelVariantsAsDistinct", v) end,
		disabled = function() return not addon:GetSetting("useSuperGrouping") end,
	},

	treatUniqueEffectsAsDistinct = {
		order = 15,
		type = "toggle",
		name = "Unique Effects/Skins as Distinct",
		get = function() return addon:GetSetting("treatUniqueEffectsAsDistinct") end,
		set = function(i, v) addon:SetSetting("treatUniqueEffectsAsDistinct", v) end,
		disabled = function() return not addon:GetSetting("useSuperGrouping") end,
	},
}
local mainSettingsOptionsTable = {
	name = mainSettings_DisplayName,
	handler = addon,
	type = "group",
	order = 1,
	args = mainSettingsOptionsArgs,
}
LibAceConfig:RegisterOptionsTable(mainSettings_InternalName, mainSettingsOptionsTable)
local mainPanel, mainCatID = LibAceConfigDialog:AddToBlizOptions(
	mainSettings_InternalName,
	mainSettings_DisplayName,
	actualParentCategoryKey
)
if mainPanel then
	addon.optionsPanel_Main = {
		frame = mainPanel,
		id = mainCatID or mainPanel.name,
	}
	addon.optionsPanelObject = addon.optionsPanel_Main
	print("RMB_OPTIONS: Registered '" .. mainSettings_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Main Settings AddToBliz.")
end
--]]
--[[-----------------------------------------------------------------------------
    2. Family & Group Management Page
-------------------------------------------------------------------------------]]
local familyManagement_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_FamilyManagement"
local familyManagement_DisplayName = "Family & Groups"
local initialFamilyManagementArgs = {
	_placeholder_header_fmg = {
		order = 0,
		type = "header",
		name = "Family & Group Configuration",
	},

	_placeholder_description_fmg = {
		order = 1,
		type = "description",
		name =
		"This panel allows you to adjust weights for mount families and groups. Higher weights increase the chance of a mount being selected when using the random mount feature. You can also preview mounts in each family.",
		fontSize = "medium",
	},

	_placeholder_refresh_button_fmg = {
		order = 2,
		type = "execute",
		name = "Load / Refresh Mount Groups",
		func = function()
			if addon.MountDataManager then
				addon.MountDataManager:InvalidateCache("manual_refresh")
			end

			if addon.PopulateFamilyManagementUI then
				addon:PopulateFamilyManagementUI()
			else
				print("RMB_OPTIONS_ERROR: PopulateFamilyManagementUI missing!")
			end
		end,
		width = "full",
	},

	_placeholder_status_fmg = {
		order = 3,
		type = "description",
		name = "Click 'Load / Refresh' or wait for data to auto-populate.",
	},
}
addon.fmArgsRef = initialFamilyManagementArgs -- Core.lua will use this reference
local familyManagementOptionsTable = {
	name = "",
	handler = addon,
	type = "group",
	order = 2,
	args = initialFamilyManagementArgs,
}
LibAceConfig:RegisterOptionsTable(familyManagement_InternalName, familyManagementOptionsTable)
local familyPanel, familyCatID = LibAceConfigDialog:AddToBlizOptions(
	familyManagement_InternalName,
	familyManagement_DisplayName,
	actualParentCategoryKey
)
if familyPanel then
	addon.optionsPanel_Family = {
		frame = familyPanel,
		id = familyCatID or familyPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. familyManagement_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Family & Groups AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    3. Mount Inspector Page
-------------------------------------------------------------------------------]]
local mountInspector_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_MountInspector"
local mountInspector_DisplayName = "Mount Inspector"
local favoriteMountsArgsTable = (addon.GetFavoriteMountsForOptions and addon:GetFavoriteMountsForOptions()) or
		{ err = { order = 1, type = "description", name = "Error." } }
local mountInspectorOptionsTable = {
	name = mountInspector_DisplayName,
	handler = addon,
	type = "group",
	order = 3,
	args = {
		header_inspector = {
			order = 1,
			type = "header",
			name = "Favorite Mounts Overview",
		},

		desc_inspector = {
			order = 2,
			type = "description",
			name = "Lists your favorite mounts and their assigned family name.",
			fontSize = "medium",
		},

		mount_list_container = {
			order = 3,
			type = "group",
			name = " ",
			inline = true,
			args = favoriteMountsArgsTable,
		},
	},
}
LibAceConfig:RegisterOptionsTable(mountInspector_InternalName, mountInspectorOptionsTable)
local inspPanel, inspCatID = LibAceConfigDialog:AddToBlizOptions(
	mountInspector_InternalName,
	mountInspector_DisplayName,
	actualParentCategoryKey
)
if inspPanel then
	addon.optionsPanel_Inspector = {
		frame = inspPanel,
		id = inspCatID or inspPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. mountInspector_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Mount Inspector AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    4. Group Weights Page
-------------------------------------------------------------------------------]]
local groupWeights_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_GroupWeights"
local groupWeights_DisplayName = "Group Weights"
local groupWeightsOptionsTable = {
	name = "",
	handler = addon,
	type = "group",
	order = 4,
	args = {
		desc_weights = {
			order = 1,
			type = "description",
			name = "Assign weights to groups. This feature will be available in a future update.",
		},
	},
}
LibAceConfig:RegisterOptionsTable(groupWeights_InternalName, groupWeightsOptionsTable)
local weightsPanel, weightsCatID = LibAceConfigDialog:AddToBlizOptions(
	groupWeights_InternalName,
	groupWeights_DisplayName,
	actualParentCategoryKey
)
if weightsPanel then
	addon.optionsPanel_Weights = {
		frame = weightsPanel,
		id = weightsCatID or weightsPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. groupWeights_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Group Weights AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    5. Supergroup Management Pages
-------------------------------------------------------------------------------]]

-- Page 1: Supergroup Management
local superGroupMgmt_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_SuperGroupMgmt"
local superGroupMgmt_DisplayName = "Supergroup Management"
-- Create initial args table (same pattern as Family & Groups)
local initialSuperGroupMgmtArgs = {
	header_mgmt = {
		order = 1,
		type = "header",
		name = "Create, Rename, Delete & Merge Supergroups",
	},

	desc_mgmt = {
		order = 2,
		type = "description",
		name =
		"Manage your supergroup structure. Create custom supergroups, rename existing ones, or merge similar groups together.",
		fontSize = "medium",
	},

	loading_placeholder = {
		order = 3,
		type = "description",
		name = "Loading supergroup data...",
	},
}
-- Set reference on addon object (same pattern as fmArgsRef)
addon.sgMgmtArgsRef = initialSuperGroupMgmtArgs
local superGroupMgmtOptionsTable = {
	name = superGroupMgmt_DisplayName,
	handler = addon,
	type = "group",
	order = 5,
	args = initialSuperGroupMgmtArgs, -- Direct reference
}
LibAceConfig:RegisterOptionsTable(superGroupMgmt_InternalName, superGroupMgmtOptionsTable)
local mgmtPanel, mgmtCatID = LibAceConfigDialog:AddToBlizOptions(
	superGroupMgmt_InternalName,
	superGroupMgmt_DisplayName,
	actualParentCategoryKey
)
if mgmtPanel then
	addon.optionsPanel_SuperGroupMgmt = {
		frame = mgmtPanel,
		id = mgmtCatID or mgmtPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. superGroupMgmt_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Supergroup Management AddToBliz.")
end

-- Page 2: Family Assignment
local familyAssign_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_FamilyAssign"
local familyAssign_DisplayName = "Family Assignment"
-- Create initial args table
local initialFamilyAssignArgs = {
	header_assign = {
		order = 1,
		type = "header",
		name = "Assign Families to Supergroups",
	},

	desc_assign = {
		order = 2,
		type = "description",
		name =
		"Move families between supergroups or make them standalone. Use search and bulk operations to manage large collections efficiently.",
		fontSize = "medium",
	},

	loading_placeholder = {
		order = 3,
		type = "description",
		name = "Loading family assignment data...",
	},
}
-- Set reference on addon object
addon.sgFamilyArgsRef = initialFamilyAssignArgs
local familyAssignOptionsTable = {
	name = familyAssign_DisplayName,
	handler = addon,
	type = "group",
	order = 6,
	args = initialFamilyAssignArgs, -- Direct reference
}
LibAceConfig:RegisterOptionsTable(familyAssign_InternalName, familyAssignOptionsTable)
local assignPanel, assignCatID = LibAceConfigDialog:AddToBlizOptions(
	familyAssign_InternalName,
	familyAssign_DisplayName,
	actualParentCategoryKey
)
if assignPanel then
	addon.optionsPanel_FamilyAssign = {
		frame = assignPanel,
		id = assignCatID or assignPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. familyAssign_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Family Assignment AddToBliz.")
end

-- Page 3: Import/Export
local importExport_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_ImportExport"
local importExport_DisplayName = "Import/Export"
local importExportOptionsTable = {
	name = importExport_DisplayName,
	handler = addon,
	type = "group",
	order = 7,
	args = {
		header_ie = {
			order = 1,
			type = "header",
			name = "Import/Export & Reset Configuration",
		},

		desc_ie = {
			order = 2,
			type = "description",
			name = "Share your supergroup configurations with others or reset to default settings.",
			fontSize = "medium",
		},
		-- Validation Section
		validation_header = {
			order = 5,
			type = "header",
			name = "Data Validation & Repair",
		},

		validation_desc = {
			order = 6,
			type = "description",
			name =
			"Check for and fix common data integrity issues including weight synchronization problems, orphaned settings, and name conflicts.",
			fontSize = "medium",
		},

		validation_check_button = {
			order = 7,
			type = "execute",
			name = "Run Validation Check",
			desc = "Scan for data integrity issues without fixing them",
			func = function()
				if addon.SuperGroupManager then
					local success, report = addon.SuperGroupManager:RunDataValidation(false)
					if success then
						local reportText = addon.SuperGroupManager:FormatValidationReport(report)
						addon.SuperGroupManager.lastValidationReport = reportText
						print("RMB: Validation check completed")
						-- Refresh UI to show the report
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
						end
					else
						print("RMB Error: " .. tostring(report))
					end
				end
			end,
			width = 1.0,
		},

		validation_fix_button = {
			order = 8,
			type = "execute",
			name = "Run Validation & Auto-Fix",
			desc = "Scan for data integrity issues and automatically fix safe issues",
			func = function()
				if addon.SuperGroupManager then
					local success, report = addon.SuperGroupManager:RunDataValidation(true)
					if success then
						local reportText = addon.SuperGroupManager:FormatValidationReport(report)
						addon.SuperGroupManager.lastValidationReport = reportText
						print("RMB: Validation and auto-fix completed")
						-- If any issues were fixed, trigger a data refresh
						if report.totalFixed > 0 then
							print("RMB: " .. report.totalFixed .. " issues were fixed, refreshing data...")
							-- Trigger data rebuild to apply fixes
							addon:RebuildMountGrouping()
							-- Refresh all UIs
							if addon.SuperGroupManager.RefreshAllUIs then
								addon.SuperGroupManager:RefreshAllUIs()
							end
						end

						-- Refresh UI to show the report
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
						end
					else
						print("RMB Error: " .. tostring(report))
					end
				end
			end,
			width = 1.0,
		},

		validation_report = {
			order = 9,
			type = "description",
			name = function()
				if addon.SuperGroupManager and addon.SuperGroupManager.lastValidationReport then
					return addon.SuperGroupManager.lastValidationReport
				else
					return "|cff888888Click 'Run Validation Check' to scan for data integrity issues.|r"
				end
			end,
			width = "full",
			fontSize = "medium",
		},

		validation_spacer = {
			order = 9.5,
			type = "description",
			name = "",
			width = "full",
		},
		-- Export Section
		export_header = {
			order = 10,
			type = "header",
			name = "Export Configuration",
		},

		export_preview = {
			order = 11,
			type = "description",
			name = function()
				if not addon.SuperGroupManager then
					return "SuperGroup Manager not initialized"
				end

				local stats = {
					overrides = 0,
					definitions = 0,
					deletions = 0,
					separatedMounts = 0, -- ENHANCED: Track separated mounts
				}
				if addon.db and addon.db.profile then
					if addon.db.profile.superGroupOverrides then
						stats.overrides = addon:CountTableEntries(addon.db.profile.superGroupOverrides)
					end

					if addon.db.profile.superGroupDefinitions then
						stats.definitions = addon:CountTableEntries(addon.db.profile.superGroupDefinitions)
					end

					if addon.db.profile.deletedSuperGroups then
						for _, isDeleted in pairs(addon.db.profile.deletedSuperGroups) do
							if isDeleted then
								stats.deletions = stats.deletions + 1
							end
						end
					end

					-- ENHANCED: Count separated mounts
					if addon.db.profile.separatedMounts then
						stats.separatedMounts = addon:CountTableEntries(addon.db.profile.separatedMounts)
					end
				end

				return string.format(
					"Configuration Preview:\n• Family Assignments: %d\n• Custom/Renamed Supergroups: %d\n• Deleted Supergroups: %d\n• Separated Mounts: %d",
					stats.overrides, stats.definitions, stats.deletions, stats.separatedMounts)
			end,
			width = "full",
		},

		export_button = {
			order = 12,
			type = "execute",
			name = "Export Configuration",
			desc = "Show configuration in a copyable popup window",
			func = function()
				if addon.SuperGroupManager then
					-- ENHANCED: Include separated mounts in export
					local config = addon.SuperGroupManager:ExportConfiguration()
					if config then
						-- Show the popup with the configuration string
						StaticPopup_Show("RMB_EXPORT_CONFIG_POPUP", nil, nil, {
							configString = config,
						})
						print("RMB: Configuration export popup opened - copy the text from the dialog")
					else
						print("RMB Error: Failed to generate configuration export")
					end
				else
					print("RMB Error: SuperGroupManager not available")
				end
			end,
			width = 1.0,
		},

		-- Import Section
		import_header = {
			order = 20,
			type = "header",
			name = "Import Configuration",
		},

		import_input = {
			order = 21,
			type = "input",
			name = "Configuration String",
			desc = "Paste exported configuration here",
			multiline = true,
			width = "full",
			get = function() return addon.SuperGroupManager and addon.SuperGroupManager.pendingImportString or "" end,
			set = function(info, value)
				if addon.SuperGroupManager then
					addon.SuperGroupManager.pendingImportString = value
				end
			end,
		},

		import_mode = {
			order = 22,
			type = "select",
			name = "Import Mode",
			desc = "How to handle existing configuration",
			values = {
				["replace"] = "Replace All - Clear existing configuration first",
				["merge"] = "Merge - Keep existing, add new",
			},
			get = function() return addon.SuperGroupManager and addon.SuperGroupManager.pendingImportMode or "replace" end,
			set = function(info, value)
				if addon.SuperGroupManager then
					addon.SuperGroupManager.pendingImportMode = value
				end
			end,
			width = 1.5,
		},

		import_button = {
			order = 23,
			type = "execute",
			name = "Import Configuration",
			desc = "Apply the imported configuration",
			func = function()
				if addon.SuperGroupManager then
					local configString = addon.SuperGroupManager.pendingImportString or ""
					local importMode = addon.SuperGroupManager.pendingImportMode or "replace"
					local success, message = addon.SuperGroupManager:ImportConfiguration(configString, importMode)
					if success then
						addon.SuperGroupManager.pendingImportString = ""
						print("RMB: " .. message)
					else
						print("RMB Error: " .. message)
					end
				end
			end,
			width = 1.0,
		},

		-- Reset Section
		reset_header = {
			order = 30,
			type = "header",
			name = "Reset to Defaults",
		},

		reset_warning = {
			order = 31,
			type = "description",
			name = "|cffff9900Warning: Reset operations cannot be undone. Consider exporting your configuration first.|r",
			width = "full",
		},

		reset_all = {
			order = 32,
			type = "execute",
			name = "Reset Everything",
			desc = "Clear all supergroup customizations and return to default configuration",
			func = function()
				StaticPopup_Show("RMB_RESET_ALL_CONFIRM")
			end,
			width = 1.0,
		},

		reset_assignments = {
			order = 33,
			type = "execute",
			name = "Reset Family Assignments Only",
			desc = "Clear family assignments but keep custom supergroups",
			func = function()
				StaticPopup_Show("RMB_RESET_ASSIGNMENTS_CONFIRM")
			end,
			width = 1.5,
		},

		reset_custom = {
			order = 34,
			type = "execute",
			name = "Reset Custom Supergroups Only",
			desc = "Remove custom supergroups but keep family assignments",
			func = function()
				StaticPopup_Show("RMB_RESET_CUSTOM_CONFIRM")
			end,
			width = 1.5,
		},
		reset_separation = {
			order = 35,
			type = "execute",
			name = "Reset Mount Separation Only",
			desc = "Reunite all separated mounts with their original families but keep other settings",
			func = function()
				StaticPopup_Show("RMB_RESET_SEPARATION_CONFIRM")
			end,
			width = 1.5,
		},
	},
}
LibAceConfig:RegisterOptionsTable(importExport_InternalName, importExportOptionsTable)
local iePanel, ieCatID = LibAceConfigDialog:AddToBlizOptions(
	importExport_InternalName,
	importExport_DisplayName,
	actualParentCategoryKey
)
if iePanel then
	addon.optionsPanel_ImportExport = {
		frame = iePanel,
		id = ieCatID or iePanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. importExport_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Import/Export AddToBliz.")
end

-- Static Popup Dialogs for SuperGroup Management (FIXED)
StaticPopupDialogs["RMB_DELETE_SUPERGROUP_CONFIRM"] = {
	text = "Delete supergroup '%s'?\n\nAll families in this supergroup will become standalone.",
	button1 = "Delete",
	button2 = "Cancel",
	OnAccept = function(self, sgName)
		if addon.SuperGroupManager then
			local success, message = addon.SuperGroupManager:DeleteSuperGroup(sgName)
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			-- NO UI REFRESH HERE - the polling system will handle it
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_MERGE_SUPERGROUPS_CONFIRM"] = {
	text =
	"Merge '%s' into '%s'?\n\nAll families from the first supergroup will be moved to the second, and the first supergroup will be deleted.",
	button1 = "Merge",
	button2 = "Cancel",
	OnAccept = function(self, data)
		if addon.SuperGroupManager and data then
			local success, message = addon.SuperGroupManager:MergeSuperGroups(data.source, data.target)
			if success then
				addon.SuperGroupManager.pendingMergeSource = ""
				addon.SuperGroupManager.pendingMergeTarget = ""
				print("RMB: " .. message)
				-- FIXED: Use enhanced refresh method that updates ALL UIs
				addon.SuperGroupManager:RefreshAllUIs()
			else
				print("RMB Error: " .. message)
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_RESET_ALL_CONFIRM"] = {
	text =
	"Reset ALL addon customizations?\n\nThis will:\n• Clear all family assignments\n• Remove all custom supergroups\n• Restore all deleted supergroups\n• Remove all renames\n• Reset ALL separated mounts\n• Clear ALL weight settings\n• Reset ALL trait overrides\n\nThis is a complete reset and cannot be undone!",
	button1 = "Reset Everything",
	button2 = "Cancel",
	OnAccept = function()
		if addon.SuperGroupManager then
			local success, message = addon.SuperGroupManager:ResetToDefaults("all")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- ENHANCED: Also refresh Mount Separation UI since everything was reset
				if addon.MountSeparationManager and addon.MountSeparationManager.PopulateSeparationManagementUI then
					addon.MountSeparationManager:PopulateSeparationManagementUI()
				end

				-- Use enhanced refresh method that updates ALL UIs
				addon.SuperGroupManager:RefreshAllUIs()
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_RESET_ASSIGNMENTS_CONFIRM"] = {
	text =
	"Reset all family assignments?\n\nThis will clear all family supergroup assignments but keep custom supergroups and renames.\n\nThis cannot be undone!",
	button1 = "Reset Assignments",
	button2 = "Cancel",
	OnAccept = function()
		if addon.SuperGroupManager then
			local success, message = addon.SuperGroupManager:ResetToDefaults("assignments")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- FIXED: Use enhanced refresh method that updates ALL UIs
				addon.SuperGroupManager:RefreshAllUIs()
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_RESET_CUSTOM_CONFIRM"] = {
	text =
	"Reset custom supergroups?\n\nThis will remove all custom supergroups but keep family assignments and original supergroup renames.\n\nThis cannot be undone!",
	button1 = "Reset Custom",
	button2 = "Cancel",
	OnAccept = function()
		if addon.SuperGroupManager then
			local success, message = addon.SuperGroupManager:ResetToDefaults("custom")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- FIXED: Use enhanced refresh method that updates ALL UIs
				addon.SuperGroupManager:RefreshAllUIs()
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_EXPORT_CONFIG_POPUP"] = {
	text = "Configuration Export\n\nCopy the text below:",
	button1 = "Close",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, data)
		if data and data.configString then
			-- Set the edit box text and select all for easy copying
			self.editBox:SetText(data.configString)
			self.editBox:HighlightText()
			self.editBox:SetFocus()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		-- Just close when user presses enter
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		-- Close when user presses escape
		self:GetParent():Hide()
	end,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_RESET_SEPARATION_CONFIRM"] = {
	text =
	"Reset mount separation?\n\nThis will:\n• Reunite all separated mounts with their original families\n• Clear weights and settings for separated families\n• Keep individual mount weights\n\nThis cannot be undone!",
	button1 = "Reset Separation",
	button2 = "Cancel",
	OnAccept = function()
		if addon.SuperGroupManager then
			local success, message = addon.SuperGroupManager:ResetMountSeparationOnly()
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- Also refresh Mount Separation UI
				if addon.MountSeparationManager and addon.MountSeparationManager.PopulateSeparationManagementUI then
					addon.MountSeparationManager:PopulateSeparationManagementUI()
				end
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
-- Mount Separation Page
local mountSeparation_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_MountSeparation"
local mountSeparation_DisplayName = "Mount Separation"
local initialMountSeparationArgs = {
	header = {
		order = 1,
		type = "header",
		name = "Mount Separation Management",
	},
	desc = {
		order = 2,
		type = "description",
		name = "Separate individual mounts from their families to create custom single-mount families.",
		fontSize = "medium",
	},
	loading_placeholder = {
		order = 3,
		type = "description",
		name = "Loading mount separation data...",
	},
}
addon.separationArgsRef = initialMountSeparationArgs
local mountSeparationOptionsTable = {
	name = mountSeparation_DisplayName,
	handler = addon,
	type = "group",
	order = 8,
	args = initialMountSeparationArgs,
}
LibAceConfig:RegisterOptionsTable(mountSeparation_InternalName, mountSeparationOptionsTable)
local separationPanel, separationCatID = LibAceConfigDialog:AddToBlizOptions(
	mountSeparation_InternalName,
	mountSeparation_DisplayName,
	actualParentCategoryKey
)
if separationPanel then
	addon.optionsPanel_MountSeparation = {
		frame = separationPanel,
		id = separationCatID or separationPanel.name,
	}
	print("RMB_OPTIONS: Registered '" .. mountSeparation_DisplayName .. "' page.")
else
	print("RMB_OPTIONS_ERROR: FAILED Mount Separation AddToBliz.")
end

print("RMB_OPTIONS: Options.lua END - All sub-categories registration completed.")
