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
        {"share_reward_8",8},
        {"share_reward_9",9},
        {"share_reward_10",10},
        {"share_reward_11",11},
        {"share_reward_12",12},
        {"share_reward_13",13},
        {"share_reward_14",14},
        {"share_reward_15",15},
        {"share_reward_16",16},
        {"share_reward_17",17},
        {"share_reward_18",18},
        {"share_reward_19",19},
        {"share_reward_20",20},
        {"share_reward_21",21},
        {"share_reward_22",22},
        {"share_reward_23",23},
        {"share_reward_24",24},
        {"share_reward_25",25},
        {"share_reward_26",26},
        {"share_reward_27",27},
        {"share_reward_28",28},
        {"share_reward_29",29},
        {"share_reward_30",30},
        {"share_reward_31",31},
        {"share_reward_32",32},
        {"share_reward_33",33},
        {"share_reward_34",34},
        {"share_reward_35",35},
        {"share_reward_36",36},
        {"share_reward_37",37},
        {"share_reward_38",38},
        {"share_reward_39",39},
        {"share_reward_40",40},
        {"share_reward_41",41},
        {"share_reward_42",42},
        {"share_reward_43",43},
        {"share_reward_44",44},
        {"share_reward_45",45},
        {"share_reward_46",46},
        {"share_reward_47",47},

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
            case 5: {addRangeItemInBackpack(m_metagame,0,"carry_item","cigars.carry_item",m_pos,40.0);break;}
            case 6: {addRangeItemInBackpack(m_metagame,0,"carry_item","beer_can.carry_item",m_pos,40.0);break;}
            case 7: {addRangeItemInBackpack(m_metagame,0,"carry_item","lighter.carry_item",m_pos,40.0);break;}
            case 8: {addRangeItemInBackpack(m_metagame,0,"carry_item","steroids.carry_item",m_pos,40.0);break;}
            case 9: {addRangeItemInBackpack(m_metagame,0,"carry_item","teddy.carry_item",m_pos,40.0);break;}
            case 10: {addRangeItemInBackpack(m_metagame,0,"carry_item","gold_bar.carry_item",m_pos,40.0);break;}
            case 11: {addRangeItemInBackpack(m_metagame,0,"carry_item","bible.carry_item",m_pos,40.0);break;}
            case 12: {addRangeItemInBackpack(m_metagame,0,"carry_item","koran.carry_item",m_pos,40.0);break;}
            case 13: {addRangeItemInBackpack(m_metagame,0,"carry_item","chewing_gum.carry_item",m_pos,40.0);break;}
            case 14: {addRangeItemInBackpack(m_metagame,0,"carry_item","bizarre_rubber_bullet.carry_item",m_pos,40.0);break;}
            case 15: {addRangeItemInBackpack(m_metagame,0,"carry_item","chocolate.carry_item",m_pos,40.0);break;}
            case 16: {addRangeItemInBackpack(m_metagame,0,"carry_item","dollars_300.carry_item",m_pos,40.0);break;}
            case 17: {addRangeItemInBackpack(m_metagame,0,"carry_item","energy_drink.carry_item",m_pos,40.0);break;}
            case 18: {addRangeItemInBackpack(m_metagame,0,"carry_item","fancy_sunglasses.carry_item",m_pos,40.0);break;}
            case 19: {addRangeItemInBackpack(m_metagame,0,"carry_item","radio.carry_item",m_pos,40.0);break;}
            case 20: {addRangeItemInBackpack(m_metagame,0,"carry_item","razor.carry_item",m_pos,40.0);break;}
            case 21: {addRangeItemInBackpack(m_metagame,0,"carry_item","sheaths.carry_item",m_pos,40.0);break;}
            case 22: {addRangeItemInBackpack(m_metagame,0,"carry_item","sheaths_xxl.carry_item",m_pos,40.0);break;}
            case 23: {addRangeItemInBackpack(m_metagame,0,"carry_item","sunglasses.carry_item",m_pos,40.0);break;}
            case 24: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_blue.carry_item",m_pos,40.0);break;}
            case 25: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_red.carry_item",m_pos,40.0);break;}
            case 26: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_white.carry_item",m_pos,40.0);break;}
            case 27: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_silver.carry_item",m_pos,40.0);break;}
            case 28: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_yellow.carry_item",m_pos,40.0);break;}
            case 29: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_green.carry_item",m_pos,40.0);break;}
            case 30: {addRangeItemInBackpack(m_metagame,0,"carry_item","ipoo_player_pink.carry_item",m_pos,40.0);break;}
            case 31: {addRangeItemInBackpack(m_metagame,0,"carry_item","playing_cards.carry_item",m_pos,40.0);break;}
            case 32: {addRangeItemInBackpack(m_metagame,0,"carry_item","suitcase.carry_item",m_pos,40.0);break;}
            case 33: {addRangeItemInBackpack(m_metagame,0,"carry_item","underpants.carry_item",m_pos,40.0);break;}
            case 34: {addRangeItemInBackpack(m_metagame,0,"carry_item","kamasutra.carry_item",m_pos,40.0);break;}
            case 35: {addRangeItemInBackpack(m_metagame,0,"carry_item","cd.carry_item",m_pos,40.0);break;}
            case 36: {addRangeItemInBackpack(m_metagame,0,"carry_item","whiskey_bottle.carry_item",m_pos,40.0);break;}
            case 37: {addRangeItemInBackpack(m_metagame,0,"carry_item","cigarettes.carry_item",m_pos,40.0);break;}
            case 38: {addRangeItemInBackpack(m_metagame,0,"carry_item","dollars.carry_item",m_pos,40.0);break;}
            case 39: {addRangeItemInBackpack(m_metagame,0,"carry_item","gamingdevice.carry_item",m_pos,40.0);break;}
            case 40: {addRangeItemInBackpack(m_metagame,0,"carry_item","gem.carry_item",m_pos,40.0);break;}
            case 41: {addRangeItemInBackpack(m_metagame,0,"carry_item","comic_book.carry_item",m_pos,40.0);break;}
            case 42: {addRangeItemInBackpack(m_metagame,0,"carry_item","rwr_handbook.carry_item",m_pos,40.0);break;}
            case 43: {addRangeItemInBackpack(m_metagame,0,"carry_item","oscar_statue.carry_item",m_pos,40.0);break;}
            case 44: {addRangeItemInBackpack(m_metagame,0,"carry_item","laptop.carry_item",m_pos,40.0);break;}
            case 45: {addRangeItemInBackpack(m_metagame,0,"carry_item","painting.carry_item",m_pos,40.0);break;}
            case 46: {addRangeItemInBackpack(m_metagame,0,"carry_item","gift_box_community_2.carry_item",m_pos,40.0);break;}
            case 47: {addRangeItemInBackpack(m_metagame,0,"carry_item","gift_box_1.carry_item",m_pos,40.0);break;}

            //case 48: {addRangeItemInBackpack(m_metagame,0,"carry_item","comic_book.carry_item",m_pos,40.0);break;}

            
            default:
                break;
        }

    }

}

