#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"

class juptier: Tracker {
	protected Metagame@ m_metagame;
	protected float reload_cycle;
	protected float reload_time;
    protected int activation;
    protected int m_numLeft;
	protected bool m_started;


	juptier(Metagame@ metagame) {
		@m_metagame = @metagame;
		reload_cycle = 10.0;
		reload_time = 10.0;
		m_started = false;
		m_numLeft = 0;	
    }

	void jupiterfire() {
		array<const XmlElement@> players = getPlayers(m_metagame);
        if(players is null) return;
		int luckyguyId = rand(1,players.length)-1;
		const XmlElement@ playerinfo = getPlayerInfo(m_metagame, luckyguyId);
        if (playerinfo is null) return;
		int characterId = playerinfo.getIntAttribute("character_id");
		const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
        if (characterinfo is null) return;
		Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,10,0)),c_pos,"jupiter_airstrike_warning.projectile",-1,1,120,100);
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,60,0)),c_pos,"artillery_jupiter_420.projectile",-1,1,120,10);
	}

	void start(){
		_log("Jupiter_Initialized: "+m_numLeft);
        m_started = true;
	}

    void update(float time) {
		reload_time -= time;

		if (reload_time < 0){
			if(m_started){
				jupiterfire();
				_log("Jupiter_Activated:"+ m_numLeft);
				m_numLeft++;
				reload_time = reload_cycle;			
			}
			else{
				_log("Jupiter_Deactivated:"+ m_numLeft);
				m_numLeft++;				
			}
		}
	}

	void end() {
		reload_time = reload_cycle;
        m_started = false;
		m_numLeft = 0;
	}

	bool hasEnded() const {
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_started;
	}
}