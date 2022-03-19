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
    string CallType;

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
                    if (CallTaskArray.length()>= 3){
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
                        //_log("Queue+1");
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request trauma team support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
                        //_log("Add Call Task Success");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_mgsg"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()>= 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_mgsg.weapon");
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
                        " instance_key='sg1hg1mg2_landing.vehicle' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,8.0,Faction,target,"mgsg_call"));
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request MG-SG echelon support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_hvy"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()>= 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_hvy.weapon");
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
                        " instance_key='hvy_landing.vehicle' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,8.0,Faction,target,"hvy_call"));
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request HVY echelon support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_repair"){
            //_log("getEventFc");
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()>= 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","repair_fairy.weapon");
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
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='repair_fairy.projectile'" +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        //m_metagame.getComms().send(c);
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,3.0,Faction,target,"repair_call"));
                        //_log("Queue+1");
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request Barrier Fairy");
                        sendFactionMessageKey(m_metagame,Faction,"Armor Fortification in progress");
                        //_log("Add Call Task Success");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_rescue"){
            //_log("getEventFc");
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()>= 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","rescue_fairy.weapon");
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
                        " instance_class='grenade'" +
                        " instance_key='medical_agl_call.projectile' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        //m_metagame.getComms().send(c);
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,3.0,Faction,target,"rescue_call"));
                        //_log("Queue+1");
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request Rescue Fairy support!");
                        sendFactionMessageKey(m_metagame,Faction,"Nano repair capsules in progress");
                        //_log("Add Call Task Success");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_target"){
            //_log("getEventFc");
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int playerId = character.getIntAttribute("player_id");
                const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if(player !is null){
                    if (CallTaskArray.length()>= 3){
                        sendPrivateMessageKey(m_metagame,playerId,"Fairy Command System is overload, please try again later.");
                        addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_medic.weapon");
                        return;
                    }
                    if (player.hasAttribute("aim_target")) {
                        Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
                        Vector3 height = Vector3(0,0,0);
                        target = target.add(height);
                        string Callposition = target.toString();
                        int Faction= character.getIntAttribute("faction_id");
                        string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ Faction +"'" +
                        " instance_class='soldier'" +
                        " instance_key='GK_target' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        //m_metagame.getComms().send(c);
                        CallTaskArray.insertLast(ManualCallTask(characterId,c,5.0,Faction,target,"target_call"));
                        //_log("Queue+1");
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request Targetdrone!");
                        sendFactionMessageKey(m_metagame,Faction,"Targetdrone,Unlock!");
                        //_log("Add Call Task Success");
                    }
                }
            }
        }
    }

    void update(float time) {
		if(CallTaskArray.length()>0)
		{
			CallTaskArray[0].m_time -= time;
			if(CallTaskArray[0].m_time < 0.0)
			{
                if(CallTaskArray[0].CallType=="medic_call" || CallTaskArray[0].CallType=="mgsg_call" || CallTaskArray[0].CallType=="hvy_call"){
                    playSoundAtLocation(m_metagame,"osprey.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,7.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Echelon enter the battlefield");
                }
                if(CallTaskArray[0].CallType=="target_call"){
                    playSoundAtLocation(m_metagame,"hello.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,3.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Targetdrone,Unlock!");
                }
                if(CallTaskArray[0].CallType=="rescue_call" || CallTaskArray[0].CallType=="repair_call"){
                    playSoundAtLocation(m_metagame,"woosh1.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,3.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Confirm, data reception is normal");
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