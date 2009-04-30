#include "master.h"

/* the array is full of undefined data, and must be correctly filled before the
next GC. size is in cells */
F_ARRAY *allot_array_internal(CELL type, CELL capacity)
{
	F_ARRAY *array = allot_object(type,array_size(capacity));
	array->capacity = tag_fixnum(capacity);
	return array;
}

/* make a new array with an initial element */
F_ARRAY *allot_array(CELL type, CELL capacity, CELL fill)
{
	int i;
	REGISTER_ROOT(fill);
	F_ARRAY* array = allot_array_internal(type, capacity);
	UNREGISTER_ROOT(fill);
	if(fill == 0)
		memset((void*)AREF(array,0),'\0',capacity * CELLS);
	else
	{
		/* No need for write barrier here. Either the object is in
		the nursery, or it was allocated directly in tenured space
		and the write barrier is already hit for us in that case. */
		for(i = 0; i < capacity; i++)
			put(AREF(array,i),fill);
	}
	return array;
}

/* push a new array on the stack */
void primitive_array(void)
{
	CELL initial = dpop();
	CELL size = unbox_array_size();
	dpush(tag_array(allot_array(ARRAY_TYPE,size,initial)));
}

CELL allot_array_1(CELL obj)
{
	REGISTER_ROOT(obj);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,1);
	UNREGISTER_ROOT(obj);
	set_array_nth(a,0,obj);
	return tag_array(a);
}

CELL allot_array_2(CELL v1, CELL v2)
{
	REGISTER_ROOT(v1);
	REGISTER_ROOT(v2);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,2);
	UNREGISTER_ROOT(v2);
	UNREGISTER_ROOT(v1);
	set_array_nth(a,0,v1);
	set_array_nth(a,1,v2);
	return tag_array(a);
}

CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4)
{
	REGISTER_ROOT(v1);
	REGISTER_ROOT(v2);
	REGISTER_ROOT(v3);
	REGISTER_ROOT(v4);
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,4);
	UNREGISTER_ROOT(v4);
	UNREGISTER_ROOT(v3);
	UNREGISTER_ROOT(v2);
	UNREGISTER_ROOT(v1);
	set_array_nth(a,0,v1);
	set_array_nth(a,1,v2);
	set_array_nth(a,2,v3);
	set_array_nth(a,3,v4);
	return tag_array(a);
}

static bool reallot_array_in_place_p(F_ARRAY *array, CELL capacity)
{
	return in_zone(&nursery,(CELL)array) && capacity <= array_capacity(array);
}

F_ARRAY *reallot_array(F_ARRAY *array, CELL capacity)
{
#ifdef FACTOR_DEBUG
	CELL header = untag_header(array->header);
	assert(header == ARRAY_TYPE || header == BIGNUM_TYPE);
#endif

	if(reallot_array_in_place_p(array,capacity))
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
		F_ARRAY* new_array = allot_array_internal(untag_header(array->header),capacity);
		UNREGISTER_UNTAGGED(array);
	
		memcpy(new_array + 1,array + 1,to_copy * CELLS);
		memset((char *)AREF(new_array,to_copy),'\0',(capacity - to_copy) * CELLS);

		return new_array;
	}
}

void primitive_resize_array(void)
{
	F_ARRAY* array = untag_array(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag_array(reallot_array(array,capacity)));
}

void growable_array_add(F_GROWABLE_ARRAY *array, CELL elt)
{
	F_ARRAY *underlying = untag_object(array->array);
	REGISTER_ROOT(elt);

	if(array->count == array_capacity(underlying))
	{
		underlying = reallot_array(underlying,array->count * 2);
		array->array = tag_array(underlying);
	}

	UNREGISTER_ROOT(elt);
	set_array_nth(underlying,array->count++,elt);
}

void growable_array_append(F_GROWABLE_ARRAY *array, F_ARRAY *elts)
{
	REGISTER_UNTAGGED(elts);

	F_ARRAY *underlying = untag_object(array->array);

	CELL elts_size = array_capacity(elts);
	CELL new_size = array->count + elts_size;

	if(new_size >= array_capacity(underlying))
	{
		underlying = reallot_array(underlying,new_size * 2);
		array->array = tag_array(underlying);
	}

	UNREGISTER_UNTAGGED(elts);

	write_barrier(array->array);

	memcpy((void *)AREF(underlying,array->count),
	       (void *)AREF(elts,0),
	       elts_size * CELLS);

	array->count += elts_size;
}
