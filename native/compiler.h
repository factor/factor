/* The compiled code heap is structures into blocks. */
typedef struct
{
	CELL header;
	CELL code_length;
	CELL reloc_length;
} F_COMPILED;

#define COMPILED_HEADER 0x01c3babe

ZONE compiling;

#define LITERAL_TABLE 4096

CELL literal_top;
CELL literal_max;

void primitive_compiled_offset(void);
void primitive_set_compiled_offset(void);
void primitive_literal_top(void);
void primitive_set_literal_top(void);
void collect_literals(void);
