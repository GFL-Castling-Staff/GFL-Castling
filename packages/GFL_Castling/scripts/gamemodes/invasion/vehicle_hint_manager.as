// internal
#include "tracker.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

// gamemode specific
#include "vehicle_hint.as"
#include "vehicle_hint_config.as"

// --------------------------------------------
class VehicleHintManager : Tracker {
	// TODO: Generalize GameModeInvasion to another class here
	// - VehicleHint needs it, so it's here too
	protected GameModeInvasion@ m_metagame;
	protected const VehicleHintConfig@ m_config;

	// ----------------------------------------------------
	VehicleHintManager(GameModeInvasion@ metagame, const VehicleHintConfig@ config) {
		@m_metagame = @metagame;
		@m_config = @config;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// ----------------------------------------------------
	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == m_config.m_vehicleKey) {
			_log("vehicle hint manager, new vehicle spawned", 1);
			setupVehicleHint(event);
		}
	}

	// ----------------------------------------------------
	protected void setupVehicleHint(const XmlElement@ event) {
		// create hint tracker
		int vehicleId = event.getIntAttribute("vehicle_id");
		VehicleHint tracker(m_metagame, vehicleId, m_config);
		// register it
		m_metagame.addTracker(tracker);
	}
}
