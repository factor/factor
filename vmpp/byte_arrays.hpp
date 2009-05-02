DEFINE_UNTAG(F_BYTE_ARRAY,BYTE_ARRAY_TYPE,byte_array)

F_BYTE_ARRAY *allot_byte_array(CELL size);

void primitive_byte_array(void);
void primitive_uninitialized_byte_array(void);
void primitive_resize_byte_array(void);

/* Macros to simulate a byte vector in C */
struct F_GROWABLE_BYTE_ARRAY {
	CELL count;
	CELL array;
};

INLINE F_GROWABLE_BYTE_ARRAY make_growable_byte_array(void)
{
	F_GROWABLE_BYTE_ARRAY result;
	result.count = 0;
	result.array = tag_object(allot_byte_array(2));
	return result;
}

void growable_byte_array_append(F_GROWABLE_BYTE_ARRAY *result, void *elts, CELL len);

INLINE void growable_byte_array_trim(F_GROWABLE_BYTE_ARRAY *byte_array)
{
	byte_array->array = tag_object(reallot_array(untag_byte_array_fast(byte_array->array),byte_array->count));
}
