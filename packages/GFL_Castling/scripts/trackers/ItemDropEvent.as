#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLparameters.as"
#include "mod3_doll.as"
#include "girl_index.as"

//id
// 0 drop
// 1 armory
// 2 Backpack
// 3 Stash
// 4 Equiped
//Author: NetherCrow

class CraftQueue
{
    int m_playerId;
    float m_time=20.0;
    string m_typekey="";
    string m_string = "";
    CraftQueue(int pId){
        m_playerId=pId;
    }
    CraftQueue(int pId,string key){
        m_playerId=pId;
        m_typekey=key;
    }    
    CraftQueue(int pId,string key,string str){
        m_playerId=pId;
        m_typekey=key;
        m_string = str;
    }
    CraftQueue(int pId,string key,float time){
        m_playerId=pId;
        m_typekey=key;
        m_time = time;
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
        int type_id = event.getIntAttribute("target_container_type_id");
        if (type_id == 3){
            int cId = event.getIntAttribute("character_id");
            string key = event.getStringAttribute("item_key");
            dealwithillegalitem(key,cId);
        }
        if (type_id == 2){
            int cId = event.getIntAttribute("character_id");
            string key = event.getStringAttribute("item_key");
            if(key == "gkw_doll_logger.weapon")
            {
                int pId = event.getIntAttribute("player_id");     
                notify(m_metagame, "Help - logger system", dictionary(), "misc", pId, true, "Help - logger system title", 1.0);
            }
            else if(startsWith(key,"call_ui"))
            {
                deleteItemInBackpack(m_metagame,cId,"weapon",key);
                int pId = event.getIntAttribute("player_id");
                GFL_playerInfo@ playerInfo = getPlayerInfoFromListbyPid(pId);
                if (playerInfo.m_name == default_string) return;
                string profile_hash = playerInfo.m_hash;
                string p_name = playerInfo.m_name;
                if(handleCallChangeEvent(cId,pId,key))
                {
                    player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
                    int slot = int(callUI_Slot[key]);
                    string call_key = getCallKeyfromPlayerData(newdata,key);
                    if(call_key == "")
                    {
                        notify(m_metagame, "Hint - call - locked",dictionary(), "misc", pId, false, "", 1.0);
                        return;
                    }
                    newdata.setCallSlot(slot,call_key);
                    string filename = ("save_" + profile_hash +".xml" );
                    writeXML(m_metagame,filename,PlayerProfileSave(newdata));
                    dictionary a;
                    a["%call_key"] = "Hint - call - title - " + key;
                    a["%slot"] = "Tier " + slot;
                    notify(m_metagame, "Hint - call - changesuccess", a, "misc", pId, false, "", 1.0);
                }
            }
            else if(key == "pack_vest_repair_plate_x8")
            {
                deleteItemInBackpack(m_metagame,cId,"weapon",key);
                addMutilItemInBackpack(m_metagame,cId,"weapon","vest_repair_plate.weapon",10);
            }
        }        
        if (type_id == 1){
            string itemKey = event.getStringAttribute("item_key");
            int itemClass = event.getIntAttribute("item_class");
            int cId = event.getIntAttribute("character_id");
            int pId = event.getIntAttribute("player_id");     
            int jud_num =  int(itemDropFileIndex[itemKey]);
            string secondary_key = getPlayerWeaponFromListByPID(pId,1);
            int secondary_num = getPlayerWeaponAmountFromListByPID(pId,1);
            // _log("副手武器是" + secondary_key);

            if(secondary_key == "gkw_doll_logger.weapon" && itemClass == 0 && secondary_num!=0)
            {
                if (!reverse_tdoll_complex_index.exists(itemKey)) 
                {
                    dictionary a;
                    a["%doll_key"] = "" + itemKey;
                    notify(m_metagame, "Doll logged failed", a, "misc", pId, false, "", 1.0);
                    return;
                }
                GFL_playerInfo@ playerInfo = getPlayerInfoFromListbyPid(pId);
                if (playerInfo.m_name == default_string) return;
                string profile_hash = playerInfo.m_hash;
                string p_name = playerInfo.m_name;
                player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
                if(newdata.FindWeapon(itemKey))
                {
                    dictionary a;
                    a["%doll_key"] = "" + itemKey;                    
                    notify(m_metagame, "Doll logged already", a, "misc", pId, false, "", 1.0);
                    return;
                }
                newdata.addWeapon(itemKey);
                string format_string = string(reverse_tdoll_complex_index[itemKey]);
                dictionary a;
                a["%doll_key"] = "" + itemKey;
                a["%doll_num"] = "" + newdata.getAllNum();
                notify(m_metagame, "Doll logged success", a, "misc", pId, false, "", 1.0);
                string filename = ("save_" + profile_hash +".xml" );
                writeXML(m_metagame,filename,PlayerProfileSave(newdata));
                return;
            }

            switch(jud_num)
            {
                case 1:{
                    upgrade(cId, pId, "mod3", "firecontrol.carry_item", "digimindupdate", "digimind_sfx1.wav");
                    break;
                }
                case 2:{
                    upgrade(cId, pId, "truecore", "core_mask.carry_item", "truemask", "sfx_equip.wav");
                    break;
                }
                case 3:{
                    upgrade(cId, pId, "type88", "upgrade_type88.carry_item", "upgrade_88type", "sfx_equip.wav");
                    break;
                }
                case 4:{
                    upgrade(cId, pId, "aa12", "upgrade_aa12.carry_item", "upgrade_aa12", "sfx_equip.wav");
                    break;
                }
                case 5:{
                    upgrade(cId, pId, "m1garand", "upgrade_m1.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                } 
                case 6:{
                    upgrade(cId, pId, "fg42", "upgrade_fg42.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 7:{
                    upgrade(cId, pId, "g41", "upgrade_g41.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 8:{
                    upgrade(cId, pId, "vz61", "upgrade_vz61.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 9:{
                    upgrade(cId, pId, "m1903_1", "upgrade_m1903_1.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 10:{
                    upgrade(cId, pId, "m1903_2", "upgrade_m1903_2.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }   
                case 11:{
                    upgrade(cId, pId, "fn49", "upgrade_fn49.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }     
                case 12:{
                    upgrade(cId, pId, "9a91", "upgrade_9a91.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 13:{
                    upgrade(cId, pId, "m14", "upgrade_m14.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 14:{
                    upgrade(cId, pId, "g3", "upgrade_g3.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }             
                case 15:{
                    upgrade(cId, pId, "m1897", "upgrade_m1897.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 16:{
                    upgrade(cId, pId, "stg44", "upgrade_stg44.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }   
                case 17:{
                    upgrade(cId, pId, "wa2000", "upgrade_wa2000.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 18:{
                    upgrade(cId, pId, "pkp", "upgrade_pkp.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 19:{
                    upgrade(cId, pId, "scarl", "upgrade_scarl.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 20:{
                    upgrade(cId, pId, "scarh", "upgrade_scarh.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 21:{
                    upgrade(cId, pId, "cso", "upgrade_cso.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 22:{
                    upgrade(cId, pId, "type4", "upgrade_type4.carry_item", "upgrade_common", "sfx_equip.wav");
                    break;
                }
                case 23:{
                    upgrade(cId, pId, "sr3mp", "upgrade_sr3mp.carry_item", "upgrade_common", "sfx_equip.wav");
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
                            //下面是自动录入功能
                            GFL_playerInfo@ playerInfo = getPlayerInfoFromListbyPid(pId);
                            if (playerInfo.m_name == default_string) return;
                            string profile_hash = playerInfo.m_hash;
                            string p_name = playerInfo.m_name;
                            player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
                            if(newdata.FindWeapon(outputItem))
                            {
                                return;
                            }
                            else if(existKeyinList(itemKey) && !newdata.FindWeapon(itemKey))
                            {
                                newdata.addWeapon(itemKey);
                                newdata.addWeapon(outputItem);
                                notify(m_metagame, "Logger Mask Auto", dictionary(), "misc", pId, false, "", 1.0);
                                string filename = ("save_" + profile_hash +".xml" );
                                writeXML(m_metagame,filename,PlayerProfileSave(newdata));  
                                return;
                            }
                            else
                            {
                                newdata.addWeapon(outputItem);
                                notify(m_metagame, "Logger Mask Auto", dictionary(), "misc", pId, false, "", 1.0);
                                string filename = ("save_" + profile_hash +".xml" );
                                writeXML(m_metagame,filename,PlayerProfileSave(newdata));  
                                return;                                
                            }
                        }
                        else{
                            addItemInBackpack(m_metagame,cId,"carry_item","firecontrol.carry_item");;
                            addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                            m_craftQueue.removeAt(findQueueIndex(pId,"mod3"));
                            sendPrivateMessageKey(m_metagame, pId, "digimindupdatefailed");
                            playPrivateSound(m_metagame,"sfx_failed.wav",pId);
                        }
                    }
                    else if (checkQueue(pId,"type88") && (itemKey=="gkw_88typemod3.weapon" || itemKey=="gkw_88typemod3_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_88typemod3_6503.weapon", "type88");
                    }
                    else if (checkQueue(pId,"aa12") && (itemKey=="gkw_aa12.weapon" || itemKey=="gkw_aa12_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_aa12_only.weapon", "aa12");
                    }
                    else if (checkQueue(pId,"aa12") && (itemKey=="gkw_aa12_4401.weapon" || itemKey=="gkw_aa12_4401_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_aa12_4401_only.weapon", "aa12");
                    }
                    else if (checkQueue(pId,"aa12") && (itemKey=="gkw_aa12_2403.weapon" || itemKey=="gkw_aa12_2403_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_aa12_2403_only.weapon", "aa12");
                    }                    
                    else if (checkQueue(pId,"m1garand") && (itemKey=="gkw_m1.weapon" || itemKey=="gkw_m1_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1_sf.weapon", "m1garand");
                    }
                    else if (checkQueue(pId,"m1garand") && (itemKey=="gkw_m1_1106.weapon" || itemKey=="gkw_m1_1106_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1_sf_1106.weapon", "m1garand");
                    }
                    else if (checkQueue(pId,"m1garand") && (itemKey=="gkw_m1_6907.weapon" || itemKey=="gkw_m1_6907_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1_sf_6907.weapon", "m1garand");
                    }                    
                    else if (checkQueue(pId,"fg42") && (itemKey=="gkw_fg42.weapon" || itemKey=="gkw_fg42_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_fg42_only.weapon", "fg42");
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41.weapon" || itemKey=="gkw_g41_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g41_only.weapon", "g41");
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41_2401.weapon" || itemKey=="gkw_g41_2401_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g41_2401_only.weapon", "g41");
                    }
                    else if (checkQueue(pId,"g41") && (itemKey=="gkw_g41_7406.weapon" || itemKey=="gkw_g41_7406_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g41_7406_only.weapon", "g41");
                    }
                    else if (checkQueue(pId,"vz61") && (itemKey=="gkw_vz61.weapon")){
                        giveDigimindItem(cId, pId, "gkw_vz61_only.weapon", "vz61");
                    }
                    else if (checkQueue(pId,"m1903_1") && (itemKey=="gkw_m1903.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_only.weapon", "m1903_1");
                    }
                    else if (checkQueue(pId,"m1903_2") && (itemKey=="gkw_m1903.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_exp.weapon", "m1903_2");
                    }
                    else if (checkQueue(pId,"m1903_1") && (itemKey=="gkw_m1903_302.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_302_only.weapon", "m1903_1");
                    }
                    else if (checkQueue(pId,"m1903_2") && (itemKey=="gkw_m1903_302.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_302_exp.weapon", "m1903_2");
                    }
                    else if (checkQueue(pId,"m1903_1") && (itemKey=="gkw_m1903_1107.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_1107_only.weapon", "m1903_1");
                    }
                    else if (checkQueue(pId,"m1903_2") && (itemKey=="gkw_m1903_1107.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1903_1107_exp.weapon", "m1903_2");
                    }
                    else if (checkQueue(pId,"fn49") && (itemKey=="gkw_fn49.weapon")){
                        giveDigimindItem(cId, pId, "gkw_fn49mod3.weapon", "fn49");
                    }                                        
                    else if (checkQueue(pId,"fn49") && (itemKey=="gkw_fn49_4709.weapon")){
                        giveDigimindItem(cId, pId, "gkw_fn49mod3_4709.weapon", "fn49");
                    }           
                    else if (checkQueue(pId,"9a91") && (itemKey=="gkw_9a91.weapon" || itemKey=="gkw_9a91_skill.weapon" )){
                        giveDigimindItem(cId, pId, "gkw_9a91_only.weapon", "9a91");
                    }   
                    else if (checkQueue(pId,"9a91") && (itemKey=="gkw_9a91_1302.weapon" || itemKey=="gkw_9a91_1302_skill.weapon" )){
                        giveDigimindItem(cId, pId, "gkw_9a91_1302_only.weapon", "9a91");
                    }
                    else if (checkQueue(pId,"9a91") && (itemKey=="gkw_9a91_8304.weapon" || itemKey=="gkw_9a91_8304_skill.weapon" )){
                        giveDigimindItem(cId, pId, "gkw_9a91_8304_only.weapon", "9a91");
                    }                    
                    else if (checkQueue(pId,"m14") && (itemKey=="gkw_m14.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m14mod3.weapon", "m14");
                    }
                    else if (checkQueue(pId,"m14") && (itemKey=="gkw_m14_303.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m14mod3_303.weapon", "m14");
                    }                    
                    else if (checkQueue(pId,"g3") && (itemKey=="gkw_g3.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g3mod3.weapon", "g3");
                    }
                    else if (checkQueue(pId,"g3") && (itemKey=="gkw_g3_1303.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g3mod3_1303.weapon", "g3");
                    }
                    else if (checkQueue(pId,"m1897") && (itemKey=="gkw_m1897.weapon" || itemKey=="gkw_m1897_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1897mod3.weapon", "m1897");
                    }         
                    else if (checkQueue(pId,"m1897") && (itemKey=="gkw_m1897_2505.weapon" || itemKey=="gkw_m1897_2505_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_m1897mod3_2505.weapon", "m1897");
                    }                      
                    else if (checkQueue(pId,"stg44") && (itemKey=="gkw_stg44.weapon")){
                        giveDigimindItem(cId, pId, "gkw_stg44mod3.weapon", "stg44");
                    }
                    else if (checkQueue(pId,"stg44") && (itemKey=="gkw_g43.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g43_kurz.weapon", "stg44");
                    }                   
                    else if (checkQueue(pId,"stg44") && (itemKey=="gkw_g43_7607.weapon")){
                        giveDigimindItem(cId, pId, "gkw_g43_7607_kurz.weapon", "stg44");
                    }                                
                    else if (checkQueue(pId,"wa2000") && (itemKey=="gkw_wa2000.weapon")){
                        giveDigimindItem(cId, pId, "gkw_wa2000_only.weapon", "wa2000");
                    }
                    else if (checkQueue(pId,"wa2000") && (itemKey=="gkw_wa2000_306.weapon")){
                        giveDigimindItem(cId, pId, "gkw_wa2000_306_only.weapon", "wa2000");
                    }        
                    else if (checkQueue(pId,"wa2000") && (itemKey=="gkw_wa2000_1108.weapon")){
                        giveDigimindItem(cId, pId, "gkw_wa2000_1108_only.weapon", "wa2000");
                    }                            
                    else if (checkQueue(pId,"pkp") && (itemKey=="gkw_pkp.weapon" || itemKey=="gkw_pkp_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_pkp_only.weapon", "pkp");
                    }
                    else if (checkQueue(pId,"pkp") && (itemKey=="gkw_pkp_4203.weapon" || itemKey=="gkw_pkp_4203_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_pkp_4203_only.weapon", "pkp");
                    }
                    else if (checkQueue(pId,"pkp") && (itemKey=="gkw_pkp_5904.weapon" || itemKey=="gkw_pkp_5904_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_pkp_5904_only.weapon", "pkp");
                    }                            
                    else if (checkQueue(pId,"scarl") && (itemKey=="gkw_scarl.weapon")){
                        giveDigimindItem(cId, pId, "gkw_scarl_only.weapon", "scarl");
                    }
                    else if (checkQueue(pId,"scarh") && (itemKey=="gkw_scarh.weapon")){
                        giveDigimindItem(cId, pId, "gkw_scarh_only.weapon", "scarh");
                    }
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_svd.weapon" || itemKey=="gkw_svd_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_svdex.weapon", "cso");
                    }                    
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_svd_5506.weapon" || itemKey=="gkw_svd_5506_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_svdex_5506.weapon", "cso");
                    }   
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_ak47.weapon")){
                        giveDigimindItem(cId, pId, "gkw_ak47_60r.weapon", "cso");
                    }
                    else if (checkQueue(pId,"cso") && (itemKey=="gkw_ak47_501.weapon")){
                        giveDigimindItem(cId, pId, "gkw_ak47_60r_501.weapon", "cso");
                    }     
                    else if (checkQueue(pId,"type4") && (itemKey=="gkw_4type.weapon")){
                        giveDigimindItem(cId, pId, "gkw_4type_only.weapon", "type4");
                    }
                    else if (checkQueue(pId,"sr3mp") && (itemKey=="gkw_sr3mp.weapon" || itemKey=="gkw_sr3mp_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_sr3mp_only.weapon", "sr3mp");
                    }
                    else if (checkQueue(pId,"sr3mp") && (itemKey=="gkw_sr3mp_4101.weapon" || itemKey=="gkw_sr3mp_4101_skill.weapon")){
                        giveDigimindItem(cId, pId, "gkw_sr3mp_4101_only.weapon", "sr3mp");
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

    protected void giveDigimindItem(int cId, int pId, string weapon_xml_name,string weapon_name){
        addItemInBackpack(m_metagame,cId,"weapon",weapon_xml_name);
        m_craftQueue.removeAt(findQueueIndex(pId,weapon_name));
        playPrivateSound(m_metagame,"digimind_sfx2.wav",pId);
        //下面是自动录入功能
        GFL_playerInfo@ playerInfo = getPlayerInfoFromListbyPid(pId);
        if (playerInfo.m_name == default_string) return;
        string profile_hash = playerInfo.m_hash;
        string p_name = playerInfo.m_name;
        player_data newdata = PlayerProfileLoad(readFile(m_metagame,p_name,profile_hash));
        if(newdata.FindWeapon(weapon_xml_name))
        {
            return;
        }
        else
        {
            newdata.addWeapon(weapon_xml_name);
            notify(m_metagame, "Logger Mask Auto", dictionary(), "misc", pId, false, "", 1.0);
            string filename = ("save_" + profile_hash +".xml" );
            writeXML(m_metagame,filename,PlayerProfileSave(newdata));  
            return;
        }        
    }

    protected void failedUpgrade(int cId, int pId, string weapon_xml_name){
        addItemInBackpack(m_metagame,cId,"carry_item", weapon_xml_name);
        sendPrivateMessageKey(m_metagame, pId, "onlyonequeue_common");
        playPrivateSound(m_metagame,"sfx_failed.wav",pId);
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
                    XmlElement k("item");;
                    k.setStringAttribute("class", "carry_item");;
                    k.setStringAttribute("key", "exo_t5_16lab.carry_item");;
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
            if (player is null) return;
            int cId=player.getIntAttribute("character_id");
            string profile_hash = player.getStringAttribute("profile_hash");
            string itemKey = getKeyfromIndex(s);
            if (itemKey==""){
                addItemInBackpack(m_metagame,cId,"carry_item","core_mask.carry_item");;
                sendPrivateMessageKey(m_metagame, senderId, "truemask_failed");
                playPrivateSound(m_metagame,"sfx_failed.wav",senderId);                    
            }
            else{
                addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                dictionary a;
                a["%doll_name"] = getResourceName(m_metagame, itemKey, "weapon");                    
                sendPrivateMessageKey(m_metagame, senderId, "truemask_success",a);
                playPrivateSound(m_metagame,"sfx_big.wav",senderId);
                player_data newdata = PlayerProfileLoad(readFile(m_metagame,sender,profile_hash)); 
                if(newdata.FindWeapon(itemKey)) 
                {
                    return;
                }
                else
                {
                    newdata.addWeapon(itemKey);
                    notify(m_metagame, "Logger Mask Auto", dictionary(), "misc", senderId, false, "", 1.0);
                    string filename = ("save_" + profile_hash +".xml" );
                    writeXML(m_metagame,filename,PlayerProfileSave(newdata));  
                    return;                  
                }
            }
        }

		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

        if(checkCommand(message,"give")){
            string s = message.substr(message.findFirst(" ")+1);
            const XmlElement@ player = getPlayerInfo(m_metagame,senderId);
            if (player !is null) {
                int cId=player.getIntAttribute("character_id");
                string itemKey= getKeyfromIndex(s);
                addItemInBackpack(m_metagame,cId,"weapon",itemKey);
                dictionary a;
                a["%doll_name"] = getResourceName(m_metagame, itemKey, "weapon");                    
                sendPrivateMessageKey(m_metagame, senderId, "truemask_success",a);
                playPrivateSound(m_metagame,"sfx_big.wav",senderId);                           
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
                                upgradeTimeout(cId, pId, "firecontrol.carry_item");
                                break;
                            }
                            case 2:{ // truecore
                                upgradeTimeout(cId, pId, "core_mask.carry_item");
                                break;
                            }
                            case 3:{ // type88
                                upgradeTimeout(cId, pId, "upgrade_type88.carry_item");
                                break;
                            }
                            case 4:{ // aa12
                                upgradeTimeout(cId, pId, "upgrade_aa12.carry_item");
                                break;
                            }
                            case 5:{ // m1
                                upgradeTimeout(cId, pId, "upgrade_m1.carry_item");
                                break;
                            }
                            case 6:{ // fg42
                                upgradeTimeout(cId, pId, "upgrade_fg42.carry_item");
                                break;
                            }
                            case 7:{ // g41
                                upgradeTimeout(cId, pId, "upgrade_g41.carry_item");
                                break;
                            }
                            case 8:{ // vz61
                                upgradeTimeout(cId, pId, "upgrade_vz61.carry_item");
                                break;
                            }
                            case 9:{ // m1903
                                upgradeTimeout(cId, pId, "upgrade_m1903_1.carry_item");
                                break;
                            }
                            case 10:{ // m1903
                                upgradeTimeout(cId, pId, "upgrade_m1903_2.carry_item");
                                break;
                            }                    
                            case 11:{
                                upgradeTimeout(cId, pId, "upgrade_fn49.carry_item");
                                break;
                            }
                            case 12:{
                                upgradeTimeout(cId, pId, "upgrade_9a91.carry_item");
                                break;
                            }   
                            case 13:{
                                upgradeTimeout(cId, pId, "upgrade_m14.carry_item");
                                break;
                            }
                            case 14:{
                                upgradeTimeout(cId, pId, "upgrade_g3.carry_item");
                                break;
                            }
                            case 15:{
                                upgradeTimeout(cId, pId, "upgrade_m1897.carry_item");
                                break;
                            }     
                            case 16:{
                                upgradeTimeout(cId, pId, "upgrade_stg44.carry_item");
                                break;
                            }         
                            case 17:{
                                upgradeTimeout(cId, pId, "upgrade_wa2000.carry_item");
                                break;
                            }
                            case 18:{
                                upgradeTimeout(cId, pId, "upgrade_pkp.carry_item");
                                break;
                            }   
                            case 19:{
                                upgradeTimeout(cId, pId, "upgrade_scarl.carry_item");
                                break;
                            }
                            case 20:{
                                upgradeTimeout(cId, pId, "upgrade_scarh.carry_item");
                                break;
                            }                 
                            case 21:{
                                upgradeTimeout(cId, pId, "upgrade_cso.carry_item");
                                break;
                            }            
                            case 22:{
                                upgradeTimeout(cId, pId, "upgrade_type4.carry_item");
                                break;
                            }                        
                            case 23:{
                                upgradeTimeout(cId, pId, "upgrade_sr3mp.carry_item");
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

    protected void upgrade(int cId, int pId, string pid_name, string item_name, string message_key, string wav){
        if(checkQueue(pId, pid_name))
        {
            failedUpgrade(cId, pId, item_name);
        }
        else
        {
            startQueue(pId, pid_name);
            sendPrivateMessageKey(m_metagame, pId, message_key);
            playPrivateSound(m_metagame, wav, pId);
        }
    }

    protected bool handleCallChangeEvent(int cId, int pId, string call_key){
        if(checkQueue(pId, call_key))
        {
            m_craftQueue.removeAt(findQueueIndex(pId,call_key));
            return true;
        }
        else
        {
            if (!callUI_Slot.exists(call_key)) return false;
            string dict_intro_key = "Hint - call - intro - " + call_key;
            string dict_title_key = "Hint - call - title - " + call_key;
            startQueue(pId, call_key,10.0);
            notify(m_metagame, dict_intro_key, dictionary(), "misc", pId, true, dict_title_key, 1.0);
            notify(m_metagame, "Hint - call - rebuytochange", dictionary(), "misc", pId, false, "", 1.0);
        }
        return false;
    }

    protected string getCallKeyfromPlayerData(player_data@ data,string key)
    {
        return data.getCallKey(key);
    }

    protected void upgradeTimeout(int cId, int pId, string weapon_xml_name){
        addItemInBackpack(m_metagame,cId,"carry_item", weapon_xml_name);
        playPrivateSound(m_metagame,"sfx_returnback.wav",pId);
        sendPrivateMessageKey(m_metagame, pId, "quest_timeout");
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

    void startQueue(int playerId,string key,float time){
        m_craftQueue.insertLast(CraftQueue(playerId,key,time));
    }

}

