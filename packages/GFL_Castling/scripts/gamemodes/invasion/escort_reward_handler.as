#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class EscortRewardHandler {
	protected Metagame@ m_metagame;
	protected int m_trackedVehicleId;
	protected int m_factionId;
	protected dictionary m_protectorTimes;
	protected float m_rewardTrackingTimer;
	protected float m_totalReward;

	// ----------------------------------------------------
	EscortRewardHandler(Metagame@ metagame, int trackedVehicleId, int factionId, float totalReward) {
		@m_metagame = metagame;
		m_trackedVehicleId = trackedVehicleId;
		m_factionId = factionId;
		m_totalReward = totalReward;
		m_rewardTrackingTimer = 0.0;
	}

	// ----------------------------------------------------
	void update(float time) {
		// track rewarding:
		// - periodically check our troops near the target vehicle, track how long have they been near it
		m_rewardTrackingTimer -= time;
		if (m_rewardTrackingTimer < 0.0) {
			updateRewardTracking(VehicleDeliveries::REWARD_TRACKING_TIME);
			m_rewardTrackingTimer = VehicleDeliveries::REWARD_TRACKING_TIME;
		}
	}

    // ----------------------------------------------------
	protected void updateRewardTracking(float time) {
		// - query friendly soldiers near the vehicle
		array<const XmlElement@> characters = getCharactersNearVehicle(m_metagame, m_trackedVehicleId, m_factionId);
		if (characters.size() > 0) {
			// check the character we already had at tracking, but which no longer was returned:
			// start reducing their time 

			// copy
			dictionary previous = m_protectorTimes;
			for (uint i = 0; i < characters.size(); ++i) {
				const XmlElement@ info = characters[i];
				int id = info.getIntAttribute("id");
				string key = id;
				if (previous.exists(key)) {
					// erase from previous
					previous.erase(key);
				}
			}
			// this leaves us with the previous ids whose characters are no longer near the vehicle
			for (uint i = 0; i < previous.getKeys().size(); ++i) {
				string key = previous.getKeys()[i];
				float value;
				previous.get(key, value);
				value -= time;
				m_protectorTimes.set(key, value);
				if (value <= 0.0f) {
					// haven't been near the vehicle for a while, remove from protectors, guy's probably dead
					_log(" * previously escorting character " + key + " not near vehicle, removing", 1);
					m_protectorTimes.erase(key);
				}
			}

			for (uint i = 0; i < characters.size(); ++i) {
				const XmlElement@ info = characters[i];
				int id = info.getIntAttribute("id");
				string key = id;
				// grant whole tracking time step for this character
				if (!m_protectorTimes.exists(key)) {
					// initialise the value
					m_protectorTimes.set(key, 0.0f);
				}
				float value = 0.0f;
				m_protectorTimes.get(key, value);
				m_protectorTimes.set(key, value + time);
				_log(" * character " + id + " escorts the vehicle, time near so far: " + value + "s", 1);
			}
		}
	}

	// ----------------------------------------------------
	void doReward() {
		// who to reward?
		// everyone in the car?
		// just the driver?
		/*
		$vehicle_info = $this->get_vehicle_info($this->tracked_vehicle_id);
		$character_list = $vehicle_info->getElementsByTagName("character");
		for ($i = 0; $i < $character_list->length; ++$i) {
			$character = $character_list->item($i);
			$slot_type = $character->getAttribute("slot_type");
			// driver, 0
			if ($slot_type == 0) {
				$id = $character->getAttribute("id");
				$c = "<command class='rp_reward' character_id='" . $id . "' reward='400.0' />";
				$this->metagame->comms->send($c);
			}
		}*/
		// reward protectors, dead ones will be ignored by game
		float totalReward = m_totalReward;
		// split reward among all protectors, weighing with amount of time spent near the truck
		float totalTime = 0.0f;
		for (uint i = 0; i < m_protectorTimes.getKeys().size(); ++i) {
			string key = m_protectorTimes.getKeys()[i];
			float value = 0.0f;
			m_protectorTimes.get(key, value);
			_log("* character " + key + " spent " + value + " s near the truck", 1);
			totalTime += value;
		}
		_log("* combined time " + totalTime + " s", 1);

		for (uint i = 0; i < m_protectorTimes.getKeys().size(); ++i) {
			string key = m_protectorTimes.getKeys()[i];
			float value = 0.0f;
			m_protectorTimes.get(key, value);

			float reward = totalReward * (value / totalTime);
			string c = "<command class='rp_reward' character_id='" + key + "' reward='" + reward + "' />";
			m_metagame.getComms().send(c);
		}
	}
}
