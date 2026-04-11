// M14MOD3 火力专注 技能 Tracker
// 集中管理 M14MOD3 技能的所有状态和事件处理
// 重构自 commandskill.as（全局状态）、kill_event.as（连锁射击、死亡清理）

// 全局引用，供 GFLtask.as 中的 M14SkillEndTask 和 commandskill.as 中的 excuteM14MOD3Skill 使用
M14SkillTracker@ g_m14Tracker = null;

// M14MOD3 待添加冷却队列项
class M14PendingCooldown {
    int m_characterId;
    float m_cooldownTime;
    SkillModifer@ m_modifer;
    M14PendingCooldown(int cId, float cd, SkillModifer@ mod) {
        m_characterId = cId;
        m_cooldownTime = cd;
        @m_modifer = @mod;
    }
}

class M14SkillTracker : Tracker {
    protected GameMode@ m_metagame;

    array<M14SkillActiveTask@> m14_active_tasks;
    array<int> m14_rocket_reward_players;
    array<M14PendingCooldown@> m14_pending_cooldowns;

    M14SkillTracker(GameMode@ metagame) {
        @m_metagame = metagame;
        @g_m14Tracker = @this;
        metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");
    }

    // 激活 M14MOD3 技能，创建 Task 并注册状态
    void activate(int characterId, int playerId, int factionId, SkillModifer@ modifer) {
        M14SkillActiveTask@ activeTask = M14SkillActiveTask(
            m_metagame, 30.0, characterId, playerId, factionId, modifer);
        m14_active_tasks.insertLast(activeTask);
        TaskSequencer@ tasker = m_metagame.getTaskManager().newTaskSequencer();
        tasker.add(activeTask);
        tasker.add(M14SkillEndTask(m_metagame, activeTask, modifer));
    }

    // 是否已有激活状态（防重复激活）
    bool isActive(int characterId) {
        for (uint i = 0; i < m14_active_tasks.length(); i++) {
            if (m14_active_tasks[i].m_characterId == characterId) return true;
        }
        return false;
    }

    // 检查玩家是否有火箭弹奖励
    bool hasRocketReward(int playerId) {
        return m14_rocket_reward_players.find(playerId) >= 0;
    }

    // 消费火箭弹奖励
    void consumeRocketReward(int playerId) {
        int idx = m14_rocket_reward_players.find(playerId);
        if (idx >= 0) m14_rocket_reward_players.removeAt(idx);
    }

    // M14MOD3 火力专注 - 连锁射击（从 kill_event.as 移入）
    protected void handleCharacterKillEvent(const XmlElement@ event) {
        const XmlElement@ killer = event.getFirstElementByTagName("killer");
        if (killer is null) return;
        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target is null) return;
        if (killer.getIntAttribute("faction_id") == target.getIntAttribute("faction_id")) return;

        int characterId = killer.getIntAttribute("id");
        int factionId = killer.getIntAttribute("faction_id");
        int targetId = target.getIntAttribute("id");
        string dead_pos = target.getStringAttribute("position");
        string KillerWeaponKey = event.getStringAttribute("key");
        string killway = event.getStringAttribute("method_hint");

        if ((KillerWeaponKey == "gkw_m14mod3.weapon"
            || KillerWeaponKey == "gkw_m14mod3_skill.weapon"
            || KillerWeaponKey == "gkw_m14mod3_303.weapon"
            || KillerWeaponKey == "gkw_m14mod3_303_skill.weapon")
            && killway == "hit")
        {
            for (uint m = 0; m < m14_active_tasks.length(); m++) {
                if (m14_active_tasks[m].m_characterId == characterId
                    && m14_active_tasks[m].m_ammo > 0) {
                    // 搜索被击杀目标附近的敌人
                    Vector3 dead_position = stringToVector3(dead_pos);
                    int m_fnum = m_metagame.getFactionCount();
                    array<const XmlElement@> nearbyEnemies;
                    for (int f = 0; f < m_fnum; f++) {
                        if (f != factionId) {
                            array<const XmlElement@> found =
                                getCharactersNearPosition(m_metagame,
                                    dead_position, f, 8.0f);
                            if (found !is null) {
                                for (uint x = 0; x < found.length(); x++) {
                                    nearbyEnemies.insertLast(found[x]);
                                }
                            }
                        }
                    }
                    // 找最近的敌人（排除被击杀目标自身）
                    if (nearbyEnemies.length() > 0) {
                        int closestIdx = -1;
                        float closestDist = -1.0;
                        for (uint n = 0; n < nearbyEnemies.length(); n++) {
                            if (nearbyEnemies[n].getIntAttribute("id") == targetId)
                                continue;
                            float d = getPositionDistance(dead_position,
                                stringToVector3(
                                    nearbyEnemies[n].getStringAttribute("position")));
                            if (d < closestDist || closestDist < 0.0) {
                                closestDist = d;
                                closestIdx = n;
                            }
                        }
                        if (closestIdx >= 0) {
                            int chain_target =
                                nearbyEnemies[closestIdx].getIntAttribute("id");
                            string shooter_pos = killer.getStringAttribute("position");
                            // 发射连锁狙击弹
                            TaskSequencer@ chain =
                                m_metagame.getTaskManager().newTaskSequencer();
                            DelayAntiPersonSnipeRequest@ shot =
                                DelayAntiPersonSnipeRequest(m_metagame, 0.15,
                                    characterId, factionId,
                                    "snipe_hit_m14mod3.projectile",
                                    stringToVector3(shooter_pos).add(Vector3(0, 0.5, 0)),
                                    chain_target);
                            chain.add(shot);
                        }
                    }
                    // 消耗弹药并提示
                    m14_active_tasks[m].consumeAmmo();
                    dictionary ammo_a;
                    ammo_a["%num"] = "" + m14_active_tasks[m].m_ammo;
                    notify(m_metagame, "Skill - M14 Ammo", ammo_a,
                           "misc", m14_active_tasks[m].m_playerId,
                           false, "", 1.0);
                    break;
                }
            }
        }
    }

    // M14MOD3 技能死亡清理（从 kill_event.as 移入）
    protected void handlePlayerDieEvent(const XmlElement@ event) {
        const XmlElement@ player = event.getFirstElementByTagName("target");
        if (player is null) return;
        int cId = player.getIntAttribute("character_id");
        if (cId == -1) return;

        for (int i = m14_active_tasks.length() - 1; i >= 0; i--) {
            if (m14_active_tasks[i].m_characterId == cId) {
                m14_active_tasks[i].m_ended = true;
                break;
            }
        }
    }

    // 处理待添加冷却队列（从 commandskill.as update() 移入）
    void update(float time) {
        for (int a = m14_pending_cooldowns.length() - 1; a >= 0; a--) {
            float cdr = m14_pending_cooldowns[a].m_modifer.m_cdr;
            float cdm = m14_pending_cooldowns[a].m_modifer.m_cdm;
            SkillTrigger@ cooldown = SkillTrigger(
                m14_pending_cooldowns[a].m_characterId,
                max(m14_pending_cooldowns[a].m_cooldownTime * cdr - cdm, 0.1),
                "M14MOD3");
            cooldown.setSkillInfo(m14_pending_cooldowns[a].m_modifer);
            SkillArray.insertLast(cooldown);
            m14_pending_cooldowns.removeAt(a);
        }
    }
}
