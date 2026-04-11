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
#include "fairy_command.as"
#include "GFLparameters.as"

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

class TimerMarker : Task {
    protected Metagame@ m_metagame;
	protected float m_time;
	protected CastlingMarker@ m_info;
	protected float m_timeLeft;
	protected bool m_end=false;

	TimerMarker(Metagame@ metagame, float time,CastlingMarker@ call_info)
	{
		@m_metagame = metagame;
		@m_info = call_info;
		m_time = time;
	}

    void start() {
		m_timeLeft=m_time;
        XmlElement command("command");
		command.setStringAttribute("class", "set_marker");
		command.setIntAttribute("id", m_info.m_callId);
		command.setIntAttribute("faction_id", m_info.m_factions);
		command.setIntAttribute("atlas_index", m_info.m_atlasIndex);
		command.setFloatAttribute("size", m_info.m_size);
		command.setFloatAttribute("range", m_info.m_range);
		command.setIntAttribute("enabled", 1);
		command.setStringAttribute("position", m_info.m_pos.toString());
		command.setStringAttribute("text", "");
		command.setStringAttribute("type_key", m_info.m_typeKey);
		command.setBoolAttribute("show_in_map_view", true);
		command.setBoolAttribute("show_in_game_view", true);
		command.setBoolAttribute("show_at_screen_edge", false);
        m_metagame.getComms().send(command);
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			XmlElement command("command");
			command.setStringAttribute("class", "set_marker");
			command.setIntAttribute("id", m_info.m_callId);
			command.setIntAttribute("faction_id", m_info.m_factions);
			command.setIntAttribute("enabled", 0);
			m_metagame.getComms().send(command);
			m_end = true;
		}
	}

    bool hasEnded() const {
		if (m_end) {
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
	protected Vector3 m_pos;
	protected string m_effect_projectile = "";

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

	void setEffectParticle(string key){
		m_effect_projectile = key;
	}

    void start() {
		m_timeLeft=0;
		m_numLeft = m_num;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			if(m_effect_projectile!="")
			{
				spawnStaticProjectile(m_metagame,m_effect_projectile,m_pos,-1,m_faction_id);
			}
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

//task静态弹头，单次,POS
class DelayProjectileSet :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos;
	protected bool m_alive_check;

	DelayProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
		m_alive_check=false;
	}

	DelayProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos, bool alive_check) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
		m_alive_check=alive_check;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			if (m_alive_check) {
				const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
            	if (checkCharacterDead(character)) return;
			}
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

//task静态弹头，跟踪cId
class DelayMovingTargetProjectileSet :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_target_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;

	DelayMovingTargetProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,int target) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
        m_target_id = target;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
			if (!checkCharacterDead(character)) {
                const XmlElement@ target = getCharacterInfo(m_metagame, m_target_id);
                if(target is null) return;
				Vector3 target_pos = stringToVector3(target.getStringAttribute("position"));
				string c =
					"<command class='create_instance'" +
					" faction_id='"+ m_faction_id +"'" +
					" instance_class='grenade'" +
					" instance_key='" + m_key +"'" +
					" position='" + target_pos.toString() + "'"+
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

//task点对点弹头，单次,POS1 POS2 线速度
class DelayP2PProjectileSet :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos1;
	protected Vector3 m_pos2;
    protected float m_speed;

	DelayP2PProjectileSet(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos1,Vector3 pos2,float speed) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos1=pos1;
        m_pos2=pos2;
        m_speed = speed;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            CreateDirectProjectile(m_metagame,m_pos1,m_pos2,m_key,m_character_id,m_faction_id,m_speed);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

//task点对点定高弹头，单次,POS1 POS2 重力g 高度h
class DelayP2PProjectileSet_H :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos1;
	protected Vector3 m_pos2;
    protected float m_gspeed;
    protected float m_height;

	DelayP2PProjectileSet_H(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos1,Vector3 pos2,float gspeed,float height) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos1=pos1;
        m_pos2=pos2;
        m_gspeed = gspeed;
        m_height= height;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            CreateProjectile_H(m_metagame,m_pos1,m_pos2,m_key,m_character_id,m_faction_id,m_gspeed,m_height);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

//task人对点定高弹头，单次,POS1 POS2 重力g 高度h
class DelayC2PProjectileSet_H :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos;
    protected float m_gspeed;
    protected float m_height;
	protected string m_sound;
	protected float m_sound_volume;

	DelayC2PProjectileSet_H(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos,float gspeed,float height) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
        m_gspeed = gspeed;
        m_height= height;
		m_sound = "";
		m_sound_volume = 0;
	}

	DelayC2PProjectileSet_H(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos,float gspeed,float height,string sound,float sound_volume) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
        m_gspeed = gspeed;
        m_height= height;
		m_sound = sound;
		m_sound_volume = sound_volume;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
            if (checkCharacterDead(character)) return;
            Vector3 c_pos = getCharacterPosition(character);
            c_pos=c_pos.add(Vector3(0,1.5,0));
			if (m_sound != "") {
				playSoundAtLocation(m_metagame,m_sound,m_faction_id,c_pos,m_sound_volume);
			}
            CreateProjectile_H(m_metagame,c_pos,m_pos,m_key,m_character_id,m_faction_id,m_gspeed,m_height);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}
class ConstantStaticProjectileEvent :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected float m_timeLeft;
	protected Vector3 m_pos;
	protected int m_trigger_time;
	protected int m_triggered_time = 0;
	protected float m_time_internal;
	protected bool m_strict_check;

	ConstantStaticProjectileEvent(Metagame@ metagame, float time, int cId,int fId,string key,Vector3 pos,int trigger,float time_internal,bool strict_check=true) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_key=key;
		m_pos=pos;
		m_trigger_time = trigger;
		m_time_internal = time_internal;
		m_strict_check = strict_check;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            m_timeLeft= m_time_internal;
			if(m_strict_check)
			{
				const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
				if(checkCharacterDead(character)) return;
			}
			string c =
				"<command class='create_instance'" +
				" faction_id='"+ m_faction_id +"'" +
				" instance_class='grenade'" +
				" instance_key='" + m_key +"'" +
				" position='" + m_pos.toString() + "'"+
				" character_id='" + m_character_id + "' />";
			m_metagame.getComms().send(c);
			m_triggered_time++;
		}
	}

    bool hasEnded() const {
		if (m_triggered_time >= m_trigger_time) {
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
            const XmlElement@ characterInfo = getCharacterInfo(m_metagame,m_character_id);
			if(checkCharacterDead(characterInfo)) return;
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

class DelayKillCharacter :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_character_id;
	protected float m_timeLeft;

	DelayKillCharacter(GameMode@ metagame, float time, int cId) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            const XmlElement@ characterInfo = getCharacterInfo(m_metagame,m_character_id);
			if(checkCharacterDead(characterInfo)) return;
			killCharacter(m_metagame,m_character_id);
		}
	}

    bool hasEnded() const {
		return m_timeLeft < 0;
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
	protected string m_playsound_key="BT_rifle.wav";
	protected float m_playsound_volume=2.0;
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected Vector3 m_pos_2;
	protected string m_airstrike_key;
	protected bool m_shoot = false;
	protected MutilProjectile@ m_projectiles=null;


	DelayAntiPersonSnipeRequest(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,int target) {
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + 0.05;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		m_airstrike_key=airstrike_key;
		m_target_id = target;
	}

	DelayAntiPersonSnipeRequest(GameMode@ metagame, float time, int cId,int fId, MutilProjectile@ airstrike_key,Vector3 pos1,int target) {
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + 0.05;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		@m_projectiles = airstrike_key;
		m_target_id = target;
	}

	void setKey(string key)
	{
		m_bullet_key = key;
	}

	void setSound(string key)
	{
		m_playsound_key = key;
	}

	void setVolume(float num)
	{
		m_playsound_volume = num;
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
				CreateDirectProjectile(m_metagame,m_pos_1,m_pos_2,m_bullet_key,m_character_id,m_faction_id,float(max(dis/0.05,40.0)));
				playSoundAtLocation(m_metagame,m_playsound_key,m_faction_id,m_pos_1,m_playsound_volume);
				m_shoot = true;
			}
		}
		if (m_addtime < 0 && m_timeLeft < 0){
			if(m_projectiles !is null)
			{
				CreateMutilDirectProjectile(m_metagame,m_pos_2.add(Vector3(0,10,0)),m_pos_2,m_projectiles.m_key,m_character_id,m_faction_id,300,m_projectiles.m_num);
			}
			else
			{
				CreateDirectProjectile(m_metagame,m_pos_2.add(Vector3(0,10,0)),m_pos_2,m_airstrike_key,m_character_id,m_faction_id,300);
			}
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
			float dis = getFlatPositionDistance(m_pos_1,m_pos_2.add(Vector3(0,1,0)));
			CreateDirectProjectile(m_metagame,m_pos_1,m_pos_2.add(Vector3(0,1,0)),"sniper_bullet_airburst.projectile",m_character_id,m_faction_id,float(max(dis/0.2,40.0)));
			playSoundAtLocation(m_metagame,"BT_rifle.wav",m_faction_id,m_pos_1,2.0);
			m_shoot = true;
		}
		if (m_addtime < 0 && m_timeLeft < 0){
			CreateDirectProjectile(m_metagame,m_pos_2.add(Vector3(0,3,0)),m_pos_2,m_airstrike_key,m_character_id,m_faction_id,100);
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
	protected array<soldier_spawn_request@> m_soldier;
	protected float m_spread_x;
	protected float m_spread_y;
	protected Vector3 m_pos;

	DelaySpawnSoldier(GameMode@ metagame, float time,int fId, array<soldier_spawn_request@> spawn_soldier,Vector3 pos1,float spreadX = 0.0,float spreadY = 0.0) {
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
				soldier_spawn_request@ foo = m_soldier[i];
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

abstract class event_call_task_hasMarker : Task
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
	protected int m_markerId;

	event_call_task_hasMarker(GameMode@ metagame, float time, int cId,int fId,Vector3 start_pos,Vector3 target_pos,string mode="",int markid=0)
	{
		@m_metagame = @metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		s_pos=start_pos;
		e_pos=target_pos;
		m_mode=mode;
		m_markerId = markid;
	}

	void start() {}
	void update(float time) {}
    bool hasEnded() const {
		if (m_end) {
			if(m_markerId != 0)
			{
				removeMarkerwithId(m_metagame,m_faction_id,m_markerId);
			}
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
			if(luckyGuy is null) return;
			e_pos = stringToVector3(luckyGuy.getStringAttribute("position"));
		}
		luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,32.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuy is null) return;
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

		const XmlElement@ character = getCharacterInfo(m_metagame,m_character_id);
		if(character is null){m_end = true;return;}
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_pos1 = m_pos1.add(Vector3(0,-20*(sqrt(float(1/m_excute_Limit)*m_excute_time)),0));
		m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
	}
}

class strafe_task_15mm_mg151 : event_call_task {
	protected int luckyGuyid = -1;
	protected Vector3 first_offset = Vector3(-15,0,-15);
	protected Vector3 second_offset = Vector3(10,0,10);

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_didis = 3.0;
		Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40)));
		pos_offset = pos_offset.add(Vector3(0,60,0));
		Vector3 pos_1st = e_pos.add(getMultiplicationVector(strike_vector,first_offset));
		Vector3 pos_2nd = e_pos.add(getMultiplicationVector(strike_vector,second_offset));
        m_excute_Limit = max(int(getAimUnitDistance(1,pos_1st,pos_2nd)/strike_didis),6);
		m_pos1 = pos_1st.add(pos_offset);
		m_pos2 = pos_1st;
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));
		m_time_internal = 0.35;
		m_airstrike_key = "15mm_mg151";
	}

	strafe_task_15mm_mg151(GameMode@ metagame, float time, int cId,int fId,Vector3 start_pos,Vector3 target_pos,string mode=""){
		super(metagame,time,cId,fId,start_pos,target_pos,mode);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		const XmlElement@ character = getCharacterInfo(m_metagame,m_character_id);
		if(character is null){m_end = true;return;}
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_pos1 = m_pos1.add(Vector3(0,-20*(sqrt(float(1/m_excute_Limit)*m_excute_time)),0));
		m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
	}
}

class Ju87_Assault :Task{
	protected Metagame@ m_metagame;
	protected float m_time;
	protected float m_time_1;
    protected int m_character_id;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected float m_timeLeft_1;
	protected Vector3 m_pos;
	protected bool m_started;

	Ju87_Assault(Metagame@ metagame, float time, int cId,int fId,Vector3 pos,float time1 =5.0) {
		@m_metagame = metagame;
		m_time = time;
		m_time_1 = time1;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos=pos;
	}

	void start() {
		m_timeLeft=m_time;
		m_timeLeft_1 = m_time_1;
		m_started = false;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0 && !m_started)
		{
			m_started = true;
			playSoundAtLocation(m_metagame,"stuka_bomber_assault.wav",m_faction_id,m_pos,0.7);
		}
		if(m_started)
		{
			m_timeLeft_1 -= time;
		}
		if(m_timeLeft_1 < 0)
		{
			float rand_angle = rand(-3.14,3.14);
			float rand_x = 50*cos(rand_angle);
			float rand_y = 50*sin(rand_angle);
			Vector3 start_pos = m_pos.add(Vector3(rand_x,0,rand_y));
			start_pos = start_pos.add(Vector3(0,50,0));
			insertCommonStrike(m_character_id,m_faction_id,"ju87_assault",start_pos,m_pos);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft_1 < 0) {
			return true;
		}
		return false;
	}
}

abstract class DelaySkill :Task{
	protected GameMode@ m_metagame;
	protected float m_time; //延迟
	protected float m_timeLeft; //延迟实例
	protected float m_time_internal; //间隔
	protected float m_timeLeft_internal; //间隔实例
    protected int m_character_id;
    protected int m_faction_id;
    protected string m_key;
	protected Vector3 c_pos; //初始角色坐标
	protected Vector3 t_pos; //初始目标坐标
	protected int m_excute_time=0; //执行次数
	protected int m_excute_Limit; //执行次数上限
	protected bool m_end=false;

	DelaySkill(GameMode@ metagame, float time, int cId,int fId) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
	}

	void start() {}
	void update(float time) {}
    bool hasEnded() const {
		if (m_end) {
			return true;
		}
		return false;
	}

	void setKey(string key){
		m_key= key;
	}

	void setCharacterPos(Vector3 pos){
		c_pos=pos;
	}
	void setTargetPos(Vector3 pos){
		t_pos=pos;
	}
	void setExcuteLimit(int a){
		m_excute_Limit=a;
	}
	void setInternal(float inter){
		m_time_internal=inter;
	}
}

class Skill_m1911mod3 : DelaySkill {
	protected array<const XmlElement@> affectedCharacter;

	Skill_m1911mod3(GameMode@ metagame, float time, int cId,int fId,Vector3 pos){
		super(metagame,time,cId,fId);
		t_pos = pos;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		int m_fnum = m_metagame.getFactionCount();
		this.setExcuteLimit(7);
		this.setInternal(0.25);
		for(int i=0;i<m_fnum;i++) {
			if(i!=m_faction_id) {
				array<const XmlElement@> affectedCharacter2;
				affectedCharacter2 = getCharactersNearPosition(m_metagame,t_pos,i,20.0f);
				if (affectedCharacter2 !is null){
					for(uint x=0;x<affectedCharacter2.length();x++){
						affectedCharacter.insertLast(affectedCharacter2[x]);
					}
				}
			}
		}
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		if (affectedCharacter.length()<= 0){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyoneid = affectedCharacter[getRandomIndex(affectedCharacter.length())].getIntAttribute("id");
		const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
		if(luckyoneC is null)
		{
			m_timeLeft_internal = 0;
			return;
		}
		Vector3 e_pos = stringToVector3(luckyoneC.getStringAttribute("position"));
		if(m_excute_time < 7){
			CreateDirectProjectile(m_metagame,e_pos.add(Vector3(0,20,0)),e_pos,"snipe_m1911.projectile",m_character_id,m_faction_id,300);
		}
		else{
			CreateDirectProjectile(m_metagame,e_pos.add(Vector3(0,20,0)),e_pos,"snipe_m1911_big.projectile",m_character_id,m_faction_id,300);
		}
	}
}

class Skill_Sf_Boss_Dreamer : DelaySkill {
	protected array<const XmlElement@> affectedCharacter;

	Skill_Sf_Boss_Dreamer(GameMode@ metagame, float time, int cId,int fId,Vector3 pos){
		super(metagame,time,cId,fId);
		c_pos = pos;//目前点位
		t_pos = pos;//目标点位
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		uint m_fnum = m_metagame.getFactionCount();
		this.setExcuteLimit(100);
		this.setInternal(0.1);
		TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
		affectedCharacter = getEnemyCharactersNearPosition(m_metagame,t_pos,m_faction_id,30.0f);
	}

	void update(float time) {

		if(m_excute_time%10==0){
			const XmlElement@ LiveGuy = getCharacterInfo(m_metagame, m_character_id);
			if(LiveGuy is null){m_end = true;return;}
			affectedCharacter = getEnemyCharactersNearPosition(m_metagame,t_pos,m_faction_id,15.0f);
			if (affectedCharacter.length()<= 0)affectedCharacter = getEnemyCharactersNearPosition(m_metagame,c_pos,m_faction_id,40.0f);
			if (affectedCharacter.length()<= 0){m_end = true;return;}
			int luckyoneid = affectedCharacter[0].getIntAttribute("id");
			const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
			if(luckyoneC is null){m_end = true;return;}
			t_pos = stringToVector3(luckyoneC.getStringAttribute("position"));
		}

		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}

		m_timeLeft_internal = m_time_internal;
		// 细细切做臊子.jpg
		//insertCommonStrike(m_character_id,m_faction_id,"ioncannon_strafe_dreamer",c_pos,c_pos.add(getAimUnitVector(0.8,c_pos,t_pos)));
		CreateDirectProjectile(m_metagame,c_pos.add(Vector3(0,60,0)),c_pos,"skill_sf_boss_dreamer_ioncannon.projectile",m_character_id,m_faction_id,180);
		c_pos = c_pos.add(getAimUnitVector(1.5,c_pos,t_pos));

		m_excute_time++;
	}
}

class GDIIonCannonStrike : DelaySkill {
	protected CastlingMarker@ m_info;

	GDIIonCannonStrike(GameMode@ metagame, float time, int cId,int fId, Vector3 pos){
		super(metagame,time,cId,fId);
		t_pos = pos;
	}

    void start() {
        m_timeLeft = m_time;
        m_timeLeft_internal = 0;
        this.setExcuteLimit(25); // 设置执行限制为5次，每0.5秒一次，总共2.5秒
        this.setInternal(0.2); // 设置内部间隔为0.5秒
    }

    void update(float time) {
        if (m_timeLeft >= 0) { m_timeLeft -= time; return; }
        if (m_timeLeft_internal >= 0) { m_timeLeft_internal -= time; return; }
        if (m_excute_time >= m_excute_Limit) { m_end = true; return; }

        if (m_excute_time < 4) {
			Vector3 strikePosition;
			for(int i=1;i<=6;i++){
				strikePosition = calculateStrikePosition(0,t_pos,i);
				CreateDirectProjectile(m_metagame, strikePosition.add(Vector3(0,40,0)), strikePosition, "GDIICS_1.projectile", m_character_id, m_faction_id, 120);
			}
        } else if (m_excute_time < 15) {
			Vector3 strikePosition;
			for(int i=1;i<=6;i++){
				int num = m_excute_time-4;
				strikePosition = calculateStrikePosition(num,t_pos,i+0.1*(1+num*0.1)*num);
				CreateDirectProjectile(m_metagame, strikePosition.add(Vector3(0,40,0)), strikePosition, "GDIICS_1.projectile", m_character_id, m_faction_id, 120);
			}
		} else if (m_excute_time < 24) {
			CreateDirectProjectile(m_metagame, t_pos.add(Vector3(0,40,0)), t_pos, "GDIICS_1.projectile", m_character_id, m_faction_id, 120);
		}
		 else if (m_excute_time == m_excute_Limit-1){
            CreateDirectProjectile(m_metagame, t_pos.add(Vector3(0,20,0)), t_pos, "GDIICS_2.projectile", m_character_id, m_faction_id, 60);
        }

        m_timeLeft_internal = m_time_internal;
        m_excute_time++;
    }

    Vector3 calculateStrikePosition(int step, Vector3 t_pos, float num) {
        // 根据步骤计算轰击位置
        float angle = num * 60.0; // 每次逆时针旋转120度
        return t_pos.add(Vector3(
            (10-step) * cos(angle * 3.1415 / 180.0),
            0,
            (10-step) * sin(angle * 3.1415 / 180.0)
        ));
    }
}


class Skill_M200_Snipe : DelaySkill {
    protected CastlingMarker@ m_info;

	Skill_M200_Snipe(GameMode@ metagame, float time, int cId,int fId,Vector3 pos,CastlingMarker@ info){
		super(metagame,time,cId,fId);
		t_pos = pos;
        @m_info = info;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		this.setExcuteLimit(7);
		this.setInternal(2.0);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,t_pos,40.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuy is null) return;
			Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
			Vector3 startPos = getRandomOffsetVector(luckyGuyPos,70.0);
			startPos = startPos.add(Vector3(0,60,0));
			CreateDirectProjectile(m_metagame,startPos,luckyGuyPos,"m200_snipe.projectile",m_character_id,m_faction_id,400);
			playSoundAtLocation(m_metagame,"m200_fire_snipe_GFL.wav",m_faction_id,luckyGuyPos,2.0);
		}
	}

    bool hasEnded() const {
		if (m_end) {
            removeMarker(m_metagame,m_info);
			return true;
		}
		return false;
	}
}

class Skill_SSG3000_Snipe : DelaySkill {
    protected CastlingMarker@ m_info;

	Skill_SSG3000_Snipe(GameMode@ metagame, float time, int cId,int fId,Vector3 pos,CastlingMarker@ info){
		super(metagame,time,cId,fId);
		t_pos = pos;
        @m_info = info;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		this.setExcuteLimit(7);
		this.setInternal(2.0);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,t_pos,40.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuy is null) return;
			Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
			Vector3 startPos = getRandomOffsetVector(luckyGuyPos,70.0);
			startPos = startPos.add(Vector3(0,60,0));
			CreateDirectProjectile(m_metagame,startPos,luckyGuyPos,"m200_snipe.projectile",m_character_id,m_faction_id,400);
			playSoundAtLocation(m_metagame,"m200_fire_snipe_GFL.wav",m_faction_id,luckyGuyPos,2.0);
		}
	}

    bool hasEnded() const {
		if (m_end) {
            removeMarker(m_metagame,m_info);
			return true;
		}
		return false;
	}
}

class Skill_Fairy_Snipe : DelaySkill {
    protected CastlingMarker@ m_info;

	Skill_Fairy_Snipe(GameMode@ metagame, float time, int cId,int fId,Vector3 pos,CastlingMarker@ info){
		super(metagame,time,cId,fId);
		t_pos = pos;
        @m_info = info;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		this.setExcuteLimit(10);
		this.setInternal(2.0);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,t_pos,40.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuy is null) return;
			Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
			Vector3 startPos = getRandomOffsetVector(luckyGuyPos,70.0);
			startPos = startPos.add(Vector3(0,60,0));
			CreateDirectProjectile(m_metagame,startPos,luckyGuyPos,"fairy_snipe.projectile",m_character_id,m_faction_id,240);
			playSoundAtLocation(m_metagame,"sniperfairy_fire_FromCOD15.wav",m_faction_id,luckyGuyPos,2.2);
		}
		if(m_excute_time ==1)
		{
			sendFactionMessageKey(m_metagame,m_faction_id,"snipefight");
		}
	}
    bool hasEnded() const {
		if (m_end) {
            removeMarker(m_metagame,m_info);
			return true;
		}
		return false;
	}
}

class Skill_ff_excutioner : DelaySkill {
	protected array<const XmlElement@> affectedCharacter;

	Skill_ff_excutioner(GameMode@ metagame, float time, int cId,int fId,Vector3 pos){
		super(metagame,time,cId,fId);
		t_pos = pos;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		int m_fnum = m_metagame.getFactionCount();
		this.setExcuteLimit(3);
		this.setInternal(0.2);
		for(int i=0;i<m_fnum;i++) {
			if(i!=m_faction_id) {
				array<const XmlElement@> affectedCharacter2;
				affectedCharacter2 = getCharactersNearPosition(m_metagame,t_pos,i,6.0f);
				if (affectedCharacter2 !is null){
					for(uint x=0;x<affectedCharacter2.length();x++){
						affectedCharacter.insertLast(affectedCharacter2[x]);
					}
				}
			}
		}
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		if (affectedCharacter.length()<= 0){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyoneid = affectedCharacter[getRandomIndex(affectedCharacter.length())].getIntAttribute("id");
		const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
		if(luckyoneC is null)
		{
			m_timeLeft_internal = 0;
			return;
		}
		Vector3 e_pos = stringToVector3(luckyoneC.getStringAttribute("position"));
		CreateDirectProjectile(m_metagame,e_pos.add(Vector3(0,20,0)),e_pos,"snipe_ff_excutioner.projectile",m_character_id,m_faction_id,300);
	}
}

class Skill_ff_hunter : DelaySkill {
	protected array<const XmlElement@> affectedCharacter;

	Skill_ff_hunter(GameMode@ metagame, float time, int cId,int fId,Vector3 pos){
		super(metagame,time,cId,fId);
		t_pos = pos;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		int m_fnum = m_metagame.getFactionCount();
		this.setExcuteLimit(8);
		this.setInternal(0.2);
		for(int i=0;i<m_fnum;i++) {
			if(i!=m_faction_id) {
				array<const XmlElement@> affectedCharacter2;
				affectedCharacter2 = getCharactersNearPosition(m_metagame,t_pos,i,16.0f);
				if (affectedCharacter2 !is null){
					for(uint x=0;x<affectedCharacter2.length();x++){
						affectedCharacter.insertLast(affectedCharacter2[x]);
					}
				}
			}
		}
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		if (affectedCharacter.length()<= 0){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyoneid = affectedCharacter[getRandomIndex(affectedCharacter.length())].getIntAttribute("id");
		const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
		if(luckyoneC is null)
		{
			m_timeLeft_internal = 0;
			return;
		}
		Vector3 e_pos = stringToVector3(luckyoneC.getStringAttribute("position"));
		CreateDirectProjectile(m_metagame,e_pos.add(Vector3(0,20,0)),e_pos,"snipe_ff_hunter.projectile",m_character_id,m_faction_id,300);
	}
}

class Skill_ff_dreamer : DelaySkill {

	Skill_ff_dreamer(GameMode@ metagame, float time, int cId, int fId, Vector3 spos, Vector3 epos){
		super(metagame,time,cId,fId);
		c_pos = spos;
		t_pos = epos;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		int m_fnum = m_metagame.getFactionCount();
		this.setExcuteLimit(1);
		this.setInternal(0.2);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		//扫射位置偏移单位向量 与 扫射位置偏移单位距离
		Vector3 strike_vector = getAimUnitVector(1,c_pos,t_pos);
		float strike_didis = 1.2;
		//扫射起点 从弹头终点指向弹头起点的位置
		Vector3 pos_offset = Vector3(0,60,0);
		//扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
		c_pos = t_pos.add(getMultiplicationVector(strike_vector,Vector3(-12,0,-12)));
		t_pos = t_pos.add(getMultiplicationVector(strike_vector,Vector3(12,0,12)));
		//依据扫射位置偏移单位距离而设置的扫射次数
		int strike_time = int(getAimUnitDistance(1,c_pos,t_pos)/strike_didis);
		//弹头起始扫射位置与终止扫射位置
		Vector3 startPos = c_pos.add(pos_offset);
		Vector3 endPos = c_pos;

		for(int i=0;i<=strike_time;i++){
			//水平偏移
			startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			//每单轮扫射生成1次对点扫射
			CreateDirectProjectile(m_metagame,startPos,endPos,"skill_ff_dreamer_ioncannon.projectile",m_character_id,m_faction_id,280);
		}
	}
}


class Event_call_bombardment_fairy_82mm_mortar : event_call_task_hasMarker {

	string m_airstrike_key_alt="";

	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_vector = getRotatedVector(getIntSymbol()*1.57,strike_vector);
		strike_didis = 0;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(0,0,0)));
		m_pos2 = m_pos1;
		m_pos1=m_pos1.add(Vector3(0,40,0));
		if(m_mode == "bombardment_fairy_82mm_mortar_lv0")
		{
			m_excute_Limit = 4;
			m_time_internal = 1.3;
			m_airstrike_key = "mortar_82mm_x8";
			m_airstrike_key_alt = "mortar_82mm";
		}
		if(m_mode == "bombardment_fairy_82mm_mortar_free_lv0")
		{
			m_excute_Limit = 4;
			m_time_internal = 1.3;
			m_airstrike_key = "mortar_82mm_x4";
			m_airstrike_key_alt = "mortar_82mm";
		}
		if(m_mode == "bombardment_fairy_82mm_mortar_free_beta")
		{
			m_excute_Limit = 4;
			m_time_internal = 1.3;
			m_airstrike_key = "mortar_82mm_x4_he";
			m_airstrike_key_alt = "mortar_82mm_he";
		}
		if(m_mode == "bombardment_fairy_82mm_mortar_beta")
		{
			m_excute_Limit = 5;
			m_time_internal = 1.3;
			m_airstrike_key = "mortar_82mm_x8_he";
			m_airstrike_key_alt = "mortar_82mm_he";
		}
		if(m_mode == "bombardment_fairy_82mm_mortar_gamma")
		{
			m_excute_Limit = 4;
			m_time_internal = 1.3;
			m_airstrike_key = "mortar_82mm_x16";
			m_airstrike_key_alt = "mortar_82mm";
		}
	}

	Event_call_bombardment_fairy_82mm_mortar(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;

		const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character))
		{
			m_end = true;
			return;
		}
		if(m_excute_time==1)
		{
			m_timeLeft_internal = 2.5;
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key_alt,m_pos1,m_pos2);
		}
		else
		{
			m_timeLeft_internal = m_time_internal;
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		}
	}
}

class Event_call_airstrike_fairy_precise : event_call_task_hasMarker {

	string m_airstrike_key_alt="";

	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_vector = getRotatedVector(getIntSymbol()*1.57,strike_vector);
		strike_didis = 0;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(0,0,0)));
		m_pos2 = m_pos1;
		m_pos1=m_pos1.add(Vector3(0,40,0));
		if(m_mode == "airstrike_fairy_precise")
		{
			m_excute_Limit = 1;
			m_time_internal = 0.1;
			m_airstrike_key = "precision_airstrike";
		}
		if(m_mode == "airstrike_fairy_precise_alpha")
		{
			m_excute_Limit = 1;
			m_time_internal = 0.1;
			m_airstrike_key = "precision_airstrike_big";
		}

	}

	Event_call_airstrike_fairy_precise(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;

		const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character))
		{
			m_end = true;
			return;
		}
		playSoundAtLocation(m_metagame,"airstrike_flyby.wav",m_faction_id,m_pos2,1.5);
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
	}
}

class Event_call_airstrike_fairy_bomber : event_call_task_hasMarker {

	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_vector = getRotatedVector(getIntSymbol()*1.57,strike_vector);
		strike_didis = 4.5;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-18,0,-18)));
		m_pos2 = m_pos1;
		m_pos1 = m_pos1.add(Vector3(0,40,0));
		if(m_mode == "airstrike_fairy_bomber_lv0")
		{
			m_excute_Limit = 9;
			m_time_internal = 0.12;
			m_airstrike_key = "bomber_drop_lv0";
		}
		if(m_mode == "airstrike_fairy_bomber_alpha")
		{
			m_excute_Limit = 9;
			m_time_internal = 0.12;
			m_airstrike_key = "bomber_drop_dragonfire";
		}
		if(m_mode == "airstrike_fairy_bomber_gamma")
		{
			m_excute_Limit = 5;
			m_time_internal = 0.4;
			strike_didis = 9.0;
			m_airstrike_key = "bomber_drop_gamma";
		}
	}

	Event_call_airstrike_fairy_bomber(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}

		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		if(m_excute_time == 1)
		{
			playSoundAtLocation(m_metagame,"airstrike_flyby.wav",m_faction_id,m_pos2,1.5);
		}

		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
	}
}

class Event_call_airstrike_fairy_cas : event_call_task_hasMarker {
	string bomb_string = "airstrike_cas_bomb";

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_vector = getRotatedVector(getIntSymbol()*1.57,strike_vector);
		strike_didis = 3.2;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-60,0,-60)));
		m_pos1= m_pos1.add(Vector3(0,40,0));
		m_pos2 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-16,0,-16)));
		m_excute_Limit = 10;
		m_time_internal = 0.1;
		m_airstrike_key = "airstrike_cas_23mm";
		if(m_mode == "airstrike_fairy_cas_beta")
		{
			m_airstrike_key = "airstrike_cas_23mm+2";
		}
		if(m_mode == "airstrike_fairy_cas_gamma")
		{
			bomb_string = "airstrike_cas_bomb_big";
		}
	}

	Event_call_airstrike_fairy_cas(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		if(m_excute_time!=10)
		{
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
			m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			m_timeLeft_internal = m_time_internal;
		}
		else if(m_excute_time==10)
		{
			Vector3 start_pos = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-6,0,-6)));
			start_pos = start_pos.add(Vector3(0,40,0));
			DelayCommonCallRequest@ shot = DelayCommonCallRequest(m_metagame,0.5,m_character_id,m_faction_id,bomb_string,start_pos,e_pos);
            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
            tasker.add(shot);
			m_timeLeft_internal = m_time_internal;
		}
		if(m_excute_time==1)
		{
			CreateDirectProjectile(m_metagame,m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))),m_pos2.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",m_character_id,m_faction_id,70);
		}
	}
}

class Event_call_airstrike_fairy_cas_p2p : event_call_task_hasMarker {
	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_didis = 3.2;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-60,0,-60)));
		m_pos1= m_pos1.add(Vector3(0,40,0));
		m_pos2 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-16,0,-16)));
		m_excute_Limit = 10;
		m_time_internal = 0.1;
		m_airstrike_key = "airstrike_cas_23mm";
	}

	Event_call_airstrike_fairy_cas_p2p(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		if(m_excute_time!=10)
		{
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
			m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
			m_timeLeft_internal = m_time_internal;
		}
		else if(m_excute_time==10)
		{
			Vector3 start_pos = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-10,0,-10)));
			start_pos = start_pos.add(Vector3(0,40,0));
			DelayCommonCallRequest@ shot = DelayCommonCallRequest(m_metagame,0.5,m_character_id,m_faction_id,"airstrike_cas_bomb",start_pos,e_pos);
            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
            tasker.add(shot);
			m_timeLeft_internal = m_time_internal;
		}
		if(m_excute_time==1)
		{
			CreateDirectProjectile(m_metagame,m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))),m_pos2.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",m_character_id,m_faction_id,70);
		}
	}
}

class Event_call_warrior_fairy_recon_heil : event_call_task_hasMarker {
	int lucky_vehicle_id = -1;
	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1= e_pos.add(Vector3(10.0*cos(rand(0.0,3.14)),40,10.0*sin(rand(0.0,3.14))));
		sendFactionMessageKey(m_metagame,m_faction_id,"warriorfight");
		m_excute_Limit = 22;
		m_time_internal = 1.0;
        m_airstrike_key= "warrior_yakb_12.7mm";
        if(m_mode == "warrior_fairy_recon_heil_alpha")
        {
            m_excute_Limit = 42;
        }

        if(m_mode == "warrior_fairy_recon_heil_gamma")
        {
            m_airstrike_key = "warrior_yakb_12.7mm_x2";
        }
	}

	Event_call_warrior_fairy_recon_heil(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_timeLeft_internal = m_time_internal;
		if(m_excute_time % 2 == 0)
		{
			int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,50.0f);
			if(luckyGuyid!=-1){
				const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
				if(luckyGuy is null) return;
				Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
				insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,getRandomOffsetVector(m_pos1,8),luckyGuyPos);
			}
		}
		if(m_excute_time == 5)
		{
			lucky_vehicle_id = getNearByEnemyVehicle(m_metagame,m_faction_id,e_pos,50.0f);
			if(lucky_vehicle_id!=-1)
			{
				playSoundAtLocation(m_metagame,"atgm_lockon.wav",m_faction_id,e_pos,7.5);//锁定载具成功
				DelayedVehicleProjectileStrike@ shot = DelayedVehicleProjectileStrike(m_metagame,3.0,m_character_id,m_faction_id,"warrior_9M114",getRandomOffsetVector(m_pos1,8),lucky_vehicle_id);
				TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(shot);
			}
		}
		if(m_excute_time == 10 && m_mode=="warrior_fairy_recon_heil_beta")
        {
            array<soldier_spawn_request@> m_soldier =
            {
                soldier_spawn_request("Task_MG",4),
                soldier_spawn_request("Task_Medic",2),
                soldier_spawn_request("Task_SG",2)
            };
            for(uint i=0;i<m_soldier.length();i++){
				soldier_spawn_request@ foo = m_soldier[i];
				spawnSoldier(m_metagame,foo.m_num,m_faction_id,e_pos,foo.m_type,2,2);
			}
        }
		if(m_excute_time % 3 == 0)
		{
			playSoundAtLocation(m_metagame,"mi24_heli_rotor_idle.wav",m_faction_id,e_pos,1.8);
		}
		m_excute_time++;
	}
}

class DelayedVehicleProjectileStrike :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_character_id;
    protected int m_faction_id;
	protected int m_vehicle_id;
	protected float m_timeLeft;
	protected Vector3 m_pos_1;
	protected string m_airstrike_key;

	DelayedVehicleProjectileStrike(GameMode@ metagame, float time, int cId,int fId, string airstrike_key,Vector3 pos1,int vehicle_id) {
		@m_metagame = metagame;
		m_time = time;
		m_character_id = cId;
		m_faction_id =fId;
		m_pos_1=pos1;
		m_airstrike_key=airstrike_key;
		m_vehicle_id = vehicle_id;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			const XmlElement@ target_info = getVehicleInfo(m_metagame, m_vehicle_id);
			if(target_info is null) return;
			Vector3 target_fin_pos = stringToVector3(target_info.getStringAttribute("position"));//目标位置
			insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos_1,target_fin_pos);
		}
	}

    bool hasEnded() const {
		if (m_timeLeft < 0) {
			return true;
		}
		return false;
	}
}

class Event_call_warrior_fairy_attack_heil : event_call_task_hasMarker {
	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1= e_pos.add(Vector3(10.0*cos(rand(0.0,3.14)),40,10.0*sin(rand(0.0,3.14))));
		sendFactionMessageKey(m_metagame,m_faction_id,"warriorfight");
		m_excute_Limit = 31;
		m_time_internal = 1.0;
	}

	Event_call_warrior_fairy_attack_heil(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_timeLeft_internal = m_time_internal;
		if(m_excute_time % 2 == 0)
		{
			int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,55.0f);
			if(luckyGuyid!=-1){
				const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
				if(luckyGuy is null) return;
				Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
				insertCommonStrike(m_character_id,m_faction_id,"warrior_2a42_30mm",getRandomOffsetVector(m_pos1,8),luckyGuyPos);
			}
		}
		if(m_excute_time % 10 == 0 && m_excute_time!= 0)
		{
			int lucky_vehicle_id = getNearByEnemyVehicle(m_metagame,m_faction_id,e_pos,55.0f);
			if(lucky_vehicle_id!=-1)
			{
				playSoundAtLocation(m_metagame,"atgm_lockon.wav",m_faction_id,e_pos,7.5);//锁定载具成功
				DelayedVehicleProjectileStrike@ shot = DelayedVehicleProjectileStrike(m_metagame,3.0,m_character_id,m_faction_id,"warrior_9M127",getRandomOffsetVector(m_pos1,8),lucky_vehicle_id);
				TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(shot);
			}
			int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,55.0f);
			if(luckyGuyid!=-1){
				const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
				if(luckyGuy is null) return;
				Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
				insertCommonStrike(m_character_id,m_faction_id,"warrior_S13_rocket",getRandomOffsetVector(m_pos1,8),luckyGuyPos);
			}
		}

		if(m_excute_time % 5 == 0)
		{
            int luckyGuyid2 = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,e_pos,55.0f);
			if(luckyGuyid2!=-1){
				const XmlElement@ luckyGuy2 = getCharacterInfo(m_metagame, luckyGuyid2);
				if(luckyGuy2 is null) return;
				Vector3 luckyGuy2Pos = stringToVector3(luckyGuy2.getStringAttribute("position"));
				insertCommonStrike(m_character_id,m_faction_id,"warrior_gsh23mm",getRandomOffsetVector(m_pos1,8),luckyGuy2Pos);
			}
        }

		if(m_excute_time % 6 == 0)
		{
			playSoundAtLocation(m_metagame,"ka52_heli_rotor_idle.wav",m_faction_id,e_pos,1.8);
		}
		m_excute_time++;
	}
}

class Event_call_warrior_fairy_VTOL : event_call_task_hasMarker {
	int lucky_vehicle_id = -1;
	Vector3 m_character_pos;
	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1=e_pos.add(Vector3(0,40,0));
		m_pos2=e_pos;
		sendFactionMessageKey(m_metagame,m_faction_id,"warriorfight");
		m_excute_Limit = 31;
		m_time_internal = 1.0;
	}

	Event_call_warrior_fairy_VTOL(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_timeLeft_internal = m_time_internal;
		if(m_excute_time % 2 == 0 && m_excute_time!=0)
		{
			const XmlElement@ ItsmeInfo = getCharacterInfo(m_metagame, m_character_id);
			if(ItsmeInfo is null)
			{
				m_end = true;
			}
			else{
				if(ItsmeInfo.getIntAttribute("dead")==1) m_end = true;
				m_character_pos = stringToVector3(ItsmeInfo.getStringAttribute("position"));
			}
			int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,m_character_pos,55.0f);
			if(luckyGuyid!=-1){
				const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
				if(luckyGuy is null) return;
				Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
				float strike_rand = 10.0;
				float rand_x = rand(-strike_rand,strike_rand);
				float rand_y = rand(-strike_rand,strike_rand);
				insertCommonStrike(m_character_id,m_faction_id,"warrior_vtol_strafe",m_character_pos.add(Vector3(rand_x,40,rand_y)),luckyGuyPos);
			}
		}
		if(m_excute_time == 0)
		{
			insertCommonStrike(m_character_id,m_faction_id,"warrior_vtol_bomb",m_pos1,m_pos2);
		}
		m_excute_time++;
	}
}

class Event_call_rocket_fairy_rush : event_call_task_hasMarker {
	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		strike_vector = getAimUnitVector(1,s_pos,e_pos);
		strike_vector = getRotatedVector(getIntSymbol()*1.57,strike_vector);
		strike_didis = 7.5;
		m_pos1 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-60,0,-60)));
		m_pos1= m_pos1.add(Vector3(0,40,0));
		m_pos2 = e_pos.add(getMultiplicationVector(strike_vector,Vector3(-15,0,-15)));
		m_excute_Limit = 5;
		m_time_internal = 0.25;
		m_airstrike_key = "rocket_s8ko";
	}

	Event_call_rocket_fairy_rush(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid){
		super(metagame, time, cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = m_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_pos2 = m_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
		m_timeLeft_internal = m_time_internal;
		if(m_excute_time==1)
		{
			CreateDirectProjectile(m_metagame,m_pos1.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))),m_pos2.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",m_character_id,m_faction_id,70);
		}
	}
}

class Event_call_bombardment_fairy_155mm_airburst : event_call_task_hasMarker {


	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1 = e_pos;
		m_pos2 = m_pos1;
		m_pos1=m_pos1.add(Vector3(0,60,0));
		m_excute_Limit = 1;
		m_time_internal = 0.1;
		m_airstrike_key = "cannon_155mm_airburst";
	}

	Event_call_bombardment_fairy_155mm_airburst(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;

		const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character))
		{
			m_end = true;
			return;
		}
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
	}
}

class Event_call_bombardment_fairy_170mm : event_call_task_hasMarker {


	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1 = e_pos;
		m_pos2 = getRandomOffsetVector(e_pos,10.0);
		m_pos1=m_pos1.add(Vector3(0,60,0));
		m_excute_Limit = 1;
		m_time_internal = 0.1;
		m_airstrike_key = "cannon_170mm";
	}

	Event_call_bombardment_fairy_170mm(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;

		const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character))
		{
			m_end = true;
			return;
		}
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
	}
}

//火箭妖精 巡曳飞弹
class Event_call_rocket_fairy_missile : event_call_task_hasMarker {


	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1 = e_pos.add(Vector3(0,20,0));
		m_pos2 = e_pos;
		m_excute_Limit = 3;
		m_time_internal = 1.0;
		m_airstrike_key = "rocket_missile";
	}

	Event_call_rocket_fairy_missile(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		const XmlElement@ character = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character))
		{
			m_end = true;
			return;
		}
		int playerId = character.getIntAttribute("player_id");
		const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
		if (player !is null) {
			if (player.hasAttribute("aim_target")) {
				Vector3 aim_pos = stringToVector3(player.getStringAttribute("aim_target"));
				spawnStaticProjectile(m_metagame,"hd_effect_radar_scan.projectile",aim_pos,m_character_id,m_faction_id);
				if(m_excute_time == 3)
				{
					playSoundAtLocation(m_metagame,"cruise_missile_accel_fromCOD16.wav",m_faction_id,aim_pos,1.8);
					spawnStaticProjectile(m_metagame,"hd_effect_radar_scan.projectile",aim_pos,m_character_id,m_faction_id);
					DelayCommonCallRequest@ shot = DelayCommonCallRequest(m_metagame,1.3,m_character_id,m_faction_id,m_airstrike_key,aim_pos.add(Vector3(0,50,0)),aim_pos);
					TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
					tasker.add(shot);
				}
			}
		}
	}
}

class Event_call_rocket_fairy_strike : event_call_task_hasMarker {
	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1 = e_pos.add(Vector3(0,50,0));
		m_pos2 = e_pos;
		m_excute_Limit = 5;
		m_time_internal = 2.0;
		m_airstrike_key = "rocket_bm30_2round";
	}

	Event_call_rocket_fairy_strike(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = getRandomOffsetVector(e_pos.add(Vector3(0,50,0)),7.5);
	}
}

class Event_call_rocket_fairy_cover : event_call_task_hasMarker {
	void start() {
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		m_pos1 = e_pos.add(Vector3(0,50,0));
		m_pos2 = e_pos;
		m_excute_Limit = 9;
		m_time_internal = 3.0;
		m_airstrike_key = "rocket_bm21_24round";
	}

	Event_call_rocket_fairy_cover(GameMode@ metagame, float time, int cId,int fId,Vector3 characterpos,Vector3 targetpos,string mode,int markerid)
	{
		super(metagame,time,cId,fId,characterpos,targetpos,mode,markerid);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		insertCommonStrike(m_character_id,m_faction_id,m_airstrike_key,m_pos1,m_pos2);
		m_pos1 = getRandomOffsetVector(e_pos.add(Vector3(0,50,0)),4.5 + m_excute_time*1.5);
	}
}

class DelayGPSScanRequest : Task{
	protected GameMode@ m_metagame;
	protected float m_time;
	protected float m_addtime;
    protected int m_character_id;
    protected int m_faction_id;
	protected float m_timeLeft;
	protected string m_scan_mode;
	protected Vector3 m_pos;
	protected float m_radius;
	protected bool m_scanned = false;
	protected array<int> m_markers;
	array<string> GPSScanTargets;

	DelayGPSScanRequest(GameMode@ metagame, float time, float time_duration, int cId, int fId, string scan_mode="_all", Vector3 position = Vector3(0,0,0), float radius = 10000.0){
		@m_metagame = metagame;
		m_time = time;
		m_addtime = time + time_duration;
		m_character_id = cId;
		m_faction_id = fId;
		m_scan_mode = scan_mode;
		m_pos = position;
		m_radius = radius;
		GPSScanTargets = GPSScanTargets_All;
		if(m_scan_mode.findFirst("_vonly")!=-1)	{GPSScanTargets = GPSScanTargets_Vehicle;}
		if(m_scan_mode.findFirst("_bonly")!=-1)	{GPSScanTargets = GPSScanTargets_Building;}
		if(m_scan_mode.findFirst("_sonly")!=-1)	{GPSScanTargets = GPSScanTargets_Support;}
		if(m_scan_mode.findFirst("_aaonly")!=-1)	{GPSScanTargets = GPSScanTargets_AA;}
	}

	void start() {
		// _log("DelayGPSScanRequest start");
		m_timeLeft = m_time;
    }

	void update(float time) {
		// _log("DelayGPSScanRequest update");
		m_timeLeft -= time;
		m_addtime -= time;

		if (m_addtime < 0 && m_timeLeft < 0){
			for (uint i = 0; i < m_markers.length(); ++i){
				//removing the marker
				XmlElement command("command");
					command.setStringAttribute("class", "set_marker");
					command.setIntAttribute("id", m_markers[i]);
					command.setIntAttribute("enabled", 0);
					command.setIntAttribute("faction_id", 0);
				m_metagame.getComms().send(command);
			}
			//clearing the marker list
			m_markers.resize(0);
		}

		if (m_timeLeft < 0 && m_scanned == false){
			bool anyFound = false;

			for (int f = 0; f < m_metagame.getFactionCount(); ++f){
				if(f == m_faction_id) continue;
				//scanning for all vehicles on the list
				for (uint i = 0; i < GPSScanTargets.length(); ++i){
					string vehicleKey = GPSScanTargets[i];
					array<const XmlElement@>@ vehicles = getVehicles(m_metagame, f, vehicleKey);
					for (uint j = 0; j < vehicles.length(); ++j){
						int vehicleId = vehicles[j].getIntAttribute("id");
						const XmlElement@ vehicle = getVehicleInfo(m_metagame,vehicleId);

						if (vehicle is null) continue;

						float health = vehicle.getFloatAttribute("health");
						if (health <= 0.0) continue;

						int markerId = vehicles[j].getIntAttribute("id") + 7000;
						string position = vehicles[j].getStringAttribute("position");
						string vehicleName = vehicle.getStringAttribute("name");

						// 限制扫描距离
						if(m_scan_mode.findFirst("_poslimited") != -1){
							if(getAimUnitDistance(1.0,m_pos,stringToVector3(position)) > m_radius) continue;
						}

						// 扫描不显示名称
						if(m_scan_mode.findFirst("_nameinvisible") != -1){
							vehicleName = "";
						}
						//set_spotting(m_metagame,vehicleId,0);
						//collecting marker ids for removal later
						m_markers.insertLast(markerId);
						int atlas_index = 0;
						string atlas_color = "#00b9ff";
						float atlas_size = 0.6;
						if(GPSScanTargets_Vehicle.find(vehicleKey) != -1) 	{atlas_index = 0; atlas_color = "#00b9ff";}
						if(GPSScanTargets_Building.find(vehicleKey) != -1) {atlas_index = 0; atlas_color = "#ff0000";}
						if(GPSScanTargets_Support.find(vehicleKey) != -1) 	{atlas_index = 7; atlas_color = "#ccccff";}
						if(GPSScanTargets_AA.find(vehicleKey) != -1) 		{atlas_index = 14; atlas_color = "#00b9ff"; atlas_size = 1.0;}

						//placing the marker
						XmlElement command("command");
							command.setStringAttribute("class", "set_marker");
							command.setIntAttribute("id", markerId);
							command.setIntAttribute("faction_id", 0);
							command.setIntAttribute("atlas_index", atlas_index);
							command.setFloatAttribute("size", atlas_size);
							command.setFloatAttribute("range", 0.0);
							command.setIntAttribute("enabled", 1);
							command.setStringAttribute("position", position);
							command.setStringAttribute("text", vehicleName);
							command.setStringAttribute("color", atlas_color);
							command.setBoolAttribute("show_in_map_view", true);
							command.setBoolAttribute("show_in_game_view", false);
							command.setBoolAttribute("show_at_screen_edge", false);

						m_metagame.getComms().send(command);

						if (!anyFound) {
							anyFound = true;
						}
					}
				}
			}

			if (!anyFound) {
				sendFactionMessageKey(m_metagame, 0, "gps_laptop, targets not ok", dictionary = {}, 1.0);
			}
			m_scanned = true;
		}
	}

    bool hasEnded() const {
		if (m_addtime < 0) {
			return true;
		}
		return false;
	}
}

class Tac50_Maple_Sniper_Drone : DelaySkill {
	protected array<const XmlElement@> affectedCharacter;
	protected int m_tickCount;
	protected int m_tickLimit;

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		this.setExcuteLimit(10);
		this.setInternal(3.0);
		m_tickCount = 0;
		m_tickLimit = 20;
	}

	Tac50_Maple_Sniper_Drone(GameMode@ metagame, float time, int cId,int fId){
		super(metagame, time,cId,fId);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		if (m_tickCount >= m_tickLimit){m_end = true;return;}
		m_timeLeft_internal = m_time_internal;
		m_tickCount++;

		const XmlElement@ character_tac50 = getCharacterInfo(m_metagame, m_character_id);
		if (checkCharacterDead(character_tac50))
		{
			m_end = true;
			return;
		}
		Vector3 tac50_pos = stringToVector3(character_tac50.getStringAttribute("position"));
		Vector3 maple_pos = tac50_pos.add(Vector3(0,40,0));

		affectedCharacter.resize(0);

		int m_fnum = m_metagame.getFactionCount();
		for(int i=0;i<m_fnum;i++) {
			if(i!=m_faction_id) {
				array<const XmlElement@> affectedCharacter2;
				affectedCharacter2 = getCharactersNearPosition(m_metagame,tac50_pos,i,30.0f);
				if (affectedCharacter2 !is null){
					for(uint x=0;x<affectedCharacter2.length();x++){
						affectedCharacter.insertLast(affectedCharacter2[x]);
					}
				}
			}
		}

		if(affectedCharacter.length() <= 0){
			return;
		}

		bool findTarget = false;
		int maxAttempts = 10; // 限制最大尝试次数，防止死循环
		int attempts = 0;
		const XmlElement@ luckyGuy;

		while (!findTarget && affectedCharacter.length() > 0 && attempts < maxAttempts) {
			attempts++;

			// 随机选取目标索引
			int luckyone_index = getRandomIndex(affectedCharacter.length());

			// 获取随机目标信息
			int luckyoneid = affectedCharacter[luckyone_index].getIntAttribute("id");
			@luckyGuy = getCharacterInfo(m_metagame, luckyoneid);

			// 检查目标是否有效且未死亡
			if (luckyGuy !is null && !checkCharacterDead(luckyGuy)) {
				findTarget = true;
			} else {
				// 移除无效或死亡目标，继续寻找
				affectedCharacter.removeAt(luckyone_index);
				if (affectedCharacter.length() == 0) break;
			}
		}

		// 如果找到目标，执行攻击逻辑
		if (findTarget && luckyGuy !is null) {
			Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
			CreateDirectProjectile(m_metagame, maple_pos, luckyGuyPos, "m200_snipe.projectile", m_character_id, m_faction_id, 400);
			playSoundAtLocation(m_metagame, "tac50_fire_FromINS.wav", m_faction_id, luckyGuyPos, 2.0);
			_log("枫月无人机开火，现在是第"+m_excute_time);
			m_excute_time++;
		}
	}
}

class Skill_AEK999 : DelaySkill {
	float m_ori4;
	Skill_AEK999(GameMode@ metagame, float time, int cId,int fId,Vector3 pos,float ori4){
		super(metagame,time,cId,fId);
		t_pos = pos;
		m_ori4 = ori4;
	}

	void start(){
		m_timeLeft=m_time;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		spawnVehicle(m_metagame,1,m_faction_id,t_pos.add(Vector3(0,30,0)),Orientation(0,1,0,m_ori4),"aek999.vehicle");
		healCharacter(m_metagame,m_character_id,30);
		m_end = true;
	}
}

class Airdrop_Support_Negev : DelaySkill {

	Airdrop_Support_Negev(GameMode@ metagame, float time, int cId,int fId,Vector3 pos){
		super(metagame,time,cId,fId);
		t_pos = pos;
	}

	void start(){
		m_timeLeft=m_time;
		m_timeLeft_internal = 0;
		this.setExcuteLimit(4);
		this.setInternal(1.0);
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time;return;}
		if (m_timeLeft_internal >= 0){m_timeLeft_internal -= time;return;}
		if (m_excute_time >= m_excute_Limit){m_end = true;return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,m_faction_id,t_pos,20.0f);
		if(luckyGuyid!=-1){
			const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuy is null) return;
			Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
			Vector3 startPos = t_pos.add(Vector3(0,60,0));

			float strike_rand=2.0;
			for(int j=1;j<=5;j++)
			{
				float rand_x = rand(-strike_rand,strike_rand);
				float rand_y = rand(-strike_rand,strike_rand);
				float offset = rand(-0.2,0.2);
				CreateDirectProjectile(m_metagame,startPos,luckyGuyPos.add(Vector3(rand_x,0,rand_y)),"fairy_airstrike_heavymg.projectile",m_character_id,m_faction_id,150);
				CreateDirectProjectile(m_metagame,startPos,luckyGuyPos.add(Vector3(rand_x+offset,0,rand_y+offset)),"fairy_airstrike_heavymg.projectile",m_character_id,m_faction_id,150);
			}
			playSoundAtLocation(m_metagame,"yakb_shot_fromWarthunder.wav",m_faction_id,luckyGuyPos,2.2);
		}
	}
    bool hasEnded() const {
		if (m_end) {
			return true;
		}
		return false;
	}
}

class DelayNuke :Task{
	protected GameMode@ m_metagame;
	protected float m_time;
    protected int m_faction_id;
	protected float m_timeLeft;

	DelayNuke(GameMode@ metagame, float time, int fId) {
		@m_metagame = metagame;
		m_time = time;
		m_faction_id =fId;
	}

	void start() {
		m_timeLeft=m_time;
	}

	void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
            sendFactionMessageKey(m_metagame,m_faction_id,"Nuke End Message");
            m_metagame.getComms().send("<command class='set_match_status' win='1' faction_id='0' />");
            for (uint i = 1; i < m_metagame.getFactionCount(); ++i) {
                m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='" + i + "' />");
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

class DelayNytoBlackSkillTask : Task {
    protected GameMode@ m_metagame;
    protected float m_time;
    protected float m_addtime;
    protected float m_timeLeft;
    protected int m_character_id;
    protected int m_faction_id;
    protected Vector3 m_pos_1;
    protected Vector3 m_pos_2;
    protected array<int> m_targets;
    protected bool m_shoot = false;
    protected string m_bullet_key = "snipe_bullet_blacknyto.projectile";//效果不是很好 not use
    protected string m_strike_key = "snipe_nytoblack.projectile";
    protected string m_sound_key = "skill_blacknyto_fire.wav";
    protected float m_sound_volume = 1.0;

    DelayNytoBlackSkillTask(GameMode@ metagame, float time, int cid, int fid, Vector3 pos1, Vector3 aimPos, array<int>@ targets) {
        @m_metagame = metagame;
        m_time = time;
        m_addtime = time + 0.05f;
        m_character_id = cid;
        m_faction_id = fid;
        m_pos_1 = pos1;
        m_pos_2 = aimPos;
        m_targets = targets;
    }

    void start() {
        m_timeLeft = m_time;
    }

    void update(float time) {
        m_timeLeft -= time;
        m_addtime -= time;

        if (m_timeLeft < 0 && m_shoot == false) {
            float dis = getFlatPositionDistance(m_pos_1, m_pos_2);
            // CreateDirectProjectile(m_metagame, m_pos_1, m_pos_2, m_bullet_key, m_character_id, m_faction_id, float(max(dis/0.05,40.0)));
            playSoundAtLocation(m_metagame, m_sound_key, m_faction_id, m_pos_1, m_sound_volume);
            m_shoot = true;
        }

        if (m_addtime < 0 && m_timeLeft < 0) {
            int totalShots = 6;
            int shotCount = 0;
            int targetCount = m_targets.length();
            if (targetCount <= 0) {
                return;
            }

            int index = 0;
            int tryCount = 0;
            int maxTry = totalShots * 2;
            while (shotCount < totalShots && tryCount < maxTry) {
                int idx = index % targetCount;
                int target_id = m_targets[idx];
                const XmlElement@ targetinfo = getCharacterInfo(m_metagame, target_id);
                if (targetinfo !is null) {
                    Vector3 t_pos = stringToVector3(targetinfo.getStringAttribute("position"));
                    CreateDirectProjectile(m_metagame, t_pos.add(Vector3(0,10,0)), t_pos, m_strike_key, m_character_id, m_faction_id, 300);
                    shotCount++;
                }
                index++;
                tryCount++;
            }
        }
    }

    bool hasEnded() const {
        return m_addtime < 0;
    }
}

// 摇人妖精 机枪压制+空投 Task（原 event_system case 4 "mg_strafe"）
array<int> YaorenParatrooperHeight = {
    50,50,50,50,35,20,20,20,35,50,50,50,50
};

class Event_call_yaoren_fairy : event_call_task_hasMarker {

    Event_call_yaoren_fairy(GameMode@ metagame, float time, int cId, int fId, Vector3 characterpos, Vector3 targetpos, string mode, int markerid) {
        super(metagame, time, cId, fId, characterpos, targetpos, mode, markerid);
    }

    void start() {
        m_timeLeft = m_time;
        m_timeLeft_internal = 0;
        m_excute_Limit = 10;
        m_time_internal = 1.0;
    }

    void update(float time) {
        if(m_timeLeft >= 0) { m_timeLeft -= time; return; }
        if(m_timeLeft_internal >= 0) { m_timeLeft_internal -= time; return; }
        if(m_excute_time >= m_excute_Limit) { m_end = true; return; }

        //索敌并发射机枪弹头
        int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame, m_faction_id, e_pos, 30.0f);
        if(luckyGuyid != -1) {
            const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
            if(luckyGuy !is null) {
                Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
                int heightIndex = m_excute_time + 1;
                if(heightIndex >= int(YaorenParatrooperHeight.length())) {
                    heightIndex = int(YaorenParatrooperHeight.length()) - 1;
                }
                insertCommonStrike(m_character_id, m_faction_id, 12,
                    e_pos.add(Vector3(0.0, float(YaorenParatrooperHeight[heightIndex]), 0.0)),
                    luckyGuyPos);
            }
        }

        //phase 3（m_excute_time==2，从0开始计数）：生成鱼鹰+延迟空投士兵
        if(m_excute_time == 2) {
            string c =
                "<command class='create_instance'" +
                " faction_id='" + m_faction_id + "'" +
                " instance_class='vehicle'" +
                " instance_key='osprey_enter' " +
                " character_id='" + m_character_id + "'" +
                " position='" + (e_pos.add(Vector3(0, 50, 0))).toString() + "' />";
            m_metagame.getComms().send(c);
            TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
            array<soldier_spawn_request@> spawn_soldier = {
                soldier_spawn_request("Task_MG", 5),
                soldier_spawn_request("Task_SG", 3)
            };
            tasker.add(DelaySpawnSoldier(m_metagame, 6.0, m_faction_id, spawn_soldier, e_pos, 3.0, 3.0));
        }

        m_excute_time++;
        m_timeLeft_internal = m_time_internal;
    }
}

// AC130 全局唯一性标志，同一时刻只能存在一架AC130
bool g_ac130_active = false;

// 暴怒妖精 AC130 炮艇 Task（原 event_system case 2 "rampage_fairy_ac130"）
class Event_call_rampage_fairy_ac130 : event_call_task_hasMarker {

	// --- 武器充能系统 ---
	protected int m_rocket_ready;
	protected int m_rocket_ammo;
	protected int m_shotgun_ready;
	protected int m_shotgun_ammo;
	protected int m_minigun_ready;
	protected int m_minigun_ammo;

	// 武器常量
	protected int COOLDOWN_ROCKET = 5;
	protected int COOLDOWN_MINIGUN = 0;
	protected int COOLDOWN_SHOTGUN = 3;
	protected int AMMO_ROCKET = 1;
	protected int AMMO_MINIGUN = 1;
	protected int AMMO_SHOTGUN = 2;

	// --- 音效控制 ---
	protected int m_voice_interval;
	protected int m_flyby_interval;

	// --- 索敌 ---
	protected Vector3 m_pre_pos;

	// --- 语音包 ---
	protected int m_voicekey;
    array<array<string>> m_startVoice= {
        {},
        {
            "ac130entrance_rus1.wav",
            "ac130entrance_rus2.wav",
            "ac130entrance_rus3.wav"
        },
        {
            "ac130entrance_blkops1.wav",
            "ac130entrance_blkops2.wav",
            "ac130entrance_blkops3.wav"
        },
        {
            "ac130entrance_nato1.wav",
            "ac130entrance_nato2.wav",
            "ac130entrance_nato3.wav"
        }
    };
    array<array<string>> m_endVoice= {
        {},
        {
            "ac130exit_rus1.wav",
            "ac130exit_rus2.wav",
            "ac130exit_rus3.wav"
        },
        {
            "ac130exit_blkops1.wav",
            "ac130exit_blkops2.wav",
            "ac130exit_blkops3.wav"
        },
        {
            "ac130exit_nato1.wav",
            "ac130exit_nato2.wav",
            "ac130exit_nato3.wav"
        }
    };
    array<array<string>> m_noTargetVoice= {
        {},
        {
            "ac130search_rus1.wav",
            "ac130search_rus2.wav"
        },
        {
            "ac130search_blkops1.wav",
            "ac130search_blkops2.wav",
            "ac130search_blkops3.wav",
            "ac130search_blkops4.wav"
        },
        {
            "ac130search_nato1.wav",
            "ac130search_nato2.wav",
            "ac130search_nato3.wav",
            "ac130search_nato4.wav",
            "ac130search_nato5.wav",
            "ac130search_nato6.wav",
            "ac130search_nato7.wav",
            "ac130search_nato8.wav",
            "ac130search_nato9.wav"
        }
    };
    array<array<string>> m_minigunVoice= {
        {},
        {
            "ac130mg_rus1.wav",
            "ac130mg_rus2.wav",
            "ac130allguns_rus1.wav",
            "ac130allguns_rus2.wav",
            "ac130allguns_rus3.wav"
        },
        {
            "ac130mg_blkops1.wav",
            "ac130mg_blkops2.wav"
        },
        {
            "ac130mg_nato1.wav",
            "ac130mg_nato2.wav",
            "ac130mg_nato3.wav",
            "ac130mg_nato4.wav"
        }
    };
    array<array<string>> m_shotgunVoice= {
        {},
        {
            "ac130sg_rus1.wav",
            "ac130sg_rus2.wav",
            "ac130allguns_rus1.wav",
            "ac130allguns_rus2.wav",
            "ac130allguns_rus3.wav"
        },
        {
            "ac130sg_blkops1.wav",
            "ac130sg_blkops2.wav",
            "ac130sg_blkops3.wav"
        },
        {
            "ac130sg_nato1.wav",
            "ac130sg_nato2.wav",
            "ac130sg_nato3.wav"
        }
    };
    array<array<string>> m_m202Voice= {
        {},
        {
            "ac130rpg_rus1.wav",
            "ac130rpg_rus2.wav",
            "ac130rpg_rus3.wav",
            "ac130allguns_rus1.wav",
            "ac130allguns_rus2.wav",
            "ac130allguns_rus3.wav"
        },
        {
            "ac130rpg_blkops1.wav",
            "ac130rpg_blkops2.wav",
            "ac130rpg_blkops3.wav"
        },
        {
            "ac130rpg_nato1.wav",
            "ac130rpg_nato2.wav",
            "ac130rpg_nato3.wav",
            "ac130rpg_nato4.wav",
            "ac130rpg_nato5.wav"
        }
    };

	// --- 载具避让列表 ---
	array<string> m_avoid_vehicles = {"armored_truck.vehicle","radar_tower.vehicle"};

	// --- 环形飞行随机种子 ---
	protected float m_randseed;

	// --- 构造函数 ---
	// voicekey: 语音包索引 1=俄语 2=黑色行动 3=北约
	Event_call_rampage_fairy_ac130(GameMode@ metagame, float time, int cId, int fId,
		Vector3 characterpos, Vector3 targetpos, int voicekey, int markerid)
	{
		super(metagame, time, cId, fId, characterpos, targetpos, "", markerid);
		m_voicekey = voicekey;
		if(m_voicekey < 1 || m_voicekey > 3) m_voicekey = 1;
	}

	void start() {
		g_ac130_active = true;

		// 基础时间控制
		m_timeLeft = m_time;          // 初始延迟（调用方传入，约1.0s）
		m_time_internal = 1.8;        // 基础射击间隔
		m_timeLeft_internal = 0;
		m_excute_Limit = 50;          // 总phase数

		// 随机种子
		m_randseed = rand(0.0, 3.14);

		// 武器初始化
		m_rocket_ready = COOLDOWN_ROCKET;
		m_rocket_ammo = AMMO_ROCKET;
		m_shotgun_ready = COOLDOWN_SHOTGUN;
		m_shotgun_ammo = AMMO_SHOTGUN;
		m_minigun_ready = COOLDOWN_MINIGUN;
		m_minigun_ammo = AMMO_MINIGUN;

		// 索敌状态
		m_pre_pos = e_pos;

		// 音效控制
		m_voice_interval = 0;
		m_flyby_interval = 0;

	}

	void update(float time) {
		// 标准延迟门控
		if(m_timeLeft >= 0) { m_timeLeft -= time; return; }
		if(m_timeLeft_internal >= 0) { m_timeLeft_internal -= time; return; }
		if(m_excute_time >= m_excute_Limit) { m_end = true; return; }

		m_excute_time++;

		// 递减音效间隔计数器
		if(m_voice_interval > 0) m_voice_interval -= 1;
		if(m_excute_time >= (m_excute_Limit - 2)) m_voice_interval = 99;
		if(m_flyby_interval > 0) m_flyby_interval -= 1;

		// ---- Phase 1: 进场 ----
		if(m_excute_time <= 1) {
			playSoundAtLocation(m_metagame, "ac130_flyby.wav", m_faction_id, e_pos, 2.5);
			playRandomSoundArray(m_metagame, m_startVoice[m_voicekey], m_faction_id, e_pos.toString(), 4.0);
			m_voice_interval = 2;
			m_flyby_interval = 3;
			m_pre_pos = e_pos;
			sendFactionMessageKey(m_metagame, m_faction_id, "ac130fight");

			// 重置武器状态（与原代码一致，phase 1 初始化）
			m_rocket_ready = COOLDOWN_ROCKET;
			m_rocket_ammo = AMMO_ROCKET;
			m_shotgun_ready = COOLDOWN_SHOTGUN;
			m_shotgun_ammo = AMMO_SHOTGUN;
			m_minigun_ready = COOLDOWN_MINIGUN;
			m_minigun_ammo = AMMO_MINIGUN;

			m_timeLeft_internal = m_time_internal;
			return;
		}

		// ---- 飞行音效循环 ----
		int voice_last_time = 30;
		int voice_phase_interval = int(voice_last_time / m_time_internal);
		if((m_flyby_interval == 0) && ((m_excute_Limit - m_excute_time) > (voice_phase_interval - 4))) {
			_log("current phase: " + m_excute_time);
			m_flyby_interval = 6;
			playSoundAtLocation(m_metagame, "ac130_flyby.wav", m_faction_id, e_pos, 2.5);
		}

		// ---- 充能恢复 ----
		if(m_rocket_ready <= 0 && m_rocket_ammo < AMMO_ROCKET)     { m_rocket_ammo += 1; m_rocket_ready = COOLDOWN_ROCKET; }
		if(m_shotgun_ready <= 0 && m_shotgun_ammo < AMMO_SHOTGUN)  { m_shotgun_ammo += 1; m_shotgun_ready = COOLDOWN_SHOTGUN; }
		if(m_minigun_ready <= 0 && m_minigun_ammo < AMMO_MINIGUN)  { m_minigun_ammo += 1; m_minigun_ready = COOLDOWN_MINIGUN; }

		// ---- 武器初步选择 ----
		int attacknum;
		if(m_rocket_ammo > 0)         attacknum = 7; // 火箭
		else if(m_shotgun_ammo > 0)   attacknum = 5; // 霰弹
		else                          attacknum = 6; // 机炮

		// ---- 索敌 ----
		int luckyGuyid;
		float searchrange_nearby = 15.0f;
		float searchrange_origin = 60.0f;
		float searchrange_avoid_vehicle = 20.0f;
		bool need_reselect = false;

		// 临近索敌
		luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame, m_faction_id, m_pre_pos, searchrange_nearby);

		if(luckyGuyid == -1) { // 没索敌到
			need_reselect = true;
		}
		else {
			const XmlElement@ testcharacterInfo = getCharacterInfo(m_metagame, luckyGuyid);
			if(testcharacterInfo is null) { // 敌人不存在
				need_reselect = true;
			}
			else {
				Vector3 ac130_jud_pos = stringToVector3(testcharacterInfo.getStringAttribute("position"));
				if(getAimUnitDistance(1.0, ac130_jud_pos, e_pos) > (searchrange_origin + 9.0f)) { // 超出预期范围
					need_reselect = true;
				}
				else if(attacknum != 6) { // 不为机炮时再检查是否需要避让载具
					array<const XmlElement@>@ vehicles = getAllVehicles(m_metagame, 0);
					for(uint i = 0; i < vehicles.length(); i++) {
						Vector3 vpos = stringToVector3(vehicles[i].getStringAttribute("position"));
						if(getAimUnitDistance(1.0, ac130_jud_pos, vpos) > searchrange_avoid_vehicle)
							continue;
						const XmlElement@ vinfo = getVehicleInfo(m_metagame, vehicles[i].getIntAttribute("id"));
						if(vinfo is null) continue;
						string key = vinfo.getStringAttribute("key");
						if(m_avoid_vehicles.find(key) > -1) { // 目标在重要载具附近
							need_reselect = true;
							break;
						}
					}
				}
			}
		}
		// 随机索敌 fallback
		if(need_reselect) {
			m_pre_pos = e_pos;
			luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame, m_faction_id, m_pre_pos, searchrange_origin);
		}

		if(luckyGuyid != -1) {
			const XmlElement@ luckyGuyInfo = getCharacterInfo(m_metagame, luckyGuyid);
			if(luckyGuyInfo is null) {
				m_timeLeft_internal = m_time_internal;
				return;
			}

			float rand_angle = m_randseed + m_excute_time * 3.14 / 10;
			Vector3 luckyGuyPos = stringToVector3(luckyGuyInfo.getStringAttribute("position"));
			Vector3 aimPos = e_pos.add(Vector3(45.0 * cos(rand_angle), 60, 45.0 * sin(rand_angle)));
			m_pre_pos = luckyGuyPos;

			// 重新索敌后二次检查载具避让
			bool force_minigun = false;
			if(attacknum != 6 && need_reselect) {
				array<const XmlElement@>@ vehicles = getAllVehicles(m_metagame, 0);
				for(uint i = 0; i < vehicles.length(); i++) {
					Vector3 vpos = stringToVector3(vehicles[i].getStringAttribute("position"));
					if(getAimUnitDistance(1.0, luckyGuyPos, vpos) > searchrange_avoid_vehicle)
						continue;
					const XmlElement@ vinfo = getVehicleInfo(m_metagame, vehicles[i].getIntAttribute("id"));
					if(vinfo is null) continue;
					string key = vinfo.getStringAttribute("key");
					if(m_avoid_vehicles.find(key) > -1) {
						force_minigun = true;
						break;
					}
				}
			}
			if(force_minigun) attacknum = 6;

			// 最终武器决策：扣弹药 + 冷却递减
			if(attacknum == 7)       m_rocket_ammo--;
			else if(attacknum == 5)  m_shotgun_ammo--;
			else                     m_minigun_ammo--;
			m_rocket_ready -= 1;
			m_shotgun_ready -= 1;
			m_minigun_ready -= 0;

			// 发射音效与下一次发射间隔设定
			switch(attacknum) {
				case 5: {
					playSoundAtLocation(m_metagame, "ac130sg_fire_FromWARTHUNDER.wav", m_faction_id, e_pos, 3);
					m_timeLeft_internal = 1.0;
					break;
				}
				case 6: {
					playSoundAtLocation(m_metagame, "ac130mg_fire_FromSAM4.wav", m_faction_id, e_pos, 3.1);
					m_timeLeft_internal = 0.25;
					break;
				}
				case 7: {
					playSoundAtLocation(m_metagame, "ac130rpg_fire_FromCOD16.wav", m_faction_id, e_pos, 2.4);
					m_timeLeft_internal = 1.5;
					break;
				}
				default:
					m_timeLeft_internal = m_time_internal;
					break;
			}

			// 发射弹头（通过 GFLairstrike 的 case 5/6/7）
			insertCommonStrike(m_character_id, m_faction_id, attacknum, aimPos, luckyGuyPos);

			// 语音播报
			if(m_voice_interval <= 0) {
				switch(attacknum) {
					case 5: {
						playRandomSoundArray(m_metagame, m_shotgunVoice[m_voicekey], m_faction_id, e_pos.toString(), 3.2);
						m_voice_interval = 3;
						break;
					}
					case 6: {
						playRandomSoundArray(m_metagame, m_minigunVoice[m_voicekey], m_faction_id, e_pos.toString(), 3.2);
						m_voice_interval = 8;
						break;
					}
					case 7: {
						playRandomSoundArray(m_metagame, m_m202Voice[m_voicekey], m_faction_id, e_pos.toString(), 3.2);
						m_voice_interval = 2;
						break;
					}
					default: break;
				}
			}
		}
		else if(m_voice_interval <= 0) {
			// 无目标时播放搜索语音
			m_voice_interval = 2;
			playRandomSoundArray(m_metagame, m_noTargetVoice[m_voicekey], m_faction_id, e_pos.toString(), 3.5);
			m_timeLeft_internal = m_time_internal; // 无目标时用默认间隔
		}
		else {
			m_timeLeft_internal = m_time_internal; // 无目标且语音冷却中，用默认间隔
		}

		// ---- 结束判定 ----
		if(m_excute_time >= m_excute_Limit) {
			playRandomSoundArray(m_metagame, m_endVoice[m_voicekey], m_faction_id, e_pos.toString(), 3.5);
			m_end = true;
		}
	}

	bool hasEnded() const {
		if(m_end) {
			// 清除全局唯一性标志
			g_ac130_active = false;
			// 基类处理 marker 清理
			if(m_markerId != 0) {
				removeMarkerwithId(m_metagame, m_faction_id, m_markerId);
			}
			return true;
		}
		return false;
	}
}

// 干扰者刷兵（原 event_system case 11）
class Skill_SF_Intruder_Spawn : event_call_task {

	Skill_SF_Intruder_Spawn(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="")
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode);
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 2.0;
		m_excute_Limit = 3;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		spawnSoldier(m_metagame, 6, m_faction_id, e_pos, "sf_dinergate", 4, 4);
	}
}

// 闪电风暴（原 event_system case 9）
class Skill_Lightning_Storm : event_call_task {

	Skill_Lightning_Storm(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="")
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode);
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 5.0;
		m_excute_Limit = 12;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		Vector3 lightning_pos = e_pos.add(Vector3(0, 20, 0));
		CreateDirectProjectile(m_metagame, lightning_pos, lightning_pos, "weather_lightning_storm_1.projectile", m_character_id, m_faction_id, 0);
	}
}

// HK416 奶包（原 event_system case 10）
class Skill_HK416_Heal : event_call_task {

	Skill_HK416_Heal(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="")
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode);
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 2.0;
		m_excute_Limit = 11;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		CreateDirectProjectile(m_metagame, e_pos, e_pos.add(Vector3(0, 1, 0)), "medical_agl_call.projectile", m_character_id, m_faction_id, 10);
		healRangedCharacters(m_metagame, e_pos, m_faction_id, 8.4, 3);
	}
}

// UMP45MOD3 烟雾（原 event_system case 5）
class Skill_UMP45MOD3_Smoke : event_call_task {

	Skill_UMP45MOD3_Smoke(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="")
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode);
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 3.0;
		m_excute_Limit = 6;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;
		CreateDirectProjectile(m_metagame, e_pos.add(Vector3(0, 6, 0)), e_pos.add(Vector3(0, 6.1, 0)), "ump45mod3_skill.projectile", m_character_id, m_faction_id, 10);
	}
}

// 炮击妖精 105mm（原 event_system case 7）
// specialkey 1: phase 7 用 case 15（高爆）
// specialkey 2: phase 7 用 case 126（大高爆）
class Event_call_bomb_fairy : event_call_task_hasMarker {
	protected int m_specialkey;

	Event_call_bomb_fairy(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="", int markerid=0, int specialkey=1)
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode, markerid);
		m_specialkey = specialkey;
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 1.0;
		m_excute_Limit = 7;
		m_pos1 = e_pos.add(Vector3(0, 40, 0));
		m_pos2 = e_pos;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		// 首次执行发送阵营消息
		if(m_excute_time == 1)
		{
			sendFactionMessageKey(m_metagame, m_faction_id, "bombfight");
		}

		if(m_excute_time != 7)
		{
			// phase 1-6: 105mm炮击
			insertCommonStrike(m_character_id, m_faction_id, 14, m_pos1, m_pos2);
		}
		else
		{
			// phase 7: 最后一发高爆
			if(m_specialkey == 1)
			{
				insertCommonStrike(m_character_id, m_faction_id, 15, m_pos1, m_pos2);
			}
			else
			{
				insertCommonStrike(m_character_id, m_faction_id, 126, m_pos1, m_pos2);
			}
		}

		// phase 6（m_excute_time==6）后间隔改为 2s
		if(m_excute_time == 6)
		{
			m_timeLeft_internal = 2.0;
		}
	}
}

// 勇士妖精 Apache（原 event_system case 5）
// 环形飞行 + 机枪扫射 + 标枪导弹 + 诱饵箭矢
class Event_call_warrior_fairy_apache : event_call_task_hasMarker {
	protected float m_randseed;
	protected int m_javelin_vehicle_id;

	Event_call_warrior_fairy_apache(GameMode@ metagame, float time, int cId, int fId, Vector3 start_pos, Vector3 target_pos, string mode="", int markerid=0)
	{
		super(metagame, time, cId, fId, start_pos, target_pos, mode, markerid);
		m_randseed = rand(0.0, 3.14);
		m_javelin_vehicle_id = -1;
	}

	void start() {
		m_timeLeft = m_time;
		m_timeLeft_internal = 0;
		m_time_internal = 0.5;
		m_excute_Limit = 12;
	}

	void update(float time) {
		if(m_timeLeft >= 0){m_timeLeft -= time; return;}
		if(m_timeLeft_internal >= 0){m_timeLeft_internal -= time; return;}
		if(m_excute_time >= m_excute_Limit){m_end = true; return;}
		m_excute_time++;
		m_timeLeft_internal = m_time_internal;

		// 环形飞行位置（固定偏移）
		Vector3 aimPos = e_pos.add(Vector3(10.0 * cos(m_randseed), 40, 10.0 * sin(m_randseed)));

		// phase 12: 诱饵箭矢（原代码 bug 修复，原来不会执行到这里）
		if(m_excute_time == 12)
		{
			insertCommonStrike(m_character_id, m_faction_id, "apache_bait", aimPos, e_pos);
		}

		// phase 1: 发消息 + 锁定载具
		if(m_excute_time == 1)
		{
			sendFactionMessageKey(m_metagame, m_faction_id, "warriorfight");
			m_javelin_vehicle_id = getNearByEnemyVehicle(m_metagame, m_faction_id, e_pos, 20);
			if(m_javelin_vehicle_id != -1)
			{
				playSoundAtLocation(m_metagame, "javelin_locked.wav", m_faction_id, e_pos, 1.0);
			}
			else
			{
				playSoundAtLocation(m_metagame, "javelin_lock_fail.wav", m_faction_id, e_pos, 1.0);
			}
		}

		// phase 6: 播放扫射音效
		if(m_excute_time == 6)
		{
			playSoundAtLocation(m_metagame, "30mm_strafe.wav", m_faction_id, e_pos, 1.0);
		}

		// phase 6-11: 机枪扫射
		if(m_excute_time >= 6 && m_excute_time <= 11)
		{
			int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame, m_faction_id, e_pos, 30.0f);
			if(luckyGuyid != -1)
			{
				const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
				Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
				DelayCommonCallRequest@ shot = DelayCommonCallRequest(m_metagame, 0.05, m_character_id, m_faction_id, "apache_mg", aimPos, luckyGuyPos);
				TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(shot);
				tasker.add(shot);
				tasker.add(shot);
				tasker.add(shot);
			}
		}

		// phase 8: 标枪导弹
		if(m_excute_time == 8)
		{
			if(m_javelin_vehicle_id != -1)
			{
				int target_id = m_javelin_vehicle_id;
				Vector3 target_fin_pos;
				const XmlElement@ target_info = getVehicleInfo(m_metagame, target_id);
				if(target_info !is null)
				{
					target_fin_pos = stringToVector3(target_info.getStringAttribute("position"));
				}
				else
				{
					target_fin_pos = e_pos;
				}
				insertCommonStrike(m_character_id, m_faction_id, "apache_javelin", aimPos, target_fin_pos);
			}
			else
			{
				// 未锁定载具时，向目标点发射
				insertCommonStrike(m_character_id, m_faction_id, "apache_javelin", aimPos, e_pos);
			}
		}
	}
}

// M14MOD3 火力专注 Task
// 负责：管理技能持续时间，到期后计算冷却并清理状态
class M14SkillActiveTask : Task {
    protected GameMode@ m_metagame;
    protected float m_timeLeft;
    int m_characterId;
    int m_playerId;
    int m_factionId;
    SkillModifer@ m_modifer;

    // 技能状态（kill_event 通过引用直接修改 m_ammo）
    int m_ammo = 8;
    bool m_ended = false;

    M14SkillActiveTask(GameMode@ metagame, float duration, 
                       int cId, int pId, int fId, 
                       SkillModifer@ mod) {
        @m_metagame = metagame;
        m_timeLeft = duration;
        m_characterId = cId;
        m_playerId = pId;
        m_factionId = fId;
        @m_modifer = @mod;
    }

    void start() {
        // 技能激活提示
        notify(m_metagame, "Skill - M14 Activate", dictionary(), 
               "misc", m_playerId, false, "", 1.0);
    }

    void update(float time) {
        m_timeLeft -= time;
        // 弹药耗尽由 kill_event 设置 m_ended = true
    }

    bool hasEnded() const {
        return m_ended || m_timeLeft < 0.0;
    }

    // 由 kill_event 在连锁弹命中时调用
    void consumeAmmo() {
        m_ammo--;
        if (m_ammo <= 0) {
            m_ended = true;
        }
    }

    // 返回技能结束时应设置的冷却时间
    float getCooldownTime() {
		if (m_ammo <= 0) {
			// 8发全部用完，奖励缩短冷却
			return 15.0;
		}
		// 未用完：30 - 剩余弹药 * 3
		return max(30.0 - (m_ammo * 3.0), 0.1);
	}

    // 是否达成火箭弹奖励条件
    bool isRocketEarned() {
        return m_ammo <= 0;
    }
}

// M14 技能结束处理 Task
class M14SkillEndTask : Task {
    protected GameMode@ m_metagame;
    protected M14SkillActiveTask@ m_skillState;
    protected SkillModifer@ m_modifer;

    M14SkillEndTask(GameMode@ metagame, M14SkillActiveTask@ state,
                    SkillModifer@ mod) {
        @m_metagame = metagame;
        @m_skillState = @state;
        @m_modifer = @mod;
    }

	void start() {
		// 从 Tracker 状态数组中移除
		for (int i = g_m14Tracker.m14_active_tasks.length() - 1; i >= 0; i--) {
			if (g_m14Tracker.m14_active_tasks[i] is m_skillState) {
				g_m14Tracker.m14_active_tasks.removeAt(i);
				break;
			}
		}
		// 火箭弹奖励
		if (m_skillState.isRocketEarned()) {
			g_m14Tracker.m14_rocket_reward_players.insertLast(m_skillState.m_playerId);
			notify(m_metagame, "Skill - M14 Rocket Ready", dictionary(),
				"misc", m_skillState.m_playerId, false, "", 1.0);
		}
		// 将冷却请求加入待处理队列
		g_m14Tracker.m14_pending_cooldowns.insertLast(
			M14PendingCooldown(m_skillState.m_characterId,
							m_skillState.getCooldownTime(),
							m_modifer));
	}

    void update(float time) {}
    bool hasEnded() const { return true; } // 立即结束
}

// ============================================================
// 通用重复效果 Task 基类（用于替代 GFLskill 手动 tracker 数组模式）
// ============================================================
class RepeatEffectTask : Task {
    protected GameMode@ m_metagame;
    protected int m_characterId;
    protected int m_factionId;
    protected Vector3 m_pos;
    protected float m_interval;
    protected float m_timeLeft;
    protected int m_remainCount;

    RepeatEffectTask(GameMode@ metagame, int cId, int fId,
                     Vector3 pos, float interval, int count) {
        @m_metagame = metagame;
        m_characterId = cId;
        m_factionId = fId;
        m_pos = pos;
        m_interval = interval;
        m_remainCount = count;
    }

    void start() {
        m_timeLeft = m_interval;
    }

    void update(float time) {
        m_timeLeft -= time;
        if (m_timeLeft <= 0) {
            excuteEffect();
            m_remainCount--;
            m_timeLeft = m_interval;
        }
    }

    bool hasEnded() const {
        return m_remainCount <= 0;
    }

    // 子类重写此方法实现具体效果
    void excuteEffect() {}
}

// DOT（持续伤害）效果 Task，在固定位置重复生成弹头
class DOTEffectTask : RepeatEffectTask {
    protected string m_projectile;

    DOTEffectTask(GameMode@ metagame, int cId, int fId,
                  Vector3 pos, float interval, int count, string projectile) {
        super(metagame, cId, fId, pos, interval, count);
        m_projectile = projectile;
    }

    void excuteEffect() {
        string c =
            "<command class='create_instance'" +
            " faction_id='" + m_factionId + "'" +
            " instance_class='grenade'" +
            " instance_key='" + m_projectile + "'" +
            " position='" + m_pos.toString() + "'" +
            " character_id='" + m_characterId + "' />";
        m_metagame.getComms().send(c);
    }
}

// XM8 技能 Task，每秒在附近随机选一个敌人生成爆炸弹头，共 8 次
class XM8SkillTask : RepeatEffectTask {

    XM8SkillTask(GameMode@ metagame, int cId, int fId, Vector3 pos) {
        super(metagame, cId, fId, pos, 1.0, 8);
    }

    void excuteEffect() {
        uint fnum = m_metagame.getFactionCount();
        array<const XmlElement@> affectedCharacter;
        affectedCharacter = getCharactersNearPosition(m_metagame, m_pos, 1, 8.0f);
        if (fnum == 3) {
            array<const XmlElement@> affectedCharacter2;
            affectedCharacter2 = getCharactersNearPosition(m_metagame, m_pos, 2, 8.0f);
            if (affectedCharacter2 !is null) {
                for (uint x = 0; x < affectedCharacter2.length(); x++) {
                    affectedCharacter.insertLast(affectedCharacter2[x]);
                }
            }
        }
        if (fnum == 4) {
            array<const XmlElement@> affectedCharacter2;
            affectedCharacter2 = getCharactersNearPosition(m_metagame, m_pos, 2, 8.0f);
            if (affectedCharacter2 !is null) {
                for (uint x = 0; x < affectedCharacter2.length(); x++) {
                    affectedCharacter.insertLast(affectedCharacter2[x]);
                }
            }
            array<const XmlElement@> affectedCharacter3;
            affectedCharacter3 = getCharactersNearPosition(m_metagame, m_pos, 3, 8.0f);
            if (affectedCharacter3 !is null) {
                for (uint x = 0; x < affectedCharacter3.length(); x++) {
                    affectedCharacter.insertLast(affectedCharacter3[x]);
                }
            }
        }
        if (affectedCharacter.length() > 0) {
            int enemynum = affectedCharacter.length() - 1;
            int luckyone;
            if (enemynum <= 0) {
                luckyone = 0;
            } else {
                luckyone = rand(0, enemynum);
            }
            int luckyoneid = affectedCharacter[luckyone].getIntAttribute("id");
            const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
            if (luckyoneC !is null) {
                Vector3 luckyoneposV = stringToVector3(luckyoneC.getStringAttribute("position"));
                luckyoneposV = luckyoneposV.add(Vector3(0, 0.5, 0));
                string c =
                    "<command class='create_instance'" +
                    " faction_id='" + m_factionId + "'" +
                    " instance_class='grenade'" +
                    " instance_key='skill_xm8mod3.projectile'" +
                    " position='" + luckyoneposV.toString() + "'" +
                    " character_id='" + m_characterId + "' />";
                m_metagame.getComms().send(c);
            }
        }
    }
}