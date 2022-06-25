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
		setupDollCrafting();
		setupDollCrafting_AR();
		setupDollCrafting_SG();
		setupDollCrafting_SMG();
		setupDollCrafting_RF();
		setupDollCrafting_MG();
		setupDollCrafting_HG();
		setupBriefcaseUnlocks();
		setupGift1();
		setupGift2();
		setupGift3();
		setupCommunity1();    
		setupCommunity2();
		setupIcecream();                
		setupEnemyWeaponUnlocks();
		setupSFgift();
		setupArmorCraft();
		setupStuffEasterEgg();
		setupSupplyBox();
	}

	// --------------------------------------------
	void refresh() {
		// called each time an item unlock is removed
		refreshEnemyWeaponDeliveryObjectives();
	}

	protected void setupStuffEasterEgg(){
		_log("adding stuff easter box", 1);
		setupGucard();
		setupMusksocks();
		setupRegingFlamebox();
		setupAk12();
		setupSv98();
		setupNether();
		setupK309();
		setupSaiwa();
		setupZhuZhu();
		setupIDW();
		setupPPSH41();
	}
	protected void setupSupplyBox(){
		setupDreambox();
		setupSingularity();
		_log("adding supply reward box", 1);
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
	protected void setupArmorCraft() {
		array<Resource@> deliveryList = {
			 Resource("armor_crafting_card.carry_item", "carry_item")
		};
		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("bp_t5_16lab.carry_item", "carry_item", 1.0f),
		ScoredResource("exo_t5_16lab.carry_item", "carry_item", 1.0f),
		ScoredResource("cc_t5_16lab.carry_item","carry_item",1.0f)
			}
		};
		processRewardPasses(rewardPasses);
		
		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// ScoredResource("key", "class", 00.0f)
	protected void setupGift1() {
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
		ScoredResource("gkw_m99_404.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m99_1701.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m99_3304.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ntw20_307.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g36_1507.weapon", "weapon", 1.0f),
		ScoredResource("gkw_rfb_1601.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mk23_8.weapon", "weapon", 1.0f),
		ScoredResource("gkw_js9_4702.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp446_402.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp446_103.weapon", "weapon", 1.0f),
		ScoredResource("gkw_negev_3202.weapon", "weapon", 1.0f),
		ScoredResource("gkw_fn57_1109.weapon", "weapon", 1.0f),
		ScoredResource("gkw_sat8_1802.weapon", "weapon", 1.0f),
		ScoredResource("gkw_honeybadger_4005.weapon", "weapon", 1.0f),
		ScoredResource("gkw_p90_2802.weapon", "weapon", 1.0f),
		ScoredResource("gkw_an94_3303.weapon", "weapon", 1.0f),
		ScoredResource("gkw_an94_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_ak12_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_rpk16_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_ak15_blm.weapon", "weapon", 0.8f),
		ScoredResource("gkw_cz75_1604.weapon", "weapon", 0.15f),
		ScoredResource("gkw_m1895_5309.weapon", "weapon", 0.15f),
		ScoredResource("gkw_fp6_2804.weapon", "weapon", 0.15f),
		ScoredResource("gkw_hk21_4002.weapon", "weapon", 0.15f),
		ScoredResource("gkw_vp1915_6604.weapon", "weapon", 0.15f),
		ScoredResource("gkw_type89_6601.weapon", "weapon", 0.15f),
		ScoredResource("gkw_python_6603.weapon", "weapon", 0.15f),
		ScoredResource("gkw_lewis_4001.weapon", "weapon", 0.15f),
		ScoredResource("gkw_fnc_6608.weapon", "weapon", 0.15f),
		ScoredResource("gkw_sacr_5303.weapon", "weapon", 0.15f),
		ScoredResource("gkw_hs2000_5304.weapon", "weapon", 0.15f),
		ScoredResource("gkw_gsh18_523.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m500_3707.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m16a1_533.weapon", "weapon", 1.0f),
		ScoredResource("gkw_contender_3201.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m4a1_530.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ntw20_4801.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ar15_532.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ak47_501.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g3_1303.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hk416_537.weapon", "weapon", 1.0f),
		ScoredResource("gkw_9a91_1302.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g11_9.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g11_538.weapon", "weapon", 1.0f),
		ScoredResource("gkw_art556_2803.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ak12_2402.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hk416_3401.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hk416_6505.weapon", "weapon", 1.0f),
		ScoredResource("gkw_zasm21_2104.weapon", "weapon", 1.0f),
		ScoredResource("gentiane.carry_item", "carry_item", 0.5f),
		ScoredResource("kalina.carry_item", "carry_item", 0.5f),
		ScoredResource("m1903.carry_item", "carry_item", 0.5f),
		ScoredResource("jill.carry_item", "carry_item", 0.5f),
		ScoredResource("light.carry_item", "carry_item", 0.5f),
		ScoredResource("gkw_idw_2108.weapon", "weapon", 1.0f),
		ScoredResource("gkw_idw_3205.weapon", "weapon", 1.0f),
		ScoredResource("gkw_idw_4908.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ak74u_3002.weapon", "weapon", 1.0f),
		ScoredResource("gkw_t91_4206.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mk23_1805.weapon", "weapon", 1.0f),
		ScoredResource("gkw_nz75_403.weapon", "weapon", 1.0f),
		ScoredResource("gkw_spp1_4207.weapon", "weapon", 1.0f),
		ScoredResource("gkw_lwmmg_1808.weapon", "weapon", 1.0f),
		ScoredResource("gkw_svd_5506.weapon", "weapon", 1.0f),
		ScoredResource("gkw_augpara_5503.weapon", "weapon", 1.0f),
		ScoredResource("gkw_defender_5505.weapon", "weapon", 1.0f),
		ScoredResource("gkw_tkb408_6804.weapon", "weapon", 1.0f),
		ScoredResource("gkw_aps_6808.weapon", "weapon", 1.0f),
		ScoredResource("gkw_aa12_4401.weapon","weapon", 1.0f),
		ScoredResource("gkw_mp5_3.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp5_1205.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp5_1903.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp5_3006.weapon", "weapon", 1.0f),
		ScoredResource("gkw_mp7_6806.weapon", "weapon", 1.0f),
		ScoredResource("gkw_kolibri_6802.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hs50_6805.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m4sopmodii_531.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m1918_102.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m1918_806.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m1918_1606.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ksvk_3405.weapon", "weapon", 1.0f),
		ScoredResource("gkw_ksvk_3805.weapon", "weapon", 1.0f),
		ScoredResource("gkw_tar21_1305.weapon", "weapon", 1.0f),
		ScoredResource("gkw_thunder_2206.weapon", "weapon", 1.0f),
		ScoredResource("gkw_spas12_2408.weapon", "weapon", 1.0f),
		ScoredResource("gkw_spas12_3203.weapon", "weapon", 1.0f),
		ScoredResource("gkw_g41_2401.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m950a_702.weapon", "weapon", 1.0f),
		ScoredResource("gkw_m37_1105.weapon", "weapon", 1.0f),
		ScoredResource("gkw_type100_4004.weapon","weapon",1.0f),
		ScoredResource("gkw_m870_3803.weapon", "weapon", 1.0f)
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
		ScoredResource("ff_hunter.weapon", "weapon", 1.0f),
		ScoredResource("ff_excutioner_1.weapon", "weapon", 1.0f),
		ScoredResource("ff_parw_alina.weapon", "weapon", 1.0f),
		ScoredResource("ff_Intruder.weapon", "weapon", 1.0f),
		ScoredResource("ff_parw_nyto_black.weapon", "weapon", 1.0f),
		ScoredResource("ff_justice.weapon", "weapon", 1.0f),
		ScoredResource("ff_dreamer.weapon", "weapon", 1.0f),
		ScoredResource("ff_ripper.weapon", "weapon", 2.0f),
		ScoredResource("ff_scarecrow.weapon", "weapon", 1.0f),
		ScoredResource("ff_striker.weapon", "weapon", 2.0f),
		ScoredResource("ff_weaver.weapon", "weapon", 1.0f)
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
		ScoredResource("ff_agent.weapon", "weapon", 0.3f),
		ScoredResource("ff_parw_nyto_black.weapon", "weapon", 0.3f),
		ScoredResource("ff_parw_alina.weapon", "weapon", 0.3f),
		ScoredResource("ff_alchemist.weapon", "weapon", 0.3f),
		ScoredResource("ff_gager.weapon", "weapon", 0.3f),
		ScoredResource("ff_excutioner_1.weapon", "weapon", 0.3f),
		ScoredResource("ff_guard.weapon", "weapon", 30.0f),
		ScoredResource("ff_hunter.weapon", "weapon", 0.3f),
		ScoredResource("ff_Intruder.weapon", "weapon", 0.3f),
		ScoredResource("ff_justice.weapon", "weapon", 0.3f),
		ScoredResource("ff_ripper.weapon", "weapon", 30.0f),
		ScoredResource("ff_dreamer.weapon", "weapon", 0.3f),
		ScoredResource("ff_scarecrow.weapon", "weapon", 0.3f),
		ScoredResource("ff_striker.weapon", "weapon", 30.0f),
		ScoredResource("ff_vespid.weapon", "weapon", 30.0f)
			}
		};
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// MOD3采购币（测试）----------------------------------------------------
	protected void setupCommunity1() {
		_log("adding community box 1 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_1.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
				ScoredResource("gkw_hk416_6505_mod3.weapon", "weapon", 1.0f),   
				ScoredResource("gkw_hk416_537_mod3.weapon", "weapon", 1.0f),
				ScoredResource("gkw_hk416_3401_mod3.weapon", "weapon", 1.0f),
				ScoredResource("gkw_g11mod3_9.weapon", "weapon", 1.0f),
				ScoredResource("gkw_g11mod3_538.weapon", "weapon", 1.0f),
				ScoredResource("gkw_ntw20mod3_307.weapon", "weapon", 1.0f),
				ScoredResource("gkw_ntw20mod3_4801.weapon", "weapon", 1.0f),
				ScoredResource("gkw_idwmod3_2108.weapon", "weapon", 1.0f),
				ScoredResource("gkw_idwmod3_3205.weapon", "weapon", 1.0f),
				ScoredResource("gkw_idwmod3_4908.weapon", "weapon", 1.0f),
				ScoredResource("gkw_m4a1mod3_530.weapon", "weapon", 1.0f),
				ScoredResource("gkw_ar15mod3_532.weapon", "weapon", 1.0f),
				ScoredResource("gkw_ump45mod3_410.weapon", "weapon", 1.0f),
				ScoredResource("gkw_ump45mod3_535.weapon", "weapon", 1.0f),
				ScoredResource("gkw_supersassmod3_1407.weapon", "weapon", 1.0f),
				ScoredResource("gkw_gsh18mod3_523.weapon", "weapon", 1.0f),
				ScoredResource("gkw_an94mod3_3303.weapon","weapon",1.0f),
				ScoredResource("gkw_an94mod3_blm.weapon","weapon",1.0f),
				ScoredResource("gkw_m4sopmodiimod3_531.weapon","weapon",1.0f),
				ScoredResource("gkw_lwmmgmod3_1808.weapon","weapon",1.0f),
				ScoredResource("gkw_mp5mod3_3.weapon","weapon",1.0f),
				ScoredResource("gkw_mp5mod3_1205.weapon","weapon",1.0f),
				ScoredResource("gkw_mp5mod3_1903.weapon","weapon",1.0f),
				ScoredResource("gkw_mp5mod3_3006.weapon","weapon",1.0f),
				ScoredResource("gkw_m1918mod3_102.weapon","weapon",1.0f),
				ScoredResource("gkw_m1918mod3_806.weapon","weapon",1.0f),
				ScoredResource("gkw_m1918mod3_1606.weapon","weapon",1.0f),
				ScoredResource("gkw_ksvkmod3_3405.weapon","weapon",1.0f),
				ScoredResource("gkw_ksvkmod3_3805.weapon","weapon",1.0f),
				ScoredResource("gkw_m1895mod3_5309.weapon","weapon",1.0f),
				ScoredResource("gkw_g36mod3_1507.weapon","weapon",1.0f)
			}
		};   
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// 圣诞币替换----------------------------------------------------
	protected void setupCommunity2() {
		_log("adding community box 2 config", 1);
		array<Resource@> deliveryList = {
			 Resource("gift_box_community_2.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gkw_cz75_1604.weapon", "weapon", 0.45f),
		ScoredResource("gkw_m1895_5309.weapon", "weapon", 0.45f),
		ScoredResource("gkw_fp6_2804.weapon", "weapon", 0.45f),
		ScoredResource("gkw_hk21_4002.weapon", "weapon", 0.45f),
		ScoredResource("gkw_vp1915_6604.weapon", "weapon", 0.45f),
		ScoredResource("gkw_type89_6601.weapon", "weapon", 0.45f),
		ScoredResource("gkw_python_6603.weapon", "weapon", 0.45f),
		ScoredResource("gkw_lewis_4001.weapon", "weapon", 0.45f),
		ScoredResource("gkw_fnc_6608.weapon", "weapon", 0.45f),
		ScoredResource("gkw_sacr_5303.weapon", "weapon", 0.45f),
		ScoredResource("gkw_hs2000_5304.weapon", "weapon", 0.45f)    
			},
			{
		ScoredResource("snow_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("wild_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("sweet_bomb_box.carry_item", "carry_item", 0.0001f),
		ScoredResource("ice_theatre.carry_item", "carry_item", 0.001f),
		ScoredResource("SOPII_Ant_Doll.carry_item", "carry_item", 0.5f),
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 1.6f)
			},
			{
		ScoredResource("costume_santa.carry_item", "carry_item", 1.0f)
			}
		};   
			
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupSFgift() {
		array<Resource@> deliveryList = {
			 Resource("sf_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("city_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("wild_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("snow_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("forest_gifts.carry_item", "carry_item", 1.0f, 40),
		ScoredResource("gift_box_community_2.carry_item", "carry_item", 0.01f),
		ScoredResource("SOPII_Ant_Doll.carry_item", "carry_item", 0.1f),
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 0.2f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupDreambox() {
		array<Resource@> deliveryList = {
			Resource("complete_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 15.0f),
		ScoredResource("city_gifts.carry_item", "carry_item", 10.0f, 10),
		ScoredResource("wild_gifts.carry_item", "carry_item", 10.0f, 10),
		ScoredResource("snow_gifts.carry_item", "carry_item", 10.0f, 10),
		ScoredResource("forest_gifts.carry_item", "carry_item", 10.0f, 10),	
		ScoredResource("gift_box_1.carry_item", "carry_item", 30.0f,3),
		ScoredResource("firecontrol.carry_item", "carry_item", 10.0f,1),
		ScoredResource("gift_box_2.carry_item", "carry_item", 15.0f,1),
		ScoredResource("lottery.carry_item", "carry_item", 20.0f,3),
		ScoredResource("core_mask.carry_item", "carry_item", 5.0f,1),
		ScoredResource("dollcraft.carry_item", "carry_item", 40.0f,5)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}
	protected void setupSingularity() {
		array<Resource@> deliveryList = {
			Resource("complete_box_singularity.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 15.0f),
		ScoredResource("wild_gifts.carry_item", "carry_item", 10.0f, 10),
		ScoredResource("snow_gifts.carry_item", "carry_item", 10.0f, 10),
		ScoredResource("gift_box_1.carry_item", "carry_item", 30.0f,3),
		ScoredResource("firecontrol.carry_item", "carry_item", 15.0f,1),
		ScoredResource("gift_box_2.carry_item", "carry_item", 15.0f,1),
		ScoredResource("lottery.carry_item", "carry_item", 20.0f,3),
		ScoredResource("core_mask.carry_item", "carry_item", 5.0f,1),
		ScoredResource("dollcraft.carry_item", "carry_item", 40.0f,5)
			},
			{
		// ScoredResource("gkw_hk21.weapon", "weapon", 0.5f),
		ScoredResource("gkw_mp7.weapon", "weapon", 0.5f),
		ScoredResource("gkw_ballista.weapon", "weapon", 0.5f),
		// ScoredResource("gkw_cz2000.weapon", "weapon", 0.5f),
		ScoredResource("gkw_honeybadger.weapon", "weapon", 0.5f),
		ScoredResource("gkw_thunder.weapon", "weapon", 0.5f),
		ScoredResource("wild_gifts.carry_item", "carry_item", 3.0f,5)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	// 替换彩票----------------------------------------------------
	protected void setupIcecream() {
		_log("adding icecream van config", 1);
		array<Resource@> deliveryList = {
			 Resource("lottery.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
      	ScoredResource("double_enjoyment_package.carry_item", "carry_item", 0.00001f),
		ScoredResource("holy_meat_buns.carry_item", "carry_item", 0.000001f),
		ScoredResource("sweet_bomb_box.carry_item", "carry_item", 0.00001f),
		ScoredResource("ice_theatre.carry_item", "carry_item", 0.0001f),
		ScoredResource("SOPII_Ant_Doll.carry_item", "carry_item", 0.5f),
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 1.6f),
		ScoredResource("kalina.carry_item", "carry_item", 1.0f),
		ScoredResource("city_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("wild_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("snow_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("forest_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("gentiane.carry_item", "carry_item", 1.0f),
		ScoredResource("m1903.carry_item", "carry_item", 1.0f),
		ScoredResource("jill.carry_item", "carry_item", 1.0f),
		ScoredResource("light.carry_item", "carry_item", 1.0f),
		ScoredResource("ange.carry_item", "carry_item", 1.0f),
		ScoredResource("dandelion.carry_item", "carry_item", 1.0f),
		ScoredResource("dima.carry_item", "carry_item", 1.0f),
		ScoredResource("K309.carry_item", "carry_item", 0.7f),
		ScoredResource("IAQS.carry_item", "carry_item", 0.7f),
		ScoredResource("NZ75.carry_item", "carry_item", 0.7f),
		ScoredResource("bakery_jefuty.carry_item", "carry_item", 0.7f),
		ScoredResource("gkw_ltlx7000_icecream.weapon", "weapon", 0.5f),
		ScoredResource("gkw_consume_javelin.weapon", "weapon", 0.5f,5),
		ScoredResource("woshieoe.carry_item", "carry_item", 0.7f),
		ScoredResource("gkw_yurine.weapon","weapon",0.7f)
			}
		};
    
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupGucard() {
    array<Resource@> deliveryList = {
         Resource("kudan_box.carry_item", "carry_item")
    };

    array<array<ScoredResource@>> rewardPasses = {
        {
    ScoredResource("gu_card.carry_item", "carry_item", 1.0f)
        }
    };
    processRewardPasses(rewardPasses);

    GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

    m_itemDeliveryOrganizer.addObjective(
        ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
        );
}

	protected void setupMusksocks() {
		array<Resource@> deliveryList = {
			Resource("musksocks_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("zas_paint.carry_item", "carry_item", 1.0f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupPPSH41() {
		array<Resource@> deliveryList = {
			Resource("ppsh_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("shasha.carry_item", "carry_item", 1.0f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupRegingFlamebox() {
		array<Resource@> deliveryList = {
			Resource("regingflame_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gkw_hvy_at4.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hvy_qlz04.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hvy_m2.weapon", "weapon", 1.0f),
		ScoredResource("gkw_hvy_mk153.weapon", "weapon", 1.0f),
		ScoredResource("gkw_type100_banzai.weapon", "weapon", 1.0f)
			},
			{
		ScoredResource("gkw_88rocker.weapon", "weapon", 1.0f, 40),
		ScoredResource("hand_88grenade.projectile", "projectile", 1.0f, 40),
		ScoredResource("kcco_smartgrenade_1.projectile", "projectile", 1.0f, 40),
		ScoredResource("c4.projectile", "projectile", 1.0f, 40),
		ScoredResource("parw_grenade.projectile", "projectile", 1.0f, 40)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupAk12() {
		array<Resource@> deliveryList = {
			Resource("ak12_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("red_tides.carry_item", "carry_item", 1.0f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupSv98() {
		array<Resource@> deliveryList = {
			Resource("sv98_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("fadan.carry_item", "carry_item", 1.0f),
		ScoredResource("fadan.carry_item", "carry_item", 0.02f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupNether() {
		array<Resource@> deliveryList = {
			Resource("nether_crow_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("SOPII_Ant_Doll.carry_item", "carry_item", 1.0f, 2)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupK309() {
		array<Resource@> deliveryList = {
			Resource("k309_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("k309_dowry.carry_item", "carry_item", 1.0f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupIDW() {
		array<Resource@> deliveryList = {
			Resource("idw_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gkw_idw.weapon", "weapon", 1.0f,100)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}
	
	protected void setupSaiwa() {
		array<Resource@> deliveryList = {
			Resource("saiwa_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gkw_m14mod3.weapon", "weapon", 1.0f)
			},
			{
		ScoredResource("gkw_consume_javelin.weapon", "weapon", 1.0f, 2)
			},
			{
		ScoredResource("kcco_smartgrenade_1.projectile", "projectile", 1.0f, 4)
			},
			{
		ScoredResource("cc_t5_16lab.carry_item", "carry_item", 1.0f)
			},
			{
		ScoredResource("saiwa_juggernaut.carry_item", "carry_item", 1.0f)
			}
		};
		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
			);
	}

	protected void setupZhuZhu() {
		array<Resource@> deliveryList = {
			Resource("Zhuzhu_box.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{
		ScoredResource("gu_card.carry_item", "carry_item", 1.0f),
		ScoredResource("", "carry_item", 9.0f)
			},
			{
		ScoredResource("416_nukenade.carry_item", "carry_item", 1.0f),
		ScoredResource("", "carry_item", 19.0f)
			},			
			{
		ScoredResource("city_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("wild_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("snow_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("forest_gifts.carry_item", "carry_item", 1.0f, 20),
		ScoredResource("SOPII_Ant_Doll.carry_item", "carry_item", 0.5f),
		ScoredResource("RO365_Ant_Doll.carry_item", "carry_item", 1.0f)
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

		list.push_back(Resource("gkw_m2hb.weapon", "weapon"));
		list.push_back(Resource("gkw_spas12.weapon", "weapon"));
		list.push_back(Resource("gkw_mg42.weapon", "weapon"));
		list.push_back(Resource("gkw_uzi.weapon", "weapon"));
		list.push_back(Resource("gkw_supersass.weapon", "weapon"));
		list.push_back(Resource("gkw_mp5.weapon", "weapon"));
		list.push_back(Resource("gkw_m1897.carry_item", "carry_item")); 
		list.push_back(Resource("gkw_m1014.weapon", "weapon"));
		list.push_back(Resource("gkw_svd.weapon", "weapon"));
		list.push_back(Resource("gkw_fal.weapon", "weapon"));        
		list.push_back(Resource("gkw_desert_eagle.weapon", "weapon"));        
		list.push_back(Resource("gkw_mk23.weapon", "weapon"));        

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

		return list;
	}

	protected void setupDollCrafting() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_arx160.weapon", "weapon", 0.6f),
				ScoredResource("gkw_ash127.weapon", "weapon", 0.6f),
				ScoredResource("gkw_c14.weapon", "weapon", 0.6f),
				ScoredResource("gkw_c96.weapon", "weapon", 0.6f),
				ScoredResource("gkw_gm6.weapon", "weapon", 0.6f),
				ScoredResource("gkw_gsh18.weapon", "weapon", 0.6f),
				// ScoredResource("gkw_hk21.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m1.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m1a1.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m21.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m249saw.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m9.weapon", "weapon", 0.6f),
				ScoredResource("gkw_mg42.weapon", "weapon", 0.6f),
				ScoredResource("gkw_p226.weapon", "weapon", 0.6f),
				ScoredResource("gkw_pps43.weapon", "weapon", 0.6f),
				ScoredResource("gkw_qsb91.weapon", "weapon", 0.6f),
				ScoredResource("gkw_rpd.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m2hb.weapon", "weapon", 0.6f),
				ScoredResource("gkw_uzi.weapon", "weapon", 0.6f),
				ScoredResource("gkw_supersass.weapon", "weapon", 0.6f),
				// ScoredResource("gkw_t-cms.weapon", "weapon", 0.6f),
				ScoredResource("gkw_ks23.weapon", "weapon", 0.6f),


				ScoredResource("gkw_m1908.weapon", "weapon", 0.3f),
				ScoredResource("gkw_4type.weapon", "weapon", 0.3f),
				ScoredResource("gkw_9a91.weapon", "weapon", 0.3f),
				ScoredResource("gkw_aek999.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ak74m.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ameli.weapon", "weapon", 0.3f),
				ScoredResource("gkw_apc556.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ar57.weapon", "weapon", 0.3f),
				ScoredResource("gkw_asval.weapon", "weapon", 0.3f),
				ScoredResource("gkw_cz100.weapon", "weapon", 0.3f),
				ScoredResource("gkw_famas.weapon", "weapon", 0.3f),
				ScoredResource("gkw_fara83.weapon", "weapon", 0.3f),
				ScoredResource("gkw_fx05.weapon", "weapon", 0.3f),
				ScoredResource("gkw_g28.weapon", "weapon", 0.3f),
				ScoredResource("gkw_g36.weapon", "weapon", 0.3f),
				ScoredResource("gkw_honeybadger.weapon", "weapon", 0.3f),
				ScoredResource("gkw_k31.weapon", "weapon", 0.3f),
				ScoredResource("gkw_klin.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ksvk.weapon", "weapon", 0.3f),
				ScoredResource("gkw_liberator.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1014.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1897.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1903.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m60.weapon", "weapon", 0.3f),
				// ScoredResource("gkw_mg3.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk23.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk46.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk48.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mp446.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mp5.weapon", "weapon", 0.3f),
				ScoredResource("gkw_p7.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pp19.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pp90.weapon", "weapon", 0.3f),
				ScoredResource("gkw_psg1.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ribeyrolles.weapon", "weapon", 0.3f),
				ScoredResource("gkw_supershorty.weapon", "weapon", 0.3f),
				ScoredResource("gkw_svd.weapon", "weapon", 0.3f),
				ScoredResource("gkw_tar21.weapon", "weapon", 0.3f),
				ScoredResource("gkw_thunder.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump40.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump45.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump9.weapon", "weapon", 0.3f),
				ScoredResource("gkw_usas12.weapon", "weapon", 0.3f),
				ScoredResource("gkw_xm3.weapon", "weapon", 0.3f),
				ScoredResource("gkw_xm8.weapon", "weapon", 0.3f),
				ScoredResource("gkw_spas12.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pk.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m37.weapon", "weapon", 0.3f),


				ScoredResource("gkw_type89.weapon", "weapon", 0.2f),
				ScoredResource("gkw_QBZ95.weapon", "weapon", 0.2f),
				ScoredResource("gkw_QBZ97.weapon", "weapon", 0.2f),
				ScoredResource("gkw_aa12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_acr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak15.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak74u.weapon", "weapon", 0.2f),
				ScoredResource("gkw_akalfa.weapon", "weapon", 0.2f),
				ScoredResource("gkw_art556.weapon", "weapon", 0.2f),
				ScoredResource("gkw_c93.weapon", "weapon", 0.2f),
				ScoredResource("gkw_caws.weapon", "weapon", 0.2f),
				ScoredResource("gkw_python.weapon", "weapon", 0.2f),
				ScoredResource("gkw_contender.weapon", "weapon", 0.2f),
				ScoredResource("gkw_cz75.weapon", "weapon", 0.2f),
				ScoredResource("gkw_nz75.weapon", "weapon", 0.2f),
				ScoredResource("gkw_desert_eagle.weapon", "weapon", 0.2f),
				ScoredResource("gkw_dp12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_dsr50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_fal.weapon", "weapon", 0.2f),
				ScoredResource("gkw_g11.weapon", "weapon", 0.2f),
				ScoredResource("gkw_g36c.weapon", "weapon", 0.2f),
				ScoredResource("gkw_g41.weapon", "weapon", 0.2f),
				ScoredResource("gkw_grizzly.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hk416.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hp35.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hs2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hs50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_iws2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_js05.weapon", "weapon", 0.2f),
				ScoredResource("gkw_js9.weapon", "weapon", 0.2f),
				ScoredResource("gkw_98k.weapon", "weapon", 0.2f),
				ScoredResource("gkw_kolibri.weapon", "weapon", 0.2f),
				ScoredResource("gkw_kord.weapon", "weapon", 0.2f),
				ScoredResource("gkw_kp31.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ksg.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mlemk1.weapon", "weapon", 0.2f),
				ScoredResource("gkw_lewis.weapon", "weapon", 0.2f),
				ScoredResource("gkw_carcano1891.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m200.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m82a1.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m870.weapon", "weapon", 0.2f),
				ScoredResource("gkw_carcano1938.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m950a.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m99.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mdr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mg5.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mp7.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ntw20.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ots14.weapon", "weapon", 0.2f),
				ScoredResource("gkw_p22.weapon", "weapon", 0.2f),
				ScoredResource("gkw_p90.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pa15.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pm06.weapon", "weapon", 0.2f),
				ScoredResource("gkw_qbz191.weapon", "weapon", 0.2f),
				ScoredResource("gkw_qjy88.weapon", "weapon", 0.2f),
				ScoredResource("gkw_r5.weapon", "weapon", 0.2f),
				ScoredResource("gkw_zasm21.weapon","weapon",0.2f),
				ScoredResource("gkw_r93.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rfb.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rpk16.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sat8.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sacr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sigmcx.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sig556.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sp9.weapon", "weapon", 0.2f),
				ScoredResource("gkw_srs.weapon", "weapon", 0.2f),
				ScoredResource("gkw_svch.weapon", "weapon", 0.2f),
				ScoredResource("gkw_t91.weapon", "weapon", 0.2f),
				ScoredResource("gkw_tac50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_thompson.weapon", "weapon", 0.2f),
				ScoredResource("gkw_tkb408.weapon", "weapon", 0.2f),
				ScoredResource("gkw_type100.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vector.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vhs.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vsk94.weapon", "weapon", 0.2f),
				ScoredResource("gkw_wa2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_webley.weapon", "weapon", 0.2f),
				ScoredResource("gkw_welrod.weapon", "weapon", 0.2f),
				ScoredResource("gkw_x95.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sr3mp.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pkp.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ballista.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ltlx7000.weapon","weapon",0.2f),
				ScoredResource("gkw_mg4.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rpk203.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mg338.weapon", "weapon", 0.2f),
				ScoredResource("gkw_saiga12.weapon","weapon",0.2f),
				ScoredResource("gkw_fo12.weapon","weapon",0.2f),
				ScoredResource("gkw_vp1915.weapon", "weapon", 0.2f),
				ScoredResource("gkw_fp6.weapon", "weapon", 0.2f),
				ScoredResource("gkw_cms.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sl8.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sterling.weapon", "weapon", 0.2f),
				ScoredResource("gkw_negev.weapon", "weapon", 0.2f)

			},
			{
				ScoredResource("core_mask.carry_item", "carry_item", 1.0f),
				ScoredResource("", "carry_item", 99.0f)
			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}
	protected void setupDollCrafting_HG() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_hg.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_c96.weapon", "weapon", 0.6f),
				ScoredResource("gkw_gsh18.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m9.weapon", "weapon", 0.6f),
				ScoredResource("gkw_p226.weapon", "weapon", 0.6f),

				ScoredResource("gkw_cz100.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk23.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mp446.weapon", "weapon", 0.3f),
				ScoredResource("gkw_p7.weapon", "weapon", 0.3f),
				ScoredResource("gkw_thunder.weapon", "weapon", 0.3f),

				ScoredResource("gkw_c93.weapon", "weapon", 0.2f),
				ScoredResource("gkw_python.weapon", "weapon", 0.2f),
				ScoredResource("gkw_contender.weapon", "weapon", 0.2f),
				ScoredResource("gkw_cz75.weapon", "weapon", 0.2f),
				ScoredResource("gkw_nz75.weapon", "weapon", 0.2f),
				ScoredResource("gkw_desert_eagle.weapon", "weapon", 0.2f),
				ScoredResource("gkw_grizzly.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hp35.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hs2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_kolibri.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m950a.weapon", "weapon", 0.2f),
				ScoredResource("gkw_p22.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pa15.weapon", "weapon", 0.2f),
				ScoredResource("gkw_webley.weapon", "weapon", 0.2f),
				ScoredResource("gkw_welrod.weapon", "weapon", 0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}
	protected void setupDollCrafting_SMG() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_smg.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_pps43.weapon", "weapon", 0.6f),
				ScoredResource("gkw_uzi.weapon", "weapon", 0.6f),
				// ScoredResource("gkw_t-cms.weapon", "weapon", 0.6f),

				ScoredResource("gkw_honeybadger.weapon", "weapon", 0.3f),
				ScoredResource("gkw_klin.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mp5.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pp19.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pp90.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump40.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump45.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ump9.weapon", "weapon", 0.3f),

				ScoredResource("gkw_g36c.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak74u.weapon", "weapon", 0.2f),
				ScoredResource("gkw_js9.weapon", "weapon", 0.2f),
				ScoredResource("gkw_kp31.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mp7.weapon", "weapon", 0.2f),
				ScoredResource("gkw_p90.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vp1915.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pm06.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sp9.weapon", "weapon", 0.2f),
				ScoredResource("gkw_thompson.weapon", "weapon", 0.2f),
				ScoredResource("gkw_type100.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vector.weapon", "weapon", 0.2f),
				ScoredResource("gkw_x95.weapon", "weapon", 0.2f),
				ScoredResource("gkw_cms.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sterling.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sr3mp.weapon", "weapon", 0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}	
	protected void setupDollCrafting_AR() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_ar.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_arx160.weapon", "weapon", 0.6f),
				ScoredResource("gkw_ash127.weapon", "weapon", 0.6f),

				ScoredResource("gkw_9a91.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ak74m.weapon", "weapon", 0.3f),
				ScoredResource("gkw_apc556.weapon", "weapon", 0.3f),
				ScoredResource("gkw_asval.weapon", "weapon", 0.3f),
				ScoredResource("gkw_famas.weapon", "weapon", 0.3f),
				ScoredResource("gkw_fara83.weapon", "weapon", 0.3f),
				ScoredResource("gkw_fx05.weapon", "weapon", 0.3f),
				ScoredResource("gkw_g36.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ribeyrolles.weapon", "weapon", 0.3f),
				ScoredResource("gkw_tar21.weapon", "weapon", 0.3f),
				ScoredResource("gkw_xm8.weapon", "weapon", 0.3f),

				ScoredResource("gkw_type89.weapon", "weapon", 0.2f),
				ScoredResource("gkw_QBZ95.weapon", "weapon", 0.2f),
				ScoredResource("gkw_QBZ97.weapon", "weapon", 0.2f),
				ScoredResource("gkw_acr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ak15.weapon", "weapon", 0.2f),
				ScoredResource("gkw_akalfa.weapon", "weapon", 0.2f),
				ScoredResource("gkw_art556.weapon", "weapon", 0.2f),
				ScoredResource("gkw_fal.weapon", "weapon", 0.2f),
				ScoredResource("gkw_g11.weapon", "weapon", 0.2f),
				ScoredResource("gkw_g41.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hk416.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mdr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ots14.weapon", "weapon", 0.2f),
				ScoredResource("gkw_qbz191.weapon", "weapon", 0.2f),
				ScoredResource("gkw_r5.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rfb.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sacr.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sigmcx.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sig556.weapon", "weapon", 0.2f),
				ScoredResource("gkw_t91.weapon", "weapon", 0.2f),
				ScoredResource("gkw_tkb408.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vhs.weapon", "weapon", 0.2f),
				ScoredResource("gkw_zasm21.weapon","weapon",0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}
	protected void setupDollCrafting_RF() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_rf.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_c14.weapon", "weapon", 0.6f),
				ScoredResource("gkw_gm6.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m1.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m1a1.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m21.weapon", "weapon", 0.6f),
				ScoredResource("gkw_supersass.weapon", "weapon", 0.6f),

				ScoredResource("gkw_m1908.weapon", "weapon", 0.3f),
				ScoredResource("gkw_4type.weapon", "weapon", 0.3f),
				ScoredResource("gkw_g28.weapon", "weapon", 0.3f),
				ScoredResource("gkw_g36.weapon", "weapon", 0.3f),
				ScoredResource("gkw_k31.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ksvk.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1903.weapon", "weapon", 0.3f),
				ScoredResource("gkw_psg1.weapon", "weapon", 0.3f),
				ScoredResource("gkw_svd.weapon", "weapon", 0.3f),
				ScoredResource("gkw_xm3.weapon", "weapon", 0.3f),

				ScoredResource("gkw_dsr50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_hs50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_iws2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_js05.weapon", "weapon", 0.2f),
				ScoredResource("gkw_98k.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mlemk1.weapon", "weapon", 0.2f),
				ScoredResource("gkw_carcano1891.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m200.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m82a1.weapon", "weapon", 0.2f),
				ScoredResource("gkw_carcano1938.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m99.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ntw20.weapon", "weapon", 0.2f),
				ScoredResource("gkw_r93.weapon", "weapon", 0.2f),
				ScoredResource("gkw_srs.weapon", "weapon", 0.2f),
				ScoredResource("gkw_svch.weapon", "weapon", 0.2f),
				ScoredResource("gkw_tac50.weapon", "weapon", 0.2f),
				ScoredResource("gkw_vsk94.weapon", "weapon", 0.2f),
				ScoredResource("gkw_wa2000.weapon", "weapon", 0.2f),
				ScoredResource("gkw_sl8.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ballista.weapon", "weapon", 0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}
	protected void setupDollCrafting_SG() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_sg.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_ks23.weapon", "weapon", 0.6f),

				ScoredResource("gkw_liberator.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1014.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m1897.weapon", "weapon", 0.3f),
				ScoredResource("gkw_supershorty.weapon", "weapon", 0.3f),
				ScoredResource("gkw_usas12.weapon", "weapon", 0.3f),
				ScoredResource("gkw_spas12.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m37.weapon", "weapon", 0.3f),

				ScoredResource("gkw_aa12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_caws.weapon", "weapon", 0.2f),
				ScoredResource("gkw_dp12.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ksg.weapon", "weapon", 0.2f),
				ScoredResource("gkw_m870.weapon", "weapon", 0.2f),
				ScoredResource("gkw_saiga12.weapon","weapon",0.2f),
				ScoredResource("gkw_fo12.weapon","weapon",0.2f),
				ScoredResource("gkw_sat8.weapon", "weapon", 0.2f),
				ScoredResource("gkw_fp6.weapon", "weapon", 0.2f),
				ScoredResource("gkw_ltlx7000.weapon","weapon",0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}
	protected void setupDollCrafting_MG() {
		array<Resource@> deliveryList = {
			 Resource("dollcraft_mg.carry_item", "carry_item")
		};

		array<array<ScoredResource@>> rewardPasses = {
			{	
				ScoredResource("gkw_m249saw.weapon", "weapon", 0.6f),
				ScoredResource("gkw_mg42.weapon", "weapon", 0.6f),
				ScoredResource("gkw_rpd.weapon", "weapon", 0.6f),
				ScoredResource("gkw_m2hb.weapon", "weapon", 0.6f),
				// ScoredResource("gkw_hk21.weapon", "weapon", 0.6f),

				ScoredResource("gkw_aek999.weapon", "weapon", 0.3f),
				ScoredResource("gkw_ameli.weapon", "weapon", 0.3f),
				ScoredResource("gkw_m60.weapon", "weapon", 0.3f),
				// ScoredResource("gkw_mg3.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk46.weapon", "weapon", 0.3f),
				ScoredResource("gkw_mk48.weapon", "weapon", 0.3f),
				ScoredResource("gkw_pk.weapon", "weapon", 0.3f),

				ScoredResource("gkw_kord.weapon", "weapon", 0.2f),
				ScoredResource("gkw_lewis.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mg5.weapon", "weapon", 0.2f),
				ScoredResource("gkw_qjy88.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rpk16.weapon", "weapon", 0.2f),
				ScoredResource("gkw_pkp.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mg4.weapon", "weapon", 0.2f),
				ScoredResource("gkw_mg338.weapon", "weapon", 0.2f),
				ScoredResource("gkw_rpk203.weapon", "weapon", 0.2f),
				ScoredResource("gkw_negev.weapon", "weapon", 0.2f)

			}
		};

		processRewardPasses(rewardPasses);

		GiftItemDeliveryRandomRewarder@ rewarder = GiftItemDeliveryRandomRewarder(m_metagame, rewardPasses);

		m_itemDeliveryOrganizer.addObjective(
			ItemDeliveryObjective(m_metagame, 0, deliveryList, m_itemDeliveryOrganizer, null, "", "", "", -1 /* loop */, rewarder)
		);
	}	
}
