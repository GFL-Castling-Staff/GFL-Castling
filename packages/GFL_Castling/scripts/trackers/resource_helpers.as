// internal
#include "log.as"
#include "query_helpers.as"
#include "resource.as"
#include "call_sort.as"

// Originally created by WW2 DLC group
// Adapted by NetherCrow for Castling

// --------------------------------------------
void updateResources(array<const XmlElement@>@ calls, const array<Resource@>@ resourcesToChange, bool enabled, const array<string>@ sorting) {
	// combine enabled calls and calls to be enabled/disabled and sort them
	// - if to be disabled, simply remove from enabled, no sorting needed
	if (enabled) {
		// add
		for (uint i = 0; i < resourcesToChange.size(); ++i) {
			Resource@ r = resourcesToChange[i];
			XmlElement item(r.m_type);
			item.setStringAttribute("key", r.m_key);
			calls.insertLast(item);
		}

		// now sort
		array<const XmlElement@> sorted;
		for (uint i = 0; i < sorting.size(); ++i) {
			string sortKey = sorting[i];
			for (uint j = 0; j < calls.size(); ++j) {
				const XmlElement@ call = calls[j];
				if (call.getStringAttribute("key") == sortKey) {
					sorted.insertLast(call);
					break;
				}
			}
		}

		calls = sorted;
	} else {
		// remove
		for (uint i = 0; i < resourcesToChange.size(); ++i) {
			Resource@ r = resourcesToChange[i];
			for (uint j = 0; j < calls.size(); ++j) {
				const XmlElement@ call = calls[j];
				if (call.getStringAttribute("key") == r.m_key) {
					calls.removeAt(j);
					break;
				}
			}
		}
	}
}

// --------------------------------------------
void resetFactionCallResources(Metagame@ metagame, int factionId, const array<Resource@>@ resourcesToChange, bool enabled, const array<string>@ sorting) { 
	// get enabled calls from game
	array<const XmlElement@>@ calls = getFactionResources(metagame, factionId, "call", "calls");
	updateResources(calls, resourcesToChange, enabled, sorting);

	// clear and set enabled faction resouces in game
	XmlElement command("command");
	command.setStringAttribute("class", "faction_resources");
	command.setBoolAttribute("clear_calls", true);
	command.setIntAttribute("faction_id", factionId);
	for (uint i = 0; i < calls.size(); ++i) {
		const XmlElement@ call = calls[i];
		command.appendChild(call);
	}
	metagame.getComms().send(command);
}
