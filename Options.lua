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
				-- Refresh mount pools if needed
				if addon.RefreshMountPools then
					addon:RefreshMountPools()
				end
			end,
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
		useTravelFormWhileMoving = {
			order = 7,
			type = "toggle",
			name = "Use Travel Form While Moving",
			desc = "If checked, the keybind will use Travel Form while moving (Druids only).",
			get = function() return addon:GetSetting("useTravelFormWhileMoving") end,
			set = function(i, v)
				addon:SetSetting("useTravelFormWhileMoving", v)
				-- Force an update of smartButton if it exists and we're not in combat
				if RandomMountBuddy.smartButton and not InCombatLockdown() then
					local isMoving = IsPlayerMoving()
					if isMoving and v then
						-- If moving and setting turned ON, use Travel Form
						RandomMountBuddy.smartButton:SetAttribute("type", "spell")
						RandomMountBuddy.smartButton:SetAttribute("spell",
							C_Spell.GetSpellInfo(783) and C_Spell.GetSpellInfo(783).name or "Travel Form")
					else
						-- Otherwise use mount
						RandomMountBuddy.smartButton:SetAttribute("type", "macro")
						RandomMountBuddy.smartButton:SetAttribute("macrotext", "/run RandomMountBuddy:SummonRandomMount(true)")
					end

					-- Update lastMoving value in updateFrame if it exists
					if RandomMountBuddy.updateFrame then
						RandomMountBuddy.updateFrame.lastMoving = isMoving
					end
				end
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
		traitStrictnessHeader = {
			order = 10,
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
				addon:RebuildMountGrouping() -- Rebuild the grouping
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
				addon:RebuildMountGrouping() -- Rebuild the grouping
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
				addon:RebuildMountGrouping() -- Rebuild the grouping
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
				addon:RebuildMountGrouping() -- Rebuild the grouping
			end,
			disabled = function() return not addon:GetSetting("useSuperGrouping") end,
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
	name = familyManagement_DisplayName,
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
	name = groupWeights_DisplayName,
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
