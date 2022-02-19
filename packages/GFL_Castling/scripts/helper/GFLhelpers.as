#include "query_helpers2.as"
#include "helpers.as"

void playSoundAtLocation(const Metagame@ metagame, string filename, int factionId, const Vector3@ position, float volume=1.0) {
	XmlElement command("command");
	command.setStringAttribute("class", "play_sound");
	command.setStringAttribute("filename", filename);
	command.setIntAttribute("faction_id", factionId);
	command.setFloatAttribute("volume", volume);
	command.setStringAttribute("position", position.toString());
	metagame.getComms().send(command);
}

void playSoundAtLocation(const Metagame@ metagame, string filename, int factionId, string position, float volume=1.0) {
	XmlElement command("command");
	command.setStringAttribute("class", "play_sound");
	command.setStringAttribute("filename", filename);
	command.setIntAttribute("faction_id", factionId);
	command.setFloatAttribute("volume", volume);
	command.setStringAttribute("position", position);
	metagame.getComms().send(command);
}

void editPlayerVest(const Metagame@ metagame, int characterId, string Itemkey, uint numVests){
	if (numVests < 1) return;
		XmlElement c("command");
			c.setStringAttribute("class", "update_inventory");
			c.setIntAttribute("character_id", characterId);
			c.setIntAttribute("container_type_id", numVests); 
			XmlElement item("item");
			item.setStringAttribute("class", "carry_item");
			item.setStringAttribute("key", Itemkey);
			c.appendChild(item);
		metagame.getComms().send(c);
}

void editPlayerNade(const Metagame@ metagame, int characterId, string Itemkey, uint numVests){
	if (numVests < 1) return;
		XmlElement c("command");
			c.setStringAttribute("class", "update_inventory");
			c.setIntAttribute("character_id", characterId);
			c.setIntAttribute("container_type_id", numVests); 
			XmlElement item("item");
			item.setStringAttribute("class", "projectile");
			item.setStringAttribute("key", Itemkey);
			c.appendChild(item);
		metagame.getComms().send(c);
}

string getPlayerEquipmentKey(const Metagame@ metagame, int characterId, uint slot){
	if (slot <0) return "";
	if (slot >5) return "";
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	if (targetCharacter is null) return "";
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return "";
	if (equipment[slot].getIntAttribute("amount") == 0) return "";
	string ItemKey = equipment[slot].getStringAttribute("key");
	return ItemKey;
}

string getDeadPlayerEquipmentKey(const Metagame@ metagame, int characterId, uint slot){
	if (slot <0) return "";
	if (slot >5) return "";
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	if (targetCharacter is null) return "";
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return "";
	string ItemKey = equipment[slot].getStringAttribute("key");
	return ItemKey;
}

int getPlayerEquipmentAmount(const Metagame@ metagame, int characterId, uint slot){
	if (slot <0) return -1;
	if (slot >5) return -1;
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	if (targetCharacter is null) return -1;
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return -1;
	int amount = equipment[slot].getIntAttribute("amount");
	return amount;
}

void GiveRP(const Metagame@ metagame,int character_id,int rp){
	string c = "<command class='rp_reward' character_id='" + character_id + "' reward='" + rp + "' />";
    metagame.getComms().send(c);
}

void GiveXP(const Metagame@ metagame,int character_id,float rp){
	string c = "<command class='xp_reward' character_id='" + character_id + "' reward='" + rp + "' />";
    metagame.getComms().send(c);
}

void addItemInBackpack(Metagame@ metagame, int characterId, string ItemType, string ItemKey) {
	string c = 
		"<command class='update_inventory' character_id='" + characterId + "' container_type_class='backpack'>" + 
			"<item class='" + ItemType + "' key='" + ItemKey + "' />" +
		"</command>";
	metagame.getComms().send(c);
}

bool checkCommandAlter(string message, string target, string target1) {
    return startsWith(message.toLowerCase(), "/" + target) || endsWith(message.toLowerCase(),"/"+ target1);
}

void playSoundtrack(Metagame@ m_metagame,string filename) {
	m_metagame.getComms().send(
	"<command " +
	" class='set_soundtrack' " + 
	" enabled='1' " + 
	" filename='" + filename + "'" + 
	"</command>");
}

void stopSoundtrack(Metagame@ m_metagame,string filename) {
	m_metagame.getComms().send(
	"<command " +
	" class='set_soundtrack' " + 
	" enabled='0' " + 
	" filename='" + filename + "'" + 
	"</command>");
}
//soundtrack function from ww2dlc thanks for coding wheel


		// query for Equipment
		// TagName=query_result query_id=22
		// TagName=character
		// block=11 17
		// dead=0
		// faction_id=0
		// id=3
		// leader=1
		// name=CT: 62
		// player_id=0
		// position=375.557 2.74557 609.995
		// rp=9400
		// soldier_group_name=default
		// squad_size=0
		// wounded=0
		// xp=0

		// TagName=item amount=1 index=17 key=steyr_aug.weapon slot=0
		// TagName=item amount=0 index=3 key=9x19mm_sidearm_burst.weapon slot=1
		// TagName=item amount=1 index=3 key=hand_grenade.projectile slot=2
		// TagName=item amount=0 index=-1 key= slot=4
		// TagName=item amount=1 index=3 key=kevlar_plus_helmet.carry_item slot=5