#include "factor.h"

/* untagged */
F_ARRAY* allot_array(CELL type, CELL capacity)
{
	F_ARRAY* array;
	array = allot_object(type,sizeof(F_ARRAY) + capacity * CELLS);
	array->capacity = tag_fixnum(capacity);
	return array;
}

/* untagged */
F_ARRAY* array(CELL type, CELL capacity, CELL fill)
{
	int i;

	F_ARRAY* array = allot_array(type, capacity);

	for(i = 0; i < capacity; i++)
		put(AREF(array,i),fill);

	return array;
}

void primitive_array(void)
{
	F_FIXNUM capacity = to_fixnum(dpop());
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));
	maybe_garbage_collection();
	dpush(tag_object(array(ARRAY_TYPE,capacity,F)));
}

void primitive_to_array(void)
{
	type_check(ARRAY_TYPE,dpeek());
}

void primitive_tuple(void)
{
	F_FIXNUM capacity = to_fixnum(dpop());
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));
	maybe_garbage_collection();
	dpush(tag_object(array(TUPLE_TYPE,capacity,F)));
}

void primitive_to_tuple(void)
{
	type_check(TUPLE_TYPE,dpeek());
}

F_ARRAY* grow_array(F_ARRAY* array, CELL capacity, CELL fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	int i;
	F_ARRAY* new_array;
	CELL curr_cap = untag_fixnum_fast(array->capacity);

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
	F_ARRAY* array;
	CELL capacity;
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
	int i = 0;
	CELL capacity = untag_fixnum_fast(array->capacity);
	for(i = 0; i < capacity; i++)
		data_fixup((void*)AREF(array,i));
}

void collect_array(F_ARRAY* array)
{
	int i = 0;
	CELL capacity = untag_fixnum_fast(array->capacity);
	for(i = 0; i < capacity; i++)
		copy_handle((void*)AREF(array,i));
}
