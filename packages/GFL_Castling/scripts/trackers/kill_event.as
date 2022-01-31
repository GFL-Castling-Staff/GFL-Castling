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

	// --------------------------------------------
	kill_event(Metagame@ metagame) {
		@m_metagame = @metagame;
        //rpScale = rp_multiplier;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
	}

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
        "parw_doppelsoldner_mg.weapon",
        "parw_doppelsoldner_rocket",
        "parw_nimogen.weapon",
        "parw_narciss.weapon",
        "sfw_ripper_swap.weapon",
        "sfw_striker_swap.weapon",
        "sfw_jaeger_swap.weapon",
        "sfw_vespid_swap.weapon",
        "sfw_dragoon.weapon",
        "kccow_cerynitis.weapon",
        "sfw_nemeum.weapon"
	};

	protected void handleCharacterKillEvent(const XmlElement@ event){
        //_log("114514testinglog");
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if (killer.getIntAttribute("player_id") == -1) return;
        if ((killer.getIntAttribute("faction_id")) != (target.getIntAttribute("faction_id"))){
            int targetId = target.getIntAttribute("id");
            int characterId = killer.getIntAttribute("id");
            string VestKey = getDeadPlayerEquipmentKey(m_metagame,targetId,0);
            if (VestKey=="") return;
            if(targetVestKey.find(VestKey)> -1){
                if(VestKey=="parw_teal.weapon" || VestKey=="sfw_agent.weapon" || VestKey=="sfw_m16a1.weapon"){
                    GiveRP(m_metagame,characterId,150);
                    return;
                }
                
                if(VestKey=="sfw_manticore.weapon" || VestKey=="kccow_hydra.weapon" || VestKey=="kcco_teslatrooper.weapon"){
                    GiveRP(m_metagame,characterId,80);
                    //_log("giveitmoney");
                    return;
                }
                if(VestKey=="parw_doppelsoldner_rocket.weapon"){
                    GiveRP(m_metagame,characterId,70);
                    //_log("giveitmoney");
                    return;
                }
                if(VestKey=="sfw_ripper_swap.weapon" || VestKey=="sfw_striker_swap.weapon" || VestKey=="sfw_jaeger_swap.weapon" || VestKey=="sfw_vespid_swap.weapon"){
                    GiveRP(m_metagame,characterId,18);
                    //_log("giveitmoney");
                    return;
                }
                if(VestKey=="sfw_dragoon.weapon" || VestKey=="kccow_cerynitis.weapon" || VestKey=="sfw_nemeum.weapon"){
                    GiveRP(m_metagame,characterId,30);
                    //_log("giveitmoney");
                    return;
                }
                else{
                    GiveRP(m_metagame,characterId,50);
                    //_log("giveitmoney");
                    return;
                }
            }
        }
	}
}