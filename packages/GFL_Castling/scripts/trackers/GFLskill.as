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
	protected Metagame@ m_metagame;

	// --------------------------------------------
	GFLskill(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected array<XM8tracker@> XM8track;
	

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
	
		//checking if the event was triggered by a rangefinder notify_script
		string EventKeyGet = event.getStringAttribute("key");	
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
                        " instance_key='40mm_sopmod_main.projectile'" +
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
					c.setIntAttribute("untransform_count", 10);
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
					//获取技能影响的敌人数量
					array<const XmlElement@> affectedCharacter;
					array<const XmlElement@> affectedCharacter2;
					array<const XmlElement@> affectedCharacter3;

					affectedCharacter = getCharactersNearPosition(m_metagame,Pos_40mm,1,8.0f);
					affectedCharacter2 = getCharactersNearPosition(m_metagame,Pos_40mm,2,8.0f);
					affectedCharacter3 = getCharactersNearPosition(m_metagame,Pos_40mm,3,8.0f);
					if (affectedCharacter2 != null){
						for(int x=0;x<affectedCharacter2.length;x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}
					if (affectedCharacter3 != null){
						for(int x=0;x<affectedCharacter3.length;x++){
							affectedCharacter.insertLast(affectedCharacter3[x]);
						}
					}
					XM8track.insertLast(XM8tracker(characterId,1.0,affectedCharacter,factionid));
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='40mm_xm8mod3.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				}
			}
		}
	}

	void update(float time) {
        if(XM8track.length()>0)
		{
            for (int a=0;a<XM8track.length();a++){
                XM8track[a].m_time-=time;
                if(XM8track[a].m_time<0){
					int enemynum= XM8track[a].m_affected.length-1;
					int luckyone = rand(0,enemynum);
					string lucyonepos = XM8track[a].m_affected[luckyone].getStringAttribute("position");
					string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ XM8track[a].m_factionid +"'" +
                        " instance_class='grenade'" +
                        " instance_key='skill_xm8mod3.projectile'" +
                        " position='" + lucyonepos + "'"+
				        " character_id='" + XM8track[a].m_characterId + "' />";
					m_metagame.getComms().send(c);
                    XM8track[a].m_numtime--;
					if (XM8track[a].m_numtime<1){
						XM8track.removeAt(a);
					}
                }
            }
        }
	}

}

class XM8tracker{
    int m_characterId;
	float m_time;
	int m_numtime=8;
	int m_factionid;
	array<const XmlElement@> m_affected;
	XM8tracker(int characterId,float time,array<const XmlElement@> affected,int factionid)
	{
		m_characterId = characterId;
		m_time = time;
		m_affected = affected;
		m_factionid= factionid;
	}
}