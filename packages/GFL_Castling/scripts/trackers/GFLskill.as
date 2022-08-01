#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "task_sequencer.as"
//Author: NetherCrow
//Author: SAIWA

dictionary gameSkillIndex = {

        // 空技能
        {"",0},

        // 生成防空炮
        {"aa_spawn",1},

        // 摧毁防空炮
        {"aa_destroy",2},

        // RO635技能，已弃用
        {"RO635_skill",3},

        // SOPMODII散射榴弹
        {"SOPMOD_skill",4},

        // UMP9白鸮轰鸣
        {"ump9_skill",5},

        // 维修妖精
        {"repair_fairy",6},

        // XM8技能
        {"xm8_skill",7},

        // HK416寄生榴弹
        {"416_skill",8},

        // KCCO智能雷扫描阶段
        {"kcco_smartgrenade_scan",9},

        // 给ai用的标枪脚本
        {"javelin_launch_for_sb_ai",10},

        // 标枪锁定兼射出弹头阶段
        {"javelin_launch",11},

        // 标枪弹头改垂直爬升阶段
        {"javelin_uprise",12},

        // 标枪弹头改垂直攻顶阶段
        {"javelin_strike",13},

        // VECTOR燃烧弹
        {"VV_skill",14},

        // STG44炎风暴
        {"stg44_skill",15},

        // 刺雷半载
        {"banzai100",16},

        // 白教白憨憨普攻砸地
        {"roarer",17},

        // 白教白憨憨技能搓球砸地
        {"roarer_skill",18},

        // G3榴弹
        {"g3_skill",19},

        // 大僵尸技能
        {"smasher_skill",20},

        // 刘氏步枪协同攻击
        {"rf_liu",21},

        // KCCO狙击手脚本弹头
        {"kcco_sniper_scan",22},

        // 下面这行是用来占位的，在这之上添加新的技能key和index即可
        {"666",-1}
};
	// --------------------------------------------
class GFLskill : Tracker {
	protected GameMode@ m_metagame;
	uint m_fnum;

	// --------------------------------------------
	GFLskill(GameMode@ metagame) {
		@m_metagame = @metagame;
	}
	protected array<string> GKcallList={
		"gk_airstrike_fairy.call",
		"gk_rocket_fairy.call",
		"sg1hg1mg2.call",
		"hvy_landing.call",
		"martina.call",
		"chiara.call",
		"pierre.call",
		"gk_repair_fairy.call",
		"target.call",
		"manticore.call"
	};

    protected array<XM8tracker@> XM8track;
	protected array<HK416_tracker@> HK416_track;
	protected array<Vector_tracker@> Vector_track;
	protected array<Javelin_lister@> Javelin_list;

	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		//checking if the event was triggered by a rangefinder notify_script
		string EventKeyGet = event.getStringAttribute("key");
		switch(int(gameSkillIndex[EventKeyGet]))
        {
            case 0: {break;}

            case 1: {// 生成防空炮
				const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
				if(playerFaction.getStringAttribute("name")=="G&K PMC"){
					XmlElement command("command");
					command.setStringAttribute("class", "faction_resources");
					command.setIntAttribute("faction_id", 0);
					addFactionResourceElements(command, "call", GKcallList, false);
					m_metagame.getComms().send(command);
				}
				break;
			}

			case 2: {// 摧毁防空炮
				const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
				if(playerFaction.getStringAttribute("name")=="G&K PMC"){
					XmlElement command("command");
					command.setStringAttribute("class", "faction_resources");
					command.setIntAttribute("faction_id", 0);
					addFactionResourceElements(command, "call", GKcallList, true);
					m_metagame.getComms().send(command);
				}
				break;
			}
			// if (EventKeyGet == "Jupiter_spawn"){
			// 	const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
			// 	if(playerFaction.getStringAttribute("name")=="G&K PMC"){
			// 		XmlElement command("command");
			// 		command.setStringAttribute("class", "faction_resources");
			// 		command.setIntAttribute("faction_id", 0);
			// 		addFactionResourceElements(command, "call", GKcallList, false);
			// 		m_metagame.getComms().send(command);
			// 	}
			// }
			// if (EventKeyGet == "Jupiter_down"){
			// 	const XmlElement@ playerFaction = getFactionInfo(m_metagame,0);
			// 	if(playerFaction.getStringAttribute("name")=="G&K PMC"){
			// 		XmlElement command("command");
			// 		command.setStringAttribute("class", "faction_resources");
			// 		command.setIntAttribute("faction_id", 0);
			// 		addFactionResourceElements(command, "call", GKcallList, true);
			// 		m_metagame.getComms().send(command);
			// 	}
			// }
			case 3: {// RO635技能，已弃用
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					
					if (player !is null) {
				
						if (player.hasAttribute("aim_target")) {
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							string c = 
								"<command class='create_instance'" +
								" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
								" instance_class='grenade'" +
								" instance_key='RO635skiller.projectile'" +
								" position='" + target.toString() + "' />";
							m_metagame.getComms().send(c);
						}
					}
				}
				break;
			}

			case 4: {// SOPMODII散射榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='40mm.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='std_aa_grenade.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);
						m_metagame.getComms().send(c);
					}
				}
				break;
			}

			case 5: {// UMP9白鸮轰鸣
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
						int factionid = player.getIntAttribute("faction_id");
						int affectedNumber =0;
						//获取技能影响的敌人数量
						array<int> enemyfaction = {0,1,2,3,4};
						for(int i =0;i<4;i++){
							if (enemyfaction[i] ==factionid){
								enemyfaction.removeAt(i);
							}
						}
						int n=enemyfaction.length-1;
						for(int i=0;i<n;i++){
							array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,grenade_pos,enemyfaction[i],15.0f);
							affectedNumber += affectedCharacter.length;
						}
						string sendtext= "白鸮轰鸣击中了"+ affectedNumber +"个敌人";
						sendPrivateMessage(m_metagame,playerId,sendtext);
						int PlayerfactionId = player.getIntAttribute("faction_id");
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ PlayerfactionId +"'" +
							" instance_class='grenade'" +
							" instance_key='ump9_stun_grenade.projectile'" +
							" position='" + grenade_pos.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);					
						if (affectedNumber >= 6){
							Vector3 UMP9_pos = stringToVector3(character.getStringAttribute("position"));
							string c1 = 
								"<command class='create_instance'" +
								" faction_id='"+ PlayerfactionId +"'" +
								" instance_class='grenade'" +
								" instance_key='ump9_skill_soldier_spawner.projectile'" +
								" position='" + UMP9_pos.toString() + "'"+
								" character_id='" + characterId + "' />";
							m_metagame.getComms().send(c1);
							playSoundAtLocation(m_metagame,"UMP9_skill_Extra2.wav",PlayerfactionId,UMP9_pos,0.8);						
						}
						else {
							Vector3 UMP9_pos = stringToVector3(character.getStringAttribute("position"));
							playSoundAtLocation(m_metagame,"UMP9_skill_Extra1.wav",PlayerfactionId,UMP9_pos,0.8);
						}
					}
				}
				break;
			}

			case 6: {// 维修妖精
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, grenade_pos, factionid, 20.0f);
					for (uint i = 0; i < characters.length; i++) {
						int soldierId = characters[i].getIntAttribute("id");
						XmlElement c ("command");
						c.setStringAttribute("class", "update_inventory");
						c.setIntAttribute("character_id", soldierId); 
						c.setIntAttribute("untransform_count", 20);
						m_metagame.getComms().send(c);
					}
				}
				break;
			}

			case 7: {// XM8技能
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						int factionid = player.getIntAttribute("faction_id");
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ factionid +"'" +
							" instance_class='grenade'" +
							" instance_key='damage_40mm_aamod3.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);
						XM8track.insertLast(XM8tracker(characterId,1.0,factionid,Pos_40mm));
					}
				}
				break;
			}

			case 8: {// HK416寄生榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						uint factionid = player.getIntAttribute("faction_id");
						//获取技能影响的敌人数量
						m_fnum= m_metagame.getFactionCount();
						array<const XmlElement@> affectedCharacter;
						for(uint i=0;i<m_fnum;i++) 
							if(i!=factionid) {
							array<const XmlElement@> affectedCharacter2;
							affectedCharacter2 = getCharactersNearPosition(m_metagame,Pos_40mm,i,7.0f);
							if (affectedCharacter2 !is null){
								for(uint x=0;x<affectedCharacter2.length();x++){
									affectedCharacter.insertLast(affectedCharacter2[x]);
								}
							}
						}
						if (affectedCharacter.length()>0){
							HK416_track.insertLast(HK416_tracker(characterId,factionid,Pos_40mm,affectedCharacter));
						}
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ factionid +"'" +
							" instance_class='grenade'" +
							" instance_key='damage_40mm_aamod3.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);
					}
				}
				break;
			}

			case 9: {// KCCO智能雷扫描阶段
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					_log("Scan successful");
					for(uint i=0;i<m_fnum;i++) 
						if(i!=factionid) {
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,10.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
					if (affectedCharacter.length()>0) {
						_log("Locate1 successful");
						uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
						uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
						const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
						Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
						//智能雷对披风的减伤
						string vestkey = getPlayerEquipmentKey(m_metagame,luckyGuyid,4);
						if (startsWith(vestkey,'cc_t4') || startsWith(vestkey,'cc_t5_16lab') || startsWith(vestkey,'woshieoe')){
							CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3_1.projectile",characterId,factionid,120,0.01);
						}
						else if(startsWith(vestkey,'bp_t4') || startsWith(vestkey,'bp_t5_16lab') || startsWith(vestkey,'K309')){
							CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3_2.projectile",characterId,factionid,120,0.01);
						}
						else
							CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3.projectile",characterId,factionid,120,0.01);
					}
					else {
						_log("Locate2 successful");
						CreateProjectile(m_metagame,pos_smartgrenade,pos_smartgrenade.add(Vector3(0,-10,0)),"kcco_smartgrenade_3.projectile",characterId,factionid,120,0.01);
					}									
				}			
				break;			
			}

			//标枪导弹，由初始定位弹头，最终定位弹头1,2，标枪一阶段弹头，标枪二阶段弹头五个脚本弹头联合完成。最终打击由标枪三阶段弹头完成。
			//发射过程如下：
			//0.标枪发射器将首先射出初始定位弹头
			//1.初始定位弹头爆炸后在所在位置与发射者处分别射出最终定位弹头1,2与标枪一阶段弹头
			//2.标枪一阶段弹头爆炸后将在所在位置生成二阶段弹头
			//3.最终弹头1,最终弹头2分别引爆并得到最终目标载具坐标
			//4.最终弹头2爆炸后获取最终弹头1,2修正得到的坐标，生成三阶段弹头并射向目标。

			//在得知查询车辆id需要时间并不久后以上说法当放屁处理
			//单次提取到vehicleid后后续一直跟踪id车辆位置即可。

			//给玩家用的标枪以上0过程当放屁，直接读取玩家瞄准位置的坐标然后锁定周围的载具
			//ai由于无法直接读取瞄准位置所以寄，照样，不过目前也没有用标枪的ai

			//激发弹头为贴在目标载具上的初始定位弹头

			case 10: {// 给ai用的标枪脚本
				_log("javelin_launch");
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {

					int factionid = character.getIntAttribute("faction_id");
					Vector3 target_pos = stringToVector3(event.getStringAttribute("position"));//标枪发射器发射时的载具位置
					int vehicleid = getNearByEnemyVehicle(m_metagame,factionid,target_pos,7);

					Vector3 aimer_pos = stringToVector3(character.getStringAttribute("position"));

					Vector3 pos1 = getAimUnitPosition(aimer_pos,target_pos,1);
					Vector3 pos2 = getAimUnitPosition(aimer_pos,target_pos,8.0);
					pos1 = pos1.add(Vector3(0,0.8,0));				
					pos2 = pos2.add(Vector3(0,8,0));
					CreateProjectile(m_metagame,pos1,pos2,"javelin_rocket_1.projectile",characterId,factionid,5,6);	
					//CreateProjectile(m_metagame,target_pos,target_pos.add(Vector3(0,0,0)),"javelin_locater_2.projectile",characterId,factionid,0,8);	
					//CreateProjectile(m_metagame,target_pos,target_pos.add(Vector3(0,0,0)),"javelin_locater_3.projectile",characterId,factionid,0,8);
					Javelin_list.insertLast(Javelin_lister(characterId,factionid,vehicleid,target_pos));//存储初始定位弹头锁定的载具id							
				}			
				break;			
			}
			
			//激发弹头为贴在目标载具上的初始定位弹头
				
			case 11: {// 标枪锁定兼射出弹头阶段
				_log("javelin_launch");
				int characterId = event.getIntAttribute("character_id");
				int playerId = event.getIntAttribute("player_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					Vector3 target_pos;
					int factionid = character.getIntAttribute("faction_id");

					if (player !is null){
						if (player.hasAttribute("aim_target")) {
							target_pos = stringToVector3(player.getStringAttribute("aim_target"));		
						}
					}
					else{
						target_pos = stringToVector3(event.getStringAttribute("position"));//标枪发射器发射时的载具位置
					}

					int vehicleid = getNearByEnemyVehicle(m_metagame,factionid,target_pos,7);
					Vector3 aimer_pos = stringToVector3(character.getStringAttribute("position"));
					if(vehicleid!=-1)playSoundAtLocation(m_metagame,"javelin_locked.wav",factionid,aimer_pos,1.0);//锁定载具成功
					else	playSoundAtLocation(m_metagame,"javelin_lock_fail.wav",factionid,aimer_pos,1.0);//未锁定载具

					Vector3 pos1 = getAimUnitPosition(aimer_pos,target_pos,1);
					Vector3 pos2 = getAimUnitPosition(aimer_pos,target_pos,8.0);
					pos1 = pos1.add(Vector3(0,0.8,0));				
					pos2 = pos2.add(Vector3(0,8,0));
					CreateProjectile(m_metagame,pos1,pos2,"javelin_rocket_1.projectile",characterId,factionid,5,6);	
					//CreateProjectile(m_metagame,target_pos,target_pos.add(Vector3(0,0,0)),"javelin_locater_2.projectile",characterId,factionid,0,8);	
					//CreateProjectile(m_metagame,target_pos,target_pos.add(Vector3(0,0,0)),"javelin_locater_3.projectile",characterId,factionid,0,8);
					Javelin_list.insertLast(Javelin_lister(characterId,factionid,vehicleid,target_pos));//存储初始定位弹头锁定的载具id							
				}			
				break;			
			}

			//激发弹头为标枪导弹一阶段弹头

			case 12: {// 标枪弹头改垂直爬升阶段
				_log("javelin_uprise");
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));//标枪导弹一阶段弹头位置
					if(Javelin_list.length()>0){
						for (uint a=0;a<Javelin_list.length();a++){
							if((Javelin_list[a].m_characterId==characterId)&&(Javelin_list[a].m_factionid==factionid)){//在序列中如果能找到
								_log("javelin_uprise success");
								int target_id = Javelin_list[a].m_vehicleid;
								Vector3 target_pos;
								if(target_id!=-1){
									_log("aimming 1 success.");
									const XmlElement@ target_info = getVehicleInfo(m_metagame, target_id);
									target_pos = stringToVector3(target_info.getStringAttribute("position"));
								}
								else{
									target_pos = Javelin_list[a].m_pos;
								}
								CreateProjectile(m_metagame,aimer_pos,target_pos,"javelin_rocket_2.projectile",characterId,factionid,getAimUnitDistance(0.4,aimer_pos,target_pos),-20);	
								break;								
							}
						}
					}
				}		
				break;			
			}

			//激发弹头为最终定位弹头2			

			case 13: {// 标枪弹头改垂直攻顶阶段
				_log("javelin_strike");
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));//最终弹头位置
					if(Javelin_list.length()>0){
						for (uint a=0;a<Javelin_list.length();a++){
							if((Javelin_list[a].m_characterId==characterId)&&(Javelin_list[a].m_factionid==factionid)){//在序列中如果能找到
								_log("javelin_locate_aimer success");
								int target_id = Javelin_list[a].m_vehicleid;
								Vector3 target_fin_pos;
								if(target_id!=-1){
									_log("aimming 2 success.");
									const XmlElement@ target_info = getVehicleInfo(m_metagame, target_id);

									//有病								
									// Vector3 target_pos1 = stringToVector3(target_info.getStringAttribute("position"));
									// _log("Position 1 = "+target_pos1.toString());

									// TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
									// tasker.add(DelayProjectileSet(m_metagame,0.8,characterId,factionid,"bullet.projectile",target_pos1));
									
									// Vector3 target_pos2 = stringToVector3(target_info.getStringAttribute("position"));
									// _log("Position 2 = "+target_pos2.toString());

									// target_fin_pos = target_pos2.add(getAimUnitVector(5.0,target_pos1,target_pos2));//标枪导弹目标位置
									target_fin_pos = stringToVector3(target_info.getStringAttribute("position"));//标枪导弹目标位置

								}
								else{
									target_fin_pos = Javelin_list[a].m_pos;
								}
								CreateDirectProjectile(m_metagame,aimer_pos,target_fin_pos,"javelin_rocket_3.projectile",characterId,factionid,180);
								Javelin_list.removeAt(a);
								break;																	
							}
						}
					}
				}		
				break;			
			}			

			case 14: {// VECTOR燃烧弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ factionid +"'" +
						" instance_class='grenade'" +
						" instance_key='firenade_Vector_blast.projectile'" +
						" position='" + grenade_pos.toString() + "'"+
						" character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
					Vector_track.insertLast(Vector_tracker(characterId,factionid,grenade_pos));
				}
				break;			
			}

			case 15: {// STG44炎风暴
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='skill_stg44_1.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);
						c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='skill_stg44_2.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);
						c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='skill_stg44_3.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);
					}
				}
				break;			
			}

			case 16: {// 刺雷半载
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='cl.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c);				

						string command = "<command class='update_character' id='" + characterId + "' dead='1' />";
						m_metagame.getComms().send(command);	

						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='cl_1.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);
					}
				}
				break;			
			}

			case 17: {// 白教白憨憨普攻砸地
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					playAnimationKey(m_metagame,characterId,"stabbing_roarer",false);
					Vector3 pos = stringToVector3(event.getStringAttribute("position"));
					TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
					tasker.add(DelayProjectileSet(m_metagame,0.7,characterId,character.getIntAttribute("faction_id"),"roarer_main.projectile",pos));
				}
				break;			
			}

			case 18: {// 白教白憨憨技能搓球砸地
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ character.getIntAttribute("faction_id") +"'" +
						" instance_class='grenade'" +
						" instance_key= 'roarer_main2.projectile'" +
						" position='" + Pos_40mm.toString() + "'"+
						" character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
				}
				break;			
			}
			
			case 19: {// G3榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
						string c = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='damage_40mm_g3.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						Pos_40mm=Pos_40mm.add(Vector3(0,2,0));
						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='damage_40mm_g3_stun.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);
						m_metagame.getComms().send(c);
					}
				}			
				break;			
			}
			
			case 20: {// 大僵尸技能
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {

					Vector3 pos = stringToVector3(character.getStringAttribute("position"));
					int randomeffect = rand(0,1);
					switch(randomeffect){
						case 0:{
							int factionid = character.getIntAttribute("faction_id");
							playAnimationKey(m_metagame,characterId,"warcry, elid boss",false);
							spawnSoldier(m_metagame,10,factionid,pos,"infected");
							break;
						}
						case 1:{
							playAnimationKey(m_metagame,characterId,"warcry_big_unit",false);
							string c = 
								"<command class='create_instance'" +
								" faction_id='"+ character.getIntAttribute("faction_id") +"'" +
								" instance_class='grenade'" +
								" instance_key= 'roarer_main2.projectile'" +
								" position='" + pos.toString() + "'"+
								" character_id='" + characterId + "' />";
							m_metagame.getComms().send(c);
							break;
						}
						default:
							break;					
					}
				}
				break;			
			}
			
			case 21: {// 刘氏步枪协同攻击
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					string c_pos = character.getStringAttribute("position");
					if (player !is null){
						if (player.hasAttribute("aim_target")) {
							int fId = player.getIntAttribute("faction_id");
							string target_pos = player.getStringAttribute("aim_target");
							array<const XmlElement@> affectedCharacter = getCharactersNearPosition(m_metagame,stringToVector3(c_pos),fId,20.0f);
							for (uint i=0;i<affectedCharacter.length();i++){
								int RF_cId = affectedCharacter[i].getIntAttribute("id");
								const XmlElement@ RFcharacter = getCharacterInfo(m_metagame, RF_cId);
								if (RFcharacter !is null){
									if(RFcharacter.getStringAttribute("soldier_group_name")=="316_liu_rf"){
										string start_pos = RFcharacter.getStringAttribute("position");
										CreateDirectProjectile(m_metagame,stringToVector3(start_pos).add(Vector3(0,1,0)),stringToVector3(target_pos),"liu.projectile",characterId,fId,220.0);  
									}
								}
							}
						}
					}
				}
				break;			
			}

			case 22: {// KCCO狙击手脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartbullet = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					_log("Kcco Sniper Scan successful");
					for(uint i=0;i<m_fnum;i++) 
						if(i!=factionid) {
							array<const XmlElement@> affectedCharacter2;
							affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartbullet,i,24.0f);
							if (affectedCharacter2 !is null){
								for(uint x=0;x<affectedCharacter2.length();x++){
									affectedCharacter.insertLast(affectedCharacter2[x]);
								}
							}
						}
					//根据区域内敌人数量执行不同的脚本弹头：
					//0~5：精准狙击
					//6~15：精准炮击
					//15~25：中等范围迫击炮打击
					//25以上：call大伊万
					uint num_jud = affectedCharacter.length();
					Vector3 sniperPos = stringToVector3(character.getStringAttribute("position"));
					sniperPos = sniperPos.add(Vector3(0,0.1,0));
					if (num_jud>0){
						if (num_jud<=5) {
							_log("Mode 1");
							uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
							uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
							const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
							Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));

							CreateProjectile(m_metagame,sniperPos,luckyGuyPos,"kcco_smartbullet_1.projectile",characterId,factionid,240,0.01);
							break;
						}			
						else if (num_jud<=15) {
							_log("Mode 2");
							CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_2.projectile",characterId,factionid,240,0.01);
							break;						
						}			
						else if (num_jud<=25) {
							_log("Mode 3");
							CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_3.projectile",characterId,factionid,240,0.01);
							break;						
						}			
						else  {
							_log("Mode 4");
							CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_4.projectile",characterId,factionid,240,0.01);
							break;						
						}	
					}		
					_log("Mode 0");			
				}			
				break;
			}

            default:
                break;
		}
	}


	void update(float time) {
		if(XM8track.length()>0){
			for (uint a=0;a<XM8track.length();a++){
				XM8track[a].m_time-=time;
				if(XM8track[a].m_time<0){
					m_fnum= m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					affectedCharacter = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,1,8.0f);
					if (m_fnum==3){
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,2,8.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
					if (m_fnum==4){
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,2,8.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
						array<const XmlElement@> affectedCharacter3;
						affectedCharacter3 = getCharactersNearPosition(m_metagame,XM8track[a].m_pos,3,8.0f);
						if (affectedCharacter3 !is null){
							for(uint x=0;x<affectedCharacter3.length();x++){
								affectedCharacter.insertLast(affectedCharacter3[x]);
							}
						}
					}
					if (affectedCharacter.length()>0){
						int enemynum= affectedCharacter.length()-1;
						int luckyone;
						if (enemynum<=0) {
							luckyone=0;
						}
						else{
							luckyone = rand(0,enemynum);
						}
						int luckyoneid = affectedCharacter[luckyone].getIntAttribute("id");
						const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
						if (luckyoneC !is null && luckyoneid!= -1){
							string luckyonepos = luckyoneC.getStringAttribute("position");
							Vector3 luckyoneposV = stringToVector3(luckyonepos);
							Vector3 height = Vector3(0,0.5,0);
							luckyoneposV = luckyoneposV.add(height);
							luckyonepos = luckyoneposV.toString();
							string c = 
								"<command class='create_instance'" +
								" faction_id='"+ XM8track[a].m_factionid +"'" +
								" instance_class='grenade'" +
								" instance_key='skill_xm8mod3.projectile'" +
								" position='" + luckyonepos + "'"+
								" character_id='" + XM8track[a].m_characterId + "' />";
							m_metagame.getComms().send(c);		
						}
					}
					XM8track[a].m_numtime--;
					XM8track[a].m_time=1;
					if (XM8track[a].m_numtime<0){
						XM8track.removeAt(a);
					}
				}
			}
		}
		if(HK416_track.length()>0){
			for (uint a=0;a<HK416_track.length();a++){
				HK416_track[a].m_time-=time;
				if(HK416_track[a].m_time<0){	
					if (HK416_track[a].m_affected.length()>0){
						for(uint b=0;b<HK416_track[a].m_affected.length();b++){
							int luckyoneid = HK416_track[a].m_affected[b].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC.getIntAttribute("id")!=-1){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								Vector3 height = Vector3(0,0.5,0);
								luckyoneposV = luckyoneposV.add(height);
								luckyonepos = luckyoneposV.toString();
								string c = 
									"<command class='create_instance'" +
									" faction_id='"+ HK416_track[a].m_factionid +"'" +
									" instance_class='grenade'" +
									" instance_key='firenade_sub_416.projectile'" +
									" position='" + luckyonepos + "'"+
									" character_id='" + HK416_track[a].m_characterId + "' />";
								m_metagame.getComms().send(c);
							}
						}
					}
					HK416_track[a].m_numtime--;
					HK416_track[a].m_time=0.33;
					if (HK416_track[a].m_numtime<0){
						HK416_track.removeAt(a);
					}
				}			
			}
		}
		if(Vector_track.length()>0){
			for (uint a=0;a<Vector_track.length();a++){
				Vector_track[a].m_time-=time;
				if(Vector_track[a].m_time<0){
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ Vector_track[a].m_factionid +"'" +
						" instance_class='grenade'" +
						" instance_key='firenade_Vector_sub.projectile'" +
						" position='" + Vector_track[a].m_pos.toString() + "'"+
						" character_id='" + Vector_track[a].m_characterId + "' />";
					m_metagame.getComms().send(c);		
					Vector_track[a].m_numtime--;
					Vector_track[a].m_time=1;
					if (Vector_track[a].m_numtime<1){
						Vector_track.removeAt(a);
					}
				}
			}
		}
		if(Javelin_list.length()>0){
			for (uint a=0;a<Javelin_list.length();a++){
				Javelin_list[a].m_time-=time;
				if(Javelin_list[a].m_time<0){				
					Javelin_list[a].m_numtime--;
					Javelin_list[a].m_time=1;
					if (Javelin_list[a].m_numtime<1){
						Javelin_list.removeAt(a);
					}
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

class XM8tracker{
    int m_characterId;
	float m_time;
	int m_numtime=7;
	int m_factionid;
	Vector3 m_pos;
	XM8tracker(int characterId,float time,int factionid,Vector3 pos)
	{
		m_characterId = characterId;
		m_time = time;
		m_factionid= factionid;
		m_pos=pos;
	}
}

class HK416_tracker{
    int m_characterId;
	float m_time=0.25;
	int m_numtime=16;
	int m_factionid;
	array<const XmlElement@> m_affected;
	Vector3 m_pos;
	HK416_tracker(int characterId,int factionid,Vector3 pos,array<const XmlElement@> affected)
	{
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
		m_affected= affected;
	}
}

class Vector_tracker{
    int m_characterId;
	int m_numtime=4;
	float m_time=0;
	int m_factionid;
	Vector3 m_pos;
	Vector_tracker(int characterId,int factionid,Vector3 pos){
		m_characterId = characterId;
		m_factionid= factionid;
		m_pos= pos;
	}
}

class Javelin_lister{
    int m_characterId;
	float m_time=6;
	int m_numtime=1;
	int m_factionid;
	int m_vehicleid;
	Vector3 m_pos;
	Javelin_lister(int characterId,int factionid,int vehicleid,Vector3 pos)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_vehicleid = vehicleid;
		m_pos = pos;
	}
}
