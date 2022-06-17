#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "mod3_doll.as"

//id
// 0 drop
// 1 armory
// 2 Backpack
// 3 Stash

class CraftQueue
{
    int m_playerId;
    float m_time=10.0;
    CraftQueue(int pId){
        m_playerId=pId;
    }
}

class ItemDropEvent : Tracker {
    protected array<CraftQueue@> m_craftQueue;

	protected Metagame@ m_metagame;
    ItemDropEvent(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleItemDropEvent(const XmlElement@ event) 
	{
        if (event.getIntAttribute("target_container_type_id") == 3){
            int cId = event.getIntAttribute("character_id");
            string key = event.getStringAttribute("item_key");
            dealwithillegalitem(key,cId);
        }
        if (event.getIntAttribute("target_container_type_id") == 1){
            string itemKey = event.getStringAttribute("item_key");
            int cId = event.getIntAttribute("character_id");
            int pId = event.getIntAttribute("player_id");            
            if(itemKey=="firecontrol.carry_item"){
                if(checkQueue(pId)){
                    addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                    // sendPrivateMessageKey(m_metagame, pId, "onlyonequeue");
                }
                else{
                    startQueue(pId);
                }
            }
            else if (checkQueue(pId)){
                string outputItem = string(MOD3craftList[itemKey]);
                if (outputItem != ""){
                    addItemInBackpack(m_metagame,cId,"weapon",outputItem);
                    m_craftQueue.removeAt(findQueueIndex(pId));
                    // sendPrivateMessageKey(m_metagame, pId, "onlyonequeue");
                }
                else{
                    addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                    addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                    m_craftQueue.removeAt(findQueueIndex(pId));
                    // sendPrivateMessageKey(m_metagame, pId, "onlyonequeue");
                }
            }
        }
    }

    protected void dealwithillegalitem(string foobar,int id){
        if (illegalitem.find(foobar)>-1){
            deleteItemInStash(m_metagame,id,"carry_item",foobar);
        }
    }
	array<string> illegalitem = {
        "immunity_mp5.carry_item",
        "immunity_g36c.carry_item",
        "immunity_thompson.carry_item"
    };

    protected void handlePlayerSpawnEvent(const XmlElement@ event){
        const XmlElement@ player = event.getFirstElementByTagName("player");
        if (player !is null) {
            int cId = player.getIntAttribute("character_id");
            string vestkey="";
            vestkey = getPlayerEquipmentKey(m_metagame,cId,4);
            if (illegalitem.find(vestkey)>-1){
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

    void update(float time) {
        if(m_craftQueue.size()>0){
            for(uint a=0;a<m_craftQueue.size();a++){
                m_craftQueue[a].m_time-=time;
                if(m_craftQueue[a].m_time<0){
                    const XmlElement@ player = getPlayerInfo(m_metagame, m_craftQueue[a].m_playerId);
                    int cId=player.getIntAttribute("character_id");
                    addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                    m_craftQueue.removeAt(a);
                }
            }
        }
    }
    bool checkQueue(int pId){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId){
                return true;
            }
        }
        return false;
    }

    int findQueueIndex(int pId){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId){
                return int(i);
            }
        }
        return -1;
    }

    void startQueue(int playerId){
        m_craftQueue.insertLast(CraftQueue(playerId));
    }
}


