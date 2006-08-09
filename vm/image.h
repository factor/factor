#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION 2

typedef struct {
	CELL magic;
	CELL version;
	/* all pointers in the image file are relocated from
	   relocation_base to here when the image is loaded */
	CELL data_relocation_base;
	/* tagged pointer to bootstrap quotation */
	CELL boot;
	/* tagged pointer to global namespace */
	CELL global;
	/* tagged pointer to t singleton */
	CELL t;
	/* tagged pointer to bignum 0 */
	CELL bignum_zero;
	/* tagged pointer to bignum 1 */
	CELL bignum_pos_one;
	/* tagged pointer to bignum -1 */
	CELL bignum_neg_one;
	/* size of heap */
	CELL data_size;
	/* size of code heap */
	CELL code_size;
	/* code relocation base */
	CELL code_relocation_base;
} HEADER;

void init_objects(HEADER *h);
void load_image(const char* file);
bool save_image(const char* file);
void primitive_save_image(void);

/* relocation base of currently loaded image's data heap */
CELL data_relocation_base;

INLINE void data_fixup(CELL *cell)
{
	if(TAG(*cell) != FIXNUM_TYPE && *cell != F)
		*cell += (tenured.base - data_relocation_base);
}

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

#define REL_RELATIVE_2_MASK 0x3fffffc
#define REL_RELATIVE_3_MASK 0xfffc

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

CELL code_relocation_base;

INLINE void code_fixup(CELL *cell)
{
	*cell += (compiling.base - code_relocation_base);
}

void relocate_data();

void relocate_code_step(F_REL *rel, CELL code_start, CELL literal_start,
	F_VECTOR *labels);
CELL relocate_code_next(CELL relocating);
void relocate_code();

/* on PowerPC, return the 32-bit literal being loaded at the code at the
given address */
INLINE CELL reloc_get_2_2(CELL cell)
{
	return ((get(cell - CELLS) & 0xffff) << 16) | (get(cell) & 0xffff);
}

INLINE void reloc_set_2_2(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}
