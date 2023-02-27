// 在这里存放所有的参数数据，方便后面的修改与维护

// parameters for "GFLhelpers.as":

    array<string> unlockable_vehicles = {
        "deco_car1_brown.vehicle",
        "deco_car1_blue.vehicle",
        "deco_car1_yellow.vehicle",
        "deco_car1_black.vehicle",
        "deco_car1_white.vehicle",
        "deco_car1_red.vehicle",
        "deco_car1_pink.vehicle",
        "deco_car1_green.vehicle",

        "deco_car2_red.vehicle",
        "deco_car2_green.vehicle",
        "deco_car2_yellow.vehicle",
        "deco_car2_white.vehicle",
        "deco_car2_silver.vehicle",
        "deco_car2_grey.vehicle",
        "deco_car2_brown.vehicle",
        "deco_car2_blue.vehicle",
        "deco_car2_black.vehicle",

        "deco_car3_sky.vehicle",
        "deco_car3_green.vehicle",
        "deco_car3_blue.vehicle",
        "deco_car3_red.vehicle",
        "deco_car3_yellow.vehicle",
        "deco_car3_black.vehicle",

        "deco_van_blue.vehicle",
        "deco_van_khaki.vehicle",
        "deco_van_sky.vehicle",
        "deco_van_brown.vehicle",
        "deco_van_yellow.vehicle",
        "deco_van_red.vehicle",
        "deco_van_green.vehicle",

        "deco_pickup_red.vehicle",
        "deco_pickup_yellow.vehicle",
        "deco_pickup_blue.vehicle",
        "deco_pickup_green.vehicle",
        "deco_pickup_khaki.vehicle",

        "dumpster.vehicle",
        "cover1.vehicle",
        "cover2.vehicle",
        "shelter.vehicle"
    };

    array<string> vip_vehicles = {
        "mobile_armory.vehicle", 		// 军械车
        "armored_truck.vehicle",		// 艾莫号
        "ogas_pulse_generator.vehicle",	// OGAS干扰仪
        "radio_jammer.vehicle",
        "radio_jammer2.vehicle"
    };

    dictionary specialHealIndex = {
            // 空需求
            {"",-1},

            // 白教指挥士回血
            {"para_heal",1},

            // 下面这行是用来占位的，在这之上添加新的即可
            {"666",-1}
    };    


// parameters for "ItemDropEvent.as":

    dictionary itemDropFileIndex = {
        // 空
        {"",0},

        {"firecontrol.carry_item",1},       // 火控核心
        {"core_mask.carry_item",2},         // 真核面具  
        {"upgrade_type88.carry_item",3},    // 汉阳造加速线圈
        {"upgrade_aa12.carry_item",4},      // AA12独头弹
        {"upgrade_m1.carry_item",5},      // M1加兰德弹鼓
        {"upgrade_fg42.carry_item",6},      // FG42
        {"upgrade_g41.carry_item",7},      // G41
        {"upgrade_vz61.carry_item",8},      // vz61
        {"upgrade_m1903_1.carry_item",9},      // 太太
        {"upgrade_m1903_2.carry_item",10},      // 太太
        {"upgrade_fn49.carry_item",11},      // FN49
        {"upgrade_9a91.carry_item",12},      // 9A91
        {"upgrade_m14.carry_item",13},
        {"upgrade_g3.carry_item",14},
        {"upgrade_m1897.carry_item",15},
        {"upgrade_stg44.carry_item",16},
        {"upgrade_wa2000.carry_item",17},
        {"upgrade_pkp.carry_item",18},
        {"upgrade_scarl.carry_item",19},
        {"upgrade_scarh.carry_item",20},
        {"upgrade_cso.carry_item",21},

        {"666",0}
    };

    dictionary itemDropKeyIndex = {
        // 空
        {"",0},

        {"mod3",1},                         // 火控核心
        {"truecore",2},                     // 真核面具  
        {"type88",3},                       // 汉阳造加速线圈
        {"aa12",4},                         // AA12独头弹
        {"m1garand",5},                     // M1加兰德弹鼓
        {"fg42",6},                         // FG42
        {"g41",7},                          // G41
        {"vz61",8},                         // vz61
        {"m1903_1",9},                      // m1903
        {"m1903_2",10},                     // m1903
        {"fn49",11},                        // fn49
        {"9a91",12},                        // 9a91
        {"m14",13},
        {"g3",14},
        {"m1897",15},
        {"stg44",16},
        {"wa2000",17},
        {"pkp",18},
        {"scarl",19},
        {"scarh",20},
        {"cso",21},

        {"666",0}
    };

    dictionary Tier6VestIndex = {
        // 空
        {"",0},

        {"exchange_t6_ticket_1",1},
        {"exchange_t6_ticket_2",2}, 
        {"exchange_t6_ticket_3",3}, 
        {"exchange_t6_ticket_4",4},     
        {"exchange_t6_ticket_5",5}, 
        {"exchange_t6_ticket_6",6}, 
        {"exchange_t6_ticket_7",7}, 
        {"exchange_t6_ticket_8",8}, 
        {"exchange_t6_ticket_9",9}, 
        {"exchange_t6_ticket_10",10}, 
        {"exchange_t6_ticket_11",11}, 
        {"exchange_t6_ticket_12",12}, 
        {"exchange_t6_ticket_13",13}, 

        {"666",0}
    };


// parameters for "ServerHelper.as":

    dictionary lv120dict={
        {"DUSK",361.0},
        {"M14MOD3",431.0},
        {"MOQIAN",561.0},
        {"PENGLAISI",621.0},
        {"WOSHIEOE1999",661.0},
        {"VIVI",710.0},
        {"MELONDOVE",761.0},
        {"LAPPLAND",811.0},
        {"AK12",811.0},
        {"HUIR",861.0},
        {"ALIEN",911.0},
        {"SAIWA",961.0},
        {"ASANONANA",1011.0},
        {"IAQS",1111.0},
        {"WHITE",1161.0},
        {"MAPPLE",1261.0},
        {"TEST310",1311.0},
        {"TONYZSZ",1361.0},
        {"MAJOR_KAI",1411.0},
        {"AMEMLIKY",1461.0},
        {"AACCBB",1511.0},
        {"HOW",1561.0},
        {"CHADOFCHANS",1611.0},
        {"AURORA_ZERO",1661.0},
        {"ANGELICA",1711.0},
        {"D_GAODIAO",1761.0},
        {"DD",1811.0},
        {"HASUMI",1861.0},
        {"KUAT",1911.0},
        {"MYA",1961.0},
        {"HOSIAYA",2011.0},
        {"ATID",2061.0},
        {"FUYU",2111.0},
        {"FNF",2161.0},
        {"SALTFISHFIELD",2211.0},
        {"STALINA",2261.0},
        {"SUIGETSU",2311.0},
        {"TMP.1",2361.0},
        {"YORIKO",2411.0},
        {"YOUYUE",2461.0},
        {"CAP.DAHUA",2511.0},
        {"GANDURO",2561.0},
        {"DILING",2611.0},
        {"O_OLONICERA",2711.0},
        {"JLK941",2761.0},
        {"ROYI",2811.0},
        {"MIRRORWAVE",2861.0},
        {"PIG744",2911.0},
        {"CAT HEAD",2961.0},
        {"HUALIN",3011.0},
        {"NEKO_CUP",3061.0},
        {"EISEN",3110.0},
        {"NETHER_CROW",761.0}
    };
