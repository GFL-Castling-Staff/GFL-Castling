int getRPKillReward(string name) {
    if(RP_enemy_index.exists(name)) {
        int key = int(RP_enemy_index[name]);
        return key;
    }
    else{
        return 0;
    }
}

dictionary RP_enemy_index = {
    {"kcco_ar_human_tel",30},
    {"kcco_talos",75},
    {"kcco_mg",75},
    {"kcco_cerynitis",30},
    {"kcco_cerynitis_alter",30},
    {"kcco_Hydra",100},
    {"kcco_teslatrooper",100},

    {"para_streletplus",20},
    {"para_streletplus_richman",20},
    {"parw_commander",10},
    {"alina",150},
    {"teal",200},
    {"eagleyes",150},
    {"vanguard",150},
    {"Nimogen",200},
    {"Narciss",200},
    {"Adeline",150},
    {"smasher",100},
    {"Paradeus_doppelsoldner",100},
    {"Paradeus_roarer",100},

    {"sfw_nemeum",30},
    {"sfw_nemeum_swap",50},
    {"sf_manticore",100},
    {"sf_vespid_swap",20},
    {"sf_ripper_swap",20},
    {"sf_jaeger_swap",20},
    {"sf_striker_swap",20},
    {"Brute_swap",20},
    {"sfw_dragoon",40},
    {"sfw_dragoon_swap",80},
    {"sfw_prowler_sweap",20},

    

    {"sf_hunter",150},
    {"sf_architect",150},
    {"sfw_Intruder",150},
    {"sfw_Dreamer",150},
    {"sfw_Alchemist",150},
    {"sfw_Gager",150},
    {"sfw_Excutioner-Wind_rose",150},
    {"sfw_Excutioner-Queen_of_the_Moon",150},
    {"sfw_M16A1",150},
    {"sfw_Agent",150},
    {"sfw_Destroyer",150},
    {"sfw_Weaver",150},
    {"sfw_Justice",150},
    {"sfw_Scarecrow",150},

    {"",0}
};

float getXPKillReward(string name) {
    if(XP_enemy_index.exists(name)) {
        float key = float(XP_enemy_index[name]);
        return key;
    }
    else{
        return 0.0;
    }
}

dictionary XP_enemy_index = {
    {"kcco_ar_human_tel",0.003},
    {"kcco_talos",0.002},
    {"kcco_mg",0.002},
    {"kcco_cerynitis",0.003},
    {"kcco_cerynitis_alter",0.003},
    {"kcco_Hydra",0.01},
    {"kcco_teslatrooper",0.01},

    {"para_streletplus",0.002},
    {"para_streletplus_richman",0.002},
    {"parw_commander",0.001},
    {"alina",0.02},
    {"teal",0.02},
    {"eagleyes",0.02},
    {"vanguard",0.02},
    {"Nimogen",0.02},
    {"Narciss",0.02},
    {"Adeline",0.02},
    {"smasher",0.01},
    {"Paradeus_doppelsoldner",0.01},
    {"Paradeus_roarer",0.01},

    {"sfw_nemeum",0.003},
    {"sfw_nemeum_swap",0.005},
    {"sf_manticore",0.01},
    {"sf_vespid_swap",0.002},
    {"sf_ripper_swap",0.002},
    {"sf_jaeger_swap",0.002},
    {"sf_striker_swap",0.002},
    {"sfw_dragoon",0.003},
    {"sfw_dragoon_swap",0.006},
    {"Brute_swap",0.002},
    {"sfw_prowler_sweap",0.002},

    {"sf_hunter",0.02},
    {"sf_architect",0.02},
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

    {"",0}
};