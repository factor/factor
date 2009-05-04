namespace factor
{

#define DEFPUSHPOP(prefix,ptr) \
	inline static cell prefix##peek() { return *(cell *)ptr; } \
	inline static void prefix##repl(cell tagged) { *(cell *)ptr = tagged; } \
	inline static cell prefix##pop(void) \
	{ \
		cell value = prefix##peek(); \
		ptr -= sizeof(cell); \
		return value; \
	} \
	inline static void prefix##push(cell tagged) \
	{ \
		ptr += sizeof(cell); \
		prefix##repl(tagged); \
	}

}
