// declare include paths
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/GFL_Castling/scripts"
#include "path://media/packages/GFLC_Map/scripts"
#include "path://media/packages/GFLC_Invasion/scripts"
#include "my_gamemode.as"

// Author:GFLC STaff
// --------------------------------------------
void main(dictionary@ inputData) {
        XmlElement inputSettings(inputData);

        UserSettings settings;
		settings.m_initialRp = 1000;
        settings.m_factionChoice = 0;
		settings.fromXmlElement(inputSettings);


        array<string> overlays = {
			"media/packages/GFL_Castling",
            "media/packages/GFLC_Invasion"
        };
        settings.m_overlayPaths = overlays;

        settings.print();

        MyGameMode metagame(settings);

        metagame.init();
        metagame.run();
        metagame.uninit();

        _log("ending execution");
}



