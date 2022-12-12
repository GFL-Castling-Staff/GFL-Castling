		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "sf_assault.call", "sf_assault_sub.call", array<string> = {""}, false,true,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_assault.call", "kcco_assault_sub.call", array<string> = {""}, false,true,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_zircon.call", "kcco_zircon_sub.call", array<string> = {""}, false,true,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_assault.call", "para_assault_sub.call", array<string> = {""}, false,true,false,"infantry"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "para_eod.call", "para_eod_sub.call", array<string> = {""}, false,true,false,"infantry"));

		}

		{
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_coeus.call", "kcco_deploy_coeus_sub.call", array<string> = {""}, false,true,false,"vehicle"));
			stage.addTracker(SpawnInBaseCallHandler(m_metagame, "kcco_deploy_typhon.call", "kcco_deploy_typhon_sub.call", array<string> = {""}, false,true,false,"vehicle"));	
		}