// internal
#include "objective.as"
#include "admin_manager.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"

// generic trackers
#include "resource_unlocker.as"
#include "item_delivery_objective.as"

// --------------------------------------------
interface ItemDeliveryConfigurator {
	// --------------------------------------------
	void setup(ItemDeliveryOrganizer@ organizer);
	// --------------------------------------------
	void refresh();
};

// --------------------------------------------
class ItemDeliveryOrganizer {
	protected Metagame@ m_metagame;
	protected array<ItemDeliveryObjective@> m_objectives;
	protected int m_friendlyId;
	protected ItemDeliveryConfigurator@ m_configurator;

	// ----------------------------------------------------
	ItemDeliveryOrganizer(Metagame@ metagame, ItemDeliveryConfigurator@ configurator) {
		@m_metagame = @metagame;
		m_friendlyId = 0;
		@m_configurator = @configurator;
	}

	// ----------------------------------------------------
	void addObjective(ItemDeliveryObjective@ objective) {
		m_objectives.insertLast(objective);
	}

	// ----------------------------------------------------
	void init() {
		_log("ItemDeliveryOrganizer::init", 1);

		m_configurator.setup(this);

		_log("ItemDeliveryOrganizer, objectives " + m_objectives.size(), 1);
	}

	// ----------------------------------------------------
	void start() {
	}

	// ----------------------------------------------------
	void matchStarted() {
		_log("ItemDeliveryOrganizer::matchStarted", 1);

		for (uint i = 0; i < m_objectives.size(); ++i) {
			ItemDeliveryObjective@ objective = m_objectives[i];
			m_metagame.addTracker(objective);
		}
	}

	// ----------------------------------------------------
	void refresh() {
		m_configurator.refresh();
	}

	// ----------------------------------------------------
	void objectiveEnded(ItemDeliveryObjective@ objective) {
		int index = m_objectives.findByRef(objective);
		if (index >= 0) {
			_log("removing item objective " + index, 1);
			m_objectives.erase(index);
		} else {
			_log("WARNING, ended item objective not found in organizer list of objectives", -1);
		}
	}

	// --------------------------------------------
	void save(XmlElement@ root) {
		XmlElement@ parent = root;
		XmlElement subroot("item_delivery_organizer");
		_log("saving ItemDeliveryOrganizer", 1);
		for (uint i = 0; i < m_objectives.size(); ++i) {
			ItemDeliveryObjective@ objective = m_objectives[i];
			XmlElement e("item");
			e.setStringAttribute("id", objective.getId());
			e.setIntAttribute("amount", objective.getDeliveryAmount());
			subroot.appendChild(e);
		}
		parent.appendChild(subroot);
	}

	// --------------------------------------------
	void load(const XmlElement@ root) {
		_log("loading ItemDeliveryOrganizer", 1);
		// we'll just load the amounts and override the initially created objectives, and their amounts
		const XmlElement@ subroot = root.getFirstElementByTagName("item_delivery_organizer");
		if (subroot !is null) {
			_log("item_delivery_organizer found", 1);
			array<const XmlElement@> items = subroot.getElementsByTagName("item");
			for (uint i = 0; i < items.size(); ++i) {
				const XmlElement@ e = items[i];
				string id = e.getStringAttribute("id");
				int amount = e.getIntAttribute("amount");
				
				ItemDeliveryObjective@ objective = getObjectiveById(id);
				if (objective !is null) {
					objective.setDeliveryAmount(amount);
				}
			}
		}
	}

	// ----------------------------------------------------
	ItemDeliveryObjective@ getObjectiveById(string id) const {
		for (uint i = 0; i < m_objectives.size(); ++i) {
			ItemDeliveryObjective@ objective = m_objectives[i];
			if (objective.getId() == id) {
				return objective;
			}
		}
		return null;
	}
}
