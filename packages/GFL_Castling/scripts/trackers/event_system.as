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
                                    GFL_event_array[a].m_randseed= rand(0,3.14);
                                }
                                excuteRampageFairyAC130(m_metagame,GFL_event_array[a]);
                                break;
                            }
                            case 3:{excuteSniperM200(m_metagame,GFL_event_array[a]);break;}
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
    float m_randseed;
    int m_specialkey=1;

    int m_phase=1;
    int m_markerId=0;
    float m_time;
    bool m_enable=true;

    GFL_event(int characterId,int factionid,int key,Vector3 pos,float delay_time=0.0,float randseed=-1.0,int markerId=0){
        m_characterId=characterId;
        m_factionid=factionid;
        m_eventkey=key;
        m_pos=pos;
        m_time=delay_time;
        m_randseed=randseed;
        m_markerId=markerId;
    }

    void setSpeicalKey(int key){
        m_specialkey=key;
    }
}

void excuteSniperFairy(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.5;
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,30.0f);
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

array<int> RampageFairyAC130List={
    6,6,6,5,6,6,6,5,7
};



int ac130_voice_interval = 0;
int ac130_flyby_interval = 0;
int ac130_strike_num = 30;
int ac130_jud_confused = 0;
Vector3 ac130_pre_pos = Vector3(-1,-1,-1); // 这是为了ac130索敌能每次尽量锁附近的，而不是去到处乱锁
            
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
    // 优先锁定上一个目标点旁边的
    luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,20.0f);
    Vector3 ac130_jud_pos;

    // 如果没有索敌到敌人或者距离超过130范围，重新索敌一次
    if (luckyGuyid!=-1) {
        ac130_jud_pos = stringToVector3(getCharacterInfo(metagame,luckyGuyid).getStringAttribute("position"));
        if(getAimUnitDistance(1.0,ac130_jud_pos,ac130_pre_pos)>60) {
            ac130_pre_pos = eventinfo.m_pos;
            luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,60.0f);
        }
    }
    else {
        ac130_pre_pos = eventinfo.m_pos;
        luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,ac130_pre_pos,60.0f);
    }
        
    if(eventinfo.m_phase>1){
        if(luckyGuyid!=-1){
            ac130_jud_confused = 0;
            
            uint jud_num = eventinfo.m_phase/10;
            float rand_angle = eventinfo.m_randseed + eventinfo.m_phase*3.14/10;

            Vector3 luckyGuyPos = stringToVector3(getCharacterInfo(metagame,luckyGuyid).getStringAttribute("position"));
            Vector3 aimPos = luckyGuyPos.add(Vector3(45.0*cos(rand_angle),40,45.0*sin(rand_angle)));
            ac130_pre_pos = luckyGuyPos;

            int attacknum = RampageFairyAC130List[int(eventinfo.m_phase%RampageFairyAC130List.length())];

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
            ac130_jud_confused++;
            if(ac130_jud_confused>=5){
                ac130_jud_confused = 0;
                playSoundAtLocation(metagame,"AUHarbi_voiSelBate.wav",eventinfo.m_factionid,eventinfo.m_pos,3.5);
            }
            else playRandomSoundArray(metagame,AC130NoTargetVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);

        }        
    }

    eventinfo.m_phase++;
    if(eventinfo.m_phase>=ac130_strike_num){
        playRandomSoundArray(metagame,AC130EndVoice,eventinfo.m_factionid,eventinfo.m_pos.toString(),3.5);
        eventinfo.m_enable=false;
    }
}