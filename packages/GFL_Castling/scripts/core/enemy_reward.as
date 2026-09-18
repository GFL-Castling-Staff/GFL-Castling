#include "gift_item_delivery_rewarder.as"

int getRPKillReward(string name) {
    if(RP_enemy_index.exists(name)) {
        int key = int(RP_enemy_index[name]);
        int scale = 1;
        return key * scale;
    }
    return 0;

}

dictionary RP_enemy_index = {
    {"kcco_ar_human_elite",30},
    {"kcco_ar_human_tel",75},
    {"kcco_talos",75},
    {"kcco_mg",75},
    {"kcco_cerynitis",50},
    {"kcco_cerynitis_swap",100},
    {"kcco_hydra",250},
    {"kcco_teslatrooper",200},
    {"kcco_human_sniper",250},
    {"kcco_quartz_ranger",300},
    {"kcco_zircon_squadleader",300},


    {"pard_streletplus",20},
    {"pard_commander",100},
    {"alina",300},
    {"teal",500},
    {"eagleyes",250},
    {"vanguard",250},
    {"wrath",250},
    {"aileron",350},
    {"nimogen",300},
    {"narciss",300},
    {"adeline",300},
    {"smasher",250},
    {"pard_doppelsoldner",250},
    {"pard_roarer",250},
    {"pard_hannibal",500},
    {"thunder",500},
    {"ladon",500},
    {"pard_arachne",500},
    {"pard_grenadier",100},
    {"pard_rodelero",80},
    {"tareus",1500},

    {"sf_nemeum",50},
    {"sf_nemeum_swap",75},
    {"sf_manticore",250},
    {"sf_vespid_swap",20},
    {"sf_vespid_vehicle_user",20},
    {"sf_ripper_swap",20},
    {"sf_jaeger_swap",20},
    {"sf_striker_swap",20},
    {"sf_brute_swap",30},
    {"sf_dragoon",40},
    {"sf_dragoon_swap",80},
    {"sf_prowler_swap",40},

    {"sf_goliath",200},
    {"sf_goliath_plus",400},

    {"sf_hunter",300},
    {"sf_architect",300},
    {"sf_intruder",300},
    {"sf_dreamer",300},
    {"sf_alchemist",450},
    {"sf_gager",300},
    {"sf_executioner_wind_rose",450},
    {"sf_executioner_queen_of_the_moon",450},
    {"sf_m16a1",450},
    {"sf_agent",300},
    {"sf_destroyer",300},
    {"sf_weaver",300},
    {"sf_justice",300},
    {"sf_scarecrow",300},
    {"sf_cerberus",1000},
    {"sf_cerberus_plus",2000},

    {"",0}
};

float getXPKillReward(string name) {
    if(XP_enemy_index.exists(name)) {
        float key = float(XP_enemy_index[name]);
        return key;
    }
    return 0.0;
}

dictionary XP_enemy_index = {
    {"kcco_ar_human_elite",0.001},
    {"kcco_ar_human_tel",0.005},
    {"kcco_talos",0.002},
    {"kcco_mg",0.002},
    {"kcco_cerynitis",0.003},
    {"kcco_cerynitis_swap",0.003},
    {"kcco_hydra",0.01},
    {"kcco_teslatrooper",0.01},
    {"kcco_human_sniper",0.01},
    {"kcco_quartz_ranger",0.015},
    {"kcco_zircon_squadleader",0.015},

    {"pard_streletplus",0.002},
    {"pard_commander",0.005},
    {"alina",0.02},
    {"teal",0.02},
    {"eagleyes",0.02},
    {"vanguard",0.02},
    {"wrath",0.02},
    {"aileron",0.02},
    {"nimogen",0.02},
    {"narciss",0.02},
    {"adeline",0.02},
    {"smasher",0.01},
    {"pard_doppelsoldner",0.01},
    {"pard_roarer",0.01},
    {"ladon",0.01},
    {"pard_hannibal",0.02},    
    {"thunder",0.02},
    {"pard_arachne",0.02},
    {"pard_grenadier",0.003},
    {"tareus",0.05},

    {"sf_nemeum",0.003},
    {"sf_nemeum_swap",0.005},
    {"sf_manticore",0.01},
    {"sf_vespid_swap",0.002},
    {"sf_vespid_vehicle_user",0.002},
    {"sf_ripper_swap",0.002},
    {"sf_jaeger_swap",0.002},
    {"sf_striker_swap",0.002},
    {"sf_dragoon",0.003},
    {"sf_dragoon_swap",0.006},
    {"sf_brute_swap",0.002},
    {"sf_prowler_swap",0.002},
    {"sf_goliath",0.008},
    {"sf_goliath_plus",0.016},    
    {"pard_rodelero",0.002},

    {"sf_hunter",0.02},
    {"sf_architect",0.02},
    {"sf_intruder",0.02},
    {"sf_dreamer",0.02},
    {"sf_alchemist",0.02},
    {"sf_gager",0.02},
    {"sf_executioner_wind_rose",0.02},
    {"sf_executioner_queen_of_the_moon",0.02},
    {"sf_m16a1",0.02},
    {"sf_agent",0.02},
    {"sf_destroyer",0.02},
    {"sf_weaver",0.02},
    {"sf_justice",0.02},
    {"sf_scarecrow",0.02},
    {"sf_cerberus",0.05},
    {"sf_cerberus_plus",0.1},

    {"",0}
};

string getRewardPool(string name) {
    if(reward_pool_list.exists(name)) {
        string key = string(reward_pool_list[name]);
        return key;
    }
    else{
        return "common";
    }
}

dictionary reward_pool_list= {
    {"sf_hunter","boss"},
    {"sf_architect","boss"},
    {"sf_intruder","boss"},
    {"sf_dreamer","boss"},
    {"sf_alchemist","boss"},
    {"sf_gager","boss"},
    {"sf_executioner_wind_rose","boss"},
    {"sf_executioner_queen_of_the_moon","boss"},
    {"sf_m16a1","boss"},
    {"sf_agent","boss"},
    {"sf_destroyer","boss"},
    {"sf_weaver","boss"},
    {"sf_justice","boss"},
    {"sf_scarecrow","boss"},
    {"teal","boss"},
    {"nimogen","boss"},
    {"narciss","boss"},
    {"kcco_quartz_ranger","boss"},
    {"kcco_zircon_squadleader","boss"},
    {"sf_cerberus","boss"},
    {"sf_cerberus_plus","boss"},
    {"tareus","boss"},

    {"alina","elite"},
    {"vanguard","elite"},
    {"eagleyes","elite"},
    {"wrath","elite"},
    {"aileron","elite"},
    {"adeline","elite"},
    {"smasher","elite"},
    {"thunder","elite"},
    {"pard_hannibal","elite"},
    {"ladon","elite"},
    {"pard_arachne","elite"},

    {"sf_manticore","rare"},
    {"sf_goliath","rare"},
    {"sf_goliath_plus","rare"},
    {"pard_doppelsoldner","rare"},
    {"pard_roarer","rare"},
    {"kcco_hydra","rare"},
    {"kcco_teslatrooper","rare"},
    {"kcco_human_sniper","rare"},

    {"sf_nemeum","uncommon"},
    {"sf_nemeum_swap","uncommon"},
    {"sf_vespid_swap","uncommon"},
    {"sf_vespid_vehicle_user","uncommon"},
    {"sf_ripper_swap","uncommon"},
    {"sf_jaeger_swap","uncommon"},
    {"sf_striker_swap","uncommon"},
    {"sf_brute_swap","uncommon"},
    {"sf_dragoon","uncommon"},
    {"sf_dragoon_swap","uncommon"},
    {"sf_prowler_swap","uncommon"},
    {"kcco_talos","uncommon"},
    {"kcco_mg","uncommon"},
    {"pard_commander","uncommon"},
    {"kcco_ar_human_elite","uncommon"},
    {"kcco_cerynitis","uncommon"},
    {"kcco_cerynitis_swap","uncommon"},
    {"pard_rodelero","uncommon"},
    {"kcco_ar_human_tel","uncommon"},
    {"pard_grenadier","uncommon"},


    {"","common"}
};

array<ScoredResource@> reward_pool_common ={
    ScoredResource("city_gifts.drop_reward", "grenade", 1.0f),
    ScoredResource("wild_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("snow_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("forest_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("beer_can.drop_reward", "grenade", 10.0f),
    ScoredResource("lighter.drop_reward", "grenade", 8.0f),
    ScoredResource("cigars.drop_reward", "grenade", 7.0f),
    ScoredResource("steroids.drop_reward", "grenade", 2.0f),
    ScoredResource("gold_bar.drop_reward", "grenade", 0.3f),
    ScoredResource("bible.drop_reward", "grenade", 1.5f),
    ScoredResource("koran.drop_reward", "grenade", 1.5f),
    ScoredResource("chewing_gum.drop_reward", "grenade", 8.0f),
    ScoredResource("bizarre_rubber_bullet.drop_reward", "grenade", 1.0f),
    ScoredResource("chocolate.drop_reward", "grenade", 8.0f),
    ScoredResource("dollars_300.drop_reward", "grenade", 1.5f),
    ScoredResource("energy_drink.drop_reward", "grenade", 5.0f),
    ScoredResource("fancy_sunglasses.drop_reward", "grenade", 2.0f),
    ScoredResource("radio.drop_reward", "grenade", 2.0f),
    ScoredResource("razor.drop_reward", "grenade", 4.0f),
    ScoredResource("sheaths.drop_reward", "grenade", 1.0f),
    ScoredResource("sheaths_xxl.drop_reward", "grenade", 0.5f),
    ScoredResource("sunglasses.drop_reward", "grenade", 4.0f),
    ScoredResource("teddy.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_blue.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_red.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_white.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_silver.drop_reward", "grenade", 1.5f),
    ScoredResource("ipoo_player_yellow.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_green.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_pink.drop_reward", "grenade", 1.0f),
    ScoredResource("playing_cards.drop_reward", "grenade", 6.0f),
    ScoredResource("suitcase.drop_reward", "grenade", 4.0f),
    ScoredResource("underpants.drop_reward", "grenade", 1.0f),
    ScoredResource("kamasutra.drop_reward", "grenade", 3.0f),
    ScoredResource("cd.drop_reward", "grenade", 0.2f),
    ScoredResource("whiskey_bottle.drop_reward", "grenade", 10.0f),
    ScoredResource("cigarettes.drop_reward", "grenade", 15.0f),
    ScoredResource("dollars.drop_reward", "grenade", 4.0f),
    ScoredResource("gamingdevice.drop_reward", "grenade", 5.0f),
    ScoredResource("gem.drop_reward", "grenade", 2.0f),
    ScoredResource("comic_book.drop_reward", "grenade", 2.0f),
    ScoredResource("rwr_handbook.drop_reward", "grenade", 5.0f),
    ScoredResource("oscar_statue.drop_reward", "grenade", 1.0f),
    ScoredResource("laptop.drop_reward", "grenade", 4.0f),
    ScoredResource("painting.drop_reward", "grenade", 0.6f),
    ScoredResource("gift_box_community_2.drop_reward", "grenade", 0.4f),
    ScoredResource("ct_gift_halloween.drop_reward", "grenade", 0.4f),
    ScoredResource("416_grenade.drop_reward", "grenade", 1.0f),

    
    ScoredResource("gift_box_1.drop_reward", "grenade", 1.0f)
};

array<ScoredResource@> reward_pool_uncommon ={
    ScoredResource("city_gifts.drop_reward", "grenade", 1.0f),
    ScoredResource("wild_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("snow_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("forest_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("steroids.drop_reward", "grenade", 2.0f),
    ScoredResource("gold_bar.drop_reward", "grenade", 0.3f),
    ScoredResource("bible.drop_reward", "grenade", 1.5f),
    ScoredResource("koran.drop_reward", "grenade", 1.5f),
    ScoredResource("bizarre_rubber_bullet.drop_reward", "grenade", 1.0f),
    ScoredResource("dollars_300.drop_reward", "grenade", 1.5f),
    ScoredResource("energy_drink.drop_reward", "grenade", 5.0f),
    ScoredResource("fancy_sunglasses.drop_reward", "grenade", 2.0f),
    ScoredResource("radio.drop_reward", "grenade", 2.0f),
    ScoredResource("razor.drop_reward", "grenade", 4.0f),
    ScoredResource("sheaths.drop_reward", "grenade", 1.0f),
    ScoredResource("sheaths_xxl.drop_reward", "grenade", 0.5f),
    ScoredResource("sunglasses.drop_reward", "grenade", 4.0f),
    ScoredResource("teddy.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_blue.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_red.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_white.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_silver.drop_reward", "grenade", 1.5f),
    ScoredResource("ipoo_player_yellow.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_green.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_pink.drop_reward", "grenade", 1.0f),
    ScoredResource("suitcase.drop_reward", "grenade", 4.0f),
    ScoredResource("underpants.drop_reward", "grenade", 1.0f),
    ScoredResource("kamasutra.drop_reward", "grenade", 3.0f),
    ScoredResource("cd.drop_reward", "grenade", 0.2f),
    ScoredResource("dollars.drop_reward", "grenade", 4.0f),
    ScoredResource("gamingdevice.drop_reward", "grenade", 5.0f),
    ScoredResource("gem.drop_reward", "grenade", 2.0f),
    ScoredResource("comic_book.drop_reward", "grenade", 2.0f),
    ScoredResource("rwr_handbook.drop_reward", "grenade", 5.0f),
    ScoredResource("oscar_statue.drop_reward", "grenade", 1.0f),
    ScoredResource("laptop.drop_reward", "grenade", 4.0f),
    ScoredResource("painting.drop_reward", "grenade", 0.6f),
    ScoredResource("gift_box_community_2.drop_reward", "grenade", 0.4f),
    ScoredResource("ct_gift_halloween.drop_reward", "grenade", 0.4f),
    ScoredResource("416_grenade.drop_reward", "grenade", 1.0f),

    ScoredResource("gift_box_1.drop_reward", "grenade", 1.0f)
};

array<ScoredResource@> reward_pool_rare ={
    ScoredResource("city_gifts.drop_reward", "grenade", 1.0f),
    ScoredResource("wild_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("snow_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("forest_gifts.drop_reward", "grenade", 1.0f), 
    ScoredResource("gold_bar.drop_reward", "grenade", 0.3f),
    ScoredResource("bizarre_rubber_bullet.drop_reward", "grenade", 1.0f),
    ScoredResource("dollars_300.drop_reward", "grenade", 1.5f),
    ScoredResource("fancy_sunglasses.drop_reward", "grenade", 2.0f),
    ScoredResource("radio.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_blue.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_red.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_white.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_silver.drop_reward", "grenade", 1.5f),
    ScoredResource("ipoo_player_yellow.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_green.drop_reward", "grenade", 2.0f),
    ScoredResource("ipoo_player_pink.drop_reward", "grenade", 1.0f),
    ScoredResource("underpants.drop_reward", "grenade", 1.0f),
    ScoredResource("cd.drop_reward", "grenade", 0.2f),
    ScoredResource("gem.drop_reward", "grenade", 2.0f),
    ScoredResource("comic_book.drop_reward", "grenade", 2.0f),
    ScoredResource("oscar_statue.drop_reward", "grenade", 1.0f),
    ScoredResource("laptop.drop_reward", "grenade", 4.0f),
    ScoredResource("painting.drop_reward", "grenade", 0.6f),
    ScoredResource("gift_box_community_2.drop_reward", "grenade", 0.4f),
    ScoredResource("ct_gift_halloween.drop_reward", "grenade", 0.4f),
    ScoredResource("416_grenade.drop_reward", "grenade", 1.0f),

    ScoredResource("gift_box_1.drop_reward", "grenade", 1.0f)
};

array<ScoredResource@> reward_pool_elite ={
    ScoredResource("city_gifts.drop_reward", "grenade", 2.0f),
    ScoredResource("wild_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("snow_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("forest_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("gold_bar.drop_reward", "grenade", 0.1f),
    ScoredResource("underpants.drop_reward", "grenade", 0.2f),
    ScoredResource("416_grenade.drop_reward", "grenade", 1.0f),
    ScoredResource("painting.drop_reward", "grenade", 0.1f)
};

array<ScoredResource@> reward_pool_boss ={
    ScoredResource("city_gifts.drop_reward", "grenade", 2.0f),
    ScoredResource("wild_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("snow_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("forest_gifts.drop_reward", "grenade", 2.0f), 
    ScoredResource("gold_bar.drop_reward", "grenade", 0.2f),
    ScoredResource("underpants.drop_reward", "grenade", 0.4f),
    ScoredResource("painting.drop_reward", "grenade", 0.2f),
    ScoredResource("gift_box_community_2.drop_reward", "grenade", 0.05f),
    ScoredResource("ct_gift_halloween.drop_reward", "grenade", 0.05f),
    ScoredResource("416_grenade.drop_reward", "grenade", 1.0f),
    ScoredResource("gift_box_1.drop_reward", "grenade", 0.4f)    
};

array<string> SFbossList ={
    "sf_hunter",
    "sf_architect",
    "sf_intruder",
    "sf_dreamer",
    "sf_alchemist",
    "sf_gager",
    "sf_executioner_wind_rose",
    "sf_executioner_queen_of_the_moon",
    "sf_m16a1",
    "sf_agent",
    "sf_destroyer",
    "sf_weaver",
    "sf_justice",
    "sf_scarecrow",
    "sf_cerberus"
};

// 已弃用，建议使用reward_pool_list
array<string> boss_list ={
    "sf_hunter",
    "sf_architect",
    "sf_intruder",
    "sf_dreamer",
    "sf_alchemist",
    "sf_gager",
    "sf_executioner_wind_rose",
    "sf_executioner_queen_of_the_moon",
    "sf_m16a1",
    "sf_agent",
    "sf_destroyer",
    "sf_weaver",
    "sf_justice",
    "sf_scarecrow",
    "sf_cerberus",
    "alina",
    "adeline",
    "narciss",
    "nimogen",
    "teal",
    "tareus",
    "kcco_quartz_ranger",
    "kcco_zircon_squadleader"
};