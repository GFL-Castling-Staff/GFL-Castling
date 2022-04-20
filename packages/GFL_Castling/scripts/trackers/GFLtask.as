// internal
#include "task_sequencer.as"

class VestRecoverTask : Task {
    protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_num;
    protected int m_character_id;
	protected float m_timeLeft;
    protected int m_numLeft;

    void start() {
		m_timeLeft=m_time;
		m_numLeft=1;
	}

    void update(float time) {
		m_timeLeft -= time;
		if (m_timeLeft < 0)
		{
			_log("timeplayed:"+ m_numLeft);
			m_numLeft++;
			m_timeLeft=m_time;
		}

	}

    bool hasEnded() const {
		if (m_numLeft >= m_num) {
			return true;
		}
		return false;
	}
}