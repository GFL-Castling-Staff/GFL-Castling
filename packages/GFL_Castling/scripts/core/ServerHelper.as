#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"
#include "GFLparameters.as"
#include "kill_event.as"
#include "commandskill.as"

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

        if(checkCommand(message,"addmosin_level")){
            const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
            if (playerInfo is null) return;				
            int characterId= playerInfo.getIntAttribute("character_id");

            int j = findKillCountIndex(characterId,"mosinnagant");
            if(j>=0){
                KillCountArray[j].add(9);
            }
            else{
                KillCountArray.insertLast(kill_count(characterId,9,"mosinnagant"));       
            }
        }

        if(checkCommand(message,"addmosin_500")){
            const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
            if (playerInfo is null) return;				
            int characterId= playerInfo.getIntAttribute("character_id");

            int j = findKillCountIndex(characterId,"mosinnagant");
            if(j>=0){
                KillCountArray[j].add(500);
            }
            else{
                KillCountArray.insertLast(kill_count(characterId,500,"mosinnagant"));       
            }
        }

        if(checkCommand(message,"add98klevel")){
            const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
            if (playerInfo is null) return;				
            int characterId= playerInfo.getIntAttribute("character_id");
            string strname= playerInfo.getStringAttribute("name");
            int j = findNodeleteDataIndex(strname,"kar98k");
            if(j>=0){
                No_Delete_DataArray[j].add();
                const XmlElement@ characterInfo = getCharacterInfo(m_metagame,characterId);
                if (characterInfo is null) return;
                string c_pos = characterInfo.getStringAttribute("position");
                spawnStaticProjectile(m_metagame,"particle_effect_98k_medal.projectile",c_pos,characterId,characterInfo.getIntAttribute("faction_id"));
            }
            else{
                No_Delete_DataArray.insertLast(no_delete_data(strname,1,"kar98k"));       
                const XmlElement@ characterInfo = getCharacterInfo(m_metagame,characterId);
                if (characterInfo is null) return;
                string c_pos = characterInfo.getStringAttribute("position");
                spawnStaticProjectile(m_metagame,"particle_effect_98k_medal.projectile",c_pos,characterId,characterInfo.getIntAttribute("faction_id"));                            
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
                if(s=="qwd") spawnSoldier(m_metagame,1,1,target,"sf_manticore");
                if(s=="hydra") spawnSoldier(m_metagame,1,1,target,"kcco_Hydra");
                if(s=="vespid") spawnSoldier(m_metagame,1,1,target,"sf_vespid");
                if(s=="guard") spawnSoldier(m_metagame,1,1,target,"sf_guard");
                if(s=="jaeger") spawnSoldier(m_metagame,1,1,target,"sf_jaeger");
                if(s=="gangshi") spawnSoldier(m_metagame,1,1,target,"sfw_nemeum");
                if(s=="longqi") spawnSoldier(m_metagame,1,1,target,"sfw_dragoon");
                if(s=="m16") spawnSoldier(m_metagame,1,1,target,"sfw_M16A1");
                if(s=="baka") spawnSoldier(m_metagame,1,1,target,"sfw_Destroyer");
                if(s=="diner") spawnSoldier(m_metagame,1,1,target,"sf_dinergate");
                if(s=="xfj") spawnSoldier(m_metagame,1,1,target,"sf_scouts");
                if(s=="aegis") spawnSoldier(m_metagame,1,1,target,"kcco_aegis");
                if(s=="nbl") spawnSoldier(m_metagame,1,1,target,"kcco_cerynitis");
                if(s=="archer") spawnSoldier(m_metagame,1,1,target,"kcco_archer");
                if(s=="kccodog") spawnSoldier(m_metagame,1,1,target,"kcco_dog");
                if(s=="lhh") spawnSoldier(m_metagame,1,1,target,"kcco_teslatrooper");
                if(s=="kccoar") spawnSoldier(m_metagame,1,1,target,"kcco_ar");
                if(s=="paraar") spawnSoldier(m_metagame,1,1,target,"para_strelet");
                if(s=="tiaotiao") spawnSoldier(m_metagame,1,1,target,"para_rodelero");
                if(s=="zhs") spawnSoldier(m_metagame,1,1,target,"parw_commander");
                if(s=="police") spawnSoldier(m_metagame,1,1,target,"parw_police");
                if(s=="paradog") spawnSoldier(m_metagame,1,1,target,"parw_dog");
                if(s=="nyto") spawnSoldier(m_metagame,1,1,target,"alina");
                if(s=="teal") spawnSoldier(m_metagame,1,1,target,"teal");
                if(s=="int") spawnSoldier(m_metagame,1,1,target,"sfw_Intruder");
                if(s=="bgd") spawnSoldier(m_metagame,1,1,target,"Paradeus_doppelsoldner");
                //if(s=="mgnmsl") spawnSoldier(m_metagame,1,0,target,"default_mg");
                if(s=="nbl2") spawnSoldier(m_metagame,1,1,target,"kcco_cerynitis_swap");
                if(s=="daoniang") spawnSoldier(m_metagame,1,1,target,"Brute");
                if(s=="daoniang_s") spawnSoldier(m_metagame,1,1,target,"Brute_swap");
                if(s=="njie") spawnSoldier(m_metagame,1,1,target,"Narciss");
                if(s=="pathfinder") spawnSoldier(m_metagame,5,0,target,"kcco_pathfinder");
                if(s=="cerberus") spawnSoldier(m_metagame,1,0,target,"cerberus");
                if(s=="uhlan") spawnVehicle(m_metagame,1,0,target,Orientation(0,1,0,0.1),"paradeus_uhlan.vehicle");
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
