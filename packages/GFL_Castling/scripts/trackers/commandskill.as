// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"


//02:29:23: SCRIPT:  received: TagName=chat_event channel=global global=1 message=/promote player_id=0 player_name=NETHER_CROW 
//02:29:23: SCRIPT:  received: TagName=query_result query_id=18     TagName=player aim_target=154.627 19.7851 688.99 character_id=174 color=0.68 0.85 0 1 faction_id=0 name=NETHER_CROW player_id=0 profile_hash=ID3580998501 sid=ID0 
class SkillTrigger{
    int m_character_id;
    float m_time;
    string m_weapontype;
    SkillTrigger(int characterId, float time,string weapontype){
        m_character_id=characterId;
        m_time=time;
        m_weapontype=weapontype;
    }
}

class CommandSkill : Tracker {
    protected Metagame@ m_metagame;
    
	protected array<SkillTrigger@> SkillArray;

	// --------------------------------------------
	CommandSkill(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handleChatEvent(const XmlElement@ event) {
        string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first 
		if (!startsWith(message, "/")) {
			return;
		}

        string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

        if (checkCommand(message,"skill") || message=="/s"){
            const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
                int cId = info.getIntAttribute("character_id");
                string c_weaponType = getPlayerEquipmentKey(m_metagame,cId,0);
                if (c_weaponType=="") return;
                if (c_weaponType=="gkw_an94_mod3.weapon" || c_weaponType=="gkw_an94_mod3_skill.weapon"){
                    excuteAN94skill(cId,senderId);
                }
                if (c_weaponType=="gkw_vector.weapon"){
                    excuteVVskill(cId,senderId);
                }
            }
        }
    }


    void update(float time) {
        if(SkillArray.length()>0)
		{
            for (int a=0;a<SkillArray.length();a++){
                SkillArray[a].m_time-=time;
                if(SkillArray[a].m_time<0){
                    SkillArray.removeAt(a);
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

    void excuteAN94skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (int i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="AN94") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,180,"AN94"));
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        string soldierClass = info.getStringAttribute("soldier_group_name");
            XmlElement command("command");
            command.setStringAttribute("class", "create_instance");
            command.setIntAttribute("faction_id", info.getIntAttribute("faction_id"));
            command.setStringAttribute("instance_class", "character");
            command.setStringAttribute("instance_key","206_ak12_ar_defyAI");
            command.setStringAttribute("position",info.getStringAttribute("position"));
            m_metagame.getComms().send(command);    
        sendPrivateMessage(m_metagame,playerId,"Defy AK-12 summoned");
        _log("summonAK12");
    }
    void excuteVVskill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (int i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="VECTOR") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,20,"VECTOR"));
        if(getPlayerEquipmentKey(m_metagame,characterId,2)==""){
            editPlayerNade(m_metagame,characterId,"VVfirenade.projectile",2);
        }
        else{
            addItemInBackpack(m_metagame,characterId,"projectile","VVfirenade.projectile");
        }
        sendPrivateMessage(m_metagame,playerId,"Firenade Added");

    }
}

