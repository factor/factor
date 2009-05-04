#define DEFPUSHPOP(prefix,ptr) \
	inline static CELL prefix##peek() { return *(CELL *)ptr; } \
	inline static void prefix##repl(CELL tagged) { *(CELL *)ptr = tagged; } \
	inline static CELL prefix##pop(void) \
	{ \
		CELL value = prefix##peek(); \
		ptr -= CELLS; \
		return value; \
	} \
	inline static void prefix##push(CELL tagged) \
	{ \
		ptr += CELLS; \
		prefix##repl(tagged); \
	}
