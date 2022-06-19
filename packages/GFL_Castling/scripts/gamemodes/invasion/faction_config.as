class FactionConfig {
	int m_index ;
	string m_file;
	string m_finalBattleFile;
	string m_name;
	string m_color;

	// --------------------------------------------
	FactionConfig(int index, string file, string name, string color, string finalBattleFile = "") {
		m_index = index;
		m_file = file;
		m_name = name;
		m_color = color;
		m_finalBattleFile = finalBattleFile != "" ? finalBattleFile : m_file;
	}

	// --------------------------------------------
	void replaceData(FactionConfig@ config) {
		m_index = config.m_index;
		m_file = config.m_file;
		m_name = config.m_name;
		m_color = config.m_color;
		m_finalBattleFile = config.m_finalBattleFile;
	}
};
