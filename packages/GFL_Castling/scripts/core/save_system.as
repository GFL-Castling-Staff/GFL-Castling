#include "helpers.as"

// sid = profile_hash

class player_data
{
    array<Tdoll_Information@> m_inventory;
	int m_corenum;
    string m_playername;
    string m_player_sid;

	player_data(string name, string id) {
		m_playername = name;
		m_player_sid = id;
	}

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
        else return false;
    }
}

class Tdoll_Information
{
    int m_doll_index;
    array<int> m_skin_index;
    array<string> m_type;
    bool m_own;
    Tdoll_Information(int index)
    {
        m_doll_index = index;
    }

    void addSkinIndex(int skin_index)
    {
        for(uint i=0;i<m_skin_index.size();i++){
            if (m_skin_index[i] == skin_index){
                return;
            }
        }
        m_skin_index.insertLast(skin_index);
    }

    void addType(string type)
    {
        for(uint i=0;i<m_type.size();i++){
            if (m_type[i] == type){
                return;
            }
        }
        m_type.insertLast(type);
    }

    void enable()
    {
        m_own = true;
    }

    void disable()
    {
        m_own = false;
    }
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