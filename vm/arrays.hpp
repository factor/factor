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

inline void factor_vm::set_array_nth(array *array, cell slot, cell value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(array->h.hi_tag() == ARRAY_TYPE);
	check_tagged_pointer(value);
#endif
	array->data()[slot] = value;
	write_barrier(array);
}

struct growable_array {
	cell count;
	gc_root<array> elements;

	growable_array(factor_vm *myvm, cell capacity = 10) : count(0), elements(myvm->allot_array(capacity,F),myvm) {}

	void add(cell elt);
	void trim();
};

}
