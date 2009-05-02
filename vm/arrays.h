DEFINE_UNTAG(F_ARRAY,ARRAY_TYPE,array)

INLINE CELL tag_array(F_ARRAY *array)
{
	return RETAG(array,ARRAY_TYPE);
}

/* Inline functions */
INLINE CELL array_size(CELL size)
{
	return sizeof(F_ARRAY) + size * CELLS;
}

INLINE CELL array_capacity(F_ARRAY* array)
{
#ifdef FACTOR_DEBUG
	CELL header = untag_header(array->header);
	assert(header == ARRAY_TYPE || header == BIGNUM_TYPE || header == BYTE_ARRAY_TYPE);
#endif
	return array->capacity >> TAG_BITS;
}

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)
#define UNAREF(array,ptr) (((CELL)(ptr)-(CELL)(array)-sizeof(F_ARRAY)) / CELLS)

INLINE CELL array_nth(F_ARRAY *array, CELL slot)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(untag_header(array->header) == ARRAY_TYPE);
#endif
	return get(AREF(array,slot));
}

INLINE void set_array_nth(F_ARRAY *array, CELL slot, CELL value)
{
#ifdef FACTOR_DEBUG
	assert(slot < array_capacity(array));
	assert(untag_header(array->header) == ARRAY_TYPE);
#endif
	put(AREF(array,slot),value);
	write_barrier((CELL)array);
}

F_ARRAY *allot_array_internal(CELL type, CELL capacity);
F_ARRAY *allot_array(CELL type, CELL capacity, CELL fill);
F_BYTE_ARRAY *allot_byte_array(CELL size);

CELL allot_array_1(CELL obj);
CELL allot_array_2(CELL v1, CELL v2);
CELL allot_array_4(CELL v1, CELL v2, CELL v3, CELL v4);

void primitive_array(void);

F_ARRAY *reallot_array(F_ARRAY* array, CELL capacity);
void primitive_resize_array(void);

/* Macros to simulate a vector in C */
typedef struct {
	CELL count;
	CELL array;
} F_GROWABLE_ARRAY;

/* Allocates memory */
INLINE F_GROWABLE_ARRAY make_growable_array(void)
{
	F_GROWABLE_ARRAY result;
	result.count = 0;
	result.array = tag_array(allot_array(ARRAY_TYPE,100,F));
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
	array->array = tag_array(reallot_array(untag_object(array->array),array->count));
}

#define GROWABLE_ARRAY_TRIM(result) growable_array_trim(&result##_g)

#define GROWABLE_ARRAY_DONE(result) \
	UNREGISTER_ROOT(result##_g.array); \
	CELL result = result##_g.array;
