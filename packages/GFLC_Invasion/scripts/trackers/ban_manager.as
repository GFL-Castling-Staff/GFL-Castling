// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"

// --------------------------------------------
class BanManager : Tracker {
	protected Metagame@ m_metagame;

	protected string m_usernameFilename = "ban_list_username.xml"; 
	protected string m_steamIdFilename = "ban_list_steamid.xml"; 
	protected string m_ipFilename = "ban_list_ip.xml"; 

	protected array<string> m_usernameList;
	protected array<string> m_steamIdList;
	protected array<string> m_ipList;

	protected bool m_requireSid = false;

	// --------------------------------------------
	BanManager(Metagame@ metagame, bool requireSid = false) {
		@m_metagame = metagame;
		m_requireSid = requireSid;
		load();
	}

	// ----------------------------------------------------
	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		// if the connecting player is among the persistently stored tracked players
		// get his tracking or penalty up and running

		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			checkBan(player);
		}
	}

	// --------------------------------------------
	protected void kickPlayer(int playerId, string textKey = "", bool showRules = true) {
		if (textKey != "") {
			notify(m_metagame, textKey, dictionary(), "misc", playerId, true, "Kicked from server", 1.0);
			if (showRules) {
				notify(m_metagame, "rules text", dictionary(), "misc", playerId, true, "Rules", 1.0, 700.0);
			}
		}
        ::kickPlayer(m_metagame, playerId);
	}

	// --------------------------------------------
	protected void load() {
		refresh();
	}

	// --------------------------------------------
	protected array<string> loadData(string filename) {
		return loadStringsFromFile(m_metagame, filename);
	}

	// --------------------------------------------
	protected void refresh() {
		m_usernameList = loadData(m_usernameFilename);
		m_steamIdList = loadData(m_steamIdFilename);
		m_ipList = loadData(m_ipFilename);

		_log("BanManager: refresh");
		_log(m_usernameList.size() + " usernames loaded");
		_log(m_steamIdList.size() + " steamids loaded");
		_log(m_ipList.size() + " ips loaded");

		// get players and apply new bans
		array<const XmlElement@> players = getPlayers(m_metagame);
		for (uint i = 0; i < players.size(); ++i) {
			const XmlElement@ player = players[i];

			int id = player.getIntAttribute("player_id");
			if (id >= 0) {
				checkBan(player);
			}
		}
	}

	// --------------------------------------------
	protected void checkBan(const XmlElement@ player) {
		string hash = player.getStringAttribute("profile_hash");
		string ip = player.getStringAttribute("ip");
		int id = player.getIntAttribute("player_id");
		string sid = player.getStringAttribute("sid");
		string name = player.getStringAttribute("name");

		if (checkBanByName(name, id)) return;
		if (checkBanBySteamId(sid, id)) return;
		if (checkBanByIp(ip, id)) return;
	}

	// --------------------------------------------
	protected bool checkBanBySteamId(string sid, int id) {
		// if (m_requireSid) {
		// 	if (sid == "" || sid == "0" || sid == "ID0") {
		// 		_log("BanManager: sid required, player banned");
		// 		kickPlayer(id, "Kicked - Steam ID not found; try playing in Steam", false /* don't show rules in this case */);
		// 		return true;
		// 	}
		// }

		if (sid == "") return false;

		for (uint i = 0; i < m_steamIdList.size(); ++i) {
			string steamId = m_steamIdList[i];
			if (steamId == "") continue;

			if (sid == steamId) {
				_log("BanManager: banned player detected, steamid=" + sid  + " violated");
				kickPlayer(id, "Kicked - Steam ID banned");
				return true;
			}
		}
		return false;
	}

	// --------------------------------------------
	protected bool checkBanByName(string name, int id) {
		for (uint i = 0; i < m_usernameList.size(); ++i) {
			string pattern = m_usernameList[i];
			// TODO: not a pattern check anymore
			//if (pattern == name.toLowerCase()) {
			if (matchString(name, pattern)) {
				_log("BanManager: banned player detected, player=" + name + ", pattern " + pattern + " violated");
				kickPlayer(id, "Kicked - Username banned");
				return true;
			}
		}
		return false;
	}

	// --------------------------------------------
	protected bool checkBanByIp(string playerIp, int id) {
		if (playerIp == "") return false;

		for (uint i = 0; i < m_ipList.size(); ++i) {
			string ip = m_ipList[i];
			if (playerIp == ip) {
				_log("BanManager: banned player detected, ip=" + playerIp + " violated");
				kickPlayer(id, "Kicked - IP banned");
				return true;
			}
		}
		return false;
	}

    // ----------------------------------------------------
    protected void handleChatEvent(const XmlElement@ event) {
		Tracker::handleChatEvent(event);

		// player_id
		// player_name
		// message
		// global

		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		if (checkCommand(message, "refresh_ban")) {
			refresh();
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
}

