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
#endif
	cell *slot_ptr = &array->data()[slot];
	*slot_ptr = value;
	write_barrier(slot_ptr);
}

struct growable_array {
	cell count;
	data_root<array> elements;

	explicit growable_array(factor_vm *parent, cell capacity = 10) :
		count(0), elements(parent->allot_array(capacity,false_object),parent) {}

	void add(cell elt);
	void append(array *elts);
	void trim();
};

}
