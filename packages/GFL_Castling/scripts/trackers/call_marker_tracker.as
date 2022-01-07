// internal
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class CallMarkerConfig {
	string m_key;
	int m_atlasIndex;
	float m_size;
	float m_range;
	string m_typeKey;
	string m_text;
	
	// --------------------------------------------
	CallMarkerConfig(string key, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "") {
		m_key = key;
		m_atlasIndex = atlasIndex;
		m_size = size;
		m_range = range;
		m_typeKey = "call_marker";
		m_text = text;
	}

	// --------------------------------------------
	CallMarkerConfig(string key, string typeKey, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "") {
		m_key = key;
		m_atlasIndex = atlasIndex;
		m_size = size;
		m_range = range;
		m_typeKey = typeKey;
		m_text = text;
	}
}

// --------------------------------------------
class CallMarker {
	int m_callId;
	int m_markerId;
	
	// --------------------------------------------
	CallMarker(int callId, int markerId) {
		m_callId = callId;
		m_markerId = markerId;
	}
}

// --------------------------------------------
class CallMarkerTracker : Tracker {
	protected Metagame@ m_metagame;
	protected int m_nextMarkerId = 6000;
	protected array<CallMarker@> m_callMarkers;
	protected array<CallMarkerConfig@> m_configs;
	protected bool m_allFactions;
	
	// --------------------------------------------
	CallMarkerTracker(Metagame@ metagame, array<CallMarkerConfig@>@ configs, bool allFactions = false) {
		@m_metagame = @metagame;
		m_configs = configs; // copy
		m_allFactions = allFactions;
	}

	protected CallMarkerConfig@ findConfig(string key) const {
		CallMarkerConfig@ result = null;
		for (uint i = 0; i < m_configs.size(); ++i) {
			CallMarkerConfig@ config = m_configs[i];
			if (config.m_key == key) {
				@result = @config;
				break;
			}
		}
		return result;
	}
	
	// --------------------------------------------
	protected void handleCallEvent(const XmlElement@ event) {
		string callKey = event.getStringAttribute("call_key");
		string phase = event.getStringAttribute("phase");
		string position = event.getStringAttribute("target_position");
		int callId = event.getIntAttribute("id");
		int factionId = event.getIntAttribute("faction_id");
		
		// 0 faction only
		// if (factionId != 0 && !m_allFactions) return;

		CallMarkerConfig@ config = findConfig(callKey);
		if (config !is null) {
			if (phase == "queue") {
				int markerId = m_nextMarkerId;
				m_nextMarkerId++;
				
				m_callMarkers.insertLast(CallMarker(callId, markerId));
				
				// place the marker
				XmlElement command("command");
					command.setStringAttribute("class", "set_marker");
					command.setIntAttribute("id", markerId);
					command.setIntAttribute("faction_id", factionId);
					command.setIntAttribute("atlas_index", config.m_atlasIndex);
					command.setFloatAttribute("size", config.m_size);
					command.setFloatAttribute("range", config.m_range);
					command.setIntAttribute("enabled", 1);
					command.setStringAttribute("position", position);
					command.setStringAttribute("text", config.m_text);
					command.setStringAttribute("type_key", config.m_typeKey);
					command.setBoolAttribute("show_in_map_view", true);
					command.setBoolAttribute("show_in_game_view", true);
					command.setBoolAttribute("show_at_screen_edge", false);
					
				m_metagame.getComms().send(command);
				
			} else if (phase == "end") {
			
				int markerId = -1;
				for (uint i = 0; i < m_callMarkers.length(); ++i) {
					if (m_callMarkers[i].m_callId == callId) {
						markerId = m_callMarkers[i].m_markerId;
						m_callMarkers.removeAt(i);
						break;
					}
				}
				
				if (markerId != -1) {
					// remove the marker
					XmlElement command("command");
						command.setStringAttribute("class", "set_marker");
						command.setIntAttribute("id", markerId);
						command.setIntAttribute("enabled", 0);
						command.setIntAttribute("faction_id", factionId);
					m_metagame.getComms().send(command);
				} else {
					_log("WARNING, call " + callId + " does not have associated marker");
				}
			}
		}
	}
	
	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}
	
}

