// --------------------------------------------
class AdminManager {
	protected Metagame@ m_metagame;
	protected array<string> m_admins;

	// --------------------------------------------
	AdminManager(Metagame@ metagame) {
		@m_metagame = metagame;
	}

	// --------------------------------------------
	void addAdmin(string name) {
		m_admins.insertLast(name.toLowerCase());
	}

	// --------------------------------------------
	void loadFromFile() {
		m_admins = loadStringsFromSaveFile(m_metagame, "admins.xml");
		for (uint i = 0; i < m_admins.size(); ++i) {
			m_admins[i] = m_admins[i].toLowerCase();
		}
	}

	// --------------------------------------------
	bool isAdmin(string name, int playerId = -1) const {
		// consider server console comments as admin
		if (playerId == 0 && name == "") {
			return true;
		}
		return m_admins.find(name.toLowerCase()) >= 0;
	}
};
