// ------------------------------------------------------------------------------------------------
// Breakthrough sector data for every map that uses the mode.
//
// This is the single file that holds all map-specific region division designs.
// PhaseControllerBreakthrough keeps the main flow; this file only answers
// "which bases belong to sector R0, R1, ... for map X".
//
// The map id must match the stage's m_mapInfo.m_id / the id passed to the
// controller. To add a breakthrough map, add another else-if branch here and
// create its stage definition normally in stage_configurator_invasion.as.
//
// Sector order matters: R0 is the player start, each next sector is opened in
// order. The last sector must be the last bases the player captures; at the end
// the player owns all bases and the engine's win_with_all_bases=true decides
// the match.
//
// Initial ownership convention (same as map10b):
//   R0          -> player
//   R1 + R2     -> enemy
//   R3 and up   -> neutral placeholder
// The phase controller applies this at phase 0; getBreakthroughInitialBases()
// returns the matching base-id groups for the stage's m_presetBases.
// ------------------------------------------------------------------------------------------------

class BreakthroughSector {
    array<string> m_bases;

    // --------------------------------------------
    BreakthroughSector(const array<string>@ bases) {
        m_bases = bases;
    }
}

// ------------------------------------------------------------------------------------------------
array<BreakthroughSector@>@ getBreakthroughSectors(const string&in mapId) {
    array<BreakthroughSector@> sectors;

    if (mapId == "map10b") {
        // map10 "Railroad Gap" breakthrough variant
        // R0 Gas station
        // R1 Main road, City Center
        // R2 Embassy, Market, Terminus
        // R3 Warehouse, Mosque
        // R4 Racing Track, Tennis Club
        // R5 Chemical factory, Container Port
        sectors.insertLast(BreakthroughSector(array<string> = {"Gas station"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Main road", "City Center"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Embassy", "Market", "Terminus"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Warehouse", "Mosque"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Racing Track", "Tennis Club"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Chemical factory", "Container Port"}));
    } else if (mapId == "map2b") {
        // map2 "Eastern District" breakthrough variant
        // R0 Villa (4)
        // R1 West end (5)
        // R2 Docks (3), Shop lane (6)
        // R3 Eastern district (0), Church (7)
        // R4 East Beach (2), Ranch (1)
        // 4 attack sectors after R0.
        sectors.insertLast(BreakthroughSector(array<string> = {"Villa"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"West end"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Docks", "Shop lane"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Eastern district", "Church"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"East Beach", "Ranch"}));
    } else if (mapId == "map6cb") {
        // map6_c "Rattlesnake Crescent" breakthrough variant
        // R0 Attacking Base (10)
        // R1 Mosque (0), Powerhouse (6)
        // R2 Bazaar (3), TV station (2), Junkyard (1)
        // R3 Outskirts (8), Mountain Side (9)
        // R4 Outpost (4)
        // R5 Forward HQ alpha (5), Forward HQ bravo (7)
        // R6 Air field (11)
        // 6 attack sectors after R0.
        sectors.insertLast(BreakthroughSector(array<string> = {"Attacking Base"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mosque", "Powerhouse"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Bazaar", "TV station", "Junkyard"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Outskirts", "Mountain Side"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Outpost"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Forward HQ alpha", "Forward HQ bravo"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Air field"}));
    } else if (mapId == "map14b") {
        // map14 "Misty Heights" breakthrough variant
        // R0 North Beach (3), Mid Beach (0), South Beach (4)
        // R1 North Draw (2), South Draw (7)
        // R2 Command Center (1), Ruins (5)
        // R3 Southern Village (8), Chemical Plant (10)
        // R4 Northern Village (6), Graveyard (9)
        // 4 attack sectors after R0.
        sectors.insertLast(BreakthroughSector(array<string> = {"North Beach", "Mid Beach", "South Beach"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"North Draw", "South Draw"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Command Center", "Ruins"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Southern Village", "Chemical Plant"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Northern Village", "Graveyard"}));
    } else if (mapId == "map20b") {
        // map20 breakthrough variant
        // R0 Dock (6)
        // R1 Mine (5), Airfield (7)
        // R2 Village (4), Ruins (8)
        // R3 Sentry (2), Lighthouse (3)
        // R4 Prison (1), South Fortification (9)
        // R5 Mansion (0)
        // 5 attack sectors after R0. Ruins (8) stays in R2: it carries the
        // map's only usable AA spawn point and must remain in R1/R2.
        sectors.insertLast(BreakthroughSector(array<string> = {"Dock"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mine", "Airfield"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Village", "Ruins"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Sentry", "Lighthouse"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Prison", "South Fortification"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mansion"}));
    } else if (mapId == "map21b") {
        // map21 "Hell's High Way" breakthrough variant
        // R0 Infiltrated Village (11)
        // R1 Wet fields (12), South Ranch (15)
        // R2 Wet Town (5), Townline (13), River Junction (16)
        // R3 Ridge (7), Hell Suburb (6)
        // R4 Hell City South (0), Hell City East (1), Hell City West (2), Hell City North (8)
        // R5 Hell Bridge (3), North Ranch (9), North fields (14)
        // R6 River Side (4), Goldfield Ranch (10)
        // 6 attack sectors after R0.
        sectors.insertLast(BreakthroughSector(array<string> = {"Infiltrated Village"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Wet fields", "South Ranch"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Wet Town", "Townline", "River Junction"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Ridge", "Hell Suburb"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Hell City South", "Hell City East", "Hell City West", "Hell City North"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Hell Bridge", "North Ranch", "North fields"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"River Side", "Goldfield Ranch"}));
    } else if (mapId == "mapxmasb") {
        // mapxmas "A Snowy Night Capriccio" breakthrough variant
        // R0 Start Point (8)
        // R1 Massacres B (2), Massacres A (9)
        // R2 Mass Market (1), Mass transit rest Area (6), Mass-Delta (7)
        // R3 Mass media Flow (0), Mass organizations Factory (3)
        // R4 Mass production Zone (4), Mass containers Storage (5)
        // 4 attack sectors after R0 (0/3 merged).
        sectors.insertLast(BreakthroughSector(array<string> = {"Start Point"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Massacres B", "Massacres A"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mass Market", "Mass transit rest Area", "Mass-Delta"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mass media Flow", "Mass organizations Factory"}));
        sectors.insertLast(BreakthroughSector(array<string> = {"Mass production Zone", "Mass containers Storage"}));
    }
    // else if (mapId == "mapXb") {
    //     // add another map's R0..Rn here
    // }

    return sectors;
}

// ------------------------------------------------------------------------------------------------
// Initial base-id groups for the stage's m_presetBases:
//   [0] player  = R0
//   [1] enemy   = R1 + R2
//   [2] neutral = R3 and later
//
// The stage must NOT set Faction::m_bases for these factions, otherwise
// getStartGameCommand uses m_bases and ignores m_presetBases.
// ------------------------------------------------------------------------------------------------
array<array<int>>@ getBreakthroughInitialBases(const string&in mapId) {
    array<array<int>> result;

    if (mapId == "map10b") {
        result.insertLast(array<int> = {0});                    // R0 player: Gas station
        result.insertLast(array<int> = {1, 2, 4, 7, 8});        // R1+R2 enemy: Main road, City Center, Market, Terminus, Embassy
        result.insertLast(array<int> = {3, 5, 6, 9, 10, 11});   // R3+ neutral
    } else if (mapId == "map2b") {
        result.insertLast(array<int> = {4});                    // R0 Villa
        result.insertLast(array<int> = {5, 3, 6});              // R1 West end, R2 Docks + Shop lane
        result.insertLast(array<int> = {0, 7, 2, 1});           // R3+ Eastern district, Church, East Beach, Ranch
    } else if (mapId == "map6cb") {
        result.insertLast(array<int> = {10});                   // R0 Attacking Base
        result.insertLast(array<int> = {0, 6, 3, 2, 1});        // R1 Mosque/Powerhouse, R2 Bazaar/TV/Junkyard
        result.insertLast(array<int> = {8, 9, 4, 5, 7, 11});    // R3+ Outskirts, Mountain Side, Outpost, HQs, Air field
    } else if (mapId == "map14b") {
        result.insertLast(array<int> = {3, 0, 4});              // R0 North/Mid/South Beach
        result.insertLast(array<int> = {2, 7, 1, 5});           // R1 North/South Draw, R2 Command Center/Ruins
        result.insertLast(array<int> = {8, 10, 6, 9});          // R3+ Southern Village, Chemical Plant, Northern Village, Graveyard
    } else if (mapId == "map20b") {
        result.insertLast(array<int> = {6});                    // R0 Dock
        result.insertLast(array<int> = {5, 7, 4, 8});           // R1 Mine/Airfield, R2 Village/Ruins (AA)
        result.insertLast(array<int> = {2, 3, 1, 9, 0});        // R3+ Sentry, Lighthouse, Prison, South Fortification, Mansion
    } else if (mapId == "map21b") {
        result.insertLast(array<int> = {11});                   // R0 Infiltrated Village
        result.insertLast(array<int> = {12, 15, 5, 13, 16});    // R1 Wet fields/South Ranch, R2 Wet Town/Townline/River Junction
        result.insertLast(array<int> = {7, 6, 0, 1, 2, 8, 3, 9, 14, 4, 10}); // R3+
    } else if (mapId == "mapxmasb") {
        result.insertLast(array<int> = {8});                    // R0 Start Point
        result.insertLast(array<int> = {2, 9, 1, 6, 7});        // R1 Massacres B/A, R2 Mass Market/transit/Mass-Delta
        result.insertLast(array<int> = {0, 3, 4, 5});           // R3+ Mass media Flow/Factory, production/containers
    }

    return result;
}
