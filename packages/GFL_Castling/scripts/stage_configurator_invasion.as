// gamemode specific
#include "faction_config.as"
#include "stage_configurator.as"
#include "stage_invasion.as"
#include "phase_controller_map12.as"
#include "pausing_koth_timer.as"
#include "spawn_at_node.as"
#include "comms_capacity_handler.as"
#include "attack_defense_handler_map16.as"
#include "attack_defense_handler_map1_2.as"
#include "run_at_start.as"

// ------------------------------------------------------------------------------------------------
class StageConfiguratorInvasion : StageConfigurator {
	protected GameModeInvasion@ m_metagame;
	protected MapRotatorInvasion@ m_mapRotator;
	protected int m_stagesAdded;

	// ------------------------------------------------------------------------------------------------
	StageConfiguratorInvasion(GameModeInvasion@ metagame, MapRotatorInvasion@ mapRotator) {
		@m_metagame = @metagame;
		@m_mapRotator = mapRotator;
		mapRotator.setConfigurator(this);
		m_stagesAdded = 0;
	}

	// ------------------------------------------------------------------------------------------------
	void setup() {
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

	// ------------------------------------------------------------------------------------------------
	protected void addRandomSpecialCrates(Stage@ stage, int minCount, int maxCount) {
		array<ScoredResource@> resources = {
			ScoredResource("special_crate1.vehicle", "vehicle", 100.0f),           // m4
			ScoredResource("special_crate2.vehicle", "vehicle", 80.0f),           // p90
			ScoredResource("special_crate3.vehicle", "vehicle", 80.0f),           // aks
			ScoredResource("special_crate4.vehicle", "vehicle", 80.0f),           // Stoner
			ScoredResource("special_crate5.vehicle", "vehicle", 80.0f),           // neo
			ScoredResource("special_crate6.vehicle", "vehicle", 70.0f),           // aa12
			ScoredResource("special_crate7.vehicle", "vehicle", 40.0f),           // chain
			ScoredResource("special_crate8.vehicle", "vehicle", 40.0f),           // m107
			ScoredResource("special_crate9.vehicle", "vehicle", 50.0f),           // apr
			ScoredResource("special_crate10.vehicle", "vehicle", 30.0f),          // ares
			ScoredResource("special_crate11.vehicle", "vehicle", 30.0f),          // kriss
			ScoredResource("special_crate12.vehicle", "vehicle", 40.0f),          // m712
			ScoredResource("special_crate13.vehicle", "vehicle", 40.0f),          // jack
			ScoredResource("special_crate14.vehicle", "vehicle", 10.0f),          // m60
			ScoredResource("special_crate15.vehicle", "vehicle", 30.0f),          // paw
			ScoredResource("special_crate16.vehicle", "vehicle", 5.0f),          // honey
			ScoredResource("special_crate17.vehicle", "vehicle", 10.0f),          // flame
			ScoredResource("special_crate18.vehicle", "vehicle", 1.0f),          // milk
			ScoredResource("special_crate19.vehicle", "vehicle", 1.0f),          // l39
			ScoredResource("special_crate20.vehicle", "vehicle", 1.0f),           // mg42
			ScoredResource("special_crate31.vehicle", "vehicle", 3.0f),          // cb2
			ScoredResource("special_crate32.vehicle", "vehicle", 5.0f),          // stoner62
			ScoredResource("special_crate33.vehicle", "vehicle", 40.0f),          // camo_vest
			ScoredResource("special_crate34.vehicle", "vehicle", 30.0f),          // deagle
			ScoredResource("special_crate35.vehicle", "vehicle", 100.0f),          // banana peel
			ScoredResource("special_crate36.vehicle", "vehicle", 15.0f),          // mp7
			ScoredResource("special_crate37.vehicle", "vehicle", 60.0f),          // goldbar
			ScoredResource("special_crate38.vehicle", "vehicle", 50.0f),          // medikit
			ScoredResource("special_crate39.vehicle", "vehicle", 100.0f),          // resmini
			ScoredResource("special_crate41.vehicle", "vehicle", 5.0f),           // cb3 
			ScoredResource("special_crate42.vehicle", "vehicle", 4.0f)           // cb4 
                             
      
		};
		int count = rand(minCount, maxCount);
		stage.addTracker(SpawnAtNode(m_metagame, resources, "random_crate", 0, count));
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addFixedSpecialCrates(Stage@ stage) {
		array<ScoredResource@> resources = {
			ScoredResource("special_crate21.vehicle", "vehicle", 50.0f),          // xm25
			ScoredResource("special_crate22.vehicle", "vehicle", 50.0f),          // musket
			ScoredResource("special_crate23.vehicle", "vehicle", 40.0f),          // aafrag
			ScoredResource("special_crate24.vehicle", "vehicle", 30.0f),          // Deagle
			ScoredResource("special_crate25.vehicle", "vehicle", 100.0f),          // gb1
			ScoredResource("special_crate26.vehicle", "vehicle", 30.0f),          // gb2
			ScoredResource("special_crate27.vehicle", "vehicle", 10.0f),          // gb3
			ScoredResource("special_crate28.vehicle", "vehicle", 5.0f),          // cb1
			ScoredResource("special_crate29.vehicle", "vehicle", 100.0f),          // resmini
			ScoredResource("special_crate30.vehicle", "vehicle", 100.0f),           // resgl
      ScoredResource("special_crate35.vehicle", "vehicle", 100.0f),          // banana peel
      ScoredResource("special_crate19.vehicle", "vehicle", 5.0f),          // l39
      ScoredResource("special_crate32.vehicle", "vehicle", 5.0f)          // stoner62
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "fixed_crate", 0, 1000));
	}
	
	// ------------------------------------------------------------------------------------------------
	protected void addLotteryVehicle(Stage@ stage) {
		array<ScoredResource@> resources = {
			// for testing: 0 score no spawn -> 100% chance for icecream
			//ScoredResource("", "", 0.0f),          
			ScoredResource("", "", 85.0f),
			ScoredResource("icecream.vehicle", "vehicle", 15.0f)
		};
		stage.addTracker(SpawnAtNode(m_metagame, resources, "icecream", 0, 1));
	}
	
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
	addStage(setupStage101());        // mapnana
	addStage(setupStage7());          // map6
	addStage(setupStage1());          // map2
    addStage(setupStage9());          // map9
    // addStage(setupStage16());         // map8_2
    addStage(setupStage4());          // map7
    addStage(setupStage15());         // map1_2
    addStage(setupStage12());         // map14
    addStage(setupStage10());         // map10
    addStage(setupStage17());         // map17    
    addStage(setupStage18());         // map13_2
    addStage(setupStage3());          // map3
    addStage(setupStage13());         // map16    
	addStage(setupFinalStage1());     // map11
    addStage(setupStage8());          // map8
 	addStage(setupStage14());         // map6_2
    addStage(setupStage2());          // map4
    addStage(setupStage5());          // map1
    addStage(setupStage6());          // map5
    addStage(setupFinalStage2());     // map12
    addStage(setupStage11());         // map13
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
	protected Stage@ setupStage101() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Uprising";
		stage.m_mapInfo.m_path = "media/packages/GFL_Castling/maps";
		stage.m_mapInfo.m_id = "map101";
		
		stage.m_includeLayers.insertLast("layer1.invasion"); 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 14 * 10;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.4;
		stage.m_playerAiCompensation = 4.5;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 0;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1));
			f.m_overCapacity = 60;                                               
			f.m_capacityOffset = 8;                                                 
			stage.m_factions.insertLast(f);                                         
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map2";
		stage.m_mapInfo.m_id = "map2";
		
		stage.m_includeLayers.insertLast("layer1.invasion"); 


		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 12 * 8;                                             // was 12*7 in 1.65, 1 base added

		stage.m_soldierCapacityVariance = 0.3;
		stage.m_playerAiCompensation = 4.5;                                         // was 4 (1.82)
        stage.m_playerAiReduction = 0;                                          // was 2 (test3)    

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 4;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));                                                  
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1));
			f.m_overCapacity = 40;                                               // was 30 (test2)
      f.m_capacityOffset = 8;                                                 // was 5 (1.81)
			stage.m_factions.insertLast(f);                                         // was 0 in 1.65
		}
		
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"noxe.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}        

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		// setReduceDefenseForFinalAttack(stage, 0.1); // use this for final attack boost if needed for friendlies
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage2() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Fridge Valley";
		stage.m_mapInfo.m_path = "media/packages/vanilla.winter/maps/map4";
		stage.m_mapInfo.m_id = "map4";

		stage.m_fogOffset = 20.0;    
		stage.m_fogRange = 50.0;     

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 17 * 6;
		stage.m_playerAiCompensation = 4;                                         // was 5 (test4)
		stage.m_playerAiReduction = 0;                                            // was 2 (test3)

		stage.m_minRandomCrates = 2; 
		stage.m_maxRandomCrates = 3;    

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1));
			f.m_overCapacity = 40;                                              // was 30 (test2)
			f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f); 
		}

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage3() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Old Fort Creek";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map3";
		stage.m_mapInfo.m_id = "map3";

		stage.m_includeLayers.insertLast("layer1.invasion");

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 14 * 8;
		stage.m_playerAiCompensation = 5;                                         // was 6 (test4)
    stage.m_playerAiReduction = 0;                                              // was 2.5 (test4)   

		stage.m_soldierCapacityVariance = 0.4;                                   // was 0.31 in 1.65

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 3;    

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0));
			f.m_capacityOffset = 0; 
			f.m_overCapacity = 0;
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1));
			f.m_overCapacity = 40;                                              // was 30 (test2)
      f.m_capacityOffset = 5;                                                 // was 0 in 1.65 
			stage.m_factions.insertLast(f); 
		}
        

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"flamer_tank.vehicle"}, false);

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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map7";
		stage.m_mapInfo.m_id = "map7";

		stage.m_includeLayers.insertLast("layer1.invasion");        

		stage.addTracker(Overtime(m_metagame, 0));
//		stage.addTracker(Spawner(m_metagame, 1, Vector3(477,0,520)));
//		stage.addTracker(Spawner(m_metagame, 1, Vector3(455,0,508)));
//		stage.addTracker(Spawner(m_metagame, 1, Vector3(446,0,539)));

		stage.m_maxSoldiers = 30 * 3;                                             // was 28*3 in 1.75
		stage.m_playerAiCompensation = 4;                                         // was 5 (test4)
    stage.m_playerAiReduction = 0;                                            // was 3 (test4)  
    stage.m_soldierCapacityModel = "constant";                                // was set to default in 1.65
    
    stage.m_minRandomCrates = 0; 
    stage.m_maxRandomCrates = 0;
         
		stage.m_defenseWinTime = 600;     // was 400 in 1.65 old koth mode
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
	
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.1));     // was 0.1, 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.38, 0.1));           // was 0.1, 0.1 in 1.65
			f.m_overCapacity = 20;                                              // was 0 (test2)
      f.m_capacityOffset = 5;                                                             // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.38, 0.1));           // was 0.1, 0.1 in 1.65
            f.m_overCapacity = 20;                                              // was 0 (test2)
      f.m_capacityOffset = 5;                                                             // was 0 in 1.65
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
		stage.m_playerAiCompensation = 3;                                     // was 4 (test4)     
    stage.m_playerAiReduction = 0;                                            // was 1 (test3)    

		stage.m_soldierCapacityVariance = 0.4; // map1 is a big map; using high variance helps keep the attack group not growing super large when more bases are captured

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
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1));
			f.m_overCapacity = 60;                                                  // was 50 (test2)   
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2));
			f.m_overCapacity = 60;                                                  // was 50 (test2)      
			stage.m_factions.insertLast(f);
		}

		// aa emplacements work right only if one enemy faction has them
		// - all factions have it disabled by default
		// - manually enable it for faction #1 in map1 
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}

		// metadata
		stage.m_primaryObjective = "capture";

		setDefaultAttackBreakTimes(stage);
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage6() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Bootleg Islands";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map5";
		stage.m_mapInfo.m_id = "map5";

		stage.m_maxSoldiers = 11 * 10;
		stage.m_playerAiCompensation = 4;                                       // was 5 (test4)
    stage.m_playerAiReduction = 0;                                              // was 2 (test3)

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 4;

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
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2));
			f.m_overCapacity = 30;                                              // was 0 (test2)            
      f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1));
			f.m_overCapacity = 30;                                              // was 0 (test2)             
      f.m_capacityOffset = 5;                                                // was 0 in 1.65
			stage.m_factions.insertLast(f);
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map6";
		stage.m_mapInfo.m_id = "map6";

		stage.m_maxSoldiers = 15 * 9;                                             // was 17*7 in 1.65
		stage.m_playerAiCompensation = 5;                                         // was 7 (test4)
        stage.m_playerAiReduction = 0;                                            // was 3 (test2)
    
    stage.addTracker(Spawner(m_metagame, 1, Vector3(485,5,705), 10, "default_ai"));        // outpost filler (1.70)

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 3;

		{
			// greens will push a bit harder here
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.15));   // was 0.3, 0.12 in 1.65
			f.m_overCapacity = 0;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;                                          // was 0.9 in 1.65
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1, 0.45, 0.2));        // was not set (default) in 1.65
			f.m_overCapacity = 80;                                              // was 60 (test2) 
			f.m_capacityOffset = 15;                                               // was 10 in 1.65
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}

		setDefaultAttackBreakTimes(stage);
		return stage;
	} 

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage8() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Vigil Island";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map8";
		stage.m_mapInfo.m_id = "map8";

		stage.m_includeLayers.insertLast("layer1.invasion"); 

		stage.addTracker(Overtime(m_metagame, 0));
		stage.addTracker(Spawner(m_metagame, 1, Vector3(255,0,344),20, "default_ai"));          // added 15 in 1.65, less over_capacity to compensate


		stage.m_maxSoldiers = 21 * 5;     // was 33 * 3 in 1.65
		stage.m_playerAiCompensation = 5;                                         // was 4 (1.81)
    stage.m_playerAiReduction = 0;                                            // was 2 (1.81)   
		stage.m_soldierCapacityModel = "constant";

    stage.m_minRandomCrates = 1; 
    stage.m_maxRandomCrates = 2;

		stage.m_defenseWinTime = 720.0;   // was 600 in 1.65
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.3, 0.1));      // was  0.1 0.1 in 1.65
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.25, 0.05));             // was 0.2 0.1 in 1.65
			f.m_overCapacity = 60;
			f.m_capacityMultiplier = 0.0001;                                                      // was 1.32 in 1.65, now working with offset only
			f.m_capacityOffset = 60;
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
			addFactionResourceElements(command, "vehicle", array<string> = {"radio_jammer.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map9";
		stage.m_mapInfo.m_id = "map9";

		stage.m_includeLayers.insertLast("layer1.invasion");

		stage.m_maxSoldiers = 17 * 13;                // 220 in 1.65
		stage.m_soldierCapacityVariance = 0.55;       // 0.4 in 1.65
		stage.m_playerAiCompensation = 4;                                     // was 6 (test4)
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
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1, 0.5, 0.2));           // 0.45, 0.2 in 1.65
			f.m_overCapacity = 80;                                              // was 60 (test2) 
      f.m_capacityOffset = 5;                                                   // was 0 (test3)
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = true;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"sev90.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}         

		setDefaultAttackBreakTimes(stage);
		return stage;
	}

	// ------------------------------------------------------------------------------------------------
	protected Stage@ setupStage10() {
		Stage@ stage = createStage();
		stage.m_mapInfo.m_name = "Railroad Gap";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map10";
		stage.m_mapInfo.m_id = "map10";

		stage.m_maxSoldiers = 13 * 12;                                            // 156, was 15*10 in 1.65
  
		stage.m_soldierCapacityVariance = 0.45;                                   // 0.4 in 1.65
		stage.m_playerAiCompensation = 4;                                     // was 5 (test4)
    stage.m_playerAiReduction = 0;                                            // was 1.5 (test3)

		stage.addTracker(Spawner(m_metagame, 1, Vector3(309,15,524), 10, "default_ai"));        // 1st tow slot filler
		stage.addTracker(Spawner(m_metagame, 1, Vector3(658,10,374), 10, "default_ai"));        // vulcan slot filler

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 3;
// faction 0 had 2 bases to start with (a dummy one), now only 1
		{ 				
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.4, 0.2));    // 0.1 0.2 in 1.65
			f.m_overCapacity = 0;                                                              // 0 in 1.65
			f.m_capacityOffset = 8;                                                            // was 5 (test3)
			f.m_capacityMultiplier = 1.0;                                                      // 0.9 in 1.65
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1, 0.5, 0.2));          // 0.6 0.2 in 1.65
			f.m_overCapacity = 70;                                              // was 50 (test2) 
			f.m_capacityOffset = 20; 
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}

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
		stage.m_playerAiCompensation = 4;                                       // was 5 (test4)
    stage.m_playerAiReduction = 0;                                            // was 2.5 (test4) 

		stage.m_soldierCapacityVariance = 0.4; 

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 1; 
    stage.m_maxRandomCrates = 2;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.2));
			f.m_overCapacity = 0;                                              // was 20
			f.m_bases = 1;
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.5, 0.2));
			f.m_overCapacity = 40;                                              // was 20 (test3)
            f.m_capacityOffset = 20;                                            // was 10 (test3)
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.5, 0.2));
			f.m_overCapacity = 40;                                              // was 20 (test3)
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

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map14";
		stage.m_mapInfo.m_id = "map14";

    stage.m_fogOffset = 20.0;    
    stage.m_fogRange = 50.0; 

		stage.m_maxSoldiers = 11 * 13;
		stage.m_playerAiCompensation = 4;                                       // was 5 (test4)
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
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.25));
			f.m_overCapacity = 70;                                              // was 50 (test2)
			f.m_capacityOffset = 15; 
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map16";
		stage.m_mapInfo.m_id = "map16";

		stage.m_maxSoldiers = 18 * 13;
		stage.m_playerAiCompensation = 3;                                       // was 4 (test4)
    stage.m_playerAiReduction = 0;                                            // was 1.5 (test3)

		stage.m_soldierCapacityVariance = 0.45;        // was 0.4

//		stage.addTracker(PeacefulLastBase(m_metagame, 0));
        stage.addTracker(AttackDefenseHandlerMap16(m_metagame, 0));   // we use this instead of peacefullastbase for map16
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 5;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.53, 0.3));   // was 0.45 0.3
			f.m_overCapacity = 5;                                               // was 0 (test3)
			f.m_bases = 1;
			f.m_capacityMultiplier = 1.0;                                       // was 0.9 (test2)
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.6, 0.28));
			f.m_overCapacity = 80;                                              // was 40 (test2)
			f.m_capacityOffset = 10;         
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
// attack score is taken from the map16 attack handler script, if bases => 5    
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.65, 0.1));          
			f.m_overCapacity = 40;
			f.m_capacityOffset = 5;                                                             
			f.m_capacityMultiplier = 1.0; 
			stage.m_factions.insertLast(f);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"vulcan_tank.vehicle", "radar_tank2.vehicle", "radio_jammer2.vehicle", "apc.vehicle", "apc_1.vehicle", "apc_2.vehicle"}, false);

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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map6";
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
		stage.m_playerAiCompensation = 5;                                       // was 7 (test4) 
        stage.m_playerAiReduction = 0;                                          // was 1.5 (test3)    

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
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(1, 0.48, 0.15));        
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
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map1_2";
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
		stage.m_playerAiCompensation = 4;                                       // was 5 (test4) 
        stage.m_playerAiReduction = 0;                                          // was 2 (test2)
        
		stage.m_soldierCapacityVariance = 0.45;                                                       

//		stage.addTracker(PeacefulLastBase(m_metagame, 0));
        stage.addTracker(AttackDefenseHandlerMap1_2(m_metagame, 0));   // we use this instead of peacefullastbase for map1_2
		stage.addTracker(CommsCapacityHandler(m_metagame));

    stage.m_minRandomCrates = 2; 
    stage.m_maxRandomCrates = 3;

		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.5, 0.15));   
			f.m_overCapacity = 0;
			f.m_capacityOffset = 0; 
			f.m_capacityMultiplier = 1.0;                                          
			f.m_bases = 1;
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.58, 0.15));        
			f.m_overCapacity = 40;                                                
			f.m_capacityOffset = 0;                                            
			stage.m_factions.insertLast(f);
		}
		{
// attack score is taken from the map1_2 attack handler script, if bases => 11    
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.70, 0.1));          
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
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
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
		stage.m_mapInfo.m_path = "media/packages/vanilla.winter/maps/map8_2";
		stage.m_mapInfo.m_id = "map8_2";

    stage.m_fogOffset = 10.0;    
    stage.m_fogRange = 40.0;


		stage.m_maxSoldiers = 12 * 11;                                         // 132
		stage.m_soldierCapacityVariance = 0.6;                              

		stage.m_playerAiCompensation = 4;                                         
        stage.m_playerAiReduction = 0;                                       // was 1.5 (test5)        
		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));

		stage.addTracker(Spawner(m_metagame, 1, Vector3(146,10,173), 2, "miniboss"));           // Cargo helicopter filler 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(146,10,173), 10, "default_ai"));        // Cargo helicopter filler                  

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
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.65, 0.1));            // was 0.7 0.1
			f.m_overCapacity = 50;                                                
			f.m_capacityOffset = 0;                                            
			stage.m_factions.insertLast(f);
		}

		// metadata
		stage.m_primaryObjective = "capture";
		stage.m_radioObjectivePresent = false;

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}
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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map17";
		stage.m_mapInfo.m_id = "map17";

		stage.addTracker(PeacefulLastBase(m_metagame, 0));
		stage.addTracker(CommsCapacityHandler(m_metagame));
		stage.m_maxSoldiers = 11 * 12;                                          // was 11*10

		stage.m_soldierCapacityVariance = 0.55;                                  // was 0.4
		stage.m_playerAiCompensation = 4;                                       // was 4
        stage.m_playerAiReduction = 0;                                        // was 2    

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
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.60, 0.14));             // was 0.0.62, 0.14 (test 6)
			f.m_overCapacity = 60;                                             // was 30
            f.m_capacityOffset = 5;                                            // was 5
			stage.m_factions.insertLast(f);                                    
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
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
		stage.m_mapInfo.m_name = "Dry Enclave";
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map13_2";
		stage.m_mapInfo.m_id = "map13_2";

		stage.m_includeLayers.insertLast("layer1.invasion");        

		stage.addTracker(Overtime(m_metagame, 0));

		stage.m_maxSoldiers = 10 * 20;                                             
		stage.m_playerAiCompensation = 4;                                         
		stage.m_playerAiReduction = 0;                                              
		stage.m_soldierCapacityModel = "constant";       

		stage.addTracker(Spawner(m_metagame, 3, Vector3(506,0,465), 50, "default"));
		
		
		stage.m_minRandomCrates = 0; 
		stage.m_maxRandomCrates = 1;
         
		stage.m_defenseWinTime = 800; 
		stage.m_defenseWinTimeMode = "custom";
		stage.addTracker(PausingKothTimer(m_metagame, stage.m_defenseWinTime));
		
		{
        XmlElement command("command");
        command.setStringAttribute("class", "change_game_settings");
        for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
            XmlElement faction("faction");
            if (int(i) == 3) {
                faction.setFloatAttribute("capacity_multiplier", 0.00001);
                faction.setBoolAttribute("lose_without_bases", false);
            }
            command.appendChild(faction);
            }
        m_metagame.getComms().send(command);
        stage.addTracker(RunAtStart(m_metagame, command));
        }
		{
			Faction f(getFactionConfigs()[0], createFellowCommanderAiCommand(0, 0.35, 0.1));     
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[2], createCommanderAiCommand(2, 0.32, 0.05));          // was 0.38 0.1 (1.82)  
			f.m_overCapacity = 0;                                              
			f.m_capacityOffset = 5;                                                             
			stage.m_factions.insertLast(f);
		}
		{
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 0.32, 0.05));          // was 0.38 0.1 (1.82)  
            f.m_overCapacity = 0;                                              
			f.m_capacityOffset = 5;                                                             
			stage.m_factions.insertLast(f);
		}
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 0);
			addFactionResourceElements(command, "vehicle", array<string> = {"technical.vehicle", "radio_jammer2.vehicle", "radar_tank2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		} 
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"technical.vehicle", "radio_jammer2.vehicle", "radar_tank2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}        
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 2);
			addFactionResourceElements(command, "vehicle", array<string> = {"technical.vehicle", "radio_jammer2.vehicle", "radar_tank2.vehicle"}, false);

			stage.m_extraCommands.insertLast(command);
		}  
		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 3);
			addFactionResourceElements(command, "vehicle", array<string> = {"technical.vehicle", "radio_jammer2.vehicle", "radar_tank2.vehicle"}, true);

			stage.m_extraCommands.insertLast(command);
		}  		
		{
			// neutral
			Faction f(getFactionConfigs()[3], createCommanderAiCommand(3));
		//	f.m_overCapacity = 60;
			f.m_capacityMultiplier = 0;
			stage.m_factions.insertLast(f);
		}


		// metadata
		stage.m_primaryObjective = "koth";
		stage.m_kothTargetBase = "Dry Enclave";

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
		stage.m_mapInfo.m_path = "media/packages/vanilla/maps/map11";
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

		stage.addTracker(Spawner(m_metagame, 1, Vector3(367,0,702), 5, "default_ai"));         // 1st tower
		stage.addTracker(Spawner(m_metagame, 1, Vector3(396,0,692), 5, "default_ai"));         
		stage.addTracker(Spawner(m_metagame, 1, Vector3(407,0,720), 5, "default_ai"));

		stage.addTracker(Spawner(m_metagame, 1, Vector3(422,0,539), 5, "default_ai"));         // 1st top tower
		stage.addTracker(Spawner(m_metagame, 1, Vector3(416,0,500), 5, "default_ai"));
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(507,0,651), 5, "default_ai")); 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(471,0,672), 5, "default_ai")); 

		stage.addTracker(Spawner(m_metagame, 1, Vector3(482,0,730), 5, "default_ai"));  
		stage.addTracker(Spawner(m_metagame, 1, Vector3(500,0,550), 5, "default_ai"));     
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(612,0,519), 5, "default_ai"));    
		stage.addTracker(Spawner(m_metagame, 1, Vector3(641,0,527), 5, "default_ai"));    

		stage.addTracker(Spawner(m_metagame, 1, Vector3(544,0,476), 5, "default_ai")); 
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(603,0,620), 5, "default_ai")); 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(622,0,601), 5, "default_ai")); 
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(707,0,569), 5, "default_ai")); 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(705,0,595), 5, "default_ai")); 

		stage.addTracker(Spawner(m_metagame, 1, Vector3(720,0,477), 5, "default_ai"));    
		stage.addTracker(Spawner(m_metagame, 1, Vector3(688,0,463), 5, "default_ai"));    
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(790,0,454), 5, "default_ai")); 
		stage.addTracker(Spawner(m_metagame, 1, Vector3(766,0,454), 5, "default_ai")); 
		
		stage.addTracker(Spawner(m_metagame, 1, Vector3(541,0,608), 5, "default_ai"));     
		stage.addTracker(Spawner(m_metagame, 1, Vector3(527,0,581), 5, "default_ai"));     
		
		// make neutral instantly not alive to avoid any possibility to gain capacity, like via not losing all bases first 
		// and then gaining bases which have vehicles that give capacity offset..
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
			Faction f(getFactionConfigs()[1], createCommanderAiCommand(1, 1.0, 0.0, false));
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
		stage.m_mapInfo.m_path = "media/packages/vanilla.winter/maps/map12";
		stage.m_mapInfo.m_id = "map12";

    stage.m_fogOffset = 20.0;    
    stage.m_fogRange = 50.0; 

		stage.m_maxSoldiers = 70;                                               // was 80 in 1.70
		stage.m_playerAiCompensation = 3;                                       // was 5 (test4)
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

		{
			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", 1);
			addFactionResourceElements(command, "vehicle", array<string> = {"aa_emplacement.vehicle"}, true);
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

		_log("completion percentage: " + completionPercentage);

		const UserSettings@ settings = m_metagame.getUserSettings();
		_log(" variance enabled: " + settings.m_completionVarianceEnabled);
		if (settings.m_completionVarianceEnabled) {
			array<XmlElement@>@ varianceCommands = getCompletionVarianceCommands(stage, completionPercentage);
			// append with command already gathered
			merge(commands, varianceCommands);
		}

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
//		list.push_back(ResourceChange(Resource("a10_gun_run.call", "call"), true));
//		list.push_back(ResourceChange(Resource("gunship_run.call", "call"), true));        

		// no m79 for friendlies
		list.push_back(ResourceChange(Resource("m79.weapon", "weapon"), false));

		// no suitcases/laptops carried by friendlies
		list.push_back(ResourceChange(Resource("suitcase.carry_item", "carry_item"), false));
		list.push_back(ResourceChange(Resource("laptop.carry_item", "carry_item"), false));

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

}
