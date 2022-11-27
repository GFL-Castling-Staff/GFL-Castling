// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class CommsCapacityHandler : Tracker {
	protected GameMode@ m_metagame;

	// --------------------------------------------
	CommsCapacityHandler(GameMode@ metagame) {
		@m_metagame = @metagame;
	}
	
	// --------------------------------------------
	protected void handleCommsChangeEvent(const XmlElement@ event) {
		// when comms goes off, set initial comms off multiplier
		int factionId = event.getIntAttribute("faction_id");
		bool comms = event.getBoolAttribute("state");
		_log("CommsCapacityHandler, handleCommsChangeEvent, factionId=" + factionId + ", state=" + comms, 1);
		if (!comms) {
			setCommsDisabledCapacityMultiplier(factionId, 0.5);
		}
	}

	// --------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		// when base is lost while comms is off, set new comms off multiplier to prevent multibase steamroll while comms is off
		int oldOwner = event.getIntAttribute("previous_owner_id");		
		if (oldOwner >= 0 && !hasFactionComms(m_metagame, oldOwner)) {
			_log("CommsCapacityHandler, handleBaseOwnerChangeEvent, previous_owner_id=" + oldOwner + ", no comms", 1);
			setCommsDisabledCapacityMultiplier(oldOwner, 0.9);
		}
	}

	// --------------------------------------------
	void setCommsDisabledCapacityMultiplier(int factionId, float multiplier) {
		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
			XmlElement faction("faction");
			if (int(i) == factionId) {
				faction.setFloatAttribute("comms_disabled_capacity_multiplier", multiplier);
			}
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);
	}
}
