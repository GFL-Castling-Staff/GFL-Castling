#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"

//Originally created by NetherCrow
//TagName=vehicle_destroyed_event character_id=196 faction_id=0 owner_id=1 position=510.667 12.0977 411.387 vehicle_id=5 vehicle_key=bgm71_tow.vehicle 
//TagName=vehicle block=11 17 forward=-0.913688 0.0720795 0.399974 health=41 holder_id=0 id=23 key=mobile_armory.vehicle max_health=50 name=Armory truck owner_id=0 position=379.602 11.9074 600.574 right=0.405958 0.193882 0.893089 type_id=141 
class decryptSystem : Tracker {
    protected const DEFAULT_KEY = "decrypt_toolkit_dummy.vehicle";
	protected Metagame@ m_metagame;

	decryptSystem(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handleVehicleDestroyEvent(const XmlElement@ event){
        string key = event.getStringAttribute("vehicle_key");
		if (key != DEFAULT_KEY) return;

        int v_id = event.getIntAttribute("vehicle_id");
        int f_id = event.getIntAttribute("owner_id");
        string v_pos = event.getStringAttribute("position");
        int decrypter_id = -1;
        array<const XmlElement@> possible_affectedCharacter;
        possible_affectedCharacter = getCharactersNearPosition(m_metagame,v_pos,f_id,10);
        if (possible_affectedCharacter is null) return;
        for (uint i =0;i<possible_affectedCharacter.length();i++)
        {
            int characterid = possible_affectedCharacter[i].getIntAttribute("id");
            if (checkCharacterIdisPlayerOwn(characterid)) 
            {
                decrypter_id = characterid;
            }
        }

        if(decrypter_id == -1) return;

        //寻找最近的可破解载具 查询非0阵营载具，并且计算出范围10以内的


        //生成破解机弹头和启动事件
        
    }
}

class decrypt_event{
	protected Metagame@ m_metagame;

}

array<string> decrypt_vehicle_list = {
    "",
    "",
    ""
}; 