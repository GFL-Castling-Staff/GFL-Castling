#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "gamemode_invasion.as"
#include "GFLhelpers.as"
#include "GFLplayerlist.as"

// sid = sid
// 记录玩家武器数据 使用<weapon key="武器key">形式存储在<weapons>元素下
// 记录玩家通用数据
// 每次调用时 从xml文件中转储读取生成player_data
// 每次存储时 将player_data重新封装回新的xml中

class player_data
{
	int m_corenum;
    string m_playername;
    string m_sid;
    array<string> m_weapons;

	player_data() {}

    player_data(const string _player_name, const string _sid)
    {
        m_playername = _player_name;
        m_sid = _sid;
    }

    void addInfo(string tdoll){
        m_inventory.insertLast(tdoll);
    }

    void addWeapon(const string key)
    {
        bool isDuplicate = false;
        for (uint i = 0; i < m_weapons.length(); ++i)
        {
            if (m_weapons[i].key == key)
            {
                isDuplicate = true;
                break;
            }
        }        
        if (!isDuplicate)
        {
            m_weapons.insertLast(key);
        }  
    }

    int GetCoreNum() const
    {
        return m_corenum;
    }

    void SetCoreNum(int newCoreNum)
    {
        m_corenum = newCoreNum;
    }

    bool FindWeapon(const string weaponToFind)
    {
        for (uint i = 0; i < m_weapons.length(); ++i)
        {
            if (m_weapons[i] == weaponToFind)
            {
                return true;
            }
        }
        return false;
    }

    bool checkTdollAvailable(int doll_index){
        int check_id = -1;
        for(uint i=0;i<m_inventory.size();i++){
            if (m_inventory[i].m_doll_index == doll_index){
                check_id = i;
                break;
            }
        }
        if (check_id == -1) return false;
        if (m_inventory[check_id].m_own) return true;
        return false;
    }
}

const XmlElement@ readFile(string filename){
    const XmlElement@ root = readXML(m_metagame,filename).getFirstChild();
    if(root is null){
        _log("readFile is null,create");
        writeXML(m_metagame,filename,PlayerProfileSave(player_data));
        @root = readXML(m_metagame,filename).getFirstChild();
    }
    return root;
}

void writeXML(const Metagame@ metagame, string filename, XmlElement@ xml, string location = "" ){
	XmlElement command("command");
		command.setStringAttribute("class", "save_data");
		command.setStringAttribute("filename", filename);
        if(location != "")
        {
            command.setStringAttribute("location", location);
        }
		command.appendChild(xml);
	metagame.getComms().send(command);
}


const XmlElement@ PlayerProfileSave(player_data@ player_info) {
	XmlElement root("playerdata");
	root.setStringAttribute("username", player_info.m_playername);
	root.setStringAttribute("sid", player_info.m_sid);
    root.setIntAttribute("core_num", player_info.m_corenum);
	string FILENAME =  ("save_" + player_info.m_player_sid +".xml" );

    XmlElement subroot("weapons");

    for (uint i = 0; i < player_info.m_weapons.length(); i++) {
        XmlElement e("weapon");
        e.setStringAttribute("key", player_info.m_weapons[i]);
        subroot.appendChild(e);
    }

    root.appendChild(subroot);
    return root;
}


class Save_System : Tracker {
    protected Metagame@ m_metagame;
    Save_System(Metagame@ metagame)
    {
        @m_metagame = @metagame;
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

    protected void handleChatEvent(const XmlElement@ event){
		string message = event.getStringAttribute("message");
		string p_name = event.getStringAttribute("player_name");
        GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
        if (playerInfo.m_name == default_string ) return;

        string profile_hash = playerInfo.m_hash;

	}
}