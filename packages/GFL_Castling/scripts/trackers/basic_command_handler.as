// internal
#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "generic_call_task.as"
#include "task_sequencer.as"
#include "GFLhelpers.as"
#include "event_system.as"

// 目前正在播放的点歌机中的歌曲剩余时间

dictionary songIndex = {

	// 命名规则：枪种key+歌曲编号+.wav
	// 歌曲编号直接与sing挂钩（举例：sing1 = 歌曲编号为1）
	// 以sopii为例，命名规则为 ‘gkw_m4sopmodii.weapon’ + ‘1’ + ‘.wav’
	// 当然，相应的你要把你的歌在文件夹里也改成这个名字

    {"gkw_m1895mod3.weapon1.wav",1},//已检测，歌曲：神圣的战争

	{"gkw_m1891mod3.weapon1.wav",2},//已检测，歌曲：布谷鸟
	{"gkw_m1891mod3.weapon2.wav",3},//已检测，歌曲：小雄鹰

	{"gkw_ak15mod3.weapon1.wav",4},//已检测，歌曲：为俄罗斯服役
	{"gkw_ak15mod3.weapon2.wav",5},//已检测，歌曲：我们是人民的军队
	{"gkw_ak15mod3.weapon3.wav",6},//已检测，歌曲：俄罗斯终结者
	{"gkw_ak15mod3.weapon4.wav",7},//已检测，歌曲：半机械大爷
	{"gkw_ak15mod3.weapon5.wav",38},//已检测，歌曲：战斗仍将继续

	{"gkw_an94_mod3.weapon1.wav",8},//已检测，歌曲：战斗仍将继续
	{"gkw_an94_mod3.weapon2.wav",9},//已检测，歌曲：起身吧，同志
	{"gkw_an94_mod3.weapon3.wav",10},//已检测，歌曲：救救孩子

	{"gkw_stg44mod3.weapon1.wav",11},//已检测，歌曲：守望莱茵

	{"gkw_ppsh41mod3.weapon1.wav",12},//已检测，歌曲：喀秋莎
	{"gkw_ppsh41mod3.weapon2.wav",13},//已检测，歌曲：喀秋莎

	{"gkw_stenmod3.weapon1.wav",14},//已检测，歌曲：统治吧不列颠尼亚

	{"gkw_type80mod3.weapon1.wav",15},//已检测，歌曲：共青团员之歌

	{"gkw_88typemod3.weapon1.wav",16},//已检测，歌曲：旗正飘飘(?)

	{"gkw_mp5mod3.weapon1.wav",17},//已检测，歌曲：秘密集结

	{"gkw_98kmod3.weapon1.wav",18},//已检测，歌曲：艾丽卡
	{"gkw_98kmod3.weapon2.wav",36},//已检测，歌曲：西部森林之歌
	{"gkw_98kmod3.weapon3.wav",37},//已检测，歌曲：罗尔之歌

	{"gkw_ak12.weapon1.wav",19},//已检测，歌曲：战斗仍将继续
	{"gkw_ak12.weapon2.wav",20},//已检测，歌曲：歌唱动荡的青春
	{"gkw_ak12.weapon3.wav",21},//已检测，歌曲：布尔什维克离开家
	{"gkw_ak12.weapon4.wav",22},//已检测，歌曲：伊里奇的训言号飞艇
	{"gkw_ak12.weapon5.wav",23},//已检测，歌曲：飞翔吧，白鹤

	{"gkw_ak47.weapon1.wav",24},//已检测，歌曲：我们的装甲师

	{"gkw_ak74m.weapon1.wav",25},//已检测，歌曲：变革
	{"gkw_ak74m.weapon2.wav",26},//已检测，歌曲：永别了
	{"gkw_ak74m.weapon3.wav",27},//已检测，歌曲：血液型

	{"gkw_m16a1.weapon1.wav",28},//已检测，歌曲：幸运儿

	{"gkw_dp28.weapon1.wav",29},//已检测，歌曲：莫斯科保卫者

	{"gkw_mg42.weapon1.wav",30},//已检测，歌曲：我们是黑色盖叶部队

	{"gkw_fg42.weapon1.wav",31},//已检测，歌曲：榛子是黑色的

	{"gkw_qbz191.weapon1.wav",32},//已检测，歌曲：当那一天来临

	{"gkw_QBZ95.weapon1.wav",33},//已检测，歌曲：中国人民志愿军战歌

	{"gkw_QBZ97.weapon1.wav",34},//已检测，歌曲：大海航行靠舵手

	{"gkw_mab38mod3.weapon1.wav",35},//已检测，歌曲：阿迪蒂突击队
	{"gkw_mab38mod3.weapon2.wav",39},//已检测，歌曲：啊，朋友再见

	{"gkw_ots14.weapon1.wav",40},//已检测，歌曲：暗夜女巫
	// 列表末尾，不用管
	{"end_of_list",0}
};

array<array<float>> songInfo = {
	
	// 对应上面的歌曲名设置一下音量和时长(单位：秒)就行

	// 列表开头，不用管
	{0.0,0.0},

    {4.0,184.0}, // 编号1，以此类推
    {4.0,392.0}, // 2 
    {4.0,268.0}, // 3
    {4.0,216.0}, // 4
    {4.0,123.0}, // 5
    {4.0,209.0}, // 6
    {4.0,186.0}, // 7
    {4.0,206.0}, // 8
    {4.0,177.0}, // 9
    {4.0,309.0}, // 10
    {4.0,280.0}, // 11
    {4.0,251.0}, // 12
    {4.0,137.0}, // 13
    {4.0,169.0}, // 14
    {4.0,121.0}, // 15
    {4.0,196.0}, // 16
    {4.0,104.0}, // 17
    {4.0,129.0}, // 18
    {4.0,208.0}, // 19
    {4.0,251.0}, // 20
    {4.0,205.0}, // 21
    {4.0,205.0}, // 22
    {4.0,166.0}, // 23
    {4.0,105.0}, // 24
    {4.0,267.0}, // 25
    {4.0,259.0}, // 26
    {4.0,238.0}, // 27
    {4.0,235.0}, // 28
    {4.0,221.0}, // 29
	{4.0,199.0}, // 30
	{4.0,138.0}, // 31
	{4.0,152.0}, // 32
	{4.0,107.0}, // 33
	{4.0,97.0}, // 34
	{4.0,275.0}, // 35
	{4.0,147.0}, // 36
	{4.0,144.0}, // 37
	{4.0,120.0}, // 38
	{4.0,179.0}, // 39
	{4.0,183.0}, // 40

	// 列表末尾，不用管
	{0.0,0.0}
};

//Adapted and optimizated by Castling Staff

// --------------------------------------------
class BasicCommandHandler : Tracker {
	protected Metagame@ m_metagame;
	protected float singLastTime = 0.0;

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
		else if (checkCommand(message, "dance7")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dancing, zoufang",true,true);
		}
		else if (checkCommand(message, "dance8")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dance, groove battle",true,true);
		}		
		else if (checkCommand(message, "dance9")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");			
			playAnimationKey(m_metagame,characterId,"dance, moonwalk",true,true);
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
		else if (checkCommand(message, "sing")) {

			_log('pre_sing 0.');
			// 获取玩家阵营，位置信息
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			int playerId = playerInfo.getIntAttribute("player_id");
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, characterId);
			if (characterInfo is null) return;
			string c_pos = characterInfo.getStringAttribute("position");
			int fId = characterInfo.getIntAttribute("faction_id");

			// 获取玩家装备，注意这里用的是getCharacterInfo2，和上面getCharacterInfo不同
			const XmlElement@ targetCharacter = getCharacterInfo2(m_metagame,characterId);
			if (targetCharacter is null) return;
			array<const XmlElement@>@ equipment = targetCharacter.getElementsByTagName("item");
			if (equipment.size() == 0) return;
			if (equipment[0].getIntAttribute("amount") == 0) return;
			string c_weaponType = equipment[0].getStringAttribute("key");
			string c_armorType = equipment[4].getStringAttribute("key");

			if(singLastTime>0){
				dictionary a;
                a["%time"] = ""+singLastTime;  
				sendPrivateMessageKey(m_metagame,playerId,"VODcooldown",a);
				return;
			}

			_log("Sing last time is: "+singLastTime);
			if(message=="/sing"){
				sendPrivateMessageKey(m_metagame,playerId,"VODvoid");
			}
			else{
				uint jud_num = uint(message.toLowerCase()[5]) - 48;
				string jud_sing_file = c_weaponType + '' + jud_num + '.wav';
				if(songIndex.exists(jud_sing_file)){
					_log("Sing file is: "+jud_sing_file);
					int songId = int(songIndex[jud_sing_file]);
					_log("Add up time: " + float(songInfo[songId][1]));
					singLastTime += float(songInfo[songId][1]);
					playSoundAtLocation(m_metagame,jud_sing_file,fId,c_pos,float(songInfo[songId][0]));
				}				
				else{
					sendPrivateMessageKey(m_metagame,playerId,"VODerror");
				}
			}
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
		else if (checkCommand(message, "testa2")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			if (playerInfo is null) return;
			int characterId= playerInfo.getIntAttribute("character_id");
			int factionId= playerInfo.getIntAttribute("faction_id");
			string target = playerInfo.getStringAttribute("aim_target");			
			GFL_event_array.insertLast(GFL_event(characterId,factionId,2,stringToVector3(target),1.0,-1.0));
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
					"	reward='10.0'>" + // multiplier affected..
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
		} else  if(checkCommand(message, "rewardtest")) {
			spawnInstanceNearPlayer(senderId, "city_gifts.drop_reward", "projectile");
			spawnInstanceNearPlayer(senderId, "city_gifts.drop_reward", "grenade");
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
			Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));					
			string c = 
				"<command class='create_instance'" +
				" faction_id='" + 0 + "'" +
				" instance_class='grenade'" +
				" instance_key='" + "city_gifts.drop_reward" + "'" +
				" position='" + pos.toString() + "'" +
				" character_id='" + playerInfo.getIntAttribute("character_id") + "'/>";
		} else  if(checkCommand(message, "stunme")) {
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			const XmlElement@ characterInfo = getCharacterInfo(m_metagame, playerInfo.getIntAttribute("character_id"));
			Vector3 pos = stringToVector3(characterInfo.getStringAttribute("position"));					
			string c = 
				"<command class='create_instance'" +
				" faction_id='" + 0 + "'" +
				" instance_class='grenade'" +
				" instance_key='" + "selfstun.projectile" + "'" +
				" position='" + pos.toString() + "'" +
				" character_id='" + playerInfo.getIntAttribute("character_id") + "'/>";				
			m_metagame.getComms().send(c);				      
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
			spawnInstanceNearPlayer(senderId, "upgrade_aa12.carry_item", "carry_item", 0);
			spawnInstanceNearPlayer(senderId, "upgrade_type88.carry_item", "carry_item", 0);
			spawnInstanceNearPlayer(senderId, "complete_box.carry_item", "carry_item", 0);
			spawnInstanceNearPlayer(senderId, "complete_box.carry_item", "carry_item", 0);
			spawnInstanceNearPlayer(senderId, "complete_box.carry_item", "carry_item", 0);
			spawnInstanceNearPlayer(senderId, "complete_box_singularity.carry_item","carry_item",0);
		} else if (checkCommand(message, "gb2")) {
			spawnInstanceNearPlayer(senderId, "core_mask.carry_item", "carry_item", 0);
		} else if (checkCommand(message, "gb3")) {
			spawnInstanceNearPlayer(senderId, "firecontrol.carry_item", "carry_item", 0);        
			spawnInstanceNearPlayer(senderId, "firecontrol.carry_item", "carry_item", 0);        
			spawnInstanceNearPlayer(senderId, "firecontrol.carry_item", "carry_item", 0);        
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
		} else  if(checkCommand(message, "javelin")) {
			spawnInstanceNearPlayer(senderId, "gkw_consume_javelin.weapon", "weapon", 0);        
		} else  if(checkCommand(message, "humvee")) {
			spawnInstanceNearPlayer(senderId, "humvee_gl_para.vehicle", "vehicle", 0);        
		} else  if(checkCommand(message, "javelin")) {
			spawnInstanceNearPlayer(senderId, "javelin_ap.weapon", "weapon", 0);        
		} else  if(checkCommand(message, "vectorflame")) {
			spawnInstanceNearPlayer(senderId, "gkw_vector_549_skill.weapon", "weapon", 0);        
		} else  if(checkCommand(message, "complete_campaign")) {
			m_metagame.getComms().send("<command class='set_campaign_status' show_stats='1'/>");
		} else if (checkCommand(message, "enable_gps")) {
			m_metagame.getComms().send("<command class='faction_resources' faction_id='0'><call key='gps.call' /></command>");
		} else  if(checkCommand(message, "icecream")) {
			// int randIndex=rand(1,4);
			// switch (randIndex){
			// 	case 1: spawnInstanceNearPlayer(senderId, "icecream.vehicle", "vehicle", 0);break;      
			// 	case 2: spawnInstanceNearPlayer(senderId, "icecream_Solar_Sea.vehicle", "vehicle", 0);break;
			// 	case 3: spawnInstanceNearPlayer(senderId, "icecream_akino.vehicle", "vehicle", 0);break;
			// 	case 4: spawnInstanceNearPlayer(senderId, "icecream_connexion.vehicle", "vehicle", 0);break;
			// }
			spawnInstanceNearPlayer(senderId, "icecream.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "rj")) {
			spawnInstanceNearPlayer(senderId, "deployed_mortar.vehicle", "vehicle", 1);        
		} else  if(checkCommand(message, "cat")) {
			spawnInstanceNearPlayer(senderId, "darkcat.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "ecat")) {
			spawnInstanceNearPlayer(senderId, "darkcat.vehicle", "vehicle", 1);
		} else  if(checkCommand(message, "spawntower")) {
			spawnInstanceNearPlayer(senderId, "radar_tower.vehicle", "vehicle", 0); 
		} else  if(checkCommand(message, "lblm")) {
			spawnInstanceNearPlayer(senderId, "wheelchair.vehicle", "vehicle", 0); 
		} else  if(checkCommand(message, "spawnaa")) {
			spawnInstanceNearPlayer(senderId, "aa_emplacement.vehicle", "vehicle", 1); 
		} else  if(checkCommand(message, "spawnjpt")) {
			spawnInstanceNearPlayer(senderId, "sf_jupiter.vehicle", "vehicle", 1); 		
		} else  if(checkCommand(message, "spawnmoth")) {
			spawnInstanceNearPlayer(senderId, "par_moth.vehicle", "vehicle", 1); 		
		} else  if(checkCommand(message, "moth1")) {
			spawnInstanceNearPlayer(senderId, "par_moth_ruin.vehicle", "vehicle", 1); 		
		} else  if(checkCommand(message, "spawnuhlan")) {
			spawnInstanceNearPlayer(senderId, "paradeus_uhlan.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnsand")) {
			spawnInstanceNearPlayer(senderId, "sandstorm.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawncoeus")) {
			spawnInstanceNearPlayer(senderId, "coeus.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawntyphon")) {
			spawnInstanceNearPlayer(senderId, "typhon.vehicle", "vehicle", 0);
		} else  if(checkCommand(message, "spawnaek")) {
			spawnInstanceNearPlayer(senderId, "aek999.vehicle", "vehicle", 0);		
		} else  if(checkCommand(message, "spawnbfg")) {
			spawnInstanceNearPlayer(senderId, "kcco_BFG.vehicle", "vehicle", 0);
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
		} else if (checkCommand(message,"givetestweapon")){
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","gkw_m1887.weapon");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","gkw_m240l.weapon");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","gkw_g41.weapon");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","gkw_obr.weapon");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"weapon","gkw_g3mod3.weapon");

			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"carry_item","upgrade_fg42.carry_item");
			addItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"carry_item","upgrade_g41.carry_item");



		} else if (checkCommand(message,"114514sf")){
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			addMutilItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"carry_item","gift_box_1.carry_item",400);
		} else if (checkCommand(message,"1919test")){
			const XmlElement@ playerInfo = getPlayerInfo(m_metagame, senderId);
			addMutilItemInBackpack(m_metagame,playerInfo.getIntAttribute("character_id"),"carry_item","complete_box.carry_item",20);  			            			
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

    void update(float time) {
        if(singLastTime>0){singLastTime-=time;}
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
