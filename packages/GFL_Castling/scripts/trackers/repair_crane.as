#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17
//Originally created for stationary cranes only. Expanded for repair tanks and blowtorches.
//Adapted by Castling Staff

	// --------------------------------------------
class RepairCrane : Tracker {
	protected Metagame@ m_metagame;

	array<string> m_vehicle_norepair = {"is2_m1895.vehicle"};
	array<string> m_vehicle_nerf = {"armored_truck.vehicle"};

	// --------------------------------------------
	RepairCrane(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		//repair effect radius (at 5.0 or higher the crane repairs itself)
		float range;
		//the amount of health points added each repair cycle
		float repairValue = 0.0;
		float repairPercent = 0.0;
		//overrepair percentage
		float overHealth;	
		
		//vertical offset for repair position
		float y_offset;
		
		//xp reward for the repairer each repair cycle
		float xpReward = 0.0004;
		//rp reward for the repairer each repair cycle
		uint rpReward = 5;
		
		//checking if the event was triggered by a repair projectile
		string key = event.getStringAttribute("key");		
		
		if (key == "repair_crane") {
			range = 3.5;
			repairValue = 0.6;
			overHealth = 1.1;
			y_offset = -5.0;
		} else if (key == "paul_repair") {
			range = 5.0;
			repairValue = 30.0;
			repairPercent = 0.25;
			overHealth = 1.2;
			y_offset = 0.0;
			rpReward = 50;
			xpReward = 0.01;
		} else if (key == "bbs_repair") {
			range = 5.0;
			repairValue = 10.0;
			repairPercent = 0.10;
			overHealth = 1.1;
			y_offset = 0.0;
			rpReward = 20;
			xpReward = 0.003;
		}
		
		if (repairValue > 0.0 || repairPercent > 0.0) {
			//extracting the repairer's id
			int repairerId = event.getIntAttribute("character_id");
		
			//extracting the repair position
			Vector3 repairPos = stringToVector3(event.getStringAttribute("position"));
			repairPos = Vector3(repairPos.get_opIndex(0), repairPos.get_opIndex(1) + y_offset, repairPos.get_opIndex(2));
			const XmlElement@ repairer = getCharacterInfo(m_metagame,repairerId);
			if (repairer is null) return;
			int f = repairer.getIntAttribute("faction_id");
			array<const XmlElement@>@ vehicles = getAllVehicles(m_metagame, f);
			if (vehicles is null) return;
			for (uint i = 0; i < vehicles.length(); ++i) {
				//collecting vehicle positions
				Vector3 vehiclePos = stringToVector3(vehicles[i].getStringAttribute("position"));
				
				if (checkRange(repairPos, vehiclePos, range)) {
					int vehicleId = vehicles[i].getIntAttribute("id");
					const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, vehicleId);
					if (vehicleInfo !is null) {
						string vehicleKey = vehicleInfo.getStringAttribute("key");

						float vehicleHealth = vehicleInfo.getFloatAttribute("health");
						if (vehicleHealth <= 0.0) continue;
						int index = m_vehicle_norepair.find(vehicleKey);
						if (index >=0) continue;
						index = m_vehicle_nerf.find(vehicleKey);
						if (index >=0){
							repairPercent = repairPercent*1/2;
						}

						float vehicleMaxHealth = vehicleInfo.getFloatAttribute("max_health");
						float vehicleMaxOverHealth = vehicleMaxHealth * overHealth;
						
						//only running the update command when necessary
						if (vehicleHealth < vehicleMaxOverHealth) {
							//rounding error fix
							vehicleMaxOverHealth += 0.01;
							float repairValue_true = max(vehicleMaxHealth*repairPercent,repairValue);
							
							string command = "";
							
							//calculating and applying repairs
							float vehicleHealthDifference = vehicleMaxOverHealth - vehicleHealth;
							if (vehicleHealthDifference > repairValue_true){
								vehicleHealth += repairValue_true;
								vehicleHealthDifference = repairValue_true;
								command = "<command class='update_vehicle' id='" + vehicleId + "' health='" + vehicleHealth + "' />";
							} else {
								command = "<command class='update_vehicle' id='" + vehicleId + "' health='" + vehicleMaxOverHealth + "' />";
							}
							m_metagame.getComms().send(command);
							
							//rewarding the repairer
							float xpRewardFinal = xpReward;
							float rpRewardFinal = rpReward;
							if(xpRewardFinal > 0)
							{
								command = "<command class='xp_reward' character_id='" + repairerId + "' reward='" + xpRewardFinal + "' />";
								m_metagame.getComms().send(command);
							}
							if(rpRewardFinal > 0)
							{
								command = "<command class='rp_reward' character_id='" + repairerId + "' reward='" + rpRewardFinal + "' />";
								m_metagame.getComms().send(command);
							}
						}
					}
				}
			}
		}
    }
}