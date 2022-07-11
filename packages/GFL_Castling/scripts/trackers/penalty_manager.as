// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"

// --------------------------------------------
class PenalizedPlayer {
	string m_username = "";
	string m_hash = "";
	string m_ip = "";
	string m_sid = "ID0";
	float m_penaltyTimer = -1.0;
	int m_teamKills = 0;
	float m_forgiveTeamKillTimer = -1.0;

	int m_id = -1; // only valid if player is in-game

	// --------------------------------------------
	PenalizedPlayer(string username, string hash, string ip, string sid, int id) {
		m_username = username;
		m_hash = hash;
		m_ip = ip;
		m_sid = sid;
		m_id = id;
	}

	// --------------------------------------------
	string getKey() const {
		return m_sid;
	}
}

// --------------------------------------------
class PenalizedPlayerBucket {
	protected PenaltyManager@ m_manager;
	protected string m_name;
	protected dictionary m_players;
	protected float m_updateTimer;
	protected float m_updateTime;
	protected float m_timeFactor;

	// --------------------------------------------
	PenalizedPlayerBucket(PenaltyManager@ manager, string name, float updateTime, float timeFactor = 1.0f) {
		@m_manager = @manager;
		m_name = name;

		m_updateTimer = 0.0f;
		m_updateTime = updateTime;
		m_timeFactor = timeFactor;
	}

	// --------------------------------------------
	array<string> getKeys() const {
		return m_players.getKeys();
	}

	// --------------------------------------------
	bool exists(string key) const {
		return m_players.exists(key);
	}

	// --------------------------------------------
	PenalizedPlayer@ get(string key) const {
		PenalizedPlayer@ player;
		m_players.get(key, @player);
		return player;
	}

	// --------------------------------------------
	void add(PenalizedPlayer@ player) {
		_log("PenaltyManager, " + m_name + ": add, player=" + player.m_username + ", hash=" + player.m_hash + ", count before=" + m_players.size() + ", sid=" + player.m_sid);
		m_players.set(player.m_sid, @player);
	}

	// --------------------------------------------
	void remove(PenalizedPlayer@ player) {
		int s = size();
		m_players.erase(player.m_sid);
		if (size() != s) {
			_log("PenaltyManager, " + m_name + ": remove, player=" + player.m_username + ", sid=" + player.m_sid);
		}
	}

	// --------------------------------------------
	void update(float time) {
		// update penalized players with interval 
		m_updateTimer -= time;
		if (m_updateTimer < 0.0) {
			array<string> keys = m_players.getKeys();
			for (uint i = 0; i < keys.size(); ++i) {
				string key = keys[i];
				PenalizedPlayer@ player = get(key);
				if (updatePlayer(player, m_updateTime * m_timeFactor)) {
					// tracking ended
					//--i;
				}
			}
			m_updateTimer = m_updateTime;
		}
	}

	// --------------------------------------------
	void addPlayersToSave(XmlElement@ root) {
		for (uint i = 0; i < m_players.getKeys().size(); ++i) {
			string sid = m_players.getKeys()[i];
			PenalizedPlayer@ player = get(sid);

			// with forgiving team kills actually removing tracking this won't be needed,
			// but it helps instantly with old data that has players that don't require
			// tracking which also won't connect in a long time now
			if (player.m_teamKills > 0 || player.m_penaltyTimer > 0.0f) {
				XmlElement e("penalized_player");
				e.setStringAttribute("username", player.m_username);
				e.setStringAttribute("hash", player.m_hash);
				e.setStringAttribute("ip", player.m_ip);
				e.setStringAttribute("sid", player.m_sid);
				e.setIntAttribute("team_kills", player.m_teamKills);
				e.setFloatAttribute("penalty_timer", player.m_penaltyTimer);
				e.setFloatAttribute("forgive_team_kill_timer", player.m_forgiveTeamKillTimer);
				root.appendChild(e);
			}
		}
	}

	// --------------------------------------------
	int size() const {
		return m_players.size();
	}

	// --------------------------------------------
	void clear() {
		m_players = dictionary();
	}

	// --------------------------------------------
	protected bool updatePlayer(PenalizedPlayer@ player, float time) {
		bool ended = false;
		if (player.m_penaltyTimer >= 0.0) {
			player.m_penaltyTimer -= time;
			if (player.m_penaltyTimer < 0.0) {
				m_manager.endPenalty(player); 
				ended = true;
			}
		} else {
			// not yet in penalty, just being tracked
			// forgive team kills if the next doesn't happen soon enough
			if (player.m_forgiveTeamKillTimer >= 0.0) {
				player.m_forgiveTeamKillTimer -= time;
				if (player.m_forgiveTeamKillTimer < 0.0) {
					if (player.m_teamKills > 0) {
						player.m_teamKills -= 1;

						if (player.m_teamKills > 0) {
							// prepare to forgive the next one
							player.m_forgiveTeamKillTimer = m_manager.getForgiveTeamKillTime();
						} else {
							// no more team kills left, remove tracking
							m_manager.removeTracking(player);
							ended = true;
						}
					}
				}
			}
		}
		return ended;
	}
}

// --------------------------------------------
class PenaltyManager : Tracker {
	protected Metagame@ m_metagame;

	protected float AUTOSAVE_TIME = 180.0;
	protected string FILENAME = "penalized_players.xml"; 

	// penalty starts after x team kills
	protected int m_teamKillsToStartPenalty;

	// penalty lasts for x seconds
	protected float m_penaltyTime;
	
	// a tracked team kill expires in x seconds, unless next one happen earlier
	protected float m_forgiveTeamKillTime;

	protected PenalizedPlayerBucket@ m_trackedPlayers;
	protected PenalizedPlayerBucket@ m_persistentTrackedPlayers;

	protected float m_autosaveUpdateTimer = 0.0;

	// --------------------------------------------
	PenaltyManager(Metagame@ metagame, int teamKillsToStartPenalty = 3, float penaltyTime = 1800.0, float forgiveTeamKillTime = 900.0, float persistentPenaltyTime = 1209600.0f) {
		@m_metagame = @metagame;
		m_teamKillsToStartPenalty = teamKillsToStartPenalty;
		m_penaltyTime = penaltyTime;
		m_forgiveTeamKillTime = forgiveTeamKillTime;

		float persistentPenaltyTimeFactor = penaltyTime / persistentPenaltyTime;
		_log("penalty time " + m_penaltyTime);
		_log("persistent penalty time " + persistentPenaltyTime);
		_log("persistent penalty time factor " + persistentPenaltyTimeFactor);

		@m_trackedPlayers = PenalizedPlayerBucket(this, "tracked", 5.0);
		@m_persistentTrackedPlayers = PenalizedPlayerBucket(this, "persistent", 60, persistentPenaltyTimeFactor);

		load();
	}

	// --------------------------------------------
	void onRemove() {
		// trackers are removed just before a new match starts
		// - at match start no players are on the server, and players are about to (re)connect
		// - it often happens that previous match ends so quickly that player disconnect events
		//   aren't received from the server, so we must consider this point as if
		//   all players still thought to be left in the game had disconnected
		array<string> keys = m_trackedPlayers.getKeys();
		for (uint i = 0; i < keys.size(); ++i) {
			handlePlayerDisconnect(keys[i]);
		}
	}

	// --------------------------------------------
	float getForgiveTeamKillTime() const {
		return m_forgiveTeamKillTime;
	}

	// --------------------------------------------
	protected void handlePlayerKillEvent(const XmlElement@ event) {

		const XmlElement@ killer = event.getFirstElementByTagName("killer");
		if (killer !is null) {
			int killerFactionId = killer.getIntAttribute("faction_id");

			const XmlElement@ target = event.getFirstElementByTagName("target");
			if (target !is null) {
				int targetFactionId = target.getIntAttribute("faction_id");

				if (killerFactionId == targetFactionId) {
					// it's a team kill
					string targetHash = target.getStringAttribute("profile_hash");
					string killerHash = killer.getStringAttribute("profile_hash");

					// rule out self kill
					if (targetHash != killerHash) {
					//if (true) {
						string killerUsername = killer.getStringAttribute("name");
						string killerIp = killer.getStringAttribute("ip");
						int killerId = killer.getIntAttribute("player_id");
						string killerSid = killer.getStringAttribute("sid");

						PenalizedPlayer@ player;
						string key = killerSid;
						if (key != "ID0") {
							if (m_trackedPlayers.exists(key)) {
								@player = m_trackedPlayers.get(key);
							} else {
								@player = PenalizedPlayer(killerUsername, killerHash, killerIp, killerSid, killerId);
								m_trackedPlayers.add(player);
							}

							addTeamKill(player);
						}
					}
				}
			}
		}
	}

	// ----------------------------------------------------
	protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		// when tracked player leaves, remove from tracking, but keep in persistently tracked

		const XmlElement@ player = event.getFirstElementByTagName("player");

		if (player !is null) {
			string key = player.getStringAttribute("sid");
			if (key != "ID0") {
				handlePlayerDisconnect(key);
			}
		}
	}

	// ----------------------------------------------------
	protected void handlePlayerDisconnect(string key) {
		if (m_trackedPlayers.exists(key)) {
			PenalizedPlayer@ p = m_trackedPlayers.get(key);
			_log("PenaltyManager: penalized/tracked player disconnected, player=" + p.m_username);
			m_persistentTrackedPlayers.add(p);
			m_trackedPlayers.remove(p);

			p.m_id = -1;
		}
	}

	// ----------------------------------------------------
	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		// if the connecting player is among the persistently stored tracked players
		// get his tracking or penalty up and running

		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			string hash = player.getStringAttribute("profile_hash");
			string playerIp = player.getStringAttribute("ip");
			int playerId = player.getIntAttribute("player_id");

			string key = player.getStringAttribute("sid");
			PenalizedPlayer@ trackedPlayer;
			if (key != "ID0") {
				if (m_persistentTrackedPlayers.exists(key)) {
					@trackedPlayer = m_persistentTrackedPlayers.get(key);

					_log("PenaltyManager: penalized/tracked player connected, player=" + trackedPlayer.m_username + ", hash=" + hash + ", sid=" + trackedPlayer.m_sid);

					// update player id and ip
					trackedPlayer.m_id = playerId;
					trackedPlayer.m_ip = playerIp;

					m_trackedPlayers.add(trackedPlayer);
					m_persistentTrackedPlayers.remove(trackedPlayer);
				} 
			}

			if (trackedPlayer !is null && trackedPlayer.m_penaltyTimer >= 0.0) {
				startPenalty(trackedPlayer);
			}
		}
	}

	// --------------------------------------------
	protected void addTeamKill(PenalizedPlayer@ player) {
		// if already serving penalty, disregard; most likely someone killed a lot of players with an artillery strike
		// and already got his penalty started when more team kill notifications come in
		if (player.m_penaltyTimer > 0.0f) {
			return;
		}

		player.m_teamKills += 1;
		_log("PenaltyManager: add_team_kill, player=" + player.m_username + ", team kills now = " + player.m_teamKills + ", sid=" + player.m_sid);
		player.m_forgiveTeamKillTimer = getForgiveTeamKillTime();

		if (player.m_teamKills >= m_teamKillsToStartPenalty) {
			// start penalty
			player.m_penaltyTimer = m_penaltyTime;
			startPenalty(player);
		}
		
		// report to moderators 
		{
			array<const XmlElement@>@ players = getPlayers(m_metagame);
			for (uint i = 0; i < players.size(); ++i) {
				const XmlElement@ candidate = players[i];
				string name = candidate.getStringAttribute("name");
				int id = candidate.getIntAttribute("player_id");
				if (m_metagame.getAdminManager().isAdmin(name, id) ||
				    m_metagame.getModeratorManager().isModerator(name, id)) {
					report(player, id);
				}
			}
		}
	}
	
	// --------------------------------------------
	protected void report(PenalizedPlayer@ player, int toPlayerId) {
		string text = "teamkill: " + player.m_username + " (hash=" + player.m_hash + ")";
		sendPrivateMessage(m_metagame, toPlayerId, text);
	}
	

	// --------------------------------------------
	protected void startPenalty(PenalizedPlayer@ player) {
		if (player.m_id >= 0) {
			// player is in-game
			_log("PenaltyManager: start_penalty, player=" + player.m_username + ", sid=" + player.m_sid);
			string command = "<command class='update_player' player_id='" + player.m_id + "' penalty='1' />";
			m_metagame.getComms().send(command);

			dictionary a;
			a["%penalty_time"] = formatInt(max(1,int(player.m_penaltyTimer/60)));
			notify(m_metagame, "Teamkill penalty", a, "misc", player.m_id, true, "your penalty has started", 0.8);
		}

		// clear team kills tracking now
		player.m_teamKills = 0;
		player.m_forgiveTeamKillTimer = -1.0;
	}

	// --------------------------------------------
	void endPenalty(PenalizedPlayer@ player) {
		if (player.m_id >= 0) {
			// player is in-game
			_log("PenaltyManager: end_penalty, player=" + player.m_username + ", sid=" + player.m_sid);
			string command = "<command class='update_player' player_id='" + player.m_id + "' penalty='0' />";
			m_metagame.getComms().send(command);

			notify(m_metagame, "your penalty has expired", dictionary(), "misc", player.m_id);
		}

		removeTracking(player);
	}

	// --------------------------------------------
	void removeTracking(PenalizedPlayer@ player) {
		// when penalty ends, remove from tracked and persistent too, doesn't matter if not found
		m_trackedPlayers.remove(player);
		m_persistentTrackedPlayers.remove(player);
	}

	// --------------------------------------------
	void update(float time) {
		m_trackedPlayers.update(time);
		m_persistentTrackedPlayers.update(time);

		m_autosaveUpdateTimer -= time;
		if (m_autosaveUpdateTimer < 0.0) {
			save();
			m_autosaveUpdateTimer = AUTOSAVE_TIME;
		}
	}

	// --------------------------------------------
	protected void save() {
		XmlElement root("penalized_players");

		m_persistentTrackedPlayers.addPlayersToSave(root);
		m_trackedPlayers.addPlayersToSave(root);

		XmlElement command("command");
		command.setStringAttribute("class", "save_data");
		command.setStringAttribute("filename", FILENAME);
		command.setStringAttribute("location", "app_data");
		command.appendChild(root);

		m_metagame.getComms().send(command);

		_log("PenaltyManager: save, players " + m_persistentTrackedPlayers.size() + " saved");
	}

	// --------------------------------------------
	protected void load() {
		m_persistentTrackedPlayers.clear();
		m_trackedPlayers.clear();

		XmlElement@ query = XmlElement(
			makeQuery(m_metagame, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", FILENAME}, {"location", "app_data"} } }));
		const XmlElement@ doc = m_metagame.getComms().query(query);

		if (doc !is null) {
			const XmlElement@ root = doc.getFirstChild();
			if (root !is null) {
				array<const XmlElement@> penalizedPlayers = root.getElementsByTagName("penalized_player");
				for (uint i = 0; i < penalizedPlayers.size(); ++i) {
					const XmlElement@ e = penalizedPlayers[i];
					string username = e.getStringAttribute("username");
					string hash = e.getStringAttribute("hash");
					string ip = e.getStringAttribute("ip");
					string sid = e.getStringAttribute("sid");

					PenalizedPlayer player(username, hash, ip, sid, -1);
					player.m_teamKills = e.getIntAttribute("team_kills");
					player.m_penaltyTimer = e.getFloatAttribute("penalty_timer");
					player.m_forgiveTeamKillTimer = e.getFloatAttribute("forgive_team_kill_timer");

					m_persistentTrackedPlayers.add(player);
				}
			}
		}

		_log("PenaltyManager: load, players " + m_persistentTrackedPlayers.size() + " loaded");
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
	protected void handleChatEvent(const XmlElement@ event) {		
		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first 
		if (!startsWith(message, "/")) {
			return;
		}
		
		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		
		// admin and moderator only from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId) && !m_metagame.getModeratorManager().isModerator(sender, senderId)) {
			return;
		}
		if (checkCommand(message, "penalize_id")) {
			handlePenalize(message,senderId,true);
		} else if (checkCommand(message, "penalize")) {
			handlePenalize(message,senderId);
		} else if (checkCommand(message, "forgive_id")) {
			handleForgive(message,senderId,true);
		} else if (checkCommand(message, "forgive")) {
			handleForgive(message,senderId);
		}
	}
	
	// --------------------------------------------
	protected void handlePenalize(string message, int senderId, bool id = false) {
		const XmlElement@ p = getPlayerByIdOrNameFromCommand(m_metagame, message, id);
		if (p !is null) {
			// get player's id, ip, sid and hash, in case a PenalizedPlayer object must be constructed
			int playerId = p.getIntAttribute("player_id"); 
			string playerIp = p.getStringAttribute("ip");
			string playerSid = p.getStringAttribute("sid");
			string playerHash = p.getStringAttribute("profile_hash");
			string playerName = p.getStringAttribute("name");

			// ok player id, now penalize
			//notify(m_metagame, "penalizing player", dictionary = {{"%player_name", playerName}}, "misc");
			
			PenalizedPlayer@ player;
			string key = playerSid;
			if (key != "ID0") {
				if (m_trackedPlayers.exists(key)) {
					@player = m_trackedPlayers.get(key);
				} else {
					@player = PenalizedPlayer(playerName, playerHash, playerIp, playerSid, playerId);
					m_trackedPlayers.add(player);
				}
				
				player.m_penaltyTimer = m_penaltyTime;
				sendPrivateMessage(m_metagame, senderId, "penalizing " + playerName + " for " + (m_penaltyTime / 60) + " minutes");
				startPenalty(player);
			}
		} else {
			//_log("* couldn't find a match for " + playerName);
			sendPrivateMessage(m_metagame, senderId, "penalize missed!");
		}
	}
	
	// --------------------------------------------
	protected void handleForgive(string message, int senderId, bool id = false) {
		const XmlElement@ p = getPlayerByIdOrNameFromCommand(m_metagame, message, id);
		if (p !is null) {
			int playerId = p.getIntAttribute("player_id"); // get player's id and sid
			string playerSid = p.getStringAttribute("sid");
			string playerName = p.getStringAttribute("name");

			// ok player id, now forgive
			PenalizedPlayer@ player;
			string key = playerSid;
			if (key != "ID0") {
				if (m_trackedPlayers.exists(key)) {
					@player = m_trackedPlayers.get(key);
				} else {
					sendPrivateMessage(m_metagame, senderId, "player not penalized");
					return;
				}
				
				player.m_penaltyTimer = -1.0;
				endPenalty(player);
				sendPrivateMessage(m_metagame, senderId, "player " + playerName + " forgiven");
			}
		} else {
			//_log("* couldn't find a match for " + playerName);
			sendPrivateMessage(m_metagame, senderId, "forgive missed!");
		}
	}
}

