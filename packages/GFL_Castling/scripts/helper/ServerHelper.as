#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"


class ServerHelper : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	ServerHelper(Metagame@ metagame) {
		@m_metagame = @metagame;
	}
	
	// ----------------------------------------------------

	protected void handleChatEvent(const XmlElement@ event) {

        string message = event.getStringAttribute("message");
		if (!startsWith(message, "/")) {
			return;
		}

        
        string sender = event.getStringAttribute("player_name");
		int senderId = event.getIntAttribute("player_id");

        if (!m_metagame.getAdminManager().isAdmin(sender, senderId) && !m_metagame.getModeratorManager().isModerator(sender, senderId)) {
			return;
		}

        if(checkCommand(message,"alertgrab")){
            const XmlElement@ player = getPlayerByIdOrNameFromCommand(m_metagame, message,false);
            if (player !is null) {
                int playerId = player.getIntAttribute("player_id");
                string playerName = player.getStringAttribute("name");
                string pos= player.getStringAttribute("position");
                int faction= player.getIntAttribute("faction_id");
                dictionary a;
				a["%name"] = sender;
                sendPrivateMessageKey(m_metagame, senderId, "Send Alert Success",dictionary());
                playSoundAtLocation(m_metagame,"objective_priority.wav",faction,pos);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert001",a);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert002",dictionary());
            }
        }

        if(checkCommand(message,"alerttk")){
            const XmlElement@ player = getPlayerByIdOrNameFromCommand(m_metagame, message,false);
            if (player !is null) {
                int playerId = player.getIntAttribute("player_id");
                string playerName = player.getStringAttribute("name");
                string pos= player.getStringAttribute("position");
                int faction= player.getIntAttribute("faction_id");
                dictionary a;
				a["%name"] = sender;
                sendPrivateMessageKey(m_metagame, senderId, "Send Alert Success",dictionary());
                playSoundAtLocation(m_metagame,"objective_priority.wav",faction,pos);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert003",a);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert002",dictionary());
            }
        }

        if(checkCommand(message,"alertother")){
            const XmlElement@ player = getPlayerByIdOrNameFromCommand(m_metagame, message,false);
            if (player !is null) {
                int playerId = player.getIntAttribute("player_id");
                string playerName = player.getStringAttribute("name");
                string pos= player.getStringAttribute("position");
                int faction= player.getIntAttribute("faction_id");
                dictionary a;
				a["%name"] = sender;
                sendPrivateMessageKey(m_metagame, senderId, "Send Alert Success",dictionary());
                playSoundAtLocation(m_metagame,"objective_priority.wav",faction,pos);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert004",a);
                sendPrivateMessageKey(m_metagame, playerId, "ServerQuickChatAlert002",dictionary());
            }
        }
    }

    bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}
}