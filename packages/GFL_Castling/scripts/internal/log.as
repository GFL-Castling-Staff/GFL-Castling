class Log {
	int m_logLevel;

	Log() {
		// log levels:
		// -1 = minimal, errors and warnings only
		// 0 = default
		// 1 = verbose
		// 2 = dev verbose

		// by default, still going verbose;
		// - see log_setup.php for how to control the log level via command line
		m_logLevel = 1;
	}
};

Log _logger();

// e.g. level = 1 -> only if level 1 (verbose) logging is enabled
void _log(string input, int level = 0) {
	if (level > _logger.m_logLevel) {
		// too detailed log, not written
		return;
	}

	print(input);
	//output = date('H:i:s') . " " . $string . PHP_EOL;
}

// --------------------------------------------
void _setupLog(string logLevel) {
	//_logger.m_debugOutput = m_launchArguments.exists("debug_output");
	if (logLevel == "minimal") {
		_logger.m_logLevel = -1;
	} else if (logLevel == "normal") {
		_logger.m_logLevel = 0;
	} else if (logLevel == "verbose") {
		_logger.m_logLevel = 1;
	} else if (logLevel == "dev_verbose") {
		_logger.m_logLevel = 2;
	}
}

// --------------------------------------------
void _setupLog(const XmlElement@ settings, string key = "log_level") {
	string logLevel = "normal";
	if (settings.hasAttribute(key)) {
		logLevel = settings.getStringAttribute(key);
	}
	_setupLog(logLevel);
}