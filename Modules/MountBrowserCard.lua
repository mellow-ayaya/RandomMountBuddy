-- MountBrowserCard.lua
-- Card creation, display, model loading, and visibility management
-- Extracted from MountBrowser.lua for better code organization
local addonName, addon = ...
local MountBrowser = addon.MountBrowser
-- ============================================================================
-- CONSTANTS
-- ============================================================================
local CARD_WIDTH = 220
local CARD_HEIGHT = 260
local PREVIEW_HEIGHT = 200
-- Weight display configuration (matches MountUIComponents)
local WeightDisplayMapping = {
	[0] = { text = "Never", color = "ff3e00" },     -- Red
	[1] = { text = "Occasional", color = "9d9d9d" }, -- Grey
	[2] = { text = "Uncommon", color = "cbcbcb" },  -- Light Grey
	[3] = { text = "Normal", color = "ffffff" },    -- White
	[4] = { text = "Common", color = "1eff00" },    -- Green
	[5] = { text = "Often", color = "0070dd" },     -- Blue
	[6] = { text = "Always", color = "ff8000" },    -- Orange
}
-- ============================================================================
-- CAMERA OVERRIDES
-- ============================================================================
-- Camera overrides for specific mount families/supergroups
-- Priority: Mount-specific > Family-specific > Supergroup-wide > Default
local CameraOverrides = {
	["Bakars"] = { x = 9.70, y = -5.00, z = 5.00, yaw = 2.64, pitch = 0.20, roll = 0.00 },
	["Aerial Units"] = { x = 9.70, y = -5.00, z = 5.00, yaw = 2.67, pitch = 0.20, roll = 0.00 },
	["Lepidoptera"] = { x = 2.70, y = -1.60, z = 2.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Bats"] = { x = 7.70, y = -4.00, z = 5.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Bears"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Bears"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Gargons"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Harvesthog"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Oxes"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Moonbeasts"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Meeksi"] = { x = 5.60, y = -3.00, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Moles"] = { x = 6.70, y = -3.40, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Birds"] = { x = 4.20, y = -2.30, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Bruffalon"] = { x = 8.70, y = -4.00, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Motocycles"] = { x = 5.80, y = -2.30, z = 2.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Crawhs"] = { x = 6.70, y = -3.70, z = 4.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Boards"] = { x = 8.70, y = -4.60, z = 5.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Creepers"] = { x = 10.50, y = -5.00, z = 5.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Direhorns"] = { x = 14.10, y = -6.70, z = 6.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Dragonhawks"] = { x = 7.50, y = -4.00, z = 4.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Drakes"] = { x = 8.70, y = -4.60, z = 5.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Storm Dragons"] = { x = 8.70, y = -4.60, z = 5.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Riverwallow"] = { x = 23.80, y = -12.40, z = 13.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Vicious War Riverbeast (PVP)"] = { x = 14.70, y = -7.00, z = 7.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Jellyfishes"] = { x = 11.70, y = -6.00, z = 9.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Subaquatic Jellyfishes"] = { x = 11.70, y = -6.00, z = 9.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Jade"] = { x = 4.70, y = -2.50, z = 2.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Kite"] = { x = 22.70, y = -10.00, z = 8.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Boars"] = { x = 19.90, y = -9.70, z = 10.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Crawgs"] = { x = 8.70, y = -4.60, z = 5.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Darkhounds"] = { x = 6.30, y = -3.10, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Elderhorns"] = { x = 6.70, y = -3.50, z = 3.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Elderhorns"] = { x = 6.70, y = -3.50, z = 3.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Felstalkers"] = { x = 6.70, y = -3.40, z = 3.80, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Discs"] = { x = 5.70, y = -3.00, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Brutosaurs"] = { x = 18.70, y = -8.80, z = 10.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Camels"] = { x = 6.00, y = -3.10, z = 3.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Crane"] = { x = 6.70, y = -3.70, z = 4.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Dread ravens"] = { x = 15.70, y = -10.00, z = 10.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Sabers"] = { x = 3.90, y = -2.20, z = 2.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Sabers"] = { x = 3.90, y = -2.20, z = 2.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Foxes"] = { x = 5.30, y = -2.90, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Foxes"] = { x = 5.30, y = -2.90, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Shu-Zen"] = { x = 5.30, y = -2.90, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Crawler"] = { x = 7.70, y = -3.60, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Goat"] = { x = 8.40, y = -4.10, z = 4.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Ground Ravens"] = { x = 8.80, y = -4.40, z = 5.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Gryphons"] = { x = 8.30, y = -4.00, z = 4.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hawkstriders"] = { x = 6.70, y = -3.80, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hogrus"] = { x = 18.50, y = -8.90, z = 10.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hymenoptera"] = { x = 2.30, y = -1.20, z = 1.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Ottuks"] = { x = 4.00, y = -2.00, z = 2.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Furlines"] = { x = 7.30, y = -3.90, z = 4.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["High Priest's Lightsworn Seeker"] = { x = 7.80, y = -3.50, z = 3.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Magic Rooster"] = { x = 5.00, y = -2.70, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Giants"] = { x = 7.70, y = -4.00, z = 5.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Rats"] = { x = 6.10, y = -3.20, z = 3.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Mechacycle"] = { x = 8.80, y = -4.20, z = 5.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Mawguard Hand"] = { x = 7.90, y = -4.30, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Lions"] = { x = 4.60, y = -2.40, z = 2.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Lions"] = { x = 4.60, y = -2.40, z = 2.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hippogryphs"] = { x = 7.50, y = -3.70, z = 3.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Lupines"] = { x = 5.90, y = -2.80, z = 3.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Lupines"] = { x = 5.90, y = -2.80, z = 3.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Motorcycles"] = { x = 8.60, y = -4.00, z = 4.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Owls"] = { x = 5.70, y = -2.90, z = 3.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Qirajis"] = { x = 8.70, y = -4.50, z = 5.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Rams"] = { x = 7.40, y = -3.60, z = 4.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Raptors"] = { x = 6.70, y = -3.70, z = 4.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Rockets"] = { x = 6.70, y = -3.50, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Goblin Trikes"] = { x = 5.70, y = -3.10, z = 3.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Mechanostriders"] = { x = 5.30, y = -2.90, z = 3.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Horses"] = { x = 6.20, y = -3.10, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Winged Flying Horses"] = { x = 6.20, y = -3.10, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Horses"] = { x = 6.20, y = -3.10, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Skeletal Horses"] = { x = 6.20, y = -3.10, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Talbuks"] = { x = 7.40, y = -3.60, z = 4.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Striders"] = { x = 6.70, y = -3.80, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Skiffs"] = { x = 5.90, y = -3.00, z = 4.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Alpaca"] = { x = 7.10, y = -3.60, z = 2.40, yaw = 2.6400, pitch = 0.0000, roll = 0.0000 },
	["Mechaspiders"] = { x = 7.70, y = -4.00, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Scarabs"] = { x = 7.60, y = -3.90, z = 4.20, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Spiders"] = { x = 5.80, y = -2.80, z = 2.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Swarmites"] = { x = 10.70, y = -5.70, z = 6.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Mechasuits"] = { x = 6.40, y = -3.70, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Mechasuits"] = { x = 6.40, y = -3.70, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Ohunas"] = { x = 5.70, y = -3.00, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hawks"] = { x = 5.70, y = -3.00, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flarendo the Furious"] = { x = 7.70, y = -4.20, z = 4.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flyers"] = { x = 7.10, y = -3.50, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Fishes"] = { x = 8.70, y = -5.00, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Fishes"] = { x = 8.70, y = -5.00, z = 4.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Machines"] = { x = 8.70, y = -4.60, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Glowmite"] = { x = 4.20, y = -2.30, z = 1.80, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Vanquished Wyrms"] = { x = 8.70, y = -4.60, z = 5.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Hyenas"] = { x = 6.60, y = -3.20, z = 3.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Nether Drakes"] = { x = 9.40, y = -4.90, z = 5.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Quilens"] = { x = 5.30, y = -2.90, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Flying Quilens"] = { x = 5.30, y = -2.90, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Scorpions"] = { x = 3.70, y = -2.00, z = 1.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Sea Ray"] = { x = 7.70, y = -3.90, z = 2.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Stags"] = { x = 7.40, y = -3.60, z = 4.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Slateback"] = { x = 8.50, y = -4.30, z = 4.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Skitterfly"] = { x = 7.70, y = -4.30, z = 4.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Water Strider"] = { x = 7.70, y = -4.30, z = 4.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Toads"] = { x = 9.70, y = -5.00, z = 5.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Ur'zul"] = { x = 5.30, y = -2.70, z = 3.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Turtles"] = { x = 3.70, y = -2.00, z = 2.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Subaquatic Turtles"] = { x = 3.70, y = -2.00, z = 2.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Vanquisher Wyrms"] = { x = 9.00, y = -4.70, z = 5.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Vorquins"] = { x = 7.20, y = -3.50, z = 3.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Wandering Ancient"] = { x = 9.70, y = -5.00, z = 5.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Wolfhawks"] = { x = 6.10, y = -3.20, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Wyverns"] = { x = 6.10, y = -3.20, z = 3.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Wolves"] = { x = 5.20, y = -2.70, z = 2.90, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Wooly White Rhino"] = { x = 3.70, y = -2.50, z = 2.30, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Yaks"] = { x = 4.70, y = -2.00, z = 2.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Sweepers"] = { x = 7.70, y = -3.60, z = 3.60, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Skyreavers"] = { x = 7.90, y = -3.50, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Pterrordax"] = { x = 16.70, y = -10.00, z = 11.00, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Phoenixes"] = { x = 8.70, y = -4.30, z = 4.80, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Plaguebats"] = { x = 8.20, y = -4.20, z = 4.10, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Salamanthes"] = { x = 6.70, y = -3.60, z = 3.40, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Snails"] = { x = 8.20, y = -4.50, z = 4.70, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	["Snapdragons"] = { x = 5.90, y = -3.20, z = 3.50, yaw = 2.6400, pitch = 0.2000, roll = 0.0000 },
	-- Add more calibrated settings here...
}
-- Default camera settings (fallback)
local DefaultCamera = { x = 9.70, y = -5.00, z = 5.00, yaw = 2.64, pitch = 0.20, roll = 0.00 }
-- Expose camera settings to addon namespace for use by other modules (e.g., calibrator)
addon.CameraOverrides = CameraOverrides
addon.DefaultCameraSettings = DefaultCamera
-- Get camera settings with inheritance cascade
-- Priority: Mount-specific > Family-specific > Supergroup-wide > Default
-- Get camera settings with inheritance cascade
-- Priority: Mount-specific > Family-specific > Supergroup-wide > Default
local function GetCameraSettings(groupKey, groupType, mountID)
	-- 1. Mount-specific override (highest priority)
	if mountID then
		local mountKey = "mount_" .. mountID
		if CameraOverrides[mountKey] then
			return CameraOverrides[mountKey]
		end
	end

	-- 2. Family-specific override
	if groupType == "familyName" and CameraOverrides[groupKey] then
		return CameraOverrides[groupKey]
	end

	-- 3. Supergroup-wide override
	if groupType == "familyName" then
		-- Get the supergroup this family belongs to
		local supergroup = addon and addon.GetEffectiveSuperGroup and addon:GetEffectiveSuperGroup(groupKey)
		if supergroup and CameraOverrides[supergroup] then
			return CameraOverrides[supergroup]
		end
	elseif groupType == "supergroup" and CameraOverrides[groupKey] then
		return CameraOverrides[groupKey]
	end

	-- 4. Default fallback (lowest priority)
	return DefaultCamera
end

-- Enhanced camera settings with full context
-- Checks: mount-specific > family-specific > supergroup-wide > default
local function GetCameraSettingsWithContext(cameraInfo)
	-- 1. Mount-specific override (highest priority)
	if cameraInfo.mountID then
		local mountKey = "mount_" .. cameraInfo.mountID
		if CameraOverrides[mountKey] then
			return CameraOverrides[mountKey]
		end
	end

	-- 2. Family-specific override
	if cameraInfo.familyName and CameraOverrides[cameraInfo.familyName] then
		return CameraOverrides[cameraInfo.familyName]
	end

	-- 3. Supergroup-wide override (even for separated families)
	if cameraInfo.supergroupName and CameraOverrides[cameraInfo.supergroupName] then
		return CameraOverrides[cameraInfo.supergroupName]
	end

	-- 4. Default fallback (lowest priority)
	return DefaultCamera
end


-- ============================================================================
-- TOOLTIP HELPER FUNCTIONS
-- ============================================================================
-- Format capabilities into readable text for tooltips
function MountBrowser:FormatCapabilities(capabilities)
	if not capabilities then return nil end

	local capTexts = {}
	-- Flying mounts can also be used on ground (WoW convention)
	-- So if mount has flying, only show flying
	if capabilities.flight then
		if capabilities.flightEdgeCase then
			table.insert(capTexts, "Limited Flight")
		else
			table.insert(capTexts, "Flying")
		end
	elseif capabilities.ground then
		-- Only show ground if mount doesn't have flying
		table.insert(capTexts, "Ground")
	end

	-- Only show aquatic if mount actually has it
	if capabilities.swimming then
		table.insert(capTexts, "Aquatic")
	end

	if #capTexts == 0 then return nil end

	return table.concat(capTexts, ", ") .. " mount(s)"
end

-- Highlight search term in display name
function MountBrowser:HighlightSearchTerm(displayName)
	if not displayName then return displayName end

	-- Only highlight if search is active
	if not self.Search or not self.Search:IsActive() then
		return displayName
	end

	local searchTerm = self.Search:GetSearchTerm()
	if not searchTerm or searchTerm == "" then
		return displayName
	end

	-- Case-insensitive search
	local lowerName = displayName:lower()
	local lowerSearch = searchTerm:lower()
	-- Find the search term in the name
	local startPos, endPos = lowerName:find(lowerSearch, 1, true) -- plain text search
	if not startPos then
		return displayName                                         -- No match, return original
	end

	-- Split the name into: before, match, after
	local before = displayName:sub(1, startPos - 1)
	local match = displayName:sub(startPos, endPos)
	local after = displayName:sub(endPos + 1)
	-- Highlight the match in green
	local highlightColor = "|cff00ff00" -- Green
	local resetColor = "|r"
	return before .. highlightColor .. match .. resetColor .. after
end

-- Get collection status text with proper coloring
function MountBrowser:GetCollectionStatusText(data)
	if not data then return nil end

	local textColor = "|cff00ff00" -- Green for collected
	if data.type == "mount" then
		-- Single mount: Collected or Uncollected
		local mountID = data.mountID or (data.mountData and data.mountData.mountID)
		if mountID then
			-- Check if mount data has the isUncollected flag (most reliable source)
			if data.mountData and data.mountData.isUncollected ~= nil then
				-- Use the flag from mount data (set during mount grid construction)
				if data.mountData.isUncollected then
					return "|cffff0000Uncollected|r" -- Red
				else
					return textColor .. "Collected|r"
				end
			else
				-- Fallback to API call if flag not available
				-- Use GetMountInfoExtraByID to check actual ownership, not current summonability
				local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoExtraByID(mountID)
				if isCollected then
					return textColor .. "Collected|r"
				else
					return "|cffff0000Uncollected|r" -- Red
				end
			end
		end
	elseif data.type == "familyName" or data.type == "supergroup" then
		-- Check if comprehensive filters are active
		local hasComprehensiveFilters = false
		if self.Filters and self.Filters.GetTotalActiveFilterCount then
			hasComprehensiveFilters = self.Filters:GetTotalActiveFilterCount() > 0
		end

		-- If filters are active, get filtered counts; otherwise get total counts
		local collectedCount, totalCount
		if hasComprehensiveFilters then
			collectedCount, totalCount = self:GetFilteredMountCounts(data)
		else
			collectedCount, totalCount = self:GetTotalMountCounts(data)
		end

		if totalCount > 0 then
			-- Treat single-mount families like single mounts
			if totalCount == 1 then
				if collectedCount == 1 then
					return textColor .. "Collected|r"
				else
					return "|cffff0000Uncollected|r"
				end
			else
				-- Multiple mounts - show count
				if collectedCount == totalCount then
					return textColor .. "Collected: " .. collectedCount .. "/" .. totalCount .. "|r"
				else
					return "|cffffffff" .. "Collected: " .. collectedCount .. "/" .. totalCount .. "|r"
				end
			end
		end
	end

	return nil
end

-- Get total mount counts (unfiltered)
function MountBrowser:GetTotalMountCounts(data)
	local collectedCount = 0
	local totalCount = 0
	if data.type == "familyName" and addon.processedData then
		collectedCount = (addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[data.key])
				and #addon.processedData.familyToMountIDsMap[data.key] or 0
		local uncollectedCount = (addon.processedData.familyToUncollectedMountIDsMap and addon.processedData.familyToUncollectedMountIDsMap[data.key])
				and #addon.processedData.familyToUncollectedMountIDsMap[data.key] or 0
		totalCount = collectedCount + uncollectedCount
	elseif data.type == "supergroup" and addon.processedData then
		-- Check if families should be kept together
		local groupTogether = addon:GetSetting("browserGroupFamiliesTogether")
		if groupTogether == nil then
			groupTogether = false
		end

		-- Use appropriate map based on grouping setting
		local families = {}
		if not groupTogether then
			-- Use dynamic supergroup map (trait-separated)
			if addon.GetSuperGroupFamilies then
				families = addon:GetSuperGroupFamilies(data.key)
			elseif addon.processedData.dynamicSuperGroupMap then
				families = addon.processedData.dynamicSuperGroupMap[data.key] or {}
			elseif addon.processedData.superGroupMap then
				families = addon.processedData.superGroupMap[data.key] or {}
			end
		else
			-- Use original supergroup map (keep families together)
			if addon.processedData.superGroupMap then
				families = addon.processedData.superGroupMap[data.key] or {}
			end
		end

		for _, familyName in ipairs(families) do
			local famCollected = (addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName])
					and #addon.processedData.familyToMountIDsMap[familyName] or 0
			local famUncollected = (addon.processedData.familyToUncollectedMountIDsMap and addon.processedData.familyToUncollectedMountIDsMap[familyName])
					and #addon.processedData.familyToUncollectedMountIDsMap[familyName] or 0
			collectedCount = collectedCount + famCollected
			totalCount = totalCount + famCollected + famUncollected
		end
	end

	return collectedCount, totalCount
end

-- Get filtered mount counts (only mounts that pass current filters)
function MountBrowser:GetFilteredMountCounts(data)
	if not self.Filters or not self.Filters.ShouldShowMount then
		return self:GetTotalMountCounts(data)
	end

	local collectedCount = 0
	local totalCount = 0
	if data.type == "familyName" and addon.processedData then
		-- Check collected mounts
		if addon.processedData.familyToMountIDsMap then
			local mountIDs = addon.processedData.familyToMountIDsMap[data.key]
			if mountIDs then
				for _, mountID in ipairs(mountIDs) do
					local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
					if mountInfo then
						-- Add mountID to mountInfo for filtering
						local mountWithID = {}
						for k, v in pairs(mountInfo) do
							mountWithID[k] = v
						end

						mountWithID.mountID = mountID
						-- Check if mount passes filters
						if self.Filters:ShouldShowMount(mountWithID) then
							collectedCount = collectedCount + 1
							totalCount = totalCount + 1
						end
					end
				end
			end
		end

		-- Check uncollected mounts
		if addon.processedData.familyToUncollectedMountIDsMap then
			local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[data.key]
			if mountIDs then
				for _, mountID in ipairs(mountIDs) do
					local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
					if mountInfo then
						-- Add mountID to mountInfo for filtering
						local mountWithID = {}
						for k, v in pairs(mountInfo) do
							mountWithID[k] = v
						end

						mountWithID.mountID = mountID
						-- Check if mount passes filters
						if self.Filters:ShouldShowMount(mountWithID) then
							totalCount = totalCount + 1
						end
					end
				end
			end
		end
	elseif data.type == "supergroup" and addon.processedData then
		-- Check if families should be kept together
		local groupTogether = addon:GetSetting("browserGroupFamiliesTogether")
		if groupTogether == nil then
			groupTogether = false
		end

		-- Get families in supergroup using appropriate map
		local families = {}
		if not groupTogether then
			-- Use dynamic map (trait-separated)
			if addon.GetSuperGroupFamilies then
				families = addon:GetSuperGroupFamilies(data.key)
			elseif addon.processedData.dynamicSuperGroupMap then
				families = addon.processedData.dynamicSuperGroupMap[data.key] or {}
			elseif addon.processedData.superGroupMap then
				families = addon.processedData.superGroupMap[data.key] or {}
			end
		else
			-- Use original map (keep families together)
			if addon.processedData.superGroupMap then
				families = addon.processedData.superGroupMap[data.key] or {}
			end
		end

		-- Count filtered mounts from each family
		for _, familyName in ipairs(families) do
			-- Check collected mounts
			if addon.processedData.familyToMountIDsMap then
				local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
				if mountIDs then
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
						if mountInfo then
							-- Add mountID to mountInfo for filtering
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							-- Check if mount passes filters
							if self.Filters:ShouldShowMount(mountWithID) then
								collectedCount = collectedCount + 1
								totalCount = totalCount + 1
							end
						end
					end
				end
			end

			-- Check uncollected mounts
			if addon.processedData.familyToUncollectedMountIDsMap then
				local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[familyName]
				if mountIDs then
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
						if mountInfo then
							-- Add mountID to mountInfo for filtering
							local mountWithID = {}
							for k, v in pairs(mountInfo) do
								mountWithID[k] = v
							end

							mountWithID.mountID = mountID
							-- Check if mount passes filters
							if self.Filters:ShouldShowMount(mountWithID) then
								totalCount = totalCount + 1
							end
						end
					end
				end
			end
		end
	end

	return collectedCount, totalCount
end

-- ============================================================================
-- CARD CREATION
-- ============================================================================
function MountBrowser:CreateCard(parent)
	local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
	card:SetSize(CARD_WIDTH, CARD_HEIGHT)
	-- Card background
	card:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	card:SetBackdropColor(0.1, 0.1, 0.1, 0)
	card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	-- Use utility to set up hover and dynamic tooltip
	MountBrowser:SetupInteractiveElement(card, {
		hoverType = "backdrop",
		tooltipFunc = function(self)
			if not self.data then return nil end

			local lines = {}
			local displayName = self.data.displayName or self.data.key
			-- Determine card type (mount, familyName, or supergroup)
			local cardType = self.data.type
			local mountID = nil
			local isSingleMountFamily = false
			-- Check if familyName is actually a single-mount family
			if cardType == "familyName" and addon.processedData then
				local mountIDs = addon.processedData.familyToMountIDsMap and
						addon.processedData.familyToMountIDsMap[self.data.key]
				local uncollectedMountIDs = addon.processedData.familyToUncollectedMountIDsMap and
						addon.processedData.familyToUncollectedMountIDsMap[self.data.key]
				local allMountIDs = {}
				if mountIDs then
					for _, id in ipairs(mountIDs) do table.insert(allMountIDs, id) end
				end

				if uncollectedMountIDs then
					for _, id in ipairs(uncollectedMountIDs) do table.insert(allMountIDs, id) end
				end

				if #allMountIDs == 1 then
					isSingleMountFamily = true
					mountID = allMountIDs[1]
				end
			end

			-- Get mountID for regular mounts
			if cardType == "mount" then
				mountID = self.data.mountID or (self.data.mountData and self.data.mountData.mountID)
			end

			-- Build tooltip based on card type
			if (cardType == "mount" or isSingleMountFamily) and mountID then
				-- ========== MOUNT TOOLTIP ==========
				-- Get actual mount name from game
				local mountName = C_MountJournal.GetMountInfoByID(mountID) or displayName
				-- [MOUNT] mountname
				table.insert(lines,
					"|cff1eff00Mount|r|cffffffff(|TInterface\\AddOns\\RandomMountBuddy\\media\\mount.tga:16:16:0:0|t)|r " ..
					mountName)
				-- Capabilities
				local capabilities = MountBrowser:GetCapabilitiesForCard(self.data)
				local capText = MountBrowser:FormatCapabilities(capabilities)
				if capText then
					table.insert(lines, "|cff00ccff" .. capText .. "|r")
				end

				-- Description
				local _, description, source = C_MountJournal.GetMountInfoExtraByID(mountID)
				if description and description ~= "" then
					table.insert(lines, "|cffCCA700" .. description .. "|r")
				end

				-- Source
				if source and source ~= "" then
					table.insert(lines, "|cffffd700Source:|r |cffffffff" .. source .. "|r")
				end

				-- Collection status
				local collectionText = MountBrowser:GetCollectionStatusText(self.data)
				if collectionText then
					table.insert(lines, collectionText)
				end

				-- Spacer
				table.insert(lines, " ")
				-- Summon instruction
				table.insert(lines, "|cffffd700Shift/Ctrl + Left click:|r |cffffffffSummon mount|r")
			elseif cardType == "familyName" then
				-- ========== FAMILY TOOLTIP ==========
				-- [FAMILY] familyname
				table.insert(lines,
					"|cffa335eeFamily|r|cffffffff(|TInterface\\AddOns\\RandomMountBuddy\\media\\family.tga:16:16:0:0|t)|r " ..
					displayName)
				-- Capabilities
				local capabilities = MountBrowser:GetCapabilitiesForCard(self.data)
				local capText = MountBrowser:FormatCapabilities(capabilities)
				if capText then
					table.insert(lines, "|cff00ccff" .. capText .. "|r")
				end

				-- Description
				table.insert(lines,
					"|cffffd700This is a Family, all recolors of the " ..
					displayName .. "|r |cffffd700can be found here.|r")
				-- Collection status
				local collectionText = MountBrowser:GetCollectionStatusText(self.data)
				if collectionText then
					table.insert(lines, collectionText)
				end

				-- Spacer
				table.insert(lines, " ")
				-- Navigation instructions
				table.insert(lines,
					"|cffffd700Left Click:|r |cffffffffOpen " .. displayName .. " family|r")
				table.insert(lines, "|cffffd700Shift/Ctrl + Left click:|r |cffffffffSummon random " .. displayName)
			elseif cardType == "supergroup" then
				-- ========== GROUP TOOLTIP ==========
				-- [GROUP] groupname
				table.insert(lines,
					"|cffff8000Group|r|cffffffff(|TInterface\\AddOns\\RandomMountBuddy\\media\\group.tga:16:16:0:0|t)|r " ..
					displayName)
				-- Capabilities
				local capabilities = MountBrowser:GetCapabilitiesForCard(self.data)
				local capText = MountBrowser:FormatCapabilities(capabilities)
				if capText then
					table.insert(lines, "|cff00ccff" .. capText .. "|r")
				end

				-- Description
				table.insert(lines,
					"This is a Group, all recolors and variants of the " .. displayName .. " can be found here.")
				-- Collection status
				local collectionText = MountBrowser:GetCollectionStatusText(self.data)
				if collectionText then
					table.insert(lines, collectionText)
				end

				-- Spacer
				table.insert(lines, " ")
				-- Navigation instructions
				table.insert(lines, "|cffffd700Left Click:|r |cffffffffOpen " .. displayName .. " group|r")
				table.insert(lines, "|cffffd700Shift/Ctrl + Left click:|r |cffffffffSummon random " .. displayName)
			end

			-- Add back button if nested
			if MountBrowser.navigationStack and #MountBrowser.navigationStack > 0 then
				table.insert(lines, "|cffffd700Right Click:|r |cff1eff00Go Back|r")
			end

			return lines[1], { unpack(lines, 2) }
		end,
		tooltipAnchor = "ANCHOR_TOP",
	})
	-- Preview model using ModelScene
	card.modelScene = CreateFrame("ModelScene", nil, card)
	card.modelScene:SetPoint("TOP", 0, -3)
	card.modelScene:SetSize(CARD_WIDTH - 6, PREVIEW_HEIGHT)
	-- Keep model below the card border
	card.modelScene:SetFrameLevel(card:GetFrameLevel() - 1)
	-- Set camera position: X, Y (up/down), Z (distance)
	-- Y=1 raises camera above ground, Z=3 moves back
	card.modelScene:SetCameraPosition(10, 0, 0)
	-- Rotate camera 180 degrees to face FRONT of mount
	card.modelScene:SetCameraOrientationByYawPitchRoll(math.pi, -0.3, 0)
	-- Create actor for the model
	card.actor = card.modelScene:CreateActor()
	-- Mount journal style textured background (positioned with model)
	card.previewBg = card.modelScene:CreateTexture(nil, "BACKGROUND")
	card.previewBg:SetPoint("TOPLEFT", 1, -3)
	card.previewBg:SetSize(CARD_WIDTH - 8, CARD_HEIGHT - 8)
	card.previewBg:SetTexture(651761)
	card.previewBg:SetTexCoord(0.3, 0.7, 0.1, 0.9) -- Crop 10% from edges
	card.previewBg:SetVertexColor(1, 1, 1, 1)
	-- Name label
	card.nameLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	card.nameLabel:SetPoint("TOP", card.modelScene, "BOTTOM", 0, -8)
	card.nameLabel:SetWidth(CARD_WIDTH - 10)
	card.nameLabel:SetJustifyH("CENTER")
	card.nameLabel:SetWordWrap(false) -- Prevent wrapping, font will be sized adaptively
	-- Collection status label (positioned above name)
	local nameBg = card.nameLabel    -- Reference for positioning
	card.collectionStatus = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	card.collectionStatus:SetPoint("BOTTOM", nameBg, "TOP", 0, 5)
	card.collectionStatus:SetWidth(CARD_WIDTH - 10)
	card.collectionStatus:SetJustifyH("CENTER")
	-- Type icon (Mount/Family/Group) - top left corner, mirrors capability icon position
	local adjustmentY = -3
	card.typeIconFrame = CreateFrame("Frame", nil, card)
	card.typeIconFrame:SetSize(24, 24)
	card.typeIconFrame:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -8 + adjustmentY)
	-- Create icon texture on the frame
	card.typeIcon = card.typeIconFrame:CreateTexture(nil, "OVERLAY", nil, 7)
	card.typeIcon:SetAllPoints(card.typeIconFrame)
	-- Use utility to set up dynamic tooltip
	MountBrowser:SetupDynamicTooltip(card.typeIconFrame, {
		textFunc = function(self)
			local tooltipText = ""
			local tooltipDesc = ""
			if self.cardType == "mount" then
				tooltipText = "Mount"
				tooltipDesc = "A single mount"
			elseif self.cardType == "familyName" then
				tooltipText = "Family"
				tooltipDesc = "Families contain all recolors of a mount"
			elseif self.cardType == "supergroup" then
				tooltipText = "Group"
				tooltipDesc = "Groups contain all recolors and variants of a mount"
			end

			return tooltipText, tooltipDesc ~= "" and tooltipDesc or nil
		end,
		anchor = "ANCHOR_TOP",
	})
	-- START WITH MOUSE DISABLED to prevent tooltip spam on first scroll
	-- Mouse will be re-enabled during UpdateCard when card is visible and not scrolling
	card.typeIconFrame:EnableMouse(false)
	card.typeIconFrame:Show()
	-- Weight label
	card.weightLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	card.weightLabel:SetPoint("TOP", card.nameLabel, "BOTTOM", 0, -5)
	-- Weight decrease button [-]
	card.weightDecrease = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
	card.weightDecrease:SetSize(20, 20)
	card.weightDecrease:SetPoint("RIGHT", card.weightLabel, "LEFT", -5, 0)
	card.weightDecrease:SetText("-")
	card.weightDecrease:SetScript("OnClick", function(self, button)
		if card.data and card.data.key then
			-- Check if we should notify about weight sync
			local shouldNotify, notificationMessage = addon:CheckWeightChangeNotification(card.data.key, false)
			if shouldNotify and notificationMessage then
				addon:AlwaysPrint(notificationMessage)
				-- Increment notification counter
				if addon.uiState then
					addon.uiState.weightChangeNotificationCount = (addon.uiState.weightChangeNotificationCount or 0) + 1
				end
			end

			addon:DecrementGroupWeight(card.data.key)
			-- Refresh the card display
			MountBrowser:UpdateCard(card, card.data)
		end

		self:GetParent():GetScript("OnLeave")(self:GetParent()) -- Reset highlight
	end)
	-- Weight increase button [+]
	card.weightIncrease = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
	card.weightIncrease:SetSize(20, 20)
	card.weightIncrease:SetPoint("LEFT", card.weightLabel, "RIGHT", 5, 0)
	card.weightIncrease:SetText("+")
	card.weightIncrease:SetScript("OnClick", function(self, button)
		if card.data and card.data.key then
			-- Check if we should notify about weight sync
			local shouldNotify, notificationMessage = addon:CheckWeightChangeNotification(card.data.key, true)
			if shouldNotify and notificationMessage then
				addon:AlwaysPrint(notificationMessage)
				-- Increment notification counter
				if addon.uiState then
					addon.uiState.weightChangeNotificationCount = (addon.uiState.weightChangeNotificationCount or 0) + 1
				end
			end

			addon:IncrementGroupWeight(card.data.key)
			-- Refresh the card display
			MountBrowser:UpdateCard(card, card.data)
		end

		self:GetParent():GetScript("OnLeave")(self:GetParent()) -- Reset highlight
	end)
	-- Mount name textured background
	card.nameBg = card:CreateTexture(nil, "BACKGROUND")
	card.nameBg:SetPoint("CENTER", card.nameLabel, 0, -9)
	card.nameBg:SetSize(CARD_WIDTH - 6, 60)
	card.nameBg:SetAtlas("garr_listtab")
	-- Collection status textured background
	card.collectionStatusBg = card:CreateTexture(nil, "BACKGROUND")
	card.collectionStatusBg:SetPoint("CENTER", card.collectionStatus, 0, 0)
	card.collectionStatusBg:SetSize(CARD_WIDTH - 6, 15)
	card.collectionStatusBg:SetAtlas("BossBanner-BgBanner-Mid")
	-- Trait icons container (positioned at very top of card, above everything)
	card.traitContainer = CreateFrame("Frame", nil, card)
	card.traitContainer:SetPoint("TOP", card, "TOP", 0, -13)
	card.traitContainer:SetSize(CARD_WIDTH - 20, 20)
	card.traitButtons = {}
	-- Trait data with custom icon names (will use _up/_down from media folder)
	local traitData = {
		{
			key = "isUniqueEffect",
			iconPath = "Interface\\ICONS\\Inv_70_raid_ring6a",
			tooltipTitle = "Unique variant",
			tooltipDesc = {
				"|cffffd700Click to toggle|r",
				"|cff00ff00Unique mounts get independent (better) summon chances when 'Favor Unique Mounts' is enabled.|r",
			},
		},
	}
	for _, data in ipairs(traitData) do
		local trait = data.key
		-- Create clickable button
		local button = CreateFrame("Button", nil, card.traitContainer)
		button:SetSize(20, 20)
		button:Hide()
		-- Background
		button.bg = button:CreateTexture(nil, "BACKGROUND")
		button.bg:SetAllPoints()
		button.bg:SetColorTexture(0, 0, 0, 0)
		-- Icon texture (WoW interface icon)
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetSize(20, 20)
		button.icon:SetPoint("CENTER")
		button.icon:SetTexture(data.iconPath)
		-- Zoom in slightly to crop the shine at top of gem icons
		-- Format: left, right, top, bottom (simple crop)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		-- Set initial state (inactive = grayed out)
		button.icon:SetDesaturated(true)
		-- Store data
		button.traitKey = trait
		button.iconPath = data.iconPath
		button.tooltipTitle = data.tooltipTitle
		button.tooltipDesc = data.tooltipDesc
		button.isActive = false
		-- Click handler to toggle trait
		button:SetScript("OnClick", function(self, mouseButton)
			if card.data and addon.SetFamilyTrait and addon.MountDataManager then
				-- Get current trait value
				local currentTraits = addon.MountDataManager:GetFamilyTraits(card.data.key)
				local currentValue = currentTraits[self.traitKey] or false
				-- Toggle the value and set it
				local newValue = not currentValue
				addon:SetFamilyTrait(card.data.key, self.traitKey, newValue)
				-- Update icon desaturation (grayed = inactive, colored = active)
				self.isActive = newValue
				self.icon:SetDesaturated(not newValue)
				-- Invalidate cache and refresh card
				addon.MountDataManager:InvalidateTraitCache(card.data.key)
				MountBrowser:UpdateCard(card, card.data)
			end
		end)
		-- Use utility to set up hover and tooltip
		MountBrowser:SetupInteractiveElement(button, {
			hoverType = "texture",
			defaultColor = MountBrowser.VISUAL_STATES.TRAIT_BG_DEFAULT,
			hoverColor = MountBrowser.VISUAL_STATES.TRAIT_BG_HOVER,
			tooltipFunc = function(self)
				return self.tooltipTitle, self.tooltipDesc
			end,
			tooltipAnchor = "ANCHOR_TOP",
			wrap = false, -- Disable wrapping to prevent extra newline at top
		})
		card.traitButtons[trait] = button
		-- START WITH MOUSE DISABLED to prevent tooltip spam on first scroll
		-- Mouse will be enabled during UpdateCard when card becomes visible and not scrolling
		button:EnableMouse(false)
	end

	-- Click handler (left-click navigates, ctrl/shift+left summons, right-click goes back)
	card:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			-- Check for modifier keys (Ctrl or Shift) for summoning
			if IsControlKeyDown() or IsShiftKeyDown() then
				MountBrowser:SummonFromCard(self)
			else
				MountBrowser:OnCardClick(self)
			end
		elseif button == "RightButton" then
			MountBrowser:NavigateBack()
		end
	end)
	-- Create capability icons
	addon:DebugUI("RMB_CAP: About to call CreateCapabilityIcons during card creation")
	self:CreateCapabilityIcons(card)
	return card
end

-- ============================================================================
-- VISIBILITY SYSTEM
-- ============================================================================
function MountBrowser:StartVisibilityCheck()
	if self.visibilityCheckActive then return end

	addon:DebugUI("StartVisibilityCheck called")
	self.visibilityCheckActive = true
	-- Initial check to load visible cards
	addon:DebugUI("StartVisibilityCheck calling initial CheckVisiblecards.")
	self:CheckVisibleCards()
	-- Note: Ongoing visibility checks are handled by OnVerticalScroll and OnMouseWheel
	-- which both call CheckVisibleCards() with throttling
end

function MountBrowser:StopVisibilityCheck()
	if not self.visibilityCheckActive then return end

	self.visibilityCheckActive = false
	-- No event cleanup needed - scroll handlers remain active
end

-- Check which cards are visible and queue them for loading
-- Check which cards are visible and queue them for loading
function MountBrowser:CheckVisibleCards()
	if not self.mainFrame or not self.mainFrame:IsShown() then
		return
	end

	local scrollFrame = self.mainFrame.scrollFrame
	if not scrollFrame then return end

	local scrollTop = scrollFrame:GetVerticalScroll()
	local scrollBottom = scrollTop + scrollFrame:GetHeight()
	-- Add buffer zone for smoother loading (load slightly outside viewport)
	local bufferZone = 300
	local loadTop = math.max(0, scrollTop - bufferZone)
	local loadBottom = scrollBottom + bufferZone
	-- Limit how many we queue at once to prevent overload
	local queuedThisCheck = 0
	local maxQueuePerCheck = 10 -- Reduced from 15 for graphics engine safety
	-- Collect cards that need updating
	local cardsToUpdate = {}
	-- Check each card in the pool
	for _, card in ipairs(self.cardPool) do
		if card:IsVisible() and card.data then
			-- Check if card is in visible area (with buffer)
			local cardTop = math.abs(card:GetTop() - self.mainFrame.scrollChild:GetTop())
			local cardBottom = cardTop + card:GetHeight()
			local isInViewport = (cardBottom >= loadTop and cardTop <= loadBottom)
			if isInViewport then
				-- Collect card if it needs updating
				if card.currentDataKey ~= card.data.key then
					table.insert(cardsToUpdate, card)
				end

				-- Queue model loading if in viewport and not loaded
				if not card.modelLoaded and card.repMount then
					if queuedThisCheck < maxQueuePerCheck then
						self:QueueModelLoad(card, card.repMount)
						queuedThisCheck = queuedThisCheck + 1
					end
				end

				-- Enable mouse for all interactive elements (when not actively scrolling)
				if not self.isActivelyScrolling then
					if card.typeIconFrame then
						card.typeIconFrame:EnableMouse(true)
					end

					if card.traitButtons then
						for _, button in pairs(card.traitButtons) do
							if button:IsShown() then
								button:EnableMouse(true)
							end
						end
					end

					if card.capabilityIconFrames then
						for _, iconFrame in pairs(card.capabilityIconFrames) do
							iconFrame:EnableMouse(true)
						end
					end
				end
			else
				-- Card is outside viewport - disable mouse to reduce event handlers
				if card.typeIconFrame then
					card.typeIconFrame:EnableMouse(false)
				end

				if card.traitButtons then
					for _, button in pairs(card.traitButtons) do
						button:EnableMouse(false)
					end
				end

				if card.capabilityIconFrames then
					for _, iconFrame in pairs(card.capabilityIconFrames) do
						iconFrame:EnableMouse(false)
					end
				end
			end
		end
	end

	-- Batch update cards to spread load across frames
	if #cardsToUpdate > 0 then
		self:BatchUpdateCards(cardsToUpdate)
	end
end

-- ============================================================================
-- BATCHED CARD UPDATES
-- ============================================================================
-- Batch update multiple cards with progressive loading to prevent frame drops
function MountBrowser:BatchUpdateCards(cards)
	if not cards or #cards == 0 then return end

	-- If only a few cards, update them immediately
	-- If only 1-2 cards, update them immediately
	if #cards <= 2 then
		for _, card in ipairs(cards) do
			if card and card.data then
				self:UpdateCard(card, card.data)
			end
		end

		return
	end

	-- For larger batches, spread updates across multiple frames
	-- Update 2 cards per frame with 20ms (~3 frames @ 60fps) between batches for smoother loading
	local batchSize = 2
	local currentIndex = 1
	local totalCards = #cards
	local function processBatch()
		if not self.mainFrame or not self.mainFrame:IsShown() then
			return -- Stop if browser was closed
		end

		local endIndex = math.min(currentIndex + batchSize - 1, totalCards)
		-- Process this batch
		for i = currentIndex, endIndex do
			local card = cards[i]
			if card and card.data then
				-- Only update if still needs updating (user might have scrolled)
				if card.currentDataKey ~= card.data.key then
					self:UpdateCard(card, card.data)
				end
			end
		end

		currentIndex = endIndex + 1
		-- Schedule next batch if there are more cards
		if currentIndex <= totalCards then
			C_Timer.After(0.020, processBatch) -- ~1.2 frames delay for smoother feel
		end
	end

	-- Start processing
	processBatch()
end

-- ============================================================================
-- CARD DISPLAY
-- ============================================================================
-- Show cards immediately (frames are lightweight, models load progressively)
function MountBrowser:ShowCards(cardsData)
	-- Show all cards at once
	for _, cardData in ipairs(cardsData) do
		if cardData and cardData.card then
			cardData.card:Show()
		end
	end

	-- Trigger immediate visibility check
	self:CheckVisibleCards()
end

-- PROGRESSIVE MODEL LOADING
-- ============================================================================
-- ============================================================================
-- MODEL LOADING QUEUE
-- ============================================================================
function MountBrowser:QueueModelLoad(card, repMount)
	if not card or not repMount then return end

	-- Check if already queued
	for _, item in ipairs(self.loadQueue) do
		if item.card == card then
			return -- Already queued
		end
	end

	-- Add to queue
	table.insert(self.loadQueue, {
		card = card,
		repMount = repMount,
		addedTime = GetTime(),
	})
	-- Start processing if not already running
	if not self.isLoading then
		self:ProcessLoadQueue()
	end
end

-- Process the load queue progressively with improved safety
function MountBrowser:ProcessLoadQueue()
	if #self.loadQueue == 0 then
		self.isLoading = false
		return
	end

	self.isLoading = true
	-- Skip invisible cards to reduce wasted processing
	local item = nil
	local skipped = 0
	while #self.loadQueue > 0 and skipped < 10 do
		item = table.remove(self.loadQueue, 1)
		if item.card and item.card:IsVisible() then
			break
		end

		item = nil
		skipped = skipped + 1
	end

	-- If we found a visible card, load it
	if item and item.card and item.card.actor and item.card:IsVisible() then
		local mountID = item.repMount.mountID
		if mountID then
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mountID))
			if creatureDisplayID then
				local success = pcall(function()
					item.card.actor:SetModelByCreatureDisplayID(creatureDisplayID)
				end)
				if success then
					item.card.modelLoaded = true
					-- Re-apply camera settings after model loads
					if item.card.cameraSettings and item.card.modelScene then
						local cam = item.card.cameraSettings
						item.card.modelScene:SetCameraPosition(cam.x, cam.y, cam.z)
						item.card.modelScene:SetCameraOrientationByYawPitchRoll(cam.yaw, cam.pitch, cam.roll)
					end
				else
					-- Model failed to load, mark as failed but don't crash
					item.card.modelLoaded = false
					addon:DebugUI("Failed to load model for mount " .. mountID)
				end
			else
				-- First try: GetAllCreatureDisplayIDsForMountID (works for class-restricted mounts)
				local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mountID)
				if allDisplayIDs and #allDisplayIDs > 0 then
					-- Use the first displayID (could randomize if desired)
					creatureDisplayID = allDisplayIDs[1]
					addon:DebugUI("Using alternate API for mount " ..
						mountID .. " - found " .. #allDisplayIDs .. " displayIDs, using: " .. creatureDisplayID)
					local success = pcall(function()
						item.card.actor:SetModelByCreatureDisplayID(creatureDisplayID)
					end)
					if success then
						item.card.modelLoaded = true
						-- Re-apply camera settings after model loads
						if item.card.cameraSettings and item.card.modelScene then
							local cam = item.card.cameraSettings
							item.card.modelScene:SetCameraPosition(cam.x, cam.y, cam.z)
							item.card.modelScene:SetCameraOrientationByYawPitchRoll(cam.yaw, cam.pitch, cam.roll)
						end
					else
						item.card.modelLoaded = false
						addon:DebugUI("Failed to load model using alternate API for mount " .. mountID)
					end
				else
					-- Second try: GetAlternativeMount (find a different mount in same family)
					addon:DebugUI("No display ID found for mount " .. mountID .. " - trying alternative mount")
					item.card.modelLoaded = false
					-- Try to find an alternative mount from the same family/supergroup
					-- that CAN be displayed (has valid displayID)
					if item.card.data then
						local alternativeMount = self:GetAlternativeMount(item.card.data.key, item.card.data.type, mountID)
						if alternativeMount and alternativeMount.mountID then
							addon:DebugUI("Found alternative mount " .. alternativeMount.mountID .. " for " .. mountID)
							-- Try loading the alternative
							local altDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(alternativeMount.mountID))
							if altDisplayID then
								local success = pcall(function()
									item.card.actor:SetModelByCreatureDisplayID(altDisplayID)
								end)
								if success then
									item.card.modelLoaded = true
									item.card.repMount = alternativeMount -- Update the representative
									addon:DebugUI("Successfully loaded alternative mount " .. alternativeMount.mountID)
								end
							end
						else
							addon:DebugUI("No alternative mount found for " .. mountID)
						end
					end
				end
			end
		end
	end

	-- Schedule next load with increased delay for stability
	if #self.loadQueue > 0 then
		C_Timer.After(self.loadDelay, function()
			self:ProcessLoadQueue()
		end)
	else
		self.isLoading = false
	end
end

-- Clear the load queue
function MountBrowser:ClearLoadQueue()
	self.loadQueue = {}
	self.isLoading = false
end

-- ============================================================================
-- REPRESENTATIVE MOUNT SELECTION
-- ============================================================================
function MountBrowser:GetRepresentativeMount(key, type)
	if not addon.processedData then return nil end

	-- Build cache key
	local cacheKey = type .. ":" .. key
	-- Check cache first
	if self.representativeMountCache[cacheKey] then
		local cachedMountID = self.representativeMountCache[cacheKey]
		addon:DebugUI("GetRepresentativeMount: Using cached mount " .. cachedMountID .. " for " .. cacheKey)
		-- Validate cached mount still exists
		local isCollected = addon.processedData.allCollectedMountFamilyInfo[cachedMountID]
		local isUncollected = addon.processedData.allUncollectedMountFamilyInfo[cachedMountID]
		if isCollected or isUncollected then
			-- Reconstruct mount data
			local mountInfo = isCollected or isUncollected
			local mountWithID = {}
			for k, v in pairs(mountInfo) do
				mountWithID[k] = v
			end

			mountWithID.mountID = cachedMountID
			mountWithID.isUncollected = not isCollected
			return mountWithID
		else
			-- Cached mount no longer exists, clear cache entry
			addon:DebugUI("GetRepresentativeMount: Cached mount " .. cachedMountID .. " no longer exists, reselecting")
			self.representativeMountCache[cacheKey] = nil
		end
	end

	local mounts = {}
	if type == "supergroup" then
		-- Get all mounts from all families in supergroup
		if addon.processedData.superGroupMap and addon.processedData.superGroupMap[key] then
			local families = addon.processedData.superGroupMap[key]
			for _, familyName in ipairs(families) do
				-- Try collected mounts first
				if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName] then
					local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
						if mountInfo then
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

				-- If no collected mounts, try uncollected
				if #mounts == 0 and addon.processedData.familyToUncollectedMountIDsMap and
						addon.processedData.familyToUncollectedMountIDsMap[familyName] then
					local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[familyName]
					for _, mountID in ipairs(mountIDs) do
						local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
						if mountInfo then
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
			end
		end
	elseif type == "familyName" then
		-- Get all mounts in family
		-- Try collected mounts first
		if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[key] then
			local mountIDs = addon.processedData.familyToMountIDsMap[key]
			for _, mountID in ipairs(mountIDs) do
				local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
				if mountInfo then
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

		-- If no collected mounts, try uncollected
		if #mounts == 0 and addon.processedData.familyToUncollectedMountIDsMap and
				addon.processedData.familyToUncollectedMountIDsMap[key] then
			local mountIDs = addon.processedData.familyToUncollectedMountIDsMap[key]
			for _, mountID in ipairs(mountIDs) do
				local mountInfo = addon.processedData.allUncollectedMountFamilyInfo[mountID]
				if mountInfo then
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
	end

	if #mounts == 0 then
		addon:DebugUI("GetRepresentativeMount: No mounts found for " .. key .. " (type: " .. type .. ")")
		return nil
	end

	-- Debug: Log all mounts found
	addon:DebugUI("GetRepresentativeMount for " .. key .. " found " .. #mounts .. " mounts")
	for i, mount in ipairs(mounts) do
		if mount.mountID then
			addon:DebugUI("  Mount " ..
				i ..
				": ID=" ..
				mount.mountID .. ", name=" .. (mount.name or "unknown") .. ", isUncollected=" .. tostring(mount.isUncollected))
		end
	end

	-- Filter mounts if comprehensive filters are active
	if self.Filters and self.Filters.GetTotalActiveFilterCount and self.Filters.ShouldShowMount then
		local filterCount = self.Filters:GetTotalActiveFilterCount()
		if filterCount > 0 then
			local filteredMounts = {}
			for _, mount in ipairs(mounts) do
				if self.Filters:ShouldShowMount(mount) then
					table.insert(filteredMounts, mount)
				end
			end

			if #filteredMounts > 0 then
				mounts = filteredMounts
				addon:DebugUI("GetRepresentativeMount: Filtered to " .. #mounts .. " mounts matching active filters")
			else
				addon:DebugUI("GetRepresentativeMount: No mounts match filters, using all mounts as fallback")
			end
		end
	end

	-- Randomize mount selection to allow variety in previews
	-- This helps when multiple color variants exist and allows user to see different options
	-- RESOLVED: Randomization now only happens on window open/reopen via caching system
	--           Results are cached in representativeMountCache and persist during scroll
	--           Cache is cleared in Show() to get fresh randomization on each browser open
	local function shuffleMounts(tbl)
		local shuffled = {}
		for i, v in ipairs(tbl) do
			shuffled[i] = v
		end

		for i = #shuffled, 2, -1 do
			local j = math.random(i)
			shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
		end

		return shuffled
	end

	-- Shuffle mounts for random selection
	mounts = shuffleMounts(mounts)
	addon:DebugUI("GetRepresentativeMount: Shuffled mount order")
	-- Priority 1: Collected + Usable (best option)
	addon:DebugUI("GetRepresentativeMount: Checking Priority 1 (Collected + Usable)")
	for _, mount in ipairs(mounts) do
		if not mount.isUncollected and mount.mountID then
			local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mount.mountID)
			-- Also check if we can get display ID (handles class-restricted mounts)
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
			-- Fallback for class-restricted mounts: try GetAllCreatureDisplayIDsForMountID
			if not creatureDisplayID then
				local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mount.mountID)
				if allDisplayIDs and #allDisplayIDs > 0 then
					creatureDisplayID = allDisplayIDs[1]
				end
			end

			-- Debug logging for mount 866 specifically
			if mount.mountID == 866 or mount.mountID == 867 then
				addon:DebugUI("  [" ..
					mount.mountID ..
					"] name=" ..
					tostring(name) .. ", isUsable=" .. tostring(isUsable) .. ", creatureDisplayID=" .. tostring(creatureDisplayID))
			end

			-- STRICT CHECK: Must have both name AND displayID (not just one or the other)
			if name and creatureDisplayID then
				addon:DebugUI("GetRepresentativeMount: Selected mount " .. mount.mountID .. " from Priority 1")
				-- Cache the selection
				self.representativeMountCache[cacheKey] = mount.mountID
				return mount
			end
		end
	end

	-- Priority 2: Uncollected + Usable OR has display ID (better to show preview than nothing)
	addon:DebugUI("GetRepresentativeMount: Checking Priority 2 (Uncollected + Usable)")
	for _, mount in ipairs(mounts) do
		if mount.isUncollected and mount.mountID then
			local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mount.mountID)
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
			-- Fallback for class-restricted mounts: try GetAllCreatureDisplayIDsForMountID
			if not creatureDisplayID then
				local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mount.mountID)
				if allDisplayIDs and #allDisplayIDs > 0 then
					creatureDisplayID = allDisplayIDs[1]
				end
			end

			-- Debug logging for mount 866/867 specifically
			if mount.mountID == 866 or mount.mountID == 867 then
				addon:DebugUI("  [" ..
					mount.mountID ..
					"] name=" ..
					tostring(name) .. ", isUsable=" .. tostring(isUsable) .. ", creatureDisplayID=" .. tostring(creatureDisplayID))
			end

			-- STRICT CHECK: Must have both name AND displayID
			if name and creatureDisplayID then
				addon:DebugUI("GetRepresentativeMount: Selected mount " .. mount.mountID .. " from Priority 2")
				-- Cache the selection
				self.representativeMountCache[cacheKey] = mount.mountID
				return mount
			end
		end
	end

	-- Priority 3: Any collected mount with valid display ID (even if unusable)
	addon:DebugUI("GetRepresentativeMount: Checking Priority 3 (Collected with displayID)")
	for _, mount in ipairs(mounts) do
		if not mount.isUncollected and mount.mountID then
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
			-- Fallback for class-restricted mounts: try GetAllCreatureDisplayIDsForMountID
			if not creatureDisplayID then
				local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mount.mountID)
				if allDisplayIDs and #allDisplayIDs > 0 then
					creatureDisplayID = allDisplayIDs[1]
				end
			end

			-- Debug logging for mount 866/867 specifically
			if mount.mountID == 866 or mount.mountID == 867 then
				addon:DebugUI("  [" .. mount.mountID .. "] creatureDisplayID=" .. tostring(creatureDisplayID))
			end

			if creatureDisplayID then
				addon:DebugUI("GetRepresentativeMount: Selected mount " .. mount.mountID .. " from Priority 3")
				-- Cache the selection
				self.representativeMountCache[cacheKey] = mount.mountID
				return mount
			end
		end
	end

	-- Priority 4: Any uncollected mount with valid display ID
	addon:DebugUI("GetRepresentativeMount: Checking Priority 4 (Uncollected with displayID)")
	for _, mount in ipairs(mounts) do
		if mount.mountID then
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
			-- Fallback for class-restricted mounts: try GetAllCreatureDisplayIDsForMountID
			if not creatureDisplayID then
				local allDisplayIDs = C_MountJournal.GetAllCreatureDisplayIDsForMountID(mount.mountID)
				if allDisplayIDs and #allDisplayIDs > 0 then
					creatureDisplayID = allDisplayIDs[1]
				end
			end

			-- Debug logging for mount 866/867 specifically
			if mount.mountID == 866 or mount.mountID == 867 then
				addon:DebugUI("  [" .. mount.mountID .. "] creatureDisplayID=" .. tostring(creatureDisplayID))
			end

			if creatureDisplayID then
				addon:DebugUI("GetRepresentativeMount: Selected mount " .. mount.mountID .. " from Priority 4")
				-- Cache the selection
				self.representativeMountCache[cacheKey] = mount.mountID
				return mount
			end
		end
	end

	-- Priority 5: Absolute fallback - return any mount (may not have preview)
	addon:DebugUI("GetRepresentativeMount: Falling back to Priority 5 (any mount) - THIS MAY NOT HAVE A PREVIEW")
	if mounts[1] and mounts[1].mountID then
		addon:DebugUI("GetRepresentativeMount: Returning mount " .. mounts[1].mountID .. " from Priority 5 (may not display)")
		-- Cache even Priority 5 selections
		self.representativeMountCache[cacheKey] = mounts[1].mountID
	end

	return mounts[1]
end

-- Get an alternative mount when the selected one can't be displayed
-- Excludes the problematic mountID and finds another mount with valid displayID
function MountBrowser:GetAlternativeMount(key, type, excludeMountID)
	if not addon.processedData then return nil end

	addon:DebugUI("GetAlternativeMount: Looking for alternative to mount " .. excludeMountID .. " for " .. key)
	local mounts = {}
	if type == "supergroup" then
		-- Get all mounts from all families in supergroup
		if addon.processedData.superGroupMap and addon.processedData.superGroupMap[key] then
			local families = addon.processedData.superGroupMap[key]
			for _, familyName in ipairs(families) do
				-- Get collected mounts
				if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[familyName] then
					local mountIDs = addon.processedData.familyToMountIDsMap[familyName]
					for _, mountID in ipairs(mountIDs) do
						if mountID ~= excludeMountID then -- Exclude the problematic mount
							local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
							if mountInfo then
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
				end
			end
		end
	elseif type == "familyName" then
		-- Get all mounts in family
		if addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[key] then
			local mountIDs = addon.processedData.familyToMountIDsMap[key]
			for _, mountID in ipairs(mountIDs) do
				if mountID ~= excludeMountID then -- Exclude the problematic mount
					local mountInfo = addon.processedData.allCollectedMountFamilyInfo[mountID]
					if mountInfo then
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
		end
	end

	if #mounts == 0 then
		addon:DebugUI("GetAlternativeMount: No alternative mounts found")
		return nil
	end

	-- Try to find ANY mount with a valid displayID (don't shuffle, just find first valid one)
	for _, mount in ipairs(mounts) do
		if mount.mountID then
			local creatureDisplayID = select(1, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
			if creatureDisplayID then
				addon:DebugUI("GetAlternativeMount: Found valid alternative mount " .. mount.mountID)
				return mount
			end
		end
	end

	addon:DebugUI("GetAlternativeMount: No mounts with valid displayID found")
	return nil
end

-- ============================================================================
-- CARD UPDATE
-- ============================================================================
function MountBrowser:UpdateCard(card, data)
	if not card or not data then return end

	-- Check if this is the same data and model is already loaded
	local sameDataAndLoaded = (card.currentDataKey == data.key and card.modelLoaded)
	-- OPTIMIZATION: If same data and model loaded, skip most updates but still handle traits
	-- This prevents animation resets while allowing trait buttons to show/hide after scrolling
	if sameDataAndLoaded then
		addon:DebugUI("UpdateCard: Same data, skipping model updates for " .. data.key)
		-- Update name highlighting (fast path - needed when search changes)
		local displayName = data.displayName or data.key
		local highlightedName = self:HighlightSearchTerm(displayName)
		card.nameLabel:SetText(highlightedName)
		-- Update collection status (fast path)
		if addon:GetSetting("browserShowCollectionStatus") then
			local collectionText = self:GetCollectionStatusText(data) or ""
			card.collectionStatus:SetText(collectionText)
			card.collectionStatus:Show()
			card.collectionStatusBg:Show()
		else
			card.collectionStatus:Hide()
			card.collectionStatusBg:Hide()
		end

		-- Update weight display (fast path - needed for weight button clicks)
		local weight = addon:GetGroupWeight(data.key) or 3
		local weightInfo = WeightDisplayMapping[weight] or WeightDisplayMapping[3]
		card.weightLabel:SetText("|cff" .. weightInfo.color .. weightInfo.text .. "|r")
		-- Update type icon visibility (fast path)
		if card.typeIconFrame then
			if addon:GetSetting("browserShowGroupIndicators") then
				card.typeIconFrame:Show()
				-- Only re-enable mouse interaction if we're not actively scrolling
				if not self.isActivelyScrolling then
					card.typeIconFrame:EnableMouse(true)
				end
			else
				card.typeIconFrame:Hide()
			end
		end

		-- Still update traits (they get hidden during scroll and need to be reshown)
		if not self.isActivelyScrolling then
			local shouldShowTraits = false
			local traits = {}
			if addon.MountDataManager and addon.MountDataManager.ShouldShowTraits then
				shouldShowTraits = addon.MountDataManager:ShouldShowTraits(data.key, data.type)
				if shouldShowTraits and addon.MountDataManager.GetFamilyTraits then
					traits = addon.MountDataManager:GetFamilyTraits(data.key) or {}
				end
			end

			-- Hide all trait buttons first
			for _, button in pairs(card.traitButtons) do
				button:Hide()
			end

			-- Hide trait container by default
			card.traitContainer:Hide()
			-- Show ALL traits for eligible families/mounts
			if shouldShowTraits and next(traits) then
				local visibleCount = 0
				local iconSpacing = 25
				local traitOrder = {
					"isUniqueEffect",
				}
				for _, traitKey in ipairs(traitOrder) do
					if traits[traitKey] ~= nil and card.traitButtons[traitKey] then
						local isEnabled = traits[traitKey]
						local button = card.traitButtons[traitKey]
						-- Position if needed
						local needsPositioning = not card.traitButtonsPositioned or card.lastTraitKey ~= data.key
						if needsPositioning then
							button:ClearAllPoints()
							button:SetPoint("LEFT", card.traitContainer, "LEFT", visibleCount * iconSpacing, 0)
						end

						-- Update icon desaturation
						button.isActive = isEnabled
						button.icon:SetDesaturated(not isEnabled)
						button:EnableMouse(true)
						button:Show()
						visibleCount = visibleCount + 1
					end
				end

				-- Show the trait container if we have visible buttons
				if visibleCount > 0 then
					local totalWidth = (visibleCount * iconSpacing) - 5
					card.traitContainer:SetWidth(totalWidth)
					if addon:GetSetting("browserShowUniquenessIndicators") then
						card.traitContainer:Show()
					else
						card.traitContainer:Hide()
					end

					card.traitButtonsPositioned = true
					card.lastTraitKey = data.key
				else
					card.traitContainer:Hide()
				end
			end

			self:UpdateCapabilityIcons(card, data)
		end

		return -- Skip the rest of the update (model reload, etc.)
	end

	-- Full update for new data
	addon:DebugUI("UpdateCard: Full update for " .. data.key)
	-- Update name with adaptive font sizing
	local displayName = data.displayName or data.key
	-- Apply search term highlighting if search is active
	local highlightedName = self:HighlightSearchTerm(displayName)
	card.nameLabel:SetText(highlightedName)
	-- Adaptive font sizing to prevent long names from wrapping and pushing nameBg down
	local nameLength = string.len(displayName)
	if nameLength >= 30 then
		-- Very long names: smallest font
		card.nameLabel:SetFontObject(GameFontNormalSmall)
	elseif nameLength >= 20 then
		-- Long names: medium font
		card.nameLabel:SetFontObject(GameFontNormal)
	else
		-- Normal names: large font (default)
		card.nameLabel:SetFontObject(GameFontNormalLarge)
	end

	-- Disable word wrap to prevent multi-line names (keeps layout clean)
	card.nameLabel:SetWordWrap(false)
	-- Update collection status (if enabled in settings)
	if addon:GetSetting("browserShowCollectionStatus") then
		local collectionText = self:GetCollectionStatusText(data) or ""
		card.collectionStatus:SetText(collectionText)
		card.collectionStatus:Show()
		card.collectionStatusBg:Show()
	else
		card.collectionStatus:Hide()
		card.collectionStatusBg:Hide()
	end

	-- Update type icon
	if data.type == "supergroup" then
		card.typeIcon:SetTexture("Interface\\AddOns\\RandomMountBuddy\\media\\group.tga")
		card.typeIconFrame.cardType = "supergroup"
	elseif data.type == "familyName" then
		-- Check if single mount or multiple mounts
		local totalMounts = 0
		if addon.processedData then
			local collectedCount = (addon.processedData.familyToMountIDsMap and addon.processedData.familyToMountIDsMap[data.key])
					and #addon.processedData.familyToMountIDsMap[data.key] or 0
			local uncollectedCount = (addon.processedData.familyToUncollectedMountIDsMap and addon.processedData.familyToUncollectedMountIDsMap[data.key])
					and #addon.processedData.familyToUncollectedMountIDsMap[data.key] or 0
			totalMounts = collectedCount + uncollectedCount
		end

		if totalMounts == 1 then
			-- Single mount family - treat as mount
			card.typeIcon:SetTexture("Interface\\AddOns\\RandomMountBuddy\\media\\mount.tga")
			card.typeIconFrame.cardType = "mount"
		else
			-- Multiple mounts - show as family
			card.typeIcon:SetTexture("Interface\\AddOns\\RandomMountBuddy\\media\\family.tga")
			card.typeIconFrame.cardType = "familyName"
		end
	elseif data.type == "mount" then
		card.typeIcon:SetTexture("Interface\\AddOns\\RandomMountBuddy\\media\\mount.tga")
		card.typeIconFrame.cardType = "mount"
	end

	-- Update type icon visibility based on settings
	if card.typeIconFrame then
		if addon:GetSetting("browserShowGroupIndicators") then
			card.typeIconFrame:Show()
			-- Only re-enable mouse interaction if we're not actively scrolling
			if not self.isActivelyScrolling then
				card.typeIconFrame:EnableMouse(true)
			end
		else
			card.typeIconFrame:Hide()
		end
	end

	-- Update weight display
	local weight = addon:GetGroupWeight(data.key) or 3
	local weightInfo = WeightDisplayMapping[weight] or WeightDisplayMapping[3]
	-- Show weight UI for all types (including mounts)
	card.weightLabel:SetText("|cff" .. weightInfo.color .. weightInfo.text .. "|r")
	card.weightDecrease:Show()
	card.weightIncrease:Show()
	-- Update traits (matches MountUIComponents logic)
	-- Skip trait updates during active scrolling for performance
	-- Buttons are hidden during scroll and will be reshown when scrolling stops
	addon:DebugUI("UpdateCard: isActivelyScrolling = " .. tostring(self.isActivelyScrolling))
	if not self.isActivelyScrolling then
		local shouldShowTraits = false
		local traits = {}
		if addon.MountDataManager and addon.MountDataManager.ShouldShowTraits then
			shouldShowTraits = addon.MountDataManager:ShouldShowTraits(data.key, data.type)
			addon:DebugUI("UpdateCard: shouldShowTraits = " .. tostring(shouldShowTraits) .. " for " .. data.key)
			if shouldShowTraits and addon.MountDataManager.GetFamilyTraits then
				traits = addon.MountDataManager:GetFamilyTraits(data.key) or {}
				addon:DebugUI("UpdateCard: Got " .. (traits and "traits" or "no traits"))
			end
		end

		-- Hide all trait buttons first
		for _, button in pairs(card.traitButtons) do
			button:Hide()
		end

		-- Hide trait container by default
		card.traitContainer:Hide()
		-- Show ALL traits for eligible families/mounts
		if shouldShowTraits and next(traits) then
			local visibleCount = 0
			local iconSpacing = 25
			-- Define trait order (must match CreateCard order)
			local traitOrder = {
				"isUniqueEffect",
			}
			-- Show all trait buttons in order
			for _, traitKey in ipairs(traitOrder) do
				if traits[traitKey] ~= nil and card.traitButtons[traitKey] then
					local isEnabled = traits[traitKey]
					local button = card.traitButtons[traitKey]
					-- Position the button
					-- OPTIMIZATION: Only position button if not already positioned for this card
					local needsPositioning = not card.traitButtonsPositioned or card.lastTraitKey ~= data.key
					if needsPositioning then
						button:ClearAllPoints()
						button:SetPoint("LEFT", card.traitContainer, "LEFT", visibleCount * iconSpacing, 0)
					end

					-- Update icon desaturation (grayed = inactive, colored = active)
					button.isActive = isEnabled
					button.icon:SetDesaturated(not isEnabled)
					button:EnableMouse(true)
					button:Show()
					visibleCount = visibleCount + 1
				end
			end

			-- Show the trait container if we have visible buttons
			if visibleCount > 0 then
				local totalWidth = (visibleCount * iconSpacing) - 5
				card.traitContainer:SetWidth(totalWidth)
				if addon:GetSetting("browserShowUniquenessIndicators") then
					card.traitContainer:Show()
				else
					card.traitContainer:Hide()
				end

				-- Mark buttons as positioned for this data
				card.traitButtonsPositioned = true
				card.lastTraitKey = data.key
			else
				card.traitContainer:Hide()
			end
		end
	end -- End of isActivelyScrolling check

	-- Apply camera overrides with inheritance
	if data.key and card.modelScene then
		local mountID = data.mountData and data.mountData.mountID
		local familyName = data.mountData and data.mountData.familyName
		-- Build the full camera cascade information
		local cameraInfo = {
			mountID = mountID,
			familyName = nil,
			supergroupName = nil,
		}
		if data.type == "mount" then
			-- For mount cards, get family and supergroup context
			cameraInfo.familyName = data.parentFamily or familyName
			-- Try to get supergroup from family
			if cameraInfo.familyName and addon.GetOriginalSuperGroup then
				cameraInfo.supergroupName = addon:GetOriginalSuperGroup(cameraInfo.familyName)
			end
		elseif data.type == "familyName" then
			-- For family cards
			cameraInfo.familyName = data.key
			-- Get original supergroup (even if separated by trait strictness)
			if data.parentSupergroup then
				cameraInfo.supergroupName = data.parentSupergroup
			elseif addon.GetOriginalSuperGroup then
				cameraInfo.supergroupName = addon:GetOriginalSuperGroup(data.key)
			end
		elseif data.type == "supergroup" then
			-- For supergroup cards
			cameraInfo.supergroupName = data.key
		end

		-- Get camera with full cascade: mount -> family -> supergroup -> default
		local cam = GetCameraSettingsWithContext(cameraInfo)
		-- Store camera settings on the card for re-application after model loads
		card.cameraSettings = cam
		card.modelScene:SetCameraPosition(cam.x, cam.y, cam.z)
		card.modelScene:SetCameraOrientationByYawPitchRoll(cam.yaw, cam.pitch, cam.roll)
	end

	-- Store data reference
	card.data = data
	card.currentDataKey = data.key -- Track current data for change detection
	-- Clear existing model immediately to prevent showing wrong preview
	if card.actor then
		pcall(function()
			card.actor:ClearModel()
		end)
	end

	-- Mark model as not loaded
	card.modelLoaded = false
	-- Reset button positioning cache when card data changes
	card.traitButtonsPositioned = false
	card.lastTraitKey = nil
	-- Get the mount to display
	local repMount = nil
	if data.type == "mount" then
		-- For individual mount cards, use the mount data directly
		repMount = data.mountData
	else
		-- For families and supergroups, get a representative mount
		repMount = self:GetRepresentativeMount(data.key, data.type)
	end

	-- Queue model loading
	if repMount and card.actor then
		card.repMount = repMount
		self:QueueModelLoad(card, repMount)
	end

	-- Update capability icons
	addon:DebugUI("RMB_CAP: About to call UpdateCapabilityIcons for " .. tostring(data.key))
	self:UpdateCapabilityIcons(card, data)
	-- ========================================================================
	-- SEARCH RESULTS DISPLAY
	-- ========================================================================
	-- Display search results if search is active and item has matches
	if self.Search and self.Search:IsActive() and data.type ~= "mount" then
		local resultText = self.Search:GetCardResultText(data.type, data.key)
		if resultText then
			-- Create or update search result label
			if not card.searchResultLabel then
				card.searchResultLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
				card.searchResultLabel:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -38)
				card.searchResultLabel:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -38)
				card.searchResultLabel:SetJustifyH("LEFT")
				card.searchResultLabel:SetJustifyV("TOP")
			end

			card.searchResultLabel:SetText(resultText)
			card.searchResultLabel:Show()
		elseif card.searchResultLabel then
			card.searchResultLabel:Hide()
		end
	elseif card.searchResultLabel then
		card.searchResultLabel:Hide()
	end

	-- FINAL SETTINGS ENFORCEMENT
	-- Apply all settings-dependent visibility regardless of scrolling state
	-- This ensures settings changes take effect immediately via RefreshAllCards()
	-- Collection Status
	if not addon:GetSetting("browserShowCollectionStatus") then
		card.collectionStatus:Hide()
		card.collectionStatusBg:Hide()
	end

	-- Group Indicators (already handled earlier, but ensure it's correct)
	if not addon:GetSetting("browserShowGroupIndicators") then
		if card.typeIconFrame then
			card.typeIconFrame:Hide()
		end
	end

	-- Uniqueness Indicators (trait container)
	if not addon:GetSetting("browserShowUniquenessIndicators") then
		card.traitContainer:Hide()
	end

	-- Capability Indicators (already handled in UpdateCapabilityIcons)
	-- No additional action needed here
end

-- ============================================================================
-- TYPE ICON MOUSE OPTIMIZATION
-- ============================================================================
-- Disable mouse interaction on type icon frames during scrolling (keeps them visible)
function MountBrowser:DisableTypeIconMouseDuringScroll()
	-- Disable mouse on all card type icons
	for _, card in ipairs(self.cardPool) do
		if card.typeIconFrame then
			self:DisableMouseOnElements(card.typeIconFrame)
		end
	end
end

-- ============================================================================
-- ============================================================================
-- PUBLIC API
-- ============================================================================
-- Public method to get camera settings (for FamilyCameraCalibrator)
-- This wraps the local GetCameraSettings function
function MountBrowser:GetCameraSettings(groupKey, groupType, mountID)
	return GetCameraSettings(groupKey, groupType, mountID)
end
