DEFINE_UNTAG(F_BYTE_ARRAY,BYTE_ARRAY_TYPE,byte_array)

INLINE CELL byte_array_capacity(F_BYTE_ARRAY *array)
{
	return untag_fixnum_fast(array->capacity);
}

INLINE CELL byte_array_size(CELL size)
{
	return sizeof(F_BYTE_ARRAY) + size;
}

F_BYTE_ARRAY *allot_byte_array(CELL size);
F_BYTE_ARRAY *allot_byte_array_internal(CELL size);
F_BYTE_ARRAY *reallot_byte_array(F_BYTE_ARRAY *array, CELL capacity);

void primitive_byte_array(void);
void primitive_uninitialized_byte_array(void);
void primitive_resize_byte_array(void);

/* Macros to simulate a byte vector in C */
typedef struct {
	CELL count;
	CELL array;
} F_GROWABLE_BYTE_ARRAY;

INLINE F_GROWABLE_BYTE_ARRAY make_growable_byte_array(void)
{
	F_GROWABLE_BYTE_ARRAY result;
	result.count = 0;
	result.array = tag_object(allot_byte_array(100));
	return result;
}

void growable_byte_array_append(F_GROWABLE_BYTE_ARRAY *result, void *elts, CELL len);

INLINE void growable_byte_array_trim(F_GROWABLE_BYTE_ARRAY *byte_array)
{
	byte_array->array = tag_object(reallot_byte_array(untag_object(byte_array->array),byte_array->count));
}
