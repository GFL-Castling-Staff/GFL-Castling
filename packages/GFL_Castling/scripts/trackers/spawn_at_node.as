// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"

#include "gift_item_delivery_rewarder.as"

// --------------------------------------------
class SpawnAtNode : Tracker {
	protected Metagame@ m_metagame;
	protected bool m_started;
	protected array<ScoredResource@> m_resources;
	protected int m_spawnCount;
	protected string m_genericNodeTag;
	protected int m_factionId;

	// --------------------------------------------
	SpawnAtNode(Metagame@ metagame, const array<ScoredResource@>@ resources, string genericNodeTag, int factionId, int count = 1) {
		@m_metagame = @metagame;

		m_resources = resources;
		normalizeScoredResources(m_resources);

		m_genericNodeTag = genericNodeTag;
		m_factionId = factionId;
		m_spawnCount = count;

		m_started = false;
	}

	// --------------------------------------------
	void gameContinuePreStart() {
		// on_game_continue_pre_start happens before start
		
		// it basically allows us to have trackers that are run only once in the beginning of a match, not at all when it is loaded into by continuing a savegame

		// the spawner tracker is certainly set up so that it fits, it only spawns extra troops at the start of a match

		// to skip processing start function which contains all the logic, we set the tracker started at this point already,
		// the metagame won't then call start at all
		m_started = true;
	}
	
	// --------------------------------------------
	void start() {
		_log("starting SpawnAtNode tracker with tag " + m_genericNodeTag, 1);

		string layerName = "";
		array<const XmlElement@>@ nodes = getGenericNodes(m_metagame, layerName, m_genericNodeTag);

		_log("  spawn count=" + m_spawnCount + ", nodes=" + nodes.size(), 1);
		for (int i = 0; i < m_spawnCount && nodes.size() > 0; ++i) {
			ScoredResource@ r = getRandomScoredResource(m_resources);

			if (r.m_key == "") {
				continue;
			}

			XmlElement command("command");
			command.setStringAttribute("class", "create_instance");
			command.setIntAttribute("faction_id", m_factionId);
			command.setStringAttribute("instance_class", r.m_type);
			command.setStringAttribute("instance_key", r.m_key);
			
			int index = rand(0, nodes.size() - 1);
			const XmlElement@ node = nodes[index];
			nodes.erase(index);

			command.setStringAttribute("position", node.getStringAttribute("position"));
			command.setStringAttribute("orientation", node.getStringAttribute("orientation"));
			m_metagame.getComms().send(command);
		}

		m_started = true;
	}

	// --------------------------------------------
	void onRemove() {
		// make start() called again if the tracker is added again, like for restart
		m_started = false;
	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}
}
