#include "helpers.as"

array<string> nytoAllList = {
    "alina",
    "teal",
    "eagleyes",
    "vanguard",
    "wrath",
    "aileron",
    "Nimogen",
    "Narciss",
    "Adeline"  
};

array<string> nytoBasicList = {
    "eagleyes",
    "vanguard",
    "wrath"
};

dictionary gameSkillIndex = {

        // 空技能
        {"",0},

        // 生成防空炮
        {"aa_spawn",1},

        // 摧毁防空炮
        {"aa_destroy",2},

        // RO635技能，已弃用
        {"RO635_skill",3},

        // SOPMODII散射榴弹
        {"SOPMOD_skill",4},

        // UMP9白鸮轰鸣
        {"ump9_skill",5},

        // 维修妖精
        {"repair_fairy",6},

        // XM8技能
        {"xm8_skill",7},

        // HK416寄生榴弹
        {"416_skill",8},

        // KCCO智能雷扫描阶段
        {"kcco_smartgrenade_scan",9},

        // 给ai用的标枪脚本
        {"javelin_launch_for_sb_ai",10},

        // 标枪锁定兼射出弹头阶段
        {"javelin_launch_for_player",11},

        // 标枪弹头改垂直爬升阶段
        {"javelin_uprise",12},

        // 标枪弹头改垂直攻顶阶段
        {"javelin_strike",13},

        // VECTOR燃烧弹
        {"VV_skill",14},

        // STG44炎风暴
        {"stg44_skill",15},

        // 刺雷半载
        {"banzai100",16},

        // 白教白憨憨普攻砸地
        {"roarer",17},

        // 白教白憨憨技能搓球砸地
        {"roarer_skill",18},

        // G3榴弹
        {"g3_skill",19},

        // 大僵尸技能
        {"smasher_skill",20},

        // 刘氏步枪协同攻击
        {"rf_liu",21},

        // KCCO狙击手脚本弹头
        {"kcco_sniper_scan",22},

        // 玩家炼金术师脚本弹头
        {"ff_alchemist_skill_scan",23},

        // 防御妖精
        {"fc_defence_1",24},
        {"fc_defence_2",25},

		// 飞蛾无人机坠毁
        {"moth_destroy",26},

		// G41 Only
        {"g41_scan",27},

		// UMP45MOD3 烟雾弹
        {"ump45mod3_skill",28},

		// SAT8 披萨
        {"sat8_pizza",29},

	    // 整活载具召唤
        {"spawn_aek999",30},
        {"spawn_wheelchair",31},

        // 玩家衔尾蛇脚本弹头
        {"ff_weaver_skill_scan",32},

		// uzi mod3 fire
        {"uzi_firenade",33},

		// gsh18 庸医
        {"gsh18_medic",34},

		// 利贝罗勒
        {"mle_skill_heal",35},

		// 生成孤儿号
        {"spawn_mortar_truck",36},

		// 生成一分钟闪电风暴
        {"spawn_lightning_storm_1_min",37},

		// 生成腐蚀区域
		{"para_acid",38},

		// 格里芬奶包回甲
		{"gk_medaid_hk416",39},

		// 白教指挥士回甲
		{"para_heal",40},

        // PA15技能
		{"pa15_skill",41},

        // 敌方干扰者技能
		{"sf_boss_intruder_skill",42},

		{"sfw_aegis_selfheal",44},

		{"c96_skill",45},

        // 铁血boss 刽子手 技能 跳劈
        {"sf_boss_excutioner_skill",46},
        
        // 铁血boss 炼金术师 技能 大限
        {"sf_boss_alchemist_skill",47},

        // 侦察中枢
        {"spawn_pathfinder",48},

        // 铁血boss 破坏者 技能 指尖风
        {"sf_boss_destroyer_skill",49},

        // 铁血boss 梦想家 技能 跟踪激光打击
        {"sf_boss_dreamer_skill",50},

        // 玩家用KCCO智能雷扫描阶段
        {"kcco_smartgrenade_player_scan",51},

        // 轨道炮轰炸
        {"spawn_orbital_strike",52},

        // 白教涅托辅翼回甲 摇人
		{"para_nytro_support",53},
		{"nyto_spawn_trigger",54},

        // 铁血boss 猎手 技能 困兽狙击
        {"sf_boss_hunter_skill",55},

        // 铁血boss 衔尾蛇 技能 热毒坠落
        {"sf_boss_oroborus_skill",56},

        //菲德洛夫
        {"fedorov_medkit",57},

        // 下面这行是用来占位的，在这之上添加新的技能key和index即可
        {"666",-1}
};

class XM8tracker{
    int m_characterId;
	float m_time;
	int m_numtime=7;
	int m_factionid;
	Vector3 m_pos;
	XM8tracker(int characterId,float time,int factionid,Vector3 pos)
	{
		m_characterId = characterId;
		m_time = time;
		m_factionid= factionid;
		m_pos=pos;
	}
}

class HK416_tracker{
    int m_characterId;
	float m_time=0.5;
	int m_numtime=8;
	int m_factionid;
	array<const XmlElement@> m_affected;
	Vector3 m_pos;
	HK416_tracker(int characterId,int factionid,Vector3 pos,array<const XmlElement@> affected)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
		m_affected= affected;
	}
}

class UZI_tracker{
    int m_characterId;
	float m_time=2.0;
	int m_numtime=2;
	int m_factionid;
	array<const XmlElement@> m_affected;
	Vector3 m_pos;
	UZI_tracker(int characterId,int factionid,Vector3 pos,array<const XmlElement@> affected)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
		m_affected= affected;
	}
}

class Vector_tracker{
    int m_characterId;
	int m_numtime=4;
	float m_time=0;
	int m_factionid;
	Vector3 m_pos;
	Vector_tracker(int characterId,int factionid,Vector3 pos){
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
	}
}

class Javelin_lister{
    int m_characterId;
	float m_time=6;
	int m_numtime=1;
	int m_factionid;
	int m_vehicleid;
	Vector3 m_pos;
	Javelin_lister(int characterId,int factionid,int vehicleid,Vector3 pos)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_vehicleid = vehicleid;
		m_pos = pos;
	}
}

class DOT_tracker{
    int m_characterId;
	int m_numtime;
	float m_time=0.05;
	float m_time_interval;
	int m_factionid;
	string m_projectile;
	Vector3 m_pos;
	DOT_tracker(int characterId,int factionid,Vector3 pos,float time,string projectile,int num){
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
		m_projectile=projectile;
		m_time_interval=time;
		m_numtime = num;
	}
}
