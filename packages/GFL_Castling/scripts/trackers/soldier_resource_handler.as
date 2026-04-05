// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"

#include "GFLhelpers.as"
#include "soldier_weight.as"

// --------------------------------------------
class SoldierResourceHandler : Tracker {
	protected GameModeInvasion@ m_metagame;
    protected bool m_started;

	SoldierResourceHandler(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
        m_started = false;
	}

	void gameContinuePreStart() {
		m_started = true;
	}
	
	// --------------------------------------------
	void start() {
		_log("starting SoldierResourceHandler", 1);
        int difficulty = m_metagame.getUserSettings().m_GlobalDifficulty;
        if(difficulty == 1) //eazy
        {   
            for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
                Faction@ f = m_metagame.getFactions()[i];

                if (f.m_config.m_file == "gk.xml") {
                    continue;
                }
                else if(f.m_config.m_file == "sf.xml"){
                    changeSoldierGroupResource(m_metagame,i,sf_vespid_resource,true,"sf_vespid",true);
                    _log("starting 铁血改改改改", 1);
                }
                else if(f.m_config.m_file == "kcco.xml"){
                }
                else if(f.m_config.m_file == "paradeus.xml"){
                }
                else continue;
            }
        }        
        m_started = true;
	}

	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

	bool hasEnded() const {
		// always on
		return false;
	}

	bool hasStarted() const {
		return m_started;
	}
}
