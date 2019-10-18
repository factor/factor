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
	/* a compiled word reference */
	RT_XT,
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
	unsigned int type;
	unsigned int offset;
} F_REL;

void relocate_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end);
void primitive_add_compiled_block(void);
void primitive_finalize_compile(void);
void primitive_xt_map(void);
