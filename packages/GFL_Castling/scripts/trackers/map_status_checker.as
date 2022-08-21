#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"

class MapStatusChecker : Tracker {
    protected Metagame@ m_metagame;
    float m_time=10.0;
    float m_internal= 120.0;
    bool m_started=false;
	MapStatusChecker(Metagame@ metagame, float time=120.0){
		@m_metagame = @metagame;
        m_internal = time;
	}

    void update(float time) {
        m_time-=time;
        if(m_time <= 0 ){
            m_time=m_internal;

        }
    }

    void CheckStatus(){
        array<const XmlElement@> baseList = getBases(m_metagame);
        for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getBoolAttribute("capturable")) {
				winner = base.getIntAttribute("owner_id");
				if (winner!=0){
					pause = true;
					break;
				}
			}
		}
    }

    bool hasEnded() const {
		return m_started;
	}
	bool hasStarted() const {
		return true;
	}
}
