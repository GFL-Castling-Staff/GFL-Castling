// internal
#include "comms.as"
#include "metagame.as"
#include "resource.as"

// --------------------------------------------------------
dictionary makeQuery(const Metagame@ metagame, array<dictionary> elements) {
	dictionary dict = {
		{"TagName",	"command"}, {"class", "make_query"}, {"id", metagame.getComms().getQueryUid()}, {"Children", elements}
	};
	return dict;
}

// --------------------------------------------------------
const XmlElement@ getGenericObjectInfo(const Metagame@ metagame, string className, int instanceId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", className}, {"id", instanceId} } 
		}));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getFirstElementByTagName(className);
	}
	return null;
}

// --------------------------------------------------------
array<const XmlElement@>@ getGenericObjectList(const Metagame@ metagame, string queryClassName, string className) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", queryClassName} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getElementsByTagName(className);
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
const XmlElement@ getVehicleInfo(const Metagame@ metagame, int vehicleId) {
	return getGenericObjectInfo(metagame, "vehicle", vehicleId);
}

// --------------------------------------------------------
array<const XmlElement@>@ getVehicles(const Metagame@ metagame, int factionId, string vehicleKey) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "vehicles"}, {"faction_id", factionId}, {"key", vehicleKey} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getElementsByTagName("vehicle");
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
array<const XmlElement@>@ getFactions(const Metagame@ metagame) {
	return getGenericObjectList(metagame, "factions", "faction");
}

// --------------------------------------------------------
const XmlElement@ getFactionInfo(const Metagame@ metagame, int factionId) {
	return getGenericObjectInfo(metagame, "faction", factionId);
}

// --------------------------------------------------------
array<const XmlElement@>@ getPlayers(const Metagame@ metagame) {
	return getGenericObjectList(metagame, "players", "player");
}

// --------------------------------------------------------
const XmlElement@ getPlayerInfo(const Metagame@ metagame, int playerId) {
	array<const XmlElement@> players = getGenericObjectList(metagame, "players", "player");

	const XmlElement@ player = null;
	for (uint i = 0; i < players.size(); ++i) {
		const XmlElement@ info = players[i];
		if (info.getIntAttribute("player_id") == playerId) {
			@player = info;
			break;
		}
	}

	return player;
}

// --------------------------------------------
const XmlElement@ findPlayerByName(Metagame@ metagame, string name) {
	const XmlElement@ result = null;
	
	array<const XmlElement@> playerList = getPlayers(metagame);

	// go through the player list and match for the given name
	int playerId = -1;
	for (uint i = 0; i < playerList.size(); ++i) {
		const XmlElement@ player = playerList[i];
		string name2 = player.getStringAttribute("name");
		// case insensitive
		if (name2.toLowerCase() == name.toLowerCase()) {
			// found it
			@result = @player;
			break;
		}
	}
	
	return result;
}

// --------------------------------------------
const XmlElement@ findPlayerById(Metagame@ metagame, int playerId) {
	return getPlayerInfo(metagame, playerId);
}	

// --------------------------------------------
const XmlElement@ getPlayerByIdOrNameFromCommand(Metagame@ metagame, string message, bool id) {
	string s = message.substr(message.findFirst(" ")+1);
	const XmlElement@ player = null;
	if (id) {
		int playerId = parseInt(s);
		// warning, id is 0 if parsing fails, check it again
		if (playerId == 0 && s != "0") {
			// cancel
			//sendPrivateMessage(m_metagame, senderId, "not a number? " + s);
			return player;
		}
		@player = findPlayerById(metagame, playerId);
	} else {
		string name = s;
		@player = findPlayerByName(metagame, name);
	}
	return player;
}

// --------------------------------------------------------
const XmlElement@ getCharacterInfo(const Metagame@ metagame, int characterId) {
	return getGenericObjectInfo(metagame, "character", characterId);
}

// --------------------------------------------------------
array<const XmlElement@>@ getBases(const Metagame@ metagame) {
	return getGenericObjectList(metagame, "bases", "base");
}

// --------------------------------------------------------
const XmlElement@ getClosestBase(const Metagame@ metagame, const Vector3@ position, float &out out_distance, int factionId = -1, const array<string>@ unacceptedBaseKeys = null) {
	const XmlElement@ result = null;
	array<const XmlElement@> baseList = getBases(metagame);
	if (baseList.size() > 0) {
		int closestBaseIndex = -1;
		float closestDistance = -1.0f;
		for (uint i = 0; i < baseList.size(); ++i) {
			const XmlElement@ base = baseList[i];
			if (unacceptedBaseKeys && unacceptedBaseKeys.find(base.getStringAttribute("key")) >= 0) {
				// not accepted
				continue;
			}
			if (factionId >= 0 && base.getIntAttribute("owner_id") != factionId) {
				continue;
			}

			Vector3 basePosition = stringToVector3(base.getStringAttribute("position"));
			float distance = getPositionDistance(position, basePosition);
			if (closestDistance < 0.0 || distance < closestDistance) {
				closestDistance = distance;
				closestBaseIndex = i;
			}
		}
		if (closestBaseIndex >= 0) {
			out_distance = closestDistance;
			@result = baseList[closestBaseIndex];
		}
    }
	return result;
}

// --------------------------------------------------------
const XmlElement@ getClosestNode(const Metagame@ metagame, const Vector3@ position, string layerName, string tagName) {
	const XmlElement@ result = null;
	array<const XmlElement@> nodeList = getGenericNodes(metagame, layerName, tagName);
	if (nodeList.size() > 0) {
		int closestNodeIndex = -1;
		float closestDistance = -1.0f;
		for (uint i = 0; i < nodeList.size(); ++i) {
			const XmlElement@ node = nodeList[i];

			Vector3 nodePosition = stringToVector3(node.getStringAttribute("position"));
			float distance = getPositionDistance(position, nodePosition);
			if (closestDistance < 0.0 || distance < closestDistance) {
				closestDistance = distance;
				closestNodeIndex = i;
			}
		}
		if (closestNodeIndex >= 0) {
			@result = nodeList[closestNodeIndex];
		}
    }
	return result;
}

// --------------------------------------------------------
const XmlElement@ getStartingBase(const Metagame@ metagame, int factionId) {
    array<const XmlElement@> baseList = getBases(metagame);
	for (uint i = 0; i < baseList.size(); ++i) {
		const XmlElement@ base = baseList[i];
		int ownerId = base.getIntAttribute("owner_id");
		if (ownerId == factionId) {
			// assume the first base is the one we are looking for
			return base;
		}
	}

	return null;
}

// --------------------------------------------------------
const XmlElement@ getBase(array<const XmlElement@>@ baseList, int baseId) {
	for (uint i = 0; i < baseList.size(); ++i) {
		const XmlElement@ base = baseList[i];
		int id = base.getIntAttribute("id");
		if (baseId == id) {
			return base;
		}
	}
	return null;
}

// --------------------------------------------------------
const XmlElement@ getBase(const Metagame@ metagame, int baseId) {
    array<const XmlElement@> baseList = getBases(metagame);
	return getBase(baseList, baseId);
}

// ----------------------------------------------------
int getBasesForFaction(const Metagame@ metagame, int factionId) {
	array<const XmlElement@> baseList = getBases(metagame);
	int bases = 0;
	// go through list of bases
	for (uint i = 0; i < baseList.size(); ++i) {
		const XmlElement@ base = baseList[i];
		if (base.getIntAttribute("owner_id") == factionId) {
			bases++;
		}
	}
	return bases;
}

// --------------------------------------------------------
const XmlElement@ getGeneralInfo(const Metagame@ metagame) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "general"} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getFirstElementByTagName("general");
	}
	return null;
}

// --------------------------------------------------------
void lockVehicle(const Metagame@ metagame, int vehicleId) {
	string command =
		"<command class='update_vehicle' id='" + vehicleId + "' locked='1'>\n" +
		"</command>";
	metagame.getComms().send(command);
}

// --------------------------------------------------------
void removeVehicle(const Metagame@ metagame, int vehicleId) {
	string command =
		"<command class='remove_vehicle' id='" + vehicleId + "'>\n" +
		"</command>";
	metagame.getComms().send(command);
}

// --------------------------------------------------------
void destroyVehicle(const Metagame@ metagame, int vehicleId) {
	string command =
		"<command class='update_vehicle' id='" + vehicleId + "' health='-1.0'>\n" +
		"</command>";
	metagame.getComms().send(command);
}

// --------------------------------------------------------
int getPlayerCount(const Metagame@ metagame) {
	return getPlayers(metagame).size();
}

// --------------------------------------------------------
array<const XmlElement@>@ getCharacters(const Metagame@ metagame, int factionId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "characters"}, {"faction_id", factionId} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getElementsByTagName("character");
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
array<const XmlElement@>@ getCharactersInBlocks(const Metagame@ metagame, int factionId, array<string>@ blocks) {
	array<dictionary> blockElements;
	for (uint i = 0; i < blocks.size(); ++i) {
		dictionary dict = {{"TagName", "block"}, {"id", blocks[i]}};
		blockElements.push_back(dict);
	}

	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "characters"}, {"faction_id", factionId}, {"Children", blockElements}} 
		}));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getElementsByTagName("character");
	}
	array<const XmlElement@> empty;
	return @empty;

}

// --------------------------------------------------------
array<const XmlElement@>@ getGenericNodes(const Metagame@ metagame, string layerName = "", string tag = "", string id = "") {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "generic_nodes"}, {"layer_name", layerName}, 
						   {"tag", tag}, {"id", id} }
		}));

	const XmlElement@ doc = metagame.getComms().query(query);
	// just write:
	// if doc {}
	if (doc) {
		return doc.getElementsByTagName("generic_node");
	}
	array<const XmlElement@> empty;
	return @empty;
}



// -------------------------------------------------------
void sendPrivateMessage(const Metagame@ metagame, int playerId, string text, string pos = "") {
	_log(" * private message to " + playerId + ": " + text, 1);

	XmlElement command("command");
	command.setStringAttribute("class", "chat");
	command.setStringAttribute("text", text);
	command.setIntAttribute("player_id", playerId);

/*	
	string command =
			"<command class='chat'\n" +
			"  text='" + text + "'\n" +
			"  player_id='" + playerId + "'\n";
	if (pos != "") {
		command +=
			"  position='" + pos + "'\n";
	}
*/

	if (pos != "") {
		command.setStringAttribute("position", pos);
	}

	metagame.getComms().send(command);
}

// -------------------------------------------------------
void sendPrivateMessageKey(const Metagame@ metagame, int playerId, string key, dictionary@ replacements = dictionary(), string pos = "") {
	// NOTE: we use first faction id here to pick the keyed comment
	// - thus it might work wrong in other context than invasion, if factions have faction specific keyed comments
	int factionId = 0;

	_log(" * private message to " + playerId + ": " + key, 1);
	/*
	string command =
			"<command class='chat'\n" +
			"  key='" + key + "'\n" +
			"  faction_id='" + factionId + "'\n" +
			"  player_id='" + playerId + "'\n";
	if (pos != "") {
		command +=
			"  position='" + pos + "'\n";
	}
	command += ">\n";
*/
	XmlElement command("command");
	command.setStringAttribute("class", "chat");
	command.setStringAttribute("key", key);
	command.setIntAttribute("faction_id", factionId);
	command.setIntAttribute("player_id", playerId);
	if (pos != "") {
		command.setStringAttribute("position", pos);
	}
	handleReplacements(command, replacements);

	metagame.getComms().send(command);
}

// -------------------------------------------------------
void sendFactionMessage(const Metagame@ metagame, int factionId, string text, double priority = 0.9) {
	_log(" * faction message to " + factionId + ": " + text, 1);
	XmlElement command("command");
	command.setStringAttribute("class", "chat");
	command.setStringAttribute("text", text);
	command.setFloatAttribute("priority", priority);
	command.setIntAttribute("faction_id", factionId);
	metagame.getComms().send(command);
}


// -------------------------------------------------------
// old, avoid using
string handleReplacements(dictionary@ replacements) {
	string command;
	for (uint i = 0; i < replacements.getKeys().size(); ++i) {
		string key = replacements.getKeys()[i];
		string value;
		replacements.get(key, value);
		command += "<replacement key='" + key + "' text='" + value + "' />";
	}
	return command;
}

// -------------------------------------------------------
void handleReplacements(XmlElement@ command, dictionary@ replacements) {
	for (uint i = 0; i < replacements.getKeys().size(); ++i) {
		string key = replacements.getKeys()[i];
		string value;
		replacements.get(key, value);
		
		//command += "<replacement key='" + key + "' text='" + value + "' />";

		XmlElement replacement("replacement");
		replacement.setStringAttribute("key", key);
		replacement.setStringAttribute("text", value);
		
		command.appendChild(replacement);
	}
}

// -------------------------------------------------------
// default priority < 1.0: user can control "amount" of commander messages to show, 1.0 priority goes through regardless of the user settings
void sendFactionMessageKey(const Metagame@ metagame, int factionId, string key, dictionary@ replacements = dictionary(), double priority = 0.9) {
	_log(" * faction message to " + factionId + ": " + key, 1);
	/*
	string command =
		"<command class='chat'\n" +
		"  key='" + key + "'\n" +
		"  priority='" + priority + "'\n" +
		"  faction_id='" + factionId + "'>\n";
	*/	
	XmlElement command("command");
	command.setStringAttribute("class", "chat");
	command.setStringAttribute("key", key);
	command.setFloatAttribute("priority", priority);
	command.setIntAttribute("faction_id", factionId);

	handleReplacements(command, replacements);

	metagame.getComms().send(command);
}

// -------------------------------------------------------
void sendFactionMessageKeySaidAsCharacter(const Metagame@ metagame, int factionId, int characterId, string key, dictionary@ replacements = dictionary(), double priority = 0.9) {
	_log(" * faction message to " + factionId + " as character " + characterId + ": " + key, 1);

	/*
	string command =
		"<command class='chat'\n" +
		"  key='" + key + "'\n" +
		"  priority='" + priority + "'\n" +
		"  said_as_character_id='" + characterId + "'\n" +
		"  faction_id='" + factionId + "'>\n";
*/

	XmlElement command("command");
	command.setStringAttribute("class", "chat");
	command.setStringAttribute("key", key);
	command.setFloatAttribute("priority", priority);
	command.setIntAttribute("faction_id", factionId);
	command.setIntAttribute("said_as_character_id", characterId);

	handleReplacements(command, replacements);

	metagame.getComms().send(command);
}

// -------------------------------------------------------
void notify(const Metagame@ metagame, string key, dictionary@ replacements = dictionary(), string dict = "", int playerId = -1, bool alert = false, string titleKey = "", float priority = 1.0, float width = -1.0) {
	_log(" * notification message: " + key, 1);

	//string command = "command class='notify' dict='" + dict + "' key='" + key + "'>";
	
	XmlElement command("command");
	command.setStringAttribute("class", "notify");
	command.setStringAttribute("dict", dict);
	command.setStringAttribute("key", key);
	command.setIntAttribute("player_id", playerId);
	command.setBoolAttribute("alert", alert);
	command.setStringAttribute("title_key", titleKey);
	command.setFloatAttribute("priority", priority);
	command.setFloatAttribute("width", width);
	
	handleReplacements(command, replacements);

	metagame.getComms().send(command);
}

// -------------------------------------------------------
array<const XmlElement@>@ getHitboxes(const Metagame@ metagame) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "hitboxes"} } }));
	
	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		array<const XmlElement@> hitboxes = doc.getElementsByTagName("hitbox");
		return hitboxes;
	}
	array<const XmlElement@> empty;
	return @empty;
}

array<const XmlElement@>@ getVehiclePoint(const Metagame@ metagame) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "spawns"} } }));
	
	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		array<const XmlElement@> hitboxes = doc.getElementsByTagName("spawn");
		return hitboxes;
	}
	array<const XmlElement@> empty;
	return @empty;
}

// -------------------------------------------------------
array<const XmlElement@>@ getArmoryHitboxes(const Metagame@ metagame, int factionId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "hitboxes"}, {"faction_id", factionId} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		array<const XmlElement@> armoryList = doc.getElementsByTagName("hitbox");

		// go through the list and only leave the ones in we're interested of, i.e. weapon racks = armories
		for (uint i = 0; i < armoryList.size(); ++i) {
			const XmlElement@ hitboxNode = armoryList[i];
			string id = hitboxNode.getStringAttribute("id");
			// rule out those that have stash in id
			// - every specifically made up hitbox and weapon_rack hitbox are allowed
			if (id.findFirst("stash") < 0 &&
				id.findFirst("extraction") < 0) {
				_log("including " + id, 1);
			} else {
				_log("ruling out " + id, 1);
				// remove this
				armoryList.erase(i);
				i--;
			}
		}
		_log("* " + armoryList.size() + " armories found", 1);
		return armoryList;
	}
	array<const XmlElement@> empty;
	return @empty;
}

// -------------------------------------------------------
array<const XmlElement@>@ getArmoryList(const Metagame@ metagame, int factionId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "item_containers"}, {"faction_id", factionId} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		array<const XmlElement@> armoryList = doc.getElementsByTagName("item_container");

		// go through the list and only leave the ones in we're interested of, i.e. weapon racks = armories
		for (uint i = 0; i < armoryList.size(); ++i) {
			const XmlElement@ node = armoryList[i];
			int typeId = node.getIntAttribute("type_id");
			string pos = node.getStringAttribute("position");
			// 1 is armory, 3 is personal stash
			if (typeId == 1) {
				_log("including " + pos, 1);
			} else {
				_log("ruling out " + pos, 1);
				// remove this
				armoryList.erase(i);
				// one step back
				i--;
			}
		}
		_log("* " + armoryList.size() + " armories found", 1);
		return armoryList;
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
array<const XmlElement@>@ getCharactersNearPosition(const Metagame@ metagame, const Vector3@ position, int factionId, float range = 80.0f) {
	array<const XmlElement@> characters;

	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "characters"}, {"faction_id", factionId}, 
						   {"position", position.toString()}, {"range", range} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		characters = doc.getElementsByTagName("character");
		return characters;
	}
	array<const XmlElement@> empty;
	return @empty;
}

array<const XmlElement@>@ getCharactersNearPosition2(const Metagame@ metagame, const Vector3@ position,float range = 80.0f) {
	array<const XmlElement@> characters;

	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "characters"}, 
						   {"position", position.toString()}, {"range", range} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		characters = doc.getElementsByTagName("character");
		return characters;
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
array<const XmlElement@>@ getCharactersNearVehicle(const Metagame@ metagame, int vehicleId, int factionId) {
	array<const XmlElement@>@ characters;

	const XmlElement@ vehicleInfo = getVehicleInfo(metagame, vehicleId);
	if (vehicleInfol) {
		Vector3 position = stringToVector3(vehicleInfo.getStringAttribute("position"));
		@characters = getCharactersNearPosition(metagame, position, factionId);
	} else {
		_log("WARNING, getting vehicle info for " + vehicleId + " failed", -1);
	}

	return characters;
}

void killCharactersNearPosition(Metagame@ metagame, const Vector3@ position, int factionId, float range) {
	array<const XmlElement@>@ list = getCharactersNearPosition(metagame, position, factionId, range);
	for (uint j = 0; j < list.size(); ++j) {
		killCharacter(metagame, list[j].getIntAttribute("id"));
	}
}

void killCharacter(Metagame@ metagame, int characterId, bool preserveItems = false) {
	string command = "<command class='update_character' id='" + characterId + "' dead='1' preserve_items='" + (preserveItems ? 1 : 0) + "' />";
	metagame.getComms().send(command);
}

// --------------------------------------------------------
// $type_str1 = "weapon", "grenade", "carry_item" ("vehicle", "call") 
// $type_str2 = "weapons", "grenades", "carry_items" ("vehicles", "calls") 
array<const XmlElement@>@ getFactionResources(const Metagame@ metagame, int factionId, string typeStr1, string typeStr2, string soldierGroup = "default") {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "resources"}, {"faction_id", factionId}, {"soldier_group_name", soldierGroup},
						   {typeStr2, "1"} } }));

	const XmlElement@ doc = metagame.getComms().query(query);

	array<const XmlElement@> list;
	if (doc) {
		list = doc.getElementsByTagName(typeStr1);
		_log("* " + list.size() + " " + typeStr1 + " resources found in faction " + factionId + ", soldierg group " + soldierGroup, 1);
	}
	return list;
}

// renamed function, old provided for backwards compatibility
array<const XmlElement@>@ getFactionDeliverables(const Metagame@ metagame, int factionId, string typeStr1, string typeStr2) {
	return getFactionResources(metagame, factionId, typeStr1, typeStr2);
}

// --------------------------------------------------------
// $type_str1 = "weapon", "grenade", "carry_item" ("vehicle", "call") 
const XmlElement@ getResource(const Metagame@ metagame, string key, string typeStr1) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "resource"}, {typeStr1 + "_key", key} } }));

	const XmlElement@ doc = metagame.getComms().query(query);
	
	const XmlElement@ r = null;
	if (doc) {
		@r = doc.getFirstElementByTagName(typeStr1);
	}

	return r;
}

// --------------------------------------------------------
string getResourceName(const Metagame@ metagame, string key, string typeStr1) {
	string name = "";
	const XmlElement@ r = getResource(metagame, key, typeStr1);
	if (r) {
		name = r.getStringAttribute("name");
	}
	return name;
}

// -------------------------------------------------------
void associateHitboxes(const Metagame@ metagame, const array<const XmlElement@>@ armoryList, string instanceType, int instanceId, array<string>@ trackedHitboxes) {
	array<string> addIds;
	associateHitboxesEx(metagame, armoryList, instanceType, instanceId, trackedHitboxes, addIds);
}

// -------------------------------------------------------
void associateHitboxesEx(const Metagame@ metagame, const array<const XmlElement@>@ armoryList, string instanceType, int instanceId, array<string>@ trackedHitboxes, array<string>@ addIds) {
	if (instanceId < 0) return;

	// check against already associated hitboxes
	// and determine which need to be added and which to removed

	// prepare to remove all hitboxes
	array<string> removeIds = trackedHitboxes;

	for (uint i = 0; i < armoryList.size(); ++i) {
		const XmlElement@ armory = armoryList[i];
		string armoryId = armory.getStringAttribute("id");

		int index = removeIds.find(armoryId);
		if (index >= 0) {
			// already tracked and still needed
			// remove from ids to remove
			removeIds.erase(index);
		} else {
			// not yet tracked, needs to be added
			addIds.push_back(armoryId);
		}
	}

	for (uint i = 0; i < removeIds.size(); ++i) {
		string id = removeIds[i];
		string command = "<command class='remove_hitbox_check' id='" + id + "' instance_type='" + instanceType + "' instance_id='" + instanceId + "' />";
		metagame.getComms().send(command);
		trackedHitboxes.erase(trackedHitboxes.find(id));
	}

	for (uint i = 0; i < addIds.size(); ++i) {
		string id = addIds[i];
		string command = "<command class='add_hitbox_check' id='" + id + "' instance_type='" + instanceType + "' instance_id='" + instanceId + "' />";
		metagame.getComms().send(command);

		// remember we've set out to track this armory 
		trackedHitboxes.push_back(id);
	}
}

// ----------------------------------------------------
void clearHitboxAssociations(const Metagame@ metagame, string instanceType, int instanceId, array<string>@ trackedHitboxes) {
	if (instanceId < 0) return;

	// remove all tracked hitboxes
	for (uint i = 0; i < trackedHitboxes.size(); ++i) {
		string id = trackedHitboxes[i];
		string command = "<command class='remove_hitbox_check' id='" + id + "' instance_type='" + instanceType + "' instance_id='" + instanceId + "' />";
		metagame.getComms().send(command);
	}
	
	trackedHitboxes.clear();
}

// --------------------------------------------
array<string>@ loadStringsFromFile(const Metagame@ metagame, string filename, string itemName = "item", string valueName = "value") {
	array<string> result;
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", filename}, {"location", "app_data"} } }));
	const XmlElement@ doc = metagame.getComms().query(query);

	if (doc) {
		const XmlElement@ root = doc.getFirstChild();
		if (root) {
			array<const XmlElement@> items = root.getElementsByTagName(itemName);
			for (uint i = 0; i < items.size(); ++i) {
				const XmlElement@ item = items[i];
				result.insertLast(item.getStringAttribute(valueName));
			}
		}
	}
	return result;
}

array<string>@ loadStringsFromSaveFile(const Metagame@ metagame, string filename, string itemName = "item", string valueName = "value") {
	array<string> result;
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", filename} } }));
	const XmlElement@ doc = metagame.getComms().query(query);

	if (doc) {
		const XmlElement@ root = doc.getFirstChild();
		if (root) {
			array<const XmlElement@> items = root.getElementsByTagName(itemName);
			for (uint i = 0; i < items.size(); ++i) {
				const XmlElement@ item = items[i];
				result.insertLast(item.getStringAttribute(valueName));
			}
		}
	}
	return result;
}

// --------------------------------------------
void addFactionResourceElements(XmlElement@ command, string type, const array<string>@ keys, bool enabled) {
	for (uint i = 0; i < keys.size(); ++i) {
		XmlElement item(type);
		item.setStringAttribute("key", keys[i]);
		item.setBoolAttribute("enabled", enabled);
		command.appendChild(item);
	}
}

// --------------------------------------------
void addItemInBackpack(Metagame@ metagame, int characterId, const Resource@ r) {
	string c = 
		"<command class='update_inventory' character_id='" + characterId + "' container_type_class='backpack'>" + 
			"<item class='" + r.m_type + "' key='" + r.m_key + "' />" +
		"</command>";
	metagame.getComms().send(c);
}

// ----------------------------------------------------
XmlElement@ makeFactionResourceChangeCommand(int factionId, const Resource@ resource, bool add) {
	XmlElement command("command");
	command.setStringAttribute("class", "faction_resources");
	command.setIntAttribute("faction_id", factionId);
	addFactionResourceElements(command, resource.m_type, array<string> = {resource.m_key}, add);
	return command;
}

// ----------------------------------------------------
void addCustomStatToAllPlayers(Metagame@ metagame, string tag) {
	array<const XmlElement@> players = getPlayers(metagame);
	for (uint i = 0; i < players.size(); ++i) {
		const XmlElement@ player = players[i];
		int characterId = player.getIntAttribute("character_id");
		if (characterId >= 0) {
			string c = "<command class='add_custom_stat' character_id='" + characterId + "' tag='" + tag + "' />";
			metagame.getComms().send(c);
		}
	}
}

void addCustomStatToPlayers(Metagame@ metagame, string tag ,int playerId) {
	const XmlElement@ player = getPlayerInfo(metagame,playerId);
	int characterId = player.getIntAttribute("character_id");
	if (characterId >= 0) {
		string c = "<command class='add_custom_stat' character_id='" + characterId + "' tag='" + tag + "' />";
		metagame.getComms().send(c);
	}
}

void addCustomStatToCharacter(Metagame@ metagame, string tag ,int characterId) {
	if (characterId >= 0) {
		string c = "<command class='add_custom_stat' character_id='" + characterId + "' tag='" + tag + "' />";
		metagame.getComms().send(c);
	}
}

// -------------------------------------------------------
void playSound(const Metagame@ metagame, string filename, int factionId,float volume=1.0) {
	XmlElement command("command");
	command.setStringAttribute("class", "play_sound");
	command.setStringAttribute("filename", filename);
	command.setIntAttribute("faction_id", factionId);
	command.setFloatAttribute("volume", volume);
	// TODO: can also do private sounds with player_id, extend
	metagame.getComms().send(command);
}

// -------------------------------------------------------
void playObjectiveCompleteSound(const Metagame@ metagame, int factionId) {
	playSound(metagame, "objective_complete.wav", factionId);
}

// --------------------------------------------
bool hasFactionComms(const Metagame@ metagame, int factionId) {
	const XmlElement@ faction = getFactionInfo(metagame, factionId);
	if (faction) {
		return faction.getBoolAttribute("comms_status");
	}
	return true;
}

// --------------------------------------------
void kickPlayer(Metagame@ metagame, int playerId) {
	string command = "<command class='kick_player' player_id='" + playerId + "' />";
	metagame.getComms().send(command);
}
