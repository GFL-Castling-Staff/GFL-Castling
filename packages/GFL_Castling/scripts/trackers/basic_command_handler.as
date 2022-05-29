// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"

// --------------------------------------------
class BasicCommandHandler : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	BasicCommandHandler(Metagame@ metagame) {
		@m_metagame = @metagame;
	}
	
	// ----------------------------------------------------
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
		if (checkCommand(message, "chat")) {
			if (message=="/chat1") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;				
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat1d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat1",dictionary(),0.9);
			}
			if (message=="/chat2") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat2d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat2",dictionary(),0.9);
			}
			if (message=="/chat3") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat3d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat3",dictionary(),0.9);
			}
			if (message=="/chat4") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat4d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat4",dictionary(),0.9);
			}
			if (message=="/chat5") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				playSound(m_metagame, "objective_priority.wav", 0); //high priority
				sendFactionMessageKey(m_metagame, 0,"quickchat5d",a,2.0);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat5",dictionary(),0.9);
			}
			if (message=="/chat6") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat6d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat6",dictionary(),0.9);
			}
			if (message=="/chat7") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat7d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat7",dictionary(),0.9);
			}
			if (message=="/chat8") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat8d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat8",dictionary(),0.9);
			}
			if (message=="/chat9") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat9d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat9",dictionary(),0.9);
			}
			if (message=="/chat10") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat10d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat10",dictionary(),0.9);
			}
			if (message=="/chat11") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat11d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat11",dictionary(),0.9);
			}
			if (message=="/chat12") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat12d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat12",dictionary(),0.9);
			}
			if (message=="/chat13") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat13d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat13",dictionary(),0.9);
			}
			if (message=="/chat14") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat14d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat14",dictionary(),0.9);
			}
			if (message=="/chat15") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat15d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat15",dictionary(),0.9);
			}
			if (message=="/chat16") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat16d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat16",dictionary(),0.9);
			}
			if (message=="/chat17") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat17d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat17",dictionary(),0.9);
			}
			if (message=="/chat18") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat18d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat18",dictionary(),0.9);
			}
			if (message=="/chat19") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat19d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat19",dictionary(),0.9);
			}
			if (message=="/chat20") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat20d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat20",dictionary(),0.9);
			}
			if (message=="/chat21") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat21d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat21",dictionary(),0.9);
			}
			if (message=="/chat22") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat22d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat22",dictionary(),0.9);
			}
			if (message=="/chat23") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat23d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat23",dictionary(),0.9);
			}
			if (message=="/chat24") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat24d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat24",dictionary(),0.9);
			}
			if (message=="/chat25") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat25d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat25",dictionary(),0.9);
			}
			if (message=="/chat26") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat26d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat26",dictionary(),0.9);
			}
			if (message=="/chat27") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat27d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat27",dictionary(),0.9);
			}
			if (message=="/chat28") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat28d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat28",dictionary(),0.9);
			}
			if (message=="/chat29") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat29d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat29",dictionary(),0.9);
			}
			if (message=="/chat30") {
				const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
				if (playerInfo is null) return;
				string strname= playerInfo.getStringAttribute("name");
				dictionary a;
				a["%name"] = strname;
				int cId= playerInfo.getIntAttribute("character_id");
				sendFactionMessageKey(m_metagame, 0,"quickchat30d",a,0.9);
				sendFactionMessageKeySaidAsCharacter(m_metagame, 0, cId,"quickchat30",dictionary(),0.9);
			}
		}

		else if (checkCommand(message, "dance1")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");
			playAnimationKey(m_metagame,characterId,"dancing, kazachok",true,true);
		}
		else if (checkCommand(message, "dance2")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, raise hands",true,true);
		}
		else if (checkCommand(message, "dance3")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, beat hands",true,true);
		}
		else if (checkCommand(message, "dance4")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, ten years old ass",true,true);
		}
		else if (checkCommand(message, "dance5")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, helltaker",true,true);
		}
		else if (checkCommand(message, "dance6")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, phut hon",true,true);
		}
		else if (checkCommand(message, "action1")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"celebrating",true,true);
		}
		else if (checkCommand(message, "action2")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"celebrating2",true,true);
		}
		
		// admin and moderator only from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId) && !m_metagame.getModeratorManager().isModerator(sender, senderId)) {
			return;
		}
		if (checkCommand(message, "modtest")) {
			dictionary dict = {{"TagName", "command"},{"class", "chat"},{"text", "mod or admin"}};
			m_metagame.getComms().send(XmlElement(dict));
		} else if (checkCommand(message, "sidinfo")) {
			handleSidInfo(message,senderId);
		} else if (checkCommand(message, "kick_id")) {
			handleKick(message, senderId, true);
		} else if (checkCommand(message, "kick")) {
			handleKick(message, senderId);
		} else if (checkCommand(message, "0_win")) {
			m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='1' />");
			m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='2' />");
			m_metagame.getComms().send("<command class='set_match_status' win='1' faction_id='0' />");
		} else if (checkCommand(message, "1_win")) {
			m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='0' />");
			m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='2' />");
			m_metagame.getComms().send("<command class='set_match_status' win='1' faction_id='1' />");
		} else if (checkCommand(message, "1_lose")) {
			m_metagame.getComms().send("<command class='set_match_status' lose='1' faction_id='1' />");
		} else if (checkCommand(message, "1_own")) {
			int factionId = 1;
			array<const XmlElement@> bases = getBases(m_metagame);
			for (uint i = 0; i < bases.size(); ++i) {
				const XmlElement@ base = bases[i];
				if (base.getIntAttribute("owner_id") != factionId) {
					XmlElement command("command");
					command.setStringAttribute("class", "update_base");
					command.setIntAttribute("base_id", base.getIntAttribute("id"));
					command.setIntAttribute("owner_id", factionId);
					m_metagame.getComms().send(command);
				}
			}
		}
		
		// admin only from here on
		if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
			return;
		}
		else if (checkCommand(message, "testa1")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"stabbing_roarer",true,true);
		}
		else if (checkCommand(message, "testa2")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"throwing, large mecha",true,true);
		}
		// it's a silent server command, check which one
		if (checkCommand(message, "test2")) {
			string command = "<command class='set_marker' faction_id='0' position='512 0 512' color='0 0 1' atlas_index='0' text='hello!' />";
			m_metagame.getComms().send(command);
		} else if (checkCommand(message, "test")) {
			dictionary dict = {{"TagName", "command"},{"class", "chat"},{"text", "test yourself!"}};
			m_metagame.getComms().send(XmlElement(dict));

		} else if (checkCommand(message, "defend")) {
			// make ai defend only, both sides
			for (int i = 0; i < 2; ++i) {
				string command =
					"<command class='commander_ai'" +
					"	faction='" + i + "'" +
					"	base_defense='1.0'" +
					"	border_defense='0.0'>" +
					"</command>";
				m_metagame.getComms().send(command);
			}
			sendPrivateMessage(m_metagame, senderId, "defensive ai set");
		} else if (checkCommand(message,"bpiq")){
			const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
				int characterId = info.getIntAttribute("character_id");
				@info = getCharacterInfo2(m_metagame, characterId);
			}
		} else if (checkCommand(message, "0_attack")) {
			// make ai attack only, both sides
			string command =
				"<command class='commander_ai'" +
				"	faction='0'" +
				"	base_defense='0.0'" +
				"	border_defense='0.0'>" +
				"</command>";
			m_metagame.getComms().send(command);
			sendPrivateMessage(m_metagame, senderId, "attack green ai set");

		} else if (checkCommand(message, "whereami")) {
			_log("whereami received", 1);
			const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
				int characterId = info.getIntAttribute("character_id");
				@info = getCharacterInfo(m_metagame, characterId);
				if (info !is null) {
					string posStr = info.getStringAttribute("position");
					Vector3 pos = stringToVector3(posStr);
					string region = m_metagame.getRegion(pos);

					string text = posStr + ", " + region;

					sendPrivateMessage(m_metagame, senderId, text);
				} else {
					_log("character info not ok", 1);
				}
			} else {
				_log("player info not ok", 1);
			}
		} else  if(checkCommand(message, "kill_aa")) {
			for (uint f = 1; f < 3; ++f) {
				array<const XmlElement@>@ vehicles = getVehicles(m_metagame, f, "aa_emplacement.vehicle");
				
				for (uint i = 0; i < vehicles.size(); ++i) {
					const XmlElement@ vehicle = vehicles[i];
					int id = vehicle.getIntAttribute("id");
					destroyVehicle(m_metagame, id);
				}
			}
		} else  if(checkCommand(message, "promote")) {
			const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
				int id = info.getIntAttribute("character_id");
				string command =
					"<command class='xp_reward'" +
					"	character_id='" + id + "'" +
					"	reward='4.0'>" + // multiplier affected..
					"</command>";
				m_metagame.getComms().send(command);
			} else {
				_log("player info is null");
			}
		} else if (checkCommand(message, "rp")) {
			const XmlElement@ info = getPlayerInfo(m_metagame, senderId);
			if (info !is null) {
				int id = info.getIntAttribute("character_id");
				string command =
					"<command class='rp_reward'" +
					"	character_id='" + id + "'" +
					"	reward='100000000'>" + // multiplier affected..
					"</command>";
				m_metagame.getComms().send(command);
			}
		} else  if(checkCommand(message, "god")) {
			// .. god vest!
			spawnInstanceNearPlayer(senderId, "god_vest.carry_item", "carry_item");    		
        } else if (checkCommand(message, "create_vehicle")) {
			spawnInstanceNearPlayer(senderId, "special_cargo_vehicle1.vehicle", "vehicle");
		} else if (checkCommand(message, "jeep")) {
			spawnInstanceNearPlayer(senderId, "jeep.vehicle", "vehicle");      
		} else  if(checkCommand(message, "c4")) {
			spawnInstanceNearPlayer(senderId, "c4.projectile", "projectile");      
		} else if (checkCommand(message, "dc")) {
			spawnInstanceNearPlayer(senderId, "cover_resource.weapon", "weapon");
		} else if (checkCommand(message, "dgl")) {
			spawnInstanceNearPlayer(senderId, "gl_resource.weapon", "weapon");
		} else if (checkCommand(message, "dmg")) {
			spawnInstanceNearPlayer(senderId, "mg_resource.weapon", "weapon");
		} else if (checkCommand(message, "milkor")) {
			spawnInstanceNearPlayer(senderId, "milkor_mgl.weapon", "weapon");
		} else if (checkCommand(message, "m72")) {
			spawnInstanceNearPlayer(senderId, "m72_law.weapon", "weapon");
			spawnInstanceNearPlayer(senderId, "m72_law.weapon", "weapon");
			spawnInstanceNearPlayer(senderId, "m72_law.weapon", "weapon");
			spawnInstanceNearPlayer(senderId, "m72_law.weapon", "weapon");
		} else if (checkCommand(message, "cargo")) {
			spawnInstanceNearPlayer(senderId, "cargo_truck.vehicle", "vehicle", 1);
		} else if (checkCommand(message, "tank")) {
			spawnInstanceNearPlayer(senderId, "tank.vehicle", "vehicle", 0);
		} else if (checkCommand(message, "apc")) {
			spawnInstanceNearPlayer(senderId, "apc.vehicle", "vehicle", 0);
		} else if (checkCommand(message, "tow")) {
			spawnInstanceNearPlayer(senderId, "tow.vehicle", "vehicle", 1);
		} else if (checkCommand(message, "teddy")) {
			spawnInstanceNearPlayer(senderId, "teddy.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "briefcase")) {
			spawnInstanceNearPlayer(senderId, "suitcase.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "friend")) {
			spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
        } else if (checkCommand(message, "squad")) {
			spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 0);            
        } else if (checkCommand(message, "esquad")) {
			spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "default", "soldier", 1);                 
		} else if (checkCommand(message, "spawnbhh")) {
			spawnInstanceNearPlayer(senderId, "Paradeus_roarer", "soldier", 0);            
		} else if (checkCommand(message, "foe")) {
			spawnInstanceNearPlayer(senderId, "default", "soldier", 1);
		} else if (checkCommand(message, "eod")) {
			spawnInstanceNearPlayer(senderId, "eod", "soldier", 0);
		} else if (checkCommand(message, "sniper")) {
			spawnInstanceNearPlayer(senderId, "sniper", "soldier", 0);
		} else if (checkCommand(message, "dog")) {
			spawnInstanceNearPlayer(senderId, "dog", "soldier", 0);    	
		} else if (checkCommand(message, "gb1")) {
			spawnInstanceNearPlayer(senderId, "gift_box_1.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "gb2")) {
			spawnInstanceNearPlayer(senderId, "gift_box_2.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "gb3")) {
			spawnInstanceNearPlayer(senderId, "gift_box_3.carry_item", "carry_item", 0);        
		} else if (checkCommand(message, "cb1")) {
			spawnInstanceNearPlayer(senderId, "gift_box_community_1.carry_item", "carry_item", 0); 
            spawnInstanceNearPlayer(senderId, "gift_box_community_1.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_1.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_1.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_1.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "cb2")) {
			spawnInstanceNearPlayer(senderId, "sf_box.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "sf_box.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "sf_box.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "sf_box.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "sf_box.carry_item", "carry_item", 0);                      
        } else if (checkCommand(message, "cb3")) {
			spawnInstanceNearPlayer(senderId, "gift_box_community_3.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_3.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_3.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_3.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_3.carry_item", "carry_item", 0);  
        } else if (checkCommand(message, "cb4")) {
			spawnInstanceNearPlayer(senderId, "gift_box_community_4.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_4.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_4.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_4.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_4.carry_item", "carry_item", 0);  
        } else if (checkCommand(message, "cb5")) {
			spawnInstanceNearPlayer(senderId, "gift_box_community_5.carry_item", "carry_item", 0); 
            spawnInstanceNearPlayer(senderId, "gift_box_community_5.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_5.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_5.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_5.carry_item", "carry_item", 0);                                                     
        } else if (checkCommand(message, "cb6")) {
			spawnInstanceNearPlayer(senderId, "gift_box_community_6.carry_item", "carry_item", 0); 
            spawnInstanceNearPlayer(senderId, "gift_box_community_6.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_6.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_6.carry_item", "carry_item", 0);
            spawnInstanceNearPlayer(senderId, "gift_box_community_6.carry_item", "carry_item", 0);   			
		} else  if(checkCommand(message, "kill_rt")) {
			destroyAllEnemyVehicles("radar_tower.vehicle");
		} else  if(checkCommand(message, "kill_own_rt")) {
			destroyAllFactionVehicles(0, "radar_tower.vehicle");
		} else  if(checkCommand(message, "kill_rj")) {
			destroyAllEnemyVehicles("radio_jammer.vehicle");
		} else  if(checkCommand(message, "mustela")) {
			spawnInstanceNearPlayer(senderId, "wiesel_tow.vehicle", "vehicle", 0);        
		} else  if(checkCommand(message, "mortar")) {
			spawnInstanceNearPlayer(senderId, "mortar_resource.weapon", "weapon", 0);        
		} else  if(checkCommand(message, "humvee")) {
			spawnInstanceNearPlayer(senderId, "humvee_gl_para.vehicle", "vehicle", 0);        
		} else  if(checkCommand(message, "javelin")) {
			spawnInstanceNearPlayer(senderId, "javelin_ap.weapon", "weapon", 0);        
		} else  if(checkCommand(message, "complete_campaign")) {
			m_metagame.getComms().send("<command class='set_campaign_status' show_stats='1'/>");
		} else if (checkCommand(message, "enable_gps")) {
			m_metagame.getComms().send("<command class='faction_resources' faction_id='0'><call key='gps.call' /></command>");
		} else  if(checkCommand(message, "icecream")) {
			int randIndex=rand(1,3);
			spawnInstanceNearPlayer(senderId, "icecream.vehicle", "vehicle", 0);        
		} else  if(checkCommand(message, "rj")) {
			spawnInstanceNearPlayer(senderId, "radio_jammer.vehicle", "vehicle", 1);        
		} else  if(checkCommand(message, "cat")) {
			spawnInstanceNearPlayer(senderId, "darkcat.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "ecat")) {
			spawnInstanceNearPlayer(senderId, "darkcat.vehicle", "vehicle", 1);
		} else  if(checkCommand(message, "spawntower")) {
			spawnInstanceNearPlayer(senderId, "radar_tower.vehicle", "vehicle", 0); 
		} else  if(checkCommand(message, "spawnaa")) {
			spawnInstanceNearPlayer(senderId, "aa_emplacement.vehicle", "vehicle", 1); 
		} else  if(checkCommand(message, "spawnjpt")) {
			spawnInstanceNearPlayer(senderId, "sf_jupiter.vehicle", "vehicle", 1); 		
		} else  if(checkCommand(message, "spawnuhlan")) {
			spawnInstanceNearPlayer(senderId, "paradeus_uhlan.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawncoeus")) {
			spawnInstanceNearPlayer(senderId, "coeus.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawntyphon")) {
			spawnInstanceNearPlayer(senderId, "typhon.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnpierre")) {
			spawnInstanceNearPlayer(senderId, "pierre.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnamos")) {
			spawnInstanceNearPlayer(senderId, "armored_truck.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawncompass")) {
			spawnInstanceNearPlayer(senderId, "par_compass.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnjxk")) {
			spawnInstanceNearPlayer(senderId, "mobile_armory.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnybc")) {
			spawnInstanceNearPlayer(senderId, "kcco_trans_truck.vehicle", "vehicle", 0);			
		} else if (checkCommand(message, "spawntarget")) {
			spawnInstanceNearPlayer(senderId, "GK_target", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "GK_target", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "GK_target", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "GK_target", "soldier", 0);
            spawnInstanceNearPlayer(senderId, "GK_target", "soldier", 0);
		} else if (checkCommand(message, "spawnqwd")) {
			spawnInstanceNearPlayer(senderId, "kcco_Hydra", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_Hydra", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_Hydra", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_Hydra", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_Hydra", "soldier", 1);
		} else if (checkCommand(message, "spawnlhh")) {
			spawnInstanceNearPlayer(senderId, "kcco_teslatrooper", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_teslatrooper", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_teslatrooper", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_teslatrooper", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_teslatrooper", "soldier", 1);
		} else if (checkCommand(message, "spawnkccoar")) {
			spawnInstanceNearPlayer(senderId, "kcco_ar", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_ar", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_ar", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_ar", "soldier", 1);
            spawnInstanceNearPlayer(senderId, "kcco_ar", "soldier", 1);      
		} else if (checkCommand(message,"givesfweapon")){
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","ff_agent.weapon");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","ff_alchemist.weapon");
		} else if (checkCommand(message,"114514sf")){
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			addMutilItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"carry_item","gift_box_1.carry_item",400);            			
		} else  if(checkCommand(message, "wound")) {
			for (int i = 2; i < 100; ++i) {
				string command =
					"<command class='update_character'" +
					"	id='" + i + "'" +
					"	wounded='1'>" + 
					"</command>";
				m_metagame.getComms().send(command);
			}
		} else if (checkCommand(message, "fill")) {
			fillInventory(senderId);
		}
	}

	// --------------------------------------------
	bool hasEnded() const {
		// always on
		return false;
	}

	// --------------------------------------------
	bool hasStarted() const {
		// always on
		return true;
	}
	
	// --------------------------------------------
	void handleKick(string message, int senderId, bool id = false) {
		const XmlElement@ player = getPlayerByIdOrNameFromCommand(m_metagame, message, id);
		if (player !is null) {
			int playerId = player.getIntAttribute("player_id");
			string name = player.getStringAttribute("name");
			notify(m_metagame, "kicking player", dictionary = {{"%player_name", name}}, "misc");

			notify(m_metagame, "Kicked from server", dictionary(), "misc", playerId, true, "", 1.0);
            ::kickPlayer(m_metagame, playerId);

		} else {
			//_log("* couldn't find a match for name=" + name + "");
			sendPrivateMessage(m_metagame, senderId, "kick missed!");
		}
	}
	
	// --------------------------------------------
	void handleSidInfo(string message, int senderId) {
		// get name given as parameter
		string name = message.substr(string("sidinfo ").length() + 1);

		// assuming player name 
		// ask for player list from the server
		array<const XmlElement@> playerList = getPlayers(m_metagame);
		_log("* "  + playerList.size() + " players found");
		
		// go through the player list and match for the given name
		bool foundFlag = false;
		string playerSid = "";
		for (uint i = 0; i < playerList.size(); ++i) {
			const XmlElement@ player = playerList[i];
			string name2 = player.getStringAttribute("name");
			// case insensitive
			if (name2.toLowerCase() == name.toLowerCase()) {
				// found it
				playerSid = player.getStringAttribute("sid");
				foundFlag = true;
				break;
			}
		}
		if (foundFlag){
			sendPrivateMessage(m_metagame, senderId, "player " + name + " found, SID: " + playerSid);
		} else {
			_log("* couldn't find a match for " + name);
			sendPrivateMessage(m_metagame, senderId, "player not found");
		}
	}
	
	// ----------------------------------------------------
	protected void spawnInstanceNearPlayer(int senderId, string key, string type, int factionId = 0) {
		const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
		if (playerInfo !is null) {
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
			if (characterInfo !is null) {
				Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));
				pos.m_values[0] += 5.0;
				string c = "<command class='create_instance' instance_class='" + type + "' instance_key='" + key + "' position='" + pos.toString() + "' faction_id='" + factionId + "' />";
				m_metagame.getComms().send(c);
			}
		}
	}

	// ----------------------------------------------------
	protected void destroyAllFactionVehicles(uint f, string key) {
		array<const XmlElement@>@ vehicles = getVehicles(m_metagame, f, key);
		
		for (uint i = 0; i < vehicles.size(); ++i) {
			const XmlElement@ vehicle = vehicles[i];
			int id = vehicle.getIntAttribute("id");
			destroyVehicle(m_metagame, id);
		}
	}

	// ----------------------------------------------------
	protected void destroyAllEnemyVehicles(string key) {
		for (uint f = 1; f < 3; ++f) {
			destroyAllFactionVehicles(f, key);
		}
	}

	// ----------------------------------------------------
	protected void addItem(XmlElement@ command, Resource@ r) {
		XmlElement i("item"); 
		i.setStringAttribute("class", r.m_type); 
		i.setStringAttribute("key", r.m_key); 
		command.appendChild(i); 
	}

	// ----------------------------------------------------
	protected void fillInventory(int senderId) {
		const XmlElement@ player = getPlayerInfo(m_metagame, senderId);
		if (player !is null) {
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, player.getIntAttribute("character_id"));
			if (characterInfo !is null) {
				int characterId = player.getIntAttribute("character_id");
				XmlElement c("command");
				c.setStringAttribute("class", "update_inventory");

				c.setIntAttribute("character_id", characterId); 
				c.setStringAttribute("container_type_class", "backpack");
				
				for (uint i = 0; i < 3; ++i) {
					array<string> typeStr1 = {"weapon", "grenade", "carry_item"};
					array<string> typeStr2 = {"weapons", "grenades", "carry_items"};
					for (uint k = 0; k < typeStr1.size(); ++k) {
						array<const XmlElement@>@ resources = getFactionResources(m_metagame, i, typeStr1[k], typeStr2[k]);
						for (uint j = 0; j < resources.size(); ++j) {
							const XmlElement@ item = resources[j];
							addItem(c, Resource(item.getStringAttribute("key"), typeStr1[k]));
						}
					}
				}
				
				m_metagame.getComms().send(c);
			}
		}
	}
}
