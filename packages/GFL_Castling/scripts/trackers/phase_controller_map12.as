// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "announce_task.as"
#include "phase_controller.as"

// generic trackers
#include "spawner.as"

#include "gamemode_invasion.as"

// --------------------------------------------
class Phase : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected PhaseControllerMap12@ m_controller;
	protected bool m_started;
	protected bool m_ended;

	// --------------------------------------------
	Phase(GameModeInvasion@ metagame, PhaseControllerMap12@ controller) {
		@m_metagame = @metagame;
		@m_controller = @controller;
		m_started = false;
		m_ended = false;
	}

	// --------------------------------------------
	void start() {
		m_started = true;
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

// --------------------------------------------
class Phase1 : Phase {
	protected float m_timer;

	// --------------------------------------------
	Phase1(GameModeInvasion@ metagame, PhaseControllerMap12@ controller) {
		super(metagame, controller);
		m_timer = 0.0;
	}

	// --------------------------------------------
	void start() {
		Phase::start();
		_log("Phase1 starting");

		//$this->timer = 10.0 * 60.0;

		// quick phase1, for testing
		m_timer = 5.0 * 60.0;

		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.1' border_defense='0.1' attack_start_spread='0' />");

		// set enemy soldier ai modifications
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>" + 
			"  <parameter class='willingness_to_charge' value='0.7' />" +
			"</command>");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.9' border_defense='0.0' />");

		string position("515 0 562");
		m_metagame.getComms().send("<command class='create_call' key='paratroopers2.call' position='" + position + "' faction_id='1'/>");    

		// some resets for map restart:
		m_metagame.getComms().send("<command class='update_base' base_key='lab' capturable='1' />");
		m_metagame.getComms().send("<command class='update_base' base_key='castle ruins' capturable='1' />");

		//$this->metagame->comms->send("say phase 1 started");
	}

	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			// done
			end();
		}
	}
	

	// TODO: timer could be saved, but won't bother with it now; if phase1 is save&quit and continued, it'll start from beginning
};

// --------------------------------------------
class Phase2 : Phase {
	// --------------------------------------------
	Phase2(GameModeInvasion@ metagame, PhaseControllerMap12@ controller) {
		super(metagame, controller);
	}

	// --------------------------------------------
	protected void handleSettingsChangeEvent(const XmlElement@ event) {
		applyCapacityMultipliers();
	}	

	// --------------------------------------------
	protected void applyCapacityMultipliers() {
		// decrease amount of enemy soldiers in phase 2
		m_metagame.getComms().send(
			"<command class='change_game_settings'>" + 
			// was 0.8, 0.667*1.2 = 0.8
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_fellowCapacityFactor * 0.667) + "' />" + 
			// was 0.5, 0.5*1.0 = 0.5
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_enemyCapacityFactor * 0.5) + "' />" + 
			"  <faction />" + 
			"</command>");
	}

	// --------------------------------------------
	void start() {
		Phase::start();
		_log("Phase2 starting");

		// set enemy commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.7' border_defense='0.2' />");

		applyCapacityMultipliers();

		// set enemy soldier ai modifications, back to normal actually
		m_metagame.getComms().send(
			"<command class='soldier_ai' faction='1'>" + 
			"  <parameter class='willingness_to_charge' value='0.0' />" +
			"</command>");

		// set friendly commander ai
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.4' border_defense='0.0' />");

		// testing helper:
		//$this->metagame->comms->send("say phase 2 started");

		m_controller.invalidateDestroyTargets();

		if (!hasEnded()) {
			string textKeyPrefix = "Final mission II, phase 2, ";
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 1"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 2"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix +"part 3"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix +"part 4", dictionary(), 2.0, "objective_priority.wav"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix +"part 5", dictionary(), 2.0, "objective_priority.wav"));
		}
	}

	// --------------------------------------------
	void onDestroyTargetsChanged(array<string>@ destroyTargets) {
		bool found = false;
		for (uint i = 0; i < destroyTargets.size(); ++i) {
			string key = destroyTargets[i];
			if (key == "radio_jammer.vehicle"
				 || $key == "aa_emplacement.vehicle") {
				// one of these still exist, can't end yet
				found = true;
				break;
			}
		}

		if (!found) {
			// all phase2 targets destroyed, we're done here
			end();
		}
	}
};

// --------------------------------------------
class Phase3 : Phase {
	// --------------------------------------------
	Phase3(GameModeInvasion@ metagame, PhaseControllerMap12@ controller) {
		super(metagame, controller);
	}

	// --------------------------------------------
	protected void handleSettingsChangeEvent(const XmlElement@ event) {
		applyCapacityMultipliers();
	}	

	// --------------------------------------------
	protected void applyCapacityMultipliers() {
		// decrease amount of allied soldiers in phase 3
		m_metagame.getComms().send(	
			"<command class='change_game_settings'>" + 
			// was 0.4, 0.333*1.2 = 0.4
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_fellowCapacityFactor * 0.333) + "' />" + 
			// was 0.45, 0.45*1.0 = 0.45
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_enemyCapacityFactor * 0.45) + "' />" + 
			"  <faction />" + 
			"</command>");
	}

	// --------------------------------------------
	void start() {
		Phase::start();
		_log("Phase3 starting");

		applyCapacityMultipliers();

		// defend while player handles the tower
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.7' border_defense='0.22' />");
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='0.7' border_defense='0.3' />");

		// refilling the radar_tower side-base to have defenders 
		string position = "515 0 562";
		m_metagame.getComms().send("<command class='create_call' key='paratroopers2.call' position='"+position+"' faction_id='1'/>");
		m_metagame.getComms().send("<command class='create_call' key='paratroopers2.call' position='"+position+"' faction_id='1'/>");    
		m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='"+position+"' instance_class='vehicle' instance_key='para_spawn.vehicle' />");

		// testing helper:
		//$this->metagame->comms->send("say phase 3 started");

		m_controller.invalidateDestroyTargets();

		if (!hasEnded()) {
			string textKeyPrefix = "Final mission II, phase 3, ";
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 1"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 2"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 3"));
			m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 4", dictionary(), 2.0, "objective_priority.wav"));
		}
	}

	// --------------------------------------------
	void onDestroyTargetsChanged(array<string>@ destroyTargets) {
		bool found = false;
		for (uint i = 0; i < destroyTargets.size(); ++i) {
			string key = destroyTargets[i];
			if (key == "radar_tower.vehicle") {
				// one of these still exist, can't end yet
				found = true;
				break;
			}
		}

		if (!found) {
			// all phase2 targets destroyed, we're done here
			end();
		}
	}
};

// --------------------------------------------
class Phase4 : Phase {
	protected bool m_continueMode;

	Phase4(GameModeInvasion@ metagame, PhaseControllerMap12@ controller) {
		super(metagame, controller);
		m_continueMode = false;
	}

	// --------------------------------------------
	protected void handleSettingsChangeEvent(const XmlElement@ event) {
		applyCapacityMultipliers();
	}	

	// --------------------------------------------
	protected void applyCapacityMultipliers() {
		// decrease amount of allied soldiers in phase 4
		m_metagame.getComms().send(
			"<command class='change_game_settings'>" +
			// was 0.3, 0.25*1.2 = 0.3
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_fellowCapacityFactor * 0.25) + "' />" + 
			// was 0.6, 0.6*1.0 = 0.6
			"  <faction capacity_multiplier='" + (m_metagame.getUserSettings().m_enemyCapacityFactor * 0.6) + "' />" + 
			"  <faction />" +
			"</command>");
	}

	// --------------------------------------------
	void start() {
		Phase::start();
		_log("Phase4 starting");

		applyCapacityMultipliers();

		// bring down the door at start of phase 4
		m_metagame.getComms().send("<command class='update_static_object' key='wall_door' destroyed='1' />");

		// testing helper:
		//$this->metagame->comms->send("say phase 4 started");

		// make enemy capture arena
		m_metagame.getComms().send("<command class='update_base' owner_id='1' base_key='arena' />");

		// disable enemy commander ai; soldiers will stay mainly where they spawn
		//$this->metagame->comms->send("<command class='commander_ai' faction='1' base_defense='1.0' border_defense='0.0' active='0' />");
		// change of plans; ai commander to be active to handle tank2 protector allocation for failsafes
		// - doesn't matter that the commander will then also move troops around the arena a bit
		m_metagame.getComms().send("<command class='commander_ai' faction='1' base_defense='1.0' border_defense='0.0' active='1' />");
		m_metagame.getComms().send("<command class='set_comms' faction_id='1' enabled='1' />");

		// set friendly commander ai
		// arena is not capturable, so commander ai won't automatically organize attack there; request it here
		m_metagame.getComms().send("<command class='commander_ai' faction='0' base_defense='0.1' border_defense='0.1' attack_target_base_key='arena' />");

		// ensure we hold the other bases and that they can't be recaptured anymore by the enemy
		m_metagame.getComms().send("<command class='update_base' owner_id='0' base_key='lab' capturable='0' />");
		m_metagame.getComms().send("<command class='update_base' owner_id='0' base_key='castle ruins' capturable='0' />");

		if (!m_continueMode) {
			// spawners to fill the arena at moment of getting to own it
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(638,0,522), 5, "default_ai"));
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(686,0,521), 5, "default_ai"));
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(707,0,460), 5, "default_ai"));
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(655,0,435), 5, "default_ai"));
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(699,0,391), 5, "default_ai"));
			m_metagame.addTracker(Spawner(m_metagame, 1, Vector3(617,0,408), 5, "default_ai"));

			// spawn enemy tank2
			{
				Vector3 position(696, 10, 415);              // 			was	Vector3 position(660, 10, 498); in 1.63
				string vehicleKey = "tank2.vehicle";
				m_metagame.getComms().send("<command class='create_instance' faction_id='1' position='"+position.toString()+"' instance_class='vehicle' instance_key='"+vehicleKey+"' />");

				/*
				// spawn enemy boss_driver, and set his role as vehicle protector; he'll go to tank2
				$position[0] += 10.0;
				$soldier_group = "boss_driver";
				$this->metagame->comms->send("<command class='create_instance' faction_id='1' position='".vector_to_string($position)."' instance_class='soldier' instance_key='".$soldier_group."' event='1' />");
				// see handle_character_spawn_event for the post spawn handling
				*/
				// change of plans; ai commander will be active and handling promoting someone as a vehicle protector
				// - this way if the vehicle protector dies for any reason (faulty devirtualization or some other bug which kills the driver)
				//   there will be someone else to take over the vehicle
			}

			{
				string textKeyPrefix = "Final mission II, phase 4, ";
				m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 1"));
				m_metagame.getTaskSequencer().add(AnnounceTask(m_metagame, 5.0, 0, textKeyPrefix + "part 2", dictionary(), 2.0, "objective_priority.wav"));
			}
		}
	}

	/*
	// --------------------------------------------
	protected function handle_character_spawn_event($doc) {
		_log("handle_character_spawn_event");
		// we set the boss driver creation to be reported as an event, here it is

		// we need it to obtain the id for the boss driver character, to set his role as vehicle protector so that he'll occupy a vehicle needing protection
		$results = $doc->getElementsByTagName("character");
		if ($results->length > 0) {
			$character = $results->item(0);

			$id = $character->getAttribute("id");
			$position = $character->getAttribute("position");

			$this->metagame->comms->send("<command class='soldier_objective' character_id='".$id."' target='".$position."' objective='protect' />");
		}
	}
	*/

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {

		string key = event.getStringAttribute("vehicle_key");
		if (key == "tank2.vehicle") {
			_log("Phase4, vehicle being destroyed, key " + key); 

			end();
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		// here's a little hack;
		// - if we come by load method, we know we're continuing, store that piece of inof
		m_continueMode = true;
		// we'll use it to handle start method so that the settings
		// are applied but none of the creations are not
	}
};

// --------------------------------------------
class PhaseControllerMap12 : PhaseController {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;

	protected uint m_currentPhaseIndex;

	protected array<Phase@> m_phases;

	protected array<string> m_destroyTargets;

	// --------------------------------------------
	PhaseControllerMap12(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
		m_started = false;
		m_currentPhaseIndex = 0;

		// reset here initially
		// - continue: reset -> load -> game_continue_pre_start
		// - start: reset -> reset -> start
		// - restart: reset -> reset -> start, reset -> start
		reset();
	}

	// --------------------------------------------
	void reset() {
		m_phases = array<Phase@>();

		m_phases.insertLast(Phase1(m_metagame, this));
		m_phases.insertLast(Phase2(m_metagame, this));
		m_phases.insertLast(Phase3(m_metagame, this));
		m_phases.insertLast(Phase4(m_metagame, this));

		m_currentPhaseIndex = 0;

		array<string> targets = {"radio_jammer.vehicle", "aa_emplacement.vehicle", "radar_tower.vehicle"};
		m_destroyTargets = targets;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		_log("starting PhaseControllerMap12 tracker with game_continue_pre_start, phase=" + m_currentPhaseIndex);
		// on_game_continue_pre_start happens before start

		// mark as started, to skip calling start()
		// the metagame won't then call start at all
		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

	// --------------------------------------------
	void start() {
		// call reset here, phases and targets are initialized fresh
		// - helps with handling restart
		reset();

		_log("starting PhaseControllerMap12 tracker, phase=" + m_currentPhaseIndex);

		m_started = true;
		startCurrentPhase();
	}

	// --------------------------------------------
	void phaseEnded() {
		// advance to next phase
		m_currentPhaseIndex += 1;
		if (m_currentPhaseIndex < m_phases.size()) {
			startCurrentPhase();
		} else {
			// finished, no more phases left
			completeMatch();
		}
	}

	// --------------------------------------------
	void completeMatch() {
		m_metagame.getComms().send("<command class='set_match_status' faction_id='1' lose='1' />");
		m_metagame.getComms().send("<command class='update_base' owner_id='0' base_key='arena' capturable='0' />");
		m_metagame.getComms().send("<command class='set_match_status' faction_id='0' win='1' />");
	}

	// --------------------------------------------
	void startCurrentPhase() {
		if (m_currentPhaseIndex < m_phases.size()) {
			Phase@ phase = m_phases[m_currentPhaseIndex];

			m_metagame.addTracker(phase);
		} else {
			// no phases left
			// - at least make sure the gate is down
			m_metagame.getComms().send("<command class='update_static_object' key='wall_door' destroyed='1' />");
		}
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

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		// when AA emplacement is destroyed, spawn reinforcements at start base

		string key = event.getStringAttribute("vehicle_key");
		if (key == "aa_emplacement.vehicle") {
			_log("vehicle being destroyed, key " + key); 

			array<string> positions;
			positions.insertLast("240 25 468");
			positions.insertLast("225 25 444");
			positions.insertLast("254 25 445");
			positions.insertLast("240 25 468");

			for (uint i = 0; i < positions.size(); ++i) {
				string position = positions[i];
				m_metagame.getComms().send("<command class='create_call' key='paratroopers2.call' position='" + position + "' faction_id='0'/>");
			}
		}

		int i = m_destroyTargets.find(key);
		if (i >= 0) {
			// found, remove
			m_destroyTargets.erase(i);

			// current phase might be depending on specific targets to be destroyed, notify
			invalidateDestroyTargets();
		}
	}

	// --------------------------------------------
	void invalidateDestroyTargets() {
		if (m_currentPhaseIndex < m_phases.size()) {
			Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.onDestroyTargetsChanged(m_destroyTargets);
		}
	}

	// --------------------------------------------
	protected void handleFactionLoseEvent(const XmlElement@ event) {
		// if green lost a battle, start over
		int factionId = -1;

		const XmlElement@ loseCondition = event.getFirstElementByTagName("lose_condition");
		if (loseCondition !is null) {
			factionId = loseCondition.getIntAttribute("faction_id");
		}

		if (factionId == 0) {
			// friendly faction lost
			// - mark this tracker not started so that it will be added again when map restarts
			m_metagame.removeTracker(this);
			m_started = false;
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		// store which phase we've reached
		// and let phase store additional stuff
		XmlElement@ parent = root;
		XmlElement subroot("map12_phase_controller");

		subroot.setIntAttribute("phase_index", m_currentPhaseIndex);

		if (m_currentPhaseIndex < m_phases.size()) {
			m_phases[m_currentPhaseIndex].save(subroot);
		}

		for (uint i = 0; i < m_destroyTargets.size(); ++i) {
			string key = m_destroyTargets[i];
			XmlElement target("destroy_target");
			target.setStringAttribute("key", key);
			subroot.appendChild(target);
		}

		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		const XmlElement@ controllerElement = root.getFirstElementByTagName("map12_phase_controller");
		// map completion makes the stage use generic completed stage which gets saved, but at load
		// phase we are still loading the real stage.. verify the data is ok before processing it
		if (controllerElement !is null) {
			const XmlElement@ subroot = controllerElement;

			m_currentPhaseIndex = subroot.getIntAttribute("phase_index");
			if (m_currentPhaseIndex < m_phases.size()) {
				m_phases[m_currentPhaseIndex].load(subroot);
			}

			m_destroyTargets = array<string>();
			array<const XmlElement@> targets = subroot.getElementsByTagName("destroy_target");
			for (uint i = 0; i < targets.size(); ++i) {
				const XmlElement@ target = targets[i];
				string key = target.getStringAttribute("key");
				m_destroyTargets.insertLast(key);
			}
		} else {
			// if no save.. we know map12 was completed.. 
			// oh god, 10k points for this hack:
			// - make sure the gate is down after map completes and we load into it
			string command = "<command class='update_static_object' key='wall_door' destroyed='1' />";
			m_metagame.getComms().send(command);
		}
	}

    // ----------------------------------------------------
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
			Phase@ phase = m_phases[m_currentPhaseIndex];
			phase.end();
		}
	}
}
