// --------------------------------------------
class MapInfo {
	float m_size;
    bool m_flipped;
	string m_path;
	string m_name;
	string m_id;

	// --------------------------------------------
	MapInfo() {
		m_size = 1024.0;
		m_flipped = true;
		m_path = "";
		m_name = "";
		m_id = "";
	}
};

// --------------------------------------------
string getRegion(const Vector3@ pos, const MapInfo@ mapInfo) {
    float x = pos[0];
    float z = pos[2];

    float size = mapInfo.m_size;
	x = x / size;
    z = z / size;

	// if not flipped (the old way)
	// x = 0 = east, x = lot = west
	// z = 0 = south, z = lot = north

	// flipped flips this
	// map4, map5, map6 
	// x = 0 = west, x = lot = east
	// z = 0 = north, z = lot = south

    if (mapInfo.m_flipped) {
		x = 1.0f - x;
        z = 1.0f - z;
    }

	int cellX = min(int(floor(3.0f * x)), 2);
	int cellZ = min(int(floor(3.0f * z)), 2);

	array<array<string>> grid = {
		{"southeast", "east", "northeast"},
		{"south", "center", "north"},
		{"southwest", "west", "northwest"}};

	string text = grid[cellX][cellZ];

	_log("get_region, x=" + x + " z=" + z + " (" + cellX + "," + cellZ + ") " + text, 1);

	return text;
}

