// internal
#include "helpers.as"
#include "tracker.as"
#include "log.as"

bool _quitSignalReceived = false;

// --------------------------------------------
class QueryTracker : Tracker {
	protected int m_outgoingQueryId;
	protected bool m_ok;

	// --------------------------------------------
	QueryTracker() {
		m_outgoingQueryId = -1;
		m_ok = false;
	}

	// --------------------------------------------
	void init(int id) {
		m_outgoingQueryId = id;
	}

	// --------------------------------------------
	protected void handleQueryResultEvent(const XmlElement@ event) {
		int incomingQueryId = event.getIntAttribute("query_id");
		_log("handleQueryResult, incomingQueryId " + incomingQueryId, 1);
		_log("handleQueryResult, m_outgoingQueryId " + m_outgoingQueryId, 1);
		// check if this is the result for our query, and process it 
		if (incomingQueryId == m_outgoingQueryId) {
			// expected response got
			m_ok = true;
		}
	}

	// --------------------------------------------
	bool isOk() const {
		return m_ok;
	}

	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}

	// --------------------------------------------
	bool hasEnded() const {
		return m_ok;
	}
}

// --------------------------------------------
class Comms {
	array<const XmlElement@> m_receivedMessages;
	int m_lastQueryUid;

	// --------------------------------------------
	Comms() {
		m_receivedMessages = array<const XmlElement@>();
		m_lastQueryUid = 0;
	}

	// --------------------------------------------
	void send(const XmlElement@ message) {
		_log("  sending: " + message.toStringWithFloats(), 1);

		commsWrite(message.toDictionary());
	}

	// --------------------------------------------
	void send(string message) {
		_log("  sending: " + message, 1);
		commsWriteString(message);
	}

	// --------------------------------------------
	const XmlElement@ receive() {
		// it's possible the comms interface has queued some data to be handled
		// when the public receive gets called

		// consume this queue first in such case
		int queueSize = m_receivedMessages.size();
		if (queueSize > 0) {
			_log("  queue size " + queueSize, 2);

			const XmlElement@ event = m_receivedMessages[0];
			m_receivedMessages.removeAt(0);
			return event;
		}

		// if no more queued messages, receive new data from the pipe

		// (this is done to allow query-response to handle things synchronously
		// and collect missed messages not related to the query, to be served
		// at a later time by the Comms user who is handling all other messages)

		return _receive();
	}

	// --------------------------------------------
	protected const XmlElement@ _receive() {
		dictionary data;
		commsRead(data);
		XmlElement event(data);
		if (!data.isEmpty() && (event.getName() != "dummy_event")) {
			_log("  received: " + event.toString());
		}
		return event;
	}

	// --------------------------------------------
	// two way query-response, for convenience
	// - accepts query DOMDocument as input
	// - execution blocks here until response is received
	// - returns the response DOMDocument or NULL if failed
	// --------------------------------------------
	const XmlElement@ query(const XmlElement@ queryElement) {
		// if quit was received, don't handle any more queries, no one's going to respond
		if (_quitSignalReceived) {
			_log("  aborting query", -1);
			return null;
		}

		_log("  sending query", 1);

		// create in-place Tracker for matching with the incoming data
		QueryTracker@ tracker = QueryTracker();

		// store query id in tracker for matching with the response
		int queryId = queryElement.getIntAttribute("id");
		tracker.init(queryId);

		// send the query now
		send(queryElement);

		const XmlElement@ result = null;

		// keep receiving data until the response arrives
		_log("  waiting for response for the query...", 1);
		while (true) {
			// using internal receiving call, bypass any queued messages
			const XmlElement@ data = _receive();

			// check if it's response to what we asked, and not empty and not dummy_event; no need to queue dummies
			if (!data.empty() && (data.getName() != "dummy_event")) {
				//_log("  verifying data");
				if (data.getName() == "user_quit_event") {
					// a bit messy, but go for it for now
					_log("user quit signal detected, aborting query", -1);

					_quitSignalReceived = true;

					// push it in to re-handle it on metagame level
					m_receivedMessages.insertLast(data);
					break;
				}

				tracker.handleEvent(data);
				if (tracker.isOk()) {
					_log("  response received", 1);
					// correct response received, return to caller as XML
					@result = data;
					break;
				} else {
					_log("  received something else than the response, queueing", 1);
					// if another event comes in, we must not lose the data,
					// store these in the internal comms data queue, and let them 
					// come out one by one on subsequent external receive calls
					// until they have been discarded or processed
					m_receivedMessages.insertLast(data);
				}
			} else {
				// TODO: consider improving this:
				// sleep and recheck the data channel
				const float MINIMUM_SLEEP_TIME = 0.010f;
				sleep(MINIMUM_SLEEP_TIME);
			}
		}

		if (result is null) {
			_log("WARNING, invalid query result", -1);
		}

		return result;
	}

	// --------------------------------------------
	void clearQueue() {
		_log("clearing received messages, count " + m_receivedMessages.size(), 1);
		m_receivedMessages = array<const XmlElement@>();
		// also clear infifo
		while (true) {
			const XmlElement@ data = receive();
			if (data.empty()) break;
		}
	}

	// --------------------------------------------
	int getQueryUid() {
		int uid = m_lastQueryUid;
		m_lastQueryUid++;
		return uid;
	}

}
