#include "factor.h"

/* the array is full of undefined data, and must be correctly filled before the
next GC. */
F_ARRAY* allot_array(CELL type, CELL capacity)
{
	F_ARRAY *array;

	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));

	array = allot_object(type,array_size(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

/* WARNING: fill must be an immediate type:
either be F or a fixnum.

if you want to use pass a pointer, you _must_ hit
the write barrier manually with a write_barrier()
call with the returned object. */
F_ARRAY* array(CELL type, CELL capacity, CELL fill)
{
	int i; F_ARRAY* array = allot_array(type, capacity);
	for(i = 0; i < capacity; i++)
		put(AREF(array,i),fill);
	return array;
}

void primitive_array(void)
{
	CELL size = to_fixnum(dpop());
	maybe_gc(array_size(size));
	dpush(tag_object(array(ARRAY_TYPE,size,F)));
}

void primitive_tuple(void)
{
	CELL size = to_fixnum(dpop());
	maybe_gc(array_size(size));
	dpush(tag_object(array(TUPLE_TYPE,size,F)));
}

void primitive_byte_array(void)
{
	CELL size = to_fixnum(dpop());
	maybe_gc(array_size(size));
	dpush(tag_object(array(BYTE_ARRAY_TYPE,size,0)));
}

/* see note about fill in array() */
F_ARRAY* resize_array(F_ARRAY* array, CELL capacity, CELL fill)
{
	int i;
	F_ARRAY* new_array;
	
	CELL to_copy = array_capacity(array);
	if(capacity < to_copy)
		to_copy = capacity;
	
	new_array = allot_array(untag_header(array->header),capacity);
	
	memcpy(new_array + 1,array + 1,to_copy * CELLS);
	
	for(i = to_copy; i < capacity; i++)
		put(AREF(new_array,i),fill);

	return new_array;
}

void primitive_resize_array(void)
{
	F_ARRAY* array;
	CELL capacity = to_fixnum(dpeek2());
	maybe_gc(array_size(capacity));
	array = untag_array_fast(dpop());
	drepl(tag_object(resize_array(array,capacity,F)));
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
