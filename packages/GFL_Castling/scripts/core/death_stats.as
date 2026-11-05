// ------------------------------------------------------------------------------------------------
// Per-faction death statistics.
//
// This is a small, self-contained service:
//   - DeathStatsTracker listens to the engine's character_die event.
//   - Every death of every faction is counted once.
//   - Other systems can read the counters through the global functions without
//     doing any XML query.
//
// character_kill is intentionally not used here. kill_event.as keeps handling
// character_kill for its on-kill behaviour; character_die is the complete death
// event (it also covers deaths without a killer).
// ------------------------------------------------------------------------------------------------

#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "gamemode.as"

// --------------------------------------------
array<int> g_factionDeaths;

// --------------------------------------------
void resetFactionDeaths(int factionCount) {
    if (factionCount < 0) {
        factionCount = 0;
    }
    g_factionDeaths.resize(factionCount);
    for (uint i = 0; i < g_factionDeaths.size(); ++i) {
        g_factionDeaths[i] = 0;
    }
}

// --------------------------------------------
void registerFactionDeath(int factionId) {
    if (factionId < 0 || factionId >= int(g_factionDeaths.size())) {
        return;
    }
    g_factionDeaths[factionId] += 1;
}

// --------------------------------------------
int getFactionDeathCount(int factionId) {
    if (factionId < 0 || factionId >= int(g_factionDeaths.size())) {
        return 0;
    }
    return g_factionDeaths[factionId];
}

// --------------------------------------------
int getTotalDeathCount() {
    int total = 0;
    for (uint i = 0; i < g_factionDeaths.size(); ++i) {
        total += g_factionDeaths[i];
    }
    return total;
}

// ------------------------------------------------------------------------------------------------
// Global tracker that owns the character_die subscription.
//
// It is added once by GameModeInvasion. The per-match reset is done from the
// gamemode's preBeginMatch (and also defensively from start()).
// ------------------------------------------------------------------------------------------------
class DeathStatsTracker : Tracker {
    protected GameMode@ m_metagame;
    protected bool m_started;
    protected bool m_missingLogged;

    // --------------------------------------------
    DeathStatsTracker(GameMode@ metagame) {
        @m_metagame = @metagame;
        m_started = false;
        m_missingLogged = false;
    }

    // --------------------------------------------
    void start() {
        if (m_started) {
            return;
        }
        m_started = true;
        m_missingLogged = false;

        resetFactionDeaths(m_metagame.getFactionCount());

        // character_die is not delivered by default.
        m_metagame.getComms().send(
            "<command class='set_metagame_event' name='character_die' enabled='1' />");
        _log("DeathStatsTracker started, character_die enabled", 1);
    }

    // --------------------------------------------
    bool hasStarted() const {
        return m_started;
    }

    // --------------------------------------------
    protected int getDeathFactionId(const XmlElement@ event) {
        if (event.hasAttribute("faction_id")) {
            return event.getIntAttribute("faction_id");
        }

        const XmlElement@ character = event.getFirstElementByTagName("character");
        if (character !is null && character.hasAttribute("faction_id")) {
            return character.getIntAttribute("faction_id");
        }

        const XmlElement@ target = event.getFirstElementByTagName("target");
        if (target !is null && target.hasAttribute("faction_id")) {
            return target.getIntAttribute("faction_id");
        }

        return -1;
    }

    // --------------------------------------------
    protected void handleCharacterDieEvent(const XmlElement@ event) {
        int factionId = getDeathFactionId(event);
        if (factionId < 0) {
            if (!m_missingLogged) {
                _log("DeathStatsTracker, character_die event without faction id", -1);
                m_missingLogged = true;
            }
            return;
        }

        registerFactionDeath(factionId);
    }
}
