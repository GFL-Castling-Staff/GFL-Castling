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
	protected int m_heal_layer;

	VestRecoverTask(Metagame@ metagame, float internal, int cId,int heal_time,int heal_layer)
	{
		@m_metagame = metagame;
		m_time = internal;
		m_character_id = cId;
		m_num = heal_time;
		m_heal_layer = heal_layer;
	}


    void start() {
		m_timeLeft=m_time;
		m_numLeft = m_num;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			healCharacter(m_metagame,m_character_id,m_heal_layer);
			m_numLeft--;
			m_timeLeft=m_time;
		}

	}

    bool hasEnded() const {
		if (m_numLeft <= 0) {
			return true;
		}
		return false;
	}
}

class AOEVestRecoverTask : Task {
    protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_num;
	protected float m_timeLeft;
    protected int m_numLeft;
	protected int m_heal_layer;
	protected int m_faction_id;
	protected float m_radius;
	protected Vector3@ m_pos;

	AOEVestRecoverTask(Metagame@ metagame, float internal, Vector3 pos,int heal_time,int heal_layer,int fid,float radius)
	{
		@m_metagame = metagame;
		m_time = internal;
		m_pos = pos;
		m_num = heal_time;
		m_heal_layer = heal_layer;
		m_faction_id = fid;
		m_radius = radius;
	}



    void start() {
		m_timeLeft=m_time;
		m_numLeft = m_num;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,m_pos,m_faction_id,m_radius);
			if (affectedCharacter !is null){
                for(uint x=0;x<affectedCharacter.length();x++){
					int soldierId = affectedCharacter[x].getIntAttribute("id");
					healCharacter(m_metagame,soldierId,m_heal_layer);
                }
            }
			m_numLeft--;
			m_timeLeft=m_time;
		}

	}

    bool hasEnded() const {
		if (m_numLeft <= 0) {
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

class DelayDetailedCallRequest :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
	protected float m_timeLeft;
	protected Airstrike_strafer@ m_strike;

	DelayDetailedCallRequest(GameMode@ metagame, float time, Airstrike_strafer@ strike) {
		@m_metagame = metagame;
		m_time = time;
		@m_strike = @strike;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			insertDetailedStrike(m_strike);
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
	protected string m_bullet_key="sniper_bullet.projectile";
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected Vector3 m_pos_2;
	protected string m_airstrike_key;	
	protected bool m_shoot = false;


	DelayAntiPersonSnipeRequest(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,int target) {
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + 0.1;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		m_airstrike_key=airstrike_key;
		m_target_id = target;
	}

	void setKey(string key)
	{
		m_bullet_key = key;
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
				CreateDirectProjectile(m_metagame,m_pos_1,m_pos_2,m_bullet_key,m_character_id,m_faction_id,float(max(dis/0.1,40.0)));
				playSoundAtLocation(m_metagame,"BT_rifle.wav",m_faction_id,m_pos_1,2.0);
				m_shoot = true;
			}
		}		
		if (m_addtime < 0 && m_timeLeft < 0){
			CreateDirectProjectile(m_metagame,m_pos_2.add(Vector3(0,9,0)),m_pos_2,m_airstrike_key,m_character_id,m_faction_id,90);
		}
	}

    bool hasEnded() const {
		if (m_addtime < 0) {
			return true;
		}
		return false;
	}
}

class DelayAntiTankSnipeRequest :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
	protected float m_addtime;
    protected int m_character_id;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected Vector3 m_pos_2;
	protected string m_airstrike_key;	
	protected bool m_shoot = false;


	DelayAntiTankSnipeRequest(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,Vector3 pos2) {
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + 0.2;
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
		m_addtime -= time;
		if (m_timeLeft < 0 && m_shoot==false)
		{
			float dis = getFlatPositionDistance(m_pos_1,m_pos_2);
			CreateDirectProjectile(m_metagame,m_pos_1,m_pos_2,"sniper_bullet.projectile",m_character_id,m_faction_id,float(max(dis/0.2,40.0)));
			playSoundAtLocation(m_metagame,"BT_rifle.wav",m_faction_id,m_pos_1,2.0);
			m_shoot = true;
		}		
		if (m_addtime < 0 && m_timeLeft < 0){
			CreateDirectProjectile(m_metagame,m_pos_2.add(Vector3(0,6,0)),m_pos_2,m_airstrike_key,m_character_id,m_faction_id,100);
		}	
	}

    bool hasEnded() const {
		if (m_addtime < 0) {
			return true;
		}
		return false;
	}
}

class DelaySpawnSoldier : Task {
    protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected array<Spawn_request@> m_soldier;
	protected float m_spread_x;
	protected float m_spread_y;
	protected Vector3 m_pos;

	DelaySpawnSoldier(GameMode@ metagame, float time,int fId, array<Spawn_request@> spawn_soldier,Vector3 pos1,float spreadX = 0.0,float spreadY = 0.0) {
		@m_metagame = metagame;
		m_time = time;
		m_faction_id =fId;
		m_pos=pos1;
		m_soldier=spawn_soldier;
		m_spread_x = spreadX;
		m_spread_y = spreadY;
	}

    void start() {
		m_timeLeft=m_time;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			for(uint i=0;i<m_soldier.length();i++){
				Spawn_request@ foo = m_soldier[i];
				spawnSoldier(m_metagame,foo.m_num,m_faction_id,m_pos,foo.m_type,m_spread_x,m_spread_y);
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

abstract class event_call_task : Task
{
	protected GameMode@ m_metagame;
	protected float m_time; //延迟
	protected float m_timeLeft; //延迟实例
	protected float m_time_internal; //间隔
	protected float m_timeLeft_internal; //间隔实例
    protected int m_character_id;
    protected int m_faction_id;
	protected Vector3 s_pos; //初始发射坐标
	protected Vector3 e_pos; //结束坐标
	protected Vector3 m_pos1; //发射坐标
	protected Vector3 m_pos2; //打击坐标
	protected string m_mode; //空袭等级
	protected string m_airstrike_key; //空袭key
    protected int m_excute_time=0; //执行次数
	protected int m_excute_Limit; //执行次数上限
	protected bool m_end=false;
	protected Vector3 strike_vector;
	protected float strike_didis;	//偏移

	event_call_task(GameMode@ metagame, float time, int cId,int fId,Vector3 start_pos,Vector3 target_pos,string mode="")
	{
		@m_metagame = @metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		s_pos=start_pos;
		e_pos=target_pos;
		m_mode=mode;
	}

	void start() {}
	void update(float time) {}
    bool hasEnded() const {
		if (m_end) {
			return true;
		}
		return false;
	}	
}

class strafe_task_30mm : event_call_task {
	protected int luckyGuyid = -1;

	void start(){
		float rand_angle = rand(-3.14,3.14);
		float rand_x = 2*cos(rand_angle);
		float rand_y = 2*sin(rand_angle);
		e_pos = e_pos.add(Vector3(rand_x,0,rand_y));
		rand_angle = rand(-3.14,3.14);
		rand_x = cos(rand_angle);
		rand_y = sin(rand_angle);  		
		Vector3 e_pos2 = e_pos.add(Vector3(rand_x,0,rand_y));
		luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,8.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			e_pos = stringToVector3(luckyGuy.getStringAttribute("position"));
		}
		luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,32.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			e_pos2 = stringToVector3(luckyGuy.getStringAttribute("position"));
		}
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,e_pos,e_pos2);
		strike_didis = 4.0;
		Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))); 
		pos_offset = pos_offset.add(Vector3(0,60,0));
		Vector3 pos_1st = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-15,0,-15)));
		Vector3 pos_2nd = e_pos2.add(getMultiplicationVector(strike_vector,Vector3(10,0,10)));
        m_excute_Limit = max(int(getAimUnitDistance(1,pos_1st,pos_2nd)/strike_didis),6);
		m_pos1 = pos_1st.add(pos_offset);
		m_pos2 = pos_1st;
		CreateDirectProjectile(m_metagame,m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))),m_pos2.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",m_character_id,m_faction_id,70);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));
		m_time_internal = 0.15;
		m_airstrike_key = "30mm_strafe";
	}

	strafe_task_30mm(GameMode@ metagame, float time, int cId,int fId,Vector3 start_pos,Vector3 target_pos,string mode=""){
		super(metagame,time,cId,fId,start_pos,target_pos,mode);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_pos1 = m_pos1.add(Vector3(0,-20*(sqrt(float(1/m_excute_Limit)*m_excute_time)),0));
		m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));					
	}
}