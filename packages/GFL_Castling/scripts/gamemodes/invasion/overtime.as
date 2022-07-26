// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

// --------------------------------------------
class Overtime : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected int m_factionId;
	protected bool m_started;
	protected float m_matchWinTimer;
	protected int m_matchWinner;
	protected bool m_matchWinTimerPaused;
	protected float m_timer;
	protected float m_risk_timer;
	protected float REFRESH_TIME = 10.0;
	protected float THRESHOLD1 = 150.0;
	protected float THRESHOLD2 = 90.0;
	protected int m_lastMode;
	protected int m_risklevel;
	protected int m_risklevel_cap;

	// --------------------------------------------
	Overtime(GameModeInvasion@ metagame, int factionId, int cap=20) {
		@m_metagame = @metagame;
		m_factionId = factionId;
		m_started = false;
		m_matchWinTimer = 100000.0;
		m_matchWinner = -1;
		m_matchWinTimerPaused = false;
		m_timer = 0.0;
		m_risk_timer= 0.0;
		m_lastMode = -1;
		m_risklevel = 0;
		m_risklevel_cap = cap;
	}

	// --------------------------------------------
	void start() {
		_log("starting Overtime tracker", 1);
		m_started = true;

		m_matchWinTimer = 100000.0;
		m_matchWinner = -1;
		m_matchWinTimerPaused = false;
		
		refresh();
	}

    // ----------------------------------------------------
	void update(float time) {
		// recheck every 10 seconds
		m_timer -= time;
		m_risk_timer -= time;
		if (m_timer < 0.0) {
			refresh();
		}
		if (m_risk_timer < 0.0) {
			if (m_risklevel < m_risklevel_cap){
				m_risklevel++;
			}
			m_risk_timer = 60.0;
		}		
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
	}

    // ----------------------------------------------------
	protected void refresh() {
		// query for game win timer 
		// if used to be higher than threshold and is now lower than threshold, decrease attacker faction capacities
		// if used to be lower than threshold and is now higher than threshold, set attacker faction capacities back to normal
	
		// query about bases
		const XmlElement@ general = getGeneralInfo(m_metagame);
		if (general !is null) {
			float lastWinTimer = m_matchWinTimer;
			int lastWinner = m_matchWinner;
			bool lastPaused = m_matchWinTimerPaused;
		
			m_matchWinner = general.getIntAttribute("match_winner");
			m_matchWinTimer = general.getFloatAttribute("match_win_timer");
			m_matchWinTimerPaused = general.getBoolAttribute("match_win_timer_paused");
			_log("* " + m_matchWinTimer + " win timer, " + m_matchWinner + " about to win, paused " + m_matchWinTimerPaused, 1);

			const array<Faction@>@ factions = m_metagame.getFactions();
			// if invalid winner, not set 
			if ((m_matchWinner < 0) ||
				// or if winner changed since last time
				(lastWinner != m_matchWinner) ||
				// or current winner is neutral
				(factions[m_matchWinner].isNeutral()) ||
				// or win time used to be below threshold, and now went back up
				(lastWinTimer <= THRESHOLD1 && m_matchWinTimer > THRESHOLD1) ||
				// or changed to paused
				(m_matchWinTimerPaused && m_matchWinTimerPaused != lastPaused)) {

				// go back to default
				setLoserCapacityDefault();
				setAllDefaultMode();
				m_lastMode = 0;

			} else if (lastWinTimer > THRESHOLD1 && m_matchWinTimer <= THRESHOLD1) {
				setLoserOffensiveMode();
				m_lastMode = 1;

			} else if (lastWinTimer > THRESHOLD2 && m_matchWinTimer <= THRESHOLD2) {
				setLoserCapacityDown();
			
				if (m_factionId == m_matchWinner) {
					// player is winning
					sendFactionMessageKey(m_metagame, m_factionId, "overtime, we are winning");

				} else {
					// player is losing
					sendFactionMessageKey(m_metagame, m_factionId, "overtime, we are losing");
				}
			
				m_lastMode = 2;
			}

		}
		m_timer = REFRESH_TIME;
	}

	// ----------------------------------------------------
    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
        // base_id
        // owner_id (faction)

		refresh();
    }

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	void setLoserCapacityDown() {
		_log("Overtime, setLoserCapacityDown", 1);

		string command =
			"<command class='change_game_settings'>";
		
		for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
			Faction@ f = m_metagame.getFactions()[i];
			float multiplier = m_metagame.determineFinalFactionCapacityMultiplier(f, i);
			float offset = f.m_capacityOffset;

			if (int(i) == m_matchWinner) {
				command +=
				"    <faction capacity_multiplier='" + multiplier + "' " + 
				"    		  capacity_offset='" + offset + "' " + "/>";
			} else {
				// if capacity multiplier was 0 (neutral), it will continue to be
				float capacity = min(multiplier, 0.3);
				offset = 0.0;
				command +=
				"    <faction capacity_multiplier='" + capacity + "' " +
				"             capacity_offset='" + offset + "' />";
			}
		}

		command += 
			"</command>";

		m_metagame.getComms().send(command);
		
		// also make enemies go in charge mode
		for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
			if (int(i) != m_matchWinner) {
				array<const XmlElement@>@ list = getSoldierGroups(m_metagame, i);
				for (uint j = 0; j < list.size(); ++j) {
					const XmlElement@ group = list[j];
					// NOTE: nothing handles reseting spawn scores back to default 
					// not even for /restart!
					string name = group.getStringAttribute("name");
					m_metagame.getComms().send(
						"<command class='soldier_ai' faction='" + i + "' soldier_group_name='" + name + "'>" + 
						"  <parameter class='willingness_to_charge' value='1.0' />" +
						"</command>");			
					}
			}
		}

		// TODO: instead of using friendly id we could have this send messages to all factions
		// - would make the tracker usable in PvP too 
	}

	// --------------------------------------------
	void setLoserCapacityDefault() {
		_log("Overtime, setLoserCapacityDefault", 1);

		string command =
			"<command class='change_game_settings'>";
		
		for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
			Faction@ f = m_metagame.getFactions()[i];
			float multiplier = m_metagame.determineFinalFactionCapacityMultiplier(f, i);
			float offset = f.m_capacityOffset;
			offset += m_risklevel * 5;
			multiplier += m_risklevel * 0.02;

			command +=
			"    <faction capacity_multiplier='" + multiplier + "' " +
			"     		  capacity_offset='" + offset + "' " + "/>";
		}

		command += 
			"</command>";

		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	void setAllDefaultMode() {
		_log("Overtime, setAllDefaultMode", 1);
		for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
			applyDefaultMode(i);
		}
	}

	// --------------------------------------------
	void applyDefaultMode(int enemyId) {
		const array<Faction@>@ factions = m_metagame.getFactions();

		const XmlElement@ command = factions[enemyId].m_defaultCommanderAiCommand;
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	void setLoserOffensiveMode() {
		_log("Overtime, setLoserOffensiveMode", 1);
		for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
			if (int(i) != m_matchWinner) {
				applyOffensiveMode(i);
			} 
		}
	}

	// --------------------------------------------
	void applyOffensiveMode(int id) {
		string command =
			"<command class='commander_ai'" +
 			"       faction='" + id + "'" +
 			"       base_defense='0.0'" +
 			"       border_defense='0.0'>" +
        	        "</command>";
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	protected void handleSettingsChangeEvent(const XmlElement@ event) {
		// - reapply current mode after this function
		// - assuming map rotator has already updated user settings
		if (m_lastMode == 0) {
			setLoserCapacityDefault();
		} else if (m_lastMode == 1) {
			setLoserOffensiveMode();
		} else if (m_lastMode == 2) {
			setLoserCapacityDown();
		}
	}	
}

