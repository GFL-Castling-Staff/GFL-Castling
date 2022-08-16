#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
//Originally created by NetherCrow
dictionary SharedRewardList = {

        // null
        {"",0},

        {"share_reward_1",1},
        {"share_reward_2",2},
        {"share_reward_3",3},
        {"share_reward_4",4},
        {"share_reward_5",5},
        {"share_reward_6",6},
        {"share_reward_7",7},

        // foobar
        {"666",-1}
};
class SharedReward : Tracker {
	protected Metagame@ m_metagame;

	SharedReward(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleResultEvent(const XmlElement@ event) {
        string EventKeyGet = event.getStringAttribute("key");
        if(int(SharedRewardList[EventKeyGet])<=0) return;
        Vector3 m_pos= stringToVector3(event.getStringAttribute("position"));
        switch(int(SharedRewardList[EventKeyGet]))
        {
            case 0: {break;}
            
            case 1: {addRangeItemInBackpack(m_metagame,0,"carry_item","city_gifts.carry_item",m_pos,40.0);break;}
            case 2: {addRangeItemInBackpack(m_metagame,0,"carry_item","wild_gifts.carry_item",m_pos,40.0);break;}
            case 3: {addRangeItemInBackpack(m_metagame,0,"carry_item","snow_gifts.carry_item",m_pos,40.0);break;}
            case 4: {addRangeItemInBackpack(m_metagame,0,"carry_item","forest_gifts.carry_item",m_pos,40.0);break;}
            case 5: {addRangeItemInBackpack(m_metagame,0,"carry_item","city_gifts.carry_item",m_pos,40.0);break;}
            case 6: {addRangeItemInBackpack(m_metagame,0,"carry_item","city_gifts.carry_item",m_pos,40.0);break;}
            case 7: {addRangeItemInBackpack(m_metagame,0,"carry_item","city_gifts.carry_item",m_pos,40.0);break;}

            
            default:
                break;
        }

    }

}

