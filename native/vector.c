#include "factor.h"

F_VECTOR* vector(F_FIXNUM capacity)
{
	F_VECTOR* vector;
	if(capacity < 0)
		general_error(ERROR_NEGATIVE_ARRAY_SIZE,tag_fixnum(capacity));
	vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = tag_fixnum(0);
	vector->array = tag_object(array(ARRAY_TYPE,capacity,F));
	return vector;
}

void primitive_vector(void)
{
	maybe_garbage_collection();
	drepl(tag_object(vector(to_fixnum(dpeek()))));
}

void primitive_to_vector(void)
{
	type_check(VECTOR_TYPE,dpeek());
}

void fixup_vector(F_VECTOR* vector)
{
	data_fixup(&vector->array);
}

void collect_vector(F_VECTOR* vector)
{
	COPY_OBJECT(vector->array);
}
