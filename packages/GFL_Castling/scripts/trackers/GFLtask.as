// internal
#include "task_sequencer.as"

#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

class VestRecoverTask : Task {
    protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_num;
    protected int m_character_id;
	protected float m_timeLeft;
    protected int m_numLeft;

    void start() {
		m_timeLeft=m_time;
		m_numLeft=1;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			_log("timeplayed:"+ m_numLeft);
			m_numLeft++;
			m_timeLeft=m_time;
		}

	}

    bool hasEnded() const {
		if (m_numLeft >= m_num) {
			return true;
		}
		return false;
	}
}

class Jupiter_Airstrike_Task : Task {
    protected Metagame@ m_metagame;
	protected const float reload_cycle;
	protected float reload_time;
    protected int activation;
    protected int m_numLeft;

	void init(Metagame@ metagame){
		@m_metagame = @metagame;
		reload_cycle = 150.0;
		reload_time = 150.0;
		activation = 1;
		m_numLeft = 0;
	}

	void jupiterfire() {
		array<const XmlElement@> players = getPlayers(m_metagame);

		int luckyguyId = rand(1,players.length)-1;
		const XmlElement@ playerinfo = getPlayerInfo(m_metagame, luckyguyId);
		int characterId = playerinfo.getIntAttribute("character_id");
		const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
		int factionid = characterinfo.getIntAttribute("faction_id");

		Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
		// CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg){
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,10,0)),c_pos,"jupiter_airstrike_warning.projectile",characterId,factionid,720,100);
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,60,0)),c_pos,"artillery_jupiter_420.projectile",characterId,factionid,120,10);

	}

    void update(float time) {
		reload_time -= time;
		if (reload_time < 0){
			if(activation > 0){
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
		activation = 0;
		m_numLeft = 0;
	}

    bool hasEnded() const {
		if (activation>0) {
			return true;
		}
		return false;
	}
}