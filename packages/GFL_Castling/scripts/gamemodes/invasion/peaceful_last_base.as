// internal
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class PeacefulLastBase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected int m_factionId = 0;
	protected bool m_started;
	protected int m_lastOwnedBasesCount;

	// --------------------------------------------
	PeacefulLastBase(GameModeInvasion@ metagame, int factionId) {
		super();

		@m_metagame = @metagame;
		m_factionId = factionId;
		m_started = false;
		m_lastOwnedBasesCount = -1; // start with force refresh
	}

	// --------------------------------------------
	void start() {
		_log("starting PeacefulLastBase", 1);
		setEnemiesDefend();
		m_started = true;
		
		refresh();
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;

		// we'll continue whatever settings the savegame had in the game
		// by restoring the last owned bases count from current situation
		m_lastOwnedBasesCount = getBasesForFaction(m_factionId);
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

    // ----------------------------------------------------
	protected int getBasesForFaction(int factionId) {
		array<const XmlElement@> baseList = getBases(m_metagame);
		int bases = 0;
		// go through list of bases
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getIntAttribute("owner_id") == factionId) {
				bases++;
			}
		}
		return bases;
	}

    // ----------------------------------------------------
	protected bool refresh() {
		bool changed = false;
		// query for total count of bases for friendly faction
		// if 1, make enemy defend
		// if more, apply default commander settings
	
        // query about bases
		array<const XmlElement@> baseList = getBases(m_metagame);
		int bases = getBasesForFaction(m_factionId);

        _log("* " + bases + " friendly bases", 1);

		bool forceRefresh = m_lastOwnedBasesCount < 0;
		if ((forceRefresh || m_lastOwnedBasesCount != 1) && bases == 1) {
			setEnemiesDefend();
			// go to boosted attack mode with player faction
			// - our capacity is pretty low when there's just one base
			//   and usually defending is a priority to avoid just a
			//   run through with the attack
			applyOffensiveMode(m_factionId);
			changed = true;
		} else if ((forceRefresh || m_lastOwnedBasesCount == 1) && bases > 1) {
			setEnemiesDefault();
			// go to normal mode with player faction as well
			applyDefaultMode(m_factionId);
			changed = true;
		} // else 0, don't care

		m_lastOwnedBasesCount = bases;
		
		return changed;
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
	void applyDefensiveMode(int enemyId) {
		string command =
			"<command class='commander_ai'" +
 			"       faction='" + enemyId + "'" +
 			"       base_defense='0.8'" +
 			"       border_defense='0.2'>" +
        	        "</command>";
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	void applyOffensiveMode(int id) {
		string command =
			"<command class='commander_ai'" +
 			"       faction='" + id + "'" +
 			"       base_defense='0.1'" +
 			"       border_defense='0.1'>" +
        	        "</command>";
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	void applyDefaultMode(int enemyId) {
/*
		$command =
                	"<command class='commander_ai'" .
                        "       faction='" . $enemy_id . "'" .
                        "       base_defense='0.64'" .
                        "       border_defense='0.14'>" .
                        "</command>";
*/
		const array<Faction@>@ factions = m_metagame.getFactions();
		const XmlElement@ command = factions[enemyId].m_defaultCommanderAiCommand;
		m_metagame.getComms().send(command);
	}

	// --------------------------------------------
	void setEnemiesDefend() {
		const array<Faction@>@ factions = m_metagame.getFactions();
		for (uint i = 0; i < factions.size(); ++i) {
			if (int(i) != m_factionId) {
				applyDefensiveMode(i);
			}
		}
	}

	// --------------------------------------------
	void setEnemiesDefault() {
		const array<Faction@>@ factions = m_metagame.getFactions();
		for (uint i = 0; i < factions.size(); ++i) {
			if (int(i) != m_factionId) {
				applyDefaultMode(i);
			}
		}
	}
}
