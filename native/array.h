typedef struct {
	CELL header;
	/* tagged */
	CELL capacity;
} F_ARRAY;

INLINE F_ARRAY* untag_array_fast(CELL tagged)
{
	return (F_ARRAY*)UNTAG(tagged);
}

INLINE F_ARRAY* untag_array(CELL tagged)
{
	type_check(ARRAY_TYPE,tagged);
	return untag_array_fast(tagged);
}

INLINE F_ARRAY* untag_byte_array_fast(CELL tagged)
{
	return (F_ARRAY*)UNTAG(tagged);
}

INLINE CELL array_size(CELL size)
{
	return align8(sizeof(F_ARRAY) + size * CELLS);
}

F_ARRAY *allot_array(CELL type, F_FIXNUM capacity);
F_ARRAY *array(CELL type, F_FIXNUM capacity, CELL fill);
F_ARRAY *byte_array(F_FIXNUM size);

void primitive_array(void);
void primitive_tuple(void);
void primitive_byte_array(void);

F_ARRAY* resize_array(F_ARRAY* array, F_FIXNUM capacity, CELL fill);
void primitive_resize_array(void);
void primitive_array_to_tuple(void);
void primitive_tuple_to_array(void);

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)

INLINE CELL array_capacity(F_ARRAY* array)
{
	return untag_fixnum_fast(array->capacity);
}

void fixup_array(F_ARRAY* array);
void collect_array(F_ARRAY* array);
