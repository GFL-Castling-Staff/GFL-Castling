#include "gamemode_invasion.as"
#include "map_rotator_campaign.as"
#include "stage_configurator_campaign.as"
#include "item_delivery_configurator_campaign.as"
#include "difficulty_tracker.as"

// --------------------------------------------
class GameModeCampaign : GameModeInvasion {
	// --------------------------------------------
	protected DifficultyTracker@ m_difficultyTracker;

	// --------------------------------------------
	GameModeCampaign(UserSettings@ settings) {
		super(settings);
	}

	// --------------------------------------------
	void init() {
		setupDifficultyTracker();

		GameModeInvasion::init();

		// add local player as admin for easy testing, hacks, etc
		if (!getAdminManager().isAdmin(getUserSettings().m_username)) {
			getAdminManager().addAdmin(getUserSettings().m_username);
		}
		
	}

	// --------------------------------------------
	protected void setupExperimentalFeatures() {
		// certain features are considered experimental,
		// they're only available in Invasion,
		// this dummy implementation removes them from vanilla campaign
		
		// to enable them for campaign, remove comment on the next line
		GameModeInvasion::setupExperimentalFeatures();
	}

	// --------------------------------------------
	protected void setupIcecreamReport() {
	}

	// --------------------------------------------
	protected void setupUnlockManager() {
		@m_unlockManager = UnlockManager(this, this, 100.0 * 60.0 * 60.0);
	}
	
	// --------------------------------------------
	protected void setupMapRotator() {
		// StageConfigurator registers itself to map rotator, waiting to be called at a specific time
		MapRotatorCampaign mapRotatorCampaign(this);
		StageConfiguratorCampaign configurator(this, mapRotatorCampaign);
		@m_mapRotator = @mapRotatorCampaign;
		
		if (m_difficultyTracker !is null) {
			m_difficultyTracker.setMapRotator(mapRotatorCampaign);
		}
	}

	// --------------------------------------------
	protected void setupPenaltyManager() {
		// skip for single player
	}

	// --------------------------------------------
	protected void setupLocalBanManager() {
		// skip for single player
	}

	// --------------------------------------------
	protected void setupMinibosses() {
		// skip for single player
	}

    // --------------------------------------------
	protected void setupDogs() {
		// skip for single player
	}

	// --------------------------------------------
    protected void setupRipper() {
		// skip for single player
	}	
	
	// --------------------------------------------
    protected void setupGrinch() {
		// skip for single player
	}		

	// --------------------------------------------
	protected void setupDisableRadioAtMatchOver() {
		// skip for single player, not really needed
	}

	// --------------------------------------------
	protected void setupItemDeliveryOrganizer() {
		ItemDeliveryConfiguratorCampaign configurator(this);
		@m_itemDeliveryOrganizer = ItemDeliveryOrganizer(this, configurator);
	}

	// --------------------------------------------
	protected void setupSpawnTimeHandler() {
		// not needed in campaign
	}
	
	// --------------------------------------------
	protected void setupSideBaseAttackHandler() {
		// not needed in campaign
	}	

	// --------------------------------------------
	protected void setupIdlerKicker() {
		// not needed in campaign
	}	

	// --------------------------------------------
	protected void setupDifficultyTracker() {
		if (getUserSettings().m_difficultyTrackerEnabled) {
			@m_difficultyTracker = DifficultyTracker(this);
		}
	}	

	// --------------------------------------------
	void postBeginMatch() {
		GameModeInvasion::postBeginMatch();
		
		if (m_difficultyTracker !is null) {
			addTracker(m_difficultyTracker);
		}
	}

	// --------------------------------------------
	void save() {
		// save metagame status now:
		_log("saving metagame", 1);

		XmlElement commandRoot("command");
		commandRoot.setStringAttribute("class", "save_data");

		XmlElement root("saved_metagame");

		m_mapRotator.save(root);
		m_unlockManager.save(root);
		if (m_itemDeliveryOrganizer !is null) {
			m_itemDeliveryOrganizer.save(root);
		}
	
		// append user-settings in too
		XmlElement@ settings = m_userSettings.toXmlElement("settings");
		root.appendChild(settings);

		commandRoot.appendChild(root);

		// save through game
		getComms().send(commandRoot);
	}

	// --------------------------------------------
	void load() {
		// load metagame status now:
		_log("loading metagame", 1);

		XmlElement@ query = XmlElement(
			makeQuery(this, array<dictionary> = {
				dictionary = { {"TagName", "data"}, {"class", "saved_data"} } }));
		const XmlElement@ doc = getComms().query(query);

		if (doc !is null) {
			const XmlElement@ root = doc.getFirstChild();
			// read user-settings too, have them around separately..
			const XmlElement@ settings = root.getFirstElementByTagName("settings");
			if (settings !is null) {
				m_userSettings.fromXmlElement(settings);
				m_userSettings.m_continue = true;
				
				// prepare game menu for settings change
				{
					XmlElement@ command = getUserSettings().toXmlElement("command");
					command.setStringAttribute("class", "set_game_settings_menu");
					getComms().send(command);
				}
			}

			m_userSettings.print();

			m_mapRotator.init();
			m_mapRotator.load(root);

			m_unlockManager.init(0);
			m_unlockManager.load(root);

			if (m_itemDeliveryOrganizer !is null) {
				m_itemDeliveryOrganizer.init();
				m_itemDeliveryOrganizer.load(root);
			}

			_log("loaded", 1);
		} else {
			_log("load failed");
			m_mapRotator.init();
			m_unlockManager.init(0);
			if (m_itemDeliveryOrganizer !is null) {
				m_itemDeliveryOrganizer.init();
			}
		}
	}
}

