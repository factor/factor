/* The compiled code heap is structured into blocks. */
typedef struct
{
	CELL code_length; /* # bytes */
	CELL reloc_length; /* # bytes */
	CELL literal_length; /* # bytes */
} F_COMPILED;

typedef void (*CODE_HEAP_ITERATOR)(F_COMPILED *compiled, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL literal_end);

void iterate_code_heap(CELL start, CELL end, CODE_HEAP_ITERATOR iter);

typedef enum {
	/* arg is a primitive number */
	RT_PRIMITIVE,
	/* arg is a literal table index, holding an array pair (symbol/dll) */
	RT_DLSYM,
	/* store current address here */
	RT_HERE,
	/* store the offset of the card table from the data heap base */
	RT_CARDS,
	/* an indirect literal from the word's literal table */
	RT_LITERAL,
	/* a word */
	RT_WORD,
	/* a local label */
	RT_LABEL
} F_RELTYPE;

#define REL_ABSOLUTE_CELL 0
#define REL_ABSOLUTE 1
#define REL_RELATIVE 2
#define REL_ABSOLUTE_2_2 3
#define REL_RELATIVE_2_2 4
#define REL_RELATIVE_2 5
#define REL_RELATIVE_3 6

#define REL_RELATIVE_2_MASK 0xfffc
#define REL_RELATIVE_3_MASK 0x3fffffc

/* the rel type is built like a cell to avoid endian-specific code in
the compiler */
#define REL_TYPE(r) ((r)->type & 0x000000ff)
#define REL_CLASS(r) (((r)->type & 0x0000ff00) >> 8)
#define REL_ARGUMENT(r) (((r)->type & 0xffff0000) >> 16)

/* code relocation consists of a table of entries for each fixup */
typedef struct {
	CELL type;
	CELL offset;
} F_REL;

void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL literal_end);

void collect_literals(void);

void init_compiler(CELL size);

void primitive_add_compiled_block(void);

CELL last_flush;

void primitive_finalize_compile(void);
