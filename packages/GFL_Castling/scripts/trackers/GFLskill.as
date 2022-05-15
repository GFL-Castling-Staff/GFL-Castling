#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

//Author: NetherCrow

	// --------------------------------------------
class GFLskill : Tracker {
	protected GameMode@ m_metagame;
	uint m_fnum;

	// --------------------------------------------
	GFLskill(GameMode@ metagame) {
		@m_metagame = @metagame;
	}
	protected array<string> GKcallList={
		"gk_airstrike_fairy.call",
		"gk_rocket_fairy.call",
		"sg1hg1mg2.call",
		"hvy_landing.call",
		"martina.call",
		"chiara.call",
		"pierre.call",
		"gk_repair_fairy.call",
		"target.call",
		"manticore.call",
		"manticore2.call"
	};
    protected array<XM8tracker@> XM8track;
	protected array<HK416_tracker@> HK416_track;
	protected array<Vector_tracker@> Vector_track;

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
	
		//checking if the event was triggered by a rangefinder notify_script
		string EventKeyGet = event.getStringAttribute("key");
		if (EventKeyGet == "aa_spawn"){
			const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
			if(playerFaction.getStringAttribute("name")=="G&K PMC"){
				XmlElement command("command");
				command.setStringAttribute("class", "faction_resources");
				command.setIntAttribute("faction_id", 0);
				addFactionResourceElements(command, "call", GKcallList, false);
				m_metagame.getComms().send(command);
			}
		}
		if (EventKeyGet == "aa_destroy"){
			const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
			if(playerFaction.getStringAttribute("name")=="G&K PMC"){
				XmlElement command("command");
				command.setStringAttribute("class", "faction_resources");
				command.setIntAttribute("faction_id", 0);
				addFactionResourceElements(command, "call", GKcallList, true);
				m_metagame.getComms().send(command);
			}
		}		
		if (EventKeyGet == "RO635_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				
				if (player !is null) {
			
					if (player.hasAttribute("aim_target")) {
						Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
                        string c = 
                            "<command class='create_instance'" +
                            " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                            " instance_class='grenade'" +
                            " instance_key='RO635skiller.projectile'" +
                            " position='" + target.toString() + "' />";
                        m_metagame.getComms().send(c);
					}
				}
			}
		}
		if (EventKeyGet == "SOPMOD_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				if (player !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='40mm.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
				    string c1 = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='std_aa_grenade.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
                    m_metagame.getComms().send(c1);
					m_metagame.getComms().send(c);
				}
			}
		}
		if (EventKeyGet == "ump9_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				if (player !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = player.getIntAttribute("faction_id");
					int affectedNumber =0;
					//获取技能影响的敌人数量
					array<int> enemyfaction = {0,1,2,3,4};
					for(int i =0;i<4;i++){
						if (enemyfaction[i] ==factionid){
							enemyfaction.removeAt(i);
						}
					}
					int n=enemyfaction.length-1;
					for(int i=0;i<n;i++){
						array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,grenade_pos,enemyfaction[i],15.0f);
						affectedNumber += affectedCharacter.length;
					}
					string sendtext= "白鸮轰鸣击中了"+ affectedNumber +"个敌人";
					sendPrivateMessage(m_metagame,playerId,sendtext);
					int PlayerfactionId = player.getIntAttribute("faction_id");
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ PlayerfactionId +"'" +
                        " instance_class='grenade'" +
                        " instance_key='ump9_stun_grenade.projectile'" +
                        " position='" + grenade_pos.toString() + "'"+
				        " character_id='" + characterId + "' />";
                    m_metagame.getComms().send(c);					
					if (affectedNumber >= 5){
						Vector3 UMP9_pos = stringToVector3(character.getStringAttribute("position"));
						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ PlayerfactionId +"'" +
							" instance_class='grenade'" +
							" instance_key='ump9_skill_soldier_spawner.projectile'" +
							" position='" + UMP9_pos.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);
						playSoundAtLocation(m_metagame,"UMP9_skill_Extra2.wav",PlayerfactionId,UMP9_pos,0.8);						
					}
					else {
						Vector3 UMP9_pos = stringToVector3(character.getStringAttribute("position"));
						playSoundAtLocation(m_metagame,"UMP9_skill_Extra1.wav",PlayerfactionId,UMP9_pos,0.8);
					}
				}
			}
		}
		if (EventKeyGet == "repair_fairy"){
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
				int factionid = character.getIntAttribute("faction_id");
				array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, grenade_pos, factionid, 20.0f);
				for (uint i = 0; i < characters.length; i++) {
					int soldierId = characters[i].getIntAttribute("id");
					XmlElement c ("command");
					c.setStringAttribute("class", "update_inventory");
					c.setIntAttribute("character_id", soldierId); 
					c.setIntAttribute("untransform_count", 20);
					m_metagame.getComms().send(c);
				}
			}
		}
		if (EventKeyGet == "xm8_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				if (player !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
					int factionid = player.getIntAttribute("faction_id");
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='std_aa_grenade.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
					XM8track.insertLast(XM8tracker(characterId,1.0,factionid,Pos_40mm));
				}
			}
		}
		if (EventKeyGet == "416_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				if (player !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
					int factionid = player.getIntAttribute("faction_id");
					//获取技能影响的敌人数量
					m_fnum= m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					for(uint i=0;i<m_fnum;i++) 
						if(i!=factionid) {
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,Pos_40mm,i,7.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
					if (affectedCharacter.length()>0){
						HK416_track.insertLast(HK416_tracker(characterId,factionid,Pos_40mm,affectedCharacter));
					}

                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='std_aa_grenade.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				}
			}
		}
		if (EventKeyGet == "kcco_smartgrenade_scan") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int factionid = character.getIntAttribute("faction_id");
				Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
				//获取技能影响的敌人数量
				m_fnum = m_metagame.getFactionCount();
				array<const XmlElement@> affectedCharacter;
				_log("Scan successful");
				for(uint i=0;i<m_fnum;i++) 
					if(i!=factionid) {
					array<const XmlElement@> affectedCharacter2;
					affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,10.0f);
					if (affectedCharacter2 !is null){
						for(uint x=0;x<affectedCharacter2.length();x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}
				}
				if (affectedCharacter.length()>0) {
					_log("Locate1 successful");
					uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
					uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
					const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
					Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
					CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3.projectile",characterId,factionid,120,0.01);
				}
				else {
					_log("Locate2 successful");
					CreateProjectile(m_metagame,pos_smartgrenade,pos_smartgrenade.add(Vector3(0,-10,0)),"kcco_smartgrenade_3.projectile",characterId,factionid,120,0.01);
				}									
			}			
		}
		if (EventKeyGet == "VV_skill"){
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
				int factionid = character.getIntAttribute("faction_id");
				Vector_track.insertLast(Vector_tracker(characterId,factionid,grenade_pos));			
			}
		}
		if (EventKeyGet == "stg44_skill") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				
				if (player !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='skill_stg44_1.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				    c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='skill_stg44_2.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				    c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='skill_stg44_3.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				}
			}
		}
		if (EventKeyGet == "banzai100"){
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				
				if (player !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='cl.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
				    string c1 = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='cl_1.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
				    string c2 = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='cl_e.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c2);
                    m_metagame.getComms().send(c1);
					m_metagame.getComms().send(c);
					string command = "<command class='update_character' id='" + characterId + "' dead='1' />";
					m_metagame.getComms().send(command);
				}
			}
		}
	}

	void update(float time) {
        if(XM8track.length()>0){
            for (uint a=0;a<XM8track.length();a++){
                XM8track[a].m_time-=time;
                if(XM8track[a].m_time<0){
					m_fnum= m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					affectedCharacter = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,1,8.0f);
					if (m_fnum==3){
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,2,8.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
					if (m_fnum==4){
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,2,8.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
						array<const XmlElement@> affectedCharacter3;
						affectedCharacter3 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,3,8.0f);
						if (affectedCharacter3 !is null){
							for(uint x=0;x<affectedCharacter3.length();x++){
								affectedCharacter.insertLast(affectedCharacter3[x]);
							}
						}
					}
					if (affectedCharacter.length()>0){
						int enemynum= affectedCharacter.length()-1;
						int luckyone;
						if (enemynum<=0) {
							luckyone=0;
						}
						else{
							luckyone = rand(0,enemynum);
						}
						int luckyoneid = affectedCharacter[luckyone].getIntAttribute("id");
						const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
						if (luckyoneC !is null && luckyoneid!= -1){
							string luckyonepos = luckyoneC.getStringAttribute("position");
							Vector3 luckyoneposV = stringToVector3(luckyonepos);
							Vector3 height = Vector3(0,0.5,0);
							luckyoneposV = luckyoneposV.add(height);
							luckyonepos = luckyoneposV.toString();
							string c = 
								"<command class='create_instance'" +
								" faction_id='"+ XM8track[a].m_factionid +"'" +
								" instance_class='grenade'" +
								" instance_key='skill_xm8mod3.projectile'" +
								" position='" + luckyonepos + "'"+
								" character_id='" + XM8track[a].m_characterId + "' />";
							m_metagame.getComms().send(c);		
						}
					}
                    XM8track[a].m_numtime--;
					XM8track[a].m_time=1;
					if (XM8track[a].m_numtime<0){
						XM8track.removeAt(a);
					}
                }
            }
        }
		if(HK416_track.length()>0){
            for (uint a=0;a<HK416_track.length();a++){
                HK416_track[a].m_time-=time;
                if(HK416_track[a].m_time<0){	
					if (HK416_track[a].m_affected.length()>0){
						for(uint b=0;b<HK416_track[a].m_affected.length();b++){
							int luckyoneid = HK416_track[a].m_affected[b].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC.getIntAttribute("id")!=-1){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								Vector3 height = Vector3(0,0.5,0);
								luckyoneposV = luckyoneposV.add(height);
								luckyonepos = luckyoneposV.toString();
								string c = 
									"<command class='create_instance'" +
									" faction_id='"+ HK416_track[a].m_factionid +"'" +
									" instance_class='grenade'" +
									" instance_key='firenade_sub_416.projectile'" +
									" position='" + luckyonepos + "'"+
									" character_id='" + HK416_track[a].m_characterId + "' />";
								m_metagame.getComms().send(c);
							}
						}
					}
					HK416_track[a].m_numtime--;
					HK416_track[a].m_time=0.33;
					if (HK416_track[a].m_numtime<0){
						HK416_track.removeAt(a);
					}
				}			
			}
		}
        if(Vector_track.length()>0){
            for (uint a=0;a<Vector_track.length();a++){
                Vector_track[a].m_time-=time;
                if(Vector_track[a].m_time<0){
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ Vector_track[a].m_factionid +"'" +
						" instance_class='grenade'" +
						" instance_key='VVfirenade_sub.projectile'" +
						" position='" + Vector_track[a].m_pos.toString() + "'"+
						" character_id='" + Vector_track[a].m_characterId + "' />";
					m_metagame.getComms().send(c);		
                    Vector_track[a].m_numtime--;
					Vector_track[a].m_time=1;
					if (Vector_track[a].m_numtime<1){
						Vector_track.removeAt(a);
					}
                }
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
}

class XM8tracker{
    int m_characterId;
	float m_time;
	int m_numtime=7;
	int m_factionid;
	Vector3 m_pos;
	XM8tracker(int characterId,float time,int factionid,Vector3 pos)
	{
		m_characterId = characterId;
		m_time = time;
		m_factionid= factionid;
		m_pos=pos;
	}
}

class HK416_tracker{
    int m_characterId;
	float m_time=0.33;
	int m_numtime=12;
	int m_factionid;
	array<const XmlElement@> m_affected;
	Vector3 m_pos;
	HK416_tracker(int characterId,int factionid,Vector3 pos,array<const XmlElement@> affected)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
		m_affected= affected;
	}
}

class Vector_tracker{
    int m_characterId;
	int m_numtime=4;
	float m_time=0;
	int m_factionid;
	Vector3 m_pos;
	Vector_tracker(int characterId,int factionid,Vector3 pos){
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
	}
}

