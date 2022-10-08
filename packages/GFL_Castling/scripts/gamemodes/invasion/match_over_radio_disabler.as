// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class MatchOverRadioDisabler : Tracker {
	protected GameMode@ m_metagame;

	// --------------------------------------------
	MatchOverRadioDisabler(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on, no need to run anything particular at start
		return true;
	}

	// --------------------------------------------
	protected void handleMatchEndEvent(const XmlElement@ event) {
		int factionId = 1;
		const XmlElement@ winCondition = event.getFirstElementByTagName("win_condition");
		if (winCondition !is null) {
			factionId = winCondition.getIntAttribute("faction_id");
		}

		if (factionId == 0) {
			_log("MatchOverRadioDisabler::handleMatchEndEvent, disabling calls at match end for winner=friendly");

			array<const XmlElement@>@ resources = getFactionResources(m_metagame, factionId, "call", "calls");

			XmlElement command("command");
			command.setStringAttribute("class", "faction_resources");
			command.setIntAttribute("faction_id", factionId);
			for (uint j = 0; j < resources.size(); ++j) {
				addFactionResourceElements(command, "call", array<string> = {resources[j].getStringAttribute("key")}, false);
			}

			m_metagame.getComms().send(command);
		}
	}

}
