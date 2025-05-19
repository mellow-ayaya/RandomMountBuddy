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
	[205] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=203
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[206] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=204
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[207] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=205
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
	[231] = {
		-- TypeName: "2"
		-- Relevant Caps: Capability_0=231, Capability_1=265
		isGround = false,
		isAquatic = true,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[232] = {
		-- TypeName: "2"
		-- Relevant Caps: Capability_0=232
		isGround = false,
		isAquatic = true,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[233] = {
		-- TypeName: "2"
		-- Relevant Caps: Capability_0=234
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[241] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=256, Capability_1=257, Capability_2=258
		isGround = true,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[242] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=259
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[245] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=494, Capability_1=455
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[246] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=494, Capability_1=457, Capability_2=456
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[247] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=457, Capability_1=456, Capability_2=455, Capability_3=236, Capability_4=235
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[248] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=457, Capability_1=456, Capability_2=455, Capability_3=227, Capability_4=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[254] = {
		-- TypeName: "2"
		-- Relevant Caps: Capability_0=451, Capability_1=450, Capability_2=449, Capability_3=448, Capability_4=447, Capability_5=265, Capability_6=272
		isGround = false,
		isAquatic = true,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[264] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=202
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[269] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_1=306, Capability_2=307
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[283] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=315
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[284] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=316
		isGround = true,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[291] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=321
		isGround = true,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[292] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=328
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[293] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=329
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[295] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=332, Capability_1=318, Capability_2=284, Capability_3=250, Capability_4=247, Capability_5=244, Capability_6=238, Capability_7=241, Capability_8=325, Capability_9=333
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[296] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=336
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[398] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=506, Capability_1=454, Capability_2=453, Capability_3=452, Capability_4=227, Capability_5=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[400] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=459
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[401] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=461
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[402] = {
		-- TypeName: "13"
		-- Relevant Caps: Capability_0=462, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=227, Capability_5=226
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[407] = {
		-- TypeName: "3"
		-- Relevant Caps: Capability_0=468, Capability_1=473, Capability_2=474, Capability_3=479, Capability_4=480
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = false,
		isUnused = false,
	},
	[408] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=475
		isGround = true,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[409] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=483
		isGround = false,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[410] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=484
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[411] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=485, Capability_1=227, Capability_2=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[412] = {
		-- TypeName: "2"
		-- Relevant Caps: Capability_0=479, Capability_1=480
		isGround = true,
		isAquatic = true,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[413] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=486
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[418] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=489
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[419] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=490
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[420] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=491
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[421] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=492
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[422] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=493
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
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
	[426] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=499
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[430] = {
		-- TypeName: "4"
		-- Relevant Caps: Capability_0=502, Capability_1=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[431] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=503, Capability_1=516, Capability_2=517, Capability_3=518, Capability_4=519, Capability_5=520, Capability_6=521, Capability_7=522, Capability_8=523, Capability_9=527, Capability_10=528, Capability_11=529, Capability_12=227, Capability_13=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[433] = {
		-- TypeName: "1"
		-- Relevant Caps: Capability_0=504, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=227, Capability_5=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[435] = {
		-- TypeName: "5"
		-- Relevant Caps: Capability_0=508, Capability_1=483
		isGround = false,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[436] = {
		-- TypeName: "7"
		-- Relevant Caps: Capability_0=494, Capability_1=468, Capability_2=473, Capability_3=474, Capability_4=479, Capability_5=480
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[437] = {
		-- TypeName: "5"
		-- Relevant Caps: Capability_0=494, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=236, Capability_5=235
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[438] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=509
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[439] = {
		-- TypeName: "6"
		-- Relevant Caps: Capability_0=510, Capability_1=451, Capability_2=450, Capability_3=449, Capability_4=448, Capability_5=447, Capability_6=265, Capability_7=272
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[440] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=511
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[441] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=512
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[442] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=457, Capability_1=456, Capability_2=455, Capability_3=483
		isGround = false,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[444] = {
		-- TypeName: "5"
		-- Relevant Caps: Capability_0=462, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=227, Capability_5=226
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[445] = {
		-- TypeName: "13"
		-- Relevant Caps: Capability_0=494, Capability_1=457, Capability_2=456, Capability_3=455, Capability_4=227, Capability_5=226
		isGround = true,
		isAquatic = false,
		isSteadyFly = true,
		isSkyriding = true,
		isUnused = false,
	},
	[446] = {
		-- TypeName: "5"
		-- Relevant Caps: Capability_0=514
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[447] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=515
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = false,
	},
	[448] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=227, Capability_1=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
	[450] = {
		-- TypeName: "0"
		-- Relevant Caps: Capability_0=524, Capability_1=227, Capability_2=226
		isGround = false,
		isAquatic = false,
		isSteadyFly = false,
		isSkyriding = false,
		isUnused = true,
	},
}
-- END OF HELPER --
