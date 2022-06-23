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
// 1.用户本身的属性：characterid, factionid, weapon_key, cur_pos, aim_pos, kill_count；
// 2.事件本身的属性：event_key, time_count(此事件已持续时间)
// 以往的脚本技能，诸如最开始的技能冷却，到现在的杀敌减冷却，杀敌加范围啥的，按理说都可以用这个接口。

// 不过乌鸦才铲了屎山上面的事后面再说，我这里就尽可能写通用的吧。创建的时候只需要写一个a10，后面还有跟踪轨道炮啥的，鬼知道还有什么需求。
// 抽象下来大概就是 characterid, factionid, event_key, cur_pos, aim_pos 这几个就行。

// 在tracker里面整理空袭队列，update才射出弹头。
array<Airstrike_strafer@> Airstrike_strafe;

	// --------------------------------------------
class GFLairstrike : Tracker {
	protected GameMode@ m_metagame;
	uint m_fnum;
    uint max_airstrike_per_frame = 10;
    uint airstrike_per_frame = 0;

	// --------------------------------------------
	GFLairstrike(GameMode@ metagame) {
		@m_metagame = @metagame;
	}


	// --------------------------------------------
	protected void handleResultEvent(const XmlElement@ event) {
		//checking if the event was triggered by a rangefinder notify_script
        string EventKeyGet = event.getStringAttribute("key");
		if (EventKeyGet == "a10_gun_strafe"){
            int characterId = event.getIntAttribute("character_id");
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                uint factionid = character.getIntAttribute("faction_id");
                Vector3 pos_a10_gun_strafe = stringToVector3(event.getStringAttribute("position"));

                _log("A10 gun strafe activate successful");	

                float rand_x = cos(float(rand(0,628))/100)-0.5;
                float rand_y = sin(float(rand(0,628))/100)-0.5;
                Vector3 luckyGuyPos = pos_a10_gun_strafe.add(Vector3(rand_x,0,rand_y)); //若周围没有敌人又必须要扫射，则直接默认以任意朝向扫一轮

                int luckyGuyid = getNearbyRandomLuckyGuyId(m_metagame,factionid,pos_a10_gun_strafe,30.0f);
                if(luckyGuyid!=-1){
                    const XmlElement@ luckyGuy = getCharacterInfo(m_metagame, luckyGuyid);
                    luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));                        
                }
                Airstrike_strafe.insertLast(Airstrike_strafer(characterId,factionid,0,pos_a10_gun_strafe,luckyGuyPos));          						
            }		
        }	    
	}

	void update(float time) {
        airstrike_per_frame = 0;
        if(Airstrike_strafe.length()>0){
            for (uint a=0;a<Airstrike_strafe.length();a++){
                //如果超过单帧空袭个数上限，立刻结束，在下一次update的时候再循环
                if(airstrike_per_frame>=max_airstrike_per_frame)break;
                airstrike_per_frame+=1;

                int cid = Airstrike_strafe[a].m_characterId;
                int fid = Airstrike_strafe[a].m_factionid;
                Vector3 start_pos = Airstrike_strafe[a].m_c_pos;
                Vector3 end_pos = Airstrike_strafe[a].m_s_pos;               

                switch(Airstrike_strafe[a].m_straferkey){
                    case 0:{//A10 单次 锁人扫射

                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        float strike_didis = 2.0;
                        //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                        Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-20,0,-20)));  
                        pos_offset = pos_offset.add(Vector3(0,40,0));
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = start_pos.add(getMultiplicationVector(strike_vector,Vector3(-10,0,-10)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(10,0,10)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;
                        //最终弹头随机程度
                        float strike_rand = 3.0;
                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //垂直偏移，先快后慢
                            startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                            //每单轮扫射生成12次对点扫射
                            for(int j=1;j<=12;j++)
                            {
                                float rand_x = strike_rand*float(rand(1,100)/100)-strike_rand/2;
                                float rand_y = strike_rand*float(rand(1,100)/100)-strike_rand/2;
                                
                                CreateDirectProjectile(m_metagame,startPos,endPos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,180);           
                            }
                        }                      
                        Airstrike_strafe.removeAt(a);
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
    int m_straferkey;
    Vector3 m_c_pos;
    Vector3 m_s_pos;
	Airstrike_strafer(int characterId,int factionid,int straferkey,Vector3 c_pos,Vector3 s_pos)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_straferkey = straferkey;
		m_c_pos = c_pos;
		m_s_pos = s_pos;
	}
}



