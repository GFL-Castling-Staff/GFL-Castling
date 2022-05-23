// --------------------------------------------
class ModeratorManager {
	protected Metagame@ m_metagame;
	protected array<string> m_moderators;

	// --------------------------------------------
	ModeratorManager(Metagame@ metagame) {
		@m_metagame = metagame;
	}

	// --------------------------------------------
	void addModerator(string name) {
		m_moderators.insertLast(name.toLowerCase());
	}

	// --------------------------------------------
	void loadFromFile() {
		m_moderators = loadStringsFromFile(m_metagame, "moderators.xml");
		for (uint i = 0; i < m_moderators.size(); ++i) {
			m_moderators[i] = m_moderators[i].toLowerCase();
		}
	}

	// --------------------------------------------
	bool isModerator(string name, int playerId = -1) const {
		// consider server console comments as admin, but not as moderator, thus returning false
		if (playerId == 0 && name == "") {
			return false;
		}
		return m_moderators.find(name.toLowerCase()) >= 0;
	}
};
