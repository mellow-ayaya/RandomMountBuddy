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
			set = function(i, v)
				addon:SetSetting("contextualSummoning", v)
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
			end,
		},

		showUncollectedMounts = {
			order = 6,
			type = "toggle",
			name = "Show Uncollected Mounts",
			desc =
			"If checked, uncollected mounts will be shown in the interface. When disabled, also hides single-mount families that contain only an uncollected mount.",
			get = function() return addon:GetSetting("showUncollectedMounts") end,
			set = function(i, v)
				addon:SetSetting("showUncollectedMounts", v)
			end,
		},

		showAllUncollectedGroups = {
			order = 6.5,
			type = "toggle",
			name = "Show Families with Only Uncollected Mounts",
			desc =
			"If checked, families and supergroups that contain only uncollected mounts will be shown in the interface. Only available when 'Show Uncollected Mounts' is enabled.",
			get = function() return addon:GetSetting("showAllUncollectedGroups") end,
			set = function(i, v)
				addon:SetSetting("showAllUncollectedGroups", v)
			end,
			disabled = function()
				return not addon:GetSetting("showUncollectedMounts")
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
		-- Add after the existing Monk options
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

				-- Refresh the Family Management UI to show/hide sync warnings
				C_Timer.After(0.1, function()
					if addon.PopulateFamilyManagementUI then
						print("RMB_OPTIONS: Refreshing UI after FavoriteSync toggle change")
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
				-- FIXED: Remove the "or true" that was causing it to be stuck on
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

				-- Refresh the Family Management UI to show/hide family-level sync warnings
				C_Timer.After(0.1, function()
					if addon.PopulateFamilyManagementUI then
						print("RMB_OPTIONS: Refreshing UI after Family Sync toggle change")
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

				-- Refresh the Family Management UI to show/hide supergroup-level sync warnings
				C_Timer.After(0.1, function()
					if addon.PopulateFamilyManagementUI then
						print("RMB_OPTIONS: Refreshing UI after SuperGroup Sync toggle change")
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

print("RMB_OPTIONS: Options.lua END - All sub-categories registration completed.")
