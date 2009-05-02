DEFINE_UNTAG(F_ARRAY,ARRAY_TYPE,array)

INLINE CELL tag_array(F_ARRAY *array)
{
	return RETAG(array,ARRAY_TYPE);
}

F_ARRAY *allot_array(CELL capacity, CELL fill);
F_BYTE_ARRAY *allot_byte_array(CELL size);

CELL allot_array_1(CELL obj);
CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

void primitive_array(void);
void primitive_resize_array(void);

/* Macros to simulate a vector in C */
struct F_GROWABLE_ARRAY {
	CELL count;
	CELL array;
};

/* Allocates memory */
INLINE F_GROWABLE_ARRAY make_growable_array(void)
{
	F_GROWABLE_ARRAY result;
	result.count = 0;
	result.array = tag_array(allot_array(2,F));
	return result;
}

#define GROWABLE_ARRAY(result) F_GROWABLE_ARRAY result##_g = make_growable_array(); \
	REGISTER_ROOT(result##_g.array)

void growable_array_add(F_GROWABLE_ARRAY *result, CELL elt);

#define GROWABLE_ARRAY_ADD(result,elt) \
	growable_array_add(&result##_g,elt)

void growable_array_append(F_GROWABLE_ARRAY *result, F_ARRAY *elts);

#define GROWABLE_ARRAY_APPEND(result,elts) \
	growable_array_append(&result##_g,elts)

INLINE void growable_array_trim(F_GROWABLE_ARRAY *array)
{
	array->array = tag_array(reallot_array(untag_array_fast(array->array),array->count));
}

#define GROWABLE_ARRAY_TRIM(result) growable_array_trim(&result##_g)

#define GROWABLE_ARRAY_DONE(result) \
	UNREGISTER_ROOT(result##_g.array); \
	CELL result = result##_g.array;
