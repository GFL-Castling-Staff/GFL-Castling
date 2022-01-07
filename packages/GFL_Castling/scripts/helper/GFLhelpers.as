#include "query_helpers2.as"


void playSoundAtLocation(const Metagame@ metagame, string filename, int factionId, const Vector3@ position, float volume=1.0) {
	XmlElement command("command");
	command.setStringAttribute("class", "play_sound");
	command.setStringAttribute("filename", filename);
	command.setIntAttribute("faction_id", factionId);
	command.setFloatAttribute("volume", volume);
	command.setStringAttribute("position", position.toString());
	metagame.getComms().send(command);
}

void editPlayerVest(const Metagame@ metagame, int characterId, string Itemkey, uint numVests){
	if (numVests < 1) return;
	for (uint j = numVests; j > 0; --j) {
		XmlElement c("command");
			c.setStringAttribute("class", "update_inventory");
			c.setIntAttribute("character_id", characterId);
			c.setIntAttribute("container_type_id", 4); 
			XmlElement item("item");
			item.setStringAttribute("class", "carry_item");
			item.setStringAttribute("key", Itemkey);
			c.appendChild(item);
		metagame.getComms().send(c);
	}
}

string getPlayerEquipmentKey(const Metagame@ metagame, int characterId, uint slot){
	if (slot <0) return "";
	if (slot >5) return "";
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return "";
	string ItemKey = equipment[slot].getStringAttribute("key");
	return ItemKey;
}

void GiveRP(const Metagame@ metagame,int character_id,int rp){
	string c = "<command class='rp_reward' character_id='" + character_id + "' reward='" + rp + "' />";
    metagame.getComms().send(c);
}
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