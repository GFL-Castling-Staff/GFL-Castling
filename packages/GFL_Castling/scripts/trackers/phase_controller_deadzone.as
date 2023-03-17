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
#include "GFLparameters.as"
//Author: NetherCrow

array<ScoredResource@> reinforce_resource = {
	ScoredResource("deadzone_reinforce_assault.call", "call", 1.0f),
	ScoredResource("deadzone_reinforce_eod.call", "call", 1.0f),
	ScoredResource("deadzone_reinforce_3wheel.call", "call", 1.0f),
	ScoredResource("deadzone_reinforce_3wheelplus.call", "call", 0.5f),
	ScoredResource("deadzone_reinforce_nyto.call", "call", 0.5f),
	ScoredResource("deadzone_reinforce_tank.call", "call", 0.5f)
};

array<ScoredResource@> tower_resource = {
	ScoredResource("par_sentrytower_deadzone.vehicle", "vehicle", 1.0f)
};

class map_DeadZone_Phase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected PhaseControllerDeadZone@ m_controller;
	protected bool m_started;
	protected bool m_ended;



	// --------------------------------------------
	map_DeadZone_Phase(GameModeInvasion@ metagame, PhaseControllerDeadZone@ controller) {
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
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.6' border_defense='0.3'/>");
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.2' border_defense='0.1' attack_start_spread='0' attack_target_spread='0' attack_target_base_key='Crash part' />");
		m_metagame.getComms().send("<command class='commander_ai' faction='2' base_defense='0.6' border_defense='0.4'/>");
		m_metagame.getComms().send("<command class='commander_ai' faction='3' base_defense='0.6' border_defense='0.4'/>");
		setSpawnScore(m_metagame,1,"eagleyes",0);
		setSpawnScore(m_metagame,1,"teal",0);
		setSpawnScore(m_metagame,1,"vanguard",0);
		setSpawnScore(m_metagame,1,"wrath",0);
		setSpawnScore(m_metagame,1,"Nimogen",0);
		setSpawnScore(m_metagame,1,"Narciss",0);
		setSpawnScore(m_metagame,1,"Thunder",0);
		m_metagame.addTracker(SpawnAtNode(m_metagame, tower_resource, "deadzone_tower", 1, 3));	
		resetFactionCallResources(m_metagame, 0, AllGKcallList, false, getCallSorting());
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>" + 
			"  <parameter class='willingness_to_charge' value='0.4' />" +
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

class map_DeadZone_Phase1 : map_DeadZone_Phase {
	map_DeadZone_Phase1(GameModeInvasion@ metagame, PhaseControllerDeadZone@ controller) {
		super(metagame, controller);
	}
	void start() {
		map_DeadZone_Phase::start();
		_log("Phase1 starting");
		playSoundtrack(m_metagame,"Singularity_4.wav");
	}

	protected float m_timer = 90.0;
	protected float REFRESH_TIME = 90.0;
	protected int m_killtime = 0;


	string m_vehicleKey = "par_sentrytower_deadzone.vehicle";

	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		int owner = event.getIntAttribute("owner_id");		
		string baseKey = event.getStringAttribute("base_key");
		if (baseKey == "Crash part") {
			if (owner == 0) 
			{
				m_metagame.getComms().send("<command class='update_base' base_key='Last Defence' capturable='0' />");
				m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 1.0, 0, "Map105_3,last base safe"));
				SetAttackTarget(m_metagame,1,"Crash part");
			}
			else
			{
				m_metagame.getComms().send("<command class='update_base' base_key='Last Defence' capturable='1' />");
				m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 1.0, 0, "Map105_3,last base risk"));
				SetAttackTarget(m_metagame,1,"Last Defence");
			}
		}
    }

	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_vehicleKey) {
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 2.0, 0, "Map105_3,tower destoryed"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 1.0, 0, "Map105_3,white rush"));			
			m_metagame.addTracker(SpawnAtNode(m_metagame, reinforce_resource, "reinforce", 1, 4));
			m_killtime++;
		}
		if(m_killtime >=3)
		{
			end();
		}
	}

	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			m_timer = REFRESH_TIME;
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 1.0, 0, "Map105_3,white assault"));
			m_metagame.addTracker(SpawnAtNode(m_metagame, reinforce_resource, "reinforce", 1, 1));		
			m_metagame.getComms().send("<command class='commander_ai' faction='2' base_defense='0.6' border_defense='0.4'/>");
			m_metagame.getComms().send("<command class='commander_ai' faction='3' base_defense='0.6' border_defense='0.4'/>");	
		}
	}

};

class map_DeadZone_Phase2 : map_DeadZone_Phase {
	map_DeadZone_Phase2(GameModeInvasion@ metagame, PhaseControllerDeadZone@ controller) {
		super(metagame, controller);
	}
	void start() {
		map_DeadZone_Phase::start();
		_log("Phase2 starting");
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105_3,all tower destoryed1"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105_3,all tower destoryed2"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105_3,all tower destoryed3"));
		m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 3.0, 0, "Map105_3,all tower destoryed4"));
		resetFactionCallResources(m_metagame, 0, AllGKcallList, true, getCallSorting());
		array<const XmlElement@> baseList = getBases(m_metagame);
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			string basekey = base.getStringAttribute("key");
			m_metagame.getComms().send("<command class='update_base' base_key='" + basekey + "' capturable='1' />");
		}
	}

};


// --------------------------------------------
class PhaseControllerDeadZone : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	protected uint m_currentPhaseIndex;
	protected array<map_DeadZone_Phase@> m_phases;
	protected array<string> m_destroyTargets;

	PhaseControllerDeadZone(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
		m_started = false;
		m_currentPhaseIndex = 0;
		reset();
	}

	void reset() {
		m_phases = array<map_DeadZone_Phase@>();

		m_phases.insertLast(map_DeadZone_Phase1(m_metagame, this));
		m_phases.insertLast(map_DeadZone_Phase2(m_metagame, this));

		m_currentPhaseIndex = 0;
	}

	void gameContinuePreStart() {
		_log("starting PhaseControllerDeadZone tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		m_started = true;
		startCurrentPhase();
	}

	void onRemove() {
		m_started = false;
	}

	// --------------------------------------------
	void start() {
		reset();
		_log("starting PhaseControllerDeadZone tracker, phase=" + m_currentPhaseIndex);
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
			map_DeadZone_Phase@ phase = m_phases[m_currentPhaseIndex];

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
			map_DeadZone_Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		}
	}
}
