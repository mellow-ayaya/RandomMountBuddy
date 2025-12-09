-- Random Mount Buddy - Converted Mount Data
-- Two-table format: MountToFamily + FamilyDefinitions

if not RandomMountBuddy_PreloadData then
    RandomMountBuddy_PreloadData = {}
end

-- ============================================================
-- MOUNT TO FAMILY ASSIGNMENTS
-- ============================================================

RandomMountBuddy_PreloadData.MountToFamily = {
    -- ========================================================
    -- AERIAL UNITS
    -- ========================================================


    [1227] = "Aerial Unit",    -- Aerial Unit R-21/X
    [1254] = "Aerial Unit",    -- Rustbolt Resistor
    [1270] = "Aerial Unit",    -- Swift Spectral Magnetocraft
    [1813] = "Aerial Unit",    -- Mimiron's Jumpjets


    [2291] = "Cartel Aerial Unit",    -- Salvaged Goblin Gazillionaire's Flying Machine
    [2292] = "Cartel Aerial Unit",    -- Margin Manipulator
    [2293] = "Cartel Aerial Unit",    -- Darkfuse Spy-Eye
    [2294] = "Cartel Aerial Unit",    -- Mean Green Flying Machine
    [2295] = "Cartel Aerial Unit",    -- Bilgewater Bombardier


    [2640] = "Propelled Aerial Units",    -- Brewfest Barrel Bomber


    [2507] = "Prototype A.S.M.R.",    -- Prototype A.S.M.R.


    -- ========================================================
    -- ANTORAN FELHOUNDS
    -- ========================================================


    [955] = "Vile Fiend",    -- Vile Fiend
    [979] = "Vile Fiend",    -- Crimson Slavermaw
    [980] = "Vile Fiend",    -- Acid Belcher
    [981] = "Vile Fiend",    -- Biletooth Gnasher
...

RandomMountBuddy_PreloadData.FamilyDefinitions = {
    -- Aerial Units
    ["Aerial Unit"] = {
        superGroup = "Aerial Units",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Cartel Aerial Unit"] = {
        superGroup = "Aerial Units",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Propelled Aerial Units"] = {
        superGroup = "Aerial Units",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


-- MountID_to_MountTypeID
-- Generated mapping of MountID to MountTypeID
MountIDtoMountTypeID = {
    [6] = 230, -- Brown Horse
    [7] = 230, -- Gray Wolf
		[137] = 424,    -- Swift Red Gryphon
		[138] = 424,    -- Swift Green Gryphon
		[139] = 424,    -- Swift Purple Gryphon
...

-- Mount Type
-- Helper for assigning custom traits to MountTypeIDs
-- Manually create a Lua table: MountTypeTraits = { [MountTypeID] = {isGround=bool, isAquatic=bool,... derivedMovementType="YOUR_TYPE"} }
MountTypeTraits_Input_Helper = {
	[204] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=202
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[230] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_1=226, Capability_2=227
		isGround = true,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[424] = {
		-- TypeName: "5"
		-- Relevant Caps: Capability_0=494, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=227, Capability_5=226
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},