// ------------------------------------------------------------------------------------------------
// Breakthrough manpower (death budget).
//
// Manpower = how many more faction 0 deaths (AI + players) are allowed.
// It is completely independent from AI capacity and from the way deaths are
// counted: the global DeathStatsTracker / death_stats.as owns the counters and
// this tracker only reads them.
//
// Enabled per stage through Stage::m_enableBreakthroughManpower and added only
// for stages that opt in.
// ------------------------------------------------------------------------------------------------

#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"
#include "gamemode.as"
#include "death_stats.as"

const float BREAKTHROUGH_MANPOWER_DISPLAY_INTERVAL = 1.0;

// ------------------------------------------------------------------------------------------------
class BreakthroughManpower : Tracker {
    protected GameModeInvasion@ m_metagame;

    protected bool m_started;
    protected bool m_initialised;
    protected bool m_matchDecided;
    protected bool m_lostTriggered;

    protected int m_remaining;
    protected int m_max;
    protected int m_onlinePlayers;

    // last seen faction 0 death counter value, used to consume only the delta
    protected int m_lastDeathCount;

    protected bool m_displayDirty;
    protected float m_displayTimer;

    protected string m_color;

    // --------------------------------------------
    BreakthroughManpower(GameModeInvasion@ metagame) {
        @m_metagame = @metagame;
        m_started = false;
        m_initialised = false;
        m_matchDecided = false;
        m_lostTriggered = false;
        m_remaining = 0;
        m_max = 0;
        m_onlinePlayers = 0;
        m_lastDeathCount = 0;
        m_displayDirty = false;
        m_displayTimer = 0.0;
        m_color = "0.1 0.6 0.2 1";
    }

    // --------------------------------------------
    void start() {
        if (m_started) {
            return;
        }
        m_started = true;
        m_initialised = false;
        m_matchDecided = false;
        m_lostTriggered = false;
        m_displayDirty = false;
        m_displayTimer = 0.0;
        _log("BreakthroughManpower started, waiting for the first sector apply", 1);
    }

    // --------------------------------------------
    void gameContinuePreStart() {
        m_started = true;
        m_initialised = false;
        m_matchDecided = false;
        m_lostTriggered = false;
        m_displayDirty = false;
        m_displayTimer = 0.0;
        _log("BreakthroughManpower continued, waiting for the first sector apply", 1);
    }

    // --------------------------------------------
    // Called by PhaseControllerBreakthrough::applySector() on the first apply.
    // The player count is read here, at the same moment the sector/base
    // capturability is applied, instead of too early in start().
    void onMatchStart() {
        if (m_initialised) {
            return;
        }
        m_initialised = true;
        initialiseMatchState();
        _log("BreakthroughManpower initialised at sector apply, max=" + m_max +
             ", players=" + m_onlinePlayers, 1);
    }

    // --------------------------------------------
    bool hasStarted() const {
        return m_started;
    }

    // --------------------------------------------
    protected void initialiseMatchState() {
        m_matchDecided = false;
        m_lostTriggered = false;
        m_onlinePlayers = getPlayerCount(m_metagame);
        m_max = maxManpowerForPlayers(m_onlinePlayers);
        m_remaining = m_max;
        m_lastDeathCount = getFactionDeathCount(0);
        m_color = playerFactionColor();
        m_displayDirty = true;
        m_displayTimer = 0.0;

        clearDisplay();
        updateScoreDisplay();
        m_displayDirty = false;
    }

    // --------------------------------------------
    protected int maxManpowerForPlayers(int players) {
        if (players <= 1) {
            return 750;
        }
        if (players <= 2) {
            return 500;
        }
        if (players <= 3) {
            return 400;
        }
        if (players <= 5) {
            return 300;
        }
        return 250;
    }

    // --------------------------------------------
    protected void pollDeathDelta() {
        int current = getFactionDeathCount(0);
        if (current < m_lastDeathCount) {
            // counters were reset (new match); start a new baseline
            m_lastDeathCount = current;
            return;
        }

        int delta = current - m_lastDeathCount;
        if (delta <= 0) {
            return;
        }

        m_lastDeathCount = current;
        m_remaining -= delta;
        if (m_remaining < 0) {
            m_remaining = 0;
        }
        m_displayDirty = true;
    }

    // --------------------------------------------
    void update(float time) {
        if (!m_started || !m_initialised || m_matchDecided) {
            return;
        }

        pollDeathDelta();

        m_displayTimer -= time;
        if (m_displayTimer > 0.0) {
            return;
        }
        m_displayTimer = BREAKTHROUGH_MANPOWER_DISPLAY_INTERVAL;

        if (!m_displayDirty) {
            return;
        }

        updateScoreDisplay();
        m_displayDirty = false;

        // Loss is resolved together with the HUD refresh, after any sector
        // reinforcement has already been applied in onSectorCaptured().
        checkManpowerLoss();
    }

    // --------------------------------------------
    // Called by PhaseControllerBreakthrough::advance().
    // finalSector is true for the last sector: the match is won, never lost.
    void onSectorCaptured(bool finalSector) {
        if (!m_initialised || m_matchDecided) {
            return;
        }

        if (finalSector) {
            m_matchDecided = true;
            m_displayDirty = true;
            m_displayTimer = 0.0;
            return;
        }

        // account for deaths that happened before the sector was secured,
        // then apply the reinforcement before any loss decision
        pollDeathDelta();

        // Re-check the live player count on the server for every captured
        // sector. This is the authoritative count and avoids event drift.
        m_onlinePlayers = getPlayerCount(m_metagame);

        int newMax = maxManpowerForPlayers(m_onlinePlayers);
        int reinforce = newMax / 2;
        m_max = newMax;

        m_remaining += reinforce;
        if (m_remaining > m_max) {
            m_remaining = m_max;
        }
        if (m_remaining < 0) {
            m_remaining = 0;
        }

        _log("BreakthroughManpower sector refresh: players=" + m_onlinePlayers +
             ", max=" + m_max + ", reinforce=" + reinforce +
             ", remaining=" + m_remaining, 1);

        m_displayDirty = true;
        m_displayTimer = 0.0;
    }

    // --------------------------------------------
    protected void checkManpowerLoss() {
        if (m_matchDecided || m_lostTriggered) {
            return;
        }
        if (m_remaining > 0) {
            return;
        }

        m_lostTriggered = true;
        _log("BreakthroughManpower exhausted, faction 0 loses", 1);
        m_metagame.getComms().send(
            "<command class='set_match_status' lose='1' faction_id='0' />");
    }

    // --------------------------------------------
    protected string playerFactionColor() {
        const array<Faction@>@ factions = m_metagame.getFactions();
        if (factions.size() > 0 && factions[0] !is null) {
            return factions[0].m_config.m_color;
        }
        return "0.1 0.6 0.2 1";
    }

    // --------------------------------------------
    protected void updateScoreDisplay() {
        int shown = m_remaining;
        if (shown < 0) {
            shown = 0;
        }

        string value = shown + " / " + m_max;

        m_metagame.getComms().send(
            "<command class='update_score_display' id='0'" +
            " text='" + value + "'" +
            " color='" + m_color + "' />");
    }

    // --------------------------------------------
    protected void clearDisplay() {
        // the score display is a single shared widget; blank every faction slot
        // and the shared max label, like the minimodes start_match cleanup
        for (uint i = 0; i < m_metagame.getFactionCount(); ++i) {
            m_metagame.getComms().send(
                "<command class='update_score_display' id='" + int(i) + "' text='' />");
        }
        m_metagame.getComms().send(
            "<command class='update_score_display' max_text='' />");
    }

    // --------------------------------------------
    protected void handleMatchEndEvent(const XmlElement@ event) {
        m_matchDecided = true;
        clearDisplay();
    }

    // --------------------------------------------
    protected void handleChatEvent(const XmlElement@ event) {
        Tracker::handleChatEvent(event);

        string message = event.getStringAttribute("message");
        if (!startsWith(message, "/")) {
            return;
        }

        string sender = event.getStringAttribute("player_name");
        int senderId = event.getIntAttribute("player_id");
        if (!m_metagame.getAdminManager().isAdmin(sender, senderId)) {
            return;
        }

        if (checkCommand(message, "mandec")) {
            m_remaining -= 200;
            if (m_remaining < 0) {
                m_remaining = 0;
            }
            m_displayDirty = true;
            m_displayTimer = 0.0;
        }
    }

    // --------------------------------------------
    void onRemove() {
        m_started = false;
        m_initialised = false;
        clearDisplay();
    }
}
