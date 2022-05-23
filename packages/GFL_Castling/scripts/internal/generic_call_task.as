// internal
#include "task_sequencer.as"

// can't do this in AS:
/*
// --------------------------------------------
class GenericCallTask : Task {
	protected $owner = NULL;
	protected $method = "";
	protected $parameters = array();

	// --------------------------------------------
	function __construct($owner, $method, $parameters) {
		$this->owner = $owner;
		$this->method = $method;
		$this->parameters = $parameters;
	}

	// --------------------------------------------
	void start() {
		call_user_func_array(array($this->owner, $this->method), $this->parameters);
	}

	// --------------------------------------------
	void update($time) {
	}

	// --------------------------------------------
	bool hasEnded() {
		// ends immediately, doesn't take any time
		return true;
	}
}
*/

// --------------------------------------------
abstract class CallTask : Task {
	// --------------------------------------------
	CallTask() {
	}

	// --------------------------------------------
	void start() {}

	// --------------------------------------------
	void update(float time) {}

	// --------------------------------------------
	bool hasEnded() const {
		// ends immediately, doesn't take any time
		return true;
	}
}

// --------------------------------------------
funcdef void CALL();
class Call : CallTask {
	CALL@ m_call;
	Call(CALL@ call) { @m_call = @call; }
	void start() { m_call(); }
}

// --------------------------------------------
funcdef void CALL_INT(int);
class CallInt : CallTask {
	CALL_INT@ m_call;
	int m_p1;
	CallInt(CALL_INT@ call, int p1) { @m_call = @call; m_p1 = p1; }
	void start() { m_call(m_p1); }
}

// --------------------------------------------
funcdef void CALL_INT_INT(int, int);
class CallIntInt : CallTask {
	CALL_INT_INT@ m_call;
	int m_p1;
	int m_p2;
	CallIntInt(CALL_INT_INT@ call, int p1, int p2) { @m_call = @call; m_p1 = p1; m_p2 = p2;}
	void start() { m_call(m_p1, m_p2); }
}

// --------------------------------------------
funcdef void CALL_FLOAT(float);
class CallFloat : CallTask {
	CALL_FLOAT@ m_call;
	float m_p1;
	CallFloat(CALL_FLOAT@ call, float p1) { @m_call = @call; m_p1 = p1; }
	void start() { m_call(m_p1); }
}

// --------------------------------------------
class DelayedCallTask : Task {
    protected float m_timer = 0.0;
	protected CallTask@ m_callTask;

	// --------------------------------------------
    DelayedCallTask(CallTask@ callTask, float time) {
		@m_callTask = callTask;
		m_timer = time;
    }

	// --------------------------------------------
    void start() {
    }

	// --------------------------------------------
    void update(float time) {
		m_timer -= time;
		if (hasEnded()) {
			m_callTask.start();
		}
    }

	// --------------------------------------------
    bool hasEnded() const {
		return m_timer < 0.0;
    }
}
