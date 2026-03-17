// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"

// --------------------------------------------
class LocalBanManager : Tracker {
	protected Metagame@ m_metagame;
	protected dictionary m_bannedPlayers;
	float updateTimer = 0.0;
	float AUTOUPDATE_TIME = 5.0;
	float DEFAULT_BAN_TIME = 600.0;

	// --------------------------------------------
	LocalBanManager(Metagame@ metagame) {
		@m_metagame = metagame;
	}
	
	// --------------------------------------------
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first 
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

		// admins and mods allowed from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId) && !m_metagame.getModeratorManager().isModerator(sender,senderId)) {
			return;
		}
		// tempban only affects online players
		if (checkCommand(message, "tempban_id")) {
			handleTempBan(message, senderId, true);
		} else if (checkCommand(message, "tempban")) {
			handleTempBan(message, senderId);
		} else if (checkCommand(message, "clearban")) {
			handleClearBan(message, senderId);
		} else if (checkCommand(message, "tbdebug")) {
			sendPrivateMessage(m_metagame, senderId, "currently temp banned players");
			array<string> keys = m_bannedPlayers.getKeys();
			for (uint i = 0; i < keys.size(); ++i){
				string userName = keys[i];
				float remainingTime;
				m_bannedPlayers.get(userName, remainingTime);
				sendPrivateMessage(m_metagame, senderId, userName + ": " + remainingTime);
			}
		}
	}
	
	// --------------------------------------------
	void handleTempBan(string message, int senderId, bool id = false) {
		const XmlElement@ player = getPlayerByIdOrNameFromCommand(m_metagame, message, id);
		if (player !is null) {
			int playerId = player.getIntAttribute("player_id");
			string playerName = player.getStringAttribute("name");
			// ok player id, now ban
			//notify(m_metagame, "temp banning player", dictionary = {{"%player_name", playerName}}, "misc");
			// ban
			float banTime = DEFAULT_BAN_TIME;
			addBannedPlayer(playerName, banTime);
			sendPrivateMessage(m_metagame, senderId, "banning " + playerName + " for " + (banTime/60) + " minutes");
			// kick
			kickPlayer(playerId, banTime);
		} else {
			//_log("* couldn't find a match for " + playerName);
			sendPrivateMessage(m_metagame, senderId, "temp ban missed!");
		}
	}
	
	// --------------------------------------------
	void handleClearBan(string message, int senderId) {
		string name = message.substr(message.findFirst(" ")+1);
		if (isBanned(name)){
			removeBannedPlayer(name);
			sendPrivateMessage(m_metagame, senderId, "unbanned " + name);
		} else {
			sendPrivateMessage(m_metagame, senderId, name + " is not banned");
		}
	}
	
	// ---------------------------------------------
	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		// if the connecting player is among the banned players, kick immediately

		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			string playerName = player.getStringAttribute("name");
			string name = playerName.toLowerCase();
			if (isBanned(name)){
				float banTime = 0.0;
				m_bannedPlayers.get(name, banTime);
				// proceed to kick player by their id
				int playerId = player.getIntAttribute("player_id");
				kickPlayer(playerId, banTime);
			}
		}
	}
	
	// --------------------------------------------
	protected void kickPlayer(int playerId, float banTime) {
		dictionary a;
		a["%ban_time"] = formatInt(max(1,int(banTime/60)));
		notify(m_metagame, "Kicked - Temp banned", a, "misc", playerId, true, "Kicked from server", 1.0);
		notify(m_metagame, "rules text", dictionary(), "misc", playerId, true, "rules", 1.0, 700.0);
        ::kickPlayer(m_metagame, playerId);
	}
	
	// --------------------------------------------
	void addBannedPlayer(string name, float time) {
		m_bannedPlayers.set(name.toLowerCase(),time);
	}
	
	// --------------------------------------------
	void removeBannedPlayer(string name) {
		m_bannedPlayers.delete(name.toLowerCase());
	}

	// --------------------------------------------
	bool isBanned(string name) const {
		return m_bannedPlayers.exists(name.toLowerCase());
	}
	
	// --------------------------------------------
	// decreases all remaining times by value of the time parameter
	// and removes player from the banlist if remaining time falls under 0.0
	void updateBanTimes(float time){
		array<string> keys = m_bannedPlayers.getKeys();
		for (uint i = 0; i < keys.size(); ++i){
			string userName = keys[i];
			float remainingTime;
			m_bannedPlayers.get(userName, remainingTime);
			remainingTime -= time;
			if (remainingTime < 0.0){
				removeBannedPlayer(userName);
				keys.removeAt(i);
				--i;
			} else {
				m_bannedPlayers.set(userName,remainingTime);
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
		return true;
	}
	
	// --------------------------------------------
	void update(float time) {
		updateTimer -= time;
		if (updateTimer <= 0.0){ // for every AUTOUPDATE_TIME seconds, decrease remaining ban time by that amount
			updateBanTimes(AUTOUPDATE_TIME);
			updateTimer = AUTOUPDATE_TIME;
		}
	}
	
	
};
