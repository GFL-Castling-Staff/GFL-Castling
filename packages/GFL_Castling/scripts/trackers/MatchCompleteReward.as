#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
//Originally created by NetherCrow

class MatchCompleteReward : Tracker {
	protected Metagame@ m_metagame;

	MatchCompleteReward(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handleMatchEndEvent(const XmlElement@ event){
		const XmlElement@ winCondition = event.getFirstElementByTagName("win_condition");
		if (winCondition !is null) {
			int factionId = winCondition.getIntAttribute("faction_id");
            if (factionId == 0) {
                array<const XmlElement@> players = getPlayers(m_metagame);
                if(players is null || players.size()<=0) return;
                for (uint i = 0; i < players.size(); ++i) {
                    int characterId = players[i].getIntAttribute("character_id");
                    if (characterId >= 0) {
                        GiveRP(m_metagame,characterId,2000);
                        GiveXP(m_metagame,characterId,0.1);
                        addItemInStash(m_metagame,characterId,"carry_item","complete_box.carry_item");
                    }                    
                }

                if(rand(1,5)==1){
                    sendFactionMessageKey(m_metagame, 0,"celebrateXB");
                    playSound(m_metagame, "winwin.wav", 0,1.0);
                    for (uint i = 0; i < players.size(); ++i) {
                        int characterId = players[i].getIntAttribute("character_id");
                        if (characterId >= 0) {
                            addItemInStash(m_metagame,characterId,"carry_item","complete_box_xb.carry_item");
                        }
                    }
                }
            }
		} 
    }

}