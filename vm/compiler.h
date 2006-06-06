/* The compiled code heap is structured into blocks. */
typedef struct
{
	CELL header; /* = COMPILED_HEADER */
	CELL code_length;
	CELL reloc_length; /* see relocate.h */
} F_COMPILED;

#define COMPILED_HEADER 0x01c3babe

ZONE compiling;

CELL literal_top;
CELL literal_max;

void init_compiler(CELL size);
void primitive_compiled_offset(void);
void primitive_set_compiled_offset(void);
void primitive_literal_top(void);
void primitive_set_literal_top(void);
void collect_literals(void);

#ifdef FACTOR_PPC
void flush_icache(void *start, int len);
#else
INLINE void flush_icache(void *start, int len) {}
#endif

CELL last_flush;

void primitive_flush_icache(void);
