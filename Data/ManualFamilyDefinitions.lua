-- Manual Family Definitions
if not RandomMountBuddy_PreloadData then RandomMountBuddy_PreloadData = {} end

RandomMountBuddy_PreloadData.FamilyDefinitions = {
	["character/companiondrake/companiondrake.m2"] = {
		familyName = "Highland Drake",
		superGroup = "Highland Drake",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dragon Isles Drake Model Test (MountID: 1605)
		--   Highland Drake (MountID: 1563)
		--   Highland Drake (MountID: 1771)
		--   Swift Spectral Drake (MountID: 1607)
	},
	["character/companionnetherwingdrake/companionnetherwingdrake.m2"] = {
		familyName = "Grotto Netherwing Drake",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grotto Netherwing Drake (MountID: 1744)
		--   Grotto Netherwing Drake (MountID: 1953)
	},
	["character/companionprotodragon/companionprotodragon.m2"] = {
		familyName = "Renewed Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Renewed Proto-Drake (MountID: 1589)
		--   Renewed Proto-Drake (MountID: 1786)
	},
	["character/companionpterrodax/companionpterrodax.m2"] = {
		familyName = "Windborne Velocidrake",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Windborne Velocidrake (MountID: 1590)
		--   Windborne Velocidrake (MountID: 1787)
	},
	["character/companionserpent/companionserpent.m2"] = {
		familyName = "Winding Slitherdrake",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Winding Slitherdrake (MountID: 1588)
		--   Winding Slitherdrake (MountID: 1789)
	},
	["character/companionwyvern/companionwyvern.m2"] = {
		familyName = "Cliffside Wylderdrake",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cliffside Wylderdrake (MountID: 1591)
		--   Cliffside Wylderdrake (MountID: 1788)
	},
	["character/rostrumairship/rostrumairship.m2"] = {
		familyName = "Dirigible",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Delver's Dirigible (MountID: 2144)
		--   Delver's Gob-Trotter (MountID: 2296)
	},
	["character/rostrumfaeriedragon/rostrumfaeriedragon.m2"] = {
		familyName = "Flourishing Whimsydrake",
		superGroup = "Fey Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Flourishing Whimsydrake (MountID: 1830)
		--   Flourishing Whimsydrake (MountID: 1954)
	},
	["character/rostrumstormgryphon/rostrumstormgryphon.m2"] = {
		familyName = "Algarian Stormrider",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Algarian Stormrider (MountID: 1792)
	},
	["creature/30thbatmount/30thbatmount.m2"] = {
		familyName = "Chaos-Forged Dreadwing",
		superGroup = "Bats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chaos-Forged Dreadwing (MountID: 2307)
	},
	["creature/30thgryphonmount/30thgryphonmount.m2"] = {
		familyName = "Chaos-Forged Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chaos-Forged Gryphon (MountID: 2304)
	},
	["creature/30thhippogryphmount/30thhippogryphmount.m2"] = {
		familyName = "Chaos-Forged Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chaos-Forged Hippogryph (MountID: 2305)
	},
	["creature/30thwyvernmount/30thwyvernmount.m2"] = {
		familyName = "Chaos-Forged Wind Rider",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chaos-Forged Wind Rider (MountID: 2308)
	},
	["creature/aetherserpentmount/aetherserpentmount.m2"] = {
		familyName = "Ensorcelled Everwyrm",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ensorcelled Everwyrm (MountID: 1289)
	},
	["creature/alliancechopper/alliancechopper.m2"] = {
		familyName = "Champion's Treadblade",
		superGroup = "Choppers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Champion's Treadblade (MountID: 652)
	},
	["creature/alliancepvpmount/alliancepvpmount.m2"] = {
		familyName = "War Steed (PVP)",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Prestigious War Steed (MountID: 775)
		--   Vicious War Steed (MountID: 422)
	},
	["creature/allianceshipmount/allianceshipmount.m2"] = {
		familyName = "Stormwind Skychaser",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Stormwind Skychaser (MountID: 959)
	},
	["creature/alliancewolfmount/alliancewolfmount.m2"] = {
		familyName = "Ironclad Frostclaw",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ironclad Frostclaw (MountID: 1246)
	},
	["creature/alliancewolfmount2/alliancewolfmount2.m2"] = {
		familyName = "Alliance Wolf Mount",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Kaldorei War Wolf (MountID: 2203)
		--   Sentinel War Wolf (MountID: 2201)
		--   [PH] Alliance Wolf Mount (MountID: 2202)
	},
	["creature/alpacamount/alpacamount.m2"] = {
		familyName = "Alpaca",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Elusive Quickhoof (MountID: 1324)
		--   Mollie (MountID: 1250)
		--   Pattie (MountID: 1794)
		--   Springfur Alpaca (MountID: 1329)
	},
	["creature/amalgamofrage/amalgamofrage.m2"] = {
		familyName = "Amalgam of Rage",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Amalgam of Rage (MountID: 1596)
	},
	["creature/ancientmount/ancientmount.m2"] = {
		familyName = "Wandering Ancient",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Wandering Ancient (MountID: 1458)
	},
	["creature/aqirflyingmount/aqirflyingmount.m2"] = {
		familyName = "Drone",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Malevolent Drone (MountID: 1319)
		--   Royal Swarmer (MountID: 1784)
		--   Shadowbarb Drone (MountID: 1320)
		--   Wicked Swarmer (MountID: 1321)
	},
	["creature/arathilynxmount/arathilynxmount.m2"] = {
		familyName = "Lynx",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Dauntless Imperial Lynx (MountID: 2194)
		--   Radiant Imperial Lynx (MountID: 2519)
		--   Vermillion Imperial Lynx (MountID: 2193)
		--   Void-Scarred Lynx (MountID: 2535)
	},
	["creature/ardenwealdstagmount/ardenwealdstagmount.m2"] = {
		familyName = "Runestag",
		superGroup = "Stags",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dreamlight Runestag (MountID: 1302)
		--   Shadeleaf Runestag (MountID: 1354)
		--   Wakener's Runestag (MountID: 1355)
		--   Winterborn Runestag (MountID: 1356)
	},
	["creature/ardenwealdstagmount2/ardenwealdstagmount2.m2"] = {
		familyName = "Enchanted Runestag",
		superGroup = "Stags",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Enchanted Dreamlight Runestag (MountID: 1303)
		--   Enchanted Shadeleaf Runestag (MountID: 1357)
		--   Enchanted Wakener's Runestag (MountID: 1358)
		--   Enchanted Winterborn Runestag (MountID: 1359)
	},
	["creature/argusfelstalkermount/argusfelstalkermount.m2"] = {
		familyName = "Vile Fiend",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Acid Belcher (MountID: 980)
		--   Biletooth Gnasher (MountID: 981)
		--   Crimson Slavermaw (MountID: 979)
		--   Vile Fiend (MountID: 955)
	},
	["creature/argustalbuk/argustalbuk.m2"] = {
		familyName = "Maddened Chaosrunner",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Maddened Chaosrunner (MountID: 970)
	},
	["creature/argustalbukmount/argustalbukmount.m2"] = {
		familyName = "Argus Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amethyst Ruinstrider (MountID: 964)
		--   Beryl Ruinstrider (MountID: 966)
		--   Bleakhoof Ruinstrider (MountID: 986)
		--   Cerulean Ruinstrider (MountID: 965)
		--   Russet Ruinstrider (MountID: 968)
		--   Sable Ruinstrider (MountID: 939)
		--   Umber Ruinstrider (MountID: 967)
	},
	["creature/armoredraptor/armoredraptor.m2"] = {
		familyName = "Armored Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gilded Ravasaur (MountID: 997)
		--   Tomb Stalker (MountID: 1040)
	},
	["creature/automatonfliermount/automatonfliermount.m2"] = {
		familyName = "Aquilon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ascendant's Aquilon (MountID: 1494)
		--   Battle-Hardened Aquilon (MountID: 1436)
		--   Elysian Aquilon (MountID: 1492)
		--   Forsworn Aquilon (MountID: 1493)
	},
	["creature/automatonlionmount/automatonlionmount.m2"] = {
		familyName = "Phalynx",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Phalynx of Courage (MountID: 1396)
		--   Phalynx of Humility (MountID: 1395)
		--   Phalynx of Loyalty (MountID: 1394)
		--   Phalynx of Purity (MountID: 1398)
	},
	["creature/automatonlionmount2/automatonlionmount2.m2"] = {
		familyName = "Eternal Phalynx",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Eternal Phalynx of Courage (MountID: 1400)
		--   Eternal Phalynx of Humility (MountID: 1402)
		--   Eternal Phalynx of Loyalty (MountID: 1401)
		--   Eternal Phalynx of Purity (MountID: 1399)
	},
	["creature/basiliskmount/basiliskmount.m2"] = {
		familyName = "Brawler's Burly Basilisk",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brawler's Burly Basilisk (MountID: 878)
	},
	["creature/bat/batmount.m2"] = {
		familyName = "Bat",
		superGroup = "Bats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodthirsty Dreadwing (MountID: 1210)
		--   Witherbark Direwing (MountID: 1185)
	},
	["creature/bat/epicbatmount.m2"] = {
		familyName = "Armored Bat",
		superGroup = "Bats",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Bloodwing (MountID: 544)
		--   Bloodgorged Hunter (MountID: 1211)
	},
	["creature/bear2/bear2.m2"] = {
		familyName = "Blackpaw",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blackpaw (MountID: 1199)
	},
	["creature/bearmount/bearmount.m2"] = {
		familyName = "Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amani Battle Bear (MountID: 419)
		--   Amani Hunting Bear (MountID: 2225)
		--   Amani War Bear (MountID: 199)
	},
	["creature/bearmountalt/bearmountalt.m2"] = {
		familyName = "Big Battle Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Big Battle Bear (MountID: 230)
	},
	["creature/bearmountalt/bearmountalt_darkmoonfaire.m2"] = {
		familyName = "Darkmoon Dancing Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Darkmoon Dancing Bear (MountID: 434)
	},
	["creature/bearmountblizzard/bearmountblizzard.m2"] = {
		familyName = "Snowstorm",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Snowstorm (MountID: 1424)
	},
	["creature/bearmountblizzard2/bearmountblizzard2.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Harmonious Salutations Bear (MountID: 2262)
	},
	["creature/bearmountutility/bearmountutility.m2"] = {
		familyName = "Grizzly Hills Packmaster",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Grizzly Hills Packmaster (MountID: 2237)
	},
	["creature/beemount/beemount.m2"] = {
		familyName = "Honeyback",
		superGroup = "Bees",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Honeyback Harvester (MountID: 1013)
		--   Honeyback Hivemother (MountID: 1277)
	},
	["creature/beetlemount/beetlemount.m2"] = {
		familyName = "Telix",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Telix the Stormhorn (MountID: 1662)
	},
	["creature/blizzardphoenixmount/blizzardphoenixmount.m2"] = {
		familyName = "Skyblazer",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Coldflame Tempest (MountID: 2261)
	},
	["creature/bloodtickmount/bloodtickmount.m2"] = {
		familyName = "Bloodswarmer",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Expedition Bloodswarmer (MountID: 1061)
		--   Leaping Veinseeker (MountID: 956)
	},
	["creature/bloodtrollfemalebeast_mount/bloodtrollbeast_mount.m2"] = {
		familyName = "Crawg",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodgorged Crawg (MountID: 963)
		--   Underrot Crawg (MountID: 1053)
	},
	["creature/bookmount/bookmount.m2"] = {
		familyName = "Soaring Spelltome",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Soaring Spelltome (MountID: 1532)
	},
	["creature/brokermount/brokermount.m2"] = {
		familyName = "Gearglider",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cartel Master's Gearglider (MountID: 1481)
		--   Tazavesh Gearglider (MountID: 1446)
	},
	["creature/brontosaurusmount/brontosaurusmount.m2"] = {
		familyName = "Mighty Caravan Brutosaur",
		superGroup = "Brutosaurs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mighty Caravan Brutosaur (MountID: 1039)
	},
	["creature/brontosaurusmountspecial/brontosaurusmountspecial.m2"] = {
		familyName = "Trader's Gilded Brutosaur",
		superGroup = "Brutosaurs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Trader's Gilded Brutosaur (MountID: 2265)
	},
	["creature/broommount2/broommount2.m2"] = {
		familyName = "Eve's Ghastly Rider",
		superGroup = "Sweepers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Eve's Ghastly Rider (MountID: 1799)
	},
	["creature/butterflymount/butterflymount.m2"] = {
		familyName = "Butterfly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Midnight Butterfly (MountID: 2494)
		--   Pearlescent Butterfly (MountID: 2489)
		--   Ruby Butterfly (MountID: 2491)
		--   Spring Butterfly (MountID: 2492)
	},
	["creature/camel/camelmount.m2"] = {
		familyName = "Camel",
		superGroup = "Camels",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brown Riding Camel (MountID: 398)
		--   Grey Riding Camel (MountID: 400)
		--   Tan Riding Camel (MountID: 399)
		--   White Riding Camel (MountID: 432)
	},
	["creature/camelmount2/camelmount2.m2"] = {
		familyName = "Explorer's Dunetrekker",
		superGroup = "Camels",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Explorer's Dunetrekker (MountID: 1288)
	},
	["creature/catmount/catmount.m2"] = {
		familyName = "Sunwarmed Furline",
		superGroup = "Furlines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Sunwarmed Furline (MountID: 1330)
	},
	["creature/catmountslime/catmountslime.m2"] = {
		familyName = "Jigglesworth Sr.",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Jigglesworth Sr. (MountID: 1576)
	},
	["creature/caveborerwormmount/caveborerwormmount.m2"] = {
		familyName = "Ferocious Jawcrawler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ferocious Jawcrawler (MountID: 2184)
	},
	["creature/celestialcatmount/celestialcatmount.m2"] = {
		familyName = "Startouched Furline",
		superGroup = "Furlines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Startouched Furline (MountID: 2235)
	},
	["creature/celestialhorse/celestialhorse.m2"] = {
		familyName = "Celestial Steed",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Celestial Steed (MountID: 376)
	},
	["creature/celestialserpent/celestialserpentmount.m2"] = {
		familyName = "Astral Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Astral Cloud Serpent (MountID: 478)
		--   Astral Emperor's Serpent (MountID: 2143)
		--   Shaohao's Sage Serpent (MountID: 2582)
	},
	["creature/chessmount/chessmount.m2"] = {
		familyName = "Grandmaster's Board",
		superGroup = "Boards",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grandmaster's Deep Board (MountID: 2576)
		--   Grandmaster's Prophetic Board (MountID: 2575)
		--   Grandmaster's Royal Board (MountID: 2577)
		--   Grandmaster's Smokey Board (MountID: 2578)
	},
	["creature/chickenmount/chickenmount.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Magic Rooster (MountID: 328)
		--   Magic Rooster (MountID: 333)
	},
	["creature/chickenmount/chickenmount15.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Magic Rooster (MountID: 334)
	},
	["creature/chickenmount/chickenmount35.m2"] = {
		familyName = "Magic Rooster",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Magic Rooster (MountID: 335)
	},
	["creature/chimera2/chromaticchimera.m2"] = {
		familyName = "Chimera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Soaring Skyterror (MountID: 772)
		--   Swift Spectral Rylak (MountID: 776)
	},
	["creature/chimera2/ironchimera.m2"] = {
		familyName = "Armored Chimera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Iron Skyreaver (MountID: 571)
		--   Nightfall Skyreaver (MountID: 2470)
	},
	["creature/chimera3mount/chimera3mount.m2"] = {
		familyName = "Ashenvale Chimaera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ashenvale Chimaera (MountID: 1200)
	},
	["creature/chimerafiremount/chimerafiremount.m2"] = {
		familyName = "Cormaera",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Coldflame Cormaera (MountID: 2524)
		--   Felborn Cormaera (MountID: 2526)
		--   Lavaborn Cormaera (MountID: 2528)
		--   Molten Cormaera (MountID: 2527)
	},
	["creature/chinabearmount/chinabearmount.m2"] = {
		familyName = "Harmonious Salutations Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
	},
	["creature/clefthoofdraenor/clefthoofdraenormount.m2"] = {
		familyName = "Clefthoof",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ancestral Clefthoof (MountID: 1785)
		--   Bloodhoof Bull (MountID: 612)
		--   Trained Icehoof (MountID: 609)
		--   Tundra Icehoof (MountID: 611)
		--   Witherhide Cliffstomper (MountID: 608)
	},
	["creature/clockworkhorse/clockworkhorse.m2"] = {
		familyName = "Warforged Nightmare",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Warforged Nightmare (MountID: 593)
	},
	["creature/cloudmount/cloudmount.m2"] = {
		familyName = "Cloud",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Golden Discus (MountID: 2060)
		--   Mogu Hazeblazer (MountID: 2063)
		--   Red Flying Cloud (MountID: 509)
		--   Sky Surfer (MountID: 2064)
	},
	["creature/cockatrice/cockatriceelite.m2"] = {
		familyName = "Armored Hawkstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Silvermoon Hawkstrider (MountID: 302)
		--   Sunreaver Hawkstrider (MountID: 332)
		--   Swift Green Hawkstrider (MountID: 160)
		--   Swift Pink Hawkstrider (MountID: 146)
		--   Swift Purple Hawkstrider (MountID: 161)
		--   Swift Red Hawkstrider (MountID: 320)
		--   Swift Warstrider (MountID: 162)
		--   Swift White Hawkstrider (MountID: 213)
	},
	["creature/cockatrice/cockatricemount.m2"] = {
		familyName = "Hawkstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Hawkstrider (MountID: 159)
		--   Blue Hawkstrider (MountID: 158)
		--   Elusive Emerald Hawkstrider (MountID: 1600)
		--   Ivory Hawkstrider (MountID: 877)
		--   Purple Hawkstrider (MountID: 157)
		--   Red Hawkstrider (MountID: 152)
	},
	["creature/compy/compy.m2"] = {
		familyName = "Jani's Trashpile",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Jani's Trashpile (MountID: 2339)
	},
	["creature/corehound2/corehoundmount.m2"] = {
		familyName = "Core Hound",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Core Hound (MountID: 606)
		--   Steelbound Devourer (MountID: 797)
		--   Sulfur Hound (MountID: 1781)
	},
	["creature/crabmount/crabmount.m2"] = {
		familyName = "Crawler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crusty Crawler (MountID: 1574)
		--   Snapback Scuttler (MountID: 1238)
	},
	["creature/crane/cranemount.m2"] = {
		familyName = "Crane",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azure Riding Crane (MountID: 479)
		--   Gilded Riding Crane (MountID: 2072)
		--   Golden Riding Crane (MountID: 480)
		--   Jungle Riding Crane (MountID: 482)
		--   Luxurious Riding Crane (MountID: 2076)
		--   Pale Riding Crane (MountID: 2073)
		--   Regal Riding Crane (MountID: 481)
		--   Rose Riding Crane (MountID: 2074)
		--   Silver Riding Crane (MountID: 2075)
		--   Tropical Riding Crane (MountID: 2077)
	},
	["creature/crocoliskmount/crocoliskmount.m2"] = {
		familyName = "Bruce",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bruce (MountID: 1220)
	},
	["creature/crystalmech/crystalmech.m2"] = {
		familyName = "Diamond Mechsuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Diamond Mechsuit (MountID: 2244)
	},
	["creature/darkhoundmount/darkhoundmount.m2"] = {
		familyName = "Grimhowl",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grimhowl (MountID: 1597)
	},
	["creature/darkhoundmount_draka/darkhoundmount_draka.m2"] = {
		familyName = "Darkhound",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Battle-Bound Warhound (MountID: 1437)
		--   Undying Darkhound (MountID: 1477)
		--   Warstitched Darkhound (MountID: 1422)
	},
	["creature/darkirondwarfcorehound/darkirondwarfcorehound.m2"] = {
		familyName = "Dark Iron Core Hound",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Dark Iron Core Hound (MountID: 1048)
	},
	["creature/darkmoonhorsemount/darkmoonhorsemount.m2"] = {
		familyName = "Darkmoon Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Lively Darkmoon Charger (MountID: 2482)
		--   Midnight Darkmoon Charger (MountID: 2481)
		--   Snowy Darkmoon Charger (MountID: 2484)
		--   Violet Darkmoon Charger (MountID: 2483)
	},
	["creature/darkphoenix/darkphoenixmount.m2"] = {
		familyName = "Dark Phoenix",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dark Phoenix (MountID: 401)
	},
	["creature/deathelementalmount/deathelementalmount.m2"] = {
		familyName = "Deathwalker",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Restoration Deathwalker (MountID: 1405)
		--   Sintouched Deathwalker (MountID: 1419)
		--   Soultwisted Deathwalker (MountID: 1520)
		--   Wastewarped Deathwalker (MountID: 1544)
	},
	["creature/deathknightmount/deathknightmount.m2"] = {
		familyName = "Deathcharger",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Acherus Deathcharger (MountID: 221)
		--   Crimson Deathcharger (MountID: 366)
	},
	["creature/deathwargmount/deathwargmount.m2"] = {
		familyName = "Gargon",
		superGroup = "Gargons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crypt Gargon (MountID: 1385)
		--   Hopecrusher Gargon (MountID: 1298)
		--   Inquisition Gargon (MountID: 1382)
		--   Sinfall Gargon (MountID: 1384)
	},
	["creature/deathwargmount2/deathwargmount2.m2"] = {
		familyName = "Armored Gargon",
		superGroup = "Gargons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Battle Gargon Silessa (MountID: 1389)
		--   Battle Gargon Vrednic (MountID: 1299)
		--   Desire's Battle Gargon (MountID: 1387)
		--   Gravestone Battle Gargon (MountID: 1388)
	},
	["creature/decomposermount/decomposermount.m2"] = {
		familyName = "Gorm",
		superGroup = "Gorms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Darkwarren Hardshell (MountID: 1305)
		--   Pale Acidmaw (MountID: 1392)
		--   Spinemaw Gladechewer (MountID: 1362)
		--   Umbral Scythehorn (MountID: 1420)
		--   Wild Hunt Legsplitter (MountID: 1476)
	},
	["creature/devourermediummount/devourermediummount.m2"] = {
		familyName = "Gorger",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Loyal Gorger (MountID: 1391)
		--   Voracious Gorger (MountID: 1443)
	},
	["creature/devourersmallmount/devourersmallmount.m2"] = {
		familyName = "Devourer",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chittering Animite (MountID: 1309)
		--   Endmire Flyer (MountID: 1379)
	},
	["creature/devourerswarmermount/devourerswarmermount.m2"] = {
		familyName = "Devouring Mauler",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Rampaging Mauler (MountID: 1514)
		--   Tamed Mauler (MountID: 1454)
	},
	["creature/dhmount/dhmount.m2"] = {
		familyName = "Felsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Felsaber (MountID: 780)
	},
	["creature/dhmount2/dhmount2.m2"] = {
		familyName = "Slayer's Felbroken Shrieker",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Slayer's Felbroken Shrieker (MountID: 868)
	},
	["creature/direwolf/pvpridingdirewolf.m2"] = {
		familyName = "Armored Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Wolf (MountID: 82)
		--   Frostwolf Howler (MountID: 108)
		--   Orgrimmar Wolf (MountID: 300)
		--   Swift Brown Wolf (MountID: 104)
		--   Swift Burgundy Wolf (MountID: 327)
		--   Swift Gray Wolf (MountID: 106)
		--   Swift Horde Wolf (MountID: 342)
		--   Swift Timber Wolf (MountID: 105)
		--   White War Wolf (MountID: 1776)
	},
	["creature/direwolf/ridingdirewolf.m2"] = {
		familyName = "Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Arctic Wolf (MountID: 51)
		--   Black Wolf (MountID: 12)
		--   Black Wolf (MountID: 310)
		--   Brown Wolf (MountID: 20)
		--   Dire Wolf (MountID: 19)
		--   Gray Wolf (MountID: 7)
		--   Red Wolf (MountID: 13)
		--   Red Wolf (MountID: 50)
		--   Timber Wolf (MountID: 14)
		--   Winter Wolf (MountID: 15)
	},
	["creature/dkmount/dkmount.m2"] = {
		familyName = "Deathlord's Vilebrood Vanquisher",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Deathlord's Vilebrood Vanquisher (MountID: 866)
	},
	["creature/dogmount/dogmount.m2"] = {
		familyName = "Shu-Zen",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Shu-Zen, the Divine Sentinel (MountID: 1011)
	},
	["creature/dogprimalmount/dogprimalmount.m2"] = {
		familyName = "Spiky Bakar",
		superGroup = "Bakars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brown-Furred Spiky Bakar (MountID: 1824)
	},
	["creature/dogprimalmount2/dogprimalmount2.m2"] = {
		familyName = "Taivan",
		superGroup = "Bakars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Taivan (MountID: 1825)
	},
	["creature/dragon/onyxiamount.m2"] = {
		familyName = "Onyxian Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Onyxian Drake (MountID: 349)
	},
	["creature/dragonchromaticmount/dragonchromaticmount.m2"] = {
		familyName = "Heart of the Aspects",
		superGroup = "Chromatic Dragon",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Heart of the Aspects (MountID: 446)
	},
	["creature/dragonchromaticmount2/dragonchromaticmount2.m2"] = {
		familyName = "Corruption of the Aspects",
		superGroup = "Chromatic Dragon",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Corruption of the Aspects (MountID: 2501)
	},
	["creature/dragondeepholm/dragondeepholmmount.m2"] = {
		familyName = "Stone Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Phosphorescent Stone Drake (MountID: 393)
		--   Sandstone Drake (MountID: 407)
		--   Vitreous Stone Drake (MountID: 397)
		--   Volcanic Stone Drake (MountID: 391)
	},
	["creature/dragonhawk/dragonhawkarmormountalliance.m2"] = {
		familyName = "Armored Blue Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Blue Dragonhawk (MountID: 549)
	},
	["creature/dragonhawk/dragonhawkarmormounthorde.m2"] = {
		familyName = "Armored Red Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Red Dragonhawk (MountID: 548)
	},
	["creature/dragonhawk/dragonhawkmount.m2"] = {
		familyName = "Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amani Dragonhawk (MountID: 412)
		--   Blue Dragonhawk (MountID: 291)
		--   Eclipse Dragonhawk (MountID: 778)
		--   Illidari Doomhawk (MountID: 293)
		--   Red Dragonhawk (MountID: 292)
		--   Sunreaver Dragonhawk (MountID: 330)
	},
	["creature/dragonhawkmountshadowlands/dragonhawkmountshadowlands.m2"] = {
		familyName = "Vengeance",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vengeance (MountID: 1471)
	},
	["creature/dragonskywall/dragonskywallmount.m2"] = {
		familyName = "Drake of the Wind",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Drake of the East Wind (MountID: 392)
		--   Drake of the Four Winds (MountID: 1314)
		--   Drake of the North Wind (MountID: 395)
		--   Drake of the South Wind (MountID: 396)
		--   Drake of the West Wind (MountID: 394)
	},
	["creature/dragonturtle/ridingdragonturtle.m2"] = {
		familyName = "Dragon Turtle ",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Dragon Turtle (MountID: 492)
		--   Blue Dragon Turtle (MountID: 493)
		--   Brown Dragon Turtle (MountID: 494)
		--   Green Dragon Turtle (MountID: 452)
		--   Purple Dragon Turtle (MountID: 495)
		--   Red Dragon Turtle (MountID: 496)
	},
	["creature/dragonturtle/ridingdragonturtleepic.m2"] = {
		familyName = "Great Dragon Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Great Black Dragon Turtle (MountID: 498)
		--   Great Blue Dragon Turtle (MountID: 499)
		--   Great Brown Dragon Turtle (MountID: 500)
		--   Great Green Dragon Turtle (MountID: 497)
		--   Great Purple Dragon Turtle (MountID: 501)
		--   Great Red Dragon Turtle (MountID: 453)
	},
	["creature/dragonwhelp3/dragonwhelp3.m2"] = {
		familyName = "Whelpling",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Whelpling (MountID: 1690)
		--   Whelpling (MountID: 1796)
	},
	["creature/drake2mountgladiator/drake2mountgladiator.m2"] = {
		familyName = "Gladiator's Drake (PVP)",
		superGroup = "Highland Drake",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Crimson Gladiator's Drake (MountID: 1660)
		--   Draconic Gladiator's Drake (MountID: 1822)
	},
	["creature/drakemount/armoredtwilightdrake.m2"] = {
		familyName = "Gladiator's Twilight Drake (PVP)",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cataclysmic Gladiator's Twilight Drake (MountID: 467)
		--   Ruthless Gladiator's Twilight Drake (MountID: 428)
		--   Vicious Gladiator's Twilight Drake (MountID: 424)
	},
	["creature/drakemount/drakemount.m2"] = {
		familyName = "Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Albino Drake (MountID: 268)
		--   Azure Drake (MountID: 246)
		--   Black Drake (MountID: 253)
		--   Blue Drake (MountID: 247)
		--   Bronze Drake (MountID: 248)
		--   Broodling of Sinestra (MountID: 2473)
		--   Emerald Drake (MountID: 664)
		--   Experiment 12-B (MountID: 445)
		--   Mottled Drake (MountID: 408)
		--   Red Drake (MountID: 249)
		--   Twilight Avenger (MountID: 1175)
		--   Twilight Drake (MountID: 250)
	},
	["creature/drakemount/feldrakemount.m2"] = {
		familyName = "Feldrake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Feldrake (MountID: 447)
	},
	["creature/drakemountemerald/drakemountemerald.m2"] = {
		familyName = "Tangled Dreamweaver",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Tangled Dreamweaver (MountID: 1556)
	},
	["creature/dreadravenwarbird/dreadravenwarbirdfelmount.m2"] = {
		familyName = "Corrupted Dreadwing",
		superGroup = "Dread ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Corrupted Dreadwing (MountID: 753)
	},
	["creature/dreamowl_firemount/dreamowl_firemount.m2"] = {
		familyName = "Anu'relos",
		superGroup = "Owls",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Anu'relos, Flame's Guidance (MountID: 1818)
	},
	["creature/dreamsabermount/dreamsabermount.m2"] = {
		familyName = "Dreamsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Evening Sun Dreamsaber (MountID: 1816)
		--   Morning Flourish Dreamsaber (MountID: 1817)
		--   Shadow Dusk Dreamsaber (MountID: 1814)
		--   Winter Night Dreamsaber (MountID: 1815)
	},
	["creature/dressedhorse/dressedhorse.m2"] = {
		familyName = "Seabraid Stallion",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Seabraid Stallion (MountID: 996)
	},
	["creature/dwarfpaladinram/dwarfpaladinram.m2"] = {
		familyName = "Darkforge Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Darkforge Ram (MountID: 1046)
		--   Darkforge Ram (MountID: 1069)
		--   Dawnforge Ram (MountID: 1047)
		--   Dawnforge Ram (MountID: 1071)
	},
	["creature/dwarvenmechboss/dwarvenmechboss.m2"] = {
		familyName = "Dwarven Mechsuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crowd Pummeler 2-30 (MountID: 2158)
		--   Machine Defense Unit 1-11 (MountID: 2159)
		--   Stonevault Mechsuit (MountID: 2119)
	},
	["creature/eagle2wind/eagle2wind.m2"] = {
		familyName = "Divine Kiss of Ohn'ahra",
		superGroup = "Ohunas",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Divine Kiss of Ohn'ahra (MountID: 1545)
	},
	["creature/eagle2windmount/eagle2windmount.m2"] = {
		familyName = "Ohuna",
		superGroup = "Ohunas",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bestowed Ohuna Spotter (MountID: 1669)
		--   Duskwing Ohuna (MountID: 1671)
		--   Zenet Hatchling (MountID: 1672)
	},
	["creature/earthenpaladinmount/earthenpaladinmount.m2"] = {
		familyName = "Earthen Ordinant's Ramolith",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Earthen Ordinant's Ramolith (MountID: 2233)
	},
	["creature/electriceelviciousmount/electriceelviciousmount.m2"] = {
		familyName = "Vicious Electro Eel (PVP)",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Electro Eel (MountID: 2299)
		--   Vicious Electro Eel (MountID: 2300)
	},
	["creature/elekk/elekkdraenormount.m2"] = {
		familyName = "Elekk Draenor",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Beastlord's Irontusk (MountID: 1242)
		--   Dusty Rockhide (MountID: 617)
		--   Mottled Meadowstomper (MountID: 614)
		--   Shadowhide Pearltusk (MountID: 616)
		--   Trained Meadowstomper (MountID: 615)
	},
	["creature/elitegryphon/elitegryphon.m2"] = {
		familyName = "Grand Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grand Gryphon (MountID: 528)
		--   Ravenous Black Gryphon (MountID: 1777)
		--   Void-Scarred Gryphon (MountID: 2496)
	},
	["creature/elitegryphon/elitegryphonarmored.m2"] = {
		familyName = "Grand Armored Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dusky Waycrest Gryphon (MountID: 1062)
		--   Grand Armored Gryphon (MountID: 526)
		--   Harbor Gryphon (MountID: 1773)
		--   Proudmoore Sea Scout (MountID: 1064)
		--   Stormsong Coastwatcher (MountID: 1063)
		--   Swift Spectral Armored Gryphon (MountID: 1271)
	},
	["creature/elitehippogryph/elitehippogryph.m2"] = {
		familyName = "Emerald Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Emerald Hippogryph (MountID: 568)
	},
	["creature/elitewyvern/elitewyvern.m2"] = {
		familyName = "Grand Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grand Wyvern (MountID: 529)
		--   Void-Scarred Windrider (MountID: 2499)
	},
	["creature/elitewyvern/elitewyvernarmored.m2"] = {
		familyName = "Grand Armored Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grand Armored Wyvern (MountID: 527)
	},
	["creature/emeralddreamstagmount/emeralddreamstagmount.m2"] = {
		familyName = "Dreamstag",
		superGroup = "Stags",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Blossoming Dreamstag (MountID: 1808)
		--   Lunar Dreamstag (MountID: 1811)
		--   Rekindled Dreamstag (MountID: 1810)
		--   Stargrazer (MountID: 1839)
		--   Suntouched Dreamstag (MountID: 1809)
	},
	["creature/encrypted05/encrypted05.m2"] = {
		familyName = "Meat Wagon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Meat Wagon (MountID: 1193)
	},
	["creature/encrypted06/encrypted06.m2"] = {
		familyName = "Hogrus",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Hogrus, Swine of Good Fortune (MountID: 1221)
	},
	["creature/encrypted08/encrypted08.m2"] = {
		familyName = "Sylverian Dreamer",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Sylverian Dreamer (MountID: 1223)
	},
	["creature/encrypted09/encrypted09.m2"] = {
		familyName = "Vulpine Familiar",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vulpine Familiar (MountID: 1222)
	},
	["creature/encrypted13/encrypted13.m2"] = {
		familyName = "World Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Azure Worldchiller (MountID: 1798)
		--   Obsidian Worldbreaker (MountID: 1240)
	},
	["creature/encrypted16/encrypted16.m2"] = {
		familyName = "Steamscale Incinerator",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Steamscale Incinerator (MountID: 1346)
	},
	["creature/encrypted21/encrypted21.m2"] = {
		familyName = "Alabaster Stormtalon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Alabaster Stormtalon (MountID: 1266)
	},
	["creature/encrypted22/encrypted22.m2"] = {
		familyName = "Alabaster Thunderwing",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Alabaster Thunderwing (MountID: 1267)
	},
	["creature/explorergyrocopter/explorergyrocopter.m2"] = {
		familyName = "Explorer's Jungle Hopper",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Explorer's Jungle Hopper (MountID: 1287)
	},
	["creature/eyeballjellyfishmount/eyeballjellyfishmount.m2"] = {
		familyName = "Ny'alotha Allseer",
		superGroup = "Jellyfishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ny'alotha Allseer (MountID: 1293)
	},
	["creature/facelessmount/facelessmount2.m2"] = {
		familyName = "Jelly",
		superGroup = "Jellyfishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fathom Dweller (MountID: 838)
		--   Pond Nettle (MountID: 982)
		--   Surf Jelly (MountID: 1169)
	},
	["creature/faeriedragonmount/faeriedragonmount.m2"] = {
		familyName = "Enchanted Fey Dragon",
		superGroup = "Fey Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Enchanted Fey Dragon (MountID: 551)
	},
	["creature/falcosauros/falcosaurosmount.m2"] = {
		familyName = "Falcosaur",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brilliant Direbeak (MountID: 794)
		--   Predatory Bloodgazer (MountID: 793)
		--   Snowfeather Hunter (MountID: 795)
		--   Viridian Sharptalon (MountID: 796)
	},
	["creature/felbatgladiatormount/felbatgladiatormount.m2"] = {
		familyName = "Gladiator's Fel Bat (PVP)",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Forged Gladiator's Fel Bat (MountID: 2218)
		--   Prized Gladiator's Fel Bat (MountID: 2298)
	},
	["creature/felbatmountforsaken/felbatmountforsaken.m2"] = {
		familyName = "Fel Bat",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Undercity Plaguebat (MountID: 1049)
	},
	["creature/felhippogryph/felhippogryphmount.m2"] = {
		familyName = "Corrupted Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Corrupted Hippogryph (MountID: 433)
	},
	["creature/felhorse/felhorseepic.m2"] = {
		familyName = "Fiery Warhorse",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fiery Warhorse (MountID: 168)
	},
	["creature/felhound3_fire_mount/felhound3_fire_mount.m2"] = {
		familyName = "Antoran Charhound",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Antoran Charhound (MountID: 971)
	},
	["creature/felhound3_shadow_mount/felhound3_shadow_mount.m2"] = {
		familyName = "Antoran Gloomhound",
		superGroup = "Antoran Felhounds",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Antoran Gloomhound (MountID: 972)
	},
	["creature/fellessergronn/fellessergronnmount.m2"] = {
		familyName = "Felblood Gronnling (PVP)",
		superGroup = "Gronnlings",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Primal Gladiator's Felblood Gronnling (MountID: 759)
		--   Warmongering Gladiator's Felblood Gronnling (MountID: 761)
		--   Wild Gladiator's Felblood Gronnling (MountID: 760)
	},
	["creature/felreavermount/felreavermount.m2"] = {
		familyName = "Felsteel Annihilator",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Felsteel Annihilator (MountID: 751)
	},
	["creature/felstalkermount/felstalkermount.m2"] = {
		familyName = "Felstalker",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Illidari Felstalker (MountID: 763)
	},
	["creature/firebeemount/firebeemount.m2"] = {
		familyName = "Cinderbee",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Raging Cinderbee (MountID: 2167)
		--   Smoldering Cinderbee (MountID: 2148)
		--   Soaring Meaderbee (MountID: 2165)
	},
	["creature/firecatmount/firecatmount.m2"] = {
		familyName = "Primal Flamesaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Primal Flamesaber (MountID: 896)
	},
	["creature/firefly2mount/firefly2mount.m2"] = {
		familyName = "Glowmite",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cyan Glowmite (MountID: 2162)
	},
	["creature/firehawk/firehawk_mount.m2"] = {
		familyName = "Fire Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Corrupted Fire Hawk (MountID: 417)
		--   Felfire Hawk (MountID: 416)
		--   Pureblood Fire Hawk (MountID: 415)
	},
	["creature/firehawk2_mount/firehawk2_mount.m2"] = {
		familyName = "Blazing Royal Fire Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Blazing Royal Fire Hawk (MountID: 2478)
	},
	["creature/fireravengodmount/fireravengodmount.m2"] = {
		familyName = "Elemental Raven",
		superGroup = "Ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Flametalon of Alysrazor (MountID: 425)
		--   Frenzied Feltalon (MountID: 1191)
		--   Voidtalon of the Dark Star (MountID: 682)
	},
	["creature/fishmount/fishmount.m2"] = {
		familyName = "Brinedeep Bottom-Feeder",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brinedeep Bottom-Feeder (MountID: 800)
	},
	["creature/flyingcarpet3/flyingcarpet3.m2"] = {
		familyName = "Noble Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Noble Flying Carpet (MountID: 2023)
	},
	["creature/flyingcarpetmount/flyingcarpetmount.m2"] = {
		familyName = "Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Creeping Carpet (MountID: 603)
		--   Enchanted Spellweave Carpet (MountID: 2317)
		--   Flying Carpet (MountID: 285)
		--   Frosty Flying Carpet (MountID: 375)
		--   Magnificent Flying Carpet (MountID: 279)
	},
	["creature/flyingcarpetmount2/flyingcarpetmount2.m2"] = {
		familyName = "Leywoven Flying Carpet",
		superGroup = "Flying Carpets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Leywoven Flying Carpet (MountID: 905)
	},
	["creature/flyingnerubian2mount/flyingnerubian2mount.m2"] = {
		familyName = "Swarmite",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Aquamarine Swarmite (MountID: 2177)
		--   Nesting Swarmite (MountID: 2178)
		--   Shadowed Swarmite (MountID: 2180)
		--   Swarmite Skyhunter (MountID: 2181)
	},
	["creature/flyingpanther/flyingpanther.m2"] = {
		familyName = "Obsidian Nightwing",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Obsidian Nightwing (MountID: 455)
	},
	["creature/flymaldraxxus/flymaldraxxus.m2"] = {
		familyName = "Corpsefly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Battlefield Swarmer (MountID: 1497)
		--   Lord of the Corpseflies (MountID: 1449)
		--   Maldraxxian Corpsefly (MountID: 1495)
		--   Regal Corpsefly (MountID: 1496)
	},
	["creature/forsakenhorsemount/forsakenhorsemount.m2"] = {
		familyName = "Banshee's Charger",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Banshee's Chilling Charger (MountID: 2572)
		--   Banshee's Sickening Charger (MountID: 2581)
		--   Forsaken's Grotesque Charger (MountID: 2579)
		--   Wailing Banshee's Charger (MountID: 2580)
	},
	["creature/fox2/fox2.m2"] = {
		familyName = "Glimmerfur",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crimson Glimmerfur (MountID: 1841)
		--   Wild Glimmerfur Prowler (MountID: 1393)
	},
	["creature/foxmount/foxmount.m2"] = {
		familyName = "Fox",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gilnean Prowler (MountID: 1949)
		--   Llothien Prowler (MountID: 656)
	},
	["creature/foxwyvernmount/foxwyvernmount.m2"] = {
		familyName = "Slyvern",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Liberated Slyvern (MountID: 1553)
		--   Temperamental Skyclaw (MountID: 1674)
	},
	["creature/frostbroodprotowyrm/frostbroodprotowyrm.m2"] = {
		familyName = "Frostbrood Proto-Wyrm",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Frostbrood Proto-Wyrm (MountID: 1679)
	},
	["creature/frostsabre/pvpridingfrostsabre.m2"] = {
		familyName = "Armored Saber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Tiger (MountID: 81)
		--   Darnassian Nightsaber (MountID: 297)
		--   Swift Frostsaber (MountID: 87)
		--   Swift Mistsaber (MountID: 85)
		--   Swift Moonsaber (MountID: 319)
		--   Swift Stormsaber (MountID: 107)
		--   Swift Zulian Tiger (MountID: 111)
	},
	["creature/frostsabre/ridingfrostsabre.m2"] = {
		familyName = "Saber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ancient Frostsaber (MountID: 46)
		--   Black Nightsaber (MountID: 45)
		--   Spotted Frostsaber (MountID: 31)
		--   Striped Dawnsaber (MountID: 337)
		--   Striped Frostsaber (MountID: 26)
		--   Striped Nightsaber (MountID: 34)
		--   Swift Zulian Panther (MountID: 411)
		--   Tiger (MountID: 32)
		--   Winterspring Frostsaber (MountID: 55)
	},
	["creature/frostwolfhowler/frostwolfhowler.m2"] = {
		familyName = "Frostwolf Snarler",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Frostwolf Snarler (MountID: 1285)
	},
	["creature/gallywixmechmount/gallywixmechmount.m2"] = {
		familyName = "The Big G",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   The Big G (MountID: 2487)
	},
	["creature/gargoylebrute2mount/gargoylebrute2mount.m2"] = {
		familyName = "Gravewing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mastercraft Gravewing (MountID: 803)
		--   Obsidian Gravewing (MountID: 1489)
		--   Pale Gravewing (MountID: 1491)
		--   Sinfall Gravewing (MountID: 1490)
	},
	["creature/ghostlycharger/ghostlycharger.m2"] = {
		familyName = "Ghastly Charger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ghastly Charger (MountID: 532)
	},
	["creature/ghostlymoose/ghostlymoosemount.m2"] = {
		familyName = "Spirit of Eche'ro",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spirit of Eche'ro (MountID: 779)
	},
	["creature/giantbeastmount/giantbeastmount.m2"] = {
		familyName = "Tauralus",
		superGroup = "Tauraluses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bonehoof Tauralus (MountID: 1366)
		--   Chosen Tauralus (MountID: 1367)
		--   Plaguerot Tauralus (MountID: 1365)
		--   War-Bred Tauralus (MountID: 1364)
	},
	["creature/giantbeastmount2/giantbeastmount2.m2"] = {
		familyName = "Armored Tauralus",
		superGroup = "Tauraluses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Bonehoof Tauralus (MountID: 1370)
		--   Armored Chosen Tauralus (MountID: 1371)
		--   Armored Plaguerot Tauralus (MountID: 1369)
		--   Armored War-Bred Tauralus (MountID: 1368)
	},
	["creature/giantboar/giantboararmoredmount.m2"] = {
		familyName = "Armored Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Frostboar (MountID: 621)
		--   Armored Razorback (MountID: 622)
		--   Blacksteel Battleboar (MountID: 619)
		--   Bristling Hellboar (MountID: 765)
		--   Deathtusk Felboar (MountID: 768)
		--   Frostplains Battleboar (MountID: 623)
		--   Rocktusk Battleboar (MountID: 620)
	},
	["creature/giantboar/giantboarmount.m2"] = {
		familyName = "Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Domesticated Razorback (MountID: 625)
		--   Giant Coldsnout (MountID: 626)
		--   Great Greytusk (MountID: 627)
		--   Trained Rocktusk (MountID: 628)
		--   Unarmored Deathtusk Felboar (MountID: 2600)
		--   Wild Goretusk (MountID: 624)
	},
	["creature/giantvampirebatmount/giantvampirebatmount.m2"] = {
		familyName = "Dredwing",
		superGroup = "Bats",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Harvester's Dredwing (MountID: 1378)
		--   Horrid Dredwing (MountID: 1310)
		--   Rampart Screecher (MountID: 1377)
		--   Silvertip Dredwing (MountID: 1376)
	},
	["creature/goat/goatmount.m2"] = {
		familyName = "Goat",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Riding Goat (MountID: 511)
		--   Brown Riding Goat (MountID: 508)
		--   Little Red Riding Goat (MountID: 2080)
		--   Snowy Riding Goat (MountID: 2078)
		--   Spotted Black Riding Goat (MountID: 2504)
		--   White Riding Goat (MountID: 510)
	},
	["creature/goblinflyingmachine/goblinflyingmachine.m2"] = {
		familyName = "Cartel Aerial Unit",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bilgewater Bombardier (MountID: 2295)
		--   Darkfuse Spy-Eye (MountID: 2293)
		--   Margin Manipulator (MountID: 2292)
		--   Mean Green Flying Machine (MountID: 2294)
		--   Salvaged Goblin Gazillionaire's Flying Machine (MountID: 2291)
	},
	["creature/goblinflyingmachineboss/goblinflyingmachineboss.m2"] = {
		familyName = "Prototype A.S.M.R.",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Prototype A.S.M.R. (MountID: 2507)
	},
	["creature/goblinheadmech/goblinheadmech.m2"] = {
		familyName = "Mecha-Mogul Mk2",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mecha-Mogul Mk2 (MountID: 1028)
	},
	["creature/goblinshreddermech/goblinshreddermech.m2"] = {
		familyName = "Cartel Mechasuit",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Asset Advocator (MountID: 2290)
		--   Blackwater Shredder Deluxe Mk 2 (MountID: 2286)
		--   Darkfuse Demolisher (MountID: 2287)
		--   Personalized Goblin S.C.R.A.P.per (MountID: 2288)
		--   Venture Co-ordinator (MountID: 2289)
		--   Violet Goblin Shredder (MountID: 2303)
	},
	["creature/goblinshreddermechboss/goblinshreddermechboss.m2"] = {
		familyName = "Magnetomech",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Junkmaestro's Magnetomech (MountID: 2313)
	},
	["creature/goblinspidertank/goblinspidertank.m2"] = {
		familyName = "Shreddertank",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crimson Shreddertank (MountID: 2480)
		--   Enterprising Shreddertank (MountID: 2508)
	},
	["creature/goblinsurfboardmount/goblinsurfboardmount.m2"] = {
		familyName = "Surfboard",
		superGroup = "Boards",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bronze Goblin Waveshredder (MountID: 2334)
		--   Kickin' Kezan Waveshredder (MountID: 2145)
		--   Pearlescent Goblin Wave Shredder (MountID: 2152)
		--   Soweezi's Vintage Waveshredder (MountID: 2333)
	},
	["creature/goblintrike/goblintrike01.m2"] = {
		familyName = "Goblin Turbo-Trike",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Goblin Turbo-Trike (MountID: 389)
	},
	["creature/goblintrike/goblintrike02.m2"] = {
		familyName = "Goblin Trike",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Goblin Trike (MountID: 388)
	},
	["creature/gryphon/gryphon_armoredmount.m2"] = {
		familyName = "Armored Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Snowy Gryphon (MountID: 276)
		--   Swift Blue Gryphon (MountID: 132)
		--   Swift Green Gryphon (MountID: 138)
		--   Swift Purple Gryphon (MountID: 139)
		--   Swift Red Gryphon (MountID: 137)
	},
	["creature/gryphon/gryphon_ghost_mount.m2"] = {
		familyName = "Swift Spectral Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Swift Spectral Gryphon (MountID: 238)
	},
	["creature/gryphon/gryphon_mount.m2"] = {
		familyName = "Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ebon Gryphon (MountID: 130)
		--   Golden Gryphon (MountID: 129)
		--   Remembered Golden Gryphon (MountID: 2116)
		--   Snowy Gryphon (MountID: 131)
	},
	["creature/gryphon/gryphon_skeletal_mount.m2"] = {
		familyName = "Winged Steed of the Ebon Blade",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Winged Steed of the Ebon Blade (MountID: 236)
	},
	["creature/gryphon_air_mount/gryphon_air_mount.m2"] = {
		familyName = "Alunira",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Alunira (MountID: 2176)
	},
	["creature/guildcreatures/alliancelionmount/alliancelionmount.m2"] = {
		familyName = "Golden King",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Golden King (MountID: 403)
	},
	["creature/gyrocopter/gyrocopter_01.m2"] = {
		familyName = "Turbo-Charged Flying Machine",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Turbo-Charged Flying Machine (MountID: 204)
	},
	["creature/gyrocopter/gyrocopter_02.m2"] = {
		familyName = "Flying Machine",
		superGroup = "Flying Machines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Flying Machine (MountID: 205)
	},
	["creature/hearthstonemount/hearthstonemount.m2"] = {
		familyName = "Compass Rose",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Compass Rose (MountID: 1959)
	},
	["creature/hedgehogmount/hedgehogmount.m2"] = {
		familyName = "Harvesthog",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Autumn Harvesthog (MountID: 2523)
		--   Spring Harvesthog (MountID: 2520)
		--   Summer Harvesthog (MountID: 2521)
		--   Winter Harvesthog (MountID: 2522)
	},
	["creature/hhmount/hhmount.m2"] = {
		familyName = "Headless Horseman's Mount",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Headless Horseman's Mount (MountID: 219)
	},
	["creature/hippocampus/hippocampus.m2"] = {
		familyName = "Fabious",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fabious (MountID: 1258)
	},
	["creature/hippocampusmount/hippocampusmount.m2"] = {
		familyName = "Tidestallion",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crimson Tidestallion (MountID: 1260)
		--   Inkscale Deepseeker (MountID: 1262)
		--   Silver Tidestallion (MountID: 1259)
	},
	["creature/hippogryph/burnthippogryph.m2"] = {
		familyName = "Blazing Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blazing Hippogryph (MountID: 371)
	},
	["creature/hippogryph2/hippogryph2mount.m2"] = {
		familyName = "Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cloudwing Hippogryph (MountID: 943)
		--   Swift Spectral Hippogryph (MountID: 934)
		--   Val'sharah Hippogryph (MountID: 1521)
	},
	["creature/hippogryph_arcane/hippogryph_arcanemount.m2"] = {
		familyName = "Leyfeather Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Leyfeather Hippogryph (MountID: 846)
	},
	["creature/hippogryphmount/hippogryphmount.m2"] = {
		familyName = "Armored Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Argent Hippogryph (MountID: 305)
		--   Cenarion War Hippogryph (MountID: 203)
		--   Frayfeather Hippogryph (MountID: 2224)
		--   Long-Forgotten Hippogryph (MountID: 802)
		--   Silver Covenant Hippogryph (MountID: 329)
	},
	["creature/hippogryphmountnightelf/hippogryphmountnightelf.m2"] = {
		familyName = "Teldrassil Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Teldrassil Hippogryph (MountID: 1054)
	},
	["creature/hippomount/hippomount.m2"] = {
		familyName = "Riverwallow",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mosshide Riverwallow (MountID: 632)
		--   Mudback Riverbeast (MountID: 631)
		--   Sapphire Riverbeast (MountID: 630)
		--   Trained Riverwallow (MountID: 629)
	},
	["creature/hivemind/hivemind.m2"] = {
		familyName = "The Hivemind",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   The Hivemind (MountID: 1025)
	},
	["creature/hmmoosemount/hmmoosemount.m2"] = {
		familyName = "Highmountain Thunderhoof",
		superGroup = "Elderhorns",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Highmountain Thunderhoof (MountID: 1007)
	},
	["creature/hordechopper/hordechopper.m2"] = {
		familyName = "Warlord's Deathwheel",
		superGroup = "Choppers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Warlord's Deathwheel (MountID: 651)
	},
	["creature/hordehorsemount/hordehorsemount.m2"] = {
		familyName = "Bloodflank Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodflank Charger (MountID: 1245)
	},
	["creature/hordepvpmount/hordepvpmount.m2"] = {
		familyName = "War Wolf (PVP)",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Prestigious War Wolf (MountID: 784)
		--   Vicious War Wolf (MountID: 423)
	},
	["creature/hordescorpionmount/hordescorpionmount.m2"] = {
		familyName = "Scorpion",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amber Scorpion (MountID: 463)
		--   Felcrystal Scorpion (MountID: 1742)
		--   Kor'kron Annihilator (MountID: 409)
	},
	["creature/hordezeppelinmount/hordezeppelinmount.m2"] = {
		familyName = "Orgrimmar Interceptor",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Orgrimmar Interceptor (MountID: 960)
	},
	["creature/horse2/horse2.m2"] = {
		familyName = "Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lucid Nightmare (MountID: 961)
		--   Pureheart Courser (MountID: 1190)
		--   Wild Dreamrunner (MountID: 942)
	},
	["creature/horse2ardenweald/horse2ardenweald.m2"] = {
		familyName = "Ardenweald Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Maelie, the Wanderer (MountID: 1511)
		--   Shimmermist Free Runner (MountID: 2488)
	},
	["creature/horse2ardenwealdmount/horse2ardenwealdmount.m2"] = {
		familyName = "Armored Ardenweald Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Shimmermist Runner (MountID: 1360)
		--   Swift Gloomhoof (MountID: 1306)
	},
	["creature/horse2bastion/horse2bastion.m2"] = {
		familyName = "Bastion Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ascended Skymane (MountID: 1426)
	},
	["creature/horse2bastionmount/horse2bastionmount.m2"] = {
		familyName = "Armored Bastion Courser",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dauntless Duskrunner (MountID: 1413)
		--   Sundancer (MountID: 1307)
	},
	["creature/horse2mount/horse2mount.m2"] = {
		familyName = "Prestigious Courser (PVP)",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Prestigious Azure Courser (MountID: 834)
		--   Prestigious Bronze Courser (MountID: 826)
		--   Prestigious Forest Courser (MountID: 832)
		--   Prestigious Ivory Courser (MountID: 833)
		--   Prestigious Midnight Courser (MountID: 836)
		--   Prestigious Royal Courser (MountID: 831)
	},
	["creature/horse2mountelite/horse2mountelite.m2"] = {
		familyName = "Bloodforged Courser (PVP)",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Prestigious Bloodforged Courser (MountID: 1192)
	},
	["creature/horse3/horse3.m2"] = {
		familyName = "Mountain Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mountain Horse (MountID: 435)
		--   Swift Mountain Horse (MountID: 436)
	},
	["creature/horsekultiran/horsekultiran.m2"] = {
		familyName = "Kul Tiran Charger",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Kul Tiran Charger (MountID: 1198)
	},
	["creature/horsemultisaddle/horsemultisaddle.m2"] = {
		familyName = "Saddled Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Admiralty Stallion (MountID: 1010)
		--   Broken Highland Mustang (MountID: 1173)
		--   Court Sinrunner (MountID: 1421)
		--   Dapple Gray (MountID: 1015)
		--   Goldenmane (MountID: 1019)
		--   Highland Mustang (MountID: 1174)
		--   Lil' Donkey (MountID: 1182)
		--   Sinrunner Blanchy (MountID: 1414)
		--   Smoky Charger (MountID: 1016)
		--   Terrified Pack Mule (MountID: 1018)
		--   Void-Forged Stallion (MountID: 2497)
	},
	["creature/hovercraftmount/hovercraftmount.m2"] = {
		familyName = "Xiwyllag ATV",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Xiwyllag ATV (MountID: 999)
	},
	["creature/hunterkillership/hunterkillership.m2"] = {
		familyName = "Aerial Unit",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Aerial Unit R-21/X (MountID: 1227)
		--   Mimiron's Jumpjets (MountID: 1813)
		--   Rustbolt Resistor (MountID: 1254)
		--   Swift Spectral Magnetocraft (MountID: 1270)
	},
	["creature/huntermount/huntermount.m2"] = {
		familyName = "Huntmaster's Wolfhawk",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Huntmaster's Dire Wolfhawk (MountID: 872)
		--   Huntmaster's Fierce Wolfhawk (MountID: 870)
		--   Huntmaster's Loyal Wolfhawk (MountID: 865)
	},
	["creature/hyena2goblinmount/hyena2goblinmount.m2"] = {
		familyName = "Cartel Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blackwater Bonecrusher (MountID: 2274)
		--   Crimson Armored Growler (MountID: 2272)
		--   Darkfuse Chompactor (MountID: 2276)
		--   Violet Armored Growler (MountID: 2277)
	},
	["creature/hyena2mount/hyena2mount.m2"] = {
		familyName = "Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Alabaster Hyena (MountID: 926)
		--   Dune Scavenger (MountID: 928)
	},
	["creature/inariusmount/inariusmount.m2"] = {
		familyName = "Inarius' Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Inarius' Charger (MountID: 2605)
	},
	["creature/infernalmount/infernalmount.m2"] = {
		familyName = "Infernal",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Coldflame Infernal (MountID: 646)
		--   Felblaze Infernal (MountID: 791)
		--   Flarecore Infernal (MountID: 799)
		--   Frostshard Infernal (MountID: 1167)
		--   Hellfire Infernal (MountID: 633)
	},
	["creature/infinitedragonmount/infinitedragonmount.m2"] = {
		familyName = "Infinite Timereaver",
		superGroup = "Infinite Timereavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Infinite Timereaver (MountID: 781)
	},
	["creature/invisiblestalker/invisiblestalker.m2"] = {
		familyName = "Soar",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Soar (MountID: 1608)
		--   Soar (MountID: 1952)
		--   Soar (MountID: 2115)
	},
	["creature/ironhordeclefthoof/ironhordeclefthoof.m2"] = {
		familyName = "Ironhoof Destroyer",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ironhoof Destroyer (MountID: 613)
	},
	["creature/ironhordeelekk/ironhordeelekk.m2"] = {
		familyName = "Armored Irontusk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Irontusk (MountID: 618)
	},
	["creature/ironhordewolf/ironhordewolf.m2"] = {
		familyName = "Beastlord's Warwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Beastlord's Warwolf (MountID: 1243)
	},
	["creature/ironjuggernaut/ironjuggernautmount.m2"] = {
		familyName = "Juggernaut",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cobalt Juggernaut (MountID: 2085)
		--   Fel Iron Juggernaut (MountID: 2086)
		--   Kor'kron Juggernaut (MountID: 559)
		--   Perfected Juggernaut (MountID: 1782)
	},
	["creature/jailerhoundmount/jailerhoundmount.m2"] = {
		familyName = "Shadehound",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Bound Shadehound (MountID: 1441)
		--   Corridor Creeper (MountID: 1442)
		--   Mawsworn Soulhunter (MountID: 1304)
	},
	["creature/kezancrowdpummeler_gallywix/kezancrowdpummeler_gallywix.m2"] = {
		familyName = "G.M.O.D.",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   G.M.O.D. (MountID: 1217)
	},
	["creature/kirinmount/kirinmount.m2"] = {
		familyName = "Armored Vorquin",
		superGroup = "Vorquins",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Vorquin Leystrider (MountID: 1667)
		--   Guardian Vorquin (MountID: 1664)
		--   Majestic Armored Vorquin (MountID: 1668)
		--   Swift Armored Vorquin (MountID: 1665)
	},
	["creature/kirinmountdracthyr/kirinmountdracthyr.m2"] = {
		familyName = "Vorquin",
		superGroup = "Vorquins",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bronze Vorquin (MountID: 1685)
		--   Crimson Vorquin (MountID: 1683)
		--   Obsidian Vorquin (MountID: 1686)
		--   Sapphire Vorquin (MountID: 1684)
	},
	["creature/kodobeast/kodobeastpvpt2.m2"] = {
		familyName = "Armored Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Kodo (MountID: 76)
		--   Great Brewfest Kodo (MountID: 226)
		--   Great Brown Kodo (MountID: 103)
		--   Great Golden Kodo (MountID: 322)
		--   Great Gray Kodo (MountID: 102)
		--   Great White Kodo (MountID: 101)
		--   Thunder Bluff Kodo (MountID: 301)
	},
	["creature/kodobeast/ridingkodo.m2"] = {
		familyName = "Brewfest Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brewfest Riding Kodo (MountID: 225)
	},
	["creature/kodobeast/ridingkotobeastsunwalker.m2"] = {
		familyName = "Sunwalker Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Sunwalker Kodo (MountID: 350)
	},
	["creature/kodobeast/ridingkotobeastsunwalkerelite.m2"] = {
		familyName = "Great Sunwalker Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Great Sunwalker Kodo (MountID: 351)
		--   Great Sunwalker Kodo (MountID: 823)
	},
	["creature/kodobeast2mount/kodobeast2mount.m2"] = {
		familyName = "Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brown Kodo (MountID: 72)
		--   Frightened Kodo (MountID: 1201)
		--   Gray Kodo (MountID: 71)
		--   Green Kodo (MountID: 73)
		--   Riding Kodo (MountID: 70)
		--   Teal Kodo (MountID: 74)
		--   White Kodo (MountID: 309)
	},
	["creature/kodomount/kodomount.m2"] = {
		familyName = "Armored Siege Kodo",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Armored Siege Kodo (MountID: 1583)
	},
	["creature/korkronelitewolf/korkronelitewolf.m2"] = {
		familyName = "Kor'kron War Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Kor'kron War Wolf (MountID: 558)
	},
	["creature/lavahorse/lavahorse.m2"] = {
		familyName = "Cindermane Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cindermane Charger (MountID: 454)
	},
	["creature/lavaslugmount/lavaslugmount.m2"] = {
		familyName = "Seething Slug",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Seething Slug (MountID: 1623)
	},
	["creature/lavasnailmount/lavasnailmount.m2"] = {
		familyName = "Snailemental",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Gooey Snailemental (MountID: 1627)
		--   Magmashell (MountID: 1469)
		--   Scrappy Worldsnail (MountID: 1629)
		--   Shellack (MountID: 1626)
	},
	["creature/lessergronn/lessergronnmount.m2"] = {
		familyName = "Gronnling",
		superGroup = "Gronnlings",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Coalfist Gronnling (MountID: 762)
		--   Gorestrider Gronnling (MountID: 607)
		--   Sunhide Gronnling (MountID: 655)
	},
	["creature/lightforgedelekk/lightforgedelekk.m2"] = {
		familyName = "Lightforged Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Avenging Felcrusher (MountID: 985)
		--   Blessed Felcrusher (MountID: 984)
		--   Glorious Felcrusher (MountID: 983)
		--   Lightforged Felcrusher (MountID: 1006)
	},
	["creature/lightforgedmechsuit/lightforgedmechsuit.m2"] = {
		familyName = "Lightforged Warframe",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lightforged Warframe (MountID: 932)
	},
	["creature/lightforgedtalbuk/lightforgedtalbuk.m2"] = {
		familyName = "Lightforged Ruinstrider",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lightforged Ruinstrider (MountID: 1567)
		--   Lightforged Ruinstrider (MountID: 1568)
	},
	["creature/lovebroom/lovebroom.m2"] = {
		familyName = "Sweeper",
		superGroup = "Sweepers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Love Witch's Sweeper (MountID: 2328)
		--   Silvermoon Sweeper (MountID: 2329)
		--   Sky Witch's Sweeper (MountID: 2331)
		--   Twilight Witch's Sweeper (MountID: 2330)
	},
	["creature/lovefoxmount/lovefoxmount.m2"] = {
		familyName = "Sky Fox",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fur-endship Fox (MountID: 1956)
		--   Soaring Sky Fox (MountID: 1957)
		--   Twilight Sky Prowler (MountID: 1958)
	},
	["creature/lunardragonmount/lunardragonmount.m2"] = {
		familyName = "Auspicious Arborwyrm",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Auspicious Arborwyrm (MountID: 1795)
	},
	["creature/lunarrocketmount/lunarrocketmount.m2"] = {
		familyName = "Lunar Launcher",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lunar Launcher (MountID: 2327)
	},
	["creature/lunarsnakemount/lunarsnakemount.m2"] = {
		familyName = "Timbered Sky Snake",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Timbered Sky Snake (MountID: 2315)
	},
	["creature/magemount_arcane/magemount_arcane.m2"] = {
		familyName = "Archmage's Prismatic Disc",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Archmage's Prismatic Disc (MountID: 860)
	},
	["creature/magemount_fel/magemount_fel.m2"] = {
		familyName = "Archmage's Felscorned Disc",
		superGroup = "Flying Discs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Archmage's Felscorned Disc (MountID: 2724)
	},
	["creature/magicalfishmount/magicalfishmount.m2"] = {
		familyName = "Wondrous Wavewhisker",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Wondrous Wavewhisker (MountID: 1692)
	},
	["creature/magicalowlbearmount/magicalowlbearmount.m2"] = {
		familyName = "Gleaming Moonbeast",
		superGroup = "Moonbeasts",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gleaming Moonbeast (MountID: 1699)
	},
	["creature/maldraxxusboarmount/maldraxxusboarmount.m2"] = {
		familyName = "Maldraxxus Boar",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Blisterback Bloodtusk (MountID: 1372)
		--   Gorespine (MountID: 1373)
		--   Lurid Bloodtusk (MountID: 1375)
	},
	["creature/maldraxxusflyermount/maldraxxusflyermount.m2"] = {
		familyName = "Flayedwing",
		superGroup = "Skyreavers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Callow Flayedwing (MountID: 1407)
		--   Gruesome Flayedwing (MountID: 1408)
		--   Marrowfang (MountID: 1406)
	},
	["creature/mammoth/mammothmount_1seat.m2"] = {
		familyName = "Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Mammoth (MountID: 254)
		--   Black War Mammoth (MountID: 255)
		--   Ice Mammoth (MountID: 258)
		--   Ice Mammoth (MountID: 259)
		--   Wooly Mammoth (MountID: 256)
		--   Wooly Mammoth (MountID: 257)
	},
	["creature/mammoth/mammothmount_3seat.m2"] = {
		familyName = "Grand Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grand Black War Mammoth (MountID: 286)
		--   Grand Black War Mammoth (MountID: 287)
		--   Grand Caravan Mammoth (MountID: 273)
		--   Grand Caravan Mammoth (MountID: 274)
		--   Grand Ice Mammoth (MountID: 288)
		--   Grand Ice Mammoth (MountID: 289)
		--   Traveler's Tundra Mammoth (MountID: 280)
		--   Traveler's Tundra Mammoth (MountID: 284)
	},
	["creature/mammoth2lavamount/mammoth2lavamount.m2"] = {
		familyName = "Magmammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Loyal Magmammoth (MountID: 1612)
		--   Mammyth (MountID: 1938)
		--   Raging Magmammoth (MountID: 1644)
		--   Renewed Magmammoth (MountID: 1645)
		--   Subterranean Magmammoth (MountID: 1603)
	},
	["creature/mammoth2mount/mammoth2mount.m2"] = {
		familyName = "Trawling Mammoth",
		superGroup = "Mammoths",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bestowed Trawling Mammoth (MountID: 1633)
		--   Mossy Mammoth (MountID: 1634)
		--   Plainswalker Bearer (MountID: 1635)
	},
	["creature/manaraymount/manaraymount.m2"] = {
		familyName = "Mana Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bulbous Necroray (MountID: 1438)
		--   Darkspore Mana Ray (MountID: 906)
		--   Felglow Mana Ray (MountID: 975)
		--   Heartseeker Mana Ray (MountID: 1941)
		--   Infested Necroray (MountID: 1439)
		--   Lambent Mana Ray (MountID: 973)
		--   Pestilent Necroray (MountID: 1440)
		--   Scintillating Mana Ray (MountID: 976)
		--   Vibrant Mana Ray (MountID: 974)
	},
	["creature/manawyrmmount/manawyrmmount.m2"] = {
		familyName = "Nether-Gorged Greatwyrm",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Nether-Gorged Greatwyrm (MountID: 1581)
	},
	["creature/mawexpansionbearmount/mawexpansionbearmount.m2"] = {
		familyName = "Shardhide",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Amber Shardhide (MountID: 1505)
		--   Beryl Shardhide (MountID: 1455)
		--   Crimson Shardhide (MountID: 1506)
		--   Darkmaul (MountID: 1507)
	},
	["creature/mawexpansionfliermount/mawexpansionfliermount.m2"] = {
		familyName = "Razorwing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dusklight Razorwing (MountID: 1510)
		--   Fierce Razorwing (MountID: 1508)
		--   Garnet Razorwing (MountID: 1509)
		--   Soaring Razorwing (MountID: 1450)
	},
	["creature/mawguardhandmount/mawguardhandmount.m2"] = {
		familyName = "Mawguard Hand",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Hand of Bahmethra (MountID: 1475)
		--   Hand of Hrestimorak (MountID: 1417)
		--   Hand of Nilganihmaht (MountID: 1503)
		--   Hand of Reshkigaal (MountID: 2249)
		--   Hand of Salaranga (MountID: 1504)
	},
	["creature/mawhorsespikes/mawhorsespikes.m2"] = {
		familyName = "Mawsworn Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Fallen Charger (MountID: 1502)
		--   Mawsworn Charger (MountID: 1416)
		--   Sanctum Gloomcharger (MountID: 1500)
		--   Soulbound Gloomcharger (MountID: 1501)
	},
	["creature/mawratmount/mawratmount.m2"] = {
		familyName = "Mawrat",
		superGroup = "Darkhounds",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Colossal Ebonclaw Mawrat (MountID: 1566)
		--   Colossal Plaguespew Mawrat (MountID: 1584)
		--   Colossal Soulshredder Mawrat (MountID: 1564)
		--   Colossal Umbrahide Mawrat (MountID: 1565)
		--   Colossal Wraithbound Mawrat (MountID: 1585)
	},
	["creature/mechacycle/mechacycle.m2"] = {
		familyName = "Mechacycle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Junkheap Drifter (MountID: 1248)
		--   Mechacycle Model W (MountID: 1247)
	},
	["creature/mechadevilsaurmount/mechadevilsaurmount.m2"] = {
		familyName = "Flarendo the Furious",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Flarendo the Furious (MountID: 2278)
	},
	["creature/mechagnomestrider/mechagnomestrider.m2"] = {
		familyName = "Mechagon Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Mechagon Mechanostrider (MountID: 1283)
	},
	["creature/mechagonspidertank/mechagonspidertank.m2"] = {
		familyName = "Mechaspider",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mechagon Peacekeeper (MountID: 1252)
		--   Rusty Mechanocrawler (MountID: 1229)
		--   Scrapforged Mechaspider (MountID: 1253)
	},
	["creature/mechanicaltiger/mechanicaltiger.m2"] = {
		familyName = "X-995 Mechanocat",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   X-995 Mechanocat (MountID: 1239)
	},
	["creature/mechastrider/mechastrider.m2"] = {
		familyName = "Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Mechanostrider (MountID: 145)
		--   Blue Mechanostrider (MountID: 40)
		--   Green Mechanostrider (MountID: 43)
		--   Green Mechanostrider (MountID: 57)
		--   Icy Blue Mechanostrider Mod A (MountID: 62)
		--   Red Mechanostrider (MountID: 39)
		--   Unpainted Mechanostrider (MountID: 58)
		--   White Mechanostrider Mod B (MountID: 42)
	},
	["creature/mechastrider/pvpmechastrider.m2"] = {
		familyName = "Armored Mechanostrider",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Battlestrider (MountID: 77)
		--   Gnomeregan Mechanostrider (MountID: 298)
		--   Swift Green Mechanostrider (MountID: 90)
		--   Swift White Mechanostrider (MountID: 89)
		--   Swift Yellow Mechanostrider (MountID: 88)
		--   Turbostrider (MountID: 323)
	},
	["creature/mimiron/mimiron_head_mount.m2"] = {
		familyName = "Mimiron's Head",
		superGroup = "Mechaheads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mimiron's Head (MountID: 304)
	},
	["creature/molemount/molemount.m2"] = {
		familyName = "Fancy Mole",
		superGroup = "Moles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ol' Mole Rufus (MountID: 2205)
		--   Wick (MountID: 2204)
	},
	["creature/molemountbasic/molemountbasic.m2"] = {
		familyName = "Mole",
		superGroup = "Moles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crimson Mudnose (MountID: 2209)
	},
	["creature/monkmount/monkmount.m2"] = {
		familyName = "Ban-Lu",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ban-Lu, Grandmaster's Companion (MountID: 864)
	},
	["creature/moosebullmount/moosebullmount.m2"] = {
		familyName = "Bruffalon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Noble Bruffalon (MountID: 1467)
		--   Stormtouched Bruffalon (MountID: 1614)
	},
	["creature/moosemount/moosemount.m2"] = {
		familyName = "Grove Warden",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grove Warden (MountID: 764)
	},
	["creature/moosemount2/moosemount2.m2"] = {
		familyName = "Elderhorn",
		superGroup = "Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Great Northern Elderhorn (MountID: 854)
		--   Highmountain Elderhorn (MountID: 941)
		--   Stonehide Elderhorn (MountID: 1209)
	},
	["creature/moosemount2nightmare/moosemount2nightmare.m2"] = {
		familyName = "Grove Defiler",
		superGroup = "Flying Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grove Defiler (MountID: 773)
	},
	["creature/mothardenwealdmount/mothardenwealdmount.m2"] = {
		familyName = "Ardenmoth",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amber Ardenmoth (MountID: 1428)
		--   Duskflutter Ardenmoth (MountID: 1361)
		--   Silky Shimmermoth (MountID: 1332)
		--   Vibrant Flutterwing (MountID: 1429)
	},
	["creature/motorcyclefelreavermount/motorcyclefelreavermount.m2"] = {
		familyName = "Reaver Motorcycle",
		superGroup = "Choppers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Hateforged Blazecycle (MountID: 1947)
		--   Incognitro, the Indecipherable Felcycle (MountID: 1943)
		--   Voidfire Deathcycle (MountID: 1948)
	},
	["creature/motorcyclevehicle/motorcyclevehicle.m2"] = {
		familyName = "Mechano-Hog",
		superGroup = "Choppers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mechano-Hog (MountID: 240)
		--   Mekgineer's Chopper (MountID: 275)
	},
	["creature/motorcyclevehicle/motorcyclevehicle2.m2"] = {
		familyName = "Chauffeured vehicle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chauffeured Mechano-Hog (MountID: 678)
		--   Chauffeured Mekgineer's Chopper (MountID: 679)
	},
	["creature/mounteddeathknight/ridingundeadwarhorse.m2"] = {
		familyName = "Armored Skeletal Horse",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Skeletal Warhorse (MountID: 308)
		--   Forsaken Warhorse (MountID: 303)
		--   Green Skeletal Warhorse (MountID: 68)
		--   Ochre Skeletal Warhorse (MountID: 336)
		--   Purple Skeletal Warhorse (MountID: 100)
		--   Red Skeletal Warhorse (MountID: 80)
		--   Rivendare's Deathcharger (MountID: 69)
		--   Valiance (MountID: 1774)
		--   White Skeletal Warhorse (MountID: 326)
	},
	["creature/murlocmount/murlocmount.m2"] = {
		familyName = "Grrloc",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gargantuan Grrloc (MountID: 1312)
		--   Gigantic Grrloc (MountID: 2259)
		--   Ginormous Grrloc (MountID: 1797)
	},
	["creature/mushanbeast/mushanbeastmount.m2"] = {
		familyName = "Mushan Beast",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ashhide Mushan Beast (MountID: 560)
		--   Brawler's Burly Mushan Beast (MountID: 550)
		--   Palehide Mushan Beast (MountID: 2089)
		--   Riverwalker Mushan (MountID: 2088)
		--   Son of Galleon (MountID: 515)
	},
	["creature/nbsabermount/nbsabermount.m2"] = {
		familyName = "Nightborne Manasaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Nightborne Manasaber (MountID: 1008)
	},
	["creature/nerubianbeetlelargemount/nerubianbeetlelargemount.m2"] = {
		familyName = "Ivory Goliathus",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ivory Goliathus (MountID: 2230)
	},
	["creature/nerubianwarbeastmount/nerubianwarbeastmount.m2"] = {
		familyName = "Skyrazor",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ascendant Skyrazor (MountID: 2223)
		--   Siesbarg (MountID: 2222)
		--   Sureki Skyrazor (MountID: 2219)
	},
	["creature/netherdrake/netherdrake.m2"] = {
		familyName = "Nether Drake",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azure Netherwing Drake (MountID: 187)
		--   Cobalt Netherwing Drake (MountID: 188)
		--   Nether Drake (MountID: 123)
		--   Onyx Netherwing Drake (MountID: 186)
		--   Purple Netherwing Drake (MountID: 189)
		--   Veridian Netherwing Drake (MountID: 190)
		--   Violet Netherwing Drake (MountID: 191)
	},
	["creature/netherdrake/netherdrakeelite.m2"] = {
		familyName = "Nether Drake (PVP)",
		superGroup = "Nether Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brutal Nether Drake (MountID: 241)
		--   Merciless Nether Drake (MountID: 206)
		--   Merciless Nether Drake (MountID: 207)
		--   Swift Nether Drake (MountID: 169)
		--   Vengeful Nether Drake (MountID: 223)
	},
	["creature/nightbane2mount/nightbane2mount.m2"] = {
		familyName = "Smoldering Ember Wyrm",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Smoldering Ember Wyrm (MountID: 883)
	},
	["creature/nightmare/gorgon101.m2"] = {
		familyName = "Dreadsteed",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Dreadsteed (MountID: 83)
	},
	["creature/nightmare/nightmare.m2"] = {
		familyName = "Felsteed",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Felsteed (MountID: 17)
	},
	["creature/nightsaber2mount/nightsaber2mount.m2"] = {
		familyName = "Nightsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Kaldorei Nightsaber (MountID: 1205)
		--   Moonlit Nightsaber (MountID: 2586)
		--   Sandy Nightsaber (MountID: 1204)
		--   Umber Nightsaber (MountID: 1203)
	},
	["creature/nightsaber2mountsunmoon/nightsaber2mountsunmoon.m2"] = {
		familyName = "Ash'adar",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ash'adar, Harbinger of Dawn (MountID: 1577)
	},
	["creature/nightsaberhordemount/nightsaberhordemount.m2"] = {
		familyName = "Nightsaber Horde Mount",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blackrock Warsaber (MountID: 2199)
		--   Kor'kron Warsaber (MountID: 2198)
		--   [PH] Nightsaber Horde Mount White (MountID: 2200)
	},
	["creature/northrendbearmount/northrendbearmountarmored.m2"] = {
		familyName = "Armored Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Brown Bear (MountID: 269)
		--   Armored Brown Bear (MountID: 270)
		--   Black Polar Bear (MountID: 251)
		--   Black War Bear (MountID: 271)
		--   Black War Bear (MountID: 272)
		--   White Polar Bear (MountID: 237)
	},
	["creature/northrendbearmount/northrendbearmountblizzcon.m2"] = {
		familyName = "Big Blizzard Bear",
		superGroup = "Bears",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Big Blizzard Bear (MountID: 243)
	},
	["creature/nzothserpent/nzothserpent.m2"] = {
		familyName = "Slime Serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Slime Serpent (MountID: 1445)
	},
	["creature/nzothserpentmount/nzothserpentmount.m2"] = {
		familyName = "N'Zoth serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Awakened Mindborer (MountID: 1326)
		--   Black Serpent of N'Zoth (MountID: 1282)
		--   Mail Muncher (MountID: 1315)
		--   Wriggling Parasite (MountID: 1322)
	},
	["creature/oldgodfishmount/oldgodfishmount.m2"] = {
		familyName = "Underlight Behemoth",
		superGroup = "Flying Fishes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Kah, Legend of the Deep (MountID: 2188)
		--   Underlight Corrupted Behemoth (MountID: 2189)
		--   Underlight Shorestalker (MountID: 2187)
		--   [PH] Blue Old God Fish Mount (MountID: 2186)
	},
	["creature/onyxpanther/onyxpanther.m2"] = {
		familyName = "Jeweled Panther",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Jade Panther (MountID: 457)
		--   Jeweled Onyx Panther (MountID: 451)
		--   Ruby Panther (MountID: 458)
		--   Sapphire Panther (MountID: 456)
		--   Sunstone Panther (MountID: 459)
		--   Void-Crystal Panther (MountID: 2502)
	},
	["creature/orcclanworg/orcclanworg.m2"] = {
		familyName = "Mag'har Direwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mag'har Direwolf (MountID: 1044)
	},
	["creature/overchargedmech/overchargedmech.m2"] = {
		familyName = "OC91 Chariot",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   OC91 Chariot (MountID: 2604)
	},
	["creature/owldragonmount/owldragonmount.m2"] = {
		familyName = "Charming Courier",
		superGroup = "Owls",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Charming Courier (MountID: 2140)
	},
	["creature/oxmount/oxmount.m2"] = {
		familyName = "Lucky Yun",
		superGroup = "Oxes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lucky Yun (MountID: 1291)
	},
	["creature/paladinmount/paladinmount.m2"] = {
		familyName = "Highlord's Charger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Golden Charger (MountID: 991)
		--   Highlord's Golden Charger (MountID: 885)
		--   Highlord's Valorous Charger (MountID: 894)
		--   Highlord's Vengeful Charger (MountID: 892)
		--   Highlord's Vigilant Charger (MountID: 893)
		--   Valorous Charger (MountID: 987)
		--   Vengeful Charger (MountID: 989)
		--   Vigilant Charger (MountID: 990)
	},
	["creature/pandarenkitemount/pandarenkitemount.m2"] = {
		familyName = "Kite",
		superGroup = "Kite",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Feathered Windsurfer (MountID: 2069)
		--   Jade Pandaren Kite (MountID: 521)
		--   Pandaren Kite (MountID: 450)
		--   Pandaren Kite (MountID: 516)
	},
	["creature/pandarenphoenixmount/pandarenphoenixmount.m2"] = {
		familyName = "Pandaren Phoenix",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ashen Pandaren Phoenix (MountID: 518)
		--   August Phoenix (MountID: 2142)
		--   Crimson Pandaren Phoenix (MountID: 503)
		--   Emerald Pandaren Phoenix (MountID: 519)
		--   Violet Pandaren Phoenix (MountID: 520)
	},
	["creature/pandarenserpent/pandarenserpentmount.m2"] = {
		familyName = "Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azure Cloud Serpent (MountID: 464)
		--   Crimson Cloud Serpent (MountID: 472)
		--   Golden Cloud Serpent (MountID: 465)
		--   Ivory Cloud Serpent (MountID: 1311)
		--   Jade Cloud Serpent (MountID: 448)
		--   Magenta Cloud Serpent (MountID: 1573)
		--   Onyx Cloud Serpent (MountID: 471)
	},
	["creature/pandarenserpent/pandarenserpentmount_lightning.m2"] = {
		familyName = "Thundering Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Rajani Warserpent (MountID: 1313)
		--   Thundering August Cloud Serpent (MountID: 504)
		--   Thundering Cobalt Cloud Serpent (MountID: 542)
		--   Thundering Jade Cloud Serpent (MountID: 466)
		--   Thundering Onyx Cloud Serpent (MountID: 561)
		--   Thundering Ruby Cloud Serpent (MountID: 517)
	},
	["creature/pandarenserpent/pvppandarenserpentmount.m2"] = {
		familyName = "Gladiator's Cloud Serpent (PVP)",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grievous Gladiator's Cloud Serpent (MountID: 563)
		--   Malevolent Gladiator's Cloud Serpent (MountID: 541)
		--   Prideful Gladiator's Cloud Serpent (MountID: 564)
		--   Tyrannical Gladiator's Cloud Serpent (MountID: 562)
	},
	["creature/pandarenserpentgod/pandarenserpentgodmount.m2"] = {
		familyName = "Heavenly Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Heavenly Azure Cloud Serpent (MountID: 477)
		--   Heavenly Crimson Cloud Serpent (MountID: 474)
		--   Heavenly Golden Cloud Serpent (MountID: 475)
		--   Heavenly Onyx Cloud Serpent (MountID: 473)
		--   Yu'lei, Daughter of Jade (MountID: 476)
	},
	["creature/pandarenyetimount/pandarenyetimount.m2"] = {
		familyName = "Yeti",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Challenger's War Yeti (MountID: 654)
		--   Craghorn Chasm-Leaper (MountID: 1176)
		--   Minion of Grumpus (MountID: 769)
	},
	["creature/parrotmount/parrotmount.m2"] = {
		familyName = "Parrot",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Quawks (MountID: 1575)
		--   Royal Seafeather (MountID: 994)
		--   Sharkbait (MountID: 995)
		--   Squawks (MountID: 993)
	},
	["creature/parrotpiratemount/parrotpiratemount.m2"] = {
		familyName = "Pirate Parrot",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Hooktalon (MountID: 2324)
		--   Polly Roger (MountID: 2090)
	},
	["creature/mechanicalparrotmount/mechanicalparrotmount.m2"] = {
		familyName = "Mechanical Parrot",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Wonderwing 2.0 (MountID: 1224)
	},
	["creature/peacockmount/peacockmount.m2"] = {
		familyName = "Peafowl",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brilliant Sunburst Peafowl (MountID: 2036)
		--   Majestic Azure Peafowl (MountID: 2035)
	},
	["creature/pegasusmount/pegasusmount.m2"] = {
		familyName = "Hearthsteed",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fiery Hearthsteed (MountID: 1168)
		--   Hearthsteed (MountID: 547)
	},
	["creature/phoenix2mount/phoenix2mount.m2"] = {
		familyName = "Skyblazer",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Sapphire Skyblazer (MountID: 1456)
	},
	["creature/piratedragonmount/piratedragonmount.m2"] = {
		familyName = "Chrono Corsair",
		superGroup = "Infinite Timereavers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Chrono Corsair (MountID: 2518)
	},
	["creature/priestmount/priestmount.m2"] = {
		familyName = "High Priest's Lightsworn Seeker",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   High Priest's Lightsworn Seeker (MountID: 861)
	},
	["creature/primaldragonflymount/primaldragonflymount.m2"] = {
		familyName = "Skitterfly",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amber Skitterfly (MountID: 1468)
		--   Azure Skitterfly (MountID: 1616)
		--   Bestowed Sandskimmer (MountID: 1618)
		--   Tamed Skitterfly (MountID: 1615)
		--   Verdant Skitterfly (MountID: 1617)
	},
	["creature/progenitorbotminemount/progenitorbotminemount.m2"] = {
		familyName = "Carcinized Zerethsteed",
		superGroup = "Mechaspiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Carcinized Zerethsteed (MountID: 1552)
	},
	["creature/progenitorbotmount/progenitorbotmount.m2"] = {
		familyName = "Zereth Overseer",
		superGroup = "Zereth Overseers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Zereth Overseer (MountID: 1587)
	},
	["creature/progenitorhawkmount/progenitorhawkmount.m2"] = {
		familyName = "Progenitor Hawk",
		superGroup = "Hawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Desertwing Hunter (MountID: 1430)
		--   Mawdapted Raptora (MountID: 1536)
		--   Raptora Swooper (MountID: 1537)
	},
	["creature/progenitorjellyfishmount/progenitorjellyfishmount.m2"] = {
		familyName = "Progenitor Aurelid",
		superGroup = "Jellyfishes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cryptic Aurelid (MountID: 1551)
		--   Deepstar Aurelid (MountID: 1434)
		--   Depthstalker (MountID: 1550)
		--   Shimmering Aurelid (MountID: 1549)
	},
	["creature/progenitorsnailmount/progenitorsnailmount.m2"] = {
		familyName = "Progenitor Snail",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Bronze Helicid (MountID: 1538)
		--   Scarlet Helicid (MountID: 1540)
		--   Serenade (MountID: 1448)
		--   Unsuccessful Prototype Fleetpod (MountID: 1539)
	},
	["creature/progenitorspidermount/progenitorspidermount.m2"] = {
		familyName = "Progenitor Spider",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Genesis Crawler (MountID: 1541)
		--   Ineffable Skitterer (MountID: 1543)
		--   Tarachnid Creeper (MountID: 1542)
	},
	["creature/progenitorstagmount/progenitorstagmount.m2"] = {
		familyName = "Progenitor Stag",
		superGroup = "Stags",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Anointed Protostag (MountID: 1529)
		--   Deathrunner (MountID: 1526)
		--   Pale Regal Cervid (MountID: 1431)
		--   Sundered Zerethsteed (MountID: 1528)
	},
	["creature/progenitortoadmount/progenitortoadmount.m2"] = {
		familyName = "Progenitor Gulper",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Goldplate Bufonid (MountID: 1547)
		--   Patient Bufonid (MountID: 1569)
		--   Prototype Leaper (MountID: 1570)
		--   Russet Bufonid (MountID: 1571)
	},
	["creature/progenitorwaspmount/progenitorwaspmount.m2"] = {
		familyName = "Progenitor Wasp",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bronzewing Vespoid (MountID: 1535)
		--   Buzz (MountID: 1534)
		--   Forged Spiteflyer (MountID: 1533)
		--   Vespoid Flutterer (MountID: 1433)
	},
	["creature/progenitorwolf/progenitorwolf.m2"] = {
		familyName = "Heartbond Lupine",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Heartbond Lupine (MountID: 1580)
	},
	["creature/progenitorwombatmount/progenitorwombatmount.m2"] = {
		familyName = "Progenitor Wombat",
		superGroup = "Boars",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Adorned Vombata (MountID: 1525)
		--   Curious Crystalsniffer (MountID: 1523)
		--   Darkened Vombata (MountID: 1524)
		--   Heartlight Vombata (MountID: 1522)
	},
	["creature/protodragon/korkronprotodrakemount.m2"] = {
		familyName = "Spawn of Galakras",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spawn of Galakras (MountID: 557)
	},
	["creature/protodragon/mdprotodrakemount.m2"] = {
		familyName = "Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Proto-Drake (MountID: 263)
		--   Blue Proto-Drake (MountID: 264)
		--   Green Proto-Drake (MountID: 278)
		--   Plagued Proto-Drake (MountID: 266)
		--   Red Proto-Drake (MountID: 262)
		--   Time-Lost Proto-Drake (MountID: 265)
		--   Violet Proto-Drake (MountID: 267)
	},
	["creature/protodragon/protodragon_razorscale_mount.m2"] = {
		familyName = "Razorscale Proto-Drake",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ironbound Proto-Drake (MountID: 306)
		--   Rusted Proto-Drake (MountID: 307)
	},
	["creature/protodrakegladiatormount/protodrakegladiatormount.m2"] = {
		familyName = "Gladiator's Proto-Drake (PVP)",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Corrupted Gladiator's Proto-Drake (MountID: 1035)
		--   Dread Gladiator's Proto-Drake (MountID: 1030)
		--   Notorious Gladiator's Proto-Drake (MountID: 1032)
		--   Sinister Gladiator's Proto-Drake (MountID: 1031)
	},
	["creature/protoramearthenmount/protoramearthenmount.m2"] = {
		familyName = "Ramolith",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Shale Ramolith (MountID: 2213)
		--   Slatestone Ramolith (MountID: 2214)
	},
	["creature/pterrordax2mount/pterrordax2mount.m2"] = {
		familyName = "Battle Pterrordax",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Golden Pterrordax (MountID: 1586)
		--   Captured Swampstalker (MountID: 1059)
		--   Cobalt Pterrordax (MountID: 1058)
		--   Dazar'alor Windreaver (MountID: 1218)
		--   Kua'fon (MountID: 1043)
		--   Scarlet Pterrordax (MountID: 1772)
		--   Spectral Pterrorwing (MountID: 958)
		--   Swift Spectral Pterrordax (MountID: 1272)
		--   Voldunai Dunescraper (MountID: 1060)
	},
	["creature/pyrogryph/pyrogryph.m2"] = {
		familyName = "Flameward Hippogryph",
		superGroup = "Hippogryphs",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Flameward Hippogryph (MountID: 413)
	},
	["creature/quilin/quilinflyingmount.m2"] = {
		familyName = "Flying Quilen",
		superGroup = "Quilens",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Copper-Maned Quilen (MountID: 2474)
		--   Imperial Quilen (MountID: 468)
	},
	["creature/quilin/quilinmount.m2"] = {
		familyName = "Quilen",
		superGroup = "Quilens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Guardian Quilen (MountID: 2070)
		--   Marble Quilen (MountID: 2071)
		--   Qinsho's Eternal Hound (MountID: 1178)
		--   Ren's Stalwart Hound (MountID: 1327)
		--   Xinlao (MountID: 1328)
	},
	["creature/rabbitmount/rabbitmount.m2"] = {
		familyName = "Jade",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Jade, Bright Foreseer (MountID: 1594)
	},
	["creature/ragnarosmount/ragnarosmount.m2"] = {
		familyName = "Runebound Firelord",
		superGroup = "Elementals",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Runebound Firelord (MountID: 1812)
	},
	["creature/ram/pvpridingram.m2"] = {
		familyName = "Armored Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Ram (MountID: 78)
		--   Ironforge Ram (MountID: 296)
		--   Stormpike Battle Charger (MountID: 109)
		--   Swift Brewfest Ram (MountID: 202)
		--   Swift Brown Ram (MountID: 94)
		--   Swift Gray Ram (MountID: 95)
		--   Swift Violet Ram (MountID: 324)
		--   Swift White Ram (MountID: 96)
	},
	["creature/ram/ridingram.m2"] = {
		familyName = "Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Ram (MountID: 22)
		--   Black Ram (MountID: 64)
		--   Brewfest Ram (MountID: 201)
		--   Brown Ram (MountID: 25)
		--   Frost Ram (MountID: 63)
		--   Gray Ram (MountID: 21)
		--   White Ram (MountID: 24)
	},
	["creature/raptor2/raptor2.m2"] = {
		familyName = "Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Skullripper (MountID: 1183)
	},
	["creature/raptor2/viciouswarraptor.m2"] = {
		familyName = "Vicious War Raptor (PVP)",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vicious War Raptor (MountID: 641)
	},
	["creature/ratmount/ratmount.m2"] = {
		familyName = "Ratstallion",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ratstallion (MountID: 804)
	},
	["creature/ratmount2/ratmount2.m2"] = {
		familyName = "Squeakers, the Trickster",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Squeakers, the Trickster (MountID: 1290)
	},
	["creature/ratmounthearthstone/ratmounthearthstone.m2"] = {
		familyName = "Sarge's Tale",
		superGroup = "Rats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Sarge's Tale (MountID: 1513)
	},
	["creature/ravager2/ravager2mount.m2"] = {
		familyName = "Grinning Reaver",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Grinning Reaver (MountID: 594)
	},
	["creature/ravengod/ravengod.m2"] = {
		familyName = "Raven Lord",
		superGroup = "Ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Raven Lord (MountID: 185)
	},
	["creature/ravenlord/ravenlordmount.m2"] = {
		familyName = "Dread Raven",
		superGroup = "Dread ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dread Raven (MountID: 600)
	},
	["creature/ravenmount/ravenmount.m2"] = {
		familyName = "Great Raven",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Archmage's Great Raven (MountID: 2529)
		--   Prophet's Great Raven (MountID: 2525)
	},
	["creature/reddrakemount/reddrakemount.m2"] = {
		familyName = "Horned Drake",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blazing Drake (MountID: 442)
		--   Life-Binder's Handmaiden (MountID: 444)
		--   Twilight Harbinger (MountID: 443)
	},
	["creature/redpandamount/redpandamount.m2"] = {
		familyName = "Meeksi",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Meeksi Brewthief (MountID: 2346)
		--   Meeksi Rollingpaw (MountID: 2344)
		--   Meeksi Rufflefur (MountID: 2342)
		--   Meeksi Softpaw (MountID: 2343)
		--   Meeksi Teatuft (MountID: 2345)
	},
	["creature/rhinoprimalmountdream/rhinoprimalmountdream.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Verdant Armoredon (MountID: 1801)
	},
	["creature/rhinoprimalmountfire/rhinoprimalmountfire.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Inferno Armoredon (MountID: 1725)
	},
	["creature/rhinoprimalmountice/rhinoprimalmountice.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Hailstorm Armoredon (MountID: 1681)
	},
	["creature/rhinoprimalmountinfinite/rhinoprimalmountinfinite.m2"] = {
		familyName = "Armoredon",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Infinite Armoredon (MountID: 2055)
	},
	["creature/ridingdirewolfspectral/ridingdirewolfspectral.m2"] = {
		familyName = "Spectral Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spectral Wolf (MountID: 406)
	},
	["creature/ridingelekk/draeneipaladinelekk.m2"] = {
		familyName = "Exarch's Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Exarch's Elekk (MountID: 367)
	},
	["creature/ridingelekk/paladinelekkelite.m2"] = {
		familyName = "Great Exarch's Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Great Exarch's Elekk (MountID: 368)
		--   Great Exarch's Elekk (MountID: 824)
	},
	["creature/ridingelekk/ridingelekk.m2"] = {
		familyName = "Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brown Elekk (MountID: 147)
		--   Gray Elekk (MountID: 163)
		--   Purple Elekk (MountID: 164)
	},
	["creature/ridingelekk/ridingelekkelite.m2"] = {
		familyName = "Armored Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Elekk (MountID: 220)
		--   Exodar Elekk (MountID: 299)
		--   Great Blue Elekk (MountID: 166)
		--   Great Green Elekk (MountID: 165)
		--   Great Purple Elekk (MountID: 167)
		--   Great Red Elekk (MountID: 318)
	},
	["creature/ridinghorse/ridinghorse.m2"] = {
		familyName = "Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Stallion (MountID: 9)
		--   Brown Horse (MountID: 6)
		--   Chestnut Mare (MountID: 18)
		--   Palomino (MountID: 52)
		--   Pinto (MountID: 11)
		--   White Stallion (MountID: 53)
		--   White Stallion (MountID: 8)
	},
	["creature/ridinghorse/ridinghorsepvpt2.m2"] = {
		familyName = "Armored Horse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black War Steed (MountID: 75)
		--   Stormwind Steed (MountID: 294)
		--   Swift Alliance Steed (MountID: 343)
		--   Swift Brown Steed (MountID: 93)
		--   Swift Gray Steed (MountID: 321)
		--   Swift Palomino (MountID: 91)
		--   Swift White Steed (MountID: 92)
	},
	["creature/ridinghorse/ridinghorsespectral.m2"] = {
		familyName = "Spectral Steed",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spectral Steed (MountID: 405)
	},
	["creature/ridingnetherray/ridingnetherray.m2"] = {
		familyName = "Nether Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Riding Nether Ray (MountID: 180)
		--   Green Riding Nether Ray (MountID: 176)
		--   Purple Riding Nether Ray (MountID: 178)
		--   Red Riding Nether Ray (MountID: 177)
		--   Silver Riding Nether Ray (MountID: 179)
	},
	["creature/ridingphoenix/ridingphoenix.m2"] = {
		familyName = "Ashes of Al'ar",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ashes of Al'ar (MountID: 183)
	},
	["creature/ridingphoenix2/ridingphoenix2.m2"] = {
		familyName = "Golden Ashes of Al'ar",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Golden Ashes of Al'ar (MountID: 2255)
	},
	["creature/ridingraptor/pvpridingraptor.m2"] = {
		familyName = "Armored Primal Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Razzashi Raptor (MountID: 410)
		--   Black War Raptor (MountID: 79)
		--   Darkspear Raptor (MountID: 295)
		--   Swift Albino Raptor (MountID: 1180)
		--   Swift Blue Raptor (MountID: 97)
		--   Swift Olive Raptor (MountID: 98)
		--   Swift Orange Raptor (MountID: 99)
		--   Swift Purple Raptor (MountID: 325)
		--   Swift Razzashi Raptor (MountID: 110)
	},
	["creature/ridingraptor/ridingraptor.m2"] = {
		familyName = "Primal Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Primal Raptor (MountID: 539)
		--   Bone-White Primal Raptor (MountID: 537)
		--   Emerald Raptor (MountID: 27)
		--   Green Primal Raptor (MountID: 540)
		--   Ivory Raptor (MountID: 35)
		--   Ivory Raptor (MountID: 56)
		--   Mottled Red Raptor (MountID: 54)
		--   Red Primal Raptor (MountID: 538)
		--   Savage Raptor (MountID: 418)
		--   Turquoise Raptor (MountID: 36)
		--   Venomhide Ravasaur (MountID: 311)
		--   Violet Raptor (MountID: 38)
	},
	["creature/ridingsilithid/ridingsilithid.m2"] = {
		familyName = "Qiraji Battle Tank",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Qiraji Battle Tank (MountID: 116)
		--   Black Qiraji Battle Tank (MountID: 121)
		--   Black Qiraji Battle Tank (MountID: 122)
		--   Blue Qiraji Battle Tank (MountID: 117)
		--   Green Qiraji Battle Tank (MountID: 120)
		--   Red Qiraji Battle Tank (MountID: 118)
		--   Ultramarine Qiraji Battle Tank (MountID: 404)
		--   Yellow Qiraji Battle Tank (MountID: 119)
	},
	["creature/ridingsilithid2/ridingsilithid2.m2"] = {
		familyName = "Qiraji War Tank",
		superGroup = "Qirajis",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Black Qiraji War Tank (MountID: 937)
		--   Blue Qiraji War Tank (MountID: 935)
		--   Red Qiraji War Tank (MountID: 936)
	},
	["creature/ridingtalbuk/ridingtalbuk.m2"] = {
		familyName = "Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cobalt Riding Talbuk (MountID: 170)
		--   Dark Riding Talbuk (MountID: 171)
		--   Silver Riding Talbuk (MountID: 172)
		--   Tan Riding Talbuk (MountID: 173)
		--   White Riding Talbuk (MountID: 174)
	},
	["creature/ridingtalbuk/ridingtalbukepic.m2"] = {
		familyName = "Armored Talbuk",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cobalt War Talbuk (MountID: 153)
		--   Dark War Talbuk (MountID: 151)
		--   Silver War Talbuk (MountID: 155)
		--   Tan War Talbuk (MountID: 156)
		--   White War Talbuk (MountID: 154)
	},
	["creature/ridingturtle/ridingturtle.m2"] = {
		familyName = "Sea Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Riding Turtle (MountID: 125)
		--   Sea Turtle (MountID: 312)
	},
	["creature/ridingundeaddrake/armoredridingundeaddrake.m2"] = {
		familyName = "Vanquisher",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodbathed Frostbrood Vanquisher (MountID: 365)
		--   Icebound Frostbrood Vanquisher (MountID: 364)
		--   Scourgebound Vanquisher (MountID: 1783)
	},
	["creature/ridingundeaddrake/ridingundeaddrake.m2"] = {
		familyName = "Gladiator's Frost Wyrm (PVP)",
		superGroup = "Vanquisher Wyrms",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Deadly Gladiator's Frost Wyrm (MountID: 313)
		--   Furious Gladiator's Frost Wyrm (MountID: 317)
		--   Relentless Gladiator's Frost Wyrm (MountID: 340)
		--   Wrathful Gladiator's Frost Wyrm (MountID: 358)
	},
	["creature/ridingwyvern/ridingwyvern.m2"] = {
		familyName = "Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Wind Rider (MountID: 134)
		--   Green Wind Rider (MountID: 135)
		--   Remembered Wind Rider (MountID: 2117)
		--   Tawny Wind Rider (MountID: 133)
	},
	["creature/ridingwyvernarmored/ridingwyvernarmored.m2"] = {
		familyName = "Armored Wyvern",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Blue Wind Rider (MountID: 277)
		--   Swift Green Wind Rider (MountID: 140)
		--   Swift Purple Wind Rider (MountID: 142)
		--   Swift Red Wind Rider (MountID: 136)
		--   Swift Yellow Wind Rider (MountID: 141)
	},
	["creature/ridingyak/ridingyak.m2"] = {
		familyName = "Yak",
		superGroup = "Yaks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Riding Yak (MountID: 484)
		--   Blonde Riding Yak (MountID: 487)
		--   Grey Riding Yak (MountID: 486)
		--   Kafa Yak (MountID: 462)
		--   Modest Expedition Yak (MountID: 485)
	},
	["creature/riverotterlargemount01/riverotterlargemount01.m2"] = {
		familyName = "Ottuk",
		superGroup = "Ottuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brown Scouting Ottuk (MountID: 1657)
		--   Delugen (MountID: 1837)
		--   Iskaara Trader's Ottuk (MountID: 1546)
		--   Ivory Trader's Ottuk (MountID: 1658)
		--   Otto (MountID: 1656)
		--   Yellow Scouting Ottuk (MountID: 1659)
	},
	["creature/riverotterlargemount02/riverotterlargemount02.m2"] = {
		familyName = "Armored Ottuk",
		superGroup = "Ottuks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bestowed Ottuk Vanguard (MountID: 1651)
		--   Brown War Ottuk (MountID: 1653)
		--   Otterworldly Ottuk Carrier (MountID: 1654)
		--   Yellow War Ottuk (MountID: 1655)
	},
	["creature/rocketmount/rocketmount.m2"] = {
		familyName = "Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Unstable Rocket (MountID: 2301)
		--   Unstable Rocket (MountID: 2302)
		--   X-45 Heartbreaker (MountID: 352)
		--   X-51 Nether-Rocket (MountID: 211)
		--   X-51 Nether-Rocket X-TREME (MountID: 212)
	},
	["creature/rocketmount2/rocketmount2.m2"] = {
		familyName = "X-53 Touring Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   X-53 Touring Rocket (MountID: 382)
	},
	["creature/rocketmount3/rocketmount3.m2"] = {
		familyName = "Depleted-Kyparium Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Depleted-Kyparium Rocket (MountID: 469)
	},
	["creature/rocketmount4/rocketmount4.m2"] = {
		familyName = "Geosynchronous World Spinner",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Geosynchronous World Spinner (MountID: 470)
	},
	["creature/rocketmount5/rocketmount5.m2"] = {
		familyName = "Cartel Rocket",
		superGroup = "Rockets",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Innovation Investigator (MountID: 2283)
		--   Ochre Delivery Rocket (MountID: 2284)
		--   Steamwheedle Supplier (MountID: 2281)
		--   The Topskimmer Special (MountID: 2280)
		--   Thunderdrum Misfire (MountID: 2279)
	},
	["creature/rocketshredder9001/rocketshredder9001.m2"] = {
		familyName = "Rocket Shredder 9001",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Rocket Shredder 9001 (MountID: 1698)
	},
	["creature/rocmaldraxxusmount/rocmaldraxxusmount.m2"] = {
		familyName = "Roc",
		superGroup = "Dread ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Bonesewn Fleshroc (MountID: 1409)
		--   Colossal Slaughterclaw (MountID: 1350)
		--   Hulking Deathroc (MountID: 1410)
		--   Predatory Plagueroc (MountID: 1411)
	},
	["creature/roguemount/roguemount.m2"] = {
		familyName = "Shadowblade's Omen",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Shadowblade's Baneful Omen (MountID: 890)
		--   Shadowblade's Crimson Omen (MountID: 891)
		--   Shadowblade's Lethal Omen (MountID: 889)
		--   Shadowblade's Murderous Omen (MountID: 884)
	},
	["creature/saber2/saber2mount.m2"] = {
		familyName = "Mystic Runesaber",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Mystic Runesaber (MountID: 741)
	},
	["creature/saber3mount/saber3mount.m2"] = {
		familyName = "Priestess' Moonsaber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Priestess' Moonsaber (MountID: 1216)
	},
	["creature/sabretoothraptormount/sabretoothraptormount.m2"] = {
		familyName = "Dreamtalon",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ochre Dreamtalon (MountID: 1834)
		--   Snowfluff Dreamtalon (MountID: 1835)
		--   Springtide Dreamtalon (MountID: 1833)
		--   Talont (MountID: 1838)
	},
	["creature/salamanderwatermount/salamanderwatermount.m2"] = {
		familyName = "Salamanther",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ancient Salamanther (MountID: 1619)
		--   Coralscale Salamanther (MountID: 1621)
		--   Salatrancer (MountID: 1940)
		--   Stormhide Salamanther (MountID: 1622)
	},
	["creature/sandbeemount/sandbeemount.m2"] = {
		familyName = "Timely Buzzbee",
		superGroup = "Bees",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Timely Buzzbee (MountID: 2321)
	},
	["creature/scaleddrakemount/scaleddrakemount.m2"] = {
		familyName = "Tarecgosa's Visage",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Tarecgosa's Visage (MountID: 1727)
	},
	["creature/scarabmount/scarabmount.m2"] = {
		familyName = "Scarab",
		superGroup = "Scarabs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Golden Regal Scarab (MountID: 1944)
		--   Jeweled Copper Scarab (MountID: 1942)
	},
	["creature/seahorse/seahorsemount.m2"] = {
		familyName = "Seahorse",
		superGroup = "Seahorses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Saltwater Seahorse (MountID: 1208)
		--   Subdued Seahorse (MountID: 420)
		--   Vashj'ir Seahorse (MountID: 373)
	},
	["creature/serpentmount/serpentmount.m2"] = {
		familyName = "Serpent",
		superGroup = "Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Abyss Worm (MountID: 899)
		--   Nazjatar Blood Serpent (MountID: 1057)
		--   Ny'alothan Shadow Worm (MountID: 2500)
		--   Riddler's Mind-Worm (MountID: 947)
	},
	["creature/serpentmountgladiator/serpentmountgladiator.m2"] = {
		familyName = "Gladiator's Slitherdrake (PVP)",
		superGroup = "Slitherdrakes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Obsidian Gladiator's Slitherdrake (MountID: 1739)
		--   Verdant Gladiator's Slitherdrake (MountID: 1831)
	},
	["creature/shadebeastflying/shadebeastflying.m2"] = {
		familyName = "Zovaal's Soul Eater",
		superGroup = "Soul Eaters",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Zovaal's Soul Eater (MountID: 2114)
	},
	["creature/shadebeastmount/shadebeastmount.m2"] = {
		familyName = "Gladiator's Soul Eater (PVP)",
		superGroup = "Soul Eaters",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cosmic Gladiator's Soul Eater (MountID: 1572)
		--   Eternal Gladiator's Soul Eater (MountID: 1599)
		--   Sinful Gladiator's Soul Eater (MountID: 1363)
		--   Unchained Gladiator's Soul Eater (MountID: 1480)
	},
	["creature/shadowelementalmount/shadowelementalmount.m2"] = {
		familyName = "Shadow",
		superGroup = "Elementals",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Beledar's Spawn (MountID: 2192)
		--   Shackled Shadow (MountID: 2191)
		--   Shadow of Doubt (MountID: 2190)
	},
	["creature/shadowstalkerpanthermount/shadowstalkerpanthermount.m2"] = {
		familyName = "Luminous Starseeker",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Luminous Starseeker (MountID: 949)
	},
	["creature/shamanmount_fire/shamanmount_fire.m2"] = {
		familyName = "Farseer's Raging Tempest",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Farseer's Raging Tempest (MountID: 888)
	},
	["creature/shamanmount_fel/shamanmount_fel.m2"] = {
		familyName = "Farseer's Felscorned Tempest",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Farseer's Felscorned Tempest (MountID: 2729)
	},
	["creature/sharkraymount/sharkraymount.m2"] = {
		familyName = "Waveray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ankoan Waveray (MountID: 1231)
		--   Azshari Bloatray (MountID: 1232)
		--   Coral-Stalker Waveray (MountID: 1579)
		--   Silent Glider (MountID: 1257)
		--   Swift Spectral Fathom Ray (MountID: 1269)
		--   Unshackled Waveray (MountID: 1230)
	},
	["creature/shaserpentmount/shaserpentmount.m2"] = {
		familyName = "Sha-Warped Cloud Serpent",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Sha-Warped Cloud Serpent (MountID: 2476)
	},
	["creature/shatigermount/shatigermount.m2"] = {
		familyName = "Sha-Warped Riding Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Sha-Warped Riding Tiger (MountID: 2477)
	},
	["creature/shipmount/shipmount.m2"] = {
		familyName = "The Breaker's Song",
		superGroup = "Skiffs",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   The Breaker's Song (MountID: 2332)
	},
	["creature/shredder/shreddermount.m2"] = {
		familyName = "Sky Golem",
		superGroup = "Mechsuits",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Mechanized Lumber Extractor (MountID: 845)
		--   Sky Golem (MountID: 522)
	},
	["creature/siberiantiger/siberiantigermount.m2"] = {
		familyName = "Shado-Pan Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Blue Shado-Pan Riding Tiger (MountID: 506)
		--   Green Shado-Pan Riding Tiger (MountID: 505)
		--   Purple Shado-Pan Riding Tiger (MountID: 2087)
		--   Red Shado-Pan Riding Tiger (MountID: 507)
	},
	["creature/skeletalraptor/skeletalraptormount.m2"] = {
		familyName = "Fossilized Raptor",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Fossilized Raptor (MountID: 386)
	},
	["creature/skeletalwarhorse/skeletalwarhorse.m2"] = {
		familyName = "Vicious Skeletal Warhorse (PVP)",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Black Bonesteed (MountID: 1196)
		--   Vicious Skeletal Warhorse (MountID: 555)
		--   Vicious White Bonesteed (MountID: 1197)
	},
	["creature/skeletalwarhorse2/skeletalwarhorse2.m2"] = {
		familyName = "Midnight",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Midnight (MountID: 875)
	},
	["creature/skiff/skiff.m2"] = {
		familyName = "The Dreadwake",
		superGroup = "Skiffs",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   The Dreadwake (MountID: 1051)
	},
	["creature/sleigh/sleigh.m2"] = {
		familyName = "Unknown",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   [DND] Test Mount JZB (MountID: 1578)
	},
	["creature/snailrockmount/snailrockmount.m2"] = {
		familyName = "Snail",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Big Slick in the City (MountID: 1729)
		--   Emerald Snail (MountID: 2495)
	},
	["creature/snapdragon/snapdragon.m2"] = {
		familyName = "Prismatic Snapdragon",
		superGroup = "Snapdragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Prismatic Snapdragon (MountID: 2469)
	},
	["creature/snapdragonmount/snapdragonmount.m2"] = {
		familyName = "Snapdragon",
		superGroup = "Snapdragons",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Deepcoral Snapdragon (MountID: 1255)
		--   Royal Snapdragon (MountID: 1237)
		--   Snapdragon Kelpstalker (MountID: 1256)
	},
	["creature/snowelementalmount/snowelementalmount.m2"] = {
		familyName = "Bound Blizzard",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bound Blizzard (MountID: 1517)
	},
	["creature/soulhoundmount/soulhoundmount.m2"] = {
		familyName = "Ur'zul",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Shackled Ur'zul (MountID: 954)
		--   Ur'zul Fleshripper (MountID: 2471)
	},
	["creature/spectralgryphon/spectralgryphon.m2"] = {
		familyName = "Spectral Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spectral Gryphon (MountID: 440)
	},
	["creature/spectraltiger/spectraltiger.m2"] = {
		familyName = "Spectral Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spectral Tiger (MountID: 196)
	},
	["creature/spectraltiger/spectraltigerepic.m2"] = {
		familyName = "Swift Spectral Tiger",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Swift Spectral Tiger (MountID: 197)
	},
	["creature/spectralwyvern/spectralwyvern.m2"] = {
		familyName = "Spectral Wind Rider",
		superGroup = "Wyverns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Spectral Wind Rider (MountID: 441)
	},
	["creature/spidermount/spidermount.m2"] = {
		familyName = "Bloodfang Widow",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodfang Widow (MountID: 663)
	},
	["creature/spiderundergroundmount/spiderundergroundmount.m2"] = {
		familyName = "Undercrawler",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Heritage Undercrawler (MountID: 2172)
		--   Royal Court Undercrawler (MountID: 2174)
		--   Widow's Undercrawler (MountID: 2171)
	},
	["creature/sporebatrockmount/sporebatrockmount.m2"] = {
		familyName = "Shalewing",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Boulder Hauler (MountID: 1736)
		--   Calescent Shalewing (MountID: 1733)
		--   Cataloged Shalewing (MountID: 1735)
		--   Cobalt Shalewing (MountID: 1732)
		--   Igneous Shalewing (MountID: 1730)
		--   Imagiwing (MountID: 1939)
		--   Morsel Sniffer (MountID: 1738)
		--   Sandy Shalewing (MountID: 1737)
		--   Shadowflame Shalewing (MountID: 1734)
	},
	["creature/steelwarhorse/steelwarhorse.m2"] = {
		familyName = "Ironbound Wraithcharger",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ironbound Wraithcharger (MountID: 552)
	},
	["creature/stingray2/stingray2mount.m2"] = {
		familyName = "Sea Ray",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Darkwater Skate (MountID: 855)
		--   Great Sea Ray (MountID: 1166)
	},
	["creature/stormcrowmount/stormcrowmount.m2"] = {
		familyName = "Stormcrow",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Thrayir, Eyes of the Siren (MountID: 2322)
	},
	["creature/stormcrowmount_solar/stormcrowmount_arcane.m2"] = {
		familyName = "Stormcrow",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Violet Spellwing (MountID: 978)
	},
	["creature/stormcrowmount_solar/stormcrowmount_solar.m2"] = {
		familyName = "Stormcrow",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Solar Spirehawk (MountID: 634)
	},
	["creature/stormdragon/stormdragonmount.m2"] = {
		familyName = "Storm Dragon",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Felstorm Dragon (MountID: 1779)
		--   Island Thunderscale (MountID: 1212)
		--   Valarjar Stormwing (MountID: 944)
	},
	["creature/stormdragonmount2/stormdragonmount2.m2"] = {
		familyName = "Gladiator's Storm Dragon (PVP)",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cruel Gladiator's Storm Dragon (MountID: 850)
		--   Dominant Gladiator's Storm Dragon (MountID: 853)
		--   Fearless Gladiator's Storm Dragon (MountID: 849)
		--   Ferocious Gladiator's Storm Dragon (MountID: 851)
		--   Fierce Gladiator's Storm Dragon (MountID: 852)
		--   Vindictive Gladiator's Storm Dragon (MountID: 848)
	},
	["creature/stormdragonmount2_fel/stormdragonmount2_fel.m2"] = {
		familyName = "Demonic Gladiator's Storm Dragon (PVP)",
		superGroup = "Storm Dragons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Demonic Gladiator's Storm Dragon (MountID: 948)
	},
	["creature/stormpikebattlecharger/stormpikebattlecharger.m2"] = {
		familyName = "Stormpike Battle Ram",
		superGroup = "Rams",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Stormpike Battle Ram (MountID: 1292)
	},
	["creature/suramarmount/suramarmount.m2"] = {
		familyName = "Arcanist's Manasaber",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Arcanist's Manasaber (MountID: 881)
	},
	["creature/swiftwindsteed/swiftwindsteed_mount.m2"] = {
		familyName = "Windsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Dashing Windsteed (MountID: 2068)
		--   Daystorm Windsteed (MountID: 2065)
		--   Forest Windsteed (MountID: 2067)
		--   Swift Windsteed (MountID: 523)
	},
	["creature/talbukdraenor/talbukdraenormount.m2"] = {
		familyName = "Talbuk Draenor",
		superGroup = "Talbuks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Breezestrider Stallion (MountID: 638)
		--   Pale Thorngrazer (MountID: 639)
		--   Shadowmane Charger (MountID: 635)
		--   Swift Breezestrider (MountID: 636)
		--   Trained Silverpelt (MountID: 637)
	},
	["creature/tallstrider2/tallstrider2.m2"] = {
		familyName = "Strider",
		superGroup = "Striders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Swift Forest Strider (MountID: 429)
		--   Swift Lovebird (MountID: 431)
		--   Swift Shorestrider (MountID: 426)
		--   Swift Springstrider (MountID: 430)
	},
	["creature/tallstriderprimalmount/tallstriderprimalmount.m2"] = {
		familyName = "Hornstrider",
		superGroup = "Striders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Clayscale Hornstrider (MountID: 2038)
		--   Skyskin Hornstrider (MountID: 1478)
	},
	["creature/thunderislebird/thunderislebirdbossmount.m2"] = {
		familyName = "Clutch of..",
		superGroup = "Phoenixes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Clutch of Ha-Li (MountID: 1297)
		--   Clutch of Ji-Kun (MountID: 543)
	},
	["creature/thunderlizardprimalmount/thunderlizardprimalmount.m2"] = {
		familyName = "Thunderspine",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bestowed Thunderspine Packleader (MountID: 1474)
		--   Explorer's Stonehide Packbeast (MountID: 1638)
		--   Lizi, Thunderspine Tramper (MountID: 1639)
	},
	["creature/thunderpterodactyl/thunderpterodactylmount.m2"] = {
		familyName = "Thunder Pterrordax",
		superGroup = "Pterrordax",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amber Pterrordax (MountID: 2118)
		--   Armored Skyscreamer (MountID: 530)
		--   Bloody Skyscreamer (MountID: 2081)
		--   Jade Pterrordax (MountID: 2084)
		--   Night Pterrorwing (MountID: 2083)
	},
	["creature/tigermount/tigermount.m2"] = {
		familyName = "Wen Lo",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Wen Lo, the River's Edge (MountID: 1531)
	},
	["creature/toadardenwealdmount/toadardenwealdmount.m2"] = {
		familyName = "Arboreal Gulper",
		superGroup = "Toads",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Arboreal Gulper (MountID: 1415)
	},
	["creature/toadloamount/toadloamount.m2"] = {
		familyName = "Hopper",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Marsh Hopper (MountID: 1206)
		--   Cerulean Marsh Hopper (MountID: 1595)
		--   Green Marsh Hopper (MountID: 1012)
		--   Yellow Marsh Hopper (MountID: 1207)
	},
	["creature/travelersyak/travelersyak.m2"] = {
		familyName = "Grand Expedition Yak",
		superGroup = "Yaks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Grand Expedition Yak (MountID: 460)
	},
	["creature/treasurebasiliskmount/treasurebasiliskmount.m2"] = {
		familyName = "Plunderlord's Crocolisk",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Keg Leg's Radiant Crocolisk (MountID: 2239)
		--   Plunderlord's Golden Crocolisk (MountID: 2238)
		--   Plunderlord's Midnight Crocolisk (MountID: 2240)
		--   Plunderlord's Weathered Crocolisk (MountID: 2241)
	},
	["creature/triceratops/triceratopsmount.m2"] = {
		familyName = "Primordial Direhorn",
		superGroup = "Direhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amber Primordial Direhorn (MountID: 534)
		--   Child of Torcali (MountID: 1249)
		--   Cobalt Primordial Direhorn (MountID: 533)
		--   Crimson Primal Direhorn (MountID: 546)
		--   Golden Primal Direhorn (MountID: 545)
		--   Jade Primordial Direhorn (MountID: 536)
		--   Palehide Direhorn (MountID: 1179)
		--   Slate Primordial Direhorn (MountID: 535)
		--   Spawn of Horridon (MountID: 531)
		--   Zandalari Direhorn (MountID: 1038)
	},
	["creature/trilobitemount1/trilobitemount1.m2"] = {
		familyName = "Krolusk",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azureshell Krolusk (MountID: 1214)
		--   Conqueror's Scythemaw (MountID: 1172)
		--   Obsidian Krolusk (MountID: 933)
		--   Rubyshell Krolusk (MountID: 1215)
	},
	["creature/turtlemount/turtlemount.m2"] = {
		familyName = "Super Armored Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Arcadian War Turtle (MountID: 847)
		--   Tyrannotort (MountID: 2531)
	},
	["creature/turtlemount2/turtlemount2.m2"] = {
		familyName = "Savage Battle Turtle",
		superGroup = "Turtles",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Savage Alabaster Battle Turtle (MountID: 2347)
		--   Savage Blue Battle Turtle (MountID: 2039)
		--   Savage Ebony Battle Turtle (MountID: 2232)
		--   Savage Green Battle Turtle (MountID: 1582)
	},
	["creature/tuskarrglider/tuskarrglider.m2"] = {
		familyName = "Tuskarr Shoreglider",
		superGroup = "Kite",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Tuskarr Shoreglider (MountID: 1602)
	},
	["creature/tyraelmount/tyraelmount.m2"] = {
		familyName = "Tyrael's Charger",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Tyrael's Charger (MountID: 439)
	},
	["creature/undeadhorse/ridingundeadhorse.m2"] = {
		familyName = "Skeletal Horse",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Black Skeletal Horse (MountID: 314)
		--   Blue Skeletal Horse (MountID: 66)
		--   Brown Skeletal Horse (MountID: 67)
		--   Red Skeletal Horse (MountID: 65)
		--   Skeletal Horse (MountID: 28)
	},
	["creature/undeadhorse/undeadhorse.m2"] = {
		familyName = "Risen Mare",
		superGroup = "Skeletal Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Risen Mare (MountID: 1213)
	},
	["creature/viciousalliancebearmount/viciousalliancebearmount.m2"] = {
		familyName = "Vicious War Bear (PVP)",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Bear (MountID: 873)
	},
	["creature/viciousalliancehippo/viciousalliancehippo.m2"] = {
		familyName = "Vicious War Riverbeast (PVP)",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Riverbeast (MountID: 1050)
	},
	["creature/viciousalliancespider/viciousalliancespider.m2"] = {
		familyName = "Vicious War Spider (PVP)",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Spider (MountID: 1351)
	},
	["creature/viciousalliancetoad/viciousalliancetoad.m2"] = {
		familyName = "Vicious War Croaker (PVP)",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Croaker (MountID: 1452)
	},
	["creature/viciousalliancewolf/viciousalliancewolf.m2"] = {
		familyName = "Vicious Warstalker (PVP)",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Warstalker (MountID: 1465)
	},
	["creature/viciousdragonturtlemount/viciousdragonturtlemount.m2"] = {
		familyName = "Vicious War Turtle (PVP)",
		superGroup = "Turtles",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Turtle (MountID: 900)
		--   Vicious War Turtle (MountID: 901)
	},
	["creature/viciousflyingnerubian2/viciousflyingnerubian2_alliance.m2"] = {
		familyName = "Vicious War Skyflayer (PVP)",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Skyflayer (MountID: 2211)
	},
	["creature/viciousflyingnerubian2/viciousflyingnerubian2_horde.m2"] = {
		familyName = "Vicious War Skyflayer (PVP)",
		superGroup = "Swarmites",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Skyflayer (MountID: 2150)
	},
	["creature/viciousgoblintrike/viciousgoblintrike.m2"] = {
		familyName = "Vicious War Trike (PVP)",
		superGroup = "Goblin Trikes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Trike (MountID: 842)
	},
	["creature/viciousgoldenking/viciousgoldenking.m2"] = {
		familyName = "Vicious War Lion (PVP)",
		superGroup = "Lions",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Lion (MountID: 876)
	},
	["creature/viciousgorm/viciousgorm.m2"] = {
		familyName = "Vicious War Gorm (PVP)",
		superGroup = "Gorms",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Gorm (MountID: 1459)
		--   Vicious War Gorm (MountID: 1460)
	},
	["creature/vicioushawkstrider/vicioushawkstrider.m2"] = {
		familyName = "Vicious Warstrider (PVP)",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Warstrider (MountID: 843)
	},
	["creature/vicioushordebearmount/vicioushordebearmount.m2"] = {
		familyName = "Vicious War Bear (PVP)",
		superGroup = "Bears",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Bear (MountID: 874)
	},
	["creature/vicioushordeclefthoof/vicioushordeclefthoof.m2"] = {
		familyName = "Vicious War Clefthoof (PVP)",
		superGroup = "Clefthooves",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Clefthoof (MountID: 1045)
	},
	["creature/vicioushordespider/vicioushordespider.m2"] = {
		familyName = "Vicious War Spider (PVP)",
		superGroup = "Spiders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Spider (MountID: 1352)
	},
	["creature/vicioushordetoad/vicioushordetoad.m2"] = {
		familyName = "Vicious War Croaker (PVP)",
		superGroup = "Toads",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Croaker (MountID: 1451)
	},
	["creature/vicioushordewolf/vicioushordewolf.m2"] = {
		familyName = "Vicious Warstalker (PVP)",
		superGroup = "Lupines",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Warstalker (MountID: 1466)
	},
	["creature/vicioushorse/vicioushorse.m2"] = {
		familyName = "Vicious Gilnean Warhorse (PVP)",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Gilnean Warhorse (MountID: 841)
	},
	["creature/viciouskorkronannihilator/viciouskorkronannihilator.m2"] = {
		familyName = "Vicious War Scorpion (PVP)",
		superGroup = "Scorpions",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Scorpion (MountID: 882)
	},
	["creature/viciousowlbearmount/viciousowlbearmount.m2"] = {
		familyName = "Vicious Moonbeast (PVP)",
		superGroup = "Moonbeasts",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Moonbeast (MountID: 1819)
		--   Vicious Moonbeast (MountID: 1820)
	},
	["creature/vicioussabertooth/vicioussabertooth.m2"] = {
		familyName = "Vicious Sabertooth (PVP)",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vicious Sabertooth (MountID: 1688)
		--   Vicious Sabertooth (MountID: 1689)
	},
	["creature/vicioussabretoothraptor/vicioussabretoothraptor.m2"] = {
		familyName = "Vicious Dreamtalon (PVP)",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vicious Dreamtalon (MountID: 2056)
		--   Vicious Dreamtalon (MountID: 2057)
	},
	["creature/vicioussnail/vicioussnail.m2"] = {
		familyName = "Vicious War Snail (PVP)",
		superGroup = "Snails",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vicious War Snail (MountID: 1740)
		--   Vicious War Snail (MountID: 1741)
	},
	["creature/viciouswarbasiliskalliance/viciouswarbasiliskalliance.m2"] = {
		familyName = "Vicious War Basilisk (PVP)",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Basilisk (MountID: 1027)
	},
	["creature/viciouswarbasiliskhorde/viciouswarbasiliskhorde.m2"] = {
		familyName = "Vicious War Basilisk (PVP)",
		superGroup = "Basilisks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Basilisk (MountID: 1026)
	},
	["creature/viciouswarelekk/viciouswarelekk.m2"] = {
		familyName = "Vicious War Elekk (PVP)",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Elekk (MountID: 844)
	},
	["creature/viciouswarfoxalliance/viciouswarfoxalliance.m2"] = {
		familyName = "Vicious War Fox (PVP)",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Fox (MountID: 945)
	},
	["creature/viciouswarfoxhorde/viciouswarfoxhorde.m2"] = {
		familyName = "Vicious War Fox (PVP)",
		superGroup = "Foxes",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Fox (MountID: 946)
	},
	["creature/viciouswarkodo/viciouswarkodo.m2"] = {
		familyName = "Vicious War Kodo (PVP)",
		superGroup = "Kodos",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Kodo (MountID: 756)
	},
	["creature/viciouswarmechanostrider/viciouswarmechanostrider.m2"] = {
		familyName = "Vicious War Mechanostrider (PVP)",
		superGroup = "Mechanostriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Vicious War Mechanostrider (MountID: 755)
	},
	["creature/viciouswarram/viciouswarram.m2"] = {
		familyName = "Vicious War Ram (PVP)",
		superGroup = "Rams",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious War Ram (MountID: 640)
	},
	["creature/voiddragonmount/voiddragonmount.m2"] = {
		familyName = "Voidwing",
		superGroup = "Drakes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Uncorrupted Voidwing (MountID: 1265)
	},
	["creature/voidelfhawkstridermount/voidelfhawkstridermount.m2"] = {
		familyName = "Starcursed Voidstrider",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Starcursed Voidstrider (MountID: 1009)
	},
	["creature/vulperamount/vulperamount.m2"] = {
		familyName = "Caravan Hyena",
		superGroup = "Hyenas",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Caravan Hyena (MountID: 1286)
	},
	["creature/vulturemount/vulturemount.m2"] = {
		familyName = "Albatross",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gold-Toed Albatross (MountID: 1778)
		--   Siltwing Albatross (MountID: 1042)
		--   Waste Marauder (MountID: 1317)
		--   Wastewander Skyterror (MountID: 1318)
	},
	["creature/warhorse/argentwarhorse.m2"] = {
		familyName = "Crusader's Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crusader's Black Warhorse (MountID: 345)
		--   Crusader's White Warhorse (MountID: 344)
	},
	["creature/warhorse/pvpwarhorse.m2"] = {
		familyName = "Armored Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Argent Charger (MountID: 338)
		--   Charger (MountID: 767)
		--   Charger (MountID: 786)
		--   Charger (MountID: 84)
		--   Thalassian Charger (MountID: 149)
		--   Thalassian Charger (MountID: 825)
	},
	["creature/warhorse/warhorse.m2"] = {
		familyName = "Warhorse",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Argent Warhorse (MountID: 341)
		--   Thalassian Warhorse (MountID: 150)
		--   Warhorse (MountID: 41)
	},
	["creature/warlockmount/warlockmount.m2"] = {
		familyName = "Netherlord's Wrathsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Netherlord's Brimstone Wrathsteed (MountID: 930)
		--   Netherlord's Chaotic Wrathsteed (MountID: 898)
	},
	["creature/warlockmountshadow/warlockmountshadow.m2"] = {
		familyName = "Netherlord's Accursed Wrathsteed",
		superGroup = "Flying horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Netherlord's Accursed Wrathsteed (MountID: 931)
	},
	["creature/warnightsabermount/warnightsabermount.m2"] = {
		familyName = "Vicious Warsaber (PVP)",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Black Warsaber (MountID: 1195)
		--   Vicious Kaldorei Warsaber (MountID: 554)
		--   Vicious White Warsaber (MountID: 1194)
	},
	["creature/warpstalkermount/warpstalkermount.m2"] = {
		familyName = "Viridian Phase-Hunter",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Viridian Phase-Hunter (MountID: 1444)
	},
	["creature/warriormount/warriormount.m2"] = {
		familyName = "Battlelord's Bloodthirsty War Wyrm",
		superGroup = "Proto-Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Battlelord's Bloodthirsty War Wyrm (MountID: 867)
	},
	["creature/waterelementalmount/waterelementalmount.m2"] = {
		familyName = "Glacial Tidestorm",
		superGroup = "Elementals",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Glacial Tidestorm (MountID: 1219)
	},
	["creature/waterstrider/waterstridermount.m2"] = {
		familyName = "Water Strider",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azure Water Strider (MountID: 449)
		--   Crimson Water Strider (MountID: 488)
	},
	["creature/wingedhorse/wingedhorse.m2"] = {
		familyName = "Invincible",
		superGroup = "Winged Flying horses",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Invincible (MountID: 363)
	},
	["creature/wingedlion2mount/wingedlion2mount.m2"] = {
		familyName = "Larion",
		superGroup = "Lions",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Gilded Prowler (MountID: 1425)
		--   Highwind Darkmane (MountID: 1423)
		--   Silverwind Larion (MountID: 1404)
	},
	["creature/wingedlionmount/wingedlionmount.m2"] = {
		familyName = "Winged Guardian",
		superGroup = "Flying sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Winged Guardian (MountID: 421)
	},
	["creature/wolfdraenor/wolfdraenor_felmount.m2"] = {
		familyName = "Infernal Direwolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Infernal Direwolf (MountID: 758)
	},
	["creature/wolfdraenor/wolfdraenormount.m2"] = {
		familyName = "Draenor Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Dustmane Direwolf (MountID: 650)
		--   Garn Nighthowl (MountID: 657)
		--   Smoky Direwolf (MountID: 649)
		--   Swift Frostwolf (MountID: 648)
		--   Trained Snarler (MountID: 647)
		--   Void-Scarred Pack Mother (MountID: 2498)
	},
	["creature/wolfdraenor/wolfdraenormountarmored.m2"] = {
		familyName = "Armored Draenor Wolf",
		superGroup = "Wolves",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Armored Frostwolf (MountID: 644)
		--   Garn Steelmaw (MountID: 642)
		--   Ironside Warwolf (MountID: 645)
		--   Warsong Direfang (MountID: 643)
	},
	["creature/wolfserpentmount/wolfserpentmount.m2"] = {
		familyName = "Wilderling",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Ardenweald Wilderling (MountID: 1484)
		--   Autumnal Wilderling (MountID: 1485)
		--   Summer Wilderling (MountID: 1487)
		--   Winter Wilderling (MountID: 1486)
	},
	["creature/wolfserpentmount2/wolfserpentmount2.m2"] = {
		familyName = "Voyaging Wilderling",
		superGroup = "Cloud Serpents",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Voyaging Wilderling (MountID: 2091)
	},
	["creature/woolyrhino/woolyrhinomount.m2"] = {
		familyName = "Wooly White Rhino",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Wooly White Rhino (MountID: 372)
	},
	["creature/zandalaripaladinmount/zandalaripaladinmount.m2"] = {
		familyName = "Crusader's Direhorn",
		superGroup = "Direhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crusader's Direhorn (MountID: 1225)
	},
	["creature/zandalariraptor/zandalariraptor.m2"] = {
		familyName = "Ivory Savagemane",
		superGroup = "Raptors",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ivory Savagemane (MountID: 2587)
	},
	["creature/zebramount/zebramount.m2"] = {
		familyName = "Zhevra",
		superGroup = "Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Quel'dorei Steed (MountID: 331)
		--   Swift Zhevra (MountID: 222)
		--   Swift Zhevra (MountID: 224)
	},
	["creature/zeppelinmount/zeppelinmount.m2"] = {
		familyName = "Darkmoon Dirigible",
		superGroup = "Dirigibles",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Darkmoon Dirigible (MountID: 962)
	},
	["world/expansion08/doodads/fae/9fa_fae_soulpod_cart02.m2"] = {
		familyName = "Wildseed Cradle",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Wildseed Cradle (MountID: 1397)
	},

	["creature/crocsunmount/crocsunmount.m2"] = {
		familyName = "Herald of Sa'bak",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Herald of Sa'bak (MountID: 2532)
	},
	-- To update as info comes out:
	["creature/brewfestmount/brewfestmount.m2"] = {
		familyName = "Propelled Aerial Units",
		superGroup = "Aerial Units",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brewfest Barrel Bomber (MountID: 2640)
	},
	["creature/cosmicdragonmount/cosmicdragonmount.m2"] = {
		familyName = "Voidwing",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Unbound Star-Eater (MountID: 2569)
	},
	["creature/dwarfgryphonmount/dwarfgryphonmount.m2"] = {
		familyName = "Algari Gryphon",
		superGroup = "Gryphons",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Adorned Northeron Gryphon (MountID: 2626)
		--   Cinder-Plumed Highland Gryphon (MountID: 2628)
		--   Emberwing Sky Guide (MountID: 2629)
		--   High Shaman's Aerie Gryphon (MountID: 2627)
	},
	["creature/elekkfelmount/elekkfelmount.m2"] = {
		familyName = "Fel Elekk",
		superGroup = "Elekks",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cinder-seared Elekk (MountID: 2619)
		--   Legion Forged Elekk (MountID: 2621)
		--   Thunder-ridged Elekk (MountID: 2618)
		--   Void-Razed Elekk (MountID: 2620)
	},
	["creature/headlesshorsemanmount2/headlesshorsemanmount2.m2"] = {
		familyName = "Headless Horseman's",
		superGroup = "Flying Horses",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   The Headless Horseman's Burning Charger (MountID: 2624)
		--   The Headless Horseman's Chilling Charger (MountID: 2622)
		--   The Headless Horseman's Ghoulish Charger (MountID: 2623)
		--   The Headless Horseman's Hallowed Charger (MountID: 2625)
	},
	["creature/kareshflyermount/kareshflyermount.m2"] = {
		familyName = "Kareshi Dread Raven",
		superGroup = "Dread Ravens",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Lavender K'arroc (MountID: 2552)
		--   Resplendent K'arroc (MountID: 2505)
		--   Umbral K'arroc (MountID: 2549)
	},
	["creature/kareshroamermount/kareshroamermount.m2"] = {
		familyName = "Slateback",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blue Barry (MountID: 2560)
		--   Curious Slateback (MountID: 2561)
		--   Phase-Lost Slateback (MountID: 2655)
	},
	["creature/viciousvoidcreepermount/viciousvoidcreepermount.m2"] = {
		familyName = "Void Creeper (PVP)",
		superGroup = "Creepers",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Void Creeper (MountID: 2570)
		--   Vicious Void Creeper (MountID: 2571)
	},
	["creature/voidcreepermount/voidcreepermount.m2"] = {
		familyName = "Void Creeper",
		superGroup = "Creepers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Acidic Void Creeper (MountID: 2557)
		--   Ruby Void Creeper (MountID: 2556)
		--   The Bone Freezer (MountID: 2555)
	},
	["creature/voidflyermount/voidflyermount.m2"] = {
		familyName = "Kareshi Flyer",
		superGroup = "Flyers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Terror of the Night (MountID: 2511)
		--   Terror of the Wastes (MountID: 2510)
	},
	["creature/voidflyermountmythic/voidflyermountmythic.m2"] = {
		familyName = "Void Infused Kareshi Flyer",
		superGroup = "Flyers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Azure Void Flyer (MountID: 2633)
		--   Scarlet Void Flyer (MountID: 2631)
	},
	["creature/voiddragonmount2ethereal_king/voiddragonmount2ethereal_king.m2"] = {
		familyName = "Voidwing",
		superGroup = "Drakes",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Royal Voidwing (MountID: 2606)
	},
	["creature/eagle2/eagle2.m2"] = {
		familyName = "Eagle",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Snowy Highmountain Eagle (MountID: 2574)
	},
	["creature/gianteagle/gianteagle.m2"] = {
		familyName = "Eagle",
		superGroup = "Birds (flying idle)",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Treetop Highmountain Eagle (MountID: 2666)
	},
	["creature/felbat2/felbatmount.m2"] = {
		familyName = "Fel Bat (Legion Remix)",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ashplague Fel Bat (MountID: 2544)
		--   Bloodhunter Fel Bat (MountID: 2542)
		--   Wretched Fel Bat (MountID: 2546)
	},
	["creature/felbat2/felbatmountdh.m2"] = {
		familyName = "Demonic Fel Bat (Legion Remix)",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Bloodguard Fel Bat (MountID: 2540)
		--   Forgotten Fel Bat (MountID: 2545)
		--   Risen Fel Bat (MountID: 2543)
	},
	["creature/felbatgladiatormount_void/felbatgladiatormount_void.m2"] = {
		familyName = "Fel Bat (PVP)",
		superGroup = "Plaguebats",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Astral Gladiator's Fel Bat (MountID: 2326)
	},
	["creature/progenitorbotmount_void/progenitorbotmount_void.m2"] = {
		familyName = "Void Zereth Overseer",
		superGroup = "Zereth Overseers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Void-Forged Overseer (MountID: 2612)
	},
	["creature/saber2/saber2.m2"] = {
		familyName = "Arcane Saber",
		superGroup = "Sabers",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Arcberry Manasaber (MountID: 2670)
		--   Leyfrost Manasaber (MountID: 2668)
		--   Nightwell Manasaber (MountID: 2669)
	},
	["creature/dragonhawk2lightmount/dragonhawk2lightmount.m2"] = {
		familyName = "Infused Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Lightwing Dragonhawk (MountID: 2568)
		--   Voidlight Surger (MountID: 2598)
	},
	["creature/dragonhawk2voidmount/dragonhawk2voidmount.m2"] = {
		familyName = "Infused Dragonhawk",
		superGroup = "Dragonhawks",
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
		-- Mounts using this model:
		--   Voidwing Dragonhawk (MountID: 2567)
	},
	["creature/turkeymount/turkeymount.m2"] = {
		familyName = "Turkeys",
		superGroup = "Hawkstriders",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
		-- Mounts using this model:
		--   Highlands Gobbler (MountID: 2696)
		--   Murky Turkey (MountID: 2698)
		--   Prized Turkey (MountID: 2699)
		--   Quirky Turkey (MountID: 2697)
	},
	["creature/tuskarrmoosemount/tuskarrmoosemount.m2"] = {
		familyName = "Crest-horn",
		superGroup = "Elderhorns",
		traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cragstepper Crest-Horn (MountID: 2651)
		--   Floestrider Crest-Horn (MountID: 2650)
		--   Kalu'ak Crest-Horn (MountID: 2645)
		--   Sharktested Crest-Horn (MountID: 2649)
	},
	-- why?
	["creature/druidflightform/druidflightform.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Feldruid's Scornwing Form (MountID: 2722)
	},
	["creature/amanibearmount/amanibearmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amani Blessed Bear (MountID: 2776)
	},

	["creature/arcanegolem2mount/arcanegolem2mount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Delver's Arcane Golem (MountID: 2839)
		--   Elven Arcane Guardian (MountID: 2841)
		--   Silvermoon's Arcane Defender (MountID: 2840)
	},

	["creature/bloodelementalmount/bloodelementalmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Lana'thel's Crimson Cascade (MountID: 2566)
	},

	["creature/bullmount/bullmount.m2"] = {
		familyName = "Astral Aurochs",
		superGroup = "Oxes",
		traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
		-- Mounts using this model:
		--   Astral Aurochs (MountID: 2632)
	},

	["creature/cosmicflyermount/cosmicflyermount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Voidbound Stormray (MountID: 2828)
	},

	["creature/dragonhawk2mount/dragonhawk2mount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fiery Dragonhawk (MountID: 2753)
		--   Swift Spectral Dragonhawk (MountID: 2595)
	},

	["creature/flyingcarpetmount4/flyingcarpetmount4.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fluffy Comfy Flying Carpet (MountID: 2850)
		--   Gruffy Comfy Flying Carpet (MountID: 2851)
		--   Huffy Comfy Flying Carpet (MountID: 2852)
		--   Stuffy Comfy Flying Carpet (MountID: 2853)
	},

	["creature/gardensnailmount/gardensnailmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Accented Pseudoshell (MountID: 2836)
		--   Arboreal Pseudoshell (MountID: 2833)
		--   Cabbage Pseudoshell (MountID: 2834)
		--   Lavender Pseudoshell (MountID: 2835)
	},

	["creature/gardenvinemount/gardenvinemount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Blooded Snapvine (MountID: 2847)
		--   Ferocious Snapvine (MountID: 2846)
		--   Savage Snapvine (MountID: 2848)
		--   Vicious Snapvine (MountID: 2845)
	},

	["creature/geargrindermount/geargrindermount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Geargrinder Mk. 11 (MountID: 2802)
	},

	["creature/gianteagle2mount/gianteagle2mount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Amani Sunfeather (MountID: 2693)
		--   Amani Windcaller (MountID: 2694)
	},

	["creature/harronircatmount/harronircatmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Fierce Grimlynx (MountID: 2614)
	},

	["creature/hawkstridermount/hawkstridermount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Crimson Silvermoon Hawkstrider (MountID: 2761)
		--   Spectral Hawkstrider (MountID: 2805)
		--   [DNT] 12.0 Black Hawkstrider (MountID: 2763)
		--   [DNT] 12.0 White Hawkstrider (MountID: 2817)
	},

	["creature/kaijubatvoidmount/kaijubatvoidmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Tenebrous Harrower (MountID: 2831)
	},

	["creature/kaijugladiatormount/kaijugladiatormount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Galactic Gladiator's Goredrake (MountID: 2801)
	},

	["creature/manawyrm2mount/manawyrm2mount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Preyseeker's Hubris (MountID: 2769)
		--   Preyseeker's Wrath (MountID: 2770)
	},

	["creature/midnightgolemmount/midnightgolemmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Arcanovoid Construct (MountID: 2842)
	},

	["creature/mythichexeaglemount/mythichexeaglemount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Calamitous Carrion (MountID: 2733)
		--   Convalescent Carrion (MountID: 2734)
	},

	["creature/phoenix2darkwellmount/phoenix2darkwellmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ashes of Belo'ren (MountID: 2607)
	},

	["creature/sporebat3mount/sporebat3mount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Cerulean Sporeglider (MountID: 2710)
		--   Ruddy Sporeglider (MountID: 2713)
	},

	["creature/stalkermount/stalkermount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Ravenous Shredclaw (MountID: 2789)
	},

	["creature/vicioussnaplizardmount/vicioussnaplizardmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vicious Snaplizard (MountID: 2793)
		--   Vicious Snaplizard (MountID: 2794)
	},

	["creature/voidjellyfish/voidjellyfish.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   [DNT] Jellyfish (MountID: 2704)
	},
	["creature/grovecrawlermount/grovecrawlermount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Untained Grove Crawler (MountID: 2747)
	},

	["creature/kaijubatmount/kaijubatmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Contained Stormarion Defender (MountID: 2767)
	},

	["creature/resinrhinomount/resinrhinomount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Vivid Chloroceros (MountID: 2913)
	},

	["creature/rutaanibirdmount/rutaanibirdmount.m2"] = {
		familyName = "UnknownFamily",
		superGroup = nil,
		traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
		-- Mounts using this model:
		--   Brilliant Petalwing (MountID: 2707)
	},
}
