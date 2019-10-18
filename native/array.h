typedef struct {
	CELL header;
	/* untagged */
	CELL capacity;
} F_ARRAY;

INLINE F_ARRAY* untag_array(CELL tagged)
{
	/* type_check(ARRAY_TYPE,tagged); */
	return (F_ARRAY*)UNTAG(tagged); /* FIXME */
}

F_ARRAY* allot_array(CELL type, F_FIXNUM capacity);
F_ARRAY* array(F_FIXNUM capacity, CELL fill);
F_ARRAY* grow_array(F_ARRAY* array, F_FIXNUM capacity, CELL fill);
F_ARRAY* shrink_array(F_ARRAY* array, F_FIXNUM capacity);

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)

#define ASIZE(pointer) align8(sizeof(F_ARRAY) + \
	((F_ARRAY*)(pointer))->capacity * CELLS)

/* untagged & unchecked */
INLINE CELL array_nth(F_ARRAY* array, CELL index)
{
	return get(AREF(array,index));
}

/* untagged & unchecked  */
INLINE void set_array_nth(F_ARRAY* array, CELL index, CELL value)
{
	put(AREF(array,index),value);
}

void fixup_array(F_ARRAY* array);
void collect_array(F_ARRAY* array);
