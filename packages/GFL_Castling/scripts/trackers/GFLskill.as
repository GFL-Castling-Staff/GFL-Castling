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

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
	
		//checking if the event was triggered by a rangefinder notify_script		
		if (event.getStringAttribute("key") == "RO635_skill") {
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
		if (event.getStringAttribute("key") == "SOPMOD_skill") {
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
                    m_metagame.getComms().send(c);
				    string c1 = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='40mm_sopmod_main.projectile'" +
                        " position='" + Pos_40mm.toString() + "'"+
				        " character_id='" + characterId + "' />";
                    m_metagame.getComms().send(c1);
				}
			}
		}
		if (event.getStringAttribute("key") == "ump9_skill") {
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
						array<const XmlElement@>@ affectedCharacter = getCharactersNearPosition(m_metagame,grenade_pos,enemyfaction[i],15.0f);
						affectedNumber += affectedCharacter.length;
					}
					string sendtext= "白鸮轰鸣击中了"+ affectedNumber +"个敌人";
					sendPrivateMessage(m_metagame,playerId,sendtext);
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='"+ player.getIntAttribute("faction_id") +"'" +
                        " instance_class='grenade'" +
                        " instance_key='ump9_stun_grenade.projectile'" +
                        " position='" + grenade_pos.toString() + "'"+
				        " character_id='" + characterId + "' />";
                    m_metagame.getComms().send(c);					
					if (affectedNumber >= 7){
						Vector3 UMP9_pos=stringToVector3(character.getStringAttribute("position"));
						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='ump9_skill_soldier_spawner.projectile'" +
							" position='" + UMP9_pos.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);			
					}
				}
			}
		}
		if (event.getStringAttribute("key") == "repair_fairy"){
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







	}
}