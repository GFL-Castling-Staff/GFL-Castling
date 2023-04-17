// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

const float INVESTIGATION_COMPLETE_CHECK_INTERVAL_TIME = 5.0;

// --------------------------------------------
class IntelManager : Tracker {
	protected GameModeInvasion@ m_metagame;
	protected bool m_started;
	
	protected float m_reward;
	protected string m_requiredCallForHint;
	protected float m_requiredXPForHint;

	// ----------------------------------------------------
	IntelManager(GameModeInvasion@ metagame, float reward = 100.0, string requiredCallForHint = "paratroopers1.call", float requiredXPForHint = 0.150) {
		@m_metagame = @metagame;
		m_started = false;
		m_reward = reward;
		m_requiredCallForHint = requiredCallForHint;
		m_requiredXPForHint = requiredXPForHint;
	}

	// ----------------------------------------------------
	void start() {
		m_started = true;
		
		// go through all capturable enemy bases, setup markers for them, "to investigate"
		array<const XmlElement@>@ bases = getBases(m_metagame);
		for (uint i = 0; i < bases.size(); ++i) {
			const XmlElement@ base = bases[i];
			if (base.getIntAttribute("owner_id") != 0 && base.getBoolAttribute("capturable")) {
				setBaseToInvestigate(base);
			}
		}
	}
	
	// ----------------------------------------------------
	protected int getMarkerId(int baseId) const {
		return 5000 + baseId;
	}
	
	// ----------------------------------------------------
	protected void setBaseMarker(const XmlElement@ base, string style, string text = "") {
		int baseId = base.getIntAttribute("id");
		string position = base.getStringAttribute("position");
	
		int markerId = getMarkerId(baseId);
		
		int atlasIndex = 
			style == "investigate" ? 5 :
			style == "capture" ? 15 :
			0;
			
		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", markerId);
		command.setIntAttribute("faction_id", 0);
		command.setIntAttribute("atlas_index", atlasIndex);
		command.setFloatAttribute("size", 2.0f);
		command.setBoolAttribute("enabled", style != "");
		command.setStringAttribute("position", position);
		command.setStringAttribute("text", text);
		command.setBoolAttribute("show_in_map_view", true);
		command.setBoolAttribute("show_in_game_view", false);
		command.setBoolAttribute("show_at_screen_edge", false);
		// text, color, size
		
		m_metagame.getComms().send(command);
	}

	// ----------------------------------------------------
	protected void clearBaseMarker(int baseId) {
		_log("clearBaseMarker, baseId=" + baseId, 1);
		int markerId = getMarkerId(baseId);
		
		XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", markerId);
		command.setIntAttribute("enabled", 0);
		command.setIntAttribute("faction_id", 0);
		
		m_metagame.getComms().send(command);
	}
	
	// ----------------------------------------------------
	protected void setBaseToInvestigate(const XmlElement@ base) {
		int baseId = base.getIntAttribute("id");
		setBaseMarker(base, "capture");
	}
	
	// ----------------------------------------------------
	void gameContinuePreStart() {
		m_started = true;
	}
	
	// ----------------------------------------------------
	void end() {
	}	

	// ----------------------------------------------------
	bool hasStarted() const {
		return m_started;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// ----------------------------------------------------
	protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
		array<const XmlElement@>@ bases = getBases(m_metagame);

		int baseId = event.getIntAttribute("base_id");
		int newOwner = event.getIntAttribute("owner_id");
		const XmlElement@ base = getBase(bases, baseId);

		if (newOwner > 0 /* owned by enemy */) {
			setBaseMarker(base, "capture");
		} 
		else if (newOwner == 0 /* owned by friendly */) {
			clearBaseMarker(baseId);
		}
	}

	// ----------------------------------------------------
	protected void handleAttackChangeEvent(const XmlElement@ event) {
		if (event.getIntAttribute("faction_id") != 0) return;
		
		int baseId = event.getIntAttribute("base_id");
		if (baseId >= 0) {			
			const XmlElement@ base = getBase(m_metagame, baseId);
			setBaseMarker(base, "capture");
		}
	}
	
    // ----------------------------------------------------
	void update(float time) {}
	
	
	// ----------------------------------------------------
	protected bool hasCallAvailable(string key) {
		bool result = false;
		array<const XmlElement@> calls = getFactionResources(m_metagame, 0, "call", "calls");
		for (uint i = 0; i < calls.size(); ++i) {
			const XmlElement@ call = calls[i];
			if (call.getStringAttribute("key") == key) {
				result = true;
				break;
			}
		}
		return result;
	}
	
	// ----------------------------------------------------
	protected bool hasEnoughXP(int characterId, float xp) {
		bool result = false;
		const XmlElement@ characterInfo = getCharacterInfo(m_metagame, characterId);
		if (characterInfo !is null &&
		    characterInfo.getFloatAttribute("xp") >= xp) {
			result = true;
		}
		return result;
	}

	// ----------------------------------------------------
	void onRemove() {
		m_started = false;
	}

}
