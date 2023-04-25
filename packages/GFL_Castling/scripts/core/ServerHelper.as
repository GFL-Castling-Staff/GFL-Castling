#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"
#include "GFLparameters.as"

//Originally created by NetherCrow

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

        if(checkCommand(message,"resetxp")){
            if(lv120dict.exists(sender)){
                const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
                if (info !is null) {
                    int cId = info.getIntAttribute("character_id");
                    setXPcharacter(m_metagame,cId,float(lv120dict[sender]));
                }
            }
        }

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

        if(checkCommand(message,"alertfadan")){
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
                addItemInBackpack(m_metagame,player.getIntAttribute("character_id"),"carry_item","fadan.carry_item");
            }
        }

        if(checkCommand(message,"spt")){
            string s = message.substr(message.findFirst(" ")+1);
            const XmlElement@ player = getPlayerInfo(m_metagame,senderId);
            if (player is null) {return;}
            if (player.hasAttribute("aim_target")) {
                string target = player.getStringAttribute("aim_target");
                switch (s){
                    //if(s=="mgnmsl") spawnSoldier(m_metagame,1,0,target,"default_mg");

                    case "qwd":
                        spawnSoldier(m_metagame,1,1,target,"sf_manticore");
                        break;
                    case "hydra":
                        spawnSoldier(m_metagame,1,1,target,"kcco_Hydra");
                        break;
                    case "vespid":
                        spawnSoldier(m_metagame,1,1,target,"sf_vespid");
                        break;
                    case "guard":
                        spawnSoldier(m_metagame,1,1,target,"sf_guard");
                        break;
                    case "jaeger":
                        spawnSoldier(m_metagame,1,1,target,"sf_jaeger");break;
                    case "gangshi":
                        spawnSoldier(m_metagame,1,1,target,"sfw_nemeum");break;
                    case "longqi":
                        spawnSoldier(m_metagame,1,1,target,"sfw_dragoon");break;
                    case "m16":
                        spawnSoldier(m_metagame,1,1,target,"sfw_M16A1");break;
                    case "baka":
                        spawnSoldier(m_metagame,1,1,target,"sfw_Destroyer");
                        break;
                    case "diner":
                        spawnSoldier(m_metagame,1,1,target,"sf_dinergate");
                        break;
                    case "xfj":
                        spawnSoldier(m_metagame,1,1,target,"sf_scouts");
                        break;
                    case "aegis": spawnSoldier(m_metagame,1,1,target,"kcco_aegis");
                        break;
                    case "nbl":
                        spawnSoldier(m_metagame,1,1,target,"kcco_cerynitis");
                        break;
                    case "archer":
                        spawnSoldier(m_metagame,1,1,target,"kcco_archer");
                        break;
                    case "kccodog":
                        spawnSoldier(m_metagame,1,1,target,"kcco_dog");
                        break;
                    case "lhh":
                        spawnSoldier(m_metagame,1,1,target,"kcco_teslatrooper");
                        break;
                    case "kccoar":
                        spawnSoldier(m_metagame,1,1,target,"kcco_ar");
                        break;
                    case "paraar":
                        spawnSoldier(m_metagame,1,1,target,"para_strelet");
                        break;
                    case "tiaotiao":
                        spawnSoldier(m_metagame,1,1,target,"para_rodelero");
                        break;
                    case "zhs":
                        spawnSoldier(m_metagame,1,1,target,"parw_commander");
                        break;
                    case "police":
                        spawnSoldier(m_metagame,1,1,target,"parw_police");
                        break;
                    case "paradog": spawnSoldier(m_metagame,1,1,target,"parw_dog");
                        break;
                    case "nyto":
                        spawnSoldier(m_metagame,1,1,target,"alina");
                        break;
                    case "teal":
                        spawnSoldier(m_metagame,1,1,target,"teal");
                        break;
                    case "int":
                        spawnSoldier(m_metagame,1,1,target,"sfw_Intruder");
                        break;
                    case "bgd":
                        spawnSoldier(m_metagame,1,1,target,"Paradeus_doppelsoldner");
                        break;
                    case "nbl2":
                        spawnSoldier(m_metagame,1,1,target,"kcco_cerynitis_swap");
                        break;
                    case "daoniang":
                        spawnSoldier(m_metagame,1,1,target,"Brute");
                        break;
                    case "daoniang_s":
                        spawnSoldier(m_metagame,1,1,target,"Brute_swap");
                        break;
                    case "njie":
                        spawnSoldier(m_metagame,1,1,target,"Narciss");
                        break;
                }
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
