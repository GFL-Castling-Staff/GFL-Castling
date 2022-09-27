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

    // 空空投
    {"",0}
};

//Originally created by NetherCrow
// 11:25:26: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=queue player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:10: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=launch player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:54: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=end player_id=0 target_position=944.656 17.7529 563.095

class call_event : Tracker {
	protected Metagame@ m_metagame;
    protected int m_DummyCallID=0;
    protected array<Call_Cooldown@> m_cooldown;

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
                        int j=-1;
                        for (uint i=0;i<GFL_event_array.length();i++){
                            if (GFL_event_array[i].m_eventkey==2) {exsist_ac130=true;j=i;}
                        }
                        if (exsist_ac130){
                            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                            if (character !is null) {
                                sendPrivateMessageKey(m_metagame,playerId,"ac130callexisthint");
                                GiveRP(m_metagame,characterId,5000);
                            }
                        }
                        else{
                            if(findCooldown(playerName,"ac130")){
                                const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                if (character !is null) {
                                    dictionary a;
                                    a["%time"] = ""+getCooldown(playerName,"ac130");                        
                                    sendPrivateMessageKey(m_metagame,playerId,"ac130cooldown",a);
                                    GiveRP(m_metagame,characterId,5000);
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
                                GFL_event@ newCall = GFL_event(characterId,factionId,2,stringToVector3(position),1.0,-1.0,flagId);
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
                        else {
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
                            GFL_event_array.insertLast(GFL_event(characterId,factionId,1,stringToVector3(position),1.0,-1.0,flagId));
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
                            GFL_event@ newCall = GFL_event(characterId,factionId,4,stringToVector3(position),1.0,-1.0,flagId);
                            GFL_event_array.insertLast(newCall);
                        }
                        break;
                    }
                    default:
                        break;
                }
            }

			else if(phase == "queue"){
                addCustomStatToCharacter(m_metagame,"radio_call",event.getIntAttribute("character_id"));
            }
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