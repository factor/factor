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

F_ARRAY* allot_array(CELL type, CELL capacity);
F_ARRAY* array(CELL capacity, CELL fill);
F_ARRAY* grow_array(F_ARRAY* array, CELL capacity, CELL fill);
void primitive_grow_array(void);
F_ARRAY* shrink_array(F_ARRAY* array, CELL capacity);

#define AREF(array,index) ((CELL)(array) + sizeof(F_ARRAY) + (index) * CELLS)

#define ASIZE(pointer) align8(sizeof(F_ARRAY) + \
	((F_ARRAY*)(pointer))->capacity * CELLS)

void fixup_array(F_ARRAY* array);
void collect_array(F_ARRAY* array);
