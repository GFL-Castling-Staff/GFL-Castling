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

class player_data
{
    array<string> m_inventory;
	int m_corenum;
    string m_playername;

	player_data() {}

    void setCoreNumber(int core){
        m_corenum = core;
    }

    void addInfo(Tdoll_Information@ tdoll){
        m_inventory.insertLast(tdoll);
    }

    bool costCore(int num){
        if((m_corenum-num) <0){
            return false;
        }
        m_corenum -= num;
        return true;
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
        writeXML(m_metagame,filename,XmlElement(filename));
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


void PlayerProfileSave(Metagame@ m_metagame,player_data@ player_info) {
	XmlElement root("playerdata");
	root.setStringAttribute("username", player_info.m_playername);
	root.setStringAttribute("sid", player_info.m_player_sid);
    root.setIntAttribute("core_num", player_info.m_corenum);
	string FILENAME =  ("save_" + player_info.m_player_sid +".xml" );

    XmlElement subroot("Tdoll_Information");

    for (uint i = 0; i < player_info.m_inventory.size(); i++) {
        Tdoll_Information@ m_information = player_info.m_inventory[i];
        XmlElement e("Tdoll");
        e.setIntAttribute("index", m_information.m_doll_index);
        e.setBoolAttribute("own", m_information.m_own);

        if(m_information.m_skin_index.size() <= 0){continue;}
        for(uint i1 =0; i1<m_information.m_skin_index.size();i1++) {
            XmlElement e1("skin");
            e1.setIntAttribute("skin_index",m_information.m_skin_index[i1]);
            e.appendChild(e1);
        }
        

        if(m_information.m_type.size() <= 0){continue;}
        for(uint i2 =0; i2<m_information.m_type.size();i2++) {
            XmlElement e1("type");
            e1.setStringAttribute("type_name",m_information.m_type[i2]);
            e.appendChild(e1);
        }

        subroot.appendChild(e);
    }

    root.appendChild(subroot);

	XmlElement command("command");
	command.setStringAttribute("class", "save_data");
	command.setStringAttribute("filename", FILENAME);
	command.appendChild(root);

	m_metagame.getComms().send(command);

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