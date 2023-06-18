#include "tracker.as"
#include "gamemode_campaign.as"
#include "map_rotator_campaign.as"

// --------------------------------------------
class DifficultyTracker : Tracker {
	protected GameModeCampaign@ m_metagame;
	protected const MapRotatorCampaign@ m_mapRotator;
	protected float m_refreshTimer;
	protected bool m_triggered;
	
	protected float m_deathTimer;
	protected array<float> m_deathTimes;

	// --------------------------------------------
	DifficultyTracker(GameModeCampaign@ metagame) {
		@m_metagame = @metagame;
		@m_mapRotator = null;
		m_refreshTimer = 0.0f;
		m_triggered = false;
		m_deathTimer = 0.0f;

		_log("DifficultyTracker");
	}

	// --------------------------------------------
	void setMapRotator(const MapRotatorCampaign@ mapRotator) {
		@m_mapRotator = @mapRotator;
	}

	// --------------------------------------------
	bool hasStarted() const { return true; }

	// --------------------------------------------
	void update(float time) {
		if (m_triggered) return;
		
		m_refreshTimer -= time;
		if (m_refreshTimer <= 0.0f) {
			refresh();
			m_refreshTimer = 60.0f;
		}
		
		m_deathTimer += time;
	}

	// ----------------------------------------------------
	protected void refresh() {
		// track time in map
		// if over the threshold, trigger

		const XmlElement@ general = getGeneralInfo(m_metagame);
		if (general !is null) {
			float mapTime = general.getFloatAttribute("map_time");

			bool isCaptureMap = false;
			const Stage@ stage = m_mapRotator.getCurrentStage();
			if (stage !is null) {
				isCaptureMap = stage.isCapture();
			}

			if (isCaptureMap) {
				// struggling with advancing; assume the friendly faction will capture a base every x seconds, in worst case
				float timePerBase = 60.0f * 15.0f;
				int numberOfBasesPlayerShouldOwn = int(ceil(mapTime / timePerBase));
			    if (getBasesForFaction(m_metagame, 0) < numberOfBasesPlayerShouldOwn) { 
					trigger();
				}
			}			
		
			// 1.5h in map, struggling
			/*
			if (mapTime > 60.0f * 60.0f * 1.5f) {
				trigger();
			}
			*/
			
			// x hours in campaign, just allow difficulty changes by now
			// maybe player wants to change how it is without starting over
			float campaignTime = general.getFloatAttribute("campaign_time");
			float campaignTriggerTime = 60.0f * 60.0f * 3.0f;
			if (m_metagame.getUserSettings().m_presetId == "easy") {
				campaignTriggerTime = 60.0f * 60.0f * 1.5f;
			}
			
			if (campaignTime > campaignTriggerTime) {
				trigger();
			}
		}
	}

	// ----------------------------------------------------
	protected void handleChatEvent(const XmlElement@ event) {
		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first 
		if (!startsWith(message, "/")) {
			return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

		// admin only from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}

		if (checkCommand(message, "difficulty_change")) {
			trigger();
		}
	}

	// ----------------------------------------------------
	protected void trigger() {
		if (m_triggered) return;
		
		_log("DifficultyTracker, trigger");
		const XmlElement@ player = m_metagame.queryLocalPlayer();
		if (player !is null) {
			int characterId = player.getIntAttribute("character_id");
			if (characterId >= 0) {
				// doesn't matter that this gets called several times eventually
				XmlElement command("command");
				command.setStringAttribute("class", "add_custom_stat");
				command.setIntAttribute("character_id", characterId);
				command.setStringAttribute("tag", "difficulty_change");
				m_metagame.getComms().send(command);
				m_triggered = true;
			}
		}
	}
}
