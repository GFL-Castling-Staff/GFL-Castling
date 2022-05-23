#include "tracker.as"

// --------------------------------------------
enum ObjectiveState {
	NotStarted,
	Started,
	Ended
};

// --------------------------------------------
abstract class Objective : Tracker {
	protected Metagame@ m_metagame;
	protected ObjectiveState m_state;

	// --------------------------------------------
	Objective(Metagame@ metagame) {
		@m_metagame = @metagame;
		m_state = NotStarted;
	}

	// --------------------------------------------
	void start() {
		m_state = Started;
	}

	// --------------------------------------------
	void end() {
		m_state = Ended;
	}

	// --------------------------------------------
	void reset() {
		m_state = NotStarted;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return m_state == Started;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_state == Ended;
	}
}
