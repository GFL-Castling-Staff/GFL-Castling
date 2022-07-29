#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "mod3_doll.as"
#include "girl_index.as"
//id
// 0 drop
// 1 armory
// 2 Backpack
// 3 Stash

//Author: NetherCrow

class CraftQueue
{
    int m_playerId;
    float m_time=10.0;
    string m_typekey="";
    CraftQueue(int pId){
        m_playerId=pId;
    }
    CraftQueue(int pId,string key){
        m_playerId=pId;
        m_typekey=key;
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
                if(checkQueue(pId,"mod3")){
                    addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                    sendPrivateMessageKey(m_metagame, pId, "onlyonequeue");
                    playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                }
                else{
                    startQueue(pId,"mod3");
                    sendPrivateMessageKey(m_metagame, pId, "digimindupdate");
                    playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                }
            }
            else if (itemKey=="core_mask.carry_item"){
                if(checkQueue(pId,"truecore")){
                    addItemInBackpack(m_metagame,cId,"carry_item","core_mask.carry_item");
                    sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_mask");
                    playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                }
                else{
                    startQueue(pId,"truecore");
                    sendPrivateMessageKey(m_metagame, pId, "truemask");
                    playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                }
            }
            else if (itemKey=="upgrade_type88.carry_item"){
                if(checkQueue(pId,"type88")){
                    addItemInBackpack(m_metagame,cId,"carry_item","upgrade_type88.carry_item");
                    sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                    playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                }
                else{
                    startQueue(pId,"type88");
                    sendPrivateMessageKey(m_metagame, pId, "upgrade_88type");
                    playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                }
            }
            else if (itemKey=="upgrade_aa12.carry_item"){
                if(checkQueue(pId,"aa12")){
                    addItemInBackpack(m_metagame,cId,"carry_item","upgrade_aa12.carry_item");
                    sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                    playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                }
                else{
                    startQueue(pId,"aa12");
                    sendPrivateMessageKey(m_metagame, pId, "upgrade_aa12");
                    playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                }
            }            
            else if (checkQueue(pId,"mod3")){
                string outputItem = string(MOD3craftList[itemKey]);
                if (outputItem != ""){
                    addItemInBackpack(m_metagame,cId,"weapon",outputItem);
                    m_craftQueue.removeAt(findQueueIndex(pId,"mod3"));
                    dictionary a;
                    a["%doll_name"] = getResourceName(m_metagame, itemKey, "weapon");
                    sendPrivateMessageKey(m_metagame, pId, "digimindupdatesuccess",a);
                    playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                }
                else{
                    addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                    addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                    m_craftQueue.removeAt(findQueueIndex(pId,"mod3"));
                    sendPrivateMessageKey(m_metagame, pId, "digimindupdatefailed");
                    playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                }
            }
            else if (checkQueue(pId,"type88") && (itemKey=="gkw_88typemod3.weapon" || itemKey=="gkw_88typemod3_skill.weapon")){
                addItemInBackpack(m_metagame,cId,"weapon","gkw_88typemod3_6503.weapon");
                m_craftQueue.removeAt(findQueueIndex(pId,"type88"));
                playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
            }
            else if (checkQueue(pId,"aa12") && (itemKey=="gkw_aa12.weapon" || itemKey=="gkw_aa12_skill.weapon")){
                addItemInBackpack(m_metagame,cId,"weapon","gkw_aa12_only.weapon");
                m_craftQueue.removeAt(findQueueIndex(pId,"aa12"));
                playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
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
	protected void handleChatEvent(const XmlElement@ event) {
        string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) {
			return;
		}
        string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
        if(checkCommand(message,"mask")){
            if(checkQueue(senderId,"truecore") != true) return;
            m_craftQueue.removeAt(findQueueIndex(senderId,"truecore"));
            string s = message.substr(message.findFirst(" ")+1);
            const XmlElement@ player = getPlayerInfo(m_metagame,senderId);
            if (player !is null) {
                int cId=player.getIntAttribute("character_id");
                string itemKey= getGFLkey(s);
                if (itemKey==""){
                    addItemInBackpack(m_metagame,cId,"carry_item","core_mask.carry_item");
                    sendPrivateMessageKey(m_metagame, senderId, "truemask_failed");
                    playPrivateSound(m_metagame,"sfx_failed.wav",senderId);                    
                }
                else{
                    addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                    dictionary a;
                    a["%doll_name"] = getResourceName(m_metagame, itemKey, "weapon");                    
                    sendPrivateMessageKey(m_metagame, senderId, "truemask_success",a);
                    playPrivateSound(m_metagame,"sfx_big.wav",senderId);                           
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

    void update(float time) {
        if(m_craftQueue.size()>0){
            for(uint a=0;a<m_craftQueue.size();a++){
                m_craftQueue[a].m_time-=time;
                if(m_craftQueue[a].m_time<0){
                    int pId=m_craftQueue[a].m_playerId;
                    const XmlElement@ player = getPlayerInfo(m_metagame, pId);
                    if(player !is null){
                        int cId=player.getIntAttribute("character_id");
                        if(m_craftQueue[a].m_typekey=="mod3"){
                            addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                            playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                            sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                        }
                        if(m_craftQueue[a].m_typekey=="truecore"){
                            addItemInBackpack(m_metagame,cId,"carry_item","core_mask.carry_item");
                            playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                            sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                        }
                        if(m_craftQueue[a].m_typekey=="type88"){
                            addItemInBackpack(m_metagame,cId,"carry_item","upgrade_type88.carry_item");
                            playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                            sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                        }
                        if(m_craftQueue[a].m_typekey=="aa12"){
                            addItemInBackpack(m_metagame,cId,"carry_item","upgrade_aa12.carry_item");
                            playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                            sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                        }                                              
                    }
                    m_craftQueue.removeAt(a);
                }
            }
        }
    }

    bool checkQueue(int pId,string type){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId && m_craftQueue[i].m_typekey==type){
                return true;
            }
        }
        return false;
    }

    int findQueueIndex(int pId,string type){
        for(uint i=0;i<m_craftQueue.size();i++){
            if(m_craftQueue[i].m_playerId==pId && m_craftQueue[i].m_typekey==type){
                return int(i);
            }
        }
        return -1;
    }

    void startQueue(int playerId,string key){
        m_craftQueue.insertLast(CraftQueue(playerId,key));
    }    
}


