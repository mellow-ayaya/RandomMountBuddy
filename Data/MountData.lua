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


    -- ========================================================
    -- BAKARS
    -- ========================================================


    [1824] = "Spiky Bakar",    -- Brown-Furred Spiky Bakar


    [1825] = "Taivan",    -- Taivan


    -- ========================================================
    -- BASILISKS
    -- ========================================================


    [878] = "Brawler's Burly Basilisk",    -- Brawler's Burly Basilisk
    [2593] = "Brawler's Burly Basilisk",    -- Slag Basilisk
    [2660] = "Brawler's Burly Basilisk",    -- Leystone Basilisk
    [2661] = "Brawler's Burly Basilisk",    -- Felslate Basilisk
    [2662] = "Brawler's Burly Basilisk",    -- Aquamarine Basilisk


    [1220] = "Bruce",    -- Bruce
    [2807] = "Bruce",    -- Brawlin' Bruno


    [2238] = "Plunderlord's Crocolisk",    -- Plunderlord's Golden Crocolisk
    [2239] = "Plunderlord's Crocolisk",    -- Keg Leg's Radiant Crocolisk
    [2240] = "Plunderlord's Crocolisk",    -- Plunderlord's Midnight Crocolisk
    [2241] = "Plunderlord's Crocolisk",    -- Plunderlord's Weathered Crocolisk


    [1026] = "Vicious War Basilisk (PVP)",    -- Vicious War Basilisk
    [1027] = "Vicious War Basilisk (PVP)",    -- Vicious War Basilisk


    -- ========================================================
    -- BATS
    -- ========================================================


    [544] = "Armored Bat",    -- Armored Bloodwing
    [1211] = "Armored Bat",    -- Bloodgorged Hunter


    [1185] = "Bat",    -- Witherbark Direwing
    [1210] = "Bat",    -- Bloodthirsty Dreadwing


    [2307] = "Chaos-Forged Dreadwing",    -- Chaos-Forged Dreadwing


    [1310] = "Dredwing",    -- Horrid Dredwing
    [1376] = "Dredwing",    -- Silvertip Dredwing
    [1377] = "Dredwing",    -- Rampart Screecher
    [1378] = "Dredwing",    -- Harvester's Dredwing


    -- ========================================================
    -- BEARS
    -- ========================================================


    [237] = "Armored Bear",    -- White Polar Bear
    [251] = "Armored Bear",    -- Black Polar Bear
    [269] = "Armored Bear",    -- Armored Brown Bear
    [270] = "Armored Bear",    -- Armored Brown Bear
    [271] = "Armored Bear",    -- Black War Bear
    [272] = "Armored Bear",    -- Black War Bear


    [199] = "Bear",    -- Amani War Bear
    [419] = "Bear",    -- Amani Battle Bear
    [2225] = "Bear",    -- Amani Hunting Bear


    [230] = "Big Battle Bear",    -- Big Battle Bear


    [243] = "Big Blizzard Bear",    -- Big Blizzard Bear


    [1199] = "Blackpaw",    -- Blackpaw


    [434] = "Darkmoon Dancing Bear",    -- Darkmoon Dancing Bear


    [2237] = "Grizzly Hills Packmaster",    -- Grizzly Hills Packmaster


    [2262] = "Harmonious Salutations Bear",    -- Harmonious Salutations Bear


    [1304] = "Shadehound",    -- Mawsworn Soulhunter
    [1441] = "Shadehound",    -- Bound Shadehound
    [1442] = "Shadehound",    -- Corridor Creeper


    [1455] = "Shardhide",    -- Beryl Shardhide
    [1505] = "Shardhide",    -- Amber Shardhide
    [1506] = "Shardhide",    -- Crimson Shardhide
    [1507] = "Shardhide",    -- Darkmaul


    [1424] = "Snowstorm",    -- Snowstorm


    [873] = "Vicious War Bear (PVP)",    -- Vicious War Bear
    [874] = "Vicious War Bear (PVP)",    -- Vicious War Bear


    -- ========================================================
    -- BEES
    -- ========================================================


    [2148] = "Cinderbee",    -- Smoldering Cinderbee
    [2165] = "Cinderbee",    -- Soaring Meaderbee
    [2167] = "Cinderbee",    -- Raging Cinderbee


    [1013] = "Honeyback",    -- Honeyback Harvester
    [1277] = "Honeyback",    -- Honeyback Hivemother


    [2321] = "Timely Buzzbee",    -- Timely Buzzbee


    -- ========================================================
    -- BIRDS (FLYING IDLE)
    -- ========================================================


    [1042] = "Albatross",    -- Siltwing Albatross
    [1317] = "Albatross",    -- Waste Marauder
    [1318] = "Albatross",    -- Wastewander Skyterror
    [1778] = "Albatross",    -- Gold-Toed Albatross


    [2574] = "Eagle",    -- Snowy Highmountain Eagle
    [2666] = "Eagle",    -- Treetop Highmountain Eagle


    [1224] = "Mechanical Parrot",    -- Wonderwing 2.0


    [993] = "Parrot",    -- Squawks
    [994] = "Parrot",    -- Royal Seafeather
    [995] = "Parrot",    -- Sharkbait
    [1575] = "Parrot",    -- Quawks


    [2090] = "Pirate Parrot",    -- Polly Roger
    [2324] = "Pirate Parrot",    -- Hooktalon


    [884] = "Shadowblade's Omen",    -- Shadowblade's Murderous Omen
    [889] = "Shadowblade's Omen",    -- Shadowblade's Lethal Omen
    [890] = "Shadowblade's Omen",    -- Shadowblade's Baneful Omen
    [891] = "Shadowblade's Omen",    -- Shadowblade's Crimson Omen
    [2728] = "Shadowblade's Omen",    -- Shadowblade's Felscorned Omen


    [634] = "Stormcrow",    -- Solar Spirehawk
    [978] = "Stormcrow",    -- Violet Spellwing
    [2322] = "Stormcrow",    -- Thrayir, Eyes of the Siren


    -- ========================================================
    -- BOARDS
    -- ========================================================


    [2575] = "Grandmaster's Board",    -- Grandmaster's Prophetic Board
    [2576] = "Grandmaster's Board",    -- Grandmaster's Deep Board
    [2577] = "Grandmaster's Board",    -- Grandmaster's Royal Board
    [2578] = "Grandmaster's Board",    -- Grandmaster's Smokey Board


    [2145] = "Surfboard",    -- Kickin' Kezan Waveshredder
    [2152] = "Surfboard",    -- Pearlescent Goblin Wave Shredder
    [2333] = "Surfboard",    -- Soweezi's Vintage Waveshredder
    [2334] = "Surfboard",    -- Bronze Goblin Waveshredder


    -- ========================================================
    -- BOARS
    -- ========================================================


    [619] = "Armored Boar",    -- Blacksteel Battleboar
    [620] = "Armored Boar",    -- Rocktusk Battleboar
    [621] = "Armored Boar",    -- Armored Frostboar
    [622] = "Armored Boar",    -- Armored Razorback
    [623] = "Armored Boar",    -- Frostplains Battleboar
    [765] = "Armored Boar",    -- Bristling Hellboar
    [768] = "Armored Boar",    -- Deathtusk Felboar


    [624] = "Boar",    -- Wild Goretusk
    [625] = "Boar",    -- Domesticated Razorback
    [626] = "Boar",    -- Giant Coldsnout
    [627] = "Boar",    -- Great Greytusk
    [628] = "Boar",    -- Trained Rocktusk
    [2600] = "Boar",    -- Unarmored Deathtusk Felboar


    [1372] = "Maldraxxus Boar",    -- Blisterback Bloodtusk
    [1373] = "Maldraxxus Boar",    -- Gorespine
    [1374] = "Maldraxxus Boar",    -- Bonecleaver's Skullboar
    [1375] = "Maldraxxus Boar",    -- Lurid Bloodtusk


    [1522] = "Progenitor Wombat",    -- Heartlight Vombata
    [1523] = "Progenitor Wombat",    -- Curious Crystalsniffer
    [1524] = "Progenitor Wombat",    -- Darkened Vombata
    [1525] = "Progenitor Wombat",    -- Adorned Vombata


    -- ========================================================
    -- BRUTOSAURS
    -- ========================================================


    [1039] = "Mighty Caravan Brutosaur",    -- Mighty Caravan Brutosaur


    [2265] = "Trader's Gilded Brutosaur",    -- Trader's Gilded Brutosaur


    -- ========================================================
    -- CAMELS
    -- ========================================================


    [398] = "Camel",    -- Brown Riding Camel
    [399] = "Camel",    -- Tan Riding Camel
    [400] = "Camel",    -- Grey Riding Camel
    [432] = "Camel",    -- White Riding Camel


    [1288] = "Explorer's Dunetrekker",    -- Explorer's Dunetrekker


    -- ========================================================
    -- CHOPPERS
    -- ========================================================


    [652] = "Champion's Treadblade",    -- Champion's Treadblade


    [240] = "Mechano-Hog",    -- Mechano-Hog
    [275] = "Mechano-Hog",    -- Mekgineer's Chopper


    [1943] = "Reaver Motorcycle",    -- Incognitro, the Indecipherable Felcycle
    [1947] = "Reaver Motorcycle",    -- Hateforged Blazecycle
    [1948] = "Reaver Motorcycle",    -- Voidfire Deathcycle


    [651] = "Warlord's Deathwheel",    -- Warlord's Deathwheel


    -- ========================================================
    -- CHROMATIC DRAGON
    -- ========================================================


    [2501] = "Corruption of the Aspects",    -- Corruption of the Aspects


    [446] = "Heart of the Aspects",    -- Heart of the Aspects


    -- ========================================================
    -- CLEFTHOOVES
    -- ========================================================


    [608] = "Clefthoof",    -- Witherhide Cliffstomper
    [609] = "Clefthoof",    -- Trained Icehoof
    [611] = "Clefthoof",    -- Tundra Icehoof
    [612] = "Clefthoof",    -- Bloodhoof Bull
    [1785] = "Clefthoof",    -- Ancestral Clefthoof


    [613] = "Ironhoof Destroyer",    -- Ironhoof Destroyer


    [1045] = "Vicious War Clefthoof (PVP)",    -- Vicious War Clefthoof


    -- ========================================================
    -- CLOUD SERPENTS
    -- ========================================================


    [478] = "Astral Cloud Serpent",    -- Astral Cloud Serpent
    [2143] = "Astral Cloud Serpent",    -- Astral Emperor's Serpent
    [2582] = "Astral Cloud Serpent",    -- Shaohao's Sage Serpent


    [448] = "Cloud Serpent",    -- Jade Cloud Serpent
    [464] = "Cloud Serpent",    -- Azure Cloud Serpent
    [465] = "Cloud Serpent",    -- Golden Cloud Serpent
    [471] = "Cloud Serpent",    -- Onyx Cloud Serpent
    [472] = "Cloud Serpent",    -- Crimson Cloud Serpent
    [1311] = "Cloud Serpent",    -- Ivory Cloud Serpent
    [1573] = "Cloud Serpent",    -- Magenta Cloud Serpent
    [2749] = "Cloud Serpent",    -- Echo of Aln'sharan


    [541] = "Gladiator's Cloud Serpent (PVP)",    -- Malevolent Gladiator's Cloud Serpent
    [562] = "Gladiator's Cloud Serpent (PVP)",    -- Tyrannical Gladiator's Cloud Serpent
    [563] = "Gladiator's Cloud Serpent (PVP)",    -- Grievous Gladiator's Cloud Serpent
    [564] = "Gladiator's Cloud Serpent (PVP)",    -- Prideful Gladiator's Cloud Serpent


    [473] = "Heavenly Cloud Serpent",    -- Heavenly Onyx Cloud Serpent
    [474] = "Heavenly Cloud Serpent",    -- Heavenly Crimson Cloud Serpent
    [475] = "Heavenly Cloud Serpent",    -- Heavenly Golden Cloud Serpent
    [476] = "Heavenly Cloud Serpent",    -- Yu'lei, Daughter of Jade
    [477] = "Heavenly Cloud Serpent",    -- Heavenly Azure Cloud Serpent


    [2476] = "Sha-Warped Cloud Serpent",    -- Sha-Warped Cloud Serpent


    [466] = "Thundering Cloud Serpent",    -- Thundering Jade Cloud Serpent
    [504] = "Thundering Cloud Serpent",    -- Thundering August Cloud Serpent
    [517] = "Thundering Cloud Serpent",    -- Thundering Ruby Cloud Serpent
    [542] = "Thundering Cloud Serpent",    -- Thundering Cobalt Cloud Serpent
    [561] = "Thundering Cloud Serpent",    -- Thundering Onyx Cloud Serpent
    [1313] = "Thundering Cloud Serpent",    -- Rajani Warserpent


    [2091] = "Voyaging Wilderling",    -- Voyaging Wilderling


    [1484] = "Wilderling",    -- Ardenweald Wilderling
    [1485] = "Wilderling",    -- Autumnal Wilderling
    [1486] = "Wilderling",    -- Winter Wilderling
    [1487] = "Wilderling",    -- Summer Wilderling
    [2795] = "Wilderling",    -- Bronze Wilderling


    -- ========================================================
    -- CREEPERS
    -- ========================================================


    [2555] = "Void Creeper",    -- The Bone Freezer
    [2556] = "Void Creeper",    -- Ruby Void Creeper
    [2557] = "Void Creeper",    -- Acidic Void Creeper


    [2570] = "Void Creeper (PVP)",    -- Vicious Void Creeper
    [2571] = "Void Creeper (PVP)",    -- Vicious Void Creeper


    -- ========================================================
    -- DARKHOUNDS
    -- ========================================================


    [1048] = "Dark Iron Core Hound",    -- Dark Iron Core Hound


    [1422] = "Darkhound",    -- Warstitched Darkhound
    [1437] = "Darkhound",    -- Battle-Bound Warhound
    [1477] = "Darkhound",    -- Undying Darkhound


    [1597] = "Grimhowl",    -- Grimhowl


    [1564] = "Mawrat",    -- Colossal Soulshredder Mawrat
    [1565] = "Mawrat",    -- Colossal Umbrahide Mawrat
    [1566] = "Mawrat",    -- Colossal Ebonclaw Mawrat
    [1584] = "Mawrat",    -- Colossal Plaguespew Mawrat
    [1585] = "Mawrat",    -- Colossal Wraithbound Mawrat


    -- ========================================================
    -- DIREHORNS
    -- ========================================================


    [1225] = "Crusader's Direhorn",    -- Crusader's Direhorn


    [531] = "Primordial Direhorn",    -- Spawn of Horridon
    [533] = "Primordial Direhorn",    -- Cobalt Primordial Direhorn
    [534] = "Primordial Direhorn",    -- Amber Primordial Direhorn
    [535] = "Primordial Direhorn",    -- Slate Primordial Direhorn
    [536] = "Primordial Direhorn",    -- Jade Primordial Direhorn
    [545] = "Primordial Direhorn",    -- Golden Primal Direhorn
    [546] = "Primordial Direhorn",    -- Crimson Primal Direhorn
    [1038] = "Primordial Direhorn",    -- Zandalari Direhorn
    [1179] = "Primordial Direhorn",    -- Palehide Direhorn
    [1249] = "Primordial Direhorn",    -- Child of Torcali


    -- ========================================================
    -- DIRIGIBLES
    -- ========================================================


    [962] = "Darkmoon Dirigible",    -- Darkmoon Dirigible


    [2144] = "Dirigible",    -- Delver's Dirigible
    [2296] = "Dirigible",    -- Delver's Gob-Trotter
    [2512] = "Dirigible",    -- Delver's Mana-Skimmer


    [960] = "Orgrimmar Interceptor",    -- Orgrimmar Interceptor


    [959] = "Stormwind Skychaser",    -- Stormwind Skychaser


    -- ========================================================
    -- DRAGONHAWKS
    -- ========================================================


    [549] = "Armored Blue Dragonhawk",    -- Armored Blue Dragonhawk


    [548] = "Armored Red Dragonhawk",    -- Armored Red Dragonhawk


    [291] = "Dragonhawk",    -- Blue Dragonhawk
    [292] = "Dragonhawk",    -- Red Dragonhawk
    [293] = "Dragonhawk",    -- Illidari Doomhawk
    [330] = "Dragonhawk",    -- Sunreaver Dragonhawk
    [412] = "Dragonhawk",    -- Amani Dragonhawk
    [778] = "Dragonhawk",    -- Eclipse Dragonhawk


    [2567] = "Infused Dragonhawk",    -- Voidwing Dragonhawk
    [2568] = "Infused Dragonhawk",    -- Lightwing Dragonhawk
    [2598] = "Infused Dragonhawk",    -- Voidlight Surger


    [1471] = "Vengeance",    -- Vengeance


    -- ========================================================
    -- DRAKES
    -- ========================================================

    [246] = "Drake",    -- Azure Drake
    [247] = "Drake",    -- Blue Drake
    [248] = "Drake",    -- Bronze Drake
    [249] = "Drake",    -- Red Drake
    [250] = "Drake",    -- Twilight Drake
    [253] = "Drake",    -- Black Drake
    [268] = "Drake",    -- Albino Drake
    [408] = "Drake",    -- Mottled Drake
    [445] = "Drake",    -- Experiment 12-B
    [664] = "Drake",    -- Emerald Drake
    [1175] = "Drake",    -- Twilight Avenger
    [2473] = "Drake",    -- Broodling of Sinestra


    [392] = "Drake of the Wind",    -- Drake of the East Wind
    [394] = "Drake of the Wind",    -- Drake of the West Wind
    [395] = "Drake of the Wind",    -- Drake of the North Wind
    [396] = "Drake of the Wind",    -- Drake of the South Wind
    [1314] = "Drake of the Wind",    -- Drake of the Four Winds


    [447] = "Feldrake",    -- Feldrake


    [551] = "Fey Dragon",    -- Enchanted Fey Dragon
    [1830] = "Fey Dragon",    -- Flourishing Whimsydrake
    [1954] = "Fey Dragon",    -- Flourishing Whimsydrake


    [1660] = "Gladiator's Drake (PVP)",    -- Crimson Gladiator's Drake
    [1822] = "Gladiator's Drake (PVP)",    -- Draconic Gladiator's Drake


    [424] = "Gladiator's Twilight Drake (PVP)",    -- Vicious Gladiator's Twilight Drake
    [428] = "Gladiator's Twilight Drake (PVP)",    -- Ruthless Gladiator's Twilight Drake
    [467] = "Gladiator's Twilight Drake (PVP)",    -- Cataclysmic Gladiator's Twilight Drake


    [1563] = "Highland Drake",    -- Highland Drake
    [1605] = "Highland Drake",    -- Dragon Isles Drake Model Test
    [1607] = "Highland Drake",    -- Swift Spectral Drake
    [1771] = "Highland Drake",    -- Highland Drake


    [442] = "Horned Drake",    -- Blazing Drake
    [443] = "Horned Drake",    -- Twilight Harbinger
    [444] = "Horned Drake",    -- Life-Binder's Handmaiden


    [781] = "Infinite Timereaver",    -- Infinite Timereaver
    [2518] = "Chrono Corsair",    -- Chrono Corsair

    [349] = "Onyxian Drake",    -- Onyxian Drake


    [883] = "Smoldering Ember Wyrm",    -- Smoldering Ember Wyrm


    [1346] = "Steamscale Incinerator",    -- Steamscale Incinerator


    [391] = "Stone Drake",    -- Volcanic Stone Drake
    [393] = "Stone Drake",    -- Phosphorescent Stone Drake
    [397] = "Stone Drake",    -- Vitreous Stone Drake
    [407] = "Stone Drake",    -- Sandstone Drake


    [1223] = "Sylverian Dreamer",    -- Sylverian Dreamer


    [1556] = "Tangled Dreamweaver",    -- Tangled Dreamweaver


    [1727] = "Tarecgosa's Visage",    -- Tarecgosa's Visage


    [1265] = "Voidwing",    -- Uncorrupted Voidwing
    [2569] = "Voidwing",    -- Unbound Star-Eater
    [2606] = "Voidwing",    -- Royal Voidwing


    [1240] = "World Drake",    -- Obsidian Worldbreaker
    [1798] = "World Drake",    -- Azure Worldchiller


    -- ========================================================
    -- DREAD RAVENS
    -- ========================================================


    [753] = "Corrupted Dreadwing",    -- Corrupted Dreadwing


    [600] = "Dread Raven",    -- Dread Raven


    [2505] = "Kareshi Dread Raven",    -- Resplendent K'arroc
    [2549] = "Kareshi Dread Raven",    -- Umbral K'arroc
    [2550] = "Kareshi Dread Raven",    -- K'arroc Swiftwing
    [2552] = "Kareshi Dread Raven",    -- Lavender K'arroc


    [1350] = "Roc",    -- Colossal Slaughterclaw
    [1409] = "Roc",    -- Bonesewn Fleshroc
    [1410] = "Roc",    -- Hulking Deathroc
    [1411] = "Roc",    -- Predatory Plagueroc


    -- ========================================================
    -- ELDERHORNS
    -- ========================================================


    [2645] = "Crest-horn",    -- Kalu'ak Crest-Horn
    [2649] = "Crest-horn",    -- Sharktested Crest-Horn
    [2650] = "Crest-horn",    -- Floestrider Crest-Horn
    [2651] = "Crest-horn",    -- Cragstepper Crest-Horn


    [854] = "Elderhorn",    -- Great Northern Elderhorn
    [941] = "Elderhorn",    -- Highmountain Elderhorn
    [1209] = "Elderhorn",    -- Stonehide Elderhorn
    [2665] = "Elderhorn",    -- Highland Elderhorn


    [1007] = "Highmountain Thunderhoof",    -- Highmountain Thunderhoof


    -- ========================================================
    -- ELEKKS
    -- ========================================================


    [165] = "Armored Elekk",    -- Great Green Elekk
    [166] = "Armored Elekk",    -- Great Blue Elekk
    [167] = "Armored Elekk",    -- Great Purple Elekk
    [220] = "Armored Elekk",    -- Black War Elekk
    [299] = "Armored Elekk",    -- Exodar Elekk
    [318] = "Armored Elekk",    -- Great Red Elekk


    [618] = "Armored Irontusk",    -- Armored Irontusk


    [147] = "Elekk",    -- Brown Elekk
    [163] = "Elekk",    -- Gray Elekk
    [164] = "Elekk",    -- Purple Elekk


    [614] = "Elekk Draenor",    -- Mottled Meadowstomper
    [615] = "Elekk Draenor",    -- Trained Meadowstomper
    [616] = "Elekk Draenor",    -- Shadowhide Pearltusk
    [617] = "Elekk Draenor",    -- Dusty Rockhide
    [1242] = "Elekk Draenor",    -- Beastlord's Irontusk


    [367] = "Exarch's Elekk",    -- Exarch's Elekk


    [2618] = "Fel Elekk",    -- Thunder-ridged Elekk
    [2619] = "Fel Elekk",    -- Cinder-seared Elekk
    [2620] = "Fel Elekk",    -- Void-Razed Elekk
    [2621] = "Fel Elekk",    -- Legion Forged Elekk


    [368] = "Great Exarch's Elekk",    -- Great Exarch's Elekk
    [824] = "Great Exarch's Elekk",    -- Great Exarch's Elekk


    [983] = "Lightforged Elekk",    -- Glorious Felcrusher
    [984] = "Lightforged Elekk",    -- Blessed Felcrusher
    [985] = "Lightforged Elekk",    -- Avenging Felcrusher
    [1006] = "Lightforged Elekk",    -- Lightforged Felcrusher


    [844] = "Vicious War Elekk (PVP)",    -- Vicious War Elekk


    -- ========================================================
    -- ELEMENTAL HAWKS
    -- ========================================================


    [2478] = "Blazing Royal Fire Hawk",    -- Blazing Royal Fire Hawk


    [415] = "Fire Hawk",    -- Pureblood Fire Hawk
    [416] = "Fire Hawk",    -- Felfire Hawk
    [417] = "Fire Hawk",    -- Corrupted Fire Hawk


    -- ========================================================
    -- ELEMENTALS
    -- ========================================================


    [1517] = "Bound Blizzard",    -- Bound Blizzard


    [2566] = "Cascade",    -- Lana'thel's Crimson Cascade


    [1405] = "Deathwalker",    -- Restoration Deathwalker
    [1419] = "Deathwalker",    -- Sintouched Deathwalker
    [1520] = "Deathwalker",    -- Soultwisted Deathwalker
    [1544] = "Deathwalker",    -- Wastewarped Deathwalker


    [2729] = "Farseer's Raging Tempest",    -- Farseer's Felscorned Tempest


    [888] = "Farseer's Raging Tempest",    -- Farseer's Raging Tempest


    [1219] = "Glacial Tidestorm",    -- Glacial Tidestorm


    [1812] = "Runebound Firelord",    -- Runebound Firelord


    [2190] = "Shadow",    -- Shadow of Doubt
    [2191] = "Shadow",    -- Shackled Shadow
    [2192] = "Shadow",    -- Beledar's Spawn


    -- ========================================================
    -- FELSTALKERS
    -- ========================================================


    [763] = "Felstalker",    -- Illidari Felstalker
    [2663] = "Felstalker",    -- Illidari Dreadstalker
    [2664] = "Felstalker",    -- Illidari Blightstalker


    -- ========================================================
    -- FLYERS
    -- ========================================================


    [2510] = "Kareshi Flyer",    -- Terror of the Wastes
    [2511] = "Kareshi Flyer",    -- Terror of the Night


    [2631] = "Void Infused Kareshi Flyer",    -- Scarlet Void Flyer
    [2633] = "Void Infused Kareshi Flyer",    -- Azure Void Flyer


    -- ========================================================
    -- FLYING CARPETS
    -- ========================================================


    [279] = "Flying Carpet",    -- Magnificent Flying Carpet
    [285] = "Flying Carpet",    -- Flying Carpet
    [375] = "Flying Carpet",    -- Frosty Flying Carpet
    [603] = "Flying Carpet",    -- Creeping Carpet
    [2317] = "Flying Carpet",    -- Enchanted Spellweave Carpet


    [905] = "Leywoven Flying Carpet",    -- Leywoven Flying Carpet


    [2023] = "Noble Flying Carpet",    -- Noble Flying Carpet


    -- ========================================================
    -- FLYING DISCS
    -- ========================================================


    [2724] = "Archmage's Prismatic Disc",    -- Archmage's Felscorned Disc


    [860] = "Archmage's Prismatic Disc",    -- Archmage's Prismatic Disc


    [509] = "Cloud",    -- Red Flying Cloud
    [2060] = "Cloud",    -- Golden Discus
    [2063] = "Cloud",    -- Mogu Hazeblazer
    [2064] = "Cloud",    -- Sky Surfer


    [1959] = "Compass Rose",    -- Compass Rose


    [1446] = "Gearglider",    -- Tazavesh Gearglider
    [1481] = "Gearglider",    -- Cartel Master's Gearglider
    [1482] = "Gearglider",    -- Xy Trustee's Gearglider
    [1483] = "Gearglider",    -- Vandal's Gearglider


    -- ========================================================
    -- FLYING ELDERHORNS
    -- ========================================================


    [773] = "Grove Defiler",    -- Grove Defiler


    [764] = "Grove Warden",    -- Grove Warden


    [779] = "Spirit of Eche'ro",    -- Spirit of Eche'ro


    -- ========================================================
    -- FLYING FISHES
    -- ========================================================


    [800] = "Brinedeep Bottom-Feeder",    -- Brinedeep Bottom-Feeder


    [2186] = "Underlight Behemoth",    -- [PH] Blue Old God Fish Mount
    [2187] = "Underlight Behemoth",    -- Underlight Shorestalker
    [2188] = "Underlight Behemoth",    -- Kah, Legend of the Deep
    [2189] = "Underlight Behemoth",    -- Underlight Corrupted Behemoth


    [1692] = "Wondrous Wavewhisker",    -- Wondrous Wavewhisker


    -- ========================================================
    -- FLYING MACHINES
    -- ========================================================


    [1287] = "Explorer's Jungle Hopper",    -- Explorer's Jungle Hopper


    [205] = "Flying Machine",    -- Flying Machine


    [204] = "Turbo-Charged Flying Machine",    -- Turbo-Charged Flying Machine


    -- ========================================================
    -- FLYING HORSES
    -- ========================================================


    [1511] = "Ardenweald Courser",    -- Maelie, the Wanderer
    [2488] = "Ardenweald Courser",    -- Shimmermist Free Runner


    [1306] = "Armored Ardenweald Courser",    -- Swift Gloomhoof
    [1360] = "Armored Ardenweald Courser",    -- Shimmermist Runner


    [1307] = "Armored Bastion Courser",    -- Sundancer
    [1413] = "Armored Bastion Courser",    -- Dauntless Duskrunner


    [1426] = "Bastion Courser",    -- Ascended Skymane


    [1192] = "Bloodforged Courser (PVP)",    -- Prestigious Bloodforged Courser


    [942] = "Courser",    -- Wild Dreamrunner
    [961] = "Courser",    -- Lucid Nightmare
    [1190] = "Courser",    -- Pureheart Courser
    [2675] = "Courser",    -- Twilight Courser
    [2676] = "Courser",    -- Golden Sunrunner
    [2677] = "Courser",    -- Turquoise Courser
    [2678] = "Courser",    -- Gloomdark Nightmare
    [2706] = "Courser",    -- Brimstone Courser


    [168] = "Fiery Warhorse",    -- Fiery Warhorse


    [532] = "Ghastly Charger",    -- Ghastly Charger


    [2622] = "Headless Horseman's",    -- The Headless Horseman's Chilling Charger
    [2623] = "Headless Horseman's",    -- The Headless Horseman's Ghoulish Charger
    [2624] = "Headless Horseman's",    -- The Headless Horseman's Burning Charger
    [2625] = "Headless Horseman's",    -- The Headless Horseman's Hallowed Charger


    [219] = "Headless Horseman's Mount",    -- Headless Horseman's Mount


    [885] = "Highlord's Charger",    -- Highlord's Golden Charger
    [892] = "Highlord's Charger",    -- Highlord's Vengeful Charger
    [893] = "Highlord's Charger",    -- Highlord's Vigilant Charger
    [894] = "Highlord's Charger",    -- Highlord's Valorous Charger
    [987] = "Highlord's Charger",    -- Valorous Charger
    [989] = "Highlord's Charger",    -- Vengeful Charger
    [990] = "Highlord's Charger",    -- Vigilant Charger
    [991] = "Highlord's Charger",    -- Golden Charger
    [2726] = "Highlord's Charger",    -- Felscorned Highlord's Charger


    [552] = "Ironbound Wraithcharger",    -- Ironbound Wraithcharger


    [931] = "Netherlord's Accursed Wrathsteed",    -- Netherlord's Accursed Wrathsteed


    [898] = "Netherlord's Wrathsteed",    -- Netherlord's Chaotic Wrathsteed
    [930] = "Netherlord's Wrathsteed",    -- Netherlord's Brimstone Wrathsteed
    [2730] = "Netherlord's Wrathsteed",    -- Felscorned Netherlord's Dreadsteed


    [826] = "Prestigious Courser (PVP)",    -- Prestigious Bronze Courser
    [831] = "Prestigious Courser (PVP)",    -- Prestigious Royal Courser
    [832] = "Prestigious Courser (PVP)",    -- Prestigious Forest Courser
    [833] = "Prestigious Courser (PVP)",    -- Prestigious Ivory Courser
    [834] = "Prestigious Courser (PVP)",    -- Prestigious Azure Courser
    [836] = "Prestigious Courser (PVP)",    -- Prestigious Midnight Courser
    [2705] = "Prestigious Courser (PVP)",    -- Chestnut Courser


    [593] = "Warforged Nightmare",    -- Warforged Nightmare


    [523] = "Windsteed",    -- Swift Windsteed
    [2065] = "Windsteed",    -- Daystorm Windsteed
    [2067] = "Windsteed",    -- Forest Windsteed
    [2068] = "Windsteed",    -- Dashing Windsteed


    -- ========================================================
    -- FLYING SABERS
    -- ========================================================


    [881] = "Arcanist's Manasaber",    -- Arcanist's Manasaber


    [1577] = "Ash'adar",    -- Ash'adar, Harbinger of Dawn


    [864] = "Ban-Lu",    -- Ban-Lu, Grandmaster's Companion
    [2725] = "Ban-Lu",    -- Felscorned Grandmaster's Companion


    [451] = "Jeweled Panther",    -- Jeweled Onyx Panther
    [456] = "Jeweled Panther",    -- Sapphire Panther
    [457] = "Jeweled Panther",    -- Jade Panther
    [458] = "Jeweled Panther",    -- Ruby Panther
    [459] = "Jeweled Panther",    -- Sunstone Panther
    [2502] = "Jeweled Panther",    -- Void-Crystal Panther


    [949] = "Luminous Starseeker",    -- Luminous Starseeker


    [741] = "Mystic Runesaber",    -- Mystic Runesaber


    [455] = "Obsidian Nightwing",    -- Obsidian Nightwing


    [1531] = "Wen Lo",    -- Wen Lo, the River's Edge


    [421] = "Winged Guardian",    -- Winged Guardian


    -- ========================================================
    -- FOXES
    -- ========================================================


    [656] = "Fox",    -- Llothien Prowler
    [1949] = "Fox",    -- Gilnean Prowler


    [1393] = "Glimmerfur",    -- Wild Glimmerfur Prowler
    [1841] = "Glimmerfur",    -- Crimson Glimmerfur
    [2803] = "Glimmerfur",    -- Skypaw Glimmerfur
    [2815] = "Glimmerfur",    -- Snowpaw Glimmerfur Prowler


    [1956] = "Sky Fox",    -- Fur-endship Fox
    [1957] = "Sky Fox",    -- Soaring Sky Fox
    [1958] = "Sky Fox",    -- Twilight Sky Prowler


    [945] = "Vicious War Fox (PVP)",    -- Vicious War Fox
    [946] = "Vicious War Fox (PVP)",    -- Vicious War Fox


    [1222] = "Vulpine Familiar",    -- Vulpine Familiar


    -- ========================================================
    -- FURLINES
    -- ========================================================


    [2235] = "Startouched Furline",    -- Startouched Furline


    [1330] = "Sunwarmed Furline",    -- Sunwarmed Furline


    -- ========================================================
    -- GARGONS
    -- ========================================================


    [1299] = "Armored Gargon",    -- Battle Gargon Vrednic
    [1387] = "Armored Gargon",    -- Desire's Battle Gargon
    [1388] = "Armored Gargon",    -- Gravestone Battle Gargon
    [1389] = "Armored Gargon",    -- Battle Gargon Silessa


    [1298] = "Gargon",    -- Hopecrusher Gargon
    [1382] = "Gargon",    -- Inquisition Gargon
    [1384] = "Gargon",    -- Sinfall Gargon
    [1385] = "Gargon",    -- Crypt Gargon


    -- ========================================================
    -- GOBLIN TRIKES
    -- ========================================================


    [388] = "Goblin Trike",    -- Goblin Trike


    [389] = "Goblin Turbo-Trike",    -- Goblin Turbo-Trike


    [842] = "Vicious War Trike (PVP)",    -- Vicious War Trike


    -- ========================================================
    -- GORMS
    -- ========================================================


    [1305] = "Gorm",    -- Darkwarren Hardshell
    [1362] = "Gorm",    -- Spinemaw Gladechewer
    [1392] = "Gorm",    -- Pale Acidmaw
    [1420] = "Gorm",    -- Umbral Scythehorn
    [1476] = "Gorm",    -- Wild Hunt Legsplitter


    [1459] = "Vicious War Gorm (PVP)",    -- Vicious War Gorm
    [1460] = "Vicious War Gorm (PVP)",    -- Vicious War Gorm


    -- ========================================================
    -- GRINDERS
    -- ========================================================


    [2802] = "Geargrinder",    -- Geargrinder Mk. 11


    [1193] = "Meat Wagon",    -- Meat Wagon


    -- ========================================================
    -- GRONNLINGS
    -- ========================================================


    [759] = "Felblood Gronnling (PVP)",    -- Primal Gladiator's Felblood Gronnling
    [760] = "Felblood Gronnling (PVP)",    -- Wild Gladiator's Felblood Gronnling
    [761] = "Felblood Gronnling (PVP)",    -- Warmongering Gladiator's Felblood Gronnling


    [607] = "Gronnling",    -- Gorestrider Gronnling
    [655] = "Gronnling",    -- Sunhide Gronnling
    [762] = "Gronnling",    -- Coalfist Gronnling


    -- ========================================================
    -- GROUND RAVENS
    -- ========================================================


    [185] = "Raven Lord",    -- Raven Lord


    -- ========================================================
    -- GROUNDED RAVENS
    -- ========================================================


    [425] = "Elemental Raven",    -- Flametalon of Alysrazor
    [682] = "Elemental Raven",    -- Voidtalon of the Dark Star
    [1191] = "Elemental Raven",    -- Frenzied Feltalon


    -- ========================================================
    -- GRYPHONS
    -- ========================================================


    [1266] = "Alabaster Stormtalon",    -- Alabaster Stormtalon


    [2626] = "Algari Gryphon",    -- Adorned Northeron Gryphon
    [2627] = "Algari Gryphon",    -- High Shaman's Aerie Gryphon
    [2628] = "Algari Gryphon",    -- Cinder-Plumed Highland Gryphon
    [2629] = "Algari Gryphon",    -- Emberwing Sky Guide


    [1792] = "Algarian Stormrider",    -- Algarian Stormrider


    [2176] = "Alunira",    -- Alunira


    [132] = "Armored Gryphon",    -- Swift Blue Gryphon
    [137] = "Armored Gryphon",    -- Swift Red Gryphon
    [138] = "Armored Gryphon",    -- Swift Green Gryphon
    [139] = "Armored Gryphon",    -- Swift Purple Gryphon
    [276] = "Armored Gryphon",    -- Armored Snowy Gryphon


    [2304] = "Chaos-Forged Gryphon",    -- Chaos-Forged Gryphon


    [526] = "Grand Armored Gryphon",    -- Grand Armored Gryphon
    [1062] = "Grand Armored Gryphon",    -- Dusky Waycrest Gryphon
    [1063] = "Grand Armored Gryphon",    -- Stormsong Coastwatcher
    [1064] = "Grand Armored Gryphon",    -- Proudmoore Sea Scout
    [1271] = "Grand Armored Gryphon",    -- Swift Spectral Armored Gryphon
    [1773] = "Grand Armored Gryphon",    -- Harbor Gryphon


    [528] = "Grand Gryphon",    -- Grand Gryphon
    [1777] = "Grand Gryphon",    -- Ravenous Black Gryphon
    [2496] = "Grand Gryphon",    -- Void-Scarred Gryphon


    [129] = "Gryphon",    -- Golden Gryphon
    [130] = "Gryphon",    -- Ebon Gryphon
    [131] = "Gryphon",    -- Snowy Gryphon
    [2116] = "Gryphon",    -- Remembered Golden Gryphon


    [440] = "Spectral Gryphon",    -- Spectral Gryphon


    [238] = "Swift Spectral Gryphon",    -- Swift Spectral Gryphon


    [236] = "Winged Steed of the Ebon Blade",    -- Winged Steed of the Ebon Blade


    -- ========================================================
    -- HAWKS
    -- ========================================================


    [2525] = "Great Raven",    -- Prophet's Great Raven
    [2529] = "Great Raven",    -- Archmage's Great Raven


    [2035] = "Peafowl",    -- Majestic Azure Peafowl
    [2036] = "Peafowl",    -- Brilliant Sunburst Peafowl


    [1430] = "Progenitor Hawk",    -- Desertwing Hunter
    [1536] = "Progenitor Hawk",    -- Mawdapted Raptora
    [1537] = "Progenitor Hawk",    -- Raptora Swooper


    [1456] = "Skyblazer",    -- Sapphire Skyblazer
    [2261] = "Skyblazer",    -- Coldflame Tempest


    -- ========================================================
    -- HAWKSTRIDERS
    -- ========================================================


    [146] = "Armored Hawkstrider",    -- Swift Pink Hawkstrider
    [160] = "Armored Hawkstrider",    -- Swift Green Hawkstrider
    [161] = "Armored Hawkstrider",    -- Swift Purple Hawkstrider
    [162] = "Armored Hawkstrider",    -- Swift Warstrider
    [213] = "Armored Hawkstrider",    -- Swift White Hawkstrider
    [302] = "Armored Hawkstrider",    -- Silvermoon Hawkstrider
    [320] = "Armored Hawkstrider",    -- Swift Red Hawkstrider
    [332] = "Armored Hawkstrider",    -- Sunreaver Hawkstrider


    [152] = "Hawkstrider",    -- Red Hawkstrider
    [157] = "Hawkstrider",    -- Purple Hawkstrider
    [158] = "Hawkstrider",    -- Blue Hawkstrider
    [159] = "Hawkstrider",    -- Black Hawkstrider
    [877] = "Hawkstrider",    -- Ivory Hawkstrider
    [1600] = "Hawkstrider",    -- Elusive Emerald Hawkstrider


    [1009] = "Starcursed Voidstrider",    -- Starcursed Voidstrider


    [2696] = "Turkeys",    -- Highlands Gobbler
    [2697] = "Turkeys",    -- Quirky Turkey
    [2698] = "Turkeys",    -- Murky Turkey
    [2699] = "Turkeys",    -- Prized Turkey


    [843] = "Vicious Warstrider (PVP)",    -- Vicious Warstrider


    -- ========================================================
    -- HIPPOGRYPHS
    -- ========================================================


    [203] = "Armored Hippogryph",    -- Cenarion War Hippogryph
    [305] = "Armored Hippogryph",    -- Argent Hippogryph
    [329] = "Armored Hippogryph",    -- Silver Covenant Hippogryph
    [802] = "Armored Hippogryph",    -- Long-Forgotten Hippogryph
    [2224] = "Armored Hippogryph",    -- Frayfeather Hippogryph


    [371] = "Blazing Hippogryph",    -- Blazing Hippogryph


    [2305] = "Chaos-Forged Hippogryph",    -- Chaos-Forged Hippogryph


    [433] = "Corrupted Hippogryph",    -- Corrupted Hippogryph


    [568] = "Emerald Hippogryph",    -- Emerald Hippogryph


    [413] = "Flameward Hippogryph",    -- Flameward Hippogryph


    [934] = "Hippogryph",    -- Swift Spectral Hippogryph
    [943] = "Hippogryph",    -- Cloudwing Hippogryph
    [1521] = "Hippogryph",    -- Val'sharah Hippogryph


    [846] = "Leyfeather Hippogryph",    -- Leyfeather Hippogryph


    [1054] = "Teldrassil Hippogryph",    -- Teldrassil Hippogryph


    -- ========================================================
    -- HORSES
    -- ========================================================


    [75] = "Armored Horse",    -- Black War Steed
    [91] = "Armored Horse",    -- Swift Palomino
    [92] = "Armored Horse",    -- Swift White Steed
    [93] = "Armored Horse",    -- Swift Brown Steed
    [294] = "Armored Horse",    -- Stormwind Steed
    [321] = "Armored Horse",    -- Swift Gray Steed
    [343] = "Armored Horse",    -- Swift Alliance Steed


    [84] = "Armored Warhorse",    -- Charger
    [149] = "Armored Warhorse",    -- Thalassian Charger
    [338] = "Armored Warhorse",    -- Argent Charger
    [767] = "Armored Warhorse",    -- Charger
    [786] = "Armored Warhorse",    -- Charger
    [825] = "Armored Warhorse",    -- Thalassian Charger


    [2572] = "Banshee's Charger",    -- Banshee's Chilling Charger
    [2579] = "Banshee's Charger",    -- Forsaken's Grotesque Charger
    [2580] = "Banshee's Charger",    -- Wailing Banshee's Charger
    [2581] = "Banshee's Charger",    -- Banshee's Sickening Charger


    [1245] = "Bloodflank Charger",    -- Bloodflank Charger


    [344] = "Crusader's Warhorse",    -- Crusader's White Warhorse
    [345] = "Crusader's Warhorse",    -- Crusader's Black Warhorse


    [2481] = "Darkmoon Charger",    -- Midnight Darkmoon Charger
    [2482] = "Darkmoon Charger",    -- Lively Darkmoon Charger
    [2483] = "Darkmoon Charger",    -- Violet Darkmoon Charger
    [2484] = "Darkmoon Charger",    -- Snowy Darkmoon Charger


    [221] = "Deathcharger",    -- Acherus Deathcharger
    [366] = "Deathcharger",    -- Crimson Deathcharger


    [83] = "Dreadsteed",    -- Dreadsteed


    [17] = "Felsteed",    -- Felsteed


    [6] = "Horse",    -- Brown Horse
    [8] = "Horse",    -- White Stallion
    [9] = "Horse",    -- Black Stallion
    [11] = "Horse",    -- Pinto
    [18] = "Horse",    -- Chestnut Mare
    [52] = "Horse",    -- Palomino
    [53] = "Horse",    -- White Stallion


    [1198] = "Kul Tiran Charger",    -- Kul Tiran Charger


    [1416] = "Mawsworn Horse",    -- Mawsworn Charger
    [1500] = "Mawsworn Horse",    -- Sanctum Gloomcharger
    [1501] = "Mawsworn Horse",    -- Soulbound Gloomcharger
    [1502] = "Mawsworn Horse",    -- Fallen Charger


    [435] = "Mountain Horse",    -- Mountain Horse
    [436] = "Mountain Horse",    -- Swift Mountain Horse


    [1010] = "Saddled Horse",    -- Admiralty Stallion
    [1015] = "Saddled Horse",    -- Dapple Gray
    [1016] = "Saddled Horse",    -- Smoky Charger
    [1018] = "Saddled Horse",    -- Terrified Pack Mule
    [1019] = "Saddled Horse",    -- Goldenmane
    [1173] = "Saddled Horse",    -- Broken Highland Mustang
    [1174] = "Saddled Horse",    -- Highland Mustang
    [1182] = "Saddled Horse",    -- Lil' Donkey
    [1414] = "Saddled Horse",    -- Sinrunner Blanchy
    [1421] = "Saddled Horse",    -- Court Sinrunner
    [2497] = "Saddled Horse",    -- Void-Forged Stallion


    [996] = "Seabraid Stallion",    -- Seabraid Stallion


    [405] = "Spectral Steed",    -- Spectral Steed


    [841] = "Vicious Gilnean Warhorse (PVP)",    -- Vicious Gilnean Warhorse


    [422] = "War Steed (PVP)",    -- Vicious War Steed
    [775] = "War Steed (PVP)",    -- Prestigious War Steed


    [41] = "Warhorse",    -- Warhorse
    [150] = "Warhorse",    -- Thalassian Warhorse
    [341] = "Warhorse",    -- Argent Warhorse


    [222] = "Zhevra",    -- Swift Zhevra
    [224] = "Zhevra",    -- Swift Zhevra
    [331] = "Zhevra",    -- Quel'dorei Steed


    -- ========================================================
    -- HYENAS
    -- ========================================================


    [1286] = "Caravan Hyena",    -- Caravan Hyena


    [2272] = "Cartel Hyena",    -- Crimson Armored Growler
    [2274] = "Cartel Hyena",    -- Blackwater Bonecrusher
    [2276] = "Cartel Hyena",    -- Darkfuse Chompactor
    [2277] = "Cartel Hyena",    -- Violet Armored Growler


    [926] = "Hyena",    -- Alabaster Hyena
    [928] = "Hyena",    -- Dune Scavenger


    -- ========================================================
    -- JELLYFISHES
    -- ========================================================


    [838] = "Jelly",    -- Fathom Dweller
    [982] = "Jelly",    -- Pond Nettle
    [1169] = "Jelly",    -- Surf Jelly


    [1293] = "Ny'alotha Allseer",    -- Ny'alotha Allseer


    [1434] = "Progenitor Aurelid",    -- Deepstar Aurelid
    [1549] = "Progenitor Aurelid",    -- Shimmering Aurelid
    [1550] = "Progenitor Aurelid",    -- Depthstalker
    [1551] = "Progenitor Aurelid",    -- Cryptic Aurelid


    -- ========================================================
    -- KITE
    -- ========================================================


    [450] = "Kite",    -- Pandaren Kite
    [516] = "Kite",    -- Pandaren Kite
    [521] = "Kite",    -- Jade Pandaren Kite
    [2069] = "Kite",    -- Feathered Windsurfer


    [1602] = "Tuskarr Shoreglider",    -- Tuskarr Shoreglider


    -- ========================================================
    -- KODOS
    -- ========================================================


    [76] = "Armored Kodo",    -- Black War Kodo
    [101] = "Armored Kodo",    -- Great White Kodo
    [102] = "Armored Kodo",    -- Great Gray Kodo
    [103] = "Armored Kodo",    -- Great Brown Kodo
    [226] = "Armored Kodo",    -- Great Brewfest Kodo
    [301] = "Armored Kodo",    -- Thunder Bluff Kodo
    [322] = "Armored Kodo",    -- Great Golden Kodo


    [1583] = "Armored Siege Kodo",    -- Armored Siege Kodo


    [225] = "Brewfest Kodo",    -- Brewfest Riding Kodo


    [351] = "Great Sunwalker Kodo",    -- Great Sunwalker Kodo
    [823] = "Great Sunwalker Kodo",    -- Great Sunwalker Kodo


    [70] = "Kodo",    -- Riding Kodo
    [71] = "Kodo",    -- Gray Kodo
    [72] = "Kodo",    -- Brown Kodo
    [73] = "Kodo",    -- Green Kodo
    [74] = "Kodo",    -- Teal Kodo
    [309] = "Kodo",    -- White Kodo
    [1201] = "Kodo",    -- Frightened Kodo


    [350] = "Sunwalker Kodo",    -- Sunwalker Kodo


    [756] = "Vicious War Kodo (PVP)",    -- Vicious War Kodo


    -- ========================================================
    -- LIONS
    -- ========================================================


    [1399] = "Eternal Phalynx",    -- Eternal Phalynx of Purity
    [1400] = "Eternal Phalynx",    -- Eternal Phalynx of Courage
    [1401] = "Eternal Phalynx",    -- Eternal Phalynx of Loyalty
    [1402] = "Eternal Phalynx",    -- Eternal Phalynx of Humility


    [403] = "Golden King",    -- Golden King


    [1404] = "Larion",    -- Silverwind Larion
    [1423] = "Larion",    -- Highwind Darkmane
    [1425] = "Larion",    -- Gilded Prowler


    [1394] = "Phalynx",    -- Phalynx of Loyalty
    [1395] = "Phalynx",    -- Phalynx of Humility
    [1396] = "Phalynx",    -- Phalynx of Courage
    [1398] = "Phalynx",    -- Phalynx of Purity


    [876] = "Vicious War Lion (PVP)",    -- Vicious War Lion


    -- ========================================================
    -- LUPINES
    -- ========================================================


    [1580] = "Heartbond Lupine",    -- Heartbond Lupine
    [2804] = "Heartbond Lupine",    -- Crimson Lupine


    [1465] = "Vicious Warstalker (PVP)",    -- Vicious Warstalker
    [1466] = "Vicious Warstalker (PVP)",    -- Vicious Warstalker


    -- ========================================================
    -- MAMMOTHS
    -- ========================================================


    [273] = "Grand Mammoth",    -- Grand Caravan Mammoth
    [274] = "Grand Mammoth",    -- Grand Caravan Mammoth
    [280] = "Grand Mammoth",    -- Traveler's Tundra Mammoth
    [284] = "Grand Mammoth",    -- Traveler's Tundra Mammoth
    [286] = "Grand Mammoth",    -- Grand Black War Mammoth
    [287] = "Grand Mammoth",    -- Grand Black War Mammoth
    [288] = "Grand Mammoth",    -- Grand Ice Mammoth
    [289] = "Grand Mammoth",    -- Grand Ice Mammoth


    [1603] = "Magmammoth",    -- Subterranean Magmammoth
    [1612] = "Magmammoth",    -- Loyal Magmammoth
    [1644] = "Magmammoth",    -- Raging Magmammoth
    [1645] = "Magmammoth",    -- Renewed Magmammoth
    [1938] = "Magmammoth",    -- Mammyth


    [254] = "Mammoth",    -- Black War Mammoth
    [255] = "Mammoth",    -- Black War Mammoth
    [256] = "Mammoth",    -- Wooly Mammoth
    [257] = "Mammoth",    -- Wooly Mammoth
    [258] = "Mammoth",    -- Ice Mammoth
    [259] = "Mammoth",    -- Ice Mammoth


    [1633] = "Trawling Mammoth",    -- Bestowed Trawling Mammoth
    [1634] = "Trawling Mammoth",    -- Mossy Mammoth
    [1635] = "Trawling Mammoth",    -- Plainswalker Bearer


    -- ========================================================
    -- MECHAHEADS
    -- ========================================================


    [1028] = "Mecha-Mogul Mk2",    -- Mecha-Mogul Mk2


    [304] = "Mimiron's Head",    -- Mimiron's Head


    [2487] = "The Big G",    -- The Big G


    -- ========================================================
    -- MECHANOSTRIDERS
    -- ========================================================


    [77] = "Armored Mechanostrider",    -- Black Battlestrider
    [88] = "Armored Mechanostrider",    -- Swift Yellow Mechanostrider
    [89] = "Armored Mechanostrider",    -- Swift White Mechanostrider
    [90] = "Armored Mechanostrider",    -- Swift Green Mechanostrider
    [298] = "Armored Mechanostrider",    -- Gnomeregan Mechanostrider
    [323] = "Armored Mechanostrider",    -- Turbostrider


    [1283] = "Mechagon Mechanostrider",    -- Mechagon Mechanostrider


    [39] = "Mechanostrider",    -- Red Mechanostrider
    [40] = "Mechanostrider",    -- Blue Mechanostrider
    [42] = "Mechanostrider",    -- White Mechanostrider Mod B
    [43] = "Mechanostrider",    -- Green Mechanostrider
    [57] = "Mechanostrider",    -- Green Mechanostrider
    [58] = "Mechanostrider",    -- Unpainted Mechanostrider
    [62] = "Mechanostrider",    -- Icy Blue Mechanostrider Mod A
    [145] = "Mechanostrider",    -- Blue Mechanostrider


    [755] = "Vicious War Mechanostrider (PVP)",    -- Vicious War Mechanostrider


    -- ========================================================
    -- MECHASPIDERS
    -- ========================================================


    [1552] = "Carcinized Zerethsteed",    -- Carcinized Zerethsteed


    [1229] = "Mechaspider",    -- Rusty Mechanocrawler
    [1252] = "Mechaspider",    -- Mechagon Peacekeeper
    [1253] = "Mechaspider",    -- Scrapforged Mechaspider


    [2480] = "Shreddertank",    -- Crimson Shreddertank
    [2508] = "Shreddertank",    -- Enterprising Shreddertank


    -- ========================================================
    -- MECHSUITS
    -- ========================================================


    [2286] = "Cartel Mechasuit",    -- Blackwater Shredder Deluxe Mk 2
    [2287] = "Cartel Mechasuit",    -- Darkfuse Demolisher
    [2288] = "Cartel Mechasuit",    -- Personalized Goblin S.C.R.A.P.per
    [2289] = "Cartel Mechasuit",    -- Venture Co-ordinator
    [2290] = "Cartel Mechasuit",    -- Asset Advocator
    [2303] = "Cartel Mechasuit",    -- Violet Goblin Shredder


    [2244] = "Diamond Mechsuit",    -- Diamond Mechsuit
    [2608] = "Diamond Mechsuit",    -- Light-Forged Mechsuit


    [2119] = "Dwarven Mechsuit",    -- Stonevault Mechsuit
    [2158] = "Dwarven Mechsuit",    -- Crowd Pummeler 2-30
    [2159] = "Dwarven Mechsuit",    -- Machine Defense Unit 1-11


    [751] = "Felsteel Annihilator",    -- Felsteel Annihilator


    [1217] = "G.M.O.D.",    -- G.M.O.D.


    [932] = "Lightforged Warframe",    -- Lightforged Warframe


    [2313] = "Magnetomech",    -- Junkmaestro's Magnetomech


    [2604] = "OC91 Chariot",    -- OC91 Chariot


    [1698] = "Rocket Shredder 9001",    -- Rocket Shredder 9001


    [522] = "Sky Golem",    -- Sky Golem
    [845] = "Sky Golem",    -- Mechanized Lumber Extractor


    -- ========================================================
    -- MOLES
    -- ========================================================


    [2204] = "Fancy Mole",    -- Wick
    [2205] = "Fancy Mole",    -- Ol' Mole Rufus


    [2209] = "Mole",    -- Crimson Mudnose


    -- ========================================================
    -- MOONBEASTS
    -- ========================================================


    [1699] = "Gleaming Moonbeast",    -- Gleaming Moonbeast


    [1819] = "Vicious Moonbeast (PVP)",    -- Vicious Moonbeast
    [1820] = "Vicious Moonbeast (PVP)",    -- Vicious Moonbeast


    -- ========================================================
    -- NETHER DRAKES
    -- ========================================================


    [1744] = "Grotto Netherwing Drake",    -- Grotto Netherwing Drake
    [1953] = "Grotto Netherwing Drake",    -- Grotto Netherwing Drake


    [16] = "Nether Drake",    -- Nether Drake
    [123] = "Nether Drake",    -- Nether Drake
    [186] = "Nether Drake",    -- Onyx Netherwing Drake
    [187] = "Nether Drake",    -- Azure Netherwing Drake
    [188] = "Nether Drake",    -- Cobalt Netherwing Drake
    [189] = "Nether Drake",    -- Purple Netherwing Drake
    [190] = "Nether Drake",    -- Veridian Netherwing Drake
    [191] = "Nether Drake",    -- Violet Netherwing Drake


    [169] = "Nether Drake (PVP)",    -- Swift Nether Drake
    [206] = "Nether Drake (PVP)",    -- Merciless Nether Drake
    [207] = "Nether Drake (PVP)",    -- Merciless Nether Drake
    [223] = "Nether Drake (PVP)",    -- Vengeful Nether Drake
    [241] = "Nether Drake (PVP)",    -- Brutal Nether Drake


    -- ========================================================
    -- OHUNAS
    -- ========================================================


    [1545] = "Divine Kiss of Ohn'ahra",    -- Divine Kiss of Ohn'ahra


    [1669] = "Ohuna",    -- Bestowed Ohuna Spotter
    [1671] = "Ohuna",    -- Duskwing Ohuna
    [1672] = "Ohuna",    -- Zenet Hatchling


    -- ========================================================
    -- OTTUKS
    -- ========================================================


    [1651] = "Armored Ottuk",    -- Bestowed Ottuk Vanguard
    [1653] = "Armored Ottuk",    -- Brown War Ottuk
    [1654] = "Armored Ottuk",    -- Otterworldly Ottuk Carrier
    [1655] = "Armored Ottuk",    -- Yellow War Ottuk


    [1546] = "Ottuk",    -- Iskaara Trader's Ottuk
    [1656] = "Ottuk",    -- Otto
    [1657] = "Ottuk",    -- Brown Scouting Ottuk
    [1658] = "Ottuk",    -- Ivory Trader's Ottuk
    [1659] = "Ottuk",    -- Yellow Scouting Ottuk
    [1837] = "Ottuk",    -- Delugen


    -- ========================================================
    -- OWLS
    -- ========================================================


    [1818] = "Anu'relos",    -- Anu'relos, Flame's Guidance


    [2140] = "Charming Courier",    -- Charming Courier


    -- ========================================================
    -- OXES
    -- ========================================================


    [2632] = "Astral Aurochs",    -- Astral Aurochs


    [1291] = "Lucky Yun",    -- Lucky Yun


    -- ========================================================
    -- PHOENIXES
    -- ========================================================


    [183] = "Ashes of Al'ar",    -- Ashes of Al'ar


    [543] = "Clutch of..",    -- Clutch of Ji-Kun
    [1297] = "Clutch of..",    -- Clutch of Ha-Li


    [401] = "Dark Phoenix",    -- Dark Phoenix


    [2255] = "Golden Ashes of Al'ar",    -- Golden Ashes of Al'ar


    [503] = "Pandaren Phoenix",    -- Crimson Pandaren Phoenix
    [518] = "Pandaren Phoenix",    -- Ashen Pandaren Phoenix
    [519] = "Pandaren Phoenix",    -- Emerald Pandaren Phoenix
    [520] = "Pandaren Phoenix",    -- Violet Pandaren Phoenix
    [2142] = "Pandaren Phoenix",    -- August Phoenix


    -- ========================================================
    -- PLAGUEBATS
    -- ========================================================


    [1596] = "Amalgam of Rage",    -- Amalgam of Rage


    [971] = "Antoran flying hound",    -- Antoran Charhound
    [972] = "Antoran flying hound",    -- Antoran Gloomhound


    [2540] = "Demonic Fel Bat (Legion Remix)",    -- Bloodguard Fel Bat
    [2543] = "Demonic Fel Bat (Legion Remix)",    -- Risen Fel Bat
    [2545] = "Demonic Fel Bat (Legion Remix)",    -- Forgotten Fel Bat


    [1049] = "Fel Bat",    -- Undercity Plaguebat


    [2542] = "Fel Bat (Legion Remix)",    -- Bloodhunter Fel Bat
    [2544] = "Fel Bat (Legion Remix)",    -- Ashplague Fel Bat
    [2546] = "Fel Bat (Legion Remix)",    -- Wretched Fel Bat


    [2218] = "Gladiator's Fel Bat (PVP)",    -- Forged Gladiator's Fel Bat
    [2298] = "Gladiator's Fel Bat (PVP)",    -- Prized Gladiator's Fel Bat
    [2326] = "Gladiator's Fel Bat (PVP)",    -- Astral Gladiator's Fel Bat


    [2532] = "Herald of Sa'bak",    -- Herald of Sa'bak


    [2219] = "Skyrazor",    -- Sureki Skyrazor
    [2220] = "Skyrazor",    -- Retrained Skyrazor
    [2222] = "Skyrazor",    -- Siesbarg
    [2223] = "Skyrazor",    -- Ascendant Skyrazor


    [868] = "Slayer's Felbroken Shrieker",    -- Slayer's Felbroken Shrieker
    [2721] = "Slayer's Felbroken Shrieker",    -- Slayer's Felscorned Shrieker


    -- ========================================================
    -- PROTO-DRAKES
    -- ========================================================


    [867] = "Battlelord's Bloodthirsty War Wyrm",    -- Battlelord's Bloodthirsty War Wyrm
    [2731] = "Battlelord's Bloodthirsty War Wyrm",    -- Felscorned War Wyrm


    [1679] = "Frostbrood Proto-Wyrm",    -- Frostbrood Proto-Wyrm


    [1030] = "Gladiator's Proto-Drake (PVP)",    -- Dread Gladiator's Proto-Drake
    [1031] = "Gladiator's Proto-Drake (PVP)",    -- Sinister Gladiator's Proto-Drake
    [1032] = "Gladiator's Proto-Drake (PVP)",    -- Notorious Gladiator's Proto-Drake
    [1035] = "Gladiator's Proto-Drake (PVP)",    -- Corrupted Gladiator's Proto-Drake


    [262] = "Proto-Drake",    -- Red Proto-Drake
    [263] = "Proto-Drake",    -- Black Proto-Drake
    [264] = "Proto-Drake",    -- Blue Proto-Drake
    [265] = "Proto-Drake",    -- Time-Lost Proto-Drake
    [266] = "Proto-Drake",    -- Plagued Proto-Drake
    [267] = "Proto-Drake",    -- Violet Proto-Drake
    [278] = "Proto-Drake",    -- Green Proto-Drake


    [306] = "Razorscale Proto-Drake",    -- Ironbound Proto-Drake
    [307] = "Razorscale Proto-Drake",    -- Rusted Proto-Drake


    [1589] = "Renewed Proto-Drake",    -- Renewed Proto-Drake
    [1786] = "Renewed Proto-Drake",    -- Renewed Proto-Drake


    [557] = "Spawn of Galakras",    -- Spawn of Galakras


    -- ========================================================
    -- PTERRORDAX
    -- ========================================================


    [958] = "Battle Pterrordax",    -- Spectral Pterrorwing
    [1043] = "Battle Pterrordax",    -- Kua'fon
    [1058] = "Battle Pterrordax",    -- Cobalt Pterrordax
    [1059] = "Battle Pterrordax",    -- Captured Swampstalker
    [1060] = "Battle Pterrordax",    -- Voldunai Dunescraper
    [1218] = "Battle Pterrordax",    -- Dazar'alor Windreaver
    [1272] = "Battle Pterrordax",    -- Swift Spectral Pterrordax
    [1586] = "Battle Pterrordax",    -- Armored Golden Pterrordax
    [1772] = "Battle Pterrordax",    -- Scarlet Pterrordax


    [530] = "Thunder Pterrordax",    -- Armored Skyscreamer
    [2081] = "Thunder Pterrordax",    -- Bloody Skyscreamer
    [2083] = "Thunder Pterrordax",    -- Night Pterrorwing
    [2084] = "Thunder Pterrordax",    -- Jade Pterrordax
    [2118] = "Thunder Pterrordax",    -- Amber Pterrordax


    [1590] = "Windborne Velocidrake",    -- Windborne Velocidrake
    [1787] = "Windborne Velocidrake",    -- Windborne Velocidrake


    -- ========================================================
    -- QIRAJIS
    -- ========================================================


    [594] = "Grinning Reaver",    -- Grinning Reaver


    [116] = "Qiraji Battle Tank",    -- Black Qiraji Battle Tank
    [117] = "Qiraji Battle Tank",    -- Blue Qiraji Battle Tank
    [118] = "Qiraji Battle Tank",    -- Red Qiraji Battle Tank
    [119] = "Qiraji Battle Tank",    -- Yellow Qiraji Battle Tank
    [120] = "Qiraji Battle Tank",    -- Green Qiraji Battle Tank
    [121] = "Qiraji Battle Tank",    -- Black Qiraji Battle Tank
    [122] = "Qiraji Battle Tank",    -- Black Qiraji Battle Tank
    [404] = "Qiraji Battle Tank",    -- Ultramarine Qiraji Battle Tank


    [935] = "Qiraji War Tank",    -- Blue Qiraji War Tank
    [936] = "Qiraji War Tank",    -- Red Qiraji War Tank
    [937] = "Qiraji War Tank",    -- Black Qiraji War Tank


    -- ========================================================
    -- QUILENS
    -- ========================================================


    [468] = "Flying Quilen",    -- Imperial Quilen
    [2474] = "Flying Quilen",    -- Copper-Maned Quilen


    [1178] = "Quilen",    -- Qinsho's Eternal Hound
    [1327] = "Quilen",    -- Ren's Stalwart Hound
    [1328] = "Quilen",    -- Xinlao
    [2070] = "Quilen",    -- Guardian Quilen
    [2071] = "Quilen",    -- Marble Quilen


    -- ========================================================
    -- RAMS
    -- ========================================================


    [78] = "Armored Ram",    -- Black War Ram
    [94] = "Armored Ram",    -- Swift Brown Ram
    [95] = "Armored Ram",    -- Swift Gray Ram
    [96] = "Armored Ram",    -- Swift White Ram
    [109] = "Armored Ram",    -- Stormpike Battle Charger
    [202] = "Armored Ram",    -- Swift Brewfest Ram
    [296] = "Armored Ram",    -- Ironforge Ram
    [324] = "Armored Ram",    -- Swift Violet Ram


    [1046] = "Darkforge Ram",    -- Darkforge Ram
    [1047] = "Darkforge Ram",    -- Dawnforge Ram
    [1069] = "Darkforge Ram",    -- Darkforge Ram
    [1071] = "Darkforge Ram",    -- Dawnforge Ram


    [2233] = "Earthen Ordinant's Ramolith",    -- Earthen Ordinant's Ramolith


    [21] = "Ram",    -- Gray Ram
    [22] = "Ram",    -- Black Ram
    [24] = "Ram",    -- White Ram
    [25] = "Ram",    -- Brown Ram
    [63] = "Ram",    -- Frost Ram
    [64] = "Ram",    -- Black Ram
    [201] = "Ram",    -- Brewfest Ram


    [2213] = "Ramolith",    -- Shale Ramolith
    [2214] = "Ramolith",    -- Slatestone Ramolith


    [1292] = "Stormpike Battle Ram",    -- Stormpike Battle Ram


    [640] = "Vicious War Ram (PVP)",    -- Vicious War Ram


    -- ========================================================
    -- RAPTORS
    -- ========================================================


    [79] = "Armored Primal Raptor",    -- Black War Raptor
    [97] = "Armored Primal Raptor",    -- Swift Blue Raptor
    [98] = "Armored Primal Raptor",    -- Swift Olive Raptor
    [99] = "Armored Primal Raptor",    -- Swift Orange Raptor
    [110] = "Armored Primal Raptor",    -- Swift Razzashi Raptor
    [295] = "Armored Primal Raptor",    -- Darkspear Raptor
    [325] = "Armored Primal Raptor",    -- Swift Purple Raptor
    [410] = "Armored Primal Raptor",    -- Armored Razzashi Raptor
    [1180] = "Armored Primal Raptor",    -- Swift Albino Raptor


    [997] = "Armored Raptor",    -- Gilded Ravasaur
    [1040] = "Armored Raptor",    -- Tomb Stalker


    [1833] = "Dreamtalon",    -- Springtide Dreamtalon
    [1834] = "Dreamtalon",    -- Ochre Dreamtalon
    [1835] = "Dreamtalon",    -- Snowfluff Dreamtalon
    [1838] = "Dreamtalon",    -- Talont


    [386] = "Fossilized Raptor",    -- Fossilized Raptor


    [2587] = "Ivory Savagemane",    -- Ivory Savagemane


    [2339] = "Jani's Trashpile",    -- Jani's Trashpile


    [27] = "Primal Raptor",    -- Emerald Raptor
    [35] = "Primal Raptor",    -- Ivory Raptor
    [36] = "Primal Raptor",    -- Turquoise Raptor
    [38] = "Primal Raptor",    -- Violet Raptor
    [54] = "Primal Raptor",    -- Mottled Red Raptor
    [56] = "Primal Raptor",    -- Ivory Raptor
    [311] = "Primal Raptor",    -- Venomhide Ravasaur
    [418] = "Primal Raptor",    -- Savage Raptor
    [537] = "Primal Raptor",    -- Bone-White Primal Raptor
    [538] = "Primal Raptor",    -- Red Primal Raptor
    [539] = "Primal Raptor",    -- Black Primal Raptor
    [540] = "Primal Raptor",    -- Green Primal Raptor


    [1183] = "Raptor",    -- Skullripper


    [2056] = "Vicious Dreamtalon (PVP)",    -- Vicious Dreamtalon
    [2057] = "Vicious Dreamtalon (PVP)",    -- Vicious Dreamtalon


    [641] = "Vicious War Raptor (PVP)",    -- Vicious War Raptor


    -- ========================================================
    -- RATS
    -- ========================================================


    [804] = "Ratstallion",    -- Ratstallion


    [1513] = "Sarge's Tale",    -- Sarge's Tale


    [1290] = "Squeakers, the Trickster",    -- Squeakers, the Trickster


    -- ========================================================
    -- ROCKETS
    -- ========================================================


    [2279] = "Cartel Rocket",    -- Thunderdrum Misfire
    [2280] = "Cartel Rocket",    -- The Topskimmer Special
    [2281] = "Cartel Rocket",    -- Steamwheedle Supplier
    [2283] = "Cartel Rocket",    -- Innovation Investigator
    [2284] = "Cartel Rocket",    -- Ochre Delivery Rocket


    [469] = "Depleted-Kyparium Rocket",    -- Depleted-Kyparium Rocket
    [2808] = "Depleted-Kyparium Rocket",    -- Ballistic Bronco


    [470] = "Geosynchronous World Spinner",    -- Geosynchronous World Spinner


    [2327] = "Lunar Launcher",    -- Lunar Launcher


    [211] = "Rocket",    -- X-51 Nether-Rocket
    [212] = "Rocket",    -- X-51 Nether-Rocket X-TREME
    [352] = "Rocket",    -- X-45 Heartbreaker
    [2301] = "Rocket",    -- Unstable Rocket
    [2302] = "Rocket",    -- Unstable Rocket


    [382] = "X-53 Touring Rocket",    -- X-53 Touring Rocket


    -- ========================================================
    -- SABERS
    -- ========================================================


    [2668] = "Arcane Saber",    -- Leyfrost Manasaber
    [2669] = "Arcane Saber",    -- Nightwell Manasaber
    [2670] = "Arcane Saber",    -- Arcberry Manasaber


    [81] = "Armored Saber",    -- Black War Tiger
    [85] = "Armored Saber",    -- Swift Mistsaber
    [87] = "Armored Saber",    -- Swift Frostsaber
    [107] = "Armored Saber",    -- Swift Stormsaber
    [111] = "Armored Saber",    -- Swift Zulian Tiger
    [297] = "Armored Saber",    -- Darnassian Nightsaber
    [319] = "Armored Saber",    -- Swift Moonsaber


    [1814] = "Dreamsaber",    -- Shadow Dusk Dreamsaber
    [1815] = "Dreamsaber",    -- Winter Night Dreamsaber
    [1816] = "Dreamsaber",    -- Evening Sun Dreamsaber
    [1817] = "Dreamsaber",    -- Morning Flourish Dreamsaber


    [780] = "Felsaber",    -- Felsaber


    [1576] = "Jigglesworth Sr.",    -- Jigglesworth Sr.


    [2193] = "Lynx",    -- Vermillion Imperial Lynx
    [2194] = "Lynx",    -- Dauntless Imperial Lynx
    [2519] = "Lynx",    -- Radiant Imperial Lynx
    [2535] = "Lynx",    -- Void-Scarred Lynx


    [1008] = "Nightborne Manasaber",    -- Nightborne Manasaber


    [1203] = "Nightsaber",    -- Umber Nightsaber
    [1204] = "Nightsaber",    -- Sandy Nightsaber
    [1205] = "Nightsaber",    -- Kaldorei Nightsaber
    [2586] = "Nightsaber",    -- Moonlit Nightsaber


    [2198] = "Nightsaber Horde Mount",    -- Kor'kron Warsaber
    [2199] = "Nightsaber Horde Mount",    -- Blackrock Warsaber
    [2200] = "Nightsaber Horde Mount",    -- [PH] Nightsaber Horde Mount White


    [1216] = "Priestess' Moonsaber",    -- Priestess' Moonsaber


    [896] = "Primal Flamesaber",    -- Primal Flamesaber


    [26] = "Saber",    -- Striped Frostsaber
    [31] = "Saber",    -- Spotted Frostsaber
    [32] = "Saber",    -- Tiger
    [34] = "Saber",    -- Striped Nightsaber
    [45] = "Saber",    -- Black Nightsaber
    [46] = "Saber",    -- Ancient Frostsaber
    [55] = "Saber",    -- Winterspring Frostsaber
    [337] = "Saber",    -- Striped Dawnsaber
    [411] = "Saber",    -- Swift Zulian Panther


    [2477] = "Sha-Warped Riding Tiger",    -- Sha-Warped Riding Tiger


    [505] = "Shado-Pan Tiger",    -- Green Shado-Pan Riding Tiger
    [506] = "Shado-Pan Tiger",    -- Blue Shado-Pan Riding Tiger
    [507] = "Shado-Pan Tiger",    -- Red Shado-Pan Riding Tiger
    [2087] = "Shado-Pan Tiger",    -- Purple Shado-Pan Riding Tiger


    [196] = "Spectral Tiger",    -- Spectral Tiger


    [197] = "Swift Spectral Tiger",    -- Swift Spectral Tiger


    [1688] = "Vicious Sabertooth (PVP)",    -- Vicious Sabertooth
    [1689] = "Vicious Sabertooth (PVP)",    -- Vicious Sabertooth


    [554] = "Vicious Warsaber (PVP)",    -- Vicious Kaldorei Warsaber
    [1194] = "Vicious Warsaber (PVP)",    -- Vicious White Warsaber
    [1195] = "Vicious Warsaber (PVP)",    -- Vicious Black Warsaber


    [1239] = "X-995 Mechanocat",    -- X-995 Mechanocat


    -- ========================================================
    -- SCARABS
    -- ========================================================


    [2230] = "Ivory Goliathus",    -- Ivory Goliathus


    [1942] = "Scarab",    -- Jeweled Copper Scarab
    [1944] = "Scarab",    -- Golden Regal Scarab
    [1945] = "Scarab",    -- Jeweled Sapphire Scarab
    [1946] = "Scarab",    -- Jeweled Jade Scarab


    [1662] = "Telix",    -- Telix the Stormhorn


    -- ========================================================
    -- SCORPIONS
    -- ========================================================


    [559] = "Juggernaut",    -- Kor'kron Juggernaut
    [1782] = "Juggernaut",    -- Perfected Juggernaut
    [2085] = "Juggernaut",    -- Cobalt Juggernaut
    [2086] = "Juggernaut",    -- Fel Iron Juggernaut


    [409] = "Scorpion",    -- Kor'kron Annihilator
    [463] = "Scorpion",    -- Amber Scorpion
    [1742] = "Scorpion",    -- Felcrystal Scorpion


    [882] = "Vicious War Scorpion (PVP)",    -- Vicious War Scorpion


    -- ========================================================
    -- SEAHORSES
    -- ========================================================


    [1258] = "Fabious",    -- Fabious


    [373] = "Seahorse",    -- Vashj'ir Seahorse
    [420] = "Seahorse",    -- Subdued Seahorse
    [1208] = "Seahorse",    -- Saltwater Seahorse


    [1259] = "Tidestallion",    -- Silver Tidestallion
    [1260] = "Tidestallion",    -- Crimson Tidestallion
    [1262] = "Tidestallion",    -- Inkscale Deepseeker


    -- ========================================================
    -- SERPENTS
    -- ========================================================


    [1289] = "Ensorcelled Everwyrm",    -- Ensorcelled Everwyrm


    [1282] = "N'Zoth serpent",    -- Black Serpent of N'Zoth
    [1315] = "N'Zoth serpent",    -- Mail Muncher
    [1322] = "N'Zoth serpent",    -- Wriggling Parasite
    [1326] = "N'Zoth serpent",    -- Awakened Mindborer


    [1581] = "Nether-Gorged Greatwyrm",    -- Nether-Gorged Greatwyrm


    [899] = "Serpent",    -- Abyss Worm
    [947] = "Serpent",    -- Riddler's Mind-Worm
    [1057] = "Serpent",    -- Nazjatar Blood Serpent
    [2500] = "Serpent",    -- Ny'alothan Shadow Worm


    [1445] = "Slime Serpent",    -- Slime Serpent


    [2315] = "Timbered Sky Snake",    -- Timbered Sky Snake


    -- ========================================================
    -- SKELETAL HORSES
    -- ========================================================


    [68] = "Armored Skeletal Horse",    -- Green Skeletal Warhorse
    [69] = "Armored Skeletal Horse",    -- Rivendare's Deathcharger
    [80] = "Armored Skeletal Horse",    -- Red Skeletal Warhorse
    [100] = "Armored Skeletal Horse",    -- Purple Skeletal Warhorse
    [303] = "Armored Skeletal Horse",    -- Forsaken Warhorse
    [308] = "Armored Skeletal Horse",    -- Blue Skeletal Warhorse
    [326] = "Armored Skeletal Horse",    -- White Skeletal Warhorse
    [336] = "Armored Skeletal Horse",    -- Ochre Skeletal Warhorse
    [1774] = "Armored Skeletal Horse",    -- Valiance


    [875] = "Midnight",    -- Midnight
    [2679] = "Midnight",    -- Bonesteed of Triumph
    [2681] = "Midnight",    -- Bonesteed of Bloodshed
    [2682] = "Midnight",    -- Bonesteed of Plague
    [2683] = "Midnight",    -- Bonesteed of Oblivion


    [1213] = "Risen Mare",    -- Risen Mare


    [28] = "Skeletal Horse",    -- Skeletal Horse
    [65] = "Skeletal Horse",    -- Red Skeletal Horse
    [66] = "Skeletal Horse",    -- Blue Skeletal Horse
    [67] = "Skeletal Horse",    -- Brown Skeletal Horse
    [314] = "Skeletal Horse",    -- Black Skeletal Horse


    [555] = "Vicious Skeletal Warhorse (PVP)",    -- Vicious Skeletal Warhorse
    [1196] = "Vicious Skeletal Warhorse (PVP)",    -- Vicious Black Bonesteed
    [1197] = "Vicious Skeletal Warhorse (PVP)",    -- Vicious White Bonesteed


    -- ========================================================
    -- SKIFFS
    -- ========================================================


    [2332] = "The Breaker's Song",    -- The Breaker's Song


    [1051] = "The Dreadwake",    -- The Dreadwake


    -- ========================================================
    -- SKYREAVERS
    -- ========================================================


    [571] = "Armored Chimera",    -- Iron Skyreaver
    [2470] = "Armored Chimera",    -- Nightfall Skyreaver


    [1200] = "Ashenvale Chimaera",    -- Ashenvale Chimaera


    [772] = "Chimera",    -- Soaring Skyterror
    [776] = "Chimera",    -- Swift Spectral Rylak


    [2524] = "Cormaera",    -- Coldflame Cormaera
    [2526] = "Cormaera",    -- Felborn Cormaera
    [2527] = "Cormaera",    -- Molten Cormaera
    [2528] = "Cormaera",    -- Lavaborn Cormaera


    [1406] = "Flayedwing",    -- Marrowfang
    [1407] = "Flayedwing",    -- Callow Flayedwing
    [1408] = "Flayedwing",    -- Gruesome Flayedwing


    -- ========================================================
    -- SLITHERDRAKES
    -- ========================================================


    [1795] = "Auspicious Arborwyrm",    -- Auspicious Arborwyrm


    [1739] = "Gladiator's Slitherdrake (PVP)",    -- Obsidian Gladiator's Slitherdrake
    [1831] = "Gladiator's Slitherdrake (PVP)",    -- Verdant Gladiator's Slitherdrake


    [1588] = "Winding Slitherdrake",    -- Winding Slitherdrake
    [1789] = "Winding Slitherdrake",    -- Winding Slitherdrake


    -- ========================================================
    -- SNAILS
    -- ========================================================


    [1448] = "Progenitor Snail",    -- Serenade
    [1538] = "Progenitor Snail",    -- Bronze Helicid
    [1539] = "Progenitor Snail",    -- Unsuccessful Prototype Fleetpod
    [1540] = "Progenitor Snail",    -- Scarlet Helicid


    [1623] = "Seething Slug",    -- Seething Slug


    [1729] = "Snail",    -- Big Slick in the City
    [2495] = "Snail",    -- Emerald Snail


    [1469] = "Snailemental",    -- Magmashell
    [1626] = "Snailemental",    -- Shellack
    [1627] = "Snailemental",    -- Gooey Snailemental
    [1629] = "Snailemental",    -- Scrappy Worldsnail


    [1740] = "Vicious War Snail (PVP)",    -- Vicious War Snail
    [1741] = "Vicious War Snail (PVP)",    -- Vicious War Snail


    -- ========================================================
    -- SNAPDRAGONS
    -- ========================================================


    [2469] = "Prismatic Snapdragon",    -- Prismatic Snapdragon


    [1237] = "Snapdragon",    -- Royal Snapdragon
    [1255] = "Snapdragon",    -- Deepcoral Snapdragon
    [1256] = "Snapdragon",    -- Snapdragon Kelpstalker


    -- ========================================================
    -- SOUL EATERS
    -- ========================================================


    [1363] = "Gladiator's Soul Eater (PVP)",    -- Sinful Gladiator's Soul Eater
    [1480] = "Gladiator's Soul Eater (PVP)",    -- Unchained Gladiator's Soul Eater
    [1572] = "Gladiator's Soul Eater (PVP)",    -- Cosmic Gladiator's Soul Eater
    [1599] = "Gladiator's Soul Eater (PVP)",    -- Eternal Gladiator's Soul Eater


    [2114] = "Zovaal's Soul Eater",    -- Zovaal's Soul Eater


    -- ========================================================
    -- SPIDERS
    -- ========================================================


    [663] = "Bloodfang Widow",    -- Bloodfang Widow


    [1541] = "Progenitor Spider",    -- Genesis Crawler
    [1542] = "Progenitor Spider",    -- Tarachnid Creeper
    [1543] = "Progenitor Spider",    -- Ineffable Skitterer


    [2171] = "Undercrawler",    -- Widow's Undercrawler
    [2172] = "Undercrawler",    -- Heritage Undercrawler
    [2174] = "Undercrawler",    -- Royal Court Undercrawler


    [1351] = "Vicious War Spider (PVP)",    -- Vicious War Spider
    [1352] = "Vicious War Spider (PVP)",    -- Vicious War Spider


    -- ========================================================
    -- STAGS
    -- ========================================================


    [1808] = "Dreamstag",    -- Blossoming Dreamstag
    [1809] = "Dreamstag",    -- Suntouched Dreamstag
    [1810] = "Dreamstag",    -- Rekindled Dreamstag
    [1811] = "Dreamstag",    -- Lunar Dreamstag
    [1839] = "Dreamstag",    -- Stargrazer


    [1303] = "Enchanted Runestag",    -- Enchanted Dreamlight Runestag
    [1357] = "Enchanted Runestag",    -- Enchanted Shadeleaf Runestag
    [1358] = "Enchanted Runestag",    -- Enchanted Wakener's Runestag
    [1359] = "Enchanted Runestag",    -- Enchanted Winterborn Runestag


    [1431] = "Progenitor Stag",    -- Pale Regal Cervid
    [1526] = "Progenitor Stag",    -- Deathrunner
    [1528] = "Progenitor Stag",    -- Sundered Zerethsteed
    [1529] = "Progenitor Stag",    -- Anointed Protostag


    [1302] = "Runestag",    -- Dreamlight Runestag
    [1354] = "Runestag",    -- Shadeleaf Runestag
    [1355] = "Runestag",    -- Wakener's Runestag
    [1356] = "Runestag",    -- Winterborn Runestag


    -- ========================================================
    -- STORM DRAGONS
    -- ========================================================


    [948] = "Demonic Gladiator's Storm Dragon (PVP)",    -- Demonic Gladiator's Storm Dragon


    [848] = "Gladiator's Storm Dragon (PVP)",    -- Vindictive Gladiator's Storm Dragon
    [849] = "Gladiator's Storm Dragon (PVP)",    -- Fearless Gladiator's Storm Dragon
    [850] = "Gladiator's Storm Dragon (PVP)",    -- Cruel Gladiator's Storm Dragon
    [851] = "Gladiator's Storm Dragon (PVP)",    -- Ferocious Gladiator's Storm Dragon
    [852] = "Gladiator's Storm Dragon (PVP)",    -- Fierce Gladiator's Storm Dragon
    [853] = "Gladiator's Storm Dragon (PVP)",    -- Dominant Gladiator's Storm Dragon


    [944] = "Storm Dragon",    -- Valarjar Stormwing
    [1212] = "Storm Dragon",    -- Island Thunderscale
    [1779] = "Storm Dragon",    -- Felstorm Dragon
    [2656] = "Storm Dragon",    -- Thorignir Drake


    -- ========================================================
    -- STRIDERS
    -- ========================================================


    [1478] = "Hornstrider",    -- Skyskin Hornstrider
    [2038] = "Hornstrider",    -- Clayscale Hornstrider


    [426] = "Strider",    -- Swift Shorestrider
    [429] = "Strider",    -- Swift Forest Strider
    [430] = "Strider",    -- Swift Springstrider
    [431] = "Strider",    -- Swift Lovebird


    -- ========================================================
    -- SWARMITES
    -- ========================================================


    [956] = "Bloodswarmer",    -- Leaping Veinseeker
    [1061] = "Bloodswarmer",    -- Expedition Bloodswarmer


    [1309] = "Devourer",    -- Chittering Animite
    [1379] = "Devourer",    -- Endmire Flyer


    [2177] = "Swarmite",    -- Aquamarine Swarmite
    [2178] = "Swarmite",    -- Nesting Swarmite
    [2180] = "Swarmite",    -- Shadowed Swarmite
    [2181] = "Swarmite",    -- Swarmite Skyhunter


    [2150] = "Vicious War Skyflayer (PVP)",    -- Vicious Skyflayer
    [2211] = "Vicious War Skyflayer (PVP)",    -- Vicious Skyflayer


    -- ========================================================
    -- SWEEPERS
    -- ========================================================


    [1799] = "Eve's Ghastly Rider",    -- Eve's Ghastly Rider


    [2328] = "Sweeper",    -- Love Witch's Sweeper
    [2329] = "Sweeper",    -- Silvermoon Sweeper
    [2330] = "Sweeper",    -- Twilight Witch's Sweeper
    [2331] = "Sweeper",    -- Sky Witch's Sweeper


    -- ========================================================
    -- TALBUKS
    -- ========================================================


    [939] = "Argus Talbuk",    -- Sable Ruinstrider
    [964] = "Argus Talbuk",    -- Amethyst Ruinstrider
    [965] = "Argus Talbuk",    -- Cerulean Ruinstrider
    [966] = "Argus Talbuk",    -- Beryl Ruinstrider
    [967] = "Argus Talbuk",    -- Umber Ruinstrider
    [968] = "Argus Talbuk",    -- Russet Ruinstrider
    [986] = "Argus Talbuk",    -- Bleakhoof Ruinstrider
    [2630] = "Argus Talbuk",    -- Ornery Breezestrider
    [2688] = "Argus Talbuk",    -- Garnet Ruinstrider


    [151] = "Armored Talbuk",    -- Dark War Talbuk
    [153] = "Armored Talbuk",    -- Cobalt War Talbuk
    [154] = "Armored Talbuk",    -- White War Talbuk
    [155] = "Armored Talbuk",    -- Silver War Talbuk
    [156] = "Armored Talbuk",    -- Tan War Talbuk


    [1567] = "Lightforged Ruinstrider",    -- Lightforged Ruinstrider
    [1568] = "Lightforged Ruinstrider",    -- Lightforged Ruinstrider


    [970] = "Maddened Chaosrunner",    -- Maddened Chaosrunner
    [2686] = "Maddened Chaosrunner",    -- Longhorned Sable Talbuk
    [2689] = "Maddened Chaosrunner",    -- Longhorned Bleakhoof Talbuk
    [2690] = "Maddened Chaosrunner",    -- Longhorned Argussian Talbuk
    [2691] = "Maddened Chaosrunner",    -- Longhorned Beryl Talbuk
    [2716] = "Maddened Chaosrunner",    -- (PH) Legion Remix Mount


    [170] = "Talbuk",    -- Cobalt Riding Talbuk
    [171] = "Talbuk",    -- Dark Riding Talbuk
    [172] = "Talbuk",    -- Silver Riding Talbuk
    [173] = "Talbuk",    -- Tan Riding Talbuk
    [174] = "Talbuk",    -- White Riding Talbuk


    [635] = "Talbuk Draenor",    -- Shadowmane Charger
    [636] = "Talbuk Draenor",    -- Swift Breezestrider
    [637] = "Talbuk Draenor",    -- Trained Silverpelt
    [638] = "Talbuk Draenor",    -- Breezestrider Stallion
    [639] = "Talbuk Draenor",    -- Pale Thorngrazer


    -- ========================================================
    -- TAURALUSES
    -- ========================================================


    [1368] = "Armored Tauralus",    -- Armored War-Bred Tauralus
    [1369] = "Armored Tauralus",    -- Armored Plaguerot Tauralus
    [1370] = "Armored Tauralus",    -- Armored Bonehoof Tauralus
    [1371] = "Armored Tauralus",    -- Armored Chosen Tauralus


    [1364] = "Tauralus",    -- War-Bred Tauralus
    [1365] = "Tauralus",    -- Plaguerot Tauralus
    [1366] = "Tauralus",    -- Bonehoof Tauralus
    [1367] = "Tauralus",    -- Chosen Tauralus


    -- ========================================================
    -- TOADS
    -- ========================================================


    [1415] = "Arboreal Gulper",    -- Arboreal Gulper


    [1012] = "Hopper",    -- Green Marsh Hopper
    [1206] = "Hopper",    -- Blue Marsh Hopper
    [1207] = "Hopper",    -- Yellow Marsh Hopper
    [1595] = "Hopper",    -- Cerulean Marsh Hopper


    [1547] = "Progenitor Gulper",    -- Goldplate Bufonid
    [1569] = "Progenitor Gulper",    -- Patient Bufonid
    [1570] = "Progenitor Gulper",    -- Prototype Leaper
    [1571] = "Progenitor Gulper",    -- Russet Bufonid


    [1451] = "Vicious War Croaker (PVP)",    -- Vicious War Croaker
    [1452] = "Vicious War Croaker (PVP)",    -- Vicious War Croaker


    -- ========================================================
    -- TURTLES
    -- ========================================================


    [452] = "Dragon Turtle ",    -- Green Dragon Turtle
    [492] = "Dragon Turtle ",    -- Black Dragon Turtle
    [493] = "Dragon Turtle ",    -- Blue Dragon Turtle
    [494] = "Dragon Turtle ",    -- Brown Dragon Turtle
    [495] = "Dragon Turtle ",    -- Purple Dragon Turtle
    [496] = "Dragon Turtle ",    -- Red Dragon Turtle


    [453] = "Great Dragon Turtle",    -- Great Red Dragon Turtle
    [497] = "Great Dragon Turtle",    -- Great Green Dragon Turtle
    [498] = "Great Dragon Turtle",    -- Great Black Dragon Turtle
    [499] = "Great Dragon Turtle",    -- Great Blue Dragon Turtle
    [500] = "Great Dragon Turtle",    -- Great Brown Dragon Turtle
    [501] = "Great Dragon Turtle",    -- Great Purple Dragon Turtle


    [1582] = "Savage Battle Turtle",    -- Savage Green Battle Turtle
    [2039] = "Savage Battle Turtle",    -- Savage Blue Battle Turtle
    [2232] = "Savage Battle Turtle",    -- Savage Ebony Battle Turtle
    [2347] = "Savage Battle Turtle",    -- Savage Alabaster Battle Turtle
    [2823] = "Savage Battle Turtle",    -- Savage Crimson Battle Turtle


    [125] = "Sea Turtle",    -- Riding Turtle
    [312] = "Sea Turtle",    -- Sea Turtle


    [847] = "Super Armored Turtle",    -- Arcadian War Turtle
    [2531] = "Super Armored Turtle",    -- Tyrannotort


    [900] = "Vicious War Turtle (PVP)",    -- Vicious War Turtle
    [901] = "Vicious War Turtle (PVP)",    -- Vicious War Turtle


    -- ========================================================
    -- VANQUISHER WYRMS
    -- ========================================================


    [866] = "Deathlord's Vilebrood Vanquisher",    -- Deathlord's Vilebrood Vanquisher
    [2720] = "Deathlord's Vilebrood Vanquisher",    -- Felscorned Vilebrood Vanquisher


    [313] = "Gladiator's Frost Wyrm (PVP)",    -- Deadly Gladiator's Frost Wyrm
    [317] = "Gladiator's Frost Wyrm (PVP)",    -- Furious Gladiator's Frost Wyrm
    [340] = "Gladiator's Frost Wyrm (PVP)",    -- Relentless Gladiator's Frost Wyrm
    [358] = "Gladiator's Frost Wyrm (PVP)",    -- Wrathful Gladiator's Frost Wyrm


    [364] = "Vanquisher",    -- Icebound Frostbrood Vanquisher
    [365] = "Vanquisher",    -- Bloodbathed Frostbrood Vanquisher
    [1783] = "Vanquisher",    -- Scourgebound Vanquisher


    -- ========================================================
    -- VORQUINS
    -- ========================================================


    [1664] = "Armored Vorquin",    -- Guardian Vorquin
    [1665] = "Armored Vorquin",    -- Swift Armored Vorquin
    [1667] = "Armored Vorquin",    -- Armored Vorquin Leystrider
    [1668] = "Armored Vorquin",    -- Majestic Armored Vorquin


    [1683] = "Vorquin",    -- Crimson Vorquin
    [1684] = "Vorquin",    -- Sapphire Vorquin
    [1685] = "Vorquin",    -- Bronze Vorquin
    [1686] = "Vorquin",    -- Obsidian Vorquin


    -- ========================================================
    -- WINGED FLYING HORSES
    -- ========================================================


    [376] = "Celestial Steed",    -- Celestial Steed


    [454] = "Cindermane Charger",    -- Cindermane Charger


    [547] = "Hearthsteed",    -- Hearthsteed
    [1168] = "Hearthsteed",    -- Fiery Hearthsteed


    [2605] = "Inarius' Charger",    -- Inarius' Charger


    [363] = "Invincible",    -- Invincible


    [439] = "Tyrael's Charger",    -- Tyrael's Charger


    -- ========================================================
    -- WOLVES
    -- ========================================================


    [2201] = "Alliance Wolf Mount",    -- Sentinel War Wolf
    [2202] = "Alliance Wolf Mount",    -- [PH] Alliance Wolf Mount
    [2203] = "Alliance Wolf Mount",    -- Kaldorei War Wolf


    [642] = "Armored Draenor Wolf",    -- Garn Steelmaw
    [643] = "Armored Draenor Wolf",    -- Warsong Direfang
    [644] = "Armored Draenor Wolf",    -- Armored Frostwolf
    [645] = "Armored Draenor Wolf",    -- Ironside Warwolf


    [82] = "Armored Wolf",    -- Black War Wolf
    [104] = "Armored Wolf",    -- Swift Brown Wolf
    [105] = "Armored Wolf",    -- Swift Timber Wolf
    [106] = "Armored Wolf",    -- Swift Gray Wolf
    [108] = "Armored Wolf",    -- Frostwolf Howler
    [300] = "Armored Wolf",    -- Orgrimmar Wolf
    [327] = "Armored Wolf",    -- Swift Burgundy Wolf
    [342] = "Armored Wolf",    -- Swift Horde Wolf
    [1776] = "Armored Wolf",    -- White War Wolf


    [1243] = "Beastlord's Warwolf",    -- Beastlord's Warwolf


    [647] = "Draenor Wolf",    -- Trained Snarler
    [648] = "Draenor Wolf",    -- Swift Frostwolf
    [649] = "Draenor Wolf",    -- Smoky Direwolf
    [650] = "Draenor Wolf",    -- Dustmane Direwolf
    [657] = "Draenor Wolf",    -- Garn Nighthowl
    [2498] = "Draenor Wolf",    -- Void-Scarred Pack Mother


    [1285] = "Frostwolf Snarler",    -- Frostwolf Snarler


    [758] = "Infernal Direwolf",    -- Infernal Direwolf


    [1246] = "Ironclad Frostclaw",    -- Ironclad Frostclaw


    [558] = "Kor'kron War Wolf",    -- Kor'kron War Wolf


    [1044] = "Mag'har Direwolf",    -- Mag'har Direwolf


    [406] = "Spectral Wolf",    -- Spectral Wolf


    [423] = "War Wolf (PVP)",    -- Vicious War Wolf
    [784] = "War Wolf (PVP)",    -- Prestigious War Wolf


    [7] = "Wolf",    -- Gray Wolf
    [12] = "Wolf",    -- Black Wolf
    [13] = "Wolf",    -- Red Wolf
    [14] = "Wolf",    -- Timber Wolf
    [15] = "Wolf",    -- Winter Wolf
    [19] = "Wolf",    -- Dire Wolf
    [20] = "Wolf",    -- Brown Wolf
    [50] = "Wolf",    -- Red Wolf
    [51] = "Wolf",    -- Arctic Wolf
    [310] = "Wolf",    -- Black Wolf


    -- ========================================================
    -- WYVERNS
    -- ========================================================


    [1267] = "Alabaster Thunderwing",    -- Alabaster Thunderwing


    [136] = "Armored Wyvern",    -- Swift Red Wind Rider
    [140] = "Armored Wyvern",    -- Swift Green Wind Rider
    [141] = "Armored Wyvern",    -- Swift Yellow Wind Rider
    [142] = "Armored Wyvern",    -- Swift Purple Wind Rider
    [277] = "Armored Wyvern",    -- Armored Blue Wind Rider


    [2308] = "Chaos-Forged Wind Rider",    -- Chaos-Forged Wind Rider


    [1591] = "Cliffside Wylderdrake",    -- Cliffside Wylderdrake
    [1788] = "Cliffside Wylderdrake",    -- Cliffside Wylderdrake


    [527] = "Grand Armored Wyvern",    -- Grand Armored Wyvern


    [529] = "Grand Wyvern",    -- Grand Wyvern
    [2499] = "Grand Wyvern",    -- Void-Scarred Windrider


    [441] = "Spectral Wind Rider",    -- Spectral Wind Rider


    [133] = "Wyvern",    -- Tawny Wind Rider
    [134] = "Wyvern",    -- Blue Wind Rider
    [135] = "Wyvern",    -- Green Wind Rider
    [2117] = "Wyvern",    -- Remembered Wind Rider


    -- ========================================================
    -- YAKS
    -- ========================================================


    [460] = "Grand Expedition Yak",    -- Grand Expedition Yak


    [462] = "Yak",    -- Kafa Yak
    [484] = "Yak",    -- Black Riding Yak
    [485] = "Yak",    -- Modest Expedition Yak
    [486] = "Yak",    -- Grey Riding Yak
    [487] = "Yak",    -- Blonde Riding Yak


    -- ========================================================
    -- ZERETH OVERSEERS
    -- ========================================================


    [2612] = "Void Zereth Overseer",    -- Void-Forged Overseer


    [1587] = "Zereth Overseer",    -- Zereth Overseer


    -- ========================================================
    -- STANDALONE
    -- ========================================================


    [1250] = "Alpaca",    -- Mollie
    [1324] = "Alpaca",    -- Elusive Quickhoof
    [1329] = "Alpaca",    -- Springfur Alpaca
    [1794] = "Alpaca",    -- Pattie


    [1436] = "Aquilon",    -- Battle-Hardened Aquilon
    [1492] = "Aquilon",    -- Elysian Aquilon
    [1493] = "Aquilon",    -- Forsworn Aquilon
    [1494] = "Aquilon",    -- Ascendant's Aquilon
    [2796] = "Aquilon",    -- Bronze Aquilon


    [1332] = "Ardenmoth",    -- Silky Shimmermoth
    [1361] = "Ardenmoth",    -- Duskflutter Ardenmoth
    [1428] = "Ardenmoth",    -- Amber Ardenmoth
    [1429] = "Ardenmoth",    -- Vibrant Flutterwing


    [1681] = "Armoredon",    -- Hailstorm Armoredon
    [1725] = "Armoredon",    -- Inferno Armoredon
    [1801] = "Armoredon",    -- Verdant Armoredon
    [2055] = "Armoredon",    -- Infinite Armoredon


    [1467] = "Bruffalon",    -- Noble Bruffalon
    [1614] = "Bruffalon",    -- Stormtouched Bruffalon


    [2489] = "Butterfly",    -- Pearlescent Butterfly
    [2491] = "Butterfly",    -- Ruby Butterfly
    [2492] = "Butterfly",    -- Spring Butterfly
    [2494] = "Butterfly",    -- Midnight Butterfly


    [678] = "Chauffeured vehicle",    -- Chauffeured Mechano-Hog
    [679] = "Chauffeured vehicle",    -- Chauffeured Mekgineer's Chopper


    [606] = "Core Hound",    -- Core Hound
    [797] = "Core Hound",    -- Steelbound Devourer
    [1781] = "Core Hound",    -- Sulfur Hound


    [1449] = "Corpsefly",    -- Lord of the Corpseflies
    [1495] = "Corpsefly",    -- Maldraxxian Corpsefly
    [1496] = "Corpsefly",    -- Regal Corpsefly
    [1497] = "Corpsefly",    -- Battlefield Swarmer
    [2797] = "Corpsefly",    -- Bronze Corpsefly


    [479] = "Crane",    -- Azure Riding Crane
    [480] = "Crane",    -- Golden Riding Crane
    [481] = "Crane",    -- Regal Riding Crane
    [482] = "Crane",    -- Jungle Riding Crane
    [2072] = "Crane",    -- Gilded Riding Crane
    [2073] = "Crane",    -- Pale Riding Crane
    [2074] = "Crane",    -- Rose Riding Crane
    [2075] = "Crane",    -- Silver Riding Crane
    [2076] = "Crane",    -- Luxurious Riding Crane
    [2077] = "Crane",    -- Tropical Riding Crane


    [963] = "Crawg",    -- Bloodgorged Crawg
    [1053] = "Crawg",    -- Underrot Crawg


    [1238] = "Crawler",    -- Snapback Scuttler
    [1574] = "Crawler",    -- Crusty Crawler


    [1454] = "Devouring Mauler",    -- Tamed Mauler
    [1514] = "Devouring Mauler",    -- Rampaging Mauler
    [2603] = "Devouring Mauler",    -- Sthaarbs's Last Lunch


    [1319] = "Drone",    -- Malevolent Drone
    [1320] = "Drone",    -- Shadowbarb Drone
    [1321] = "Drone",    -- Wicked Swarmer
    [1784] = "Drone",    -- Royal Swarmer


    [793] = "Falcosaur",    -- Predatory Bloodgazer
    [794] = "Falcosaur",    -- Brilliant Direbeak
    [795] = "Falcosaur",    -- Snowfeather Hunter
    [796] = "Falcosaur",    -- Viridian Sharptalon


    [2184] = "Ferocious Jawcrawler",    -- Ferocious Jawcrawler


    [2278] = "Flarendo the Furious",    -- Flarendo the Furious


    [2161] = "Glowmite",    -- Elder Glowmite
    [2162] = "Glowmite",    -- Cyan Glowmite


    [508] = "Goat",    -- Brown Riding Goat
    [510] = "Goat",    -- White Riding Goat
    [511] = "Goat",    -- Black Riding Goat
    [2078] = "Goat",    -- Snowy Riding Goat
    [2080] = "Goat",    -- Little Red Riding Goat
    [2504] = "Goat",    -- Spotted Black Riding Goat


    [1391] = "Gorger",    -- Loyal Gorger
    [1443] = "Gorger",    -- Voracious Gorger
    [2602] = "Gorger",    -- Translocated Gorger


    [803] = "Gravewing",    -- Mastercraft Gravewing
    [1489] = "Gravewing",    -- Obsidian Gravewing
    [1490] = "Gravewing",    -- Sinfall Gravewing
    [1491] = "Gravewing",    -- Pale Gravewing
    [2798] = "Gravewing",    -- Bronze Gravewing


    [1312] = "Grrloc",    -- Gargantuan Grrloc
    [1797] = "Grrloc",    -- Ginormous Grrloc
    [2259] = "Grrloc",    -- Gigantic Grrloc
    [2573] = "Grrloc",    -- Grandiose Grrloc


    [2520] = "Harvesthog",    -- Spring Harvesthog
    [2521] = "Harvesthog",    -- Summer Harvesthog
    [2522] = "Harvesthog",    -- Winter Harvesthog
    [2523] = "Harvesthog",    -- Autumn Harvesthog


    [861] = "High Priest's Lightsworn Seeker",    -- High Priest's Lightsworn Seeker
    [2727] = "High Priest's Lightsworn Seeker",    -- High Priest's Felscorned Seeker


    [1221] = "Hogrus",    -- Hogrus, Swine of Good Fortune


    [865] = "Huntmaster's Wolfhawk",    -- Huntmaster's Loyal Wolfhawk
    [870] = "Huntmaster's Wolfhawk",    -- Huntmaster's Fierce Wolfhawk
    [872] = "Huntmaster's Wolfhawk",    -- Huntmaster's Dire Wolfhawk
    [2723] = "Huntmaster's Wolfhawk",    -- Felscorned Wolfhawk


    [633] = "Infernal",    -- Hellfire Infernal
    [646] = "Infernal",    -- Coldflame Infernal
    [791] = "Infernal",    -- Felblaze Infernal
    [799] = "Infernal",    -- Flarecore Infernal
    [1167] = "Infernal",    -- Frostshard Infernal


    [1594] = "Jade",    -- Jade, Bright Foreseer


    [933] = "Krolusk",    -- Obsidian Krolusk
    [1172] = "Krolusk",    -- Conqueror's Scythemaw
    [1214] = "Krolusk",    -- Azureshell Krolusk
    [1215] = "Krolusk",    -- Rubyshell Krolusk
    [2601] = "Krolusk",    -- Pearlescent Krolusk


    [328] = "Magic Rooster",    -- Magic Rooster
    [333] = "Magic Rooster",    -- Magic Rooster
    [334] = "Magic Rooster",    -- Magic Rooster
    [335] = "Magic Rooster",    -- Magic Rooster


    [906] = "Mana Ray",    -- Darkspore Mana Ray
    [973] = "Mana Ray",    -- Lambent Mana Ray
    [974] = "Mana Ray",    -- Vibrant Mana Ray
    [975] = "Mana Ray",    -- Felglow Mana Ray
    [976] = "Mana Ray",    -- Scintillating Mana Ray
    [1438] = "Mana Ray",    -- Bulbous Necroray
    [1439] = "Mana Ray",    -- Infested Necroray
    [1440] = "Mana Ray",    -- Pestilent Necroray
    [1941] = "Mana Ray",    -- Heartseeker Mana Ray
    [2671] = "Mana Ray",    -- Fel-scarred Mana Ray
    [2672] = "Mana Ray",    -- Bloodtooth Mana Ray
    [2673] = "Mana Ray",    -- Albino Mana Ray
    [2674] = "Mana Ray",    -- Luminous Mana Ray


    [1417] = "Mawguard Hand",    -- Hand of Hrestimorak
    [1475] = "Mawguard Hand",    -- Hand of Bahmethra
    [1503] = "Mawguard Hand",    -- Hand of Nilganihmaht
    [1504] = "Mawguard Hand",    -- Hand of Salaranga
    [2249] = "Mawguard Hand",    -- Hand of Reshkigaal


    [1247] = "Mechacycle",    -- Mechacycle Model W
    [1248] = "Mechacycle",    -- Junkheap Drifter


    [2342] = "Meeksi",    -- Meeksi Rufflefur
    [2343] = "Meeksi",    -- Meeksi Softpaw
    [2344] = "Meeksi",    -- Meeksi Rollingpaw
    [2345] = "Meeksi",    -- Meeksi Teatuft
    [2346] = "Meeksi",    -- Meeksi Brewthief


    [515] = "Mushan Beast",    -- Son of Galleon
    [550] = "Mushan Beast",    -- Brawler's Burly Mushan Beast
    [560] = "Mushan Beast",    -- Ashhide Mushan Beast
    [2088] = "Mushan Beast",    -- Riverwalker Mushan
    [2089] = "Mushan Beast",    -- Palehide Mushan Beast


    [176] = "Nether Ray",    -- Green Riding Nether Ray
    [177] = "Nether Ray",    -- Red Riding Nether Ray
    [178] = "Nether Ray",    -- Purple Riding Nether Ray
    [179] = "Nether Ray",    -- Silver Riding Nether Ray
    [180] = "Nether Ray",    -- Blue Riding Nether Ray


    [1433] = "Progenitor Wasp",    -- Vespoid Flutterer
    [1533] = "Progenitor Wasp",    -- Forged Spiteflyer
    [1534] = "Progenitor Wasp",    -- Buzz
    [1535] = "Progenitor Wasp",    -- Bronzewing Vespoid


    [1450] = "Razorwing",    -- Soaring Razorwing
    [1508] = "Razorwing",    -- Fierce Razorwing
    [1509] = "Razorwing",    -- Garnet Razorwing
    [1510] = "Razorwing",    -- Dusklight Razorwing
    [2825] = "Razorwing",    -- Cloudborn Razorwing


    [629] = "Riverwallow",    -- Trained Riverwallow
    [630] = "Riverwallow",    -- Sapphire Riverbeast
    [631] = "Riverwallow",    -- Mudback Riverbeast
    [632] = "Riverwallow",    -- Mosshide Riverwallow


    [1619] = "Salamanther",    -- Ancient Salamanther
    [1621] = "Salamanther",    -- Coralscale Salamanther
    [1622] = "Salamanther",    -- Stormhide Salamanther
    [1940] = "Salamanther",    -- Salatrancer


    [855] = "Sea Ray",    -- Darkwater Skate
    [1166] = "Sea Ray",    -- Great Sea Ray


    [1730] = "Shalewing",    -- Igneous Shalewing
    [1732] = "Shalewing",    -- Cobalt Shalewing
    [1733] = "Shalewing",    -- Calescent Shalewing
    [1734] = "Shalewing",    -- Shadowflame Shalewing
    [1735] = "Shalewing",    -- Cataloged Shalewing
    [1736] = "Shalewing",    -- Boulder Hauler
    [1737] = "Shalewing",    -- Sandy Shalewing
    [1738] = "Shalewing",    -- Morsel Sniffer
    [1939] = "Shalewing",    -- Imagiwing


    [1011] = "Shu-Zen",    -- Shu-Zen, the Divine Sentinel


    [1468] = "Skitterfly",    -- Amber Skitterfly
    [1615] = "Skitterfly",    -- Tamed Skitterfly
    [1616] = "Skitterfly",    -- Azure Skitterfly
    [1617] = "Skitterfly",    -- Verdant Skitterfly
    [1618] = "Skitterfly",    -- Bestowed Sandskimmer


    [2560] = "Slateback",    -- Blue Barry
    [2561] = "Slateback",    -- Curious Slateback
    [2655] = "Slateback",    -- Phase-Lost Slateback


    [1553] = "Slyvern",    -- Liberated Slyvern
    [1674] = "Slyvern",    -- Temperamental Skyclaw


    [1608] = "Soar",    -- Soar
    [1952] = "Soar",    -- Soar
    [2115] = "Soar",    -- Soar


    [1532] = "Soaring Spelltome",    -- Soaring Spelltome


    [1025] = "The Hivemind",    -- The Hivemind


    [1474] = "Thunderspine",    -- Bestowed Thunderspine Packleader
    [1638] = "Thunderspine",    -- Explorer's Stonehide Packbeast
    [1639] = "Thunderspine",    -- Lizi, Thunderspine Tramper

    [954] = "Ur'zul",    -- Shackled Ur'zul
    [2471] = "Ur'zul",    -- Ur'zul Fleshripper
    [2652] = "Ur'zul",    -- Bilebound Ur'zul
    [2653] = "Ur'zul",    -- Ghastly Ur'zul


    [2299] = "Vicious Electro Eel (PVP)",    -- Vicious Electro Eel
    [2300] = "Vicious Electro Eel (PVP)",    -- Vicious Electro Eel


    [1050] = "Vicious War Riverbeast (PVP)",    -- Vicious War Riverbeast


    [1444] = "Viridian Phase-Hunter",    -- Viridian Phase-Hunter
    [2732] = "Viridian Phase-Hunter",    -- Cerulean Phase-Hunter


    [1458] = "Wandering Ancient",    -- Wandering Ancient


    [449] = "Water Strider",    -- Azure Water Strider
    [488] = "Water Strider",    -- Crimson Water Strider


    [1230] = "Waveray",    -- Unshackled Waveray
    [1231] = "Waveray",    -- Ankoan Waveray
    [1232] = "Waveray",    -- Azshari Bloatray
    [1257] = "Waveray",    -- Silent Glider
    [1269] = "Waveray",    -- Swift Spectral Fathom Ray
    [1579] = "Waveray",    -- Coral-Stalker Waveray


    [1690] = "Whelpling",    -- Whelpling
    [1796] = "Whelpling",    -- Whelpling


    [1397] = "Wildseed Cradle",    -- Wildseed Cradle


    [372] = "Wooly White Rhino",    -- Wooly White Rhino


    [999] = "Xiwyllag ATV",    -- Xiwyllag ATV


    [654] = "Yeti",    -- Challenger's War Yeti
    [769] = "Yeti",    -- Minion of Grumpus
    [1176] = "Yeti",    -- Craghorn Chasm-Leaper

}

-- ============================================================
-- FAMILY DEFINITIONS
-- ============================================================

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

    ["Prototype A.S.M.R."] = {
        superGroup = "Aerial Units",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Antoran Felhounds
    ["Vile Fiend"] = {
        superGroup = "Antoran Felhounds",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Bakars
    ["Spiky Bakar"] = {
        superGroup = "Bakars",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Taivan"] = {
        superGroup = "Bakars",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Basilisks
    ["Brawler's Burly Basilisk"] = {
        superGroup = "Basilisks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Bruce"] = {
        superGroup = "Basilisks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Plunderlord's Crocolisk"] = {
        superGroup = "Basilisks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Basilisk (PVP)"] = {
        superGroup = "Basilisks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Bats
    ["Armored Bat"] = {
        superGroup = "Bats",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Bat"] = {
        superGroup = "Bats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Chaos-Forged Dreadwing"] = {
        superGroup = "Bats",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Dredwing"] = {
        superGroup = "Bats",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Bears
    ["Armored Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Big Battle Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Big Blizzard Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Blackpaw"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Darkmoon Dancing Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grizzly Hills Packmaster"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Harmonious Salutations Bear"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Shadehound"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Shardhide"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Snowstorm"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious War Bear (PVP)"] = {
        superGroup = "Bears",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Bees
    ["Cinderbee"] = {
        superGroup = "Bees",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Honeyback"] = {
        superGroup = "Bees",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Timely Buzzbee"] = {
        superGroup = "Bees",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Birds (flying idle)
    ["Albatross"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Eagle"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Mechanical Parrot"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Parrot"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Pirate Parrot"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Shadowblade's Omen"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Stormcrow"] = {
        superGroup = "Birds (flying idle)",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Boards
    ["Grandmaster's Board"] = {
        superGroup = "Boards",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Surfboard"] = {
        superGroup = "Boards",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Boars
    ["Armored Boar"] = {
        superGroup = "Boars",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Boar"] = {
        superGroup = "Boars",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Maldraxxus Boar"] = {
        superGroup = "Boars",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Progenitor Wombat"] = {
        superGroup = "Boars",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Brutosaurs
    ["Mighty Caravan Brutosaur"] = {
        superGroup = "Brutosaurs",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Trader's Gilded Brutosaur"] = {
        superGroup = "Brutosaurs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Camels
    ["Camel"] = {
        superGroup = "Camels",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Explorer's Dunetrekker"] = {
        superGroup = "Camels",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Choppers
    ["Champion's Treadblade"] = {
        superGroup = "Choppers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mechano-Hog"] = {
        superGroup = "Choppers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Reaver Motorcycle"] = {
        superGroup = "Choppers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Warlord's Deathwheel"] = {
        superGroup = "Choppers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Chromatic Dragon
    ["Corruption of the Aspects"] = {
        superGroup = "Chromatic Dragon",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Heart of the Aspects"] = {
        superGroup = "Chromatic Dragon",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Clefthooves
    ["Clefthoof"] = {
        superGroup = "Clefthooves",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ironhoof Destroyer"] = {
        superGroup = "Clefthooves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Clefthoof (PVP)"] = {
        superGroup = "Clefthooves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Cloud Serpents
    ["Astral Cloud Serpent"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Cloud Serpent"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gladiator's Cloud Serpent (PVP)"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Heavenly Cloud Serpent"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sha-Warped Cloud Serpent"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Thundering Cloud Serpent"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Voyaging Wilderling"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Wilderling"] = {
        superGroup = "Cloud Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Creepers
    ["Void Creeper"] = {
        superGroup = "Creepers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Void Creeper (PVP)"] = {
        superGroup = "Creepers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Darkhounds
    ["Dark Iron Core Hound"] = {
        superGroup = "Darkhounds",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Darkhound"] = {
        superGroup = "Darkhounds",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Grimhowl"] = {
        superGroup = "Darkhounds",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Mawrat"] = {
        superGroup = "Darkhounds",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Direhorns
    ["Crusader's Direhorn"] = {
        superGroup = "Direhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Primordial Direhorn"] = {
        superGroup = "Direhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Dirigibles
    ["Darkmoon Dirigible"] = {
        superGroup = "Dirigibles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Dirigible"] = {
        superGroup = "Dirigibles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Orgrimmar Interceptor"] = {
        superGroup = "Dirigibles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Stormwind Skychaser"] = {
        superGroup = "Dirigibles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Dragonhawks
    ["Armored Blue Dragonhawk"] = {
        superGroup = "Dragonhawks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armored Red Dragonhawk"] = {
        superGroup = "Dragonhawks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Dragonhawk"] = {
        superGroup = "Dragonhawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Infused Dragonhawk"] = {
        superGroup = "Dragonhawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vengeance"] = {
        superGroup = "Dragonhawks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Drakes
    ["Chrono Corsair"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Drake of the Wind"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Feldrake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Fey Dragon"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Gladiator's Drake (PVP)"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Gladiator's Twilight Drake (PVP)"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Highland Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Horned Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Infinite Timereaver"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Onyxian Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Smoldering Ember Wyrm"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Steamscale Incinerator"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Stone Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sylverian Dreamer"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Tangled Dreamweaver"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Tarecgosa's Visage"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Voidwing"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["World Drake"] = {
        superGroup = "Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Dread ravens
    ["Corrupted Dreadwing"] = {
        superGroup = "Dread ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Dread Raven"] = {
        superGroup = "Dread ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Kareshi Dread Raven"] = {
        superGroup = "Dread ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Roc"] = {
        superGroup = "Dread ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },


    -- Elderhorns
    ["Crest-horn"] = {
        superGroup = "Elderhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Elderhorn"] = {
        superGroup = "Elderhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Highmountain Thunderhoof"] = {
        superGroup = "Elderhorns",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Elekks
    ["Armored Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armored Irontusk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Elekk Draenor"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Exarch's Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Fel Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Great Exarch's Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Lightforged Elekk"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Elekk (PVP)"] = {
        superGroup = "Elekks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Elemental hawks
    ["Blazing Royal Fire Hawk"] = {
        superGroup = "Elemental hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Fire Hawk"] = {
        superGroup = "Elemental hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Elementals
    ["Bound Blizzard"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Cascade"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Deathwalker"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    ["Farseer's Raging Tempest"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Glacial Tidestorm"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Runebound Firelord"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Shadow"] = {
        superGroup = "Elementals",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Felstalkers
    ["Felstalker"] = {
        superGroup = "Felstalkers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Flyers
    ["Kareshi Flyer"] = {
        superGroup = "Flyers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Void Infused Kareshi Flyer"] = {
        superGroup = "Flyers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Flying Carpets
    ["Flying Carpet"] = {
        superGroup = "Flying Carpets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Leywoven Flying Carpet"] = {
        superGroup = "Flying Carpets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Noble Flying Carpet"] = {
        superGroup = "Flying Carpets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Flying Discs

    ["Archmage's Prismatic Disc"] = {
        superGroup = "Flying Discs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Cloud"] = {
        superGroup = "Flying Discs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Compass Rose"] = {
        superGroup = "Flying Discs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Gearglider"] = {
        superGroup = "Flying Discs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Flying Elderhorns
    ["Grove Defiler"] = {
        superGroup = "Flying Elderhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grove Warden"] = {
        superGroup = "Flying Elderhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Spirit of Eche'ro"] = {
        superGroup = "Flying Elderhorns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },


    -- Flying Fishes
    ["Brinedeep Bottom-Feeder"] = {
        superGroup = "Flying Fishes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Underlight Behemoth"] = {
        superGroup = "Flying Fishes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Wondrous Wavewhisker"] = {
        superGroup = "Flying Fishes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Flying Machines
    ["Explorer's Jungle Hopper"] = {
        superGroup = "Flying Machines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Flying Machine"] = {
        superGroup = "Flying Machines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Turbo-Charged Flying Machine"] = {
        superGroup = "Flying Machines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Flying horses
    ["Ardenweald Courser"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Ardenweald Courser"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Bastion Courser"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Bastion Courser"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Bloodforged Courser (PVP)"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Courser"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Fiery Warhorse"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ghastly Charger"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Headless Horseman's"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Headless Horseman's Mount"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Highlord's Charger"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ironbound Wraithcharger"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Netherlord's Accursed Wrathsteed"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Netherlord's Wrathsteed"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Prestigious Courser (PVP)"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Warforged Nightmare"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Windsteed"] = {
        superGroup = "Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Flying sabers
    ["Arcanist's Manasaber"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Ash'adar"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Ban-Lu"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Jeweled Panther"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Luminous Starseeker"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mystic Runesaber"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Obsidian Nightwing"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Wen Lo"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Winged Guardian"] = {
        superGroup = "Flying sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Foxes
    ["Fox"] = {
        superGroup = "Foxes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Glimmerfur"] = {
        superGroup = "Foxes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sky Fox"] = {
        superGroup = "Foxes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Fox (PVP)"] = {
        superGroup = "Foxes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vulpine Familiar"] = {
        superGroup = "Foxes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Furlines
    ["Startouched Furline"] = {
        superGroup = "Furlines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sunwarmed Furline"] = {
        superGroup = "Furlines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Gargons
    ["Armored Gargon"] = {
        superGroup = "Gargons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gargon"] = {
        superGroup = "Gargons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Goblin Trikes
    ["Goblin Trike"] = {
        superGroup = "Goblin Trikes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Goblin Turbo-Trike"] = {
        superGroup = "Goblin Trikes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Trike (PVP)"] = {
        superGroup = "Goblin Trikes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Gorms
    ["Gorm"] = {
        superGroup = "Gorms",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Gorm (PVP)"] = {
        superGroup = "Gorms",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Grinders
    ["Geargrinder"] = {
        superGroup = "Grinders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Meat Wagon"] = {
        superGroup = "Grinders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Gronnlings
    ["Felblood Gronnling (PVP)"] = {
        superGroup = "Gronnlings",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gronnling"] = {
        superGroup = "Gronnlings",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Ground ravens
    ["Raven Lord"] = {
        superGroup = "Ground ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Grounded ravens
    ["Elemental Raven"] = {
        superGroup = "Grounded ravens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Gryphons
    ["Alabaster Stormtalon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Algari Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Algarian Stormrider"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Alunira"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Armored Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Chaos-Forged Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grand Armored Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grand Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Spectral Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Swift Spectral Gryphon"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Winged Steed of the Ebon Blade"] = {
        superGroup = "Gryphons",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Hawks
    ["Great Raven"] = {
        superGroup = "Hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Peafowl"] = {
        superGroup = "Hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Progenitor Hawk"] = {
        superGroup = "Hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Skyblazer"] = {
        superGroup = "Hawks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Hawkstriders
    ["Armored Hawkstrider"] = {
        superGroup = "Hawkstriders",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Hawkstrider"] = {
        superGroup = "Hawkstriders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Starcursed Voidstrider"] = {
        superGroup = "Hawkstriders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Turkeys"] = {
        superGroup = "Hawkstriders",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Vicious Warstrider (PVP)"] = {
        superGroup = "Hawkstriders",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Hippogryphs
    ["Armored Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Blazing Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Chaos-Forged Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Corrupted Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Emerald Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Flameward Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Leyfeather Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Teldrassil Hippogryph"] = {
        superGroup = "Hippogryphs",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Horses
    ["Armored Horse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armored Warhorse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Banshee's Charger"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Bloodflank Charger"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Crusader's Warhorse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Darkmoon Charger"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Deathcharger"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Dreadsteed"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Felsteed"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Horse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Kul Tiran Charger"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Mawsworn Horse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mountain Horse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Saddled Horse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Seabraid Stallion"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Spectral Steed"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious Gilnean Warhorse (PVP)"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["War Steed (PVP)"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Warhorse"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Zhevra"] = {
        superGroup = "Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Hyenas
    ["Caravan Hyena"] = {
        superGroup = "Hyenas",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Cartel Hyena"] = {
        superGroup = "Hyenas",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Hyena"] = {
        superGroup = "Hyenas",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Jellyfishes
    ["Jelly"] = {
        superGroup = "Jellyfishes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ny'alotha Allseer"] = {
        superGroup = "Jellyfishes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Progenitor Aurelid"] = {
        superGroup = "Jellyfishes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Kite
    ["Kite"] = {
        superGroup = "Kite",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Tuskarr Shoreglider"] = {
        superGroup = "Kite",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Kodos
    ["Armored Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armored Siege Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Brewfest Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Great Sunwalker Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Sunwalker Kodo"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Kodo (PVP)"] = {
        superGroup = "Kodos",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Lions
    ["Eternal Phalynx"] = {
        superGroup = "Lions",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Golden King"] = {
        superGroup = "Lions",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Larion"] = {
        superGroup = "Lions",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Phalynx"] = {
        superGroup = "Lions",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Lion (PVP)"] = {
        superGroup = "Lions",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Lupines
    ["Heartbond Lupine"] = {
        superGroup = "Lupines",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious Warstalker (PVP)"] = {
        superGroup = "Lupines",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Mammoths
    ["Grand Mammoth"] = {
        superGroup = "Mammoths",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Magmammoth"] = {
        superGroup = "Mammoths",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mammoth"] = {
        superGroup = "Mammoths",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Trawling Mammoth"] = {
        superGroup = "Mammoths",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Mechaheads
    ["Mecha-Mogul Mk2"] = {
        superGroup = "Mechaheads",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Mimiron's Head"] = {
        superGroup = "Mechaheads",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["The Big G"] = {
        superGroup = "Mechaheads",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Mechanostriders
    ["Armored Mechanostrider"] = {
        superGroup = "Mechanostriders",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mechagon Mechanostrider"] = {
        superGroup = "Mechanostriders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mechanostrider"] = {
        superGroup = "Mechanostriders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Mechanostrider (PVP)"] = {
        superGroup = "Mechanostriders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Mechaspiders
    ["Carcinized Zerethsteed"] = {
        superGroup = "Mechaspiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Mechaspider"] = {
        superGroup = "Mechaspiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Shreddertank"] = {
        superGroup = "Mechaspiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Mechsuits
    ["Cartel Mechasuit"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Diamond Mechsuit"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Dwarven Mechsuit"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Felsteel Annihilator"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["G.M.O.D."] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Lightforged Warframe"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Magnetomech"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["OC91 Chariot"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Rocket Shredder 9001"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sky Golem"] = {
        superGroup = "Mechsuits",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Moles
    ["Fancy Mole"] = {
        superGroup = "Moles",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mole"] = {
        superGroup = "Moles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Moonbeasts
    ["Gleaming Moonbeast"] = {
        superGroup = "Moonbeasts",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious Moonbeast (PVP)"] = {
        superGroup = "Moonbeasts",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Nether Drakes
    ["Grotto Netherwing Drake"] = {
        superGroup = "Nether Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Nether Drake"] = {
        superGroup = "Nether Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Nether Drake (PVP)"] = {
        superGroup = "Nether Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Ohunas
    ["Divine Kiss of Ohn'ahra"] = {
        superGroup = "Ohunas",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Ohuna"] = {
        superGroup = "Ohunas",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Ottuks
    ["Armored Ottuk"] = {
        superGroup = "Ottuks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ottuk"] = {
        superGroup = "Ottuks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Owls
    ["Anu'relos"] = {
        superGroup = "Owls",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Charming Courier"] = {
        superGroup = "Owls",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Oxes
    ["Astral Aurochs"] = {
        superGroup = "Oxes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Lucky Yun"] = {
        superGroup = "Oxes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Phoenixes
    ["Ashes of Al'ar"] = {
        superGroup = "Phoenixes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Clutch of.."] = {
        superGroup = "Phoenixes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Dark Phoenix"] = {
        superGroup = "Phoenixes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Golden Ashes of Al'ar"] = {
        superGroup = "Phoenixes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Pandaren Phoenix"] = {
        superGroup = "Phoenixes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Plaguebats
    ["Amalgam of Rage"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Antoran flying hound"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Demonic Fel Bat (Legion Remix)"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Fel Bat"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Fel Bat (Legion Remix)"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Gladiator's Fel Bat (PVP)"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Herald of Sa'bak"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Skyrazor"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Slayer's Felbroken Shrieker"] = {
        superGroup = "Plaguebats",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Proto-Drakes
    ["Battlelord's Bloodthirsty War Wyrm"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Frostbrood Proto-Wyrm"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Gladiator's Proto-Drake (PVP)"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Proto-Drake"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Razorscale Proto-Drake"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Renewed Proto-Drake"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Spawn of Galakras"] = {
        superGroup = "Proto-Drakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Pterrordax
    ["Battle Pterrordax"] = {
        superGroup = "Pterrordax",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Thunder Pterrordax"] = {
        superGroup = "Pterrordax",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Windborne Velocidrake"] = {
        superGroup = "Pterrordax",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Qirajis
    ["Grinning Reaver"] = {
        superGroup = "Qirajis",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Qiraji Battle Tank"] = {
        superGroup = "Qirajis",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Qiraji War Tank"] = {
        superGroup = "Qirajis",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Quilens
    ["Flying Quilen"] = {
        superGroup = "Quilens",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Quilen"] = {
        superGroup = "Quilens",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Rams
    ["Armored Ram"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Darkforge Ram"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Earthen Ordinant's Ramolith"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Ram"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ramolith"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Stormpike Battle Ram"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Ram (PVP)"] = {
        superGroup = "Rams",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Raptors
    ["Armored Primal Raptor"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armored Raptor"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Dreamtalon"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Fossilized Raptor"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Ivory Savagemane"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Jani's Trashpile"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Primal Raptor"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Raptor"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious Dreamtalon (PVP)"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious War Raptor (PVP)"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Rats
    ["Ratstallion"] = {
        superGroup = "Rats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Sarge's Tale"] = {
        superGroup = "Rats",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Squeakers, the Trickster"] = {
        superGroup = "Rats",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Rockets
    ["Cartel Rocket"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Depleted-Kyparium Rocket"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Geosynchronous World Spinner"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Lunar Launcher"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Rocket"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["X-53 Touring Rocket"] = {
        superGroup = "Rockets",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Sabers
    ["Arcane Saber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Saber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Dreamsaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Felsaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Jigglesworth Sr."] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Lynx"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Nightborne Manasaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Nightsaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Nightsaber Horde Mount"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Priestess' Moonsaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Primal Flamesaber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Saber"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Sha-Warped Riding Tiger"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Shado-Pan Tiger"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Spectral Tiger"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Swift Spectral Tiger"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious Sabertooth (PVP)"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious Warsaber (PVP)"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["X-995 Mechanocat"] = {
        superGroup = "Sabers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Scarabs
    ["Ivory Goliathus"] = {
        superGroup = "Scarabs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Scarab"] = {
        superGroup = "Scarabs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Telix"] = {
        superGroup = "Scarabs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Scorpions
    ["Juggernaut"] = {
        superGroup = "Scorpions",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Scorpion"] = {
        superGroup = "Scorpions",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Scorpion (PVP)"] = {
        superGroup = "Scorpions",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Seahorses
    ["Fabious"] = {
        superGroup = "Seahorses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Seahorse"] = {
        superGroup = "Seahorses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Tidestallion"] = {
        superGroup = "Seahorses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Serpents
    ["Ensorcelled Everwyrm"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["N'Zoth serpent"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Nether-Gorged Greatwyrm"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Serpent"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Slime Serpent"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Timbered Sky Snake"] = {
        superGroup = "Serpents",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Skeletal Horses
    ["Armored Skeletal Horse"] = {
        superGroup = "Skeletal Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Midnight"] = {
        superGroup = "Skeletal Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Risen Mare"] = {
        superGroup = "Skeletal Horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Skeletal Horse"] = {
        superGroup = "Skeletal Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious Skeletal Warhorse (PVP)"] = {
        superGroup = "Skeletal Horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Skiffs
    ["The Breaker's Song"] = {
        superGroup = "Skiffs",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["The Dreadwake"] = {
        superGroup = "Skiffs",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Skyreavers
    ["Armored Chimera"] = {
        superGroup = "Skyreavers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ashenvale Chimaera"] = {
        superGroup = "Skyreavers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Chimera"] = {
        superGroup = "Skyreavers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Cormaera"] = {
        superGroup = "Skyreavers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Flayedwing"] = {
        superGroup = "Skyreavers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },


    -- Slitherdrakes
    ["Auspicious Arborwyrm"] = {
        superGroup = "Slitherdrakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Gladiator's Slitherdrake (PVP)"] = {
        superGroup = "Slitherdrakes",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Winding Slitherdrake"] = {
        superGroup = "Slitherdrakes",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Snails
    ["Progenitor Snail"] = {
        superGroup = "Snails",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Seething Slug"] = {
        superGroup = "Snails",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Snail"] = {
        superGroup = "Snails",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Snailemental"] = {
        superGroup = "Snails",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious War Snail (PVP)"] = {
        superGroup = "Snails",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
    },


    -- Snapdragons
    ["Prismatic Snapdragon"] = {
        superGroup = "Snapdragons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Snapdragon"] = {
        superGroup = "Snapdragons",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Soul Eaters
    ["Gladiator's Soul Eater (PVP)"] = {
        superGroup = "Soul Eaters",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Zovaal's Soul Eater"] = {
        superGroup = "Soul Eaters",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Spiders
    ["Bloodfang Widow"] = {
        superGroup = "Spiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Progenitor Spider"] = {
        superGroup = "Spiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Undercrawler"] = {
        superGroup = "Spiders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious War Spider (PVP)"] = {
        superGroup = "Spiders",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Stags
    ["Dreamstag"] = {
        superGroup = "Stags",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Enchanted Runestag"] = {
        superGroup = "Stags",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Progenitor Stag"] = {
        superGroup = "Stags",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Runestag"] = {
        superGroup = "Stags",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Storm Dragons
    ["Demonic Gladiator's Storm Dragon (PVP)"] = {
        superGroup = "Storm Dragons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gladiator's Storm Dragon (PVP)"] = {
        superGroup = "Storm Dragons",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Storm Dragon"] = {
        superGroup = "Storm Dragons",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Striders
    ["Hornstrider"] = {
        superGroup = "Striders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Strider"] = {
        superGroup = "Striders",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Swarmites
    ["Bloodswarmer"] = {
        superGroup = "Swarmites",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Devourer"] = {
        superGroup = "Swarmites",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Swarmite"] = {
        superGroup = "Swarmites",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Skyflayer (PVP)"] = {
        superGroup = "Swarmites",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Sweepers
    ["Eve's Ghastly Rider"] = {
        superGroup = "Sweepers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sweeper"] = {
        superGroup = "Sweepers",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Talbuks
    ["Argus Talbuk"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Talbuk"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Lightforged Ruinstrider"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Maddened Chaosrunner"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Talbuk"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Talbuk Draenor"] = {
        superGroup = "Talbuks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Tauraluses
    ["Armored Tauralus"] = {
        superGroup = "Tauraluses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Tauralus"] = {
        superGroup = "Tauraluses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Toads
    ["Arboreal Gulper"] = {
        superGroup = "Toads",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Hopper"] = {
        superGroup = "Toads",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Progenitor Gulper"] = {
        superGroup = "Toads",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Vicious War Croaker (PVP)"] = {
        superGroup = "Toads",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Turtles
    ["Dragon Turtle "] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Great Dragon Turtle"] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Savage Battle Turtle"] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Sea Turtle"] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Super Armored Turtle"] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Vicious War Turtle (PVP)"] = {
        superGroup = "Turtles",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Vanquisher Wyrms
    ["Deathlord's Vilebrood Vanquisher"] = {
        superGroup = "Vanquisher Wyrms",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Gladiator's Frost Wyrm (PVP)"] = {
        superGroup = "Vanquisher Wyrms",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vanquisher"] = {
        superGroup = "Vanquisher Wyrms",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Vorquins
    ["Armored Vorquin"] = {
        superGroup = "Vorquins",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vorquin"] = {
        superGroup = "Vorquins",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Winged Flying horses
    ["Celestial Steed"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Cindermane Charger"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Hearthsteed"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Inarius' Charger"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Invincible"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Tyrael's Charger"] = {
        superGroup = "Winged Flying horses",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },


    -- Wolves
    ["Alliance Wolf Mount"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Draenor Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Armored Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Beastlord's Warwolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Draenor Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Frostwolf Snarler"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Infernal Direwolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Ironclad Frostclaw"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Kor'kron War Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Mag'har Direwolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Spectral Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = false, isUniqueEffect = true },
    },

    ["War Wolf (PVP)"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Wolf"] = {
        superGroup = "Wolves",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Wyverns
    ["Alabaster Thunderwing"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Armored Wyvern"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = true, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Chaos-Forged Wind Rider"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Cliffside Wylderdrake"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = true, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grand Armored Wyvern"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Grand Wyvern"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Spectral Wind Rider"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = true },
    },

    ["Wyvern"] = {
        superGroup = "Wyverns",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Yaks
    ["Grand Expedition Yak"] = {
        superGroup = "Yaks",
        traits = { hasMinorArmor = false, hasMajorArmor = true, hasModelVariant = true, isUniqueEffect = false },
    },

    ["Yak"] = {
        superGroup = "Yaks",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Zereth Overseers
    ["Void Zereth Overseer"] = {
        superGroup = "Zereth Overseers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Zereth Overseer"] = {
        superGroup = "Zereth Overseers",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },


    -- Standalone
    ["Alpaca"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Aquilon"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ardenmoth"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Armoredon"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Bruffalon"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Butterfly"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Chauffeured vehicle"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Core Hound"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Corpsefly"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Crane"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Crawg"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Crawler"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Devouring Mauler"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Drone"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Falcosaur"] = {
        superGroup = "Raptors",
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = true, isUniqueEffect = true },
    },

    ["Ferocious Jawcrawler"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Flarendo the Furious"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Glowmite"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Goat"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gorger"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Gravewing"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Grrloc"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Harvesthog"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["High Priest's Lightsworn Seeker"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Hogrus"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Huntmaster's Wolfhawk"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Infernal"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Jade"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Krolusk"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Magic Rooster"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mana Ray"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mawguard Hand"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mechacycle"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Meeksi"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Mushan Beast"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Nether Ray"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Progenitor Wasp"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Razorwing"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Riverwallow"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Salamanther"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Sea Ray"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Shalewing"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Shu-Zen"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Skitterfly"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Slateback"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Slyvern"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Soar"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Soaring Spelltome"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["The Hivemind"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Thunderspine"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Ur'zul"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious Electro Eel (PVP)"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Vicious War Riverbeast (PVP)"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Viridian Phase-Hunter"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Wandering Ancient"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Water Strider"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Waveray"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Whelpling"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Wildseed Cradle"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Wooly White Rhino"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Xiwyllag ATV"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

    ["Yeti"] = {
        superGroup = nil,
        traits = { hasMinorArmor = false, hasMajorArmor = false, hasModelVariant = false, isUniqueEffect = false },
    },

}