#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"

// Javelin 鎖定鏈路專用 Tracker
// 副手武器的輸入鏈路與主武器技能不同，因此保留為獨立模塊，不強行抽象進通用 RepeatEffectTask

JavelinTracker@ g_javelinTracker = null;

class JavelinState {
    int m_characterId;
    int m_factionid;
    int m_vehicleid;
    Vector3 m_pos;
    float m_timeLeft = 6.0;

    JavelinState(int characterId, int factionid, int vehicleid, Vector3 pos) {
        m_characterId = characterId;
        m_factionid = factionid;
        m_vehicleid = vehicleid;
        m_pos = pos;
    }
}

class JavelinTracker : Tracker {
    protected GameMode@ m_metagame;
    protected array<JavelinState@> m_states;

    JavelinTracker(GameMode@ metagame) {
        @m_metagame = @metagame;
        @g_javelinTracker = @this;
    }

    void beginLockForAi(const XmlElement@ event) {
        int characterId = event.getIntAttribute("character_id");
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) {
            return;
        }

        int factionid = character.getIntAttribute("faction_id");
        Vector3 target_pos = stringToVector3(event.getStringAttribute("position"));
        int vehicleid = getNearByEnemyVehicle(m_metagame, factionid, target_pos, 7);
        Vector3 aimer_pos = stringToVector3(character.getStringAttribute("position"));

        Vector3 pos1 = getAimUnitPosition(aimer_pos, target_pos, 1);
        Vector3 pos2 = getAimUnitPosition(aimer_pos, target_pos, 8.0);
        pos1 = pos1.add(Vector3(0, 0.8, 0));
        pos2 = pos2.add(Vector3(0, 8, 0));
        CreateProjectile(m_metagame, pos1, pos2, "javelin_rocket_1.projectile", characterId, factionid, 5, 6);

        m_states.insertLast(JavelinState(characterId, factionid, vehicleid, target_pos));
    }

    void beginLockForPlayer(const XmlElement@ event) {
        int characterId = event.getIntAttribute("character_id");
        int playerId = event.getIntAttribute("player_id");
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) {
            return;
        }

        const XmlElement@ player = getPlayerInfo(m_metagame, playerId);
        Vector3 target_pos;
        int factionid = character.getIntAttribute("faction_id");

        if (player !is null && player.hasAttribute("aim_target")) {
            target_pos = stringToVector3(player.getStringAttribute("aim_target"));
        } else {
            target_pos = stringToVector3(event.getStringAttribute("position"));
        }

        int vehicleid = getNearByEnemyVehicle(m_metagame, factionid, target_pos, 7);
        Vector3 aimer_pos = stringToVector3(character.getStringAttribute("position"));
        if (vehicleid != -1) {
            playSoundAtLocation(m_metagame, "javelin_locked.wav", factionid, aimer_pos, 1.0);
        } else {
            playSoundAtLocation(m_metagame, "javelin_lock_fail.wav", factionid, aimer_pos, 1.0);
        }

        Vector3 pos1 = getAimUnitPosition(aimer_pos, target_pos, 1);
        Vector3 pos2 = getAimUnitPosition(aimer_pos, target_pos, 8.0);
        pos1 = pos1.add(Vector3(0, 0.8, 0));
        pos2 = pos2.add(Vector3(0, 8, 0));
        CreateProjectile(m_metagame, pos1, pos2, "javelin_rocket_1.projectile", characterId, factionid, 5, 6);

        m_states.insertLast(JavelinState(characterId, factionid, vehicleid, target_pos));
    }

    void handleUprise(const XmlElement@ event) {
        _log("javelin_uprise");
        int characterId = event.getIntAttribute("character_id");
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) {
            return;
        }

        int factionid = character.getIntAttribute("faction_id");
        Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));
        JavelinState@ state = getState(characterId, factionid);
        if (state is null) {
            return;
        }

        _log("javelin_uprise success");
        Vector3 target_pos = resolveTargetPosition(state, "aimming 1 success.");
        CreateProjectile(m_metagame, aimer_pos, target_pos, "javelin_rocket_2.projectile", characterId, factionid, getAimUnitDistance(0.4, aimer_pos, target_pos), -20);
    }

    void handleStrike(const XmlElement@ event) {
        _log("javelin_strike");
        int characterId = event.getIntAttribute("character_id");
        const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
        if (character is null) {
            return;
        }

        int factionid = character.getIntAttribute("faction_id");
        Vector3 aimer_pos = stringToVector3(event.getStringAttribute("position"));
        int idx = getStateIndex(characterId, factionid);
        if (idx < 0) {
            return;
        }

        _log("javelin_locate_aimer success");
        Vector3 target_fin_pos = resolveTargetPosition(m_states[idx], "aimming 2 success.");
        CreateDirectProjectile(m_metagame, aimer_pos, target_fin_pos, "javelin_rocket_3.projectile", characterId, factionid, 180);
        m_states.removeAt(idx);
    }

    void update(float time) {
        for (int i = m_states.length() - 1; i >= 0; i--) {
            m_states[i].m_timeLeft -= time;
            if (m_states[i].m_timeLeft < 0) {
                m_states.removeAt(i);
            }
        }
    }

    bool hasEnded() const {
        return false;
    }

    bool hasStarted() const {
        return true;
    }

    protected int getStateIndex(int characterId, int factionid) {
        for (uint i = 0; i < m_states.length(); i++) {
            if (m_states[i].m_characterId == characterId && m_states[i].m_factionid == factionid) {
                return i;
            }
        }
        return -1;
    }

    protected JavelinState@ getState(int characterId, int factionid) {
        int idx = getStateIndex(characterId, factionid);
        if (idx < 0) {
            return null;
        }
        return m_states[idx];
    }

    protected Vector3 resolveTargetPosition(JavelinState@ state, const string successLog) {
        if (state.m_vehicleid != -1) {
            _log(successLog);
            const XmlElement@ target_info = getVehicleInfo(m_metagame, state.m_vehicleid);
            if (target_info !is null) {
                return stringToVector3(target_info.getStringAttribute("position"));
            }
        }
        return state.m_pos;
    }
}
