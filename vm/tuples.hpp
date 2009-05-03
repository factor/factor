INLINE CELL tuple_size(F_TUPLE_LAYOUT *layout)
{
	CELL size = untag_fixnum(layout->size);
	return sizeof(F_TUPLE) + size * CELLS;
}

INLINE CELL tuple_nth(F_TUPLE *tuple, CELL slot)
{
	return get(AREF(tuple,slot));
}

INLINE void set_tuple_nth(F_TUPLE *tuple, CELL slot, CELL value)
{
	put(AREF(tuple,slot),value);
	write_barrier((CELL)tuple);
}

void primitive_tuple(void);
void primitive_tuple_boa(void);
void primitive_tuple_layout(void);
