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

/* code relocation consists of a table of entries for each fixup */
typedef struct {
	u8 type;
	u8 relative;
	/* on PowerPC, some values are stored in the high 16 bits of a pair
	of consecutive cells */
	u8 risc16_16;
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
	return ((get(cell) & 0xffff) << 16) | (get(cell + 1) & 0xffff);
}

INLINE void reloc_set_16_16(CELL cell, CELL value)
{
	put(cell,((get(cell) & ~0xffff) | ((value >> 16) & 0xffff)));
	put(cell + 1,((get(cell + 1) & ~0xffff) | (value & 0xffff)));
}
