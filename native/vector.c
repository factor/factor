#include "factor.h"

F_VECTOR* vector(F_FIXNUM capacity)
{
	F_VECTOR* vector = allot_object(VECTOR_TYPE,sizeof(F_VECTOR));
	vector->top = 0;
	vector->array = tag_object(array(capacity,F));
	return vector;
}

void primitive_vector(void)
{
	maybe_garbage_collection();
	drepl(tag_object(vector(to_fixnum(dpeek()))));
}

void primitive_vector_length(void)
{
	drepl(tag_fixnum(untag_vector(dpeek())->top));
}

void primitive_set_vector_length(void)
{
	F_VECTOR* vector;
	F_FIXNUM length;
	F_ARRAY* array;

	maybe_garbage_collection();

	vector = untag_vector(dpop());
	length = to_fixnum(dpop());
	array = untag_array(vector->array);

	if(length < 0)
		range_error(tag_object(vector),0,to_fixnum(length),vector->top);
	vector->top = length;
	if(length > array->capacity)
		vector->array = tag_object(grow_array(array,length,F));
}

void primitive_vector_nth(void)
{
	F_VECTOR* vector = untag_vector(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= vector->top)
		range_error(tag_object(vector),0,to_fixnum(index),vector->top);
	dpush(array_nth(untag_array(vector->array),index));
}

void vector_ensure_capacity(F_VECTOR* vector, CELL index)
{
	F_ARRAY* array = untag_array(vector->array);
	CELL capacity = array->capacity;
	if(index >= capacity)
		array = grow_array(array,index * 2 + 1,F);
	vector->top = index + 1;
	vector->array = tag_object(array);
}

void primitive_set_vector_nth(void)
{
	F_VECTOR* vector;
	F_FIXNUM index;
	CELL value;

	maybe_garbage_collection();

	vector = untag_vector(dpop());
	index = to_fixnum(dpop());
	value = dpop();

	if(index < 0)
		range_error(tag_object(vector),0,to_fixnum(index),vector->top);
	else if(index >= vector->top)
		vector_ensure_capacity(vector,index);

	/* the following does not check bounds! */
	set_array_nth(untag_array(vector->array),index,value);
}

void fixup_vector(F_VECTOR* vector)
{
	fixup(&vector->array);
}

void collect_vector(F_VECTOR* vector)
{
	copy_object(&vector->array);
}
