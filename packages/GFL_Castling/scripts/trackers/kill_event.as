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
        {"gkw_m1911_mod3.weapon",2},
        {"gkw_m950amod3.weapon",3},
        {"gkw_m950amod3_702.weapon",3},
        {"gkw_m950amod3_4302.weapon",3},
        {"gkw_apsmod3.weapon",3},
        {"gkw_apsmod3_4306.weapon",3},
        {"gkw_apsmod3_6808.weapon",3},
        {"gkw_c96mod3.weapon",3},
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
        {"gkw_ar15mod3_30001_skill.weapon",3},
        {"gkw_hk416_agent_hv.weapon",3},
        {"gkw_hk416_agent_fmj.weapon",3},
        {"gkw_asval.weapon",3},
        {"gkw_asval_2907.weapon",3},
        {"gkw_asvalmod3.weapon",3},
        {"gkw_asvalmod3_2907.weapon",3},
        {"gkw_ribeyrollesmod3_skill.weapon",3},

        // SMG——3kills
        {"gkw_ump40.weapon",3},
        {"gkw_ump9.weapon",3},
        {"gkw_ump45.weapon",3},
        {"gkw_ump9mod3.weapon",3},
        {"gkw_ump45mod3.weapon",3},
        {"gkw_ump45_410.weapon",3},
        {"gkw_ump45_535.weapon",3},
        {"gkw_ump45_3403.weapon",3},
        {"gkw_ump45mod3_410.weapon",3},
        {"gkw_ump45mod3_535.weapon",3},
        {"gkw_ump45mod3_3403.weapon",3},
        {"gkw_vector_agent_hpi.weapon",3},
        {"gkw_vector_agent_fmj.weapon",3},

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
        {"gkw_uzi.weapon",3},
        {"gkw_uzimod3.weapon",3},
        {"gkw_uzimod3_skill.weapon",3},
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
        {"gkw_sten.weapon",3},
        {"gkw_stenmod3.weapon",3},
        {"gkw_saf.weapon",3},
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
        {"gkw_mp7.weapon",3},
        {"gkw_mp7_6806.weapon",3},
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
        {"gkw_p90.weapon",3},
        {"gkw_p90_2802.weapon",3},
        {"gkw_augpara.weapon",3},
        {"gkw_augpara_5503.weapon",3},
        {"gkw_cms.weapon",3},
        {"gkw_cms_aps.weapon",3},
        {"gkw_cms_st.weapon",3},
        {"gkw_cms_6403.weapon",3},
        {"gkw_cms_6403_aps.weapon",3},
        {"gkw_cms_6403_st.weapon",3},
        {"gkw_vp1915.weapon",3},
        {"gkw_vp1915_6604.weapon",3},

        //短突
        {"gkw_ak74u.weapon",5},
        {"gkw_ak74u_3002.weapon",5},
        {"gkw_ak74u_skill.weapon",3},
        {"gkw_ak74u_3002_skill.weapon",3},
        {"gkw_sr3mp.weapon",4},
        {"gkw_sr3mp_skill.weapon",4},
        {"gkw_ro635.weapon",3},
        {"gkw_ro635mod3.weapon",3},
        {"gkw_honeybadger.weapon",3},
        {"gkw_honeybadger_4005.weapon",3},
        {"gkw_g36c.weapon",3},
        {"gkw_g36c_mod3.weapon",3},
        {"gkw_g36c_mod3_skill.weapon",3},
        {"gkw_g36c_3103.weapon",3},
        {"gkw_g36c_mod3_3103.weapon",3},
        {"gkw_g36c_mod3_3103_skill.weapon",3},
        {"gkw_x95.weapon",4},
        {"gkw_ar57.weapon",4},

        //SG 5kill
        {"gkw_hawk97mod3.weapon",5},
        {"gkw_hawk97mod3_5805.weapon",5},

        //其他

        {"gkw_m1903_exp.weapon",4},
        {"gkw_m1903_302_exp.weapon",4},
        {"gkw_type80mod3.weapon",5},
        {"gkw_type80mod3_skill.weapon",5},

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
            string Solider_Name = target.getStringAttribute("soldier_group_name");
            string dead_pos = target.getStringAttribute("position");
            string reward_pool_key = getRewardPool(Solider_Name);
            string KillerWeaponKey = event.getStringAttribute("key");
            string killway= event.getStringAttribute("method_hint");

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
            string killername = killer.getStringAttribute("player_name");
            if (playerId == -1) return;
            
            
            //只查询我方杀敌
            if (!(factionId==0) || !(characterId > 0)) return;

            string c_weaponType = getPlayerWeaponFromListByID(characterId,0);
            string c_armorType = getPlayerWeaponFromListByID(characterId,3);
            int kill_to_heal_scale = 1;
            if(reward_pool_key=="rare" || reward_pool_key=="elite")
            {
                kill_to_heal_scale = 2;
            }
            if(reward_pool_key=="boss")
            {
                kill_to_heal_scale = 5;
            }

            if(c_weaponType=="gkw_ppkmod3.weapon" || c_weaponType =="gkw_ppkmod3_3905.weapon"){
                int i = findSkillIndex(characterId,"PPKMOD3");
                if(i >=0){
                    SkillArray[i].m_time-=1.0;
                    if(KillerWeaponKey=="gkw_ppkmod3.weapon" || KillerWeaponKey=="gkw_ppkmod3_3905.weapon"){
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
            if(startsWith(c_armorType,"exo_x_t6")){
                updateHealByKillEvent(characterId,factionId,10,60,"vest",kill_to_heal_scale);
            }
            if(startsWith(c_armorType,"tms_t6")){
                if (c_weaponType=="gkw_hawk97mod3.weapon" || c_weaponType =="gkw_hawk97mod3_5805.weapon")
                {
                    updateHealByKillEvent(characterId,factionId,4,30,"vest",kill_to_heal_scale+1);
                }
                else
                {
                    updateHealByKillEvent(characterId,factionId,4,30,"vest",kill_to_heal_scale);
                }
            }
            updateHealByKillEvent(characterId,factionId,int(healOnKillWeaponList[c_weaponType]),15,"weapon",kill_to_heal_scale);



            if(KillerWeaponKey=="gkw_ppkmod3.weapon" || KillerWeaponKey=="gkw_ppkmod3_3905.weapon"){
                // 乌鸦是猪，望周知
                if (killway=="hit"){
                    int j = findKillCountIndex(characterId,"ppk");
                    if(j>=0){
                        KillCountArray[j].add();
                        int kill_num = KillCountArray[j].m_killnum;
                        switch(kill_num)
                        {
                            case 7:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage1");break;}
                            case 15:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage2");break;}
                            case 30:{sendPrivateMessageKey(m_metagame,playerId,"ppkmod3killstage3");break;}
                            default:    break;
                        }
                    }
                    else{
                        KillCountArray.insertLast(kill_count(characterId,1,"ppk"));
                    }
                }    
            }

            if(KillerWeaponKey=="gkw_carcano1938.weapon" && killway=="hit"){
                int j = findKillCountIndex(characterId,"carcano");
                if(j>=0){
                    KillCountArray[j].add();
                    string c_pos = getStringPosFromCharacterId(m_metagame,characterId);
                    if(c_pos != "")
                    {
                        spawnStaticProjectile(m_metagame,"particle_carcano_killstreak.projectile",c_pos,characterId,factionId);
                    }
                }
                else{
                    KillCountArray.insertLast(kill_count(characterId,1,"carcano"));
                    string c_pos = getStringPosFromCharacterId(m_metagame,characterId);
                    if(c_pos != "")
                    {
                        spawnStaticProjectile(m_metagame,"particle_carcano_killstreak.projectile",c_pos,characterId,factionId);
                    }                    
                }
            }

            if(KillerWeaponKey=="blast_snipe_mosin.projectile" && killway=="blast")
            {
                int j = findKillCountIndex(characterId,"mosinnagant");
                if(j>=0){
                    KillCountArray[j].add();
                    int kill_num = KillCountArray[j].m_killnum;
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
                else{
                    KillCountArray.insertLast(kill_count(characterId,1,"mosinnagant"));
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

            if (Solider_Name=="") return;

            if(SFbossList.find(Solider_Name)>-1 && characterId > 0){
                addCustomStatToCharacter(m_metagame,"sfboss_kill",characterId);
            }
            
            int GivenRP = getRPKillReward(Solider_Name);
            float GivenXP = getXPKillReward(Solider_Name);
            if(GivenRP>0){
                givePlayerRPcount(playerId,GivenRP);
            }
            if(GivenXP>0){
                givePlayerXPcount(playerId,GivenXP);
            }
        }
	}
    protected void handlePlayerDieEvent(const XmlElement@ event){
        if(KillCountArray.size()<=0) return;
        const XmlElement@ player = event.getFirstElementByTagName("target");
        if(player is null) return;
        int cId= player.getIntAttribute("character_id");
        if(cId==-1) return;
        int index=findKillCountIndex(cId);
        if(index==-1) return;
        KillCountArray.removeAt(index);
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
    int m_characterId;
    int m_killnum=0;
    string m_kill_count_type;
    kill_count(int a,int b,string c){
        m_characterId=a;
        m_killnum=b;
        m_kill_count_type = c;
    }

    void add(){
        m_killnum++;
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

int findKillCountIndex(int cId,string type){
    for (uint i=0;i<KillCountArray.length();i++){
        if (KillCountArray[i].m_characterId==cId && KillCountArray[i].m_kill_count_type == type ) {
            return i;
        }
    }
    return -1;
}

int findKillCountIndex(int cId){
    for (uint i=0;i<KillCountArray.length();i++){
        if (KillCountArray[i].m_characterId==cId) {
            return i;
        }
    }
    return -1;
}