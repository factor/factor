INLINE CELL tag_tuple(F_TUPLE *tuple)
{
	return RETAG(tuple,TUPLE_TYPE);
}

INLINE CELL tuple_size(F_TUPLE_LAYOUT *layout)
{
	CELL size = untag_fixnum_fast(layout->size);
	return sizeof(F_TUPLE) + size * CELLS;
}

DEFINE_UNTAG(F_TUPLE,TUPLE_TYPE,tuple)

INLINE F_TUPLE_LAYOUT *untag_tuple_layout(CELL obj)
{
	return (F_TUPLE_LAYOUT *)UNTAG(obj);
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
