#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
#include "call_marker_tracker.as"
#include "ManualCall.as"
#include "event_system.as"

dictionary callLaunchIndex = {

    // 暴怒妖精
    {"gk_rampage_fairy_ac130.call",1},

    // 狙击妖精
    {"gk_snipe_fairy.call",2},

    // 增援妖精
    {"gk_yaoren_fairy.call",3},

    // 火箭妖精
    {"gk_rocket_fairy.call",4},

    // 勇士妖精
    {"gk_warrior_fairy.call",5},

    // 炮击妖精
    {"gk_bombardment_fairy.call",6},

    // 立盾妖精
    {"gk_repair_fairy.call",7},

    {"gk_vehicle_pierre.call",8},
    {"gk_vehicle_chiara.call",9},
    {"gk_vehicle_martina.call",10},


    // 空空投
    {"",0}
};

array<string> vehicle_drop_call = {
    "gk_vehicle_pierre.call",
    "gk_vehicle_martina.call",
    "gk_vehicle_chiara.call"
};

//Originally created by NetherCrow
// 11:25:26: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=queue player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:10: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=launch player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:54: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=end player_id=0 target_position=944.656 17.7529 563.095
array<Call_Cooldown@> m_cooldown;

class call_event : Tracker {
	protected Metagame@ m_metagame;
    protected int m_DummyCallID=0;

	call_event(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleCallEvent(const XmlElement@ event) {
        if(event.getIntAttribute("player_id") != -1 ){

            _log("Player Call Detected.");

            string callKey = event.getStringAttribute("call_key");
            string phase = event.getStringAttribute("phase");
            string position = event.getStringAttribute("target_position");
            int callId = event.getIntAttribute("id");
            int characterId = event.getIntAttribute("character_id");
            int factionId = event.getIntAttribute("faction_id");
            int playerId = event.getIntAttribute("player_id");

            const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
            if (playerinfo is null) return;
            string playerName = playerinfo.getStringAttribute("name");

            if (phase == "launch") {
                switch(int(callLaunchIndex[callKey]))
                {
                    case 1:{
                        bool exsist_ac130 = false;
                        for (uint i=0;i<GFL_event_array.length();i++){
                            // mb break? What's the point of running whole array
                            if (GFL_event_array[i].m_eventkey==2) {exsist_ac130=true;break;}
                        }
                        if (exsist_ac130){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                sendPrivateMessageKey(m_metagame,playerId,"ac130callexisthint");
                                GiveRP(m_metagame,characterId,10000);
                            }
                        }
                        else{
                            if(findCooldown(playerName,"ac130")){
                                const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                if (character !is null) {
                                    dictionary a;
                                    a["%time"] = ""+getCooldown(playerName,"ac130");                        
                                    sendPrivateMessageKey(m_metagame,playerId,"ac130cooldown",a);
                                    GiveRP(m_metagame,characterId,10000);
                                }
                            }
                            else {
                                m_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"ac130"));
                                sendFactionMessageKey(m_metagame,factionId,"ac130callstarthint");
                                int flagId = m_DummyCallID + 15000;
                                ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,stringToVector3(position),"foobar");
                                FairyRequest.setIndex(9);
                                FairyRequest.setSize(0.5);
                                FairyRequest.setDummyId(flagId);
                                FairyRequest.setRange(120.0);
                                FairyRequest.setIconTypeKey("call_marker_fury");
                                addCastlingMarker(FairyRequest);
                                m_DummyCallID++;
                                GFL_event@ newCall = GFL_event(characterId,factionId,int(GFL_Event_Index["rampage_fairy_ac130"]),stringToVector3(position),1.0,-1.0,flagId);
                                newCall.setSpeicalKey(rand(1,3));
                                GFL_event_array.insertLast(newCall);
                            }
                        }
                        break;
                    }
                    case 2:{
                        bool exsist = false;
                        int j=-1;
                        for (uint i=0;i<GFL_event_array.length();i++){
                            if (GFL_event_array[i].m_eventkey==1) {exsist=true;j=i;}
                        }
                        if (exsist){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                sendPrivateMessageKey(m_metagame,playerId,"snipecallexisthint");
                                GiveRP(m_metagame,characterId,300);
                            }
                        }
                        else{
                            if(findCooldown(playerName,"sniper_call")){
                                const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                if (character !is null) {
                                    dictionary a;
                                    a["%time"] = ""+getCooldown(playerName,"sniper_call");                        
                                    sendPrivateMessageKey(m_metagame,playerId,"sniper_callcooldown",a);
                                    GiveRP(m_metagame,characterId,300);
                                }
                            }
                            else {
                                m_cooldown.insertLast(Call_Cooldown(playerName,playerId,30.0,"sniper_call"));
                                sendFactionMessageKey(m_metagame,factionId,"snipecallstarthint");
                                int flagId = m_DummyCallID + 15000;
                                ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,stringToVector3(position),"foobar");
                                FairyRequest.setIndex(14);
                                FairyRequest.setSize(0.5);
                                FairyRequest.setDummyId(flagId);
                                FairyRequest.setRange(60.0);
                                FairyRequest.setIconTypeKey("call_marker_snipe");
                                addCastlingMarker(FairyRequest);
                                m_DummyCallID++;
                                GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["sniper_fairy"]),stringToVector3(position),1.0,-1.0,flagId));
                            }
                        }
                        break;
                    }
                    case 3:{
                        bool yaoren_cooldown = false;
                        int j=-1;
                        if(findCooldown(playerName,"yaoren_8")){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                dictionary a;
                                a["%time"] = ""+getCooldown(playerName,"yaoren_8");                        
                                sendPrivateMessageKey(m_metagame,playerId,"callcooldown",a);
                                GiveRP(m_metagame,characterId,500);
                            }
                        }
                        else {
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"yaoren_8"));
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,stringToVector3(position),"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(8);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            addCastlingMarker(FairyRequest);
                            m_DummyCallID++;
                            GFL_event@ newCall = GFL_event(characterId,factionId,int(GFL_Event_Index["mg_strafe"]),stringToVector3(position),1.0,-1.0,flagId);
                            GFL_event_array.insertLast(newCall);
                        }      
                        break;
                    }              
                    case 4:{
                        if(findCooldown(playerName,"TU160")){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                dictionary a;
                                a["%time"] = ""+getCooldown(playerName,"TU160");                        
                                sendPrivateMessageKey(m_metagame,playerId,"rocketcooldown",a);
                                GiveRP(m_metagame,characterId,5000);
                            }
                        }
                        else {
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"TU160"));
                            sendFactionMessageKey(m_metagame,factionId,"rocketcallstarthint");
                            const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
                            Vector3 player_pos = stringToVector3(characterinfo.getStringAttribute("position"));
                            insertCommonStrike(characterId,factionId,int(airstrikeIndex["TU160_bomb_strafe"]),player_pos,stringToVector3(position));
                        }
                        break;
                    }
                    case 5:{
                        if(findCooldown(playerName,"warrior")){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                dictionary a;
                                a["%time"] = ""+getCooldown(playerName,"warrior");                        
                                sendPrivateMessageKey(m_metagame,playerId,"warriorcooldown",a);
                                GiveRP(m_metagame,characterId,1000);
                            }
                        }
                        else{           
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"warrior"));
                            sendFactionMessageKey(m_metagame,factionId,"warriorcallstarthint");
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,stringToVector3(position),"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(6);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            addCastlingMarker(FairyRequest);
                            m_DummyCallID++;
                            GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["warrior_fairy_apache"]),stringToVector3(position),1.0,-1.0,flagId));
                        }
                        break;
                    }
                    case 6:{
                        if(findCooldown(playerName,"bombardment")){
                            returnCooldown("bombardment", 500, characterId, playerName, playerId, "bombcooldown");
                            break;
                        }                        
                        else {
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"bombardment"));
                            playSoundAtLocation(m_metagame,"kcco_dn_1.wav",factionId,position,1.5);
                            sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,stringToVector3(position),"foobar");
                            FairyRequest.setIndex(11);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            FairyRequest.setRange(40.0);
                            FairyRequest.setIconTypeKey("call_marker_bomb");
                            addCastlingMarker(FairyRequest);
                            m_DummyCallID++;
                            GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["bomb_fairy"]),stringToVector3(position),1.0,-1.0,flagId));
                        }
                        break;
                    }    
                    case 7:{
                        if(findCooldown(playerName,"barrier")){
                            returnCooldown("barrier", 300, characterId, playerName, playerId, "barriercooldown");
                            break;
                        }
                        else {
                            Vector3 call_pos = stringToVector3(position);
                            Vector3 v_offset = Vector3(0,40,0);
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"barrier"));
                            sendFactionMessageKey(m_metagame,factionId,"barrierfight");
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,call_pos,"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(12);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                            tasker.add(TimerMarker(m_metagame,3,FairyRequest));
                            m_DummyCallID++;
                            CreateDirectProjectile(m_metagame,call_pos.add(v_offset),call_pos,"repair_fairy.projectile",characterId,factionId,50);
                        }
                        break;                        
                    }
                    case 8:{
                        if(findCooldown(playerName,"vehicle")){
                            returnCooldown("vehicle", 2000, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            break;
                        }
                        else {
                            Vector3 call_pos = stringToVector3(position);
                            Vector3 v_offset = Vector3(0,50,0);
                            call_pos = call_pos.add(v_offset);
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,600.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,call_pos,"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(8);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                            tasker.add(TimerMarker(m_metagame,3,FairyRequest));
                            m_DummyCallID++;
                            float ori4 = rand(0.0,3.14);
                            spawnVehicle(m_metagame,1,factionId,call_pos,Orientation(0,1,0,ori4),"pierre.vehicle");
                        }
                        break;
                    }
                    case 9:{
                        if(findCooldown(playerName,"vehicle")){
                            returnCooldown("vehicle", 1000, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            break;
                        }
                        else {
                            Vector3 call_pos = stringToVector3(position);
                            Vector3 v_offset = Vector3(0,50,0);
                            call_pos = call_pos.add(v_offset);
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,call_pos,"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(8);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                            tasker.add(TimerMarker(m_metagame,3,FairyRequest));                            
                            m_DummyCallID++;
                            float ori4 = rand(0.0,3.14);
                            spawnVehicle(m_metagame,1,factionId,call_pos,Orientation(0,1,0,ori4),"chiara.vehicle");
                        }
                        break;
                    }
                    case 10:{
                        if(findCooldown(playerName,"vehicle")){
                            returnCooldown("vehicle", 400, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            break;
                        }
                        else {
                            Vector3 call_pos = stringToVector3(position);
                            Vector3 v_offset = Vector3(0,50,0);
                            call_pos = call_pos.add(v_offset);
                            m_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            ManualCallTask@ FairyRequest = ManualCallTask(characterId,"",0.0,factionId,call_pos,"foobar");
                            FairyRequest.setIconTypeKey("call_marker_drop");
                            FairyRequest.setIndex(8);
                            FairyRequest.setSize(0.5);
                            FairyRequest.setDummyId(flagId);
                            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                            tasker.add(TimerMarker(m_metagame,3,FairyRequest));
                            m_DummyCallID++;
                            float ori4 = rand(0.0,3.14);
                            spawnVehicle(m_metagame,1,factionId,call_pos,Orientation(0,1,0,ori4),"martina.vehicle");
                        }
                        break;
                    }                    
                    default:
                        break;
                }
            }

			else if(phase == "queue" && vehicle_drop_call.find(callKey) < 0){
                addCustomStatToCharacter(m_metagame,"radio_call",event.getIntAttribute("character_id"));
            }
        }
    }

    protected void returnCooldown(string player_name, int rp, int characterId, string playerName, int playerId, string message) {
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            dictionary a;
            a["%time"] = ""+getCooldown(playerName, player_name);
            sendPrivateMessageKey(m_metagame,playerId, message,a);
            GiveRP(m_metagame,characterId,rp);
        }
    }

    protected void addCastlingMarker(ManualCallTask@ info){
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

	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}

    void update(float time) {
        if(m_cooldown.length()>0){
            for(uint a=0;a<m_cooldown.length();a++){
                m_cooldown[a].m_time-=time;
                if(m_cooldown[a].m_time<0){
                    m_cooldown.removeAt(a);
                }
            }
        }
    }

}

class Call_Cooldown{
    string m_playerName;
    float m_time=0;
    int m_playerid;
    string m_type;
    Call_Cooldown(string playerName,int pId,float time,string type){
        m_playerName=playerName;
        m_time=time;
        m_playerid=pId;
        m_type=type;
    }
}

bool findCooldown(string pName,string type){
    for(uint i=0;i<m_cooldown.size();i++){
        if(m_cooldown[i].m_playerName==pName && m_cooldown[i].m_type==type){
            return true;
        }
    }
    return false;
}

float getCooldown(string pName,string type){
    for(uint i=0;i<m_cooldown.size();i++){
        if(m_cooldown[i].m_playerName==pName && m_cooldown[i].m_type==type){
            return m_cooldown[i].m_time;
        }
    }
    return 0;
}