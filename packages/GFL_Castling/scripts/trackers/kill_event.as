#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
#include "commandskill.as"
#include "enemy_reward.as"
#include "GFLplayerlist.as"

//Originally created by NetherCrow
//Author: NetherCrow
//Author: Saiwa

// --------------------------------------------
class kill_event : Tracker {
	protected GameMode@ m_metagame;
    protected array<HealOnKill_tracker@> HealOnKill_track;
	protected int m_difficulty;

    protected float m_droprate_offset=0;

	// --------------------------------------------
	kill_event(GameMode@ metagame,const UserSettings@ m_userSettings) {
		@m_metagame = @metagame;
        //rpScale = rp_multiplier;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
		m_metagame.getComms().send("<command class='set_metagame_event' name='player_stun' enabled='1' />");
        m_difficulty=m_userSettings.m_GlobalDifficulty;
        m_droprate_offset= m_difficulty* 0.01;
	}
    
    dictionary healOnKillWeaponList = {

        // 空武器，后面杀几个人回一次甲就写几
        {"",0},


        // 近战武器
        {"ff_excutioner_2.weapon",3},
        {"ff_parw_alina.weapon",2},
        {"ff_gager_1.weapon",3},
        {"gkw_type100_skill.weapon",3},
        {"gkw_type100_4004_skill.weapon",3},
        {"gkw_mg36_4903_skill.weapon",3},


        // 近战定位HG
        {"gkw_m950amod3.weapon",3},
        {"gkw_m950amod3_702.weapon",3},
        {"gkw_m950amod3_4302.weapon",3},
        {"gkw_apsmod3.weapon",3},
        {"gkw_apsmod3_4306.weapon",3},
        {"gkw_apsmod3_6808.weapon",3},
        {"gkw_c96mod3.weapon",3},
        {"gkw_c96mod3_8405.weapon",3},
        {"gkw_makarovmod3.weapon",3},
        {"ff_alchemist.weapon",3},
        {"ff_alchemist_skill.weapon",3},

        // 近战定位AR
        {"gkw_ak12_skill.weapon",3},
        {"gkw_ak12_blm_skill.weapon",3},
        {"gkw_ak12_2402_skill.weapon",3},
        {"gkw_ak15mod3_skill.weapon",3},
        {"gkw_ak15mod3_blm_skill.weapon",3},
        {"gkw_ar15mod3_skill.weapon",3},
        {"gkw_ar15mod3_532_skill.weapon",3},
        {"gkw_ar15mod3_552_skill.weapon",3},
        {"gkw_ar15mod3_4508_skill.weapon",3},
        {"gkw_ar15mod3_30001_skill.weapon",3},
        {"gkw_hk416_agent_hv.weapon",3},
        {"gkw_hk416_agent_fmj.weapon",3},
        {"gkw_asval.weapon",3},
        {"gkw_asvalmod3.weapon",3},
        {"gkw_asval_2907.weapon",3},
        {"gkw_asvalmod3_2907.weapon",3},
        {"gkw_asval_10106.weapon",3},
        {"gkw_asvalmod3_10106.weapon",3},        
        {"gkw_ribeyrollesmod3_skill.weapon",3},

        // SMG——3kills
        {"gkw_ump40.weapon",3},
        {"gkw_ump40_559.weapon",3},
        {"gkw_ump9.weapon",3},
        {"gkw_ump9_556.weapon",3},
        {"gkw_ump9_3404.weapon",3},
        {"gkw_ump45.weapon",3},
        {"gkw_ump9mod3.weapon",3},
        {"gkw_ump9mod3_556.weapon",3},
        {"gkw_ump9mod3_3404.weapon",3},
        {"gkw_ump45mod3.weapon",3},
        {"gkw_ump45_410.weapon",3},
        {"gkw_ump45_535.weapon",3},
        {"gkw_ump45_555.weapon",3},
        {"gkw_ump45_3403.weapon",3},
        {"gkw_ump45mod3_410.weapon",3},
        {"gkw_ump45mod3_535.weapon",3},
        {"gkw_ump45mod3_555.weapon",3},
        {"gkw_ump45mod3_3403.weapon",3},
        {"gkw_vector_agent_hpi.weapon",3},
        {"gkw_vector_agent_fmj.weapon",3},
        {"gkw_mpk.weapon",3},
        {"gkw_mpl.weapon",3},

        {"gkw_ump45_5405.weapon",3},
        {"gkw_ump45mod3_5405.weapon",3},
        {"gkw_ump45_5405_skill.weapon",3},
        {"gkw_ump45mod3_5405_skill.weapon",3},

        {"gkw_ump9_6704.weapon",3},
        {"gkw_ump9mod3_6704.weapon",3},
        {"gkw_ump9_6704_skill.weapon",3},
        {"gkw_ump9mod3_6704_skill.weapon",3},
        
        {"gkw_pps43.weapon",3},
        {"gkw_m3.weapon",3},
        {"gkw_type100.weapon",3},
        {"gkw_type100_1.weapon",3},
        {"gkw_type100_4004.weapon",3},
        {"gkw_type100mod3.weapon",3},
        {"gkw_type100mod3_4004.weapon",3},
        {"gkw_type100mod3_skill.weapon",3},   
        {"gkw_type100mod3_4004_skill.weapon",3},
        {"gkw_sp9.weapon",3},
        {"gkw_sp9_6303.weapon",3},
        {"gkw_vector.weapon",3},
        {"gkw_vector_549.weapon",3},
        {"gkw_vector_549_skill.weapon",3},
        {"gkw_vector_1901.weapon",3},
        {"gkw_pm06.weapon",3},
        {"gkw_pp90.weapon",3},
        {"gkw_js9.weapon",3},
        {"gkw_js9_4702.weapon",3},
        {"gkw_thompson.weapon",3},
        {"gkw_thompson_5703.weapon",3},
        {"gkw_lusa_7802.weapon",3},
        {"gkw_lusa_8501.weapon",3},
        {"gkw_uzi.weapon",3},
        {"gkw_uzimod3.weapon",3},
        {"gkw_uzimod3_skill.weapon",3},
        {"gkw_uzimod3_7907.weapon",3},
        {"gkw_uzimod3_7907_skill.weapon",3},
        {"gkw_vz61.weapon",3},
        {"gkw_vz61_only.weapon",3},
        {"gkw_pp19.weapon",3},
        {"gkw_pp19mod3.weapon",3},
        {"gkw_mab38.weapon",3},
        {"gkw_mab38mod3.weapon",3},
        {"gkw_mab38_oc.weapon",3},
        {"gkw_mab38mod3_oc.weapon",3},        
        {"gkw_klin.weapon",3},
        {"gkw_mp40.weapon",3},
        {"gkw_mp40_902.weapon",3},
        {"gkw_mp5.weapon",3},
        {"gkw_mp5mod3.weapon",3},
        {"gkw_mp5_3.weapon",3},
        {"gkw_mp5_1205.weapon",3},
        {"gkw_mp5_1903.weapon",3},
        {"gkw_mp5_3006.weapon",3},
        {"gkw_mp5mod3_3.weapon",3},
        {"gkw_mp5mod3_1205.weapon",3},
        {"gkw_mp5mod3_1903.weapon",3},
        {"gkw_mp5mod3_3006.weapon",3},
        {"ff_ripper.weapon",3},
        {"ff_ripper_swap.weapon",3},
        {"gkw_sterling.weapon",3},
        {"gkw_tmp.weapon",3},
        {"gkw_tmp_2807.weapon",3},
        {"gkw_ar57_skill.weapon",3},
        {"gkw_ar57_6705_skill.weapon",3},
        {"gkw_sten.weapon",3},
        {"gkw_stenmod3.weapon",3},
        {"gkw_saf.weapon",3},
        {"gkw_saf_5205.weapon",3},
        {"gkw_saf_6607.weapon",3},
        {"gkw_f1.weapon",3},
        {"gkw_f1mod3.weapon",3},
        {"gkw_emp35.weapon",3},
        {"gkw_emp35_8003.weapon",3},
        {"gkw_type79.weapon",3},
        {"gkw_type79_1402.weapon",3},
        {"gkw_ppsh41.weapon",3},
        {"gkw_ppsh41mod3.weapon",3},
        {"gkw_ppsh41_602.weapon",3},
        {"gkw_ppsh41mod3_602.weapon",3},
        {"gkw_ppd40.weapon",3},
        {"gkw_p50.weapon",3},
        {"gkw_mp7.weapon",4},
        {"gkw_mp7_2405.weapon",4},
        {"gkw_mp7_6806.weapon",4},
        {"gkw_idw.weapon",3},
        {"gkw_idw_2108.weapon",3},
        {"gkw_idw_3205.weapon",3},
        {"gkw_idw_4908.weapon",3},
        {"gkw_idwmod3.weapon",3},
        {"gkw_idwmod3_2108.weapon",3},
        {"gkw_idwmod3_3205.weapon",3},
        {"gkw_idwmod3_4908.weapon",3},
        {"gkw_64type.weapon",3},
        {"gkw_64typemod3.weapon",3},
        {"gkw_kp31.weapon",3},
        {"gkw_kp31mod3.weapon",3},
        {"gkw_kp31_310.weapon",3},
        {"gkw_kp31mod3_310.weapon",3},
        {"gkw_kp31_3101.weapon",3},
        {"gkw_kp31mod3_3101.weapon",3},        
        {"gkw_p90.weapon",4},
        {"gkw_p90_2802.weapon",4},
        {"gkw_p90_5701.weapon",4},
        {"gkw_augpara.weapon",3},
        {"gkw_augpara_561.weapon",3},
        {"gkw_augpara_5503.weapon",3},
        {"gkw_cms.weapon",4},
        {"gkw_cms_aps.weapon",3},
        {"gkw_cms_st.weapon",4},
        {"gkw_cms_6403.weapon",4},
        {"gkw_cms_6403_aps.weapon",3},
        {"gkw_cms_6403_st.weapon",4},
        {"gkw_vp1915.weapon",3},
        {"gkw_vp1915_6604.weapon",3},
        {"gkw_vp1915_8503.weapon",3},
        {"gkw_ro635.weapon",3},
        {"gkw_ro635mod3.weapon",3},
        {"gkw_ro635_534.weapon",3},
        {"gkw_ro635mod3_534.weapon",3},
        {"gkw_ro635_554.weapon",3},
        {"gkw_ro635mod3_554.weapon",3},        
        {"gkw_owen.weapon",3},
        {"gkw_type82.weapon",3},
        {"gkw_mac10.weapon",3},
        {"gkw_jatimatic.weapon",3},
        {"gkw_43m.weapon",3},
        {"ff_dragoon.weapon",3},
        {"gkw_evo3.weapon",3},
        {"gkw_evo3mod3.weapon",3},


        //短突
        {"gkw_ak74u.weapon",5},
        {"gkw_ak74u_3002.weapon",5},
        {"gkw_ak74u_skill.weapon",4},
        {"gkw_ak74u_3002_skill.weapon",4},

        {"gkw_kacpdw.weapon",4},

        {"gkw_sr3mp.weapon",3},
        {"gkw_sr3mp_skill.weapon",4},
        {"gkw_sr3mp_4101.weapon",3},
        {"gkw_sr3mp_4101_skill.weapon",4},
        {"gkw_sr3mp_only.weapon",3},
        {"gkw_sr3mp_only_skill.weapon",4},
        {"gkw_sr3mp_4101_only.weapon",3},
        {"gkw_sr3mp_4101_only_skill.weapon",4},

        {"gkw_honeybadger.weapon",4},
        {"gkw_honeybadger_4005.weapon",4},
        {"gkw_g36c.weapon",3},
        {"gkw_g36c_mod3.weapon",4},
        {"gkw_g36c_mod3_skill.weapon",5},
        {"gkw_g36c_3103.weapon",3},
        {"gkw_g36c_mod3_3103.weapon",4},
        {"gkw_g36c_mod3_3103_skill.weapon",5},
        {"gkw_g36c_5201.weapon",3},
        {"gkw_g36c_mod3_5201.weapon",4},
        {"gkw_g36c_mod3_5201_skill.weapon",5},        
        {"gkw_x95.weapon",4},
        {"gkw_ar57.weapon",4},
        {"gkw_ar57_6705.weapon",4},

        //SG 5kill
        {"gkw_hawk97mod3.weapon",5},
        {"gkw_hawk97mod3_5805.weapon",5},

        //其他

        {"gkw_m1903_exp.weapon",4},
        {"gkw_m1903_302_exp.weapon",4},
        {"gkw_m1903_1107_exp.weapon",4},
        {"gkw_type80mod3.weapon",8},
        {"gkw_type80mod3_skill.weapon",8},

        {"666",-1}
    };
    dictionary meleeWeaponList ={
        {"ff_excutioner_2.weapon",3},
        {"ff_parw_alina.weapon",3},
        {"ff_gager_1.weapon",3},
        {"gkw_mg36_4903_skill.weapon",3},
        {"666",-1}
    };
    protected void updateHealByKillEvent(int characterid,int factionid,int killstoheal,int timeaddafterkill,string type="weapon",int killadd=1){
        if (killstoheal<=0) return;
        uint jud=0;
        for(uint a=0;a<HealOnKill_track.length();a++)
        {
            if(HealOnKill_track[a].m_characterId==characterid && HealOnKill_track[a].m_type == type ){
                HealOnKill_track[a].current_kills+= killadd;
                HealOnKill_track[a].m_numtime = timeaddafterkill;
                jud = 1;
                break;
            }
        }

        if(jud==0)HealOnKill_track.insertLast(HealOnKill_tracker(characterid,factionid,killstoheal,timeaddafterkill,type)); 
    }

	protected void handleCharacterKillEvent(const XmlElement@ event){
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if ((killer.getIntAttribute("faction_id")) != (target.getIntAttribute("faction_id"))){
            int targetId = target.getIntAttribute("id");
            int factionId = killer.getIntAttribute("faction_id");
            int characterId = killer.getIntAttribute("id");
            string solider_name = target.getStringAttribute("soldier_group_name");
            string dead_pos = target.getStringAttribute("position");
            string reward_pool_key = getRewardPool(solider_name);
            string KillerWeaponKey = event.getStringAttribute("key");
            string killway = event.getStringAttribute("method_hint");

            if (startsWith(solider_name,"sf_goliath") && killway == "drive_over")
            {
                spawnStaticProjectile(m_metagame,"goliath.projectile",dead_pos,targetId,target.getIntAttribute("faction_id"));
            }

            if(factionId !=0 && (solider_name =="ar_378_scarl" || solider_name == "daybreak_squad") )
            {
                array<string> scarl = {"gkw_scarl.weapon","gkw_scarl_only.weapon"};
                array<string> scarh = {"gkw_scarh.weapon","gkw_scarh_only.weapon"};
                array<int> characterid_scarl =getPlayerCidByWeaponKeys(scarl,0);
                array<int> characterid_scarh =getPlayerCidByWeaponKeys(scarh,0);
                for(uint i=0;i<characterid_scarl.size();i++)
                {
                    int scarl_cid = characterid_scarl[i];
                    healCharacter(m_metagame,scarl_cid,rand(1,2));
                    sendFactionMessageKeySaidAsCharacter(m_metagame,0,scarl_cid,"scarl_dogtag_gain",dictionary(),0.9);
                }
                for(uint i=0;i<characterid_scarh.size();i++)
                {
                    int scarh_cid = characterid_scarh[i];
                    int j = findSkillIndex(scarh_cid,"sniper");
                    if(j >=0){
                        SkillArray[j].m_time-=2.0;
                    }                    
                    sendFactionMessageKeySaidAsCharacter(m_metagame,0,scarh_cid,"scarh_dogtag_gain",dictionary(),0.9);
                }
            }

            if(reward_pool_key != "" && factionId==0){
                if(reward_pool_key=="common"){
                    if(rand(0.0f,1.0f) <= (0.15f+ m_droprate_offset)){
						ScoredResource@ r = getRandomScoredResource(reward_pool_common);
                        string c = 
                            "<command class='create_instance'" +
                            " faction_id='" + 0 + "'" +
                            " instance_class='" + r.m_type + "'" +
                            " instance_key='" + r.m_key + "'" +
                            " position='" + dead_pos + "'" +
                            " character_id='" + characterId + "'/>";
                        m_metagame.getComms().send(c);
                    }
                }
                else if(reward_pool_key=="uncommon"){
                    if(rand(0.0f,1.0f) <= (0.15f+ m_droprate_offset)){
						ScoredResource@ r = getRandomScoredResource(reward_pool_uncommon);
                        string c = 
                            "<command class='create_instance'" +
                            " faction_id='" + 0 + "'" +
                            " instance_class='" + r.m_type + "'" +
                            " instance_key='" + r.m_key + "'" +
                            " position='" + dead_pos + "'" +
                            " character_id='" + characterId + "'/>";
                        m_metagame.getComms().send(c);
                    }
                }
                else if(reward_pool_key=="rare"){
                    if(rand(0.0f,1.0f) <= (0.3f+ m_droprate_offset)){
						ScoredResource@ r = getRandomScoredResource(reward_pool_rare);
                        string c = 
                            "<command class='create_instance'" +
                            " faction_id='" + 0 + "'" +
                            " instance_class='" + r.m_type + "'" +
                            " instance_key='" + r.m_key + "'" +
                            " position='" + dead_pos + "'" +
                            " character_id='" + characterId + "'/>";
                        m_metagame.getComms().send(c);
                    }
                }
                else if(reward_pool_key=="elite"){
                    ScoredResource@ r = getRandomScoredResource(reward_pool_elite);
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='" + 0 + "'" +
                        " instance_class='" + r.m_type + "'" +
                        " instance_key='" + r.m_key + "'" +
                        " position='" + dead_pos + "'" +
                        " character_id='" + characterId + "'/>";
                    m_metagame.getComms().send(c);
                }
                else if(reward_pool_key=="boss"){
                    ScoredResource@ r = getRandomScoredResource(reward_pool_boss);
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='" + 0 + "'" +
                        " instance_class='" + r.m_type + "'" +
                        " instance_key='" + r.m_key + "'" +
                        " position='" + dead_pos + "'" +
                        " character_id='" + characterId + "'/>";
                    m_metagame.getComms().send(c);
                }                
            }
            
            int playerId = killer.getIntAttribute("player_id");
            if (playerId == -1) return; //下面的代码不计算AI击杀
            
            
            //只查询我方杀敌
            if (!(factionId==0) || !(characterId > 0)) return;

            // _log("击杀断点，角色ID:"+playerId);
            GFL_playerInfo@ playerInfo = getPlayerInfoFromListbyPid(playerId);
            if (playerInfo.getPlayerName() == default_string ) return;
            string playerName = playerInfo.getPlayerName();
            int kill_to_heal_scale = 1;

            string c_weaponType = playerInfo.getPlayerEquipment().getWeapon(0);
            string c_armorType = playerInfo.getPlayerEquipment().getWeapon(3);

            if(reward_pool_key=="boss")
            {
                handleKillEventToPlayerInfo(playerId,5);
                kill_to_heal_scale = 5;
                notify(m_metagame, "kill streak,boss reward", dictionary(), "misc", playerId, false, "", 1.0);
            }
            else if(reward_pool_key=="rare" || reward_pool_key=="elite")
            {
                handleKillEventToPlayerInfo(playerId,3);
                kill_to_heal_scale = 2;
                notify(m_metagame, "kill streak,elite reward", dictionary(), "misc", playerId, false, "", 1.0);
            } 
            else if(point_nerfed_reward.find(solider_name) > -1)
            {
                if(rand(0.0f,1.0f) <= 0.3f)
                {
                    handleKillEventToPlayerInfo(playerId,1);
                    //兵蚁 僵尸 这种东西给的积分变少，30%概率给1点积分
                }
            }            
            else if(gk_weapon_hvy_nerfed.find(c_weaponType) > -1)
            {
                if(rand(0.0f,1.0f) <= 0.5f)
                {
                    handleKillEventToPlayerInfo(playerId,1);
                    //榴弹发射器和迫击炮击杀小兵的收益降低50%
                }                
            }
            else
            {
                handleKillEventToPlayerInfo(playerId,1);                
            }


            GFL_battleInfo@ battleInfo = playerInfo.getBattleInfo();

            int m_killstreak_point = battleInfo.getKillStreakPoint();
            int m_tactic_point = battleInfo.getTacticPoint();
            int m_counter = battleInfo.getKillStreakPointCounter();

            if(m_counter>=10 && !battleInfo.checkKillStreakIndexUsed(1))
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=0;
                }
                else
                {
                    m_tactic_point_offset+=1;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }                  
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter);
                battleInfo.addKillStreakIndex(1);
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }
            else if(m_counter>=10 && !battleInfo.checkKillStreakIndexUsed(2))
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }
                else
                {
                    m_tactic_point_offset+=2;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }                  
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter);   
                battleInfo.addKillStreakIndex(2);  
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }
            else if(m_counter>=10 && !battleInfo.checkKillStreakIndexUsed(3))
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=2;
                }
                else
                {
                    m_tactic_point_offset+=3;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }                  
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter);
                battleInfo.addKillStreakIndex(3);       
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }
            else if(m_counter>=10 && !battleInfo.checkKillStreakIndexUsed(4))
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=3;
                }
                else
                {
                    m_tactic_point_offset+=4;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }                  
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter);  
                battleInfo.addKillStreakIndex(4);
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }
            else if(m_counter>=10 && !battleInfo.checkKillStreakIndexUsed(5))
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=4;
                }
                else
                {
                    m_tactic_point_offset+=5;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }                  
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter); 
                battleInfo.addKillStreakIndex(5);
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }
            else if(m_counter>=10 && m_killstreak_point>50)
            {
                int m_tactic_point_offset = 0;
                if(gk_weapon_sf_nerfed.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=4;
                }
                else
                {
                    m_tactic_point_offset+=5;
                }
                if(gk_weapon_rf_list.find(c_weaponType) > -1 || gk_weapon_hg_list.find(c_weaponType) > -1)
                {
                    m_tactic_point_offset+=1;
                }               
                battleInfo.addTacticPoint(m_tactic_point_offset);
                m_counter-=10;
                battleInfo.setKillStreakPointCounter(m_counter);        
                dictionary a;
                a["%num"] = ""+ m_tactic_point_offset;                
                notify(m_metagame, "kill streak,get reward", a, "misc", playerId, false, "", 1.0);
            }

            if(gk_weapon_hg_list.find(KillerWeaponKey)>=0)
            {
                reduceAllCallCooldown(playerName,1.0);
            }


            if(c_weaponType=="gkw_ppkmod3.weapon" || c_weaponType =="gkw_ppkmod3_3905.weapon" || c_weaponType =="gkw_ppkmod3_6109.weapon"){
                int i = findSkillIndex(characterId,"PPKMOD3");
                if(i >=0){
                    SkillArray[i].m_time-=1.0;
                    if(KillerWeaponKey=="gkw_ppkmod3.weapon" || KillerWeaponKey=="gkw_ppkmod3_3905.weapon" || KillerWeaponKey=="gkw_ppkmod3_6109.weapon"){
                        SkillArray[i].m_time-=1.0;
                    }
                }
            }

            if(c_weaponType=="gkw_m1895mod3_5309.weapon" 
            || c_weaponType =="gkw_m1895mod3_5309_skill.weapon"
            || c_weaponType =="gkw_m1895mod3_7107.weapon"
            || c_weaponType =="gkw_m1895mod3_7107_skill.weapon"
            || c_weaponType =="gkw_m1895mod3.weapon"
            || c_weaponType =="gkw_m1895mod3_skill.weapon"
            ){
                int i = findSkillIndex(characterId,"Nagant");
                if(i >=0){
                    SkillArray[i].m_time-=2.0;
                }
            }
            // 护甲判断
            if(startsWith(c_armorType,'acbp_t6')){
                float scale = 1.0;
                if(reward_pool_key=="rare" || reward_pool_key=="elite")
                {
                    scale = 2.0;
                }
                if(reward_pool_key=="boss")
                {
                    scale = 4.0;
                }
                int i = findSkillIndex(characterId);
                if(i >=0){
                    if(SkillArray[i].m_time >=30.0){
                        SkillArray[i].m_time-=1.0 *scale;
                    }
                    else{
                        SkillArray[i].m_time-=0.5 *scale;
                    }
                }
            }
            else if(startsWith(c_armorType,"exo_x_t6")){
                updateHealByKillEvent(characterId,factionId,10,60,"vest",kill_to_heal_scale);
            }
            else if(startsWith(c_armorType,"exo_t6") || startsWith(c_armorType,"dima_bunny")){
                if(boss_list.find(solider_name)>-1){
                    healCharacter(m_metagame,characterId,5);
                }
                else if(reward_pool_key=="rare" || reward_pool_key=="elite")
                {
                    healCharacter(m_metagame,characterId,2);
                }                
            }            
            else if(startsWith(c_armorType,"tms_t6")){
                if (c_weaponType=="gkw_hawk97mod3.weapon" || c_weaponType =="gkw_hawk97mod3_5805.weapon")
                {
                    updateHealByKillEvent(characterId,factionId,4,30,"vest",kill_to_heal_scale+1);
                }
                else
                {
                    updateHealByKillEvent(characterId,factionId,4,30,"vest",kill_to_heal_scale);
                }
            }

            if(c_weaponType=="gkw_m1911_mod3.weapon" || c_weaponType=="gkw_m1911mod3_4514.weapon" || c_weaponType=="gkw_m1911mod3_8406.weapon" ){
                if ((startsWith(c_armorType,"bp_")))
                {
                    updateHealByKillEvent(characterId,factionId,4,15,"weapon",kill_to_heal_scale*2);
                }
                else
                {
                    updateHealByKillEvent(characterId,factionId,4,15,"weapon",kill_to_heal_scale);
                }
            }            

            updateHealByKillEvent(characterId,factionId,int(healOnKillWeaponList[c_weaponType]),15,"weapon",kill_to_heal_scale);

            if(KillerWeaponKey=="gkw_ppkmod3.weapon" || KillerWeaponKey=="gkw_ppkmod3_3905.weapon" || KillerWeaponKey=="gkw_ppkmod3_6109.weapon"){
                // 乌鸦是猪，望周知
                if (killway=="hit"){
                    g_playerInfo_Buck.addKillSkillCountbyPid(playerId,"ppk");
                    int kill_num = g_playerInfo_Buck.getKillSkillCountbyPid(playerId,"ppk");
                    switch(kill_num)
                    {
                        case 7:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage1");break;}
                        case 15:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage2");break;}
                        case 30:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage3");break;}
                        default:break;
                    }
                }
            }

            if(KillerWeaponKey=="gkw_carcano1938.weapon" && killway=="hit"){
                g_playerInfo_Buck.addKillSkillCountbyPid(playerId,"carcano");
                string c_pos = getStringPosFromCharacterId(m_metagame,characterId);
                if(c_pos != "")
                {
                    spawnStaticProjectile(m_metagame,"particle_carcano_killstreak.projectile",c_pos,characterId,factionId);
                }
            }

            if(KillerWeaponKey=="blast_snipe_mosin.projectile" && killway=="blast")
            {
                g_playerInfo_Buck.addKillSkillCountbyPid(playerId,"mosin");
                int kill_num = g_playerInfo_Buck.getKillSkillCountbyPid(playerId,"mosin");
                // _log("成功积累"+ kill_num);
                switch(kill_num)
                {
                    case 10:{notify(m_metagame, "Skill - Mosin Nagant LV1", dictionary(), "misc", playerId, false, "", 1.0);break;}
                    case 20:{notify(m_metagame, "Skill - Mosin Nagant LV2", dictionary(), "misc", playerId, false, "", 1.0);break;}
                    case 30:{notify(m_metagame, "Skill - Mosin Nagant LV3", dictionary(), "misc", playerId, false, "", 1.0);break;}
                    case 40:{notify(m_metagame, "Skill - Mosin Nagant LV4", dictionary(), "misc", playerId, false, "", 1.0);break;}
                    case 505:
                    {
                        notify(m_metagame, "Skill - Mosin Nagant LV5", dictionary(), "misc", playerId, false, "", 1.0);
                        addItemInBackpack(m_metagame,characterId,"carry_item","hayha_chip.carry_item");
                        break;
                    }                        
                    default: break;
                }
                if (kill_num >= 30)
                {
                    healCharacter(m_metagame,characterId,1);
                }
            }

            if(KillerWeaponKey=="gkw_m1891mod3.projectile" && killway=="hit")
            {
                int i = findSkillIndex(characterId,"mosin");
                if(i >=0){
                    if(reward_pool_key=="boss")
                    {
                        SkillArray[i].m_time-=3.0;
                    }
                    else
                    {
                        SkillArray[i].m_time-=1.0;
                    }
                }
            }

            if(KillerWeaponKey=="blast_snipe_ff_hunter.projectile" && killway=="blast")
            {
                if(eliteEnemyName.find(solider_name)>-1)
                    healCharacter(m_metagame,characterId,1);
            }

            if (solider_name=="") return;

            if(SFbossList.find(solider_name)>-1 && characterId > 0){
                addCustomStatToCharacter(m_metagame,"sfboss_kill",characterId);
            }
            
            int GivenRP = getRPKillReward(solider_name);
            float GivenXP = getXPKillReward(solider_name);
            if(GivenRP>0){
                givePlayerRPcount(playerId,GivenRP);
            }
            if(GivenXP>0){
                givePlayerXPcount(playerId,GivenXP);
            }
        }
	}

    protected void handlePlayerDieEvent(const XmlElement@ event){
        const XmlElement@ player = event.getFirstElementByTagName("target");
        if(player is null) return;
        int cId = player.getIntAttribute("character_id");
        string name = player.getStringAttribute("name");
        int pId = player.getIntAttribute("player_id");
        if(cId==-1) return;
        handleDeadEventToPlayerInfo(name);
        notify(m_metagame, "kill streak,death report", dictionary(), "misc", pId, false, "", 1.0);

        string weapon_key = getPlayerWeaponFromList(name,0);

        if (Daybreak_Squad.find(weapon_key) >=0 )
        {
            array<string> scarl = {"gkw_scarl.weapon","gkw_scarl_only.weapon"};
            array<string> scarh = {"gkw_scarh.weapon","gkw_scarh_only.weapon"};
            array<int> characterid_scarl =getPlayerCidByWeaponKeys(scarl,0);
            array<int> characterid_scarh =getPlayerCidByWeaponKeys(scarh,0);
            for(uint i=0;i<characterid_scarl.size();i++)
            {
                int scarl_cid = characterid_scarl[i];
                healCharacter(m_metagame,scarl_cid,3);
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,scarl_cid,"scarl_dogtag_gain",dictionary(),0.9);
            }
            for(uint i=0;i<characterid_scarh.size();i++)
            {
                int scarh_cid = characterid_scarh[i];
                int j = findSkillIndex(scarh_cid,"sniper");
                if(j >=0){
                    SkillArray[j].m_time-=5.0;
                }                    
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,scarh_cid,"scarh_dogtag_gain",dictionary(),0.9);
            }
        }

    }

    void update(float time){
        if(HealOnKill_track.length()>0){
            for (uint a=0;a<HealOnKill_track.length();a++){
                HealOnKill_track[a].m_time-=time;
                if(HealOnKill_track[a].m_time<0){	
					if (HealOnKill_track[a].m_numtime>=0){
                        int vestrestore = 0;
                        while(HealOnKill_track[a].current_kills>=HealOnKill_track[a].m_killstoheal){
                            vestrestore++;
                            HealOnKill_track[a].current_kills -= HealOnKill_track[a].m_killstoheal;                            
                        }
                        if(HealOnKill_track[a].current_kills<0){
                            HealOnKill_track[a].current_kills = 0;
                        }
                        if(vestrestore>0){
                            string c = 
                                "<command class='update_inventory'" +
                                " untransform_count='"+ vestrestore +"'" +
                                " character_id='" + HealOnKill_track[a].m_characterId + "' />";
                            m_metagame.getComms().send(c);
                        }
					}
					HealOnKill_track[a].m_numtime--;
					HealOnKill_track[a].m_time=0.2;
					if (HealOnKill_track[a].m_numtime<0){
						HealOnKill_track.removeAt(a);
					}
				}			
			}
		}
    }

	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}
}

class HealOnKill_tracker{
    int m_characterId;
	float m_time=0.2;
	float m_numtime=0;
	int m_factionid;
    int m_killstoheal;
    int current_kills=0;
    string m_type;
	HealOnKill_tracker(int characterId,int factionid,int killstoheal,int timeaddafterkill,string type)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_killstoheal= killstoheal;
        current_kills++;
        m_numtime= timeaddafterkill/0.2;
        m_type = type;
	}
}

class kill_count{
    int m_killnum=0;
    string m_kill_count_type;
    kill_count(int b,string c){
        m_killnum=b;
        m_kill_count_type = c;
    }

    void add(){
        m_killnum++;
    }
    
    void add(int num){
        m_killnum += num;
    }    
}

int findSkillIndex(int cId,string key){
    for (uint i=0;i<SkillArray.length();i++){
        if (SkillArray[i].m_character_id==cId && SkillArray[i].m_weapontype==key) {
            return i;
        }
    }
    return -1;
}

int findSkillIndex(int cId){
    for (uint i=0;i<SkillArray.length();i++){
        if (SkillArray[i].m_character_id==cId) {
            return i;
        }
    }
    return -1;
}

int findSkillIndex_reserve(int cId,string key){
    for (uint i=0;i<SkillArray.length();i++){
        if (SkillArray[i].m_character_id==cId && SkillArray[i].m_weapontype!=key) {
            return i;
        }
    }
    return -1;
}

int findSkillIndex_reserve_array(int cId,array<string> keys){
    for (uint i=0;i<SkillArray.length();i++){
        if (SkillArray[i].m_character_id==cId && keys.find(SkillArray[i].m_weapontype) < 0) {
            return i;
        }
    }
    return -1;
}

class no_delete_data{
    string m_playername;
    int m_playerid;
    int m_num=0;
    string m_data_key;
    no_delete_data(string a,int t,int b,string c){
        m_playername=a;
        m_playerid=t;
        m_num=b;
        m_data_key = c;
    }

    void add(){
        m_num++;
    }
}

int findNodeleteDataIndex(string name,string type){
    for (uint i=0;i<No_Delete_DataArray.length();i++){
        if (No_Delete_DataArray[i].m_playername==name && No_Delete_DataArray[i].m_data_key == type ) {
            return i;
        }
    }
    return -1;
}

