#include "faction_config.as"

// --------------------------------------------
class StageConfigurator {
	// --------------------------------------------
	void setup() {
	}
	// --------------------------------------------
	const array<FactionConfig@>@ getAvailableFactionConfigs() const {
		array<FactionConfig@> empty;
		return empty;
	}
	// --------------------------------------------
	Stage@ setupCompletedStage(Stage@ inputStage) {
		return null;
	}
	// --------------------------------------------
	array<XmlElement@>@ getFactionResourceConfigChangeCommands(float completionPercentage, Stage@ Stage) {
		array<XmlElement@> empty;
		return empty;
	}
	// --------------------------------------------
};
