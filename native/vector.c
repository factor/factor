#include "factor.h"

VECTOR* vector(FIXNUM capacity)
{
	VECTOR* vector = allot_object(VECTOR_TYPE,sizeof(VECTOR));
	vector->top = 0;
	vector->array = array(capacity,F);
	return vector;
}

void primitive_vectorp(void)
{
	check_non_empty(env.dt);
	env.dt = tag_boolean(typep(VECTOR_TYPE,env.dt));
}

void primitive_vector(void)
{
	env.dt = tag_object(vector(to_fixnum(env.dt)));
}

void primitive_vector_length(void)
{
	env.dt = tag_fixnum(untag_vector(env.dt)->top);
}

void primitive_set_vector_length(void)
{
	VECTOR* vector = untag_vector(env.dt);
	FIXNUM length = to_fixnum(dpop());
	vector->top = length;
	if(length < 0)
		range_error(tag_object(vector),length,vector->top);
	else if(length > vector->array->capacity)
		vector->array = grow_array(vector->array,length,F);
	env.dt = dpop(); /* don't forget this! */
}

void primitive_vector_nth(void)
{
	VECTOR* vector = untag_vector(env.dt);
	CELL index = to_fixnum(dpop());

	if(index < 0 || index >= vector->top)
		range_error(tag_object(vector),index,vector->top);
	env.dt = array_nth(vector->array,index);
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
	VECTOR* vector = untag_vector(env.dt);
	FIXNUM index = to_fixnum(dpop());
	CELL value = dpop();
	check_non_empty(value);

	if(index < 0)
		range_error(tag_object(vector),index,vector->top);
	else if(index >= vector->top)
		vector_ensure_capacity(vector,index);

	/* the following does not check bounds! */
	set_array_nth(vector->array,index,value);
	
	env.dt = dpop(); /* don't forget this! */
}

void fixup_vector(VECTOR* vector)
{
	vector->array = (ARRAY*)((CELL)vector->array
		+ (active->base - relocation_base));
}

void collect_vector(VECTOR* vector)
{
	vector->array = copy_array(vector->array);
}
