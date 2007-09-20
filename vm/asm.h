#if defined( __APPLE__) || (defined(WINDOWS) && !defined(__arm__))
	#define MANGLE(sym) _##sym
	#define XX @
#else
	#define MANGLE(sym) sym
	#define XX ;
#endif

/* The returns and args are just for documentation */
#define DEF(returns,symbol,args) .globl MANGLE(symbol) XX \
MANGLE(symbol)
