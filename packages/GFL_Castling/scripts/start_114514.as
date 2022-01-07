#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/GFL_Castling/scripts"
#include "gamemode_invasion.as"

void main(dictionary@ inputData) {
	XmlElement inputSettings(inputData);

	UserSettings settings;
	
	settings.m_factionChoice = 0;
    settings.m_factionChoice = 0;
	
    settings.m_playerAiCompensationFactor = 1;
    settings.m_fellowCapacityFactor = 1.4;
    settings.m_fellowAiAccuracyFactor = 0.96;
    settings.m_enemyCapacityFactor = 1.6;
    settings.m_enemyAiAccuracyFactor = 0.94;
    settings.m_playerAiReduction = 1.0;
    settings.m_playerDamageModifier = -0.3;
	settings.m_initialRp = 6666.0;
    settings.m_teamKillPenaltyEnabled = true;
    settings.m_completionVarianceEnabled = false;
    settings.m_journalEnabled = false; 
	settings.m_fellowDisableEnemySpawnpointsSoldierCountOffset = 1;

	settings.m_xpFactor = 2;
	settings.m_rpFactor = 2;
	
	array<string> overlays = {
			"media/packages/GFL_Castling"
	};
	settings.m_overlayPaths = overlays;
	
	// TODO: setup settings
    settings.m_startServerCommand = """
<command 
	class='start_server'
	server_name='?'
	server_port='1234'
	comment='?'
	url=''
	register_in_serverlist='0'
	mode='?'
	persistency='forever'
	url="http://runningwithrifles.com"
	max_players='36'
	friendly_fire="0">
	<client_faction id='0' />
</command>
""";

	_setupLog(inputSettings);

	settings.print();

	GameModeInvasion metagame(settings);

	metagame.init();
	metagame.run();
	metagame.uninit();

	_log("ending execution");
}

