#include "master.hpp"

F_BYTE_ARRAY *allot_byte_array(CELL size)
{
	F_BYTE_ARRAY *array = allot_array_internal<F_BYTE_ARRAY>(size);
	memset(array + 1,0,size);
	return array;
}

void primitive_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_byte_array(size)));
}

void primitive_uninitialized_byte_array(void)
{
	CELL size = unbox_array_size();
	dpush(tag_object(allot_array_internal<F_BYTE_ARRAY>(size)));
}

void primitive_resize_byte_array(void)
{
	F_BYTE_ARRAY *array = untag_byte_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_object(reallot_array(array,capacity)));
}

void growable_byte_array_append(F_GROWABLE_BYTE_ARRAY *array, void *elts, CELL len)
{
	CELL new_size = array->count + len;
	F_BYTE_ARRAY *underlying = untag_byte_array_fast(array->array);

	if(new_size >= array_capacity(underlying))
	{
		underlying = reallot_array(underlying,new_size * 2);
		array->array = tag_object(underlying);
	}

	memcpy((void *)BREF(underlying,array->count),elts,len);

	array->count += len;
}
