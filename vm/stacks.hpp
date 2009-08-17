namespace factor
{

#define DEFPUSHPOP(prefix,ptr) \
	inline cell prefix##peek() { return *(cell *)ptr; } \
	inline void prefix##repl(cell tagged) { *(cell *)ptr = tagged; } \
	inline cell prefix##pop() \
	{ \
		cell value = prefix##peek(); \
		ptr -= sizeof(cell); \
		return value; \
	} \
	inline void prefix##push(cell tagged) \
	{ \
		ptr += sizeof(cell); \
		prefix##repl(tagged); \
	}

}
