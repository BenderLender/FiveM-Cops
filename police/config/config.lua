config = {
	enableOutfits = false,
	
	slowPlayers = true, --Whether or not players vehicles will be slowed down inside of Speed Zones.
	slowSpeed = 20, -- Speed in MPH players vehicles will be slowed while inside of Speed Zones.


	stationBlipsEnabled = true, -- switch between true or false to enable/disable blips for police stations
	useCopWhitelist = false, -- do not turn on (keep false)

	enable = true, -- 911 system
	prefix = "^4^*DISPATCH^0 ",
	AutoRemove = 180, -- in seconds, delay to auto remove blips
	
	enableOtherCopsBlips = true,
	useNativePoliceGarage = false,
	enableNeverWanted = true,

	--- discord log for clock in/out
	Webhook = "https://discord.com/api/webhooks/1108264979246891028/opF5Q9BbrNChQH4a-CyrSa6DcJjiEwkcOvgwBNvqwFG-qpnuA4Nj8gKRyGk1mqD0_oEW",

	--- gas mask below
	mask = 175, -- (46 by default) Change this to whichever mask you want to be equipped when using the command
	showhud = false,
	hudx = .225, -- X value of hud (used for positioning across X axis)
	hudy = .952, -- Y value of hud (used for positioning across Y axis)
	hudscale = 0.4, -- Scale of hud

	
	enablePaychecks = false,
	weekly_salary = 931,
	
	propsSpawnLimitByCop = 20,
		
	--Available languages : 'en', 'fr', 'de'
	lang = 'en',
		
	bindings = {
		interact_position = 51, -- E
		use_police_menu = 166, -- F5
		accept_fine = 246, -- Y
		refuse_fine = 45 -- R
	},

	--Customizable Departments
	departments = {
		label = {
			[0] = "CSRP"
		},

		minified_label = {
			[0] = "LEO"
		}
	},

	doorList = {
		---------------------
		-- Mission Row PD --
		---------------------
		-- Right Door to Stairs
		[1] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 473.6824, 
			["y"] = -977.6312, 
			["z"] = 21.71524, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Left Door to Stairs
		[2] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 473.6824, 
			["y"] = -981.6856, 
			["z"] = 21.71524, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Cell Gate to Cell Block
		[3] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 465.7285, 
			["y"] = -988.8992, 
			["z"] = 21.70982, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Cell Gate to cell block to cells
		[4] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 470.9623, 
			["y"] = -987.5266, 
			["z"] = 21.70897, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Cell 2
		[5] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 473.6824, 
			["y"] = -985.7404, 
			["z"] = 21.71524, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Cell 3
		[6] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 473.6824, 
			["y"] = -973.5769, 
			["z"] = 21.71524, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Single Door to Back
		[7] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 469.5333, 
			["y"] = -976.3301, 
			["z"] = 21.71711, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Right Door to Back
		[8] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 469.5305, 
			["y"] = -972.2762, 
			["z"] = 21.70854, 
			["locked"] = true, 
			["distance"] = 2
		},
		-- Left Door to Back
		[9] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 469.5333, 
			["y"] = -980.3849, 
			["z"] = 21.71711, 
			["locked"] = true, 
			["distance"] = 2
		},
		[10] = { 
			["objName"] = "dt_19_garage_doorsafe", 
			["x"] = 447.834, 
			["y"] = -992.424, 
			["z"] = 21.70754, 
			["locked"] = true, 
			["distance"] = 2
		},
		[11] = { 
			["objName"] = "dt_19_garage_cell_door", 
			["x"] = 469.5333, 
			["y"] = -984.4391, 
			["z"] = 21.71711, 
			["locked"] = true, 
			["distance"] = 2
		}
	},



	
	--Customizable ranks
	rank = {

		--You can add or remove ranks as you want (just make sure to use numeric index, ascending)
		label = {
			[0] = "'LEO'", -- Ranger Rank
			
		},

		--Used for chat
		minified_label = {
			[0] = "TNE",
			[1] = "TNE", --1
			[2] = "TNE",
			[3] = "TNE",

			[4] = "PR",
			[5] = "PO", --2
			[6] = "DS",
			[7] = "ST",

			[8] = "PR2",
			[9] = "MPO", --3
			[10] = "DS2",
			[11] = "ST2",

			[12] = "SGT",
			[13] = "SGT", --4
			[14] = "SGT",
			[15] = "SGT",

			[16] = "LT",
			[17] = "LT", --5
			[18] = "LT",
			[19] = "LT",

			[20] = "CPT",
			[21] = "CPT", --6
			[22] = "CPT",
			[23] = "CPT",

			[24] = "GW",
			[25] = "COP", --7
			[26] = "SHF",
			[27] = "COS",

			[28] = "RAR",
			[29] = "APR", --8
			[30] = "ASR",
			[31] = "SSR",
		},

		--You can set here a badge for each rank you have. You have to enable "enableOutfits" to use this
		--The index is the rank index, the value is the badge index.
		--Here a link where you have the 4 MP Models badges with their index : https://kyominii.com/fivem/index.php/MP_Badges
		outfit_badge = {
			[0] = 0,
			[1] = 0,
			[2] = 0,
			[3] = 0,

			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,

			[8] = 1,
			[9] = 1,
			[10] = 1,
			[11] = 1,

			[12] = 1,
			[13] = 1,
			[14] = 1,
			[15] = 1,

			[16] = 2,
			[17] = 2,
			[18] = 2,
			[19] = 2,

			[20] = 2,
			[21] = 2,
			[22] = 2,
			[23] = 2,

			[24] = 3,
			[25] = 3,
			[26] = 3,
			[27] = 3,

			[28] = 3,
			[29] = 3,
			[30] = 3,
			[31] = 3,
		},

		--Minimum rank require to modify officers rank
		min_rank_set_rank = 24
	}
}

clockInStation = {
  {x=853.22, y=-1313.35, z=28.24}, -- La Mesa
  {x=418.61, y=-985.21, z=21.56}, -- Mission Row
  {x=1839.4, y=3678.51, z=38.93}, -- Sandy Shore
  {x=-439.02, y=5990.67, z=31.72}, -- Paleto Bay
  --still need to add vespucci
  {x=362.00, y=-1591.78, z=25.45} -- Davis Sheriff station
}

garageStation = {
}

heliStation = {
    {x=481.52, y=-982.2, z= 41.01}, -- Mission Row 1
	{x=448.99, y=-981.16, z= 43.69}, -- Mission Row 2
	{x=1853.35, y=3706.3, z=33.00}, -- Sandy Shores
	{x=-475.37, y=5988.42, z=31.34} -- Paleto Bay
}

armoryStation = {
}

i18n.setLang(tostring(config.lang))
