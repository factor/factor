#define TAG_MASK 7
#define TAG_BITS 3
#define TAG(cell) ((CELL)(cell) & TAG_MASK)
#define RETAG(cell,tag) ((CELL)(cell) | (tag))
#define UNTAG(cell) ((CELL)(cell) & ~TAG_MASK)

/*** Tags ***/
#define FIXNUM_TYPE 0
#define BIGNUM_TYPE 1
#define CONS_TYPE 2
#define OBJECT_TYPE 3
#define RATIO_TYPE 4
#define FLOAT_TYPE 5
#define COMPLEX_TYPE 6
#define HEADER_TYPE 7 /* anything less than this is a tag */
#define GC_COLLECTED 7 /* See gc.c */

/*** Header types ***/

/* Canonical T object */
#define T_TYPE 7
CELL T;

#define ARRAY_TYPE 8

/* Canonical F object */
#define F_TYPE 9
#define F RETAG(0,OBJECT_TYPE)

#define HASHTABLE_TYPE 10
#define VECTOR_TYPE 11
#define STRING_TYPE 12
#define SBUF_TYPE 13
#define PORT_TYPE 14
#define DLL_TYPE 15
#define ALIEN_TYPE 16
#define WORD_TYPE 17
#define TUPLE_TYPE 18

#define TYPE_COUNT 19

INLINE bool headerp(CELL cell)
{
	return (cell != F
		&& TAG(cell) == OBJECT_TYPE
		&& cell < RETAG(TYPE_COUNT << TAG_BITS,OBJECT_TYPE));
}

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,OBJECT_TYPE);
}

INLINE CELL untag_header(CELL cell)
{
	return cell >> TAG_BITS;
}

INLINE CELL tag_object(void* cell)
{
	return RETAG(cell,OBJECT_TYPE);
}

INLINE CELL object_type(CELL tagged)
{
	if(tagged == F)
		return F_TYPE;
	else
		return untag_header(get(UNTAG(tagged)));
}

INLINE void type_check(CELL type, CELL tagged)
{
	if(type < HEADER_TYPE)
	{
		if(TAG(tagged) == type)
			return;
	}
	else if(TAG(tagged) == OBJECT_TYPE
		&& object_type(tagged) == type)
	{
		return;
	}

	type_error(type,tagged);
}
/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL length)
{
	CELL* object = allot(length);
	*object = tag_header(type);
	return object;
}

CELL untagged_object_size(CELL pointer);
CELL object_size(CELL pointer);
void primitive_type(void);

INLINE CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag == OBJECT_TYPE)
		return object_type(tagged);
	else
		return tag;
}

void primitive_slot(void);
void primitive_set_slot(void);
void primitive_integer_slot(void);
void primitive_set_integer_slot(void);
