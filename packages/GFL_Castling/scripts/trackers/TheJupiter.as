#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"

class jupiter: Tracker {
	protected Metagame@ m_metagame;
	protected float reload_cycle;
	protected float reload_time=15.0;
	protected bool m_started;
	protected int m_numLeft=0;
	protected int m_faction=1;
	protected int m_striketime=12;
	protected float m_delaytime=0;
	protected bool m_strike=false;
	protected Vector3 m_pos;

	jupiter(Metagame@ metagame,float cycle=60.0) {
		@m_metagame = @metagame;
		reload_cycle =cycle;
    }

	void jupiterfireReady() {
		array<const XmlElement@> players = getPlayers(m_metagame);
        if(players is null) return;
		int luckyguyId = rand(1,players.length)-1;
		const XmlElement@ playerinfo = getPlayerInfo(m_metagame, luckyguyId);
        if (playerinfo is null) return;
		int characterId = playerinfo.getIntAttribute("character_id");
		const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
		Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,10,0)),c_pos,"jupiter_airstrike_warning.projectile",-1,m_faction,120,100);
		m_delaytime=8.0;
		m_strike=true;
		m_pos=c_pos;
	}

	void jupiterfire(Vector3 pos){
		for(int i=0;i<m_striketime;i++){
			int offsetX = rand(1,9)-5;
			int offsetZ = rand(1,9)-5;
			Vector3 pos_a= pos.add(Vector3(offsetX,0,offsetZ));
			CreateProjectile(m_metagame,pos_a.add(Vector3(0,rand(1,20)+60,0)),pos_a,"artillery_jupiter_420.projectile",-1,m_faction,120,10);
		}
	}

	void start(){
		_log("Jupiter_Initialized: "+m_numLeft);
	}

    void update(float time) {
		if(m_started==false) return;
		reload_time -= time;
		if (reload_time < 0){
			jupiterfireReady();
			_log("Jupiter_Fired:"+ m_numLeft);
			m_numLeft++;
			reload_time = reload_cycle;			
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
		return true;
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