#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

//id
// 0 drop
// 1 armory
// 2 Backpack
// 3 Stash

class ItemDropEvent : Tracker {
	protected Metagame@ m_metagame;
    ItemDropEvent(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleItemDropEvent(const XmlElement@ event) 
	{
        if (event.getIntAttribute("target_container_type_id") != 3) return;
        if (event.getStringAttribute("item_key") == "immunity_mp5.carry_item"){
            int cId = event.getIntAttribute("character_id");
            deleteItemInStash(m_metagame,cId,"carry_item","immunity_mp5.carry_item");
        }
        if (event.getStringAttribute("item_key") == "VVfirenade.projectile"){
            int cId = event.getIntAttribute("character_id");
            deleteItemInStash(m_metagame,cId,"projectile","VVfirenade.projectile");
        }
    }

    protected void handlePlayerSpawnEvent(const XmlElement@ event){
        const XmlElement@ player = event.getFirstElementByTagName("player");
        if (player !is null) {
            int cId = player.getIntAttribute("character_id");
            string vestkey="";
            vestkey = getPlayerEquipmentKey(m_metagame,cId,4);
            if (vestkey=="immunity_mp5.carry_item"){
                XmlElement c ("command");
                c.setStringAttribute("class", "update_inventory");
                c.setIntAttribute("container_type_id", 4);
                c.setIntAttribute("character_id", cId); 
                {
                    XmlElement k("item");
                    k.setStringAttribute("class", "carry_item");
                    k.setStringAttribute("key", "exo_t4.carry_item");
                    c.appendChild(k);
                }
                m_metagame.getComms().send(c);
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