#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

class ManualCallTask{
    int m_characterId;
	float m_time;
    string Callkey;
    int m_factions;
    Vector3 m_pos;

    ManualCallTask(int characterId,string command,float time,int faction,Vector3 position,string callType)
	{
		m_characterId = characterId;
		m_time = time;
        m_factions =faction;
        m_pos = position;
		Callkey = command;
        CallType = callType;
	}
}

class ManualCall : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	ManualCall(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected array<ManualCallTask@> CallTaskArray;

    //Author: NetherCrow
    //妖精指令
    protected void handleResultEvent(const XmlElement@ event) {
        string EventKeyGet = event.getStringAttribute("key");	
        if(EventKeyGet == "fc_medic"){
            //_log("getEventFc");
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()> 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_medic.weapon");
                        return;
                    }
                    if (player.hasAttribute("aim_target")) {
                        Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
                        Vector3 height = Vector3(0,50,0);
                        target = target.add(height);
                        string Callposition = target.toString();
                        int Faction= character.getIntAttribute("faction_id");
                        string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ Faction +"'" +
                        " instance_class='vehicle'" +
                        " instance_key='medic_landing.vehicle' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        //m_metagame.getComms().send(c);
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,8.0,Faction,target,"medic_call"));
                        sendFactionMessageKey(m_metagame,Faction,"Request trauma team support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
                        //_log("Add Call Task Success");
                    }
                }
            }
        }
        // if(EventKeyGet == "fc_medic"){
        //     int characterId = event.getIntAttribute("character_id");
        //     const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        //     if (character !is null) {
        //         int playerId = character.getIntAttribute("player_id");
        //         const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
        //         if (CallTaskArray.length()> 3){
        //             sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
        //             addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_medic.weapon");
        //             return;
        //         }
        //         if(player !is null){
        //             if (player.hasAttribute("aim_target")) {
        //                 Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
        //                 Vector3 height = Vector3(0,50,0);
        //                 target = target.add(height);
        //                 string Callposition = target.toString();
        //                 int Faction= character.getIntAttribute("faction_id");
        //                 string c = 
        //                 "<command class='create_instance'" +
        //                 " faction_id='"+ Faction +"'" +
        //                 " instance_class='vehicle'" +
        //                 " instance_key='medic_landing.vehicle' " +
        //                 " character_id='" + characterId +"'" +
        //                 " position='" + target.toString() + "' />";
        //                 CallTaskArray.insertLast(ManualCallTask(characterId,c,8.0,Faction,target,"medic_call"));
        //                 sendFactionMessageKey(m_metagame,Faction,"Request trauma team support!");
        //                 sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
        //             }
        //         }
        //     }
        // }
    }

    void update(float time) {
		if(CallTaskArray.length()>0)
		{
			CallTaskArray[0].m_time -= time;
			if(CallTaskArray[0].m_time < 0.0)
			{
                if(CallTaskArray[0].CallType="medic_call"){
                    playSoundAtLocation(m_metagame,"osprey.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,7.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Echelon enter the battlefield");
                    //_log("excuteCallnow");
                }

                CallTaskArray.removeAt(0);
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