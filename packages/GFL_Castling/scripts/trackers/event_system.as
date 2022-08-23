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
                                if(GFL_event_array[a].m_randseed==-1.0)
                                    GFL_event_array[a].m_randseed=rand(0,3.14);
                                excuteRampageFairyAC130(m_metagame,GFL_event_array[a]);
                                break;
                            }
                            default:
                                break;
                        }
                    }
                    else{
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

}

class GFL_event{
    int m_characterId;
	int m_factionid;
    int m_eventkey;
    Vector3 m_pos;
    float m_randseed;

    int m_phase=1;
    float m_time;
    bool m_enable=true;

    GFL_event(int characterId,int factionid,int key,Vector3 pos,float delay_time=0.0,float randseed=-1.0){
        m_characterId=characterId;
        m_factionid=factionid;
        m_eventkey=key;
        m_pos=pos;
        m_time=delay_time;
        m_randseed=randseed;
    }
}

void excuteSniperFairy(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.5;
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,40.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,4,getRandomOffsetVector(eventinfo.m_pos,70.0),luckyGuyPos);                        
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=8){
        eventinfo.m_enable=false;
    }
}

array<int> RampageFairyAC130List={
    6,6,6,5,6,6,6,5,7,6,6,5,6,6,5,7,6,6,5
};
void excuteRampageFairyAC130(GameMode@ metagame,GFL_event@ eventinfo){
    eventinfo.m_time=1.5;
    if(eventinfo.m_phase<=1)
        playSoundAtLocation(metagame,"ac130_flyby.wav",eventinfo.m_factionid,eventinfo.m_pos,8.0);
    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,eventinfo.m_factionid,eventinfo.m_pos,40.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        
        uint jud_num = eventinfo.m_phase/10;
        float rand_angle = eventinfo.m_randseed + eventinfo.m_phase*3.14/10;

        Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
        Vector3 aimPos = luckyGuyPos.add(Vector3(45.0*cos(rand_angle),40,45.0*sin(rand_angle)));

        insertCommonStrike(eventinfo.m_characterId,eventinfo.m_factionid,RampageFairyAC130List[int(eventinfo.m_phase%RampageFairyAC130List.length())],aimPos,luckyGuyPos);
    }
    eventinfo.m_phase++;
    if(eventinfo.m_phase>=20){
        eventinfo.m_enable=false;
    }
}