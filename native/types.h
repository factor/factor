#define TAG_MASK 7
#define TAG_BITS 3
#define TAG(cell) ((CELL)(cell) & TAG_MASK)
#define RETAG(cell,tag) ((CELL)(cell) | (tag))
#define UNTAG(cell) ((CELL)(cell) & ~TAG_MASK)

/*** Tags ***/
#define FIXNUM_TYPE 0
#define WORD_TYPE 1
#define CONS_TYPE 2
#define OBJECT_TYPE 3
#define RATIO_TYPE 4
#define COMPLEX_TYPE 5
#define HEADER_TYPE 6
#define GC_COLLECTED 7 /* See gc.c */

/*** Header types ***/

/* Canonical F object */
#define F_TYPE 6
#define F RETAG(0,OBJECT_TYPE)

/* Canonical T object */
#define T_TYPE 7
CELL T;

#define ARRAY_TYPE 8
#define BIGNUM_TYPE 9
#define FLOAT_TYPE 10
#define VECTOR_TYPE 11
#define STRING_TYPE 12
#define SBUF_TYPE 13
#define PORT_TYPE 14
#define DLL_TYPE 15
#define ALIEN_TYPE 16

#define TYPE_COUNT 17

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,HEADER_TYPE);
}

/* #define HEADER_DEBUG */

INLINE CELL untag_header(CELL cell)
{
	CELL type = cell >> TAG_BITS;
#ifdef HEADER_DEBUG
	if(TAG(cell) != HEADER_TYPE)
		critical_error("header type check",cell);
	if(type <= HEADER_TYPE && type != WORD_TYPE)
		critical_error("header invariant check",cell);
#endif
	return type;
}

INLINE CELL tag_object(void* cell)
{
	return RETAG(cell,OBJECT_TYPE);
}

INLINE CELL object_type(CELL tagged)
{
	return untag_header(get(UNTAG(tagged)));
}

INLINE void type_check(CELL type, CELL tagged)
{
	if(type < HEADER_TYPE)
	{
#ifdef HEADER_DEBUG
		if(TAG(tagged) == WORD_TYPE && object_type(tagged) != WORD_TYPE)
			critical_error("word header check",tagged);
#endif
		if(TAG(tagged) == type)
			return;
	}
	else if(tagged == F)
	{
		if(type == F_TYPE)
			return;
	}
	else if(TAG(tagged) == OBJECT_TYPE
		&& object_type(tagged) == type)
	{
		return;
	}

	type_error(type,tagged);
}

void* allot_object(CELL type, CELL length);
CELL untagged_object_size(CELL pointer);
CELL object_size(CELL pointer);
void primitive_type(void);

INLINE CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag == OBJECT_TYPE)
	{
		if(tagged == F)
			return F_TYPE;
		else
			return untag_header(get(UNTAG(tagged)));
	}
	else
		return tag;
}

void primitive_slot(void);
void primitive_set_slot(void);
void primitive_integer_slot(void);
void primitive_set_integer_slot(void);
