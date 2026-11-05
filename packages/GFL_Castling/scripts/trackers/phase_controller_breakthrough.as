// internal
#include "tracker.as"
#include "log.as"
#include "helpers.as"
#include "query_helpers.as"
#include "phase_controller.as"
#include "gamemode_invasion.as"
#include "breakthrough_map_data.as"
#include "breakthrough_manpower.as"

// ------------------------------------------------------------------------------------------------
// Generic linear-sector breakthrough controller.
//
// For sector index i (0-based, current player base = R_i):
//   R_0..R_i      -> player owned, uncapturable
//   R_{i+1}       -> contested, capturable (owner left as-is, normally enemy)
//   R_{i+2}       -> enemy rear, uncapturable
//   all remaining -> neutral placeholder, uncapturable
//
// The phase advances when every base in R_{i+1} is owned by faction 0.
// The map-specific sector list is read from breakthrough_map_data.as; this file
// keeps the main flow and contains no map-specific sector data.
//
// Design contract: the sector list must cover every base and the final sector
// must leave the player owning all bases. The engine's win_with_all_bases=true
// then produces the match result. This controller deliberately does not send
// set_match_status win=1 (a second match_result would double-grant rewards).
// ------------------------------------------------------------------------------------------------

// Friendly AI capacity factors applied while the second-to-last and last sectors
// are contested. The values are modest reductions; the player keeps enough AI
// to assault the final objectives.
const float BREAKTHROUGH_FRIENDLY_AI_FACTOR_SECOND_LAST = 0.85;
const float BREAKTHROUGH_FRIENDLY_AI_FACTOR_LAST = 0.7;

class PhaseControllerBreakthrough : PhaseController {
    protected GameModeInvasion@ m_metagame;

    protected string m_mapId;
    protected string m_logTag;

    protected array<BreakthroughSector@> m_sectors;

    // optional per-stage manpower/death budget; null when the stage did not enable it
    protected BreakthroughManpower@ m_manpower;

    // index of the sector currently used as the player base
    protected int m_playerSector;

    protected bool m_started;
    protected bool m_completed;

    protected float m_checkTimer;

    // event batching: owner-change events only mark the contested sector dirty;
    // the actual base query happens once in update()
    protected bool m_checkPending;
    protected float m_checkDelay;

    // avoid spamming the log every safety poll if a base name cannot be resolved
    protected bool m_missingLogged;

    // --------------------------------------------
    PhaseControllerBreakthrough(GameModeInvasion@ metagame, string mapId, BreakthroughManpower@ manpower) {
        @m_metagame = @metagame;
        @m_manpower = @manpower;
        m_mapId = mapId;
        m_logTag = "PhaseControllerBreakthrough(" + mapId + ")";
        m_sectors = getBreakthroughSectors(mapId);
        if (m_sectors.size() == 0) {
            _log(m_logTag + ", no sector data for map id: " + mapId, -1);
        }

        m_playerSector = 0;
        m_started = false;
        m_completed = false;
        m_checkTimer = 0.0;
        m_checkPending = false;
        m_checkDelay = 0.0;
        m_missingLogged = false;
    }

    // --------------------------------------------
    void start() {
        m_started = true;
        m_completed = false;
        m_playerSector = 0;
        m_checkTimer = 1.0;
        m_checkPending = false;
        m_checkDelay = 0.0;
        m_missingLogged = false;

        applySector(false);
    }

    // --------------------------------------------
    void gameContinuePreStart() {
        m_started = true;
        m_checkTimer = 1.0;
        m_checkPending = false;
        m_checkDelay = 0.0;
        m_missingLogged = false;

        applySector(true);
    }

    // --------------------------------------------
    void onRemove() {
        m_started = false;
        m_checkPending = false;
        m_checkDelay = 0.0;
    }

    // --------------------------------------------
    bool hasStarted() const {
        return m_started;
    }

    // --------------------------------------------
    bool hasEnded() const {
        return m_completed;
    }

    // --------------------------------------------
    void update(float time) {
        if (m_completed) {
            return;
        }

        // owner-change events are batched; do at most one base query per batch
        if (m_checkPending) {
            m_checkDelay -= time;
            if (m_checkDelay <= 0.0) {
                m_checkPending = false;
                m_checkTimer = 5.0;
                checkAdvance();
            }
            return;
        }

        // low-frequency safety poll (capture events are the primary path)
        m_checkTimer -= time;
        if (m_checkTimer <= 0.0) {
            m_checkTimer = 5.0;
            checkAdvance();
        }
    }

    // --------------------------------------------
    protected void applySector(bool continuing) {
        int contested = m_playerSector + 1;
        int staging = m_playerSector + 2;

        for (uint i = 0; i < m_sectors.size(); ++i) {
            for (uint j = 0; j < m_sectors[i].m_bases.size(); ++j) {
                string key = m_sectors[i].m_bases[j];

                if (int(i) <= m_playerSector) {
                    // secured player area, including the current forward base
                    setBase(key, 0, 0);
                } else if (int(i) == contested) {
                    // contested sector: owner is intentionally left untouched
                    setCapturable(key, 1);
                } else if (int(i) == staging && staging < int(m_sectors.size())) {
                    // enemy rear, provides the next defensive line
                    setBase(key, 1, 0);
                } else {
                    // not opened yet: neutral placeholder
                    setBase(key, 2, 0);
                }
            }
        }

        sendCommanderAi();
        sendFriendlyCapacitySettings();

        m_checkPending = false;
        m_checkDelay = 0.0;
        m_missingLogged = false;

        string suffix = "";
        if (continuing) {
            suffix = " (continue)";
        }
        _log(m_logTag + ", sector " + (m_playerSector + 1) +
             " applied" + suffix, 1);
    }

    // --------------------------------------------
    protected void sendCommanderAi() {
        // player faction: attack, keep some AI at the secured rear bases
        m_metagame.getComms().send(
            "<command class='commander_ai' faction='0' base_defense='0.4' border_defense='0.2' " +
            "attack_start_spread='2' attack_target_spread='2' attack_target_base_key='' />");

        // enemy faction: hold the current line
        m_metagame.getComms().send(
            "<command class='commander_ai' faction='1' base_defense='0.5' border_defense='0.2' " +
            "attack_start_spread='0' attack_target_spread='0' />");

        // neutral faction: no commander, no movement
        m_metagame.getComms().send(
            "<command class='commander_ai' faction='2' active='0' />");
    }

    // --------------------------------------------
    protected void sendFriendlyCapacitySettings() {
        int count = int(m_sectors.size());
        float factor = 0.0;

        // m_playerSector is the current friendly base. When it is size-3, the
        // contested sector is the second-to-last one; when it is size-2, the
        // contested sector is the last one.
        if (m_playerSector == count - 3) {
            factor = BREAKTHROUGH_FRIENDLY_AI_FACTOR_SECOND_LAST;
        } else if (m_playerSector == count - 2) {
            factor = BREAKTHROUGH_FRIENDLY_AI_FACTOR_LAST;
        }

        if (factor <= 0.0) {
            return;
        }

        string command = "<command class='change_game_settings'>";
        for (uint i = 0; i < m_metagame.getFactions().size(); ++i) {
            Faction@ f = m_metagame.getFactions()[i];
            float multiplier = m_metagame.determineFinalFactionCapacityMultiplier(f, i);
            if (int(i) == 0) {
                multiplier *= factor;
            }
            command +=
                "<faction capacity_multiplier='" + multiplier +
                "' capacity_offset='" + f.m_capacityOffset + "' />";
        }
        command += "</command>";

        m_metagame.getComms().send(command);
        _log(m_logTag + ", friendly AI capacity factor: " + factor, 1);
    }

    // --------------------------------------------
    protected void announceSectorCaptured() {
        playSound(m_metagame, "objective_priority.wav", 0);
        sendFactionMessageKey(m_metagame, 0, "breakthrough_sector_captured", dictionary(), 2.0);
    }

    // --------------------------------------------
    protected void setBase(string key, int ownerId, int capturable) {
        m_metagame.getComms().send(
            "<command class='update_base' base_key='" + key + "' owner_id='" + ownerId + "' capturable='" + capturable + "' />");
    }

    // --------------------------------------------
    protected void setCapturable(string key, int capturable) {
        m_metagame.getComms().send(
            "<command class='update_base' base_key='" + key + "' capturable='" + capturable + "' />");
    }

    // --------------------------------------------
    protected bool allContestedOwned() {
        int contested = m_playerSector + 1;
        if (contested >= int(m_sectors.size())) {
            return false;
        }

        // one synchronous bases query per check; do not query per base
        array<const XmlElement@>@ bases = getBases(m_metagame);

        int owned = 0;
        for (uint j = 0; j < m_sectors[contested].m_bases.size(); ++j) {
            string key = m_sectors[contested].m_bases[j];
            bool found = false;

            for (uint i = 0; i < bases.size(); ++i) {
                if (bases[i].getStringAttribute("key") == key ||
                    bases[i].getStringAttribute("name") == key) {
                    found = true;
                    if (bases[i].getIntAttribute("owner_id") == 0) {
                        ++owned;
                    }
                    break;
                }
            }

            if (!found) {
                if (!m_missingLogged) {
                    _log(m_logTag + ", base not found: " + key, -1);
                    m_missingLogged = true;
                }
                return false;
            }
        }

        return owned == int(m_sectors[contested].m_bases.size());
    }

    // --------------------------------------------
    protected void checkAdvance() {
        if (m_completed) {
            return;
        }

        int contested = m_playerSector + 1;
        if (contested >= int(m_sectors.size())) {
            return;
        }

        if (allContestedOwned()) {
            advance();
        }
    }

    // --------------------------------------------
    protected void advance() {
        if (m_completed) {
            return;
        }

        // Force the sector that is being left behind to be player-owned and
        // uncapturable. In normal play this is a no-op (all bases are already
        // owner 0); it also makes /end_phase safe for testing.
        int secured = m_playerSector + 1;
        if (secured < int(m_sectors.size())) {
            for (uint j = 0; j < m_sectors[secured].m_bases.size(); ++j) {
                setBase(m_sectors[secured].m_bases[j], 0, 0);
            }
        }

        m_playerSector += 1;
        m_checkPending = false;
        m_checkDelay = 0.0;

        announceSectorCaptured();

        bool finalSector = (m_playerSector + 1 >= int(m_sectors.size()));
        if (m_manpower !is null) {
            m_manpower.onSectorCaptured(finalSector);
        }

        if (m_playerSector + 1 < int(m_sectors.size())) {
            _log(m_logTag + ", sector " + m_playerSector + " secured", 1);
            applySector(false);
        } else {
            completeMatch();
        }
    }

    // --------------------------------------------
    protected void completeMatch() {
        if (m_completed) {
            return;
        }

        m_completed = true;
        m_checkPending = false;
        m_checkDelay = 0.0;
        _log(m_logTag + ", all sectors captured, match is decided by the engine", 1);

        // Do NOT send set_match_status win=1 here.
        // The map parameter list must leave the player owning all bases at this
        // point, so the engine's win_with_all_bases=true already reports the
        // match result. Sending an extra win after that produces a second
        // match_result, which in turn grants the end-of-match reward twice.
        // The breakthrough stage setup has already force-lost the neutral faction.
    }

    // --------------------------------------------
    protected bool isPlayerSectorKey(const string&in key) {
        for (int i = 0; i <= m_playerSector && i < int(m_sectors.size()); ++i) {
            if (m_sectors[i].m_bases.find(key) >= 0) {
                return true;
            }
        }
        return false;
    }

    // --------------------------------------------
    protected void handleBaseOwnerChangeEvent(const XmlElement@ event) {
        if (m_completed) {
            return;
        }

        string key = event.getStringAttribute("base_key");
        if (key == "") {
            return;
        }

        // Fallback for a simultaneous capture that lands after the phase has
        // already advanced: a base in a secured player sector must never stay
        // enemy-owned and uncapturable. Re-assert player ownership.
        int owner = event.getIntAttribute("owner_id");
        if (owner != 0 && isPlayerSectorKey(key)) {
            _log(m_logTag + ", re-asserting player base ownership: " + key, 1);
            setBase(key, 0, 0);
            return;
        }

        int contested = m_playerSector + 1;
        if (contested >= int(m_sectors.size())) {
            return;
        }

        // only contested-sector owner changes can advance the phase;
        // this keeps our own owner changes (rear/neutral setup) from causing queries
        if (m_sectors[contested].m_bases.find(key) < 0) {
            return;
        }

        // batch: one bases query after a short delay, not one per event
        m_checkPending = true;
        m_checkDelay = 0.25;
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

        if (checkCommand(message, "end_phase")) {
            advance();
        }
    }

    // --------------------------------------------
    void save(XmlElement@ root) {
        XmlElement subroot(m_mapId + "_breakthrough");
        subroot.setIntAttribute("sector", m_playerSector);
        root.appendChild(subroot);
    }

    // --------------------------------------------
    void load(const XmlElement@ root) {
        if (m_sectors.size() == 0) {
            m_playerSector = 0;
            return;
        }

        const XmlElement@ subroot = root.getFirstElementByTagName(m_mapId + "_breakthrough");
        if (subroot !is null) {
            m_playerSector = subroot.getIntAttribute("sector");
        }

        if (m_playerSector < 0) {
            m_playerSector = 0;
        }
        if (m_playerSector >= int(m_sectors.size())) {
            m_playerSector = int(m_sectors.size()) - 1;
        }
    }
}
