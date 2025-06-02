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
	["creature/ridingdirewolfspectral/ridingdirewolfspectral.m2"] = {
		familyName = "Spectral Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/wolfdraenor/wolfdraenormount.m2"] = {
		familyName = "Draenor Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/wolfdraenor/wolfdraenor_felmount.m2"] = {
		familyName = "Infernal Direwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/frostwolfhowler/frostwolfhowler.m2"] = {
		familyName = "Frostwolf Snarler",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/orcclanworg/orcclanworg.m2"] = {
		familyName = "Mag'har Direwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/korkronelitewolf/korkronelitewolf.m2"] = {
		familyName = "Kor'kron War Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/alliancewolfmount2/alliancewolfmount2.m2"] = {
		familyName = "Alliance Wolf Mount",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/wolfdraenor/wolfdraenormountarmored.m2"] = {
		familyName = "Armored Draenor Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ironhordewolf/ironhordewolf.m2"] = {
		familyName = "Beastlord's Warwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/alliancewolfmount/alliancewolfmount.m2"] = {
		familyName = "Ironclad Frostclaw",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hordepvpmount/hordepvpmount.m2"] = {
		familyName = "War Wolf (PVP)",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Raptors
	["creature/ridingraptor/ridingraptor.m2"] = {
		familyName = "Primal Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingraptor/pvpridingraptor.m2"] = {
		familyName = "Armored Primal Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/skeletalraptor/skeletalraptormount.m2"] = {
		familyName = "Fossilized Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/raptor2/raptor2.m2"] = {
		familyName = "Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/armoredraptor/armoredraptor.m2"] = {
		familyName = "Armored Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/sabretoothraptormount/sabretoothraptormount.m2"] = {
		familyName = "Dreamtalon",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/vicioussabretoothraptor/vicioussabretoothraptor.m2"] = {
		familyName = "Vicious Dreamtalon (PVP)",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/raptor2/viciouswarraptor.m2"] = {
		familyName = "Vicious War Raptor (PVP)",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/compy/compy.m2"] = {
		familyName = "Jani's Trashpile",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/zandalariraptor/zandalariraptor.m2"] = {
		familyName = "Ivory Savagemane",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Kodos
	["creature/kodobeast2mount/kodobeast2mount.m2"] = {
		familyName = "Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/kodobeast/kodobeastpvpt2.m2"] = {
		familyName = "Armored Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarkodo/viciouswarkodo.m2"] = {
		familyName = "Vicious War Kodo (PVP)",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/kodobeast/ridingkodo.m2"] = {
		familyName = "Brewfest Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/kodobeast/ridingkotobeastsunwalker.m2"] = {
		familyName = "Sunwalker Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/kodobeast/ridingkotobeastsunwalkerelite.m2"] = {
		familyName = "Great Sunwalker Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/kodomount/kodomount.m2"] = {
		familyName = "Armored Siege Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Skeletal Horses
	["creature/undeadhorse/ridingundeadhorse.m2"] = {
		familyName = "Skeletal Horse",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mounteddeathknight/ridingundeadwarhorse.m2"] = {
		familyName = "Armored Skeletal Horse",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/undeadhorse/undeadhorse.m2"] = {
		familyName = "Risen Mare",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/skeletalwarhorse2/skeletalwarhorse2.m2"] = {
		familyName = "Midnight",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/skeletalwarhorse/skeletalwarhorse.m2"] = {
		familyName = "Vicious Skeletal Warhorse (PVP)",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Hawkstriders
	["creature/cockatrice/cockatricemount.m2"] = {
		familyName = "Hawkstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/cockatrice/cockatriceelite.m2"] = {
		familyName = "Armored Hawkstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/voidelfhawkstridermount/voidelfhawkstridermount.m2"] = {
		familyName = "Starcursed Voidstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/vicioushawkstrider/vicioushawkstrider.m2"] = {
		familyName = "Vicious Warstrider (PVP)",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Goblin Trikes
	["creature/goblintrike/goblintrike02.m2"] = {
		familyName = "Goblin Trike",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/goblintrike/goblintrike01.m2"] = {
		familyName = "Goblin Turbo-Trike",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousgoblintrike/viciousgoblintrike.m2"] = {
		familyName = "Vicious War Trike (PVP)",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Wyverns
	["creature/ridingwyvern/ridingwyvern.m2"] = {
		familyName = "Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingwyvernarmored/ridingwyvernarmored.m2"] = {
		familyName = "Armored Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/spectralwyvern/spectralwyvern.m2"] = {
		familyName = "Spectral Wind Rider",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/elitewyvern/elitewyvern.m2"] = {
		familyName = "Grand Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/elitewyvern/elitewyvernarmored.m2"] = {
		familyName = "Grand Armored Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/encrypted22/encrypted22.m2"] = {
		familyName = "Alabaster Thunderwing",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["character/companionwyvern/companionwyvern.m2"] = {
		familyName = "Cliffside Wylderdrake",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/30thwyvernmount/30thwyvernmount.m2"] = {
		familyName = "Chaos-Forged Wind Rider",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Dragonhawks
	["creature/dragonhawk/dragonhawkmount.m2"] = {
		familyName = "Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dragonhawk/dragonhawkarmormountalliance.m2"] = {
		familyName = "Armored Blue Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dragonhawk/dragonhawkarmormounthorde.m2"] = {
		familyName = "Armored Red Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dragonhawkmountshadowlands/dragonhawkmountshadowlands.m2"] = {
		familyName = "Vengeance",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Alliance
	-- Horses
	["creature/ridinghorse/ridinghorse.m2"] = {
		familyName = "Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridinghorse/ridinghorsepvpt2.m2"] = {
		familyName = "Armored Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/horsemultisaddle/horsemultisaddle.m2"] = {
		familyName = "Saddled Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dressedhorse/dressedhorse.m2"] = {
		familyName = "Seabraid Stallion",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/deathknightmount/deathknightmount.m2"] = {
		familyName = "Deathcharger",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/warhorse/warhorse.m2"] = {
		familyName = "Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/vicioushorse/vicioushorse.m2"] = {
		familyName = "Vicious Gilnean Warhorse (PVP)",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse3/horse3.m2"] = {
		familyName = "Mountain Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hordehorsemount/hordehorsemount.m2"] = {
		familyName = "Bloodflank Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/warhorse/argentwarhorse.m2"] = {
		familyName = "Crusader's Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/mawhorsespikes/mawhorsespikes.m2"] = {
		familyName = "Mawsworn Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/warhorse/pvpwarhorse.m2"] = {
		familyName = "Armored Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horsekultiran/horsekultiran.m2"] = {
		familyName = "Kul Tiran Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/darkmoonhorsemount/darkmoonhorsemount.m2"] = {
		familyName = "Darkmoon Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nightmare/gorgon101.m2"] = {
		familyName = "Dreadsteed",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nightmare/nightmare.m2"] = {
		familyName = "Felsteed",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ridinghorse/ridinghorsespectral.m2"] = {
		familyName = "Spectral Steed",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/zebramount/zebramount.m2"] = {
		familyName = "Zhevra",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/alliancepvpmount/alliancepvpmount.m2"] = {
		familyName = "War Steed (PVP)",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Flying horses
	["creature/felhorse/felhorseepic.m2"] = {
		familyName = "Fiery Warhorse",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hhmount/hhmount.m2"] = {
		familyName = "Headless Horseman's Mount",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ghostlycharger/ghostlycharger.m2"] = {
		familyName = "Ghastly Charger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/steelwarhorse/steelwarhorse.m2"] = {
		familyName = "Ironbound Wraithcharger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/clockworkhorse/clockworkhorse.m2"] = {
		familyName = "Warforged Nightmare",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/paladinmount/paladinmount.m2"] = {
		familyName = "Highlord's Charger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/warlockmountshadow/warlockmountshadow.m2"] = {
		familyName = "Netherlord's Accursed Wrathsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/warlockmount/warlockmount.m2"] = {
		familyName = "Netherlord's Wrathsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/swiftwindsteed/swiftwindsteed_mount.m2"] = {
		familyName = "Windsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/horse2/horse2.m2"] = {
		familyName = "Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2ardenweald/horse2ardenweald.m2"] = {
		familyName = "Ardenweald Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2ardenwealdmount/horse2ardenwealdmount.m2"] = {
		familyName = "Armored Ardenweald Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2bastion/horse2bastion.m2"] = {
		familyName = "Bastion Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2bastionmount/horse2bastionmount.m2"] = {
		familyName = "Armored Bastion Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2mount/horse2mount.m2"] = {
		familyName = "Prestigious Courser (PVP)",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/horse2mountelite/horse2mountelite.m2"] = {
		familyName = "Bloodforged Courser (PVP)",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Winged Flying horses
	["creature/lavahorse/lavahorse.m2"] = {
		familyName = "Cindermane Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/wingedhorse/wingedhorse.m2"] = {
		familyName = "Invincible",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/celestialhorse/celestialhorse.m2"] = {
		familyName = "Celestial Steed",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/tyraelmount/tyraelmount.m2"] = {
		familyName = "Tyrael's Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/inariusmount/inariusmount.m2"] = {
		familyName = "Inarius' Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/pegasusmount/pegasusmount.m2"] = {
		familyName = "Hearthsteed",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Elekks
	["creature/ridingelekk/ridingelekk.m2"] = {
		familyName = "Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingelekk/ridingelekkelite.m2"] = {
		familyName = "Armored Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarelekk/viciouswarelekk.m2"] = {
		familyName = "Vicious War Elekk (PVP)",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ridingelekk/draeneipaladinelekk.m2"] = {
		familyName = "Exarch's Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingelekk/paladinelekkelite.m2"] = {
		familyName = "Great Exarch's Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ironhordeelekk/ironhordeelekk.m2"] = {
		familyName = "Armored Irontusk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/elekk/elekkdraenormount.m2"] = {
		familyName = "Elekk Draenor",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/lightforgedelekk/lightforgedelekk.m2"] = {
		familyName = "Lightforged Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Sabers
	["creature/frostsabre/ridingfrostsabre.m2"] = {
		familyName = "Saber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/frostsabre/pvpridingfrostsabre.m2"] = {
		familyName = "Armored Saber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/warnightsabermount/warnightsabermount.m2"] = {
		familyName = "Vicious Warsaber (PVP)",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/nbsabermount/nbsabermount.m2"] = {
		familyName = "Nightborne Manasaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/nightsaber2mount/nightsaber2mount.m2"] = {
		familyName = "Nightsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/saber3mount/saber3mount.m2"] = {
		familyName = "Priestess' Moonsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nightsaberhordemount/nightsaberhordemount.m2"] = {
		familyName = "Nightsaber Horde Mount",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/spectraltiger/spectraltigerepic.m2"] = {
		familyName = "Swift Spectral Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/spectraltiger/spectraltiger.m2"] = {
		familyName = "Spectral Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/shatigermount/shatigermount.m2"] = {
		familyName = "Sha-Warped Riding Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/siberiantiger/siberiantigermount.m2"] = {
		familyName = "Shado-Pan Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/dhmount/dhmount.m2"] = {
		familyName = "Felsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/vicioussabertooth/vicioussabertooth.m2"] = {
		familyName = "Vicious Sabertooth (PVP)",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/catmountslime/catmountslime.m2"] = {
		familyName = "Jigglesworth Sr.",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/firecatmount/firecatmount.m2"] = {
		familyName = "Primal Flamesaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/dreamsabermount/dreamsabermount.m2"] = {
		familyName = "Dreamsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/mechanicaltiger/mechanicaltiger.m2"] = {
		familyName = "X-995 Mechanocat",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/arathilynxmount/arathilynxmount.m2"] = {
		familyName = "Lynx",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Flying sabers
	["creature/flyingpanther/flyingpanther.m2"] = {
		familyName = "Obsidian Nightwing",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/wingedlionmount/wingedlionmount.m2"] = {
		familyName = "Winged Guardian",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/suramarmount/suramarmount.m2"] = {
		familyName = "Arcanist's Manasaber",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/saber2/saber2mount.m2"] = {
		familyName = "Mystic Runesaber",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/onyxpanther/onyxpanther.m2"] = {
		familyName = "Jeweled Panther",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nightsaber2mountsunmoon/nightsaber2mountsunmoon.m2"] = {
		familyName = "Ash'adar",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/shadowstalkerpanthermount/shadowstalkerpanthermount.m2"] = {
		familyName = "Luminous Starseeker",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/tigermount/tigermount.m2"] = {
		familyName = "Wen Lo",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/monkmount/monkmount.m2"] = {
		familyName = "Ban-Lu",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Rams
	["creature/ram/ridingram.m2"] = {
		familyName = "Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ram/pvpridingram.m2"] = {
		familyName = "Armored Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarram/viciouswarram.m2"] = {
		familyName = "Vicious War Ram (PVP)",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dwarfpaladinram/dwarfpaladinram.m2"] = {
		familyName = "Darkforge Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/stormpikebattlecharger/stormpikebattlecharger.m2"] = {
		familyName = "Stormpike Battle Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/protoramearthenmount/protoramearthenmount.m2"] = {
		familyName = "Ramolith",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/earthenpaladinmount/earthenpaladinmount.m2"] = {
		familyName = "Earthen Ordinant's Ramolith",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Mechanostriders
	["creature/mechastrider/pvpmechastrider.m2"] = {
		familyName = "Armored Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mechastrider/mechastrider.m2"] = {
		familyName = "Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarmechanostrider/viciouswarmechanostrider.m2"] = {
		familyName = "Vicious War Mechanostrider (PVP)",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/mechagnomestrider/mechagnomestrider.m2"] = {
		familyName = "Mechagon Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Gryphons
	["creature/gryphon/gryphon_mount.m2"] = {
		familyName = "Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/gryphon/gryphon_armoredmount.m2"] = {
		familyName = "Armored Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/gryphon/gryphon_ghost_mount.m2"] = {
		familyName = "Swift Spectral Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/gryphon/gryphon_skeletal_mount.m2"] = {
		familyName = "Winged Steed of the Ebon Blade",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/spectralgryphon/spectralgryphon.m2"] = {
		familyName = "Spectral Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/30thgryphonmount/30thgryphonmount.m2"] = {
		familyName = "Chaos-Forged Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/elitegryphon/elitegryphon.m2"] = {
		familyName = "Grand Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/elitegryphon/elitegryphonarmored.m2"] = {
		familyName = "Grand Armored Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["character/rostrumstormgryphon/rostrumstormgryphon.m2"] = {
		familyName = "Algarian Stormrider",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/encrypted21/encrypted21.m2"] = {
		familyName = "Alabaster Stormtalon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/gryphon_air_mount/gryphon_air_mount.m2"] = {
		familyName = "Alunira",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Neutral
	-- Turtles
	["creature/dragonturtle/ridingdragonturtle.m2"] = {
		familyName = "Dragon Turtle ",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/turtlemount2/turtlemount2.m2"] = {
		familyName = "Savage Battle Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dragonturtle/ridingdragonturtleepic.m2"] = {
		familyName = "Great Dragon Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/viciousdragonturtlemount/viciousdragonturtlemount.m2"] = {
		familyName = "Vicious War Turtle (PVP)",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/turtlemount/turtlemount.m2"] = {
		familyName = "Super Armored Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ridingturtle/ridingturtle.m2"] = {
		familyName = "Sea Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Vorquins
	["creature/kirinmountdracthyr/kirinmountdracthyr.m2"] = {
		familyName = "Vorquin",
		superGroup = "Vorquins",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/kirinmount/kirinmount.m2"] = {
		familyName = "Armored Vorquin",
		superGroup = "Vorquins",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Aerial Units
	["creature/hunterkillership/hunterkillership.m2"] = {
		familyName = "Aerial Unit",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/goblinflyingmachine/goblinflyingmachine.m2"] = {
		familyName = "Cartel Aerial Unit",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/goblinflyingmachineboss/goblinflyingmachineboss.m2"] = {
		familyName = "Prototype A.S.M.R.",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Antoran Felhounds
	["creature/felhound3_shadow_mount/felhound3_shadow_mount.m2"] = {
		familyName = "Antoran Gloomhound",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/felhound3_fire_mount/felhound3_fire_mount.m2"] = {
		familyName = "Antoran Charhound",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/argusfelstalkermount/argusfelstalkermount.m2"] = {
		familyName = "Vile Fiend",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Bakars
	["creature/dogprimalmount2/dogprimalmount2.m2"] = {
		familyName = "Taivan",
		superGroup = "Bakars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dogprimalmount/dogprimalmount.m2"] = {
		familyName = "Spiky Bakar",
		superGroup = "Bakars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Basilisks
	["creature/basiliskmount/basiliskmount.m2"] = {
		familyName = "Brawler's Burly Basilisk",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/crocoliskmount/crocoliskmount.m2"] = {
		familyName = "Bruce",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/treasurebasiliskmount/treasurebasiliskmount.m2"] = {
		familyName = "Plunderlord's Crocolisk",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarbasiliskalliance/viciouswarbasiliskalliance.m2"] = {
		familyName = "Vicious War Basilisk (PVP)",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarbasiliskhorde/viciouswarbasiliskhorde.m2"] = {
		familyName = "Vicious War Basilisk (PVP)",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Bats
	["creature/bat/batmount.m2"] = {
		familyName = "Bat",
		superGroup = "Bats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/bat/epicbatmount.m2"] = {
		familyName = "Armored Bat",
		superGroup = "Bats",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/30thbatmount/30thbatmount.m2"] = {
		familyName = "Chaos-Forged Dreadwing",
		superGroup = "Bats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/giantvampirebatmount/giantvampirebatmount.m2"] = {
		familyName = "Dredwing",
		superGroup = "Bats",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Bears
	["creature/bearmount/bearmount.m2"] = {
		familyName = "Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/bearmountalt/bearmountalt.m2"] = {
		familyName = "Big Battle Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/viciousalliancebearmount/viciousalliancebearmount.m2"] = {
		familyName = "Vicious War Bear (PVP)",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/vicioushordebearmount/vicioushordebearmount.m2"] = {
		familyName = "Vicious War Bear (PVP)",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/northrendbearmount/northrendbearmountarmored.m2"] = {
		familyName = "Armored Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/northrendbearmount/northrendbearmountblizzcon.m2"] = {
		familyName = "Big Blizzard Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/jailerhoundmount/jailerhoundmount.m2"] = {
		familyName = "Shadehound",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/bearmountalt/bearmountalt_darkmoonfaire.m2"] = {
		familyName = "Darkmoon Dancing Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/chinabearmount/chinabearmount.m2"] = {
		familyName = "Harmonious Salutations Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/bear2/bear2.m2"] = {
		familyName = "Blackpaw",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/bearmountblizzard/bearmountblizzard.m2"] = {
		familyName = "Snowstorm",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/bearmountutility/bearmountutility.m2"] = {
		familyName = "Grizzly Hills Packmaster",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/mawexpansionbearmount/mawexpansionbearmount.m2"] = {
		familyName = "Shardhide",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Bees
	["creature/sandbeemount/sandbeemount.m2"] = {
		familyName = "Timely Buzzbee",
		superGroup = "Bees",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/beemount/beemount.m2"] = {
		familyName = "Honeyback",
		superGroup = "Bees",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Boards
	["creature/goblinsurfboardmount/goblinsurfboardmount.m2"] = {
		familyName = "Surfboard",
		superGroup = "Boards",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chessmount/chessmount.m2"] = {
		familyName = "Grandmaster's Board",
		superGroup = "Boards",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Boars
	["creature/giantboar/giantboarmount.m2"] = {
		familyName = "Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/giantboar/giantboararmoredmount.m2"] = {
		familyName = "Armored Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/maldraxxusboarmount/maldraxxusboarmount.m2"] = {
		familyName = "Maldraxxus Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/progenitorwombatmount/progenitorwombatmount.m2"] = {
		familyName = "Progenitor Wombat",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Brutosaurs
	["creature/brontosaurusmountspecial/brontosaurusmountspecial.m2"] = {
		familyName = "Trader's Gilded Brutosaur",
		superGroup = "Brutosaurs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/brontosaurusmount/brontosaurusmount.m2"] = {
		familyName = "Mighty Caravan Brutosaur",
		superGroup = "Brutosaurs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Camels
	["creature/camel/camelmount.m2"] = {
		familyName = "Camel",
		superGroup = "Camels",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/camelmount2/camelmount2.m2"] = {
		familyName = "Explorer's Dunetrekker",
		superGroup = "Camels",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Choppers
	["creature/motorcyclevehicle/motorcyclevehicle.m2"] = {
		familyName = "Mechano-Hog",
		superGroup = "Choppers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hordechopper/hordechopper.m2"] = {
		familyName = "Warlord's Deathwheel",
		superGroup = "Choppers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/alliancechopper/alliancechopper.m2"] = {
		familyName = "Champion's Treadblade",
		superGroup = "Choppers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/motorcyclefelreavermount/motorcyclefelreavermount.m2"] = {
		familyName = "Reaver Motorcycle",
		superGroup = "Choppers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Chromatic Dragon
	["creature/dragonchromaticmount/dragonchromaticmount.m2"] = {
		familyName = "Heart of the Aspects",
		superGroup = "Chromatic Dragon",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dragonchromaticmount2/dragonchromaticmount2.m2"] = {
		familyName = "Corruption of the Aspects",
		superGroup = "Chromatic Dragon",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Clefthooves
	["creature/ironhordeclefthoof/ironhordeclefthoof.m2"] = {
		familyName = "Ironhoof Destroyer",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/vicioushordeclefthoof/vicioushordeclefthoof.m2"] = {
		familyName = "Vicious War Clefthoof (PVP)",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/clefthoofdraenor/clefthoofdraenormount.m2"] = {
		familyName = "Clefthoof",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Cloud Serpents
	["creature/pandarenserpent/pandarenserpentmount.m2"] = {
		familyName = "Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/pandarenserpentgod/pandarenserpentgodmount.m2"] = {
		familyName = "Heavenly Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/pandarenserpent/pandarenserpentmount_lightning.m2"] = {
		familyName = "Thundering Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/celestialserpent/celestialserpentmount.m2"] = {
		familyName = "Astral Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/pandarenserpent/pvppandarenserpentmount.m2"] = {
		familyName = "Gladiator's Cloud Serpent (PVP)",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/shaserpentmount/shaserpentmount.m2"] = {
		familyName = "Sha-Warped Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/wolfserpentmount/wolfserpentmount.m2"] = {
		familyName = "Wilderling",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/wolfserpentmount2/wolfserpentmount2.m2"] = {
		familyName = "Voyaging Wilderling",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Darkhounds
	["creature/darkhoundmount/darkhoundmount.m2"] = {
		familyName = "Grimhowl",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/darkirondwarfcorehound/darkirondwarfcorehound.m2"] = {
		familyName = "Dark Iron Core Hound",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/darkhoundmount_draka/darkhoundmount_draka.m2"] = {
		familyName = "Darkhound",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mawratmount/mawratmount.m2"] = {
		familyName = "Mawrat",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Dirigibles
	["creature/zeppelinmount/zeppelinmount.m2"] = {
		familyName = "Darkmoon Dirigible",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hordezeppelinmount/hordezeppelinmount.m2"] = {
		familyName = "Orgrimmar Interceptor",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/allianceshipmount/allianceshipmount.m2"] = {
		familyName = "Stormwind Skychaser",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["character/rostrumairship/rostrumairship.m2"] = {
		familyName = "Dirigible",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Direhorns
	["creature/triceratops/triceratopsmount.m2"] = {
		familyName = "Primordial Direhorn",
		superGroup = "Direhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/zandalaripaladinmount/zandalaripaladinmount.m2"] = {
		familyName = "Crusader's Direhorn",
		superGroup = "Direhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Dread ravens
	["creature/dreadravenwarbird/dreadravenwarbirdfelmount.m2"] = {
		familyName = "Corrupted Dreadwing",
		superGroup = "Dread ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ravenlord/ravenlordmount.m2"] = {
		familyName = "Dread Raven",
		superGroup = "Dread ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Drakes
	["creature/drakemount/drakemount.m2"] = {
		familyName = "Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/drakemount/armoredtwilightdrake.m2"] = {
		familyName = "Gladiator's Twilight Drake (PVP)",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/drakemount/feldrakemount.m2"] = {
		familyName = "Feldrake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/reddrakemount/reddrakemount.m2"] = {
		familyName = "Horned Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dragon/onyxiamount.m2"] = {
		familyName = "Onyxian Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dragondeepholm/dragondeepholmmount.m2"] = {
		familyName = "Stone Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dragonskywall/dragonskywallmount.m2"] = {
		familyName = "Drake of the Wind",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/encrypted13/encrypted13.m2"] = {
		familyName = "World Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nightbane2mount/nightbane2mount.m2"] = {
		familyName = "Smoldering Ember Wyrm",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/scaleddrakemount/scaleddrakemount.m2"] = {
		familyName = "Tarecgosa's Visage",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/encrypted16/encrypted16.m2"] = {
		familyName = "Steamscale Incinerator",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/voiddragonmount/voiddragonmount.m2"] = {
		familyName = "Uncorrupted Voidwing",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/drakemountemerald/drakemountemerald.m2"] = {
		familyName = "Tangled Dreamweaver",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/encrypted08/encrypted08.m2"] = {
		familyName = "Sylverian Dreamer",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Eagles
	["creature/eagle2windmount/eagle2windmount.m2"] = {
		familyName = "Eagle",
		superGroup = "Eagles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/eagle2wind/eagle2wind.m2"] = {
		familyName = "Divine Kiss of Ohn'ahra",
		superGroup = "Eagles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	-- Elderhorns
	["creature/moosemount2/moosemount2.m2"] = {
		familyName = "Elderhorn",
		superGroup = "Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hmmoosemount/hmmoosemount.m2"] = {
		familyName = "Highmountain Thunderhoof",
		superGroup = "Elderhorns",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Elementals
	["creature/snowelementalmount/snowelementalmount.m2"] = {
		familyName = "Bound Blizzard",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/shadowelementalmount/shadowelementalmount.m2"] = {
		familyName = "Shadow",
		superGroup = "Elementals",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/deathelementalmount/deathelementalmount.m2"] = {
		familyName = "Deathwalker",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/waterelementalmount/waterelementalmount.m2"] = {
		familyName = "Glacial Tidestorm",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/shamanmount_fire/shamanmount_fire.m2"] = {
		familyName = "Farseer's Raging Tempest",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/ragnarosmount/ragnarosmount.m2"] = {
		familyName = "Runebound Firelord",
		superGroup = "Elementals",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Fey Dragons
	["creature/faeriedragonmount/faeriedragonmount.m2"] = {
		familyName = "Enchanted Fey Dragon",
		superGroup = "Fey Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	["character/rostrumfaeriedragon/rostrumfaeriedragon.m2"] = {
		familyName = "Flourishing Whimsydrake",
		superGroup = "Fey Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Flying Carpets
	["creature/flyingcarpetmount/flyingcarpetmount.m2"] = {
		familyName = "Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/flyingcarpetmount2/flyingcarpetmount2.m2"] = {
		familyName = "Leywoven Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/flyingcarpet3/flyingcarpet3.m2"] = {
		familyName = "Noble Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Flying Discs
	["creature/cloudmount/cloudmount.m2"] = {
		familyName = "Cloud",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/magemount_arcane/magemount_arcane.m2"] = {
		familyName = "Archmage's Prismatic Disc",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hearthstonemount/hearthstonemount.m2"] = {
		familyName = "Compass Rose",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/brokermount/brokermount.m2"] = {
		familyName = "Gearglider",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Flying Elderhorns
	["creature/ghostlymoose/ghostlymoosemount.m2"] = {
		familyName = "Spirit of Eche'ro",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/moosemount/moosemount.m2"] = {
		familyName = "Grove Warden",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/moosemount2nightmare/moosemount2nightmare.m2"] = {
		familyName = "Grove Defiler",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Flying Fishes
	["creature/fishmount/fishmount.m2"] = {
		familyName = "Brinedeep Bottom-Feeder",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/magicalfishmount/magicalfishmount.m2"] = {
		familyName = "Wondrous Wavewhisker",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/oldgodfishmount/oldgodfishmount.m2"] = {
		familyName = "Underlight Behemoth",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Flying Machines
	["creature/gyrocopter/gyrocopter_01.m2"] = {
		familyName = "Turbo-Charged Flying Machine",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/gyrocopter/gyrocopter_02.m2"] = {
		familyName = "Flying Machine",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/explorergyrocopter/explorergyrocopter.m2"] = {
		familyName = "Explorer's Jungle Hopper",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Foxes
	["creature/foxmount/foxmount.m2"] = {
		familyName = "Fox",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarfoxalliance/viciouswarfoxalliance.m2"] = {
		familyName = "Vicious War Fox (PVP)",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouswarfoxhorde/viciouswarfoxhorde.m2"] = {
		familyName = "Vicious War Fox (PVP)",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/fox2/fox2.m2"] = {
		familyName = "Glimmerfur",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/encrypted09/encrypted09.m2"] = {
		familyName = "Vulpine Familiar",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/lovefoxmount/lovefoxmount.m2"] = {
		familyName = "Sky Fox",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Furlines
	["creature/celestialcatmount/celestialcatmount.m2"] = {
		familyName = "Startouched Furline",
		superGroup = "Furlines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/catmount/catmount.m2"] = {
		familyName = "Sunwarmed Furline",
		superGroup = "Furlines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Gargons
	["creature/deathwargmount/deathwargmount.m2"] = {
		familyName = "Gargon",
		superGroup = "Gargons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/deathwargmount2/deathwargmount2.m2"] = {
		familyName = "Armored Gargon",
		superGroup = "Gargons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Gronnlings
	["creature/lessergronn/lessergronnmount.m2"] = {
		familyName = "Gronnling",
		superGroup = "Gronnlings",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/fellessergronn/fellessergronnmount.m2"] = {
		familyName = "Felblood Gronnling (PVP)",
		superGroup = "Gronnlings",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Gorms
	["creature/decomposermount/decomposermount.m2"] = {
		familyName = "Gorm",
		superGroup = "Gorms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousgorm/viciousgorm.m2"] = {
		familyName = "Vicious War Gorm (PVP)",
		superGroup = "Gorms",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Highland Drake
	["character/companiondrake/companiondrake.m2"] = {
		familyName = "Highland Drake",
		superGroup = "Highland Drake",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/drake2mountgladiator/drake2mountgladiator.m2"] = {
		familyName = "Gladiator's Drake (PVP)",
		superGroup = "Highland Drake",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Hippogryphs
	["creature/hippogryph_arcane/hippogryph_arcanemount.m2"] = {
		familyName = "Leyfeather Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hippogryph2/hippogryph2mount.m2"] = {
		familyName = "Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hippogryphmount/hippogryphmount.m2"] = {
		familyName = "Armored Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hippogryphmountnightelf/hippogryphmountnightelf.m2"] = {
		familyName = "Teldrassil Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hippogryph/burnthippogryph.m2"] = {
		familyName = "Blazing Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/pyrogryph/pyrogryph.m2"] = {
		familyName = "Flameward Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/felhippogryph/felhippogryphmount.m2"] = {
		familyName = "Corrupted Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/30thhippogryphmount/30thhippogryphmount.m2"] = {
		familyName = "Chaos-Forged Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/elitehippogryph/elitehippogryph.m2"] = {
		familyName = "Emerald Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Hyenas
	["creature/vulperamount/vulperamount.m2"] = {
		familyName = "Caravan Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hyena2mount/hyena2mount.m2"] = {
		familyName = "Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hyena2goblinmount/hyena2goblinmount.m2"] = {
		familyName = "Cartel Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Infinite Timereavers
	["creature/infinitedragonmount/infinitedragonmount.m2"] = {
		familyName = "Infinite Timereaver",
		superGroup = "Infinite Timereavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/piratedragonmount/piratedragonmount.m2"] = {
		familyName = "Chrono Corsair",
		superGroup = "Infinite Timereavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Jellyfishes
	["creature/eyeballjellyfishmount/eyeballjellyfishmount.m2"] = {
		familyName = "Ny'alotha Allseer",
		superGroup = "Jellyfishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/progenitorjellyfishmount/progenitorjellyfishmount.m2"] = {
		familyName = "Progenitor Aurelid",
		superGroup = "Jellyfishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Kite
	["creature/pandarenkitemount/pandarenkitemount.m2"] = {
		familyName = "Kite",
		superGroup = "Kite",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/tuskarrglider/tuskarrglider.m2"] = {
		familyName = "Tuskarr Shoreglider",
		superGroup = "Kite",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Lions
	["creature/guildcreatures/alliancelionmount/alliancelionmount.m2"] = {
		familyName = "Golden King",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousgoldenking/viciousgoldenking.m2"] = {
		familyName = "Vicious War Lion (PVP)",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/wingedlion2mount/wingedlion2mount.m2"] = {
		familyName = "Larion",
		superGroup = "Lions",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/automatonlionmount/automatonlionmount.m2"] = {
		familyName = "Phalynx",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/automatonlionmount2/automatonlionmount2.m2"] = {
		familyName = "Eternal Phalynx",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Lupines
	["creature/progenitorwolf/progenitorwolf.m2"] = {
		familyName = "Heartbond Lupine",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/vicioushordewolf/vicioushordewolf.m2"] = {
		familyName = "Vicious Warstalker (PVP)",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousalliancewolf/viciousalliancewolf.m2"] = {
		familyName = "Vicious Warstalker (PVP)",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Mechaspiders
	["creature/mechagonspidertank/mechagonspidertank.m2"] = {
		familyName = "Mechaspider",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/goblinspidertank/goblinspidertank.m2"] = {
		familyName = "Shreddertank",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/progenitorbotminemount/progenitorbotminemount.m2"] = {
		familyName = "Carcinized Zerethsteed",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Mechsuits
	["creature/felreavermount/felreavermount.m2"] = {
		familyName = "Felsteel Annihilator",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/kezancrowdpummeler_gallywix/kezancrowdpummeler_gallywix.m2"] = {
		familyName = "G.M.O.D.",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/rocketshredder9001/rocketshredder9001.m2"] = {
		familyName = "Rocket Shredder 9001",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/dwarvenmechboss/dwarvenmechboss.m2"] = {
		familyName = "Dwarven Mechsuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/crystalmech/crystalmech.m2"] = {
		familyName = "Diamond Mechsuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/goblinshreddermech/goblinshreddermech.m2"] = {
		familyName = "Cartel Mechasuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/goblinshreddermechboss/goblinshreddermechboss.m2"] = {
		familyName = "Magnetomech",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/overchargedmech/overchargedmech.m2"] = {
		familyName = "OC91 Chariot",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/shredder/shreddermount.m2"] = {
		familyName = "Sky Golem",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/lightforgedmechsuit/lightforgedmechsuit.m2"] = {
		familyName = "Lightforged Warframe",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Mechaheads
	["creature/mimiron/mimiron_head_mount.m2"] = {
		familyName = "Mimiron's Head",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/goblinheadmech/goblinheadmech.m2"] = {
		familyName = "Mecha-Mogul Mk2",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/gallywixmechmount/gallywixmechmount.m2"] = {
		familyName = "The Big G",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Mammoths
	["creature/mammoth/mammothmount_1seat.m2"] = {
		familyName = "Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mammoth/mammothmount_3seat.m2"] = {
		familyName = "Grand Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mammoth2mount/mammoth2mount.m2"] = {
		familyName = "Trawling Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/mammoth2lavamount/mammoth2lavamount.m2"] = {
		familyName = "Magmammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Moles
	["creature/molemount/molemount.m2"] = {
		familyName = "Fancy Mole",
		superGroup = "Moles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/molemountbasic/molemountbasic.m2"] = {
		familyName = "Mole",
		superGroup = "Moles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Moonbeasts
	["creature/magicalowlbearmount/magicalowlbearmount.m2"] = {
		familyName = "Gleaming Moonbeast",
		superGroup = "Moonbeasts",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousowlbearmount/viciousowlbearmount.m2"] = {
		familyName = "Vicious Moonbeast (PVP)",
		superGroup = "Moonbeasts",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Nether Drakes
	["creature/netherdrake/netherdrake.m2"] = {
		familyName = "Nether Drake",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/netherdrake/netherdrakeelite.m2"] = {
		familyName = "Nether Drake (PVP)",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["character/companionnetherwingdrake/companionnetherwingdrake.m2"] = {
		familyName = "Grotto Netherwing Drake",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Ottuks
	["creature/riverotterlargemount01/riverotterlargemount01.m2"] = {
		familyName = "Ottuk",
		superGroup = "Ottuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/riverotterlargemount02/riverotterlargemount02.m2"] = {
		familyName = "Armored Ottuk",
		superGroup = "Ottuks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Owls
	["creature/dreamowl_firemount/dreamowl_firemount.m2"] = {
		familyName = "Anu'relos",
		superGroup = "Owls",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/owldragonmount/owldragonmount.m2"] = {
		familyName = "Charming Courier",
		superGroup = "Owls",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Parrots
	["creature/parrotmount/parrotmount.m2"] = {
		familyName = "Parrot",
		superGroup = "Parrots",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/parrotpiratemount/parrotpiratemount.m2"] = {
		familyName = "Pirate Parrot",
		superGroup = "Parrots",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/mechanicalparrotmount/mechanicalparrotmount.m2"] = {
		familyName = "Wonderwing",
		superGroup = "Parrots",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/roguemount/roguemount.m2"] = {
		familyName = "Shadowblade's Omen",
		superGroup = "Parrots",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Phoenixes
	["creature/ridingphoenix/ridingphoenix.m2"] = {
		familyName = "Ashes of Al'ar",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/darkphoenix/darkphoenixmount.m2"] = {
		familyName = "Dark Phoenix",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ridingphoenix2/ridingphoenix2.m2"] = {
		familyName = "Golden Ashes of Al'ar",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/pandarenphoenixmount/pandarenphoenixmount.m2"] = {
		familyName = "Pandaren Phoenix",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/thunderislebird/thunderislebirdbossmount.m2"] = {
		familyName = "Clutch of..",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Plaguebats
	["creature/felbatmountforsaken/felbatmountforsaken.m2"] = {
		familyName = "Plaguebat",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/nerubianwarbeastmount/nerubianwarbeastmount.m2"] = {
		familyName = "Skyrazor",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/felbatgladiatormount/felbatgladiatormount.m2"] = {
		familyName = "Gladiator's Fel Bat (PVP)",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/amalgamofrage/amalgamofrage.m2"] = {
		familyName = "Amalgam of Rage",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/dhmount2/dhmount2.m2"] = {
		familyName = "Slayer's Felbroken Shrieker",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Proto-Drakes
	["creature/protodragon/mdprotodrakemount.m2"] = {
		familyName = "Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/protodragon/protodragon_razorscale_mount.m2"] = {
		familyName = "Razorscale Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/protodrakegladiatormount/protodrakegladiatormount.m2"] = {
		familyName = "Gladiator's Proto-Drake (PVP)",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["character/companionprotodragon/companionprotodragon.m2"] = {
		familyName = "Renewed Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/frostbroodprotowyrm/frostbroodprotowyrm.m2"] = {
		familyName = "Frostbrood Proto-Wyrm",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/protodragon/korkronprotodrakemount.m2"] = {
		familyName = "Spawn of Galakras",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/warriormount/warriormount.m2"] = {
		familyName = "Battlelord's Bloodthirsty War Wyrm",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Pterrordax
	["creature/pterrordax2mount/pterrordax2mount.m2"] = {
		familyName = "Battle Pterrordax",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/thunderpterodactyl/thunderpterodactylmount.m2"] = {
		familyName = "Thunder Pterrordax",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["character/companionpterrodax/companionpterrodax.m2"] = {
		familyName = "Windborne Velocidrake",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Qirajis
	["creature/ridingsilithid/ridingsilithid.m2"] = {
		familyName = "Qiraji Battle Tank",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingsilithid2/ridingsilithid2.m2"] = {
		familyName = "Qiraji War Tank",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/ravager2/ravager2mount.m2"] = {
		familyName = "Grinning Reaver",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Quilens
	["creature/quilin/quilinflyingmount.m2"] = {
		familyName = "Flying Quilen",
		superGroup = "Quilens",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/quilin/quilinmount.m2"] = {
		familyName = "Quilen",
		superGroup = "Quilens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Hawks
	["creature/progenitorhawkmount/progenitorhawkmount.m2"] = {
		familyName = "Progenitor Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/phoenix2mount/phoenix2mount.m2"] = {
		familyName = "Skyblazer",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/blizzardphoenixmount/blizzardphoenixmount.m2"] = {
		familyName = "Skyblazer",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/firehawk/firehawk_mount.m2"] = {
		familyName = "Fire Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/firehawk2_mount/firehawk2_mount.m2"] = {
		familyName = "Blazing Royal Fire Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Rats
	["creature/ratmount2/ratmount2.m2"] = {
		familyName = "Squeakers, the Trickster",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ratmounthearthstone/ratmounthearthstone.m2"] = {
		familyName = "Sarge's Tale",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ratmount/ratmount.m2"] = {
		familyName = "Ratstallion",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Ravens
	["creature/fireravengodmount/fireravengodmount.m2"] = {
		familyName = "Elemental Raven",
		superGroup = "Ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ravengod/ravengod.m2"] = {
		familyName = "Raven Lord",
		superGroup = "Ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Rockets
	["creature/rocketmount/rocketmount.m2"] = {
		familyName = "Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/lunarrocketmount/lunarrocketmount.m2"] = {
		familyName = "Lunar Launcher",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/rocketmount5/rocketmount5.m2"] = {
		familyName = "Cartel Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/rocketmount4/rocketmount4.m2"] = {
		familyName = "Geosynchronous World Spinner",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/rocketmount3/rocketmount3.m2"] = {
		familyName = "Depleted-Kyparium Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/rocketmount2/rocketmount2.m2"] = {
		familyName = "X-53 Touring Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Scorpions
	["creature/hordescorpionmount/hordescorpionmount.m2"] = {
		familyName = "Scorpion",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciouskorkronannihilator/viciouskorkronannihilator.m2"] = {
		familyName = "Vicious War Scorpion (PVP)",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/ironjuggernaut/ironjuggernautmount.m2"] = {
		familyName = "Juggernaut",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Scarabs
	["creature/scarabmount/scarabmount.m2"] = {
		familyName = "Scarab",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/beetlemount/beetlemount.m2"] = {
		familyName = "Telix",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/nerubianbeetlelargemount/nerubianbeetlelargemount.m2"] = {
		familyName = "Ivory Goliathus",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Seahorses
	["creature/hippocampusmount/hippocampusmount.m2"] = {
		familyName = "Tidestallion",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/seahorse/seahorsemount.m2"] = {
		familyName = "Seahorse",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/hippocampus/hippocampus.m2"] = {
		familyName = "Fabious",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Serpents
	["creature/serpentmount/serpentmount.m2"] = {
		familyName = "Serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/nzothserpent/nzothserpent.m2"] = {
		familyName = "Slime Serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/nzothserpentmount/nzothserpentmount.m2"] = {
		familyName = "N'Zoth serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/aetherserpentmount/aetherserpentmount.m2"] = {
		familyName = "Ensorcelled Everwyrm",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/lunarsnakemount/lunarsnakemount.m2"] = {
		familyName = "Timbered Sky Snake",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/manawyrmmount/manawyrmmount.m2"] = {
		familyName = "Nether-Gorged Greatwyrm",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Skiffs
	["creature/skiff/skiff.m2"] = {
		familyName = "The Dreadwake",
		superGroup = "Skiffs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/shipmount/shipmount.m2"] = {
		familyName = "The Breaker's Song",
		superGroup = "Skiffs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Skyreavers
	["creature/chimera2/chromaticchimera.m2"] = {
		familyName = "Chimera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chimera2/ironchimera.m2"] = {
		familyName = "Armored Chimera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chimera3mount/chimera3mount.m2"] = {
		familyName = "Ashenvale Chimaera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chimerafiremount/chimerafiremount.m2"] = {
		familyName = "Cormaera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/maldraxxusflyermount/maldraxxusflyermount.m2"] = {
		familyName = "Flayedwing",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Slitherdrakes
	["creature/lunardragonmount/lunardragonmount.m2"] = {
		familyName = "Auspicious Arborwyrm",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["character/companionserpent/companionserpent.m2"] = {
		familyName = "Winding Slitherdrake",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/serpentmountgladiator/serpentmountgladiator.m2"] = {
		familyName = "Gladiator's Slitherdrake (PVP)",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Snapdragons
	["creature/snapdragonmount/snapdragonmount.m2"] = {
		familyName = "Snapdragon",
		superGroup = "Snapdragons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/snapdragon/snapdragon.m2"] = {
		familyName = "Prismatic Snapdragon",
		superGroup = "Snapdragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Snails
	["creature/snailrockmount/snailrockmount.m2"] = {
		familyName = "Snail",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/vicioussnail/vicioussnail.m2"] = {
		familyName = "Vicious War Snail (PVP)",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
	},
	["creature/lavasnailmount/lavasnailmount.m2"] = {
		familyName = "Snailemental",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/lavaslugmount/lavaslugmount.m2"] = {
		familyName = "Seething Slug",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/progenitorsnailmount/progenitorsnailmount.m2"] = {
		familyName = "Progenitor Snail",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Soul Eaters
	["creature/shadebeastmount/shadebeastmount.m2"] = {
		familyName = "Gladiator's Soul Eater (PVP)",
		superGroup = "Soul Eaters",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/shadebeastflying/shadebeastflying.m2"] = {
		familyName = "Zovaal's Soul Eater",
		superGroup = "Soul Eaters",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Spiders
	["creature/progenitorspidermount/progenitorspidermount.m2"] = {
		familyName = "Progenitor Spider",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/spidermount/spidermount.m2"] = {
		familyName = "Bloodfang Widow",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousalliancespider/viciousalliancespider.m2"] = {
		familyName = "Vicious War Spider (PVP)",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/vicioushordespider/vicioushordespider.m2"] = {
		familyName = "Vicious War Spider (PVP)",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/spiderundergroundmount/spiderundergroundmount.m2"] = {
		familyName = "Undercrawler",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Stags
	["creature/ardenwealdstagmount/ardenwealdstagmount.m2"] = {
		familyName = "Runestag",
		superGroup = "Stags",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ardenwealdstagmount2/ardenwealdstagmount2.m2"] = {
		familyName = "Enchanted Runestag",
		superGroup = "Stags",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/emeralddreamstagmount/emeralddreamstagmount.m2"] = {
		familyName = "Dreamstag",
		superGroup = "Stags",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/progenitorstagmount/progenitorstagmount.m2"] = {
		familyName = "Progenitor Stag",
		superGroup = "Stags",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Storm Dragons
	["creature/stormdragon/stormdragonmount.m2"] = {
		familyName = "Storm Dragon",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/stormdragonmount2/stormdragonmount2.m2"] = {
		familyName = "Gladiator's Storm Dragon (PVP)",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/stormdragonmount2_fel/stormdragonmount2_fel.m2"] = {
		familyName = "Demonic Gladiator's Storm Dragon (PVP)",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Stormcrows
	["creature/stormcrowmount_solar/stormcrowmount_solar.m2"] = {
		familyName = "Solar Spirehawk",
		superGroup = "Stormcrows",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/stormcrowmount_solar/stormcrowmount_arcane.m2"] = {
		familyName = "Violet Spellwing",
		superGroup = "Stormcrows",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	["creature/stormcrowmount/stormcrowmount.m2"] = {
		familyName = "Thrayir",
		superGroup = "Stormcrows",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Striders
	["creature/tallstrider2/tallstrider2.m2"] = {
		familyName = "Strider",
		superGroup = "Striders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/tallstriderprimalmount/tallstriderprimalmount.m2"] = {
		familyName = "Hornstrider",
		superGroup = "Striders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Sweepers
	["creature/lovebroom/lovebroom.m2"] = {
		familyName = "Sweeper",
		superGroup = "Sweepers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/broommount2/broommount2.m2"] = {
		familyName = "Eve's Ghastly Rider",
		superGroup = "Sweepers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Swarmites
	["creature/flyingnerubian2mount/flyingnerubian2mount.m2"] = {
		familyName = "Swarmite",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/devourersmallmount/devourersmallmount.m2"] = {
		familyName = "Devourer",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/viciousflyingnerubian2/viciousflyingnerubian2_horde.m2"] = {
		familyName = "Vicious War Skyflayer (PVP)",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousflyingnerubian2/viciousflyingnerubian2_alliance.m2"] = {
		familyName = "Vicious War Skyflayer (PVP)",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/bloodtickmount/bloodtickmount.m2"] = {
		familyName = "Bloodswarmer",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Talbuks
	["creature/ridingtalbuk/ridingtalbuk.m2"] = {
		familyName = "Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingtalbuk/ridingtalbukepic.m2"] = {
		familyName = "Armored Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/argustalbukmount/argustalbukmount.m2"] = {
		familyName = "Argus Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/lightforgedtalbuk/lightforgedtalbuk.m2"] = {
		familyName = "Lightforged Ruinstrider",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/argustalbuk/argustalbuk.m2"] = {
		familyName = "Maddened Chaosrunner",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/talbukdraenor/talbukdraenormount.m2"] = {
		familyName = "Talbuk Draenor",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	-- Tauraluses
	["creature/giantbeastmount/giantbeastmount.m2"] = {
		familyName = "Tauralus",
		superGroup = "Tauraluses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/giantbeastmount2/giantbeastmount2.m2"] = {
		familyName = "Armored Tauralus",
		superGroup = "Tauraluses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	-- Toads
	["creature/toadloamount/toadloamount.m2"] = {
		familyName = "Hopper",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/vicioushordetoad/vicioushordetoad.m2"] = {
		familyName = "Vicious War Croaker (PVP)",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousalliancetoad/viciousalliancetoad.m2"] = {
		familyName = "Vicious War Croaker (PVP)",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/toadardenwealdmount/toadardenwealdmount.m2"] = {
		familyName = "Arboreal Gulper",
		superGroup = "Toads",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/progenitortoadmount/progenitortoadmount.m2"] = {
		familyName = "Progenitor Gulper",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Vanquisher Wyrms
	["creature/ridingundeaddrake/armoredridingundeaddrake.m2"] = {
		familyName = "Vanquisher",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingundeaddrake/ridingundeaddrake.m2"] = {
		familyName = "Gladiator's Frost Wyrm (PVP)",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dkmount/dkmount.m2"] = {
		familyName = "Deathlord's Vilebrood Vanquisher",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
	},
	-- Yaks
	["creature/ridingyak/ridingyak.m2"] = {
		familyName = "Yak",
		superGroup = "Yaks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/travelersyak/travelersyak.m2"] = {
		familyName = "Grand Expedition Yak",
		superGroup = "Yaks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/alpacamount/alpacamount.m2"] = {
		familyName = "Alpaca",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ancientmount/ancientmount.m2"] = {
		familyName = "Wandering Ancient",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/aqirflyingmount/aqirflyingmount.m2"] = {
		familyName = "Drone",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/automatonfliermount/automatonfliermount.m2"] = {
		familyName = "Aquilon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/bloodtrollfemalebeast_mount/bloodtrollbeast_mount.m2"] = {
		familyName = "Crawg",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/bookmount/bookmount.m2"] = {
		familyName = "Soaring Spelltome",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/butterflymount/butterflymount.m2"] = {
		familyName = "Butterfly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/caveborerwormmount/caveborerwormmount.m2"] = {
		familyName = "Ferocious Jawcrawler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chickenmount/chickenmount.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chickenmount/chickenmount15.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/chickenmount/chickenmount35.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/corehound2/corehoundmount.m2"] = {
		familyName = "Core Hound",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/crabmount/crabmount.m2"] = {
		familyName = "Crawler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/crane/cranemount.m2"] = {
		familyName = "Crane",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/devourermediummount/devourermediummount.m2"] = {
		familyName = "Gorger",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/devourerswarmermount/devourerswarmermount.m2"] = {
		familyName = "Devouring Mauler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dogmount/dogmount.m2"] = {
		familyName = "Shu-Zen",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/dragonwhelp3/dragonwhelp3.m2"] = {
		familyName = "Whelpling",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/electriceelviciousmount/electriceelviciousmount.m2"] = {
		familyName = "Vicious Electro Eel (PVP)",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/encrypted05/encrypted05.m2"] = {
		familyName = "Meat Wagon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/encrypted06/encrypted06.m2"] = {
		familyName = "Hogrus",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/facelessmount/facelessmount2.m2"] = {
		familyName = "Jelly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/falcosauros/falcosaurosmount.m2"] = {
		familyName = "Falcosaur",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/felstalkermount/felstalkermount.m2"] = {
		familyName = "Felstalker",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/firebeemount/firebeemount.m2"] = {
		familyName = "Cinderbee",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/firefly2mount/firefly2mount.m2"] = {
		familyName = "Glowmite",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/flymaldraxxus/flymaldraxxus.m2"] = {
		familyName = "Corpsefly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/forsakenhorsemount/forsakenhorsemount.m2"] = {
		familyName = "Banshee's Charger",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/foxwyvernmount/foxwyvernmount.m2"] = {
		familyName = "Slyvern",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/gargoylebrute2mount/gargoylebrute2mount.m2"] = {
		familyName = "Gravewing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/goat/goatmount.m2"] = {
		familyName = "Goat",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hedgehogmount/hedgehogmount.m2"] = {
		familyName = "Harvesthog",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hippomount/hippomount.m2"] = {
		familyName = "Riverwallow",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hivemind/hivemind.m2"] = {
		familyName = "The Hivemind",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/hovercraftmount/hovercraftmount.m2"] = {
		familyName = "Xiwyllag ATV",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/huntermount/huntermount.m2"] = {
		familyName = "Huntmaster's Wolfhawk",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/infernalmount/infernalmount.m2"] = {
		familyName = "Infernal",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/invisiblestalker/invisiblestalker.m2"] = {
		familyName = "Soar",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/manaraymount/manaraymount.m2"] = {
		familyName = "Mana Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mawexpansionfliermount/mawexpansionfliermount.m2"] = {
		familyName = "Razorwing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mawguardhandmount/mawguardhandmount.m2"] = {
		familyName = "Mawguard Hand",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mechacycle/mechacycle.m2"] = {
		familyName = "Mechacycle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mechadevilsaurmount/mechadevilsaurmount.m2"] = {
		familyName = "Flarendo the Furious",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/moosebullmount/moosebullmount.m2"] = {
		familyName = "Bruffalon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mothardenwealdmount/mothardenwealdmount.m2"] = {
		familyName = "Ardenmoth",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/motorcyclevehicle/motorcyclevehicle2.m2"] = {
		familyName = "Chauffeured vehicle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/murlocmount/murlocmount.m2"] = {
		familyName = "Grrloc",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/mushanbeast/mushanbeastmount.m2"] = {
		familyName = "Mushan Beast",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/oxmount/oxmount.m2"] = {
		familyName = "Lucky Yun",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/pandarenyetimount/pandarenyetimount.m2"] = {
		familyName = "Yeti",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/peacockmount/peacockmount.m2"] = {
		familyName = "Peafowl",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/priestmount/priestmount.m2"] = {
		familyName = "High Priest's Lightsworn Seeker",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/primaldragonflymount/primaldragonflymount.m2"] = {
		familyName = "Skitterfly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/progenitorbotmount/progenitorbotmount.m2"] = {
		familyName = "Zereth Overseer",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/progenitorwaspmount/progenitorwaspmount.m2"] = {
		familyName = "Progenitor Wasp",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rabbitmount/rabbitmount.m2"] = {
		familyName = "Jade",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ravenmount/ravenmount.m2"] = {
		familyName = "Great Raven",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/redpandamount/redpandamount.m2"] = {
		familyName = "Meeksi",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rhinoprimalmountdream/rhinoprimalmountdream.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rhinoprimalmountfire/rhinoprimalmountfire.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rhinoprimalmountice/rhinoprimalmountice.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rhinoprimalmountinfinite/rhinoprimalmountinfinite.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/ridingnetherray/ridingnetherray.m2"] = {
		familyName = "Nether Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/rocmaldraxxusmount/rocmaldraxxusmount.m2"] = {
		familyName = "Roc",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/salamanderwatermount/salamanderwatermount.m2"] = {
		familyName = "Salamanther",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/sharkraymount/sharkraymount.m2"] = {
		familyName = "Waveray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/sleigh/sleigh.m2"] = {
		familyName = "Unknown",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/soulhoundmount/soulhoundmount.m2"] = {
		familyName = "Ur'zul",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/sporebatrockmount/sporebatrockmount.m2"] = {
		familyName = "Shalewing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/stingray2/stingray2mount.m2"] = {
		familyName = "Sea Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/thunderlizardprimalmount/thunderlizardprimalmount.m2"] = {
		familyName = "Thunderspine",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/trilobitemount1/trilobitemount1.m2"] = {
		familyName = "Krolusk",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/viciousalliancehippo/viciousalliancehippo.m2"] = {
		familyName = "Vicious War Riverbeast (PVP)",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/vulturemount/vulturemount.m2"] = {
		familyName = "Albatross",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/warpstalkermount/warpstalkermount.m2"] = {
		familyName = "Viridian Phase-Hunter",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/waterstrider/waterstridermount.m2"] = {
		familyName = "Water Strider",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["creature/woolyrhino/woolyrhinomount.m2"] = {
		familyName = "Wooly White Rhino",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
	["world/expansion08/doodads/fae/9fa_fae_soulpod_cart02.m2"] = {
		familyName = "Wildseed Cradle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
	},
}
