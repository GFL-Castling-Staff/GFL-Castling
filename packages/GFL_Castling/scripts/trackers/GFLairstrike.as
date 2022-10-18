#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "GFLskill.as"
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

// 列空袭对应的脚本技能编号。注意字典的值为了配合后面的只能用uint，不可用string，float等    
dictionary airstrikeIndex = {

        // 空武器
        {"",-1},

        // 初版a10模板
        {"a10_strafe",0},

        // 激光射线模板
        {"ioncannon_strafe",1},

        // 暴怒妖精_a10
        {"a10_call_strafe",2},

        // 带火箭弹的a10
        {"a10_rocket_strafe",3},

        // M200狙击
        {"m200_snipe",4},

        // 暴怒妖精_ac130_三联霰弹枪
        {"ac130_shotgun",5},

        // 暴怒妖精_ac130_机枪扫射 
        {"ac130_minigun",6},

        // 暴怒妖精_ac130_四联火箭筒
        {"ac130_m202",7},

        // 狙击
        {"snipe",8},

        // 大口径机枪压制
        {"mg_strafe",9},

        // 勇士妖精_apache_诱饵箭矢
        {"apache_bait",10},

        // 勇士妖精_apache_机枪压制
        {"apache_mg",11},

        // 勇士妖精_apache_标枪导弹
        {"apache_javelin",12},

        // 空袭妖精_TU160_航弹洗地
        {"TU160_bomb_strafe",13},

        // 下面这行是用来占位的，在这之上添加新的即可
        {"666",-1}
};
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
                        _log("A10 strafe activated");

                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        float strike_didis = 5.0;
                        //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                        Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40)));  
                        pos_offset = pos_offset.add(Vector3(0,60,0));
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = start_pos.add(getMultiplicationVector(strike_vector,Vector3(-15,0,-15)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(10,0,10)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;
                        //最终弹头随机程度
                        float strike_rand = 3.0;

                        CreateDirectProjectile(m_metagame,startPos.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40))),s_pos.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",cid,fid,70);                                         
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));

                        array<string> Voice={
                        "a10_fire_FromWARTHUNDER.wav",
                        };
                                                
                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //垂直偏移，先快后慢
                            startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                            //每单轮扫射生成12次对点扫射
                            for(int j=1;j<=6;j++)
                            {
                                float rand_x = rand(-strike_rand,strike_rand);
                                float rand_y = rand(-strike_rand,strike_rand);
                                
                                CreateDirectProjectile(m_metagame,startPos,endPos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,180);           
                            } 
                        }                               
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 1:{//离子炮 单次 锁人扫射
                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        float strike_didis = 0.5;
                        //扫射起点 从弹头终点指向弹头起点的位置 
                        Vector3 pos_offset = Vector3(0,60,0);
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = start_pos.add(getMultiplicationVector(strike_vector,Vector3(-8,0,-8)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(8,0,8)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;

                        array<string> Voice={
                        "a10_fire_FromWARTHUNDER.wav",
                        };   

                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //每单轮扫射生成1次对点扫射
                            CreateDirectProjectile(m_metagame,startPos,endPos,"ASW_IonCannon_strafe.projectile",cid,fid,280);           

                        }                               
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 2:{//A10 三排同时 导弹 锁人扫射
                        _log("A10 call strafe activated");

                        //扫射位置偏移单位向量 与 扫射横向偏移向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        Vector3 offset_vector = getVerticalUnitVector(strike_vector);
                        offset_vector = getMultiplicationVector(offset_vector,Vector3(10,0,10));
                        float strike_didis = 6.0;
                        //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                        Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40)));  
                        pos_offset = pos_offset.add(Vector3(0,30,0));
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = start_pos.add(getMultiplicationVector(strike_vector,Vector3(-20,0,-20)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(20,0,20)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;
                        //最终弹头随机程度
                        float strike_rand = 3.0;

                        Vector3 a10_start_pos = startPos.add(getMultiplicationVector(strike_vector,Vector3(-50,0,-50)));
                        Vector3 a10_end_pos = s_pos.add(Vector3(0,20,0));

                        CreateDirectProjectile(m_metagame,a10_start_pos,a10_end_pos,"a10_warthog_shadow.projectile",cid,fid,70);   
                        CreateDirectProjectile(m_metagame,a10_start_pos.add(getMultiplicationVector(offset_vector,Vector3(1,0,1))),a10_end_pos.add(getMultiplicationVector(offset_vector,Vector3(1,0,1))),"a10_warthog_shadow.projectile",cid,fid,70);   
                        CreateDirectProjectile(m_metagame,a10_start_pos.add(getMultiplicationVector(offset_vector,Vector3(-1,0,-1))),a10_end_pos.add(getMultiplicationVector(offset_vector,Vector3(-1,0,-1))),"a10_warthog_shadow.projectile",cid,fid,70);   
                                                              
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));

                        array<string> Voice={
                        "a10_fire_FromWARTHUNDER.wav",
                        };

                        for(int i1=1;i1<=3;i1++){
                            Vector3 fin_end_pos = end_pos;
                            Vector3 fin_start_pos = startPos;
                            if(i1==2) {
                                fin_end_pos = end_pos.add(getMultiplicationVector(offset_vector,Vector3(1,0,1)));
                                fin_start_pos = fin_start_pos.add(getMultiplicationVector(offset_vector,Vector3(1,0,1)));
                            }
                            else if(i1==3) {
                                fin_end_pos = end_pos.add(getMultiplicationVector(offset_vector,Vector3(-1,0,-1)));
                                fin_start_pos = fin_start_pos.add(getMultiplicationVector(offset_vector,Vector3(-1,0,-1)));
                            }

                            for(int i=1;i<=8;i++){
                                float rand_x = rand(-15,15);
                                float rand_y = rand(-15,15);
                                
                                CreateDirectProjectile(m_metagame,fin_start_pos,fin_end_pos.add(Vector3(rand_x,0,rand_y)),"pierre_rocket.projectile",cid,fid,180);                              
                            }                            
                        }

                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //垂直偏移，先快后慢
                            startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                            //每单轮扫射生成12次对点扫射
                            for(int i1=1;i1<=3;i1++){
                                Vector3 fin_end_pos = endPos;
                                if(i1==2) fin_end_pos = endPos.add(getMultiplicationVector(offset_vector,Vector3(1,0,1)));
                                else if(i1==3) fin_end_pos = endPos.add(getMultiplicationVector(offset_vector,Vector3(-1,0,-1)));
                                for(int j=1;j<=3;j++)
                                {
                                    float rand_x = rand(-strike_rand,strike_rand);
                                    float rand_y = rand(-strike_rand,strike_rand);
                                    
                                    CreateDirectProjectile(m_metagame,startPos,fin_end_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,180);           
                                } 
                            }
                        }                               
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 3:{//A10 单次 带火箭弹 锁人扫射
                        _log("A10 strafe activated");

                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        float strike_didis = 5.0;
                        //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                        Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-40,0,-40)));  
                        pos_offset = pos_offset.add(Vector3(0,30,0));
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = start_pos.add(getMultiplicationVector(strike_vector,Vector3(-15,0,-15)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(10,0,10)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;
                        //最终弹头随机程度
                        float strike_rand = 3.0;

                        CreateDirectProjectile(m_metagame,startPos.add(getMultiplicationVector(strike_vector,Vector3(-50,0,-50))),s_pos.add(Vector3(0,20,0)),"a10_warthog_shadow.projectile",cid,fid,70);                                         
                        for(int i=1;i<=12;i++){
                            float rand_x = rand(-12,12);
                            float rand_y = rand(-12,12);
                            
                            CreateDirectProjectile(m_metagame,startPos,start_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_rocket.projectile",cid,fid,240);                              
                        }                            
                        
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));

                        array<string> Voice={
                        "a10_fire_FromWARTHUNDER.wav",
                        };
                                                
                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //垂直偏移，先快后慢
                            startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                            //每单轮扫射生成12次对点扫射
                            for(int j=1;j<=6;j++)
                            {
                                float rand_x = rand(-strike_rand,strike_rand);
                                float rand_y = rand(-strike_rand,strike_rand);
                                
                                CreateDirectProjectile(m_metagame,startPos,endPos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,180);           
                            } 
                        }                               
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 4:{
                        CreateDirectProjectile(m_metagame,start_pos.add(Vector3(0,60,0)),end_pos,"m200_snipe.projectile",cid,fid,400);
                        playSoundAtLocation(m_metagame,"m200_fire_snipe.wav",fid,end_pos,2.4);
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }
                    case 5:{
                        // _log("ac130 Fairy activated");
                        
                        float strike_rand=6.0;
                        playSoundAtLocation(m_metagame,"ntw20_fire_FromBF2042.wav",fid,end_pos,5.0);
                        for(int j=1;j<=18;j++)
                        {
                            float rand_angle = rand(-3.14,3.14);
                            float rand_dis = rand(-strike_rand,strike_rand);
                            float rand_x = rand_dis*cos(rand_angle);
                            float rand_y = rand_dis*sin(rand_angle);
                            CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"ASW_AC130_NTW.projectile",cid,fid,255);
                        }
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }
                    case 6:{//AC130 单次 锁人扫射
                        // _log("ac130 minigun Fairy activated");

                        float rand_angle = rand(-3.14,3.14);
                        float rand_x1 = 2*cos(rand_angle);
                        float rand_y1 = 2*sin(rand_angle);

                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,end_pos,end_pos.add(Vector3(rand_x1,0,rand_y1))); 
                        float strike_didis = 2;
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(-4,0,-4)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(4,0,4)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //最终弹头随机程度
                        float strike_rand = 2.0;
                                                
                        for(int i=0;i<=strike_time;i++){
                            //水平偏移
                            c_pos = c_pos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            //每单轮扫射生成6次对点扫射
                            for(int j=1;j<=6;j++)
                            {
                                rand_x1 = rand(-strike_rand,strike_rand);
                                rand_y1 = rand(-strike_rand,strike_rand);
                                
                                CreateDirectProjectile(m_metagame,start_pos,c_pos.add(Vector3(rand_x1,0,rand_y1)),"ASW_A10_strafe.projectile",cid,fid,240);           
                            } 
                        }                               
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 7:{
                        // _log("ac130 m202 Fairy activated");
                        float strike_rand=12.0;
                        for(int j=1;j<=12;j++)
                        {
                            float rand_angle = rand(-3.14,3.14);
                            float rand_dis = rand(-strike_rand,strike_rand);
                            float rand_x = rand_dis*cos(rand_angle);
                            float rand_y = rand_dis*sin(rand_angle);
                            CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"88heat.projectile",cid,fid,100);
                            playSoundAtLocation(m_metagame,"thrower_fire_FromSAM4_2.wav",fid,end_pos);
                        }
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }
                    case 8:{
                        // _log("Sniper Fairy activated");
                        CreateDirectProjectile(m_metagame,start_pos.add(Vector3(0,40,0)),end_pos,"fairy_snipe.projectile",cid,fid,240);
                        playSoundAtLocation(m_metagame,"sniperfairy_fire_FromCOD15.wav",fid,end_pos,2.2);
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }
                    case 9:{//鱼鹰 单次 锁人扫射


                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        //Vector3 strike_vector = getAimUnitVector(1,end_pos,end_pos.add(Vector3(rand_x1,0,rand_y1))); 
                        //Vector3 c_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(-4,0,-4)));

                        //最终弹头随机程度
                        float strike_rand = 2;
                                                
                        //每单轮扫射6发
                        for(int j=1;j<=6;j++)
                        {
                            float rand_angle = rand(-3.14,3.14);
                            float rand_x1 = strike_rand*cos(rand_angle);
                            float rand_y1 = strike_rand*sin(rand_angle);                            
                            
                            CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x1,0,rand_y1)),"bullet_fairy.projectile",cid,fid,180);           
                        } 
                        Airstrike_strafe.removeAt(a);
                        break;
                    }
                    case 10:{//勇士妖精 诱饵弹头
                        CreateDirectProjectile(m_metagame,start_pos,end_pos,"warrior_fairy_arrow.projectile",cid,fid,100);
                        playSoundAtLocation(m_metagame,"Archer_fire_FromCOD12.wav",fid,end_pos,2.4);
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }                    
                    case 11:{//勇士妖精 机枪扫射
                        //最终弹头随机程度
                        float strike_rand = 2;
                                                
                        //每单轮扫射12发
                        for(int j=1;j<=12;j++)
                        {
                            float rand_angle = rand(-3.14,3.14);
                            float rand_x1 = strike_rand*cos(rand_angle);
                            float rand_y1 = strike_rand*sin(rand_angle);                            
                            
                            CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x1,0,rand_y1)),"ASW_A10_strafe.projectile",cid,fid,180);           
                        } 
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }                    
                    case 12:{//勇士妖精 标枪导弹
                        CreateDirectProjectile(m_metagame,start_pos,end_pos,"javelin_rocket_3.projectile",cid,fid,200);	
                        Airstrike_strafe.removeAt(a);
                        break;                        
                    }                    
                    case 13:{//空袭妖精 单次 航弹覆盖
                        //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                        Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                        float strike_didis = 8;
                        //与扫射方向相垂直的向量 与 扫射方向垂直方向偏移距离
                        Vector3 v1 = getVerticalUnitVector(strike_vector);
                        float strike_dy = 6;
                        //扫射起点 从弹头终点指向弹头起点的位置 
                        Vector3 pos_offset = Vector3(0,60,0);
                        //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                        Vector3 c_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(-32,0,-32)));
                        Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(64,0,64)));
                        //依据扫射位置偏移单位距离而设置的扫射次数
                        int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                        //弹头起始扫射位置与终止扫射位置
                        Vector3 startPos = c_pos.add(pos_offset);
                        Vector3 endPos = c_pos;

                        array<string> Voice={
                        "a10_fire_FromWARTHUNDER.wav",
                        };   

                        array<int> BombHorizontalOffsetList={0,-1,1,2,-2};

                        for(int i=0;i<=strike_time;i++){
                            //水平平移
                            startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                            for(int j=0;j<5;j++){
                                Vector3 fin_pos1 = startPos.add(getMultiplicationVector(v1,Vector3(BombHorizontalOffsetList[j]*strike_dy,0,BombHorizontalOffsetList[j]*strike_dy)));
                                Vector3 fin_pos2 = endPos.add(getMultiplicationVector(v1,Vector3(BombHorizontalOffsetList[j]*strike_dy,0,BombHorizontalOffsetList[j]*strike_dy)));
                                //随机落点
                                float strike_rand = 2;
                                float rand_angle = rand(-3.14,3.14);
                                float rand_x1 = strike_rand*cos(rand_angle);
                                float rand_y1 = strike_rand*sin(rand_angle);     
                                //每单轮扫射生成1次对点扫射
                                CreateDirectProjectile(m_metagame,fin_pos1,fin_pos2.add(Vector3(rand_x1,0,rand_y1)),"artillery_airstrike_fairies.projectile",cid,fid,100);           
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

//这下面写空袭插入函数，与上面的脚本技能函数做区别。
void insertLockOnStrafeAirstrike(GameMode@ metagame,string airstrikekey,int characterId,int factionid,Vector3 pos){
    _log("strafe insert successful");	

    float rand_angle = rand(-3.14,3.14);
    float rand_x = 2*cos(rand_angle);
    float rand_y = 2*sin(rand_angle);
    Vector3 luckyGuyPos = pos.add(Vector3(rand_x,0,rand_y)); //若周围没有敌人又必须要扫射，则直接默认以任意朝向扫一轮
    rand_angle = rand(-3.14,3.14);
    rand_x = cos(rand_angle);
    rand_y = sin(rand_angle);   
    Vector3 luckyGuyPos2 = luckyGuyPos.add(Vector3(rand_x,0,rand_y));

    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,8.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));                        
    }
    int airstrikeid = int(airstrikeIndex[airstrikekey]);
    switch(airstrikeid){
        case 0:{luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,32.0f);break;}
        case 1:{luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,20.0f);break;}
        case 2:{luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,30.0f);break;}
        case 3:{luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,30.0f);break;}
        default:{luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,10.0f);break;}
    }
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        luckyGuyPos2 = stringToVector3(luckyGuy.getStringAttribute("position"));                        
    }
    Airstrike_strafe.insertLast(Airstrike_strafer(characterId,factionid,airstrikeid,luckyGuyPos,luckyGuyPos2));           
}

void insertA10Airstrike(GameMode@ metagame,int characterId,int factionid,Vector3 pos){
    _log("A10 gun strafe activate successful");	

    float rand_angle = rand(-3.14,3.14);
    float rand_x = cos(rand_angle);
    float rand_y = sin(rand_angle);
    Vector3 luckyGuyPos = pos.add(Vector3(rand_x,0,rand_y)); //若周围没有敌人又必须要扫射，则直接默认以任意朝向扫一轮
    Vector3 luckyGuyPos2 = luckyGuyPos.add(Vector3(rand(-1,1),0,rand(-1,1)));

    int luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,8.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        luckyGuyPos = stringToVector3(luckyGuy.getStringAttribute("position"));                        
    }
    luckyGuyid = getNearbyRandomLuckyGuyId(metagame,factionid,luckyGuyPos,32.0f);
    if(luckyGuyid!=-1){
        const XmlElement@ luckyGuy = getCharacterInfo(metagame, luckyGuyid);
        luckyGuyPos2 = stringToVector3(luckyGuy.getStringAttribute("position"));                        
    }

    Airstrike_strafe.insertLast(Airstrike_strafer(characterId,factionid,0,luckyGuyPos,luckyGuyPos2));           
}

void insertCommonStrike(int characterId,int factionid,int straferkey,Vector3 c_pos,Vector3 s_pos){
    Airstrike_strafe.insertLast(Airstrike_strafer(characterId,factionid,straferkey,c_pos,s_pos));
}

void insertCommonStrike(int characterId,int factionid,string straferkey,Vector3 c_pos,Vector3 s_pos){
    Airstrike_strafe.insertLast(Airstrike_strafer(characterId,factionid,int(airstrikeIndex[straferkey]),c_pos,s_pos));
}