#if defined( __APPLE__) || (defined(WINDOWS) && !defined(__arm__))
	#define MANGLE(sym) _##sym
#else
	#define MANGLE(sym) sym
#endif
