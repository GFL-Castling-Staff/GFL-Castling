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

//Originally created by NetherCrow
//11:39:11: SCRIPT:  received: TagName=character_kill key= method_hint=stab     
//TagName=killer block=12 14 dead=0 faction_id=0 id=11 leader=1 name=Nikita Sokol player_id=0 position=428.551 4.3014 499.254 rp=60 soldier_group_name=default squad_size=0 wounded=0 xp=0   
//TagName=target block=12 14 dead=0 faction_id=1 id=9 leader=1 name=Uwe Neururer player_id=-1 position=428.102 4.30089 498.737 rp=0 soldier_group_name=default_ai squad_size=2 wounded=0 xp=0 
// --------------------------------------------
class kill_event : Tracker {
	protected Metagame@ m_metagame;
    protected array<HealOnKill_tracker@> HealOnKill_track;

	// --------------------------------------------
	kill_event(Metagame@ metagame) {
		@m_metagame = @metagame;
        //rpScale = rp_multiplier;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
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
        {"gkw_88typemod3_skill.weapon",4},

        // 近战定位HG
        {"gkw_m1911mod3.weapon",2},

        // 近战定位AR
        {"gkw_ak12_skill.weapon",3},
        {"gkw_ak12_blm_skill.weapon",3},
        {"gkw_ak12_2402_skill.weapon",3},
        {"gkw_ak15mod3_skill.weapon",3},
        {"gkw_ar15mod3_skill.weapon",3},
        {"gkw_ar15mod3_532_skill.weapon",3},

        // SMG——2kills
        {"gkw_ump40.weapon",2},
        {"gkw_ump9.weapon",2},
        {"gkw_ump45.weapon",2},
        {"gkw_ump9mod3.weapon",2},
        {"gkw_ump45mod3.weapon",2},
        {"gkw_ump45_410.weapon",2},
        {"gkw_ump45_535.weapon",2},
        {"gkw_ump45mod3_410.weapon",2},
        {"gkw_ump45mod3_535.weapon",2},
        {"gkw_pps43.weapon",2},
        {"gkw_m3.weapon",2},
        {"gkw_type100.weapon",2},
        {"gkw_type100_1.weapon",2},
        {"gkw_type100_4004.weapon",2},
        {"gkw_sp9.weapon",2},
        {"gkw_vector.weapon",2},
        {"gkw_pm06.weapon",2},
        {"gkw_pp90.weapon",2},
        {"gkw_js9.weapon",2},
        {"gkw_js9_4702.weapon",2},
        {"gkw_thompson.weapon",2},
        {"gkw_uzi.weapon",2},
        {"gkw_uzimod3.weapon",2},
        {"gkw_uzimod3_skill.weapon",2},
        {"gkw_vz61.weapon",2},
        {"gkw_pp19.weapon",2},
        {"gkw_pp19mod3.weapon",2},
        {"gkw_mab38.weapon",2},
        {"gkw_mab38mod3.weapon",2},
        {"gkw_klin.weapon",2},
        {"gkw_mp40.weapon",2},
        {"gkw_mp5.weapon",2},
        {"gkw_mp5mod3.weapon",2},
        {"gkw_mp5_3.weapon",2},
        {"gkw_mp5_1205.weapon",2},
        {"gkw_mp5_1903.weapon",2},
        {"gkw_mp5_3006.weapon",2},
        {"gkw_mp5mod3_3.weapon",2},
        {"gkw_mp5mod3_1205.weapon",2},
        {"gkw_mp5mod3_1903.weapon",2},
        {"gkw_mp5mod3_3006.weapon",2},
        {"ff_ripper.weapon",2},
        {"ff_ripper_swap.weapon",2},
        {"gkw_sterling.weapon",2},
        
        // SMG——3kills
        {"gkw_ppsh41.weapon",3},
        {"gkw_ppsh41mod3.weapon",3},
        {"gkw_mp7.weapon",3},
        {"gkw_mp7_6806.weapon",3},
        {"gkw_ak74u.weapon",3},
        {"gkw_ak74u_3002.weapon",3},
        {"gkw_idw.weapon",3},
        {"gkw_idw_2108.weapon",3},
        {"gkw_idw_3205.weapon",3},
        {"gkw_idw_4908.weapon",3},
        {"gkw_idwmod3.weapon",3},
        {"gkw_idwmod3_2108.weapon",3},
        {"gkw_idwmod3_3205.weapon",3},
        {"gkw_idwmod3_4908.weapon",3},
        {"gkw_64type.weapon",3},
        {"gkw_g36c.weapon",3},
        {"gkw_g36c_mod3.weapon",3},
        {"gkw_g36c_mod3_skill.weapon",3},
        {"gkw_kp31.weapon",3},
        {"gkw_kp31mod3.weapon",3},
        {"gkw_type79.weapon",3},
        {"gkw_ro635.weapon",3},
        {"gkw_ro635mod3.weapon",3},
        {"gkw_honeybadger.weapon",3},
        {"gkw_honeybadger_4005.weapon",3},
        {"gkw_p90.weapon",3},
        {"gkw_p90_2802.weapon",3},
        {"gkw_x95.weapon",3},
        {"gkw_augpara.weapon",3},
        {"gkw_augpara_5503.weapon",3},
        {"gkw_ar57.weapon",3},
        {"gkw_cms.weapon",3},
        {"gkw_cms_aps.weapon",3},
        {"gkw_cms_st.weapon",3},
        {"gkw_sr3mp.weapon",3},
        {"gkw_sr3mp_skill.weapon",3},
        {"gkw_vp1915.weapon",3}
    };

    protected void updateHealByKillEvent(int characterid,int factionid,int killstoheal,int timeaddafterkill){
        uint jud=0;
        for(uint a=0;a<HealOnKill_track.length();a++)
            if(HealOnKill_track[a].m_characterId==characterid){
                HealOnKill_track[a].current_kills++;
                HealOnKill_track[a].m_numtime = timeaddafterkill;
                jud = 1;
                break;
            }
        if(jud==0)HealOnKill_track.insertLast(HealOnKill_tracker(characterid,factionid,killstoheal,timeaddafterkill)); 
    }

	protected void handleCharacterKillEvent(const XmlElement@ event){
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        if (killer.getIntAttribute("player_id") == -1) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if ((killer.getIntAttribute("faction_id")) != (target.getIntAttribute("faction_id"))){
            int targetId = target.getIntAttribute("id");
            int factionId = killer.getIntAttribute("faction_id");
            int characterId = killer.getIntAttribute("id");
            string Solider_Name = target.getStringAttribute("soldier_group_name");
            string KillerWeaponKey = event.getStringAttribute("key");
            string killway= event.getStringAttribute("method_hint");

            if(KillerWeaponKey=="gkw_ppkmod3.weapon"){
                // 乌鸦是猪，望周知
                int i = findSkillIndex(characterId,"PPKMOD3");
                if(i >=0){
                    SkillArray[i].m_time-=2.0;
                }    
                if (killway=="hit"){
                    int j = findKillCountIndex(characterId);
                    if(j>=0){
                        KillCountArray[j].add();
                        //_log("PPK kill " + KillCountArray[j].m_killnum);
                    }
                    else{
                        KillCountArray.insertLast(kill_count(characterId,1));
                    }
                }    
            }

            if(killway=="stab"){
                KillerWeaponKey = getDeadPlayerEquipmentKey(m_metagame,characterId,0);
            }

            switch(int(healOnKillWeaponList[KillerWeaponKey]))
            {
                case 0:{break;}
                case 1:{updateHealByKillEvent(characterId,factionId,1,10);break;}
                case 2:{updateHealByKillEvent(characterId,factionId,2,10);break;}
                case 3:{updateHealByKillEvent(characterId,factionId,3,10);break;}

                default:
                    break;
            }
 

            if (Solider_Name=="") return;

            int GivenRP = getRPKillReward(Solider_Name);
            float GivenXP = getXPKillReward(Solider_Name);
            GiveRP(m_metagame,characterId,GivenRP);
            GiveXP(m_metagame,characterId,GivenXP);
        }
	}
    protected void handlePlayerDieEvent(const XmlElement@ event){
        if(KillCountArray.size()<=0) return;
        int cId= event.getIntAttribute("character_id");
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
						string c = 
							"<command class='update_inventory'" +
							" untransform_count='"+ vestrestore +"'" +
							" character_id='" + HealOnKill_track[a].m_characterId + "' />";
						m_metagame.getComms().send(c);
                        // if(vestrestore>0)   _log("Heal successful.");  
                        // else    _log("Heal failed.");  
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
	HealOnKill_tracker(int characterId,int factionid,int killstoheal,int timeaddafterkill)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_killstoheal= killstoheal;
        current_kills++;
        m_numtime= timeaddafterkill/0.2;
	}
}

class kill_count{
    int m_characterId;
    int m_killnum=0;
    kill_count(int a,int b){
        m_characterId=a;
        m_killnum=b;
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

int findKillCountIndex(int cId){
    for (uint i=0;i<KillCountArray.length();i++){
        if (KillCountArray[i].m_characterId==cId) {
            return i;
        }
    }
    return -1;
}