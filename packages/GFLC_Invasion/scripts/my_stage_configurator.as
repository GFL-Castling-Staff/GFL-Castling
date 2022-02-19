#include "stage_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyStageConfigurator : StageConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyStageConfigurator(GameModeInvasion@ metagame, MapRotatorInvasion@ mapRotator) {
		super(metagame, mapRotator);
	}

	// ------------------------------------------------------------------------------------------------
	const array<FactionConfig@>@ getAvailableFactionConfigs() const {
		array<FactionConfig@> availableFactionConfigs;

		// --------------------------------
		// TODO: define 3 faction configs here
		// - "green.xml" faction specification filename
		// - "Greenbelts" faction name, usually same as the one in the file
		// - "0.1 0.5 0" color used for faction in the world view
		// - "green_boss.xml" faction specification filename used in the final missions; 
		//   can be same as the regular faction filename
		// --------------------------------

		// availableFactionConfigs.push_back(FactionConfig(-1, "green.xml", "Greenbelts", "0.1 0.5 0", "green_boss.xml"));
		// availableFactionConfigs.push_back(FactionConfig(-1, "grey.xml", "Graycollars", "0.5 0.5 0.5", "grey_boss.xml"));
		// availableFactionConfigs.push_back(FactionConfig(-1, "brown.xml", "Brownpants", "0.5 0.25 0", "brown_boss.xml"));
		
		availableFactionConfigs.push_back(FactionConfig(-1, "gk.xml", "GK", "0.95 0.59 0.20", "gk.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "sf.xml", "S.F.", "0.91 0.11 0.20", "sf.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "kcco.xml", "KCCO", "0.43 0.49 0.18", "kcco.xml"));
		availableFactionConfigs.push_back(FactionConfig(-1, "paradeus.xml", "Paradeus", "1 1 1", "paradeus.xml"));

		return availableFactionConfigs;
	}

	// NOTE
	// if you need to add certain resources for enemies or friendlies generally in all stages, have a look at
	// vanilla\scripts\gamemodes\invasion\stage_configurator_invasion.as and consider overriding
	// getCommonFactionResourceChanges
	// getFriendlyFactionResourceChanges
	// getCompletionVarianceCommands
}
