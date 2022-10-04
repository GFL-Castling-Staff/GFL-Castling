#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/GFL_Castling/scripts"

#include "gamemode_invasion.as"

// --------------------------------------------
void main(dictionary@ inputData) {
        XmlElement inputSettings(inputData);

        UserSettings settings;

        _setupLog("dev_verbose");

        settings.m_factionChoice = 0;                  // 0 (greenbelts), 1 (graycollars), 2 (brownpants)
        settings.m_playerAiCompensationFactor = 1.15;   // was 1.1  (1.75)
        settings.m_teamKillPenaltyEnabled = true;
        settings.m_completionVarianceEnabled = false;
        settings.m_journalEnabled = true;
		settings.m_fellowDisableEnemySpawnpointsSoldierCountOffset = -3;
		
        settings.m_fellowCapacityFactor = 0.9;
        settings.m_fellowAiAccuracyFactor = 0.85;
        settings.m_enemyCapacityFactor = 2.0;
        settings.m_enemyAiAccuracyFactor = 0.88;
        settings.m_initialRp = 1000.0;
        settings.m_GlobalDifficulty = 3;
		
		settings.m_xpFactor = 1;
		settings.m_rpFactor = 1.0;

        array<string> overlays = {
			"media/packages/GFL_Castling"
        };
        // settings.m_overlayPaths = overlays;

        settings.m_startServerCommand = """
<command class='start_server'
	server_name='[LV4]'
	server_port='1234'
	comment='Read server rules in our discord: discord.gg/wwUM3kYmRC, QQ Group: 706234535'
	url='https://castling.fandom.com/wiki/Castling_Wiki'
	register_in_serverlist='1'
	mode='Castling'
	persistency='forever'
	max_players='24'
	friendly_fire="1">
	<client_faction id='0' />
</command>
""";
        settings.print();

        GameModeInvasion metagame(settings);

        metagame.init();
        metagame.run();
        metagame.uninit();

        _log("ending execution");
}



