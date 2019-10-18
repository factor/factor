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

/* the rel type is built like a cell to avoid endian-specific code in
the compiler */
#define REL_TYPE(r) ((r)->type & 0xff)
/* on PowerPC, some values are stored in the high 16 bits of a pair
of consecutive cells */
#define REL_16_16(r) ((r)->type & 0xff00)
#define REL_RELATIVE(r) ((r)->type & 0xff0000)

/* code relocation consists of a table of entries for each fixup */
typedef struct {
	CELL type;
	CELL offset;
	CELL argument;
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
INLINE CELL reloc_get_16_16(CELL cell)
{
	return ((get(cell - CELLS) & 0xffff) << 16) | (get(cell) & 0xffff);
}

INLINE void reloc_set_16_16(CELL cell, CELL value)
{
	put(cell - CELLS,((get(cell - CELLS) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell,((get(cell) & ~0xffff) | (value & 0xffff)));
}
