// internal
#include "task_sequencer.as"
#include "query_helpers.as"

// --------------------------------------------
class AnnounceTask : Task {
	protected Metagame@ m_metagame;
	protected int m_factionId;
	protected string m_key;
	protected dictionary m_a;
	protected float m_time;
	protected float m_priority;
	protected string m_soundFilename;

	// announcements are considered high priority, with default 1.0 priority the message will be shown regardless of user setting for
	// commander muting or commander_ai reports setting
	// - especially useful for providing commander briefing at the start of the match, by making reports muted with 0.0 setting and using priority 1.0 here
	AnnounceTask(Metagame@ metagame, float time, int factionId, string key, dictionary@ a = dictionary(), float priority = 1.0, string soundFilename = "") {
		@m_metagame = metagame;
		m_factionId = factionId;
		m_key = key;
		m_a = a;
		m_time = time;
		m_priority = priority;
		m_soundFilename = soundFilename;
	}

	// --------------------------------------------
	void start() {
		if (m_key != "") {
			sendFactionMessageKey(m_metagame, m_factionId, m_key, m_a, m_priority);
			if (m_soundFilename != "") {
				playSound(m_metagame, m_soundFilename, m_factionId);
			}
		}
	}

	// --------------------------------------------
	void update(float time) {
		m_time -= time;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_time < 0.0f;
	}
}

// --------------------------------------------
class AnnouncePrivateTask : Task {
	protected Metagame@ m_metagame;
	protected int m_playerId;
	protected string m_key;
	protected dictionary m_a;
	protected float m_time;

	AnnouncePrivateTask(Metagame@ metagame, float time, int playerId, string key, dictionary@ a = dictionary()) {
		@m_metagame = metagame;
		m_playerId = playerId;
		m_key = key;
		m_a = a;
		m_time = time;
	}

	// --------------------------------------------
	void start() {
		if (m_key != "") {
			sendPrivateMessageKey(m_metagame, m_playerId, m_key, m_a);
		}
	}

	// --------------------------------------------
	void update(float time) {
		m_time -= time;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_time < 0.0f;
	}
}
