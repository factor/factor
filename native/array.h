typedef struct {
	CELL header;
	/* untagged */
	CELL capacity;
} ARRAY;

INLINE ARRAY* untag_array(CELL tagged)
{
	type_check(ARRAY_TYPE,tagged);
	return (ARRAY*)UNTAG(tagged);
}

ARRAY* allot_array(CELL type, FIXNUM capacity);
ARRAY* array(FIXNUM capacity, CELL fill);
ARRAY* grow_array(ARRAY* array, FIXNUM capacity, CELL fill);
ARRAY* shrink_array(ARRAY* array, FIXNUM capacity);

#define AREF(array,index) ((CELL)(array) + sizeof(ARRAY) + (index) * CELLS)

#define ASIZE(pointer) align8(sizeof(ARRAY) + \
	((ARRAY*)(pointer))->capacity * CELLS)

/* untagged & unchecked */
INLINE CELL array_nth(ARRAY* array, CELL index)
{
	return get(AREF(array,index));
}

/* untagged & unchecked  */
INLINE void set_array_nth(ARRAY* array, CELL index, CELL value)
{
	put(AREF(array,index),value);
}

void fixup_array(ARRAY* array);
void collect_array(ARRAY* array);
ARRAY* copy_array(ARRAY* array);
