#include "factor.h"

F_VECTOR* vector(F_FIXNUM capacity)
{
	F_VECTOR* vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = tag_fixnum(0);
	vector->array = tag_object(array(ARRAY_TYPE,capacity,F));
	return vector;
}

void primitive_vector(void)
{
	CELL size = to_fixnum(dpeek());
	maybe_gc(array_size(size) + sizeof(F_VECTOR));
	drepl(tag_object(vector(size)));
}

void primitive_array_to_vector(void)
{
	F_ARRAY *array;
	F_VECTOR *vector;
	maybe_gc(sizeof(F_VECTOR));
	array = untag_array(dpeek());
	vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = array->capacity;
	vector->array = tag_object(array);
	drepl(tag_object(vector));
}

void fixup_vector(F_VECTOR* vector)
{
	data_fixup(&vector->array);
}

void collect_vector(F_VECTOR* vector)
{
	copy_handle(&vector->array);
}
