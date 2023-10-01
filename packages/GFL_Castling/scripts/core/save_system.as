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
	int m_corenum=0;
    string m_playername;
    string m_profile_hash;
    string m_sid;

    array<string> m_weapons={};

	player_data() {}

    player_data(const string _player_name, const string _profile_hash)
    {
        m_playername = _player_name;
        m_profile_hash = _profile_hash;
    }

    void addWeapon(const string key)
    {
        bool isDuplicate = false;
        for (uint i = 0; i < m_weapons.length(); ++i)
        {
            if (m_weapons[i] == key)
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

    string GetSid() const
    {
        return m_sid;
    }

    void SetSid(string sid)
    {
        m_sid = sid;
    }

    int getAllNum() const
    {
        return m_weapons.length();
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

    string getRandomWeapon() const
    {
        if(m_weapons.length() <= 0 ) return "";
        uint index = rand(0,m_weapons.length()-1);
        return m_weapons[index];
    }

}

const XmlElement@ readFile(const Metagame@ metagame,string name, string profile_hash){
    string filename = ("save_" + profile_hash +".xml" );
    const XmlElement@ root = readXML(metagame,filename).getFirstChild();
    if(root is null){
        _log("readFile is null,create");
        XmlElement@ new_xml = PlayerProfileSave(player_data(name,profile_hash));
        writeXML(metagame,filename,new_xml);
        @root = readXML(metagame,filename).getFirstChild();
    }
    return root;
}

const XmlElement@ readXML(const Metagame@ metagame, string filename){
	XmlElement@ query = XmlElement(
		makeQuery(metagame, array<dictionary> = {
			dictionary = { {"TagName", "data"}, {"class", "saved_data"}, {"filename", filename}}}));
	const XmlElement@ xml = metagame.getComms().query(query);
    if(xml !is null){
        return xml;
    }
	else{
        return null;
    }
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

XmlElement@ PlayerProfileSave(player_data@ player_info) {
	XmlElement root("playerdata");
	root.setStringAttribute("username", player_info.m_playername);
	root.setStringAttribute("sid", player_info.m_sid);
	root.setStringAttribute("profile_hash", player_info.m_profile_hash);
    root.setIntAttribute("core_num", player_info.m_corenum);
	string FILENAME =  ("save_" + player_info.m_sid +".xml" );

    XmlElement subroot("weapons");

    for (uint i = 0; i < player_info.m_weapons.length(); i++) 
    {
        XmlElement e("weapon");
        e.setStringAttribute("key", player_info.m_weapons[i]);
        subroot.appendChild(e);
    }

    root.appendChild(subroot);
    return root;
}

player_data@ PlayerProfileLoad(const XmlElement@ player_profile){
    string m_username = player_profile.getStringAttribute("username");
    string m_profile_hash = player_profile.getStringAttribute("profile_hash");
    string m_sid = player_profile.getStringAttribute("sid");
    int m_corenum = player_profile.getIntAttribute("core_num");

    player_data output = player_data(m_username,m_profile_hash);
    output.SetSid(m_sid);
    output.SetCoreNum(m_corenum);

    array<const XmlElement@> weapon_list = player_profile.getFirstElementByTagName("weapons").getElementsByTagName("weapon");
    for(uint i = 0; i < weapon_list.length();i++)
    {
        string weapon_key = weapon_list[i].getStringAttribute("key");
        if(weapon_key =="") continue;
        output.addWeapon(weapon_key);
    }

    return output;
}


class Save_System : Tracker {
    protected Metagame@ m_metagame;
    protected array<CraftQueue@> m_craftQueue;

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
		int senderId = event.getIntAttribute("player_id");
        if(checkCommand(message,"craft")){

            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);            
            if (playerInfo.m_name == default_string ) return;
            string profile_hash = playerInfo.m_hash;
            string sid = playerInfo.m_sid;
            int player_id = playerInfo.getPlayerPid();

            if(checkQueue(player_id,"craft_2nd"))
            {
                int queue_index = findQueueIndex(player_id,"craft_2nd");
                array<string> parameters = parseParameters(message, "craft");
                if(parameters.length() <= 1 || parameters.length() >=3)
                {
                    notify(m_metagame, "Doll query format error", dictionary(), "misc", player_id, false, "", 1.0);
                    return;
                }

                string girl_index = m_craftQueue[queue_index].m_string;
                string skin_index = parameters[0];
                string mode_index = parameters[1];
                string weapon_key = getKeyfromIndex(girl_index,skin_index,mode_index);


                player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));

                if(newdata.FindWeapon(weapon_key))
                {
                    const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
                    if (player is null) return;
                    int cId = player.getIntAttribute("character_id");
                    addItemInBackpack(m_metagame,cId,"weapon",weapon_key);
                    GiveRP(m_metagame,cId,-3000);
                    dictionary a;
                    a["%doll_name"] = getNamefromDict(weapon_key);
                    notify(m_metagame, "craft success", a, "misc", player_id, false, "", 1.0);
                    playPrivateSound(m_metagame,"sfx_big.wav",player_id);
                    m_craftQueue.removeAt(queue_index);
                }
                else if(!existKeyinDataSet(weapon_key))
                {
                    dictionary a;
                    a["%index"] = girl_index;
                    a["%skin_index"] = skin_index;
                    a["%mode"] = mode_index;
                    notify(m_metagame, "craft not found", a, "misc", player_id, false, "", 1.0);
                    m_craftQueue.removeAt(queue_index);
                }
                else
                {
                    dictionary a;
                    a["%name"] = getNamefromDict(weapon_key);
                    notify(m_metagame, "craft not exist", a, "misc", player_id, false, "", 1.0);
                    m_craftQueue.removeAt(queue_index);
                }
                return;
            }

            string girl_index = message.substr(message.findFirst(" ")+1);
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash)); 

            int girl_index_i = parseInt(girl_index);
            _log("图鉴里有" +newdata.getAllNum() +"个武器");
            _log("图鉴index是" + girl_index_i);

            array<girls_information@> doll_array = findGFLIndex(girl_index_i);
            if(doll_array.length() <= 0 ) 
            {
                notify(m_metagame, "Doll query failed", dictionary(), "misc", player_id, false, "", 1.0);
                return;
            }

            string notify_script;
            int count=0;

            for(uint i=0;i<doll_array.length();i++)
            {
                _log("正在检测" + doll_array[i].weapon_key);
                if(newdata.FindWeapon(doll_array[i].weapon_key))
                {
                    count++;
                    dictionary a;
                    a["%skin_index"] = "" +doll_array[i].skin_index;
                    a["%name"]= doll_array[i].name;
                    a["%mode"]= doll_array[i].mode;
                    // notify(m_metagame, "Logger Query Result", a, "misc", player_id, false, "", 1.0);
                    sendPrivateMessageKey(m_metagame, player_id, "Logger Query Result",a);
                }
            }

            if(count <= 0)
            {
                notify(m_metagame, "Logger Query nothing", dictionary(), "misc", player_id, false, "", 1.0);
                return;
            }

            startQueue(player_id,"craft_2nd",girl_index);
            notify(m_metagame, "craft progression start", dictionary(), "misc", player_id, false, "", 1.0);
        }        
        if(checkCommand(message,"random")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);            
            if (playerInfo.m_name == default_string ) return;
            string profile_hash = playerInfo.m_hash;
            string sid = playerInfo.m_sid;
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash)); 
            string weapon_key = newdata.getRandomWeapon();
            const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
            if (player is null) return;
            if (weapon_key == "") return;
            int cId = player.getIntAttribute("character_id");
            addItemInBackpack(m_metagame,cId,"weapon",weapon_key);
            GiveRP(m_metagame,cId,-1000);
            dictionary a;
            a["%doll_name"] = getNamefromDict(weapon_key);
            notify(m_metagame, "craft success", a, "misc", player_id, false, "", 1.0);
            playPrivateSound(m_metagame,"sfx_big.wav",player_id);
        }
        if(checkCommand(message,"info")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);            
            if (playerInfo.m_name == default_string ) return;
            string profile_hash = playerInfo.m_hash;
            string sid = playerInfo.m_sid;
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash)); 
            const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
            if (player is null) return;
            int cId = player.getIntAttribute("character_id");
            dictionary a;
            a["%doll_number"] = "" + newdata.getAllNum();
            a["%all_dollnum"] = "" + (tdoll_complex_index.getSize() -1);
            string collect = formatFloat( (newdata.getAllNum() / (tdoll_complex_index.getSize() -1)) , '',0,2);
            a["%doll_collect"] = "" + collect;
            notify(m_metagame, "Logger info query", a, "misc", player_id, false, "", 1.0);
        }



		if (!m_metagame.getAdminManager().isAdmin(p_name, senderId) && !m_metagame.getModeratorManager().isModerator(p_name, senderId)) {
			return;
		}
 
        if(checkCommand(message,"savetest")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.m_name == default_string ) return;
            string profile_hash = playerInfo.m_hash;
            string sid = playerInfo.m_sid;
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
            notify(m_metagame, "你有" + newdata.m_weapons.length() + "个武器", dictionary(), "misc", player_id, false, "", 1.0);
            for(uint i = 0; i < newdata.m_weapons.length();i++)
            {
                string weapon_key = newdata.m_weapons[i];
                notify(m_metagame, "比如" + weapon_key + "这把枪", dictionary(), "misc", player_id, false, "", 1.0);
            }
            newdata.addWeapon("gkw_negev.weapon");
            newdata.addWeapon("gkw_m4a1.weapon");
            newdata.addWeapon("gkw_ak47.weapon");
            newdata.addWeapon("gkw_m3.weapon");
            newdata.addWeapon("gkw_vz61.weapon");
            newdata.addWeapon("gkw_negev.weapon");
            newdata.SetCoreNum(newdata.m_corenum+= 1500);
            newdata.SetSid(sid);
            // newdata.m_profile_hash = "test114514";
            // string filename = ("save_" + "test114514" +".xml" );
            string filename = ("save_" + profile_hash +".xml" );
            writeXML(m_metagame,filename,PlayerProfileSave(newdata));
        }
        if(checkCommand(message,"gfl_load")){
            string girl_index = message.substr(message.findFirst(" ")+1);
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.m_name == default_string ) return;
            string profile_hash = playerInfo.m_hash;
            string sid = playerInfo.m_sid;
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));

            string weapon_key = getKeyfromIndex(girl_index);
            if(weapon_key=="") 
            {
                _log("未找到武器key");  
                return;
            }                

            if(newdata.FindWeapon(weapon_key))
            {
                const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
                if (player is null) return;
                int cId = player.getIntAttribute("character_id");
                addItemInBackpack(m_metagame,cId,"weapon",weapon_key);
                dictionary a;
                a["%doll_name"] = getResourceName(m_metagame, weapon_key, "weapon");                    
                sendPrivateMessageKey(m_metagame, player_id, "truemask_success",a);
                playPrivateSound(m_metagame,"sfx_big.wav",player_id);                   
            }
            else
            {
                _log("你没有这个武器：" + weapon_key);  
            }
        }        
	}

    void update(float time) {
        if(m_craftQueue.size()>0){
            for(uint a=0;a<m_craftQueue.size();a++){
                m_craftQueue[a].m_time-=time;
                if(m_craftQueue[a].m_time<0){
                    int pId=m_craftQueue[a].m_playerId;
                    notify(m_metagame,"Logger Timeout", dictionary(), "misc", pId, false, "", 1.0);
                    m_craftQueue.removeAt(a);
                }
            }
        }
    } 

    bool checkQueue(int pId,string type){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId && m_craftQueue[i].m_typekey==type){
                return true;
            }
        }
        return false;
    }

    int findQueueIndex(int pId,string type){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId && m_craftQueue[i].m_typekey==type){
                return int(i);
            }
        }
        return -1;
    }

    void startQueue(int playerId,string key,string index){
        m_craftQueue.insertLast(CraftQueue(playerId,key,index));
    }    
}