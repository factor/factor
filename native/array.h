typedef struct {
	CELL header;
	/* tagged */
	CELL capacity;
} F_ARRAY;

INLINE F_ARRAY* untag_array(CELL tagged)
{
	type_check(ARRAY_TYPE,tagged);
	return (F_ARRAY*)UNTAG(tagged);
}

F_ARRAY* allot_array(CELL type, CELL capacity);
F_ARRAY* array(CELL type, CELL capacity, CELL fill);
void primitive_array(void);
void primitive_tuple(void);
F_ARRAY* grow_array(F_ARRAY* array, CELL capacity, CELL fill);
void primitive_grow_array(void);
F_ARRAY* shrink_array(F_ARRAY* array, CELL capacity);

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)

INLINE CELL array_capacity(F_ARRAY* array)
{
	return untag_fixnum_fast(array->capacity);
}

void fixup_array(F_ARRAY* array);
void collect_array(F_ARRAY* array);
