// internal
#include "task_sequencer.as"

// --------------------------------------------
class TimeAnnouncerTask : Task {
	protected Metagame@ m_metagame;
	protected float m_time;
	protected int m_nextBoundary;
	protected bool m_sayCountdown;

	// float
	protected float m_timeLeft;
	
	// --------------------------------------------
	TimeAnnouncerTask(Metagame@ metagame, float time, bool sayCountdown = true) {
		@m_metagame = metagame;
		m_time = time;
		m_sayCountdown = sayCountdown;
	}

	// --------------------------------------------
	void start() {
		_log("waiting " + m_time + " seconds in total", 1);

		m_timeLeft = m_time;
		m_nextBoundary = int(m_time);
	}

	// --------------------------------------------
	void update(float time) {
		m_timeLeft -= time;

		if (m_timeLeft < m_nextBoundary &&
			m_nextBoundary > 0) // don't say starting in 0 s
		{
			_log("to go: " + m_nextBoundary, 1);
			if (m_sayCountdown) {
				sendFactionMessage(m_metagame, -1, "starting in " + m_nextBoundary + " seconds");
			}

			// 10 interval
			m_nextBoundary -= 10;
		}
	}

	// --------------------------------------------
	bool hasEnded() const {
		if (m_timeLeft < 0.0) {
			return true;
		}
		return false;
	}
}
