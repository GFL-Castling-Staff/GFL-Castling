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
    {"gk_vehicle_guerche.call",11},
    {"gk_vehicle_tricycle.call",12},

    {"target.call",13},

    {"gk_call_tier1.call",1001},
    {"gk_call_tier2.call",1002},
    {"gk_call_tier3.call",1003},

    // 空空投
    {"",0}
};

array<string> vehicle_drop_call = {
    "gk_vehicle_pierre.call",
    "gk_vehicle_martina.call",
    "gk_vehicle_chiara.call",
    "gk_vehicle_guerche.call",
    "gk_vehicle_tricycle.call"
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
        CallEvent_cooldown.resize(0);
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
                            returnCooldown_Slot("tier1", 0, characterId, playerName, playerId, "call event,cool down");
                            break;
                        }
                        else
                        {
                            GFL_playerInfo@ m_playerinfo = getPlayerInfoFromListbyPid(playerId);
                            if (m_playerinfo.m_name == default_string ) break;
                            GFL_battleInfo@ battleInfo = m_playerinfo.getBattleInfo();
                            player_data newdata = PlayerProfileLoad(readFile(m_metagame,playerName,profile_hash));
                            string call_slot_key = newdata.getCallSlot(1);
                            if(call_slot_key == "") break;
                            switch(int(call_tier_index[call_slot_key]))
                            { 
                                case 100000: //免费炮击
                                {
                                    addCallCoolDown(playerName,playerId,240.0,"tier1",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(15.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_bombardment_fairy_82mm_mortar@ new_task = Event_call_bombardment_fairy_82mm_mortar(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"bombardment_fairy_82mm_mortar_free_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;                                    
                                }
                                case 100100: //82mm
                                {
                                    if(!costTacticPoint(battleInfo,15,playerId)) break;
                                    addCallCoolDown(playerName,playerId,60.0,"tier1",m_playerinfo);
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
                                    if(!costTacticPoint(battleInfo,30,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier1",m_playerinfo);
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
                                case 100300: //155mm
                                {
                                    if(!costTacticPoint(battleInfo,45,playerId)) break;
                                    addCallCoolDown(playerName,playerId,105.0,"tier1",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(45.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_bombardment_fairy_155mm_airburst@ new_task = Event_call_bombardment_fairy_155mm_airburst(m_metagame,3.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }
                                case 100400: //空袭妖精-近空支援
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,20,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier1",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_airstrike_fairy_cas@ new_task = Event_call_airstrike_fairy_cas(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_cas_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }
                                case 100500: //空袭妖精-近空支援 P2P
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(findCooldown(playerName,"airstrike_cas_p2p")){
                                        Call_Cooldown@ call_cooldowninfo = getCooldownInfo(playerName,"airstrike_cas_p2p");
                                        if(call_cooldowninfo is null) break;
                                        if(!costTacticPoint(battleInfo,20,playerId)) break;
                                        addCallCoolDown(playerName,playerId,90.0,"tier1",m_playerinfo);
                                        sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                        int flagId = m_DummyCallID + 15000;
                                        CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                        FairyRequest.setIconTypeKey("call_marker_drop");
                                        FairyRequest.setIndex(6);
                                        FairyRequest.setSize(0.5);
                                        FairyRequest.setDummyId(flagId);
                                        addCastlingMarker(FairyRequest);
                                        m_DummyCallID++;
                                        Vector3 start_pos = call_cooldowninfo.getPos();
                                        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                        Event_call_airstrike_fairy_cas_p2p@ new_task = Event_call_airstrike_fairy_cas_p2p(m_metagame,2.0,characterId,factionId,start_pos,stringToVector3(position),"airstrike_fairy_cas_lv0",flagId);
                                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                        tasker.add(new_task);
                                        addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    }
                                    else
                                    {
                                        spawnStaticProjectile(m_metagame,"fairy_airstrike_cas_p2p_pointer.projectile",stringToVector3(position),characterId,factionId);
                                        Call_Cooldown@ call_cooldowninfo = Call_Cooldown(playerName,playerId,5.0,"airstrike_cas_p2p");
                                        call_cooldowninfo.setPos(stringToVector3(position));
                                        CallEvent_cooldown.insertLast(call_cooldowninfo);
                                    }

                                    break;
                                }                                
                                case 100600: //空袭妖精-精确空袭
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,20,playerId)) break;
                                    addCallCoolDown(playerName,playerId,30.0,"tier1",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(9);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(15.0);
                                    FairyRequest.setIconTypeKey("call_marker_air");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_airstrike_fairy_precise@ new_task = Event_call_airstrike_fairy_precise(m_metagame,3.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_precise_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }
                                case 100700: //火箭妖精 巡曳飞弹
                                {
                                    if(!costTacticPoint(battleInfo,25,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier1",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"rocketfight");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_rocket_fairy_missile@ new_task = Event_call_rocket_fairy_missile(m_metagame,2.5,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_precise_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    playSoundAtLocation(m_metagame,"cruise_missile_start_fromCOD16.wav",factionId,position,1.8);
                                    break;
                                }                                
                                default:
                                    break;                                
                            }
                        }
                        break;
                    }
                    case 1002:{
                        if(findCooldown(playerName,"tier2")){
                            returnCooldown_Slot("tier2", 0, characterId, playerName, playerId, "call event,cool down");
                            break;
                        }
                        else
                        {
                            GFL_playerInfo@ m_playerinfo = getPlayerInfoFromListbyPid(playerId);
                            if (m_playerinfo.m_name == default_string ) break;
                            GFL_battleInfo@ battleInfo = m_playerinfo.getBattleInfo();
                            player_data newdata = PlayerProfileLoad(readFile(m_metagame,playerName,profile_hash));
                            string call_slot_key = newdata.getCallSlot(2);
                            if(call_slot_key == "") break;
                            switch(int(call_tier_index[call_slot_key]))
                            {
                                case 200100: //空袭妖精-高空投弹
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,45,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_airstrike_fairy_bomber@ new_task = Event_call_airstrike_fairy_bomber(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_bomber_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 200200: //170mm
                                {
                                    if(!costTacticPoint(battleInfo,30,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"bombcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(30.0);
                                    FairyRequest.setIconTypeKey("call_marker_bomb");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_bombardment_fairy_170mm@ new_task = Event_call_bombardment_fairy_170mm(m_metagame,5.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }
                                case 200300: //勇士妖精 侦察直升机
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,50,playerId)) break;
                                    addCallCoolDown(playerName,playerId,120.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"warriorcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_warrior_fairy_recon_heil@ new_task = Event_call_warrior_fairy_recon_heil(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 200400: //勇士妖精 VTOL
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,60,playerId)) break;
                                    addCallCoolDown(playerName,playerId,150.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"warriorcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_warrior_fairy_VTOL@ new_task = Event_call_warrior_fairy_VTOL(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 200500: //BM30
                                {
                                    if(!costTacticPoint(battleInfo,50,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"rocketcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(10);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(40.0);
                                    FairyRequest.setIconTypeKey("call_marker_rocket");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_rocket_fairy_strike@ new_task = Event_call_rocket_fairy_strike(m_metagame,3.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_precise_lv0",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    playSoundAtLocation(m_metagame,"rocket_artillery_barrage_distant.wav",factionId,position,2.25);
                                    break;
                                }

                                case 200600: //空袭妖精-精确空袭
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,20,playerId)) break;
                                    addCallCoolDown(playerName,playerId,30.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(15.0);
                                    FairyRequest.setIconTypeKey("call_marker_air");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_airstrike_fairy_precise@ new_task = Event_call_airstrike_fairy_precise(m_metagame,3.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_precise_lv0",flagId);
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
                    case 1003:{
                        if(findCooldown(playerName,"tier3")){
                            returnCooldown_Slot("tier3", 0, characterId, playerName, playerId, "call event,cool down");
                            break;
                        }
                        else
                        {
                            GFL_playerInfo@ m_playerinfo = getPlayerInfoFromListbyPid(playerId);
                            if (m_playerinfo.m_name == default_string ) break;
                            GFL_battleInfo@ battleInfo = m_playerinfo.getBattleInfo();
                            player_data newdata = PlayerProfileLoad(readFile(m_metagame,playerName,profile_hash));
                            string call_slot_key = newdata.getCallSlot(3);
                            if(call_slot_key == "") break;
                            switch(int(call_tier_index[call_slot_key]))
                            {
                                case 300100: //勇士妖精 武装直升机
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,75,playerId)) break;
                                    addCallCoolDown(playerName,playerId,120.0,"tier3",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"warriorcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(6);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_warrior_fairy_attack_heil@ new_task = Event_call_warrior_fairy_attack_heil(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 300200: //暴怒 空中炮艇
                                {
                                    bool exist_ac130 = false;
                                    for (uint i=0;i<GFL_event_array.length();i++){
                                        if (GFL_event_array[i].m_eventkey==2) {exist_ac130=true;break;}
                                    }
                                    if (exist_ac130){
                                        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                        if (character !is null) {
                                            sendPrivateMessageKey(m_metagame,playerId,"ac130callexisthint");
                                        }
                                        break;
                                    }
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,120,playerId)) break;
                                    addCallCoolDown(playerName,playerId,300.0,"tier3",m_playerinfo);
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
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 300300: //火箭弹飞机
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,50,playerId)) break;
                                    addCallCoolDown(playerName,playerId,90.0,"tier2",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"rocketfight");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIconTypeKey("call_marker_drop");
                                    FairyRequest.setIndex(10);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(10.0);
                                    FairyRequest.setIconTypeKey("call_marker_air");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_rocket_fairy_rush@ new_task = Event_call_rocket_fairy_rush(m_metagame,2.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    break;
                                }

                                case 300400: //BM21
                                {
                                    if(!costTacticPoint(battleInfo,120,playerId)) break;
                                    addCallCoolDown(playerName,playerId,300.0,"tier3",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"rocketcallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(10);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(60.0);
                                    FairyRequest.setIconTypeKey("call_marker_rocket");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_rocket_fairy_cover@ new_task = Event_call_rocket_fairy_cover(m_metagame,5.0,characterId,factionId,c_pos,stringToVector3(position),"",flagId);
                                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                    tasker.add(new_task);
                                    addCustomStatToCharacter(m_metagame,"radio_call",characterId);
                                    playSoundAtLocation(m_metagame,"Fairy_multirocket_FromCOD16.wav",factionId,position,1.0);
                                    break;
                                }

                                case 300600: //空袭妖精-精确空袭
                                {
                                    if(checkAntiAir(playerId)) break;
                                    if(!costTacticPoint(battleInfo,20,playerId)) break;
                                    addCallCoolDown(playerName,playerId,30.0,"tier3",m_playerinfo);
                                    sendFactionMessageKey(m_metagame,factionId,"airstrikecallstarthint");
                                    int flagId = m_DummyCallID + 15000;
                                    CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionId,stringToVector3(position));
                                    FairyRequest.setIndex(11);
                                    FairyRequest.setSize(0.5);
                                    FairyRequest.setDummyId(flagId);
                                    FairyRequest.setRange(15.0);
                                    FairyRequest.setIconTypeKey("call_marker_air");
                                    addCastlingMarker(FairyRequest);
                                    m_DummyCallID++;
                                    const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
                                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));                                    
                                    Event_call_airstrike_fairy_precise@ new_task = Event_call_airstrike_fairy_precise(m_metagame,3.0,characterId,factionId,c_pos,stringToVector3(position),"airstrike_fairy_precise_lv0",flagId);
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
                                GFL_playerInfo@ m_playerinfo = getPlayerInfoFromListbyPid(playerId);
                                if (m_playerinfo.m_name == default_string ) break;
                                GFL_battleInfo@ battleInfo = m_playerinfo.getBattleInfo();                                
                                if(!costTacticPoint(battleInfo,15,playerId)) break;
                                CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"sniper_call"));
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
                            returnCooldown("vehicle", 0, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            addItemInBackpack(m_metagame,characterId,"weapon","fairy_vehicle_pierre.weapon");
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
                            returnCooldown("vehicle", 0, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            addItemInBackpack(m_metagame,characterId,"weapon","fairy_vehicle_chiara.weapon");
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
                            returnCooldown("vehicle", 0, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            addItemInBackpack(m_metagame,characterId,"weapon","fairy_vehicle_martina.weapon");
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
                    case 11:{
                        if(findCooldown(playerName,"vehicle")){
                            returnCooldown("vehicle", 0, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            addItemInBackpack(m_metagame,characterId,"weapon","fairy_vehicle_guerche.weapon");
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
                            spawnVehicle(m_metagame,1,factionId,call_pos,Orientation(0,1,0,ori4),"mortar_truck.vehicle");
                        }
                        break;
                    }
                    case 12:{
                        if(findCooldown(playerName,"vehicle")){
                            returnCooldown("vehicle", 0, characterId, playerName, playerId, "vehicle_drop_cooldown");
                            addItemInBackpack(m_metagame,characterId,"weapon","fairy_vehicle_tricycle.weapon");
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
                            spawnVehicle(m_metagame,1,factionId,call_pos,Orientation(0,1,0,ori4),"tricycle.vehicle");
                        }
                        break;
                    }
                    case 13:{
                        if(findCooldown(playerName,"taunt")){
                            returnCooldown_Slot("taunt", 300, characterId, playerName, playerId, "call event,cool down");
                            break;
                        }
                        else {
                            Vector3 call_pos = stringToVector3(position);
                            Vector3 v_offset = Vector3(0,30,0);
                            call_pos = call_pos.add(v_offset);
                            CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,90.0,"taunt"));
                            array<soldier_spawn_request@> spawn_soldier =   
                            {
                                soldier_spawn_request("GK_target",3)
                            };
                            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                            tasker.add(DelaySpawnSoldier(m_metagame,3.0,factionId,spawn_soldier,call_pos,6.0,6.0));
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
        if(checkCommand(message,"call")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.m_name == default_string ) return;
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,playerInfo.getPlayerName(),playerInfo.getHash()));
            string call_slot_key1 = newdata.getCallSlot(1);
            string call_slot_key2 = newdata.getCallSlot(2);
            string call_slot_key3 = newdata.getCallSlot(3);
            dictionary a;
            a["%call1"] = ""+call_slot_key1;       
            a["%call2"] = ""+call_slot_key2;              
            a["%call3"] = ""+call_slot_key3;              
            notify(m_metagame, "call event,equiped", a, "misc", player_id, false, "", 1.0);
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

    protected bool costTacticPoint(GFL_battleInfo@ battle_info,int num,int player_id)
    {
        int m_tactic_point = battle_info.getTacticPoint();
        int m_tactic_point_cost = m_tactic_point - num;
        if ((m_tactic_point_cost) >=0)
        {
            battle_info.setTacticPoint(m_tactic_point_cost);
            dictionary a;
            a["%num"] = ""+m_tactic_point_cost;
            a["%cost_num"] = ""+num;
            notify(m_metagame, "call event,cost point", a, "misc", player_id, false, "", 1.0);
            return true;
        }
        else
        {
            dictionary a;
            a["%num"] = ""+(num-m_tactic_point);
            notify(m_metagame, "call event,not enough point", a, "misc", player_id, false, "", 1.0);
            return false;
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

    protected void returnCooldown_Slot(string player_name, int rp, int characterId, string playerName, int playerId, string message) {
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            dictionary a;
            a["%time"] = ""+getCooldown(playerName, player_name);
            notify(m_metagame, message, a, "misc", playerId, false, "", 1.0);
            if(rp > 0)
            {
                GiveRP(m_metagame,characterId,rp);
            }
        }
    }

    protected bool checkAntiAir(int player_id)
    {
        bool status = m_metagame.getAntiAirStatus();
        if(status)
        {
            notify(m_metagame, "call event,anti air", dictionary(), "misc", player_id, false, "", 1.0);
            return true;
        }
        else
        {
            return false;
        }
    }

    protected void addCallCoolDown(string playerName,int playerId,float time,string key,GFL_playerInfo@ playerInfo)
    {
        if(playerInfo.getPlayerEquipment().getWeapon(3) == "god_vest.carry_item")
        {
            return;
        }
        CallEvent_cooldown.insertLast(Call_Cooldown(playerName,playerId,time,key));
    }
}

class Call_Cooldown{
    string m_playerName;
    float m_time=0;
    int m_playerid;
    string m_type;
    Vector3 m_pos;
    Call_Cooldown(string playerName,int pId,float time,string type){
        m_playerName=playerName;
        m_time=time;
        m_playerid=pId;
        m_type=type;
    }

    void setPos(Vector3 pos)
    {
        m_pos = pos;
    }

    Vector3 getPos()
    {
        return m_pos;
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

Call_Cooldown@ getCooldownInfo(string pName,string type)
{
    for(uint i=0;i<CallEvent_cooldown.size();i++){
        if(CallEvent_cooldown[i].m_playerName==pName && CallEvent_cooldown[i].m_type==type){
            return CallEvent_cooldown[i];
        }
    }
    return null;    
}

dictionary call_tier_index = {

    // 新支援系统（注意命名按照T1=1xxxx,T2=2xxxx,T3=3xxxx的格式来）
    // x-xxx-xx : 支援tier级别-支援编号-支援等级/变种
    // key命名规范
    // tier+种类+具体名字+lv等级

    // T1 ----------------------------------- //

    // T1 001 炮击妖精-[82mm迫击炮打击]
        // lv0
        {"t1_bombardment_fairy_82mm_mortar_free_lv0",100000},
        {"t1_bombardment_fairy_82mm_mortar_lv0",100100},

    // T1 002 炮击妖精-[105mm榴弹扫荡]
        // lv0
        {"t1_bombardment_fairy_105mm_grenade_barrage_lv0",100200},

    // T1 003 炮击妖精-[155mm空爆榴弹]
        {"t1_bombardment_fairy_155mm_air_burst_lv0",100300},

    // T1 004/005 空袭妖精-[俯冲攻击]
        //lv0
        {"t1_airstrike_fairy_cas_lv0",100400},
        {"t1_airstrike_fairy_cas_p2p_lv0",100500},

    // T1 006 空袭妖精-[精准空袭]
        // lv0
        {"t1_airstrike_fairy_precise_lv0",100600},

    // T1 007 火箭妖精-[巡航导弹]
        // lv0
        {"t1_rocket_fairy_missile_lv0",100700},


    // T2 ----------------------------------- //

    // T2 001 空袭妖精-[高空投弹]
        // lv0
        {"t2_airstrike_fairy_bomber_lv0",200100},

    // T2 002 炮击妖精-[170]
        // lv0
        {"t2_bombardment_fairy_170mm_cannon_lv0",200200},
        

    // T2 006 空袭妖精-[精准空袭]
        // lv0
        {"t2_airstrike_fairy_precise_lv0",200600},

    // T2 003 勇士妖精-[侦察直升机扫荡]
        // lv0 
        {"t2_warrior_fairy_recon_heli_lv0",200300},

    // T2 004 勇士妖精-[VTOL战机巡航]
        // lv0
        {"t2_warrior_fairy_vtol_sentry_lv0",200400},

    // T2 005 火箭妖精-[火箭弹打击]
        // lv0
        {"t2_rocket_fairy_bm30_lv0",200500},

    // T2 耀夜姬-[轨道激光打击]
        // lv0
        {"t2_lv0_nightshine_princess",200700},

    // T3 ----------------------------------- //
    // T3 001 勇士妖精-[武装直升机扫荡]
        // lv0
        {"t3_warrior_fairy_armed_heli_lv0",300100},

    // T3 002 暴怒妖精-[炮艇支援]
        // lv0
        {"t3_rampage_fairy_gunship_lv0",300200},

    // T3 006 空袭妖精-[精准空袭]
        // lv0
        {"t3_airstrike_fairy_precise_lv0",300600},

    // T3 火箭妖精-[火箭弹突袭]
        // lv0
        {"t3_rocket_fairy_aircraft_lv0",300300},

    // T3 火箭妖精-[地毯式覆盖]
        // lv0
        {"t3_rocket_fairy_cover_lv0",300400},

    {"",0}
};