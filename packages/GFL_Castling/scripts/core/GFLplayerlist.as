#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"

//Originally created by Saiwa

// 本系统用于容纳有关玩家的请求

array<GFL_playerlist@> GFL_playerlist_array;

class GFL_playerlist{
	string m_username = "";
	string m_ip = "";
	string m_sid = "ID0";   

    int m_characterid;      //角色id
	int m_playerid;         //玩家id

    string m_pos;           //当前刷新位置
    string m_old_pos;       //上次刷新位置

    int m_rp;               //rp数
    float m_xp;             //xp数

    dictionary m_equipment; //玩家装备（包括武器啊副武器啊投掷物这些,主要可能后面存档会添加额外装备）

    //string m_weapon1key;    //主武器key
    //string m_weapon2key;    //副武器key
    //string m_weapon3key;    //投掷物key
    //string m_vestkey;       //甲key
    //string m_itemkey;       //掉落物key

    GFL_playerlist(string username, string ip, string sid, int cid, int pid, int pos, dictionary@ equipment){
        m_username = username;
        m_ip = ip;
        m_sid = sid;
        m_characterid = cid;
	    m_playerid = pid;
        m_old_pos = m_pos;
        m_pos = pos;
        m_rp= 0;
        m_xp= 0;      

        m_equipment = equipment;
    }

    void updatePos(string pos){ 
        m_old_pos = m_pos;
        m_pos= pos;
    }
}

class GFL_playerlist_system : Tracker {
	protected GameMode@ m_metagame;
    protected float m_time = 1.0; 
    protected float m_refresh_time = 5.0; // 刷新时间
    protected dictionary m_playerlist_info;

	// --------------------------------------------
	GFL_playerlist_system(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

    void update(float time) {
        if(m_time>=0) {m_time -= time;continue;}
        m_time = m_refresh_time;
        refresh();
    }

    void add(int player_sid, GFL_playerlist@ player_info) {
        m_playerlist_info.set(player_sid, @player_info);
    }

    void remove(int player_sid) {
        m_playerlist_info.erase(player_sid);
    }

    array<string> getKeys() const {
        return m_playerlist_info.getKeys();
    }

    bool exist(int player_sid) const {
        return m_playerlist_info.exist(player_sid);
    }

	void clear() {
		m_playerlist_info = dictionary();
	}

    int num() {
        return m_playerlist_info.size();
    }

    GFL_playerlist@ get(string key) const {
		GFL_playerlist@ player;
		m_players.get(key, @player);
		return player;
	}

    void changeRefreshTime(float time){
        m_refresh_time = time;
    }

    void refresh(){          
        
        array<const XmlElement@> nowPlayers = getPlayers(m_metagame);
        if (nowPlayers is null){return;}

        // 彻底删除一次并全部重新更新
        for(uint i=0;i<nowPlayers.length();i++){

            int cid = nowPlayers[i].getIntAttribute("character_id");
            int pid = nowPlayers[i].getIntAttribute("player_id");
            const XmlElement@ targetCharacter = getCharacterInfo2(m_metagame,cid);

            if(targetCharacter is null){continue;}
            string pos = targetCharacter.getStringAttribute("position");
            array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
            if(equipment is null){continue;}

            dictionary player_equipment = {
                {"m_weapon1key",equipment[0].getStringAttribute("key")},
                {"m_weapon2key",equipment[1].getStringAttribute("key")},
                {"m_weapon3key",equipment[2].getStringAttribute("key")},
                {"m_vestkey",equipment[4].getStringAttribute("key")},
                {"m_itemkey",equipment[3].getStringAttribute("key")},
            };

            GFL_playerlist@ new_player = GFL_playerlist("", "192.168.0.0.", "666", cid, pid, pos, @player_equipment); 
            // 没太看懂username,ip,sid是如何获取的，先暂且这么写
            GFL_playerlist_array.insertLast(new_player);
            if (startsWith(w4,'srexo_t6'))
            {   
                healCharacter(m_metagame,cid,1);
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

}

int getPlayerCidFromList(int playerid) {
    if(GFL_playerlist_array.length()<=0){return -1;}
    for(uint i=0;i<GFL_playerlist_array.length();i++){
        if(GFL_playerlist_array[i].m_playerid == playerid)
            return GFL_playerlist_array[i].m_characterid;
    }
    return -1;
}

string getPlayerWeaponFromList(int playerid, int weaponnum) {
    if(GFL_playerlist_array.length()<=0){return "-nan-";}
    for(uint i=0;i<GFL_playerlist_array.length();i++){
        if(GFL_playerlist_array[i].m_playerid == playerid){
            switch(weaponnum){
                case 0:{return GFL_playerlist_array[i].m_weapon1key;}
                case 1:{return GFL_playerlist_array[i].m_weapon2key;}
                case 2:{return GFL_playerlist_array[i].m_weapon3key;}
                case 3:{return GFL_playerlist_array[i].m_vestkey;}
                case 4:{return GFL_playerlist_array[i].m_itemkey;}
                default:{return "-nan-";}
            }
        }
    }
    return "-nan-";
}

bool checkIdle(int playerid){
    if(GFL_playerlist_array.length()<=0){return false;}
    for(uint i=0;i<GFL_playerlist_array.length();i++){
        if(GFL_playerlist_array[i].m_playerid != playerid){continue;}
        if (GFL_playerlist_array[i].m_pos == GFL_playerlist_array[i].m_old_pos){
            return true;
        }
    }
    return false;
}

void givePlayerRPcount(int playerid,int rp_count){
    if(GFL_playerlist_array.length()<=0){return;}
    for(uint i=0;i<GFL_playerlist_array.length();i++){
        if(GFL_playerlist_array[i].m_playerid == playerid){
            GFL_playerlist_array[i].m_rp +=rp_count;
        }
    }
    
}

void givePlayerXPcount(int playerid,float xp_count){
    if(GFL_playerlist_array.length()<=0){return;}
    for(uint i=0;i<GFL_playerlist_array.length();i++){
        if(GFL_playerlist_array[i].m_playerid == playerid){
            GFL_playerlist_array[i].m_xp +=xp_count;
        }
    }
}