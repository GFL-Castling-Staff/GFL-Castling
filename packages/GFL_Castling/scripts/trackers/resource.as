#include "helpers.as"

// --------------------------------------------
class Resource {
	string m_type;
	string m_key;

	// --------------------------------------------
	Resource(string key, string type) {
		m_key = key;
		m_type = type;
	}
}

// --------------------------------------------
class ResourceChange {
	Resource@ m_resource;
	bool m_enabled;

	// --------------------------------------------
	ResourceChange(Resource@ resource, bool enabled) {
		@m_resource = @resource;
		m_enabled = enabled;
	}
};

// --------------------------------------------
XmlElement@ getFactionResourceChangeCommand(int factionId, const array<ResourceChange@>@ changes) {
	XmlElement command("command"); 
	command.setStringAttribute("class", "faction_resources"); 
	command.setIntAttribute("faction_id", factionId);

	for (uint i = 0; i < changes.size(); ++i) {
		ResourceChange@ rc = changes[i];
		addFactionResourceElements(command, rc.m_resource.m_type, array<string> = {rc.m_resource.m_key}, rc.m_enabled);
	}

	return command;
}
