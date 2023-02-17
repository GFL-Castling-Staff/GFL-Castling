#include "helpers.as"

class Spawn_request
{
    string m_type;
	int m_num;
	Spawn_request(string key, int num) {
		m_type = key;
		m_num = num;
	}    
}