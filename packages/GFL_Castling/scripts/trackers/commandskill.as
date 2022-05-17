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
    int m_charge=1;
    SkillTrigger(int characterId, float time,string weapontype){
        m_character_id=characterId;
        m_time=time;
        m_weapontype=weapontype;
    }

    void setCharge(int num){
        m_charge=num;
    }
    void addCharge(){
        m_charge++;
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

class SkillModifer{
    float m_cdr=1.0;
    float m_cdm=0;

    void setCooldownReduction(float num){
        m_cdr=num;
    }
    void setCooldownMinus(float num){
        m_cdm=num;
    }
}

class SpamAvoider{
    float m_time=0.5;
    int m_playerid;
    SpamAvoider(int playerid){
        m_playerid=playerid;
    }
}

class CommandSkill : Tracker {
    protected Metagame@ m_metagame;
    
	public array<SkillTrigger@> SkillArray;
    public array<SkillEffectTimer@> TimerArray;
    array<SpamAvoider@> DontSpamingYourFuckingSkillWhileCoolDownBro;
    array<string> targetAPgrenades = {
        "gkw_arx160.weapon",
        "gkw_xm8.weapon",
        "gkw_g3.weapon",
        "gkw_m4sopmodii_531.weapon",
        "gkw_m4sopmodii.weapon",
        "gkw_hk416.weapon",
        "gkw_hk416_6505.weapon",
        "gkw_hk416_537.weapon",
        "gkw_hk416_3401.weapon"
    };
    array<string> targetAAgrenades = {
        "gkw_stg44.weapon",
        "gkw_famas.weapon"
    };
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
            for(uint a=0;a<DontSpamingYourFuckingSkillWhileCoolDownBro.length();a++){
                if(DontSpamingYourFuckingSkillWhileCoolDownBro[a].m_playerid==senderId) return;
            }
            DontSpamingYourFuckingSkillWhileCoolDownBro.insertLast(SpamAvoider(senderId));
            const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
                int cId = info.getIntAttribute("character_id");
                const XmlElement@ targetCharacter = getCharacterInfo2(m_metagame,cId);
                if (targetCharacter is null) return;
                array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
                if (equipment.size() == 0) return;
                if (equipment[0].getIntAttribute("amount") == 0) return;
                string c_weaponType = equipment[0].getStringAttribute("key");
                string c_armorType = equipment[4].getStringAttribute("key");

                SkillModifer m_modifer=SkillModifer();

                if (c_weaponType=="") return;

                if (c_weaponType=="gkw_an94_mod3.weapon" || c_weaponType=="gkw_an94_mod3_skill.weapon" || c_weaponType=="gkw_an94mod3_3303.weapon" || c_weaponType=="gkw_an94mod3_3303_skill.weapon" || c_weaponType=="gkw_an94mod3_blm.weapon" || c_weaponType=="gkw_an94mod3_blm_skill.weapon" ){
                    excuteAN94skill(cId,senderId,m_modifer);
                    return;
                }
                if (c_weaponType=="gkw_vector.weapon"){
                    excuteVVskill(cId,senderId,m_modifer);
                    return;
                }
                if (c_weaponType=="ff_justice.weapon"){
                    excuteJudgeskill(cId,senderId,m_modifer);
                    return;                    
                }
                if (c_weaponType=="gkw_mp5.weapon"||c_weaponType=="gkw_mp5_3.weapon"||c_weaponType=="gkw_mp5_1205.weapon"||c_weaponType=="gkw_mp5_1903.weapon"||c_weaponType=="gkw_mp5_3006.weapon"){
                    excuteMP5skill(cId,senderId,m_modifer);
                    return;                    
                }
                if (c_weaponType=="gkw_mp5mod3.weapon"||c_weaponType=="gkw_mp5mod3_3.weapon"||c_weaponType=="gkw_mp5mod3_1205.weapon"||c_weaponType=="gkw_mp5mod3_1903.weapon"||c_weaponType=="gkw_mp5mod3_3006.weapon"){
                    excuteMP5MOD3skill(cId,senderId,m_modifer);
                    return;                    
                }
                if (c_weaponType=="gkw_p22.weapon"){
                    excuteP22skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_hs2000.weapon"||c_weaponType=="gkw_hs2000_5304.weapon"){
                    excuteHS2000skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="ff_Intruder.weapon"){
                    excuteIntruderskill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="ff_agent.weapon"){
                    excuteAgentskill(cId,senderId,m_modifer);
                    return;        
                }                
                if (c_weaponType=="ff_destroyer.weapon"){
                    excuteDestroyerskill(cId,senderId,m_modifer);
                    return;        
                }                 
                if (c_weaponType=="ff_excutioner_2.weapon"){
                    excuteExcutionerskill(cId,senderId,m_modifer);        
                    return;
                }        
                if (c_weaponType=="ff_parw_alina.weapon"){
                    excuteBaibaoziskill(cId,senderId,m_modifer);
                    return;
                }              
                if (c_weaponType=="gkw_ppsh41mod3.weapon"|| c_weaponType=="gkw_ppsh41.weapon"){
                    excutePPSH41skill(cId,senderId,m_modifer);
                    return;
                }
                if (c_weaponType=="gkw_ump45mod3.weapon"|| c_weaponType=="gkw_ump45mod3_535.weapon" || c_weaponType=="gkw_ump45mod3_410.weapon"){
                    excuteUMP45skill(cId,senderId,m_modifer);
                    return;
                }
                if (c_weaponType=="gkw_m870.weapon"|| c_weaponType=="gkw_m870_3803.weapon" || c_weaponType=="gkw_m870_3803_skill.weapon"){
                    excuteM870skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_pp19.weapon"){
                    excutePP19skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_pp19mod3.weapon"){
                    excutePP19skill(cId,senderId,m_modifer,true);
                    return;        
                }
                if (c_weaponType=="gkw_ak15mod3.weapon"|| c_weaponType=="gkw_ak15mod3_skill.weapon"){
                    excuteAK15MOD3skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_xm8_mod3.weapon"){
                    excuteXM8MOD3skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_stg44mod3.weapon"){
                    excuteStg44MOD3skill(cId,senderId,m_modifer);
                    return;        
                }
                if (c_weaponType=="gkw_welrodmod3.weapon"){
                    excuteWerlodskill(cId,senderId,m_modifer,true);
                    return;        
                }
                if (targetAPgrenades.find(c_weaponType)> -1){
                    excuteAntiPersonalskill(cId,senderId,m_modifer,c_weaponType);
                    return;        
                }
                if (targetAAgrenades.find(c_weaponType)> -1){
                    excuteAntiArmorskill(cId,senderId,m_modifer,c_weaponType);
                    return;        
                }
            }
        }
    }
	protected void handleMatchEndEvent(const XmlElement@ event) {
        m_ended=true;
    }
    protected void handleResultEvent(const XmlElement@ event) {
		string EventKeyGet = event.getStringAttribute("key");
        SkillModifer m_modifer=SkillModifer();

        if (EventKeyGet == "SOPMOD_lanuch"){
            int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                //string c_armorType=getPlayerEquipmentKey(m_metagame,characterId,4);
                if (player !is null) {
                    excuteSopmodskill(characterId,playerId,m_modifer,character,player);
                }
            }
		}
        else if (EventKeyGet == "416_lanuch"){
            int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
                //string c_armorType=getPlayerEquipmentKey(m_metagame,characterId,4);
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
                if (player !is null) {
                    if(getPlayerEquipmentKey(m_metagame,characterId,0) == "gkw_hk416_3401_mod3_skill.weapon"){
                        excute416modskill(characterId,playerId,m_modifer,character,player,true);
                    }
                    excute416modskill(characterId,playerId,m_modifer,character,player,false);
                }
            }
		}
    }
    void update(float time) {
        if(DontSpamingYourFuckingSkillWhileCoolDownBro.length()>0){
            for(uint a=0;a<DontSpamingYourFuckingSkillWhileCoolDownBro.length();a++){
                DontSpamingYourFuckingSkillWhileCoolDownBro[a].m_time-=time;
                if(DontSpamingYourFuckingSkillWhileCoolDownBro[a].m_time<0){
                    DontSpamingYourFuckingSkillWhileCoolDownBro.removeAt(a);
                }
            }
        }
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

    void addCoolDown(string key,float time,int cId,SkillModifer@ modifer){
        float cdr=modifer.m_cdr;
        float cdm=modifer.m_cdm;
        SkillArray.insertLast(SkillTrigger(cId,(time*cdr-cdm),key));
    }

    void excuteTimerEffect(SkillEffectTimer@ Trigger){
        if (Trigger.m_EffectKey =="MP5MOD3" || Trigger.m_EffectKey =="MP5" || Trigger.m_EffectKey =="AK15MOD3"){
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
    void excuteAN94skill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("AN94",90,characterId,modifer);
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
    void excuteVVskill(int characterId,int playerId,SkillModifer@ modifer){
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "Vector_SKILL1_JP.wav",
                        "Vector_SKILL2_JP.wav",
                        "Vector_SkillC1.wav",
                        "Vector_SkillC2.wav",
                        "Vector_SkillC3.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"VVfirenade.projectile",characterId,factionid,20.0,4.0);
                }
            }
        }
        addCoolDown("VECTOR",15,characterId,modifer);
    }
    void excuteSopmodskill(int characterId,int playerId,SkillModifer@ modifer,const XmlElement@ characterinfo, const XmlElement@ playerinfo){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="SOPMOD") {
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

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            int factionid = characterinfo.getIntAttribute("faction_id");
            c_pos=c_pos.add(Vector3(0,1,0));
            if (checkFlatRange(c_pos,stringToVector3(target),15)){
                CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"SopmodSk_script.projectile",characterId,factionid,60);
            }
            else{
                CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"SopmodSk_script.projectile",characterId,factionid,26.0,6.0);
            }
            array<string> Voice={
            "sopmod1.wav",
            "sopmod2.wav",
            "sopmod3.wav",
            "sopmod4.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
            addCoolDown("SOPMOD",16,characterId,modifer);
        }
    }
    void excute416modskill(int characterId,int playerId,SkillModifer@ modifer,const XmlElement@ characterinfo, const XmlElement@ playerinfo,bool pussyskin){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="HK416MOD3") {
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

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            int factionid = characterinfo.getIntAttribute("faction_id");
            c_pos=c_pos.add(Vector3(0,1,0));
            if(pussyskin){
                if (checkFlatRange(c_pos,stringToVector3(target),15)){
                    CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_hk416_3401.projectile",characterId,factionid,30);
                }
                else{
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_hk416_3401.projectile",characterId,factionid,26.0,6.0);
                }
                array<string> Voice={
                "HK416_Skill4.wav",
                "HK416_Skill5.wav",
                "HK416_Skill6.wav"
                };
                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                SkillArray.insertLast(SkillTrigger(characterId,16,"HK416MOD3"));
            }
            else{
                if (checkFlatRange(c_pos,stringToVector3(target),15)){
                    CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_hk416.projectile",characterId,factionid,30);
                }
                else{
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_hk416.projectile",characterId,factionid,26.0,6.0);
                }
                array<string> Voice={
                "HK416_Skill1.wav",
                "HK416_Skill2.wav",
                "HK416_Skill3.wav"
                };
                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                addCoolDown("HK416MOD3",16,characterId,modifer);
            }
        }
    }
    void excuteJudgeskill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("FF_JUDGE",60,characterId,modifer);
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
    void excuteP22skill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("P22",12,characterId,modifer);
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
    void excuteHS2000skill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("HS2000",12,characterId,modifer);
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
    void excuteMP5skill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("MP5",29,characterId,modifer);
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
    void excuteMP5MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("MP5MOD3",29,characterId,modifer);
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
    void excuteIntruderskill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("FF_INTRUDER",60,characterId,modifer);
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
    void excuteAgentskill(int characterId,int playerId,SkillModifer@ modifer){
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
        addCoolDown("FF_AGENT",60,characterId,modifer);
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
    void excuteDestroyerskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="DESTROYER") {
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
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);

        if (playerinfo.hasAttribute("aim_target")) {
            addCoolDown("DESTROYER",30,characterId,modifer);
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            // Vector3 s_dir = s_pos;
            int factionid = characterinfo.getIntAttribute("faction_id");
            c_pos=c_pos.add(Vector3(0,10.0,0));

            // float dx = s_pos.m_values[0]-c_pos.m_values[0];
            // float dy = s_pos.m_values[2]-c_pos.m_values[2];
            // float ds = sqrt(dx*dx+dy*dy);
            // if(ds<=0.000001f) ds=0.000001f;
            // s_dir.m_values[0] = c_pos.m_values[0] + dx/ds*4;
            // s_dir.m_values[1] = c_pos.m_values[1] + 2;
            // s_dir.m_values[2] = c_pos.m_values[2] + dy/ds*4;

            c_pos.m_values[1] = c_pos.m_values[1] + 16;
            
            //void CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg,Orientation@ rotation){
            //void CreateProjectile_H(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float gspeed,float height){  

            //CreateProjectile(m_metagame,c_pos.add(Vector3(0,-8.0,0)),s_dir.add(Vector3(0,-10.0,0)),"destroyer_skill_body.projectile",characterId,factionid,26.0,26.0);
            //CreateProjectile_H(m_metagame,c_pos.add(Vector3(0,-8.0,0)),s_dir.add(Vector3(0,0.0,0)),"destroyer_skill_body.projectile",characterId,factionid,26.0,12);

            // CreateProjectile(m_metagame,c_pos.add(Vector3(0,-10.0,0)),c_pos,"destroyer_skill_body.projectile",characterId,factionid,80,-0.01);   
            int ix = 0;
            for(ix=1;ix<=6;ix++) {
                CreateProjectile(m_metagame,c_pos,s_pos.add(Vector3(ix*2-7,0,0)),"destroyer_skill.projectile",characterId,factionid,100,0.001);
            }           
            for(ix=1;ix<=6;ix++) {
                CreateProjectile(m_metagame,c_pos,s_pos.add(Vector3(0,0,ix*2-7)),"destroyer_skill.projectile",characterId,factionid,100,0.001);
            }             
            array<string> Voice={
            "Destroyer_buhuo_SKILL02_JP.wav",
            "Destroyer_buhuo_SKILL01_JP.wav",
            "Destroyer_buhuo_MEET_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
            
            
        }
    }
    void excuteExcutionerskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="EXCUTIONER") {
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
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
            c_pos=c_pos.add(Vector3(0,1,0));

            float dx = s_pos.m_values[0]-c_pos.m_values[0];
            float dy = s_pos.m_values[2]-c_pos.m_values[2];
            float ds = sqrt(dx*dx+dy*dy);
            if(ds<=0.000001f) ds=0.000001f;
            dx = dx/ds; dy=dy/ds;
            float dd = 1.2; //同一列相邻弹头的距离
            float tt = 3;   //同一行相邻弹头位置偏移比值
     
            //void CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg,Orientation@ rotation){
            //void CreateProjectile_H(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float gspeed,float height){  

            //CreateProjectile(m_metagame,c_pos.add(Vector3(0,-8.0,0)),s_dir.add(Vector3(0,-10.0,0)),"destroyer_skill_body.projectile",characterId,factionid,26.0,26.0);
            //CreateProjectile_H(m_metagame,c_pos.add(Vector3(0,-8.0,0)),s_dir.add(Vector3(0,0.0,0)),"destroyer_skill_body.projectile",characterId,factionid,26.0,12);
            array<string> Voice={
            "Excutioner_buhuo_SKILL02_JP.wav",
            "Excutioner_buhuo_SKILL03_JP.wav",
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);

            // CreateProjectile(m_metagame,c_pos.add(Vector3(0,-10.0,0)),c_pos,"destroyer_skill_body.projectile",characterId,factionid,80,-0.01);              
            int ix = 5;
            CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*3-dy*dd*3/tt,0,dy*dd*3+dx*dd*3/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));
            CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*4           ,0,dy*dd*4           )),c_pos.add(Vector3(dx*dd*(ix*2)                    ,0,dy*dd*(ix*2)                    )),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));
            CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*3+dy*dd*3/tt,0,dy*dd*3-dx*dd*3/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));

            for(ix=2;ix<=6;ix++)
            {
                CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,1,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),"excutioner_skill.projectile",characterId,factionid,100,0.001);
                CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2)                    ,1,dy*dd*(ix*2)                    )),c_pos.add(Vector3(dx*dd*(ix*2)                    ,0,dy*dd*(ix*2)                    )),"excutioner_skill.projectile",characterId,factionid,100,0.001);
                CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,1,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),"excutioner_skill.projectile",characterId,factionid,100,0.001);
            }


            addCoolDown("EXCUTIONER",30,characterId,modifer);
            
        }
    }
    void excuteBaibaoziskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="ALINA") {
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
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);        
            int factionid = characterinfo.getIntAttribute("faction_id");

            CreateProjectile(m_metagame,c_pos,s_pos,"baibaozi_skill.projectile",characterId,factionid,120,12);

            // array<string> Voice={
            // "Excutioner_buhuo_SKILL02_JP.wav",
            // "Excutioner_buhuo_SKILL03_JP.wav",
            // };
            // playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
            addCoolDown("ALINA",30,characterId,modifer);
            
        }
    }
    void excuteXM8MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="xm8mod3") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "XM8_SKILL2_JP.wav"                     
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_xm8mod3_skill.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_xm8mod3_skill.projectile",characterId,factionid,26.0,5.0);
                    }
                    addCoolDown("xm8mod3",15,characterId,modifer);
                }
            }
        }
    }
    void excuteStg44MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="stg44mod3") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "STG44_SKILL1_JP.wav"                     
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_stg44mod3.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_stg44mod3.projectile",characterId,factionid,26.0,5.0);
                    }
                    addCoolDown("stg44mod3",15,characterId,modifer);
                }
            }
        }
    }
    void excutePPSH41skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="ppsh41") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "PPsh41_SKILL1_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,30.0,5.0);
                    }
                    addCoolDown("ppsh41",15,characterId,modifer);
                }
            }
        }
    }
    void excuteAntiPersonalskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype==weaponname) {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");

                    if(weaponname=="gkw_arx160.weapon") {
                        array<string> Voice={
                            ""
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_xm8.weapon") {
                        array<string> Voice={
                            "XM8_ATTACK_JP.wav" 
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_g3.weapon") {
                        array<string> Voice={
                            ""
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_m4sopmodii.weapon"|| weaponname=="gkw_m4sopmodii_531.weapon") {
                        array<string> Voice={
                            "M4_SOPMOD_II_SKILL2_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_hk416.weapon"|| weaponname=="gkw_hk416_6505.weapon"|| weaponname=="gkw_hk416_537.weapon"|| weaponname=="gkw_hk416_3401.weapon") {
                        array<string> Voice={
                            "HK416_Skill1.wav",
                            "HK416_Skill2.wav",
                            "HK416_Skill3.wav",
                            "HK416_Skill4.wav",
                            "HK416_Skill5.wav",
                            "HK416_Skill6.wav",
                            "HK416_SKILL2_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_ap_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_ap_grenade.projectile",characterId,factionid,26.0,5.0);
                    }
                    addCoolDown(weaponname,15,characterId,modifer);
                }
            }
        }
    }
    void excuteAntiArmorskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        bool ExistQueue = false;
        int j=-1;
        _log("AA grenade ar detected");
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype==weaponname) {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    _log("AA grenade ar spotted");
                    if(weaponname=="gkw_stg44.weapon") {
                        array<string> Voice={
                            "STG44_ATTACK_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_famas.weapon") {
                        array<string> Voice={
                            "FAMAS_ATTACK_JP.wav",
                            "FAMAS_SKILL2_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,26.0,5.0);
                    }
                    addCoolDown(weaponname,15,characterId,modifer);
                }
            }
        }
    }

    void excuteUMP45skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="UMP45") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "ump45_skill1.wav",
                        "ump45_skill2.wav",
                        "ump45_skill3.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"smoke_grenade.projectile",characterId,factionid,30.0,5.0);
                    addCoolDown("UMP45",20,characterId,modifer);
                }
            }
        }
    }
    void excuteM870skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="M870") {
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
        addCoolDown("M870",30,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            int factionid = character.getIntAttribute("faction_id");
            XmlElement c ("command");
            c.setStringAttribute("class", "update_inventory");
            c.setIntAttribute("character_id", characterId); 
            c.setIntAttribute("untransform_count", 5);
            m_metagame.getComms().send(c);
            array<string> Voice={
                "M870P_ATTACK_JP.wav",
                "M870P_PHRASE_JP.wav",
                "M870P_SKILL1_JP.wav",
                "M870P_SKILL2_JP.wav",
                "M870P_SKILL3_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }
    void excutePP19skill(int characterId,int playerId,SkillModifer@ modifer,bool mod3=false){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="pp19") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        ""
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (mod3){
                        addCoolDown("pp19",45,characterId,modifer);
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                        Vector3 c_pos1 = c_pos.add(Vector3(3,0,3));
                        Vector3 c_pos2 = c_pos.add(Vector3(-3,0,-3));
                        spawnSoldier(m_metagame,1,factionid,c_pos1,"136_pp19_smg");
                        spawnSoldier(m_metagame,1,factionid,c_pos2,"136_pp19_smg");
                        CreateProjectile_H(m_metagame,c_pos1,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                        CreateProjectile_H(m_metagame,c_pos2,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                    }
                    else{
                        addCoolDown("pp19",15,characterId,modifer);
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                    }

                }
            }
        }
    }    
    void excuteWerlodskill(int characterId,int playerId,SkillModifer@ modifer,bool mod3=false){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="welrod") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        ""
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos = c_pos.add(Vector3(0,1,0));

                    Vector3 u_pos = getAimUnitPosition(m_metagame,1.2,c_pos,stringToVector3(target));
                    float ori4 = getAimOrientation4(m_metagame,c_pos,stringToVector3(target));

                    spawnVehicle(m_metagame,1,0,u_pos,Orientation(0,1,0,ori4),"gk_werlod_shelter.vehicle");		
                    addCoolDown("welrod",20,characterId,modifer);

                }
            }
        }   
    }  
    void excuteAK15MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="AK15MOD3") {
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
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        ""
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playSoundAtLocation(m_metagame,"defender_fire_FromTTF2.wav",factionid,c_pos,0.9);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"ak15_mod3.projectile",characterId,factionid,220.0);  
					int affectedNumber =0;
					array<int> enemyfaction = {0,1,2,3,4};
					for(int i =0;i<4;i++){
						if (enemyfaction[i] ==factionid){
							enemyfaction.removeAt(i);
						}
					}
					int n=enemyfaction.length-1;
					for(int i=0;i<n;i++){
						array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,c_pos,enemyfaction[i],40.0f);
						affectedNumber += affectedCharacter.length;
					}
					if (affectedNumber <= 5){
                        addCoolDown("AK15MOD3",20,characterId,modifer);
					}
					else if(affectedNumber >= 5 && affectedNumber <= 9){
                        addCoolDown("AK15MOD3",20,characterId,modifer);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        string command = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='ak15_mod3_roar.projectile'" +
                        " position='" + c_pos.toString() + "'"+
				        " character_id='" + characterId + "' />";
                        m_metagame.getComms().send(command);
                        playSoundAtLocation(m_metagame,"ak15mod3_skill_FromELDENRING.wav",factionid,c_pos,0.9);		
					}
					else {
                        addCoolDown("AK15MOD3",10,characterId,modifer);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        string command = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='ak15_mod3_roar.projectile'" +
                        " position='" + c_pos.toString() + "'"+
				        " character_id='" + characterId + "' />";
                        m_metagame.getComms().send(command);		
                        string vestkey="exo_t4.carry_item";
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
                        SkillEffectTimer@ stimer = SkillEffectTimer(characterId,2,"AK15MOD3");
                        stimer.setSkey(vestkey);
                        TimerArray.insertLast(stimer);
                    }
                }
            }
        }   
    }  

    void excuteFnFalskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (SkillArray[i].m_character_id==characterId && SkillArray[i].m_weapontype=="fnfal") {
                ExistQueue=true;
                j=i;
                SkillArray[j].addCharge();
            }
        }
        if (ExistQueue && SkillArray[j].m_charge>3 ){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            sendPrivateMessageKey(m_metagame,playerId,"skillcooldownhint",a);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,26.0,5.0);
                    }
                    
                    if(ExistQueue){
                        return;
                    }
                    else{
                        addCoolDown(weaponname,30,characterId,modifer);
                    }
                }
            }
        }
    }
}


