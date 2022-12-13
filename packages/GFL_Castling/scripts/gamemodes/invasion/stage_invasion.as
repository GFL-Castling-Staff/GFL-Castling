#include "phase_controller.as"
#include "intel_manager.as"

// --------------------------------------------
XmlElement@ createFellowCommanderAiCommand(int factionId, float base = 0.62, float border = 0.14, bool active = true) {
	XmlElement command("command");
	command.setStringAttribute("class", "commander_ai");
	command.setIntAttribute("faction", factionId);
	command.setFloatAttribute("base_defense", base);
	command.setFloatAttribute("border_defense", border);
	command.setBoolAttribute("active", active);
	return command;
}

// --------------------------------------------
// enemy will defend a bit harder than attack by default --> makes it easier for player
XmlElement@ createCommanderAiCommand(int factionId, float base = 0.70, float border = 0.14, bool active = true) {
	XmlElement command("command");
	command.setStringAttribute("class", "commander_ai");
	command.setIntAttribute("faction", factionId);
	command.setFloatAttribute("base_defense", base);
	command.setFloatAttribute("border_defense", border);
	command.setBoolAttribute("active", active);
	return command;
}

// --------------------------------------------
// stage-specific faction info
class Faction {
	const FactionConfig@ m_config;
	XmlElement@ m_defaultCommanderAiCommand;

	int m_bases;

	int m_overCapacity;
	float m_capacityMultiplier;
	int m_capacityOffset;
	bool m_loseWithoutBases;
	bool m_winWithAllBases;

	// this is optional
	array<int> m_ownedBases;

	Faction(const FactionConfig@ config, XmlElement@ defaultCommand) {
		@m_config = @config;
		@m_defaultCommanderAiCommand = @defaultCommand;
		m_bases = -1;
		m_overCapacity = 0;
		m_capacityMultiplier = 1.0;
		m_capacityOffset = 0;
		m_loseWithoutBases = true;
		m_winWithAllBases = true;
	}

	bool isNeutral() const {
		return m_capacityMultiplier <= 0.0;
	}

	string getName() const {
		return m_config.m_name;
	}
};

// --------------------------------------------
class Stage {
	// common game settings from GameModeInvasion, passed in in constructor
	const UserSettings@ m_userSettings;

	MapInfo@ m_mapInfo;

	bool m_finalBattle;
	bool m_hidden;

	// factions involved in this stage
	array<Faction@> m_factions;

	// stage specific tracker classes
	array<Tracker@> m_trackers;

	// stage specific customization through static extra commands
	array<XmlElement@> m_extraCommands;

	array<string> m_includeLayers;

	float m_fogOffset;
	float m_fogRange;

	// stage specific settings
	int m_maxSoldiers;
	float m_soldierCapacityVariance;
	string m_soldierCapacityModel;
	int m_defenseWinTime;
	string m_defenseWinTimeMode;
	float m_playerAiCompensation;
	float m_playerAiReduction;
	bool m_showMapAtStartIfDead;
	bool m_useCustomTimerMode;
	array<Comment@> m_startComments;

	// metadata, mostly for instructions comment selection logic
	string m_primaryObjective;
	string m_kothTargetBase;
	bool m_radioObjectivePresent;

	int m_minRandomCrates;
	int m_maxRandomCrates;

	IntelManager@ m_intelManager;
	
	bool m_allowChangeCapacityOnTheFly;

	// --------------------------------------------
	Stage(const UserSettings@ userSettings) {
		@m_userSettings = @userSettings;
		@m_mapInfo = MapInfo();
		m_finalBattle = false;
		m_hidden = false;
		m_maxSoldiers = 0;
		m_soldierCapacityVariance = 0.30;
		m_soldierCapacityModel = "variable";
		m_defenseWinTime = -1;
		m_defenseWinTimeMode = "hold_bases";
		m_playerAiCompensation = 8;
		m_playerAiReduction = 0;
		m_primaryObjective = "capture";
		m_kothTargetBase = "center base";
		m_radioObjectivePresent = true;
		m_allowChangeCapacityOnTheFly = true;
		m_showMapAtStartIfDead = false;
		m_useCustomTimerMode = false;

		m_includeLayers.insertLast("bases.default");
		m_includeLayers.insertLast("layer1.default");
		m_includeLayers.insertLast("layer2.default");
		m_includeLayers.insertLast("layer3.default");

		m_fogOffset = -100.0;
		m_fogRange = 600.0;
		
		m_minRandomCrates = 5;
		m_maxRandomCrates = 5;
		
		@m_intelManager = null;
	}

	// --------------------------------------------
	bool isCapture() const {
		return m_primaryObjective == "capture";
	}

	// --------------------------------------------
	bool isKoth() const {
		return m_primaryObjective == "koth";
	}

	// --------------------------------------------
	void addTracker(Tracker@ tracker) {
		m_trackers.insertLast(tracker);
	}

	// --------------------------------------------
	// only call this before running the stage
	void removeTracker(Tracker@ tracker) {
		int i = m_trackers.findByRef(tracker);
		if (i != -1) {
			m_trackers.removeAt(i);
		}
	}
	
	// --------------------------------------------
	bool hasSideObjectives() const {
		return true;
	}

	// --------------------------------------------
	bool hasLootObjective() const {
		return true;
	}

	// --------------------------------------------
	bool hasRadioObjective() const {
		return m_radioObjectivePresent;
	}

	// --------------------------------------------
	bool isFinalBattle() const {
		return m_finalBattle;
	}

	// --------------------------------------------
	bool isHidden() const {
		return m_hidden;
	}

	// --------------------------------------------
	protected void appendIncludeLayers(XmlElement@ mapConfig) const {
		for (uint i = 0; i < m_includeLayers.size(); ++i) {
			string name = m_includeLayers[i];
			XmlElement layer("include_layer"); 
			layer.setStringAttribute("name", name); 
			mapConfig.appendChild(layer);
		}
	}

	// --------------------------------------------
	protected void appendFactions(XmlElement@ mapConfig) const {
		for (uint i = 0; i < m_factions.size(); ++i) {
			Faction@ f = m_factions[i];
			XmlElement faction("faction");
			if (i == 0) {
				// friendly faction always uses basic faction form
				faction.setStringAttribute("file", f.m_config.m_file);
			} else {
				// enemies use different faction settings between regular and final battles
				faction.setStringAttribute("file", (isFinalBattle() ? f.m_config.m_finalBattleFile : f.m_config.m_file));
			}
			mapConfig.appendChild(faction);
		}
	}

	// --------------------------------------------
	protected void appendResources(XmlElement@ mapConfig) const {
		/*
		for (uint i = 0; i < m_resourcesToLoad.size(); ++i) {
			Resource@ resource = m_resourcesToLoad[i];

			XmlElement e(resource.m_type);
			e.setStringAttribute("file", resource.m_key);
			mapConfig.appendChild(e);
		}
		*/

		{ XmlElement e("weapon");		e.setStringAttribute("file", "invasion_all_weapons.xml"); mapConfig.appendChild(e); }
		{ XmlElement e("projectile");	e.setStringAttribute("file", "invasion_all_throwables.xml"); mapConfig.appendChild(e); }
		{ XmlElement e("carry_item");	e.setStringAttribute("file", "invasion_all_carry_items.xml"); mapConfig.appendChild(e); }
		{ XmlElement e("call");			e.setStringAttribute("file", "invasion_all_calls.xml"); mapConfig.appendChild(e); }
		{ XmlElement e("vehicle");		e.setStringAttribute("file", "invasion_all_vehicles.xml"); mapConfig.appendChild(e); }
		{ XmlElement e("achievement");	e.setStringAttribute("file", "achievements.xml"); mapConfig.appendChild(e); }
		
		if (m_userSettings.m_testingToolsEnabled) {
			{ XmlElement e("carry_item");	e.setStringAttribute("file", "cheat_items.xml"); mapConfig.appendChild(e); }
			{ XmlElement e("projectile");	e.setStringAttribute("file", "cheat_throwables.xml"); mapConfig.appendChild(e); }
		}
	}

	// --------------------------------------------
	protected void appendJournal(XmlElement@ mapConfig) const {
		if (m_userSettings.m_journalEnabled) {
			XmlElement journal("journal");
			journal.setStringAttribute("filename", "journal.xml");
			mapConfig.appendChild(journal); 
		}
	}

	// --------------------------------------------
	protected void appendMapLegend(XmlElement@ mapConfig) const {
		XmlElement legend("map_legend");
		legend.setStringAttribute("filename", "invasion_map_legend.xml");
		mapConfig.appendChild(legend); 
	}

	// --------------------------------------------
	protected void appendScene(XmlElement@ mapConfig) const {
		XmlElement scene("scene");
		scene.setStringAttribute("filename", "scene.xml");
		mapConfig.appendChild(scene); 
	}

	// --------------------------------------------
	protected void appendCamera(XmlElement@ scene) const {
		XmlElement camera("camera");
		camera.setStringAttribute("direction", "-0.3 -1.7 1.0");
		camera.setFloatAttribute("distance", 36.0);
		camera.setFloatAttribute("far_clip", 95.0);
		camera.setFloatAttribute("shadow_far_clip", 80.0);
		scene.appendChild(camera);
	}

	// --------------------------------------------
	protected void appendFog(XmlElement@ scene) const {
		XmlElement fog("fog");
		fog.setFloatAttribute("offset", m_fogOffset);
		fog.setFloatAttribute("range", m_fogRange);
		scene.appendChild(fog);
	}

	// --------------------------------------------
	protected void appendOverlays(XmlElement@ command) const {
		string overlays;
		for (uint i = 0; i < m_userSettings.m_overlayPaths.size(); ++i) {
			string path = m_userSettings.m_overlayPaths[i];
			_log("adding overlay " + path);
			
			XmlElement e("overlay"); 
			e.setStringAttribute("path", path); 
			command.appendChild(e);
		}
	}

	// --------------------------------------------
	XmlElement@ getChangeMapCommand() const {
		XmlElement mapConfig("map_config");

		appendIncludeLayers(mapConfig);
		appendFactions(mapConfig);
		appendResources(mapConfig);
		appendScene(mapConfig);
		appendJournal(mapConfig);
		appendMapLegend(mapConfig);

		XmlElement command("command");
		command.setStringAttribute("class", "change_map");
		// helps with loading time by avoiding creating most of the stuff before we input the wanted match settings - we aren't using the default ones in invasion
		command.setBoolAttribute("suppress_default_match", true);
		command.setStringAttribute("map", m_mapInfo.m_path);

		appendOverlays(command);

		command.appendChild(mapConfig);

		return command;
	}

	// --------------------------------------------
	array<XmlElement@>@ getExtraCommands() const {
		array<XmlElement@> commands = m_extraCommands;
		return commands;
	}

	// --------------------------------------------
	// TODO: make metagame member variable like everywhere else, this is a quick temporary fix
	const XmlElement@ getStartGameCommand(GameModeInvasion@ metagame, float completionPercentage = 0.5) const {
		string username = m_userSettings.m_username;

		XmlElement command("command");
		command.setStringAttribute("class", "start_game");
		command.setStringAttribute("savegame", m_userSettings.m_savegame);
		command.setIntAttribute("vehicles", 1);
		command.setIntAttribute("max_soldiers", m_maxSoldiers);
		command.setFloatAttribute("soldier_capacity_variance", m_soldierCapacityVariance);
		command.setStringAttribute("soldier_capacity_model", m_soldierCapacityModel);
		command.setFloatAttribute("player_ai_compensation", m_playerAiCompensation * m_userSettings.m_playerAiCompensationFactor);
		command.setFloatAttribute("player_ai_reduction", m_playerAiReduction + m_userSettings.m_playerAiReduction);
		command.setFloatAttribute("xp_multiplier", m_userSettings.m_xpFactor);
		command.setFloatAttribute("rp_multiplier", m_userSettings.m_rpFactor);
		command.setFloatAttribute("initial_xp", m_userSettings.m_initialXp);
		command.setFloatAttribute("initial_rp", m_userSettings.m_initialRp);
		command.setStringAttribute("base_capture_system", m_userSettings.m_baseCaptureSystem);
		command.setBoolAttribute("friendly_fire", m_userSettings.m_friendlyFire);
		command.setFloatAttribute("max_rp", m_userSettings.m_maxRp);
		command.setFloatAttribute("player_damage_modifier", m_userSettings.m_playerDamageModifier);
		command.setBoolAttribute("fov", m_userSettings.m_fov);
		command.setBoolAttribute("show_map_at_start_if_dead", m_showMapAtStartIfDead);

		if (m_defenseWinTime >= 0) {
			command.setFloatAttribute("defense_win_time", m_defenseWinTime);
			command.setStringAttribute("defense_win_time_mode", m_defenseWinTimeMode);
		}
		
		if (m_useCustomTimerMode) {
			command.setStringAttribute("defense_win_time_mode", "custom");
		}

		for (uint i = 0; i < m_factions.size(); ++i) {
			Faction@ f = m_factions[i];
			XmlElement faction("faction");

			faction.setFloatAttribute("capacity_offset", f.m_capacityOffset);
			faction.setFloatAttribute("initial_over_capacity", f.m_overCapacity);

			{
				float multiplier = metagame.determineFinalFactionCapacityMultiplier(f, i);
				faction.setFloatAttribute("capacity_multiplier", multiplier);
			}

			if (i == 0) {
				// friendly faction
				faction.setFloatAttribute("ai_accuracy", m_userSettings.m_fellowAiAccuracyFactor);
				faction.setIntAttribute("disable_enemy_spawnpoints_soldier_count_offset", m_userSettings.m_fellowDisableEnemySpawnpointsSoldierCountOffset);
				faction.setBoolAttribute("lose_last_base_without_spawnpoints", true);
			} else {
				// enemy
				faction.setFloatAttribute("ai_accuracy", m_userSettings.m_enemyAiAccuracyFactor);
				faction.setBoolAttribute("lose_last_base_without_spawnpoints", false);
			}			

			// if base amount has been declared for the faction, use it

			// allow adventure mode to use the amount of bases we managed to capture 
			// if we were in the map previously

			if (i == 0 && f.m_ownedBases.size() > 0) {
				faction.setIntAttribute("initial_occupied_bases", f.m_ownedBases.size());
			} else if (f.m_bases >= 0) {
				faction.setIntAttribute("initial_occupied_bases", f.m_bases);
			}

			faction.setBoolAttribute("lose_without_bases", f.m_loseWithoutBases);
			faction.setBoolAttribute("win_with_all_bases", f.m_winWithAllBases);

			command.appendChild(faction);
		}

		{
			XmlElement player("local_player");
			player.setIntAttribute("faction_id", 0);
			player.setStringAttribute("username", m_userSettings.m_username);
			command.appendChild(player);
		}

		return command;
	}

	// --------------------------------------------
	const XmlElement@ getChangeSettingsCommand(GameModeInvasion@ metagame, float completionPercentage = 0.5) const {
		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		command.setFloatAttribute("xp_multiplier", m_userSettings.m_xpFactor);
		command.setFloatAttribute("rp_multiplier", m_userSettings.m_rpFactor);
		command.setFloatAttribute("player_damage_modifier", m_userSettings.m_playerDamageModifier);
		command.setBoolAttribute("fov", m_userSettings.m_fov);

		for (uint i = 0; i < m_factions.size(); ++i) {
			Faction@ f = m_factions[i];
			XmlElement faction("faction");

			if (m_allowChangeCapacityOnTheFly) {
				float multiplier = metagame.determineFinalFactionCapacityMultiplier(f, i);
				faction.setFloatAttribute("capacity_multiplier", multiplier);
			}

			if (i == 0) {
				// friendly faction
				faction.setFloatAttribute("ai_accuracy", m_userSettings.m_fellowAiAccuracyFactor);
			} else {
				// enemy
				faction.setFloatAttribute("ai_accuracy", m_userSettings.m_enemyAiAccuracyFactor);
			}			
			command.appendChild(faction);
		}

		return command;
	}

	// --------------------------------------------
	void setIntelManager(IntelManager@ intelManager) {
		if (intelManager !is null) {
			addTracker(intelManager);
		} else {
			// clearing intel manager
			if (m_intelManager !is null) {
				removeTracker(m_intelManager);
			}
		}
		@m_intelManager = @intelManager;
	}

	// --------------------------------------------
	bool hasIntelManager() const {
		return m_intelManager !is null;
	}

	void addStartComment(Comment@ comment) {
		m_startComments.push_back(comment);
	}
	
	void announceStart(Metagame@ metagame) {
		dictionary a = {
			{"%map_name", m_mapInfo.m_name},
			{"%faction_name", m_factions.size() >= 2 ? m_factions[1].m_config.m_name : ""}
		};

		for (uint i = 0; i < m_startComments.size(); ++i) {
			Comment@ comment = m_startComments[i];
			metagame.getTaskSequencer().add(AnnounceTask(metagame, comment.m_duration, 0, comment.m_key, a));
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		if (m_intelManager !is null) {
			m_intelManager.save(root);
		}
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		if (m_intelManager !is null) {
			m_intelManager.load(root);
		}
	}
}

// --------------------------------------------
class PhasedStage : Stage {
	protected PhaseController@ m_phaseController;

	// --------------------------------------------
	PhasedStage(const UserSettings@ userSettings) {
		super(userSettings);
	}

	// --------------------------------------------
	void setPhaseController(PhaseController@ phaseController) {
		@m_phaseController = @phaseController;
		addTracker(m_phaseController);
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		Stage::save(root);
		if (m_phaseController !is null) {
			m_phaseController.save(root);
		}
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		Stage::load(root);
		if (m_phaseController !is null) {
			m_phaseController.load(root);
		}
	}
}

class Comment {
	string m_key;
	float m_duration;

	Comment(string key, float duration) {
		m_key = key;
		m_duration = duration;
	}
}