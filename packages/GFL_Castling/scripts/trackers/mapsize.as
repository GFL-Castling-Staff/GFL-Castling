#include "query_helpers2.as"
#include "helpers.as"

bool OutOfRange_2(Vector3 v2){
	float x = v2.get_opIndex(0);
	float z = v2.get_opIndex(2);

	if (x < 0 || x > 1024) return true;
	if (z < 0 || z > 1024) return true;
	return false;
}