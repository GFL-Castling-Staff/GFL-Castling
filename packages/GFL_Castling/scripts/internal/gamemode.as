// internal
#include "metagame.as"

// --------------------------------------------
class GameMode : Metagame {
	GameMode(string startServerCommand = "") {
		super(startServerCommand);
	}

	// --------------------------------------------
	void save() {
	}
	
	// --------------------------------------------
	string getMapId() const {
		return "unset mapid"; 
	}
	
	// --------------------------------------------
	uint getFactionCount() const { 
		return 0; 
	}
}

