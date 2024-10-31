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
#include "GFLparameters.as"

// sid = sid
// 记录玩家武器数据 使用<weapon key="武器key">形式存储在<weapons>元素下
// 记录玩家通用数据
// 每次调用时 从xml文件中转储读取生成player_data
// 每次存储时 将player_data重新封装回新的xml中

class GFL_call_info
{
    string m_call_key;
    string m_call_ui_key;
    GFL_call_info(string call_ui_key)
    {
        m_call_ui_key = call_ui_key;
        m_call_key = call_ui_key.substr(8);
    }
}

class player_data
{
	int m_corenum=0;
    int m_dev_point;
    int m_dev_point_lifemax;
    string m_playername;
    string m_profile_hash;
    string m_sid;
    string m_call_slot_1;
    string m_call_slot_2;
    string m_call_slot_3;


    array<string> m_weapons={};
    array<GFL_call_info@> m_unlocked_call={
        GFL_call_info("call_ui_t1_bombardment_fairy_82mm_mortar_free"),
        GFL_call_info("call_ui_t1_bombardment_fairy_82mm_mortar"),
        GFL_call_info("call_ui_t1_bombardment_fairy_105mm_grenade_barrage"),
        GFL_call_info("call_ui_t2_bombardment_fairy_170mm_cannon"),
        GFL_call_info("call_ui_t2_airstrike_fairy_bomber"),
        GFL_call_info("call_ui_t1_airstrike_fairy_precise"),
        GFL_call_info("call_ui_t2_airstrike_fairy_precise"),
        GFL_call_info("call_ui_t3_airstrike_fairy_precise"),
        GFL_call_info("call_ui_t1_airstrike_fairy_cas"),
        GFL_call_info("call_ui_t1_airstrike_fairy_cas_p2p"),

        GFL_call_info("call_ui_t2_warrior_fairy_recon_heli"),
        GFL_call_info("call_ui_t2_warrior_fairy_vtol_sentry"),
        GFL_call_info("call_ui_t3_warrior_fairy_armed_heli"),

        GFL_call_info("call_ui_t3_rampage_fairy_gunship"),
        GFL_call_info("call_ui_t1_rocket_fairy_missile"),
        GFL_call_info("call_ui_t2_rocket_fairy_bm30"),
        GFL_call_info("call_ui_t3_rocket_fairy_aircraft"),
        GFL_call_info("call_ui_t3_rocket_fairy_cover"),

        GFL_call_info("call_ui_t1_bombardment_fairy_82mm_mortar_free_update_alpha"),
        GFL_call_info("call_ui_t1_bombardment_fairy_82mm_mortar_free_update_beta"),
        GFL_call_info("call_ui_t1_bombardment_fairy_82mm_mortar_free_update_gamma"),


        GFL_call_info("call_ui_t1_bombardment_fairy_155mm_air_burst")

    };

	player_data() {}

    player_data(const string _player_name, const string _profile_hash)
    {
        m_playername = _player_name;
        m_profile_hash = _profile_hash;
        m_call_slot_1 = "";
        m_call_slot_2 = "";
        m_call_slot_3 = "";
        m_dev_point = 0;
        m_dev_point_lifemax =0;
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

    //研发点相关

    //getter setter
    int getDevPoint() const
    {
        return m_dev_point;
    }

    int getDevPointLife() const
    {
        return m_dev_point_lifemax;
    }

    void setDevPoint(int num)
    {
        m_dev_point=num;
    }

    void setDevPointLife(int num)
    {
        m_dev_point_lifemax=num;
    }

    // 这里是实际应用接口
    void addDevPoint(int newPointNum)
    {
        m_dev_point += newPointNum;
        m_dev_point_lifemax+= newPointNum;
    }

    bool tryCostDevPoint(int num_devpoint_need)
    {
        if(m_dev_point < num_devpoint_need) return false;
        m_dev_point-= num_devpoint_need;
        return true;
    }


    //核心相关 废案暂时
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

    void formatWeaponList()
    {
        array<string> new_weapons = {};
        for (uint i = 0; i < m_weapons.length(); ++i)
        {
            if (existKeyinList(m_weapons[i]))
            {
                new_weapons.insertLast(m_weapons[i]);
            }
            else
            {
                _log("风险! 移除未注册武器"+ m_weapons[i] +" 玩家为"+ m_playername);
            }
        }
        m_weapons = new_weapons; 
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


    // deal with Call Slot and Unlock Call

    void setCallSlot(int slot,string callKey){
        switch(slot)
        {
            case 1:{m_call_slot_1=callKey;break;}
            case 2:{m_call_slot_2=callKey;break;}
            case 3:{m_call_slot_3=callKey;break;}
            default:{break;}
        }
    }

    string getCallSlot(int slot)
    {
        switch(slot)
        {
            case 1:{return m_call_slot_1;}
            case 2:{return m_call_slot_2;}
            case 3:{return m_call_slot_3;}
            default:{return "";}
        }
        return "";
    }

    bool FindCallUnlock(const string key)
    {
        for (uint i = 0; i < m_unlocked_call.length(); ++i)
        {
            if (m_unlocked_call[i].m_call_ui_key == key)
            {
                return true;
            }
        }
        return false;
    }

    void addUnlockedCall(GFL_call_info@ call)
    {
        bool isDuplicate = false;
        for (uint i = 0; i < m_unlocked_call.length(); ++i)
        {
            if (m_unlocked_call[i].m_call_ui_key == call.m_call_ui_key)
            {
                isDuplicate = true;
                break;
            }
        }        
        if (!isDuplicate)
        {
            m_unlocked_call.insertLast(call);
        }  
    }
    
    string getCallKey(const string key)
    {
        for (uint i = 0; i < m_unlocked_call.length(); ++i)
        {
            if (m_unlocked_call[i].m_call_ui_key == key)
            {
                return m_unlocked_call[i].m_call_key;
            }
        }
        return "";
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
    if(xml is null){
        writeXML(metagame,filename,XmlElement(filename));
        @xml = readXML(metagame,filename);
    }
	return xml;
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
    root.setIntAttribute("dev_point", player_info.m_dev_point);
    root.setIntAttribute("dev_point_lifemax", player_info.m_dev_point_lifemax);
	string FILENAME =  ("save_" + player_info.m_sid +".xml" );

    XmlElement subroot_0("weapons");
    for (uint i = 0; i < player_info.m_weapons.length(); i++) 
    {
        XmlElement e("weapon");
        e.setStringAttribute("key", player_info.m_weapons[i]);
        subroot_0.appendChild(e);
    }


    //处理当前的支援列表
    XmlElement subroot_1("active_call");
    XmlElement callslot_1("callslot_1");
    callslot_1.setStringAttribute("key", checkCallSlotInvaild(1,player_info.getCallSlot(1)));
    subroot_1.appendChild(callslot_1); 
    XmlElement callslot_2("callslot_2");
    callslot_2.setStringAttribute("key", checkCallSlotInvaild(2,player_info.getCallSlot(2)));
    subroot_1.appendChild(callslot_2);
    XmlElement callslot_3("callslot_3");
    callslot_3.setStringAttribute("key", checkCallSlotInvaild(3,player_info.getCallSlot(3))); 
    subroot_1.appendChild(callslot_3);       

    //处理解锁的支援列表
    XmlElement subroot_2("unlocked_calls");
    for (uint i = 0; i < player_info.m_unlocked_call.length(); i++) 
    {
        XmlElement e("unlocked_call");
        e.setStringAttribute("call_key", player_info.m_unlocked_call[i].m_call_ui_key);
        e.setStringAttribute("key", player_info.m_unlocked_call[i].m_call_key);
        subroot_2.appendChild(e);
    }

    root.appendChild(subroot_0);
    root.appendChild(subroot_1);
    root.appendChild(subroot_2);
    return root;
}

player_data@ PlayerProfileLoad(const XmlElement@ player_profile){
    string m_username = player_profile.getStringAttribute("username");
    string m_profile_hash = player_profile.getStringAttribute("profile_hash");
    string m_sid = player_profile.getStringAttribute("sid");
    int m_corenum = player_profile.getIntAttribute("core_num");
    int m_dev_point = player_profile.getIntAttribute("dev_point");
    int m_dev_point_lifemax = player_profile.getIntAttribute("dev_point_lifemax");

    player_data output = player_data(m_username,m_profile_hash);
    output.SetSid(m_sid);
    output.SetCoreNum(m_corenum);
    output.setDevPoint(m_dev_point);
    output.setDevPointLife(m_dev_point_lifemax);

    const XmlElement@ weapon_dump = player_profile.getFirstElementByTagName("weapons");
    if(weapon_dump !is null)
    {
        array<const XmlElement@> weapon_list = weapon_dump.getElementsByTagName("weapon");
        if(weapon_list !is null)
        {
            for(uint i = 0; i < weapon_list.length();i++)
            {
                string weapon_key = weapon_list[i].getStringAttribute("key");
                if(weapon_key =="") continue;
                output.addWeapon(weapon_key);
            }
            output.formatWeaponList();
        }
    }

    const XmlElement@ unlocked_call_dump = player_profile.getFirstElementByTagName("unlocked_calls");
    if(unlocked_call_dump !is null)
    {
        array<const XmlElement@> unlocked_call_list = unlocked_call_dump.getElementsByTagName("unlocked_call");
        if(unlocked_call_list !is null)
        {
            for(uint i = 0; i < unlocked_call_list.length();i++)
            {
                string call_ui_key = unlocked_call_list[i].getStringAttribute("call_key");
                if(call_ui_key =="") continue;
                GFL_call_info@ new_call_info = GFL_call_info(call_ui_key);
                output.addUnlockedCall(new_call_info);
            }
        }
    }

    string call_slot_callkey_1 = call_slot_default_1;
    string call_slot_callkey_2 = call_slot_default_2;
    string call_slot_callkey_3 = call_slot_default_3;
    
    const XmlElement@ active_call_dump = player_profile.getFirstElementByTagName("active_call");
    if(active_call_dump !is null)
    {
        const XmlElement@ call_slot_1 = active_call_dump.getFirstElementByTagName("callslot_1");
        const XmlElement@ call_slot_2 = active_call_dump.getFirstElementByTagName("callslot_2");
        const XmlElement@ call_slot_3 = active_call_dump.getFirstElementByTagName("callslot_3");

        if(call_slot_1 !is null) call_slot_callkey_1 = call_slot_1.getStringAttribute("key");
        if(call_slot_2 !is null) call_slot_callkey_2 = call_slot_2.getStringAttribute("key");
        if(call_slot_3 !is null) call_slot_callkey_3 = call_slot_3.getStringAttribute("key");
    }
    
    output.setCallSlot(1,call_slot_callkey_1);
    output.setCallSlot(2,call_slot_callkey_2);
    output.setCallSlot(3,call_slot_callkey_3);

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
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
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
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
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
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash)); 
            const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
            if (player is null) return;
            int cId = player.getIntAttribute("character_id");
            dictionary a;
            a["%doll_number"] = "" + newdata.getAllNum();
            a["%all_dollnum"] = "" + (tdoll_complex_index.getSize() -1);
            float collect_value = float(newdata.getAllNum()) / (tdoll_complex_index.getSize() -1) * 100;
            string collect = formatFloat(collect_value,"",0,2);
            a["%doll_collect"] = "" + collect;
            notify(m_metagame, "Logger info query", a, "misc", player_id, false, "", 1.0);
        }
        if(checkCommand(message,"balance")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash)); 
            const XmlElement@ player = getPlayerInfo(m_metagame,player_id);
            if (player is null) return;
            int cId = player.getIntAttribute("character_id");
            dictionary a;
            a["%dev_point"] = "" + newdata.getDevPoint();
            a["%dev_point_life"] = "" + newdata.getDevPointLife();
            string collect = formatFloat((newdata.getAllNum() / (tdoll_complex_index.getSize() -1)));
            a["%doll_collect"] = "" + collect;
            notify(m_metagame, "Logger info query", a, "misc", player_id, false, "", 1.0);
        }


		if (!m_metagame.getAdminManager().isAdmin(p_name, senderId) && !m_metagame.getModeratorManager().isModerator(p_name, senderId)) {
			return;
		}
 
        if(checkCommand(message,"savetest")){
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
            int player_id = playerInfo.getPlayerPid();
            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
            newdata.addDevPoint(1000);
            string filename = ("save_" + profile_hash +".xml" );
            writeXML(m_metagame,filename,PlayerProfileSave(newdata));
        }
        if(checkCommand(message,"gfl_load")){
            string girl_index = message.substr(message.findFirst(" ")+1);
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(p_name);
            if (playerInfo.getPlayerName() == default_string ) return;
            string profile_hash = playerInfo.getHash();
            string sid = playerInfo.getSid();
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
        if(m_craftQueue.size() > 0) {
            for(int a = m_craftQueue.size() - 1; a >= 0; a--) {
                m_craftQueue[a].m_time -= time;
                if(m_craftQueue[a].m_time < 0) {
                    int pId = m_craftQueue[a].m_playerId;
                    notify(m_metagame, "Logger Timeout", dictionary(), "misc", pId, false, "", 1.0);
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