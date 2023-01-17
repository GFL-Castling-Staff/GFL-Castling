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
// 4 Equiped
//Author: NetherCrow

dictionary itemDropFileIndex = {
    // 空
    {"",0},

    {"firecontrol.carry_item",1},       // 火控核心
    {"core_mask.carry_item",2},         // 真核面具  
    {"upgrade_type88.carry_item",3},    // 汉阳造加速线圈
    {"upgrade_aa12.carry_item",4},      // AA12独头弹
    {"upgrade_m1.carry_item",5},      // M1加兰德弹鼓
    {"upgrade_fg42.carry_item",6},      // FG42
    {"upgrade_g41.carry_item",7},      // G41
    {"upgrade_vz61.carry_item",8},      // vz61
    {"upgrade_m1903_1.carry_item",9},      // 太太
    {"upgrade_m1903_2.carry_item",10},      // 太太
    {"upgrade_fn49.carry_item",11},      // FN49
    {"upgrade_9a91.carry_item",12},      // 9A91
    {"upgrade_m14.carry_item",13},
    {"upgrade_g3.carry_item",14},
    {"upgrade_m1897.carry_item",15},
    {"upgrade_stg44.carry_item",16},
    {"upgrade_wa2000.carry_item",17},
    {"upgrade_pkp.carry_item",18},
    {"upgrade_scarl.carry_item",19},
    {"upgrade_scarh.carry_item",20},
    {"upgrade_cso.carry_item",21},

    {"666",0}
};

dictionary itemDropKeyIndex = {
    // 空
    {"",0},

    {"mod3",1},                         // 火控核心
    {"truecore",2},                     // 真核面具  
    {"type88",3},                       // 汉阳造加速线圈
    {"aa12",4},                         // AA12独头弹
    {"m1garand",5},                     // M1加兰德弹鼓
    {"fg42",6},                         // FG42
    {"g41",7},                          // G41
    {"vz61",8},                         // vz61
    {"m1903_1",9},                      // m1903
    {"m1903_2",10},                     // m1903
    {"fn49",11},                        // fn49
    {"9a91",12},                        // 9a91
    {"m14",13},
    {"g3",14},
    {"m1897",15},
    {"stg44",16},
    {"wa2000",17},
    {"pkp",18},
    {"scarl",19},
    {"scarh",20},
    {"cso",21},

    {"666",0}
};

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
            int jud_num =  int(itemDropFileIndex[itemKey]);
            switch(jud_num)
            {
                case 1:{
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
                    break;
                }
                case 2:{
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
                    break;
                }
                case 3:{
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
                    break;
                }
                case 4:{
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
                    break;
                }
                case 5:{
                    if(checkQueue(pId,"m1garand")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"m1garand");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                } 
                case 6:{
                    if(checkQueue(pId,"fg42")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_fg42.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"fg42");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 7:{
                    if(checkQueue(pId,"g41")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_g41.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"g41");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 8:{
                    if(checkQueue(pId,"vz61")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_vz61.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"vz61");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 9:{
                    if(checkQueue(pId,"m1903_1")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1903_1.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"m1903_1");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 10:{
                    if(checkQueue(pId,"m1903_2")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1903_2.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"m1903_2");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }   
                case 11:{
                    if(checkQueue(pId,"fn49")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_fn49.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"fn49");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }     
                case 12:{
                    if(checkQueue(pId,"9a91")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_9a91.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"9a91");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 13:{
                    if(checkQueue(pId,"m14")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m14.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"m14");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 14:{
                    if(checkQueue(pId,"g3")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_g3.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"g3");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }             
                case 15:{
                    if(checkQueue(pId,"m1897")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1897.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"m1897");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 16:{
                    if(checkQueue(pId,"stg44")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_stg44.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"stg44");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }   
                case 17:{
                    if(checkQueue(pId,"wa2000")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_wa2000.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"wa2000");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 18:{
                    if(checkQueue(pId,"pkp")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_pkp.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"pkp");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 19:{
                    if(checkQueue(pId,"scarl")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_scarl.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"scarl");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 20:{
                    if(checkQueue(pId,"scarh")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_scarh.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"scarh");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }
                case 21:{
                    if(checkQueue(pId,"cso")){
                        addItemInBackpack(m_metagame,cId,"carry_item","upgrade_cso.carry_item");
                        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
                        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                    }
                    else{
                        startQueue(pId,"cso");
                        sendPrivateMessageKey(m_metagame, pId, "upgrade_common");
                        playPrivateSound(m_metagame,"sfx_equip.wav",pId);
                    }
                    break;
                }

                default:{
                    if (checkQueue(pId,"mod3")){
                        string outputItem = string(MOD3craftList[itemKey]);
                        if (outputItem != ""){
                            addItemInBackpack(m_metagame,cId,"weapon",outputItem);
                            m_craftQueue.removeAt(findQueueIndex(pId,"mod3"));
                            dictionary a;
                            a["%doll_name"] = getResourceName(m_metagame, itemKey, "weapon");
                            sendPrivateMessageKey(m_metagame, pId, "digimindupdatesuccess",a);
                            playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                            GiveRP(m_metagame,cId,-499);
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
                    else if (checkQueue(pId,"aa12") && (itemKey=="gkw_aa12_4401.weapon" || itemKey=="gkw_aa12_4401_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_aa12_4401_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"aa12"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1garand") && (itemKey=="gkw_m1.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1_sf.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1garand"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1garand") && (itemKey=="gkw_m1_1106.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1_sf_1106.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1garand"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"fg42") && (itemKey=="gkw_fg42.weapon" || itemKey=="gkw_fg42_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_fg42_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"fg42"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41.weapon" || itemKey=="gkw_g41_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_g41_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"g41"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41_2401.weapon" || itemKey=="gkw_g41_2401_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_g41_2401_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"g41"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41_7406.weapon" || itemKey=="gkw_g41_7406_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_g41_7406_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"g41"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"vz61") && (itemKey=="gkw_vz61.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_vz61_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"vz61"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1903_1") && (itemKey=="gkw_m1903.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1903_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1903_1"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1903_2") && (itemKey=="gkw_m1903.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1903_exp.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1903_2"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1903_1") && (itemKey=="gkw_m1903_302.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1903_302_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1903_1"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1903_2") && (itemKey=="gkw_m1903_302.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1903_302_exp.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1903_2"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }                    
                    else if (checkQueue(pId,"fn49") && (itemKey=="gkw_fn49.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_fn49mod3.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"fn49"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }                                        
                    else if (checkQueue(pId,"fn49") && (itemKey=="gkw_fn49_4709.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_fn49mod3_4709.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"fn49"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }           
                    else if (checkQueue(pId,"9a91") && (itemKey=="gkw_9a91.weapon" || itemKey=="gkw_9a91_skill.weapon" )){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_9a91_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"9a91"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }   
                    else if (checkQueue(pId,"9a91") && (itemKey=="gkw_9a91_1302.weapon" || itemKey=="gkw_9a91_1302_skill.weapon" )){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_9a91_1302_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"9a91"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m14") && (itemKey=="gkw_m14.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m14mod3.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m14"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"g3") && (itemKey=="gkw_g3.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_g3mod3.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"g3"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"g3") && (itemKey=="gkw_g3_1303.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_g3mod3_1303.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"g3"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"m1897") && (itemKey=="gkw_m1897.weapon" || itemKey=="gkw_m1897_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_m1897mod3.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"m1897"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }         
                    else if (checkQueue(pId,"stg44") && (itemKey=="gkw_stg44.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_stg44mod3.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"stg44"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"wa2000") && (itemKey=="gkw_wa2000.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_wa2000_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"wa2000"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"wa2000") && (itemKey=="gkw_wa2000_306.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_wa2000_306_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"wa2000"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }        
                    else if (checkQueue(pId,"pkp") && (itemKey=="gkw_pkp.weapon" || itemKey=="gkw_pkp_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_pkp_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"pkp"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"pkp") && (itemKey=="gkw_pkp_4203.weapon" || itemKey=="gkw_pkp_4203_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_pkp_4203_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"pkp"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }        
                    else if (checkQueue(pId,"scarl") && (itemKey=="gkw_scarl.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_scarl_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"scarl"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"scarh") && (itemKey=="gkw_scarh.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_scarh_only.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"scarh"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_svd.weapon" || itemKey=="gkw_svd_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_svdex.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"cso"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }                    
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_svd_5506.weapon" || itemKey=="gkw_svd_5506_skill.weapon")){
                        addItemInBackpack(m_metagame,cId,"weapon","gkw_svdex_5506.weapon");
                        m_craftQueue.removeAt(findQueueIndex(pId,"cso"));
                        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
                    }                           
                    break;
                }
            }

            if(startsWith(itemKey,"exchange_t6_ticket")){
                int jud_num1 =  int(Tier6VestIndex[itemKey]);
                switch(jud_num1)
                {
                    case 1:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","acbp_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 2:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","bp_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 3:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","cc_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 4:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","exo_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 5:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","exo_x_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 6:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","lcc_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 7:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","srexo_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 8:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","tms_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }
                    case 9:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","ultra_bp_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }        
                    case 10:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","gk_persica.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }       
                    case 11:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","chip_a_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }    
                    case 12:{
                        addMutilItemInBackpack(m_metagame,cId,"carry_item","chip_b_t6.carry_item",3);
                        playPrivateSound(m_metagame,"digimind_sfx1.wav",pId);
                        break;
                    }                                                                                                                       
                    default:{
                        break;
                    }
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
                        int jud_num = int(itemDropKeyIndex[m_craftQueue[a].m_typekey]);
                        switch(jud_num) // 此处是判断是否超过时限，从而返还玩家物品
                        {
                            case 1:{ // mod3
                                addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 2:{ // truecore
                                addItemInBackpack(m_metagame,cId,"carry_item","core_mask.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 3:{ // type88
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_type88.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 4:{ // aa12
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_aa12.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 5:{ // m1
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 6:{ // fg42
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_fg42.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 7:{ // g41
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_g41.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 8:{ // vz61
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_vz61.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 9:{ // m1903
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1903_1.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 10:{ // m1903
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1903_2.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }                    
                            case 11:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_fn49.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 12:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_9a91.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }   
                            case 13:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m14.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 14:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_g3.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 15:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_m1897.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }     
                            case 16:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_stg44.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }         
                            case 17:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_wa2000.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 18:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_pkp.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }   
                            case 19:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_scarl.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }
                            case 20:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_scarh.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }                 
                            case 21:{ 
                                addItemInBackpack(m_metagame,cId,"carry_item","upgrade_cso.carry_item");
                                playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
                                sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
                                break;
                            }                                                                                              
                            default:
                                break;
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


dictionary Tier6VestIndex = {
    // 空
    {"",0},

    {"exchange_t6_ticket_1",1},
    {"exchange_t6_ticket_2",2}, 
    {"exchange_t6_ticket_3",3}, 
    {"exchange_t6_ticket_4",4},     
    {"exchange_t6_ticket_5",5}, 
    {"exchange_t6_ticket_6",6}, 
    {"exchange_t6_ticket_7",7}, 
    {"exchange_t6_ticket_8",8}, 
    {"exchange_t6_ticket_9",9}, 
    {"exchange_t6_ticket_10",10}, 
    {"exchange_t6_ticket_11",11}, 
    {"exchange_t6_ticket_12",12}, 
    {"exchange_t6_ticket_13",13}, 

    {"666",0}
};