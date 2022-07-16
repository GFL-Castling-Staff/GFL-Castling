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
class AN94killnum{
    int m_characterId;
    int m_time;
    AN94killnum(int characterId,int time)
	{
		m_characterId = characterId;
		m_time = time;
	}
}

class kill_skill : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	kill_skill(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected array<AN94killnum@> killnum94;

	protected void handleCharacterKillEvent(const XmlElement@ event){
        //_log("114514testinglog");
		const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if (killer.getIntAttribute("player_id") == -1) return;
        if ((killer.getIntAttribute("faction_id")) != (target.getIntAttribute("faction_id"))){
            int targetId = target.getIntAttribute("id");
            const XmlElement@ targetCharacter = getCharacterInfo2(m_metagame,targetId);
        	if (targetCharacter is null) return;
            int characterId = killer.getIntAttribute("id");
            string charKey = getPlayerEquipmentKey(m_metagame,characterId,0);
            string killMethod = event.getStringAttribute("method_hint");
            Vector3 pos_94 = stringToVector3(event.getStringAttribute("position"));
            //AN94技能
            if(charKey=="gkw_an94_mod3.weapon"||charKey=="gkw_an94_mod3_skill.weapon"){
                if(killMethod!="hit") return;
                an94skill(characterId,pos_94);
            }
        }
	}

    protected void an94skill(int cId, Vector3 an94_pos){
        bool ExistQueue = false;
        int j;
        for (i=0;i<killnum94.length(),i++){
            if(killnum94[i].m_character_id==cId){
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            killnum94[j].m_time++;
            if (killnum94[j].m_time % 5==0){
				int factionid = character.getIntAttribute("faction_id");
				array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, an94_pos, factionid, 20.0f);
				for (uint i = 0; i < characters.length; i++) {
					int soldierId = characters[i].getIntAttribute("id");
					XmlElement c ("command");
					c.setStringAttribute("class", "update_inventory");
					c.setIntAttribute("character_id", soldierId); 
					c.setIntAttribute("untransform_count", 1);
					m_metagame.getComms().send(c);
				}
            }
        }
    }
}