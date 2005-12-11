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
	/* store a pointer to environment table */
	F_USERENV,
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
