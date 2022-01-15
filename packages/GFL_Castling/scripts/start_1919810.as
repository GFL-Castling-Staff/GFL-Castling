// declare include paths
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/GFL_Castling/scripts"
#include "path://media/packages/GFLC_Map/scripts"
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
		
   	settings.m_fellowCapacityFactor = 1.0;
   	settings.m_fellowAiAccuracyFactor = 0.90;
   	settings.m_enemyCapacityFactor = 1.9;
   	settings.m_enemyAiAccuracyFactor = 0.88;
	settings.m_initialRp = 200.0;
		
		settings.m_xpFactor = 1;
		settings.m_rpFactor = 2;

        array<string> overlays = {
			"media/packages/invasion",
			"media/packages/GFL_Castling",
            "media/packages/GFLC_Map"
        };
        settings.m_overlayPaths = overlays;

        settings.m_startServerCommand = """
<command class='start_server'
	server_name='Castling Test server'
	server_port='1234'
	comment='Read server rules in our discord: discord.gg/wwUM3kYmRC, QQ Group: 706234535'
	url=''
	register_in_serverlist='1'
	mode='Castling'
	persistency='forever'
	max_players='42'
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



