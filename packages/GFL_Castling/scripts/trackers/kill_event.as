#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
//Originally created by NetherCrow
//11:39:11: SCRIPT:  received: TagName=character_kill key= method_hint=stab     
//TagName=killer block=12 14 dead=0 faction_id=0 id=11 leader=1 name=Nikita Sokol player_id=0 position=428.551 4.3014 499.254 rp=60 soldier_group_name=default squad_size=0 wounded=0 xp=0   
//TagName=target block=12 14 dead=0 faction_id=1 id=9 leader=1 name=Uwe Neururer player_id=-1 position=428.102 4.30089 498.737 rp=0 soldier_group_name=default_ai squad_size=2 wounded=0 xp=0 
// --------------------------------------------
class kill_event : Tracker {
	protected Metagame@ m_metagame;
    protected array<HealOnBladeKill_tracker@> HealOnBladeKill_track;

	// --------------------------------------------
	kill_event(Metagame@ metagame) {
		@m_metagame = @metagame;
        //rpScale = rp_multiplier;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}
	array<string> killerVestKey = {
        "ff_excutioner_2.weapon",
        "ff_parw_alina.weapon"
	};

	array<string> targetVestKey = {
		"sfw_manticore.weapon",
		"sfw_architect.weapon",
		"sfw_hunter.weapon",
		"sfw_Intruder.weapon",
		"sfw_dreamer.weapon",
		"sfw_alchemist.weapon",
        "sfw_gager.weapon",
        "sfw_m16a1.weapon",
        "sfw_excutioner_1.weapon",
        "sfw_excutioner_2.weapon",
        "sfw_agent.weapon",
        "sfw_justice.weapon",
        "sfw_scarecrow.weapon",
        "sfw_destroyer.weapon",
        "sfw_weaver.weapon",
        "kccow_hydra.weapon",
        "kcco_teslatrooper.weapon",
        "parw_alina.weapon",
        "parw_teal.weapon",
        "parw_nyto_black.weapon",
        "parw_vanguard.weapon",
        "parw_eagleyes.weapon",
        "parw_doppelsoldner_mg.weapon",
        "parw_doppelsoldner_rocket",
        "parw_nimogen.weapon",
        "parw_narciss.weapon",
        "sfw_ripper_swap.weapon",
        "sfw_striker_swap.weapon",
        "sfw_jaeger_swap.weapon",
        "sfw_vespid_swap.weapon",
        "sfw_dragoon.weapon",
        "sfw_dragoon_swap.weapon",
        "kccow_cerynitis.weapon",
        "sfw_nemeum.weapon"
	};

	protected void handleCharacterKillEvent(const XmlElement@ event){
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if (killer.getIntAttribute("player_id") == -1) return;
        if ((killer.getIntAttribute("faction_id")) != (target.getIntAttribute("faction_id"))){
            int targetId = target.getIntAttribute("id");
            int characterId = killer.getIntAttribute("id");
            string VestKey = getDeadPlayerEquipmentKey(m_metagame,targetId,0);
            string KillerWeaponKey = getDeadPlayerEquipmentKey(m_metagame,characterId,0);

            if((KillerWeaponKey!="") && (killerVestKey.find(KillerWeaponKey)> -1)){
                // _log("Kill_detected.");
                if(KillerWeaponKey=="ff_excutioner_2.weapon"){
                    uint jud=0;
                    for(uint a=0;a<HealOnBladeKill_track.length();a++)
                        if(HealOnBladeKill_track[a].m_characterId==characterId){
                            HealOnBladeKill_track[a].current_kills++;
                            jud = 1;
                            break;
                        }
                    if(jud==0)HealOnBladeKill_track.insertLast(HealOnBladeKill_tracker(characterId,0,3,10));
                    // _log("Excutioner_Kill_detected.");
                }
                if(KillerWeaponKey=="ff_parw_alina.weapon"){
                    uint jud=0;
                    for(uint a=0;a<HealOnBladeKill_track.length();a++)
                        if(HealOnBladeKill_track[a].m_characterId==characterId){
                            HealOnBladeKill_track[a].current_kills++;
                            jud = 1;
                            break;
                        }
                   if(jud==0)HealOnBladeKill_track.insertLast(HealOnBladeKill_tracker(characterId,0,2,10));
                }                
            }      

            if (VestKey=="") return;
            if(targetVestKey.find(VestKey)> -1){
                if(VestKey=="parw_teal.weapon" || VestKey=="sfw_agent.weapon" || VestKey=="sfw_m16a1.weapon"){
                    GiveRP(m_metagame,characterId,150);
                    GiveXP(m_metagame,characterId,0.025);
                    return;
                }
                
                if(VestKey=="sfw_manticore.weapon" || VestKey=="kccow_hydra.weapon" || VestKey=="kcco_teslatrooper.weapon"){
                    GiveRP(m_metagame,characterId,80);
                    GiveXP(m_metagame,characterId,0.005);
                    //_log("giveitmoney");
                    return;
                }
                if(VestKey=="parw_doppelsoldner_rocket.weapon"){
                    GiveRP(m_metagame,characterId,70);
                    GiveXP(m_metagame,characterId,0.004);
                    return;
                }
                if(VestKey=="sfw_ripper_swap.weapon" || VestKey=="sfw_striker_swap.weapon" || VestKey=="sfw_jaeger_swap.weapon" || VestKey=="sfw_vespid_swap.weapon"){
                    GiveRP(m_metagame,characterId,18);
                    GiveXP(m_metagame,characterId,0.001);
                    return;
                }
                if(VestKey=="sfw_dragoon.weapon" || VestKey=="kccow_cerynitis.weapon" || VestKey=="sfw_nemeum.weapon"){
                    GiveRP(m_metagame,characterId,30);
                    GiveXP(m_metagame,characterId,0.002);
                    return;
                }
                else{
                    GiveRP(m_metagame,characterId,50);
                    GiveXP(m_metagame,characterId,0.003);
                    return;
                }
            }     
        }
	}

    void update(float time){
        if(HealOnBladeKill_track.length()>0){
            for (uint a=0;a<HealOnBladeKill_track.length();a++){
                HealOnBladeKill_track[a].m_time-=time;
                if(HealOnBladeKill_track[a].m_time<0){	
					if (HealOnBladeKill_track[a].m_numtime>=0){
                        int vestrestore = 0;
                        while(HealOnBladeKill_track[a].current_kills>HealOnBladeKill_track[a].m_killstoheal){
                            vestrestore++;
                            HealOnBladeKill_track[a].current_kills -= HealOnBladeKill_track[a].m_killstoheal;                            
                        }
                        if(HealOnBladeKill_track[a].current_kills<0){
                            HealOnBladeKill_track[a].current_kills = 0;
                        }
						string c = 
							"<command class='update_inventory'" +
							" untransform_count='"+ vestrestore +"'" +
							" character_id='" + HealOnBladeKill_track[a].m_characterId + "' />";
						m_metagame.getComms().send(c);
                        // if(vestrestore>0)   _log("Heal successful.");  
                        // else    _log("Heal failed.");  
					}
					HealOnBladeKill_track[a].m_numtime--;
					HealOnBladeKill_track[a].m_time=0.2;
					if (HealOnBladeKill_track[a].m_numtime<0){
						HealOnBladeKill_track.removeAt(a);
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

class HealOnBladeKill_tracker{
    int m_characterId;
	float m_time=0.2;
	float m_numtime=0;
	int m_factionid;
    int m_killstoheal;
    int current_kills=0;
	HealOnBladeKill_tracker(int characterId,int factionid,int killstoheal,float timeaddafterkill)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_killstoheal= killstoheal;
        current_kills++;
        m_numtime= timeaddafterkill;
	}
}