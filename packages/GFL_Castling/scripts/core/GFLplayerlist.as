#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLparameters.as"

//Originally created by Saiwa

// 本系统用于容纳有关玩家的请求

dictionary CT_PlayerList;

class GFL_equipment{
    string m_weapon1key = default_string;
    string m_weapon2key = default_string;
    string m_grenadekey = default_string;
    string m_armorkey = default_string;
    float m_xp = default_float;
    int m_rp = default_int;
    Vector3 m_new_pos = default_Vector3;
    Vector3 m_old_pos = default_Vector3;

    GFL_equipment(string weapon1key, string weapon2key, string grenadekey, string armorkey, float xp, int rp, Vector3 pos){
        m_weapon1key = weapon1key;
        m_weapon2key = weapon2key;
        m_grenadekey = grenadekey;
        m_armorkey = armorkey;
        m_xp = xp;
        m_rp = rp;
        m_new_pos = pos;
        m_old_pos = pos;
    }

    GFL_equipment(){}

    void setWeapon(string weapon1key=default_string, string weapon2key=default_string, string grenadekey=default_string, string armorkey=default_string){
        m_weapon1key = weapon1key;
        m_weapon2key = weapon2key;
        m_grenadekey = grenadekey;
        m_armorkey = armorkey;
    }

    string getWeapon(int num){
        switch(num){
            case 0:{return m_weapon1key;}
            case 1:{return m_weapon2key;}
            case 2:{return m_grenadekey;}
            case 3:{return m_armorkey;}
            default:{_log("WARN: GFLplayerlist: GFL_equipment(): invalid weapon number.");return default_string;}
        }
        return default_string;
    }

    void setXpRp(float xp=default_float, int rp=default_int){
        m_xp = xp;
        m_rp = rp;
    }
    float getXp(){return m_xp;}
    int getRp(){return m_rp;}

    void updatePos(Vector3 pos=default_Vector3){
        m_new_pos = pos;
        m_old_pos = m_new_pos;
    }    
    void updatePos(string spos="1 1 1"){
        Vector3 pos = stringToVector3(spos);
        m_new_pos = pos;
        m_old_pos = m_new_pos;
    }

    Vector3 getNewPos(){return m_new_pos;}
    Vector3 getOldPos(){return m_old_pos;}
}

GFL_equipment@ default_equipment = GFL_equipment(default_string,default_string,default_string,default_string,default_float,default_int,default_Vector3);
class GFL_playerInfo{
	int m_playerid;    //玩家id
    int m_characterid; //角色id
    GFL_equipment@ m_equipment; //玩家装备（包括武器啊副武器啊投掷物这些,主要可能后面存档会添加额外装备）
	string m_ip;
	string m_sid;   

    // 玩家物品栏
    GFL_playerInfo(int pid, int cid, GFL_equipment@ equipment){
	    m_playerid = pid;
        m_characterid = cid;
        @m_equipment = @equipment;
    }

    GFL_playerInfo(){}

    // 增删改单个玩家装备(注意clearEquipment不是直接删除字典)
    void setPlayerInfo(int pid=default_int, int cid=default_int){
	    m_playerid = pid;
        m_characterid = cid; 
    }
    int getPlayerPid(){return m_playerid;}
    int getPlayerCid(){return m_characterid;}

    void setPlayerEquipment(GFL_equipment@ equipment){
        @m_equipment = @equipment;
        _log("GFLplayerlist.as: GFL_playerInfo.setPlayerEquipment(): player equipment set successful.");
    }

    GFL_equipment@ getPlayerEquipment(){
        return m_equipment;
    }
}

GFL_playerInfo@ default_playerInfo = GFL_playerInfo(default_int,default_int,default_equipment);
class GFL_playerlist_system : Tracker {
	protected Metagame@ m_metagame;
    protected float m_time = 1.0; 
    protected float m_refresh_time = 5.0; // 刷新时间

	// --------------------------------------------
	GFL_playerlist_system(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    // 更新
    protected void update(float time) {
        if(m_time>=0) {m_time -= time;}
        else m_time = m_refresh_time;
    }

	protected void handlePlayerConnectEvent(const XmlElement@ event) {
		// if the connecting player is among the persistently stored tracked players
		// get his tracking or penalty up and running
		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
 			string newPlayerName = player.getStringAttribute("name");
            GFL_playerInfo@ newPlayerInfo = getPlayerListInfoFromXML(m_metagame,player);
			changePlayerInfoInList(newPlayerName,newPlayerInfo);           
		}
        _log("GFL_playerlist_system: handlePlayerConnectEvent(): player add successful.");
	}

    protected void handlePlayerSpawnEvent(const XmlElement@ event){
		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
 			string newPlayerName = player.getStringAttribute("name");
            GFL_playerInfo@ newPlayerInfo = getPlayerListInfoFromXML(m_metagame,player);
			changePlayerInfoInList(newPlayerName,newPlayerInfo);
		}
        _log("GFL_playerlist_system: handlePlayerSpawnEvent(): player update successful.");
    }    

    protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
		const XmlElement@ player = event.getFirstElementByTagName("player");
		if (player !is null) {
			string deletePlayerName = player.getStringAttribute("name");
            if(CT_PlayerList.exists(deletePlayerName))removePlayerFromList(deletePlayerName);
            else {_log("WARN: GFL_playerlist_system: handlePlayerDisconnectEvent(): no such player.");}
		}	
        _log("GFL_playerlist_system: handlePlayerDisconnectEvent(): player delete successful.");        	
	}	

	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}
}

// 增 - 单个玩家
void addPlayerToList(string player_name,GFL_playerInfo@ player_info) {CT_PlayerList.set(player_name, player_info);}
// 删 - 单个玩家
void removePlayerFromList(string player_name) {CT_PlayerList.erase(player_name);}
// 查 - 玩家数量
int getPlayerNumFromList() {return CT_PlayerList.size();}
// 查 - 得到玩家name序列
array<string> getPlayerKeysFromList() {return CT_PlayerList.getKeys();}    
// 查 - 是否存在玩家
bool existPlayerInList(string player_name) {return CT_PlayerList.exists(player_name);}
// 查 - 得到单个玩家信息
GFL_playerInfo@ getPlayerInfoFromList(string player_name) {GFL_playerInfo@ yyy= cast<GFL_playerInfo>(CT_PlayerList[player_name]); return yyy;}    
// 改 - 单个玩家
void changePlayerInfoInList(string player_name,GFL_playerInfo@ player_info){
    if(existPlayerInList(player_name)) CT_PlayerList[player_name] = player_info;
    else {addPlayerToList(player_name,player_info);}
    _log("GFL_playerlist_system: changePlayerInfoInList(): operation successful.");
}
// 改 - 单个玩家装备
void changePlayerEquipmentInList(string player_name,GFL_equipment@ equipment){
    GFL_playerInfo@ player = cast<GFL_playerInfo>(CT_PlayerList[player_name]);
    player.setPlayerEquipment(equipment);
    CT_PlayerList.set(player_name, player);
    _log("GFLplayerlist.as: changePlayerEquipmentInList(): operation successful.");
}
// 清空
void clearPlayerList() {CT_PlayerList = dictionary();}
// 根据xml制作player_info
GFL_playerInfo@ getPlayerListInfoFromXML(Metagame@ m_metagame, const XmlElement@ player){
    // 录入基本信息（玩家名，pid，cid）
    string player_username = player.getStringAttribute("name");
    int player_playerid = player.getIntAttribute("player_id");
    const XmlElement@ info = getPlayerInfo(m_metagame, player_playerid);

    // 抗null处理
    if(info is null){_log("null info.");return default_playerInfo;}

    int player_characterid = info.getIntAttribute("character_id");
    _log("GFLplayerlist.as: getPlayerListInfoFromXML(): player basic info login successful.");
    // 录入初始装备信息
    const XmlElement@ info2 = getCharacterInfo2(m_metagame,player_characterid);

    // 抗null处理    
    if(info2 is null){_log("null info2.");return default_playerInfo;}

    array<const XmlElement@>@ item = info2.getElementsByTagName("item");
    if(item is null) 
        return default_playerInfo;
    _log("GFLplayerlist.as: getPlayerListInfoFromXML(): player equipment login successful.");
    // 生成gfl_playerlist
    GFL_playerInfo@ playerinfo = GFL_playerInfo();        
    GFL_equipment@ playerequipment = GFL_equipment();
    playerinfo.setPlayerInfo(player_playerid,player_characterid);   
    string weapon1key = item[0].getStringAttribute("key");
    string weapon2key = item[1].getStringAttribute("key");
    string grenadekey = item[2].getStringAttribute("key");
    string armorkey = item[4].getStringAttribute("key"); 
    playerequipment.setWeapon(weapon1key,weapon2key,grenadekey,armorkey);
    playerinfo.setPlayerEquipment(playerequipment);
    _log("GFLplayerlist.as: getPlayerListEquipmentFromXML(): player equipment file spawn successful.");
    return playerinfo;
}

int getPlayerCidFromList(string player_name) {
    if(!existPlayerInList(player_name))return default_int;
    return cast<GFL_playerInfo>(CT_PlayerList[player_name]).getPlayerCid();
}

string getPlayerWeaponFromList(string player_name, int weaponnum) {
    if(!existPlayerInList(player_name))return default_string;
    return cast<GFL_playerInfo>(CT_PlayerList[player_name]).getPlayerEquipment().getWeapon(weaponnum);
}

bool checkCharacterIdisPlayerOwn(string player_name, int cid) {
    if(!existPlayerInList(player_name))return false;
    if(cast<GFL_playerInfo>(CT_PlayerList[player_name]).getPlayerCid()!=cid)return false;
    return true;
}
