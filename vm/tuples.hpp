namespace factor
{

inline static CELL tuple_size(F_TUPLE_LAYOUT *layout)
{
	CELL size = untag_fixnum(layout->size);
	return sizeof(F_TUPLE) + size * CELLS;
}

inline static CELL tuple_nth(F_TUPLE *tuple, CELL slot)
{
	return tuple->data()[slot];
}

inline static void set_tuple_nth(F_TUPLE *tuple, CELL slot, CELL value)
{
	tuple->data()[slot] = value;
	write_barrier(tuple);
}

PRIMITIVE(tuple);
PRIMITIVE(tuple_boa);
PRIMITIVE(tuple_layout);

}
