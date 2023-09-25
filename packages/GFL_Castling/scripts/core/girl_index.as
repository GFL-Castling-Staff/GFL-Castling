string getGFLkey(string num) {
    string key = string(tdoll_index[num]);
    if (key!=""){
        return key;
    } 
    return "";
}

dictionary tdoll_index = {
    {"1","gkw_m1873.weapon"},
    {"2","gkw_m1911.weapon"},
    {"3","gkw_m9.weapon"},
    {"4","gkw_python.weapon"},
    {"5","gkw_m1895.weapon"},
    {"6","gkw_tt33.weapon"},
    {"7","gkw_aps.weapon"},
    {"8","gkw_makarov.weapon"},
    {"9",""},
    {"10","gkw_ppk.weapon"},
    {"11",""},
    {"12","gkw_c96.weapon"},
    {"13","gkw_qsz92.weapon"},
    {"14",""},
    {"15",""},
    {"16","gkw_thompson.weapon"},
    {"17","gkw_m3.weapon"},
    {"18",""},
    {"19",""},
    {"20","gkw_vector.weapon"},
    {"21","gkw_ppsh41.weapon"},
    {"22","gkw_pps43.weapon"},
    {"23","gkw_pp90.weapon"},
    {"24",""},
    {"25","gkw_mp40.weapon"},
    {"26","gkw_mp5.weapon"},
    {"27","gkw_vz61.weapon"},
    {"28","gkw_mp7.weapon"},
    {"29","gkw_sten.weapon"},
    {"31","gkw_mab38.weapon"},
    {"32","gkw_uzi.weapon"},
    {"33",""},
    {"34","gkw_m1.weapon"},
    {"35","gkw_m1a1.weapon"},
    {"36","gkw_m1903.weapon"},
    {"37","gkw_m14.weapon"},
    {"38","gkw_m21.weapon"},
    {"39","gkw_m1891.weapon"},
    {"40",""},
    {"41",""},
    {"42","gkw_ptrd.weapon"},
    {"43","gkw_svd.weapon"},
    {"44","gkw_sv98.weapon"},
    {"46","gkw_98k.weapon"},
    {"47","gkw_g43.weapon"},
    {"48","gkw_wa2000.weapon"},
    {"49","gkw_56typer.weapon"},
    {"50","gkw_mlemk1.weapon"},
    {"51","gkw_fn49.weapon"},
    {"52",""},
    {"53","gkw_ntw20.weapon"},
    {"54","gkw_m16a1.weapon"},
    {"55","gkw_m4a1.weapon"},
    {"56","gkw_m4sopmodii.weapon"},
    {"57","gkw_ar15.weapon"},
    {"58","gkw_ak47.weapon"},
    {"59","gkw_ak74u.weapon"},
    {"60","gkw_asval.weapon"},
    {"61","gkw_stg44.weapon"},
    {"62","gkw_g41.weapon"},
    {"63","gkw_g3.weapon"},
    {"64","gkw_g36.weapon"},
    {"65","gkw_hk416.weapon"},
    {"66","gkw_56-1type.weapon"},
    {"68",""},
    {"69","gkw_famas.weapon"},
    {"70","gkw_fnc.weapon"},
    {"71","gkw_galil.weapon"},
    {"72","gkw_tar21.weapon"},
    {"73","gkw_aug.weapon"},
    {"74",""},
    {"75","gkw_m1918.weapon"},
    {"77","gkw_m2hb.weapon"},
    {"78","gkw_m60.weapon"},
    {"79","gkw_m249saw.weapon"},
    {"80","gkw_m1919a4.weapon"},
    {"81","gkw_lwmmg.weapon"},
    {"82","gkw_dp28.weapon"},
    {"84","gkw_rpd.weapon"},
    {"85","gkw_pk.weapon"},
    {"86","gkw_mg42.weapon"},
    {"87","gkw_mg34.weapon"},
    {"88","gkw_mg3.weapon"},
    {"89","gkw_bren.weapon"},
    {"90",""},
    {"91","gkw_mp446.weapon"},
    {"92",""},
    {"93","gkw_idw.weapon"},
    {"94","gkw_64type.weapon"},
    {"95","gkw_88type.weapon"},
    {"96","gkw_grizzly.weapon"},
    {"97","gkw_m950a.weapon"},
    // {"98","gkw_spp1.weapon"},
    {"99","gkw_mk23.weapon"},
    {"100","gkw_p7.weapon"},
    {"101","gkw_ump9.weapon"},
    {"102","gkw_ump40.weapon"},
    {"103","gkw_ump45.weapon"},
    {"104","gkw_g36c.weapon"},
    {"105","gkw_ots12.weapon"},
    {"106","gkw_fal.weapon"},
    {"107","gkw_f2000.weapon"},
    {"108",""},
    {"109","gkw_mg5.weapon"},
    {"110","gkw_fg42.weapon"},
    {"111",""},
    {"112","gkw_negev.weapon"},
    {"113",""},
    {"114","gkw_welrod.weapon"},
    {"115","gkw_kp31.weapon"},
    {"116",""},
    {"117","gkw_psg1.weapon"},
    {"118","gkw_9a91.weapon"},
    {"119","gkw_ots14.weapon"},
    {"120","gkw_arx160.weapon"},
    {"121","gkw_mk48.weapon"},
    {"122","gkw_g11.weapon"},
    // {"123","gkw_p99.weapon"},
    {"124","gkw_supersass.weapon"},
    {"125","gkw_mg4.weapon"},
    {"126","gkw_nz75.weapon"},
    {"127","gkw_type79.weapon"},
    {"128","gkw_m99.weapon"},
    {"129","gkw_QBZ95.weapon"},
    {"130","gkw_QBZ97.weapon"},
    {"131",""},
    {"132",""},
    {"133",""},
    {"134",""},
    {"135","gkw_sr3mp.weapon"},
    {"136","gkw_pp19.weapon"},
    {"137",""},
    {"138",""},
    {"139","gkw_brenten.weapon"},
    {"140",""},
    {"141",""},
    {"142","gkw_fn57.weapon"},
    {"143","gkw_ro635.weapon"},
    {"144",""},
    {"145",""},
    {"146","gkw_g28.weapon"},
    {"147",""},
    {"148","gkw_iws2000.weapon"},
    {"149","gkw_aek999.weapon"},
    {"150",""},
    {"151","gkw_m1887.weapon"},
    {"152","gkw_m1897.weapon"},
    {"153","gkw_m37.weapon"},
    {"154","gkw_m500.weapon"},
    {"155","gkw_m590.weapon"},
    {"156","gkw_supershorty.weapon"},
    {"157","gkw_ksg.weapon"},
    {"158","gkw_ks23.weapon"},
    {"159","gkw_rmb93.weapon"},
    {"160","gkw_saiga12.weapon"},
    {"161","gkw_hawk97.weapon"},
    {"162","gkw_spas12.weapon"},
    {"163","gkw_aa12.weapon"},
    {"164","gkw_fp6.weapon"},
    {"165","gkw_m1014.weapon"},
    {"166","gkw_cz75.weapon"},
    {"167",""},
    {"168",""},
    {"169",""},
    {"170","gkw_ash127.weapon"},
    {"171","gkw_ribeyrolles.weapon"},
    {"172","gkw_rfb.weapon"},
    {"173","gkw_pkp.weapon"},
    {"174","gkw_type81.weapon"},
    {"175","gkw_art556.weapon"},
    {"176","gkw_tmp.weapon"},
    {"177","gkw_klin.weapon"},
    {"178","gkw_f1.weapon"},
    {"179","gkw_dsr50.weapon"},
    {"180",""},
    {"181","gkw_t91.weapon"},
    {"182","gkw_wz29.weapon"},
    {"183","gkw_contender.weapon"},
    {"184",""},
    {"185","gkw_ameli.weapon"},
    {"186","gkw_p226.weapon"},
    {"187",""},
    {"188","gkw_sat8.weapon"},
    {"189","gkw_usas12.weapon"},
    {"190",""},
    {"191",""},
    {"192","gkw_js05.weapon"},
    {"193",""},
    {"194","gkw_k2.weapon"},
    {"195",""},
    {"196","gkw_zasm21.weapon"},
    {"197","gkw_carcano1891.weapon"},
    {"198","gkw_carcano1938.weapon"},
    {"199","gkw_type80.weapon"},
    {"200","gkw_xm3.weapon"},
    {"201","gkw_gepardm1.weapon"},
    {"202","gkw_thunder.weapon"},
    {"203","gkw_honeybadger.weapon"},
    {"204","gkw_ballista.weapon"},
    {"205","gkw_an94.weapon"},
    {"206","gkw_ak12.weapon"},
    {"207",""},
    {"208","gkw_hk21.weapon"},
    {"209",""},
    {"210",""},
    {"211","gkw_srs.weapon"},
    {"212","gkw_k5.weapon"},
    {"213","gkw_cms.weapon"},
    {"214",""},
    {"215","gkw_mdr.weapon"},
    {"216","gkw_xm8.weapon"},
    {"217",""},
    {"218",""},
    {"219",""},
    {"220","gkw_mp443.weapon"},
    {"221","gkw_gsh18.weapon"},
    {"222","gkw_tac50.weapon"},
    {"223",""},
    {"224","gkw_pm06.weapon"},
    {"225",""},
    {"226",""},
    {"227","gkw_a91.weapon"},
    {"228","gkw_type100.weapon"},
    {"229","gkw_m870.weapon"},
    {"230","gkw_obr.weapon"},
    {"231","gkw_m82a1.weapon"},
    {"232",""},
    {"233",""},
    {"234","gkw_js9.weapon"},
    {"235",""},
    {"236","gkw_k11_ar.weapon"},
    {"237",""},
    {"238","gkw_qjy88.weapon"},
    {"239",""},
    {"240","gkw_mk46.weapon"},
    {"241",""},
    {"242","gkw_p22.weapon"},
    {"243",""},
    {"244",""},
    {"245","gkw_p90.weapon"},
    {"247","gkw_k31.weapon"},
    {"248","gkw_Jericho.weapon"},
    {"249",""},
    {"250","gkw_hs2000.weapon"},
    {"251","gkw_x95.weapon"},
    {"252","gkw_ksvk.weapon"},
    {"253","gkw_lewis.weapon"},
    {"254","gkw_ukm2000.weapon"},
    {"255",""},
    {"256",""},
    {"257","gkw_m200.weapon"},
    {"258",""},
    {"259",""},
    {"260","gkw_pa15.weapon"},
    {"261","gkw_qbu88.weapon"},
    {"262",""},
    {"263","gkw_mg36.weapon"},
    {"264","gkw_chauchat.weapon"},
    {"265","gkw_hk33.weapon"},
    {"266","gkw_r93.weapon"},
    {"267",""},
    {"268",""},
    {"269","gkw_p30.weapon"},
    {"270","gkw_4type.weapon"},
    {"271",""},
    {"272","gkw_desert_eagle.weapon"},
    {"273",""},
    {"274","gkw_acr.weapon"},
    {"275",""},
    {"276","gkw_kord.weapon"},
    {"277",""},
    {"278",""},
    {"279",""},
    {"280",""},
    {"281","gkw_caws.weapon"},
    {"282","gkw_dp12.weapon"},
    {"283","gkw_liberator.weapon"},
    {"284",""},
    {"285","gkw_c93.weapon"},
    {"286",""},
    {"287","gkw_sig556.weapon"},
    {"288",""},
    {"289","gkw_r5.weapon"},
    {"290","gkw_type89.weapon"},
    {"291",""},
    {"292","gkw_rpk16.weapon"},
    {"293","gkw_ak15.weapon"},
    {"294","gkw_webley.weapon"},
    // {"295","gkw_cf05.weapon"},
    {"296","gkw_sl8.weapon"},
    {"297",""},
    {"298",""},
    {"299",""},
    {"300",""},
    {"301",""},
    {"302","gkw_defender.weapon"},
    {"303","gkw_hp35.weapon"},
    {"304","gkw_saf.weapon"},
    {"305",""},
    {"306","gkw_akalfa.weapon"},
    {"307","gkw_zb26.weapon"},
    {"308","gkw_c14.weapon"},
    {"309",""},
    {"310",""},
    {"311",""},
    {"312","gkw_vsk94.weapon"},
    {"313","gkw_sacr.weapon"},
    {"314",""},
    {"315","gkw_augpara.weapon"},
    {"316","gkw_liu.weapon"},
    {"317","gkw_m1908.weapon"},
    {"318","gkw_vhs.weapon"},
    {"319","gkw_pm1910.weapon"},
    {"320","gkw_gm6.weapon"},
    {"321",""},
    {"322","gkw_qsb91.weapon"},
    {"323","gkw_ltlx7000.weapon"},
    {"324","gkw_m6asw.weapon"},
    {"325",""},
    {"326","gkw_hk512.weapon"},
    {"327",""},
    {"328","gkw_ar57.weapon"},
    {"329","gkw_svch.weapon"},
    {"330","gkw_fx05.weapon"},
    {"331","gkw_kolibri.weapon"},
    {"332",""},
    {"333","gkw_vp1915.weapon"},
    {"334","gkw_savage99.weapon"},
    {"335",""},
    {"336",""},
    {"337","gkw_delisle.weapon"},
    {"338","gkw_sigmcx.weapon"},
    {"339","gkw_rpk203.weapon"},
    {"340","gkw_tkb408.weapon"},
    {"341","gkw_sp9.weapon"},
    {"342",""},
    {"343","gkw_apc556.weapon"},
    {"344","gkw_fara83.weapon"},
    {"345","gkw_mg338.weapon"},
    {"346","gkw_cz100.weapon"},
    {"347",""},
    {"348","gkw_hs50.weapon"},
    {"349","gkw_ak74m.weapon"},
    {"350","gkw_fo12.weapon"},
    {"351",""},
    {"352","gkw_nova.weapon"},
    {"353",""},
    {"354",""},
    {"355",""},
    {"356","gkw_a545.weapon"},
    {"357",""},
    {"358",""},
    {"359","gkw_sterling.weapon"},
    {"360",""},
    {"361","gkw_qbz191.weapon"},
    {"362",""},
    {"363","gkw_mpl.weapon"},
    {"364","gkw_mpk.weapon"},
    {"365",""},
    {"366","gkw_spas15.weapon"},
    {"367","gkw_mk3a1.weapon"},
    {"368","gkw_uts15.weapon"},
    {"369","gkw_m327.weapon"},
    {"370",""},
    {"371",""},
    {"372","gkw_ar18.weapon"},
    {"373",""},
    {"374","gkw_m240l.weapon"},
    {"375",""},
    {"376","gkw_emp35.weapon"},
    {"377","gkw_scarh.weapon"},
    {"378","gkw_scarl.weapon"},


    {"381","gkw_m110.weapon"},

    {"387","gkw_tps.weapon"},

    {"-1",""}

};

class modded_key
{
    string key;
    modded_key(const int index,const int skin=0, const string mod="none")
    {
        key = formatInt(index) + "-skin_" + formatInt(skin) + "-mod_" + mod;
    }

    string toString() const
    {
        return key;
    }
}

dictionary tdoll_complex_index = {
    {modded_key(1).toString(),"gkw_m1873.weapon"},
    {modded_key(1,301).toString(),"gkw_m1873_301.weapon"},
    {modded_key(1,2105).toString(),"gkw_m1873_2105.weapon"},
    {modded_key(1,0,"mod3").toString(),"gkw_m1873mod3.weapon"},
    {modded_key(1,301,"mod3").toString(),"gkw_m1873mod3_301.weapon"},
    {modded_key(1,2105,"mod3").toString(),"gkw_m1873mod3_2105.weapon"},

    {modded_key(2).toString(),"gkw_m1911.weapon"},
    {modded_key(2,4514).toString(),"gkw_m1911_4514.weapon"},
    {modded_key(2,8406).toString(),"gkw_m1911_8406.weapon"},
    {modded_key(2,0,"mod3").toString(),"gkw_m1911_mod3.weapon"},
    {modded_key(2,4514,"mod3").toString(),"gkw_m1911_mod3_4514.weapon"},
    {modded_key(2,8406,"mod3").toString(),"gkw_m1911_mod3_8406.weapon"},

    {modded_key(3).toString(),"gkw_m9.weapon"},

    {modded_key(4).toString(),"gkw_python.weapon"},
    {modded_key(4,6603).toString(),"gkw_python_6603.weapon"},

    {modded_key(5).toString(),"gkw_m1895.weapon"},
    {modded_key(5,5309).toString(),"gkw_m1895_5309.weapon"},
    {modded_key(5,7107).toString(),"gkw_m1895_7107.weapon"},
    {modded_key(5,0,"mod3").toString(),"gkw_m1895mod3.weapon"},
    {modded_key(5,5309,"mod3").toString(),"gkw_m1895mod3_5309.weapon"},
    {modded_key(5,7107,"mod3").toString(),"gkw_m1895mod3_7107.weapon"},

    {modded_key(6).toString(),"gkw_tt33.weapon"},
    {modded_key(6,601).toString(),"gkw_tt33_601.weapon"},
    {modded_key(6,3204).toString(),"gkw_tt33_3204.weapon"},

    {modded_key(7).toString(),"gkw_aps.weapon"},
    {modded_key(7,4306).toString(),"gkw_aps_4306.weapon"},
    {modded_key(7,6808).toString(),"gkw_aps_6808.weapon"},
    {modded_key(7,0,"mod3").toString(),"gkw_apsmod3.weapon"},
    {modded_key(7,4306,"mod3").toString(),"gkw_apsmod3_4306.weapon"},
    {modded_key(7,6808,"mod3").toString(),"gkw_apsmod3_6808.weapon"},

    {modded_key(8).toString(),"gkw_makarov.weapon"},
    {modded_key(8,0,"mod3").toString(),"gkw_makarovmod3.weapon"},

    {modded_key(9).toString(),"gkw_p38.weapon"},
    {modded_key(9,2401).toString(),"gkw_p38_2401.weapon"},

    {modded_key(10).toString(),"gkw_ppk.weapon"},
    {modded_key(10,3905).toString(),"gkw_ppk_3905.weapon"},
    {modded_key(10,0,"mod3").toString(),"gkw_ppkmod3.weapon"},
    {modded_key(10,3905,"mod3").toString(),"gkw_ppkmod3_3905.weapon"},

    {modded_key(12).toString(),"gkw_c96.weapon"},
    {modded_key(12,0,"mod3").toString(),"gkw_c96mod3.weapon"},

    {modded_key(13).toString(),"gkw_qsz92.weapon"},
    {modded_key(13,0,"mod3").toString(),"gkw_qsz92mod3.weapon"},

    {modded_key(14,8107).toString(),"gkw_357_8107.weapon"},


    {modded_key(16).toString(),"gkw_thompson.weapon"},
    {modded_key(16,5703).toString(),"gkw_thompson_5703.weapon"},

    {modded_key(17).toString(),"gkw_m3.weapon"},

    {modded_key(20).toString(),"gkw_vector.weapon"},
    {modded_key(20,549).toString(),"gkw_vector_549.weapon"},
    {modded_key(20,1901).toString(),"gkw_vector_1901.weapon"},

    {modded_key(21).toString(),"gkw_ppsh41.weapon"},
    {modded_key(21,602).toString(),"gkw_ppsh41_602.weapon"},
    {modded_key(21,0,"mod3").toString(),"gkw_ppsh41mod3.weapon"},
    {modded_key(21,602,"mod3").toString(),"gkw_ppsh41mod3_602.weapon"},

    {modded_key(22).toString(),"gkw_pps43.weapon"},
    {modded_key(23).toString(),"gkw_pp90.weapon"},

    {modded_key(25).toString(),"gkw_mp40.weapon"},
    {modded_key(25,902).toString(),"gkw_mp40_902.weapon"},

    {modded_key(26).toString(),"gkw_mp5.weapon"},
    {modded_key(26,3).toString(),"gkw_mp5_3.weapon"},
    {modded_key(26,1205).toString(),"gkw_mp5_1205.weapon"},
    {modded_key(26,1903).toString(),"gkw_mp5_1903.weapon"},
    {modded_key(26,3006).toString(),"gkw_mp5_3006.weapon"},
    {modded_key(26,0,"mod3").toString(),"gkw_mp5mod3.weapon"},
    {modded_key(26,3,"mod3").toString(),"gkw_mp5mod3_3.weapon"},
    {modded_key(26,1205,"mod3").toString(),"gkw_mp5mod3_1205.weapon"},
    {modded_key(26,1903,"mod3").toString(),"gkw_mp5mod3_1903.weapon"},
    {modded_key(26,3006,"mod3").toString(),"gkw_mp5mod3_3006.weapon"},

    {modded_key(27).toString(),"gkw_vz61.weapon"},
    {modded_key(27,0,"only").toString(),"gkw_vz61_only.weapon"},

    {modded_key(28).toString(),"gkw_mp7.weapon"},
    {modded_key(28,2405).toString(),"gkw_mp7_2405.weapon"},
    {modded_key(28,6806).toString(),"gkw_mp7_6806.weapon"},

    {modded_key(29).toString(),"gkw_sten.weapon"},
    {modded_key(29,0,"mod3").toString(),"gkw_stenmod3.weapon"},

    {modded_key(31).toString(),"gkw_mab38.weapon"},
    {modded_key(31,1).toString(),"gkw_mab38_oc.weapon"},
    {modded_key(31,0,"mod3").toString(),"gkw_mab38mod3.weapon"},
    {modded_key(31,1,"mod3").toString(),"gkw_mab38mod3_oc.weapon"},

    {modded_key(32).toString(),"gkw_uzi.weapon"},
    {modded_key(32,7907).toString(),"gkw_uzi_7907.weapon"},
    {modded_key(32,0,"mod3").toString(),"gkw_uzimod3.weapon"},
    {modded_key(32,7907,"mod3").toString(),"gkw_uzimod3_7907.weapon"},

    {modded_key(34).toString(),"gkw_m1.weapon"},
    {modded_key(34,1106).toString(),"gkw_m1_1106.weapon"},
    {modded_key(34,6907).toString(),"gkw_m1_6907.weapon"},
    {modded_key(34,0,"only").toString(),"gkw_m1_sf.weapon"},
    {modded_key(34,1106,"only").toString(),"gkw_m1_sf_1106.weapon"},
    {modded_key(34,6907,"only").toString(),"gkw_m1_sf_6907.weapon"},

    {modded_key(35).toString(),"gkw_m1a1.weapon"},

    {modded_key(36).toString(),"gkw_m1903.weapon"},
    {modded_key(36,0,"only").toString(),"gkw_m1903_only.weapon"},
    {modded_key(36,0,"exp").toString(),"gkw_m1903_exp.weapon"},  
    {modded_key(36,302).toString(),"gkw_m1903_302.weapon"},
    {modded_key(36,302,"only").toString(),"gkw_m1903_302_only.weapon"},
    {modded_key(36,302,"exp").toString(),"gkw_m1903_302_exp.weapon"},

    {modded_key(37).toString(),"gkw_m14.weapon"},
    {modded_key(37,303).toString(),"gkw_m14_303.weapon"},
    {modded_key(37,0,"mod3").toString(),"gkw_m14mod3.weapon"},
    {modded_key(37,303,"mod3").toString(),"gkw_m14mod3_303.weapon"},

    {modded_key(38).toString(),"gkw_m21.weapon"},

    {modded_key(39).toString(),"gkw_m1891.weapon"},
    {modded_key(39,0,"mod3").toString(),"gkw_m1891mod3.weapon"},

    {modded_key(41).toString(),"gkw_sks.weapon"},
    {modded_key(42).toString(),"gkw_ptrd.weapon"},

    {modded_key(43).toString(),"gkw_svd.weapon"},
    {modded_key(43,5506).toString(),"gkw_svd_5506.weapon"},
    {modded_key(43,0,"only").toString(),"gkw_svdex.weapon"},
    {modded_key(43,5506,"only").toString(),"gkw_svdex_5506.weapon"},

    {modded_key(44).toString(),"gkw_sv98.weapon"},
    {modded_key(44,502).toString(),"gkw_sv98_502.weapon"},
    {modded_key(44,1906).toString(),"gkw_sv98_1906.weapon"},
    {modded_key(44,0,"mod3").toString(),"gkw_sv98mod3.weapon"},
    {modded_key(44,502,"mod3").toString(),"gkw_sv98mod3_502.weapon"},
    {modded_key(44,1906,"mod3").toString(),"gkw_sv98mod3_1906.weapon"},

    {modded_key(46).toString(),"gkw_98k.weapon"},
    {modded_key(46,4301).toString(),"gkw_98k_4301.weapon"},
    {modded_key(46,0,"mod3").toString(),"gkw_98kmod3.weapon"},
    {modded_key(46,4301,"mod3").toString(),"gkw_98kmod3_4301.weapon"},

    {modded_key(47).toString(),"gkw_g43.weapon"},
    {modded_key(47,0,"only").toString(),"gkw_g43_kurz.weapon"},
    {modded_key(47,7607).toString(),"gkw_g43_7607.weapon"},
    {modded_key(47,7607,"only").toString(),"gkw_g43_7607_kurz.weapon"},

    {modded_key(48).toString(),"gkw_wa2000.weapon"},
    {modded_key(48,306).toString(),"gkw_wa2000_306.weapon"},
    {modded_key(48,1108).toString(),"gkw_wa2000_1108.weapon"},
    {modded_key(48,0,"only").toString(),"gkw_wa2000_only.weapon"},
    {modded_key(48,306,"only").toString(),"gkw_wa2000_306_only.weapon"},
    {modded_key(48,1108,"only").toString(),"gkw_wa2000_1108_only.weapon"},

    {modded_key(49).toString(),"gkw_56typer.weapon"},
    {modded_key(49,5508).toString(),"gkw_56typer_5508.weapon"},
    {modded_key(49,0,"mod3").toString(),"gkw_56typermod3.weapon"},
    {modded_key(49,5508,"mod3").toString(),"gkw_56typermod3_5508.weapon"},

    {modded_key(50).toString(),"gkw_mlemk1.weapon"},
    {modded_key(50,604).toString(),"gkw_mlemk1_604.weapon"},
    {modded_key(50,0,"mod3").toString(),"gkw_mlemk1mod3.weapon"},
    {modded_key(50,604,"mod3").toString(),"gkw_mlemk1mod3_604.weapon"},

    {modded_key(51).toString(),"gkw_fn49.weapon"},
    {modded_key(51,4709).toString(),"gkw_fn49_4709.weapon"},
    {modded_key(51,0,"mod3").toString(),"gkw_fn49mod3.weapon"},
    {modded_key(51,4709,"mod3").toString(),"gkw_fn49mod3_4709.weapon"},

    {modded_key(53).toString(),"gkw_ntw20.weapon"},
    {modded_key(53,307).toString(),"gkw_ntw20_307.weapon"},
    {modded_key(53,4801).toString(),"gkw_ntw20_4801.weapon"},
    {modded_key(53,0,"mod3").toString(),"gkw_ntw20mod3.weapon"},
    {modded_key(53,307,"mod3").toString(),"gkw_ntw20mod3_307.weapon"},
    {modded_key(53,4801,"mod3").toString(),"gkw_ntw20mod3_4801.weapon"},

    {modded_key(54).toString(),"gkw_m16a1.weapon"},
    {modded_key(54,533).toString(),"gkw_m16a1_533.weapon"},
    {modded_key(54,553).toString(),"gkw_m16a1_553.weapon"},

    {modded_key(55).toString(),"gkw_m4a1.weapon"},
    {modded_key(55,530).toString(),"gkw_m4a1_530.weapon"},
    {modded_key(55,550).toString(),"gkw_m4a1_550.weapon"},
    {modded_key(55,0,"mod3").toString(),"gkw_m4a1mod3.weapon"},
    {modded_key(55,530,"mod3").toString(),"gkw_m4a1mod3_530.weapon"},
    {modded_key(55,550,"mod3").toString(),"gkw_m4a1mod3_550.weapon"},

    {modded_key(56).toString(),"gkw_m4sopmodii.weapon"},
    {modded_key(56,531).toString(),"gkw_m4sopmodii_531.weapon"},
    {modded_key(56,551).toString(),"gkw_m4sopmodii_551.weapon"},
    {modded_key(56,4507).toString(),"gkw_m4sopmodii_4507.weapon"},
    {modded_key(56,0,"mod3").toString(),"gkw_m4sopmodiimod3.weapon"},
    {modded_key(56,531,"mod3").toString(),"gkw_m4sopmodiimod3_531.weapon"},
    {modded_key(56,551,"mod3").toString(),"gkw_m4sopmodiimod3_551.weapon"},
    {modded_key(56,4507,"mod3").toString(),"gkw_m4sopmodiimod3_4507.weapon"},

    {modded_key(57).toString(),"gkw_ar15.weapon"},
    {modded_key(57,532).toString(),"gkw_ar15_532.weapon"},
    {modded_key(57,552).toString(),"gkw_ar15_552.weapon"},
    {modded_key(57,30001).toString(),"gkw_ar15_30001.weapon"},
    {modded_key(57,0,"mod3").toString(),"gkw_ar15mod3.weapon"},
    {modded_key(57,532,"mod3").toString(),"gkw_ar15mod3_532.weapon"},
    {modded_key(57,552,"mod3").toString(),"gkw_ar15mod3_552.weapon"},
    {modded_key(57,30001,"mod3").toString(),"gkw_ar15mod3_30001.weapon"},

    {modded_key(58).toString(),"gkw_ak47.weapon"},
    {modded_key(58,501).toString(),"gkw_ak47_501.weapon"},
    {modded_key(58,0,"only").toString(),"gkw_ak47_60r.weapon"},
    {modded_key(58,501,"only").toString(),"gkw_ak47_60r_501.weapon"},

    {modded_key(59).toString(),"gkw_ak74u.weapon"},
    {modded_key(59,3002).toString(),"gkw_ak74u_3002.weapon"},

    {modded_key(60).toString(),"gkw_asval.weapon"},
    {modded_key(60,2907).toString(),"gkw_asval_2907.weapon"},
    {modded_key(60,0,"mod3").toString(),"gkw_asvalmod3.weapon"},
    {modded_key(60,2907,"mod3").toString(),"gkw_asvalmod3_2907.weapon"},

    {modded_key(61).toString(),"gkw_stg44.weapon"},
    {modded_key(61,0,"mod3").toString(),"gkw_stg44mod3.weapon"},

    {modded_key(62).toString(),"gkw_g41.weapon"},
    {modded_key(62,2401).toString(),"gkw_g41_2401.weapon"},
    {modded_key(62,7406).toString(),"gkw_g41_7406.weapon"},
    {modded_key(62,0,"only").toString(),"gkw_g41_only.weapon"},
    {modded_key(62,2401,"only").toString(),"gkw_g41_2401_only.weapon"},
    {modded_key(62,7406,"only").toString(),"gkw_g41_7406_only.weapon"},

    {modded_key(63).toString(),"gkw_g3.weapon"},
    {modded_key(63,1303).toString(),"gkw_g3_1303.weapon"},
    {modded_key(63,0,"mod3").toString(),"gkw_g3mod3.weapon"},
    {modded_key(63,1303,"mod3").toString(),"gkw_g3mod3_1303.weapon"},

    {modded_key(64).toString(),"gkw_g36.weapon"},
    {modded_key(64,1507).toString(),"gkw_g36_1507.weapon"},
    {modded_key(64,1904).toString(),"gkw_g36_1904.weapon"},
    {modded_key(64,6807).toString(),"gkw_g36_6807.weapon"},
    {modded_key(64,0,"mod3").toString(),"gkw_g36mod3.weapon"},
    {modded_key(64,1507,"mod3").toString(),"gkw_g36mod3_1507.weapon"},
    {modded_key(64,1904,"mod3").toString(),"gkw_g36mod3_1904.weapon"},
    {modded_key(64,6807,"mod3").toString(),"gkw_g36mod3_6807.weapon"},

    {modded_key(65).toString(),"gkw_hk416.weapon"},
    {modded_key(65,537).toString(),"gkw_hk416_537.weapon"},
    {modded_key(65,805).toString(),"gkw_hk416_805.weapon"},
    {modded_key(65,3401).toString(),"gkw_hk416_3401.weapon"},
    {modded_key(65,6505).toString(),"gkw_hk416_6505.weapon"},
    {modded_key(65,0,"mod3").toString(),"gkw_hk416mod3.weapon"},
    {modded_key(65,537,"mod3").toString(),"gkw_hk416_537_mod3.weapon"},
    {modded_key(65,805,"mod3").toString(),"gkw_hk416mod3_805.weapon"},
    {modded_key(65,3401,"mod3").toString(),"gkw_hk416_3401_mod3.weapon"},
    {modded_key(65,6505,"mod3").toString(),"gkw_hk416_6505_mod3.weapon"},

    {modded_key(66).toString(),"gkw_56-1type.weapon"},
    {modded_key(66,0,"mod3").toString(),"gkw_56-1typemod3.weapon"},

    {modded_key(69).toString(),"gkw_famas.weapon"},

    {modded_key(70).toString(),"gkw_fnc.weapon"},
    {modded_key(70,6608).toString(),"gkw_fnc_6608.weapon"},

    {modded_key(71).toString(),"gkw_galil.weapon"},
    {modded_key(71,0,"mod3").toString(),"gkw_galilmod3.weapon"},

    {modded_key(72).toString(),"gkw_tar21.weapon"},
    {modded_key(72,1305).toString(),"gkw_tar21_1305.weapon"},
    {modded_key(72,8106).toString(),"gkw_tar21_8106.weapon"},

    {modded_key(73).toString(),"gkw_aug.weapon"},

    {modded_key(75).toString(),"gkw_m1918.weapon"},
    {modded_key(75,102).toString(),"gkw_m1918_102.weapon"},
    {modded_key(75,806).toString(),"gkw_m1918_806.weapon"},
    {modded_key(75,1606).toString(),"gkw_m1918_1606.weapon"},
    {modded_key(75,0,"mod3").toString(),"gkw_m1918mod3.weapon"},
    {modded_key(75,102,"mod3").toString(),"gkw_m1918mod3_102.weapon"},
    {modded_key(75,806,"mod3").toString(),"gkw_m1918mod3_806.weapon"},
    {modded_key(75,1606,"mod3").toString(),"gkw_m1918mod3_1606.weapon"},

    {modded_key(77).toString(),"gkw_m2hb.weapon"},

    {modded_key(78).toString(),"gkw_m60.weapon"},
    {modded_key(79).toString(),"gkw_m249saw.weapon"},

    {modded_key(80).toString(),"gkw_m1919a4.weapon"},
    {modded_key(80,0,"mod3").toString(),"gkw_m1919a4mod3.weapon"},

    {modded_key(81).toString(),"gkw_lwmmg.weapon"},
    {modded_key(81,1808).toString(),"gkw_lwmmg_1808.weapon"},
    {modded_key(81,0,"mod3").toString(),"gkw_lwmmgmod3.weapon"},
    {modded_key(81,1808,"mod3").toString(),"gkw_lwmmgmod3_1808.weapon"},

    {modded_key(82).toString(),"gkw_dp28.weapon"},
    {modded_key(82,8008).toString(),"gkw_dp28_8008.weapon"},

    {modded_key(84).toString(),"gkw_rpd.weapon"},
    {modded_key(85).toString(),"gkw_pk.weapon"},

    {modded_key(86).toString(),"gkw_mg42.weapon"},
    {modded_key(86,7606).toString(),"gkw_mg42_7606.weapon"},

    {modded_key(87).toString(),"gkw_mg34.weapon"},

    {modded_key(88).toString(),"gkw_mg3.weapon"},
    {modded_key(88,3806).toString(),"gkw_mg3_3806.weapon"},
    {modded_key(88,0,"mod3").toString(),"gkw_mg3mod3.weapon"},
    {modded_key(88,3806,"mod3").toString(),"gkw_mg3mod3_3806.weapon"},

    {modded_key(89).toString(),"gkw_bren.weapon"},
    {modded_key(89,0,"mod3").toString(),"gkw_brenmod3.weapon"},

    {modded_key(91).toString(),"gkw_mp446.weapon"},


    {modded_key(93).toString(),"gkw_idw.weapon"},
    {modded_key(93,2108).toString(),"gkw_idw_2108.weapon"},
    {modded_key(93,3205).toString(),"gkw_idw_3205.weapon"},
    {modded_key(93,4908).toString(),"gkw_idw_4908.weapon"},
    {modded_key(93,0,"mod3").toString(),"gkw_idwmod3.weapon"},
    {modded_key(93,2108,"mod3").toString(),"gkw_idwmod3_2108.weapon"},
    {modded_key(93,3205,"mod3").toString(),"gkw_idwmod3_3205.weapon"},
    {modded_key(93,4908,"mod3").toString(),"gkw_idwmod3_4908.weapon"},

    {modded_key(94).toString(),"gkw_64type.weapon"},
    {modded_key(94,0,"mod3").toString(),"gkw_64typemod3.weapon"},

    {modded_key(95).toString(),"gkw_88type.weapon"},
    {modded_key(95,0,"mod3").toString(),"gkw_88typemod3.weapon"},
    {modded_key(95,6503,"mod3").toString(),"gkw_88typemod3_6503.weapon"},

    {modded_key(96).toString(),"gkw_grizzly.weapon"},
    {modded_key(96,4303).toString(),"gkw_grizzly_4303.weapon"},

    {modded_key(97).toString(),"gkw_m950a.weapon"},
    {modded_key(97,702).toString(),"gkw_m950a_702.weapon"},
    {modded_key(97,4302).toString(),"gkw_m950a_4302.weapon"},
    {modded_key(97,0,"mod3").toString(),"gkw_m950amod3.weapon"},
    {modded_key(97,702,"mod3").toString(),"gkw_m950amod3_702.weapon"},
    {modded_key(97,4302,"mod3").toString(),"gkw_m950amod3_4302.weapon"},

    {modded_key(98,4207).toString(),"gkw_spp1_4207.weapon"},

    {modded_key(99).toString(),"gkw_mk23.weapon"},
    {modded_key(99,8).toString(),"gkw_mk23_8.weapon"},
    {modded_key(99,1805).toString(),"gkw_mk23_1805.weapon"},

    {modded_key(100).toString(),"gkw_p7.weapon"},

    {modded_key(101).toString(),"gkw_ump9.weapon"},
    {modded_key(101,3404).toString(),"gkw_ump9_3404.weapon"},
    {modded_key(101,6704).toString(),"gkw_ump9_6704.weapon"},
    {modded_key(101,0,"mod3").toString(),"gkw_ump9mod3.weapon"},
    {modded_key(101,3404,"mod3").toString(),"gkw_ump9mod3_3404.weapon"},
    {modded_key(101,6704,"mod3").toString(),"gkw_ump9mod3_6704.weapon"},

    {modded_key(102).toString(),"gkw_ump40.weapon"},

    {modded_key(103).toString(),"gkw_ump45.weapon"},
    {modded_key(103,410).toString(),"gkw_ump45_410.weapon"},
    {modded_key(103,535).toString(),"gkw_ump45_535.weapon"},
    {modded_key(103,3404).toString(),"gkw_ump45_3403.weapon"},
    {modded_key(103,5405).toString(),"gkw_ump45_5405.weapon"},
    {modded_key(103,0,"mod3").toString(),"gkw_ump45mod3.weapon"},
    {modded_key(103,410,"mod3").toString(),"gkw_ump45mod3_410.weapon"},
    {modded_key(103,535,"mod3").toString(),"gkw_ump45mod3_535.weapon"},
    {modded_key(103,3404,"mod3").toString(),"gkw_ump45mod3_3403.weapon"},
    {modded_key(103,5405,"mod3").toString(),"gkw_ump45mod3_5405.weapon"},

    {modded_key(104).toString(),"gkw_g36c.weapon"},
    {modded_key(104,3103).toString(),"gkw_g36c_3103.weapon"},
    {modded_key(104,0,"mod3").toString(),"gkw_g36c_mod3.weapon"},
    {modded_key(104,3103,"mod3").toString(),"gkw_g36c_mod3_3103.weapon"},

    {modded_key(105).toString(),"gkw_ots12.weapon"},
    {modded_key(105,3605).toString(),"gkw_ots12_3605.weapon"},

    {modded_key(106).toString(),"gkw_fal.weapon"},
    {modded_key(106,308).toString(),"gkw_fal_308.weapon"},
    {modded_key(106,2406).toString(),"gkw_fal_2406.weapon"},

    {modded_key(107).toString(),"gkw_f2000.weapon"},

    {modded_key(109).toString(),"gkw_mg5.weapon"},

    {modded_key(110).toString(),"gkw_fg42.weapon"},
    {modded_key(110,0,"only").toString(),"gkw_fg42_only.weapon"},

    {modded_key(112).toString(),"gkw_negev.weapon"},
    {modded_key(112,904).toString(),"gkw_negev_904.weapon"},
    {modded_key(112,3202).toString(),"gkw_negev_3202.weapon"},

    {modded_key(114).toString(),"gkw_welrod.weapon"},
    {modded_key(114,411).toString(),"gkw_welrod_411.weapon"},
    {modded_key(114,2103).toString(),"gkw_welrod_2103.weapon"},
    {modded_key(114,0,"mod3").toString(),"gkw_welrodmod3.weapon"},
    {modded_key(114,411,"mod3").toString(),"gkw_welrodmod3_411.weapon"},
    {modded_key(114,2103,"mod3").toString(),"gkw_welrodmod3_2103.weapon"},

    {modded_key(115).toString(),"gkw_kp31.weapon"},
    {modded_key(115,310).toString(),"gkw_kp31_310.weapon"},
    {modded_key(115,3101).toString(),"gkw_kp31_3101.weapon"},
    {modded_key(115,0,"mod3").toString(),"gkw_kp31mod3.weapon"},
    {modded_key(115,310,"mod3").toString(),"gkw_kp31mod3_310.weapon"},
    {modded_key(115,3101,"mod3").toString(),"gkw_kp31mod3_3101.weapon"},

    {modded_key(117).toString(),"gkw_psg1.weapon"},
    {modded_key(117,8404).toString(),"gkw_psg1_8404.weapon"},

    {modded_key(118).toString(),"gkw_9a91.weapon"},
    {modded_key(118,1302).toString(),"gkw_9a91_1302.weapon"},
    {modded_key(118,8304).toString(),"gkw_9a91_8304.weapon"},
    {modded_key(118,0,"only").toString(),"gkw_9a91_only.weapon"},
    {modded_key(118,1302,"only").toString(),"gkw_9a91_1302_only.weapon"},
    {modded_key(118,8304,"only").toString(),"gkw_9a91_8304_only.weapon"},

    {modded_key(119).toString(),"gkw_ots14.weapon"},
    {modded_key(119,1203).toString(),"gkw_ots14_1203.weapon"},
    {modded_key(119,4501).toString(),"gkw_ots14_4501.weapon"},

    {modded_key(120).toString(),"gkw_arx160.weapon"},

    {modded_key(121).toString(),"gkw_mk48.weapon"},

    {modded_key(122).toString(),"gkw_g11.weapon"},
    {modded_key(122,9).toString(),"gkw_g11_9.weapon"},
    {modded_key(122,538).toString(),"gkw_g11_538.weapon"},
    {modded_key(122,4102).toString(),"gkw_g11_4102.weapon"},
    {modded_key(122,0,"mod3").toString(),"gkw_g11mod3.weapon"},
    {modded_key(122,9,"mod3").toString(),"gkw_g11mod3_9.weapon"},
    {modded_key(122,538,"mod3").toString(),"gkw_g11mod3_538.weapon"},
    {modded_key(122,4102,"mod3").toString(),"gkw_g11mod3_4102.weapon"},

    {modded_key(124).toString(),"gkw_supersass.weapon"},
    {modded_key(124,1407).toString(),"gkw_supersass_1407.weapon"},
    {modded_key(124,0,"mod3").toString(),"gkw_supersassmod3.weapon"},
    {modded_key(124,1407,"mod3").toString(),"gkw_supersassmod3_1407.weapon"},

    {modded_key(125).toString(),"gkw_mg4.weapon"},
    {modded_key(125,1).toString(),"gkw_mg4_oc.weapon"},
    {modded_key(125,703).toString(),"gkw_mg4_703.weapon"},
    {modded_key(125,0,"mod3").toString(),"gkw_mg4mod3.weapon"},
    {modded_key(125,1,"mod3").toString(),"gkw_mg4mod3_oc.weapon"},
    {modded_key(125,703,"mod3").toString(),"gkw_mg4mod3_703.weapon"},

    {modded_key(126).toString(),"gkw_nz75.weapon"},
    {modded_key(126,403).toString(),"gkw_nz75_403.weapon"},

    {modded_key(127).toString(),"gkw_type79.weapon"},
    {modded_key(127,1402).toString(),"gkw_type79_1402.weapon"},

    {modded_key(128).toString(),"gkw_m99.weapon"},
    {modded_key(128,404).toString(),"gkw_m99_404.weapon"},
    {modded_key(128,1701).toString(),"gkw_m99_1701.weapon"},
    {modded_key(128,3304).toString(),"gkw_m99_3304.weapon"},
    
    {modded_key(129).toString(),"gkw_QBZ95.weapon"},
    {modded_key(129,405).toString(),"gkw_QBZ95_405.weapon"},
    {modded_key(129,1102).toString(),"gkw_QBZ95_1102.weapon"},
    {modded_key(129,3702).toString(),"gkw_QBZ95_3702.weapon"},
    {modded_key(129,5604).toString(),"gkw_QBZ95_5604.weapon"},

    {modded_key(130).toString(),"gkw_QBZ97.weapon"},
    {modded_key(130).toString(),"gkw_QBZ97_6902.weapon"},

    {modded_key(135).toString(),"gkw_sr3mp.weapon"},
    {modded_key(135,4101).toString(),"gkw_sr3mp_4101.weapon"},

    {modded_key(136).toString(),"gkw_pp19.weapon"},
    {modded_key(136,0,"mod3").toString(),"gkw_pp19mod3.weapon"},

    {modded_key(138).toString(),"gkw_6p62.weapon"},
    {modded_key(138,8610).toString(),"gkw_6p62_8610.weapon"},

    {modded_key(139).toString(),"gkw_brenten.weapon"},
    {modded_key(139,7809).toString(),"gkw_brenten_7809.weapon"},

    {modded_key(142).toString(),"gkw_fn57.weapon"},
    {modded_key(142,1109).toString(),"gkw_fn57_1109.weapon"},

    {modded_key(143).toString(),"gkw_ro635.weapon"},
    {modded_key(143,534).toString(),"gkw_ro635_534.weapon"},
    {modded_key(143,0,"mod3").toString(),"gkw_ro635mod3.weapon"},
    {modded_key(143,534,"mod3").toString(),"gkw_ro635mod3_534.weapon"},

    {modded_key(146).toString(),"gkw_g28.weapon"},

    {modded_key(148).toString(),"gkw_iws2000.weapon"},
    {modded_key(148,1403).toString(),"gkw_iws2000_1403.weapon"},
    {modded_key(148,7308).toString(),"gkw_iws2000_7308.weapon"},

    {modded_key(149).toString(),"gkw_aek999.weapon"},

    // 从编号150开始
    {modded_key(151).toString(),"gkw_m1887.weapon"},

    {modded_key(152).toString(),"gkw_m1897.weapon"},
    {modded_key(152,0,"mod3").toString(),"gkw_m1897mod3.weapon"},

    {modded_key(153).toString(),"gkw_m37.weapon"},
    {modded_key(153,1105).toString(),"gkw_m37_1105.weapon"},

    {modded_key(154).toString(),"gkw_m500.weapon"},
    {modded_key(154,3707).toString(),"gkw_m500_3707.weapon"},
    {modded_key(154,0,"mod3").toString(),"gkw_m500mod3.weapon"},
    {modded_key(154,3707,"mod3").toString(),"gkw_m500mod3_3707.weapon"},

    {modded_key(155).toString(),"gkw_m590.weapon"},
    {modded_key(155,1806).toString(),"gkw_m590_1806.weapon"},

    {modded_key(156).toString(),"gkw_supershorty.weapon"},
    {modded_key(156,8506).toString(),"gkw_supershorty_8506.weapon"},

    {modded_key(157).toString(),"gkw_ksg.weapon"},

    {modded_key(158).toString(),"gkw_ks23.weapon"},

    {modded_key(159).toString(),"gkw_rmb93.weapon"},
    {modded_key(159,4309).toString(),"gkw_rmb93_4309.weapon"},
    {modded_key(159,0,"mod3").toString(),"gkw_rmb93mod3.weapon"},
    {modded_key(159,4309,"mod3").toString(),"gkw_rmb93mod3_4309.weapon"},

    {modded_key(160).toString(),"gkw_saiga12.weapon"},

    {modded_key(161).toString(),"gkw_hawk97.weapon"},
    {modded_key(161,5805).toString(),"gkw_hawk97_5805.weapon"},
    {modded_key(161,0,"mod3").toString(),"gkw_hawk97mod3.weapon"},
    {modded_key(161,5805,"mod3").toString(),"gkw_hawk97mod3_5805.weapon"},

    {modded_key(162).toString(),"gkw_spas12.weapon"},
    {modded_key(162,2408).toString(),"gkw_spas12_2408.weapon"},
    {modded_key(162,3203).toString(),"gkw_spas12_3203.weapon"},

    {modded_key(163).toString(),"gkw_aa12.weapon"},
    {modded_key(163,2403).toString(),"gkw_aa12_2403.weapon"},
    {modded_key(163,4401).toString(),"gkw_aa12_4401.weapon"},
    {modded_key(163,0,"only").toString(),"gkw_aa12_only.weapon"},
    {modded_key(163,2403,"only").toString(),"gkw_aa12_2403_only.weapon"},
    {modded_key(163,4401,"only").toString(),"gkw_aa12_4401_only.weapon"},

    {modded_key(164).toString(),"gkw_fp6.weapon"},
    {modded_key(164,2804).toString(),"gkw_fp6_2804.weapon"},

    {modded_key(166).toString(),"gkw_cz75.weapon"},
    {modded_key(166,1604).toString(),"gkw_cz75_1604.weapon"},

    {modded_key(170).toString(),"gkw_ash127.weapon"},
    {modded_key(171).toString(),"gkw_ribeyrolles.weapon"},
    {modded_key(171,0,"mod3").toString(),"gkw_ribeyrollesmod3.weapon"},

    {modded_key(172).toString(),"gkw_rfb.weapon"},
    {modded_key(172,1601).toString(),"gkw_rfb_1601.weapon"},

    {modded_key(173).toString(),"gkw_pkp.weapon"},
    {modded_key(173,4203).toString(),"gkw_pkp_4203.weapon"},
    {modded_key(173,0,"only").toString(),"gkw_pkp_only.weapon"},
    {modded_key(173,4203,"only").toString(),"gkw_pkp_4203_only.weapon"},

    {modded_key(174).toString(),"gkw_type81.weapon"},
    {modded_key(174,5607).toString(),"gkw_type81_5607.weapon"},

    {modded_key(175).toString(),"gkw_art556.weapon"},
    {modded_key(175,1803).toString(),"gkw_art556_1803.weapon"},
    {modded_key(175,2803).toString(),"gkw_art556_2803.weapon"},

    {modded_key(176).toString(),"gkw_tmp.weapon"},
    {modded_key(176,2807).toString(),"gkw_tmp_2807.weapon"},

    {modded_key(177).toString(),"gkw_klin.weapon"},

    {modded_key(178).toString(),"gkw_f1.weapon"},
    {modded_key(178,0,"mod3").toString(),"gkw_f1mod3.weapon"},

    {modded_key(179).toString(),"gkw_dsr50.weapon"},
    {modded_key(179,1801).toString(),"gkw_dsr50_1801.weapon"},
    {modded_key(179,2101).toString(),"gkw_dsr50_2101.weapon"},

    {modded_key(181).toString(),"gkw_t91.weapon"},
    {modded_key(181,4206).toString(),"gkw_t91_4206.weapon"},

    {modded_key(182).toString(),"gkw_wz29.weapon"},

    {modded_key(183).toString(),"gkw_contender.weapon"},
    {modded_key(183,1502).toString(),"gkw_contender_1502.weapon"},
    {modded_key(183,3201).toString(),"gkw_contender_3201.weapon"},

    {modded_key(185).toString(),"gkw_ameli.weapon"},
    {modded_key(185,1605).toString(),"gkw_ameli_1605.weapon"},
    {modded_key(185,2409).toString(),"gkw_ameli_2409.weapon"},

    {modded_key(186).toString(),"gkw_p226.weapon"},

    {modded_key(188).toString(),"gkw_sat8.weapon"},
    {modded_key(188,1802).toString(),"gkw_sat8_1802.weapon"},
    {modded_key(188,2601).toString(),"gkw_sat8_2601.weapon"},

    {modded_key(189).toString(),"gkw_usas12.weapon"},

    {modded_key(192).toString(),"gkw_js05.weapon"},

    {modded_key(194).toString(),"gkw_k2.weapon"},

    {modded_key(196).toString(),"gkw_zasm21.weapon"},
    {modded_key(196,2104).toString(),"gkw_zasm21_2104.weapon"},

    {modded_key(197).toString(),"gkw_carcano1891.weapon"},

    {modded_key(198).toString(),"gkw_carcano1938.weapon"},

    {modded_key(199).toString(),"gkw_type80.weapon"},
    {modded_key(199,0,"mod3").toString(),"gkw_type80mod3.weapon"},

    {modded_key(200).toString(),"gkw_xm3.weapon"},
    {modded_key(200,0,"mod3").toString(),"gkw_xm3mod3.weapon"},

    {modded_key(201).toString(),"gkw_gepardm1.weapon"},
    {modded_key(201,4006).toString(),"gkw_gepardm1_4006.weapon"},
    {modded_key(201,0,"mod3").toString(),"gkw_gepardm1mod3.weapon"},
    {modded_key(201,4006,"mod3").toString(),"gkw_gepardm1mod3_4006.weapon"},

    {modded_key(202).toString(),"gkw_thunder.weapon"},
    {modded_key(202,2206).toString(),"gkw_thunder_2206.weapon"},

    {modded_key(203).toString(),"gkw_honeybadger.weapon"},
    {modded_key(203,4005).toString(),"gkw_honeybadger_4005.weapon"},

    {modded_key(204).toString(),"gkw_ballista.weapon"},

    {modded_key(205).toString(),"gkw_an94.weapon"},
    {modded_key(205,3303).toString(),"gkw_an94_3303.weapon"},
    {modded_key(205,8606).toString(),"gkw_an94_blm.weapon"},
    {modded_key(205,0,"mod3").toString(),"gkw_an94_mod3.weapon"},
    {modded_key(205,3303,"mod3").toString(),"gkw_an94mod3_3303.weapon"},
    {modded_key(205,8606,"mod3").toString(),"gkw_an94mod3_blm.weapon"},

    {modded_key(206).toString(),"gkw_ak12.weapon"},
    {modded_key(206,2402).toString(),"gkw_ak12_2402.weapon"},
    {modded_key(206,8605).toString(),"gkw_ak12_blm.weapon"},

    {modded_key(208).toString(),"gkw_hk21.weapon"},
    {modded_key(208,4402).toString(),"gkw_hk21_4002.weapon"},

    {modded_key(211).toString(),"gkw_srs.weapon"},

    {modded_key(212).toString(),"gkw_k5.weapon"},
    {modded_key(212,0,"mod3").toString(),"gkw_k5mod3.weapon"},

    {modded_key(213).toString(),"gkw_cms.weapon"},
    {modded_key(213,6403).toString(),"gkw_cms_6403.weapon"},

    {modded_key(215).toString(),"gkw_mdr.weapon"},
    {modded_key(215,2603).toString(),"gkw_mdr_2603.weapon"},

    {modded_key(216).toString(),"gkw_xm8.weapon"},
    {modded_key(216,5606).toString(),"gkw_xm8_5606.weapon"},
    {modded_key(216,0,"mod3").toString(),"gkw_xm8_mod3.weapon"},
    {modded_key(216,5606,"mod3").toString(),"gkw_xm8mod3_5606.weapon"},

    {modded_key(220).toString(),"gkw_mp443.weapon"},
    {modded_key(220,0,"mod3").toString(),"gkw_mp443mod3.weapon"},

    {modded_key(221).toString(),"gkw_gsh18.weapon"},
    {modded_key(221,523).toString(),"gkw_gsh18_523.weapon"},
    {modded_key(221,0,"mod3").toString(),"gkw_gsh18mod3.weapon"},
    {modded_key(221,523,"mod3").toString(),"gkw_gsh18mod3_523.weapon"},

    {modded_key(222).toString(),"gkw_tac50.weapon"},
    {modded_key(222,2602).toString(),"gkw_tac50_2602.weapon"},
    {modded_key(222,0,"only").toString(),"gkw_tac50_only_ap.weapon"},
    
    {modded_key(224).toString(),"gkw_pm06.weapon"},

    {modded_key(225,6606).toString(),"gkw_cx4_6606.weapon"},

    {modded_key(227).toString(),"gkw_a91.weapon"},
    {modded_key(227,4403).toString(),"gkw_a91_4403.weapon"},

    {modded_key(228).toString(),"gkw_type100.weapon"},
    {modded_key(228,4004).toString(),"gkw_type100_4004.weapon"},
    {modded_key(228,0,"mod3").toString(),"gkw_type100mod3.weapon"},
    {modded_key(228,4004,"mod3").toString(),"gkw_type100mod3_4004.weapon"},

    {modded_key(229).toString(),"gkw_m870.weapon"},
    {modded_key(229,3803).toString(),"gkw_m870_3803.weapon"},

    {modded_key(230).toString(),"gkw_obr.weapon"},
    {modded_key(230,0,"mod3").toString(),"gkw_obrmod3.weapon"},

    {modded_key(231).toString(),"gkw_m82a1.weapon"},

    {modded_key(233,2801).toString(),"gkw_px4_2801.weapon"},

    {modded_key(234).toString(),"gkw_js9.weapon"},
    {modded_key(234,4702).toString(),"gkw_js9_4702.weapon"},

    {modded_key(236).toString(),"gkw_k11_ar.weapon"},

    {modded_key(238).toString(),"gkw_qjy88.weapon"},

    {modded_key(240).toString(),"gkw_mk46.weapon"},

    {modded_key(242).toString(),"gkw_p22.weapon"},

    {modded_key(245).toString(),"gkw_p90.weapon"},
    {modded_key(245,2802).toString(),"gkw_p90_2802.weapon"},
    {modded_key(245,5701).toString(),"gkw_p90_5701.weapon"},

    {modded_key(246).toString(),"gkw_k31.weapon"},

    {modded_key(248).toString(),"gkw_Jericho.weapon"},

    {modded_key(250).toString(),"gkw_hs2000.weapon"},
    {modded_key(250,5304).toString(),"gkw_hs2000_5304.weapon"},

    {modded_key(251).toString(),"gkw_x95.weapon"},

    {modded_key(252).toString(),"gkw_ksvk.weapon"},
    {modded_key(252,3405).toString(),"gkw_ksvk_3405.weapon"},
    {modded_key(252,3805).toString(),"gkw_ksvk_3805.weapon"},
    {modded_key(252,4509).toString(),"gkw_ksvk_4509.weapon"},
    {modded_key(252,5504).toString(),"gkw_ksvk_5504.weapon"},
    {modded_key(252,7807).toString(),"gkw_ksvk_7807.weapon"},
    {modded_key(252,0,"mod3").toString(),"gkw_ksvkmod3.weapon"},
    {modded_key(252,3405,"mod3").toString(),"gkw_ksvkmod3_3405.weapon"},
    {modded_key(252,3805,"mod3").toString(),"gkw_ksvkmod3_3805.weapon"},
    {modded_key(252,4509,"mod3").toString(),"gkw_ksvkmod3_4509.weapon"},
    {modded_key(252,5504,"mod3").toString(),"gkw_ksvkmod3_5504.weapon"},
    {modded_key(252,7807,"mod3").toString(),"gkw_ksvkmod3_7807.weapon"},

    {modded_key(253).toString(),"gkw_lewis.weapon"},
    {modded_key(253,4001).toString(),"gkw_lewis_4001.weapon"},
    {modded_key(253,5501).toString(),"gkw_lewis_5501.weapon"},

    {modded_key(254).toString(),"gkw_ukm2000.weapon"},
    {modded_key(254,6106).toString(),"gkw_ukm2000_6106.weapon"},

    // {modded_key(256).toString(),"gkw_op99.weapon"},

    {modded_key(257).toString(),"gkw_m200.weapon"},
    {modded_key(257,560).toString(),"gkw_m200_560.weapon"},
    {modded_key(257,4502).toString(),"gkw_m200_4502.weapon"},

    {modded_key(260).toString(),"gkw_pa15.weapon"},
    {modded_key(260,3701).toString(),"gkw_pa15_3701.weapon"},
    {modded_key(260,4202).toString(),"gkw_pa15_4202.weapon"},
    {modded_key(260,4402).toString(),"gkw_pa15_4402.weapon"},
    {modded_key(260,5802).toString(),"gkw_pa15_5802.weapon"},

    {modded_key(261).toString(),"gkw_qbu88.weapon"},
    {modded_key(261,5502).toString(),"gkw_qbu88_5502.weapon"},

    {modded_key(263).toString(),"gkw_mg36.weapon"},
    {modded_key(263,4205).toString(),"gkw_mg36_4205.weapon"},
    {modded_key(263,4903).toString(),"gkw_mg36_4903.weapon"},

    {modded_key(264).toString(),"gkw_chauchat.weapon"},

    {modded_key(265).toString(),"gkw_hk33.weapon"},

    // {modded_key(268).toString(),"gkw_tcms.weapon"},

    {modded_key(269).toString(),"gkw_p30.weapon"},

    {modded_key(270).toString(),"gkw_4type.weapon"},
    {modded_key(270,0,"only").toString(),"gkw_4type_only.weapon"},

    {modded_key(272).toString(),"gkw_desert_eagle.weapon"},
    {modded_key(272,6501).toString(),"gkw_desert_eagle_6501.weapon"},

    {modded_key(274).toString(),"gkw_acr.weapon"},

    {modded_key(276).toString(),"gkw_kord.weapon"},
    {modded_key(276,5102).toString(),"gkw_kord_5102.weapon"},

    {modded_key(281).toString(),"gkw_caws.weapon"},

    {modded_key(282).toString(),"gkw_dp12.weapon"},
    {modded_key(282,4201).toString(),"gkw_dp12_4201.weapon"},
    {modded_key(282,0,"mod3").toString(),"gkw_dp12mod3.weapon"},
    {modded_key(282,4201,"mod3").toString(),"gkw_dp12mod3_4201.weapon"},

    {modded_key(283).toString(),"gkw_liberator.weapon"},

    {modded_key(285).toString(),"gkw_c93.weapon"},

    {modded_key(287).toString(),"gkw_sig556.weapon"},

    {modded_key(289).toString(),"gkw_r5.weapon"},
    {modded_key(289,5302).toString(),"gkw_r5_5302.weapon"},

    {modded_key(290).toString(),"gkw_type89.weapon"},
    {modded_key(290,6601).toString(),"gkw_type89_6601.weapon"},

    {modded_key(292).toString(),"gkw_rpk16.weapon"},
    {modded_key(292,8608).toString(),"gkw_rpk16_blm.weapon"},

    {modded_key(293).toString(),"gkw_ak15.weapon"},
    {modded_key(293,0,"mod3").toString(),"gkw_ak15mod3.weapon"},
    {modded_key(293,8607).toString(),"gkw_ak15_blm.weapon"},
    {modded_key(293,8607,"mod3").toString(),"gkw_ak15mod3_blm.weapon"},

    {modded_key(294).toString(),"gkw_webley.weapon"},
    {modded_key(294,5601).toString(),"gkw_webley_5601.weapon"},

    {modded_key(296).toString(),"gkw_sl8.weapon"},

    {modded_key(302).toString(),"gkw_defender.weapon"},
    {modded_key(302,5505).toString(),"gkw_defender_5505.weapon"},

    {modded_key(303).toString(),"gkw_hp35.weapon"},

    {modded_key(304).toString(),"gkw_saf.weapon"},
    {modded_key(304,6607).toString(),"gkw_saf_6607.weapon"},

    {modded_key(306).toString(),"gkw_akalfa.weapon"},

    {modded_key(307).toString(),"gkw_zb26.weapon"},
    {modded_key(307,5603).toString(),"gkw_zb26_5603.weapon"},

    {modded_key(308).toString(),"gkw_c14.weapon"},

    {modded_key(311,7802).toString(),"gkw_lusa_7802.weapon"},

    {modded_key(312).toString(),"gkw_vsk94.weapon"},
    {modded_key(312,5301).toString(),"gkw_vsk94_5301.weapon"},

    {modded_key(313).toString(),"gkw_sacr.weapon"},
    {modded_key(313,5303).toString(),"gkw_sacr_5303.weapon"},

    {modded_key(315).toString(),"gkw_augpara.weapon"},
    {modded_key(315,5503).toString(),"gkw_augpara_5503.weapon"},

    {modded_key(316).toString(),"gkw_liu.weapon"},
    {modded_key(316,5101).toString(),"gkw_liu_5101.weapon"},

    {modded_key(317).toString(),"gkw_m1908.weapon"},

    {modded_key(318).toString(),"gkw_vhs.weapon"},

    {modded_key(319).toString(),"gkw_pm1910.weapon"},
    {modded_key(310,5307).toString(),"gkw_pm1910_5307.weapon"},

    {modded_key(320).toString(),"gkw_gm6.weapon"},

    {modded_key(322).toString(),"gkw_qsb91.weapon"},

    {modded_key(323).toString(),"gkw_ltlx7000.weapon"},
    {modded_key(323,6101).toString(),"gkw_ltlx7000_6101.weapon"},
    {modded_key(323,6702).toString(),"gkw_ltlx7000_6702.weapon"},

    {modded_key(324).toString(),"gkw_m6asw.weapon"},

    {modded_key(328).toString(),"gkw_ar57.weapon"},

    {modded_key(329).toString(),"gkw_svch.weapon"},

    {modded_key(330).toString(),"gkw_fx05.weapon"},

    {modded_key(331).toString(),"gkw_kolibri.weapon"},
    {modded_key(331,6802).toString(),"gkw_kolibri_6802.weapon"},

    {modded_key(333).toString(),"gkw_vp1915.weapon"},
    {modded_key(333,6604).toString(),"gkw_vp1915_6604.weapon"},
    {modded_key(333,8505).toString(),"gkw_vp1915_8505.weapon"},

    {modded_key(334).toString(),"gkw_savage99.weapon"},

    {modded_key(337).toString(),"gkw_delisle.weapon"},
    {modded_key(337,6202).toString(),"gkw_delisle_6202.weapon"},
    {modded_key(337,7801).toString(),"gkw_delisle_7801.weapon"},

    {modded_key(338).toString(),"gkw_sigmcx.weapon"},
    {modded_key(338,8203).toString(),"gkw_sigmcx_8203.weapon"},

    {modded_key(339).toString(),"gkw_rpk203.weapon"},

    {modded_key(340).toString(),"gkw_tkb408.weapon"},
    {modded_key(340,6804).toString(),"gkw_tkb408_6804.weapon"},

    {modded_key(341).toString(),"gkw_sp9.weapon"},
    {modded_key(341,6303).toString(),"gkw_sp9_6303.weapon"},

    {modded_key(343).toString(),"gkw_apc556.weapon"},
    {modded_key(343,8007).toString(),"gkw_apc556_8007.weapon"},

    {modded_key(344).toString(),"gkw_fara83.weapon"},

    {modded_key(345).toString(),"gkw_mg338.weapon"},

    {modded_key(346).toString(),"gkw_cz100.weapon"},

    {modded_key(348).toString(),"gkw_hs50.weapon"},
    {modded_key(348,6805).toString(),"gkw_hs50_6805.weapon"},
    
    {modded_key(349).toString(),"gkw_ak74m.weapon"},
    {modded_key(349,7305).toString(),"gkw_ak74m_7305.weapon"},

    {modded_key(350).toString(),"gkw_fo12.weapon"},

    {modded_key(352).toString(),"gkw_nova.weapon"},

    {modded_key(356).toString(),"gkw_a545.weapon"},
    {modded_key(356,6803).toString(),"gkw_a545_6803.weapon"},

    {modded_key(359).toString(),"gkw_sterling.weapon"},

    {modded_key(361).toString(),"gkw_qbz191.weapon"},
    {modded_key(361,7702).toString(),"gkw_qbz191_7702.weapon"},

    {modded_key(363).toString(),"gkw_mpl.weapon"},

    {modded_key(364).toString(),"gkw_mpk.weapon"},

    {modded_key(366).toString(),"gkw_spas15.weapon"},

    {modded_key(367).toString(),"gkw_mk3a1.weapon"},
    {modded_key(367,30007).toString(),"gkw_mk3a1_30007.weapon"},

    {modded_key(368).toString(),"gkw_uts15.weapon"},

    {modded_key(369).toString(),"gkw_m327.weapon"},

    {modded_key(372).toString(),"gkw_ar18.weapon"},
    {modded_key(372,8504).toString(),"gkw_ar18_8504.weapon"},

    {modded_key(374).toString(),"gkw_m240l.weapon"},

    {modded_key(376).toString(),"gkw_emp35.weapon"},
    {modded_key(376,8003).toString(),"gkw_emp35_8003.weapon"},

    {modded_key(377).toString(),"gkw_scarh.weapon"},
    {modded_key(377,0,"only").toString(),"gkw_scarh_only.weapon"},

    {modded_key(378).toString(),"gkw_scarl.weapon"},
    {modded_key(378,0,"only").toString(),"gkw_scarl_only.weapon"},

    {modded_key(381).toString(),"gkw_m110.weapon"},
    {modded_key(382).toString(),"gkw_msbs.weapon"},

    {modded_key(386).toString(),"gkw_lamg.weapon"},
    {modded_key(386,8505).toString(),"gkw_lamg_8505.weapon"},

    {modded_key(387).toString(),"gkw_tps.weapon"},
    {modded_key(389).toString(),"gkw_boys.weapon"},
    {modded_key(391).toString(),"gkw_type82.weapon"},
    {modded_key(392).toString(),"gkw_owen.weapon"},

    {modded_key(393).toString(),"gkw_beowulf.weapon"},
    {modded_key(394).toString(),"gkw_cm901.weapon"},

    {"-1",""}
};

dictionary reverse_tdoll_complex_index = {};
dictionary tdoll_name_dict = {};
array<girls_information@> all_girls_information = {};

string getKeyfromIndex(string girl_index, string skin_index = "0", string mode="none") {
    string key = girl_index + "-skin_" + skin_index + "-mod_" + mode;
    if (key!=""){
        string output_key = string(tdoll_complex_index[key]);
        if(output_key!=""){
            return output_key;
        }
        return "";
    } 
    return "";
}

void reverse_tdoll_index_dict_init()
{
    array<string> all_key = tdoll_complex_index.getKeys();
    for (uint i=0;i < all_key.length();i++)
    {
        string value = all_key[i];
        string key = string(tdoll_complex_index[value]);
        if (reverse_tdoll_complex_index.exists(key))
        {
            _log("写重复了" + key +" 值 " + value);
        }
        reverse_tdoll_complex_index.set(key,value);
    }
    _log("初始化图鉴词典成功");
    _log("词典正向有" + tdoll_complex_index.getSize() + "个键值对" );
    _log("词典反向有" + reverse_tdoll_complex_index.getSize() + "个键值对" );
}

class girls_information
{
    int girl_index = 0;
    int skin_index = -1;
    string mode = "";
    string name = "";
    string weapon_key = "";

    girls_information(int _girl_index,int _skin_index,string _mode,string _name,string _weapon_key )
    {
        girl_index = _girl_index;
        skin_index = _skin_index;
        mode = _mode;
        name = _name;
        weapon_key = _weapon_key;        
    }

    girls_information(){}

    void SetGirlIndex(int _girl_index)
    {
        girl_index = _girl_index;
    }

    void SetSkinIndex(int _skin_index)
    {
        skin_index = _skin_index;
    }

    void SetMode(const string _mode)
    {
        mode = _mode;
    }

    void SetName(const string _name)
    {
        name = _name;
    }

    void SetWeaponKey(const string _weapon_key)
    {
        weapon_key = _weapon_key;
    }    

    bool isAllowed()
    {
        if(girl_index <=0) return false;
        if(skin_index < 0) return false;
        if(mode == "") return false;
        if(name == "") return false;
        if(weapon_key == "") return false;
        return true;
    }
}


girls_information ParseGFLString(const string input,const string key,const string name)
{
    
    int firstNumber = 0;
    int secondNumber = -1;
    string modString = "";
    int firstDash = -1;
    int secondDash = -1;

    // 查找第一个 "-"
    firstDash = input.findFirst("-");

    if (firstDash != -1)
    {
        // 提取第一个数字
        string firstPart = input.substr(0, firstDash);
        firstNumber = parseInt(firstPart); // 使用parseInt

        // 剩余部分
        string remaining = input.substr(firstDash + 1);

        // 查找第二个 "-"
        secondDash = remaining.findFirst("-");
        if (secondDash != -1)
        {
            // 提取第二个数字
            string secondPart = remaining.substr(0, secondDash);
            secondPart = secondPart.substr(5);
            _log("第二部分: " + secondPart);
            secondNumber = parseInt(secondPart); // 使用parseInt

            // 提取mod字符串
            modString = remaining.substr(secondDash + 5);
        }
    }

    // 打印提取的结果
    // _log("第一个数字: " + firstNumber);
    // _log("第二个数字: " + secondNumber);
    // _log("mod字符串: " + modString);

    girls_information info = girls_information(firstNumber,secondNumber,modString,name,key);
    return info;
}

array<girls_information@> findGFLIndex(int index)
{
    array<girls_information@> resultArray;
    for (uint i = 0; i < all_girls_information.length(); i++)
    {
        if (all_girls_information[i].girl_index == index)
        {
            resultArray.insertLast(all_girls_information[i]);
        }
    }
    return resultArray;
}

string getNamefromDict(string key)
{
    string output = string(tdoll_name_dict[key]);
    return output;
}

bool existKeyinDataSet(string key)
{
    for (uint i = 0; i < all_girls_information.length(); i++)
    {
        if (all_girls_information[i].weapon_key == key)
        {
            return true;
        }
    }    
    return false;
}