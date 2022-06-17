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
                string outputItem = string(craftList[itemKey]);
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

dictionary craftList = {
    {"",""},

    {"gkw_hk416.weapon","gkw_hk416mod3.weapon"},
    {"gkw_hk416_537.weapon","gkw_hk416_537_mod3.weapon"},
    {"gkw_hk416_3401.weapon","gkw_hk416_3401_mod3.weapon"},
    {"gkw_hk416_6505.weapon","gkw_hk416_6505_mod3.weapon"},
    {"gkw_g11.weapon","gkw_g11mod3.weapon"},
    {"gkw_g11_9.weapon","gkw_g11mod3_9.weapon"},
    {"gkw_g11_538.weapon","gkw_g11mod3_538.weapon"},
    {"gkw_g3.weapon","gkw_g3mod3.weapon"},
    {"gkw_ar15.weapon","gkw_ar15mod3.weapon"},
    {"gkw_ar15_532.weapon","gkw_ar15mod3_532.weapon"},
    {"gkw_asval.weapon","gkw_asvalmod3.weapon"},
    {"gkw_g36.weapon","gkw_g36mod3.weapon"},
    {"gkw_g36_1507.weapon","gkw_g36mod3_1507.weapon"},
    {"gkw_m4a1.weapon","gkw_m4a1mod3.weapon"},
    {"gkw_m4a1_530.weapon","gkw_m4a1mod3_530.weapon"},
    {"gkw_m4sopmodii.weapon","gkw_m4sopmodiimod3.weapon"},
    {"gkw_m4sopmodii_531.weapon","gkw_m4sopmodiimod3_531.weapon"},
    {"gkw_stg44.weapon","gkw_stg44mod3.weapon"},
    {"gkw_gsh18.weapon","gkw_gsh18mod3.weapon"},
    {"gkw_gsh18_523.weapon","gkw_gsh18mod3_523.weapon"},
    {"gkw_gsh18_609.weapon","gkw_gsh18mod3_609.weapon"},
    {"gkw_m1911.weapon","gkw_m1911_mod3.weapon"},
    {"gkw_m1895.weapon","gkw_m1895mod3.weapon"},
    {"gkw_m1895_5309.weapon","gkw_m1895mod3_5309.weapon"},
    {"gkw_m1918.weapon","gkw_m1918mod3.weapon"},
    {"gkw_m1918_102.weapon","gkw_m1918mod3_102.weapon"},
    {"gkw_m1918_806.weapon","gkw_m1918mod3_806.weapon"},
    {"gkw_m1918_1606.weapon","gkw_m1918mod3_1606.weapon"},
    // {"gkw_88type.weapon","gkw_88typemod3.weapon"},
    {"gkw_mg4.weapon","gkw_mg4mod3.weapon"},
    {"gkw_ksvk.weapon","gkw_ksvkmod3.weapon"},
    {"gkw_ksvk_3405.weapon","gkw_ksvkmod3_3405.weapon"},
    {"gkw_ksvk_3805.weapon","gkw_ksvkmod3_3805.weapon"},
    {"gkw_m14.weapon","gkw_m14mod3.weapon"},
    // {"gkw_m1891.weapon","gkw_m1891mod3.weapon"},
    {"gkw_ntw20.weapon","gkw_ntw20mod3.weapon"},
    {"gkw_ntw20_307.weapon","gkw_ntw20mod3_307.weapon"},
    {"gkw_ntw20_4801.weapon","gkw_ntw20mod3_4801.weapon"},
    {"gkw_supersass.weapon","gkw_supersassmod3.weapon"},
    {"gkw_supersass_1407.weapon","gkw_supersassmod3_1407.weapon"},
    {"gkw_sv98.weapon","gkw_sv98mod3.weapon"},

    {"gkw_g36c.weapon","gkw_g36c_mod3.weapon"},
    {"gkw_idw.weapon","gkw_idwmod3.weapon"},
    {"gkw_idw_2108.weapon","gkw_idwmod3_2108.weapon"},
    {"gkw_idw_3205.weapon","gkw_idwmod3_3205.weapon"},
    {"gkw_idw_4908.weapon","gkw_idwmod3_4908.weapon"},
    {"gkw_kp31.weapon","gkw_kp31mod3.weapon"},

    {"gkw_mp5.weapon","gkw_mp5mod3.weapon"},
    {"gkw_mp5_1205.weapon","gkw_mp5mod3_1205.weapon"},
    {"gkw_mp5_1903.weapon","gkw_mp5mod3_1903.weapon"},
    {"gkw_mp5_3.weapon","gkw_mp5mod3_3.weapon"},
    {"gkw_mp5_3006.weapon","gkw_mp5mod3_3006.weapon"},

    {"gkw_pp19.weapon","gkw_pp19mod3.weapon"},
    {"gkw_ppsh41.weapon","gkw_ppsh41mod3.weapon"},
    {"gkw_ro635.weapon","gkw_ro635mod3.weapon"},

    {"gkw_ump45.weapon","gkw_ump45mod3.weapon"},
    {"gkw_ump45_410.weapon","gkw_ump45mod3_410.weapon"},
    {"gkw_ump45_535.weapon","gkw_ump45mod3_535.weapon"},

    {"gkw_uzi.weapon","gkw_uzimod3.weapon"},
    {"gkw_ak15.weapon","gkw_ak15mod3.weapon"},
    {"gkw_ribeyrolles.weapon","gkw_ribeyrollesmod3.weapon"},
    {"gkw_welrod.weapon","gkw_welrodmod3.weapon"},
    {"gkw_lwmmg.weapon","gkw_lwmmgmod3.weapon"},
    {"gkw_lwmmg_1808.weapon","gkw_lwmmgmod3_1808.weapon"},

    {"gkw_an94.weapon","gkw_an94_mod3.weapon"},
    {"gkw_an94_3303.weapon","gkw_an94mod3_3303.weapon"},
    {"gkw_an94_blm.weapon","gkw_an94mod3_blm.weapon"},

    {"gkw_xm8.weapon","gkw_xm8_mod3.weapon"},
    {"gkw_mab38.weapon","gkw_mab38mod3.weapon"},
    {"gkw_galil.weapon","gkw_galilmod3.weapon"},
    // {"gkw_ppk.weapon","gkw_ppkmod3.weapon"},
    // {"gkw_m500.weapon","gkw_m500mod3.weapon"},


    {"666","-1"}
};
