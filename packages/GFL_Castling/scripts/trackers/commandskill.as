// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "generic_call_task.as"
#include "task_sequencer.as"

class SkillInfo{
    int m_character_id;
    float cdr_time;
    float m_time;
    SkillTrigger(int characterId, float time){
        m_character_id=characterId;
        m_time=time;
    }
}

class CommandSkill : Tracker {
    protected Metagame@ m_metagame;
    
	protected array<SkillInfo@> SkillInfoArray;

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

        if (checkCommand(message,"skill") or checkCommand(message,"s")){
            const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
				int characterId = info.getIntAttribute("character_id");
				const XmlElement@ cinfo = getCharacterInfo2(m_metagame, characterId);
				if (cinfo !is null) {
                    string posStr = info.getStringAttribute("position");
                    array<const XmlElement@>@ equipment = cinfo.getElementsByTagName("item");
                    if (equipment.size() == 0) return;
                    string VestKey = equipment[0].getStringAttribute("key");
                    if(VestKey=="")
                }
        }
    }


}