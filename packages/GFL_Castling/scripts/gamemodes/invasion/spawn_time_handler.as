// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// --------------------------------------------
class SpawnTimeHandler : Tracker {
	protected GameMode@ m_metagame;
	protected int m_factionId;
	protected int m_minPlayers;
	protected int m_maxPlayers;
	protected float m_spawnTimeAtMinPlayers;
	protected float m_spawnTimeAtMaxPlayers;

	// --------------------------------------------
	SpawnTimeHandler(GameMode@ metagame, int factionId, int minPlayers, int maxPlayers, float spawnTimeAtMinPlayers, float spawnTimeAtMaxPlayers) {
		@m_metagame = @metagame;
		m_factionId = factionId;
		m_minPlayers = minPlayers;
		m_maxPlayers = maxPlayers;
		m_spawnTimeAtMinPlayers = spawnTimeAtMinPlayers;
		m_spawnTimeAtMaxPlayers = spawnTimeAtMaxPlayers;
	}
	
	// --------------------------------------------
	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		refresh();
	}
		
	// --------------------------------------------
	protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		refresh();
	}
	
	// --------------------------------------------
	protected void refresh() {
		int count = getPlayerCount(m_metagame);
		// map player count to faction spawn_interval, usual interpolation?
		float p = float(max(min(count, m_maxPlayers), m_minPlayers) - m_minPlayers) / float(m_maxPlayers - m_minPlayers);
		float spawnTime = m_spawnTimeAtMinPlayers + p * (m_spawnTimeAtMaxPlayers - m_spawnTimeAtMinPlayers);
		
		XmlElement command("command");
		command.setStringAttribute("class", "change_game_settings");
		for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
			XmlElement faction("faction");
			if (int(i) == m_factionId) {
				faction.setFloatAttribute("spawn_interval", spawnTime);
			}
			command.appendChild(faction);
		}
		m_metagame.getComms().send(command);		
	}
}
