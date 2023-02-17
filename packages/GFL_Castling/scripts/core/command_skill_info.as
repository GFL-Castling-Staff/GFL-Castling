// 反装甲榴弹AR，杀伤大范围小
array<string> AR_grenade_AntiArmor = {
    "gkw_arx160.weapon",
    "gkw_xm8.weapon",
    "gkw_g3.weapon",
    "gkw_m4sopmodii_531.weapon",
    "gkw_m4sopmodii_551.weapon",
    "gkw_m4sopmodii.weapon",
    "gkw_hk416.weapon",
    "gkw_hk416_6505.weapon",
    "gkw_hk416_537.weapon",
    "gkw_hk416_805.weapon",
    "gkw_hk416_3401.weapon"
};

// 反人员榴弹AR，杀伤小范围大
array<string> AR_grenade_AntiPersonal = {
    "gkw_stg44.weapon",
    "gkw_famas.weapon",
    "gkw_k11_ar.weapon",
    "gkw_k11_20mm_impact.weapon",
    "gkw_56-1type.weapon",
    "gkw_56-1typemod3.weapon",
    "gkw_hk416_agent.weapon"
};

// 列举枪对应的脚本技能编号。注意字典的值为了配合后面的只能用uint，不可用string，float等    
dictionary commandSkillIndex = {

        // 空武器
        {"",0},

        // AN94MOD3
        {"gkw_an94_mod3.weapon",1},
        {"gkw_an94_mod3_skill.weapon",1},
        {"gkw_an94mod3_3303.weapon",1},
        {"gkw_an94mod3_3303_skill.weapon",1},
        {"gkw_an94mod3_blm.weapon",1},
        {"gkw_an94mod3_blm_skill.weapon",1},

        // SMG燃烧弹
        {"gkw_vector.weapon",2},
        {"gkw_vector_549.weapon",2},
        {"gkw_vector_549_skill.weapon",2},
        {"gkw_vector_1901.weapon",2},

        {"gkw_vz61.weapon",2},
        {"gkw_vz61_only.weapon",2},
        {"gkw_klin.weapon",2},
        {"gkw_uzi.weapon",2},
        {"gkw_mp40.weapon",2},
        {"gkw_kp31mod3.weapon",2},
        {"gkw_kp31mod3_310.weapon",2},

        // FF_JUSTICE
        {"ff_justice.weapon",3},

        // MP5
        {"gkw_mp5.weapon",4},
        {"gkw_mp5_3.weapon",4},
        {"gkw_mp5_1205.weapon",4},
        {"gkw_mp5_1903.weapon",4},
        {"gkw_mp5_3006.weapon",4},

        // MP5MOD3
        {"gkw_mp5mod3.weapon",5},
        {"gkw_mp5mod3_3.weapon",5},
        {"gkw_mp5mod3_1205.weapon",5},
        {"gkw_mp5mod3_1903.weapon",5},
        {"gkw_mp5mod3_3006.weapon",5},

        // P22
        {"gkw_p22.weapon",6},

        // HS2000
        {"gkw_hs2000.weapon",7},
        {"gkw_hs2000_5304.weapon",7},

        // FF_INTRUDER
        {"ff_Intruder.weapon",8},

        // FF_AGENT
        {"ff_agent.weapon",9},

        // FF_DESTROYER
        {"ff_destroyer.weapon",10},
        {"ff_destroyer_skin.weapon",10},

        // FF_EXCUTIONER
        {"ff_excutioner_2.weapon",11},

        // FF_BAIBAOZI
        {"ff_parw_alina.weapon",12},

        // G3 Mod3
        {"gkw_g3mod3.weapon",13},
        {"gkw_g3mod3_1303.weapon",13},
        {"gkw_g3mod3_skill.weapon",13},
        {"gkw_g3mod3_1303_skill.weapon",13},

        // UMP45
        {"gkw_ump45.weapon",14},
        {"gkw_ump45_535.weapon",14},
        {"gkw_ump45_410.weapon",14},      
        {"gkw_ump45_3403.weapon",14},
        {"gkw_ump45_5405.weapon",14},
        {"gkw_ump45_5405_skill.weapon",14},

        // M870
        {"gkw_m870.weapon",15},
        {"gkw_m870_3803.weapon",15},

        // PP19
        {"gkw_pp19.weapon",16},

        // PP19MOD3
        {"gkw_pp19mod3.weapon",17},

        // AK15MOD3
        {"gkw_ak15mod3.weapon",18},
        {"gkw_ak15mod3_skill.weapon",18},
        {"gkw_ak15mod3_blm.weapon",18},
        {"gkw_ak15mod3_blm_skill.weapon",18},
        // XM8MOD3
        {"gkw_xm8_mod3.weapon",19},

        // STG44MOD3
        {"gkw_stg44mod3.weapon",20},

        // WERLODMOD3
        {"gkw_welrodmod3.weapon",21},
        {"gkw_welrodmod3_411.weapon",21},
        {"gkw_welrodmod3_2103.weapon",21},

        // FAL
        {"gkw_fal.weapon",22},
        {"gkw_fal_2406.weapon",22},
        {"gkw_fal_308.weapon",22},

        // M4SOPMODIIMOD3
        {"gkw_m4sopmodiimod3.weapon",23},
        {"gkw_m4sopmodiimod3_531.weapon",23},
        {"gkw_m4sopmodiimod3_551.weapon",23},

        // PPSH41, PPSH41MOD3
        {"gkw_ppsh41.weapon",24},
        {"gkw_ppsh41_602.weapon",24},
        {"gkw_ppsh41mod3.weapon",25},
        {"gkw_ppsh41mod3_602.weapon",25},

        // fo-12
        {"gkw_fo12.weapon",26},
        {"gkw_fo12_skill.weapon",26},

        // Flashbang
        {"gkw_type79.weapon",27},
        {"gkw_ump9.weapon",27},
        {"gkw_ump9_409.weapon",27},
        {"gkw_ump9_536.weapon",27},
        {"gkw_ump9_6704.weapon",27},
        {"gkw_ump9_6704_skill.weapon",27},

        {"gkw_mab38.weapon",27},
        {"gkw_mab38_oc.weapon",27},
        {"gkw_64type.weapon",27},
        {"gkw_m16a1.weapon",27},
        {"gkw_m16a1_533.weapon",27},
        {"gkw_m9.weapon",27},

        {"gkw_ump9mod3.weapon",28},
        {"gkw_ump9mod3_6704.weapon",28},
        {"gkw_ump9mod3_6704_skill.weapon",28},

        {"gkw_mab38mod3.weapon",29},
        {"gkw_mab38mod3_oc.weapon",29},
        // AK12冰沙时代
        // {"gkw_ak12_2402.weapon",30},
        // {"gkw_ak12_2402_skill.weapon",30},

        {"gkw_ppkmod3.weapon",31},
        {"gkw_ppkmod3_3905.weapon",31},

        //利贝罗勒
        {"gkw_ribeyrollesmod3.weapon",32},
        {"gkw_ribeyrollesmod3_skill.weapon",32},

        //MG4
        {"gkw_mg4mod3.weapon",33},
        {"gkw_mg4mod3_skill.weapon",33},
        {"gkw_mg4mod3_703.weapon",33},
        {"gkw_mg4mod3_703_skill.weapon",33},
        {"gkw_mg4mod3_oc.weapon",33},
        {"gkw_mg4mod3_oc_skill.weapon",33},

        //Liu RF
        {"gkw_liu.weapon",34},
        {"gkw_liu_skill.weapon",34},
        {"gkw_liu_5101.weapon",34},
        {"gkw_liu_5101_skill.weapon",34},

        //sat8
        {"gkw_sat8.weapon",35},
        {"gkw_sat8_1802.weapon",35},
        {"gkw_sat8_2601.weapon",35},

        // HK416MOD3
        {"gkw_hk416mod3.weapon",36},
        {"gkw_hk416mod3_skill.weapon",36},
        {"gkw_hk416_537_mod3.weapon",36},
        {"gkw_hk416_537_mod3_skill.weapon",36},
        {"gkw_hk416_6505_mod3.weapon",36},
        {"gkw_hk416_6505_mod3_skill.weapon",36},
        {"gkw_hk416mod3_805.weapon",36},
        {"gkw_hk416mod3_805_skill.weapon",36},

        {"gkw_hk416_3401_mod3.weapon",37},
        {"gkw_hk416_3401_mod3_skill.weapon",37},

        // SMG 手雷
        {"gkw_m3.weapon",38},
        {"gkw_sten.weapon",38},
        {"gkw_stenmod3.weapon",38},
        {"gkw_sterling.weapon",38},
        {"gkw_saf.weapon",38},
        {"gkw_saf_6607.weapon",38},

        // 炼金术师 大限
        {"ff_alchemist.weapon",39},
        {"ff_alchemist_skill.weapon",39},

        // 汉阳造88式，88雷(普通一颗雷，mod3三颗充能雷)
        {"gkw_88type.weapon",40},
        {"gkw_88typemod3.weapon",41},
        {"gkw_88typemod3_skill.weapon",41},

        // 汉阳造高达，攻顶火箭
        {"gkw_88typemod3_6503.weapon",42},        
        {"gkw_88typemod3_6503_skill.weapon",42},   

        // M200 无言杀意
        {"gkw_m200.weapon",43},        
        {"gkw_m200_560.weapon",43},        
        {"gkw_m200_4502.weapon",43},        

        // CZ75 
        {"gkw_cz75.weapon",44},
        {"gkw_cz75_1604.weapon",44},

        // G41_only
        {"gkw_g41_only.weapon",46},
        {"gkw_g41_only_skill.weapon",46},
        {"gkw_g41_2401_only.weapon",46},
        {"gkw_g41_2401_only_skill.weapon",46},
        {"gkw_g41_7406_only.weapon",46},
        {"gkw_g41_7406_only_skill.weapon",46},

        // UMP45MOD3
        {"gkw_ump45mod3.weapon",47},
        {"gkw_ump45mod3_535.weapon",47},
        {"gkw_ump45mod3_410.weapon",47},
        {"gkw_ump45mod3_3403.weapon",47},
        {"gkw_ump45mod3_5405.weapon",47},
        {"gkw_ump45mod3_5405_skill.weapon",47},

        // 衔尾蛇
        {"ff_weaver.weapon",48},
        {"ff_weaver_1.weapon",48},

        //汤普森
        {"gkw_thompson.weapon",49},
        {"gkw_thompson_5703.weapon",49},

        //燃烧链接 UZI
        {"gkw_uzimod3.weapon",50},
        {"gkw_uzimod3_skill.weapon",50},

        //瞄准射击 锁人版
        {"gkw_m1903.weapon",51},
        {"gkw_m1903_only.weapon",51},
        {"gkw_m1903_exp.weapon",51},
        {"gkw_m1903_302.weapon",51},
        {"gkw_m1903_302_only.weapon",51},
        {"gkw_m1903_302_exp.weapon",51},        
        {"gkw_m1.weapon",51},
        {"gkw_m1_1106.weapon",51},
        {"gkw_m1_sf.weapon",51},
        {"gkw_m1_sf_skill.weapon",51},
        {"gkw_m1_sf_1106.weapon",51},
        {"gkw_m1_sf_1106_skill.weapon",51},
        {"gkw_m1891.weapon",51},
        {"gkw_m21.weapon",51},
        {"gkw_psg1.weapon",51},
        {"gkw_qbu88.weapon",51},
        {"gkw_qbu88_skill.weapon",51},
        {"gkw_qbu88_5502.weapon",51},
        {"gkw_qbu88_5502_skill.weapon",51},        
        {"gkw_sv98.weapon",51},
        {"gkw_sv98_502.weapon",51},
        {"gkw_sv98_1906.weapon",51},

        {"gkw_sv98mod3.weapon",51},
        {"gkw_sv98mod3_502.weapon",51},
        {"gkw_sv98mod3_1906.weapon",51},
        {"gkw_sv98mod3_skill.weapon",51},
        {"gkw_sv98mod3_502_skill.weapon",51},
        {"gkw_sv98mod3_1906_skill.weapon",51},

        {"gkw_supersass.weapon",51},
        {"gkw_supersass_1407.weapon",51},
        {"gkw_supersassmod3.weapon",51},
        {"gkw_supersassmod3_1407.weapon",51},        
        {"gkw_supersassmod3_skill.weapon",51},
        {"gkw_supersassmod3_1407_skill.weapon",51},

        {"gkw_thunder.weapon",51},
        {"gkw_thunder_2206.weapon",51},

        {"gkw_98k.weapon",51},
        {"gkw_98k_skill.weapon",51},
        {"gkw_98kmod3.weapon",51},
        {"gkw_98kmod3_skill.weapon",51},

        //墨尔斯假面 乐
        {"gkw_carcano1938.weapon",52},

        //瞄准射击 坐标版
        {"gkw_m99.weapon",53},
        {"gkw_m99_1701.weapon",53},
        {"gkw_m99_3304.weapon",53},
        {"gkw_m99_404.weapon",53},
        {"gkw_ptrd.weapon",53},

        // 这几位都要重做
        {"gkw_tac50.weapon",53},
        {"gkw_gm6.weapon",53},
        {"gkw_m82a1.weapon",53},
        {"gkw_m82a1_skill.weapon",53},
        {"gkw_gepardm1.weapon",53},
        {"gkw_gepardm1mod3.weapon",53},
        {"gkw_gepardm1_4006.weapon",53},
        {"gkw_gepardm1mod3_4006.weapon",53},

        {"gkw_f1.weapon",54},
        {"gkw_f1mod3.weapon",54},

        // 波波沙机甲，先暂定为打烟，做不做维修效果另说
        {"gkr_bbs.weapon",55},

        {"gkw_svdex.weapon",56},
        {"gkw_svdex_5506.weapon",56},

        // 特工416奶箱
        {"gkw_hk416_agent_he.weapon",57},
        {"gkw_hk416_agent_sticky.weapon",57},

        {"gkw_emp35.weapon",58},
        {"gkw_emp35_8003.weapon",58},

        {"gkw_64typemod3.weapon",59},

        {"gkw_zasm21.weapon",60},
        {"gkw_zasm21_2104.weapon",60},

        {"gkw_c96mod3.weapon",61},

        // 下面这行是用来占位的，在这之上添加新的枪和index即可
        {"666",-1}
};