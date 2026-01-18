-- Options.lua (Improved formatting and organization)
local PARENT_ADDON_INTERNAL_NAME = "RandomMountBuddy"  -- Used as the key for the parent category
local PARENT_ADDON_DISPLAY_NAME = "Random Mount Buddy" -- What the user sees for the top-level
local addon = RandomMountBuddy
if not addon then
	addon:DebugOptions("CRITICAL ERROR - RandomMountBuddy global (addon object) is nil!")
	return
end

local LibAceConfig = LibStub("AceConfig-3.0")
local LibAceConfigDialog = LibStub("AceConfigDialog-3.0")
if not (LibAceConfig and LibAceConfigDialog) then
	addon:DebugOptions("CRITICAL ERROR - AceConfig or AceConfigDialog libraries not found!")
	return
end

-- Ensure necessary functions exist on the addon object for various pages
if type(addon.GetSetting) ~= "function" or type(addon.SetSetting) ~= "function" then
	addon:DebugOptions("Core Get/SetSetting methods missing!")
end

if type(addon.BuildFamilyManagementArgs) ~= "function" then
	addon:DebugOptions("addon.BuildFamilyManagementArgs is missing!")
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
	addon:DebugOptions("addon.GetFavoriteMountsForOptions is missing!")
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
	addon:DebugOptions("addon.PopulateFamilyManagementUI is missing!")
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
		showMinimapButton = {
			order = 20,
			type = "toggle",
			name = "Show Minimap Button",
			desc =
			"Toggle minimap icon.",
			get = function() return addon:GetSetting("showMinimapButton") end,
			set = function(i, v)
				addon:SetSetting("showMinimapButton", v)
				-- Update minimap button visibility
				if addon.MinimapButton and addon.MinimapButton.UpdateMinimapButtonVisibility then
					addon.MinimapButton:UpdateMinimapButtonVisibility()
				end
			end,
			width = 1.4,

		},

		enableDebugMode = {
			order = 21,
			type = "toggle",
			name = "Debug Messages",
			desc = "Show detailed debug information in chat. Useful for troubleshooting.",
			get = function()
				-- Direct database access to avoid any SetSetting loops
				if addon.db and addon.db.profile then
					return addon.db.profile.enableDebugMode or false
				end

				return false
			end,
			set = function(i, v)
				-- Direct database write to avoid triggering other systems
				if addon.db and addon.db.profile then
					addon.db.profile.enableDebugMode = v
				end

				-- Simple direct print - don't use AlwaysPrint to avoid any loops
				if v then
					print("RMB: Debug mode enabled - you'll see detailed debug messages")
				else
					print("RMB: Debug mode disabled")
				end
			end,
			width = 1,
		},

		utilityMountsEnabled = {
			order = 22,
			type = "toggle",
			name = "Show Utility Mounts",
			desc =
			"Display clickable utility mount icons on the game menu (ESC).\n|cff00ff00RFurther ustomization options can be found in the Mount Browser.|r",
			get = function() return addon:GetSetting("utilityMounts_enabled") end,
			set = function(i, v)
				addon:SetSetting("utilityMounts_enabled", v)
				-- Refresh utility mounts display
				if addon.UtilityMounts and addon.UtilityMounts.RefreshDisplay then
					addon.UtilityMounts:RefreshDisplay()
				end
			end,
			width = 1.4,
		},

		generalHeader = {
			order = 30,
			type = "header",
			name = "Summon Configuration",
		},
		contextualSummoning = {
			order = 31,
			type = "toggle",
			name = "Contextual Summoning",
			desc = "Automatically filter mounts based on location/situation.",
			get = function() return addon:GetSetting("contextualSummoning") end,
			set = function(i, v)
				addon:SetSetting("contextualSummoning", v)
				-- ENHANCED: Refresh mount pools since this affects mount selection logic
				if addon.MountSummon and addon.MountSummon.RefreshMountPools then
					addon.MountSummon:RefreshMountPools()
					addon:DebugOptions("Refreshed mount pools after contextual summoning change")
				end
			end,
			width = 1.4,
		},

		useDeterministicSummoning = {
			order = 32,
			type = "toggle",
			name = "Improved randomness",
			desc =
			"When enabled, recently used mount groups become temporarily unavailable, ensuring more variety in mount selection. Groups become unavailable for a duration based on your collection size.",
			get = function() return addon:GetSetting("useDeterministicSummoning") end,
			set = function(i, v)
				addon:SetSetting("useDeterministicSummoning", v)
				-- Reset normal deterministic cache when toggling mode
				if addon.MountSummon and addon.MountSummon.deterministicCache then
					for poolName, cache in pairs(addon.MountSummon.deterministicCache) do
						if cache then
							cache.unavailableGroups = {}
							cache.pendingSummon = nil
						end
					end

					addon:DebugSummon("Normal cache reset due to mode toggle")
				end

				-- Also reset rule deterministic cache
				if addon.MountSummon and addon.MountSummon.rulesDeterministicCache then
					addon.MountSummon.rulesDeterministicCache = {}
					addon:DebugSummon("Cleared rule deterministic cache due to mode toggle")
				end

				-- ENHANCED: Refresh mount pools since this affects selection logic
				if addon.MountSummon and addon.MountSummon.RefreshMountPools then
					addon.MountSummon:RefreshMountPools()
					addon:DebugOptions("Refreshed mount pools after deterministic summoning change")
				end
			end,
			width = 1.2,
		},

		summonTargetMount = {
			order = 32.5,
			type = "toggle",
			name = "Summon Target's Mount",
			desc =
			"When targeting a player, summon their current mount instead of using normal mount selection logic. Takes priority over rules and weight settings. If you don't own the mount, the addon will use normal selection instead.",
			get = function() return addon:GetSetting("summonTargetMount") end,
			set = function(i, v)
				addon:SetSetting("summonTargetMount", v)
			end,
			width = 1.2,
		},

		treatUniqueEffectsAsDistinct = {
			order = 33,
			type = "toggle",
			name = "Favor Unique Mounts",
			width = "1.2",
			desc =
			"Displays mounts in their assigned groups regardless whether you enabled the Improved Unique Mount Chances setting.\n|cff00ff00Recommended to keep Enabled|r",
			get = function() return addon:GetSetting("treatUniqueEffectsAsDistinct") end,
			set = function(i, v)
				addon:SetSetting("treatUniqueEffectsAsDistinct", v)
				-- ENHANCED: Explicitly refresh mount pools after trait changes
				C_Timer.After(0.1, function()
					if addon.RefreshMountPools then
						addon:RefreshMountPools()
						addon:DebugOptions("Refreshed mount pools after trait distinctness change")
					end
				end)
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
		},

		syncSettings = {
			name = "",
			type = "group",
			inline = true,
			args = {
				favoriteSyncHeader = {
					order = 100,
					type = "header",
					name = "Weight Sync Settings",
				},

				enableFavoriteSync = {
					order = 101,
					type = "toggle",
					name = "Enable Weight Sync",
					desc = "Automatically sync your WoW Mount Journal favorites with RMB mount weights",
					get = function()
						return addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") or false
					end,
					set = function(i, v)
						if addon.FavoriteSync then
							addon.FavoriteSync:SetSetting("enableFavoriteSync", v)
						end

						-- Reset notification counter when toggling sync
						if addon.uiState then
							addon.uiState.weightChangeNotificationCount = 0
						end

						-- ENHANCED: Refresh mount pools since this affects weight assignments
						C_Timer.After(0.2, function()
							if addon.RefreshMountPools then
								addon:RefreshMountPools()
								addon:DebugOptions("Refreshed mount pools after FavoriteSync enable/disable")
							end

							-- Refresh the Family Management UI to show/hide sync warnings
							if addon.PopulateFamilyManagementUI then
								addon:PopulateFamilyManagementUI()
							end
						end)
					end,
					width = 2,
				},

				weightPriority = {
					order = 101.5,
					type = "description",
					name = "|cffcbcbcbWeight = Summon Chance|r",
					width = 1,
				},

				syncOnLogin = {
					order = 102,
					type = "toggle",
					name = "Sync on Login",
					desc =
					"Automatically sync favorites when you log in.",
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
					width = 1.4,
				},

				syncFamilyWeights = {
					order = 104,
					type = "toggle",
					name = "Sync Family Weights",
					desc =
					"Apply favorite Mount weights to entire mount families when they contain favorite mounts.\nFamilies contain all recolors of a mount.\n|cff00ff00Recommended to keep Enabled|r",
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
								addon:DebugOptions("Refreshed mount pools after family sync setting change")
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
					order = 105,
					type = "toggle",
					name = "Sync Group Weights",
					desc =
					"Apply favorite Mount weights to entire supergroups when they contain favorite mounts.\nGroups contain all recolors and variants of a mount.\n|cff00ff00Recommended to keep Enabled|r",
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
								addon:DebugOptions("Refreshed mount pools after supergroup sync setting change")
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
					width = 1,
				},


				favoriteWeightMode = {
					order = 105,
					type = "select",
					name = "Sync Mode",
					desc =
					"Replace weights: Syncing will update all weights.|cff00ff00Use this if you don't care about modifying weights manually|r.\nOnly increase weights: Syncing will only change weights that are below the selected values.|cff00ff00Use this if you want to set specific mounts/families/groups to a higher weight|r.",
					values = {
						["set"] = "Replace current weights",
						["minimum"] = "Only increase weights",
					},
					get = function()
						return addon.FavoriteSync and addon.FavoriteSync:GetSetting("favoriteWeightMode") or "set"
					end,
					set = function(i, v)
						if addon.FavoriteSync then
							addon.FavoriteSync:SetSetting("favoriteWeightMode", v)
						end

						-- Reset notification counter when changing mode
						if addon.uiState then
							addon.uiState.weightChangeNotificationCount = 0
						end

						-- ENHANCED: Auto-sync after mode change
						C_Timer.After(0.2, function()
							if addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") then
								addon:DebugOptions("Auto-syncing after weight mode change to " .. v)
								addon.FavoriteSync:SyncFavoriteMounts(true)
							end

							if addon.RefreshMountPools then
								addon:RefreshMountPools()
								addon:DebugOptions("Refreshed mount pools after weight mode change")
							end
						end)
					end,
					disabled = function()
						return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
					end,
					width = 1.2,
				},

				nonFavoriteWeight = {
					order = 106,
					type = "select",
					name = "Non-Favorite Mount Weight",
					desc = "Weight applied to mounts not marked as favorites. \nRecommended:0-2",
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
						return addon.FavoriteSync and addon.FavoriteSync:GetSetting("nonFavoriteWeight") or 3
					end,
					set = function(i, v)
						if addon.FavoriteSync then
							addon.FavoriteSync:SetSetting("nonFavoriteWeight", v)
						end

						-- ENHANCED: Auto-sync after weight change
						C_Timer.After(0.2, function()
							if addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") then
								addon:DebugOptions("Auto-syncing after non-favorite weight change to " .. v)
								addon.FavoriteSync:SyncFavoriteMounts(true)
							end

							if addon.RefreshMountPools then
								addon:RefreshMountPools()
								addon:DebugOptions("Refreshed mount pools after non-favorite weight change")
							end
						end)
					end,
					disabled = function()
						return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
					end,
					width = 1.2,
				},

				favoriteWeight = {
					order = 107,
					type = "select",
					name = "Favorite Mount Weight",
					desc = "Weight applied to mounts marked as favorites.\nRecommended:3-5",
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

						-- ENHANCED: Auto-sync after weight change
						C_Timer.After(0.2, function()
							if addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync") then
								addon:DebugOptions("Auto-syncing after favorite weight change to " .. v)
								addon.FavoriteSync:SyncFavoriteMounts(true)
							end

							if addon.RefreshMountPools then
								addon:RefreshMountPools()
								addon:DebugOptions("Refreshed mount pools after favorite weight change")
							end
						end)
					end,
					disabled = function()
						return not (addon.FavoriteSync and addon.FavoriteSync:GetSetting("enableFavoriteSync"))
					end,
					width = 1.2,
				},

				favoriteSyncControlsGroup = {
					order = 108,
					type = "group",
					inline = true,
					name = "",
					args = {

						manualSyncButton = {
							order = 2,
							type = "execute",
							name = "Sync Now",
							desc = "Manually trigger favorite mount sync",
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
						spacer = {
							order = 3,
							type = "description",
							name = " ",
							width = 0.1,
						},
						syncStats = {
							order = 4,
							type = "description",
							name = function()
								if not addon.FavoriteSync then
									return ""
								end

								local stats = addon.FavoriteSync:GetSyncStatistics()
								return string.format("Stats: %d favorite, %d usable mounts | Last sync: %s",
									stats.favoriteMountCount, stats.totalMountCount, stats.lastSyncTimeFormatted)
							end,
							width = 3,
						},
					},
				},
			},
		},
		mountBrowserRedirect = {
			order = 999,
			name = "",
			type = "group",
			inline = true,
			args = {
				displaySettingsHeader = {
					order = 9,
					type = "header",
					name = "Mount Browser",
				},
				browser_button_fmg = {
					order = 20,
					type = "execute",
					name =
					"Open Mount Browser - New Main menu + mount previewer!",
					desc = "Visual grid reference of all mount families and supergroups",
					func = function()
						if addon.MountBrowser then
							addon.MountBrowser:Show()
						else
							addon:AlwaysPrint("Mount Browser not available")
						end
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
	addon:DebugOptions("FAILED to create parent category '" ..
		PARENT_ADDON_DISPLAY_NAME .. "' in Blizzard Options.")
	return -- If parent can't be made, children will fail
else
	addon:DebugOptions("Parent category '" ..
		PARENT_ADDON_DISPLAY_NAME ..
		"' created/found. ID/Name: " .. tostring(rootCategoryID or (rootPanel and rootPanel.name)))
end

-- The key used by AddToBlizOptions for 'parent' is the *display name* if a specific ID isn't returned or known.
local actualParentCategoryKey = rootCategoryID or (rootPanel and rootPanel.name) or PARENT_ADDON_DISPLAY_NAME
--[[-----------------------------------------------------------------------------
    1. Mount List Page
-------------------------------------------------------------------------------]]
local familyManagement_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_FamilyManagement"
local familyManagement_DisplayName = "Mount List (LEGACY)"
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
				addon:DebugOptions("PopulateFamilyManagementUI missing!")
			end
		end,
		width = "full",
	},
	_placeholder_browser_button_fmg = {
		order = 2.5,
		type = "execute",
		name = "Open Mount Browser",
		desc = "Visual grid reference of all mount families and supergroups",
		func = function()
			if addon.MountBrowser then
				addon.MountBrowser:Show()
			else
				addon:AlwaysPrint("Mount Browser not available")
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
	addon:DebugOptions("Registered '" .. familyManagement_DisplayName .. "' page.")
else
	addon:DebugOptions("FAILED Mount List AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    2. Class Settings
-------------------------------------------------------------------------------]]
local classSettings_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_ClassSettings"
local classSettings_DisplayName = "Class Settings"
local favoriteMountsArgsTable = (addon.GetFavoriteMountsForOptions and addon:GetFavoriteMountsForOptions()) or
		{ err = { order = 1, type = "description", name = "Error." } }
local classSettingsOptionsTable = {
	name = classSettings_DisplayName,
	handler = addon,
	type = "group",
	order = 3,
	args = {
		druidHeader = {
			order = 10,
			type = "group",
			name = "Druid",
			inline = true,
			args = {
				useTravelFormWhileMoving = {
					order = 11,
					type = "toggle",
					name = "Cast Travel Form While Moving",
					desc = "If checked, the keybind will use Travel Form while moving (Druids only).",
					get = function() return addon:GetSetting("useTravelFormWhileMoving") end,
					set = function(i, v)
						addon:SetSetting("useTravelFormWhileMoving", v)
					end,
					width = 1.4,
				},

				keepTravelFormActive = {
					order = 12,
					type = "toggle",
					name = "Don't cancel form",
					desc = "If checked, pressing the keybind while already in Travel Form won't cancel the form.",
					get = function() return addon:GetSetting("keepTravelFormActive") end,
					set = function(i, v) addon:SetSetting("keepTravelFormActive", v) end,
					width = 1,
				},

				useSmartFormSwitching = {
					order = 13,
					type = "toggle",
					name = "Smart Form Switching",
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
					width = 1.2,
				},
			},
		},

		shamanHeader = {
			order = 20,
			type = "group",
			name = "Shaman",
			inline = true,
			args = {
				useGhostWolfWhileMoving = {
					order = 21,
					type = "toggle",
					name = "Cast Ghost Wolf While Moving",
					desc = "If checked, the keybind will use Ghost Wolf while moving or in combat (Shamans only).",
					get = function() return addon:GetSetting("useGhostWolfWhileMoving") end,
					set = function(i, v) addon:SetSetting("useGhostWolfWhileMoving", v) end,
					width = 1.4,
				},

				keepGhostWolfActive = {
					order = 22,
					type = "toggle",
					name = "Don't cancel form",
					desc = "If checked, pressing the keybind while already in Ghost Wolf won't cancel the form.",
					get = function() return addon:GetSetting("keepGhostWolfActive") end,
					set = function(i, v) addon:SetSetting("keepGhostWolfActive", v) end,
					width = 1,
				},
			},
		},

		monkHeader = {
			order = 30,
			type = "group",
			name = "Monk",
			inline = true,
			args = {
				useZenFlightWhileMoving = {
					order = 31,
					type = "toggle",
					name = "Cast ZF While Moving/Falling",
					desc =
					"If checked, the keybind will use Zen Flight while moving or falling (Monks only). Will not cast in combat while falling.",
					get = function() return addon:GetSetting("useZenFlightWhileMoving") end,
					set = function(i, v) addon:SetSetting("useZenFlightWhileMoving", v) end,
					width = 1.4,
				},

				keepZenFlightActive = {
					order = 32,
					type = "toggle",
					name = "Don't cancel ZF",
					desc = "If checked, pressing the keybind while already using Zen Flight won't cancel it.",
					get = function() return addon:GetSetting("keepZenFlightActive") end,
					set = function(i, v) addon:SetSetting("keepZenFlightActive", v) end,
					width = 1,
				},
			},
		},

		mageHeader = {
			order = 40,
			type = "group",
			name = "Mage",
			inline = true,
			args = {
				useSlowFallWhileFalling = {
					order = 41,
					type = "toggle",
					name = "Cast Slow Fall While Falling",
					desc = "If checked, the keybind will use Slow Fall while falling (Mages only).",
					get = function() return addon:GetSetting("useSlowFallWhileFalling") end,
					set = function(i, v) addon:SetSetting("useSlowFallWhileFalling", v) end,
					width = 1.4,
				},

				useSlowFallOnOthers = {
					order = 42,
					type = "toggle",
					name = "Cast Slow Fall on Others",
					desc =
					"If checked, Slow Fall will try to cast on your target or mouseover first, before falling back to yourself.",
					get = function() return addon:GetSetting("useSlowFallOnOthers") end,
					set = function(i, v) addon:SetSetting("useSlowFallOnOthers", v) end,
					width = 1.2,
				},
			},
		},

		priestHeader = {
			order = 50,
			type = "group",
			name = "Priest",
			inline = true,
			args = {
				useLevitateWhileFalling = {
					order = 51,
					type = "toggle",
					name = "Cast Levitate While Falling",
					desc = "If checked, the keybind will use Levitate while falling (Priests only).",
					get = function() return addon:GetSetting("useLevitateWhileFalling") end,
					set = function(i, v) addon:SetSetting("useLevitateWhileFalling", v) end,
					width = 1.4,
				},

				useLevitateOnOthers = {
					order = 52,
					type = "toggle",
					name = "Cast Levitate on Others",
					desc =
					"If checked, Levitate will try to cast on your target or mouseover first, before falling back to yourself.",
					get = function() return addon:GetSetting("useLevitateOnOthers") end,
					set = function(i, v) addon:SetSetting("useLevitateOnOthers", v) end,
					width = 1.2,
				},
			},
		},
	},
}
LibAceConfig:RegisterOptionsTable(classSettings_InternalName, classSettingsOptionsTable)
local inspPanel, inspCatID = LibAceConfigDialog:AddToBlizOptions(
	classSettings_InternalName,
	classSettings_DisplayName,
	actualParentCategoryKey
)
if inspPanel then
	addon.optionsPanel_Inspector = {
		frame = inspPanel,
		id = inspCatID or inspPanel.name,
	}
	addon:DebugOptions("Registered '" .. classSettings_DisplayName .. "' page.")
else
	addon:DebugOptions("FAILED Class Settings AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    3. Advanced Settings (Parent Category) - NEW EXPANDABLE STRUCTURE
-------------------------------------------------------------------------------]]
-- Initialize references for dynamic content if they don't exist
if not addon.sgMgmtArgsRef then
	addon.sgMgmtArgsRef = {
		loading_placeholder = {
			order = 1,
			type = "description",
			name = "Loading supergroup data...",
		},
	}
end

if not addon.sgFamilyArgsRef then
	addon.sgFamilyArgsRef = {
		loading_placeholder = {
			order = 1,
			type = "description",
			name = "Loading family assignment data...",
		},
	}
end

if not addon.separationArgsRef then
	addon.separationArgsRef = {
		loading_placeholder = {
			order = 1,
			type = "description",
			name = "Loading mount separation data...",
		},
	}
end

-- Create Advanced Settings parent category
local advancedSettings_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_AdvancedSettings"
local advancedSettings_DisplayName = "Advanced Settings"
local advancedSettingsOptionsTable = {
	name = advancedSettings_DisplayName,
	handler = addon,
	type = "group",
	order = 4,
	args = {
		description = {
			order = 1,
			type = "description",
			name = "|cffffd700Advanced Settings Guide|r\n\n" ..
					"The Advanced Settings allow fully overriding the base mount groupings for maximum customization. I recommend you read the below to get a better idea of how the addon works before making any changes.\n\n" ..
					"|cffffff001. Mounts -> Families|r\n" ..
					"Mounts that use the literal same model but different colors are grouped in families.\n    Example 1: The Black Wolf and the Gray Wolf in the Wolf Family.\n    Example 2: The Black War Wolf and Swift Gray Wolf are in the Armored Wolf family instead since they have extra armor on them.\n\n" ..
					"|cffffff002. Families -> Supergroups|r\n" ..
					"Families with similar models are grouped in the same Supergroups.\n" ..
					"    Example: The Wolf family and the Armored Wolf family are both in the Wolves supergroup.\n" ..
					"Families with truly unique models like Jade, remain standalone (don't get added to supergroups).\n\n" ..
					"|cffffff003. Uniqueness System|r\n" ..
					"Families that are assigned to Groups can be labelled as Unique." ..
					"Enabling the 'Favor Unique Mounts' toggle in Settings will ungroup the Unique Families, meaning that they will compete in the summoning process individually from their group.\n\n" ..
					"|cffffff004. Summoning|r\n" ..
					"The mount summoning process picks a supergroup or ungrouped family, then a mount within it, to equalize chances between mounts with a lot of recolor and unique ones.\n" ..
					"    Example 1: With the default settings, Wolves are one of the eligible groups and ungrouped families for summoning, meaning that to summon the Spectral Wolf, the Wolf group needs to win the roll, then the Spectral Wolf needs to win the roll.\n" ..
					"    Example 2: With the 'Favor Unique Mounts' toggle enabled, the summon pool will contain Wolves + Spectral Wolf separately, heavily increasing the chances of summoning the Spectral Wolf, and doubling the chance to summon any Wolf.\n\n" ..
					"|cff00ff00Available Tools|r\n" ..
					"|cffffff00Supergroup Management:|r Create custom supergroups, rename existing ones, delete unwanted groups\n" ..
					"|cffffff00Family Assignment:|r Move families between supergroups, make families standalone\n" ..
					"|cffffff00Mount Separation:|r Extract individual mounts from families, create custom single-mount families, override traits for separated mounts",
			fontSize = "medium",
		},
	},
}
LibAceConfig:RegisterOptionsTable(advancedSettings_InternalName, advancedSettingsOptionsTable)
local advancedPanel, advancedCatID = LibAceConfigDialog:AddToBlizOptions(
	advancedSettings_InternalName,
	advancedSettings_DisplayName,
	actualParentCategoryKey
)
if advancedPanel then
	addon.optionsPanel_AdvancedSettings = {
		frame = advancedPanel,
		id = advancedCatID or advancedPanel.name,
	}
	addon:DebugOptions("Registered '" .. advancedSettings_DisplayName .. "' parent category.")
else
	addon:DebugOptions("FAILED Advanced Settings parent category AddToBliz.")
end

-- Get the Advanced Settings category key for use as parent
local advancedSettingsParentKey = advancedCatID or (advancedPanel and advancedPanel.name) or advancedSettings_DisplayName
-- Now create the three sub-menus under Advanced Settings
--[[-----------------------------------------------------------------------------
    3a. Supergroup Management (Child of Advanced Settings)
-------------------------------------------------------------------------------]]
local superGroupMgmt_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_SuperGroupMgmt"
local superGroupMgmt_DisplayName = "Supergroup Management"
local superGroupMgmtOptionsTable = {
	name = superGroupMgmt_DisplayName,
	handler = addon,
	type = "group",
	order = 1,
	args = addon.sgMgmtArgsRef, -- Direct reference to dynamic content
}
LibAceConfig:RegisterOptionsTable(superGroupMgmt_InternalName, superGroupMgmtOptionsTable)
local mgmtPanel, mgmtCatID = LibAceConfigDialog:AddToBlizOptions(
	superGroupMgmt_InternalName,
	superGroupMgmt_DisplayName,
	advancedSettingsParentKey -- Child of Advanced Settings
)
if mgmtPanel then
	addon.optionsPanel_SuperGroupMgmt = {
		frame = mgmtPanel,
		id = mgmtCatID or mgmtPanel.name,
	}
	addon:DebugOptions("Registered '" .. superGroupMgmt_DisplayName .. "' as child of Advanced Settings.")
else
	addon:DebugOptions("FAILED Supergroup Management AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    3b. Family Assignment (Child of Advanced Settings)
-------------------------------------------------------------------------------]]
local familyAssign_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_FamilyAssign"
local familyAssign_DisplayName = "Family Assignment"
local familyAssignOptionsTable = {
	name = familyAssign_DisplayName,
	handler = addon,
	type = "group",
	order = 2,
	args = addon.sgFamilyArgsRef, -- Direct reference to dynamic content
}
LibAceConfig:RegisterOptionsTable(familyAssign_InternalName, familyAssignOptionsTable)
local assignPanel, assignCatID = LibAceConfigDialog:AddToBlizOptions(
	familyAssign_InternalName,
	familyAssign_DisplayName,
	advancedSettingsParentKey -- Child of Advanced Settings
)
if assignPanel then
	addon.optionsPanel_FamilyAssign = {
		frame = assignPanel,
		id = assignCatID or assignPanel.name,
	}
	addon:DebugOptions("Registered '" .. familyAssign_DisplayName .. "' as child of Advanced Settings.")
else
	addon:DebugOptions("FAILED Family Assignment AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    3c. Mount Separation (Child of Advanced Settings)
-------------------------------------------------------------------------------]]
local mountSeparation_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_MountSeparation"
local mountSeparation_DisplayName = "Mount Separation"
local mountSeparationOptionsTable = {
	name = mountSeparation_DisplayName,
	handler = addon,
	type = "group",
	order = 3,
	args = addon.separationArgsRef, -- Direct reference to dynamic content
}
LibAceConfig:RegisterOptionsTable(mountSeparation_InternalName, mountSeparationOptionsTable)
local separationPanel, separationCatID = LibAceConfigDialog:AddToBlizOptions(
	mountSeparation_InternalName,
	mountSeparation_DisplayName,
	advancedSettingsParentKey -- Child of Advanced Settings
)
if separationPanel then
	addon.optionsPanel_MountSeparation = {
		frame = separationPanel,
		id = separationCatID or separationPanel.name,
	}
	addon:DebugOptions("Registered '" .. mountSeparation_DisplayName .. "' as child of Advanced Settings.")
else
	addon:DebugOptions("FAILED Mount Separation AddToBliz.")
end

--[[-----------------------------------------------------------------------------
    3d. Zone-Specific Mounts (Child of Advanced Settings)
-------------------------------------------------------------------------------
-- Initialize reference for dynamic content if it doesn't exist
if not addon.zoneSpecificArgsRef then
	addon.zoneSpecificArgsRef = {
		loading_placeholder = {
			order = 1,
			type = "description",
			name = "Loading zone-specific mount data...",
		},
	}
end

local zoneSpecific_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_MountRules"
local zoneSpecific_DisplayName = "Rules"
local zoneSpecificOptionsTable = {
	name = zoneSpecific_DisplayName,
	handler = addon,
	type = "group",
	order = 4,
	args = addon.zoneSpecificArgsRef, -- Direct reference to dynamic content
}
LibAceConfig:RegisterOptionsTable(zoneSpecific_InternalName, zoneSpecificOptionsTable)
local zoneSpecificPanel, zoneSpecificCatID = LibAceConfigDialog:AddToBlizOptions(
	zoneSpecific_InternalName,
	zoneSpecific_DisplayName,
	actualParentCategoryKey -- Top-level tab
)
if zoneSpecificPanel then
	addon.optionsPanel_MountRules = {
		frame = zoneSpecificPanel,
		id = zoneSpecificCatID or zoneSpecificPanel.name,
	}
	addon:DebugOptions("Registered '" .. zoneSpecific_DisplayName .. "' as top-level tab.")
else
	addon:DebugOptions("FAILED Zone-Specific Mounts AddToBliz.")
end
]] --
--[[-----------------------------------------------------------------------------
    4. Import/Export Page (updated order)
-------------------------------------------------------------------------------]]
local importExport_InternalName = PARENT_ADDON_INTERNAL_NAME .. "_ImportExport"
local importExport_DisplayName = "Import/Export"
local importExportOptionsTable = {
	name = importExport_DisplayName,
	handler = addon,
	type = "group",
	order = 10,
	args = {
		desc_ie = {
			order = 2,
			type = "description",
			name = "Share your supergroup configurations with others or reset to default settings.",
			fontSize = "medium",
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
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if not addon.ConfigurationManager then
					return "Configuration Manager not initialized"
				end

				local stats = {
					overrides = 0,
					definitions = 0,
					deletions = 0,
					separatedMounts = 0, -- ENHANCED: Track separated mounts
					zoneSpecificMounts = 0, -- ENHANCED: Track zone-specific mounts
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
						-- ENHANCED: Count zone-specific mounts
						if addon.db.profile.zoneSpecificMounts then
							stats.zoneSpecificMounts = addon:CountTableEntries(addon.db.profile.zoneSpecificMounts)
						end
					end
				end

				return string.format(
					"Configuration Preview:\n- Family Assignments: %d\n- Custom/Renamed Supergroups: %d\n- Deleted Supergroups: %d\n- Separated Mounts: %d",
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
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if addon.ConfigurationManager then
					-- ENHANCED: Include separated mounts in export
					local config = addon.ConfigurationManager:ExportConfiguration()
					if config then
						-- Show the popup with the configuration string
						StaticPopup_Show("RMB_EXPORT_CONFIG_POPUP", nil, nil, {
							configString = config,
						})
						addon:AlwaysPrint("Configuration export popup opened - copy the text from the dialog")
					else
						addon:AlwaysPrint("Failed to generate configuration export")
					end
				else
					addon:AlwaysPrint("ConfigurationManager not available")
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
			-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
			get = function() return addon.ConfigurationManager and addon.ConfigurationManager.pendingImportString or "" end,
			set = function(info, value)
				if addon.ConfigurationManager then
					addon.ConfigurationManager.pendingImportString = value
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
			-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
			get = function() return addon.ConfigurationManager and addon.ConfigurationManager.pendingImportMode or "replace" end,
			set = function(info, value)
				if addon.ConfigurationManager then
					addon.ConfigurationManager.pendingImportMode = value
				end
			end,
			width = 2.75,
		},

		import_button = {
			order = 23,
			type = "execute",
			name = "Import Configuration",
			desc = "Apply the imported configuration",
			func = function()
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if addon.ConfigurationManager then
					local configString = addon.ConfigurationManager.pendingImportString or ""
					local importMode = addon.ConfigurationManager.pendingImportMode or "replace"
					local success, message = addon.ConfigurationManager:ImportConfiguration(configString, importMode)
					if success then
						addon.ConfigurationManager.pendingImportString = ""
						addon:AlwaysPrint("" .. message)
						-- ADDED: Force refresh of all UIs including this options page
						if addon.ConfigurationManager.RefreshAllUIs then
							addon.ConfigurationManager:RefreshAllUIs()
						end

						-- ADDED: Force refresh of the Import/Export options page
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							C_Timer.After(0.1, function()
								LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
							end)
						end
					else
						addon:AlwaysPrint("" .. message)
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

		reset_custom = {
			order = 33,
			type = "execute",
			name = "Reset Supergroup Manager",
			desc = "Remove custom supergroups but keep family assignments",
			func = function()
				StaticPopup_Show("RMB_RESET_CUSTOM_CONFIRM")
			end,
			width = 1.25,
		},

		reset_assignments = {
			order = 34,
			type = "execute",
			name = "Reset Family Assignments",
			desc = "Clear family assignments but keep custom supergroups",
			func = function()
				StaticPopup_Show("RMB_RESET_ASSIGNMENTS_CONFIRM")
			end,
			width = 1.25,
		},

		reset_separation = {
			order = 35,
			type = "execute",
			name = "Reset Mount Separation",
			desc = "Reunite all separated mounts with their original families but keep other settings",
			func = function()
				StaticPopup_Show("RMB_RESET_SEPARATION_CONFIRM")
			end,
			width = 1.25,
		},

		reset_all = {
			order = 36,
			type = "execute",
			name = "Reset Everything",
			desc = "Clear all supergroup customizations and return to default configuration",
			func = function()
				StaticPopup_Show("RMB_RESET_ALL_CONFIRM")
			end,
			width = 3.75,
		},

		-- Validation Section
		validation_header = {
			order = 45,
			type = "header",
			name = "Data Validation & Repair",
		},

		validation_desc = {
			order = 46,
			type = "description",
			name =
			"Check for and fix common data integrity issues including weight sync problems, orphaned settings, and name conflicts.",
			fontSize = "medium",
		},

		validation_check_button = {
			order = 47,
			type = "execute",
			name = "Run Validation Check",
			desc = "Scan for data integrity issues without fixing them",
			func = function()
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if addon.ConfigurationManager then
					local success, report = addon.ConfigurationManager:RunDataValidation(false)
					if success then
						local reportText = addon.ConfigurationManager:FormatValidationReport(report)
						addon.ConfigurationManager.lastValidationReport = reportText
						addon:AlwaysPrint("Validation check completed")
						-- Refresh UI to show the report
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
						end
					else
						addon:AlwaysPrint("" .. tostring(report))
					end
				end
			end,
			width = 1.85,
		},

		validation_fix_button = {
			order = 48,
			type = "execute",
			name = "Run Validation & Auto-Fix",
			desc = "Scan for data integrity issues and automatically fix safe issues",
			func = function()
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if addon.ConfigurationManager then
					local success, report = addon.ConfigurationManager:RunDataValidation(true)
					if success then
						local reportText = addon.ConfigurationManager:FormatValidationReport(report)
						addon.ConfigurationManager.lastValidationReport = reportText
						addon:AlwaysPrint("Validation and auto-fix completed")
						-- If any issues were fixed, trigger a data refresh
						if report.totalFixed > 0 then
							addon:AlwaysPrint("" .. report.totalFixed .. " issues were fixed, refreshing data...")
							-- Trigger data rebuild to apply fixes
							addon:RebuildMountGrouping()
							-- Refresh all UIs - CHANGED: Use ConfigurationManager
							if addon.ConfigurationManager.RefreshAllUIs then
								addon.ConfigurationManager:RefreshAllUIs()
							end
						end

						-- Refresh UI to show the report
						if LibStub and LibStub:GetLibrary("AceConfigRegistry-3.0", true) then
							LibStub("AceConfigRegistry-3.0"):NotifyChange("RandomMountBuddy")
						end
					else
						addon:AlwaysPrint("" .. tostring(report))
					end
				end
			end,
			width = 1.85,
		},

		validation_report = {
			order = 49,
			type = "description",
			name = function()
				-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
				if addon.ConfigurationManager and addon.ConfigurationManager.lastValidationReport then
					return addon.ConfigurationManager.lastValidationReport
				else
					return "|cff888888Click 'Run Validation Check' to scan for data integrity issues.|r"
				end
			end,
			width = "full",
			fontSize = "medium",
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
	addon:DebugOptions("Registered '" .. importExport_DisplayName .. "' page.")
else
	addon:DebugOptions("FAILED Import/Export AddToBliz.")
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
StaticPopupDialogs["RMB_RESET_ALL_CONFIRM"] = {
	text =
	"Reset ALL addon customizations?\n\nThis will:\n- Clear all family assignments\n- Remove all custom supergroups\n- Restore all deleted supergroups\n- Remove all renames\n- Reset ALL separated mounts\n- Clear ALL weight settings\n- Reset ALL trait overrides\n\nThis is a complete reset and cannot be undone!",
	button1 = "Reset Everything",
	button2 = "Cancel",
	OnAccept = function()
		-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
		if addon.ConfigurationManager then
			local success, message = addon.ConfigurationManager:ResetToDefaults("all")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- ENHANCED: Also refresh Mount Separation UI since everything was reset
				if addon.MountSeparationManager and addon.MountSeparationManager.PopulateSeparationManagementUI then
					addon.MountSeparationManager:PopulateSeparationManagementUI()
				end

				-- Use enhanced refresh method that updates ALL UIs
				if addon.ConfigurationManager.RefreshAllUIs then
					addon.ConfigurationManager:RefreshAllUIs()
				end
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
		-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
		if addon.ConfigurationManager then
			local success, message = addon.ConfigurationManager:ResetToDefaults("assignments")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- Use enhanced refresh method that updates ALL UIs
				if addon.ConfigurationManager.RefreshAllUIs then
					addon.ConfigurationManager:RefreshAllUIs()
				end
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
		-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
		if addon.ConfigurationManager then
			local success, message = addon.ConfigurationManager:ResetToDefaults("custom")
			print(success and ("RMB: " .. message) or ("RMB Error: " .. message))
			if success then
				-- Use enhanced refresh method that updates ALL UIs
				if addon.ConfigurationManager.RefreshAllUIs then
					addon.ConfigurationManager:RefreshAllUIs()
				end
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
StaticPopupDialogs["RMB_RESET_SEPARATION_CONFIRM"] = {
	text =
	"Reset mount separation?\n\nThis will:\n- Reunite all separated mounts with their original families\n- Clear weights and settings for separated families\n- Keep individual mount weights\n\nThis cannot be undone!",
	button1 = "Reset Separation",
	button2 = "Cancel",
	OnAccept = function()
		-- CHANGED: Use ConfigurationManager instead of SuperGroupManager
		if addon.ConfigurationManager then
			local success, message = addon.ConfigurationManager:ResetMountSeparationOnly()
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
			self.EditBox:SetText(data.configString)
			self.EditBox:HighlightText()
			self.EditBox:SetFocus()
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
StaticPopupDialogs["RMB_EXPORT_MOUNTS_POPUP"] = {
	text = "New Mounts Export\n\nCopy the data below to add to your data files:",
	button1 = "Close",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, data)
		if data and data.exportString then
			-- Set the edit box text and select all for easy copying
			self.EditBox:SetText(data.exportString)
			self.EditBox:HighlightText()
			self.EditBox:SetFocus()
			-- Update the text to show mount count
			if data.mountCount then
				self.Text:SetText("New Mounts Export (" ..
					data.mountCount .. " mounts)\n\nCopy the data below to add to your data files:")
			end
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
