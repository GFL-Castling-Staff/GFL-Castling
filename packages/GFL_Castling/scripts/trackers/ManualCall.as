#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "call_marker_tracker.as"
//Author: NetherCrow

class ManualCallTask{
    int m_characterId;
	float m_time;
    string Callkey;
    int m_factions;
    Vector3 m_pos;
    string CallType;
    int m_callId;
	int m_atlasIndex=0;
	float m_size=2.0;
	float m_range=1.0;
    string m_typeKey;

    ManualCallTask(int characterId,string command,float time,int faction,Vector3 position,string callType)
	{
		m_characterId = characterId;
		m_time = time;
        m_factions =faction;
        m_pos = position;
		Callkey = command;
        CallType = callType;
	}

    void setIndex(int key){
        m_atlasIndex=key;
    }
    void setSize(float key){
        m_size=key;
    }
    void setRange(float key){
        m_range=key;
    }
    void setIconTypeKey(string key){
        m_typeKey=key;
    }
    void setDummyId(int key){
        m_callId=key;
    }
}

class ManualCall : Tracker {
	protected GameMode@ m_metagame;
    protected int m_DummyCallID=0;
	// --------------------------------------------
	ManualCall(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

    protected array<ManualCallTask@> CallTaskArray;

    //Author: NetherCrow
    //妖精指令
    protected void handleResultEvent(const XmlElement@ event) {
        string EventKeyGet = event.getStringAttribute("key");	
        if(EventKeyGet == "fc_medic"){
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
                        " instance_key='osprey_enter' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,8.0,Faction,target,"medic_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(4);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);
                        // _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request trauma team support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
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
                        " instance_key='osprey_enter' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,8.0,Faction,target,"mgsg_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(8);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);                        
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
                        " instance_key='osprey_enter' " +
                        " character_id='" + characterId +"'" +
                        " position='" + target.toString() + "' />";
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,8.0,Faction,target,"hvy_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(8);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);                   
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request HVY echelon support!");
                        sendFactionMessageKey(m_metagame,Faction,"Receive, transport aircraft is maneuvering");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_repair"){
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
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,3.0,Faction,target,"repair_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(12);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);                   
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request Barrier Fairy");
                        sendFactionMessageKey(m_metagame,Faction,"Armor Fortification in progress");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_rescue"){
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
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,3.0,Faction,target,"rescue_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(7);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Request Rescue Fairy support!");
                        sendFactionMessageKey(m_metagame,Faction,"Nano repair capsules in progress");
                    }
                }
            }
        }
        if(EventKeyGet == "fc_target"){
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
                        ManualCallTask@ FairyRequest = ManualCallTask(characterId,c,5.0,Faction,target,"target_call");
                        FairyRequest.setIconTypeKey("call_marker_drop");
                        FairyRequest.setIndex(8);
                        FairyRequest.setSize(0.5);
                        FairyRequest.setDummyId(m_DummyCallID);
                        m_DummyCallID++;                        
                        CallTaskArray.insertLast(FairyRequest);
                        addCastlingMarker(FairyRequest);
                        _log("QueueLegeth:"+CallTaskArray.length());
                        sendFactionMessageKey(m_metagame,Faction,"Provocation Fairy");
                        sendFactionMessageKey(m_metagame,Faction,"Targetdrone,Unlock!");
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
                if(CallTaskArray[0].CallType=="medic_call"){
                    playSoundAtLocation(m_metagame,"osprey.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,7.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    removeCastlingMarker(CallTaskArray[0]);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Echelon enter the battlefield");
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    array<Spawn_request@> spawn_soldier =
                    {
                        Spawn_request("Task_Medic",6)
                    };
                    tasker.add(DelaySpawnSoldier(m_metagame,6.0,CallTaskArray[0].m_factions,spawn_soldier,CallTaskArray[0].m_pos.add(Vector3(0,-50,0)),3.0,3.0));
                }

                if(CallTaskArray[0].CallType=="mgsg_call"){
                    playSoundAtLocation(m_metagame,"osprey.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,7.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    removeCastlingMarker(CallTaskArray[0]);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Echelon enter the battlefield");
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    array<Spawn_request@> spawn_soldier =
                    {
                        Spawn_request("Task_MG",3),
                        Spawn_request("Task_SG",2)
                    };
                    tasker.add(DelaySpawnSoldier(m_metagame,6.0,CallTaskArray[0].m_factions,spawn_soldier,CallTaskArray[0].m_pos.add(Vector3(0,-50,0)),3.0,3.0));
                }

                if(CallTaskArray[0].CallType=="hvy_call"){
                    playSoundAtLocation(m_metagame,"osprey.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,7.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    removeCastlingMarker(CallTaskArray[0]);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Echelon enter the battlefield");
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    array<Spawn_request@> spawn_soldier =
                    {
                        Spawn_request("default_hvy",6)
                    };
                    tasker.add(DelaySpawnSoldier(m_metagame,6.0,CallTaskArray[0].m_factions,spawn_soldier,CallTaskArray[0].m_pos.add(Vector3(0,-50,0)),3.0,3.0));
                }

                if(CallTaskArray[0].CallType=="target_call"){
                    playSoundAtLocation(m_metagame,"hello.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,3.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    removeCastlingMarker(CallTaskArray[0]);
                    sendFactionMessageKey(m_metagame,CallTaskArray[0].m_factions,"Targetdrone,Unlock!");
                }
                if(CallTaskArray[0].CallType=="rescue_call" || CallTaskArray[0].CallType=="repair_call"){
                    playSoundAtLocation(m_metagame,"woosh1.wav",CallTaskArray[0].m_factions,CallTaskArray[0].m_pos,3.0f);
                    m_metagame.getComms().send(CallTaskArray[0].Callkey);
                    removeCastlingMarker(CallTaskArray[0]);
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

    protected void addCastlingMarker(ManualCallTask@ info){
        int flagId = info.m_callId + 114514;
        XmlElement command("command");
            command.setStringAttribute("class", "set_marker");
            command.setIntAttribute("id", flagId);
            command.setIntAttribute("faction_id", info.m_factions);
            command.setIntAttribute("atlas_index", info.m_atlasIndex);
            command.setFloatAttribute("size", info.m_size);
            command.setFloatAttribute("range", info.m_range);
            command.setIntAttribute("enabled", 1);
            command.setStringAttribute("position", info.m_pos.toString());
            command.setStringAttribute("text", "");
            command.setStringAttribute("type_key", info.m_typeKey);
            command.setBoolAttribute("show_in_map_view", true);
            command.setBoolAttribute("show_in_game_view", true);
            command.setBoolAttribute("show_at_screen_edge", false);
        m_metagame.getComms().send(command);
    }

    protected void removeCastlingMarker(ManualCallTask@ info){
        int flagId = info.m_callId + 114514;
        XmlElement command("command");
            command.setStringAttribute("class", "set_marker");
            command.setIntAttribute("id", flagId);
            command.setIntAttribute("faction_id", info.m_factions);
            command.setIntAttribute("enabled", 0);
        m_metagame.getComms().send(command);
    }
}

