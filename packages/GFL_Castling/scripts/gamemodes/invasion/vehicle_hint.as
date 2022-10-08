// internal
#include "tracker.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"

// gamemode specific
#include "vehicle_hint_config.as"

// --------------------------------------------
class VehicleHint : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected const VehicleHintConfig@ m_config;

	protected float m_waitForNewIntelTimer;
	protected int m_trackedVehicleId;
	protected string m_latestIntelText;
	protected bool m_started;

	protected string m_vehicleName;
	protected string m_ownerName;

	// ----------------------------------------------------
	VehicleHint(GameModeInvasion@ metagame, int vehicleId, const VehicleHintConfig@ config) {
		@m_metagame = @metagame;
		m_trackedVehicleId = vehicleId;
		@m_config = @config;

		m_waitForNewIntelTimer = rand(m_config.m_minWaitIntelTime, m_config.m_maxWaitIntelTime);
		m_latestIntelText = "";
		m_started = false;

		const XmlElement@ v = getVehicleInfo(m_metagame, m_trackedVehicleId);
		if (v !is null) {
			// cache vehicle name
			m_vehicleName = v.getStringAttribute("name");

			// cache owner name
			int ownerId = v.getIntAttribute("owner_id");
			Faction@ f = m_metagame.getFactions()[ownerId];
			m_ownerName = f.m_config.m_name;
		}
	}

    // ----------------------------------------------------
	void update(float time) {
		//_log(" * delivery, intel timer: " + m_waitForNewIntelTimer, 1);
		m_waitForNewIntelTimer -= time;
		if (m_waitForNewIntelTimer < 0.0) {
			// resets the timer
			const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, m_trackedVehicleId);
			if (vehicleInfo is null || vehicleInfo.getIntAttribute("id") == -1) {
				// vehicle no longer exists, maybe match was restarted?
				// stop tracker
				m_trackedVehicleId = -1;
			} else {
				m_latestIntelText = getIntelText(vehicleInfo);
				instructObjective();
			}
		}
	}

	// ----------------------------------------------------
	void start() {
		if (m_config.m_makeSpotted) {
			// spot for all factions
			for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
				Faction@ faction = m_metagame.getFactions()[i];
				string command = "<command class='set_spotting' vehicle_id='" + m_trackedVehicleId + "' faction_id='" + i + "' />";
				m_metagame.getComms().send(command);
			}
		}
		m_started = true;
	}

	// ----------------------------------------------------
	void end() {
		m_trackedVehicleId = -1;
	}	

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return m_trackedVehicleId == -1;
	}

	// ----------------------------------------------------
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		// vehicle_id
		if (event.getIntAttribute("vehicle_id") == m_trackedVehicleId) {
			// vehicle was destroyed, stop this tracker
			m_trackedVehicleId = -1;

			// announce the message now
			if (m_config.m_destroyedText != "") {
				dictionary a = {
					{"%vehicle_name", m_vehicleName}
				}; 
				// "vehicle objective cancelled, vehicle destroyed"
				sendFactionMessageKey(m_metagame, m_config.m_factionId, m_config.m_destroyedText, a);
			}
		}
	}

	// --------------------------------------------------------
	protected void instructObjective() {

		dictionary a = {
			{"%vehicle_name", m_vehicleName}, 
			{"%faction_name", m_ownerName},
			{"%location", m_latestIntelText}
		};

		// TODO:
		//if ($player_id == -1) 
		{
			//"vehicle objective instruction"
			sendFactionMessageKey(m_metagame, m_config.m_factionId, m_config.m_intelText, a);
		}/* else {
			send_private_message_key($this->metagame, $player_id, "vehicle objective instruction", $a);
		}*/

		//sendFactionMessage(m_metagame, m_config.m_factionId, m_config.m_intelText + m_latestIntelText);
		m_waitForNewIntelTimer = rand(m_config.m_minWaitIntelTime, m_config.m_maxWaitIntelTime);
	}

	// --------------------------------------------------------
	protected string getIntelText(const XmlElement@ vehicleInfo) {
		string text = "";
		Vector3 pos = stringToVector3(vehicleInfo.getStringAttribute("position"));
		if (m_config.m_mode == "region") {
			string regionText = m_metagame.getRegion(pos);
			text = regionText; // + " region";

		} else if (m_config.m_mode == "base") {
			float distance = 0.0;
			const XmlElement@ base = getClosestBase(m_metagame, pos, distance);
			if (base !is null) {
				string locationText = ".. somewhere";
				if (base !is null) {
					string baseName = base.getStringAttribute("name");
					locationText = baseName;
					/*
					$location_text = "in " . $base_name;
					if ($distance > 50.0) {
						$location_text = "near " . $base_name;
					}
					*/
				}
				text = locationText; // + " area";
			}
		}
		return text;
	}
}
