// declare include paths
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/GFL_Castling/scripts"
#include "gamemode_invasion.as"

// --------------------------------------------
void main(dictionary@ inputData) {
        XmlElement inputSettings(inputData);

        UserSettings settings;

        _setupLog("dev_verbose");

        settings.m_factionChoice = 0;                  // 0 (greenbelts), 1 (graycollars), 2 (brownpants)
        settings.m_playerAiCompensationFactor = 1.0;   // was 1.1  (1.75)
        settings.m_playerAiReduction = 0.0;            // didn't work before 1.76! (was 1.0)
        settings.m_teamKillPenaltyEnabled = true;
        settings.m_completionVarianceEnabled = false;
        settings.m_journalEnabled = true;
		settings.m_fellowDisableEnemySpawnpointsSoldierCountOffset = 1;
		
		settings.m_fellowCapacityFactor = 1.4;
		settings.m_fellowAiAccuracyFactor = 0.96;
		settings.m_enemyCapacityFactor = 1.6;
		settings.m_enemyAiAccuracyFactor = 0.94;
		
		settings.m_xpFactor = 1;
		settings.m_rpFactor = 1;

        array<string> overlays = {
			"media/packages/invasion",
			"media/packages/GFL_Castling"
                
        };
        settings.m_overlayPaths = overlays;

        settings.m_startServerCommand = """
<command class='start_server'
	server_name='114514'
	server_port='1234'
	comment='Coop1'
	url=''
	register_in_serverlist='0'
	mode='COOP'
	persistency='forever'
	max_players='32'
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



