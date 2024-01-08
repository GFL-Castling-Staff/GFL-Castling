#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
#include "call_marker_tracker.as"
#include "fairy_command.as"
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

    {"gk_call_tier1.call",1001},
    {"gk_call_tier2.call",1002},
    {"gk_call_tier3.call",1003},

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
array<Call_Cooldown@> CallEvent_cooldown;

class call_event : Tracker {
	protected GameMode@ m_metagame;
    protected int m_DummyCallID=0;

	call_event(GameMode@ metagame) {
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
            string profile_hash = playerinfo.getStringAttribute("profile_hash");

            if (phase == "launch") {
                switch(int(callLaunchIndex[callKey]))
                {
                    case 1001:{
                        if(findCooldown(playerName,"tier1")){
                            returnCooldown("tier1", 0, characterId, playerName, playerId, "callcooldown");
                            break;
                        }
                        else
                        {
                            player_data newdata = PlayerProfileLoad(readFile(m_metagame,playerName,profile_hash));
                            string call_slot_key = newdata.getCallSlot(1);
                            if(call_slot_key == "") break;
                            switch(int(call_tier_index[call_slot_key]))
                            { 
                                case 100100: //82mm
                                {
                                    CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,60.0,"tier1"));
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(20.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_bombardment_fairy_82mm_mortar@ new_task = Event_call_bombardment_fairy_82mm_mortar(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"bombardment_fairy_82mm_mortar_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }
                                case 100200: //105mm
                                {
                                    CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"tier1"));
                                    playSoundAtLocation(m_metagame,"kcco_dn_1.wav",factionId,position,1.5);
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(40.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["bomb_fairy"]),stringToVector3(position),1.0,-1.0,flagId));
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }         
                                case 100300: //空袭妖精-俯冲共计
                                {
                                    CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,60.0,"tier1"));
                                    playSoundAtLocation(m_metagame,"kcco_dn_1.wav",factionId,position,1.5);
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(20.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_bombardment_fairy_82mm_mortar@ new_task = Event_call_bombardment_fairy_82mm_mortar(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"bombardment_fairy_82mm_mortar_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }                       
                                default:
                                    break;                                
                            }
                        }
                        break;
                    }                    
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
                                CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"ac130"));
                                sendFactionMessageKey(m_metagame,factionId,"ac130callstarthint");
                                int flagId = m_DummyCallID + 15000;
                                CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                                CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,30.0,"sniper_call"));
                                sendFactionMessageKey(m_metagame,factionId,"snipecallstarthint");
                                int flagId = m_DummyCallID + 15000;
                                CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                FairyRequest.setIndex(14);
                                FairyRequest.setSize(0.5);
                                FairyRequest.setDummyId(flagId);
                                FairyRequest.setRange(60.0);
                                FairyRequest.setIconTypeKey("call_marker_snipe");
                                addCastlingMarker(FairyRequest);
                                m_DummyCallID++;
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(Skill_Fairy_Snipe(m_metagame,1.0,characterId,factionId,stringToVector3(position),FairyRequest));
                                // GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["sniper_fairy"]),stringToVector3(position),1.0,-1.0,flagId));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"yaoren_8"));
                            int flagId = m_DummyCallID + 15000;
                                CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"TU160"));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"warrior"));
                            sendFactionMessageKey(m_metagame,factionId,"warriorcallstarthint");
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                        else 
                        {
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"bombardment"));
                            playSoundAtLocation(m_metagame,"kcco_dn_1.wav",factionId,position,1.5);
                            sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"barrier"));
                            sendFactionMessageKey(m_metagame,factionId,"barrierfight");
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,600.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,300.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,120.0,"vehicle"));
                            int flagId = m_DummyCallID + 15000;
                            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
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
        }
    }

    protected void handleChatEvent(const XmlElement@ event){
		string message = event.getStringAttribute("message");
		string p_name = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
        if(checkCommand(message,"point")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.m_name == default_string ) return;
            int player_id = playerInfo.getPlayerPid();
            int tactic_point = playerInfo.getBattleInfo().getTacticPoint();
            dictionary a;
            a["%num"] = ""+tactic_point;              
            notify(m_metagame, "tactic point system,info", a, "misc", player_id, false, "", 1.0);
        }
    }

    protected void returnCooldown(string player_name, int rp, int characterId, string playerName, int playerId, string message) {
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            dictionary a;
            a["%time"] = ""+getCooldown(playerName, player_name);
            sendPrivateMessageKey(m_metagame,playerId, message,a);
            if(rp > 0)
            {
                GiveRP(m_metagame,characterId,rp);
            }
        }
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
        if(CallEvent_cooldown.length()>0){
            for(uint a=0;a<CallEvent_cooldown.length();a++){
                CallEvent_cooldown[a].m_time-=time;
                if(CallEvent_cooldown[a].m_time<0){
                    CallEvent_cooldown.removeAt(a);
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
    for(uint i=0;i<CallEvent_cooldown.size();i++){
        if(CallEvent_cooldown[i].m_playerName==pName && CallEvent_cooldown[i].m_type==type){
            return true;
        }
    }
    return false;
}

float getCooldown(string pName,string type){
    for(uint i=0;i<CallEvent_cooldown.size();i++){
        if(CallEvent_cooldown[i].m_playerName==pName && CallEvent_cooldown[i].m_type==type){
            return CallEvent_cooldown[i].m_time;
        }
    }
    return 0;
}

dictionary call_tier_index = {

    // 新支援系统（注意命名按照T1=1xxxx,T2=2xxxx,T3=3xxxx的格式来）
    // x-xxx-xx : 支援级别-支援编号-支援等级/变种

    // T1 ----------------------------------- //

    // T1 炮击妖精-[82mm迫击炮打击]
        // lv0
        {"t1_lv0_bombardment_fairy_82mm_mortar",100100},

    // T1 炮击妖精-[105mm榴弹扫荡]
        // lv0
        {"t1_lv0_bombardment_fairy_105mm_grenade_barrage",100200},

    // T1 炮击妖精-[155mm空爆榴弹]

        {"t1_lv0_bombardment_fairy_155mm_air_burst",100300},

    // T1 空袭妖精-[俯冲攻击]
        //lv0
        {"t1_lv0_dive_airstrike_fairy",100200},
        {"t1_lv1_dive_airstrike_fairy",100201},

    // T1 空袭妖精-[精准空袭]
        // lv0
        {"t1_lv0_precise_airstrike_fairy",100300},

    // T1 火箭妖精-[巡航导弹]
        // lv0
        {"t1_lv0_missile_rocket_fairy",100400},

    // T1 魔女妖精 
        // lv0
        {"t1_lv0_witch_fairy",100500},
        // lv1
        {"t1_lv1_witch_fairy",100501},
        // lv2
        {"t1_lv2_witch_fairy",100502},
        // lv3
        {"t1_lv3_witch_fairy",100503},

    // T1 花火妖精（春节限定）
        // lv0
        {"t1_lv0_newyear_firework_fairy",100600},

    // T2 ----------------------------------- //

    // T2 空袭妖精-[高空投弹]
        // lv0
        {"t2_lv0_highal_airstrike_fairy",200100},

    // T2 勇士妖精-[侦察直升机扫荡]
        // lv0 
        {"t2_lv0_scout_warrior_fairy",200200},

    // T2 勇士妖精-[VTOL战机巡航]
        // lv0
        {"t2_lv0_VTOL_warrior_fairy",200300},

    // T2 火箭妖精-[火箭弹打击]
        // lv0
        {"t2_lv0_TOS_rocket_fairy",200400},

    // T2 耀夜姬-[轨道激光打击]
        // lv0
        {"t2_lv0_nightshine_princess",200500},

    // T2 连击妖精
        // lv0
        {"t2_lv0_combo_fairy",200600},

    // T2 沙舞妖精
        // lv0
        {"t2_lv0_sanddance_fairy",200700},
        // lv1
        {"t2_lv1_sanddance_fairy",200701},
        // lv2
        {"t2_lv2_sanddance_fairy",200702},
        // lv3
        {"t2_lv3_sanddance_fairy",200703},

    // T2 双生妖精
        // lv0
        {"t2_lv0_twin_fairy",200800},
        // lv1
        {"t2_lv1_twin_fairy",200801},

    // T2 护盾妖精
        // lv0
        {"t2_lv0_shield_fairy",200900},

    // T2 年兽妖精
        // lv0
        {"t2_lv0_nian_fairy,call",201000},

    // T3 ----------------------------------- //

    // T3 勇士妖精-[武装直升机扫荡]
        // lv0
        {"t3_lv0_warrior_fairy",300100},

    // T3 暴怒妖精-[炮艇支援]
        // lv0
        {"t3_lv0_rage_fairy",300200},

    // T3 火箭妖精-[火箭弹突袭]
        // lv0
        {"t3_lv0_raid_rocket_fairy",300300},

    // T3 火箭妖精-[地毯式覆盖]
        // lv0
        {"t3_lv0_carpetb_rocket_fairy",300400},

    {"",0}
};