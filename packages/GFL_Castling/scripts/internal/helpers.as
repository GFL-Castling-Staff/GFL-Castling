// internal
#include "log.as"

// --------------------------------------------
class XmlElement {
	// --------------------------------------------
	XmlElement(dictionary data) {
		// COPY
		m_data = data;
	}

	// --------------------------------------------
	XmlElement(string name) {
		m_data.set("TagName", name);
		array<dictionary> childrenData;
		m_data.set("Children", childrenData);
	}

	// --------------------------------------------
	const dictionary@ toDictionary() const {
		return m_data;
	}

	// --------------------------------------------
	bool empty() const {
		return m_data.empty();
	}

	// --------------------------------------------
	string getName() const {
		return getStringAttribute("TagName");
	}

	// --------------------------------------------
	bool hasAttribute(string name) const {
		return m_data.getKeys().find(name) >= 0;
	}

	// --------------------------------------------
	int getIntAttribute(string name) const {
		int value = 0;
		if (!m_data.get(name, value)) {
			_log("WARNING, attribute " + name + " of type int not found in " + getName() + " element");
		}
		return value;
	}

	// --------------------------------------------
	bool getBoolAttribute(string name) const {
		int value = 0;
		if (!m_data.get(name, value)) {
			_log("WARNING, attribute " + name + " of type int not found in " + getName() + " element");
		}
		return value != 0;
	}

	// --------------------------------------------
	float getFloatAttribute(string name) const {
		float value = 0.0f;
		if (!m_data.get(name, value)) {
			_log("WARNING, attribute " + name + " of type float not found in " + getName() + " element");
		}
		return value;
	}

	// --------------------------------------------
	string getStringAttribute(string name) const {
		return getAnyAttributeAsString(name);
	}

	// --------------------------------------------
	string getStringAttributeStrict(string name) const {
		string value = "";
		if (!m_data.get(name, value)) {
			_log("WARNING, attribute " + name + " of type string not found in " + getName() + " element");
		}
		return value;
	}

	// --------------------------------------------
	string getAnyAttributeAsString(string name) const {
		string result;
		float fvalue = 0.0f;
		int ivalue = 0;
		if (m_data.get(name, result)) {
		} else if (m_data.get(name, fvalue)) {
			result = formatFloat(fvalue); // will truncate to integer..
		} else if (m_data.get(name, ivalue)) {
			result = formatInt(ivalue);
		}
		return result;
	}

	// --------------------------------------------
	string getAnyAttributeAsStringWithFloats(string name) const {
		string result;
		float fvalue = 0.0f;
		int ivalue = 0;
		if (m_data.get(name, result)) {
		} else if (m_data.get(name, fvalue)) {
			// ... ivalues will convert to fvalues
			// so this can't really be used reliably,
			// ok for debugging anyway
			result = formatFloat(fvalue, '', 0, 3);
		} else if (m_data.get(name, ivalue)) {
			result = formatInt(ivalue);
		}
		return result;
	}

	// --------------------------------------------
	const XmlElement@ getFirstElementByTagName(string name) const {
		const XmlElement@ element = null;
		array<dictionary>@ childrenData = null;
		if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
			for (uint i = 0; i < childrenData.size(); ++i) {
				const XmlElement child(childrenData[i]);
				if (child.getName() == name) {
					@element = child;
					break;
				}
			}
		}
		return element;
	}

	// --------------------------------------------
	array<const XmlElement@>@ getElementsByTagName(string name) const {
		array<const XmlElement@> elements;

		array<dictionary>@ childrenData = null;
		if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
			for (uint i = 0; i < childrenData.size(); ++i) {
				const XmlElement child(childrenData[i]);
				if (child.getName() == name) {
					elements.push_back(child);
				}
			}
		}

		return elements;
	}

	// --------------------------------------------
	const XmlElement@ getFirstChild() const {
		const XmlElement@ element = null;
		array<dictionary>@ childrenData = null;
		if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
			XmlElement child(childrenData[0]);
			@element = child;
		}
		return element;
	}

	// --------------------------------------------
	void appendChild(const XmlElement@ child) {
		array<dictionary>@ childrenData;
		if (!m_data.exists("Children")) {
			@childrenData = array<dictionary>();
			m_data.set("Children", @childrenData);
		} else {
			m_data.get("Children", @childrenData);
		}

		if (childrenData !is null) {
			childrenData.insertLast(child.toDictionary());
		}
	}

	// --------------------------------------------
	void removeChild(string tagName, int index = 0) {
		array<dictionary>@ childrenData = null;
		if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
			childrenData.removeAt(index);
			if (childrenData.empty()) {
				m_data.delete("Children");
			}			
		}
	}

	// --------------------------------------------
	void setStringAttribute(string name, string value) {
		m_data.set(name, value);
	}

	// --------------------------------------------
	void setIntAttribute(string name, int value) {
		m_data.set(name, value);
	}

	// --------------------------------------------
	void setBoolAttribute(string name, bool value) {
		m_data.set(name, value ? 1 : 0);
	}

	// --------------------------------------------
	void setFloatAttribute(string name, float value) {
		m_data.set(name, value);
	}

	// --------------------------------------------
	string toString() const {
		string result;

		if (!m_data.isEmpty()) {
			for (uint i = 0; i < m_data.getKeys().size(); ++i) {
				string key = m_data.getKeys()[i];
				if (key != "Children") {
					string value = getAnyAttributeAsString(key);
					result += key + "=" + value + " ";
				}
			}

			array<dictionary>@ childrenData = null;
			if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
				for (uint j = 0; j < childrenData.size(); ++j) {
					const XmlElement child(childrenData[j]);
					result += "    " + child.toString();
				}
			}
		}

		return result;
	}

	// --------------------------------------------
	string toStringWithFloats() const {
		string result;

		if (!m_data.isEmpty()) {
			for (uint i = 0; i < m_data.getKeys().size(); ++i) {
				string key = m_data.getKeys()[i];
				if (key != "Children") {
					string value = getAnyAttributeAsStringWithFloats(key);
					result += key + "=" + value + " ";
				}
			}

			array<dictionary>@ childrenData = null;
			if (m_data.exists("Children") && m_data.get("Children", @childrenData)) {
				for (uint j = 0; j < childrenData.size(); ++j) {
					const XmlElement child(childrenData[j]);
					result += "    " + child.toStringWithFloats();
				}
			}
		}

		return result;
	}

	// --------------------------------------------
	bool equals(const XmlElement@ other) const {
		return toString() == other.toString();
	}

	// --------------------------------------------
	protected dictionary m_data;
}

// --------------------------------------------
bool testParameter(const XmlElement@ element, string target) {
	bool result = false;
	if (element.hasAttribute(target)) {
		result = element.getIntAttribute(target) == 1;
	}
	return result;
}

// --------------------------------------------
int pickRandomMapIndex(int mapCount, const array<int>@ avoidThese) {
	array<int> useThese;
	_log("unusable maps: ", 1);
	for (uint i = 0; i < avoidThese.size(); ++i) {
		int value = avoidThese[i];
		_log("  " + value);
	}
	for (int i = 0; i < mapCount; ++i) {
		if (avoidThese.find(i) < 0) {
			useThese.insertLast(i);
		}
	}
	_log("usable maps: ", 1);
	for (uint i = 0; i < useThese.size(); ++i) {
		int value = useThese[i];
		_log("  " + value);
	}
	int index = rand(0,useThese.size() - 1);

	return useThese[index];
}

// --------------------------------------------
bool startsWith(string haystack, string needle) {
	return haystack.findFirst(needle) == 0;
}

// --------------------------------------------
bool endsWith(string haystack, string needle) {
    return needle.isEmpty() || haystack.substr(-needle.length()) == needle;
}

// --------------------------------------------
bool checkCommand(string message, string target) {
    return startsWith(message.toLowerCase(), "/" + target);
}

// --------------------------------------------
array<string> parseParameters(string message, string command) {
	string s = message.trim().substr(command.length() + 2);
	array<string> a = s.split(" ");
	return a;
}

// --------------------------------------------
class Vector3 {
	// --------------------------------------------
	Vector3() {
		m_values = array<float>(3, 0.0f);
	}

	// --------------------------------------------
	Vector3(float x, float y, float z) {
		m_values = array<float>(3, 0.0f);
		set(x,y,z);
	}

	// --------------------------------------------
	Vector3 scale(float scalar) const {
		Vector3 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] * scalar;
		}
		return d;
	}

	// --------------------------------------------
	Vector3 add(const Vector3@ v2) const {
		Vector3 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] + v2.m_values[i];
		}
		return d;
	}

	// --------------------------------------------
	Vector3 subtract(const Vector3@ v2) const {
		Vector3 d();
		for (uint i = 0; i < m_values.size(); ++i) {
			d.m_values[i] = m_values[i] - v2.m_values[i];
		}
		return d;
	}

	float length() const {
		float sum = 0;
		for (uint i = 0; i < m_values.size(); ++i) {
			sum += m_values[i] * m_values[i];
		}
		return sqrt(sum);
	}

	// --------------------------------------------
	void set(float x, float y, float z) {
		m_values[0] = x;
		m_values[1] = y;
		m_values[2] = z;
	}

	// --------------------------------------------
	string toString() const {
		array<string> strings;
		for (uint i = 0; i < m_values.size(); ++i) {
			string s = formatFloat(m_values[i], '', 0, 5);
			strings.insertLast(s);
		}
		return join(strings, " ");
	}

	// [] usage
	// --------------------------------------------
    float get_opIndex(int i) const { 
		return m_values[i]; 
	}

	// --------------------------------------------
	array<float> m_values;
};

// --------------------------------------------
Vector3 stringToVector3(string s) {
	Vector3 d;
	array<string> strings = s.split(" ");
	if(strings.length()!=3)
		for (int i = 0; i < 3; ++i) {
			d.m_values[i] = 0.0;
		}		
	else
		for (int i = 0; i < 3; ++i) {
			d.m_values[i] = parseFloat(strings[i]);
		}
	return d;
}

// --------------------------------------------
float getPositionDistance(const Vector3@ pos1, const Vector3@ pos2) {
	Vector3 d = pos1.subtract(pos2);

	d.m_values[0] *= d.m_values[0];
	d.m_values[1] *= d.m_values[1];
	d.m_values[2] *= d.m_values[2];

	float result = sqrt(d.m_values[0] + d.m_values[1] + d.m_values[2]);
	return result;
}

// --------------------------------------------
bool checkRange(const Vector3@ pos1, const Vector3@ pos2, float range) {
	float length = getPositionDistance(pos1, pos2);
	return length <= range; 
}

// --------------------------------------------
array<string> arrayDiff(const array<string>@ a, const array<string>@ b) {
	array<string> result;

	for (uint i = 0; i < a.size(); ++i) {
		string v = a[i];
		if (b.find(v) < 0) {
			result.insertLast(v);
		}
	}

	return result;
}

void merge(array<XmlElement@>@ a1, const array<XmlElement@>@ a2) {
	for (uint i = 0; i < a2.size(); ++i) {
		a1.insertLast(a2[i]);
	}
}

void merge(array<const XmlElement@>@ a1, const array<const XmlElement@>@ a2) {
	for (uint i = 0; i < a2.size(); ++i) {
		a1.insertLast(a2[i]);
	}
}


/*
// --------------------------------------------
// - reads given file as xml, extracts root as string
// - can be used to import certain resources directly into map_config
//   so that custom resources become synced with clients withouot
//   having clients download file resources
// - e.g. $all_factions = read_xml("my_deathmatch.xml");
function read_xml($filename) {
    $doc = new DOMDocument();
    $doc->load($filename);
    $root = $doc->documentElement;
    $s = $doc->saveXML($root);
    return $s;
}

// --------------------------------------------
function copy_folder($src, $dst) {
    _log("copy_folder, src=" + $src + ", dst=" + $dst);

    $dir = opendir($src);
    @mkdir($dst, 0777, true); // recursive = true
    while(false !== ( $file = readdir($dir)) ) {
        if (( $file != '.' ) && ( $file != '..' )) {
            if ( is_dir($src + '/' + $file) ) {
            } else {
                copy($src + '/' + $file,$dst + '/' + $file);
            }
        }
    }
    closedir($dir);
} 

// --------------------------------------------
function get_profile_path($hash) {
	// server stores current profiles at <server_dir>/profiles
	global $_path_to_server_root;
	$result = $_path_to_server_root + "profiles/" . $hash . ".profile";
	return $result;
}

// --------------------------------------------
function copy_profiles($target_folder_name) {
	// server stores current profiles at <server_dir>/profiles
	global $_path_to_server_root;
	$source_path = $_path_to_server_root . "profiles";
	$target_path = $_path_to_server_root . $target_folder_name;
	copy_folder($source_path, $target_path);
}

// --------------------------------------------
function merge_profiles($source_folder_name, $target_folder_name) {
	global $_path_to_server_root;
	$src = $_path_to_server_root . $source_folder_name;
	$dst = $_path_to_server_root . $target_folder_name;

	// make sure dst exists
	if (!file_exists($dst)) {
	    @mkdir($dst, 0777, true); // recursive = true
	}

	// go through all profiles in source 
	$dir = opendir($src);
	while(false !== ( $file = readdir($dir)) ) {
        if (( $file != '.' ) && ( $file != '..' )) {
			$src_file_path = $src . '/' . $file;
			if (!is_dir($src_file_path) && ends_with($file, ".profile")) {
				// look for a match in target
				$dst_file_path = $dst . '/' . $file;
				if (file_exists($dst_file_path)) {
					// if match, do merging
					merge_profile($src_file_path, $dst_file_path);
				} else {
					// if no match, just copy the file
					copy($src_file_path, $dst_file_path);
				}
			}
        }
    }
    closedir($dir);
}

// --------------------------------------------
function merge_profile($src_file_path, $dst_file_path) {
	<stats
		attributes:
			kills --> add
			deaths --> add
			time_played --> add
			player_kills --> add
			teamkills --> add
			longest_kill_streak --> highest
			targets_destroyed --> add
			vehicles_destroyed --> add
			soldiers_healed --> add
			times_got_healed --> add
		>
		<monitor name="kill combo">
			<entry combo="x" count="y" /> --> highest count per combo
		</monitor>
        <monitor name="death streak" longest_death_streak="1" /> --> highest 
		...
	</stats>

	$src_doc = new DOMDocument();
	$src_doc->load($src_file_path);

	$dst_doc = new DOMDocument();
	$dst_doc->load($dst_file_path);

	// <stats>
	{
		$src_root = $src_doc->getElementsByTagName("stats")->item(0);
		$dst_root = $dst_doc->getElementsByTagName("stats")->item(0);

		// default operation is to sum
		$operations = array();
		$operations["longest_kill_streak"] = "max";

		if ($src_root && $src_root->attributes && $dst_root) {
			for ($i = 0; $i < $src_root->attributes->length; ++$i) {
				$src_attr = $src_root->attributes->item($i);
				$name = $src_attr->name;
				$value = intval($src_attr->value);

				$dst_attr = $dst_root->attributes ? $dst_root->attributes->getNamedItem($name) : null;
				if (!$dst_attr) {
					// a new attribute? just set it
				} else {
					// found, either sum or max
					$operation = "sum";
					if (array_key_exists($name, $operations)) {
						$operation = $operations[$name];
					}

					$dst_value = intval($dst_attr->value);

					if ($operation == "sum") {
						$value = $value + $dst_value;
					} else if ($operation == "max") {
						$value = max($value, $dst_value);
					}
				}

				$dst_root->setAttribute($name, $value);
			}
		}
	}

	// <monitor>
	$dst_doc->save($dst_file_path);
}

*/