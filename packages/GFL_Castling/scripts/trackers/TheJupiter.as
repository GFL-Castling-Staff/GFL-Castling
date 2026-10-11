#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
//Author: NetherCrow
//Author: Saiwa

class jupiter: Tracker {
	protected GameMode@ m_metagame;
	protected float reload_cycle;
	protected float reload_time=60.0;
	protected bool m_started=false;
	protected bool tracker_started;
	protected int m_numLeft=0;
	protected int m_faction=1;
	protected int m_striketime=3; //木星炮弹头数量
	protected float m_delaytime=0;
	protected bool m_strike=false;
	protected Vector3 m_pos;
	protected int radd = 12; //木星炮随机半径
	protected int currentplayers = 1;//目前在线玩家数量
	protected int awaitingstrikes = 1;//同时射击的木星炮数

	jupiter(GameMode@ metagame,float cycle=60.0) {
		@m_metagame = @metagame;
		reload_cycle =cycle;
    }

	float getJupiterReloadTime(int currentplayers){
		if(currentplayers<=1)return 75.0;
		else if(currentplayers<=2)return 45.0;
		else if(currentplayers<=3)return 36.0;
		else if(currentplayers<=5)return 30.0;
		else if(currentplayers<=20)return 25.0;
		else return 20.0;
	}

	int getJupiterStrikeNum(int currentplayers){
		if(currentplayers<=10)return 1;
		else if(currentplayers<=25)return 2;
		else return 3;
	}

	void jupiterfireReady() {
		array<const XmlElement@> players = getPlayers(m_metagame);
		currentplayers = players.length;
        if(players is null || currentplayers<=0) return;
		int luckyguyId = rand(0,players.length-1);
		const XmlElement@ playerinfo = getPlayerInfo(m_metagame, luckyguyId);
        if (playerinfo is null) return;
		int characterId = playerinfo.getIntAttribute("character_id");
		const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
		Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
		
		//艾莫号等一众vip载具特别保护措施
		float jud_amos = 48.0;
		int jud_fire = 1;
		int jud_loop = 0;

		//循环外只查询一次各阵营载具列表
		array<array<const XmlElement@>@> factionVehicles;
		for(int f=0; f<int(m_metagame.getFactionCount()); f++){
			factionVehicles.insertLast(getAllVehicles(m_metagame, f));
		}
		Vector3 jud_start = c_pos;

		while(jud_fire!=0 && jud_loop<5)
		{
			jud_loop++;
			jud_fire = 0;
			for(uint i=0;i<factionVehicles.length();i++){
				if(hasVipVehicleNear(m_metagame, factionVehicles[i], c_pos, jud_amos)!=-1){
					jud_fire = 1;
					break;
				}
			}
			if(jud_fire!=0) {
				float jud_rad = rand(0, 628) * 0.01;
				c_pos = c_pos.add(Vector3(jud_amos*sin(jud_rad),0,jud_amos*cos(jud_rad)));
			}
		}
		_log("Jupiter_Avoid_Offset: loops=" + jud_loop + " from=" + jud_start.toString() + " to=" + c_pos.toString());

		// int circle = 8;	//警示烟雾数量

		// for(int i=0;i<circle;i++){
		// 	CreateProjectile(m_metagame,c_pos.add(Vector3(radd*sin(i*3.14/circle*2),6,radd*cos(i*3.14/circle*2))),c_pos.add(Vector3(radd*sin(i*3.14/circle*2),0,radd*cos(i*3.14/circle*2))),"jupiter_airstrike_warning_s.projectile",-1,m_faction,120,100);
		// }

		spawnStaticProjectile(m_metagame,"jupiter_airstrike_warning.projectile",c_pos,-1,m_faction);
		playSoundAtLocation(m_metagame,"Jupiter_warning_form_aigei_com.wav",0,c_pos,1.0);
		m_delaytime=7.0;
		m_strike=true;
		m_pos=c_pos;
	}

	void jupiterfire(Vector3 pos,float delaytime){
		int offsetY=0;
		for(int i=0;i<m_striketime;i++){
			int offsetX = rand(0,2*radd-8)-radd+4;
			int offsetZ = rand(0,2*radd-8)-radd+4;
			Vector3 pos_a= pos.add(Vector3(offsetX,0,offsetZ));
			float delayheight = delaytime*60;
			CreateProjectile(m_metagame,pos_a.add(Vector3(0,60+offsetY+delayheight,0)),pos_a,"artillery_jupiter_420.projectile",-1,m_faction,60,0);
			offsetY+=30;
		}
	}

	void start(){
		_log("Jupiter_Initialized: "+m_numLeft);
		reload_time=15.0;
		tracker_started=true;
	}

    void update(float time) {
		if(m_started==false) return;
		reload_time -= time;
		if (reload_time < 0){
			jupiterfireReady();
			if(m_strike){
				jupiterfire(m_pos,m_delaytime);
				m_strike=false;
			}
			_log("Jupiter_Fired:"+ m_numLeft);
			m_numLeft++;
			if(m_numLeft<awaitingstrikes){
				reload_time = -1;	
			}
			else{
				awaitingstrikes = getJupiterStrikeNum(currentplayers);
				reload_time = getJupiterReloadTime(currentplayers);		
				m_numLeft = 0;		
			}
		}
		// if(m_strike){
		// 	m_delaytime-=time;
		// 	if(m_delaytime<0){
		// 		jupiterfire(m_pos);
		// 		m_strike=false;
		// 	}
		// }
	}

	void end() {
	}

	bool hasEnded() const {
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return tracker_started;
	}

	void gameContinuePreStart() {
		tracker_started = true;
	}

	// --------------------------------------------
	void onRemove() {
		tracker_started = false;
	}

	protected void handleMatchEndEvent(const XmlElement@ event) {
        m_started= false;
    }

	protected void handleVehicleSpawnEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == "sf_jupiter.vehicle") {
			m_started=true;
			_log("Jupiter_Activated");
			m_faction=event.getIntAttribute("owner_id");
		}
	}
	protected void handleVehicleDestroyEvent(const XmlElement@ event) {
		string key = event.getStringAttribute("vehicle_key");
		if (key == "sf_jupiter.vehicle") {
			m_started=false;
			_log("Jupiter_Deactivated");
		}
	}
}