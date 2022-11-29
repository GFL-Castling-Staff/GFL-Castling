// internal
#include "tracker.as"
#include "log.as"
#include "query_helpers.as"

// Originally created by WW2 DLC group
// Adapted by NetherCrow for Castling

// --------------------------------------------
void addBlockRange(array<string>@ blocks, int range, string blockCoordinate) {
	array<string> strings = blockCoordinate.split(" ");
	if (strings.size() == 2) {
		// ok
		int x = parseInt(strings[0]);
		int z = parseInt(strings[1]);

		// doesn't matter if ix or iz becomes negative or goes out of block range,
		// game will just neglect invalid blocks
		for (int ix = x - range; ix <= x + range; ++ix) {
			for (int iz = z - range; iz <= z + range; ++iz) {
				string b = formatInt(ix) + " " + formatInt(iz);
				blocks.push_back(b);
			}
		}

	} else {
		// not ok
		_log("ERROR, failed to parse block coordinate from " + blockCoordinate);
	}
}

// --------------------------------------------
class SpawnInBaseCallHandler : Tracker {
	protected GameMode@ m_metagame;
	protected string m_listenCallKey;
	protected string m_targetCallKey;
	protected array<string> m_unacceptedBaseKeys;
	protected bool m_useGenericNodes;
	protected string m_nodeLayerName;
	protected string m_nodeTagName;
	protected bool m_boardcast;
	protected bool m_forcerefresh;

	// ----------------------------------------------------
	SpawnInBaseCallHandler(GameMode@ metagame, string listenCallKey, string targetCallKey, const array<string>@ unacceptedBaseKeys, bool useGenericNodes = false,bool boardcast=false,bool force=false,string nodeTagName = "", string nodeLayerName = ""){
		@m_metagame = @metagame;
		m_listenCallKey = listenCallKey;
		m_targetCallKey = targetCallKey;
		m_unacceptedBaseKeys = unacceptedBaseKeys; // copy
		m_useGenericNodes = useGenericNodes;
		m_nodeLayerName = nodeLayerName;
		m_nodeTagName = nodeTagName;
		m_boardcast = boardcast;
		m_forcerefresh = force;
	}

	// ----------------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// ----------------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// --------------------------------------------------------
	const XmlElement@ getClosestBaseAndPosition(const Vector3@ position, int factionId, float &out out_distance, Vector3 &out out_targetPosition,bool force_spawn = false) {
		const XmlElement@ result = null;
		array<const XmlElement@> baseList = getBases(m_metagame);
		if (baseList.size() > 0) {
			int closestBaseIndex = -1;
			float closestDistance = -1.0f;
			Vector3 closestTargetPosition;
			for (uint i = 0; i < baseList.size(); ++i) {
				const XmlElement@ base = baseList[i];
				if (m_unacceptedBaseKeys !is null && m_unacceptedBaseKeys.find(base.getStringAttribute("key")) >= 0) {
					// not accepted
					continue;
				}
				if (factionId >= 0 && base.getIntAttribute("owner_id") != factionId) {
					continue;
				}

				Vector3 basePosition = stringToVector3(base.getStringAttribute("position"));
				float distance = getPositionDistance(position, basePosition);
				if (closestDistance < 0.0 || distance < closestDistance) {
					// ensure that the block of basePosition doesn't have any enemies
					array<string> blocks;

					const int BLOCK_RANGE = 1; // -1 to +1, resulting in 3x3 area
					if (m_useGenericNodes) {
						// get closest generic node to base position matching layer and tag
						const XmlElement@ node = getClosestNode(m_metagame, basePosition, m_nodeLayerName, m_nodeTagName);
						if (node !is null) {
							basePosition = stringToVector3(node.getStringAttribute("position"));
							addBlockRange(blocks, BLOCK_RANGE, node.getStringAttribute("block"));
						}
					} else {
						addBlockRange(blocks, BLOCK_RANGE, base.getStringAttribute("block"));
					}

					if(force_spawn){
						closestDistance = distance;
						closestBaseIndex = i;
						closestTargetPosition = basePosition;						
					}

					else{
						bool safe = true;
						array<const XmlElement@>@ friend = getCharactersInBlocks(m_metagame, factionId, blocks);
						int friend_count  = friend.size();
						for (int enemyId = 0; enemyId < int(m_metagame.getFactionCount()); ++enemyId) {
							if (enemyId != factionId) {
								array<const XmlElement@>@ enemies = getCharactersInBlocks(m_metagame, enemyId, blocks);
								int enemies_count=enemies.size();
								if (enemies_count/(friend_count+enemies_count) > 0.33) {
									_log("base " + base.getStringAttribute("name") + " not safe, faction " + enemyId + " is in block");
									safe = false;
									break;
								}
							}
						}

						if (safe) {
							closestDistance = distance;
							closestBaseIndex = i;
							closestTargetPosition = basePosition;
						}
					}
				}
			}

			if (closestBaseIndex >= 0) {
				out_distance = closestDistance;
				out_targetPosition = closestTargetPosition;
				@result = baseList[closestBaseIndex];
			}
		}
		return result;
	}


	// ----------------------------------------------------
	protected void handleCallRequestEvent(const XmlElement@ event) {
		// _log("SpawnInBaseCallHandler, handleCallRequestEvent, key=" + event.getStringAttribute("call_key"), 1); 

		if (event.getStringAttribute("call_key") == m_listenCallKey) {
			Vector3 position = stringToVector3(event.getStringAttribute("target_position"));
			int factionId = event.getIntAttribute("faction_id");
			int callerId = event.getIntAttribute("character_id");
			if (factionId >= 0) {
				int baseId = -1;
				float distance = -1.0;

				Vector3 targetPosition;
				const XmlElement@ baseInfo = getClosestBaseAndPosition(position, factionId, distance, targetPosition,m_forcerefresh);
				if (baseInfo !is null) {
					dictionary a = {{"%base_name", baseInfo.getStringAttribute("name")}};
					sendFactionMessageKey(m_metagame, factionId, "spawn_in_base_call, accepted, key=" + m_listenCallKey,a);
					if(m_boardcast && factionId!=0){
						sendFactionMessageKey(m_metagame, 0, "spawn_in_base_call, alerted, key=" + m_listenCallKey,a);
					}
					XmlElement command("command");
					command.setStringAttribute("class", "create_call");
					command.setStringAttribute("key", m_targetCallKey);
					command.setStringAttribute("position", targetPosition.toString());
					command.setIntAttribute("faction_id", factionId);
					command.setIntAttribute("character_id", callerId);
					m_metagame.getComms().send(command);
					_log("生成call 坐标"+ targetPosition.toString());
				} else {
					// denied, no acceptable base found
					sendFactionMessageKey(m_metagame, factionId, "spawn_in_base_call, denied, key=" + m_listenCallKey);
				}
			}
		}
	}
}
