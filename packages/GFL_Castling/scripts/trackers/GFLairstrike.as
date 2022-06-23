#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "task_sequencer.as"
//Author: SAIWA
//编写API的原则：依赖倒置
//高层模块不应该依赖底层模块，两者应该依赖其抽象
//抽象不应该依赖于细节，细节应该依赖于抽象

//某种意义上整个脚本系统应该重构，重构成一下一个接口:
// 1.用户本身的属性：characterid, factionid, weapon_key, cur_pos, aim_pos, kill_count; 
// 2.事件本身的属性：event_key, event_id, time_count; (此事件剩余时间)
// 以往的脚本技能，诸如最开始的技能冷却，到现在的杀敌减冷却，杀敌加范围啥的，按理说都可以用这个接口。

// 不过乌鸦才铲了屎山上面的事后面再说，我这里就尽可能写通用的吧。创建的时候只需要写一个a10，后面还有跟踪轨道炮啥的，鬼知道还有什么需求。
// 抽象下来大概就是 characterid, factionid, cur_pos, aim_pos; event_key, event_id, time_count这几个就行。

// 在tracker里面整理空袭队列，update才射出弹头。
array<Airstrike_strafer@> Airstrike_strafe;

	// --------------------------------------------
class GFLairstrike : Tracker {
	protected GameMode@ m_metagame;
	uint m_fnum;

    // uint max_id_num = 2000;//id上限，到达后从1开始给(反正rwr几乎不可能同时支持2000个角色同时干什么事hhhhh)
    // uint cur_id_num = 1;
    uint jud_id_num = 0;

    uint max_airstrike_per_frame = 10;//每帧同时执行的轰炸个数
    uint airstrike_per_frame = 0;

	// --------------------------------------------
	GFLairstrike(GameMode@ metagame) {
		@m_metagame = @metagame;
	}


	// --------------------------------------------
	// protected void handleAirstrikeEvent(string incomming_strike_key, int characterId, Vector3 aiming_pos) {
	// 	if (incomming_strike_key == "a10_gun_strafe"){
	
    //     }	    
	// }
    // 傻逼玩意

	void update(float time) {
        airstrike_per_frame = 0;
        jud_id_num = 0;
        if(Airstrike_strafe.length()>0){
            for (uint a=0;a<Airstrike_strafe.length();a++){
                //如果超过单帧空袭个数上限，立刻结束，在下一次update的时候再循环
                if(airstrike_per_frame>=max_airstrike_per_frame)break;
                 
                airstrike_per_frame+=1;  
                int cid = Airstrike_strafe[a].m_characterId;
                int fid = Airstrike_strafe[a].m_factionid;
                Vector3 start_pos = Airstrike_strafe[a].m_c_pos;
                Vector3 next_pos = Airstrike_strafe[a].m_s_pos; 
                int jud_num = Airstrike_strafe[a].m_strafercount;

                _log("Strafe activate successful");	

                switch(Airstrike_strafe[a].m_straferkey){
                    case 0:{//A10 单次 锁人扫射
                        if(jud_num>=0){
                            _log("a10 firing");
                            //更新            
                            jud_id_num = Airstrike_strafe[a].m_straferid;          
                            //扫射位置偏移向量
                            Vector3 strike_vector = getAimUnitVector(5,start_pos,next_pos);
                            //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                            Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-4,0,-4)));  
                            pos_offset = pos_offset.add(Vector3(0,40,0));                            
                            //最终弹头随机程度
                            float strike_rand = 3.0;

                            //垂直偏移，-sqrt(x)图像，先快后慢
                            //startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                            //去你妈的懒得写了，麻烦
                            
                            //每单轮扫射生成10次对点扫射
                            for(int j=1;j<=3;j++)
                            {
                                float rand_x = rand(-strike_rand,strike_rand);
                                float rand_y = rand(-strike_rand,strike_rand);                                        
                                CreateDirectProjectile(m_metagame,start_pos.add(pos_offset),next_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,180);           
                            }                   
                            
                            //更新
                            Airstrike_strafe[a].m_c_pos = next_pos;
                            Airstrike_strafe[a].m_s_pos = next_pos.add(strike_vector);
                            Airstrike_strafe[a].m_strafercount -= 1;
                            
                        }
                        else    Airstrike_strafe.removeAt(a);
                        break; 
                    }
                    default:
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

class Airstrike_strafer{
    int m_characterId;
	int m_factionid;
    Vector3 m_c_pos;
    Vector3 m_s_pos;
	int m_straferkey;
    int m_straferid;
    int m_strafercount;
    
    Airstrike_strafer(int characterId,int factionid,Vector3 c_pos,Vector3 s_pos,int straferkey,int straferid,int strafercount)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_c_pos = c_pos;
		m_s_pos = s_pos;
        m_straferkey = straferkey;
		m_straferid = straferid;
		m_strafercount = strafercount;
	}
}



