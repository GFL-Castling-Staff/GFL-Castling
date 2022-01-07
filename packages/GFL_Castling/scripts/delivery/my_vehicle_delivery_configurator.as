#include "vehicle_delivery_configurator_invasion.as"

// ------------------------------------------------------------------------------------------------
class MyVehicleDeliveryConfigurator : VehicleDeliveryConfiguratorInvasion {
	// ------------------------------------------------------------------------------------------------
	MyVehicleDeliveryConfigurator(GameModeInvasion@ metagame) {
		super(metagame);
	}

	// --------------------------------------------
	protected array<Resource@>@ getUnlockItemList() const {
		array<Resource@> list;

		// --------------------------------------------
		// TODO:
		// - replace these with suitable items for cargo truck delivery rewards
		// --------------------------------------------

		// list.push_back(Resource("l85a2.weapon", "weapon"));
		// list.push_back(Resource("famasg1.weapon", "weapon"));
		// list.push_back(Resource("sg552.weapon", "weapon"));
		// list.push_back(Resource("m79.weapon", "weapon"));
		// list.push_back(Resource("minig_resource.weapon", "weapon"));
		// list.push_back(Resource("desert_eagle.weapon", "weapon"));
		// list.push_back(Resource("tow_resource.weapon", "weapon"));
   		// list.push_back(Resource("eodvest.carry_item", "carry_item"));   
         
		return list;
	}
}

