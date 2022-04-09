// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"


//02:29:23: SCRIPT:  received: TagName=chat_event channel=global global=1 message=/promote player_id=0 player_name=NETHER_CROW 
//02:29:23: SCRIPT:  received: TagName=query_result query_id=18     TagName=player aim_target=154.627 19.7851 688.99 character_id=174 color=0.68 0.85 0 1 faction_id=0 name=NETHER_CROW player_id=0 profile_hash=ID3580998501 sid=ID0 
class SkillTrigger{
    int m_character_id;
    float m_time;
    string m_weapontype;
    SkillTrigger(int characterId, float time,string weapontype){
        m_character_id=characterId;
        m_time=time;
        m_weapontype=weapontype;
    }
}

class SkillEffectTimer{
    int m_character_id;
    float m_time;
    string m_EffectKey="";
    string m_specialkey1;
    string m_specialkey2;
    SkillEffectTimer(int characterId, float time,string EffectKey){
        m_character_id=characterId;
        m_time=time;
        m_EffectKey=EffectKey;
    }

    void setSkey(string key){
        m_specialkey1=key;
    }
    void setSkey2(string key){
        m_specialkey2=key;
    }
}

class CommandSkill : Tracker {
    protected Metagame@ m_metagame;
    
	protected array<SkillTrigger@> SkillArray;
    protected array<SkillEffectTimer@> TimerArray;
	protected bool m_ended;

	// --------------------------------------------
	CommandSkill(Metagame@ metagame) {
		@m_metagame = @metagame;
        m_ended = false;
	}

    protected void handleChatEvent(const XmlElement@ event) {
        string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first 
		if (!startsWith(message, "/")) {
			return;
		}

        if(m_ended){
            return;
        }

        string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

        if (checkCommand(message,"skill") || message=="/s"){
            const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
                int cId = info.getIntAttribute("character_id");
                string c_weaponType = getPlayerEquipmentKey(m_metagame,cId,0);
                if (c_weaponType=="") return;
                if (c_weaponType=="gkw_an94_mod3.weapon" || c_weaponType=="gkw_an94_mod3_skill.weapon" || c_weaponType=="gkw_an94mod3_3303.weapon" || c_weaponType=="gkw_an94mod3_3303_skill.weapon" || c_weaponType=="gkw_an94mod3_blm.weapon" || c_weaponType=="gkw_an94mod3_blm_skill.weapon" ){
                    excuteAN94skill(cId,senderId);
                }
                if (c_weaponType=="gkw_vector.weapon"){
                    excuteVVskill(cId,senderId);
                }
                if (c_weaponType=="ff_justice.weapon"){
                    excuteJudgeskill(cId,senderId);                    
                }
                if (c_weaponType=="gkw_mp5.weapon"||c_weaponType=="gkw_mp5_1205.weapon"||c_weaponType=="gkw_mp5_1903.weapon"||c_weaponType=="gkw_mp5_3.weapon"){
                    excuteMP5skill(cId,senderId);                    
                }
                if (c_weaponType=="gkw_mp5mod3.weapon"){
                    excuteMP5MOD3skill(cId,senderId);                    
                }
                if (c_weaponType=="gkw_p22.weapon"){
                    excuteP22skill(cId,senderId);        
                }
                if (c_weaponType=="gkw_hs2000.weapon"||c_weaponType=="gkw_hs2000_5304.weapon"){
                    excuteHS2000skill(cId,senderId);        
                }
                if (c_weaponType=="ff_Intruder.weapon"){
                    excuteIntruderskill(cId,senderId);        
                }
                if (c_weaponType=="ff_agent.weapon"){
                    excuteAgentskill(cId,senderId);        
                }
            }
        }
    }
	protected void handleMatchEndEvent(const XmlElement@ event) {
        m_ended=true;
    }

    void update(float time) {
        if(SkillArray.length()>0)
		{
            for (uint a=0;a<SkillArray.length();a++){
                SkillArray[a].m_time-=time;
                if(SkillArray[a].m_time<0){
                    SkillArray.removeAt(a);
                }
            }
        }
        if(TimerArray.length()>0)
        {
            for (uint a=0;a<TimerArray.length();a++){
                TimerArray[a].m_time-=time;
                if(TimerArray[a].m_time<0){
                    excuteTimerEffect(TimerArray[a]);
                    TimerArray.removeAt(a);
                }
            }
        }
	}

	void start() {
		m_ended = false;
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
    void excuteTimerEffect(SkillEffectTimer@ Trigger){
        if (Trigger.m_EffectKey =="MP5MOD3" || Trigger.m_EffectKey =="MP5" ){
            if(Trigger.m_specialkey1==""){
                Trigger.m_specialkey1="exo_t4.carry_item";
            }
            editPlayerVest(m_metagame,Trigger.m_character_id,Trigger.m_specialkey1,4);

            if(Trigger.m_EffectKey =="MP5MOD3"){
                const XmlElement@ character = getCharacterInfo(m_metagame, Trigger.m_character_id);
                if (character !is null){
                    string cpos = character.getStringAttribute("position");
                    array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,stringToVector3(cpos),0,10.0f);
                    XmlElement c1 ("command");
                    c1.setStringAttribute("class", "update_inventory");
                    c1.setIntAttribute("character_id", Trigger.m_character_id); 
                    c1.setIntAttribute("untransform_count", affectedCharacter.length());
                    m_metagame.getComms().send(c1);
                }
            }
            deleteItemInBackpack(m_metagame,Trigger.m_character_id,"carry_item","immunity_mp5.carry_item");
            deleteItemInStash(m_metagame,Trigger.m_character_id,"carry_item","immunity_mp5.carry_item");
        }
    }
    
    void excuteAN94skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="AN94") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,180,"AN94"));
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        int fID = info.getIntAttribute("faction_id");
        string c_pos = info.getStringAttribute("position");
        string soldierClass = info.getStringAttribute("soldier_group_name");
            XmlElement command("command");
            command.setStringAttribute("class", "create_instance");
            command.setIntAttribute("faction_id",fID);
            command.setStringAttribute("instance_class", "character");
            command.setStringAttribute("instance_key","206_ak12_ar_defyAI");
            command.setStringAttribute("position",c_pos);
            m_metagame.getComms().send(command);    
        sendPrivateMessage(m_metagame,playerId,"Defy AK-12 summoned");
        playSoundAtLocation(m_metagame,"AN94mod3_skill.wav",fID,c_pos,0.9);

        // _log("summonAK12");
    }

    void excuteVVskill(int characterId,int playerId){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="VECTOR") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,30,"VECTOR"));
        addItemInBackpack(m_metagame,characterId,"projectile","VVfirenade.projectile");
        addItemInBackpack(m_metagame,characterId,"projectile","VVfirenade.projectile");
        sendPrivateMessage(m_metagame,playerId,"Firenade Added");
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            int factionid = character.getIntAttribute("faction_id");
            array<string> Voice={
                "Vector_SkillC1.wav",
                "Vector_SkillC2.wav",
                "Vector_SkillC3.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }

    void excuteJudgeskill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="FF_JUDGE") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,90,"FF_JUDGE"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            int factionid = character.getIntAttribute("faction_id");
            array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 15.0f);
            for (uint i = 0; i < characters.length; i++) {
                int soldierId = characters[i].getIntAttribute("id");
                XmlElement c ("command");
                c.setStringAttribute("class", "update_inventory");
                c.setIntAttribute("character_id", soldierId); 
                c.setIntAttribute("untransform_count", 6);
                m_metagame.getComms().send(c);
            }
            array<string> Voice={
                "judge_skill_1.wav",
                "judge_skill_2.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }

    void excuteP22skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="P22") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,12,"P22"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            int factionid = character.getIntAttribute("faction_id");
            array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 15.0f);
            for (uint i = 0; i < characters.length; i++) {
                int soldierId = characters[i].getIntAttribute("id");
                XmlElement c ("command");
                c.setStringAttribute("class", "update_inventory");
                c.setIntAttribute("character_id", soldierId); 
                c.setIntAttribute("untransform_count", 1);
                m_metagame.getComms().send(c);
            }
            array<string> Voice={
                "P22_SKILL1_JP.wav",
                "P22_SKILL2_JP.wav",
                "P22_SKILL3_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }

    void excuteHS2000skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="HS2000") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,15,"HS2000"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            int factionid = character.getIntAttribute("faction_id");
            array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 15.0f);
            for (uint i = 0; i < characters.length; i++) {
                int soldierId = characters[i].getIntAttribute("id");
                XmlElement c ("command");
                c.setStringAttribute("class", "update_inventory");
                c.setIntAttribute("character_id", soldierId); 
                c.setIntAttribute("untransform_count", 1);
                m_metagame.getComms().send(c);
            }
            array<string> Voice={
                "HS2000_SKILL1_JP.wav",
                "HS2000_SKILL2_JP.wav",
                "HS2000_SKILL3_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }

    void excuteMP5skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="MP5") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,29,"MP5"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        string vestkey="exo_t4.carry_item";
        if (character !is null) {
            vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
            if (vestkey=="immunity_mp5.carry_item" || vestkey==""){
                vestkey="exo_t4.carry_item";
            }
            XmlElement c ("command");
            c.setStringAttribute("class", "update_inventory");
            c.setIntAttribute("container_type_id", 4);
            c.setIntAttribute("character_id", characterId); 
            {
                XmlElement k("item");
                k.setStringAttribute("class", "carry_item");
                k.setStringAttribute("key", "immunity_mp5.carry_item");
                c.appendChild(k);
            }            
            m_metagame.getComms().send(c);
            deleteItemInBackpack(m_metagame,characterId,"carry_item","immunity_mp5.carry_item");
            SkillEffectTimer@ stimer = SkillEffectTimer(characterId,4,"MP5");
            stimer.setSkey(vestkey);
            TimerArray.insertLast(stimer);
            array<string> Voice={
                "MP5Mod_SKILL1_JP.wav",
                "MP5Mod_SKILL2_JP.wav",
                "MP5Mod_SKILL3_JP.wav",
                "MP5Mod_MEET_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
        }
    }
    void excuteMP5MOD3skill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="MP5MOD3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,29,"MP5MOD3"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        string vestkey="exo_t4.carry_item";
        if (character !is null) {
            vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
            if (vestkey=="immunity_mp5.carry_item" || vestkey==""){
                vestkey=="exo_t4.carry_item";
            }
            XmlElement c ("command");
            c.setStringAttribute("class", "update_inventory");
            c.setIntAttribute("container_type_id", 4);
            c.setIntAttribute("character_id", characterId); 
            {
                XmlElement k("item");
                k.setStringAttribute("class", "carry_item");
                k.setStringAttribute("key", "immunity_mp5.carry_item");
                c.appendChild(k);
            }            
            m_metagame.getComms().send(c);
            SkillEffectTimer@ stimer = SkillEffectTimer(characterId,5,"MP5MOD3");
            stimer.setSkey(vestkey);
            TimerArray.insertLast(stimer);
            array<string> Voice={
                "MP5Mod_SKILL1_JP.wav",
                "MP5Mod_SKILL2_JP.wav",
                "MP5Mod_SKILL3_JP.wav",
                "MP5Mod_MEET_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
        }
    }
    void excuteIntruderskill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="FF_INTRUDER") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,30,"FF_INTRUDER"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    int Faction= character.getIntAttribute("faction_id");
                    spawnSoldier(m_metagame,7,0,target,"gk_dinergate");
                }
                array<string> Voice={
                    "Intruder_buhuo_SKILL03_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
            }
        }
    }
        void excuteAgentskill(int characterId,int playerId){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="FF_AGENT") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            return;
        }
        SkillArray.insertLast(SkillTrigger(characterId,60,"FF_AGENT"));
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    int Faction= character.getIntAttribute("faction_id");
					
					float xx1=1.0,yy1=1.7;
					Vector3 target0 = stringToVector3(target);
					
					target0.m_values[0] = target0.m_values[0]-xx1;
					target0.m_values[2] = target0.m_values[2]-yy1;
					target = target0.toString();
                    spawnSoldier(m_metagame,1,0,target,"GK_Agent");
					
					target0.m_values[2] = target0.m_values[2]+2*yy1;
					target = target0.toString();
                    spawnSoldier(m_metagame,1,0,target,"GK_Agent");

					target0.m_values[0] = target0.m_values[0]+3*xx1;
					target0.m_values[2] = target0.m_values[2]-yy1;
					target = target0.toString();					
                    spawnSoldier(m_metagame,1,0,target,"GK_Agent");					
                }
                array<string> Voice={
                    "Agent_buhuo_SKILL02_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
            }
        }
    }
}