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
#include "kill_event.as"
#include "event_system.as"
#include "fairy_command.as"
#include "command_skill_info.as"
#include "GFLplayerlist.as"
#include "GFLparameters.as"
 
//Interface Author: NetherCrow
//Contributor: SAIWA K309 Lappland

array<SkillTrigger@> SkillArray;
array<no_delete_data@> No_Delete_DataArray;

class SkillTrigger{
    int m_character_id;
    float m_time;
    float m_inittime;
    string m_weapontype;
    int m_charge=0;
    string m_charge_mode;
    bool m_alert;
    SkillModifer@ m_skillInfo;

    SkillTrigger(int characterId, float time,string weapontype,string charge_mode="normal",bool alert = true){
        m_character_id=characterId;
        m_time=time;
        m_inittime=time;
        m_weapontype=weapontype;
        m_charge_mode=charge_mode;
        m_alert = alert;
    }
    void setSkillInfo(SkillModifer@ skillinfo){
        @m_skillInfo= @skillinfo;
    }

    void setCharge(int num){
        m_charge=num;
    }
    void addCharge(){
        m_charge++;
    }
    void delCharge(){
        m_charge=m_charge-1;
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
    int m_player_id=-1;
    string m_playername="";

    SkillModifer(int pId,string pName){
        m_player_id=pId;
        m_playername=pName;
    }

    void setPlayerId(int num){
        m_player_id=num;
    }
    void setPlayerName(string num){
        m_playername=num;
    }    

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
    protected GameMode@ m_metagame;
    protected int m_DummyCallID=0;

    array<SkillEffectTimer@> TimerArray;
    array<SpamAvoider@> DontSpamingYourFuckingSkillWhileCoolDownBro;


	protected bool m_ended;

	// --------------------------------------------
	CommandSkill(GameMode@ metagame) {
		@m_metagame = @metagame;
        m_ended = false;
	}

    protected void handleChatEvent(const XmlElement@ event) {
        string message = event.getStringAttribute("message");
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
			if (info is null) return;
            int cId = info.getIntAttribute("character_id");
            string pname = info.getStringAttribute("name");
            string c_weaponType = getPlayerWeaponFromList(pname,0);
            if(c_weaponType == default_string)_log("WARN: commandskill.as: handleChatEvent(): player weapon is nan.");
            string c_armorType = getPlayerWeaponFromList(pname,3);
            if(c_armorType == default_string)_log("WARN: commandskill.as: handleChatEvent(): player weapon is nan.");

            SkillModifer@ m_modifer=SkillModifer(senderId,pname);

            // 不受任何减少时间效果影响的技能
            if (Weapon_free_of_other_cooldown.find(c_weaponType)== -1){

                if (startsWith(c_armorType,'chip_b_t6')){
                    m_modifer.setCooldownMinus(5.0);
                }

                if (startsWith(c_armorType,'chip_a_t6')){
                    m_modifer.setCooldownReduction(0.8);
                }

                if (startsWith(c_armorType,'gk_persica')){
                    m_modifer.setCooldownReduction(0.8);
                }

                if (startsWith(c_armorType,'god_vest.carry_item')){
                    m_modifer.setCooldownReduction(0.1);
                    m_modifer.setCooldownMinus(30.0);
                }
            }
            
            if (AR_grenade_AntiArmor.find(c_weaponType)> -1){
                excuteAntiArmorskill(cId,senderId,m_modifer,c_weaponType);
                return;
            }

            if (AR_grenade_AntiPersonal.find(c_weaponType)> -1){
                excuteAntiPersonalskill(cId,senderId,m_modifer,c_weaponType);
                return;
            }

            switch(int(commandSkillIndex[c_weaponType]))
            {
                case 0:{break;}
                case 1:{excuteAN94skill(cId,senderId,m_modifer);break;}
                case 2:{excuteFirenadeskill(cId,senderId,m_modifer,c_weaponType);break;}
                case 3:{excuteJusticeskill(cId,senderId,m_modifer);break;}
                case 4:{excuteMP5skill(cId,senderId,m_modifer);break;}
                case 5:{excuteMP5MOD3skill(cId,senderId,m_modifer);break;}
                case 6:{excuteP22skill(cId,senderId,m_modifer);break;}
                case 7:{excuteHS2000skill(cId,senderId,m_modifer);break;}
                case 8:{excuteIntruderskill(cId,senderId,m_modifer);break;}
                case 9:{excuteAgentskill(cId,senderId,m_modifer);break;}
                case 10:{excuteDestroyerskill(cId,senderId,m_modifer);break;}
                case 11:{excuteExcutionerskill(cId,senderId,m_modifer);break;}
                case 12:{excuteBaibaoziskill(cId,senderId,m_modifer);break;}
                case 13:{excuteG3mod3skill(cId,senderId,m_modifer);break;}
                case 14:{excuteUMP45skill(cId,senderId,m_modifer);break;}
                case 15:{excuteM870skill(cId,senderId,m_modifer);break;}
                case 16:{excutePP19skill(cId,senderId,m_modifer);break;}
                case 17:{excutePP19skill(cId,senderId,m_modifer,true);break;}
                case 18:{excuteAK15MOD3skill(cId,senderId,m_modifer);break;}
                case 19:{excuteXM8MOD3skill(cId,senderId,m_modifer);break;}
                case 20:{excuteStg44MOD3skill(cId,senderId,m_modifer);break;}
                case 21:{excuteWerlodModskill(cId,senderId,m_modifer,true);break;}
                case 22:{excuteFnFalskill(cId,senderId,m_modifer);break;}
                case 23:{excuteM4SOPMODIIMOD3skill(cId,senderId,m_modifer);break;}
                case 24:{excutePPSH41skill(cId,senderId,m_modifer);break;}
                case 25:{excutePPSH41MOD3skill(cId,senderId,m_modifer);break;}
                case 26:{excuteFO12skill(cId,senderId,m_modifer);break;}
                case 27:{excuteFlashbangskill(cId,senderId,m_modifer,c_weaponType);break;}
                case 28:{excuteUMP9skill(cId,senderId,m_modifer);break;}
                case 29:{excuteMab38skill(cId,senderId,m_modifer);break;}
                // case 30:{excuteAK12SEskill(cId,senderId,m_modifer);break;}
                case 31:{excutePPKMOD3skill(cId,senderId,m_modifer);break;}
                case 32:{excuteMLEskill(cId,senderId,m_modifer);break;}
                case 33:{excuteMG4MOD3skill(cId,senderId,m_modifer);break;}
                case 34:{excuteLiuRFskill(cId,senderId,m_modifer);break;}
                case 35:{excuteSAT8skill(cId,senderId,m_modifer);break;}
                case 36:{excuteHK416mod3skill(cId,senderId,m_modifer);break;}
                case 37:{excuteHK416mod3skill(cId,senderId,m_modifer,true);break;}
                case 38:{excuteGrenadeSkill(cId,senderId,m_modifer,c_weaponType);break;}
                case 39:{excuteAlchemistskill(cId,senderId,m_modifer);break;}
                case 40:{excute88typeskill(cId,senderId,m_modifer);break;}
                case 41:{excute88typeskill(cId,senderId,m_modifer,true);break;}
                case 42:{excute88typeGUNDAMskill(cId,senderId,m_modifer);break;}
                case 43:{excuteM200skill(cId,senderId,m_modifer);break;}
                case 44:{excuteCZ75skill(cId,senderId,m_modifer);break;}
                // case 45:{excutSuperSASSSkill(cId,senderId,m_modifer);break;}
                case 46:{excuteG41Onlyskill(cId,senderId,m_modifer);break;}
                case 47:{excuteUMP45MOD3skill(cId,senderId,m_modifer);break;}
                case 48:{excuteWeaverskill(cId,senderId,m_modifer);break;}
                case 49:{excuteM1928A1skill(cId,senderId,m_modifer);break;}
                case 50:{excuteUZImod3skill(cId,senderId,m_modifer);break;}
                case 51:{excuteSniperSkill_Antiperson(cId,senderId,m_modifer,c_weaponType);break;}
                case 52:{excuteCarcano1938(cId,senderId,m_modifer);break;}
                case 53:{excuteSniperSkill_Pos(cId,senderId,m_modifer,c_weaponType);break;}
                case 54:{excuteF1skill(cId,senderId,m_modifer);break;}
                case 55:{excuteBBSRobotskill(cId,senderId,m_modifer);break;}
                case 56:{excuteSVDEXskill(cId,senderId,m_modifer);break;}
                case 57:{excuteHK416Agentskill(cId,senderId,m_modifer);break;}
                case 58:{excuteErmaskill(cId,senderId,m_modifer);break;}
                case 59:{excute64typemod3Skill(cId,senderId,m_modifer);break;}
                case 60:{excuteZasM21Skill(cId,senderId,m_modifer);break;}
                case 61:{excuteC96MODSkill(cId,senderId,m_modifer);break;}
                case 62:{excute_AGS30_Skill(cId,senderId,m_modifer);break;}
                case 63:{excute_QLZ04_Skill_Smoke(cId,senderId,m_modifer);break;}
                case 64:{excute_QLZ04_Skill_Fire(cId,senderId,m_modifer);break;}
                case 65:{excuteWerlodskill(cId,senderId,m_modifer);break;}
                case 66:{excutePA15skill(cId,senderId,m_modifer);break;}
                case 67:{excuteNagantM1895skill(cId,senderId,m_modifer);break;}
                case 68:{excuteMosinNagant(cId,senderId,m_modifer);break;}
                case 69:{excuteKar98k(cId,senderId,m_modifer);break;}
                case 70:{excuteGM6Lynx(cId,senderId,m_modifer);break;}
                case 71:{excuteM1911skill(cId,senderId,m_modifer);break;}
                case 72:{excuteM1911mod3skill(cId,senderId,m_modifer);break;}
                case 73:{excuteHunterskill(cId,senderId,m_modifer);break;}
                case 74:{excuteDreamerskill(cId,senderId,m_modifer);break;}
                case 75:{excuteStenSterlingskill(cId,senderId,m_modifer,c_weaponType);break;}
                case 77:{excuteOwenskill(cId,senderId,m_modifer);break;}
                case 78:{excuteM1897MOD3skill(cId,senderId,m_modifer);break;}
                case 79:{excuteType82skill(cId,senderId,m_modifer);break;}
                default:
                    break;
            }
        }

        if (checkCommand(message,"redeploy") || message=="/re" || message=="/RE"){
            for(uint a=0;a<DontSpamingYourFuckingSkillWhileCoolDownBro.length();a++){
                if(DontSpamingYourFuckingSkillWhileCoolDownBro[a].m_playerid==senderId) return;
            }
            DontSpamingYourFuckingSkillWhileCoolDownBro.insertLast(SpamAvoider(senderId));     
            const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
                int cId = info.getIntAttribute("character_id");
                string pname = info.getStringAttribute("name");
                SkillModifer@ m_modifer=SkillModifer(senderId,pname);

                bool ExistQueue = false;
                int j =-1;
                for (uint i=0;i<SkillArray.length();i++){
                    if (InCooldown(cId,m_modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="REDEPLOY") {
                        ExistQueue=true;
                        j=i;
                    }
                }
                if (ExistQueue){
                    dictionary a;
                    a["%time"] = ""+SkillArray[j].m_time;
                    sendPrivateMessageKey(m_metagame,senderId,"redeploycooldownhint",a);
                    return;
                }

                killCharacter(m_metagame, cId, true);
                addCooldown("REDEPLOY",120,cId,m_modifer);
            }                   
        }
    }
	protected void handleMatchEndEvent(const XmlElement@ event) {
        m_ended=true;
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
                    if(SkillArray[a].m_weapontype =="REDEPLOY"){
                        sendFactionMessageKeySaidAsCharacter(m_metagame,0,SkillArray[a].m_character_id,"redeploycooldowndone");
                        SkillArray.removeAt(a);
                        continue;
                    }
                    if(SkillArray[a].m_charge_mode=="normal"){
                        if(SkillArray[a].m_alert){
                            playPrivateSound(m_metagame,"skilldone.wav",SkillArray[a].m_skillInfo.m_player_id);
                        }
                        sendFactionMessageKeySaidAsCharacter(m_metagame,0,SkillArray[a].m_character_id,"skillcooldowndone");
                        notify(m_metagame, "Hint - Skill Cooldown Done",dictionary(), "misc", SkillArray[a].m_skillInfo.m_player_id, false, "", 1.0);
                        SkillArray.removeAt(a);
                    }
                    else if (SkillArray[a].m_charge_mode=="nohint"){
                        SkillArray.removeAt(a);
                    }
                    else if (SkillArray[a].m_charge_mode=="constant"){
                        sendFactionMessageKeySaidAsCharacter(m_metagame,0,SkillArray[a].m_character_id,"skillcooldowndone");
                        notify(m_metagame, "Hint - Skill Cooldown Done",dictionary(), "misc", SkillArray[a].m_skillInfo.m_player_id, false, "", 1.0);
                        if (SkillArray[a].m_charge==0){
                            SkillArray.removeAt(a);
                        }
                        else{
                            SkillArray[a].delCharge();
                            SkillArray[a].m_time=SkillArray[a].m_inittime;
                        }
                    }
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

    void addCooldown(string key,float time,int cId,SkillModifer@ modifer,string charge_mode="normal",bool alert =true){
        float cdr=modifer.m_cdr;
        float cdm=modifer.m_cdm;
        SkillTrigger@ cooldown = SkillTrigger(cId,max((time*cdr-cdm),0.1),key,charge_mode,alert);
        cooldown.setSkillInfo(modifer);
        SkillArray.insertLast(cooldown);
    }

    bool tryaddChargeCount(string key,int cId,SkillModifer@ modifer,bool NoRemoveOnDeath){
        int j = getCooldownIndex(cId,modifer,key,NoRemoveOnDeath);
        if(j==-1)return false;
        SkillArray[j].addCharge();
        return true;
    }

    bool existCooldown(int cId, SkillModifer@ modifer,SkillTrigger@ queue,bool NoRemoveOnDeath=false){
        if(queue.m_character_id==cId) return true;
        if(NoRemoveOnDeath){
            if(queue.m_skillInfo.m_playername==modifer.m_playername){
                return true;
            }
        }
        return false;
    }

    bool InCooldown(int cId, SkillModifer@ modifer,SkillTrigger@ queue,bool NoRemoveOnDeath=false,string charge_mode="normal",int charge_jud_num=0){
        if(charge_mode=="normal" || charge_mode=="nohint") return existCooldown(cId,modifer,queue,NoRemoveOnDeath);
        else if(charge_mode=="constant" && queue.m_charge>=charge_jud_num){
            return existCooldown(cId,modifer,queue,NoRemoveOnDeath);
        }
        return false;
    }

    bool checkCooldown(int characterId,SkillModifer@ modifer,string checkstr,bool NoRemoveOnDeath=false,string charge_mode="normal",int charge_jud_num=0)
    {
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],NoRemoveOnDeath,charge_mode,charge_jud_num) && SkillArray[i].m_weapontype== checkstr ) {
                return true;
            }
        }
        return false;
    }

    int getCooldownIndex(int characterId,SkillModifer@ modifer,string checkstr,bool NoRemoveOnDeath=false)
    {
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (existCooldown(characterId,modifer,SkillArray[i],NoRemoveOnDeath) && SkillArray[i].m_weapontype==checkstr) {
                j=i;
            }
        }
        return j;
    }

    bool refreshCooldown(int characterId,SkillModifer@ modifer,string checkstr,bool NoRemoveOnDeath=false)
    {
        int j = getCooldownIndex(characterId,modifer,checkstr,NoRemoveOnDeath);
        if (j != -1 )
        {
            SkillArray[j].m_time=SkillArray[j].m_inittime;
            return true;
        }
        else
        {
            return false;
        }
    }

    string getCooldown(int characterId,SkillModifer@ modifer,string checkstr,bool NoRemoveOnDeath=false)
    {
        int j = getCooldownIndex(characterId,modifer,checkstr,NoRemoveOnDeath);

        if (j != -1 )
        {
            return ""+SkillArray[j].m_time;
        }
        else
        {
            return "";
        }
    }

    float getCooldownNum(int characterId,SkillModifer@ modifer,string checkstr,bool NoRemoveOnDeath=false)
    {
        int j = getCooldownIndex(characterId,modifer,checkstr,NoRemoveOnDeath);

        if (j != -1 )
        {
            return SkillArray[j].m_time;
        }
        else
        {
            return -1.0;
        }
    }

    bool canCastSkill(const XmlElement@ character){
        int death = character.getIntAttribute("dead");
        int wound = character.getIntAttribute("wounded");
        if (death == 1 || wound == 1) return false;
        return true;
    }

    string getCooldownFromIndex(int j)
    {
        return ""+SkillArray[j].m_time;
    }

    bool excuteCooldownCheck(GameMode@ metagame,int characterId,SkillModifer@ modifer,int pId,string checkstr,bool NoRemoveOnDeath=false,string charge_mode="normal",int charge_jud_num=0)
    {
        if(!checkCooldown(characterId,modifer,checkstr,NoRemoveOnDeath,charge_mode,charge_jud_num))return false;
        string lefttime = getCooldown(characterId,modifer,checkstr,NoRemoveOnDeath);
        if(lefttime == "") return false;
        dictionary a;
        a["%time"] = lefttime;
        notify(metagame, "Hint - Skill Cooldown Hint", a, "misc", pId, false, "", 1.0);
        return true;
    }

    void excuteTimerEffect(SkillEffectTimer@ Trigger){

        // MP5无敌甲
        if (Trigger.m_EffectKey =="MP5MOD3" || Trigger.m_EffectKey =="MP5" || Trigger.m_EffectKey =="AK15MOD3"){
            if(Trigger.m_specialkey1=="" ||
               Trigger.m_specialkey1=="immunity_thompson.carry_item"
            ){
                Trigger.m_specialkey1="exo_t5_16lab.carry_item";
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
        if (Trigger.m_EffectKey =="M1928A1"){
            if(Trigger.m_specialkey1=="" ||
               Trigger.m_specialkey1=="immunity_mp5.carry_item"
            ){
                Trigger.m_specialkey1="exo_t5_16lab.carry_item";
            }
            editPlayerVest(m_metagame,Trigger.m_character_id,Trigger.m_specialkey1,4);
            deleteItemInBackpack(m_metagame,Trigger.m_character_id,"carry_item","immunity_thompson.carry_item");
            deleteItemInStash(m_metagame,Trigger.m_character_id,"carry_item","immunity_thompson.carry_item");
        }
        //破坏者，法官，
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

    void excuteAN94skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"AN94",true)) return;
        addCooldown("AN94",30,characterId,modifer);
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        if(info is null) return;
        int fID = info.getIntAttribute("faction_id");
        string c_pos = info.getStringAttribute("position");
        spawnSoldier(m_metagame,1,fID,c_pos,"defy_ak12_ar");
        sendPrivateMessage(m_metagame,playerId,"Defy AK-12 summoned");
        playSoundAtLocation(m_metagame,"AN94mod3_skill.wav",fID,c_pos,0.9);
    }
    void excuteAK12SEskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="AK12SE") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        addCooldown("AK12SE",120,characterId,modifer);
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        if(info is null) return;
        int fID = info.getIntAttribute("faction_id");
        string c_pos = info.getStringAttribute("position");
        spawnSoldier(m_metagame,4,fID,c_pos,"defy_aegis_shield");
        spawnSoldier(m_metagame,2,fID,c_pos,"defy_cyclops_sg");
        spawnSoldier(m_metagame,2,fID,c_pos,"defy_cyclops_sghe");
        playSoundAtLocation(m_metagame,"AK12_ATTACK_JP.wav",fID,c_pos,0.9);
    }
    void excuteFirenadeskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FIRENADE")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    if(weaponname=="gkw_vector.weapon" || weaponname=="gkw_vector_549.weapon" || weaponname=="gkw_vector_549_skill.weapon" || weaponname=="gkw_vector_1901.weapon" || weaponname =="gkw_vector_hellfire_sticky.weapon") {
                        array<string> Voice={
                            "Vector_SKILL1_JP.wav",
                            "Vector_SKILL2_JP.wav",
                            "Vector_SkillC1.wav",
                            "Vector_SkillC2.wav",
                            "Vector_SkillC3.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    if(weaponname=="gkw_vz61.weapon" || weaponname=="gkw_vz61_only.weapon") {
                        array<string> Voice={
                            "VZ61_SKILL1_JP.wav",
                            "VZ61_SKILL2_JP.wav",
                            "VZ61_SKILL3_JP.wav"                            
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    if(weaponname=="gkw_mp40.weapon" || weaponname=="gkw_mp40_902.weapon") {
                        array<string> Voice={
                            "MP40_SKILL1_JP.wav",
                            "MP40_SKILL2_JP.wav",
                            "MP40_PHRASE_JP.wav"                            
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    if(weaponname=="gkw_uzi.weapon" || weaponname=="gkw_uzi_7907.weapon") {
                        array<string> Voice={
                            "MicroUZI_SKILL1_JP.wav",
                            "MicroUZI_SKILL2_JP.wav",
                            "MicroUZIMod_SKILL1_JP.wav",
                            "MicroUZIMod_SKILL2_JP.wav",
                            "MicroUZIMod_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    if(weaponname=="gkw_klin.weapon") {
                        array<string> Voice={
                            "KLIN_SKILL1_JP.wav",
                            "KLIN_SKILL2_JP.wav",
                            "KLIN_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    if(weaponname=="gkw_kp31mod3.weapon" || weaponname=="gkw_kp31mod3_310.weapon" || weaponname=="gkw_kp31mod3_3101.weapon" ) {
                        array<string> Voice={
                            "KP31_SKILL1_JP.wav",
                            "KP31_SKILL2_JP.wav",
                            "KP31_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }                    
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),16)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"firenade_Vector.projectile",characterId,factionid,50);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"firenade_Vector.projectile",characterId,factionid,26.0,4.0);
                    }
                }
            }
        }
        if(weaponname=="gkw_kp31mod3.weapon" || weaponname=="gkw_kp31mod3_310.weapon" || weaponname=="gkw_kp31mod3_3101.weapon"){
            addCooldown("FIRENADE",12,characterId,modifer);
        }
        else{
            addCooldown("FIRENADE",15,characterId,modifer);
        }
    }
    void excuteJudgeskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_JUDGE")) return;
        addCooldown("FF_JUDGE",40,characterId,modifer);
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"P22")) return;
        addCooldown("P22",12,characterId,modifer);
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"HS2000")) return;
        addCooldown("HS2000",12,characterId,modifer);
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"MP5")) return;
        addCooldown("MP5",25,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        string vestkey="exo_t5_16lab.carry_item";
        if (character !is null) {
            vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
            if (vestkey=="immunity_mp5.carry_item" || vestkey==""){
                vestkey="exo_t5_16lab.carry_item";
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"MP5MOD3")) return;
        addCooldown("MP5MOD3",25,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        string vestkey="exo_t5_16lab.carry_item";
        if (character !is null) {
            vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
            if (vestkey=="immunity_mp5.carry_item" || vestkey==""){
                vestkey=="exo_t5_16lab.carry_item";
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
    void excuteM1928A1skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"M1928A1")) return;
        addCooldown("M1928A1",45,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        string vestkey="exo_t5_16lab.carry_item";
        if (character !is null) {
            vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
            if (vestkey=="immunity_thompson.carry_item" || vestkey==""){
                vestkey="exo_t5_16lab.carry_item";
            }
            XmlElement c ("command");
            c.setStringAttribute("class", "update_inventory");
            c.setIntAttribute("container_type_id", 4);
            c.setIntAttribute("character_id", characterId); 
            {
                XmlElement k("item");
                k.setStringAttribute("class", "carry_item");
                k.setStringAttribute("key", "immunity_thompson.carry_item");
                c.appendChild(k);
            }            
            m_metagame.getComms().send(c);
            deleteItemInBackpack(m_metagame,characterId,"carry_item","immunity_thompson.carry_item");
            SkillEffectTimer@ stimer = SkillEffectTimer(characterId,10,"M1928A1");
            stimer.setSkey(vestkey);
            TimerArray.insertLast(stimer);
            array<string> Voice={
                "M1928A1_SKILL1_JP.wav",
                "M1928A1_SKILL2_JP.wav",
                "M1928A1_SKILL3_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
        }
    }    
    void excuteIntruderskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_INTRUDER",true)) return;
        addCooldown("FF_INTRUDER",45,characterId,modifer);
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_AGENT",true)) return;
        addCooldown("FF_AGENT",60,characterId,modifer);
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
                    spawnSoldier(m_metagame,1,0,target,"Dummy_Agent");
					
					target0.m_values[2] = target0.m_values[2]+2*yy1;
					target = target0.toString();
                    spawnSoldier(m_metagame,1,0,target,"Dummy_Agent");

					target0.m_values[0] = target0.m_values[0]+3*xx1;
					target0.m_values[2] = target0.m_values[2]-yy1;
					target = target0.toString();					
                    spawnSoldier(m_metagame,1,0,target,"Dummy_Agent");					
                }
                array<string> Voice={
                    "Agent_buhuo_SKILL02_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,0,character.getStringAttribute("position"),1);
            }
        }
    }
    void excuteDestroyerskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_DESTROYER")) return;
        addCooldown("FF_DESTROYER",25,characterId,modifer);
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        if (!playerinfo.hasAttribute("aim_target")) return;

        string target = playerinfo.getStringAttribute("aim_target");
        Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
        Vector3 s_pos = stringToVector3(target);
        int factionid = characterinfo.getIntAttribute("faction_id");
        c_pos=c_pos.add(Vector3(0,10.0,0));
        c_pos.m_values[1] = c_pos.m_values[1] + 16;
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

    void excuteExcutionerskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_EXCUTIONER")) return;
        addCooldown("FF_EXCUTIONER",25,characterId,modifer);
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        if (!playerinfo.hasAttribute("aim_target")) return;
        string target = playerinfo.getStringAttribute("aim_target");
        Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
        Vector3 s_pos = stringToVector3(target);
        int factionid = characterinfo.getIntAttribute("faction_id");
        c_pos=c_pos.add(Vector3(0,1,0));

        healCharacter(m_metagame,characterId,4);

        float dx = s_pos.m_values[0]-c_pos.m_values[0];
        float dy = s_pos.m_values[2]-c_pos.m_values[2];
        float ds = sqrt(dx*dx+dy*dy);
        if(ds<=0.000001f) ds=0.000001f;
        dx = dx/ds; dy=dy/ds;
        float dd = 1.2; //同一列相邻弹头的距离
        float tt = 3;   //同一行相邻弹头位置偏移比值
    
        array<string> Voice={
        "Excutioner_buhuo_SKILL02_JP.wav",
        "Excutioner_buhuo_SKILL03_JP.wav",
        };
        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        // playAnimationKey(m_metagame,characterId,"excution_skill",false,false);

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
    }
    void excuteBaibaoziskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_ALINA",true,"constant",4)) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if(characterinfo !is null){
            const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
            if(playerinfo !is null){
                if (playerinfo.hasAttribute("aim_target")) {
                    if(!tryaddChargeCount("FF_ALINA",characterId,modifer,true)){
                        // _log("no new charge");
                        addCooldown("FF_ALINA",15,characterId,modifer,"constant");
                    }
                    string target = playerinfo.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    s_pos = s_pos.add(Vector3(0,2,0));
                    c_pos = c_pos.add(Vector3(0,2,0));
                    c_pos = c_pos.add((getAimUnitVector(2,c_pos,s_pos)));
                    int factionid = characterinfo.getIntAttribute("faction_id");

                    CreateDirectProjectile_T(m_metagame,c_pos,s_pos,'baibaozi_skill.projectile',characterId,factionid,0.4); 
                    // array<string> Voice={
                    // "Excutioner_buhuo_SKILL02_JP.wav",
                    // "Excutioner_buhuo_SKILL03_JP.wav",
                    // };
                    // playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                }  
            }
          
        }
    }
    void excuteXM8MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"xm8mod3")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (!canCastSkill(character)) return;
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "XM8_SKILL2_JP.wav"                     
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    if (checkFlatRange(c_pos,s_pos,15)){
                        CreateDirectProjectile(m_metagame,c_pos,s_pos,"40mm_xm8mod3_skill.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,s_pos,"40mm_xm8mod3_skill.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("xm8mod3",15,characterId,modifer);
                }
            }
        }
    }
    void excuteStg44MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"stg44mod3")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "STG44Mod_SKILL1_JP.wav",
                        "STG44Mod_SKILL2_JP.wav",
                        "STG44Mod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.3);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_stg44mod3.projectile",characterId,factionid,45);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_stg44mod3.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("stg44mod3",15,characterId,modifer);
                }
            }
        }
    }
    void excutePPSH41skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"ppsh41")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    array<string> Voice={
                        "PPsh41_SKILL1_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    addCooldown("ppsh41",15,characterId,modifer);

                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,50.0,5.0);
                    }
                }
            }
        }
    }

    void excutePPSH41MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"ppsh41")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    int index = findNodeleteDataIndex(modifer.m_playername,"ppsh41");
                    string player_name = player.getStringAttribute("name");
                    int medal_num = 0;
                    if (index>=0)
                    {
                        medal_num = No_Delete_DataArray[index].m_num;
                    }
                    medal_num = min(medal_num,3);
                    // _log("现在有" + medal_num + "枚永久勋章");

                    int temp_medal_num = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"ppsh41");
                    medal_num += temp_medal_num;

                    // _log("现在有" + medal_num + "枚勋章");

                    g_playerInfo_Buck.addKillSkillCountbyName(player_name,"ppsh41");

                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);

                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    array<string> Voice={
                        "PPsh41Mod_SKILL1_JP.wav",
                        "PPsh41Mod_SKILL2_JP.wav",
                        "PPsh41Mod_SKILL3_JP.wav",
                        "PPsh41Mod_ATTACK_JP.wav",
                        "PPsh41Mod_MEET_JP.wav",
                        "PPsh41Mod_DEFENSE_JP.wav"
                    };                        
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);

                    if(medal_num <= 2)
                    {
                        addCooldown("ppsh41",15,characterId,modifer);
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,60);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,50.0,5.0);
                        }                        
                    }
                    else if(medal_num <= 3)
                    {
                        addCooldown("ppsh41",15,characterId,modifer);
                        healCharacter(m_metagame,characterId,1);
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,60);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41.projectile",characterId,factionid,50.0,5.0);
                        }                        
                    }
                    else if(medal_num <= 4)
                    {
                        addCooldown("ppsh41",15,characterId,modifer);
                        healCharacter(m_metagame,characterId,1);
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,60);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,50.0,5.0);
                        }                        
                    }
                    else if(medal_num <= 5)
                    {
                        addCooldown("ppsh41",12,characterId,modifer);
                        healCharacter(m_metagame,characterId,2);
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,60);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,50.0,5.0);
                        }                        
                    }
                    else if(medal_num > 5)
                    {
                        medal_num = min(10,medal_num);
                        addCooldown("ppsh41",12,characterId,modifer);
                        healCharacter(m_metagame,characterId,2);
                        if(rand(0.0f,1.0f) <= ((medal_num-5)*0.2))
                        {
                            if (checkFlatRange(c_pos,stringToVector3(target),15)){
                                CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_rangeup.projectile",characterId,factionid,60);
                            }
                            else{
                                CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_rangeup.projectile",characterId,factionid,50.0,5.0);
                            }                        
                        }
                        else
                        {
                            if (checkFlatRange(c_pos,stringToVector3(target),15)){
                                CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,60);
                            }
                            else{
                                CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_ppsh41_dmgup.projectile",characterId,factionid,50.0,5.0);
                            }                                
                        }
                        if(medal_num > 6)
                        {
                            if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"ppsh41_summon")) return;
                            addCooldown("ppsh41_summon",60,characterId,modifer);
                            spawnSoldier(m_metagame,1,factionid,c_pos,"smg_21_ppsh_mod3");
                        }
                    }
                }
            }
        }
    }

    void excuteAntiArmorskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"AAgrenade")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    
                    if(weaponname=="gkw_arx160.weapon") {
                        array<string> Voice={
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);                      
                    }
                    if(weaponname=="gkw_vhs.weapon" || weaponname=="gkw_vhs_562.weapon") {
                        array<string> Voice={
                            "VHS_SKILL1_JP.wav",
                            "VHS_SKILL2_JP.wav",
                            "VHS_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);                      
                    }                    
                    if(weaponname=="gkw_xm8.weapon"||weaponname=="gkw_xm8_5606.weapon") {
                        array<string> Voice={
                            "XM8_ATTACK_JP.wav" 
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);
                    }
                    if(weaponname=="gkw_g3.weapon") {
                        array<string> Voice={
                            "G3_SKILL1_JP.wav",
                            "G3_SKILL2_JP.wav",
                            "G3_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);                        
                    }
                    if(weaponname=="gkw_m4sopmodii.weapon"|| weaponname=="gkw_m4sopmodii_531.weapon" || weaponname=="gkw_m4sopmodii_551.weapon"|| weaponname=="gkw_m4sopmodii_4507.weapon" ) {
                        array<string> Voice={
                            "sopmod1.wav",
                            "sopmod2.wav",
                            "sopmod3.wav",
                            "sopmod4.wav",
                            "sopmod5.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_hk416.weapon"|| weaponname=="gkw_hk416_6505.weapon"|| weaponname=="gkw_hk416_537.weapon"|| weaponname=="gkw_hk416_805.weapon") {
                        array<string> Voice={
                            "HK416_Skill1.wav",
                            "HK416_Skill2.wav",
                            "HK416_Skill3.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_hk416_3401.weapon") {
                        array<string> Voice={
                            "HK416_Skill4.wav",
                            "HK416_Skill5.wav",
                            "HK416_Skill6.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }                    
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    Vector3 s_pos = stringToVector3(target);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("AAgrenade",15,characterId,modifer);
                }
            }
        }
    }
    void excuteAntiPersonalskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"APgrenade")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    // _log("AA grenade ar spotted");
                    if(weaponname=="gkw_stg44.weapon") {
                        array<string> Voice={
                            "STG44_ATTACK_JP.wav",
                            "STG44_SKILL2_JP.wav",
                            "STG44_SKILL1_JP.wav"
                        };
                        playSoundAtLocation(m_metagame,"gp25_fire_FromSQUAD.wav",factionid,c_pos,1.0);
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_famas.weapon") {
                        array<string> Voice={
                            "FAMAS_ATTACK_JP.wav",
                            "FAMAS_SKILL2_JP.wav"
                        };
                        playSoundAtLocation(m_metagame,"gp25_fire_FromSQUAD.wav",factionid,c_pos,1.0);
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_k11_20mm_impact.weapon" || weaponname=="gkw_k11_ar.weapon") {
                        array<string> Voice={
                            "K11_SKILL1_JP.wav",
                            "K11_SKILL2_JP.wav",
                            "K11_SKILL3_JP.wav"
                        };
                        playSoundAtLocation(m_metagame,"gp25_fire_FromSQUAD.wav",factionid,c_pos,1.15);
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }
                    if(weaponname=="gkw_56-1type.weapon") {
                        array<string> Voice={
                            "56-1type_SKILL1_JP.wav",
                            "56-1type_SKILL2_JP.wav",
                            "56-1type_SKILL3_JP.wav"
                        };
                        playSoundAtLocation(m_metagame,"gp25_fire_FromSQUAD.wav",factionid,c_pos,1.0);
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                    }                    
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    Vector3 s_pos = stringToVector3(target);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_ap_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_ap_grenade.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("APgrenade",15,characterId,modifer);
                }
            }
        }
    }

    void excuteUMP45skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="UMP45") {
                ExistQueue=true;
                j=i;
                if (ExistQueue && SkillArray[j].m_charge >=3){
                    dictionary a;
                    a["%time"] = ""+SkillArray[j].m_time;
                    notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
                    //_log("skill cooldown" + SkillArray[j].m_time);
                    return;
                }
                if(SkillArray[j].m_charge <3){
                    SkillArray[j].addCharge();
                }                
            }
        }        
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    if(!ExistQueue){
                        addCooldown("UMP45",20,characterId,modifer,"constant"); 
                    }
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
                    c_pos=c_pos.add(Vector3(0,1.8,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"smoke_grenade.projectile",characterId,factionid,30.0,5.0);
                }
            }
        }
    }
    void excuteUMP45MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="UMP45MOD3") {
                ExistQueue=true;
                j=i;
                if (ExistQueue && SkillArray[j].m_charge >=3){
                    dictionary a;
                    a["%time"] = ""+SkillArray[j].m_time;
                    notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
                    //_log("skill cooldown" + SkillArray[j].m_time);
                    return;
                }
                if(SkillArray[j].m_charge <3){
                    SkillArray[j].addCharge();
                }                
            }
        }        

        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    if(!ExistQueue){
                        addCooldown("UMP45MOD3",20,characterId,modifer,"constant");
                    }
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
                    c_pos=c_pos.add(Vector3(0,1.8,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"ump45mod3_smoke_grenade.projectile",characterId,factionid,30.0,1.0);
                }
            }
        }
    }
    void excuteM870skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"M870")) return;
        addCooldown("M870",30,characterId,modifer);
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
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"PP-19")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "PP19_skill1.wav",
                        "PP19_skill2.wav",
                        "PP19_skill3.wav",
                        "PP19_skill4.wav",
                        "PP19_skill5.wav",
                        "PP19_skill6.wav",
                        "PP19_skill7.wav",
                        "PP19_skill8.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (mod3){
                        addCooldown("PP-19",45,characterId,modifer);
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                        Vector3 c_pos1 = c_pos.add(Vector3(3,0,3));
                        Vector3 c_pos2 = c_pos.add(Vector3(-3,0,-3));
                        Vector3 c_pos3 = c_pos.add(Vector3(-3,0,3));
                        Vector3 c_pos4 = c_pos.add(Vector3(3,0,-3));                        
                        spawnSoldier(m_metagame,1,factionid,c_pos1,"smg_136_pp19");
                        spawnSoldier(m_metagame,1,factionid,c_pos2,"smg_136_pp19");
                        spawnSoldier(m_metagame,1,factionid,c_pos3,"smg_136_pp19");
                        spawnSoldier(m_metagame,1,factionid,c_pos4,"smg_136_pp19");
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,0.9);
                        CreateProjectile_H(m_metagame,c_pos1,stringToVector3(target),"grenade_pp19_sub.projectile",characterId,factionid,40.0,6.0);
                        CreateProjectile_H(m_metagame,c_pos2,stringToVector3(target),"grenade_pp19_sub.projectile",characterId,factionid,40.0,6.0);
                        CreateProjectile_H(m_metagame,c_pos3,stringToVector3(target),"grenade_pp19_sub.projectile",characterId,factionid,40.0,6.0);
                        CreateProjectile_H(m_metagame,c_pos4,stringToVector3(target),"grenade_pp19_sub.projectile",characterId,factionid,40.0,6.0);
                    }
                    else{
                        addCooldown("PP-19",15,characterId,modifer);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,0.9);
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_pp19.projectile",characterId,factionid,40.0,6.0);
                    }

                }
            }
        }
    }
    void excuteWerlodskill(int characterId,int playerId,SkillModifer@ modifer,bool mod3=false){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"WELROD")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) return;
        Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
        int factionid = character.getIntAttribute("faction_id");
        array<string> Voice={
            "WelrodMod_ATTACK_JP.wav",
            "WelrodMod_SKILL3_JP.wav",
            "WelrodMod_DEFENSE_JP.wav"
        };
        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
        addCooldown("WELROD",20,characterId,modifer);
        array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 20.0f);
        if (characters is null) return;
        GrenadeSupplyGroup(m_metagame,characters,2);
    }
    void excuteWerlodModskill(int characterId,int playerId,SkillModifer@ modifer,bool mod3=false){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"WELROD")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "WelrodMod_ATTACK_JP.wav",
                        "WelrodMod_SKILL3_JP.wav",
                        "WelrodMod_DEFENSE_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos = c_pos.add(Vector3(0,1,0));
                    Vector3 u_pos = getAimUnitPosition(c_pos,stringToVector3(target),1.5);
                    float ori4 = getAimOrientation4(c_pos,stringToVector3(target));
                    spawnVehicle(m_metagame,1,0,u_pos,Orientation(0,1,0,ori4),"gk_werlod_shelter.vehicle");
                    addCooldown("WELROD",20,characterId,modifer);

                    array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 20.0f);
                    if (characters is null) return;
                    GrenadeSupplyGroup(m_metagame,characters,2);
                }
            }
        }   
    }  
    void excuteAK15MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"AK15MOD3")) return;
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
                        addCooldown("AK15MOD3",20,characterId,modifer);
					}
					else if(affectedNumber >= 5 && affectedNumber <= 9){
                        addCooldown("AK15MOD3",20,characterId,modifer);
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
                        addCooldown("AK15MOD3",10,characterId,modifer);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        string command = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='ak15_mod3_roar.projectile'" +
                        " position='" + c_pos.toString() + "'"+
				        " character_id='" + characterId + "' />";
                        m_metagame.getComms().send(command);		
                        string vestkey="exo_t5_16lab.carry_item";
                        vestkey = getPlayerEquipmentKey(m_metagame,characterId,4);
                        if (vestkey=="immunity_mp5.carry_item" || vestkey==""){
                            vestkey=="exo_t5_16lab.carry_item";
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
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="fnfal") {
                ExistQueue=true;
                j=i;
                SkillArray[j].addCharge();
            }
        }
        if (ExistQueue && SkillArray[j].m_charge>3 ){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
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
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,45.0,6.0);
                    }
                    playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);
                    if(ExistQueue){
                        return;
                    }
                    else{
                        addCooldown("fnfal",30,characterId,modifer);
                        array<string> Voice={
                        "FNFAL_SKILL1_JP.wav",
                        "FNFAL_SKILL2_JP.wav",
                        "FNFAL_SKILL3_JP.wav",
                        "FNFAL_PHRASE_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                }
            }
        }
    }
    void excuteJusticeskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"justice")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "judge_skill_1.wav",
                        "judge_skill_2.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);

                    //CreateProjectile_H(m_metagame,c_pos.add(Vector3(0,2,0)),c_pos.add(Vector3(0,12,0)),'ff_justice_riderkick_1.projectile',characterId,factionid,30,12);
                    
                    c_pos = c_pos.add(Vector3(0,12,0));
                    Vector3 e_pos = stringToVector3(target);

                    CreateDirectProjectile(m_metagame,c_pos,e_pos,'ff_justice_riderkick_2.projectile',characterId,factionid,120);
                
                    addCooldown("justice",20,characterId,modifer);
                }
            }
        }   
    }
    void excuteM4SOPMODIIMOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="m4sopmodiimod3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "sopmod1.wav",
                        "sopmod2.wav",
                        "sopmod3.wav",
                        "sopmod4.wav",
                        "sopmod5.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),10)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"SopmodSk_script.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"SopmodSk_script.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("m4sopmodiimod3",16,characterId,modifer);
                }
            }
        }
    }
    void excuteHK416mod3skill(int characterId,int playerId,SkillModifer@ modifer,bool pussyskin = false){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="HK416MOD3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if(pussyskin){
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_hk416_3401.projectile",characterId,factionid,30);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_hk416_3401.projectile",characterId,factionid,45.0,6.0);
                        }
                        array<string> Voice={
                        "HK416_Skill4.wav",
                        "HK416_Skill5.wav",
                        "HK416_Skill6.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    else{
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_hk416.projectile",characterId,factionid,30);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_hk416.projectile",characterId,factionid,45.0,6.0);
                        }
                        array<string> Voice={
                        "HK416_Skill1.wav",
                        "HK416_Skill2.wav",
                        "HK416_Skill3.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    }
                    addCooldown("HK416MOD3",16,characterId,modifer);
                }
            }
        }
    }
    void excuteG3mod3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="G3MOD3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "G3Mod_SKILL1_JP.wav",
                        "G3Mod_SKILL2_JP.wav",
                        "G3Mod_SKILL3_JP.wav",
                        "G3Mod_ATTACK_JP.wav"
                    };
                    playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"40mm_g3mod3.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"40mm_g3mod3.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("G3MOD3",20,characterId,modifer);
                }
            }
        }
    }    
    void excuteSVDEXskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="SVDEX") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "SVD_SKILL1_JP.wav",
                        "SVD_MEET_JP.wav",
                        "SVD_SKILL2_JP.wav"
                    };
                    playSoundAtLocation(m_metagame,"416mod3skill_Fire_FromL4D2.wav",factionid,c_pos,1.0);
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"std_aa_grenade.projectile",characterId,factionid,45.0,6.0);
                    }
                    addCooldown("SVDEX",12,characterId,modifer);
                }
            }
        }
    }    
    void excuteFO12skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="FO12") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        addCooldown("FO12",60,characterId,modifer);
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        int fID = info.getIntAttribute("faction_id");
        string c_pos = info.getStringAttribute("position");
            XmlElement command("command");
            command.setStringAttribute("class", "create_instance");
            command.setIntAttribute("faction_id",fID);
            command.setStringAttribute("instance_class", "character");
            command.setStringAttribute("instance_key","FO12_Dog");
            command.setStringAttribute("position",c_pos);
            m_metagame.getComms().send(command);    
        // playSoundAtLocation(m_metagame,"AN94mod3_skill.wav",fID,c_pos,0.9);
    }
    void excuteFlashbangskill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="Flashbang") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");

                    if(weaponname=="gkw_m9.weapon") {
                        array<string> Voice={
                            "M9_SKILL1_JP.wav",
                            "M9_SKILL2_JP.wav",
                            "M9_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Flashbang",12,characterId,modifer);
                    }
                    if(weaponname=="gkw_m16a1.weapon" || weaponname=="gkw_m16a1_533.weapon" || weaponname=="gkw_m16a1_553.weapon") {
                        array<string> Voice={
                            "m16a1_skill1.wav",
                            "m16a1_skill2.wav",
                            "m16a1_skill3.wav",
                            "m16a1_skill4.wav",
                            "m16a1_skill5.wav"                            
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Flashbang",16,characterId,modifer);
                    }
                    if(weaponname=="gkw_ump9.weapon" || weaponname=="gkw_ump9_409.weapon" || weaponname=="gkw_ump9_536.weapon" || weaponname=="gkw_ump9_3404.weapon"  || weaponname=="gkw_ump9_6704.weapon" || weaponname=="gkw_ump9_6704_skill.weapon") {
                        array<string> Voice={
                            "UMP9_skill1.wav",
                            "UMP9_skill2.wav",
                            "UMP9_skill3.wav",
                            "UMP9_skill4.wav",
                            "UMP9_skill5.wav"                            
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        addCooldown("Flashbang",16,characterId,modifer);
                    }
                    if(weaponname=="gkw_mab38.weapon" || weaponname=="gkw_mab38_oc.weapon") {
                        array<string> Voice={
                            "mab38_skilll1.wav",
                            "mab38_skilll2.wav",
                            "mab38_skilll3.wav",
                            "mab38_skilll4.wav",
                            "mab38_skilll5.wav"                            
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Flashbang",16,characterId,modifer);
                    }
                    if(weaponname=="gkw_64type.weapon") {
                        array<string> Voice={
                            "64type_SKILL1_JP.wav",
                            "64type_SKILL2_JP.wav",
                            "64type_SKILL3_JP.wav"                          
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Flashbang",16,characterId,modifer);
                    }
                    if(weaponname=="gkw_type79.weapon") {
                        array<string> Voice={
                            "79type_skilll1.wav",
                            "79type_skilll2.wav",
                            "79type_skilll3.wav",
                            "79type_skilll4.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Flashbang",16,characterId,modifer);
                    }
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),10)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"skill_flashbang.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"skill_flashbang.projectile",characterId,factionid,60.0,6.0);
                    }
                }
            }
        }
    }    
    void excuteUMP9skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="UMP9") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "UMP9_skill1.wav",
                        "UMP9_skill2.wav",
                        "UMP9_skill3.wav",
                        "UMP9_skill4.wav",
                        "UMP9_skill5.wav"                        
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),10)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"ump9_stun_grenade_spawner.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"ump9_stun_grenade_spawner.projectile",characterId,factionid,60.0,6.0);
                    }                    
                    addCooldown("UMP9",15,characterId,modifer);
                }
            }
        }
    }
    void excuteMab38skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="MAB38") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "mab38mod3_skilll1.wav",
                        "mab38mod3_skilll2.wav",
                        "mab38mod3_skilll3.wav",
                        "mab38mod3_skilll4.wav",
                        "mab38mod3_skilll5.wav"                        
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),10)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"skill_flashbang.projectile",characterId,factionid,60);
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"firenade_Vector.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"skill_flashbang.projectile",characterId,factionid,60.0,6.0);
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"firenade_Vector.projectile",characterId,factionid,26.0,6.0);
                    }                    
                    addCooldown("MAB38",16,characterId,modifer);
                }
            }
        }
    }        
    void excutePPKMOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="PPKMOD3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    string player_name = player.getStringAttribute("name");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "PPK_WIN_JP.wav",
                        "PPK_ATTACK_JP.wav",
                        "PPK_SKILL1_JP.wav",
                        "PPK_SKILL2_JP.wav",
                        "PPK_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil, pistol",true,true);
                    playSoundAtLocation(m_metagame,"dart_shot.wav",factionid,c_pos,1.75);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"ppk_tracer_dart_1.projectile",characterId,factionid,60);
                    int kill_count = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"ppk");
                    if (kill_count>=7){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"ppk_tracer_dart_3.projectile",characterId,factionid,260);
                    }
                    if (kill_count>=15){
                        insertLockOnStrafeAirstrike(m_metagame,"ioncannon_strafe",characterId,factionid,stringToVector3(target));
                    }
                    if (kill_count>=30){
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAirstrikeRequest(m_metagame,5.0,characterId,factionid,stringToVector3(target),"ioncannon_strafe"));
                    }                        
                    addCooldown("PPKMOD3",90,characterId,modifer);
                }
            }
        }
    }        
    void excuteMLEskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="RBLL") {
                ExistQueue=true;
                j=i;
                if (ExistQueue && SkillArray[j].m_charge >=3){
                    dictionary a;
                    a["%time"] = ""+SkillArray[j].m_time;
                    notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
                    //_log("skill cooldown" + SkillArray[j].m_time);
                    return;
                }
                if(SkillArray[j].m_charge <3){
                    SkillArray[j].addCharge();
                }                
            }
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    if(!ExistQueue){
                        addCooldown("RBLL",20,characterId,modifer,"constant");
                    }
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "Ribeyrolles_ATTACK_JP.wav",
                        "Ribeyrolles_MEET_JP.wav",
                        "Ribeyrolles_PHRASE_JP.wav",
                        "Ribeyrolles_TIP_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,2.2,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"bandage_mle1918_spawn.projectile",characterId,factionid,30.0,3.0);
                }
            }
        }
    }    
    void excuteErmaskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="Erma") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            _log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                int factionid = character.getIntAttribute("faction_id");
                array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 20.0f);
                for (uint i = 0; i < characters.length; i++) {   
                    int soldierId = characters[i].getIntAttribute("id");
                    int index = findSkillIndex(soldierId);
                    if(index != -1 && soldierId != characterId ){
                        if(SkillArray[index].m_weapontype != "Erma")
                        {
                            SkillArray[index].m_time-=1000.0;
                        }                        
                    }
                }
                addCooldown("Erma",300,characterId,modifer);
            }
        }
    }    
    void excuteGrenadeSkill(int characterId,int playerId,SkillModifer@ modifer,string weaponname){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="Grenade") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");

                    if(weaponname=="gkw_m3.weapon") {
                        array<string> Voice={
                            "M3_ATTACK_JP.wav",
                            "M3_GOATTACK_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                        addCooldown("Grenade",15,characterId,modifer);
                        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        if (checkFlatRange(c_pos,stringToVector3(target),10)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,45);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,30.0,3.0);
                        }                        
                    }

                    else if(weaponname=="gkw_sten.weapon") {
                        array<string> Voice={
                            "StenMK2_ATTACK_JP.wav",
                            "StenMK2_GOATTACK_JP.wav",
                            "StenMK2_SKILL1_JP.wav",
                            "StenMK2_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,0.7);
                        addCooldown("Grenade",15,characterId,modifer);
                        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        if (checkFlatRange(c_pos,stringToVector3(target),10)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,45);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,30.0,3.0);
                        }                        
                    }

                    else if(weaponname=="gkw_stenmod3.weapon") {
                        array<string> Voice={
                            "StenMK2Mod_ATTACK_JP.wav",
                            "StenMK2Mod_DEFENSE_JP.wav",
                            "StenMK2Mod_SKILL1_JP.wav",
                            "StenMK2Mod_SKILL2_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.2);
                        addCooldown("Grenade",12,characterId,modifer);
                        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        if (checkFlatRange(c_pos,stringToVector3(target),10)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,45);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s.projectile",characterId,factionid,30.0,3.0);
                        }                        
                    }     
                    else if(weaponname=="gkw_sterling.weapon") {
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.2);
                        addCooldown("Grenade",15,characterId,modifer);
                        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        if (checkFlatRange(c_pos,stringToVector3(target),10)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_english.projectile",characterId,factionid,45);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_english.projectile",characterId,factionid,30.0,3.0);
                        }                        
                    }       
                    else if(weaponname=="gkw_saf.weapon" || weaponname=="gkw_saf_6607.weapon") {
                        array<string> Voice={
                            "SAF_SKILL1_JP.wav",
                            "SAF_SKILL2_JP.wav",
                            "SAF_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                        playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.4);
                        addCooldown("Grenade",15,characterId,modifer);
                        playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                        c_pos=c_pos.add(Vector3(0,1,0));
                        if (checkFlatRange(c_pos,stringToVector3(target),10)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"hand_88grenade.projectile",characterId,factionid,45);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"hand_88grenade.projectile",characterId,factionid,40.0,5.0);
                        }                        
                    }                                                   
                }
            }
        }
    }    

    void excuteMG4MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="MG4MOD3") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
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

                    array<string> Voice2={
                        "MG4_SKILL3_JP.wav",
                        "MG4_SKILL1_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice2,factionid,c_pos.toString(),1);                    
                    playAnimationKey(m_metagame,characterId,"air thrust",false,true);
                    playSoundAtLocation(m_metagame,"dart_shot.wav",factionid,c_pos,1.75);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    tasker.add(DelayAirstrikeRequest(m_metagame,3.0,characterId,factionid,stringToVector3(target),"a10_rocket_strafe",true));
                    tasker.add(strafe_task_30mm(m_metagame,3.0,characterId,factionid,c_pos,stringToVector3(target)));
                    tasker.add(strafe_task_30mm(m_metagame,3.0,characterId,factionid,c_pos,stringToVector3(target)));
                    addCooldown("MG4MOD3",90,characterId,modifer);
                }
            }
        }
    }

    void excuteLiuRFskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j =-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="Liushi") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        addCooldown("Liushi",300,characterId,modifer);
        const XmlElement@ info = getCharacterInfo(m_metagame, characterId);
        int fID = info.getIntAttribute("faction_id");
        string c_pos = info.getStringAttribute("position");
        spawnSoldier(m_metagame,5,fID,c_pos,"rf_316_liu");
        playSoundAtLocation(m_metagame,"GeneralLiu_skill.wav",fID,c_pos,1.0);

    }

    void excuteSAT8skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="SAT8") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            return;
        }
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
            // c_pos=c_pos.add(Vector3(0,1,0));
            int num_jud = 0;
            int num_max_character = 6;
            int m_fnum = m_metagame.getFactionCount();

            array<const XmlElement@> affectedCharacter;
            array<const XmlElement@> affectedCharacter2;

            affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,0,10.0f);
            if (affectedCharacter2 !is null){
                for(uint x=0;x<affectedCharacter2.length();x++){
                    affectedCharacter.insertLast(affectedCharacter2[x]);
                    num_jud += 1;
                    if(num_jud>=(num_max_character-1))break;
                }
            }

            int healnum = min(3,num_max_character-num_jud);
            healCharacter(m_metagame,characterId,3*healnum);

            if(num_jud>0)
            {
                array<string> Voice={
                    "SAT8_SKILL1_JP.wav",
                    "SAT8_SKILL2_JP.wav",
                    "SAT8_SKILL3_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);

                while(num_jud>0){
                    for (uint i1=0;i1<affectedCharacter.length();i1++)	{
                        int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
                        const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
                        if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
                            string luckyonepos = luckyoneC.getStringAttribute("position");
                            Vector3 luckyoneposV = stringToVector3(luckyonepos);
                            CreateDirectProjectile(m_metagame,c_pos.add(Vector3(0,1.2,0)),luckyoneposV.add(Vector3(0,1.8,0)),"sat8_pizza.projectile",characterId,factionid,60);
                        }			
                        num_jud-=1;	
                    }
                }

                addCooldown("SAT8",15+15*healnum,characterId,modifer);
            }
            
        }    
    }

    void excuteAlchemistskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="FF_ALCHEMIST") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        addCooldown("FF_ALCHEMIST",25,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
        int factionid = character.getIntAttribute("faction_id");
        array<string> Voice={
            "Alchemist_buhuo_SKILL01_JP.wav",
            "Alchemist_buhuo_SKILL02_JP.wav"
        };
        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        c_pos = c_pos.add(Vector3(0,1,0));
        CreateDirectProjectile(m_metagame,c_pos,c_pos.add(Vector3(0,-1,0)),"ff_alchemist_skill_scan.projectile",characterId,factionid,60);	   
    }  
    void excute88typeskill(int characterId,int playerId,SkillModifer@ modifer,bool mod3=false){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="88type") {
                ExistQueue=true;
                j=i;
                SkillArray[j].addCharge();
            }
        }
        if (ExistQueue && mod3==false){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        if (ExistQueue && mod3 && SkillArray[j].m_charge>3){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
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
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if(mod3){
                        if(!ExistQueue){
                            array<string> Voice={
                                "88typeMod_SKILL2_JP.wav",
                            };                        
                            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                            addCooldown("88type",20,characterId,modifer);
                        }
                    }
                    else{
                        array<string> Voice={
                            "88typeMod_MEET_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                        
                        addCooldown("88type",15,characterId,modifer);
                    }

                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"hand_88grenade.projectile",characterId,factionid,40);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"hand_88grenade.projectile",characterId,factionid,40.0,5.0);
                    }
                }
            }
        }
    }
    void excute88typeGUNDAMskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="88typeGUNDAM") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
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
                        "88typeMod_SKILL2_JP.wav",
                        "88typeMod_MEET_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);     

                    Vector3 v3d_offset = getAimUnitVector(-1.0,c_pos,stringToVector3(target));         
                    v3d_offset=v3d_offset.add(Vector3(0,2,0));
                    Vector3 v1 = getVerticalUnitVector(v3d_offset);
                    Vector3 v2 = getMultiplicationVector(v1,Vector3(-1,1,-1));
                    v1 = v1.add(v3d_offset);
                    v2 = v2.add(v3d_offset);
                    
                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos.add(v1),stringToVector3(target),"88typeGUNDAM_rocket.projectile",characterId,factionid,100);
                        CreateDirectProjectile(m_metagame,c_pos.add(v2),stringToVector3(target),"88typeGUNDAM_rocket.projectile",characterId,factionid,100);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos.add(v1),stringToVector3(target),"88typeGUNDAM_rocket.projectile",characterId,factionid,150.0,15.0);
                        CreateProjectile_H(m_metagame,c_pos.add(v2),stringToVector3(target),"88typeGUNDAM_rocket.projectile",characterId,factionid,150.0,15.0);
                        
                    }
                    addCooldown("88typeGUNDAM",40,characterId,modifer);
                }
            }
        }
    }

    void excuteM200skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"M200",true)) return;
        addCooldown("M200",45,characterId,modifer);
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) return;
        const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
        if (player is null) return;
        if (player.hasAttribute("aim_target")) {
            string target = player.getStringAttribute("aim_target");
            int factionid = character.getIntAttribute("faction_id");
            Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
            array<string> Voice={
                "M200_SKILL1_JP.wav",
                "M200_SKILL2_JP.wav",
                "M200_SKILL3_JP.wav",
                "M200_ATTACK_JP.wav"
            };
            playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),2.0);
            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
            int flagId = m_DummyCallID + 20000;
            CastlingMarker@ FairyRequest = CastlingMarker(characterId,factionid,stringToVector3(target));
            FairyRequest.setIndex(14);
            FairyRequest.setSize(0.5);
            FairyRequest.setDummyId(flagId);
            FairyRequest.setRange(80.0);
            FairyRequest.setIconTypeKey("call_marker_snipe_m200");
            addCastlingMarker(FairyRequest);
            tasker.add(Skill_M200_Snipe(m_metagame,1.0,characterId,factionid,stringToVector3(target),FairyRequest));
            // GFL_event_array.insertLast(GFL_event(characterId,factionid,"sniper_m200",stringToVector3(target),2.0,-1.0,flagId));
            m_DummyCallID++;
        }        
    }

    void excuteCZ75skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"CZ75",true)) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
            int num_jud = 0;
            int num_max_character = 3;
            int m_fnum = m_metagame.getFactionCount();
            array<const XmlElement@> affectedCharacter;
            for(int i=0;i<m_fnum;i++) {
                if(i!=factionid) {
                    array<const XmlElement@> affectedCharacter2;
                    affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,10.0f);
                    if (affectedCharacter2 !is null){
                        for(uint x=0;x<affectedCharacter2.length();x++){
                            affectedCharacter.insertLast(affectedCharacter2[x]);
                            num_jud += 1;
                            if(num_jud>=num_max_character)break;
                        }
                    }
                }
            }

            if(num_jud>0)
            {
                array<string> Voice={
                "CZ75_SKILL1_JP.wav",
                "CZ75_SKILL2_JP.wav",
                "CZ75_SKILL3_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.4);
                playSoundAtLocation(m_metagame,"cz75_skill_throwout.wav",factionid,c_pos,0.85);

                while(num_jud>0){
                    for (uint i1=0;i1<affectedCharacter.length();i1++)	{
                        int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
                        const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
                        if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
                            string luckyonepos = luckyoneC.getStringAttribute("position");
                            Vector3 luckyoneposV = stringToVector3(luckyonepos);
                            CreateDirectProjectile(m_metagame,c_pos.add(Vector3(0,1.2,0)),luckyoneposV.add(Vector3(0,1.8,0)),"gkw_cz75_axe.projectile",characterId,factionid,60);
                        }			
                        num_jud-=1;	
                    }
                }
                addCooldown("CZ75",15,characterId,modifer);
            }
            
        }    
    }

    void excuteSniperSkill_Pos(int characterId,int playerId,SkillModifer@ modifer,string weapon_name){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"sniper")) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;

        if (playerinfo.hasAttribute("aim_target") && characterinfo !is null) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
            if (weapon_name == "gkw_m99.weapon" || weapon_name=="gkw_m99_1701.weapon" || weapon_name=="gkw_m99_3304.weapon" || weapon_name== "gkw_m99_404.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s noob",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_40.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",60,characterId,modifer);
            }
            else if (weapon_name == "gkw_ptrd.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",45,characterId,modifer);
            }
            else if (weapon_name == "gkw_tac50.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",45,characterId,modifer);
            }   
            else if (weapon_name == "gkw_gepardm1.weapon" || weapon_name == "gkw_gepardm1_4006.weapon" ){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_80.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",45,characterId,modifer);
            } 
            else if (weapon_name == "gkw_gepardm1mod3.weapon"|| weapon_name == "gkw_gepardm1mod3_4006.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_80.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",30,characterId,modifer);
            }  
            else if (weapon_name == "gkw_gm6.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",45,characterId,modifer);
            }     
            else if (weapon_name == "gkw_m82a1.weapon" || weapon_name=="gkw_m82a1_skill.weapon"){
                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                tasker.add(DelayAntiTankSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),s_pos));
                addCooldown("sniper",45,characterId,modifer);
            }                                                 
        }
        else{
            addCooldown("sniper",5,characterId,modifer);
        } 
    }

    void excuteSniperSkill_Antiperson(int characterId,int playerId,SkillModifer@ modifer,string weapon_name){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="sniper") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            return;
        }
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
            // c_pos=c_pos.add(Vector3(0,1,0));
    
            int m_fnum = m_metagame.getFactionCount();
            array<const XmlElement@> affectedCharacter;
            for(int i=0;i<m_fnum;i++) {
                if(i!=factionid) {
                    array<const XmlElement@> affectedCharacter2;
                    affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,5.0f);
                    if (affectedCharacter2 !is null){
                        for(uint x=0;x<affectedCharacter2.length();x++){
                            affectedCharacter.insertLast(affectedCharacter2[x]);
                        }
                    }
                }
            }

            if (affectedCharacter !is null && affectedCharacter.length > 0){
                int closestIndex = -1;
                float closestDistance = -1.0f;                
                for(uint i=0;i<affectedCharacter.length();i++){
                    float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
                    if (distance < closestDistance || closestDistance < 0.0){
                        closestDistance = distance;
                        closestIndex = i;
                    }
                }


                if (closestIndex >= 0){
                    int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
                    if (weapon_name == "gkw_m1.weapon" 
                    || weapon_name=="gkw_m1_1106.weapon" 
                    || weapon_name=="gkw_m1_6907.weapon" 
                    || weapon_name=="gkw_m1_sf.weapon" 
                    || weapon_name=="gkw_m1_sf_1106.weapon" 
                    || weapon_name=="gkw_m1_sf_6907.weapon"
                    || weapon_name=="gkw_m1_sf_skill.weapon" 
                    || weapon_name=="gkw_m1_sf_1106_skill.weapon"
                    || weapon_name=="gkw_m1_sf_6907_skill.weapon"                    
                    ){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_m1903.weapon" || weapon_name=="gkw_m1903_exp.weapon" || weapon_name=="gkw_m1903_exp_skill.weapon" || weapon_name=="gkw_m1903_only.weapon"){
                        playAnimationKey(m_metagame,characterId,"recoil1, big",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",10,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_m1903_302.weapon" || weapon_name=="gkw_m1903_302_exp.weapon" || weapon_name=="gkw_m1903_302_exp_skill.weapon" || weapon_name=="gkw_m1903_302_only.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_60.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_m1903_1107.weapon" || weapon_name=="gkw_m1903_1107_exp.weapon" || weapon_name=="gkw_m1903_1107_exp_skill.weapon" || weapon_name=="gkw_m1903_1107_only.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_60.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_m1891.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_80.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",30,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_m21.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_40.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",15,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_psg1.weapon" || weapon_name == "gkw_psg1_8404.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_40.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",15,characterId,modifer);
                    }                                        
                    else if (weapon_name == "gkw_sv98.weapon" || weapon_name =="gkw_sv98_502.weapon" || weapon_name=="gkw_sv98_1906.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_blast_15.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",12,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_sv98mod3.weapon" || weapon_name =="gkw_sv98mod3_502.weapon" || weapon_name=="gkw_sv98mod3_1906.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",12,characterId,modifer);
                    }                    
                    else if (weapon_name == "gkw_sv98mod3_skill.weapon" || weapon_name =="gkw_sv98mod3_502_skill.weapon" || weapon_name=="gkw_sv98mod3_1906_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",12,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_scarh_only.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",10,characterId,modifer);
                    }                                         
                    else if (weapon_name == "gkw_qbu88.weapon" || weapon_name == "gkw_qbu88_skill.weapon" || weapon_name == "gkw_qbu88_5502.weapon" || weapon_name == "gkw_qbu88_5502_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_blast_30.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",15,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_thunder.weapon" || weapon_name == "gkw_thunder_2206.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s noob",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_blast_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_98k.weapon" || weapon_name == "gkw_98k_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_98k_4301.weapon" || weapon_name == "gkw_98k_4301_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                    else if (weapon_name == "gkw_98k_8301.weapon" || weapon_name == "gkw_98k_8301_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }                    
                    else if (weapon_name == "gkw_supersass.weapon" || weapon_name=="gkw_supersass_1407.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }  
                    else if (weapon_name == "gkw_supersassmod3.weapon" || weapon_name=="gkw_supersassmod3_1407.weapon" || weapon_name == "gkw_supersassmod3_skill.weapon" || weapon_name=="gkw_supersassmod3_1407_skill.weapon"){
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_40.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                        addCooldown("sniper",20,characterId,modifer);
                    }
                }
            }
            else{
                addCooldown("sniper",3,characterId,modifer,"normal",false);
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
            }  
        } 
    }

    void excuteCarcano1938(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"sniper")) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        string player_name = playerinfo.getStringAttribute("name");
        int kill_count = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"carcano");
        // _log("现在有" + kill_count + "击杀数量");
        if (kill_count >= 6){
            if (playerinfo.hasAttribute("aim_target")) {
                string target = playerinfo.getStringAttribute("aim_target");
                Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
                Vector3 s_pos = stringToVector3(target);
                int factionid = characterinfo.getIntAttribute("faction_id");
        
                int m_fnum = m_metagame.getFactionCount();
                array<const XmlElement@> affectedCharacter;
                for(int i=0;i<m_fnum;i++) {
                    if(i!=factionid) {
                        array<const XmlElement@> affectedCharacter2;
                        affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,5.0f);
                        if (affectedCharacter2 !is null){
                            for(uint x=0;x<affectedCharacter2.length();x++){
                                affectedCharacter.insertLast(affectedCharacter2[x]);
                            }
                        }
                    }
                }

                if (affectedCharacter !is null && affectedCharacter.length > 0){
                    int closestIndex = -1;
                    float closestDistance = -1.0f;                
                    for(uint i=0;i<affectedCharacter.length();i++){
                        float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
                        if (distance < closestDistance || closestDistance < 0.0){
                            closestDistance = distance;
                            closestIndex = i;
                        }
                    }

                    if (closestIndex >= 0){
                        g_playerInfo_Buck.addKillSkillCountbyName(player_name,"carcano",-6);
                        int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        DelayAntiPersonSnipeRequest@ snipe_quest = DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_hit_kennedy.projectile",c_pos.add(Vector3(0,0.5,0)),target_id);
                        snipe_quest.setKey("sniper_bullet_carcano.projectile");
                        tasker.add(snipe_quest);
                        sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"carcano_1938_skill_fire");
                        addCooldown("sniper",5,characterId,modifer);
                        array<string> Voice={
                        "Carcano1938_SKILL1_JP.wav",
                        "Carcano1938_SKILL2_JP.wav",
                        "Carcano1938_SKILL3_JP.wav"
                        };
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.0);                            
                    }
                }
                else{
                    sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
                    addCooldown("sniper",3,characterId,modifer,"normal",false);
                }  
            } 
        }
        else{
            sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"carcano_1938_not_ready");
            addCooldown("sniper",5,characterId,modifer,"normal",false);
        }
    }

    void excuteMosinNagant(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"mosin")) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        if (!playerinfo.hasAttribute("aim_target")) return;
        string target = playerinfo.getStringAttribute("aim_target");
        Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
        Vector3 s_pos = stringToVector3(target);
        string player_name = playerinfo.getStringAttribute("name");
        int factionid = characterinfo.getIntAttribute("faction_id");

        int m_fnum = m_metagame.getFactionCount();
        array<const XmlElement@> affectedCharacter;
        for(int i=0;i<m_fnum;i++) {
            if(i!=factionid) {
                array<const XmlElement@> affectedCharacter2;
                affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,5.0f);
                if (affectedCharacter2 !is null){
                    for(uint x=0;x<affectedCharacter2.length();x++){
                        affectedCharacter.insertLast(affectedCharacter2[x]);
                    }
                }
            }
        }

        if (affectedCharacter !is null && affectedCharacter.length > 0){
            int closestIndex = -1;
            float closestDistance = -1.0f;                
            for(uint i=0;i<affectedCharacter.length();i++){
                float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
                if (distance < closestDistance || closestDistance < 0.0){
                    closestDistance = distance;
                    closestIndex = i;
                }
            }

            if (closestIndex >= 0){
                int fire_num = 2;
                modifer.setCooldownMinus(0);
                modifer.setCooldownReduction(1.0);
                int mosin_level = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"mosin");

                fire_num = int(min(int(floor(mosin_level/10))+2,8));
                int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
                if (mosin_level < 20)
                {
                    playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    DelayAntiPersonSnipeRequest@ snipe_quest = DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,MutilProjectile("snipe_mosin.projectile",fire_num),c_pos.add(Vector3(0,0.5,0)),target_id);
                    tasker.add(snipe_quest);
                }
                else if (mosin_level <40 && mosin_level >=20 )
                {
                    playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    DelayAntiPersonSnipeRequest@ snipe_quest = DelayAntiPersonSnipeRequest(m_metagame,2,characterId,factionid,MutilProjectile("snipe_mosin.projectile",fire_num),c_pos.add(Vector3(0,0.5,0)),target_id);
                    tasker.add(snipe_quest);
                }
                else if (mosin_level>=40)
                {
                    playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    DelayAntiPersonSnipeRequest@ snipe_quest = DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,MutilProjectile("snipe_mosin.projectile",fire_num),c_pos.add(Vector3(0,0.5,0)),target_id);
                    tasker.add(snipe_quest);
                }
                if (mosin_level < 10)
                {
                    addCooldown("mosin",15,characterId,modifer);
                }
                else if (mosin_level < 30 && mosin_level >=10)
                {
                    addCooldown("mosin",10,characterId,modifer);
                }
                else if (mosin_level >=30)
                {
                    addCooldown("mosin",5,characterId,modifer);
                }                
                array<string> Voice={
                "M1891Mod_SKILL1_JP.wav",
                "M1891Mod_SKILL2_JP.wav",
                "M1891Mod_SKILL3_JP.wav",
                "M1891Mod_ATTACK_JP.wav"
                };
                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);                            
            }
        }
        else{
            sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
            addCooldown("mosin",3,characterId,modifer,"normal",false);
        }  
    }

    void excuteKar98k(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"kar98k")) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        if (playerinfo.hasAttribute("aim_target")) {
            int index = findNodeleteDataIndex(modifer.m_playername,"kar98k");
            int medal_num = 0;
            if (index>=0)
            {
                medal_num = No_Delete_DataArray[index].m_num;
            }
            medal_num = min(medal_num,4);
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
    
            int m_fnum = m_metagame.getFactionCount();
            array<const XmlElement@> affectedCharacter;
            for(int i=0;i<m_fnum;i++) {
                if(i!=factionid) {
                    array<const XmlElement@> affectedCharacter2;
                    affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,10.0f);
                    if (affectedCharacter2 !is null){
                        for(uint x=0;x<affectedCharacter2.length();x++){
                            affectedCharacter.insertLast(affectedCharacter2[x]);
                        }
                    }
                }
            }

            if (affectedCharacter !is null && affectedCharacter.length > 0){
                int closestIndex = -1;
                int secondClosestIndex = -1;
                float closestDistance = -1.0f;
                float secondClosestDistance = -1.0f;              
                for (uint i = 0; i < affectedCharacter.length(); i++) {
                    float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));

                    if (distance < closestDistance || closestDistance < 0.0) {
                        secondClosestDistance = closestDistance;
                        secondClosestIndex = closestIndex;

                        closestDistance = distance;
                        closestIndex = i;
                    } else if (distance < secondClosestDistance || secondClosestDistance < 0.0) {
                        secondClosestDistance = distance;
                        secondClosestIndex = i;
                    }
                }
                if (secondClosestIndex == -1) {
                    secondClosestIndex = closestIndex;
                }
                if (closestIndex >= 0 && secondClosestIndex >= 0){
                    array<string> Voice={
                    "98KMod_SKILL1_JP.wav",
                    "98KMod_SKILL2_JP.wav",
                    "98KMod_SKILL3_JP.wav"
                    };
                    if(closestIndex != secondClosestIndex)
                    {
                        int target_id_1 = affectedCharacter[closestIndex].getIntAttribute("id");
                        int target_id_2 = affectedCharacter[secondClosestIndex].getIntAttribute("id");
                        switch(medal_num)
                        {
                            case 1:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 2:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 3:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                                addCooldown("kar98k",20,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 4:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 0.8s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.8,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                                addCooldown("kar98k",20,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }                                                                                    
                            default:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;                                
                            };
                        }
                    }
                    else
                    {
                        int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
                        switch(medal_num)
                        {
                            case 1:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 2:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1.5s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 3:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 1s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,1.0,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                addCooldown("kar98k",20,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }
                            case 4:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 0.8s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.8,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                addCooldown("kar98k",20,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;
                            }                                                                                    
                            default:
                            {
                                playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2.5s",false);
                                TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.5,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.25,characterId,factionid,"snipe_50.projectile",c_pos.add(Vector3(0,0.5,0)),target_id));
                                addCooldown("kar98k",25,characterId,modifer);
                                playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.5);
                                break;                                
                            };
                        }                        
                    }
                }
            }
            else{
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
                addCooldown("kar98k",3,characterId,modifer,"normal",false);
            }  
        } 
    }

    void excuteGM6Lynx(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"GM6")) return;
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;
        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
    
            int m_fnum = m_metagame.getFactionCount();
            array<const XmlElement@> affectedCharacter;
            for(int i=0;i<m_fnum;i++) {
                if(i!=factionid) {
                    array<const XmlElement@> affectedCharacter2;
                    affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,10.0f);
                    if (affectedCharacter2 !is null){
                        for(uint x=0;x<affectedCharacter2.length();x++){
                            affectedCharacter.insertLast(affectedCharacter2[x]);
                        }
                    }
                }
            }

            if (affectedCharacter !is null && affectedCharacter.length > 0){
                int closestIndex = -1;
                int secondClosestIndex = -1;
                int thirdClosestIndex = -1;
                float closestDistance = -1.0f;
                float secondClosestDistance = -1.0f;
                float thirdClosestDistance = -1.0f;     
                array<string> Voice={
                "Gm6Lynx_SKILL1_JP.wav",
                "Gm6Lynx_SKILL2_JP.wav",
                "Gm6Lynx_SKILL3_JP.wav"
                };                        
                for (uint i = 0; i < affectedCharacter.length(); i++) {
                    float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
                    if (distance < closestDistance || closestDistance < 0.0f) {
                        thirdClosestDistance = secondClosestDistance;
                        thirdClosestIndex = secondClosestIndex;
                        
                        secondClosestDistance = closestDistance;
                        secondClosestIndex = closestIndex;

                        closestDistance = distance;
                        closestIndex = i;
                    } else if (distance < secondClosestDistance || secondClosestDistance < 0.0f) {
                        thirdClosestDistance = secondClosestDistance;
                        thirdClosestIndex = secondClosestIndex;

                        secondClosestDistance = distance;
                        secondClosestIndex = i;
                    } else if (distance < thirdClosestDistance || thirdClosestDistance < 0.0f) {
                        thirdClosestDistance = distance;
                        thirdClosestIndex = i;
                    }
                }
                if (thirdClosestIndex == -1) {
                    thirdClosestIndex = closestIndex;
                }

                if (secondClosestIndex == -1) {
                    secondClosestIndex = closestIndex;
                }
                if (closestIndex >= 0 && secondClosestIndex >= 0 && thirdClosestIndex >= 0){
                    if (closestIndex != secondClosestIndex && closestIndex != thirdClosestIndex && secondClosestIndex != thirdClosestIndex){
                        int target_id_1 = affectedCharacter[closestIndex].getIntAttribute("id");
                        int target_id_2 = affectedCharacter[secondClosestIndex].getIntAttribute("id");
                        int target_id_3 = affectedCharacter[thirdClosestIndex].getIntAttribute("id");
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.3,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_3));                        
                        addCooldown("GM6",30,characterId,modifer);
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.2);                            
                    }
                    else if (closestIndex == secondClosestIndex && closestIndex != thirdClosestIndex) {
                        int target_id_1 = affectedCharacter[closestIndex].getIntAttribute("id");
                        int target_id_2 = affectedCharacter[thirdClosestIndex].getIntAttribute("id");
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));                        
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                        addCooldown("GM6",30,characterId,modifer);      
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.2);                            
                    }
                    else if (closestIndex == thirdClosestIndex && closestIndex != secondClosestIndex) {
                        int target_id_1 = affectedCharacter[closestIndex].getIntAttribute("id");
                        int target_id_2 = affectedCharacter[secondClosestIndex].getIntAttribute("id");
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));                        
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_2));
                        addCooldown("GM6",30,characterId,modifer);        
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.2);                            
                    }
                    else if (closestIndex == secondClosestIndex && closestIndex == thirdClosestIndex) {
                        int target_id_1 = affectedCharacter[closestIndex].getIntAttribute("id");
                        playAnimationKey(m_metagame,characterId,"crouching aiming, RF skill 2s",false);
                        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,2.0,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));                        
                        tasker.add(DelayAntiPersonSnipeRequest(m_metagame,0.2,characterId,factionid,"snipe_blast_20.projectile",c_pos.add(Vector3(0,0.5,0)),target_id_1));
                        addCooldown("GM6",30,characterId,modifer);     
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1.2);                            
                    }
                }
            }
            else{
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
                addCooldown("GM6",3,characterId,modifer,"normal",false);
            }  
        } 
    }
    void excuteG41Onlyskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="G41") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
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
                        "G41_SKILL1_JP.wav",
                        "G41_SKILL2_JP.wav",
                        "G41_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_g41_trigger.projectile",characterId,factionid,41.0,6.0);
                    addCooldown("G41",15,characterId,modifer);
                }
            }
        }
    }
    void excuteWeaverskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_WEAVER")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "Weaver_buhuo_ATTACK_JP.wav",
                        "Weaver_buhuo_SKILL02_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateDirectProjectile(m_metagame,c_pos.add(Vector3(0,1,0)),c_pos,"ff_weaver_skill_scan.projectile",characterId,factionid,6.0);
                    addCooldown("FF_WEAVER",25,characterId,modifer);
                }
            }
        }
    }

    void excuteUZImod3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FIRENADE")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "MicroUZI_SKILL1_JP.wav",
                        "MicroUZI_SKILL2_JP.wav",
                        "MicroUZIMod_SKILL1_JP.wav",
                        "MicroUZIMod_SKILL2_JP.wav",
                        "MicroUZIMod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,stringToVector3(target),16)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"firenade_uzimod3.projectile",characterId,factionid,50);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"firenade_uzimod3.projectile",characterId,factionid,26.0,4.0);
                    }
                    addCooldown("FIRENADE",15,characterId,modifer);
                }
            }
        }
    }
    void excuteF1skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"F1")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "F1_SKILL1_JP.wav",
                        "F1_SKILL2_JP.wav",
                        "F1_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"smoke_grenade.projectile",characterId,factionid,26.0,4.0);
                    addCooldown("F1",15,characterId,modifer);
                }
            }
        }
    }    
    void excuteBBSRobotskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="BBS_ROBOT") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
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
                        "smokelauncher_fire_FromCOD16.wav",
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"isc reload, large mecha",false,true);

                    Vector3 strike_vector = getAimUnitVector(4,c_pos,stringToVector3(target)); 
                    Vector3 strike_posofffset_1 = getRotatedVector(1.046,strike_vector);
                    Vector3 strike_posofffset_2 = getRotatedVector(-1.046,strike_vector);

                    c_pos=c_pos.add(Vector3(0,3,0));

                    CreateProjectile_H(m_metagame,c_pos,c_pos.add(strike_posofffset_1),"smoke_grenade_bbs_skill.projectile",characterId,factionid,26.0,4.0);
                    CreateProjectile_H(m_metagame,c_pos,c_pos.add(strike_vector),"smoke_grenade_bbs_skill.projectile",characterId,factionid,26.0,4.0);
                    CreateProjectile_H(m_metagame,c_pos,c_pos.add(strike_posofffset_2),"smoke_grenade_bbs_skill.projectile",characterId,factionid,26.0,4.0);
                    
                    addCooldown("BBS_ROBOT",15,characterId,modifer);
                }
            }
        }
    }    
    void excuteHK416Agentskill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="HK416AGENT") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                   _log("hk416 agent recieved");
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    c_pos=c_pos.add(Vector3(0,1,0));

                    if (checkFlatRange(c_pos,stringToVector3(target),15)){
                        CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"medicaid_hk416_agent.projectile",characterId,factionid,30);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"medicaid_hk416_agent.projectile",characterId,factionid,26.0,6.0);
                    }
                    array<string> Voice={
                    "HK416_Skill1.wav",
                    "HK416_Skill2.wav",
                    "HK416_Skill3.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    addCooldown("HK416AGENT",30,characterId,modifer);
                }
            }
        }

    }

    void excute64typemod3Skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"64type",true)) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 aim_pos = stringToVector3(target);
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "64typeMod_SKILL1_JP.wav",
                        "64typeMod_SKILL2_JP.wav",
                        "64typeMod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    if (checkFlatRange(c_pos,aim_pos,10)){
                        CreateDirectProjectile(m_metagame,c_pos,aim_pos,"skill_flashbang.projectile",characterId,factionid,60);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,aim_pos,"skill_flashbang.projectile",characterId,factionid,60.0,6.0);
                    }
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    array<soldier_spawn_request@> spawn_soldier =
                    {
                        soldier_spawn_request("Dummy_64type",10)
                    };    
                    tasker.add(DelaySpawnSoldier(m_metagame,2.0,factionid,spawn_soldier,aim_pos,9.5,9.5));  
                    addCooldown("64type",40,characterId,modifer);
                }
            }
        }
    }

    void excuteZasM21Skill(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i]) && SkillArray[i].m_weapontype=="zasm21") {
                ExistQueue=true;
                j=i;
            }
        }
        if (ExistQueue){
            dictionary a;
            a["%time"] = ""+SkillArray[j].m_time;
            notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
            //_log("skill cooldown" + SkillArray[j].m_time);
            return;
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 aim_pos= stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "ZastavaM21_SKILL1_JP.wav",
                        "ZastavaM21_SKILL2_JP.wav",
                        "ZastavaM21_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    c_pos=c_pos.add(Vector3(0,1,0));

                    int affectedNumber =0;
                    //获取技能影响的敌人数量
                    array<int> enemyfaction = {0,1,2,3,4};
                    for(int i =0;i<4;i++){
                        if (enemyfaction[i] ==factionid){
                            enemyfaction.removeAt(i);
                        }
                    }
                    int n=enemyfaction.length-1;
                    for(int i=0;i<n;i++){
                        array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,aim_pos,enemyfaction[i],10.0f);
                        affectedNumber += affectedCharacter.length;
                    }

                    Airstrike_strafer@ new_strike = Airstrike_strafer(characterId,factionid,16,c_pos.add(Vector3(0,50,0)),aim_pos);
                    affectedNumber+=3;
                    new_strike.setNum(affectedNumber);
                    DelayDetailedCallRequest@ shot = DelayDetailedCallRequest(m_metagame,2.0,new_strike);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    tasker.add(shot);
                    if (checkFlatRange(c_pos,aim_pos,10)){
                        CreateDirectProjectile(m_metagame,c_pos,aim_pos,"std_aa_grenade.projectile",characterId,factionid,45);
                    }
                    else{
                        CreateProjectile_H(m_metagame,c_pos,aim_pos,"std_aa_grenade.projectile",characterId,factionid,45.0,3.5);
                    }
                    addCooldown("zasm21",20,characterId,modifer);
                }
            }
        }
    }
    void excuteC96MODSkill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"C96",true)) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 aim_pos = stringToVector3(target);
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    aim_pos = aim_pos.add(Vector3(0,9,0));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "C96Mod_SKILL1_JP.wav",
                        "C96Mod_SKILL2_JP.wav",
                        "C96Mod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"air thrust",false,false);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,2.25,0));
                    CreateDirectProjectile_T(m_metagame,c_pos,aim_pos,"skill_c96_flare.projectile",characterId,factionid,1.5);
                    addCooldown("C96",90,characterId,modifer);
                }
            }
        }
    }
    void excute_AGS30_Skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"AGS-30")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) return;
        const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
        if (player is null) return;
        if (!player.hasAttribute("aim_target")) return;
        addCooldown("AGS-30",30,characterId,modifer);
        string target = player.getStringAttribute("aim_target");
        int factionid = character.getIntAttribute("faction_id");
        Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
        playSoundAtLocation(m_metagame,"ags30_fire_FromEFT.wav",factionid,c_pos,1.6);
        c_pos=c_pos.add(Vector3(0,1,0));
        c_pos = getAimUnitPosition(c_pos,stringToVector3(target),1.3);
        if (checkFlatRange(c_pos,stringToVector3(target),10)){
            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"30mm_agl_ags_skill.projectile",characterId,factionid,30);
        }
        else{
            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"30mm_agl_ags_skill.projectile",characterId,factionid,26.0,10.0);
        }
    }
    void excute_QLZ04_Skill_Smoke(int characterId,int playerId,SkillModifer@ modifer){
        bool ExistQueue = false;
        int j=-1;
        for (uint i=0;i<SkillArray.length();i++){
            if (InCooldown(characterId,modifer,SkillArray[i],true) && SkillArray[i].m_weapontype=="QLZ04") {
                ExistQueue=true;
                j=i;
                if (ExistQueue && SkillArray[j].m_charge >=3){
                    dictionary a;
                    a["%time"] = ""+SkillArray[j].m_time;
                    notify(m_metagame, "Hint - Skill Cooldown Hint", a, "misc", playerId, false, "", 1.0);
                    return;
                }
                if(SkillArray[j].m_charge <3){
                    SkillArray[j].addCharge();
                }                
            }
        }
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    if(!ExistQueue){
                        addCooldown("QLZ04",20,characterId,modifer,"constant"); 
                    }
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    playSoundAtLocation(m_metagame,"ags30_fire_FromEFT.wav",factionid,c_pos,1.6);
                    c_pos=c_pos.add(Vector3(0,1.0,0));
                    c_pos = getAimUnitPosition(c_pos,stringToVector3(target),1.0);
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"smoke_grenade.projectile",characterId,factionid,30.0,5.0);
                }
            }
        }
    }
    void excute_QLZ04_Skill_Fire(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"QLZ04_FIRE")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) return;
        const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
        if (player is null) return;
        if (!player.hasAttribute("aim_target")) return;
        addCooldown("QLZ04_FIRE",20,characterId,modifer);
        string target = player.getStringAttribute("aim_target");
        Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
        int factionid = character.getIntAttribute("faction_id");
        playSoundAtLocation(m_metagame,"ags30_fire_FromEFT.wav",factionid,c_pos,1.6);
        c_pos=c_pos.add(Vector3(0,1.8,0));
        if (checkFlatRange(c_pos,stringToVector3(target),16)){
            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"firenade_qlz04.projectile",characterId,factionid,30);
        }
        else{
            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"firenade_qlz04.projectile",characterId,factionid,35.0,8.0);
        }
    }
    void excutePA15skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"PA15")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 aim_pos = stringToVector3(target);
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    aim_pos = aim_pos.add(Vector3(0,2.0,0));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "PA15_SKILL1_JP.wav",
                        "PA15_SKILL3_JP.wav",
                        "PA15_ATTACK_JP.wav",
                        "PA15_GOATTACK_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"recoil, revolver",false,false);
                    playSoundAtLocation(m_metagame,"Nytoportal_fire_FromCOD13.wav",factionid,c_pos,1.0);
                    c_pos=c_pos.add(Vector3(0,1.8,0));
                    CreateDirectProjectile_T(m_metagame,c_pos,aim_pos,"skill_pa15_main.projectile",characterId,factionid,1.0);
                    addCooldown("PA15",20,characterId,modifer);
                }
            }
        }
    }    
    void excuteNagantM1895skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"Nagant")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string player_name=player.getStringAttribute("name");
                    Vector3 target_pos = stringToVector3(player.getStringAttribute("aim_target"));
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "M1895Mod_SKILL1_JP.wav",
                        "M1895Mod_SKILL2_JP.wav",
                        "M1895Mod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"air thrust",false,true);
                    c_pos=c_pos.add(Vector3(0,1,0));

                    g_playerInfo_Buck.addKillSkillCountbyName(player_name,"m1895");
                    int count = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"m1895");

                    if (count <=1){
                        healRangedCharacters(m_metagame,c_pos,factionid,20.0,10);
                        spawnVehicle(m_metagame,1,factionid,target_pos.add(Vector3(0,5,0)),Orientation(0,1,0,0),"para_spawn.vehicle");
                    }
                    if (count == 2){
                        Vector3 c_pos1 = target_pos.add(Vector3(3,0,3));
                        Vector3 c_pos2 = target_pos.add(Vector3(-3,0,-3));
                        Vector3 c_pos3 = target_pos.add(Vector3(-3,0,3));
                        Vector3 c_pos4 = target_pos.add(Vector3(3,0,-3));                        
                        spawnSoldier(m_metagame,1,factionid,c_pos1,"smg_21_ppsh");
                        spawnSoldier(m_metagame,1,factionid,c_pos2,"smg_21_ppsh");
                        spawnSoldier(m_metagame,1,factionid,c_pos3,"ar_58_ak47");
                        spawnSoldier(m_metagame,1,factionid,c_pos4,"ar_58_ak47");
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(0,40,0)),target_pos);
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(3,40,3)),target_pos.add(Vector3(3,0,3)));
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(-3,40,-3)),target_pos.add(Vector3(-3,0,-3)));
                    }
                    if (count == 3 ){
                        int is2_exist = getNumberedVehicle(m_metagame,factionid,"is2_m1895.vehicle");
                        if (is2_exist < 2)
                        {
                            Vector3 u_pos = getAimUnitPosition(c_pos,target_pos,8.0);
                            u_pos = u_pos.add(Vector3(0,25,0));
                            float ori4 = getAimOrientation4(c_pos,target_pos);
                            spawnVehicle(m_metagame,1,factionid,u_pos,Orientation(0,1,0,ori4),"is2_m1895.vehicle"); 
                        }
                        else
                        {
                            healRangedCharacters(m_metagame,c_pos,factionid,20.0,10);
                            Vector3 c_pos1 = target_pos.add(Vector3(3,0,3));
                            Vector3 c_pos2 = target_pos.add(Vector3(-3,0,-3));
                            Vector3 c_pos3 = target_pos.add(Vector3(-3,0,3));
                            Vector3 c_pos4 = target_pos.add(Vector3(3,0,-3));                        
                            spawnSoldier(m_metagame,1,factionid,c_pos1,"smg_21_ppsh");
                            spawnSoldier(m_metagame,1,factionid,c_pos2,"smg_21_ppsh");
                            spawnSoldier(m_metagame,1,factionid,c_pos3,"ar_58_ak47");
                            spawnSoldier(m_metagame,1,factionid,c_pos4,"ar_58_ak47");
                            insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(0,40,0)),target_pos);
                            insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(3,40,3)),target_pos.add(Vector3(3,0,3)));
                            insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(-3,40,-3)),target_pos.add(Vector3(-3,0,-3)));                                
                        }
                    }
                    if (count > 3)
                    {
                        healRangedCharacters(m_metagame,c_pos,factionid,20.0,10);
                        Vector3 c_pos1 = target_pos.add(Vector3(3,0,3));
                        Vector3 c_pos2 = target_pos.add(Vector3(-3,0,-3));
                        Vector3 c_pos3 = target_pos.add(Vector3(-3,0,3));
                        Vector3 c_pos4 = target_pos.add(Vector3(3,0,-3));                        
                        spawnSoldier(m_metagame,1,factionid,c_pos1,"smg_21_ppsh");
                        spawnSoldier(m_metagame,1,factionid,c_pos2,"smg_21_ppsh");
                        spawnSoldier(m_metagame,1,factionid,c_pos3,"ar_58_ak47");
                        spawnSoldier(m_metagame,1,factionid,c_pos4,"ar_58_ak47");
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(0,40,0)),target_pos);
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(3,40,3)),target_pos.add(Vector3(3,0,3)));
                        insertCommonStrike(characterId,factionid,15,target_pos.add(Vector3(-3,40,-3)),target_pos.add(Vector3(-3,0,-3))); 
                    }
                    addCooldown("Nagant",240,characterId,modifer);
                }
            }
        }        
    }
    void excuteM1911skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"M1911")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "M1911_SKILL1_JP.wav",
                        "M1911_SKILL2_JP.wav",
                        "M1911_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"smoke_grenade.projectile",characterId,factionid,26.0,6.0);
                    addCooldown("M1911",30,characterId,modifer);
                }
            }
        }
    }        
    void excuteM1911mod3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"M1911")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 t_pos = stringToVector3(target);
                    t_pos = t_pos.add(Vector3(0,5,0));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "M1911Mod_SKILL1_JP.wav",
                        "M1911Mod_SKILL2_JP.wav",
                        "M1911Mod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));
                    CreateProjectile_H(m_metagame,c_pos,t_pos,"smoke_grenade.projectile",characterId,factionid,26.0,6.0);
                    Skill_m1911mod3@ shot = Skill_m1911mod3(m_metagame,1.5,characterId,factionid,t_pos);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    tasker.add(shot);
                    addCooldown("M1911",30,characterId,modifer);
                }
            }
        }
    }        
    void excuteHunterskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_Hunter")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 t_pos = stringToVector3(target);
                    t_pos = t_pos.add(Vector3(0,0,0));
                    int factionid = character.getIntAttribute("faction_id");
					array<string> Voice={
						"Hunter_buhuo_SKILL01_JP.wav",
						"Hunter_buhuo_SKILL03_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playSoundAtLocation(m_metagame,"grenade_throw1.wav",factionid,c_pos,1.0);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,2,0));
                    CreateProjectile_H(m_metagame,c_pos,t_pos,"ff_emp_mine.projectile",characterId,factionid,90,2);
                    Skill_ff_hunter@ shot = Skill_ff_hunter(m_metagame,1,characterId,factionid,t_pos);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    tasker.add(shot);
                    addCooldown("FF_Hunter",20,characterId,modifer);
                }
            }
        }
    }        
    void excuteDreamerskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"FF_Dreamer")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 t_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
					array<string> Voice={
						"Dreamer_buhuo_SKILL01_JP.wav",
						"Dreamer_buhuo_SKILL03_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"air thrust",true,true);
                    c_pos=c_pos.add(Vector3(0,2,0));
                    Skill_ff_dreamer@ shot = Skill_ff_dreamer(m_metagame,1,characterId,factionid,c_pos,t_pos);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    tasker.add(shot);
                    addCooldown("FF_Dreamer",30,characterId,modifer);
                }
            }
        }
    }        

    void excuteStenSterlingskill(int characterId,int playerId,SkillModifer@ modifer,string c_weaponType){
        int index = findNodeleteDataIndex(playerId,"StenSterling");
        int medal_num = 1;
        if (index>=0) medal_num = No_Delete_DataArray[index].m_num;
        medal_num = min(medal_num,4);                
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"StenSterling",false,"constant",medal_num)) return;

        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            if (!canCastSkill(character)) return;
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string target = player.getStringAttribute("aim_target");
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    Vector3 s_pos = stringToVector3(target);
                    int factionid = character.getIntAttribute("faction_id");
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos = c_pos.add(Vector3(0,1,0));
                    c_pos = c_pos.add((getAimUnitVector(1,c_pos,s_pos)));

                    if(c_weaponType=="gkw_stenmod3.weapon"){
                        array<string>Voice={
                            "StenMK2Mod_SKILL1_JP.wav",
                            "StenMK2Mod_SKILL2_JP.wav"
                        };         
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                                       
                    }else if(c_weaponType=="gkw_sterling.weapon"){
                        array<string>Voice={
                            "StenMK2Mod_SKILL1_JP.wav",
                            "StenMK2Mod_SKILL1_JP.wav"
                        };             
                        playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);                                            
                    }

                    if(!tryaddChargeCount("StenSterling",characterId,modifer,false)){
                        // _log("no new charge");
                        addCooldown("StenSterling",15,characterId,modifer,"constant");
                    }
                    if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"UsedStenSterling"))
                    {
                        refreshCooldown(characterId,modifer,"UsedStenSterling");
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s1_dmgup.projectile",characterId,factionid,90);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s1_dmgup.projectile",characterId,factionid,50.0,5.0);
                        }                        
                    }
                    else{
                        addCooldown("UsedStenSterling",6,characterId,modifer,"nohint");
                        if (checkFlatRange(c_pos,stringToVector3(target),15)){
                            CreateDirectProjectile(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s1.projectile",characterId,factionid,90);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,stringToVector3(target),"grenade_m67_s1.projectile",characterId,factionid,50.0,5.0);
                        }
                    }
                    
                }
            }
        }
    }

    void excuteOwenskill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"owen")) return;
        addCooldown("owen",60,characterId,modifer);
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
                c.setIntAttribute("untransform_count", 5);
                m_metagame.getComms().send(c);
            }
            // array<string> Voice={
            // };
            // playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
        }
    }    

    void excuteM1897MOD3skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"m1897_aim")) return;
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"m1897",true,"constant",6)) return;     
        const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
        const XmlElement@ playerinfo = getPlayerInfo(m_metagame, playerId);
        if (playerinfo is null) return;

        if (playerinfo.hasAttribute("aim_target")) {
            string target = playerinfo.getStringAttribute("aim_target");
            Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
            Vector3 s_pos = stringToVector3(target);
            int factionid = characterinfo.getIntAttribute("faction_id");
    
            int m_fnum = m_metagame.getFactionCount();
            array<const XmlElement@> affectedCharacter;
            for(int i=0;i<m_fnum;i++) {
                if(i!=factionid) {
                    array<const XmlElement@> affectedCharacter2;
                    affectedCharacter2 = getCharactersNearPosition(m_metagame,s_pos,i,5.0f);
                    if (affectedCharacter2 !is null){
                        for(uint x=0;x<affectedCharacter2.length();x++){
                            affectedCharacter.insertLast(affectedCharacter2[x]);
                        }
                    }
                }
            }

            if (affectedCharacter !is null && affectedCharacter.length > 0){
                int closestIndex = -1;
                float closestDistance = -1.0f;                
                for(uint i=0;i<affectedCharacter.length();i++){
                    float distance = getPositionDistance(s_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
                    if (distance < closestDistance || closestDistance < 0.0){
                        closestDistance = distance;
                        closestIndex = i;
                    }
                }

                if (closestIndex >= 0){
                    if(!tryaddChargeCount("m1897",characterId,modifer,true)){
                        addCooldown("m1897",20,characterId,modifer,"constant");
                    }
                    int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
                    playAnimationKey(m_metagame,characterId,"recoil1, big",true,false);
                    TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
                    DelayAntiPersonSnipeRequest@ snipe_task = DelayAntiPersonSnipeRequest(m_metagame,0.3,characterId,factionid,"flechette_m1897.projectile",c_pos.add(Vector3(0,0.5,0)),target_id);
                    snipe_task.setKey("flechette.projectile");
                    tasker.add(snipe_task);
                }
            }
            else{
                addCooldown("m1897_aim",3,characterId,modifer,"normal",false);
                sendFactionMessageKeySaidAsCharacter(m_metagame,0,characterId,"snipe_skill_notfound");
            }  
        } 
    }    
    void excuteType82skill(int characterId,int playerId,SkillModifer@ modifer){
        if (excuteCooldownCheck(m_metagame,characterId,modifer,playerId,"Type82")) return;
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character !is null) {
            const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
            if (player !is null){
                if (player.hasAttribute("aim_target")) {
                    string player_name=player.getStringAttribute("name");
                    Vector3 target_pos = stringToVector3(player.getStringAttribute("aim_target"));
                    Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
                    int factionid = character.getIntAttribute("faction_id");
                    array<string> Voice={
                        "M1895Mod_SKILL1_JP.wav",
                        "M1895Mod_SKILL2_JP.wav",
                        "M1895Mod_SKILL3_JP.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
                    playAnimationKey(m_metagame,characterId,"throwing, upside",true,true);
                    c_pos=c_pos.add(Vector3(0,1,0));

                    array<const XmlElement@> affectedCharacter;
					array<const XmlElement@> characters = getEnemyCharactersNearPosition(m_metagame,c_pos,factionid,25.0f);
                    for (uint i = 0; i < characters.length(); i++) {   
                        int cidd = characters[i].getIntAttribute("id");
                        const XmlElement@ possibleElitecharacter = getCharacterInfo(m_metagame,cidd);
                        string soldier_name = possibleElitecharacter.getStringAttribute("soldier_group_name");
                        if(eliteEnemyName.find(soldier_name)> -1){
                            affectedCharacter.insertLast(characters[i]);
                            _log("found elite");
                            break;                                  
                        }
                    }

                    int count = g_playerInfo_Buck.getKillSkillCountbyName(player_name,"Type82");
                    int jud = (characters.length()>0)?(1+characters.length()/10):0;
                    count += jud;
                    jud = min(jud+1,3-count);
                    g_playerInfo_Buck.addKillSkillCountbyName(player_name,"Type82",jud);

                    dictionary a;
                    a["%count"] = ""+count;
                    notify(m_metagame, "Hint - Skill charge count", a, "misc", playerId, false, "", 1.0);
                                        
                    addCooldown("Type82",15,characterId,modifer);
                    if (count == 0){
                        if (checkFlatRange(c_pos,target_pos,15)){
                            CreateDirectProjectile(m_metagame,c_pos,target_pos,"grenade_type82.projectile",characterId,factionid,90);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,target_pos,"grenade_type82.projectile",characterId,factionid,50.0,5.0);
                        }
                        return;
                    }
                    else if (count >= 1){
                        if (checkFlatRange(c_pos,target_pos,15)){
                            CreateDirectProjectile(m_metagame,c_pos,target_pos,"grenade_type82_rangeup.projectile",characterId,factionid,100);
                        }
                        else{
                            CreateProjectile_H(m_metagame,c_pos,target_pos,"grenade_type82_rangeup.projectile",characterId,factionid,50.0,5.0);
                        }
                    }
                    if (count >= 2){
                        if(affectedCharacter.length()>0){
                            int luckyoneid = affectedCharacter[0].getIntAttribute("id");
                            const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
                            if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
                                string luckyonepos = luckyoneC.getStringAttribute("position");
                                Vector3 target = stringToVector3(luckyonepos);
                                if (checkFlatRange(c_pos,target,15)){
                                    CreateDirectProjectile(m_metagame,c_pos,target,"grenade_type82_elite.projectile",characterId,factionid,90);
                                }
                                else{
                                    CreateProjectile_H(m_metagame,c_pos,target,"grenade_type82_elite.projectile",characterId,factionid,50.0,5.0);
                                }
                            }	
                        }
                    }
                    if (count >= 3 ){
                        healCharacter(m_metagame,characterId,3);
                        return;
                    }
                }
            }
        }        
    }
}
