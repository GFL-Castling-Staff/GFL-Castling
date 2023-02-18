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
	protected Metagame@ m_metagame;
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

	jupiter(Metagame@ metagame,float cycle=60.0) {
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
		int vehicleid;
		int jud_fire = 1;

		while(jud_fire!=0)
		{
			vehicleid = getAmosPosition(m_metagame,0,c_pos,jud_amos);
			if(vehicleid!=-1) {
				c_pos = c_pos.add(Vector3(jud_amos*sin(rand(0,20)/20*6.28),0,jud_amos*cos(rand(0,20)/20*6.28)));
			}
			else	jud_fire = 0;
		}

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

	void jupiterfire(Vector3 pos){
		int offsetY=0;
		for(int i=0;i<m_striketime;i++){
			int offsetX = rand(0,2*radd-8)-radd+4;
			int offsetZ = rand(0,2*radd-8)-radd+4;
			Vector3 pos_a= pos.add(Vector3(offsetX,0,offsetZ));
			CreateProjectile(m_metagame,pos_a.add(Vector3(0,60+offsetY,0)),pos_a,"artillery_jupiter_420.projectile",-1,m_faction,120,10);
			offsetY+=60;
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
		if(m_strike){
			m_delaytime-=time;
			if(m_delaytime<0){
				jupiterfire(m_pos);
				m_strike=false;
			}
		}
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