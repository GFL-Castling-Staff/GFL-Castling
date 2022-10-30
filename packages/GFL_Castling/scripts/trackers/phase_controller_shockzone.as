// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "announce_task.as"
#include "generic_call_task.as"
#include "phase_controller.as"

// generic trackers
#include "spawner.as"

#include "gamemode_invasion.as"
#include "GFLhelpers.as"
//Author: NetherCrow

class map105_Phase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected PhaseControllerMap105@ m_controller;
	protected bool m_started;
	protected bool m_ended;

	// --------------------------------------------
	map105_Phase(GameModeInvasion@ metagame, PhaseControllerMap105@ controller) {
		@m_metagame = @metagame;
		@m_controller = @controller;
		m_started = false;
		m_ended = false;
	}

	// --------------------------------------------
	void start() {
		m_started = true;
		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		XmlElement f1("faction");
		f1.setIntAttribute("disable_enemy_spawnpoints_soldier_count_offset", -100);
		command.appendChild(f1);
		m_metagame.getComms().send(command);
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='2'>" + 
			"  <parameter class='willingness_to_charge' value='0.5' />" +
			"</command>");		
	}

	// --------------------------------------------
	void end() {
		Tracker::end();
		m_controller.phaseEnded();
		m_ended = true; // metagame will check has_ended, and will remove the phase from processing if it has ended
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_ended;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// --------------------------------------------
	void onDestroyTargetsChanged(array<string>@ destroyTargets) {
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
	}
};

class map105_Phase1 : map105_Phase {
	map105_Phase1(GameModeInvasion@ metagame, PhaseControllerMap105@ controller) {
		super(metagame, controller);
	}
	void start() {
		map105_Phase::start();
		_log("Phase1 starting");
		playSoundtrack(m_metagame,"Singularity_3.wav");
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='2'>" + 
			"  <parameter class='willingness_to_charge' value='0.7' />" +
			"</command>");		
	}
	
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		refresh();
    }

	protected void refresh() {
		array<const XmlElement@> baseList = getBases(m_metagame);
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
		if(pause==false){
			end();
		}
	}
};

class map105_Phase2 : map105_Phase {
	map105_Phase2(GameModeInvasion@ metagame, PhaseControllerMap105@ controller) {
		super(metagame, controller);
	}
	void start() {
		map105_Phase::start();
		_log("Phase2 starting");
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105HandleAll"));
		playSoundtrack(m_metagame,"Map105Defend.wav");
		m_metagame.getComms().send("<command class='commander_ai' faction='2' base_defense='0.0' border_defense='0.05' attack_start_spread='0' />");
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='2'>" + 
			"  <parameter class='willingness_to_charge' value='1.0' />" +
			"</command>");		
	}

	protected void handleFactionLoseEvent(const XmlElement@ event) {
		// if green lost a battle, start over
		int factionId = -1;

		const XmlElement@ loseCondition = event.getFirstElementByTagName("lose_condition");
		if (loseCondition !is null) {
			factionId = loseCondition.getIntAttribute("faction_id");
		}

		if (factionId == 2) {
			// kcco倒了
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105WIN", dictionary(),2.0, "explosion3.wav"));
			updateMapViewPic(m_metagame,"map_ruin.png");
		}
	}
};


// --------------------------------------------
class PhaseControllerMap105 : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	protected uint m_currentPhaseIndex;
	protected array<map105_Phase@> m_phases;
	protected array<string> m_destroyTargets;

	PhaseControllerMap105(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
		m_started = false;
		m_currentPhaseIndex = 0;
		reset();
	}

	void reset() {
		m_phases = array<map105_Phase@>();

		m_phases.insertLast(map105_Phase1(m_metagame, this));
		m_phases.insertLast(map105_Phase2(m_metagame, this));

		m_currentPhaseIndex = 0;
	}

	void gameContinuePreStart() {
		_log("starting PhaseControllerMap105 tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		m_started = true;
		startCurrentPhase();
	}

	void onRemove() {
		m_started = false;
	}

	// --------------------------------------------
	void start() {
		reset();
		_log("starting PhaseControllerMap105 tracker, phase=" + m_currentPhaseIndex);
		m_started = true;
		startCurrentPhase();
		
	}

	void phaseEnded() {
		// advance to next phase
		m_currentPhaseIndex += 1;
		if (m_currentPhaseIndex < m_phases.size()) {
			startCurrentPhase();
		} 
	}	

	void startCurrentPhase() {
		if (m_currentPhaseIndex < m_phases.size()) {
			map105_Phase@ phase = m_phases[m_currentPhaseIndex];

			m_metagame.addTracker(phase);
		} 
	}

	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	protected void handleFactionLoseEvent(const XmlElement@ event) {
		// if green lost a battle, start over
		int factionId = -1;

		const XmlElement@ loseCondition = event.getFirstElementByTagName("lose_condition");
		if (loseCondition !is null) {
			factionId = loseCondition.getIntAttribute("faction_id");
		}

		if (factionId == 1) {
			// 铁血倒了
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105SFdown"));
			playSoundtrack(m_metagame,"Singularity_2.wav");
		}
	}

	void load(const XmlElement@ root) {}
	void save(XmlElement@ root) {}

	protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		// player_id
		// player_name
		// message
		// global

		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		if (checkCommand(message, "end_phase")) {
			map105_Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		}
	}
}
