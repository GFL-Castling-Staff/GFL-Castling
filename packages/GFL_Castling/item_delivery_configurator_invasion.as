// generic trackers
#include "item_delivery_objective.as"
#include "item_delivery_organizer.as"
#include "gift_item_delivery_rewarder.as"

// ------------------------------------------------------------------------------------------------
class ItemDeliveryConfiguratorInvasion : ItemDeliveryConfigurator {
	protected GameModeInvasion@ m_metagame;
	protected ItemDeliveryOrganizer@ m_itemDeliveryOrganizer;

	// ------------------------------------------------------------------------------------------------
	ItemDeliveryConfiguratorInvasion(GameModeInvasion@ metagame) {
		@m_metagame = @metagame;
	}

	// --------------------------------------------
	void setup(ItemDeliveryOrganizer@ organizer) {
		@m_itemDeliveryOrganizer = @organizer;

		setupBriefcaseUnlocks();
		setupGift1();
		setupGift2();
		setupGift3();
		setupCommunity1();    
		setupCommunity2(); 
		setupCommunity3(); 
        setupCommunity4();  
        setupCommunity5();
        setupCommunity6(); 		
		setupIcecream();                
		setupEnemyWeaponUnlocks();
		setupLaptopUnlocks();
		
	}

	// --------------------------------------------
	void refresh() {
		// called each time an item unlock is removed
		refreshEnemyWeaponDeliveryObjectives();
	}

	// ----------------------------------------------------
	protected void setupLaptopUnlocks() {
		_log("adding laptop unlocks", 1);
		array<Resource@> deliveryList;
		{
			 deliveryList.insertLast(Resource("laptop.carry_item", "carry_item"));
		}

		dictionary unlockList;
		{
			string target = "laptop.carry_item";
			array<Resource@>@ list = getUnlockWeaponList2();
			unlockList.set(target, @list);
		}

		// thanks happens at ResourceUnlocker now instead at ItemDeliveryObjective, in order to avoid it when nothing to unlock anymore
		string thanks = "item objective thanks";
		ResourceUnlocker@ unlocker = ResourceUnlocker(m_metagame, 0, unlockList, m_metagame, "", thanks);

		string instructions = "item objective instruction";
		string mapText = "item objective map text";

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, mapText, "", "", -1 /* loop */)
			);
	}
	
	// ----------------------------------------------------
	protected void setupBriefcaseUnlocks() {
		_log("adding briefcase unlocks", 1);
		array<Resource@> deliveryList;
		{
			 deliveryList.insertLast(Resource("suitcase.carry_item", "carry_item"));
		}

		dictionary unlockList;
		{
			string target = "suitcase.carry_item";
			array<Resource@>@ list = getUnlockWeaponList();
			unlockList.set(target, @list);
		}
		// thanks happens at ResourceUnlocker now instead at ItemDeliveryObjective, in order to avoid it when nothing to unlock anymore
		string thanks = "item objective thanks";
		ResourceUnlocker@ unlocker = ResourceUnlocker(m_metagame, 0, unlockList, m_metagame, "", thanks);

		string instructions = "item objective instruction";
		string mapText = "item objective map text";

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, mapText, "", "", -1 /* loop */)
			);
	}

	// --------------------------------------------
	protected void processRewardPasses(array<array<ScoredResource@>>@ passes) {
		// campaign can use this to cleanup unavailable experimental resources in passes 
	}

	// --------------------------------------------
	
	// ScoredResource("key", "class", 00.0f)
	// 替换采购币
	protected void setupGift1() {
		_log("adding gift1 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_1.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gkw_ump45_410.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ump45_535.weapon", "weapon", 1.0f),
		ScoredResource("gkw_fal_2406.weapon", "weapon", 1.0f),
		ScoredResource("gkw_fal_308.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ots14_4501.weapon", "weapon", 1.0f),
		ScoredResource("gkw_supersass_1407.weapon", "weapon", 1.0f),
		ScoredResource("gkw_QBZ95_1102.weapon", "weapon", 1.0f),
		ScoredResource("gkw_QBZ95_3702.weapon", "weapon", 1.0f),
		ScoredResource("gkw_QBZ95_405.weapon", "weapon", 1.0f),
		ScoredResource("gkw_negev_904.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ameli_2409.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ameli_1605.weapon", "weapon", 1.0f),
		ScoredResource("gkw_art556_1803.weapon", "weapon", 1.0f),
		ScoredResource("gkw_art556_2803.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m99_404.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m99_1701.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m99_3304.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ntw20_307.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g36_1507.weapon", "weapon", 1.0f),
		ScoredResource("gkw_rfb_1601.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mk23_8.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp446_402.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp446_103.weapon", "weapon", 1.0f),
		ScoredResource("gkw_negev_904.weapon", "weapon", 1.0f),
		ScoredResource("gkw_fn57_1109.weapon", "weapon", 1.0f),
		ScoredResource("gkw_sat8_1802.weapon", "weapon", 1.0f),
		ScoredResource("gkw_pdw_4005.weapon", "weapon", 1.0f),
		ScoredResource("gkw_p90_2802.weapon", "weapon", 1.0f),
		ScoredResource("gkw_an94_3303.weapon", "weapon", 0.8f),
		ScoredResource("gkw_an94_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_ak12_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_ak15_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_rpk16_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_gsh18_523.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m500_3707.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m16a1_533.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m4a1_530.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ntw20_4801.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ar15_532.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ak47_501.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g3_1303.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hk416_537.weapon", "weapon", 1.0f),
		ScoredResource("gkw_9a91_1302.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g11_9.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g11_538.weapon", "weapon", 1.0f),
		ScoredResource("gkw_art556_1803.weapon", "weapon", 1.0f),
		ScoredResource("gkw_art556_2803.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ak12_2402.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hk416_3401.weapon", "weapon", 0.9f),
		ScoredResource("gentiane.carry_item", "carry_item", 0.5f),
		ScoredResource("kalina.carry_item", "carry_item", 0.5f),
		ScoredResource("gkw_idw_2108.weapon", "weapon", 2.0f),
		ScoredResource("gkw_idw_3205.weapon", "weapon", 0.9f),
		ScoredResource("gkw_idw_4908.weapon", "weapon", 2.0f)
			},
			{
		ScoredResource("bp_t5_16lab.carry_item", "carry_item", 1.0f),
		ScoredResource("cc_t5_16lab.carry_item", "carry_item", 1.0f),
		ScoredResource("exo_t5_16lab.carry_item", "carry_item", 1.0f)
			},
			{ 
		ScoredResource("icecream.projectile", "projectile", 1.0f, 1)
			}
		};
		
		processRewardPasses(rewardPasses);
		
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}
	// --------------------------------------------
	// 替换火神票
	protected void setupGift2() {
		_log("adding gift2 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_2.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
		ScoredResource("ff_agent.weapon", "weapon", 1.0f),
		ScoredResource("ff_alchemist.weapon", "weapon", 1.0f),
		ScoredResource("ff_architect.weapon", "weapon", 1.0f),
		ScoredResource("ff_destroyer.weapon", "weapon", 1.0f),
		ScoredResource("ff_gager.weapon", "weapon", 1.0f),
		ScoredResource("ff_guard.weapon", "weapon", 1.3f),
		ScoredResource("ff_hunter.weapon", "weapon", 1.0f),
		ScoredResource("ff_Intruder.weapon", "weapon", 1.0f),
		ScoredResource("ff_justice.weapon", "weapon", 1.0f),
		ScoredResource("ff_ripper.weapon", "weapon", 1.3f),
		ScoredResource("ff_scarecrow.weapon", "weapon", 1.0f),
		ScoredResource("ff_striker.weapon", "weapon", 1.3f),
		ScoredResource("ff_vespid.weapon", "weapon", 1.3f),
		ScoredResource("ff_weaver.weapon", "weapon", 1.0f),
			},
			{ 
		ScoredResource("icecream.projectile", "projectile", 1.0f, 1)
			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	// 超导脉冲
	protected void setupGift3() {
		_log("adding gift3 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_3.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("ff_agent.weapon", "weapon", 1.0f),
		ScoredResource("ff_alchemist.weapon", "weapon", 1.0f),
		ScoredResource("ff_architect.weapon", "weapon", 1.0f),
		ScoredResource("ff_destroyer.weapon", "weapon", 1.0f),
		ScoredResource("ff_gager.weapon", "weapon", 1.0f),
		ScoredResource("ff_guard.weapon", "weapon", 6.2f),
		ScoredResource("ff_hunter.weapon", "weapon", 1.0f),
		ScoredResource("ff_Intruder.weapon", "weapon", 1.0f),
		ScoredResource("ff_justice.weapon", "weapon", 1.0f),
		ScoredResource("ff_ripper.weapon", "weapon", 6.2f),
		ScoredResource("ff_scarecrow.weapon", "weapon", 1.0f),
		ScoredResource("ff_striker.weapon", "weapon", 6.2f),
		ScoredResource("ff_vespid.weapon", "weapon", 6.2f),
		ScoredResource("ff_weaver.weapon", "weapon", 6.2f),
			},
			{ 
		ScoredResource("icecream.projectile", "projectile", 1.0f, 1)
			}
		};
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity1() {
		_log("adding community box 1 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_1.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gold_bar.carry_item", "carry_item", 22.0f),
        ScoredResource("costume_lizard.carry_item", "carry_item", 20.0f),
        ScoredResource("tracer_dart.weapon", "weapon", 40.0f, 5),
		ScoredResource("gift_box_community_2.carry_item", "carry_item", 10.0f),        
        ScoredResource("flamethrower.weapon", "weapon", 15.0f),
        ScoredResource("javelin_ap.weapon", "weapon", 3.0f)         
			},
			{
         ScoredResource("banana_car_flare.projectile", "projectile", 20.0f, 2),
         ScoredResource("costume_underpants.carry_item", "carry_item", 20.0f),
         ScoredResource("taser.weapon", "weapon", 20.0f),
         ScoredResource("aa12_frag.weapon", "weapon", 15.0f),
         ScoredResource("wiesel_flare.projectile", "projectile", 20.0f, 2),
         ScoredResource("camo_vest.carry_item", "carry_item", 20.0f),
		 ScoredResource("gift_box_community_5.carry_item", "carry_item", 5.0f)                  
			}
		};   
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity2() {
		_log("adding community box 2 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_2.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("golden_knife.weapon", "weapon", 15.0f),
		ScoredResource("gift_box_community_1.carry_item", "carry_item", 10.0f),
        ScoredResource("m16a4_support.weapon", "weapon", 20.0f),        
        ScoredResource("dooms_hammer.projectile", "projectile", 35.0f, 5),
        ScoredResource("banana_peel.projectile", "projectile", 15.0f, 20),
        ScoredResource("javelin_ap.weapon", "weapon", 5.0f)         
			},
			{
         ScoredResource("costume_banana.carry_item", "carry_item", 25.0f),
         ScoredResource("fal_bayonet.weapon", "weapon", 20.0f),
         ScoredResource("dartgun.weapon", "weapon", 10.0f),
         ScoredResource("l30p.weapon", "weapon", 10.0f),
         ScoredResource("tti.weapon", "weapon", 15.0f),         
         ScoredResource("aav7_flare.projectile", "projectile", 20.0f, 2)
			}
		};   
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity3() {
		_log("adding community box 3 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_3.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		 ScoredResource("ump40.weapon", "weapon", 12.0f), 
         ScoredResource("mx4_storm.weapon", "weapon", 12.0f),
         ScoredResource("bizon.weapon", "weapon", 12.0f),
		 ScoredResource("dragons_breath.weapon", "weapon", 7.0f), 
         ScoredResource("enforcer.weapon", "weapon", 8.0f),
         ScoredResource("squall.weapon", "weapon", 8.0f),
         ScoredResource("chainsaw.weapon", "weapon", 10.0f),
         ScoredResource("emp_grenade.projectile", "projectile", 16.0f, 10),
         ScoredResource("kunai.projectile", "projectile", 15.0f, 20)
			},
            {
         ScoredResource("gps_laptop.weapon", "weapon", 17.0f, 5),
	     ScoredResource("hornet_resource.weapon", "weapon", 15.0f, 2), 
         ScoredResource("repair_crane_resource.weapon", "weapon", 15.0f, 2),
         ScoredResource("squall.weapon", "weapon", 8.0f),
         ScoredResource("costume_butcher.carry_item", "carry_item", 12.0f),        
         ScoredResource("vest_repair.weapon", "weapon", 15.0f, 10), 
         ScoredResource("guntruck_flare.projectile", "projectile", 10.0f, 2),
         ScoredResource("vulcan_acav_flare.projectile", "projectile", 8.0f, 2)
			} 
		};   

		processRewardPasses(rewardPasses);
    
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity4() {
		_log("adding community box 4 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_4.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
         ScoredResource("lottery.carry_item", "carry_item", 25.0f), 
         ScoredResource("tkb059.weapon", "weapon", 5.0f),
         ScoredResource("compound_bow.weapon", "weapon", 10.0f),
         ScoredResource("blowgun.weapon", "weapon", 12.0f),
         ScoredResource("g11.weapon", "weapon", 20.0f),
         ScoredResource("pf98.weapon", "weapon", 8.0f),                  
         ScoredResource("icecream.projectile", "projectile", 20.0f, 1)
			},
            {
         ScoredResource("gepard_m6_lynx.weapon", "weapon", 8.0f),
	     ScoredResource("golden_ak47.weapon", "weapon", 8.0f), 
         ScoredResource("zjx19_flare.projectile", "projectile", 15.0f, 2),
	     ScoredResource("portable_mortar.weapon", "weapon", 10.0f),
	     ScoredResource("rgm40.weapon", "weapon", 18.0f), 
	     ScoredResource("gl06.weapon", "weapon", 18.0f),
		 ScoredResource("gift_box_community_3.carry_item", "carry_item", 7.0f),
		 ScoredResource("gift_box_community_1.carry_item", "carry_item", 9.0f),
         ScoredResource("gift_box_community_2.carry_item", "carry_item", 8.0f),
		 ScoredResource("gift_box_community_5.carry_item", "carry_item", 5.0f)                                            
			} 
		};   

		processRewardPasses(rewardPasses);
    
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity5() {
		_log("adding community box 5 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_5.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
         ScoredResource("balloon.carry_item", "carry_item", 20.0f, 10),
         ScoredResource("vest_exo.carry_item", "carry_item", 25.0f, 5),          
         ScoredResource("suomi.weapon", "weapon", 10.0f),
         ScoredResource("ninjato.weapon", "weapon", 20.0f),
         ScoredResource("noxe_flare.projectile", "projectile", 15.0f, 2),
         ScoredResource("m528_flare.projectile", "projectile", 15.0f, 2),         
         ScoredResource("m320.weapon", "weapon", 15.0f),
         ScoredResource("p416.weapon", "weapon", 10.0f)            

			},
            {
	     ScoredResource("stim.projectile", "projectile", 25.0f, 10), 
         ScoredResource("flamer_tank_flare.projectile", "projectile", 15.0f, 2),
         ScoredResource("sev90_flare.projectile", "projectile", 15.0f, 2),                           
	     ScoredResource("chicken_carrier.weapon", "weapon", 10.0f, 5),
         ScoredResource("squad_equipment_kit.weapon", "weapon", 15.0f, 10),         
		 ScoredResource("gift_box_community_4.carry_item", "carry_item", 3.0f),         
		 ScoredResource("gift_box_community_3.carry_item", "carry_item", 4.0f),
		 ScoredResource("gift_box_community_1.carry_item", "carry_item", 6.0f),
         ScoredResource("gift_box_community_2.carry_item", "carry_item", 5.0f)                                   
			} 
		};   

		processRewardPasses(rewardPasses);
    
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------
	protected void setupCommunity6() {
		_log("adding community box 6 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_6.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
         
         ScoredResource("kulakov.weapon", "weapon", 10.0f),
         ScoredResource("rpd.weapon", "weapon", 15.0f),
         ScoredResource("ak47_w_gp25.weapon", "weapon", 15.0f),
         ScoredResource("g36_w_ag36.weapon", "weapon", 15.0f),
         ScoredResource("m16a4_w_m203.weapon", "weapon", 15.0f),			 
         ScoredResource("mac10.weapon", "weapon", 20.0f),
         ScoredResource("ash12.weapon", "weapon", 10.0f)            

			},
            {
         ScoredResource("ultimax.weapon", "weapon", 10.0f),
         ScoredResource("zweihander.weapon", "weapon", 20.0f), 
         ScoredResource("sabre.weapon", "weapon", 20.0f),
         ScoredResource("doublebarrel.weapon", "weapon", 20.0f),
         ScoredResource("golden_mp5sd.weapon", "weapon", 12.0f),		 
		 ScoredResource("gift_box_community_4.carry_item", "carry_item", 3.0f),         
		 ScoredResource("gift_box_community_3.carry_item", "carry_item", 4.0f),
		 ScoredResource("gift_box_community_5.carry_item", "carry_item", 6.0f),
         ScoredResource("gift_box_community_2.carry_item", "carry_item", 5.0f)                                   
			} 
		};   

		processRewardPasses(rewardPasses);
    
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}	
	
	// ----------------------------------------------------
	protected void setupIcecream() {
		_log("adding icecream van config", 1);
		array<Resource@> deliveryList = {
			 Resource("lottery.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{

        ScoredResource("icecream.projectile", "projectile", 1.0f, 1)
   
			},  		
        	{

		ScoredResource("cigarettes.carry_item", "carry_item", 30.0f),
        ScoredResource("playing_cards.carry_item", "carry_item", 29.0f),
        ScoredResource("cigars.carry_item", "carry_item", 28.0f),
		ScoredResource("dollars.carry_item", "carry_item", 27.0f),
		ScoredResource("teddy.carry_item", "carry_item", 26.0f),        
		ScoredResource("dollars_300.carry_item", "carry_item", 25.0f),
        ScoredResource("gem.carry_item", "carry_item", 24.0f),
		ScoredResource("laptop.carry_item", "carry_item", 23.0f),
		ScoredResource("suitcase.carry_item", "carry_item", 22.0f), 
   		ScoredResource("painting.carry_item", "carry_item", 21.0f),
		ScoredResource("gold_bar.carry_item", "carry_item", 20.0f),
		ScoredResource("cd.carry_item", "carry_item", 19.0f),        
                    
		ScoredResource("gift_box_1.carry_item", "carry_item", 38.0f),
		ScoredResource("gift_box_2.carry_item", "carry_item", 19.0f),
		ScoredResource("gift_box_3.carry_item", "carry_item", 10.0f),
		ScoredResource("gift_box_community_1.carry_item", "carry_item", 15.0f),
		ScoredResource("gift_box_community_2.carry_item", "carry_item", 15.0f),
		ScoredResource("gift_box_community_3.carry_item", "carry_item", 15.0f), 
		ScoredResource("gift_box_community_4.carry_item", "carry_item", 15.0f),                       
        		
		ScoredResource("underpants.carry_item", "carry_item", 50.0f, 2),
		ScoredResource("costume_clown.carry_item", "carry_item", 30.0f, 2),
        ScoredResource("costume_banana.carry_item", "carry_item", 25.0f, 2),
        ScoredResource("costume_lizard.carry_item", "carry_item", 20.0f, 2),                
		ScoredResource("costume_werewolf.carry_item", "carry_item", 15.0f, 2),        
		ScoredResource("vest2.carry_item", "carry_item", 28.0f, 5),
		ScoredResource("vest_blackops.carry_item", "carry_item", 25.0f, 5),
        ScoredResource("costume_butcher.carry_item", "carry_item", 20.0f, 2),
        ScoredResource("camo_vest.carry_item", "carry_item", 30.0f, 4),                
		ScoredResource("vest3.carry_item", "carry_item", 20.0f, 5),
        
        ScoredResource("banana_peel.projectile", "projectile", 50.0f, 2),
		ScoredResource("mk23.weapon", "weapon", 40.0f),
		ScoredResource("gps_laptop.weapon", "weapon", 40.0f, 5),
        ScoredResource("shuriken.projectile", "projectile", 39.0f, 20), 
        ScoredResource("kunai.projectile", "projectile", 39.0f, 20),        
        ScoredResource("emp_grenade.projectile", "projectile", 40.0f, 5),                
		ScoredResource("desert_eagle_gold.weapon", "weapon", 38.0f),
        ScoredResource("taser.weapon", "weapon", 37.0f),    
        ScoredResource("dooms_hammer.projectile", "projectile", 36.0f, 5),         
     	ScoredResource("ump40.weapon", "weapon", 35.0f),
        ScoredResource("emp_grenade.projectile", "projectile", 34.0f, 10),       
        ScoredResource("mx4_storm.weapon", "weapon", 33.0f),
        ScoredResource("bizon.weapon", "weapon", 32.0f),
        ScoredResource("m202_flash.weapon", "weapon", 31.0f, 4),
        ScoredResource("steyr_aug.weapon", "weapon", 30.0f),
        ScoredResource("vest_repair.weapon", "weapon", 30.0f, 5),           
        ScoredResource("jackhammer.weapon", "weapon", 28.0f),                       
		ScoredResource("xm25.weapon", "weapon", 27.0f),
        ScoredResource("sawnoff.weapon", "weapon", 26.0f),
        ScoredResource("l30p.weapon", "weapon", 25.0f),     
        ScoredResource("chain_saw.weapon", "weapon", 24.0f),
        ScoredResource("vss_vintorez.weapon", "weapon", 24.0f),
        ScoredResource("ns2000.weapon", "weapon", 24.0f),              
        ScoredResource("pecheneg_bullpup.weapon", "weapon", 23.0f),        
        ScoredResource("aa12_frag.weapon", "weapon", 22.0f),        
		ScoredResource("mp7.weapon", "weapon", 21.0f),
        ScoredResource("tti.weapon", "weapon", 20.0f), 
        ScoredResource("musket.weapon", "weapon", 19.0f), 
        ScoredResource("barrett_m107.weapon", "weapon", 18.0f),        
        ScoredResource("m16a4_support.weapon", "weapon", 17.0f),
        ScoredResource("tracer_dart.weapon", "weapon", 16.0f, 5), 
        ScoredResource("kriss_vector.weapon", "weapon", 15.0f),                                
        ScoredResource("ares_shrike.weapon", "weapon", 14.0f),
        ScoredResource("vest_repair.weapon", "weapon", 13.0f, 10),        
        ScoredResource("scarssr.weapon", "weapon", 12.0f),
        ScoredResource("paw20.weapon", "weapon", 11.0f),
		ScoredResource("golden_knife.weapon", "weapon", 10.0f),        
        ScoredResource("chainsaw.weapon", "weapon", 10.0f),       
        ScoredResource("fal_bayonet.weapon", "weapon", 10.0f), 
        ScoredResource("microgun.weapon", "weapon", 10.0f),
        ScoredResource("stoner62.weapon", "weapon", 10.0f),        
        ScoredResource("squall.weapon", "weapon", 8.0f),               
        ScoredResource("enforcer.weapon", "weapon", 8.0f),
		ScoredResource("dragons_breath.weapon", "weapon", 7.0f),        
        ScoredResource("flamethrower.weapon", "weapon", 7.0f), 
        ScoredResource("dartgun.weapon", "weapon", 7.0f),                       
        ScoredResource("javelin_ap.weapon", "weapon", 6.0f),
		ScoredResource("honey_badger.weapon", "weapon", 5.0f),
        ScoredResource("milkor_mgl.weapon", "weapon", 5.0f),
		ScoredResource("m60e4.weapon", "weapon", 4.0f),
        ScoredResource("lahti_l39.weapon", "weapon", 4.0f),
        ScoredResource("mg42.weapon", "weapon", 4.0f),
        ScoredResource("tkb059.weapon", "weapon", 4.0f),
        ScoredResource("compound_bow.weapon", "weapon", 10.0f),
        ScoredResource("blowgun.weapon", "weapon", 12.0f),
        ScoredResource("g11.weapon", "weapon", 8.0f),
        ScoredResource("pf98.weapon", "weapon", 8.0f),                  
        ScoredResource("gepard_m6_lynx.weapon", "weapon", 7.0f),
        ScoredResource("golden_ak47.weapon", "weapon", 5.0f), 
        ScoredResource("zjx19_flare.projectile", "projectile", 8.0f, 2),
        ScoredResource("portable_mortar.weapon", "weapon", 6.0f),
        ScoredResource("rgm40.weapon", "weapon", 25.0f), 
        ScoredResource("gl06.weapon", "weapon", 25.0f),                     
 
        ScoredResource("banana_car_flare.projectile", "projectile", 40.0f, 2),
	    ScoredResource("hornet_resource.weapon", "weapon", 50.0f, 2),        
        ScoredResource("repair_crane_resource.weapon", "weapon", 40.0f, 2),        
        ScoredResource("guntruck_flare.projectile", "projectile", 35.0f, 2),
        ScoredResource("aav7_flare.projectile", "projectile", 20.0f, 2),
        ScoredResource("wiesel_flare.projectile", "projectile", 15.0f, 2),                
        ScoredResource("vulcan_acav_flare.projectile", "projectile", 10.0f, 2),
        ScoredResource("stim.projectile", "projectile", 40.0f, 10),
        ScoredResource("balloon.carry_item", "carry_item", 20.0f, 10),
        ScoredResource("vest_exo.carry_item", "carry_item", 20.0f, 5),
        ScoredResource("squad_equipment_kit.weapon", "weapon", 20.0f, 10),
	    ScoredResource("chicken_carrier.weapon", "weapon", 10.0f, 5),
         ScoredResource("ak47_w_gp25.weapon", "weapon", 8.0f),
         ScoredResource("g36_w_ag36.weapon", "weapon", 8.0f),
         ScoredResource("m16a4_w_m203.weapon", "weapon", 8.0f)		
			} 
		};   
    
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ----------------------------------------------------  
	protected void setupEnemyWeaponUnlocks() {
		array<ItemDeliveryObjective@> objectives = createEnemyWeaponDeliveryObjectives();

		for (uint i = 0; i < objectives.size(); ++i) {
			m_itemDeliveryOrganizer.addObjective(objectives[i]);
		}
	}

	// ----------------------------------------------------
	protected array<Resource@>@ getEnemyWeaponDeliverables() const {
		array<Resource@> results;

		string type = "weapon";
		string typePlural = "weapons";

		// get the stuff we have in stock
		array<const XmlElement@> own = getFactionDeliverables(m_metagame, 0, type, typePlural);
		if (own is null) {
			_log("WARNING, getEnemyWeaponDeliverables, couldn't get own resources", -1);
			return results;
		}

		// get the grand list of deliverable weapons, all of them
		array<Resource@> deliverables = getDeliverablesList();
		for (uint i = 0; i < deliverables.size(); ++i) {
			Resource@ r = deliverables[i];
			// go through the list and only leave the ones in we're interested of, those which we don't have yet
			// check if we have this key
			bool add = true;
			for (uint j = 0; j < own.size(); ++j) {
				const XmlElement@ ownNode = own[j];
				string ownKey = ownNode.getStringAttribute("key");
				if (r.m_key != ownKey) {
					// no match, continue searching
				} else {
					// we already have this, skip it
					add = false;
					break;
				}
			}

			if (add) {
				// ensure it's not already in results
				if (results.findByRef(r) < 0) {
					results.insertLast(r);
				}
			}
		}

		return results;
	}

	// ----------------------------------------------------
	protected array<ItemDeliveryObjective@>@ createEnemyWeaponDeliveryObjectives() const {
		_log("createEnemyWeaponDeliveryObjectives", 1);

		array<ItemDeliveryObjective@> newObjectives;

		string instructions = "enemy item objective instruction";
		string thanks = "enemy item objective thanks";
		string thanksIncomplete = "enemy item objective thanks incomplete";

		// add objective for every enemy weapon not owned by friendlies yet
		array<Resource@>@ enemyWeaponResources = getEnemyWeaponDeliverables();
		for (uint i = 0; i < enemyWeaponResources.size(); ++i) {
			Resource@ resource = enemyWeaponResources[i];
			_log("enemy unlock target " + resource.m_key, 1);
			array<Resource@> deliveryList = {resource};
			// delivering certain amount of specific weapon unlocks that particular weapon
			dictionary unlockList = {
				{resource.m_key, array<Resource@> = {resource}}
			};
			ResourceUnlocker@ unlocker = ResourceUnlocker(m_metagame, 0, unlockList, m_metagame, /* custom stat tracker tag */ "enemy_weapon_delivered");

			int amount = 5;

			ItemDeliveryObjective objective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, unlocker, instructions, "", thanks, thanksIncomplete, amount, 0, 50);

			if (m_itemDeliveryOrganizer.getObjectiveById(objective.getId()) is null) {
				newObjectives.insertLast(objective);
			}			
		}

		return newObjectives;
	}

	// ----------------------------------------------------
	protected void refreshEnemyWeaponDeliveryObjectives() {
		// only creates ones that don't already exist
		array<ItemDeliveryObjective@>@ newObjectives = createEnemyWeaponDeliveryObjectives();

		for (uint i = 0; i < newObjectives.size(); ++i) {
			ItemDeliveryObjective@ objective = newObjectives[i];
			m_itemDeliveryOrganizer.addObjective(objective);
			// insta-add tracker
			m_metagame.addTracker(objective);
		}
	}

	// --------------------------------------------
	array<Resource@>@ getUnlockWeaponList() const {
		array<Resource@> list;

		list.push_back(Resource("l85a2.weapon", "weapon"));
		list.push_back(Resource("famasg1.weapon", "weapon"));
		list.push_back(Resource("sg552.weapon", "weapon"));
		list.push_back(Resource("m79.weapon", "weapon"));
		list.push_back(Resource("gl06.weapon", "weapon"));
		list.push_back(Resource("rgm40.weapon", "weapon"));                
		list.push_back(Resource("minig_resource.weapon", "weapon"));
		list.push_back(Resource("desert_eagle.weapon", "weapon"));
		list.push_back(Resource("tow_resource.weapon", "weapon"));   
		list.push_back(Resource("eodvest.carry_item", "carry_item")); 
		list.push_back(Resource("gl_resource.weapon", "weapon"));
		list.push_back(Resource("smaw.weapon", "weapon"));
		list.push_back(Resource("hornet_resource.weapon", "weapon"));        

		return list;
	}

	// --------------------------------------------
	array<Resource@>@ getUnlockWeaponList2() const {
		array<Resource@> list;

		list.push_back(Resource("mp5sd.weapon", "weapon"));
//		list.push_back(Resource("beretta_m9.weapon", "weapon"));
		list.push_back(Resource("scorpion-evo.weapon", "weapon"));
//		list.push_back(Resource("glock17.weapon", "weapon"));
		list.push_back(Resource("qcw-05.weapon", "weapon"));
//		list.push_back(Resource("pb.weapon", "weapon"));    
//    list.push_back(Resource("vest_blackops.carry_item", "carry_item")); 
		list.push_back(MultiGroupResource("vest_blackops.carry_item", "carry_item", array<string> = {"default", "supply"}));
		list.push_back(Resource("apr.weapon", "weapon")); 
//		list.push_back(Resource("mk23.weapon", "weapon")); 
		list.push_back(MultiGroupResource("mk23.weapon", "weapon", array<string> = {"default", "supply"})); 
		list.push_back(MultiGroupResource("shuriken.projectile", "projectile", array<string> = {"supply"})); 
		list.push_back(MultiGroupResource("kunai.projectile", "projectile", array<string> = {"supply"}));                        
		 
		return list;
	}
	


	// --------------------------------------------
	array<Resource@>@ getDeliverablesList() const {
		array<Resource@> list;

		// list here what we want to track as delivering to armory, with intention of unlocking that same item

		// the upgrade weapons, l85a2, famas, sg552, are considered semi-rare, only unlockable through cargo truck & suitcases, see get_unlock_weapon_list
		// in 1.31 we removed the weapons as unlockables that are not dropped by the AI 

		// green weapons
		list.push_back(Resource("m16a4.weapon", "weapon"));
		list.push_back(Resource("m240.weapon", "weapon"));
		list.push_back(Resource("m24_a2.weapon", "weapon"));
		//list.push_back(Resource("mp5sd.weapon", "weapon"));
		list.push_back(Resource("mossberg.weapon", "weapon"));
		//list.push_back(Resource("l85a2.weapon", "weapon"));
		list.push_back(Resource("m72_law.weapon", "weapon"));
		//list.push_back(Resource("beretta_m9.weapon", "weapon"));
		//list.push_back(Resource("mini_uzi.weapon", "weapon"));     

		// grey weapons
		list.push_back(Resource("g36.weapon", "weapon"));
		list.push_back(Resource("imi_negev.weapon", "weapon"));
		list.push_back(Resource("psg90.weapon", "weapon"));
		//list.push_back(Resource("scorpion-evo.weapon", "weapon"));
		list.push_back(Resource("spas-12.weapon", "weapon"));
		//list.push_back(Resource("famasg1.weapon", "weapon"));
		list.push_back(Resource("m2_carlgustav.weapon", "weapon"));
		//list.push_back(Resource("glock17.weapon", "weapon"));
		//list.push_back(Resource("steyr_tmp.weapon", "weapon"));     

		// brown weapons
		list.push_back(Resource("ak47.weapon", "weapon"));
		list.push_back(Resource("pkm.weapon", "weapon"));
		list.push_back(Resource("dragunov_svd.weapon", "weapon"));
		//list.push_back(Resource("qcw-05.weapon", "weapon"));
		list.push_back(Resource("qbs-09.weapon", "weapon"));
		//list.push_back(Resource("sg552.weapon", "weapon"));
		list.push_back(Resource("rpg-7.weapon", "weapon"));
		//list.push_back(Resource("pb.weapon", "weapon")); 
		//list.push_back(Resource("aek_919k.weapon", "weapon"));     

		return list;
	}
}
