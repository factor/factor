#include "factor.h"

/* the array is full of undefined data, and must be correctly filled before the
next GC. */
F_ARRAY* allot_array(CELL type, CELL capacity)
{
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));

	F_ARRAY* array = allot_object(type,sizeof(F_ARRAY) + capacity * CELLS);
	array->capacity = tag_fixnum(capacity);
	return array;
}

F_ARRAY* array(CELL type, CELL capacity, CELL fill)
{
	int i; F_ARRAY* array = allot_array(type, capacity);
	for(i = 0; i < capacity; i++)
		put(AREF(array,i),fill);
	return array;
}

void primitive_array(void)
{
	maybe_garbage_collection();
	dpush(tag_object(array(ARRAY_TYPE,to_fixnum(dpop()),F)));
}

void primitive_tuple(void)
{
	maybe_garbage_collection();
	dpush(tag_object(array(TUPLE_TYPE,to_fixnum(dpop()),F)));
}

F_ARRAY* grow_array(F_ARRAY* array, CELL capacity, CELL fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	int i; F_ARRAY* new_array;
	CELL curr_cap = array_capacity(array);
	if(curr_cap >= capacity)
		return array;
	new_array = allot_array(untag_header(array->header),capacity);
	memcpy(new_array + 1,array + 1,curr_cap * CELLS);
	for(i = curr_cap; i < capacity; i++)
		put(AREF(new_array,i),fill);
	return new_array;
}

void primitive_grow_array(void)
{
	F_ARRAY* array; CELL capacity;
	maybe_garbage_collection();
	array = untag_array(dpop());
	capacity = to_fixnum(dpop());
	dpush(tag_object(grow_array(array,capacity,F)));
}

F_ARRAY* shrink_array(F_ARRAY* array, CELL capacity)
{
	F_ARRAY* new_array = allot_array(untag_header(array->header),capacity);
	memcpy(new_array + 1,array + 1,capacity * CELLS);
	return new_array;
}

void fixup_array(F_ARRAY* array)
{
	int i = 0; CELL capacity = array_capacity(array);
	for(i = 0; i < capacity; i++)
		data_fixup((void*)AREF(array,i));
}

void collect_array(F_ARRAY* array)
{
	int i = 0; CELL capacity = array_capacity(array);
	for(i = 0; i < capacity; i++)
		copy_handle((void*)AREF(array,i));
}
