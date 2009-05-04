namespace factor
{

inline static CELL array_nth(F_ARRAY *array, CELL slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->header.hi_tag() == ARRAY_TYPE);
#endif
	return array->data()[slot];
}

inline static void set_array_nth(F_ARRAY *array, CELL slot, CELL value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->header.hi_tag() == ARRAY_TYPE);
	check_tagged_pointer(value);
#endif
	array->data()[slot] = value;
	write_barrier(array);
}

F_ARRAY *allot_array(CELL capacity, CELL fill);

CELL allot_array_1(CELL obj);
CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

PRIMITIVE(array);
PRIMITIVE(resize_array);

struct growable_array {
	CELL count;
	gc_root<F_ARRAY> array;

	growable_array() : count(0), array(allot_array(2,F)) {}

	void add(CELL elt);
	void trim();
};

}
