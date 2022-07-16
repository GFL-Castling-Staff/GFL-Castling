#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "gamemode.as"
#include "GFLhelpers.as"
//Originally created by NetherCrow

class vehicle_spawn : Tracker {
	protected Metagame@ m_metagame;

	vehicle_spawn(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

    protected void handleVehicleSpawnEvent(const XmlElement@ event){
        string key = event.getStringAttribute("vehicle_key");
		if (key == "kcco_trans_truck.vehicle") {
            int v_id = event.getIntAttribute("vehicle_id");
            int f_id = event.getIntAttribute("owner_id");
            const XmlElement@ vehicle_instance = getVehicleInfo(m_metagame,v_id);
            if (vehicle_instance is null) return;
            string v_pos=vehicle_instance.getStringAttribute("position");
            spawnSoldier(m_metagame,2,f_id,v_pos,"kcco_ar_human");
            spawnSoldier(m_metagame,4,f_id,v_pos,"kcco_ar");
            spawnSoldier(m_metagame,3,f_id,v_pos,"kcco_sg");
		}
    }
}