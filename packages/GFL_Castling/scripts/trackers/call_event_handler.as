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



//Originally created by NetherCrow
// 11:25:26: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=queue player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:10: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=launch player_id=0 target_position=944.656 17.7529 563.095 
// 11:26:54: SCRIPT:  received: TagName=call_event call_key=kcco_Hephaestus.call character_id=298 faction_id=0 id=0 phase=end player_id=0 target_position=944.656 17.7529 563.095

class call_event : Tracker {
	protected Metagame@ m_metagame;
    protected int m_DummyCallID=0;

	call_event(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleCallEvent(const XmlElement@ event) {
        if(event.getIntAttribute("player_id") != -1 ){

            string callKey = event.getStringAttribute("call_key");
            string phase = event.getStringAttribute("phase");
            string position = event.getStringAttribute("target_position");
            int callId = event.getIntAttribute("id");
            int characterId = event.getIntAttribute("character_id");
            int factionId = event.getIntAttribute("faction_id");

            if (callKey == "gk_rampage_fairy_ac130.call" && phase == "launch") {
                bool exsist_ac130 = false;
                int j=-1;
                for (uint i=0;i<GFL_event_array.length();i++){
                    if (GFL_event_array[i].m_eventkey==2) {
                        exsist_ac130=true;
                        j=i;
                    }
                }
                if (exsist_ac130){
                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                    if (character !is null) {
                        int playerId = character.getIntAttribute("player_id");
                        sendPrivateMessageKey(m_metagame,playerId,"ac130callexisthint");
                        GiveRP(m_metagame,characterId,5000);
                    }
                }
                else {
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
                    newCall.setSpeicalKey(rand(1,2,3));
                    GFL_event_array.insertLast(newCall);
                }
				
			}

            else if (callKey == "gk_snipe_fairy.call" && phase == "launch") {
                bool exsist = false;
                int j=-1;
                for (uint i=0;i<GFL_event_array.length();i++){
                    if (GFL_event_array[i].m_eventkey==1) {
                        exsist=true;
                        j=i;
                    }
                }
                if (exsist){
                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                    if (character !is null) {
                        int playerId = character.getIntAttribute("player_id");
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
			}

			if(phase == "queue"){
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

}