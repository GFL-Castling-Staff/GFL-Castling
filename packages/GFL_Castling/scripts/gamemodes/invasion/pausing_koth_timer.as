// internal
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class PausingKothTimer : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	protected float m_time;

	// --------------------------------------------
	PausingKothTimer(GameModeInvasion@ metagame, float time) {
		super();

		@m_metagame = @metagame;
		m_started = false;
		m_time = time;
	}

	// --------------------------------------------
	void start() {
		_log("starting PausingKothTimer", 1);
		m_started = true;
		m_metagame.getComms().send("<command class='set_game_timer' faction_id='0' pause='1' time='" + m_time + "' />");
		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		XmlElement f1("faction");
		f1.setIntAttribute("disable_enemy_spawnpoints_soldier_count_offset", -100);
		command.appendChild(f1);
		m_metagame.getComms().send(command);
		refresh();
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

    // ----------------------------------------------------
	protected void refresh() {
        // query about bases
		array<const XmlElement@> baseList = getBases(m_metagame);
		playSoundtrack(m_metagame,"soundtrack_koth.wav");

		int winner = -1;
		bool pause = false;
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (base.getBoolAttribute("capturable")) {
				// assuming one capturable here
				winner = base.getIntAttribute("owner_id");
				if (winner!=0){
					pause = true;
					break;
				}
			}
		}

		// pause if someone else holds the capturable base than faction 0
		m_metagame.getComms().send("<command class='set_game_timer' pause='" + (pause?1:0) + "' />");
	}

	// ----------------------------------------------------
    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
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
}
