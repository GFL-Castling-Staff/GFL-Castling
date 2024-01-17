// 在这里存放所有的参数数据，方便后面的修改与维护

// parameters for "commandskill.as"

    array<string> eliteEnemyName = {

        // sf
        "sfw_hunter",
        "sfw_architect",
        "sfw_Intruder",
        "sfw_Dreamer",
        "sfw_Alchemist",
        "sfw_Gager",
        "sfw_Excutioner-Wind_rose",
        "sfw_Excutioner-Queen_of_the_Moon",
        "sfw_M16A1",
        "sfw_Agent",
        "sfw_Destroyer",
        "sfw_Weaver",
        "sfw_Justice",
        "sfw_Scarecrow",
        "sf_manticore",

        // paradeus
        "alina",
        "Thunder",
        "teal",
        "eagleyes",
        "vanguard",
        "wrath",
        "aileron",
        "Nimogen",
        "Narciss",
        "Adeline",
        "Paradeus_doppelsoldner",
        "Paradeus_roarer",
        "parw_grenadier",
        "parw_hammer",
        "parw_commander",

        // kcco
        "kcco_Hydra",
        "kcco_teslatrooper",
        "kcco_human_sniper",
        "kcco_quartz_ranger",
        "kcco_zircon_squadleader",
        "kcco_ar_human_tel",
        "kcco_dog",
        "kcco_ar_human_elite"
    };

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
        "radio_jammer2.vehicle",
        "sf_boss_intruder_skill.vehicle"
    };

    dictionary specialHealIndex = {
            // 空需求
            {"",-1},

            // 白教指挥士回血
            {"para_heal",1},

            // 白教涅托辅翼回血
            {"para_nytro_support",2},

            // 下面这行是用来占位的，在这之上添加新的即可
            {"666",-1}
    };    
    
    array<string> resupply_grenade_list = {
        "hand_grenade.projectile",
        "hand_88grenade.projectile",
        "hand_atgrenade.projectile",
        "c4.projectile"
    };

// parameters for "GFLplayerlist.as"


    // 以下是目前游戏内存在的物品，以后可能会增加当前状态，背包物品等等

    // m_weapon1key;    //主武器key
    // m_weapon2key;    //副武器key
    // m_weapon3key;    //投掷物key
    // m_armorkey;       //甲key
    // m_itemkey;       //掉落物key

    const int default_int = -1;
    const float default_float = -0.114514;
    const string default_string = "-nan-";
    const Vector3 default_Vector3 = Vector3(1,1,1);


    dictionary tactic_point_vehicle_destroy_reward = {
        {"aa_emplacement.vehicle",30},
        {"sf_jupiter.vehicle",30},
        {"par_sentrytower.vehicle",30},

        {"radar_tower.vehicle",15},
        {"radio_jammer.vehicle",15},
        {"radio_jammer2.vehicle",15},
        {"radio_jammer3.vehicle",15},

        {"",0}
    };

    dictionary tactic_point_vehicle_destroy_personal_reward = {
        {"typhon.vehicle",5},
        {"coeus.vehicle",5},
        {"neosu_kuergants.vehicle",4},
        {"kcco_pathfinder_factory.vehicle",3},
        {"sandstorm.vehicle",3},

        {"par_uhlan.vehicle",5},
        {"par_elenusinus.vehicle",4},
        {"par_aceso.vehicle",3},
        {"par_cherub.vehicle",1},
        {"par_moth.vehicle",1},
        {"par_compass.vehicle",1},

        {"aa_emplacement.vehicle",10},
        {"sf_jupiter.vehicle",10},
        {"par_sentrytower.vehicle",10},

        {"sf_JWAG.vehicle",3},
        {"deployed_mortar.vehicle",3},
        {"hornet_ct.vehicle",3},
        {"bgm71_tow.vehicle",2},
        {"kcco_1130.vehicle",2},
        {"rubber_boat.vehicle",2},

        {"gas_tank.vehicle",1},
        {"water_tower.vehicle",3},
        {"mortar_ammunition_crates.vehicle",1},

        {"",0}
    };

    dictionary tactic_point_vehicle_spot_reward = {
        {"typhon.vehicle",5},
        {"coeus.vehicle",5},
        {"neosu_kuergants.vehicle",4},
        {"kcco_pathfinder_factory.vehicle",3},
        {"sandstorm.vehicle",3},

        {"par_uhlan.vehicle",5},
        {"par_elenusinus.vehicle",4},
        {"par_aceso.vehicle",3},
        {"par_cherub.vehicle",2},
        {"par_moth.vehicle",2},
        {"par_compass.vehicle",1},

        {"aa_emplacement.vehicle",10},
        {"sf_jupiter.vehicle",10},
        {"par_sentrytower.vehicle",10},
        {"radar_tower.vehicle",7},
        {"radio_jammer.vehicle",7},
        {"radio_jammer2.vehicle",7},
        {"radio_jammer3.vehicle",7},
        {"deployed_mortar.vehicle",3},
        {"bgm71_tow.vehicle",2},
        {"kcco_1130.vehicle",2},
        {"rubber_boat.vehicle",2},

        {"",0}
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
        {"upgrade_type4.carry_item",22},
        {"upgrade_sr3mp.carry_item",23},

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
        {"type4",22},
        {"sr3mp",23},

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

    dictionary callUI_Slot = {
        // 空
        {"",0},

        {"call_ui_t1_bombardment_fairy_82mm_mortar_free",1},
        {"call_ui_t1_bombardment_fairy_82mm_mortar",1}, 
        {"call_ui_t1_bombardment_fairy_105mm_grenade_barrage",1}, 
        {"call_ui_t1_bombardment_fairy_155mm_air_burst",1}, 
        {"call_ui_t2_bombardment_fairy_170mm_cannon",2}, 

        {"call_ui_t2_airstrike_fairy_bomber",2},
        {"call_ui_t1_airstrike_fairy_cas",1},
        {"call_ui_t1_airstrike_fairy_cas_p2p",1},
        {"call_ui_t1_airstrike_fairy_precise",1},
        {"call_ui_t2_airstrike_fairy_precise",2},
        {"call_ui_t3_airstrike_fairy_precise",3},

        {"call_ui_t1_elmo_banzai_drone",1},

        {"call_ui_t2_warrior_fairy_recon_heli",2},
        {"call_ui_t2_warrior_fairy_vtol_sentry",2},
        {"call_ui_t3_warrior_fairy_armed_heli",3},

        {"call_ui_t1_rocket_fairy_missile",1},
        {"call_ui_t2_rocket_fairy_bm30",2},
        {"call_ui_t3_rocket_fairy_aircraft",3},
        {"call_ui_t3_rocket_fairy_cover",3},

        {"call_ui_t3_rampage_fairy_gunship",3},

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

	array<Resource@> GKcallList={
		Resource("gk_airstrike_fairy.call", "call"),
		Resource("gk_snipe_fairy.call", "call"),
		Resource("gk_yaoren_fairy.call", "call"),
		Resource("martina.call", "call"),
		Resource("gk_repair_fairy.call", "call"),
		Resource("target.call", "call")
	};

    array<Resource@> AllGKcallList={
		Resource("gk_airdrop_supply.call", "call"),
        Resource("gk_medic_agl.call", "call"),
		Resource("gk_rescue_fairy.call", "call"),
        Resource("gk_call_tier1.call", "call"),
		Resource("gk_call_tier2.call", "call"),
		Resource("gk_call_tier3.call", "call"),
		Resource("gk_snipe_fairy.call", "call"),
		Resource("gk_yaoren_fairy.call", "call"),
		Resource("martina.call", "call"),
		Resource("gk_repair_fairy.call", "call"),
		Resource("target.call", "call")
	};


    // parameters for "save_system.as":
    const string call_slot_default_1 = "t1_bombardment_fairy_82mm_mortar_lv0";
    const string call_slot_default_2 = "t2_airstrike_fairy_precise_lv0";
    const string call_slot_default_3 = "t3_rocket_fairy_aircraft_lv0";

    // 默认引用的支援key

    // parameters for "kill_event.as":

    array<string> point_nerfed_reward = {
    "kcco_pathfinder",
    "infected",
    "sf_dinergate"
};