#include "query_helpers2.as"
#include "helpers.as"
#include "GFLplayerlist.as"
#include "Spawn_request.as"
#include "GFLparameters.as"

//严禁无授权转载
//Credit: NetherCrow & Castling Staff
//Contributor: Saiwa
//Inspired by Pasik & Unit G17 & RWR ww2 DLC staff
//Don't copy without gimme a ask and if you has some question about script just contact @NetherCrowCSOLYOO in rwr discord #modding

class MutilProjectile
{
	string m_key;
	int m_num;
	MutilProjectile(){}
	MutilProjectile(string key,int num)
	{
		m_key=key;
		m_num=num;
	}
}

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
	int soundrnd= rand(0,arrays.length-1);
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
	if (slot < 0 || slot > 5) return "";
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	if (targetCharacter is null) return "";
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return "";
	if (equipment[slot].getIntAttribute("amount") == 0) return "";
	string ItemKey = equipment[slot].getStringAttribute("key");
	return ItemKey;
}

string getDeadPlayerEquipmentKey(const Metagame@ metagame, int characterId, uint slot){
	if (slot < 0 || slot > 5) return "";
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
	if (targetCharacter is null) return "";
	array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
	if (equipment.size() == 0) return "";
	string ItemKey = equipment[slot].getStringAttribute("key");
	return ItemKey;
}

void getMyItem(const Metagame@ metagame, int characterId){
	const XmlElement@ targetCharacter = getCharacterInfo2(metagame,characterId);
}

int getPlayerEquipmentAmount(const Metagame@ metagame, int characterId, uint slot){
	if (slot < 0 || slot > 5) return -1;
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

void GiveXP(const Metagame@ metagame,int character_id,float xp){
	string c = "<command class='xp_reward' character_id='" + character_id + "' reward='" + xp + "' />";
    metagame.getComms().send(c);
}

void setXPcharacter(const Metagame@ metagame,int cId,float xp){
	const XmlElement@ Characterinfo= getCharacterInfo(metagame,cId);
	if (Characterinfo !is null){
		float now_xp=Characterinfo.getFloatAttribute("xp");
		float add_xp=xp-now_xp;
		GiveXP(metagame,cId,add_xp);
	}
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

void addItemInStash(Metagame@ metagame, int characterId, string ItemType, string ItemKey){
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setStringAttribute("container_type_class", "stash");
	c.setIntAttribute("character_id", characterId); 
	c.setIntAttribute("add",1);
	XmlElement k("item");
	k.setStringAttribute("class", ItemType);
	k.setStringAttribute("key", ItemKey);
	c.appendChild(k);
	metagame.getComms().send(c);	
}

void addListItemInStash(Metagame@ metagame, int characterId, array<Resource@>@ resources){
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setStringAttribute("container_type_class", "stash");
	c.setIntAttribute("character_id", characterId); 
	c.setIntAttribute("add",1);
	for(uint i=0;i<resources.size();i++){
		XmlElement k("item");
		k.setStringAttribute("class", resources[i].m_type);
		k.setStringAttribute("key", resources[i].m_key);
		c.appendChild(k);
	}
	metagame.getComms().send(c);	
}

void addRangeItemInBackpack(Metagame@ metagame, int factionId, string ItemType, string ItemKey,Vector3 pos,float range){
	array<int> player_cId;
	if (CT_PlayerList.length()<=0){return;}
	for(uint i=0;i<CT_PlayerList.length();i++){
		player_cId.insertLast(CT_PlayerList[i].m_characterid);
	}
	array<const XmlElement@> affectedCharacter = getCharactersNearPosition(metagame,pos,factionId,range);
	if (affectedCharacter is null){return;}
	for(uint i=0;i<affectedCharacter.length();i++){
		int cId = affectedCharacter[i].getIntAttribute("id");
		if(player_cId.find(cId)>=0){
			addItemInBackpack(metagame,cId,ItemType,ItemKey);
		}
	}
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
	if (OutOfRange(position))
	{
		_log("角色出界 尝试在" + position.toString() + "生成" + instanceKey +"失败");
		return;
	}	
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
	if (OutOfRange(stringToVector3(position)))
	{
		_log("角色出界 尝试在" + position + "生成" + instanceKey +"失败");
		return;
	}	
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

void spawnSoldier(Metagame@ metagame, uint count, uint factionId, Vector3 position, string instanceKey,float spreadX,float spreadY) {
	if (OutOfRange(position))
	{
		_log("角色出界 尝试在" + position.toString() + "生成" + instanceKey +"失败");
		return;
	}	
	for (uint i = 0; i < count; ++i) {
		Vector3 position_dummy = getRandomOffsetVector(position,spreadX,spreadY);
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position_dummy.toString() + "' " + 
		" offset='0 0 0' " +
		" instance_class='soldier' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

float getAimOrientation4(Vector3 s_pos, Vector3 e_pos) {
	float dx = e_pos.m_values[0]-s_pos.m_values[0];
	float dy = e_pos.m_values[2]-s_pos.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
    if(ds<=0.000001f) ds=0.000001f;
	float dir = acos(dx/ds);
	if(asin(dy/ds)>0) {
		return (dir*1.0-1.57)*(-1.0);
	}
	return (dir*(-1.0)-1.57)*(-1.0);
}

float getAimOrientation4(Vector3 e_pos) {
	float dx = e_pos.m_values[0];
	float dy = e_pos.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
    if(ds<=0.000001f) ds=0.000001f;
	float dir = acos(dx/ds);
	if(asin(dy/ds)>0) {
		return (dir*1.0-1.57)*(-1.0);
	}
	return (dir*(-1.0)-1.57)*(-1.0);
}

float getOrientation4(Vector3 a) {
	float dx = a.m_values[0];
	float dy = a.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
    if(ds<=0.000001f) ds=0.000001f;
	float dir = acos(dx/ds);
	if(asin(dy/ds)>0) {
		return (dir*1.0-1.57)*(-1.0);
	}
	return (dir*(-1.0)-1.57)*(-1.0);
}

Vector3 getMultiplicationVector(Vector3 s_pos, Vector3 scale) {
	float x = s_pos.m_values[0]*scale.m_values[0];
	float y = s_pos.m_values[1]*scale.m_values[1];
	float z = s_pos.m_values[2]*scale.m_values[2];
	return Vector3(x,y,z);
}

Vector3 getMultiplicationVector(Vector3 s_pos, float scale) {
	float x = s_pos.m_values[0]*scale;
	float y = s_pos.m_values[1]*scale;
	float z = s_pos.m_values[2]*scale;
	return Vector3(x,y,z);
}

float getAimUnitDistance(float scale, Vector3 s_pos, Vector3 e_pos) {
	float dx = e_pos.m_values[0]-s_pos.m_values[0];
	float dy = e_pos.m_values[2]-s_pos.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
	return scale*ds;
}

int getAmosPosition(Metagame@ metagame, uint ownerid, Vector3 judgePos, float radius) {
	
	array<const XmlElement@>@ vehicles = getAllVehicles(metagame, 0);
	for(uint i=0;i<vehicles.length();i++){
		Vector3 vehiclePos = stringToVector3(vehicles[i].getStringAttribute("position"));
		if(getAimUnitDistance(1.0,judgePos,vehiclePos)>radius){continue;} //载具在查询范围外

		int vehicleid = vehicles[i].getIntAttribute("id");
		const XmlElement@ vehicleInfo = getVehicleInfo(metagame, vehicleid);
		if(vehicleInfo is null){continue;}  //载具不存在
		if(vip_vehicles.find(vehicleInfo.getStringAttribute("key"))==-1){continue;} //载具是VIP载具
		return 1;
	}
	return -1;	
}

int getNearByEnemyVehicle(Metagame@ metagame, uint ownerfid, Vector3 judgePos, float radius) {
	for(uint f=0;f<4;f++){
		if(f==ownerfid)continue;
		if(f>=5){return -1;}
		array<const XmlElement@>@ vehicles = getAllVehicles(metagame, f);
		for(uint i=0;i<vehicles.length();i++){
			Vector3 vehiclePos = stringToVector3(vehicles[i].getStringAttribute("position"));
			if(getAimUnitDistance(1.0,judgePos,vehiclePos)>radius){continue;} //载具在查询范围外

			int vehicleid = vehicles[i].getIntAttribute("id");
			const XmlElement@ vehicleInfo = getVehicleInfo(metagame, vehicleid);
			if(vehicleInfo is null){continue;}  //载具不存在
			if(vehicleInfo.getIntAttribute("health")==0){continue;}  //载具被击毁
			if(unlockable_vehicles.find(vehicleInfo.getStringAttribute("key"))>-1){continue;} //载具是中立地图物件
			_log("Get vehicle id successful.");
			return vehicleid;			
		}		
	}
	return -1;
}

Vector3 getAimUnitVector(float scale, Vector3 s_pos, Vector3 e_pos) {
	float dx = e_pos.m_values[0]-s_pos.m_values[0];
	float dy = e_pos.m_values[2]-s_pos.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
    if(ds<=0.000005f) {ds=0.000005f;dx=0.000004f;dy=0.000003f;}
	return Vector3(dx*scale/ds,0,dy*scale/ds);
}

//此处angle用弧度制
Vector3 getRotatedVector(float angle, Vector3 c_pos) {
    float ds = sqrt(c_pos.m_values[0]*c_pos.m_values[0]+c_pos.m_values[2]*c_pos.m_values[2]);
    if(ds<=0.000005f) {ds=0.000005f;c_pos.m_values[0]=0.000004f;c_pos.m_values[2]=0.000003f;}
	float ori_angle = acos(c_pos.m_values[0]/ds);
	float ex = ds*cos(ori_angle+angle);
	float ey = ds*sin(ori_angle+angle);	
	return Vector3(ex,0,ey);
}

Vector3 getVerticalUnitVector(Vector3 given_vector) {
	return Vector3((-1.0)*given_vector.m_values[2],given_vector.m_values[1],given_vector.m_values[0]);
}

Vector3 getAimUnitPosition(Vector3 s_pos, Vector3 e_pos, float scale) {
	float dx = e_pos.m_values[0]-s_pos.m_values[0];
	float dy = e_pos.m_values[2]-s_pos.m_values[2];
    float ds = sqrt(dx*dx+dy*dy);
    if(ds<=0.000005f) {ds=0.000005f;dx=0.000004f;dy=0.000003f;}
	return s_pos.add(Vector3(dx*scale/ds,0,dy*scale/ds));
}

Vector3 getRandomOffsetVector(Vector3 pos,float strike_rand){
	float rand_x = rand(-strike_rand,strike_rand);
	float rand_z = rand(-strike_rand,strike_rand);
	return pos.add(Vector3(rand_x,0,rand_z));
}

Vector3 getRandomOffsetVector(Vector3 pos,float strike_randX,float strike_randY){
	float rand_x = rand(-strike_randX,strike_randX);
	float rand_z = rand(-strike_randY,strike_randY);
	return pos.add(Vector3(rand_x,0,rand_z));
}

void spawnVehicle(Metagame@ metagame, uint count, uint factionId, Vector3 position, Orientation@ dir, string instanceKey) {
	if (OutOfRange(position))
	{
		_log("载具出界 尝试在" + position.toString() + "生成" + instanceKey +"失败");
		return;
	}
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position.toString() + "' " + 
		" orientation='" + dir.output() + "' " + 
		" instance_class='vehicle' " + 
		" instance_key='" + instanceKey + "'> " + 
		"</command>");
	}
}

void spawnVehicle(Metagame@ metagame, uint count, uint factionId, string position, Orientation@ dir, string instanceKey) {
	if (OutOfRange(stringToVector3(position)))
	{
		_log("载具出界 尝试在" + position + "生成" + instanceKey +"失败");
		return;
	}	
	for (uint i = 0; i < count; ++i) {
		metagame.getComms().send(
		"<command " +
		" class='create_instance' " + 
		" faction_id='" + factionId + "' " +
		" position='" + position + "' " + 
		" orientation='" + dir.output() + "' " + 
		" instance_class='vehicle' " + 
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
	direction = direction.scale(initspeed);
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

Vector3 normalize(Vector3 v2){
	float len = v2.length();
	if (len == 0) {
		return Vector3(0, 0, 0);
	}
	float invLen = 1 / len;
	return v2.scale(invLen);
}

bool OutOfRange(Vector3 v2){
	float x = v2.get_opIndex(0);
	float z = v2.get_opIndex(2);

	if (x < 0 || x > 1024) return true;
	if (z < 0 || z > 1024) return true;
	return false;
}

class Orientation{
	float a1;
	float a2;
	float a3;
	float a4;
	Orientation(){};
	Orientation(float a_1, float a_2, float a_3,float a_4){
		a1=a_1;
		a2=a_2;
		a3=a_3;
		a4=a_4;
	}
	string output(){
		return a1+" "+a2+" "+a3+" "+a4;
	}
}
void CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg,Orientation@ rotation){
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
	direction = direction.scale(initspeed);
	string c = 
		"<command class='create_instance'" +
		" faction_id='" + fId + "'" +
		" instance_class='grenade'" +
		" instance_key='" + key + "'" +
		" position='" + startPos.toString() + "'" +
		" character_id='" + cId + "'" +
		" orientation='" + rotation.output() + "'" +
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


void CreateDirectProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed){
	initspeed=initspeed/60;
	Vector3 direction = endPos.subtract(startPos);
	float Vmod = sqrt(pow(direction.get_opIndex(0),2)  + pow(direction.get_opIndex(1),2) + pow(direction.get_opIndex(2),2));
	if (Vmod< 0.00001f) Vmod= 0.00001f;
	direction.set(direction.get_opIndex(0)/Vmod,direction.get_opIndex(1)/Vmod,direction.get_opIndex(2)/Vmod);
	direction = direction.scale(initspeed);
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

void CreateDirectProjectile_T(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float time){
	Vector3 direction = endPos.subtract(startPos);
	float Vmod = sqrt(pow(direction.get_opIndex(0),2)  + pow(direction.get_opIndex(1),2) + pow(direction.get_opIndex(2),2));
	if (Vmod< 0.00001f) Vmod= 0.00001f;
	float initspeed = Vmod/time/60;
	direction.set(direction.get_opIndex(0)/Vmod,direction.get_opIndex(1)/Vmod,direction.get_opIndex(2)/Vmod);
	direction = direction.scale(initspeed);
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

void CreateMutilDirectProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,int num){
	initspeed=initspeed/60;
	Vector3 direction = endPos.subtract(startPos);
	float Vmod = sqrt(pow(direction.get_opIndex(0),2)  + pow(direction.get_opIndex(1),2) + pow(direction.get_opIndex(2),2));
	if (Vmod< 0.00001f) Vmod= 0.00001f;
	direction.set(direction.get_opIndex(0)/Vmod,direction.get_opIndex(1)/Vmod,direction.get_opIndex(2)/Vmod);
	direction = direction.scale(initspeed);
	string c = 
		"<command class='create_instance'" +
		" faction_id='" + fId + "'" +
		" instance_class='grenade'" +
		" instance_key='" + key + "'" +
		" position='" + startPos.toString() + "'" +
		" character_id='" + cId + "'" +
		" offset='" + direction.toString() + "' />";
	for(int i=1;i<=num;i++){
		m_metagame.getComms().send(c);
	}
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

void playAnimationKey(Metagame@ m_metagame,int characterId,string animekey,bool inter=false,bool hide=false){
	XmlElement command("command");
	command.setStringAttribute("class", "update_character");
	command.setIntAttribute("id", characterId);
	command.setStringAttribute("animate", animekey);
	command.setBoolAttribute("interruptable", inter);
	command.setBoolAttribute("hide_weapon", hide);
	m_metagame.getComms().send(command);
}

void addMutilItemInBackpack(Metagame@ metagame, int characterId, const Resource@ r,uint num) {
	XmlElement command("command");
	command.setStringAttribute("class", "update_inventory");
	command.setIntAttribute("character_id", characterId);
	command.setStringAttribute("container_type_class", "backpack");
	XmlElement k("item");
	k.setStringAttribute("class", r.m_type);
	k.setStringAttribute("key", r.m_key);
	for(uint i=0;i<num;i++){
		command.appendChild(k);
	}
	metagame.getComms().send(command);
}

void addMutilItemInBackpack(Metagame@ metagame, int characterId, string ItemType, string ItemKey,uint num) {
	XmlElement command("command");
	command.setStringAttribute("class", "update_inventory");
	command.setIntAttribute("character_id", characterId);
	command.setStringAttribute("container_type_class", "backpack");
	XmlElement k("item");
	k.setStringAttribute("class", ItemType);
	k.setStringAttribute("key", ItemKey);
	for(uint i=0;i<num;i++){
		command.appendChild(k);
	}
	metagame.getComms().send(command);
}

void playPrivateSound(const Metagame@ metagame, string filename, int playerId) {
	XmlElement command("command");
	command.setStringAttribute("class", "play_sound");
	command.setStringAttribute("filename", filename);
	command.setIntAttribute("player_id", playerId);
	metagame.getComms().send(command);
}

int getNearbyRandomLuckyGuyId(GameMode@ metagame, int factionid, Vector3 pos, float range){
	uint cur_factionid_num = metagame.getFactionCount();
    array<const XmlElement@> affectedCharacter;
	for(uint i=0;i<cur_factionid_num;i++) 
		if(int(i)!=factionid) {
			array<const XmlElement@> possible_affectedCharacter;
			possible_affectedCharacter = getCharactersNearPosition(metagame,pos,i,range);
			if (possible_affectedCharacter !is null){
				for(uint x=0;x<possible_affectedCharacter.length();x++){
					affectedCharacter.insertLast(possible_affectedCharacter[x]);
				}
			}
		}
                
    if (affectedCharacter.length()>0) {
        uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
        uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
        return luckyGuyid;
    }         
	else {
		return -1;
	}
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


void ProfileSave(Metagame@ m_metagame) {
	XmlElement root("playerdata");
	root.setStringAttribute("username", "testing");
	root.setStringAttribute("hashid", "114514");
	string FILENAME =  "114514.xml";

	XmlElement command("command");
	command.setStringAttribute("class", "save_data");
	command.setStringAttribute("filename", FILENAME);
	command.appendChild(root);

	m_metagame.getComms().send(command);

}

void setVisualTimer(Metagame@ metagame, float time) {
	XmlElement command("command");
	command.setStringAttribute("class", "set_game_timer");
	command.setIntAttribute("faction_id", 0);
	command.setIntAttribute("pause", 0); 
	command.setFloatAttribute("time", time); 
	metagame.getComms().send(command);
}

void clearVisualTimer(Metagame@ metagame) {
	XmlElement command("command");
	command.setStringAttribute("class", "set_game_timer");
	command.setIntAttribute("faction_id", -1);
	command.setIntAttribute("pause", 1); 
	command.setFloatAttribute("time", -1.0f); 
	metagame.getComms().send(command);
}

void healCharacter(Metagame@ metagame,int characterId,int healnum) {
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setIntAttribute("character_id", characterId); 
	c.setIntAttribute("untransform_count", healnum);
	metagame.getComms().send(c);
}

void healRangedCharacters(Metagame@ metagame,Vector3 pos,int faction_id,float range,int healnum,string special_key="none",uint healcount=0) {
	array<const XmlElement@>@ characters = getCharactersNearPosition(metagame, pos, faction_id, range);
	if(healcount==0) {
		_log("No special heal count requirement.");
		healcount = characters.length;
	} else if (healcount>=characters.length) {
		healcount = characters.length;
	}
	for (uint i = 0; i < healcount; i++) {
		int luckyhealguyid = characters[i].getIntAttribute("id");
		switch(int(specialHealIndex[special_key]))
		{
			case 1: {
				const XmlElement@ luckyhealguyC = getCharacterInfo(metagame, luckyhealguyid);
				Vector3 c_pos = stringToVector3(luckyhealguyC.getStringAttribute("position"));
				CreateDirectProjectile(metagame,c_pos.add(Vector3(0,0.1,0)),c_pos,"para_heal_effect_on_target.projectile",-1,faction_id,10);				
				break;
			}

			default: {
				_log("No special heal requirement.");
				break;
			}
		} 
		healCharacter(metagame,characters[i].getIntAttribute("id"),healnum);
	}	
}

void updateMapViewPic(Metagame@ metagame,string pic){
	XmlElement command("command");
	command.setStringAttribute("class", "update_map_view");
	command.setStringAttribute("overlay_texture", pic);
	metagame.getComms().send(command);
}

Vector3 getVectorPosFromCharacterId(Metagame@ metagame,int character_id)
{
	Vector3 output = Vector3(0,0,0);
	const XmlElement@ characterinfo = getCharacterInfo(metagame, character_id);
	if (characterinfo !is null){
		string c_pos = characterinfo.getStringAttribute("position");
		output = stringToVector3(c_pos);
	}
	return output;
}

string getStringPosFromCharacterId(Metagame@ metagame,int character_id)
{
	string output = "";
	const XmlElement@ characterinfo = getCharacterInfo(metagame, character_id);
	if (characterinfo !is null){
		output = characterinfo.getStringAttribute("position");
	}
	return output;
}

void spawnStaticProjectile(Metagame@ metagame,string key,Vector3 pos,int characterId,int factionId)
{
	string m_pos = pos.toString();

	XmlElement command("command");
	command.setStringAttribute("class", "create_instance");
	command.setIntAttribute("character_id", characterId);
	command.setIntAttribute("faction_id", factionId);

	command.setStringAttribute("instance_class", "grenade");
	command.setStringAttribute("instance_key", key);	
	command.setStringAttribute("position", m_pos);	
	command.setStringAttribute("offset", "0 0 0");	

	metagame.getComms().send(command);
}

void spawnStaticProjectile(Metagame@ metagame,string key,string pos,int characterId,int factionId)
{
	XmlElement command("command");
	command.setStringAttribute("class", "create_instance");
	command.setIntAttribute("character_id", characterId);
	command.setIntAttribute("faction_id", factionId);

	command.setStringAttribute("instance_class", "grenade");
	command.setStringAttribute("instance_key", key);	
	command.setStringAttribute("position", pos);	
	command.setStringAttribute("offset", "0 0 0");	
	
	metagame.getComms().send(command);
}

void setSpawnScore(Metagame@ metagame,int fId,string name,float spawnScore)
{
	XmlElement command("command");
	command.setStringAttribute("class", "faction");
	command.setIntAttribute("faction_id", fId);
	command.setStringAttribute("soldier_group_name", name);
	command.setFloatAttribute("spawn_score", spawnScore);
	metagame.getComms().send(command);
}

void addItemToGrenadeSlot(Metagame@ metagame,int cid,uint num,string m_key,string m_type="projectile")
{
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setIntAttribute("container_type_id",4);
	c.setIntAttribute("character_id", cid); 
	c.setIntAttribute("add",1);
	XmlElement k("item");
	k.setStringAttribute("class", m_type);
	k.setStringAttribute("key", m_key);
	for(uint i=0;i<num;i++){
		c.appendChild(k);
	}
	metagame.getComms().send(c);
}

void deleteItemToGrenadeSlot(Metagame@ metagame,int cid,uint num,string m_key,string m_type="projectile")
{
	XmlElement c ("command");
	c.setStringAttribute("class", "update_inventory");
	c.setIntAttribute("container_type_id",4);
	c.setIntAttribute("character_id", cid); 
	c.setIntAttribute("add",0);
	XmlElement k("item");
	k.setStringAttribute("class", m_type);
	k.setStringAttribute("key", m_key);
	for(uint i=0;i<num;i++){
		c.appendChild(k);
	}
	metagame.getComms().send(c);
}

void GrenadeSupply(Metagame@ metagame,int cid,uint num,string m_key,string m_type="projectile")
{
	if(resupply_grenade_list.find(m_key)==-1) return;
	addItemToGrenadeSlot(metagame,cid,num,m_key,m_type);
}

array<const XmlElement@>@ getEnemyCharactersNearPosition(GameMode@ metagame, const Vector3@ position, int factionId, float range = 80.0f, int num = 1) {
	//获取技能影响的敌人数量
	int m_fnum = metagame.getFactionCount();
	array<const XmlElement@> affectedCharacter;
	Vector3 max_character_pos =  Vector3(0,0,0);

	uint num_jud = 0;
	uint num_max_character = num; //最多锁定目标数

	if(m_fnum==0)return affectedCharacter;

	for(int i=0;i<m_fnum;i++) {
		if(i==factionId) continue;
		array<const XmlElement@> affectedCharacter2;
		affectedCharacter2 = getCharactersNearPosition(metagame,position,i,range);
		if (affectedCharacter2 is null) continue;
		for(uint x=0;x<affectedCharacter2.length();x++){
			affectedCharacter.insertLast(affectedCharacter2[x]);
			num_jud += 1;
			if(num_jud>num_max_character)break;
		}
		if(num_jud>num_max_character)break;
	}
	return affectedCharacter;
}



void GrenadeSupplyGroup(Metagame@ metagame,array<const XmlElement@>@ characters,uint num,string m_type="projectile")
{
	for (uint i = 0; i < characters.length(); i++) {
		int luckyhealguyid = characters[i].getIntAttribute("id");
		if (!checkCharacterIdisPlayerOwn(luckyhealguyid)) continue;
		string key = getPlayerWeaponFromListByID(luckyhealguyid,2);
		if(key == "-nan-") continue;
		GrenadeSupply(metagame,luckyhealguyid,num,key,m_type);
	}
}

void SetAttackTarget(Metagame@ metagame,int m_factionId ,string baseKey) {
	_log("AttackTargetOrder, attackTo, faction=" + m_factionId + ", baseKey=" + baseKey, 1);
	XmlElement command("command");
	command.setStringAttribute("class", "commander_ai");
	command.setIntAttribute("faction", m_factionId);
	command.setStringAttribute("attack_target_base_key", baseKey);
	metagame.getComms().send(command);
}

int getNumberedVehicle(Metagame@ metagame, uint ownerid, string key) {
	
	array<const XmlElement@>@ vehicles = getVehicles(metagame, ownerid, key);
	if(vehicles is null) return -1;
	int number = vehicles.size();
	for(uint i=0;i<vehicles.length();i++){
		int vid = vehicles[i].getIntAttribute("id");
		const XmlElement@ vehicleInfo = getVehicleInfo(metagame,vid);
		if ( vehicleInfo is null)
		{
			number -= 1;
			continue;
		}
		int hp = vehicleInfo.getIntAttribute("health");
		if (hp <= 0)
		{
			number -= 1;
			continue;
		}
	}
	return number;	
}

int getRandomIndex(int size)
{
	return rand(0,size-1);
}

