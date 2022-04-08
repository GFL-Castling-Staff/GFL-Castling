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

void playRandomSoundArray(const Metagame@ metagame, array<string> arrays, int factionId, string position, float volume=1.0){
	int soundrnd= rand(1,arrays.length)-1;
	playSoundAtLocation(metagame,arrays[soundrnd],factionId,position,volume);
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

void deleteItemInBackpack(Metagame@ metagame, int characterId, string ItemType, string ItemKey){
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setStringAttribute("container_type_class", "backpack");
	c.setIntAttribute("character_id", characterId); 
	c.setIntAttribute("add",0);
	XmlElement k("item");
	k.setStringAttribute("class", ItemType);
	k.setStringAttribute("key", ItemKey);
	c.appendChild(k);
	metagame.getComms().send(c);	
}

void deleteItemInStash(Metagame@ metagame, int characterId, string ItemType, string ItemKey){
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setStringAttribute("container_type_class", "stash");
	c.setIntAttribute("character_id", characterId); 
	c.setIntAttribute("add",0);
	XmlElement k("item");
	k.setStringAttribute("class", ItemType);
	k.setStringAttribute("key", ItemKey);
	c.appendChild(k);
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

void spawnSoldier(Metagame@ metagame, uint count, uint factionId, Vector3 position, string instanceKey) {
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position.toString() + "' " + 
		" offset='0 0 0' " +
		" instance_class='soldier' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

void spawnSoldier(Metagame@ metagame, uint count, uint factionId, string position, string instanceKey) {
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position + "' " + 
		" offset='0 0 0' " +
		" instance_class='soldier' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

void CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg){
	initspeed=initspeed/60;
	startPos = startPos.add(Vector3(0,1,0));
	Vector3 direction = endPos.subtract(startPos);
	float realy = direction.get_opIndex(1);
	direction.set(direction.get_opIndex(0),0,direction.get_opIndex(2));
	float Vmod = sqrt(pow(direction.get_opIndex(0),2) + pow(direction.get_opIndex(2),2));
	if (Vmod< 0.00001f) Vmod= 0.00001f;
	float foobar = pow(initspeed,4)- ggg * (ggg*Vmod*Vmod + 2*realy*initspeed*initspeed);
	if (foobar < 0) foobar=0.1f;
	float inner = sqrt(foobar);
	float root1 = (pow(initspeed,2)+inner) / (ggg*Vmod);
	float root2 = (pow(initspeed,2)-inner) / (ggg*Vmod);
	float angle1 = atan(root1);
	float angle2 = atan(root2);
	float t = 0.0f;
	t = angle1 < angle2 ? angle1 : angle2;
	direction.set(direction.get_opIndex(0),tan(t)*Vmod,direction.get_opIndex(2));
	float barfoo = pow(direction.get_opIndex(0),2) + pow(direction.get_opIndex(2),2) + pow(direction.get_opIndex(1),2);
	if (barfoo < 0) barfoo=0.1f;
	barfoo = sqrt(barfoo);
	direction.set(direction.get_opIndex(0)/barfoo,direction.get_opIndex(1)/barfoo,direction.get_opIndex(2)/barfoo);
	direction.scale(initspeed);
	string c = 
		"<command class='create_instance'" +
		" faction_id='" + fId + "'" +
		" instance_class='grenade'" +
		" instance_key='" + key + "'" +
		" position='" + startPos.toString() + "'" +
		" character_id='" + cId + "'" +
		" offset='" + direction.toString() + "' />";
	m_metagame.getComms().send(c);
}
void CreateProjectile_H(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float gspeed,float height){
	float topY = ((startPos.get_opIndex(1)>endPos.get_opIndex(1))?startPos.get_opIndex(1):endPos.get_opIndex(1));
	topY+=height;
	float g1= -gspeed/100;
	float d1= height;
	float d2= topY - endPos.get_opIndex(1);
	float g2= 2/ -g1;
	float t1= sqrt(g2*d1);
	float t2= sqrt(g2*d2);
	float t=t1+t2;
	float vX = (endPos.get_opIndex(0) - startPos.get_opIndex(0)) / t /6 ;
	float vZ = (endPos.get_opIndex(2) - startPos.get_opIndex(2)) / t /6 ;
	float vY = t1*-g1 / 6;
	Vector3 speed = Vector3(vX,vY,vZ);
	string c = 
		"<command class='create_instance'" +
		" faction_id='" + fId + "'" +
		" instance_class='grenade'" +
		" instance_key='" + key + "'" +
		" position='" + startPos.toString() + "'" +
		" character_id='" + cId + "'" +
		" offset='" + speed.toString() + "' />";
	m_metagame.getComms().send(c);
}

float getFlatPositionDistance(const Vector3@ pos1, const Vector3@ pos2) {
	//_log("get_position_distance, pos1=" + $pos1[0] + ", " + $pos1[1] + ", " + $pos1[2] + ", pos2=" + $pos2[0] + ", " + $pos2[1] + ", " + $pos2[2]);
	Vector3 d = pos1.subtract(pos2);

	d.m_values[0] *= d.m_values[0];
	d.m_values[2] *= d.m_values[2];

	float result = sqrt(d.m_values[0] + d.m_values[2]);
	return result;
}

// --------------------------------------------
bool checkFlatRange(const Vector3@ pos1, const Vector3@ pos2, float range) {
	float length = getFlatPositionDistance(pos1, pos2);
	return length <= range; 
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