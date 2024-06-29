#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "call_marker_tracker.as"
//Author: NetherCrow

class fairyCommand : Tracker {
	protected GameMode@ m_metagame;
    protected TaskSequencer@ m_taskQueue = @metagame.getCallSequencer();
    protected int m_DummyCallID = 50000;

	// --------------------------------------------
	fairyCommand(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handleResultEvent(const XmlElement@ event) {
        string EventKeyGet = event.getStringAttribute("key");	
        if(EventKeyGet == "fc_medic"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_attack")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_attack");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_medic.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_medic.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(4);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_medic",target,FairyRequest));
            sendFactionMessageKey(m_metagame,factionId,"Request trauma team support!");
            sendFactionMessageKey(m_metagame,factionId,"Receive, transport aircraft is maneuvering");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_attack"));
        }        
        if(EventKeyGet == "fc_mgsg"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_defend")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_defend");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_mgsg.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_mgsg.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(8);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_mgsg",target,FairyRequest));
            sendFactionMessageKey(m_metagame,factionId,"Request MG-SG echelon support!");
            sendFactionMessageKey(m_metagame,factionId,"Receive, transport aircraft is maneuvering");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_defend"));
        }     
        if(EventKeyGet == "fc_hvy"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_defend")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_defend");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_hvy.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_hvy.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(8);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_hvy",target,FairyRequest));
            sendFactionMessageKey(m_metagame,factionId,"Request HVY echelon support!");
            sendFactionMessageKey(m_metagame,factionId,"Receive, transport aircraft is maneuvering");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_defend"));
        }
        if(EventKeyGet == "fc_target"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_support")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_support");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"projectile","fairy_command_target.projectile");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"projectile","fairy_command_target.projectile");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(8);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_target",target,FairyRequest));
            sendFactionMessageKey(m_metagame,factionId,"Provocation Fairy");
            sendFactionMessageKey(m_metagame,factionId,"Targetdrone,Unlock!");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_support"));
        }     
        if(EventKeyGet == "fc_mine"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_support")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_support");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"projectile","fairy_command_mine.projectile");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"projectile","fairy_command_mine.projectile");
                return;
            }
            Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));
            Vector3 aim_pos = stringToVector3(player.getStringAttribute("aim_target"));
            int factionid = character.getIntAttribute("faction_id");
            m_taskQueue.add(DelayCommonCallRequest(m_metagame,3,characterId,factionid,"mine_strafe",aimer_pos,aim_pos));
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_support"));
        }         
        if(EventKeyGet == "fc_antirain"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_attack")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_attack");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_antirain.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_antirain.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(4);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_antirain",target,FairyRequest,characterId));
            sendFactionMessageKey(m_metagame,factionId,"Request trauma team support!");
            sendFactionMessageKey(m_metagame,factionId,"Receive, transport aircraft is maneuvering");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_attack"));
        }   
        if(EventKeyGet == "fc_negev"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_defend")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_defend");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_negev.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_negev.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            Vector3 height = Vector3(0,50,0);
            target = target.add(height);
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(4);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,5,factionId,"fc_negev",target,FairyRequest,characterId));
            sendFactionMessageKey(m_metagame,factionId,"Request trauma team support!");
            sendFactionMessageKey(m_metagame,factionId,"Receive, transport aircraft is maneuvering");
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"fc_defend"));
        }   
        if(EventKeyGet == "fc_daybreak"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character is null) return;
            int playerId = character.getIntAttribute("player_id");
            int factionId= character.getIntAttribute("faction_id");
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player is null) return;
            if (!player.hasAttribute("aim_target")) return;
            string playerName = player.getStringAttribute("name");
            if(findCooldown(playerName,"fc_attack")){
                dictionary a;
                a["%time"] = ""+getCooldown(playerName,"fc_attack");                        
                notify(m_metagame, "fairycommand_cooldown",a, "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_antirain.weapon");
                return;
            }            
            if (m_taskQueue.getSize() >= 3){
                notify(m_metagame, "fairycommand_overload",dictionary(), "misc", playerId, false, "", 1.0);
                addItemInBackpack(m_metagame,characterId,"weapon","reinforcement_fairy_antirain.weapon");
                return;
            }
            Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,target);
            FairyRequest.setIconTypeKey("call_marker_drop");
            FairyRequest.setIndex(4);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(m_DummyCallID);
            m_DummyCallID++;                        
            addCastlingMarker(FairyRequest);
            m_taskQueue.add(DelayFairyCommand(m_metagame,0.5,factionId,"fc_daybreak",target,FairyRequest,characterId));
            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,240.0,"fc_attack"));
        }                         
    }    

    bool hasEnded() const {
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}

    protected void addCastlingMarker(CastlingMarker@ info){
        XmlElement command("command");
            command.setStringAttribute("class", "set_marker");
            command.setIntAttribute("id", info.m_callId);
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


    
}

class CastlingMarker{
    int m_characterId;
    int m_factions;
    Vector3 m_pos;
    int m_callId;
	int m_atlasIndex=0;
	float m_size=2.0;
	float m_range=1.0;
    string m_typeKey = "";
    string m_displaytext ="";

    CastlingMarker(int characterId,int faction,Vector3 position)
	{
		m_characterId = characterId;
        m_factions =faction;
        m_pos = position;
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
    void setDisplayText(string key){
        m_displaytext = key;
    }
}

void removeMarker(GameMode@ m_metagame,CastlingMarker@ info){
    XmlElement command("command");
        command.setStringAttribute("class", "set_marker");
        command.setIntAttribute("id", info.m_callId);
        command.setIntAttribute("faction_id", info.m_factions);
        command.setIntAttribute("enabled", 0);
    m_metagame.getComms().send(command);
}

void removeMarkerwithId(GameMode@ m_metagame,int faction_id,int callId){
    XmlElement command("command");
        command.setStringAttribute("class", "set_marker");
        command.setIntAttribute("id", callId);
        command.setIntAttribute("faction_id", faction_id);
        command.setIntAttribute("enabled", 0);
    m_metagame.getComms().send(command);
}

class DelayFairyCommand : Task {
    protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_factionId;
    protected int m_characterId;
	protected float m_timeLeft;
	protected string m_spawnkey;
	protected Vector3 m_pos;
    protected CastlingMarker@ m_info;

	DelayFairyCommand(GameMode@ metagame, float time,int fId,string spawn_key,Vector3 pos,CastlingMarker@ info,int cId=-1) {
		@m_metagame = metagame;
        @m_info = info;
		m_time = time;
		m_factionId =fId;
		m_pos= pos;
		m_spawnkey = spawn_key;
        m_characterId = cId;
	}

    void start() {
		m_timeLeft=m_time;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            removeMarker(m_metagame,m_info);
            if(m_spawnkey == "fc_medic"){
                playSoundAtLocation(m_metagame,"osprey.wav",m_factionId,m_pos,7.0f);
                spawnVehicle(m_metagame,1,m_factionId,m_pos,Orientation(0,1,0,0.1),"osprey_enter");
                sendFactionMessageKey(m_metagame,m_factionId,"Echelon enter the battlefield");
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("Task_Medic",6)
                };
                tasker.add(DelaySpawnSoldier(m_metagame,6.0,m_factionId,spawn_soldier,m_pos.add(Vector3(0,-50,0)),3.0,3.0));
            }
            if(m_spawnkey == "fc_mgsg"){
                playSoundAtLocation(m_metagame,"osprey.wav",m_factionId,m_pos,7.0f);
                spawnVehicle(m_metagame,1,m_factionId,m_pos,Orientation(0,1,0,0.1),"osprey_enter");
                sendFactionMessageKey(m_metagame,m_factionId,"Echelon enter the battlefield");
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("Task_MG",4),
                    soldier_spawn_request("Task_SG",2)
                };
                tasker.add(DelaySpawnSoldier(m_metagame,6.0,m_factionId,spawn_soldier,m_pos.add(Vector3(0,-50,0)),3.0,3.0));
            }
            if(m_spawnkey == "fc_hvy"){
                playSoundAtLocation(m_metagame,"osprey.wav",m_factionId,m_pos,7.0f);
                spawnVehicle(m_metagame,1,m_factionId,m_pos,Orientation(0,1,0,0.1),"osprey_enter");
                sendFactionMessageKey(m_metagame,m_factionId,"Echelon enter the battlefield");
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("default_hvy",6)
                };
                tasker.add(DelaySpawnSoldier(m_metagame,6.0,m_factionId,spawn_soldier,m_pos.add(Vector3(0,-50,0)),3.0,3.0));
            }
            if(m_spawnkey == "fc_target"){
                playSoundAtLocation(m_metagame,"hello.wav",m_factionId,m_pos,3.0f);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("GK_target",3)
                };
                tasker.add(DelaySpawnSoldier(m_metagame,3.0,m_factionId,spawn_soldier,m_pos,3.0,3.0));
                sendFactionMessageKey(m_metagame,m_factionId,"Targetdrone,Unlock!");
            }
            if(m_spawnkey == "fc_antirain"){
                playSoundAtLocation(m_metagame,"osprey.wav",m_factionId,m_pos,7.0f);
                spawnVehicle(m_metagame,1,m_factionId,m_pos,Orientation(0,1,0,0.1),"osprey_enter");
                spawnStaticProjectile(m_metagame,"cluster_bomb.projectile",m_pos.add(Vector3(0,-20,0)),m_characterId,m_factionId);
                sendFactionMessageKey(m_metagame,m_factionId,"Echelon enter the battlefield");
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(DelayProjectileSet(m_metagame,3.0,m_characterId,m_factionId,"cluster_bomb.projectile",m_pos.add(Vector3(0,-20,0))));
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("ar_57_ar15mod3",1),
                    soldier_spawn_request("ar_56_m4sop2mod3",1),
                    soldier_spawn_request("ar_55_m4a1mod3",1),
                    soldier_spawn_request("ar_54_m16a1",1)
                };
                tasker.add(DelaySpawnSoldier(m_metagame,4.0,m_factionId,spawn_soldier,m_pos.add(Vector3(0,-50,0)),3.0,3.0));
            }
            if(m_spawnkey == "fc_negev"){
                playSoundAtLocation(m_metagame,"osprey.wav",m_factionId,m_pos,7.0f);
                spawnVehicle(m_metagame,1,m_factionId,m_pos,Orientation(0,1,0,0.1),"osprey_enter");
                sendFactionMessageKey(m_metagame,m_factionId,"Echelon enter the battlefield");
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                TaskSequencer@ tasker2 = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(Airdrop_Support_Negev(m_metagame,2.0,m_characterId,m_factionId,m_pos));
                array<soldier_spawn_request@> spawn_soldier =   
                {
                    soldier_spawn_request("mg_112_negev",1),
                    soldier_spawn_request("ar_71_galil",1),
                    soldier_spawn_request("ar_72_tar21",1),
                    soldier_spawn_request("smg_32_uzi",1),
                    soldier_spawn_request("hg_248_jericho",1),
                    soldier_spawn_request("Task_MG",3)
                };
                tasker2.add(DelaySpawnSoldier(m_metagame,4.0,m_factionId,spawn_soldier,m_pos.add(Vector3(0,-50,0)),3.0,3.0));
            }
            if(m_spawnkey == "fc_daybreak"){
                playSoundAtLocation(m_metagame,"airstrike_flyby.wav",m_factionId,m_pos,1.5f);
                createCallatPos(m_metagame,m_characterId,m_factionId,"gk_daybreak.call",m_pos);
            }            
		}

	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}