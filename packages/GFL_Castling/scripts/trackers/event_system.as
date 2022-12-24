#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "GFLairstrike.as"

//Author: NetherCrow
// 本系统用于容纳持续性请求
dictionary GFL_Event_Index = {

        // Null
        {"",-1},

        // 狙击妖精
        {"sniper_fairy",1},

        // 暴怒妖精——AC130
        {"rampage_fairy_ac130",2},

        {"sniper_m200",3},

        {"mg_strafe",4},

        {"ump45mod3_smoke",5},

        // 勇士妖精——Apache
        {"warrior_fairy_apache",6},

        {"bomb_fairy",7},

        // 天气系统——离子风暴
        // {"ion_storm",8},

        // 天气系统——闪电风暴
        {"lightning_storm",9},

        // 下面这行是用来占位的，在这之上添加新的即可
        {"666",-1}
};

array<GFL_event@> GFL_event_array;

class GFL_event_system : Tracker {
	protected GameMode@ m_metagame;


	// --------------------------------------------
	GFL_event_system(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

    void update(float time) {
        if(GFL_event_array.length()>0){        
            for (uint a=0;a<GFL_event_array.length();a++){
                GFL_event_array[a].m_time-=time;
                if(GFL_event_array[a].m_time<=0){
                    if(GFL_event_array[a].m_enable){
                        // int cid = GFL_event_array[a].m_characterId;
                        // int fid = GFL_event_array[a].m_factionid;
                        // Vector3 event_pos = GFL_event_array[a].m_pos;
                        switch(GFL_event_array[a].m_eventkey){
                            case 1:{excuteSniperFairy(m_metagame,GFL_event_array[a]);break;}
                            case 2:{
                                if(GFL_event_array[a].m_randseed==-1.0){
                                    GFL_event_array[a].m_randseed= rand(0.0,3.14);
                                }
                                excuteRampageFairyAC130(m_metagame,GFL_event_array[a]);
                                break;
                            }
                            case 3:{excuteSniperM200(m_metagame,GFL_event_array[a]);break;}
                            case 4:{excuteYaoren(m_metagame,GFL_event_array[a]);break;}
                            case 5:{excuteUMP45MOD3event(m_metagame,GFL_event_array[a]);break;}
                            case 6:{
                                if(GFL_event_array[a].m_randseed==-1.0){
                                    GFL_event_array[a].m_randseed= rand(0.0,3.14);
                                }
                                excuteWarriorFariyApache(m_metagame,GFL_event_array[a]);
                                break;
                            }
                            case 7:{excuteBombFairy(m_metagame,GFL_event_array[a]);break;}
                            // case 8:{excuteIonStormFairy(m_metagame,GFL_event_array[a]);break;}
                            case 9:{excuteLightningStorm(m_metagame,GFL_event_array[a]);break;}

                            default:
                                break;
                        }
                    }
                    else{
                        if(GFL_event_array[a].m_markerId != 0){
                            removeCastlingMarker(GFL_event_array[a]);
                        }
                        GFL_event_array.removeAt(a);
                    }
                }
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

    protected void removeCastlingMarker(GFL_event@ info){
        XmlElement command("command");
            command.setStringAttribute("class", "set_marker");
            command.setIntAttribute("id", info.m_markerId);
            command.setIntAttribute("faction_id", info.m_factionid);
            command.setIntAttribute("enabled", 0);
        m_metagame.getComms().send(command);
    }
}

class GFL_event{
    int m_characterId;
	int m_factionid;
    int m_eventkey;
    Vector3 m_pos;
    Vector3 m_dir;
    float m_randseed;
    int m_specialkey=1;

    int m_phase=1;
    int m_markerId=0;
    float m_time;
    bool m_enable=true;

    GFL_event(int characterId,int factionid,int key,Vector3 pos,float delay_time=0.0,float randseed=-1.0,int markerId=0,Vector3 dir=Vector3(0,0,0)){
        m_characterId=characterId;
        m_factionid=factionid;
        m_eventkey=key;
        m_pos=pos;
        m_time=delay_time;
        m_randseed=randseed;
        m_markerId=markerId;
        m_dir=dir;
    }

    GFL_event(int characterId,int factionid,string key,Vector3 pos,float delay_time=0.0,float randseed=-1.0,int markerId=0,Vector3 dir=Vector3(0,0,0)){
        m_characterId=characterId;
        m_factionid=factionid;
        m_eventkey=int(GFL_Event_Index[key]);
        m_pos=pos;
        m_time=delay_time;
        m_randseed=randseed;
        m_markerId=markerId;
        m_dir=dir;
    }

    void setSpeicalKey(int key){
        m_specialkey=key;
    }
}

void excuteSniperFairy(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.5;
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,40.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,8,getRandomOffsetVector(eventinfo.m_pos,60.0),luckyGuyPos);                        
    }
    if(eventinfo.m_phase<=1)
    {
        sendFactionMessageKey(metagame,eventinfo.m_factionid,"snipefight");
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=10){
        eventinfo.m_enable=false;
    }
}

void excuteSniperM200(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.5;
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,40.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,4,getRandomOffsetVector(eventinfo.m_pos,70.0),luckyGuyPos);                        
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=6){
        eventinfo.m_enable=false;
    }
}

void excuteUMP45MOD3event(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=2.0;
    // array<const XmlElement@>@ characters = getCharactersNearPosition(metagame, eventinfo.m_pos, eventinfo.m_factionid, 10.0f);
    // for (uint i = 0; i < characters.length; i++) {
    //     int soldierId = characters[i].getIntAttribute("id");
    //     XmlElement c ("command");
    //     c.setStringAttribute("class", "update_inventory");
    //     c.setIntAttribute("character_id", soldierId); 
    //     c.setIntAttribute("untransform_count", 5);
    //     metagame.getComms().send(c);
    // }
    CreateDirectProjectile(metagame,eventinfo.m_pos.add(Vector3(0,6,0)),eventinfo.m_pos.add(Vector3(0,6.1,0)),'ump45mod3_skill.projectile',eventinfo.m_characterId,eventinfo.m_factionid,10);
    eventinfo.m_phase++;
    if(eventinfo.m_phase>9){
        eventinfo.m_enable=false;
    }
}

array<int> ParatrooperHeight={
    50,50,50,50,35,20,20,20,35,50,50,50,50
};

void excuteYaoren(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.0;
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,30.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,9,eventinfo.m_pos.add(Vector3(0.0,float(ParatrooperHeight[eventinfo.m_phase]),4.0)),luckyGuyPos);                        
    }
    if(eventinfo.m_phase==3){
        string c = 
        "<command class='create_instance'" +
        " faction_id='"+ eventinfo.m_factionid +"'" +
        " instance_class='vehicle'" +
        " instance_key='osprey_enter' " +
        " character_id='" + eventinfo.m_characterId +"'" +
        " position='" + (eventinfo.m_pos.add(Vector3(0,50,0))).toString() + "' />";
        metagame.getComms().send(c);
        TaskSequencer@ tasker = metagame.getTaskManager().newTaskSequencer();
        array<Spawn_request@> spawn_soldier =
        {
            Spawn_request("Task_MG",5),
            Spawn_request("Task_SG",3)
        };        
        tasker.add(DelaySpawnSoldier(metagame,6.0,eventinfo.m_factionid,spawn_soldier,eventinfo.m_pos,3.0,3.0));        
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=10){
        eventinfo.m_enable=false;
    }
}

void excuteLightningStorm(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=5;
    
    Vector3 lightning_storm_center_pos = eventinfo.m_pos.add(Vector3(0,20,0));
    CreateDirectProjectile(metagame,lightning_storm_center_pos,lightning_storm_center_pos,"weather_lightning_storm_1.projectile",eventinfo.m_characterId,eventinfo.m_factionid,0);
    
    eventinfo.m_phase++;
    if(eventinfo.m_phase>12){
        eventinfo.m_enable=false;
    }        
}

void excuteBombFairy(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=0.6;
    if(eventinfo.m_phase<=1)
    {
        sendFactionMessageKey(metagame,eventinfo.m_factionid,"bombfight");
    }    
    if(eventinfo.m_phase!=7){
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,14,eventinfo.m_pos.add(Vector3(0,40,0)),eventinfo.m_pos);
    }
    if(eventinfo.m_phase==6){
        eventinfo.m_time=1.0;
    }    
    if(eventinfo.m_phase==7){
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,15,eventinfo.m_pos.add(Vector3(0,40,0)),eventinfo.m_pos);
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=8){
        eventinfo.m_enable=false;
    }        
}

array<int> RampageFairyAC130List={
    6,6,6,5,6,6,6,5,7
};

int ac130_rocket_ready = 8;
int ac130_rocket_ammo = 1;
int ac130_shotgun_ready = 3;
int ac130_shotgun_ammo = 3;
int ac130_minigun_ready = 0;
int ac130_minigun_ammo = 1;

int ac130_voice_interval = 0;
int ac130_flyby_interval = 0;
int ac130_strike_num = 30;
int ac130_jud_confused = 0;

Vector3 ac130_pre_pos = Vector3(-1,-1,-1); // 这是为了ac130索敌能每次尽量锁附近的，而不是去到处乱锁
// 事实证明有时候不如随机锁      

void excuteRampageFairyAC130(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time = 1.8;
    array<string> AC130StartVoice;
    array<string> AC130EndVoice;
    array<string> AC130NoTargetVoice;
    array<string> AC130MinigunVoice;
    array<string> AC130ShotgunVoice;
    array<string> AC130M202Voice;

    if(ac130_voice_interval>0)ac130_voice_interval -= 1;
    if(eventinfo.m_phase>=(ac130_strike_num-2))ac130_voice_interval = 99;
    if(ac130_flyby_interval>0)ac130_flyby_interval -= 1;

    switch(eventinfo.m_specialkey){
        case 1:
        {
            AC130StartVoice.insertLast("ac130entrance_rus1.wav");
            AC130StartVoice.insertLast("ac130entrance_rus2.wav");
            AC130StartVoice.insertLast("ac130entrance_rus3.wav");

            AC130EndVoice.insertLast("ac130exit_rus1.wav");
            AC130EndVoice.insertLast("ac130exit_rus2.wav");
            AC130EndVoice.insertLast("ac130exit_rus3.wav");

            AC130NoTargetVoice.insertLast("ac130search_rus1.wav");
            AC130NoTargetVoice.insertLast("ac130search_rus2.wav");

            AC130MinigunVoice.insertLast("ac130mg_rus1.wav");
            AC130MinigunVoice.insertLast("ac130mg_rus2.wav");
            AC130MinigunVoice.insertLast("ac130allguns_rus1.wav");
            AC130MinigunVoice.insertLast("ac130allguns_rus2.wav");
            AC130MinigunVoice.insertLast("ac130allguns_rus3.wav");

            AC130ShotgunVoice.insertLast("ac130sg_rus1.wav");
            AC130ShotgunVoice.insertLast("ac130sg_rus2.wav");
            AC130ShotgunVoice.insertLast("ac130allguns_rus1.wav");
            AC130ShotgunVoice.insertLast("ac130allguns_rus2.wav");
            AC130ShotgunVoice.insertLast("ac130allguns_rus3.wav");

            AC130M202Voice.insertLast("ac130rpg_rus1.wav");
            AC130M202Voice.insertLast("ac130rpg_rus2.wav");
            AC130M202Voice.insertLast("ac130rpg_rus3.wav");
            AC130M202Voice.insertLast("ac130allguns_rus1.wav");
            AC130M202Voice.insertLast("ac130allguns_rus2.wav");
            AC130M202Voice.insertLast("ac130allguns_rus3.wav");
            break;
        }
        case 2:
        {
            AC130StartVoice.insertLast("ac130entrance_blkops1.wav");
            AC130StartVoice.insertLast("ac130entrance_blkops2.wav");
            AC130StartVoice.insertLast("ac130entrance_blkops3.wav");

            AC130EndVoice.insertLast("ac130exit_blkops1.wav");
            AC130EndVoice.insertLast("ac130exit_blkops2.wav");
            AC130EndVoice.insertLast("ac130exit_blkops3.wav");

            AC130NoTargetVoice.insertLast("ac130search_blkops1.wav");
            AC130NoTargetVoice.insertLast("ac130search_blkops2.wav");
            AC130NoTargetVoice.insertLast("ac130search_blkops3.wav");
            AC130NoTargetVoice.insertLast("ac130search_blkops4.wav");

            AC130MinigunVoice.insertLast("ac130mg_blkops1.wav");
            AC130MinigunVoice.insertLast("ac130mg_blkops2.wav");

            AC130ShotgunVoice.insertLast("ac130sg_blkops1.wav");
            AC130ShotgunVoice.insertLast("ac130sg_blkops2.wav");
            AC130ShotgunVoice.insertLast("ac130sg_blkops3.wav");

            AC130M202Voice.insertLast("ac130rpg_blkops1.wav");
            AC130M202Voice.insertLast("ac130rpg_blkops2.wav");
            AC130M202Voice.insertLast("ac130rpg_blkops3.wav");
            break;
        }
        case 3:
        {
            AC130StartVoice.insertLast("ac130entrance_nato1.wav");
            AC130StartVoice.insertLast("ac130entrance_nato2.wav");
            AC130StartVoice.insertLast("ac130entrance_nato3.wav");

            AC130EndVoice.insertLast("ac130exit_nato1.wav");
            AC130EndVoice.insertLast("ac130exit_nato2.wav");
            AC130EndVoice.insertLast("ac130exit_nato3.wav");

            AC130NoTargetVoice.insertLast("ac130search_nato1.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato2.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato3.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato4.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato5.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato6.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato7.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato8.wav");
            AC130NoTargetVoice.insertLast("ac130search_nato9.wav");

            AC130MinigunVoice.insertLast("ac130mg_nato1.wav");
            AC130MinigunVoice.insertLast("ac130mg_nato2.wav");
            AC130MinigunVoice.insertLast("ac130mg_nato3.wav");
            AC130MinigunVoice.insertLast("ac130mg_nato4.wav");

            AC130ShotgunVoice.insertLast("ac130sg_nato1.wav");
            AC130ShotgunVoice.insertLast("ac130sg_nato2.wav");
            AC130ShotgunVoice.insertLast("ac130sg_nato3.wav");

            AC130M202Voice.insertLast("ac130rpg_nato1.wav");
            AC130M202Voice.insertLast("ac130rpg_nato2.wav");
            AC130M202Voice.insertLast("ac130rpg_nato3.wav");
            AC130M202Voice.insertLast("ac130rpg_nato4.wav");
            AC130M202Voice.insertLast("ac130rpg_nato5.wav");
            break;
        }
        default:break;        
    }

    if(eventinfo.m_phase<=1)
    {
        playSoundAtLocation(metagame,"ac130_flyby.wav",eventinfo.m_factionid,eventinfo.m_pos,3.0);
        playRandomSoundArray(metagame,AC130StartVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),4.0);
        ac130_voice_interval = 2;
        ac130_flyby_interval = 3;
        ac130_pre_pos = eventinfo.m_pos;
        sendFactionMessageKey(metagame,eventinfo.m_factionid,"ac130fight");
                
        ac130_rocket_ready = 8;
        ac130_rocket_ammo = 1;
        ac130_shotgun_ready = 3;
        ac130_shotgun_ammo = 3;
        ac130_minigun_ready = 0;
        ac130_minigun_ammo = 1;
    }

    float jud_time = eventinfo.m_phase*eventinfo.m_time;
    // 这里的30是ac130飞行音效持续时间
    // 这里因为ac130持续时间就30秒，除非射击间隔超过2秒否则一般只用播放两轮，只看最后一轮什么时候放就行
    // 算了保险起见都写着
    // tnnd为了配合下面还得中途多放几次
    int voice_last_time = 30;
    int voice_phase_interval = int(voice_last_time/eventinfo.m_time);
    if( (ac130_flyby_interval == 0) && ((ac130_strike_num-eventinfo.m_phase)>(voice_phase_interval-4))){
        _log("current phase: " + eventinfo.m_phase);
        ac130_flyby_interval == 6;
        playSoundAtLocation(metagame,"ac130_flyby.wav",eventinfo.m_factionid,eventinfo.m_pos,3.0);
    }

    int luckyGuyid;
    float searchrange_nearby = 15.0f;
    float searchrange_origin = 60.0f;

    // 随机索敌
    // luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,searchrange_origin);

    // 优先锁定上一个目标点旁边的
    luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,searchrange_nearby);
    Vector3 ac130_jud_pos;

    // 如果没有索敌到敌人或者距离超过130范围，重新索敌一次
    if (luckyGuyid!=-1) {
        ac130_jud_pos = stringToVector3(getCharacterInfo(metagame,luckyGuyid).getStringAttribute("position"));
        if(getAimUnitDistance(1.0,ac130_jud_pos,eventinfo.m_pos)>(searchrange_origin+9.0f)) {
            ac130_pre_pos = eventinfo.m_pos;
            luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,searchrange_origin);
        }
    }
    else {
        ac130_pre_pos = eventinfo.m_pos;
        luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,searchrange_origin);
    }
        
    if(eventinfo.m_phase>1){
        if(luckyGuyid!=-1){
            ac130_jud_confused = 0;
            
            uint jud_num = eventinfo.m_phase/10;
            float rand_angle = eventinfo.m_randseed + eventinfo.m_phase*3.14/10;

            Vector3 luckyGuyPos = stringToVector3(getCharacterInfo(metagame,luckyGuyid).getStringAttribute("position"));
            Vector3 aimPos = eventinfo.m_pos.add(Vector3(45.0*cos(rand_angle),60,45.0*sin(rand_angle)));
            ac130_pre_pos = luckyGuyPos;

            //攻击由phase模式改为充能模式
            if(ac130_rocket_ready<=0 && ac130_rocket_ammo<1)    {ac130_rocket_ammo+=1;ac130_rocket_ready=8;}
            if(ac130_shotgun_ready<=0 && ac130_shotgun_ammo<3)  {ac130_shotgun_ammo+=1;ac130_shotgun_ready=3;}
            if(ac130_minigun_ready<=0 && ac130_minigun_ammo<1)  {ac130_minigun_ammo+=1;ac130_minigun_ready=0;}

            int attacknum;
            if(ac130_rocket_ammo>0)         {attacknum=7;ac130_rocket_ammo-=1;}
            else if(ac130_shotgun_ammo>0)   {attacknum=5;ac130_shotgun_ammo-=1;}
            else                            {attacknum=6;ac130_minigun_ammo-=1;}

            ac130_rocket_ready-=1;  ac130_shotgun_ready-=1;  ac130_minigun_ready-=0;

            //int attacknum = RampageFairyAC130List[int(eventinfo.m_phase%RampageFairyAC130List.length())];

            // 烈火看这里，对 playSoundAtLocation 这个函数的 第二项（音效文件名） 和 最后一项（音量大小） 操作就行
            // 5是霰弹音效，可以不用给其实；6是机炮音效；7是火箭弹齐射音效
            switch(attacknum)
            {
                case 5:{playSoundAtLocation(metagame,"ac130sg_fire_FromWARTHUNDER.wav",eventinfo.m_factionid,eventinfo.m_pos,3);break;}
                case 6:{playSoundAtLocation(metagame,"ac130mg_fire_FromSAM4.wav",eventinfo.m_factionid,eventinfo.m_pos,3.1);break;}
                case 7:{playSoundAtLocation(metagame,"ac130rpg_fire_FromCOD16.wav",eventinfo.m_factionid,eventinfo.m_pos,2.4);break;}
                default:    break;
            }  

            insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,attacknum,aimPos,luckyGuyPos);

            if(ac130_voice_interval<=0){
                switch(attacknum)
                {
                    case 5:{playRandomSoundArray(metagame,AC130ShotgunVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);break;}
                    case 6:{playRandomSoundArray(metagame,AC130MinigunVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);break;}
                    case 7:{playRandomSoundArray(metagame,AC130M202Voice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);break;}
                    default:    break;
                }           
                ac130_voice_interval = 2;
            }
        }
        else if(ac130_voice_interval<=0){
            
            ac130_voice_interval = 2;
            // ac130_jud_confused++;
            // if(ac130_jud_confused>=5){
            //     ac130_jud_confused = 0;
            //     playSoundAtLocation(metagame,AC130NoTargetVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);
            // }
            // else playRandomSoundArray(metagame,AC130NoTargetVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);

            playRandomSoundArray(metagame,AC130NoTargetVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);

        }        
    }

    eventinfo.m_phase++;
    if(eventinfo.m_phase>=ac130_strike_num){
        playRandomSoundArray(metagame,AC130EndVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);
        eventinfo.m_enable=false;
    }
}

int apache_javelin_luckyvehicleid = -1;

array<Apache_Javelin_lister@> Apache_Javelin_list;

void excuteWarriorFariyApache(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=0.33;
    Vector3 aimPos = eventinfo.m_pos.add(Vector3(10.0*cos(eventinfo.m_randseed),40,10.0*sin(eventinfo.m_randseed)));

    if(eventinfo.m_phase==18){
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,"apache_bait",aimPos,eventinfo.m_pos);
    }

    else if(eventinfo.m_phase==1){
        sendFactionMessageKey(metagame,eventinfo.m_factionid,"warriorfight");
        apache_javelin_luckyvehicleid  = getNearByEnemyVehicle(metagame,eventinfo.m_factionid,eventinfo.m_pos,20);
        if(apache_javelin_luckyvehicleid!=-1)playSoundAtLocation(metagame,"javelin_locked.wav",eventinfo.m_factionid,eventinfo.m_pos,1.0);//锁定载具成功
        else	playSoundAtLocation(metagame,"javelin_lock_fail.wav",eventinfo.m_factionid,eventinfo.m_pos,1.0);//未锁定载具
        Apache_Javelin_list.insertLast(Apache_Javelin_lister(eventinfo.m_characterId,eventinfo.m_factionid,apache_javelin_luckyvehicleid,eventinfo.m_pos));
    }

    // else if(eventinfo.m_phase==3){

    //     int m_fnum = metagame.getFactionCount();
    //     int max_check = 6;  // 最多扫描6个人
    //     int jud_check = 0;
    //     int max_num = 3;    // 最多记录3个精英
    //     int jud_num = 0;

    //     array<const XmlElement@> apache_affectedCharacter;
    //     for(int i=0;i<m_fnum;i++) 
    //         if(i!=eventinfo.m_factionid) {

    //         array<const XmlElement@> affectedCharacter2;
    //         affectedCharacter2 = getCharactersNearPosition(metagame,eventinfo.m_pos,i,20.0f);

    //         // 优先扫描精英
    //         if (affectedCharacter2 !is null){
    //             for(uint x=0;x<affectedCharacter2.length();x++){
    //                 int cidd = affectedCharacter2[x].getIntAttribute("id");
    //                 const XmlElement@ possibleElitecharacter = getCharacterInfo(metagame,cidd);
    //                 string soldier_name = possibleElitecharacter.getStringAttribute("soldier_group_name");
    //                 max_check++;
    //                 if(eliteEnemyName.find(soldier_name)> -1){
    //                     apache_affectedCharacter.insertLast(affectedCharacter2[x]);
    //                     jud_num++;
    //                     if((jud_num>=max_num) || (jud_check>=max_check))break;                                      
    //                 }
    //                 if((jud_num>=max_num) || (jud_check>=max_check))break; 
    //             }
    //         }
    //         if((jud_num>=max_num) || (jud_check>=max_check))break;

    //         // 如果精英数量少于3个，则继续选择其他敌人，满额为止
    //         else if (affectedCharacter2 !is null){
    //             for(uint x=0;x<affectedCharacter2.length();x++){
    //                 apache_affectedCharacter.insertLast(affectedCharacter2[x]);
    //                 jud_num++;  max_check++;
    //                 if((jud_num>=max_num) || (jud_check>=max_check))break;                                      
    //             }
    //         }
    //         if((jud_num>=max_num) || (jud_check>=max_check))break;
    //     }         

    //     playSoundAtLocation(metagame,"30mm_strafe.wav",eventinfo.m_factionid,eventinfo.m_pos,1.0);

    //     for (uint i0=1;i0<=3;i0++){
    //         for (uint i1=0;i1<apache_affectedCharacter.length();i1++)	{
    //             int luckyoneid = apache_affectedCharacter[i1].getIntAttribute("id");
    //             const XmlElement@ luckyoneC = getCharacterInfo(metagame, luckyoneid);
    //             if ((luckyoneC.getIntAttribute("id")!=-1)){
    //                 string luckyonepos = luckyoneC.getStringAttribute("position");
    //                 Vector3 luckyoneposV = stringToVector3(luckyonepos);
    //                 insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,"apache_mg",aimPos,luckyoneposV);
    //             }				
    //         }        
    //     }
    // }

    else if(eventinfo.m_phase==9){
        playSoundAtLocation(metagame,"30mm_strafe.wav",eventinfo.m_factionid,eventinfo.m_pos,1.0);
    }

    else if(eventinfo.m_phase>=9){
        int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,30.0f);
        if(luckyGuyid!=-1){
            const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
            Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
            insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,"apache_mg",aimPos,luckyGuyPos);                        
        }
    }


    else if(eventinfo.m_phase==12){
        if(Apache_Javelin_list.length()>0){
            for (uint a=0;a<Apache_Javelin_list.length();a++){
                if((Apache_Javelin_list[a].m_characterId==eventinfo.m_characterId)&&(Apache_Javelin_list[a].m_factionid==eventinfo.m_factionid)){//在序列中如果能找到
                    _log("javelin_locate_aimer success");
                    int target_id = Apache_Javelin_list[a].m_vehicleid;
                    Vector3 target_fin_pos;
                    if(target_id!=-1){
                        _log("aimming 2 success.");
                        const XmlElement@ target_info = getVehicleInfo(metagame, target_id);
                        target_fin_pos = stringToVector3(target_info.getStringAttribute("position"));//标枪导弹目标位置
                    }
                    else{
                        target_fin_pos = Apache_Javelin_list[a].m_pos;
                    }
                    insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,"apache_javelin",aimPos,target_fin_pos);
                    Apache_Javelin_list.removeAt(a);
                    break;																	
                }
            }
        }
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=18){
        eventinfo.m_enable=false;
    }
}

class Apache_Javelin_lister{
    int m_characterId;
	float m_time=6;
	int m_numtime=1;
	int m_factionid;
	int m_vehicleid;
	Vector3 m_pos;
	Apache_Javelin_lister(int characterId,int factionid,int vehicleid,Vector3 pos)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_vehicleid = vehicleid;
		m_pos = pos;
	}
}