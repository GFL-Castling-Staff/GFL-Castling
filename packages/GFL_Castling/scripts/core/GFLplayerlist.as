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
    GFL_battleInfo@ m_battleinfo; //战斗信息
    array<kill_count@> m_killInfo; //技能的击杀信息
	string m_hash;
	string m_sid;
    float m_xp_reward = 0; // xp奖励
    int m_rp_reward = 0; // rp奖励
    rgba_color@ m_color;
    bool m_available; //用途判定是否掉线，是否该info无效，在函数应用部分判断作错误处理
    int m_inactive_time = 0;
    
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
        @m_battleinfo = GFL_battleInfo(name);
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
    void setBattleInfo(GFL_battleInfo@ info){
        @m_battleinfo = @info;
    }    
    GFL_equipment@ getPlayerEquipment(){
        return m_equipment;
    }
    GFL_battleInfo@ getBattleInfo(){
        return @m_battleinfo;
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
    void ForceEnable()
    {
        m_available = true;
    }    
    void Inactive_Retry()
    {
        m_inactive_time++;
    }
    int getInactiveStatus()
    {
        return m_inactive_time;
    }
    int getKillSkillCount(string skill_name)
    {
        for (uint i=0;i<m_killInfo.length();i++){
            if (m_killInfo[i].m_kill_count_type==skill_name) {
                return m_killInfo[i].m_killnum;
            }
        }
        return 0;
    }
    void addKillSkillCount(string skill_name)
    {
        bool exist = false;
        for (uint i=0;i<m_killInfo.length();i++){
            if (m_killInfo[i].m_kill_count_type==skill_name) {
                m_killInfo[i].add();
                exist = true;
            }
        }
        if(!exist)
        {
            m_killInfo.insertLast(kill_count(1,skill_name));
        }
    }
    void addKillSkillCount(string skill_name,int num)
    {
        bool exist = false;
        for (uint i=0;i<m_killInfo.length();i++){
            if (m_killInfo[i].m_kill_count_type==skill_name) {
                m_killInfo[i].add(num);
                exist = true;
            }
        }
        if(!exist)
        {
            m_killInfo.insertLast(kill_count(num,skill_name));            
        }
    }
    void cleanKillSkillInfo()
    {
        m_killInfo.resize(0);
    }

    void addKill(int num)
    {
        m_battleinfo.addKill(num);
        // _log("断点，执行battlelog添加击杀");
    }

    void addDead()
    {
        m_battleinfo.addDead();
    }    

    void addTacticPoint(int num)
    {
        m_battleinfo.addTacticPoint(num);
    }
}

class GFL_playerInfo_Buck
{
	array<GFL_playerInfo@> m_playerInfo;

	GFL_playerInfo_Buck(){
		clearAll();
	}    

	uint size(){return m_playerInfo.size();}

    void addNewInfo(GFL_playerInfo@ newinfo)
    {
        bool exist = false;
        string name = newinfo.getPlayerName();
        for(uint i=0; i<size();++i){
			if(name == m_playerInfo[i].getPlayerName()){
                exist = true;
				@m_playerInfo[i] = newinfo;
			}
		
        }
        if(!exist)
        {
            m_playerInfo.insertLast(newinfo);
        }
    }

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

    array<GFL_playerInfo@> getAllPlayerInfoArray()
    {
        return m_playerInfo;
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

    void addKillbyName(string name,int num)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                m_playerInfo[i].addKill(num);
            }
        }
    }

    void addKillbyPid(int pid,int num)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                m_playerInfo[i].addKill(num);
            }
        }
    }

    void addDeadbyName(string name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                m_playerInfo[i].addDead();
                m_playerInfo[i].cleanKillSkillInfo();
            }
        }
    }    

    int getKillSkillCountbyName(string name,string skill_name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                return m_playerInfo[i].getKillSkillCount(skill_name);
            }
        }
        return 0;
    }

    void addKillSkillCountbyName(string name,string skill_name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                m_playerInfo[i].addKillSkillCount(skill_name);
            }
        }
    }

    void addKillSkillCountbyName(string name,string skill_name,int num)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerName() == name){
                m_playerInfo[i].addKillSkillCount(skill_name,num);
            }
        }        
    }

    int getKillSkillCountbyPid(int pid,string skill_name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                return m_playerInfo[i].getKillSkillCount(skill_name);
            }
        }
        return 0;
    }

    void addKillSkillCountbyPid(int pid,string skill_name)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                m_playerInfo[i].addKillSkillCount(skill_name);
            }
        }
    }

    void addKillSkillCountbyPid(int pid,string skill_name,int num)
    {
        for(uint i=0;i<size();++i){
            if(m_playerInfo[i].getPlayerPid() == pid){
                m_playerInfo[i].addKillSkillCount(skill_name,num);
            }
        }
    }

    void addTacticPointToAll(int num)
    {
        for(uint i=0;i<size();++i){
            m_playerInfo[i].addTacticPoint(num);
        }
    }
}

class GFL_battleInfo{
    protected string m_name;
	protected uint m_killCount; //击杀数
	protected uint m_oneLifekillCount; //最高连杀
	protected uint m_counter; //当前连杀
	protected uint m_deadCount; //死亡数
    protected uint m_playingTime; // 游玩分钟
    protected uint m_tactic_point; // 战术点
    protected uint m_killstreak_point; // 连杀积分
    protected uint m_killstreak_point_counter; //连杀积分计数
    protected array<uint> m_kill_streak_gived_phase={}; //连杀积分阶段获取
    protected uint m_dev_point_convert; //待转换为研发点的战术点

    GFL_battleInfo(string name) {
        m_name = name;
        m_killCount = 0;
        m_oneLifekillCount = 0;
        m_counter = 0;
        m_deadCount = 0;
        m_playingTime = 0;
        m_tactic_point = 0;
        m_dev_point_convert=0;
        m_killstreak_point = 0;
    }

    string getName() const {
        return m_name;
    }

    uint getKillCount() const {
        return m_killCount;
    }

    uint getOneLifeKillCount() const {
        return m_oneLifekillCount;
    }

    uint getCounter() const {
        return m_counter;
    }

    uint getDeadCount() const {
        return m_deadCount;
    }

    uint getPlayingTime() const {
        return m_playingTime;
    }

    uint getTacticPoint() const {
        return m_tactic_point;
    }

    uint getKillStreakPoint() const {
        return m_killstreak_point;
    }

    uint getKillStreakPointCounter() const {
        return m_killstreak_point_counter;
    }

    void setName(string name) {
        m_name = name;
    }

    void setKillCount(uint killCount) {
        m_killCount = killCount;
    }

    void setOneLifeKillCount(uint oneLifeKillCount) {
        m_oneLifekillCount = oneLifeKillCount;
    }

    void setCounter(uint counter) {
        m_counter = counter;
    }

    void setDeadCount(uint deadCount) {
        m_deadCount = deadCount;
    }

    void setPlayingTime(uint playingTime) {
        m_playingTime = playingTime;
    }    

    void setTacticPoint(uint point) {
        m_tactic_point = point;
    }

    void addTacticPoint(uint point) {
        m_tactic_point += point;
        m_dev_point_convert +=point;
    }

    int getDevPoint()
    {
        int m_num = m_dev_point_convert;
        m_dev_point_convert = 0;
        return m_num;
    }

    void setKillStreakPointCounter(uint point) {
        m_killstreak_point_counter = point;
    }

    bool checkKillStreakIndexUsed(int index)
    {
        return m_kill_streak_gived_phase.find(index)>=0;
    }

    void addKillStreakIndex(int index)
    {
        m_kill_streak_gived_phase.insertLast(index);
    }

    void tickMinute()
    {
        m_playingTime++;
    }

	void addKill(int killstreak_add=1){
        m_killCount++;
        m_counter++;
        m_killstreak_point+=killstreak_add;
        m_killstreak_point_counter+=killstreak_add;
        if(m_counter > m_oneLifekillCount){
            m_oneLifekillCount = m_counter;
        }
        // _log("断点，执行battlelog内部添加击杀");
        // _log("断点，当前m_killstreak_point为"+m_killstreak_point);
        // _log("断点，当前m_killstreak_point_counter为"+m_killstreak_point_counter);        
	}

	void addDead(){
        m_deadCount++;
        m_counter = 0;
        m_killstreak_point =0;
        m_killstreak_point_counter=0;
        m_kill_streak_gived_phase.resize(0);
	}
}

GFL_playerInfo@ default_playerInfo = GFL_playerInfo(default_string,default_int,default_int,default_int,default_string,default_string,default_equipment,rgba_color());

class GFL_playerlist_system : Tracker {
	protected Metagame@ m_metagame;
    protected float m_time = 1.0; 
    protected float m_refresh_time = 10.0; // 刷新时间
    protected float m_event_timer = 1.0; 
    protected float m_event_time = 5.0; // 事件刷新时间
    protected float m_minute_timer = 1.0; 
    protected float m_minute_time = 60.0; // 事件刷新时间    
    protected int m_maxplayer_overload;
	// --------------------------------------------
	GFL_playerlist_system(Metagame@ metagame,const UserSettings@ m_userSettings) {
		@m_metagame = @metagame;
        @g_playerInfo_Buck = GFL_playerInfo_Buck();
        m_maxplayer_overload=m_userSettings.m_server_overload_num;
	}

    // 更新
    void update(float time) {
        m_time -= time;
        m_event_timer-= time;
        m_minute_timer-= time;
        if(m_time <= 0.0)
        {
            m_time = m_refresh_time;
            array<const XmlElement@> m_players = getPlayers(m_metagame);
            if(m_players is null){return;}
            for (uint j = 0; j < m_players.size(); ++j) {
                const XmlElement@ player = m_players[j];
                if(player is null){continue;}
                updatePlayerInfo(player);
            }
            for (uint i = 0; i < g_playerInfo_Buck.size();++i)
            {
                if(g_playerInfo_Buck.m_playerInfo[i].check_Available() == false)
                {
                    g_playerInfo_Buck.m_playerInfo[i].Inactive_Retry();
                    //在处理完所有新增的players后，把30次标记为不可用的info删除
                    if(g_playerInfo_Buck.m_playerInfo[i].getInactiveStatus() >= 30)
                    {
                        g_playerInfo_Buck.removeByIndex(i);
                        --i;
                    }
                }
            }
        }
        if(m_event_timer<=0.0)
        {   
            m_event_timer = m_event_time;
            for (uint j = 0; j < g_playerInfo_Buck.size(); ++j) {
                GFL_playerInfo@ player = g_playerInfo_Buck.m_playerInfo[j];
                if(player is null){continue;}
                if(player.check_Available() != true){continue;}
                //如果处于不活跃状态，直接跳过event的处理；
                manageEventOfRefresh(player);
            }
        }
        if(m_minute_timer<=0.0)
        {
            m_minute_timer = m_minute_time;
            for (uint j = 0; j < g_playerInfo_Buck.size(); ++j) {
                GFL_playerInfo@ player = g_playerInfo_Buck.m_playerInfo[j];
                if(player is null){continue;}
                if(player.check_Available() != true){continue;}
                //如果处于不活跃状态，直接跳过event的处理；
                g_playerInfo_Buck.m_playerInfo[j].m_battleinfo.tickMinute();
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
        string _armor = equipment.getWeapon(3);
        if(startsWith(_armor,"srexo_t6"))
        {
            string _weapon = equipment.getWeapon(0);
            if( _weapon=="gkw_kp31mod3.weapon"
            ||  _weapon=="gkw_kp31mod3_1103.weapon"            
            ||  _weapon=="gkw_kp31mod3_310.weapon"
            ||  _weapon=="gkw_kp31mod3_3101.weapon")
            {
                healCharacter(m_metagame,cid,3);
            }
            else
            {
                healCharacter(m_metagame,cid,2);
            }
        }
        info.handleRpReward(m_metagame);
        info.handleXpReward(m_metagame);
    }

    void refresh_overload()
    {
		array<const XmlElement@> players = getPlayers(m_metagame);
		int currentplayers = players.length;
        if(currentplayers > m_maxplayer_overload)
        {
            //开启慢速模式
            m_refresh_time = 10.0;
        }
        else
        {
            m_refresh_time = 5.0;
        }
    }

    protected void handleMatchEndEvent(const XmlElement@ event){
		const XmlElement@ winCondition = event.getFirstElementByTagName("win_condition");
		if (winCondition is null) return;
        int factionId = winCondition.getIntAttribute("faction_id");
        if (factionId == 0) 
        {
            if(g_playerInfo_Buck.size() <= 0) return;
            for (uint i = g_playerInfo_Buck.size(); i-- > 0; ) {
                GFL_playerInfo@ playerInfo = g_playerInfo_Buck.m_playerInfo[i];
                GFL_battleInfo@ battleInfo = playerInfo.getBattleInfo();
                string p_name = playerInfo.getPlayerName();
                string profile_hash = playerInfo.getHash();
                string sid = playerInfo.getSid();
                int player_id = playerInfo.getPlayerPid();


                //结束时的战术点转换为研发点
                int m_dev_point_add = battleInfo.getDevPoint();
                int m_dev_point_complete = 20; //通关奖励研发点
                m_dev_point_add = min(250,m_dev_point_add);
                m_dev_point_add += m_dev_point_complete;

                player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
                newdata.addDevPoint(m_dev_point_add);
                string filename = ("save_" + profile_hash +".xml" );
                writeXML(m_metagame,filename,PlayerProfileSave(newdata));

                int _current_dev_point = newdata.getDevPoint();
                dictionary a;
                a["%num"] = ""+m_dev_point_add;   
                a["%current_num"] = ""+_current_dev_point;
                notify(m_metagame, "complete reward, dev point", a, "misc", player_id, false, "", 1.0);        

                string c_weaponType = playerInfo.getPlayerEquipment().getWeapon(0);
                if(
                    c_weaponType == "gkw_98kmod3.weapon" ||
                    c_weaponType == "gkw_98kmod3_skill.weapon" ||
                    c_weaponType == "gkw_98kmod3_4301.weapon" ||
                    c_weaponType == "gkw_98kmod3_4301_skill.weapon" ||
                    c_weaponType == "gkw_98kmod3_8301.weapon" ||
                    c_weaponType == "gkw_98kmod3_8301_skill.weapon" ||    
                    c_weaponType == "gkw_98kmod3_10001.weapon" ||
                    c_weaponType == "gkw_98kmod3_10001_skill.weapon"                                   
                    )
                {
                    int strid = g_playerInfo_Buck.m_playerInfo[i].getPlayerPid();
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
                        No_Delete_DataArray.insertLast(no_delete_data(strname,strid,1,"kar98k"));       
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
                    int strid = g_playerInfo_Buck.m_playerInfo[i].getPlayerPid();
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
                        No_Delete_DataArray.insertLast(no_delete_data(strname,strid,1,"ppsh41"));       
                        const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                        if (characterInfo is null) return;
                        string c_pos = characterInfo.getStringAttribute("position");
                        spawnStaticProjectile(m_metagame,"particle_effect_ppsh41_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
                    } 
                }                    
                else if(
                    c_weaponType == "gkw_sten.weapon" ||
                    c_weaponType == "gkw_stenmod3.weapon" ||
                    c_weaponType == "gkw_sterling.weapon")
                {
                    int strid = g_playerInfo_Buck.m_playerInfo[i].getPlayerPid();
                    string strname= g_playerInfo_Buck.m_playerInfo[i].getPlayerName();
                    int j = findNodeleteDataIndex(strname,"StenSterling");

                    if(j>=0){
                        const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                        if (characterInfo is null) return;
                        string c_pos = characterInfo.getStringAttribute("position");
                        spawnStaticProjectile(m_metagame,"particle_effect_stensterling_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
                        if(No_Delete_DataArray[j].m_num<4)No_Delete_DataArray[j].add();
                    }
                    else{
                        No_Delete_DataArray.insertLast(no_delete_data(strname,strid,1,"StenSterling"));       
                        const XmlElement@ characterInfo = getCharacterInfo(m_metagame, g_playerInfo_Buck.m_playerInfo[i].getPlayerCid());
                        if (characterInfo is null) return;
                        string c_pos = characterInfo.getStringAttribute("position");
                        spawnStaticProjectile(m_metagame,"particle_effect_stensterling_medal.projectile",c_pos,g_playerInfo_Buck.m_playerInfo[i].getPlayerCid(),characterInfo.getIntAttribute("faction_id"));
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

    protected void handlePlayerConnectEvent(const XmlElement@ event) {
        refresh_overload();
    }

    protected void handleVehicleSpotEvent(const XmlElement@ event) {
        int characterId = event.getIntAttribute("character_id");
        if (characterId == -1) return;
        int factionId = event.getIntAttribute("faction_id");
        if (factionId != 0) return;
        int ownerId = event.getIntAttribute("owner_id");
        if (ownerId == 0) return;
        string vehicle_key = event.getStringAttribute("vehicle_key");
        int reward_point = int(tactic_point_vehicle_spot_reward[vehicle_key]);
        if(reward_point <= 0) return;
        const XmlElement@ characterInfo = getCharacterInfo(m_metagame,characterId);
        if(characterInfo is null) return;

        int playerId = characterInfo.getIntAttribute("player_id");
        const XmlElement@ _playerInfo = getPlayerInfo(m_metagame,playerId);
        if(_playerInfo is null) return;
        string _player_name = getPlayerInfoName(_playerInfo);

        GFL_playerInfo@ playerInfo = getPlayerInfoFromList(_player_name);
        GFL_battleInfo@ battleInfo = playerInfo.getBattleInfo();
        battleInfo.addTacticPoint(reward_point);
        int m_tactic_point = battleInfo.getTacticPoint();
        dictionary a;
        a["%num"] = ""+reward_point;   
        a["%current_num"] = ""+m_tactic_point;         
        notify(m_metagame, "spot reward,hint", a, "misc", playerId, false, "", 1.0);
    }

    protected void handleVehicleDestroyEvent(const XmlElement@ event) {
        int characterId = event.getIntAttribute("character_id");
        if (characterId == -1) return;
        int factionId = event.getIntAttribute("faction_id");
        if (factionId != 0) return;
        int ownerId = event.getIntAttribute("owner_id");
        if (ownerId == 0) return;
        string vehicle_key = event.getStringAttribute("vehicle_key");
        int vehicleId = event.getIntAttribute("vehicle_id");
        const XmlElement@ vehicle = getVehicleInfo(m_metagame,vehicleId);
        if(vehicle is null) return;
        string vehicle_name = vehicle.getStringAttribute("name");
        int holder_id = vehicle.getIntAttribute("owner_id");
        if(holder_id == 0) return;

        const XmlElement@ characterInfo = getCharacterInfo(m_metagame,characterId);
        if(characterInfo is null) return;
        int playerId = characterInfo.getIntAttribute("player_id");

        const XmlElement@ _playerInfo = getPlayerInfo(m_metagame,playerId);
        if(_playerInfo is null) return;
        string _player_name = getPlayerInfoName(_playerInfo);

        int reward_point = int(tactic_point_vehicle_destroy_reward[vehicle_key]);
        if(reward_point > 0)
        {
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(_player_name);
            if (playerInfo.getPlayerName() == default_string) return;
            string player_name = playerInfo.getPlayerName();
            dictionary a;
            a["%vehicle"] = ""+vehicle_name;
            a["%num"] = ""+reward_point;   
            a["%player_name"] = ""+player_name;
            g_playerInfo_Buck.addTacticPointToAll(reward_point);
            sendFactionMessageKey(m_metagame,0,"vehicle destroy reward for all",a,0.9);
        }

        //处理击杀者奖励

        int reward_point_1 = int(tactic_point_vehicle_destroy_personal_reward[vehicle_key]);
        if(reward_point_1 > 0)
        {
            GFL_playerInfo@ playerInfo = getPlayerInfoFromList(_player_name);
            if (playerInfo.getPlayerName() == default_string) return;
            GFL_battleInfo@ battleInfo = playerInfo.getBattleInfo();
            battleInfo.addTacticPoint(reward_point_1);
            int m_tactic_point = battleInfo.getTacticPoint();

            dictionary a;
            a["%vehicle"] = ""+vehicle_name;
            a["%num"] = ""+reward_point_1;   
            a["%current_num"] = ""+m_tactic_point;
            notify(m_metagame, "vehicle destroy reward for personal", a, "misc", playerId, false, "", 1.0);
        }
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
            if(g_playerInfo_Buck.m_playerInfo[index].check_Available() != true) //如果发现玩家连回来了
            {
                g_playerInfo_Buck.m_playerInfo[index].ForceEnable();
            }
            g_playerInfo_Buck.update(player_username,player_playerid,player_characterid,player_factionid,player_profile_hash,player_sid,player_equipment,player_color);
        }
        else{
            g_playerInfo_Buck.addNewInfo(player_username,player_playerid,player_characterid,player_factionid,player_profile_hash,player_sid,player_equipment,player_color);
        }
    }

	void onRemove() {
		g_playerInfo_Buck.clearAll();
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

array<int> getPlayerPidByWeaponKeys(array<string> weapon_keys,int slot){
    array<int> result = {};
    array<GFL_playerInfo@> all_playerinfo = g_playerInfo_Buck.getAllPlayerInfoArray();
    for(uint i=0;i<all_playerinfo.size();i++)
    {
        string equipment = all_playerinfo[i].getPlayerEquipment().getWeapon(slot);
        if (equipment == default_string) continue;
        if (weapon_keys.find(equipment) > -1) result.insertLast(all_playerinfo[i].getPlayerPid());
    }
    return result;    
}

array<int> getPlayerCidByWeaponKeys(array<string> weapon_keys,int slot){
    array<int> result = {};
    array<GFL_playerInfo@> all_playerinfo = g_playerInfo_Buck.getAllPlayerInfoArray();
    for(uint i=0;i<all_playerinfo.size();i++)
    {
        string equipment = all_playerinfo[i].getPlayerEquipment().getWeapon(slot);
        if (equipment == default_string) continue;
        if (weapon_keys.find(equipment) > -1) result.insertLast(all_playerinfo[i].getPlayerCid());
    }
    return result;    
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

void handleKillEventToPlayerInfo(string name,int num)
{
    g_playerInfo_Buck.addKillbyName(name,num);
}

void handleKillEventToPlayerInfo(int id,int num)
{
    g_playerInfo_Buck.addKillbyPid(id,num);
}

void handleDeadEventToPlayerInfo(string name)
{
    g_playerInfo_Buck.addDeadbyName(name);
}

// 查询使用指定武器的玩家数量，排除特定玩家
int checkAllPlayerWeaponUsage(array<string>@ weaponKeys, int excludePlayerId=-1, string mode="playernotinvolved") {
    int count = 0;
    for (uint i = 0; i < g_playerInfo_Buck.size(); ++i) {
        GFL_playerInfo@ player = g_playerInfo_Buck.m_playerInfo[i];
        if (player is null) continue;

        // 跳过特定玩家
        if (mode=="playernotinvolved" && player.getPlayerPid() == excludePlayerId) continue;

        GFL_equipment@ equipment = player.getPlayerEquipment();
        if (equipment is null) continue;

        // 遍历输入的武器键数组，检查每个武器槽
        for (uint j = 0; j < weaponKeys.length(); ++j) {
            if (equipment.m_weapon1key == weaponKeys[j] ||
                equipment.m_weapon2key == weaponKeys[j] ||
                equipment.m_grenadekey == weaponKeys[j]) {
                count++;
                break; // 找到匹配的武器后，停止检查其它武器
            }
        }
    }
    return count;
}
