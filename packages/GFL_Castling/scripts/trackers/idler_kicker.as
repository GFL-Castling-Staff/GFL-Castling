// internal
#include "gamemode.as"
#include "tracker.as"
#include "log.as"

// --------------------------------------------
class IdlerKicker : Tracker {
	protected GameMode@ m_metagame;

	protected float m_maxIdleTime;
	protected float m_timer;
	
	protected dictionary m_positions;

	// --------------------------------------------
	IdlerKicker(GameMode@ metagame, float time = 600.0) {
		@m_metagame = @metagame;

		m_maxIdleTime = time;
		m_timer = m_maxIdleTime;
	}
	
	// --------------------------------------------
	void update(float time) {
		m_timer -= time;
		if (m_timer < 0.0) {
			refresh();
			m_timer = m_maxIdleTime;
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

	// --------------------------------------------
	protected void refresh() {
		// query player positions
		array<const XmlElement@> players = getPlayers(m_metagame);
		for (uint i = 0; i < players.size(); ++i) {
			const XmlElement@ player = players[i];
			
			// ignore admins and mods
			string name = player.getStringAttribute("name");
			if (m_metagame.getAdminManager().isAdmin(name) || 
			    m_metagame.getModeratorManager().isModerator(name)) {
				continue;
			}

			if (player.hasAttribute("character_id")) {
				const XmlElement@ character = getCharacterInfo(m_metagame, player.getIntAttribute("character_id"));
				if (character !is null) {
					string position = character.getStringAttribute("position");
					string oldPosition = "";
					// check if they're same as last time
					// if so, kick
					if (m_positions.get(name, oldPosition) && position == oldPosition) {
						int id = player.getIntAttribute("player_id");
						notify(m_metagame, "Kicked - Idling", dictionary(), "misc", id, true, "Kicked from server", 1.0);
						kickPlayer(m_metagame, id);
					} else {
						// store new position
						m_positions.set(name, position);
					}
				}
			}
		}
	}
	
	// ----------------------------------------------------
	protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			string name = player.getStringAttribute("name");
			m_positions.delete(name);
		}		
	}	
}
