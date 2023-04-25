
// --------------------------------------------------------
array<const XmlElement@>@ getAllVehicles(const Metagame@ metagame, int factionId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "vehicles"}, {"faction_id", factionId}}}));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getElementsByTagName("vehicle");
	}
	array<const XmlElement@> empty;
	return @empty;
}

// --------------------------------------------------------
void unlockVehicle(const Metagame@ metagame, int vehicleId) {
	string command =
		"<command class='update_vehicle' id='" + vehicleId + "' locked='0'>\n" +
		"</command>";
	metagame.getComms().send(command);
}

// --------------------------------------------------------
const XmlElement@ getCharacterInfo2(const Metagame@ metagame, int characterId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "character"}, {"id", characterId}, {"include_equipment", 1}}}));

	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
		return doc.getFirstElementByTagName("character"); //.getElementsByTagName("item")
	}
	return null;
}

// ----------------------------------------------------
array<const XmlElement@>@ getSoldierGroups(Metagame@ metagame, int factionId) {
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "soldier_groups"}, {"faction_id", factionId}}}));
	const XmlElement@ doc = metagame.getComms().query(query);
	if (doc) {
	return doc.getElementsByTagName("soldier_group");
	}
	array<const XmlElement@> empty;
	return @empty;
}