#include "gift_item_delivery_rewarder.as"

int getRPKillReward(string name) {
    if(RP_enemy_index.exists(name)) {
        int key = int(RP_enemy_index[name]);
        return key;
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
    {"kcco_Hydra",250},
    {"kcco_teslatrooper",200},
    {"kcco_human_sniper",250},
    {"kcco_quartz_ranger",300},
    {"kcco_zircon_squadleader",300},


    {"para_streletplus",20},
    {"parw_commander",100},
    {"alina",300},
    {"teal",500},
    {"eagleyes",250},
    {"vanguard",250},
    {"wrath",250},
    {"aileron",350},
    {"Nimogen",300},
    {"Narciss",300},
    {"Adeline",300},
    {"smasher",250},
    {"Paradeus_doppelsoldner",250},
    {"Paradeus_roarer",250},
    {"Thunder",300},
    {"parw_grenadier",100},
    {"para_rodelero",80},
    {"tareus",1500},

    {"sfw_nemeum",50},
    {"sfw_nemeum_swap",75},
    {"sf_manticore",250},
    {"sf_vespid_swap",20},
    {"sf_vespid_vehicle_user",20},
    {"sf_ripper_swap",20},
    {"sf_jaeger_swap",20},
    {"sf_striker_swap",20},
    {"Brute_swap",30},
    {"sfw_dragoon",40},
    {"sfw_dragoon_swap",80},
    {"sfw_prowler_swap",40},

    {"sf_goliath",200},
    {"sf_goliath_plus",400},

    {"sfw_hunter",300},
    {"sfw_architect",300},
    {"sfw_Intruder",300},
    {"sfw_Dreamer",300},
    {"sfw_Alchemist",450},
    {"sfw_Gager",300},
    {"sfw_Excutioner-Wind_rose",450},
    {"sfw_Excutioner-Queen_of_the_Moon",450},
    {"sfw_M16A1",450},
    {"sfw_Agent",300},
    {"sfw_Destroyer",300},
    {"sfw_Weaver",300},
    {"sfw_Justice",300},
    {"sfw_Scarecrow",300},
    {"sf_cerberus",1000},

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
    {"kcco_Hydra",0.01},
    {"kcco_teslatrooper",0.01},
    {"kcco_human_sniper",0.01},
    {"kcco_quartz_ranger",0.015},
    {"kcco_zircon_squadleader",0.015},

    {"para_streletplus",0.002},
    {"parw_commander",0.005},
    {"alina",0.02},
    {"teal",0.02},
    {"eagleyes",0.02},
    {"vanguard",0.02},
    {"wrath",0.02},
    {"aileron",0.02},
    {"Nimogen",0.02},
    {"Narciss",0.02},
    {"Adeline",0.02},
    {"smasher",0.01},
    {"Paradeus_doppelsoldner",0.01},
    {"Paradeus_roarer",0.01},
    {"Thunder",0.015},
    {"parw_grenadier",0.003},
    {"tareus",0.05},

    {"sfw_nemeum",0.003},
    {"sfw_nemeum_swap",0.005},
    {"sf_manticore",0.01},
    {"sf_vespid_swap",0.002},
    {"sf_vespid_vehicle_user",0.002},
    {"sf_ripper_swap",0.002},
    {"sf_jaeger_swap",0.002},
    {"sf_striker_swap",0.002},
    {"sfw_dragoon",0.003},
    {"sfw_dragoon_swap",0.006},
    {"Brute_swap",0.002},
    {"sfw_prowler_sweap",0.002},
    {"sf_goliath",0.008},
    {"sf_goliath_plus",0.016},    
    {"para_rodelero",0.002},

    {"sfw_hunter",0.02},
    {"sfw_architect",0.02},
    {"sfw_Intruder",0.02},
    {"sfw_Dreamer",0.02},
    {"sfw_Alchemist",0.02},
    {"sfw_Gager",0.02},
    {"sfw_Excutioner-Wind_rose",0.02},
    {"sfw_Excutioner-Queen_of_the_Moon",0.02},
    {"sfw_M16A1",0.02},
    {"sfw_Agent",0.02},
    {"sfw_Destroyer",0.02},
    {"sfw_Weaver",0.02},
    {"sfw_Justice",0.02},
    {"sfw_Scarecrow",0.02},
    {"sf_cerberus",0.05},

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
    {"sfw_hunter","boss"},
    {"sfw_architect","boss"},
    {"sfw_Intruder","boss"},
    {"sfw_Dreamer","boss"},
    {"sfw_Alchemist","boss"},
    {"sfw_Gager","boss"},
    {"sfw_Excutioner-Wind_rose","boss"},
    {"sfw_Excutioner-Queen_of_the_Moon","boss"},
    {"sfw_M16A1","boss"},
    {"sfw_Agent","boss"},
    {"sfw_Destroyer","boss"},
    {"sfw_Weaver","boss"},
    {"sfw_Justice","boss"},
    {"sfw_Scarecrow","boss"},
    {"teal","boss"},
    {"Nimogen","boss"},
    {"Narciss","boss"},
    {"kcco_quartz_ranger","boss"},
    {"kcco_zircon_squadleader","boss"},
    {"sf_cerberus","boss"},
    {"tareus","boss"},

    {"alina","elite"},
    {"vanguard","elite"},
    {"eagleyes","elite"},
    {"wrath","elite"},
    {"aileron","elite"},
    {"Adeline","elite"},
    {"smasher","elite"},
    {"Thunder","elite"},

    {"sf_manticore","rare"},
    {"sf_goliath","rare"},
    {"sf_goliath_plus","rare"},
    {"Paradeus_doppelsoldner","rare"},
    {"Paradeus_roarer","rare"},
    {"kcco_Hydra","rare"},
    {"kcco_teslatrooper","rare"},
    {"kcco_human_sniper","rare"},

    {"sfw_nemeum","uncommon"},
    {"sfw_nemeum_swap","uncommon"},
    {"sf_vespid_swap","uncommon"},
    {"sf_vespid_vehicle_user","uncommon"},
    {"sf_ripper_swap","uncommon"},
    {"sf_jaeger_swap","uncommon"},
    {"sf_striker_swap","uncommon"},
    {"Brute_swap","uncommon"},
    {"sfw_dragoon","uncommon"},
    {"sfw_dragoon_swap","uncommon"},
    {"sfw_prowler_swap","uncommon"},
    {"kcco_talos","uncommon"},
    {"kcco_mg","uncommon"},
    {"parw_commander","uncommon"},
    {"kcco_ar_human_elite","uncommon"},
    {"kcco_cerynitis","uncommon"},
    {"kcco_cerynitis_swap","uncommon"},
    {"para_rodelero","uncommon"},
    {"kcco_ar_human_tel","uncommon"},
    {"parw_grenadier","uncommon"},


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
    "sf_cerberus"
};

array<string> boss_list ={
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
    "sf_cerberus",
    "alina",
    "Adeline",
    "Narciss",
    "Nimogen",
    "teal",
    "kcco_quartz_ranger",
    "kcco_zircon_squadleader"
};