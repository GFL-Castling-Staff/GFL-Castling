#include "helpers.as"

class soldier_spawn_request
{
    string m_type;
	int m_num;
	soldier_spawn_request(string key, int num) {
		m_type = key;
		m_num = num;
	}    
}