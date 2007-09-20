#if defined(__APPLE__) || (defined(WINDOWS) && !defined(__arm__))
	#define MANGLE(sym) _##sym
#else
	#define MANGLE(sym) sym
#endif

/* Apple's PPC assembler is out of date? */
#if defined(__APPLE__) && defined(FACTOR_PPC)
	#define XX @
#else
	#define XX ;
#endif

/* The returns and args are just for documentation */
#define DEF(returns,symbol,args) .globl MANGLE(symbol) XX \
MANGLE(symbol)
