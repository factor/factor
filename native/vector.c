#include "factor.h"

VECTOR* vector(FIXNUM capacity)
{
	VECTOR* vector = allot_object(VECTOR_TYPE,sizeof(VECTOR));
	vector->top = 0;
	vector->array = array(capacity,F);
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
	VECTOR* vector;
	FIXNUM length;

	maybe_garbage_collection();

	vector = untag_vector(dpop());
	length = to_fixnum(dpop());
	if(length < 0)
		range_error(tag_object(vector),length,vector->top);
	vector->top = length;
	if(length > vector->array->capacity)
		vector->array = grow_array(vector->array,length,F);
}

void primitive_vector_nth(void)
{
	VECTOR* vector = untag_vector(dpop());
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= vector->top)
		range_error(tag_object(vector),index,vector->top);
	dpush(array_nth(vector->array,index));
}

void vector_ensure_capacity(VECTOR* vector, CELL index)
{
	ARRAY* array = vector->array;
	CELL capacity = array->capacity;
	if(index >= capacity)
		array = grow_array(array,index * 2 + 1,F);
	vector->top = index + 1;
	vector->array = array;
}

void primitive_set_vector_nth(void)
{
	VECTOR* vector;
	FIXNUM index;
	CELL value;

	maybe_garbage_collection();

	vector = untag_vector(dpop());
	index = to_fixnum(dpop());
	value = dpop();

	if(index < 0)
		range_error(tag_object(vector),index,vector->top);
	else if(index >= vector->top)
		vector_ensure_capacity(vector,index);

	/* the following does not check bounds! */
	set_array_nth(vector->array,index,value);
}

void fixup_vector(VECTOR* vector)
{
	vector->array = (ARRAY*)((CELL)vector->array
		+ (active.base - relocation_base));
}

void collect_vector(VECTOR* vector)
{
	vector->array = copy_array(vector->array);
}
