typedef struct {
    CELL start;
    CELL size;
} BOUNDED_BLOCK;

/* set up guard pages to check for under/overflow.
size must be a multiple of the page size */
BOUNDED_BLOCK *alloc_bounded_block(CELL size);
void dealloc_bounded_block(BOUNDED_BLOCK *block);

/* macros for reading/writing memory, useful when working around
C's type system */
INLINE CELL get(CELL where)
{
	return *((CELL*)where);
}

INLINE void put(CELL where, CELL what)
{
	*((CELL*)where) = what;
}

INLINE u16 cget(CELL where)
{
	return *((u16*)where);
}

INLINE void cput(CELL where, u16 what)
{
	*((u16*)where) = what;
}

INLINE CELL align8(CELL a)
{
	return (a + 7) & ~7;
}

#define TAG_MASK 7
#define TAG_BITS 3
#define TAG(cell) ((CELL)(cell) & TAG_MASK)
#define RETAG(cell,tag) ((CELL)(cell) | (tag))
#define UNTAG(cell) ((CELL)(cell) & ~TAG_MASK)

/*** Tags ***/
#define FIXNUM_TYPE 0
#define BIGNUM_TYPE 1
#define WORD_TYPE 2
#define OBJECT_TYPE 3
#define RATIO_TYPE 4
#define FLOAT_TYPE 5
#define COMPLEX_TYPE 6
#define WRAPPER_TYPE 7

#define HEADER_TYPE 7 /* anything less than or equal to this is a tag */
#define GC_COLLECTED 0 /* See gc.c */

/*** Header types ***/
#define ARRAY_TYPE 8

/* Canonical F object */
#define F_TYPE 9
#define F RETAG(0,OBJECT_TYPE)

#define HASHTABLE_TYPE 10
#define VECTOR_TYPE 11
#define STRING_TYPE 12
#define SBUF_TYPE 13
#define QUOTATION_TYPE 14
#define DLL_TYPE 15
#define ALIEN_TYPE 16
#define TUPLE_TYPE 17
#define BYTE_ARRAY_TYPE 18

#define TYPE_COUNT 19

/* Canonical T object. It's just a word */
CELL T;

#define SLOT(obj,slot) ((obj) + (slot) * CELLS)

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,OBJECT_TYPE);
}

INLINE CELL untag_header(CELL cell)
{
	/* if((cell & TAG_MASK) != OBJECT_TYPE)
		critical_error("Corrupt object header",cell); */

	return cell >> TAG_BITS;
}

INLINE CELL tag_object(void* cell)
{
	return RETAG(cell,OBJECT_TYPE);
}

INLINE CELL object_type(CELL tagged)
{
	return untag_header(get(UNTAG(tagged)));
}

INLINE CELL type_of(CELL tagged)
{
	if(tagged == F)
		return F_TYPE;
	else if(TAG(tagged) == FIXNUM_TYPE)
		return FIXNUM_TYPE;
	else
		return object_type(tagged);
}

INLINE void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type)
		type_error(type,tagged);
}

CELL untagged_object_size(CELL pointer);
CELL object_size(CELL pointer);
void primitive_room(void);
void primitive_type(void);
void primitive_tag(void);
void primitive_slot(void);
void primitive_set_slot(void);
void primitive_integer_slot(void);
void primitive_set_integer_slot(void);
void primitive_address(void);
void primitive_size(void);
CELL clone(CELL obj);
void primitive_clone(void);
void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);
