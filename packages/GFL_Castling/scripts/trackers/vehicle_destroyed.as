#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "task_sequencer.as"
#include "resource_helpers.as"
#include "GFLparameters.as"

//Author： rst

dictionary included_vehicle = {
        {"martina.vehicle",0},
        {"chiara.vehicle",1000},
        {"pierre.vehicle",1000},
        {"aek999.vehicle",0},
        {"amos.vehicle",500000},
        {"tricycle.vehicle",1000},
        {"gk_bunker.vehicle",10000},
        {"gk_bunker_tow.vehicle",10000},
        {"gk_bunker_mortar.vehicle",10000},
        {"gk_bunker_cannon.vehicle",10000},
        {"radar_tower.vehicle",500000},
        {"ogas_pulse_generator.vehicle",5000},
        {"t14_gk.vehicle",10000},
        {"is2_m1895.vehicle",10000},
        {"mobile_armory.vehicle",3000},
        {"mortar_truck.vehicle",3000},
        {"gk_store",0},
        {"elmostore",5000},
        {"gk_stash",0},
        {"hvy_store",0},
        {"t6_store",0},
        {"call_ui_store",0},
        {"armored_truck.vehicle",500000},
        {"",-1}
};

array<string> global_notify_vehicle = {
    "radar_tower.vehicle",
    "armored_truck.vehicle"
};

class vehicle_destroyed : Tracker{
    protected Metagame@ m_metagame;
    protected bool m_ended;

    //--------------------------------------------
    vehicle_destroyed(Metagame@ metagame){
        @m_metagame = @metagame;
        m_ended = false;
    }
    // --------------------------------------------
    void update(float time) {
    }
    // --------------------------------------------
	bool hasEnded() const {
		return false;
	}
	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}
    

    // ----------------------------------------------------
	protected void handleMatchEndEvent(const XmlElement@ event) {
		m_ended = true;
	}

    protected void handleVehicleDestroyEvent(const XmlElement@ event) {
        string vehicle_key = event.getStringAttribute("vehicle_key");
        int vehicle_id = event.getIntAttribute("vehicle_id");
        int killer_cid = event.getIntAttribute("character_id");
        int killer_fid = event.getIntAttribute("faction_id");
        int vehicle_owner_fid = event.getIntAttribute("owner_id");
        // Vector3 position = stringToVector3(event.getStringAttribute("position"));

        if(!included_vehicle.exists(vehicle_key)){return;}
        if(killer_fid != vehicle_owner_fid){return;}

        const XmlElement@ characterInfo = getCharacterInfo(m_metagame, killer_cid);
        if(characterInfo is null){return;}
        int pid = characterInfo.getIntAttribute("player_id");
        if(pid == -1) return;

        const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, vehicle_id);
        if(vehicleInfo is null){return;}

        if(global_notify_vehicle.find(vehicle_key)>-1) {
            const XmlElement@ playerInfo = getPlayerInfo(m_metagame, pid);
            string player_name = getPlayerInfoName(playerInfo);
            string vehicle_name = vehicleInfo.getStringAttribute("name");
            dictionary a;
            a["%player_name"] = ""+player_name;
            a["%vehicle"] = ""+vehicle_name;
            playSound(m_metagame, "objective_priority.wav", 0);
            sendFactionMessageKey(m_metagame, killer_fid, "vehicle destroy circular criticism", a, 2.0);
        }

        int rp_punish = int(included_vehicle[vehicle_key]);

        dictionary a;
        a["%count"] = ""+rp_punish;   
        notify(m_metagame, "Hint - Vehicle Destoryed TK", a , "misc", pid, false, "", 1.0);
        if(rp_punish > 0)
        {
            GiveRP(m_metagame,killer_cid,-rp_punish);
        }
 	}    

}