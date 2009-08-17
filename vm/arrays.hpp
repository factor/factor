namespace factor
{

inline cell array_nth(array *array, cell slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
#endif
	return array->data()[slot];
}

inline void factorvm::set_array_nth(array *array, cell slot, cell value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
	check_tagged_pointer(value);
#endif
	array->data()[slot] = value;
	write_barrier(array);
}

inline void set_array_nth(array *array, cell slot, cell value)
{
	return vm->set_array_nth(array,slot,value);
}

array *allot_array(cell capacity, cell fill);

cell allot_array_1(cell obj);
cell allot_array_2(cell v1, cell v2);
cell allot_array_4(cell v1, cell v2, cell v3, cell v4);

PRIMITIVE(array);
PRIMITIVE(resize_array);

struct growable_array {
	cell count;
	gc_root<array> elements;

	growable_array(factorvm *myvm, cell capacity = 10) : count(0), elements(allot_array(capacity,F),myvm) {}

	void add(cell elt);
	void trim();
};

}
