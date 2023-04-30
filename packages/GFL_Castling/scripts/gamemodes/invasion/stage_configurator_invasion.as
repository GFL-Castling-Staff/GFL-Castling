// gamemode specific
#include "faction_config.as"
#include "stage_configurator.as"
#include "stage_invasion.as"

#include "phase_controller_map12.as"
#include "phase_controller_shockzone.as"
#include "phase_controller_deadzone.as"

#include "pausing_koth_timer.as"
#include "spawn_at_node.as"
#include "comms_capacity_handler.as"
#include "attack_defense_handler_map16.as"
#include "attack_defense_handler_map1_2.as"
#include "run_at_start.as"
#include "TheJupiter.as"
#include "spawn_in_base_call_handler.as"
#include "call_sort.as"
#include "deadzone_hack.as"


// ------------------------------------------------------------------------------------------------
class StageConfiguratorInvasion : StageConfigurator {
	protected GameModeInvasion@ m_metagame;
	protected MapRotatorInvasion@ m_mapRotator;
	protected int m_stagesAdded;
	protected int m_playerAiCompensation_offset = -1;

	// ------------------------------------------------------------------------------------------------
	StageConfiguratorInvasion(GameModeInvasion@ metagame, MapRotatorInvasion@ mapRotator) {
		@m_metagame = @metagame;
		@m_mapRotator = mapRotator;
		mapRotator.setConfigurator(this);
		m_stagesAdded = 0;
	}

	// ------------------------------------------------------------------------------------------------
	void setup() {
		setupGlobalConfigs();
		
		setupFactionConfigs();

		setupWorld();

		setupNormalStages();
	}

	// ------------------------------------------------------------------------------------------------
	const array<FactionConfig@>@ getAvailableFactionConfigs() const {
		array<FactionConfig@> availableFactionConfigs;

		availableFactionConfigs.push_back(FactionConfig(-1, "gk.xml", "GK", "0.95 0.59 0.20", "gk.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "kcco.xml", "KCCO", "0.43 0.49 0.18", "kcco.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "paradeus.xml", "Paradeus", "1 1 1", "paradeus.xml"));

		return availableFactionConfigs;
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupGlobalConfigs() {
		const UserSettings@ settings = m_metagame.getUserSettings();
		// m_playerAiCompensation_offset += (settings.m_GlobalDifficulty);
		m_playerAiCompensation_offset = 1;
	}

	protected void setupFactionConfigs() {
		array<FactionConfig@> availableFactionConfigs = getAvailableFactionConfigs(); // copy for mutability

		const UserSettings@ settings = m_metagame.getUserSettings();
		// - the faction the player picks in lobby campaign menu needs to be inserted first in the faction configs list
		{
			_log("faction choice: " + settings.m_factionChoice, 1);
			FactionConfig@ userChosenFaction = availableFactionConfigs[settings.m_factionChoice];
			_log("player faction: " + userChosenFaction.m_file, 1);

			int index = int(getFactionConfigs().size()); // is 0
			userChosenFaction.m_index = index;
			m_mapRotator.addFactionConfig(userChosenFaction);

			availableFactionConfigs.erase(settings.m_factionChoice);
		}

		// - next add the rest of them, in random order
		while (availableFactionConfigs.size() > 0) {
			int index = int(getFactionConfigs().size());

			int availableIndex = rand(0, availableFactionConfigs.size() - 1);
			FactionConfig@ faction = availableFactionConfigs[availableIndex];

			_log("setting " + faction.m_name + " as index " + index, 1);

			faction.m_index = index;
			m_mapRotator.addFactionConfig(faction);

			availableFactionConfigs.erase(availableIndex);
		}

		// - finally add neutral
		{
			int index = getFactionConfigs().size();
			m_mapRotator.addFactionConfig(FactionConfig(index, "neutral.xml", "Neutral", "0 0 0"));
		}

		_log("total faction configs " + getFactionConfigs().size(), 1);
	}

	protected void setupGeneralCallConfig(Stage@ stage) {
		for(uint i=0;i<GeneralCallList.length();i++){
			stage.addTracker(GeneralCallList[i]);
			_log("录入编号"+ i);
		}
	}

	// ------------------------------------------------------------------------------------------------
	protected void addRandomSpecialCrates(Stage@ stage, int minCount, int maxCount) {
		array<ScoredResource@> resources = {
			ScoredResource("gflc_crate1.vehicle", "vehicle", 50.0f),           // cgb
			ScoredResource("gflc_crate2.vehicle", "vehicle", 100.0f),           // gift150
			ScoredResource("gflc_crate3.vehicle", "vehicle", 100.0f),           // gift150
			ScoredResource("gflc_crate4.vehicle", "vehicle", 30.0f),           // gift1000
			ScoredResource("gflc_crate5.vehicle", "vehicle", 50.0f),           // 快修
			ScoredResource("gflc_crate6.vehicle", "vehicle", 20.0f),           // 超导
			ScoredResource("gflc_crate7.vehicle", "vehicle", 2.0f),           // 火神
			ScoredResource("gflc_crate8.vehicle", "vehicle", 15.0f),           // fnc的零食盒子
			ScoredResource("gflc_crate9.vehicle", "vehicle", 5.0f),           // 我自杀算了
			ScoredResource("gflc_crate10.vehicle", "vehicle", 100.0f)           // 标枪

		};
		int count = rand(minCount, maxCount);
		stage.addTracker(SpawnAtNode(m_metagame, resources, "random_crate", 0, count));
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addFixedSpecialCrates(Stage@ stage) {
		array<ScoredResource@> resources = {
			ScoredResource("gflc_crate1.vehicle", "vehicle", 50.0f),           // cgb
			ScoredResource("gflc_crate2.vehicle", "vehicle", 100.0f),           // gift150
			ScoredResource("gflc_crate3.vehicle", "vehicle", 100.0f),           // gift150
			ScoredResource("gflc_crate4.vehicle", "vehicle", 30.0f),           // gift1000
			ScoredResource("gflc_crate5.vehicle", "vehicle", 50.0f),           // 快修
			ScoredResource("gflc_crate6.vehicle", "vehicle", 20.0f),           // 超导
			ScoredResource("gflc_crate7.vehicle", "vehicle", 2.0f),           // 火神
			ScoredResource("gflc_crate8.vehicle", "vehicle", 15.0f),           // fnc的零食盒子
			ScoredResource("gflc_crate9.vehicle", "vehicle", 5.0f),           // 我自杀算了
			ScoredResource("gflc_crate10.vehicle", "vehicle", 100.0f)           // 标枪

		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "fixed_crate", 0, 1000));
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addLotteryVehicle(Stage@ stage) {
		array<ScoredResource@> resources = {
			// for testing: 0 score no spawn -> 100% chance for icecream
			//ScoredResource("", "", 0.0f),          
			ScoredResource("", "", 70.0f),
			ScoredResource("icecream.vehicle", "vehicle", 100.0f)
			// ScoredResource("icecream_Solar_Sea.vehicle", "vehicle", 30.0f),
			// ScoredResource("icecream_akino.vehicle", "vehicle", 30.0f),
			// ScoredResource("icecream_connexion.vehicle", "vehicle", 30.0f)
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "icecream", 0, 1));
	}

	array<SpawnInBaseCallHandler@> GeneralCallList ={
		SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false),
		SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false),
		SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false)
	};

	// ------------------------------------------------------------------------------------------------
	protected void addStage(Stage@ stage) {
		addFixedSpecialCrates(stage);
		addRandomSpecialCrates(stage, stage.m_minRandomCrates, stage.m_maxRandomCrates);
		addLotteryVehicle(stage);
		
		if (stage.isCapture()) {
			stage.setIntelManager(IntelManager(m_metagame));
		}

		m_mapRotator.addStage(stage);
		m_stagesAdded++;
	}

	// ------------------------------------------------------------------------------------------------
	protected void setupNormalStages() {
		addStage(setupStage106());		  // map106 E30 Route by diling
		// addStage(setupStage1_rust());          // map2_?
		// addStage(setupStageRace());          // DEJAHU
		addStage(setupStage1());          // map2
		addStage(setupStage10());         // map10
		addStage(setupStageXmas()); 
		addStage(setupStage7());          // map6c by diling
		addStage(setupStage19());		  // map18    
		addStage(setupStage6());          // map5
		addStage(setupStage13());         // map16
		addStage(setupStage8());          // map8
		addStage(setupStage2());          // map4 c
		addStage(setupStage103()); 		  // map103 Palo Island by diling
		// addStage(setupEggStage());		  // 上坟
		addStage(setupStage9());          // map9
		addStage(setupStage18());         // map13_2
		addStage(setupStage107());		  // chapter1 by diling
		addStage(setupStage109());		  // chapter2 by diling
		addStage(setupStage12());         // map14
		addStage(setupStage106());		  // map106 E30 Route by diling
		addStage(setupStage17());         // map17
		addStage(setupStage15());         // map1_2
		addStage(setupFinalStage1());     // map11
		addStage(setupStage104()); 		  // map105_1 zoneAttack by diling
		addStage(setupStage105()); 		  // map105_2 shockzone by diling
		addStage(setupDeadZone());	      // map105_3 deadzone by diling
		addStage(setupStage3());		  // map3 c
		addStage(setupStage16());         // map8_2
		addStage(setupStage20());
		// addStage(setupStage14());         // map6_2
		// addStage(setupStage5());          // map1
		addStage(setupStage108());		  // xiaoxieshen by diling
		// addStage(setupStage11());         // map13
		addStage(setupStage4());          // map7
	}

	// --------------------------------------------
	protected Stage@ createStage() const {
		Stage@ stage = Stage(m_metagame.getUserSettings());
		return stage;
	}

	// --------------------------------------------
	protected PhasedStage@ createPhasedStage() const {
		return PhasedStage(m_metagame.getUserSettings());
	}

	// --------------------------------------------
	const array<FactionConfig@>@ getFactionConfigs() const {
		return m_mapRotator.getFactionConfigs();
	}

	// ------------------------------------------------------------------------------------------------
	Stage@ setupCompletedStage(Stage@ inputStage) {
		// currently not in use in invasion
		return null;
	}

	// ------------------------------------------------------------------------------------------------
	protected void setDefaultAttackBreakTimes(Stage@ stage) {
		for (uint i = 0; i < stage.m_factions.size(); ++i) {
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction", i);
			command.setFloatAttribute("start_attack_break_time", 50.0f);
			command.setFloatAttribute("attack_break_time", 60.0f);
			// initially clear final attack boost
			command.setFloatAttribute("reduce_defense_for_final_attack", 0.0f); 
			stage.m_extraCommands.insertLast(command);
		}
	}

	// ------------------------------------------------------------------------------------------------
	protected void setReduceDefenseForFinalAttack(Stage@ stage, float value) {
		XmlElement command("command");
		command.setStringAttribute("class", "commander_ai");
		command.setIntAttribute("faction", 0);
		command.setFloatAttribute("reduce_defense_for_final_attack", value);
		stage.m_extraCommands.insertLast(command);
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStageRace() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "De ja vu";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/C01_Race";
		stage.m_mapInfo.m_id = "Dejavu";

		stage.m_maxSoldiers = 10;

		stage.m_soldierCapacityVariance = 0.4;
		stage.m_playerAiCompensation = 0;
        stage.m_playerAiReduction = 0;

		{
        XmlElement command("command");
        command.setStringAttribute("class", "change_game_settings");
        for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
            XmlElement faction("faction");
            if (int(i) == 1) {
                faction.setBoolAttribute("lose_without_bases", false);
            }
            command.appendChild(faction);
		}
        stage.addTracker(RunAtStart(m_metagame, command));
        }

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.0, 0.0, false));
			f.m_overCapacity = 2;
			f.m_capacityMultiplier = 0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 1.0, 0.0, false));
			f.m_capacityMultiplier = 0;
			stage.m_factions.insertLast(f); 
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"aek999.vehicle","wheelchair.vehicle"}, true);
			stage.m_extraCommands.insertLast(command);
			command.setIntAttribute("faction_id", 1);
			stage.m_extraCommands.insertLast(command);
		}
		
		// metadata
		stage.m_primaryObjective = "capture";

		
		return stage;
	}

	protected Stage@ setupStage103() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Palo Island";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map103";
		stage.m_mapInfo.m_id = "map103";

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 160;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.4;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 0;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		array<int> FactionIndex = getRandomEnemyList();

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1,0.3,0.1));
			f.m_overCapacity = 30;                                               
			f.m_capacityOffset = 15;
			f.m_capacityMultiplier = 1.0;                                                 
			stage.m_factions.insertLast(f);                                         
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2,0.4,0.3));
			f.m_capacityOffset = 10;
			f.m_capacityMultiplier = 0.8;                                                 
			stage.m_factions.insertLast(f);                                         
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	protected Stage@ setupStage104() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Zone Attack";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map105_1";
		stage.m_mapInfo.m_id = "map105_1";

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.addTracker(jupiter(m_metagame,30));
		stage.m_maxSoldiers = 160;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.4;
		stage.m_playerAiCompensation = 3 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 0;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 35; 
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
			if(getFactionConfigs()[0].m_name=="GK"){
				_log("gotGKguys114514");
				XmlElement command("command");
				command.setStringAttribute("class", "faction");
				command.setIntAttribute("faction_id", 0);
				command.setStringAttribute("soldier_group_name", "kcco_f_aegis");
				command.setFloatAttribute("spawn_score", 1.0f);
				stage.m_extraCommands.insertLast(command);
				XmlElement command2("command");
				command.setStringAttribute("class", "faction");
				command.setIntAttribute("faction_id", 0);
				command.setStringAttribute("soldier_group_name", "kcco_f_cyclops_sg");
				command.setFloatAttribute("spawn_score", 2.0f);
				stage.m_extraCommands.insertLast(command2);
			}
		}
		{
			Faction f(FactionConfig(1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"), createCommanderAiCommand(1,0.3,0.2));
			f.m_capacityMultiplier = 0.8;
			f.m_capacityOffset = 35;
			stage.m_factions.insertLast(f);                                         
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,true,false,"infantry"));
		}

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		// setReduceDefenseForFinalAttack(stage, 0.1); // use this for final attack boost if needed for friendlies
		
		return stage;
	}

	protected Stage@ setupStage105() {
		PhasedStage@ stage = createPhasedStage();
		stage.setPhaseController(PhaseControllerMap105(m_metagame));
		stage.m_mapInfo.m_name = "Shock Zone";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map105_2";
		stage.m_mapInfo.m_id = "map105_2";

		stage.m_maxSoldiers = 150;
		stage.m_soldierCapacityModel = "constant";
		stage.m_playerAiCompensation = 3;
        stage.m_playerAiReduction = 0;
		stage.m_finalBattle = true;
		stage.m_fogOffset= 28;
		stage.m_fogRange= 28.5;
		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 5;

		stage.m_defenseWinTime = 360; 
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime,false,false));

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.2));                                            
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 0.85;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}			
		{
			Faction f(FactionConfig(1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"), createCommanderAiCommand(1, 0.50, 0.50));
			f.m_capacityMultiplier = 0.3;
			f.m_capacityOffset = 10;
			stage.m_factions.insertLast(f);                                                                
		}
		{
			Faction f(FactionConfig(2, "kcco.xml", "KCCO", "0.43 0.49 0.18", "kcco.xml"), createCommanderAiCommand(2, 0.10, 0.10));             
			f.m_overCapacity = 70;                                             
            f.m_capacityOffset = 40;
			f.m_capacityMultiplier = 1.3;
			stage.m_factions.insertLast(f);                                    
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"sf_jupiter_destroy.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}        
		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "All SF Base";

		
		return stage;
	} 	

	protected Stage@ setupDeadZone() {
		PhasedStage@ stage = createPhasedStage();
		stage.setPhaseController(PhaseControllerDeadZone(m_metagame));
		stage.m_mapInfo.m_name = "Dead Zone";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map105_3";
		stage.m_mapInfo.m_id = "map105_3";

		stage.m_maxSoldiers = 80;
		stage.m_playerAiCompensation = 3;
        stage.m_playerAiReduction = 0;
		stage.m_finalBattle = false;
		stage.m_fogOffset= 34;
		stage.m_fogRange= 30;
		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;
		
		stage.m_primaryObjective = "phases";
		stage.addTracker(DeadZoneHack(m_metagame));
		stage.addStartComment(Comment("Map105_3,start comment1", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment2", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment3", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment4", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment5", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment6", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment7", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment8", 2.5));
		stage.addStartComment(Comment("Map105_3,start comment9", 2.5));


		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.2));                                            
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}

		{
			Faction f(FactionConfig(1, "paradeus.xml", "Paradeus", "1 1 1", "paradeus.xml"), createCommanderAiCommand(1, 0.30, 0.30));
			f.m_capacityMultiplier = 1.0;
			f.m_capacityOffset = 80;
			stage.m_factions.insertLast(f);                                                                
		}
		{
			Faction f(FactionConfig(2, "elid.xml", "E.L.I.D.", "0.3 0.17 0.11", "elid.xml"), createCommanderAiCommand(2, 0.80, 0.20));             
			f.m_overCapacity = 70;
            f.m_capacityOffset = 80;
			f.m_capacityMultiplier = 0.001;
			stage.m_factions.insertLast(f);                                    
		}
		{
			Faction f(FactionConfig(3, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"), createCommanderAiCommand(3, 0.9, 0.1));
			f.m_overCapacity = 70;                                             
            f.m_capacityOffset = 40;
			f.m_capacityMultiplier = 0.001;
			stage.m_factions.insertLast(f);
		}

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}   
		

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_kothTargetBase = "Escape";

		return stage;
	} 	
	protected Stage@ setupStage106(){
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Route E30";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map106";
		stage.m_mapInfo.m_id = "map106";

		stage.addTracker(Overtime(m_metagame, 0,10));
		stage.m_soldierCapacityModel = "constant";     
		stage.m_maxSoldiers = 160;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.3;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 0;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;

		stage.m_defenseWinTime = 360; 
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(FactionConfig(1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"), createCommanderAiCommand(1, 0.20, 0.10));
            f.m_capacityOffset = 15;                                            
			stage.m_factions.insertLast(f);                                                                
		}
		{
			Faction f(FactionConfig(2, "kcco.xml", "KCCO", "0.43 0.49 0.18", "kcco.xml"), createCommanderAiCommand(2, 0.20, 0.10));             
            f.m_capacityOffset = 15;                                            
			stage.m_factions.insertLast(f);                                    
		}
		{
			Faction f(FactionConfig(3, "paradeus.xml", "Paradeus", "1 1 1", "paradeus.xml"), createCommanderAiCommand(3, 0.20, 0.10));             
            f.m_capacityOffset = 5;                                            
			stage.m_factions.insertLast(f);                                    
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}                
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "All Center Base";
		
		return stage;		
	}

	protected Stage@ setupStage107(){
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Awakening";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/Chapter01";
		stage.m_mapInfo.m_id = "chapter01";
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 180;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     
		stage.m_playerAiReduction = 2;                                         
		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 6;
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1,0.4,0.2));
			f.m_overCapacity = 50;                                            
			f.m_capacityOffset = 20;                                           
			stage.m_factions.insertLast(f); 
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"water_tower.vehicle","radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}		
		stage.m_primaryObjective = "capture";
		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}
	protected Stage@ setupStage108(){
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Kanda jimbocho";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/mydevilsfrontline";
		stage.m_mapInfo.m_id = "Tokyo Jimbocho";
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 120;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     
		stage.m_playerAiReduction = 2;                                         
		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 6;
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1,0.4,0.2));
			f.m_overCapacity = 40;                                            
			f.m_capacityOffset = 20;                                           
			stage.m_factions.insertLast(f); 
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2,0.3,0.2));
			f.m_overCapacity = 40;                                            
			f.m_capacityOffset = 20;                                           
			stage.m_factions.insertLast(f); 
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"water_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}		
		stage.m_primaryObjective = "capture";
		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}
	protected Stage@ setupEggStage() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "High Land 33";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/egg001";
		stage.m_mapInfo.m_id = "Highland33";

		stage.addTracker(Overtime(m_metagame, 0));

		stage.m_maxSoldiers = 150;                                             // was 28*3 in 1.75
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 5 (test4)
		stage.m_playerAiReduction = 2;                                            // was 3 (test4)  
		stage.m_soldierCapacityModel = "constant";                                // was set to default in 1.65
		
		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;
         
		stage.m_defenseWinTime = 450;     // was 400 in 1.65 old koth mode
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
	
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.55, 0.25));     // was 0.1, 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(FactionConfig(1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"), createCommanderAiCommand(1, 0.20, 0.10));
            f.m_capacityOffset = 25;                                            
			stage.m_factions.insertLast(f);                                                                
		}
		{
			Faction f(FactionConfig(2, "kcco.xml", "KCCO", "0.43 0.49 0.18", "kcco.xml"), createCommanderAiCommand(2, 0.20, 0.10));             
            f.m_capacityOffset = 25;                                            
			stage.m_factions.insertLast(f);                                    
		}
		{
			Faction f(FactionConfig(3, "paradeus.xml", "Paradeus", "1 1 1", "paradeus.xml"), createCommanderAiCommand(3, 0.20, 0.10));             
            f.m_capacityOffset = 5;                                            
			stage.m_factions.insertLast(f);                                    
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}        

		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "grave";

		
		return stage;
	} 
	protected Stage@ setupStage109(){
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Echo";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/Chapter02";
		stage.m_mapInfo.m_id = "chapter02";
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 100;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     
		stage.m_playerAiReduction = 0;                                         
		stage.m_minRandomCrates = 3; 
		stage.m_maxRandomCrates = 4;
		stage.m_fogOffset = 24.0;
		stage.m_fogRange = 24.5;
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.15));
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1,0.5,0.2));
			f.m_overCapacity = 120;                                            
			f.m_capacityOffset = 30;                                           
			stage.m_factions.insertLast(f); 
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"water_tower.vehicle","radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}		
		stage.m_primaryObjective = "capture";
		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}	

	protected Stage@ setupStageXmas() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "A Snowy Night Capriccio";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/mapxmas";
		stage.m_mapInfo.m_id = "mapxmas";
		
		stage.m_includeLayers.insertLast("layer1.invasion"); 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 12 * 10;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.3;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 2;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1));
			f.m_overCapacity = 50;                                               // was 30 (test2)
			f.m_capacityOffset = 8;                                                 // was 5 (1.81)
			stage.m_factions.insertLast(f);                                         // was 0 in 1.65
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"default_car_1.vehicle","default_car_2.vehicle","default_car_3.vehicle"}, true);
			stage.m_extraCommands.insertLast(command);
			command.setIntAttribute("faction_id", 1);
			stage.m_extraCommands.insertLast(command);
		}		

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		// setReduceDefenseForFinalAttack(stage, 0.1); // use this for final attack boost if needed for friendlies
		
		return stage;
	}

	protected Stage@ setupStage1() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Keepsake Bay";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map2";
		stage.m_mapInfo.m_id = "map2";
		
		stage.m_includeLayers.insertLast("layer1.invasion"); 

		stage.addTracker(jupiter(m_metagame));
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 12 * 10;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.3;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 2;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1));
			f.m_overCapacity = 50;                                               // was 30 (test2)
			f.m_capacityOffset = 8;                                                 // was 5 (1.81)
			stage.m_factions.insertLast(f);                                         // was 0 in 1.65
		}
		

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		// setReduceDefenseForFinalAttack(stage, 0.1); // use this for final attack boost if needed for friendlies
		
		return stage;
	}

	protected Stage@ setupStage1_rust() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Casake Bay";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map2_c";
		stage.m_mapInfo.m_id = "map2_?";
		
		stage.m_includeLayers.insertLast("layer1.invasion"); 

		stage.addTracker(jupiter(m_metagame));
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 12 * 13;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.3;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 2;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 5; 
		stage.m_maxRandomCrates = 8;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1));
			f.m_overCapacity = 50;                                               // was 30 (test2)
			f.m_capacityOffset = 20;                                                 // was 5 (1.81)
			stage.m_factions.insertLast(f);                                         // was 0 in 1.65
		}
		
		// metadata
		stage.m_primaryObjective = "capture";
		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage2() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Fridge Valley";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map4_c";
		stage.m_mapInfo.m_id = "map4";

		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0;     

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.addTracker(jupiter(m_metagame,45));
		stage.m_maxSoldiers = 17 * 7;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 5 (test4)
		stage.m_playerAiReduction = 2;                                            // was 2 (test3)

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 3;    

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1));
			f.m_overCapacity = 40;                                              // was 30 (test2)
			f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f); 
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}	
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"armored_truck.vehicle"}, false);
			stage.m_extraCommands.insertLast(command);
		}
		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage3() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Raining Fort Creek";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map3_c";
		stage.m_mapInfo.m_id = "map3";

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 14 * 11;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 6 (test4)
		stage.m_playerAiReduction = 2;                                              // was 2.5 (test4)   

		stage.m_soldierCapacityVariance = 0.4;                                   // was 0.31 in 1.65

		stage.m_minRandomCrates = 3; 
		stage.m_maxRandomCrates = 6;    
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_capacityOffset = 0; 
			f.m_overCapacity = 0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1));
			f.m_overCapacity = 20;
			f.m_capacityOffset = 10;
			stage.m_factions.insertLast(f); 
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2));
			f.m_overCapacity = 20;
			f.m_capacityOffset = 10;
			stage.m_factions.insertLast(f); 
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}	
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage4() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Power Junction";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map7";
		stage.m_mapInfo.m_id = "map7";

		stage.m_includeLayers.insertLast("layer1.invasion");        

		stage.addTracker(Overtime(m_metagame, 0));

		stage.m_maxSoldiers = 35 * 4;                                             // was 28*3 in 1.75
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 5 (test4)
		stage.m_playerAiReduction = 2;                                            // was 3 (test4)  
		stage.m_soldierCapacityModel = "constant";                                // was set to default in 1.65
		
		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;
         
		stage.m_defenseWinTime = 600;     // was 400 in 1.65 old koth mode
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.1));     // was 0.1, 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(2, 0.38, 0.1));           // was 0.1, 0.1 in 1.65
			f.m_overCapacity = 20;                                              // was 0 (test2)
			f.m_capacityOffset = 35;                                                             // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(1, 0.38, 0.1));           // was 0.1, 0.1 in 1.65
            f.m_overCapacity = 20;                                              // was 0 (test2)
			f.m_capacityOffset = 35;                                                             // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}
		
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}

		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Power Plant";

		
		return stage;
	} 

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage5() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Moorland Trenches";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map1";
		stage.m_mapInfo.m_id = "map1";

		stage.m_maxSoldiers = 18 * 14;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     // was 4 (test4)     
		stage.m_playerAiReduction = 0;                                            // was 1 (test3)    

		stage.m_soldierCapacityVariance = 0.4; // map1 is a big map; using high variance helps keep the attack group not growing super large when more bases are captured

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 3; 
		stage.m_maxRandomCrates = 5;
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_overCapacity = 6;                                                   
			f.m_bases = 1;
			f.m_capacityMultiplier = 0.79;                                          // was 0.81 in 1.65 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1));
			f.m_overCapacity = 60;                                                  // was 50 (test2)   
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2));
			f.m_overCapacity = 60;                                                  // was 50 (test2)      
			stage.m_factions.insertLast(f);
		}

		// aa emplacements work right only if one enemy faction has them
		// - all factions have it disabled by default
		// - manually enable it for faction #1 in map1 

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	protected Stage@ setupStage102() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "M16A1's Farm 0-2";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map102";
		stage.m_mapInfo.m_id = "map102";

		stage.m_maxSoldiers = 14 * 14;
		stage.m_playerAiCompensation = 3;                                     // was 4 (test4)     
		stage.m_playerAiReduction = 1;                                            // was 1 (test3)    

		stage.m_soldierCapacityVariance = 0.4; 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 3; 
		stage.m_maxRandomCrates = 5;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_overCapacity = 6;                                                   
			f.m_bases = 1;
			f.m_capacityMultiplier = 0.79;                                          // was 0.81 in 1.65 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1));
			f.m_overCapacity = 80;                                                  // was 50 (test2)   
			stage.m_factions.insertLast(f);
		}


		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage6() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Corrupt lefands";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map5_c";
		stage.m_mapInfo.m_id = "map5";

		stage.m_maxSoldiers = 11 * 12;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       // was 5 (test4)
		stage.m_playerAiReduction = 2;                                              // was 2 (test3)

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_overCapacity = 0;                                                  // was 20 in 1.65
			f.m_bases = 1;
			// seems to be quite hard at times, try to favor greens a bit
			f.m_capacityMultiplier = 1.0;                                           // was 1.1 in 1.65
			f.m_capacityOffset = 0;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(2));
			f.m_overCapacity = 30;                                              // was 0 (test2)            
			f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(1));
			f.m_overCapacity = 30;                                              // was 0 (test2)             
			f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	} 

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage7() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Rattlesnake Crescent";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map6_c";
		stage.m_mapInfo.m_id = "map6";

		stage.m_maxSoldiers = 15 * 6;                                             // was 17*7 in 1.65
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 7 (test4)
        stage.m_playerAiReduction = 2;                                            // was 3 (test2)
    	stage.addTracker(jupiter(m_metagame,30));
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 3; 
		stage.m_maxRandomCrates = 5;

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.15)); 
			f.m_overCapacity = 0;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.45, 0.2)); 
			f.m_overCapacity = 80;                                              
			f.m_capacityOffset = 50;
			f.m_capacityMultiplier = 1.0;
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	} 

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage8() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Vigil Island";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map8";
		stage.m_mapInfo.m_id = "map8";

		stage.m_includeLayers.insertLast("layer1.campaign");

		stage.addTracker(Overtime(m_metagame, 0));

		stage.m_maxSoldiers = 21 * 6;     // was 33 * 3 in 1.65
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         // was 4 (1.81)
		stage.m_playerAiReduction = 2;                                            // was 2 (1.81)   
		stage.m_soldierCapacityModel = "constant";

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 3;

		stage.m_defenseWinTime = 600.0;   // was 600 in 1.65
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.1));      // was  0.1 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.25, 0.05));             // was 0.2 0.1 in 1.65
			f.m_overCapacity = 50;
			f.m_capacityMultiplier = 1;                                                      // was 1.32 in 1.65, now working with offset only
			f.m_capacityOffset = 70;
			stage.m_factions.insertLast(f);
		}
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(2));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle","armored_truck.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}

		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Airfield";
		stage.m_radioObjectivePresent = false;

		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage9() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Black Gold Estuary";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map9";
		stage.m_mapInfo.m_id = "map9";

		stage.m_includeLayers.insertLast("layer1.invasion");

		stage.m_maxSoldiers = 17 * 13;                // 220 in 1.65
		stage.m_soldierCapacityVariance = 0.55;       // 0.4 in 1.65
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     // was 6 (test4)
		stage.m_playerAiReduction = 0;                                            // wasn't set in 1.65, thus 0

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.3));      // 0.2, 0.2 in 1.65
			f.m_overCapacity = 0;
			f.m_capacityMultiplier = 1.0;             // 0.9 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.5, 0.2));           // 0.45, 0.2 in 1.65
			f.m_overCapacity = 80;                                              // was 60 (test2) 
			f.m_capacityOffset = 5;                                                   // was 0 (test3)
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = true;


		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage10() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Railroad Gap";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map10";
		stage.m_mapInfo.m_id = "map10";

		stage.m_maxSoldiers = 13 * 12;                                            // 156, was 15*10 in 1.65
  
		stage.m_soldierCapacityVariance = 0.45;                                   // 0.4 in 1.65
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                     // was 5 (test4)
		stage.m_playerAiReduction = 0;                                            // was 1.5 (test3)

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.addTracker(jupiter(m_metagame));

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 3;
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.2));    // 0.1 0.2 in 1.65
			f.m_overCapacity = 0;                                                              // 0 in 1.65
			f.m_capacityOffset = 8;                                                            // was 5 (test3)
			f.m_capacityMultiplier = 1.0;                                                      // 0.9 in 1.65
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.5, 0.2));          // 0.6 0.2 in 1.65
			f.m_overCapacity = 70;                                              // was 50 (test2) 
			f.m_capacityOffset = 20; 
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;



		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}

	// ------------------------------------------------------------------------------------------------

	protected Stage@ setupStage11() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Iron Enclave";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map13";
		stage.m_mapInfo.m_id = "map13";

		stage.m_maxSoldiers = 15 * 15;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       // was 5 (test4)
		stage.m_playerAiReduction = 0;                                            // was 2.5 (test4) 

		stage.m_soldierCapacityVariance = 0.4; 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 2;
		array<int> FactionIndex = getRandomEnemyList();
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.2));
			f.m_overCapacity = 0;                                              // was 20
			f.m_bases = 1;
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1, 0.5, 0.2));
			f.m_overCapacity = 50;                                              // was 20 (test3)
            f.m_capacityOffset = 20;                                            // was 10 (test3)
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2, 0.5, 0.2));
			f.m_overCapacity = 50;                                              // was 20 (test3)
            f.m_capacityOffset = 20;                                            // was 10 (test3)
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3, 0.8, 0.2));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}



		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}
  
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage12() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Misty Heights";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map14";
		stage.m_mapInfo.m_id = "map14";

		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0; 

		stage.m_maxSoldiers = 11 * 13;
		stage.m_playerAiCompensation = 3 + m_playerAiCompensation_offset;                                       // was 5 (test4)
		stage.m_playerAiReduction = 0;                                            // was 2.5 (test4)
  
		stage.m_soldierCapacityVariance = 0.45;    // instead of 0.4 in 1.50  

//		stage.addTracker(Spawner(m_metagame, 1, Vector3(309,15,524), 10));        // 1st tow slot filler
//		stage.addTracker(Spawner(m_metagame, 1, Vector3(658,10,374), 10));        // vulcan slot filler

		stage.addTracker(PeacefulLastBase(m_metagame, 0));    
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;  

		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.2, 0.1));     // was 0.1, 0.1 (test3)
			f.m_overCapacity = 0;
			f.m_capacityOffset = 10;                                            // was 0 (test3)
			f.m_capacityMultiplier = 1;                                         // was 0.75 (test2)       
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.6, 0.25));
			f.m_overCapacity = 70;                                              // was 50 (test2)
			f.m_capacityOffset = 15; 
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer2.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}


		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}  
  
	// ------------------------------------------------------------------------------------------------

	protected Stage@ setupStage13() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Green Coast";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map16";
		stage.m_mapInfo.m_id = "map16";

		stage.m_maxSoldiers = 18 * 15;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       // was 4 (test4)
		stage.m_playerAiReduction = 2;                                            // was 1.5 (test3)

		stage.m_soldierCapacityVariance = 0.45;        // was 0.4

        stage.addTracker(AttackDefenseHandlerMap16(m_metagame, 0));   // we use this instead of peacefullastbase for map16
		stage.addTracker(CommsCapacityHandler(m_metagame));
		
		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 5;
		array<int> FactionIndex = getRandomEnemyList();

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.53, 0.3));   // was 0.45 0.3
			f.m_bases = 1;
			f.m_capacityMultiplier = 1.0;                                       // was 0.9 (test2)
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1, 0.6, 0.28));
			f.m_overCapacity = 80;                                              // was 40 (test2)
			f.m_capacityOffset = 10;         
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2, 0.65, 0.1));          
			f.m_overCapacity = 50;
			f.m_capacityOffset = 5;                                                             
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		} 

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	} 

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage14() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Rattlesnake Crescent (alt)";
		stage.m_mapInfo.m_path = "media/packages/vanilla.desert/maps/map6";
		stage.m_mapInfo.m_id = "map6_2";

		// we want to exclude some layers here, as the default ones are already used for the other map6
		int index = stage.m_includeLayers.find("layer1.default");
		if (index >= 0) {
		stage.m_includeLayers.removeAt(index);
		}
		index = stage.m_includeLayers.find("bases.default");
		if (index >= 0) {
		stage.m_includeLayers.removeAt(index);
		}


		stage.m_includeLayers.insertLast("layer1_2.default"); 
		stage.m_includeLayers.insertLast("bases_2.default"); 

		stage.m_maxSoldiers = 15 * 9;                                             
		stage.m_playerAiCompensation = 3 + m_playerAiCompensation_offset;                                       // was 7 (test4) 
        stage.m_playerAiReduction = 1;                                          // was 1.5 (test3)    

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.15));   
			f.m_overCapacity = 0;                                               
			f.m_capacityOffset = 5;                                             // was 0 (test3)
			f.m_capacityMultiplier = 1.0;                                          
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.48, 0.15));        
			f.m_overCapacity = 70;                                                
			f.m_capacityOffset = 15;                                            // was 0 (test2)                           
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radar_tank2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		} 

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	} 
    
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage15() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Moorland Apocalypse";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map1_2";
		stage.m_mapInfo.m_id = "map1_2";
        
		stage.m_includeLayers.insertLast("layer1.invasion");        

		stage.m_fogOffset = 15.0;    
		stage.m_fogRange = 70.0;          

			// we want to exclude some layers here
		int index = stage.m_includeLayers.find("layer1.default");
		if (index >= 0) {
		stage.m_includeLayers.removeAt(index);
		}
		index = stage.m_includeLayers.find("bases.default");
		if (index >= 0) {
		stage.m_includeLayers.removeAt(index);
		}


		stage.m_includeLayers.insertLast("layer1_2.default"); 
		stage.m_includeLayers.insertLast("bases_2.default"); 

		stage.m_maxSoldiers = 20 * 9;                                             
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       // was 5 (test4) 
        stage.m_playerAiReduction = 0;                                          // was 2 (test2)
        
		stage.m_soldierCapacityVariance = 0.45;                                                       

        stage.addTracker(AttackDefenseHandlerMap1_2(m_metagame, 0));   // we use this instead of peacefullastbase for map1_2
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 4; 
		stage.m_maxRandomCrates = 6;
		array<int> FactionIndex = getRandomEnemyList();
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.15));   
			f.m_overCapacity = 0;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;                                          
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[FactionIndex[0]], createCommanderAiCommand(1, 0.58, 0.15));        
			f.m_overCapacity = 40;                                                
			f.m_capacityOffset = 0;                                            
			stage.m_factions.insertLast(f);
		}
		{
// attack score is taken from the map1_2 attack handler script, if bases => 11    
			Faction f(getFactionConfigs()[FactionIndex[1]], createCommanderAiCommand(2, 0.70, 0.1));          
			f.m_overCapacity = 50;
			f.m_capacityOffset = 30;                                                             
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}        

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"vulcan_tank.vehicle", "radar_tank2.vehicle", "radio_jammer2.vehicle", "apc.vehicle", "apc_1.vehicle", "apc_2.vehicle", "guntruck.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		} 
        
		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}     

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage16() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Tropical Blizzard";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map8_2";
		stage.m_mapInfo.m_id = "map8_2";


		stage.m_maxSoldiers = 12 * 11;                                         // 132
		stage.m_soldierCapacityVariance = 0.6;                              

		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                         
        stage.m_playerAiReduction = 2;                                       // was 1.5 (test5)        
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.1));     
			f.m_overCapacity = 0;                                                              
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;                                          
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.65, 0.1));            // was 0.7 0.1
			f.m_overCapacity = 50;                                                
			f.m_capacityOffset = 0;                                            
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;


		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radar_tank2.vehicle", "wiesel_tow.vehicle", "cargo_helicopter_broken.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		} 

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	} 
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage17() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Gotcha Island";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map17";
		stage.m_mapInfo.m_id = "map17";

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 11 * 12;                                          // was 11*10

		stage.m_soldierCapacityVariance = 0.55;                                  // was 0.4
		stage.m_playerAiCompensation = 3 + m_playerAiCompensation_offset;                                       // was 4
        stage.m_playerAiReduction = 2;                                        // was 2    

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.14));      // was 0.62, 0.14 (default values)                                            
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.60, 0.14));             // was 0.0.62, 0.14 (test 6)
			f.m_overCapacity = 60;                                             // was 30
            f.m_capacityOffset = 15;                                            // was 5
			stage.m_factions.insertLast(f);                                    
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"m113_tank_acav.vehicle", "radio_jammer.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		// setReduceDefenseForFinalAttack(stage, 0.1); // use this for final attack boost if needed for friendlies
		
		return stage;
	}
	
	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage18() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Holy Enclave";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map13_2";
		stage.m_mapInfo.m_id = "map13_2";
		stage.m_includeLayers.insertLast("layer1.invasion");
		stage.m_includeLayers.insertLast("layer1.dominance");        
		stage.addTracker(Overtime(m_metagame, 0));
		stage.m_maxSoldiers = 10 * 3;
		stage.m_playerAiCompensation = 0;
		stage.m_playerAiReduction = 0;
		stage.m_soldierCapacityModel = "constant";       		
		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 5;
		stage.m_defenseWinTime = 600; 
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
		
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.3));     
			f.m_capacityMultiplier = 0.4;                                               
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.2, 0.05));          // was 0.38 0.1 (1.82)  
			f.m_overCapacity = 50;                                              
			f.m_capacityOffset = 30;                                                             
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.2, 0.05));          // was 0.38 0.1 (1.82)  
            f.m_overCapacity = 50;                                              
			f.m_capacityOffset = 30;                                                             
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3, 0.2, 0.05));          // was 0.38 0.1 (1.82)  
            f.m_overCapacity = 50;                                              
			f.m_capacityOffset = 30;                                                             
			stage.m_factions.insertLast(f);
		}		
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Dry Enclave";

		
		return stage;
	} 	

	protected Stage@ setupStage19() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Warsalt Legacy";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map18";
		stage.m_mapInfo.m_id = "map18";
		stage.addTracker(jupiter(m_metagame,30));
		stage.m_includeLayers.insertLast("layer1.invasion");		

		stage.m_maxSoldiers = 16 * 5;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       
        stage.m_playerAiReduction = 1;                                            

		stage.addTracker(PeacefulLastBase(m_metagame, 0));    
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;  

		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.6, 0.2));   // was 0.3 0.1  
			f.m_overCapacity = 50;
			f.m_capacityOffset = 50;      // was 5                                       
			f.m_capacityMultiplier = 1.0;                                               
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 0.5, 0.2));   // was 0.6 0.2
			f.m_overCapacity = 100;      // was 70                                       
			f.m_capacityOffset = 30;     // was 15
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer2.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}


		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}  

	protected Stage@ setupStage20() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Swan River";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map19";
		stage.m_mapInfo.m_id = "map19";
		
		stage.m_includeLayers.insertLast("layer1.invasion");		

		stage.m_fogOffset = 24.0;    
		stage.m_fogRange = 50.0; 

		stage.m_maxSoldiers = 19 * 15;
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       
        stage.m_playerAiReduction = 2.0;                                            
  
		stage.m_soldierCapacityVariance = 0.6;   

		stage.addTracker(PeacefulLastBase(m_metagame, 0));    
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 4;  

		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.1));   
			f.m_overCapacity = 0;
			f.m_capacityOffset = 10;     // was 12                                        
			f.m_capacityMultiplier = 1;                                               
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.60, 0.15));  // was 0.62 0.15  
			f.m_overCapacity = 120;                                          
			f.m_capacityOffset = 10;      // was 0
			stage.m_factions.insertLast(f);
		}
		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha.call", "sf_mecha_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_mecha_inf.call", "sf_mecha_inf_sub.call", array<string> = {""}, false,false,false,"infantry"));

			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon1.call", "kcco_zircon1_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_dog.call", "kcco_dog_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_quartz.call", "kcco_quartz_sub.call", array<string> = {""}, false,false,false,"infantry"));		
			
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,false,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,false,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_deploy_uhlan.call", "para_deploy_uhlan_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}
		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radio_jammer2.vehicle", "radar_tower.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}

		setDefaultAttackBreakTimes(stage);
		
		return stage;
	}   
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	// FINAL STAGES
	// ------------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------------
	// --------------------------------------------
	protected Stage@ setupFinalStage1() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Final mission I"; // warning, default.character has reference to this name, careful if it needs to be changed
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map11";
		stage.m_mapInfo.m_id = "map11";
        
		stage.m_includeLayers.insertLast("layer1.invasion");        

		stage.m_maxSoldiers = 110;   // 100 in 0.99.4

		stage.m_playerAiCompensation = 5;                                       // was 3 (test2)
		stage.m_playerAiReduction = 0;                                              

		stage.m_minRandomCrates = 1; 
		stage.m_maxRandomCrates = 3;

		stage.m_finalBattle = true;
		stage.m_hidden = true;

		stage.addTracker(DestroyVehicleToCaptureBase(m_metagame, "radio_jammer.vehicle", 2));
		stage.addTracker(DestroyVehicleToCaptureBase(m_metagame, "radar_tower.vehicle", 2));    

		{
			XmlElement command("command");
			command.setStringAttribute("class", "set_match_status");
			command.setIntAttribute("faction_id", 2);
			command.setBoolAttribute("lose", true);
			// can't use m_extraCommands, they happen before match start, using trackers instead then
			stage.addTracker(RunAtStart(m_metagame, command));     
		}

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.0, 0.0, false));
			f.m_overCapacity = 2;
			f.m_capacityMultiplier = 0.0001; // have at least a little capacity, otherwise is marked as neutral
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			// in adventure mode, this faction config will be replaced with the correct one when final battle 1 opponent is decided 
			Faction f(getFactionConfigs()[getRandomEnemyIndex()], createCommanderAiCommand(1, 1.0, 0.0, false));
			stage.m_factions.insertLast(f); 
		}
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"mobile_armory.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
		
		// no calls for friendly faction in the last map
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			command.setBoolAttribute("clear_calls", true);
			stage.m_extraCommands.insertLast(command);
		}

		// metadata
		stage.m_primaryObjective = "final1";

		
		return stage;
	}

	// --------------------------------------------
	protected Stage@ setupFinalStage2() {
		PhasedStage@ stage = createPhasedStage();
		stage.setPhaseController(PhaseControllerMap12(m_metagame));
		stage.m_mapInfo.m_name = "Final mission II"; // warning, default.character has reference to this name, careful if it needs to be changed
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps/map12";
		stage.m_mapInfo.m_id = "map12";

		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0; 

		stage.m_maxSoldiers = 100;                                               // was 80 in 1.70
		stage.m_playerAiCompensation = 2 + m_playerAiCompensation_offset;                                       // was 5 (test4)
		stage.m_playerAiReduction = 0;                                              // wasn't set in 1.65, thus 0
		
		stage.m_minRandomCrates = 0; 
		stage.m_maxRandomCrates = 1;

		stage.m_finalBattle = true;
		stage.m_hidden = true;

		// set all defend initially, the phases will control it once things start moving
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 1.0, 0.0));
			f.m_capacityMultiplier = 0.4;
			stage.m_factions.insertLast(f);
		}
		{
			// in adventure mode, this faction config will be replaced with the correct one when final battle 1 opponent is decided 
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1, 1.0, 0.0));
			f.m_loseWithoutBases = false;
			stage.m_factions.insertLast(f); 
		}
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3));
			f.m_capacityMultiplier = 0.0;
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "final2";

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle", "radar_tower.vehicle"}, false);
			stage.m_extraCommands.insertLast(command);
		}

		
		stage.m_allowChangeCapacityOnTheFly = false;

		
		return stage;
	}

	// --------------------------------------------
	protected void setupWorld() {
		// World disabled in Invasion for now, map10 elements are missing
		//$this->world = new World($this->metagame);
	}

	// --------------------------------------------
	array<XmlElement@>@ getFactionResourceConfigChangeCommands(float completionPercentage, Stage@ stage) {
		array<XmlElement@>@ commands = getFactionResourceChangeCommands(stage.m_factions.size());

		merge(commands, stage.m_extraCommands);

		return commands;
	}

	// --------------------------------------------
	protected array<XmlElement@>@ getFactionResourceChangeCommands(int factionCount) const {
		array<XmlElement@> commands;

		// invasion faction resources are nowadays based on resources declared for factions in the faction files 
		// + some minor changes for common and friendly
		for (int i = 0; i < factionCount; ++i) {
			commands.insertLast(getFactionResourceChangeCommand(i, getCommonFactionResourceChanges()));
		}

		// apply initial friendly faction resource modifications
		commands.insertLast(getFactionResourceChangeCommand(0, getFriendlyFactionResourceChanges()));

		return commands;
	}

	// --------------------------------------------
	protected array<ResourceChange@>@ getCommonFactionResourceChanges() const {
		array<ResourceChange@> list;
	
		list.push_back(ResourceChange(Resource("armored_truck.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("mobile_armory.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("a10_gun_run.call", "call"), true));
		list.push_back(ResourceChange(Resource("gunship_run.call", "call"), true));        

		// disable certain weapons here; mainly because Dominance uses the same .resources files but we have further changes for Invasion here
		list.push_back(ResourceChange(Resource("l85a2.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("famasg1.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("sg552.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("minig_resource.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("tow_resource.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("gl_resource.weapon", "weapon"), false));
		list.push_back(ResourceChange(Resource("hornet_resource.weapon", "weapon"), false));
		
		return list;
	}

	// --------------------------------------------
	protected array<ResourceChange@> getFriendlyFactionResourceChanges() const {
		array<ResourceChange@> list;

		// enable mobile spawn and armory trucks for player faction
		list.push_back(ResourceChange(Resource("armored_truck.vehicle", "vehicle"), true));
		list.push_back(ResourceChange(Resource("mobile_armory.vehicle", "vehicle"), true));

		// no cargo, prisons or aa
		list.push_back(ResourceChange(Resource("cargo_truck.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("prison_door.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("prison_bus.vehicle", "vehicle"), false));
		list.push_back(ResourceChange(Resource("prison_hatch.vehicle", "vehicle"), false));    
		list.push_back(ResourceChange(Resource("aa_emplacement.vehicle", "vehicle"), false));

		return list;
	}

	// --------------------------------------------
	protected array<XmlElement@>@ getCompletionVarianceCommands(Stage@ stage, float completionPercentage) {
		// we want to have a sense of progression 
		// with the starting map vs other maps played before extra final maps

		array<XmlElement@> commands;

		if (stage.isFinalBattle()) {
			// don't use for final battles
			return commands;
		}

		if (completionPercentage < 0.08) {
			_log("below 10%");
			for (uint i = 0; i < stage.m_factions.size(); ++i) {
				// disable comms truck, cargo and radio tower on all factions, same for prisons
				array<string> keys = {
					"radar_truck.vehicle", 
					"cargo_truck.vehicle", 
					"radar_tower.vehicle", 
					"prison_bus.vehicle", 
					"prison_door.vehicle", 
					"aa_emplacement.vehicle",
                    "m113_tank_mortar.vehicle" };

				if (i == 0) {
					// let friendlies have the tank, need it to make a successful tank call
				} else {
					// disable tanks for enemy factions
					keys.insertLast("tank.vehicle");
					keys.insertLast("tank_1.vehicle");
					keys.insertLast("tank_2.vehicle");
				}

				if (keys.size() > 0) {
					XmlElement command("command"); 
					command.setStringAttribute("class", "faction_resources"); 
					command.setIntAttribute("faction_id", i);
					addFactionResourceElements(command, "vehicle", keys, false);

					commands.insertLast(command);
				}
			}
			// a bit odd that we change stage members here in a getter function, but just do it for now, it's just metadata
			stage.m_radioObjectivePresent = false;

		} else if (completionPercentage < 0.20) {
			_log("below 25%, above 10%");
			for (uint i = 0; i < stage.m_factions.size(); ++i) {
				array<string> keys;

				if (i == 0) {
					// disable comms truck and radio tower on friendly faction only
					keys.insertLast("radar_truck.vehicle");
					keys.insertLast("radar_tower.vehicle");

					// cargo & prisons are disabled anyway for friendly faction
				} else {
				}

				if (keys.size() > 0) {
					XmlElement command("command"); 
					command.setStringAttribute("class", "faction_resources"); 
					command.setIntAttribute("faction_id", i);
					addFactionResourceElements(command, "vehicle", keys, false);

					commands.insertLast(command);
				}
			}
		}

		return commands;
	}

	protected int getRandomEnemyIndex(){
		// 玩家faction固定为0，中立阵营固定为index最后一位，在StartUp过程中maprotater已经排列好了随机阵营，我们只需要直接引用即可。
		int index = rand(1, getFactionConfigs().size()-2);
		return index;
	}

	protected array<int> getRandomEnemyList(){
		// 掐头去尾 建立一个数组后随机排序输出打乱的数组
		array<int> CopyedFactionList;
		array<int> FactionList;
		for (uint i = 1; i < (getFactionConfigs().size()-1); i++){
			CopyedFactionList.insertLast(i);
		}
		while (CopyedFactionList.size()>0){
			int index = rand(0,CopyedFactionList.size()-1);
			FactionList.insertLast(CopyedFactionList[index]);
			CopyedFactionList.removeAt(index);
		}

		return FactionList;
	}
}
