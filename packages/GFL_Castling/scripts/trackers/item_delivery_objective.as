// internal
#include "objective.as"
#include "admin_manager.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"

// generic trackers
#include "resource_unlocker.as"
#include "item_delivery_organizer.as"

// ------------------------------------------------------------------------------------------------
interface ItemDeliveryRewarder {
	void rewardPiece(int playerId, int characterId, int acceptedAmount, const Resource@ targetItem);
	void rewardCompletion(int playerId, int characterId, const Resource@ targetItem);
}

// ------------------------------------------------------------------------------------------------
class FixedItemDeliveryRewarder : ItemDeliveryRewarder {
	protected Metagame@ m_metagame;
	protected float m_rewardPerPiece;
	protected float m_rewardForCompletion;

	// ------------------------------------------------------------------------------------------------
	FixedItemDeliveryRewarder(Metagame@ metagame, float rewardPerPiece, float rewardForCompletion) {
		@m_metagame = @metagame;
		m_rewardPerPiece = rewardPerPiece;
		m_rewardForCompletion = rewardForCompletion; 
	}

	// ------------------------------------------------------------------------------------------------
	void rewardPiece(int playerId, int characterId, int acceptedAmount, const Resource@ targetItem) {
		if (m_rewardPerPiece > 0.0) {
			string c = "<command class='rp_reward' character_id='" + characterId + "' reward='" + m_rewardPerPiece * acceptedAmount + "' />";
			m_metagame.getComms().send(c);
		}
	}

	// ------------------------------------------------------------------------------------------------
	void rewardCompletion(int playerId, int characterId, const Resource@ targetItem) {
		if (m_rewardForCompletion > 0.0) {
			string c = "<command class='rp_reward' character_id='" + characterId + "' reward='" + m_rewardForCompletion + "' />";
			m_metagame.getComms().send(c);
		}
	}
}

// ------------------------------------------------------------------------------------------------
class ItemDeliveryObjective : Objective {
	protected array<Resource@> m_itemList;
	protected bool m_deliveryDone;
	protected int m_startingDeliveryAmount;
	protected int m_deliveryAmount;
	protected int m_factionId;
	protected ItemDeliveryOrganizer@ m_organizer;
	protected ResourceUnlocker@ m_unlocker;
	protected ItemDeliveryRewarder@ m_rewarder;
	protected string m_instructions;
	protected string m_thanks;
	protected string m_thanksIncomplete;

	protected const XmlElement@ m_collapseDropEvent;
	protected float m_collapseTimer;
	protected int m_collapseDropAmount;

	// ----------------------------------------------------
	ItemDeliveryObjective(Metagame@ metagame, int factionId, const array<Resource@>@ itemList, ItemDeliveryOrganizer@ organizer, ResourceUnlocker@ unlocker, string instructions, 
		string thanks, string thanksIncomplete, int deliveryAmount, ItemDeliveryRewarder@ rewarder) {

		super(metagame);

		m_deliveryDone = false;

		m_factionId = factionId;
		
		m_itemList = itemList; // copy

		@m_organizer = organizer;
		@m_unlocker = unlocker;
		@m_rewarder = rewarder;

		m_instructions = instructions;
		m_thanks = thanks;
		m_thanksIncomplete = thanksIncomplete;

		m_startingDeliveryAmount = deliveryAmount;
		m_deliveryAmount = deliveryAmount;

		@m_collapseDropEvent = null;
		m_collapseTimer = -1.0;
		m_collapseDropAmount = 0;
	}

	// ----------------------------------------------------
	// backwards compatible constructor
	// ----------------------------------------------------
	ItemDeliveryObjective(Metagame@ metagame, int factionId, const array<Resource@>@ itemList, ItemDeliveryOrganizer@ organizer, ResourceUnlocker@ unlocker, string instructions, 
		string deprecatedParameter, string thanks, string thanksIncomplete, int deliveryAmount, float rewardPerPiece = 100.0, 
		float rewardForCompletion = 100.0) {

		super(metagame);

		m_deliveryDone = false;

		m_factionId = factionId;
		
		m_itemList = itemList; // copy

		@m_organizer = organizer;
		@m_unlocker = unlocker;
		@m_rewarder = FixedItemDeliveryRewarder(m_metagame, rewardPerPiece, rewardForCompletion);

		m_instructions = instructions;
		m_thanks = thanks;
		m_thanksIncomplete = thanksIncomplete;

		m_startingDeliveryAmount = deliveryAmount;
		m_deliveryAmount = deliveryAmount;

		@m_collapseDropEvent = null;
		m_collapseTimer = -1.0;
		m_collapseDropAmount = 0;
	}

	// ----------------------------------------------------
	void setDeliveryAmount(int amount) {
		m_deliveryAmount = amount;
	}

	// ----------------------------------------------------
	int getDeliveryAmount() const {
		return m_deliveryAmount;
	}

	// ----------------------------------------------------
	string getId() const {
		string id = "";
		for (uint i = 0; i < m_itemList.size(); ++i) {
			string key = m_itemList[i].m_key;
			if (id == "") {
				id = key;
			} else {
				id += ", " + key;
			}
		}
		return id;
	}

    // ----------------------------------------------------
	void update(float time) {
		if (hasStarted()) {
			if (m_collapseTimer > 0.0) {
				m_collapseTimer -= time;
				if (m_collapseTimer <= 0.0) {
					_log("collapse timer done, end collapse", 1);
					// end collapse now
					endCollapse();
				}
			}
		}
	}

    // ----------------------------------------------------
	// debugging tools
    protected void handleChatEvent(const XmlElement@ event) {
		// player_id
		// player_name
		// message
		// global
		string message = event.getStringAttribute("message");
		// for the most part, chat events aren't commands, so check that first
		if (!startsWith(message, "/")) {
				return;
		}

		string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");
		if (checkCommand(message, "help")) {
			// don't process if not properly started
			if (hasStarted()) {
				instructObjective(senderId);
			}
		}

		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}
	}

	// ----------------------------------------------------
	protected const Resource@ getItemResource(string key) const {
		const Resource@ targetItem = null;
		for (uint i = 0; i < m_itemList.size(); ++i) {
			if (m_itemList[i].m_key == key) {
				@targetItem = @m_itemList[i];
			}
		}
		return targetItem;
	}

	// ----------------------------------------------------
	protected void handleItemDropEvent(const XmlElement@ event) {
		// character_id
		// item_class
		// item_type_id
		// item_key 
		// target_container_type_id
		// position

		// don't process if not properly started
		if (!hasStarted()) return;

		// if already delivered, don't care
		if (m_deliveryDone) return;

		// only check for armory drops
		if (event.getIntAttribute("target_container_type_id") != 1) return;

		// ensure it's the wanted item
		const Resource@ targetItem = getItemResource(event.getStringAttribute("item_key"));
		if (targetItem is null) return;

		// correct item, correct place, now process it

		// the game reports every item drop as single event;

		// however, here we want to collapse several item drops happening on the same instant to be examined as one drop

		// we can do that by buffering the last drop event, and on the next drop check if it is same as the previous one, 
		// if it is, collapse them, and wait for next drop
		// if it is not, handle the buffered and potentially collapsed drop, and start buffering the next one
		// in addition, we'll need to give some time for the server to send the events to be collapsed, 
		// so we can start a timer, which on expiration will conclude the item drop collapse unless it ended with another drop happening

		// if collapse is on going
		if (m_collapseTimer > 0.0) {
			// compare
			if (m_collapseDropEvent.equals(event)) {
				// it's same
				_log("same drop; collapsing", 1);
				m_collapseDropAmount += 1;
			} else {
				// different
				// handle collapsed drop now, and start a new one
				_log("different drop; end and start new one", 1);
				endCollapse();
				startCollapse(event);
			}
		} else {
			// collapse not on going, start it
			_log("start collapse", 1);
			startCollapse(event);
		}
	}

	// ----------------------------------------------------
	protected void startCollapse(const XmlElement@ dropEvent) {
		m_collapseTimer = 1.0;
		m_collapseDropAmount = 1;
		@m_collapseDropEvent = @dropEvent;
	}

	// ----------------------------------------------------
	protected void endCollapse() {
		processCollapsedDrop();

		m_collapseTimer = -1.0;
		m_collapseDropAmount = 0;
		@m_collapseDropEvent = null;
	}

	// ----------------------------------------------------
	protected void processCollapsedDrop() {
		_log("processing collapsed drop now", 1);

		const XmlElement@ event = m_collapseDropEvent;

		int id = event.getIntAttribute("character_id");
		int playerId = event.getIntAttribute("player_id");

		const Resource@ targetItem = getItemResource(event.getStringAttribute("item_key"));
		if (targetItem is null) return;

		int acceptedAmount = m_collapseDropAmount;
		if (m_deliveryAmount > 0) {
			acceptedAmount = min(acceptedAmount, m_deliveryAmount);
		}

		if (m_rewarder !is null) {
			m_rewarder.rewardPiece(playerId, id, acceptedAmount, targetItem);
		}

		_log("delivery_amount = " + m_deliveryAmount, 1);

		if (m_deliveryAmount > 0) {
			// reduce needed amount
			m_deliveryAmount -= acceptedAmount;

			if (m_deliveryAmount <= 0) {
				// all delivered
				m_deliveryDone = true;

				if (m_thanks != "") {
					sendPrivateMessageKey(m_metagame, playerId, m_thanks);
				}

				if (m_rewarder !is null) {
					m_rewarder.rewardCompletion(playerId, id, targetItem);
				}

				if (m_unlocker !is null) {
					m_unlocker.handleItemDeliveryCompleted(targetItem, id, playerId);
				}

				end();
			} else {
				// items still wanted, update marker
				if (m_thanksIncomplete != "") {
					dictionary a = {
						{"%number_of_items_left", formatInt(m_deliveryAmount)}
					};
					sendPrivateMessageKey(m_metagame, playerId, m_thanksIncomplete, a);
				}

				markObjective();
			}
		} else {
			// no specific amount of delivery requested, it's looping, so it'll complete each time; say thanks
			if (m_thanks != "") {
				sendPrivateMessageKey(m_metagame, playerId, m_thanks);
			}

			for (int i = 0; i < acceptedAmount; ++i) {
				if (m_rewarder !is null) {
					m_rewarder.rewardCompletion(playerId, id, targetItem);
				}

				// delivery amount is negative or 0, means it doesn't end ever
				// each piece delivery can unlock something
				if (m_unlocker !is null) {
					m_unlocker.handleItemDeliveryCompleted(targetItem, id, playerId);
				}
			}
		}
	}

	// ----------------------------------------------------
	void end() {
		Objective::end();

		unmarkObjective();

		m_deliveryDone = false;

		// inform organizer as well about ending
		m_organizer.objectiveEnded(this);
	}

	// --------------------------------------------------------
	protected void instructObjective(int playerId = -1) {
		// announce the message now

		dictionary a;
		if (playerId == -1) {
			sendFactionMessageKey(m_metagame, 0, m_instructions, a);
		} else {
			sendPrivateMessageKey(m_metagame, playerId, m_instructions, a);
		}
	}

	// --------------------------------------------------------
	protected void markObjective() {
	}

	// --------------------------------------------------------
	protected void unmarkObjective() {
	}
}