// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class SideBaseAttackHandler : Tracker {
	protected GameMode@ m_metagame;
	protected int m_factionId;
	protected int m_minPlayers;
	protected int m_maxPlayers;
	protected float m_sideBaseAttackProbabilityAtMinPlayers;
	protected float m_sideBaseAttackProbabilityAtMaxPlayers;
	protected float m_lonewolfSpawnScoreAtMinPlayers;
	protected float m_lonewolfSpawnScoreAtMaxPlayers;
	
	protected float m_delayTimer;

	// --------------------------------------------
	SideBaseAttackHandler(GameMode@ metagame, int factionId, int minPlayers, int maxPlayers, 
		float sideBaseAttackProbabilityAtMinPlayers, float sideBaseAttackProbabilityAtMaxPlayers,
		float lonewolfSpawnScoreAtMinPlayers, float lonewolfSpawnScoreAtMaxPlayers) {
		
		@m_metagame = @metagame;
		m_factionId = factionId;
		m_minPlayers = minPlayers;
		m_maxPlayers = maxPlayers;
		m_sideBaseAttackProbabilityAtMinPlayers = sideBaseAttackProbabilityAtMinPlayers;
		m_sideBaseAttackProbabilityAtMaxPlayers = sideBaseAttackProbabilityAtMaxPlayers;
		m_lonewolfSpawnScoreAtMinPlayers = lonewolfSpawnScoreAtMinPlayers;
		m_lonewolfSpawnScoreAtMaxPlayers = lonewolfSpawnScoreAtMaxPlayers;
		
		m_delayTimer = -1.0;
		
		_log("SideBaseAttackHandler, factionId=" + m_factionId, 1);
	}

	// --------------------------------------------
	bool hasStarted() const { return true; }
	bool hasEnded() const { return false; }

	// --------------------------------------------
	protected void startDelayTimer() {
		if (m_delayTimer < 0.0f) {
			m_delayTimer = 3.0;
		}
	}
	
	// --------------------------------------------
	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		startDelayTimer();
	}
		
	// --------------------------------------------
	protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		startDelayTimer();
	}

	// --------------------------------------------
	void update(float time) {
		if (m_delayTimer >= 0.0f) {
			m_delayTimer -= time;
			if (m_delayTimer < 0.0f) {
				refresh();
			}
		}
	}
	
	// --------------------------------------------
	protected void refresh() {
		_log("SideBaseAttackHandler, refresh", 1);

		int count = getPlayerCount(m_metagame);
		// map player count to enemy commander ai side_base_attack_probability, usual interpolation
		float p = float(max(min(count, m_maxPlayers), m_minPlayers) - m_minPlayers) / float(m_maxPlayers - m_minPlayers);

		_log("  p=" + p, 1);
		
		{		
			float sideBaseAttackProbability = m_sideBaseAttackProbabilityAtMinPlayers + p * (m_sideBaseAttackProbabilityAtMaxPlayers - m_sideBaseAttackProbabilityAtMinPlayers);
			XmlElement command("command");
			command.setStringAttribute("class", "commander_ai");
			command.setIntAttribute("faction_id", m_factionId);
			command.setFloatAttribute("side_base_attack_probability", sideBaseAttackProbability);
			m_metagame.getComms().send(command);		
		}
		
		{
			float lonewolfSpawnScore = m_lonewolfSpawnScoreAtMinPlayers + p * (m_lonewolfSpawnScoreAtMaxPlayers - m_lonewolfSpawnScoreAtMinPlayers);
			XmlElement command("command");
			command.setStringAttribute("class", "faction");
			command.setIntAttribute("faction_id", m_factionId);
			command.setStringAttribute("soldier_group_name", "lonewolf");
			command.setFloatAttribute("spawn_score", lonewolfSpawnScore);
			m_metagame.getComms().send(command);
		}
		
	}
}
