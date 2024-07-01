#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "task_sequencer.as"
#include "resource_helpers.as"
#include "gfl_skill_info.as"
#include "GFLparameters.as"

//Author: NetherCrow
//Author: SAIWA

class GFLskill : Tracker {
	protected GameMode@ m_metagame;
	uint m_fnum;

	GFLskill(GameMode@ metagame) {
		@m_metagame = @metagame;
	}

    protected array<XM8tracker@> XM8track;
	protected array<HK416_tracker@> HK416_track;
	protected array<UZI_tracker@> UZI_track;
	protected array<Vector_tracker@> Vector_track;
	protected array<Javelin_lister@> Javelin_list;
	protected array<DOT_tracker@> DOT_track;


	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		//checking if the event was triggered by a rangefinder notify_script
		string EventKeyGet = event.getStringAttribute("key");
		switch(int(gameSkillIndex[EventKeyGet]))
        {
            case 0: {break;}

            case 1: {// 生成防空炮
				m_metagame.setAntiAirStatus(true);
				resetFactionCallResources(m_metagame, 0, GKcallList, false, getCallSorting());
				break;
			}

			case 2: {// 摧毁防空炮
				m_metagame.setAntiAirStatus(false);
				resetFactionCallResources(m_metagame, 0, GKcallList, true, getCallSorting());
				break;
			}
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
						string c1 = 
							"<command class='create_instance'" +
							" faction_id='"+ player.getIntAttribute("faction_id") +"'" +
							" instance_class='grenade'" +
							" instance_key='damage_40mm_aamod3.projectile'" +
							" position='" + Pos_40mm.toString() + "'"+
							" character_id='" + characterId + "' />";
						m_metagame.getComms().send(c1);
						CreateProjectile_H(m_metagame,Pos_40mm,Pos_40mm.add(Vector3(0,0,4)),"40mm_spread.projectile",characterId,player.getIntAttribute("faction_id"),45.0,2.0);
						CreateProjectile_H(m_metagame,Pos_40mm,Pos_40mm.add(Vector3(3,0,-3)),"40mm_spread.projectile",characterId,player.getIntAttribute("faction_id"),45.0,2.0);
						CreateProjectile_H(m_metagame,Pos_40mm,Pos_40mm.add(Vector3(-3,0,-3)),"40mm_spread.projectile",characterId,player.getIntAttribute("faction_id"),45.0,2.0);												
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
						grenade_pos = grenade_pos.add(Vector3(0,3,0));
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
					if (characters !is null && characters.length > 0 ){
						for (uint i = 0; i < characters.length; i++) {
							int soldierId = characters[i].getIntAttribute("id");
							XmlElement c ("command");
							c.setStringAttribute("class", "update_inventory");
							c.setIntAttribute("character_id", soldierId); 
							c.setIntAttribute("untransform_count", 20);
							m_metagame.getComms().send(c);
						}
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
							affectedCharacter2 = getCharactersNearPosition(m_metagame,Pos_40mm,i,10.0f);
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
					for(uint i=0;i<m_fnum;i++) {
						if(i==factionid) continue;
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,10.0f);
						if (affectedCharacter2 is null) continue;
						for(uint x=0;x<affectedCharacter2.length();x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}

					if (affectedCharacter.length()>0) {
						uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
						uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
						const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
						if (luckyGuy is null) return;
						Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
						//智能雷对披风的减伤
						string vestkey = getPlayerEquipmentKey(m_metagame,luckyGuyid,4);

						if (
							startsWith(vestkey,'cc_t4') 
							|| startsWith(vestkey,'cc_t5_16lab') 
							|| startsWith(vestkey,'woshieoe')
							|| startsWith(vestkey,'cc_t6') 
							|| startsWith(vestkey,'lcc_t6')
							|| startsWith(vestkey,'exo_x_t4')
							|| startsWith(vestkey,'exo_x_t6')
						){
							CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3_1.projectile",characterId,factionid,120,0.01);
						}
						else
							CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_3.projectile",characterId,factionid,120,0.01);
					}
					else {
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
					else playSoundAtLocation(m_metagame,"javelin_lock_fail.wav",factionid,aimer_pos,1.0);//未锁定载具

					Vector3 pos1 = getAimUnitPosition(aimer_pos,target_pos,1);
					Vector3 pos2 = getAimUnitPosition(aimer_pos,target_pos,8.0);
					pos1 = pos1.add(Vector3(0,0.8,0));				
					pos2 = pos2.add(Vector3(0,8,0));
					CreateProjectile(m_metagame,pos1,pos2,"javelin_rocket_1.projectile",characterId,factionid,5,6);	
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
				if (character is null) return;
				int factionid = character.getIntAttribute("faction_id");
				Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
				Pos_40mm=Pos_40mm.add(Vector3(0,1.5,0));
				spawnStaticProjectile(m_metagame,"skill_stg44_1.projectile",Pos_40mm,characterId,factionid);
				spawnStaticProjectile(m_metagame,"skill_stg44_2.projectile",Pos_40mm,characterId,factionid);
				spawnStaticProjectile(m_metagame,"skill_stg44_3.projectile",Pos_40mm,characterId,factionid);
				break;			
			}

			case 16: {// 刺雷半载
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				int factionid = character.getIntAttribute("faction_id");
				Vector3 Pos_40mm = stringToVector3(character.getStringAttribute("position"));
				string command = "<command class='update_character' id='" + characterId + "' dead='1' />";
				m_metagame.getComms().send(command);
				spawnStaticProjectile(m_metagame,"cl.projectile",Pos_40mm,characterId,factionid);
				spawnStaticProjectile(m_metagame,"cl_1.projectile",Pos_40mm,characterId,factionid);
				break;			
			}

			case 17: {// 白教白憨憨普攻砸地
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				playAnimationKey(m_metagame,characterId,"stabbing_roarer",false);
				Vector3 pos = stringToVector3(event.getStringAttribute("position"));
				TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
				tasker.add(DelayProjectileSet(m_metagame,0.6,characterId,character.getIntAttribute("faction_id"),"roarer_main.projectile",pos));
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
				if (character is null) return;
				int factionid = character.getIntAttribute("faction_id");
				Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
				Pos_40mm=Pos_40mm.add(Vector3(0,2,0));
				spawnStaticProjectile(m_metagame,"damage_40mm_g3.projectile",Pos_40mm,characterId,factionid);
				spawnStaticProjectile(m_metagame,"damage_40mm_g3_stun.projectile",Pos_40mm,characterId,factionid);
				break;
			}
			
			case 20: {// 大僵尸技能
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				Vector3 pos = stringToVector3(character.getStringAttribute("position"));
				int randomeffect = rand(0,1);
				switch(randomeffect){
					case 0:{
						string soldier_name = "infected";
						int factionid = character.getIntAttribute("faction_id");
						array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, factionid);
						if (groups is null) return;
						bool status = false;
						for (uint i = 0; i < groups.size(); ++i) {
							const XmlElement@ group = groups[i];
							if (group is null) continue;
							string name = group.getStringAttribute("name");
							if (name == soldier_name){
								status = true;
								break;
							}
						}
						if (status){
							playAnimationKey(m_metagame,characterId,"warcry, elid boss",false);
							playSoundAtLocation(m_metagame,"bigzombie_summon_fromDOTA2.wav",0,pos,1.0);
							spawnSoldier(m_metagame,10,factionid,pos,soldier_name);
						}
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
									if(RFcharacter.getStringAttribute("soldier_group_name")=="rf_316_liu"){
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
				if (character is null) return;
				if (character.getIntAttribute("dead") == 1) return;
				if (character.getIntAttribute("wounded") == 1) return;
				uint factionid = character.getIntAttribute("faction_id");
				Vector3 pos_smartbullet = stringToVector3(event.getStringAttribute("position"));
				//获取技能影响的敌人数量
				m_fnum = m_metagame.getFactionCount();
				array<const XmlElement@> affectedCharacter;
				for(uint i=0;i<m_fnum;i++)
				{
					if(i!=factionid) {
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartbullet,i,20.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
				} 
				//根据区域内敌人数量执行不同的脚本弹头：
				//0~3：精准狙击
				//4~8：精准炮击
				//9~15：中等范围迫击炮打击
				//15以上：call大伊万
				uint num_jud = affectedCharacter.length();
				Vector3 sniperPos = stringToVector3(character.getStringAttribute("position"));
				sniperPos = sniperPos.add(Vector3(0,0.1,0));
				if (num_jud>0){
					if (num_jud<=3) {
						uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
						uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
						const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
						if(luckyGuy is null) return;
						Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
						const XmlElement@ LiveGuy = getCharacterInfo(m_metagame, characterId);
						if(LiveGuy !is null){
							CreateProjectile(m_metagame,sniperPos,luckyGuyPos,"kcco_smartbullet_AA.projectile",characterId,factionid,240,0.01);
							CreateDirectProjectile_TG(m_metagame,sniperPos.add(Vector3(0,1,0)),luckyGuyPos.add(Vector3(0,2,0)),"kcco_smartbullet_1.projectile",characterId,factionid,0.1*1.3,4);
							break;
						}
					}			
					else if (num_jud<=8) {
						CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_AA_s1.projectile",characterId,factionid,240,0.01);
						CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_2.projectile",characterId,factionid,240,0.01);
						break;						
					}			
					else if (num_jud<=15) {
						CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_AA_s5.projectile",characterId,factionid,240,0.01);
						CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_3.projectile",characterId,factionid,240,0.01);
						break;						
					}			
					else  {
						CreateProjectile(m_metagame,pos_smartbullet,pos_smartbullet,"kcco_smartbullet_4.projectile",characterId,factionid,240,0.01);
						break;						
					}	
				}		
				break;
			}

			case 23: {// 玩家炼金术师脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartbullet = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;

					uint num_jud = 0;
					uint num_max_character = 10; //最多锁定目标数
					uint num_max_kill = 20;	//最多斩击次数，目标数不为0则对剩余目标继续用完斩杀次数

					affectedCharacter.insertLast(character);

					for(uint i=0;i<m_fnum;i++) {
						if(i!=factionid) {
							array<const XmlElement@> affectedCharacter2;
							affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartbullet,i,25.0f);
							if (affectedCharacter2 !is null){
								for(uint x=0;x<affectedCharacter2.length();x++){
									affectedCharacter.insertLast(affectedCharacter2[x]);
									num_jud += 1;
									if(num_jud>num_max_character)break;
								}
							}
						}
					}

					for (uint i0=1;i0<=num_max_kill;){
						for (uint i1=0;i1<affectedCharacter.length();i1++)	{
							i0+=1;
							int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								CreateDirectProjectile(m_metagame,luckyoneposV.add(Vector3(0,1,0)),luckyoneposV,"ff_alchemist_skill_kill.projectile",characterId,factionid,60);	
								playSoundAtLocation(m_metagame,"alchemist_fire_FromHALOINFINTE.wav",factionid,luckyonepos,1.0);								
							}				
						}
					}
				}			
				break;
			}

			case 24:{ //防卫妖精1
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if(player !is null){
						if (player.hasAttribute("aim_target")) {
							Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							float ori4 = getAimOrientation4(c_pos,target);
							Vector3 height = Vector3(0,70,0);
							target = target.add(height);
							int Faction= character.getIntAttribute("faction_id");
							spawnVehicle(m_metagame,1,Faction,target,Orientation(0,1,0,ori4),"cover1.vehicle");	
						}
					}
				}
				break;
			}

			case 25:{ //防卫妖精2
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if(player !is null){
						if (player.hasAttribute("aim_target")) {
							Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							float ori4 = getAimOrientation4(c_pos,target);
							Vector3 height = Vector3(0,70,0);
							target = target.add(height);
							int Faction= character.getIntAttribute("faction_id");
							spawnVehicle(m_metagame,1,Faction,target,Orientation(0,1,0,ori4),"cover2.vehicle");	
						}
					}
				}
				break;
			}	

			// 15:33:08: SCRIPT:  received: TagName=result_event character_id=851 direction=-0.871521 0.020148 -0.489943 key=moth_destroy position=289.461 10.8204 551.587 
			case 26:{ //(已失效)趋光者概率生成残骸
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int Faction = character.getIntAttribute("faction_id");
					Vector3 ruin_dir = stringToVector3(event.getStringAttribute("direction"));
					Vector3 ruin_pos = stringToVector3(event.getStringAttribute("position"));
					float ori4 = getAimOrientation4(ruin_dir);

					float jud = rand(0,2);

					if(jud>1){
						spawnVehicle(m_metagame,1,Faction,ruin_pos.add(Vector3(0,6,0)),Orientation(0,1,0,ori4),"par_moth_ruin.vehicle");
					}			
					else{
						CreateProjectile(m_metagame,ruin_pos.add(Vector3(0,5.4,0)),ruin_pos.add(Vector3(0,5.4,0)),"moth_explode_death.projectile",characterId,Faction,0,1);
						CreateProjectile(m_metagame,ruin_pos.add(Vector3(0,5.4,0)),ruin_pos.add(Vector3(0,5.4,0)),"moth_explode_stun.projectile",characterId,Faction,0,1);
					}	

					break;
				}
			}

			case 27: { //g41智能手雷
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					for(uint i=0;i<m_fnum;i++) 
						if(i!=factionid) {
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,25.0f);
						if (affectedCharacter2 !is null){
							for(uint x=0;x<affectedCharacter2.length();x++){
								affectedCharacter.insertLast(affectedCharacter2[x]);
							}
						}
					}
					if (affectedCharacter.length()>0) {
						uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
						uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
						const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
						Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
						CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"grenade_g41.projectile",characterId,factionid,100,0.01);
					}
					else {
						CreateProjectile(m_metagame,pos_smartgrenade,pos_smartgrenade.add(Vector3(0,-10,0)),"grenade_g41.projectile",characterId,factionid,120,0.01);
					}									
				}			
				break;			
			}			
			
			case 28: {
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
					CreateProjectile(m_metagame,pos_smartgrenade.add(Vector3(0,0.1,0)),pos_smartgrenade,"smoke_grenade.projectile",characterId,factionid,0,26);
                    GFL_event_array.insertLast(GFL_event(characterId,factionid,"ump45mod3_smoke",pos_smartgrenade,1.5));
				}			
				break;			
			}

			case 29: {
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					healRangedCharacters(m_metagame,grenade_pos,factionid,2.5,3);
				}
				break;		
			}

			case 30:{
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if(player !is null){
						if (player.hasAttribute("aim_target")) {
							Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							float ori4 = getAimOrientation4(c_pos,target);
							Vector3 height = Vector3(0,70,0);
							target = target.add(height);
							int Faction= character.getIntAttribute("faction_id");
							spawnVehicle(m_metagame,1,Faction,target,Orientation(0,1,0,ori4),"aek999.vehicle");	
						}
					}
				}
				break;
			}

			case 31:{
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if(player !is null){
						if (player.hasAttribute("aim_target")) {
							Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							float ori4 = getAimOrientation4(c_pos,target);
							Vector3 height = Vector3(0,70,0);
							target = target.add(height);
							int Faction= character.getIntAttribute("faction_id");
							spawnVehicle(m_metagame,1,Faction,target,Orientation(0,1,0,ori4),"wheelchair.vehicle");	
						}
					}
				}
				break;
			}

			case 32: {// 玩家衔尾蛇脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartbullet = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					uint num_jud = 0;
					uint num_max_character = 6; //最多锁定目标数
					uint num_max_kill = 18;	//最多斩击次数，目标数不为0则对剩余目标继续用完斩杀次数

					for(uint i=0;i<m_fnum;i++) {
						if(num_jud>num_max_character)break;
						if(i!=factionid) {
							array<const XmlElement@> affectedCharacter2;
							affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartbullet,i,18.0f);
							if (affectedCharacter2 !is null){
								for(uint x=0;x<affectedCharacter2.length();x++){
									affectedCharacter.insertLast(affectedCharacter2[x]);
									num_jud += 1;
									if(num_jud>num_max_character)break;
								}
							}
						}
					}

					const XmlElement@ now_character = getCharacterInfo(m_metagame, characterId);
					if (now_character !is null) {
						Vector3 c_pos = stringToVector3(now_character.getStringAttribute("position"));
						c_pos = c_pos.add(Vector3(0,1,0));

						for (uint i0=1;i0<=num_max_kill;){
							if(affectedCharacter.length()>0){
								_log("ff_weaver lock successful");								
								for (uint i1=0;i1<affectedCharacter.length();i1++)	{
									int jud1=1;
									int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
									const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
									if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
										i0+=1;	jud1=0;
										string luckyonepos = luckyoneC.getStringAttribute("position");
										Vector3 luckyoneposV = stringToVector3(luckyonepos);
										float rand_x = rand(-1,1);
										float rand_y = rand(-1,1);			
										luckyoneposV = luckyoneposV.add(Vector3(rand_x,16,rand_y));

										float v_offset = getAimUnitDistance(1.0,c_pos,luckyoneposV);
										CreateDirectProjectile(m_metagame,c_pos,luckyoneposV,"ff_weaver_rocket.projectile",characterId,factionid,1.02*v_offset/0.4);	
										playSoundAtLocation(m_metagame,"m202_flash_shot.wav",factionid,c_pos,1.0);
										_log("ff_weaver scan kill successful");
									}
									i0+=jud1;				
								}								
							}

							else{
								i0+=1;
								float rand_x = rand(-4,4);
								float rand_y = rand(-4,4);

								Vector3 pos_smartbullet1 = pos_smartbullet.add(Vector3(rand_x,16,rand_y));
								float v_offset = getAimUnitDistance(1.0,c_pos,pos_smartbullet1);
								CreateDirectProjectile(m_metagame,c_pos,pos_smartbullet1,"ff_weaver_rocket.projectile",characterId,factionid,1.02*v_offset/0.4); 
								playSoundAtLocation(m_metagame,"m202_flash_shot.wav",factionid,c_pos,1.0);                             			
                            }     
						}
					}				
					_log("ff_weaver skill over.");			
				}			
				break;
			}

			case 33: {// UZIMOD3燃烧弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					uint factionid = character.getIntAttribute("faction_id");
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ factionid +"'" +
						" instance_class='grenade'" +
						" instance_key='firenade_Vector_blast.projectile'" +
						" position='" + grenade_pos.toString() + "'"+
						" character_id='" + characterId + "' />";
					m_metagame.getComms().send(c);
					Vector_track.insertLast(Vector_tracker(characterId,factionid,grenade_pos));

					//获取技能影响的敌人数量
					m_fnum= m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					for(uint i=0;i<m_fnum;i++) {
						if(i!=factionid) {
							array<const XmlElement@> affectedCharacter2;
							affectedCharacter2 = getCharactersNearPosition(m_metagame,grenade_pos,i,7.5f);
							if (affectedCharacter2 !is null){
								for(uint x=0;x<affectedCharacter2.length();x++){
									affectedCharacter.insertLast(affectedCharacter2[x]);
								}
							}
						}
					}
					if (affectedCharacter.length()>0){
						UZI_track.insertLast(UZI_tracker(characterId,factionid,grenade_pos,affectedCharacter));
					}					
				}
				break;			
			}

			case 34: {// GSH18
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, grenade_pos, factionid, 4.5f);
					if (characters !is null && characters.length > 0 ){
						for (uint i = 0; i < characters.length; i++) {
							int soldierId = characters[i].getIntAttribute("id");
							XmlElement c ("command");
							c.setStringAttribute("class", "update_inventory");
							c.setIntAttribute("character_id", soldierId); 
							c.setIntAttribute("untransform_count", 3);
							m_metagame.getComms().send(c);
						}
					}
				}
				break;
			}

			case 35: {// LBLL
				array<string> banned_skill_index = {
					"RBLL",
					"Nagant"
				};
				Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
				int lbll_cid = event.getIntAttribute("character_id");
				healCharacter(m_metagame,lbll_cid,2);
				int factionid = 0;
				array<const XmlElement@>@ affectedCharacter = getCharactersNearPosition(m_metagame, grenade_pos, factionid, 2.5f);

				if (affectedCharacter !is null && affectedCharacter.length > 0){
					int closestIndex = -1;
					float closestDistance = -1.0f;                
					for(uint i=0;i<affectedCharacter.length();i++){
						float distance = getPositionDistance(grenade_pos, stringToVector3(affectedCharacter[i].getStringAttribute("position")));
						if (distance < closestDistance || closestDistance < 0.0){
							closestDistance = distance;
							closestIndex = i;
						}
					}
					if (closestIndex >= 0){
						int target_id = affectedCharacter[closestIndex].getIntAttribute("id");
						XmlElement c ("command");
						c.setStringAttribute("class", "update_inventory");
						c.setIntAttribute("character_id", target_id); 
						c.setIntAttribute("untransform_count", 4);
						m_metagame.getComms().send(c);
						int index = findSkillIndex_reserve_array(target_id,banned_skill_index);
						if(index != -1){
							SkillArray[index].m_time-=5.0;
						}
					}					
				}

				break;
			}

			case 36:{
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if(player !is null){
						if (player.hasAttribute("aim_target")) {
							Vector3 c_pos = stringToVector3(character.getStringAttribute("position"));
							Vector3 target = stringToVector3(player.getStringAttribute("aim_target"));
							float ori4 = getAimOrientation4(c_pos,target);
							Vector3 height = Vector3(0,70,0);
							target = target.add(height);
							int Faction= character.getIntAttribute("faction_id");
							spawnVehicle(m_metagame,1,Faction,target,Orientation(0,1,0,ori4),"mortar_truck.vehicle");	
						}
					}
				}
				break;
			}

			case 37:{ 	// 生成一分钟闪电风暴
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				int factionId = character.getIntAttribute("faction_id");
				if (character !is null) {
					int playerId = character.getIntAttribute("player_id");
					const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
					if (player !is null) {
						Vector3 position = stringToVector3(event.getStringAttribute("position"));
                        GFL_event_array.insertLast(GFL_event(characterId,factionId,int(GFL_Event_Index["lightning_storm"]),position,1.0,-1.0));
					}
				}
				break;
			}

			case 38: {// para acid
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					DOT_track.insertLast(DOT_tracker(characterId,factionid,grenade_pos,1.0,"elenusis_acid_bomb_spawn.projectile",10));
				}
				break;			
			}

			case 39: {// hk416 medic aid
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
                    GFL_event_array.insertLast(GFL_event(characterId,factionid,int(GFL_Event_Index["hk416_medicaid"]),grenade_pos));
				}
				break;	
			}

			case 40: {// paradeus heal skill for commando
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					healRangedCharacters(m_metagame,grenade_pos,factionid,15,5,"para_heal",8);
				}
				break;			
			}

			case 41: {// PA15
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				uint factionid = character.getIntAttribute("faction_id");
				Vector3 Pos_40mm = stringToVector3(event.getStringAttribute("position"));
				//获取技能影响的敌人数量
				Pos_40mm = Pos_40mm.add(Vector3(0,0.5,0));
				m_fnum= m_metagame.getFactionCount();
				array<const XmlElement@> affectedCharacter;
				for(uint i=0;i<m_fnum;i++) 
					if(i!=factionid) {
					array<const XmlElement@> affectedCharacter2;
					affectedCharacter2 = getCharactersNearPosition(m_metagame,Pos_40mm,i,10.0f);
					if (affectedCharacter2 !is null){
						for(uint x=0;x<affectedCharacter2.length();x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}
				}
				if (affectedCharacter !is null || affectedCharacter.length() > 0)
				{
					for (uint i0=0;i0<affectedCharacter.length();i0++){
						int luckyoneid = affectedCharacter[i0].getIntAttribute("id");
						const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
						if (luckyoneC is null) continue;
						if ((luckyoneC.getIntAttribute("id")==-1)) continue;
						string luckyonepos = luckyoneC.getStringAttribute("position");
						Vector3 luckyoneposV = stringToVector3(luckyonepos);
						luckyoneposV = luckyoneposV.add(Vector3(0,1.5,0));
						spawnStaticProjectile(m_metagame,"skill_pa15_sub.projectile",luckyoneposV,characterId,factionid);
					}
				}
				spawnStaticProjectile(m_metagame,"skill_pa15_sub_big.projectile",Pos_40mm,characterId,factionid);
				spawnStaticProjectile(m_metagame,"skill_pa15_sub_stun.projectile",Pos_40mm,characterId,factionid);
				break;
			}

			case 42: {// 敌方干扰者技能
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
				if (OutOfRange_2(grenade_pos)) return;
				int factionid = character.getIntAttribute("faction_id");
				spawnVehicle(m_metagame,1,factionid,grenade_pos.add(Vector3(0,10,0)),Orientation(0,1,0,0.1),"sf_boss_intruder_skill.vehicle");
				GFL_event_array.insertLast(GFL_event(characterId,factionid,int(GFL_Event_Index["intruder_spawn"]),grenade_pos));
				break;			
			}

			// case 43: {// 地雷妖精
			// 	int characterId = event.getIntAttribute("character_id");
			// 	const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			// 	if (character is null) break;
			// 	int playerId = character.getIntAttribute("player_id");
			// 	const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
			// 	if (player is null) break;
			// 	if (player.hasAttribute("aim_target")) {
			// 		Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));
			// 		Vector3 aim_pos = stringToVector3(player.getStringAttribute("aim_target"));
			// 		int factionid = character.getIntAttribute("faction_id");
			// 		TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
			// 		tasker.add(DelayCommonCallRequest(m_metagame,3,characterId,factionid,"mine_strafe",aimer_pos,aim_pos));
			// 	}
			// 	break;					
			// }

			case 44: {// 铁血圣盾swap
				int characterId = event.getIntAttribute("character_id");
				healCharacter(m_metagame,characterId,10);
				break;			
			}

			case 45:{
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 m_pos = stringToVector3(event.getStringAttribute("position"));
					int factionId = character.getIntAttribute("faction_id");
					spawnStaticProjectile(m_metagame,"skill_c96_flare_float.projectile",m_pos,characterId,factionId);
					TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
					tasker.add(Ju87_Assault(m_metagame,3.5,characterId,factionId,m_pos.add(Vector3(0,-10,0))));
				}
				break;
			}

			case 46:{ // 敌方刽子手脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					Vector3 target_pos = Vector3(0,0,0);

					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;

					uint num_jud = 0;
					uint num_max_character = 16; //最多锁定目标数

					healCharacter(m_metagame,characterId,10);

					if(m_fnum==0)break;

					affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionid,45.0f,num_max_character);
					int target_num = affectedCharacter.length();
					if(target_num==0)break;

					for (int i1=0;i1<target_num;i1++)	{
						int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
						const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
						if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
							Vector3 luckyonepos = stringToVector3(luckyoneC.getStringAttribute("position"));
							target_pos = target_pos.add(luckyonepos);
						}				
					}

					_log("target_pos = "+target_pos.toString());

					target_pos = getMultiplicationVector(target_pos,1/float(target_num));
					Vector3 c_pos = character_pos;
					Vector3 s_pos = target_pos;
					
					int senderId = event.getIntAttribute("player_id");
					string messade = "c_pos = "+c_pos.toString()+";  s_pos = "+s_pos.toString();
					sendPrivateMessageKey(m_metagame, senderId, messade, dictionary());
					_log(messade);

					c_pos=c_pos.add(Vector3(0,1,0));

					float dx = s_pos.m_values[0]-c_pos.m_values[0];
					float dy = s_pos.m_values[2]-c_pos.m_values[2];
					float ds = sqrt(dx*dx+dy*dy);
					if(ds<=0.000001f) ds=0.000001f;
					dx = dx/ds; dy=dy/ds;
					float dd = 2; //同一列相邻弹头的距离
					float tt = 4;   //同一行相邻弹头位置偏移比值
				
					array<string> Voice={
					"Excutioner_buhuo_SKILL02_JP.wav",
					"Excutioner_buhuo_SKILL03_JP.wav",
					};
					playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
					// playAnimationKey(m_metagame,characterId,"excution_skill",false,false);

					int ix = 5;
					CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*3-dy*dd*3/tt,0,dy*dd*3+dx*dd*3/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));
					CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*4           ,0,dy*dd*4           )),c_pos.add(Vector3(dx*dd*(ix*2)                    ,0,dy*dd*(ix*2)                    )),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));
					CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*3+dy*dd*3/tt,0,dy*dd*3-dx*dd*3/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),"excutioner_skill_1.projectile",characterId,factionid,60,1,Orientation(0,1,3,2.14));

					for(ix=2;ix<=8;ix++)
					{
						CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,1,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)-dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)+dx*dd*(ix*2-1)/tt)),"excutioner_skill.projectile",characterId,factionid,100,0.001);
						CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2)                    ,1,dy*dd*(ix*2)                    )),c_pos.add(Vector3(dx*dd*(ix*2)                    ,0,dy*dd*(ix*2)                    )),"excutioner_skill.projectile",characterId,factionid,100,0.001);
						CreateProjectile(m_metagame,c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,1,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),c_pos.add(Vector3(dx*dd*(ix*2-1)+dy*dd*(ix*2-1)/tt,0,dy*dd*(ix*2-1)-dx*dd*(ix*2-1)/tt)),"excutioner_skill.projectile",characterId,factionid,100,0.001);
					}
				}			
				break;	
			}



			case 47: {// 敌方炼金术师脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量
					array<const XmlElement@> affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionid,25.0f,10);

					uint num_jud = 0;
					uint num_max_character = 10; //最多锁定目标数
					uint num_max_kill = 20;	//最多斩击次数，目标数不为0则对剩余目标继续用完斩杀次数

					healCharacter(m_metagame,characterId,20);
					int m_fnum = 0;
					m_fnum = m_metagame.getFactionCount();
					if(m_fnum==0) break;

					array<string> Voice={
						"Alchemist_buhuo_SKILL01_JP.wav",
						"Alchemist_buhuo_SKILL02_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionid,character_pos.toString(),1);

					for (uint i0=0;i0<=num_max_kill;i0++){
						for (uint i1=0;i1<affectedCharacter.length();i1++)	{
							i0+=1;
							int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC is null) break;
							if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								CreateDirectProjectile(m_metagame,luckyoneposV.add(Vector3(0,1,0)),luckyoneposV,"sfw_boss_alchemist_skill_kill.projectile",characterId,factionid,60);	
								playSoundAtLocation(m_metagame,"alchemist_fire_FromHALOINFINTE.wav",factionid,luckyonepos,1.0);								
							}				
						}
					}
				}			
				break;
			}
			
			case 48: {// 侦察中枢刷人
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				Vector3 pos = stringToVector3(event.getStringAttribute("position"));
				string soldier_name = "kcco_pathfinder";
				int factionid = character.getIntAttribute("faction_id");
				array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, factionid);
				if (groups is null) return;
				bool status = false;
				for (uint i = 0; i < groups.size(); ++i) {
					const XmlElement@ group = groups[i];
					if (group is null) continue;
					string name = group.getStringAttribute("name");
					if (name == soldier_name){
						status = true;
						break;
					}
				}
				if (status){
					spawnSoldier(m_metagame,5,factionid,pos,soldier_name);
				}
				break;			
			}

			case 49: {// 敌方破坏者脚本榴弹
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					Vector3 target_pos = Vector3(0,0,0);

					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;

					uint num_jud = 0;
					uint num_max_character = 16; //最多锁定目标数

					healCharacter(m_metagame,characterId,10);

					if(m_fnum==0)break;

					affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionid,35.0f,num_max_character);
					int target_num = affectedCharacter.length();
					if(target_num==0)break;

					for (int i1=0;i1<target_num;i1++)	{
						int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
						const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
						if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
							Vector3 luckyonepos = stringToVector3(luckyoneC.getStringAttribute("position"));
							target_pos = target_pos.add(luckyonepos);
						}				
					}
					target_pos = getMultiplicationVector(target_pos,1/float(target_num));

					Vector3 c_pos = character_pos;
					Vector3 s_pos = target_pos;
					c_pos=c_pos.add(Vector3(0,25.0,0));
					int ix = 0; float dd = 2.0;
					for(ix=1;ix<=6;ix++) {
						CreateProjectile(m_metagame,c_pos,s_pos.add(Vector3(dd*(ix*2-7),0,0)),"skill_sf_boss_destroyer_mine.projectile",characterId,factionid,100,0.001);
					}           
					for(ix=1;ix<=6;ix++) {
						CreateProjectile(m_metagame,c_pos,s_pos.add(Vector3(0,0,dd*(ix*2-7))),"skill_sf_boss_destroyer_mine.projectile",characterId,factionid,100,0.001);
					}             
					array<string> Voice={
					"Destroyer_buhuo_SKILL02_JP.wav",
					"Destroyer_buhuo_SKILL01_JP.wav",
					"Destroyer_buhuo_MEET_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionid,c_pos.toString(),1);
				}			
				break;
			}

			case 50: {// 敌方梦想家激光扫射
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					int factionid = character.getIntAttribute("faction_id");
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					//获取技能影响的敌人数量

					healCharacter(m_metagame,characterId,10);

					array<const XmlElement@> affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionid,35.0f);
					int target_num = affectedCharacter.length();
					if(target_num==0)break;
					int luckyoneid = affectedCharacter[0].getIntAttribute("id");
					const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
					if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
						Vector3 luckyonepos = stringToVector3(luckyoneC.getStringAttribute("position"));
						Skill_Sf_Boss_Dreamer@ shot = Skill_Sf_Boss_Dreamer(m_metagame,1.5,characterId,factionid,luckyonepos);
						TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
						tasker.add(shot);
					}
				}
				break;
			}

			case 51: {// KCCO智能雷 for player
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				uint factionid = character.getIntAttribute("faction_id");
				Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
				//获取技能影响的敌人数量
				m_fnum = m_metagame.getFactionCount();
				array<const XmlElement@> affectedCharacter;
				for(uint i=0;i<m_fnum;i++) {
					if(i==factionid) continue;
					array<const XmlElement@> affectedCharacter2;
					affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,10.0f);
					if (affectedCharacter2 is null) continue;
					for(uint x=0;x<affectedCharacter2.length();x++){
						affectedCharacter.insertLast(affectedCharacter2[x]);
					}
				}

				if (affectedCharacter.length()>0) {
					uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
					uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
					const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
					if (luckyGuy is null) return;
					Vector3 luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
					CreateProjectile(m_metagame,pos_smartgrenade,luckyGuyPos,"kcco_smartgrenade_player_3.projectile",characterId,factionid,120,0.01);
				}
				else {
					CreateProjectile(m_metagame,pos_smartgrenade,pos_smartgrenade.add(Vector3(0,-10,0)),"kcco_smartgrenade_player_3.projectile",characterId,factionid,120,0.01);
				}									
				break;			
			}

			case 52: {//轨道轰炸
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				int factionId = character.getIntAttribute("faction_id");
				if (character !is null) {
					Vector3 pos = stringToVector3(event.getStringAttribute("position"));
					TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
					tasker.add(GDIIonCannonStrike(m_metagame,2.5,characterId,factionId,pos));
				}
				break;
			}


			case 53: {// paradeus heal skill for nyto aileron
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, grenade_pos, factionid,25);
					uint heal_count_max = 10;
					int nyto_count = 0;
					if (heal_count_max >= characters.length()) {
						heal_count_max = characters.length();
					}
					for (uint i = 0; i < heal_count_max; i++) {
						int luckyhealguyid = characters[i].getIntAttribute("id");
						bool jud = false;
						const XmlElement@ luckyhealguyC = getCharacterInfo(m_metagame, luckyhealguyid);
						Vector3 c_pos = stringToVector3(luckyhealguyC.getStringAttribute("position"));
						int death = luckyhealguyC.getIntAttribute("dead");
						if(death == 1) continue;
						string judname = luckyhealguyC.getStringAttribute("soldier_group_name");
						if(nytoAllList.find(judname) >= 0)
						{
							nyto_count++;
							jud = true;
						}
						if(jud)
						{
							spawnStaticProjectile(m_metagame,"para_nyto_heal_effect_on_target.projectile",c_pos,-1,factionid);
							healCharacter(m_metagame,luckyhealguyid,40);
						}
						else
						{
							spawnStaticProjectile(m_metagame,"para_heal_effect_on_target.projectile",c_pos,-1,factionid);
							healCharacter(m_metagame,luckyhealguyid,5);
						}
					}
					if(nyto_count <= 3)
					{
						Vector3 random_spawn_pos_1 = getRandomOffsetVector(grenade_pos,10.0);
						spawnStaticProjectile(m_metagame,"particle_spawn_smoke.projectile",random_spawn_pos_1,characterId,factionid);
						spawnStaticProjectile(m_metagame,"nyto_spawn_trigger.projectile",random_spawn_pos_1,characterId,factionid);
						Vector3 random_spawn_pos_2 = getRandomOffsetVector(grenade_pos,10.0);
						spawnStaticProjectile(m_metagame,"particle_spawn_smoke.projectile",random_spawn_pos_2,characterId,factionid);
						spawnStaticProjectile(m_metagame,"nyto_spawn_trigger.projectile",random_spawn_pos_2,characterId,factionid);
						//生成延时弹头，走脚本
					}
				}
				break;			
			}

			case 54: {// 召唤随机涅托
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character is null) return;
				Vector3 pos = stringToVector3(event.getStringAttribute("position"));
				int factionid = character.getIntAttribute("faction_id");
				array<const XmlElement@>@ groups = getSoldierGroups(m_metagame, factionid);
				if (groups is null) return;
				string soldier_name = nytoBasicList[rand(0,nytoBasicList.length()-1)];
				bool status = false;
				for (uint i = 0; i < groups.size(); ++i) {
					const XmlElement@ group = groups[i];
					if (group is null) continue;
					string name = group.getStringAttribute("name");
					if (name == soldier_name){
						status = true;
						break;
					}
				}
				if (status){
					spawnSoldier(m_metagame,1,factionid,pos,soldier_name);
				}
				break;
			}

			case 55: {// 猎手 boss 技能 困兽狙击
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				int factionId = character.getIntAttribute("faction_id");
				if (character !is null) {
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					healCharacter(m_metagame,characterId,10);

					array<string> Voice={
						"Hunter_buhuo_SKILL01_JP.wav",
						"Hunter_buhuo_SKILL03_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionId,character_pos.toString(),1);

					array<const XmlElement@> affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionId,25.0f);
					uint num_max_kill = 3;
					if(affectedCharacter.length()==0)break;
					for (uint i0=0;i0<=num_max_kill;i0++){
						for (uint i1=0;i1<affectedCharacter.length();i1++)	{
							i0+=1;
							int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC is null) break;
							if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								CreateProjectile_H(m_metagame,character_pos.add(Vector3(0,2,0)),luckyoneposV,"sf_emp_mine.projectile",characterId,factionId,90,2);
							}
						}
					}

				}
				break;
			}

			case 56: {// 衔尾蛇 boss 技能 热毒坠落
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				int factionId = character.getIntAttribute("faction_id");
				if (character !is null) {
					Vector3 character_pos = stringToVector3(event.getStringAttribute("position"));
					healCharacter(m_metagame,characterId,10);

					array<string> Voice={
						"Hunter_buhuo_SKILL01_JP.wav",
						"Hunter_buhuo_SKILL03_JP.wav"
					};
					playRandomSoundArray(m_metagame,Voice,factionId,character_pos.toString(),1);

					array<const XmlElement@> affectedCharacter = getEnemyCharactersNearPosition(m_metagame,character_pos,factionId,45.0f,8);
					uint num_max_kill = 8;
					if(affectedCharacter.length()==0)break;
					for (uint i0=0;i0<=num_max_kill;i0++){
						for (uint i1=0;i1<affectedCharacter.length();i1++)	{
							i0+=1;
							int luckyoneid = affectedCharacter[i1].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC is null) break;
							if ((luckyoneC.getIntAttribute("id")!=-1)&&(luckyoneid!=characterId)){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								CreateDirectProjectile(m_metagame,luckyoneposV.add(Vector3(0,1,0)),luckyoneposV,"skill_sf_boss_oroborus_warn.projectile",characterId,factionId,1);								
							}				
						}
					}

				}
				break;
			}

			case 57: { //菲德洛夫
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 grenade_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					float ori4 = rand(0.0,3.14);
					spawnStaticProjectile(m_metagame,"medkit_fedorov_spawn1.projectile",grenade_pos,characterId,factionid,Orientation(0,1,0,ori4));
					TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
					AOEVestRecoverTask@ new_quest = AOEVestRecoverTask(m_metagame,3,grenade_pos,5,5,factionid,10);
					new_quest.setEffectParticle("particle_effect_radius_heal.projectile");
					tasker.add(new_quest);
				}				
				break;
			}

			case 58: {// OBR一阶段
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
					spawnStaticProjectile(m_metagame,"skill_obr_knife_damage.projectile",pos_smartgrenade,characterId,factionid);
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					for(uint i=0;i<m_fnum;i++) {
						if(i==factionid) continue;
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,15.0f);
						if (affectedCharacter2 is null) continue;
						for(uint x=0;x<affectedCharacter2.length();x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}

					if (affectedCharacter.length()>0) {
						bool getTarget =false;
						Vector3 luckyGuyPos = pos_smartgrenade;
						while(!getTarget)
						{
							if(affectedCharacter.length() <= 0)
							{
								break;
							}
							uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
							uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
							const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
							if (luckyGuy is null) 
							{
								affectedCharacter.removeAt(luckyGuyindex);
								return;
							}
							if (luckyGuy.getIntAttribute("dead") == 1)
							{
								affectedCharacter.removeAt(luckyGuyindex);
								return;
							}
							luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
							getTarget = true;
						}
						Vector3 offset = Vector3(0,1.8,0);
						CreateDirectProjectile_T(m_metagame,pos_smartgrenade,luckyGuyPos.add(offset),"skill_obr_knife_1.projectile",characterId,factionid,0.2);
					}
					else {
						float strike_rand = 6;
						float rand_x = rand(-strike_rand,strike_rand);
						float rand_y = rand(-strike_rand,strike_rand);							
						CreateDirectProjectile_T(m_metagame,pos_smartgrenade,pos_smartgrenade.add(Vector3(rand_x,-1.8,rand_y)),"skill_obr_knife_1.projectile",characterId,factionid,0.2);
					}									
				}			
				break;			
			}

			case 59: {// OBR二阶段
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					uint factionid = character.getIntAttribute("faction_id");
					Vector3 pos_smartgrenade = stringToVector3(event.getStringAttribute("position"));
					spawnStaticProjectile(m_metagame,"skill_obr_knife_damage.projectile",pos_smartgrenade,characterId,factionid);
					//获取技能影响的敌人数量
					m_fnum = m_metagame.getFactionCount();
					array<const XmlElement@> affectedCharacter;
					for(uint i=0;i<m_fnum;i++) {
						if(i==factionid) continue;
						array<const XmlElement@> affectedCharacter2;
						affectedCharacter2 = getCharactersNearPosition(m_metagame,pos_smartgrenade,i,20.0f);
						if (affectedCharacter2 is null) continue;
						for(uint x=0;x<affectedCharacter2.length();x++){
							affectedCharacter.insertLast(affectedCharacter2[x]);
						}
					}

					if (affectedCharacter.length()>0) {
						bool getTarget =false;
						Vector3 luckyGuyPos = pos_smartgrenade;
						while(!getTarget)
						{
							if(affectedCharacter.length() <= 0)
							{
								break;
							}
							uint luckyGuyindex = rand(0,affectedCharacter.length()-1);
							uint luckyGuyid = affectedCharacter[luckyGuyindex].getIntAttribute("id");
							const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
							if (luckyGuy is null) 
							{
								affectedCharacter.removeAt(luckyGuyindex);
								return;
							}
							if (luckyGuy.getIntAttribute("dead") == 1)
							{
								affectedCharacter.removeAt(luckyGuyindex);
								return;
							}
							luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));
							getTarget = true;
						}
						Vector3 offset = Vector3(0,8.5,0);
						CreateDirectProjectile_T(m_metagame,pos_smartgrenade,luckyGuyPos.add(offset),"skill_obr_knife_2.projectile",characterId,factionid,0.33);
					}
					else {
						float strike_rand = 4;
						float rand_x = rand(-strike_rand,strike_rand);
						float rand_y = rand(-strike_rand,strike_rand);						
						CreateDirectProjectile_T(m_metagame,pos_smartgrenade.add(Vector3(rand_x,8.5,rand_y)),pos_smartgrenade.add(Vector3(0,-10,0)),"skill_obr_knife_2.projectile",characterId,factionid,0.33);
					}									
				}			
				break;			
			}
			
			case 60: { //弹药箱补给
				int characterId = event.getIntAttribute("character_id");
				const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
				if (character !is null) {
					Vector3 c_pos = stringToVector3(event.getStringAttribute("position"));
					int factionid = character.getIntAttribute("faction_id");
					
					array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, c_pos, factionid, 20.0f);
                    if (characters is null) return;
					_log("script activated");
                    SecondarySupplyGroup(m_metagame,characters,0,"asindex");
					_log("secondary script finished");
					GrenadeSupplyGroup(m_metagame,characters,0,"asindex");
					_log("grenade script finished");
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
						if (luckyoneC !is null){
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
							if (luckyoneC !is null ){
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
					HK416_track[a].m_time=0.5;
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
		if(UZI_track.length()>0){
			for (uint a=0;a<UZI_track.length();a++){
				UZI_track[a].m_time-=time;
				if(UZI_track[a].m_time<0){	
					if (UZI_track[a].m_affected.length()>0){
						for(uint b=0;b<UZI_track[a].m_affected.length();b++){
							int luckyoneid = UZI_track[a].m_affected[b].getIntAttribute("id");
							const XmlElement@ luckyoneC = getCharacterInfo(m_metagame, luckyoneid);
							if (luckyoneC !is null ){
								string luckyonepos = luckyoneC.getStringAttribute("position");
								Vector3 luckyoneposV = stringToVector3(luckyonepos);
								Vector3 height = Vector3(0,0.5,0);
								luckyoneposV = luckyoneposV.add(height);
								luckyonepos = luckyoneposV.toString();
								string c = 
									"<command class='create_instance'" +
									" faction_id='"+ UZI_track[a].m_factionid +"'" +
									" instance_class='grenade'" +
									" instance_key='firenade_sub_uzi.projectile'" +
									" position='" + luckyonepos + "'"+
									" character_id='" + UZI_track[a].m_characterId + "' />";
								m_metagame.getComms().send(c);
							}
						}
					}
					UZI_track[a].m_numtime--;
					UZI_track[a].m_time=1.5;
					if (UZI_track[a].m_numtime<0){
						UZI_track.removeAt(a);
					}
				}			
			}
		}			
		if(DOT_track.length()>0){
			for (uint a=0;a<DOT_track.length();a++){
				DOT_track[a].m_time-=time;
				if(DOT_track[a].m_time<0){
					string c = 
						"<command class='create_instance'" +
						" faction_id='"+ DOT_track[a].m_factionid +"'" +
						" instance_class='grenade'" +
						" instance_key='" + DOT_track[a].m_projectile +"'" +
						" position='" + DOT_track[a].m_pos.toString() + "'"+
						" character_id='" + DOT_track[a].m_characterId + "' />";
					m_metagame.getComms().send(c);		
					DOT_track[a].m_numtime--;
					DOT_track[a].m_time=DOT_track[a].m_time_interval;
					if (DOT_track[a].m_numtime<1){
						DOT_track.removeAt(a);
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
