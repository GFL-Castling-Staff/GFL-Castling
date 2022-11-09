// internal
#include "task_sequencer.as"
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLairstrike.as"

//Author: NetherCrow

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

class DelayProjectileSet :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos;

	DelayProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			string c = 
				"<command class='create_instance'" +
				" faction_id='"+ m_faction_id +"'" +
				" instance_class='grenade'" +
				" instance_key='" + m_key +"'" +
				" position='" + m_pos.toString() + "'"+
				" character_id='" + m_character_id + "' />";
			m_metagame.getComms().send(c);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

class DelayMovingProjectileSet :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_offset;

	DelayMovingProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_offset=pos;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
			if (character !is null) {
				Vector3 now_pos = stringToVector3(character.getStringAttribute("position"));
				now_pos=now_pos.add(m_offset);
				string c = 
					"<command class='create_instance'" +
					" faction_id='"+ m_faction_id +"'" +
					" instance_class='grenade'" +
					" instance_key='" + m_key +"'" +
					" position='" + now_pos.toString() + "'"+
					" character_id='" + m_character_id + "' />";
				m_metagame.getComms().send(c);
			}
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

class Jupiter_Airstrike_Task : Task {
    protected GameMode@ m_metagame;
	protected float reload_cycle;
	protected float reload_time;
    protected int activation;
    protected int m_numLeft;

	Jupiter_Airstrike_Task(GameMode@ metagame){
		@m_metagame = @metagame;
		reload_cycle = 10.0;
		reload_time = 10.0;
		activation = 1;
		m_numLeft = 0;
	}

	void jupiterfire() {
		array<const XmlElement@> players = getPlayers(m_metagame);

		int luckyguyId = rand(1,players.length)-1;
		const XmlElement@ playerinfo = getPlayerInfo(m_metagame, luckyguyId);
		int characterId = playerinfo.getIntAttribute("character_id");
		const XmlElement@ characterinfo = getCharacterInfo(m_metagame, characterId);
		Vector3 c_pos = stringToVector3(characterinfo.getStringAttribute("position"));
		// CreateProjectile(Metagame@ m_metagame,Vector3 startPos,Vector3 endPos,string key,int cId,int fId,float initspeed,float ggg){
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,10,0)),c_pos,"jupiter_airstrike_warning_s.projectile",-1,1,720,100);
		CreateProjectile(m_metagame,c_pos.add(Vector3(0,120,0)),c_pos,"artillery_jupiter_420.projectile",-1,1,100,10);
	}

	void start(){
		_log("Jupiter_Initialized: "+m_numLeft);
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
			return false;
		}
		else {
		return true;
		}
	}
}

class DelayAirstrikeRequest :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected Vector3 m_pos;
	protected string m_airstrike_key;
	protected bool m_voice;

	DelayAirstrikeRequest(GameMode@ metagame, float time, int cId,int fId,Vector3 pos, string airstrike_key,bool voice=false) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos=pos;
		m_airstrike_key=airstrike_key;
		m_voice = voice;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			insertLockOnStrafeAirstrike(m_metagame,m_airstrike_key,m_character_id,m_faction_id,m_pos);
			if (m_voice){
				array<string> Voice={
					"A-10_1.wav",
					"A-10_2.wav",
					"A-10_3.wav"
				};
				playRandomSoundArray(m_metagame,Voice,m_faction_id,m_pos.toString(),1);		
			}
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

class DelayCommonCallRequest :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected Vector3 m_pos_2;
	protected string m_airstrike_key;

	DelayCommonCallRequest(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,Vector3 pos2) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		m_pos_2=pos2;
		m_airstrike_key=airstrike_key;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos_1,m_pos_2);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

class DelayAntiPersonSnipeRequest :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
	protected float m_addtime;
    protected int m_character_id;
    protected int m_faction_id;
	protected int m_target_id;
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected Vector3 m_pos_2;
	protected string m_airstrike_key;	
	protected bool m_shoot = false;


	DelayAntiPersonSnipeRequest(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,int target) {
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + 0.2;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		m_airstrike_key=airstrike_key;
		m_target_id = target;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		m_addtime -= time;
		if (m_timeLeft < 0 && m_shoot==false)
		{
			const XmlElement@ characterinfo = getCharacterInfo(m_metagame, m_target_id);
			if (characterinfo !is null){
				m_pos_2 = stringToVector3(characterinfo.getStringAttribute("position"));
				float dis = getFlatPositionDistance(m_pos_1,m_pos_2);
				CreateDirectProjectile(m_metagame,m_pos_1,m_pos_2,"sniper_bullet.projectile",m_character_id,m_faction_id,float(max(dis/0.2,40.0)));
				playSoundAtLocation(m_metagame,"supersassmod3_fire_FromBF4.wav",m_faction_id,m_pos_1,2.0);
				m_shoot = true;
			}
		}		
		if (m_addtime < 0 && m_timeLeft < 0){
			m_pos_2.add(Vector3(0,0.3,0));
			string c = 
				"<command class='create_instance'" +
				" faction_id='"+ m_faction_id +"'" +
				" instance_class='grenade'" +
				" instance_key='" + m_airstrike_key + "'" +
				" position='" + m_pos_2.toString() + "'"+
				" character_id='" + m_character_id + "' />";
			m_metagame.getComms().send(c);
		}		
	}

    bool hasEnded() const {
		if (m_addtime < 0) {
			return true;
		}
		return false;
	}
}