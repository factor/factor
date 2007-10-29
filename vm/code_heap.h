typedef enum {
	/* arg is a primitive number */
	RT_PRIMITIVE,
	/* arg is a literal table index, holding an array pair (symbol/dll) */
	RT_DLSYM,
	/* an indirect literal from the word's literal table */
	RT_LITERAL,
	/* a pointer to a compiled word reference */
	RT_DISPATCH,
	/* a compiled word reference */
	RT_XT,
	/* a compiled word reference, pointing at the profiling prologue */
	RT_XT_PROFILING,
	/* a local label */
	RT_LABEL
} F_RELTYPE;

typedef enum {
	/* absolute address in a 64-bit location */
	RC_ABSOLUTE_CELL,
	/* absolute address in a 32-bit location */
	RC_ABSOLUTE,
	/* relative address in a 32-bit location */
	RC_RELATIVE,
	/* relative address in a PowerPC LIS/ORI sequence */
	RC_ABSOLUTE_PPC_2_2,
	/* relative address in a PowerPC LWZ/STW/BC instruction */
	RC_RELATIVE_PPC_2,
	/* relative address in a PowerPC B/BL instruction */
	RC_RELATIVE_PPC_3,
	/* relative address in an ARM B/BL instruction */
	RC_RELATIVE_ARM_3,
	/* pointer to address in an ARM LDR/STR instruction */
	RC_INDIRECT_ARM,
	/* pointer to address in an ARM LDR/STR instruction offset by 8 bytes */
	RC_INDIRECT_ARM_PC
} F_RELCLASS;

#define REL_RELATIVE_PPC_2_MASK 0xfffc
#define REL_RELATIVE_PPC_3_MASK 0x3fffffc
#define REL_INDIRECT_ARM_MASK 0xfff
#define REL_RELATIVE_ARM_3_MASK 0xffffff

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
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end);

void finalize_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literals_start, CELL words_start, CELL words_end);

void set_word_xt(F_WORD *word, F_COMPILED *compiled);

F_COMPILED *add_compiled_block(
	CELL type,
	F_ARRAY *code,
	F_ARRAY *labels,
	F_ARRAY *rel,
	F_ARRAY *words,
	F_ARRAY *literals);

CELL compiled_code_format(void);

DECLARE_PRIMITIVE(add_compiled_block);
DECLARE_PRIMITIVE(finalize_compile);
