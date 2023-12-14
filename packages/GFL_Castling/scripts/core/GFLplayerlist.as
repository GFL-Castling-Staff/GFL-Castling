#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLparameters.as"

//Originally created by Saiwa
//Remastered by NetherCrow

// 本系统用于容纳有关玩家的请求

GFL_playerInfo_Buck@ g_playerInfo_Buck = GFL_playerInfo_Buck();

class GFL_equipment{
    string m_weapon1key = default_string;
    string m_weapon2key = default_string;
    string m_grenadekey = default_string;
    string m_armorkey = default_string;
    int m_weapon1num =0;
    int m_weapon2num =0;
    int m_grenadenum =0;
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

    void setNum(int a,int b,int c)
    {
        m_weapon1num = a;
        m_weapon2num = b;
        m_grenadenum = c;
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

    int getWeaponNum(int num){
        switch(num){
            case 0:{return m_weapon1num;}
            case 1:{return m_weapon2num;}
            case 2:{return m_grenadenum;}
            default:{_log("WARN: GFLplayerlist: GFL_equipment(): invalid weapon number.");return 0;}
        }
        return 0;
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
    string m_name;
	int m_playerid;    //玩家id
    int m_characterid; //角色id
    int m_factionid; //阵营id
    GFL_equipment@ m_equipment; //玩家装备
	string m_hash;
	string m_sid;
    float m_xp_reward = 0; // xp奖励
    int m_rp_reward = 0; // rp奖励
    rgba_color@ m_color;
    bool m_available; //用途判定是否掉线，是否该info无效，在函数应用部分判断作错误处理
    
    // 玩家物品栏
    GFL_playerInfo(string name,int pid, int cid,int fid, string hash,string sid,GFL_equipment@ equipment,rgba_color@ color){
        m_name = name;
	    m_playerid = pid;
        m_characterid = cid;
        m_factionid = fid;
        m_hash = hash;
        m_sid = sid;
        @m_equipment = @equipment;
        @m_color = color;
        m_available= true;
    }

	void update(string name,int pid, int cid,int fid, string hash,string sid,GFL_equipment@ equipment,rgba_color@ color){
        m_name = name;
	    m_playerid = pid;
        m_characterid = cid;
        m_factionid = fid;
        m_hash = hash;
        m_sid = sid;
        @m_equipment = @equipment;
        m_color = color;
        m_available = true;
	}    
    int getPlayerPid(){return m_playerid;}
    int getPlayerCid(){return m_characterid;}
    int getPlayerFid(){return m_factionid;}
    string getPlayerName(){return m_name;}
    string getHash(){return m_hash;}
    string getSid(){return m_sid;}
    rgba_color@ getColor(){return m_color;}

    void setXp(float xp){
        m_xp_reward = xp;
    }
    void setRp(int rp){
        m_rp_reward = rp;
    }
    float getXp(){return m_xp_reward;}
    int getRp(){return m_rp_reward;}

    void addXp(float xp)
    {
        m_xp_reward +=xp;
    }
    void addRp(int rp)
    {
        m_rp_reward +=rp;
    }
    void setHash(string hash){
        m_hash = hash;
    }
    void setSid(string sid){
        m_sid = sid;
    }
    void setPlayerEquipment(GFL_equipment@ equipment){
        @m_equipment = @equipment;
    }
    GFL_equipment@ getPlayerEquipment(){
        return m_equipment;
    }
    void handleRpReward(Metagame@ m_metagame)
    {
        if(m_rp_reward > 0)
        {
            GiveRP(m_metagame,m_characterid,m_rp_reward);
            m_rp_reward = 0;
        }
    }
    void handleXpReward(Metagame@ m_metagame)
    {
        if(m_xp_reward > 0)
        {
            GiveXP(m_metagame,m_characterid,m_xp_reward);
            m_xp_reward = 0;
        }
    }
    bool check_Available()
    {
        return m_available;
    }
    void ForceDisable()
    {
        m_available = false;
    }
}

class GFL_playerInfo_Buck
{
	array<GFL_playerInfo@> m_playerInfo;

	GFL_playerInfo_Buck(){
		clearAll();
	}    

	uint size(){return m_playerInfo.size();}

    void addNewInfo(string name,int pid, int cid,int fid, string hash,string sid,GFL_equipment@ equipment,rgba_color@ color){
        m_playerInfo.insertLast(GFL_playerInfo(name,pid,cid,fid,hash,sid,equipment,color));    
    }

    void update(string name,int pid, int cid,int fid, string hash,string sid,GFL_equipment@ equipment,rgba_color@ color){
        for(uint i=0; i<size();++i){
			if(name == m_playerInfo[i].getPlayerName()){
				m_playerInfo[i].update(name,pid,cid,fid,hash,sid,equipment,color);
			}
		}
    }

	bool existName(string name){
		for(uint i=0; i<size();++i){
			if(name == m_playerInfo[i].getPlayerName()){
				return true;
			}
		}
		return false;
	}

    bool existCid(int cid){
        for(uint i=0; i<size();++i){
			if(cid == m_playerInfo[i].getPlayerCid()){
				return true;
			}
		}
		return false;
    }

    bool existPid(int pid){
        for(uint i=0; i<size();++i){
			if(pid == m_playerInfo[i].getPlayerPid()){
				return true;
			}
		}
		return false;
    }    

    void removeByName(string name) {
        for (int i = m_playerInfo.size() - 1; i >= 0; --i) {
            string p_name = m_playerInfo[i].getPlayerName();
            if (name == p_name) {
                m_playerInfo.removeAt(i);
            }
        }
    }

	void removeByIndex(int index){
        m_playerInfo.removeAt(index);
	}    

    int getIndexByName(string name)
    {
		for(uint i=0; i<size();++i){
			if(name == m_playerInfo[i].getPlayerName()){
				return i;
			}
		}        
        return -1;
    }

    int getCidByName(string name)
    {
		for(uint i=0; i<size();++i){
			if(name == m_playerInfo[i].getPlayerName()){
				return m_playerInfo[i].getPlayerCid();
			}
		}        
        return -1;        
    }

    GFL_playerInfo@ getInfoByPid(int pid)
    {
        //慎用
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                return m_playerInfo[i];
            }
        }
        return default_playerInfo;
    }

    GFL_playerInfo@ getInfoByName(string name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                return m_playerInfo[i];
            }
        }
        return default_playerInfo;
    }    

    GFL_equipment@ getEquipmentByName(string name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                return m_playerInfo[i].getPlayerEquipment();
            }
        }
        return default_equipment;
    }

    GFL_equipment@ getEquipmentByCid(int cid)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerCid() == cid){
                return m_playerInfo[i].getPlayerEquipment();
            }
        }
        return default_equipment;
    }

    GFL_equipment@ getEquipmentByPid(int pid)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                return m_playerInfo[i].getPlayerEquipment();
            }
        }
        return default_equipment;
    }    

	void clearAll(){
		m_playerInfo.resize(0);
	}

    void addrpReward(int playerid,int rp_count){
        for(uint i=0;i<size();i++){
            if(m_playerInfo[i].getPlayerPid() == playerid){
                m_playerInfo[i].addRp(rp_count);
            }
        }
    }

    void addxpReward(int playerid,float xp_count){
        for(uint i=0;i<size();i++){
            if(m_playerInfo[i].getPlayerPid() == playerid){
                m_playerInfo[i].addXp(xp_count);
            }
        }
    }    
}

GFL_playerInfo@ default_playerInfo = GFL_playerInfo(default_string,default_int,default_int,default_int,default_string,default_string,default_equipment,rgba_color());

class GFL_playerlist_system : Tracker {
	protected Metagame@ m_metagame;
    protected float m_time = 1.0; 
    protected float m_refresh_time = 10.0; // 刷新时间
    protected float m_event_timer = 1.0; 
    protected float m_event_time = 5.0; // 事件刷新时间    
	// --------------------------------------------
	GFL_playerlist_system(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    // 更新
    void update(float time) {
        m_time -= time;
        m_event_timer-= time;
        if(m_time <= 0.0)
        {
            m_time = m_refresh_time;
            array<const XmlElement@> m_players = getPlayers(m_metagame);
            if(m_players is null){return;}
            for (uint j = 0; j < m_players.size(); ++j) {
                const XmlElement@ player = m_players[j];
                if(player is null){return;}
                updatePlayerInfo(player);
            }
            for (uint i = 0; i < g_playerInfo_Buck.size();++i)
            {
                if(g_playerInfo_Buck.m_playerInfo[i].check_Available() == false)
                {
                    //在处理完所有新增的players后，把被标记为不可用的info删除
                    g_playerInfo_Buck.removeByIndex(i);
                    --i;
                }
            }
        }
        if(m_event_timer<=0.0)
        {   
            m_event_timer = m_event_time;
            for (uint j = 0; j < g_playerInfo_Buck.size(); ++j) {
                GFL_playerInfo@ player = g_playerInfo_Buck.m_playerInfo[j];
                if(player is null){return;}
                manageEventOfRefresh(player);
            }
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

    void manageEventOfRefresh(GFL_playerInfo@ info){
        int cid = info.getPlayerCid(); 
        if(cid==-1) return;
        GFL_equipment@ equipment = info.getPlayerEquipment();
        string armor = equipment.getWeapon(3);
        if(startsWith(armor,"srexo_t6")) healCharacter(m_metagame,cid,2);
        info.handleRpReward(m_metagame);
        info.handleXpReward(m_metagame);
    }

    protected void handleMatchEndEvent(const XmlElement@ event){
		const XmlElement@ winCondition = event.getFirstElementByTagName("win_condition");
		if (winCondition !is null) {
			int factionId = winCondition.getIntAttribute("faction_id");
            if (factionId == 0) 
            {
                if(g_playerInfo_Buck.size() <= 0) return;
                for(uint i=0;i<g_playerInfo_Buck.size();i++){
                    string c_weaponType = g_playerInfo_Buck.m_playerInfo[i].getPlayerEquipment().getWeapon(0);
                    if(
                        c_weaponType == "gkw_98kmod3.weapon" ||
                        c_weaponType == "gkw_98kmod3_skill.weapon" ||
                        c_weaponType == "gkw_98kmod3_4301.weapon" ||
                        c_weaponType == "gkw_98kmod3_4301_skill.weapon" ||
                        c_weaponType == "gkw_98kmod3_8301.weapon" ||
                        c_weaponType == "gkw_98kmod3_8301_skill.weapon"                     
                        )
                    {
                        string strname= g_playerInfo_Buck.m_playerInfo[i].getPlayerName();
                        int j = findNodeleteDataIndex(strname,"kar98k");

                        if(j>=0){
                            No_Delete_DataArray[j].add();
                            const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                            if (characterInfo is null) return;
                            string c_pos = characterInfo.getStringAttribute("position");
                            spawnStaticProjectile(m_metagame,"particle_effect_98k_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
                        }
                        else{
                            No_Delete_DataArray.insertLast(no_delete_data(strname,1,"kar98k"));       
                            const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                            if (characterInfo is null) return;
                            string c_pos = characterInfo.getStringAttribute("position");
                            spawnStaticProjectile(m_metagame,"particle_effect_98k_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));                            
                        }
                    }
                    else if(
                        c_weaponType == "gkw_ppsh41mod3.weapon" ||
                        c_weaponType == "gkw_ppsh41mod3_602.weapon")
                    {
                        string strname= g_playerInfo_Buck.m_playerInfo[i].getPlayerName();
                        int j = findNodeleteDataIndex(strname,"ppsh41");

                        if(j>=0){
                            No_Delete_DataArray[j].add();
                            const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                            if (characterInfo is null) return;
                            string c_pos = characterInfo.getStringAttribute("position");
                            spawnStaticProjectile(m_metagame,"particle_effect_ppsh41_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
                        }
                        else{
                            No_Delete_DataArray.insertLast(no_delete_data(strname,1,"ppsh41"));       
                            const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                            if (characterInfo is null) return;
                            string c_pos = characterInfo.getStringAttribute("position");
                            spawnStaticProjectile(m_metagame,"particle_effect_ppsh41_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
                        }
                    }
                }
            }
        }
    }    

    protected void handlePlayerDisconnectEvent(const XmlElement@ event) {
        const XmlElement@ player = event.getFirstElementByTagName("player");
        if(player is null){return;}
        if(g_playerInfo_Buck is null){return;}
        string name = player.getStringAttribute("name");
        int index = g_playerInfo_Buck.getIndexByName(name); 
        if(index < 0){return;}
        g_playerInfo_Buck.m_playerInfo[index].ForceDisable();
    }

    protected void handlePlayerSpawnEvent(const XmlElement@ event) {
        const XmlElement@ player = event.getFirstElementByTagName("player");
        if(player is null){return;}
        updatePlayerInfo(player);
    }

    void updatePlayerInfo(const XmlElement@ player){
        if(player is null){return;}
        string player_username = player.getStringAttribute("name");
        int player_playerid = player.getIntAttribute("player_id");
        int player_characterid = player.getIntAttribute("character_id");
        int player_factionid = player.getIntAttribute("faction_id"); 
        string player_color_raw = player.getStringAttribute("color");
        string player_profile_hash = player.getStringAttribute("profile_hash");
        string player_sid = player.getStringAttribute("sid");        
        rgba_color player_color = stringToRGBA(player_color_raw);

        const XmlElement@ info2 = getCharacterInfo2(m_metagame,player_characterid);
        // 抗null处理
        if(info2 is null){_log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): null info2, using default playerinfo.");return;}

        array<const XmlElement@>@ item = info2.getElementsByTagName("item");
        if(item is null || item.size()!=5) {
            _log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): invalid player item, aborted.");
            return;
        }
        GFL_equipment@ player_equipment = GFL_equipment();
        string weapon1key = item[0].getStringAttribute("key");
        string weapon2key = item[1].getStringAttribute("key");
        string grenadekey = item[2].getStringAttribute("key");
        string armorkey = item[4].getStringAttribute("key"); 
        int weapon1num = item[0].getIntAttribute("amount");
        int weapon2num = item[1].getIntAttribute("amount");
        int grenadenum = item[2].getIntAttribute("amount");
        player_equipment.setWeapon(weapon1key,weapon2key,grenadekey,armorkey);
        player_equipment.setNum(weapon1num,weapon2num,grenadenum);

        if(g_playerInfo_Buck is null){return;}
        if(g_playerInfo_Buck.existName(player_username)){
            //已有玩家信息
            int index = getPlayerIndexFromList(player_username);
            if(index < 0) return;
            g_playerInfo_Buck.update(player_username,player_playerid,player_characterid,player_factionid,player_profile_hash,player_sid,player_equipment,player_color);
        }
        else{
            g_playerInfo_Buck.addNewInfo(player_username,player_playerid,player_characterid,player_factionid,player_profile_hash,player_sid,player_equipment,player_color);
        }
    }
}

// 删 - 单个玩家
void removePlayerFromList(string player_name) {
    g_playerInfo_Buck.removeByName(player_name);
}

// 查 - 玩家数量
int getPlayerNumFromList() {
    return g_playerInfo_Buck.size();
}

// 查 - 是否存在玩家
bool existPlayerInList(string player_name) {
    return g_playerInfo_Buck.existName(player_name);
}

int getPlayerIndexFromList(string player_name) {
    return g_playerInfo_Buck.getIndexByName(player_name);
}

// 查 - 得到单个玩家信息
GFL_playerInfo@ getPlayerInfoFromList(string player_name) {
    return g_playerInfo_Buck.getInfoByName(player_name);
}

// 慎用 查 - 得到单个玩家信息
GFL_playerInfo@ getPlayerInfoFromListbyPid(int pid) {
    return g_playerInfo_Buck.getInfoByPid(pid);
}    

// 根据xml制作player_info
// GFL_playerInfo@ getPlayerListInfoFromXML(Metagame@ m_metagame, const XmlElement@ player){
//     // 录入基本信息（玩家名，pid，cid）
//     string player_username = player.getStringAttribute("name");
//     int player_playerid = player.getIntAttribute("player_id");
//     int player_characterid = player.getIntAttribute("character_id");

//     // 录入初始装备信息
//     const XmlElement@ info2 = getCharacterInfo2(m_metagame,player_characterid);

//     // 抗null处理    
//     if(info2 is null){_log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): null info2, using default playerinfo.");return default_playerInfo;}

//     array<const XmlElement@>@ item = info2.getElementsByTagName("item");
//     if(item is null || item.size()!=5) {
//         _log("WARN: GFLplayerlist.as: getPlayerListInfoFromXML(): invalid player item, using default equipment.");
//         return default_playerInfo;
//     }

//     // 生成gfl_playerlist
//     GFL_playerInfo@ playerinfo = GFL_playerInfo();        
//     GFL_equipment@ playerequipment = GFL_equipment();
//     playerinfo.setPlayerInfo(player_username,player_playerid,player_characterid);   
//     string weapon1key = item[0].getStringAttribute("key");
//     string weapon2key = item[1].getStringAttribute("key");
//     string grenadekey = item[2].getStringAttribute("key");
//     string armorkey = item[4].getStringAttribute("key"); 
//     playerequipment.setWeapon(weapon1key,weapon2key,grenadekey,armorkey);
//     playerinfo.setPlayerEquipment(playerequipment);

//     string profile_hash = player.getStringAttribute("profile_hash"); 
//     playerinfo.setHash(profile_hash);
//     string sid = player.getStringAttribute("sid"); 
//     playerinfo.setSid(sid);    
//     return playerinfo;
// }

int getPlayerCidFromList(string player_name) {
    return g_playerInfo_Buck.getCidByName(player_name);
}

string getPlayerWeaponFromList(string player_name, int weaponnum) {
    GFL_equipment@ equipment = g_playerInfo_Buck.getEquipmentByName(player_name);
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

string getPlayerWeaponFromListByID(int cid, int weaponnum) {
    GFL_equipment@ equipment = g_playerInfo_Buck.getEquipmentByCid(cid);
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

string getPlayerWeaponFromListByPID(int pid, int weaponnum) {
    GFL_equipment@ equipment = g_playerInfo_Buck.getEquipmentByPid(pid);
    string weaponinfo = equipment.getWeapon(weaponnum);
    if(weaponinfo == default_string) _log("WARN: GFLplayerlist.as: getPlayerWeaponFromList(): player weapon is nan.");
    return weaponinfo;
}

int getPlayerWeaponAmountFromListByPID(int pid, int weaponnum) {
    GFL_equipment@ equipment = g_playerInfo_Buck.getEquipmentByPid(pid);
    return equipment.getWeaponNum(weaponnum);
}

bool checkCharacterIdisPlayerOwn(int cid) {
    return g_playerInfo_Buck.existCid(cid);
}

void givePlayerRPcount(int playerid,int rp_count){
    g_playerInfo_Buck.addrpReward(playerid,rp_count);
}

void givePlayerXPcount(int playerid,float xp_count){
    g_playerInfo_Buck.addxpReward(playerid,xp_count);
}