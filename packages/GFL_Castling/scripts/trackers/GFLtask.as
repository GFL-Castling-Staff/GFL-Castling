// internal
#include "task_sequencer.as"

class VestRecoverTask : Task {
    protected Metagame@ m_metagame;
	protected float m_time;
    protected int m_num;
    protected int m_character_id;

    void start() {

	}

    void update(float time) {
		m_time -= time;
		_log("time announcer, waiting " + time + ", left " + m_timeLeft, 1);

		if (m_time < 0)
		{
			_log("ticker meow");
            
		}
	}

    bool hasEnded() const {
		if (m_time < 0.0) {
			return true;
		}
		return false;
	}
}