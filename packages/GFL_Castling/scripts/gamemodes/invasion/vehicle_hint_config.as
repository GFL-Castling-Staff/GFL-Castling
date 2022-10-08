// --------------------------------------------
class VehicleHintConfig {
	string m_vehicleKey;
	string m_intelText; 
	string m_destroyedText; 
	int m_factionId;
	// mode = "region" or "base"
	string m_mode;
	bool m_makeSpotted;
	float m_minWaitIntelTime;
	float m_maxWaitIntelTime;

	VehicleHintConfig(string vehicleKey, string intelText, string destroyedText, int factionId, string mode = "region", bool makeSpotted = false, float minIntelTime = 300.0, float maxIntelTime = 500.0) {
		m_vehicleKey = vehicleKey;
		m_intelText = intelText;
		m_destroyedText = destroyedText;
		m_factionId = factionId;
		m_mode = mode; 
		m_makeSpotted = makeSpotted;
		m_minWaitIntelTime = minIntelTime;
		m_maxWaitIntelTime = maxIntelTime;
	}
}
