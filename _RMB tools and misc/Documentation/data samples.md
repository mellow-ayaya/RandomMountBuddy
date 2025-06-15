-- Generated Mount Model Groups
-- Mapping: MountID to ModelGroupIdentifier (Model Path or FileDataID if path not resolved)

if not RandomMountBuddy_PreloadData then RandomMountBuddy_PreloadData = {} end

RandomMountBuddy_PreloadData.MountToModelPath = {
    [6] = "creature/ridinghorse/ridinghorse.m2",                                    -- Brown Horse
    [7] = "creature/direwolf/ridingdirewolf.m2",                                    -- Gray Wolf
    [8] = "creature/ridinghorse/ridinghorse.m2",                                    -- White Stallion
...

-- Manual Family Definitions
if not RandomMountBuddy_PreloadData then RandomMountBuddy_PreloadData = {} end

RandomMountBuddy_PreloadData.FamilyDefinitions = {
	-- Racial mounts
	-- Horde
	-- Wolves
	["creature/direwolf/ridingdirewolf.m2"] = {
		familyName = "Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/direwolf/pvpridingdirewolf.m2"] = {
		familyName = "Armored Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/foxwyvernmount/foxwyvernmount.m2"] = {
		familyName = "Slyvern",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
...

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