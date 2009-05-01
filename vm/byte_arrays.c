#include "master.h"

/* must fill out array before next GC */
F_BYTE_ARRAY *allot_byte_array_internal(CELL size)
{
	F_BYTE_ARRAY *array = allot_object(BYTE_ARRAY_TYPE,
		byte_array_size(size));
	array->capacity = tag_fixnum(size);
	return array;
}

/* size is in bytes this time */
F_BYTE_ARRAY *allot_byte_array(CELL size)
{
	F_BYTE_ARRAY *array = allot_byte_array_internal(size);
	memset(array + 1,0,size);
	return array;
}

/* push a new byte array on the stack */
void primitive_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array(size)));
}

void primitive_uninitialized_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array_internal(size)));
}

static bool reallot_byte_array_in_place_p(F_BYTE_ARRAY *array, CELL capacity)
{
	return in_zone(&nursery,(CELL)array) && capacity <= array_capacity(array);
}

F_BYTE_ARRAY *reallot_byte_array(F_BYTE_ARRAY *array, CELL capacity)
{
#ifdef FACTOR_DEBUG
	assert(untag_header(array->header) == BYTE_ARRAY_TYPE);
#endif
	if(reallot_byte_array_in_place_p(array,capacity))
	{
		array->capacity = tag_fixnum(capacity);
		return array;
	}
	else
	{
		CELL to_copy = array_capacity(array);
		if(capacity < to_copy)
		to_copy = capacity;

		REGISTER_UNTAGGED(array);
		F_BYTE_ARRAY *new_array = allot_byte_array_internal(capacity);
		UNREGISTER_UNTAGGED(array);

		memcpy(new_array + 1,array + 1,to_copy);

		return new_array;
	}
}

void primitive_resize_byte_array(void)
{
	F_BYTE_ARRAY* array = untag_byte_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_byte_array(array,capacity)));
}

void growable_byte_array_append(F_GROWABLE_BYTE_ARRAY *array, void *elts, CELL len)
{
	CELL new_size = array->count + len;
	F_BYTE_ARRAY *underlying = untag_object(array->array);

	if(new_size >= byte_array_capacity(underlying))
	{
		underlying = reallot_byte_array(underlying,new_size * 2);
		array->array = tag_object(underlying);
	}

	memcpy((void *)BREF(underlying,array->count),elts,len);

	array->count += len;
}
