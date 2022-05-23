#include "internal/tracker.as"
#include "internal/log.as"
#include "internal/helpers.as"

// --------------------------------------------
class EventLog {
	protected string m_filename = "event_log.txt";
	protected bool m_started = false;

	// --------------------------------------------
	EventLog(string filename) {
		m_filename = filename;
	}

	// --------------------------------------------
	void log(dictionary list) { // writing to a file with AS. TODO?
		datetime now();
		string time = now.get_hour() + ":" + now.get_minute() + ":" + now.get_second();
		
		array<string> keys = list.getKeys();
		for (uint i = 0; i < list.getSize(); ++i) {
			string output = time + ": " key[i] + " " + list[key[i]];
			print(output);
		}
	}

	// --------------------------------------------
	void clear() {
		//$result = file_put_contents(m_filename, "");
	}
}