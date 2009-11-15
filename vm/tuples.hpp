namespace factor
{

inline static cell tuple_size(const tuple_layout *layout)
{
	cell size = untag_fixnum(layout->size);
	return sizeof(tuple) + size * sizeof(cell);
}

}
