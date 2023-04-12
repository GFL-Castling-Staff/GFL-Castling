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

array<GFL_playerInfo@> CT_PlayerList;


class GFL_equipment{
    string m_weapon1key = default_string;
    string m_weapon2key = default_string;
    string m_grenadekey = default_string;
    string m_armorkey = default_string;
    Vector3 m_new_pos = default_Vector3;
    Vector3 m_old_pos = default_Vector3;

    GFL_equipment(string weapon1key, string weapon2key, string grenadekey, string armorkey, Vector3 pos){
        m_weapon1key = weapon1key;
        m_weapon2key = weapon2key;
        m_grenadekey = grenadekey;
        m_armorkey = armorkey;
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

GFL_equipment@ default_equipment = GFL_equipment(default_string,default_string,default_string,default_string,default_Vector3);

class GFL_playerInfo{
	int m_playerid;    //玩家id
    int m_characterid; //角色id
    string m_name;
    GFL_equipment@ m_equipment; //玩家装备（包括武器啊副武器啊投掷物这些,主要可能后面存档会添加额外装备）
	string m_ip;
	string m_sid;   
    float m_xp = 0;
    int m_rp = 0;
    
    // 玩家物品栏
    GFL_playerInfo(string name,int pid, int cid, GFL_equipment@ equipment){
        m_name = name;
	    m_playerid = pid;
        m_characterid = cid;
        @m_equipment = @equipment;
    }

    GFL_playerInfo(){}

    // 增删改单个玩家装备(注意clearEquipment不是直接删除字典)
    void setPlayerInfo(string name=default_string,int pid=default_int, int cid=default_int){
        m_name = name;
	    m_playerid = pid;
        m_characterid = cid; 
    }
    int getPlayerPid(){return m_playerid;}
    int getPlayerCid(){return m_characterid;}
    string getPlayerName(){return m_name;}
    void setXp(float xp){
        m_xp = xp;
    }
    void setRp(int rp){
        m_rp = rp;
    }
    
    float getXp(){return m_xp;}
    int getRp(){return m_rp;}

    void setPlayerEquipment(GFL_equipment@ equipment){
        @m_equipment = @equipment;
    }

    GFL_equipment@ getPlayerEquipment(){
        return m_equipment;
    }
}

GFL_playerInfo@ default_playerInfo = GFL_playerInfo(default_string,default_int,default_int,default_equipment);

class GFL_playerlist_system : Tracker {
	protected Metagame@ m_metagame;
    protected float m_time = 1.0; 
    protected float m_refresh_time = 5.0; // 刷新时间

	// --------------------------------------------
	GFL_playerlist_system(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    // 更新
    void update(float time) {
        m_time -= time;
        if(m_time<0){
            m_time = m_refresh_time;
            refresh();
        }
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

    void refresh(){
        while(CT_PlayerList.length()>0){        
            int index_last = CT_PlayerList.length() -1;
            GFL_playerInfo@ player = CT_PlayerList[index_last];
            if(player.m_rp >0)
            {
                GiveRP(m_metagame,player.m_characterid,player.m_rp);
            }
            if(player.m_xp >0)
            {
                GiveXP(m_metagame,player.m_characterid,player.m_xp);
            }            
            CT_PlayerList.removeLast();
        }  

        array<const XmlElement@> nowPlayers = getPlayers(m_metagame);
        if (nowPlayers !is null){
            for(uint i=0;i<nowPlayers.length();i++){
                if (nowPlayers[i] is null) continue;
                string newPlayerName = nowPlayers[i].getStringAttribute("name");
                GFL_playerInfo@ newPlayerInfo = getPlayerListInfoFromXML(m_metagame,nowPlayers[i]);
                manageEventOfRefresh(newPlayerInfo);
                CT_PlayerList.insertLast(newPlayerInfo);
            }
        }
    }

    void manageEventOfRefresh(GFL_playerInfo@ info){
        int cid = info.getPlayerCid(); 
        if(cid==-1) return;
        GFL_equipment@ equipment = info.getPlayerEquipment();
        string armor = equipment.getWeapon(3);
        if(startsWith(armor,"srexo_t6")) healCharacter(m_metagame,cid,2);
    }
}

// 删 - 单个玩家
void removePlayerFromList(string player_name) {
    int index = -1;
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name)
            {
                index = i;
            }
        }
    }
    if (index == -1) return;
    CT_PlayerList.removeAt(index);
}

// 查 - 玩家数量
int getPlayerNumFromList() {
    return CT_PlayerList.size();
}

// 查 - 是否存在玩家
bool existPlayerInList(string player_name) {
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name) return true;
        }
    }
    return false;
}

int getPlayerIndexFromList(string player_name) {
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name) return i;
        }
    }
    return -1;
}

// 查 - 得到单个玩家信息
GFL_playerInfo@ getPlayerInfoFromList(string player_name) {
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name) return CT_PlayerList[i];
        }
    }
    return default_playerInfo;
}    

// 根据xml制作player_info
GFL_playerInfo@ getPlayerListInfoFromXML(Metagame@ m_metagame, const XmlElement@ player){
    // 录入基本信息（玩家名，pid，cid）
    string player_username = player.getStringAttribute("name");
    int player_playerid = player.getIntAttribute("player_id");
    int player_characterid = player.getIntAttribute("character_id");

    // 录入初始装备信息
    const XmlElement@ info2 = getCharacterInfo2(m_metagame,player_characterid);

    // 抗null处理    
    if(info2 is null){_log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): null info2, using default playerinfo.");return default_playerInfo;}

    array<const XmlElement@>@ item = info2.getElementsByTagName("item");
    if(item is null || item.size()!=5) {
        _log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): invalid player item, using default equipment.");
        return default_playerInfo;
    }

    // 生成gfl_playerlist
    GFL_playerInfo@ playerinfo = GFL_playerInfo();        
    GFL_equipment@ playerequipment = GFL_equipment();
    playerinfo.setPlayerInfo(player_username,player_playerid,player_characterid);   
    string weapon1key = item[0].getStringAttribute("key");
    string weapon2key = item[1].getStringAttribute("key");
    string grenadekey = item[2].getStringAttribute("key");
    string armorkey = item[4].getStringAttribute("key"); 
    playerequipment.setWeapon(weapon1key,weapon2key,grenadekey,armorkey);
    playerinfo.setPlayerEquipment(playerequipment);
    return playerinfo;
}

int getPlayerCidFromList(string player_name) {
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name)
                return CT_PlayerList[i].getPlayerCid();
        }
    }
    return -1;
}

string getPlayerWeaponFromList(string player_name, int weaponnum) {
    int index = -1;
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_name == player_name)
            {
                index = i;
            }
        }
    }
    if (index == -1) return default_string;
    GFL_equipment@ equipment = CT_PlayerList[index].getPlayerEquipment();
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

string getPlayerWeaponFromListByID(int cid, int weaponnum) {
    int index = -1;
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_characterid == cid)
            {
                index = i;
            }
        }
    }
    if (index == -1) return default_string;
    GFL_equipment@ equipment = CT_PlayerList[index].getPlayerEquipment();
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

string getPlayerWeaponFromListByPID(int pid, int weaponnum) {
    int index = -1;
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_playerid == pid)
            {
                index = i;
            }
        }
    }
    if (index == -1) return default_string;
    GFL_equipment@ equipment = CT_PlayerList[index].getPlayerEquipment();
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

bool checkCharacterIdisPlayerOwn(int cid) {
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_characterid == cid) return true;
        }
    }
    return false;
}

void givePlayerRPcount(int playerid,int rp_count){
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_playerid == playerid){
                CT_PlayerList[i].m_rp +=rp_count;
            }
        }
    }    
}

void givePlayerXPcount(int playerid,float xp_count){
    if(CT_PlayerList.length()>0){
        for(uint i=0;i<CT_PlayerList.length();i++){
            if(CT_PlayerList[i].m_playerid == playerid){
                CT_PlayerList[i].m_xp +=xp_count;
            }
        }
    }    
}