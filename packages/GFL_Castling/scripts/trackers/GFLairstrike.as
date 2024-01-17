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

        // 炮击妖精 105mm航弹
        {"bomb_105",14},

        // 炮击妖精 155mm航弹
        {"bomb_155",15},

        {"zasm21",16},

        {"30mm_strafe",17},

        // 地雷妖精
        {"mine_strafe",18},        

        {"30mm_strafe_missle",19},

        {"ju87_assault",20},

        // 梦想家激光射线
        {"ioncannon_strafe_dreamer",21},

        // 82mm迫击炮打击

        {"mortar_82mm",100},
        {"mortar_82mm_x4",101},
        {"mortar_82mm_x2",103},

        // 精准空袭
        {"precision_airstrike",102},

        // 航弹
        {"bomber_drop_lv0",104},

        {"airstrike_cas_23mm",105},
        {"airstrike_cas_bomb",106},

        {"rocket_s8ko",107},

        {"cannon_155mm_airburst",108},
        {"cannon_170mm",109},

        {"warrior_yakb_12.7mm",110},
        {"warrior_2a42_30mm",111},
        {"warrior_9M114",112},
        {"warrior_9M127",113},
        {"warrior_S13_rocket",114},
        {"warrior_vtol_strafe",115},
        {"warrior_vtol_bomb",116},

        {"rocket_missile",117},
        {"rocket_bm30_2round",118},
        {"rocket_bm21_24round",119},


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
        if(Airstrike_strafe.length()<=0)return;
        for (uint a=0;a<Airstrike_strafe.length();a++){
            //如果超过单帧空袭个数上限，立刻结束，在下一次update的时候再循环
            if(airstrike_per_frame>=max_airstrike_per_frame)break;
            airstrike_per_frame+=1;

            int cid = Airstrike_strafe[a].m_characterId;
            int fid = Airstrike_strafe[a].m_factionid;
            Vector3 start_pos = Airstrike_strafe[a].m_c_pos;
            Vector3 end_pos = Airstrike_strafe[a].m_s_pos;        
            int specialnum = Airstrike_strafe[a].m_specialnum;
            string specialkey = Airstrike_strafe[a].m_specialkey;

            switch(Airstrike_strafe[a].m_straferkey){
                case 0:{//A10 单次 锁人扫射
                    // _log("A10 strafe activated");

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
                                            
                    for(int i=0;i<=strike_time;i++){
                        //水平偏移
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        //垂直偏移，先快后慢
                        startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                        //每单轮扫射生成6次对点扫射
                        for(int j=1;j<=6;j++)
                        {
                            float rand_x = rand(-strike_rand,strike_rand);
                            float rand_y = rand(-strike_rand,strike_rand);
                            
                            CreateDirectProjectile(m_metagame,startPos,endPos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,150);           
                        } 
                    }                               
                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 1:{//离子炮 单次 锁人扫射
                    //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                    Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                    float strike_didis = 1.0;
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
                    // _log("A10 strafe activated");

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
                        
                        CreateDirectProjectile(m_metagame,startPos,start_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_rocket.projectile",cid,fid,80);                              
                    }                            
                    
                    startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(-30,0,-30)));
                    playSoundAtLocation(m_metagame,"a10_fire_FromWARTHUNDER.wav",fid,end_pos,2.2);
                                            
                    for(int i=0;i<=strike_time;i++){
                        //水平偏移
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        //垂直偏移，先快后慢
                        startPos = startPos.add(Vector3(0,-20*(sqrt(float(1/strike_time)*i)),0));
                        for(int j=1;j<=6;j++)
                        {
                            float rand_x = rand(-strike_rand,strike_rand);
                            float rand_y = rand(-strike_rand,strike_rand);
                            
                            CreateDirectProjectile(m_metagame,startPos,endPos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,150);           
                        } 
                    }                               
                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 4:{
                    CreateDirectProjectile(m_metagame,start_pos.add(Vector3(0,60,0)),end_pos,"m200_snipe.projectile",cid,fid,400);
                    playSoundAtLocation(m_metagame,"m200_fire_snipe.wav",fid,end_pos,2.0);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 5:{                        
                    float strike_rand=5.0;
                    playSoundAtLocation(m_metagame,"ntw20_fire_FromBF2042.wav",fid,end_pos,5.0);
                    for(int j=1;j<=4;j++)
                    {
                        float rand_angle = rand(-3.14,3.14);
                        float rand_dis = rand(-strike_rand,strike_rand);
                        float rand_x = rand_dis*cos(rand_angle);
                        float rand_y = rand_dis*sin(rand_angle);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"ASW_AC130_NTW.projectile",cid,fid,150);
                    }
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 6:{//AC130 单次 锁人扫射

                    float rand_angle = rand(-3.14,3.14);
                    float rand_x1 = 2*cos(rand_angle);
                    float rand_y1 = 2*sin(rand_angle);

                    //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                    float strike_didis = 2;
                    //最终弹头随机程度
                    float strike_rand = 2.0;
                    int projectile_num = rand(4,8);

                    for(int j=1;j<=projectile_num;j++)
                    {
                        rand_x1 = rand(-strike_rand,strike_rand);
                        rand_y1 = rand(-strike_rand,strike_rand);
                        
                        CreateDirectProjectile(m_metagame,start_pos.add(Vector3(rand_x1,0,rand_y1)),end_pos.add(Vector3(rand_x1,0,rand_y1)),"fairy_rampage_25mm.projectile",cid,fid,85);           
                    } 

                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 7:{
                    float strike_rand=5.0;
                    for(int j=1;j<=3;j++)
                    {
                        float rand_angle = rand(-3.14,3.14);
                        float rand_dis = rand(-strike_rand,strike_rand);
                        float rand_x = rand_dis*cos(rand_angle);
                        float rand_y = rand_dis*sin(rand_angle);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_rampage_120mm_rocket.projectile",cid,fid,100);
                        playSoundAtLocation(m_metagame,"rocket_fire_FromSAM4.wav",fid,end_pos);
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
                        float rand_dis = rand(-strike_rand,strike_rand);
                        float rand_angle = rand(-3.14,3.14);
                        float rand_x1 = rand_dis*cos(rand_angle);
                        float rand_y1 = rand_dis*sin(rand_angle);                            
                        
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x1,0,rand_y1)),"bullet_fairy.projectile",cid,fid,100);           
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
                    float strike_rand = 1.5;
                                            
                    //每单轮扫射3发
                    for(int j=1;j<=3;j++)
                    {
                        float rand_dis = rand(-strike_rand,strike_rand);
                        float rand_angle = rand(-3.14,3.14);
                        float rand_x1 = rand_dis*cos(rand_angle);
                        float rand_y1 = rand_dis*sin(rand_angle);                            
                        
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x1,0,rand_y1)),"ASW_heli_strafe.projectile",cid,fid,90);           
                    } 
                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 12:{//勇士妖精 标枪导弹
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"javelin_rocket_3.projectile",cid,fid,200);	
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 13:{//火箭妖精 单次 航弹覆盖
                    //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                    sendFactionMessageKey(m_metagame,fid,"rocketfight");
                    Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                    float strike_didis = 8;
                    //与扫射方向相垂直的向量 与 扫射方向垂直方向偏移距离
                    Vector3 v1 = getVerticalUnitVector(strike_vector);
                    float strike_dy = 6;
                    //扫射起点 从弹头终点指向弹头起点的位置 
                    //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                    Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-60,0,-60)));  
                    pos_offset = pos_offset.add(Vector3(0,80,0));                        
                    //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                    Vector3 c_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(-36,0,-36)));
                    Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(36,0,36)));
                    //依据扫射位置偏移单位距离而设置的扫射次数
                    int strike_time = 6;
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
                            float strike_rand = 4;
                            float rand_dis = rand(-strike_rand,strike_rand);
                            float rand_angle = rand(-3.14,3.14);
                            float rand_x1 = rand_dis*cos(rand_angle);
                            float rand_y1 = rand_dis*sin(rand_angle);     
                            //每单轮扫射生成1次对点扫射
                            CreateDirectProjectile(m_metagame,fin_pos1,fin_pos2.add(Vector3(rand_x1,0,rand_y1)),"artillery_airstrike_fairies.projectile",cid,fid,80);           
                        }
                    }                               
                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 14:{//炮击105
                    string c = 
                        "<command class='create_instance'" +
                        " faction_id='" + fid + "'" +
                        " instance_class='grenade'" +
                        " instance_key='" + "artillery_bomb.projectile" + "'" +
                        " position='" + start_pos.toString() + "'" +
                        " character_id='" + cid + "' />";
                    m_metagame.getComms().send(c);     
                    playSoundAtLocation(m_metagame,"woosh1.wav",fid,start_pos,1.0);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 15:{//炮击105 高爆
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"artillery_shell_fairies_105_he.projectile",cid,fid,15);	
                    playSoundAtLocation(m_metagame,"mortar_whistle_105mm_fromCTA.wav",fid,start_pos,1.35);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 16:{                        
                    float strike_rand=2.0;
                    playSoundAtLocation(m_metagame,"ks23skill_fire_FromBORDERLAND3.wav",fid,end_pos,1.5);
                    for(int j=1;j<=specialnum;j++)
                    {
                        float rand_angle = rand(-3.14,3.14);
                        float rand_dis = rand(-strike_rand,strike_rand);
                        float rand_x = rand_dis*cos(rand_angle);
                        float rand_y = rand_dis*sin(rand_angle);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"grenade_zasm21_sub.projectile",cid,fid,170);
                    }
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }
                case 17:{
                    float strike_rand=4.0;
                    int projectile_num = rand(4,8);
                    for(int j=1;j<=projectile_num;j++)
                    {
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,100);
                    } 
                    Airstrike_strafe.removeAt(a);
                    break;
                }   
                case 18:{//地雷妖精 
                    //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                    sendFactionMessageKey(m_metagame,fid,"minedrop");
                    Vector3 strike_vector = getVerticalUnitVector(getAimUnitVector(1,start_pos,end_pos)); 
                    float strike_didis = 5;
                    //与扫射方向相垂直的向量 与 扫射方向垂直方向偏移距离
                    Vector3 v1 = getVerticalUnitVector(strike_vector);
                    float strike_dy = strike_didis/2;
                    //扫射起点 从弹头终点指向弹头起点的位置 
                    //扫射起点 从弹头终点指向弹头起点的位置基础偏移 
                    Vector3 pos_offset = strike_vector.add(getMultiplicationVector(strike_vector,Vector3(-20,0,-20)));  
                    pos_offset = pos_offset.add(Vector3(0,60,0));                        
                    //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                    Vector3 c_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(-12,0,-12)));
                    Vector3 s_pos = end_pos.add(getMultiplicationVector(strike_vector,Vector3(7,0,7)));
                    //依据扫射位置偏移单位距离而设置的扫射次数
                    int strike_time = int(getAimUnitDistance(1,c_pos,s_pos)/strike_didis);
                    //弹头起始扫射位置与终止扫射位置
                    Vector3 startPos = c_pos.add(pos_offset);
                    Vector3 endPos = c_pos;

                    array<int> MineOffsetList={0,-1,1,2,-2};

                    for(int i=0;i<=strike_time;i++){
                        //水平平移
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        for(int j=0;j<5;j++){
                            Vector3 fin_pos1 = startPos.add(getMultiplicationVector(v1,Vector3(MineOffsetList[j]*strike_dy,0,MineOffsetList[j]*strike_dy)));
                            Vector3 fin_pos2 = endPos.add(getMultiplicationVector(v1,Vector3(MineOffsetList[j]*strike_dy,0,MineOffsetList[j]*strike_dy)));
                            if(j==1 || j==2){
                                fin_pos1 = fin_pos1.add(getMultiplicationVector(strike_vector,Vector3(strike_dy,0,strike_dy)));
                                fin_pos2 = fin_pos2.add(getMultiplicationVector(strike_vector,Vector3(strike_dy,0,strike_dy)));                                
                            }
                            //随机落点
                            float strike_rand = 1;
                            float rand_dis = rand(-strike_rand,strike_rand);
                            float rand_angle = rand(-3.14,3.14);
                            float rand_x1 = rand_dis*cos(rand_angle);
                            float rand_y1 = rand_dis*sin(rand_angle);     
                            //每单轮扫射生成1次对点扫射
                            if(j==1 || j==2){CreateDirectProjectile(m_metagame,fin_pos1,fin_pos2.add(Vector3(rand_x1,0,rand_y1)),"at_mine.projectile",cid,fid,80);}
                            else if(i!=0){CreateDirectProjectile(m_metagame,fin_pos1,fin_pos2.add(Vector3(rand_x1,0,rand_y1)),"claymore.projectile",cid,fid,80);}
                        }
                    }                               
                    Airstrike_strafe.removeAt(a);
                    break;
                }
                case 20:{
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"ju87.projectile",cid,fid,30);
                    Airstrike_strafe.removeAt(a);
                    break;
                }                   
                case 21:{//梦想家离子炮 单次 锁人扫射
                    //扫射位置偏移单位向量 与 扫射位置偏移单位距离
                    Vector3 strike_vector = getAimUnitVector(1,start_pos,end_pos); 
                    float strike_didis = 0.5;
                    //扫射起点 从弹头终点指向弹头起点的位置 
                    Vector3 pos_offset = Vector3(0,60,0);
                    //扫射终点的起点与终点（就生成弹头的终点的起始位置与终止位置）
                    Vector3 c_pos = start_pos;
                    Vector3 s_pos = end_pos;
                    //依据扫射位置偏移单位距离而设置的扫射次数
                    int strike_time = 10;
                    //弹头起始扫射位置与终止扫射位置
                    Vector3 startPos = c_pos.add(pos_offset);
                    Vector3 endPos = c_pos;

                    for(int i=0;i<=strike_time;i++){
                        //水平偏移
                        startPos = startPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        endPos = endPos.add(getMultiplicationVector(strike_vector,Vector3(strike_didis,0,strike_didis)));
                        //每单轮扫射生成1次对点扫射
                        CreateDirectProjectile(m_metagame,startPos,endPos,"skill_sf_boss_dreamer_ioncannon.projectile",cid,fid,280);           
                    }                               
                    Airstrike_strafe.removeAt(a);
                    break;
                }

                case 100:{ //82mm迫击炮打击
                    float strike_rand = 3;
                    float rand_x = rand(-strike_rand,strike_rand);
                    float rand_y = rand(-strike_rand,strike_rand);
                    float rand_z = rand(-7,7);
                    CreateDirectProjectile(m_metagame,start_pos.add(Vector3(rand_x,rand_z,rand_y)),end_pos.add(Vector3(rand_x,0,rand_y)),"artillery_shell_82.projectile",cid,fid,15);
                    array<string> Voice={
                        "mortar_whistle_82mm_0_fromCTA.wav",
                        "mortar_whistle_82mm_1_fromCTA.wav",
                        "mortar_whistle_82mm_2_fromCTA.wav"                            
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 101:{ //82mm迫击炮打击x4
                    float strike_rand = 7;
                    for(int j=1;j<=4;j++)
                    {
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        float rand_z = rand(-8,8);
                        CreateDirectProjectile(m_metagame,start_pos.add(Vector3(rand_x,rand_z,rand_y)),end_pos.add(Vector3(rand_x,0,rand_y)),"artillery_shell_82.projectile",cid,fid,15);
                    }
                    array<string> Voice={
                        "mortar_whistle_82mm_0_fromCTA.wav",
                        "mortar_whistle_82mm_1_fromCTA.wav",
                        "mortar_whistle_82mm_2_fromCTA.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 102:{ //精准空袭
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"artillery_shell_airstrike_precise.projectile",cid,fid,40);
                    array<string> Voice={
                        "mortar_whistle_105mm_fromCTA.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 103:{ //82mm迫击炮打击x2
                    float strike_rand = 5;
                    for(int j=1;j<=2;j++)
                    {
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        float rand_z = rand(-8,8);
                        CreateDirectProjectile(m_metagame,start_pos.add(Vector3(rand_x,rand_z,rand_y)),end_pos.add(Vector3(rand_x,0,rand_y)),"artillery_shell_82.projectile",cid,fid,15);
                    }
                    array<string> Voice={
                        "mortar_whistle_82mm_0_fromCTA.wav",
                        "mortar_whistle_82mm_1_fromCTA.wav",
                        "mortar_whistle_82mm_2_fromCTA.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 104:{ //单发航弹
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"artillery_shell_airstrike_bomber.projectile",cid,fid,40);
                    // array<string> Voice={
                    //     "mortar_whistle_105mm_fromCTA.wav"
                    // };
                    // playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 105:{ // cas 23mm
                    float strike_rand=2.0;
                    for(int j=1;j<=6;j++)
                    {
                        float rand_speed = rand(130,160);
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"ASW_A10_strafe.projectile",cid,fid,rand_speed);
                    } 
                    Airstrike_strafe.removeAt(a);
                    break;
                } 

                case 106:{ // cas bomb
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"artillery_shell_airstrike_cas_bomb.projectile",cid,fid,40);
                    array<string> Voice={
                        "mortar_whistle_105mm_fromCTA.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 107:{ // rocket rush
                    //最终弹头随机程度
                    float strike_rand = 3.0;
                                            
                    //每单轮扫射5发
                    for(int j=1;j<=5;j++)
                    {
                        float rand_speed = rand(140,160);
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);                     
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_rocket_s8ko.projectile",cid,fid,rand_speed);           
                    } 
                    array<string> Voice={
                        "rocket_s13_5round.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,4.0);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 108:{ //155mm空爆打击
                    CreateDirectProjectile_TG(m_metagame,start_pos,end_pos.add(Vector3(0,10,0)),"artillery_shell_fairies_155_airburst.projectile",cid,fid,1.0,30);
                    array<string> Voice={
                        "mortar_whistle_105mm_fromCTA.wav"                      
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.3);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 109:{//170
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"artillery_shell_fairies_170.projectile",cid,fid,15);	
                    playSoundAtLocation(m_metagame,"mortar_whistle_105mm_fromCTA.wav",fid,start_pos,1.35);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }

                case 110:{//勇士妖精 侦察直升机 YAK-B 12.7mm扫射
                    //最终弹头随机程度
                    float strike_rand = 2.0;
                                            
                    //每单轮扫射6发
                    for(int j=1;j<=6;j++)
                    {
                        float rand_speed = rand(120,160);
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);                     
                        
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_warrior_recon_heil_yakb.projectile",cid,fid,rand_speed);           
                    } 
                    array<string> Voice={
                        "yakb_shot_fromWarthunder.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,3.2);
                    Airstrike_strafe.removeAt(a);
                    break;
                }

                case 111:{//勇士妖精 武装直升机 2A42 30mm扫射
                    //最终弹头随机程度
                    float strike_rand = 2.0;
                                            
                    //每单轮扫射6发
                    for(int j=1;j<=4;j++)
                    {
                        float rand_speed = rand(70,95);
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);                     
                        
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_warrior_attack_heil_2a42.projectile",cid,fid,rand_speed);           
                    } 
                    array<string> Voice={
                        "2a42_30mm_shot_fromWarthunder.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,3.2);                    
                    Airstrike_strafe.removeAt(a);
                    break;
                }

                case 112:{//勇士妖精 侦察直升机 9M114
                    float strike_rand = 2.0;
                    for(int j=1;j<=2;j++)
                    {
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);                     
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"javelin_rocket_3.projectile",cid,fid,200);	
                    }
                    array<string> Voice={
                        "rocket_9m114_doubletap.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,2.5);                     
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }

                case 113:{//勇士妖精 武装直升机 9M127
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"javelin_rocket_3.projectile",cid,fid,200);	
                    array<string> Voice={
                        "rocket_9m127.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,2.6);                        
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }

                case 114:{//勇士妖精 武装直升机 火箭舱
                    //最终弹头随机程度
                    float strike_rand = 6.0;
                                            
                    //每单轮扫射5发
                    for(int j=1;j<=5;j++)
                    {
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_rocket_s13.projectile",cid,fid,90);           
                    } 
                    array<string> Voice={
                        "rocket_s13_5round.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,3.6);                       
                    Airstrike_strafe.removeAt(a);
                    break;
                }

                case 115:{ //VTOL
                    //最终弹头随机程度
                    float strike_rand = 2.5;
                                            
                    //每单轮扫射5发
                    for(int j=1;j<=8;j++)
                    {
                        float rand_speed = rand(120,160);
                        float rand_x = rand(-strike_rand,strike_rand);
                        float rand_y = rand(-strike_rand,strike_rand);
                        CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"fairy_warrior_vtol_gsh23.projectile",cid,fid,rand_speed);           
                    } 
                    array<string> Voice={
                        "gsh23l_23mm_shot_fromWarthunder.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,2.9);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 116:{ //VTOL Bomb
                    float strike_rand = 3.0;
                    float rand_x = rand(-strike_rand,strike_rand);
                    float rand_y = rand(-strike_rand,strike_rand);                
                    CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"artillery_shell_airstrike_cas_bomb.projectile",cid,fid,40);
                    CreateDirectProjectile(m_metagame,start_pos,end_pos.add(Vector3(rand_x,0,rand_y)),"artillery_shell_airstrike_cas_bomb.projectile",cid,fid,40);
                    array<string> Voice={
                        "shell_whistle_02.wav"
                    };
                    playRandomSoundArray(m_metagame,Voice,fid,end_pos,1.5);
                    Airstrike_strafe.removeAt(a);
                    break;                    
                }

                case 117:{              
                    CreateDirectProjectile(m_metagame,start_pos,end_pos,"fairy_rocket_missile.projectile",cid,fid,125);
                    Airstrike_strafe.removeAt(a);
                    break;                              
                }

                case 118:{//BM30 300mm
                    spawnStaticProjectile(m_metagame,"rocket_fairy_strike_2round.projectile",start_pos,cid,fid);	
                    playSoundAtLocation(m_metagame,"bm21_woosh_byBadGoose.wav",fid,start_pos,1.5);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }

                case 119:{//BM21 122mm
                    spawnStaticProjectile(m_metagame,"rocket_fairy_cover_24round.projectile",start_pos,cid,fid);	
                    playSoundAtLocation(m_metagame,"bm21_woosh_byBadGoose.wav",fid,start_pos,1.5);
                    Airstrike_strafe.removeAt(a);
                    break;                        
                }

                default:
                    break;
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
    string m_specialkey;
    int m_specialnum;
	Airstrike_strafer(int characterId,int factionid,int straferkey,Vector3 c_pos,Vector3 s_pos)
	{
		m_characterId = characterId;
		m_factionid = factionid;
		m_straferkey = straferkey;
		m_c_pos = c_pos;
		m_s_pos = s_pos;
	}

    void setKey(string a)
    {
        m_specialkey = a;
    }
    void setNum(int a)
    {
        m_specialnum = a;
    }    
}

//这下面写空袭插入函数，与上面的脚本技能函数做区别。
void insertLockOnStrafeAirstrike(GameMode@ metagame,string airstrikekey,int characterId,int factionid,Vector3 pos){
    // _log("strafe insert successful");	

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

void insertDetailedStrike(Airstrike_strafer@ a){
    Airstrike_strafe.insertLast(a);
}