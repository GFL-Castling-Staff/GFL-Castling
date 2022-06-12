#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"

class keepInventory : Tracker {
	protected Metagame@ m_metagame;

	keepInventory(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handlePlayerDieEvent(const XmlElement@ event){
        const XmlElement@ victim = event.getFirstElementByTagName("target");
        if (victim is null) return;
        if (victim.getIntAttribute("player_id") == -1) return;
        int cId = victim.getIntAttribute("character_id");
        int pId = victim.getIntAttribute("player_id");
        
    }

}