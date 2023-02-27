#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

class DeadZoneHack : Tracker {
	protected Metagame@ m_metagame;
	protected float m_updateTimer = 5.0;
	protected float m_updateTime = 5.0;
	protected bool m_updatePhase;


	// --------------------------------------------
	DeadZoneHack(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_updatePhase= true;
	}

	void update(float time) {
		m_updateTimer -= time;
		if (m_updateTimer < 0.0) {
			m_updateTimer = m_updateTime;
			if(m_updatePhase)
			{
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");				
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");				
				m_updatePhase = false;
			}
			else
			{
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");				
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				updateMapViewPic(m_metagame,"map.png");
				updateMapViewPic(m_metagame,"map_ruin.png");
				m_updatePhase = true;
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