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
    }
    // else if (mapId == "mapXb") {
    //     // add another map's R0..Rn here
    // }

    return sectors;
}
