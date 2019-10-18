#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION_0 0
#define IMAGE_VERSION 1

typedef struct {
	CELL magic;
	CELL version;
	/* all pointers in the image file are relocated from
	   relocation_base to here when the image is loaded */
	CELL relocation_base;
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
	CELL size;
} HEADER;

/* If version is IMAGE_VERSION_1 */
typedef struct EXT_HEADER {
	/* size of code heap */
	CELL size;
	/* code relocation base */
	CELL relocation_base;
	/* end of literal table */
	CELL literal_top;
	/* maximum value of literal_top */
	CELL literal_max;
} HEADER_2;

void init_objects(HEADER *h);
void load_image(const char* file, int literal_size);
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
	F_PRIMITIVE,
	/* arg is a pointer in the literal table hodling a cons where the
	car is a symbol string, and the cdr is a dll */
	F_DLSYM,
	/* relocate an address to start of code heap */
	F_ABSOLUTE,
	/* store the offset of the card table from the data heap base */
	F_CARDS
} F_RELTYPE;

#define REL_ABSOLUTE_CELL 0
#define REL_ABSOLUTE 1
#define REL_RELATIVE 2
#define REL_2_2 3

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
