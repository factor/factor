#include "factor.h"

/* untagged */
ARRAY* allot_array(CELL type, CELL capacity)
{
	ARRAY* array = allot_object(type,sizeof(ARRAY) + capacity * CELLS);
	array->capacity = capacity;
	return array;
}

/* untagged */
ARRAY* array(CELL capacity, CELL fill)
{
	int i;

	ARRAY* array = allot_array(ARRAY_TYPE, capacity);

	for(i = 0; i < capacity; i++)
		put(AREF(array,i),fill);

	return array;
}

ARRAY* grow_array(ARRAY* array, CELL capacity, CELL fill)
{
	/* later on, do an optimization: if end of array is here, just grow */
	int i;

	ARRAY* new_array = allot_array(untag_header(array->header),capacity);

	memcpy(new_array + 1,array + 1,array->capacity * CELLS);

	for(i = array->capacity; i < capacity; i++)
		put(AREF(new_array,i),fill);

	return new_array;
}

ARRAY* shrink_array(ARRAY* array, CELL capacity)
{
	ARRAY* new_array = allot_array(untag_header(array->header),capacity);
	memcpy(new_array + 1,array + 1,capacity * CELLS);
	return new_array;
}

void fixup_array(ARRAY* array)
{
	int i = 0;
	for(i = 0; i < array->capacity; i++)
		fixup((void*)AREF(array,i));
}

void collect_array(ARRAY* array)
{
	int i = 0;
	for(i = 0; i < array->capacity; i++)
		copy_object((void*)AREF(array,i));
}

/* copy an array to newspace */
ARRAY* copy_array(ARRAY* array)
{
	return copy_untagged_object(array,ASIZE(array));
}
