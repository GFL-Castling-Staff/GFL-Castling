#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17

	// --------------------------------------------
class RangeFinder : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	RangeFinder(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
	
		//checking if the event was triggered by a rangefinder notify_script		
		if (event.getStringAttribute("key") == "rangefinder") {
		
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			
			if (character !is null) {
				int playerId = character.getIntAttribute("player_id");
				const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
				
				if (player !is null) {
			
					if (player.hasAttribute("aim_target")) {
						Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
						Vector3 origin = stringToVector3(character.getStringAttribute("position"));
						string distance = getPositionDistance(target, origin);
						
						string intelKey = "rangefinder binoculars";
						string aim_x = character.getStringAttribute("position");
						dictionary a = {
							{"%range", distance},{"%aim_target", aim_x}
						};
						
						sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, intelKey, a);
					}
				}
			}
		}
	}
}