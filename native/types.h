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
#define VECTOR_TYPE 9
#define STRING_TYPE 10
#define SBUF_TYPE 11
#define PORT_TYPE 12
#define BIGNUM_TYPE 13
#define FLOAT_TYPE 14
#define DLL_TYPE 15
#define ALIEN_TYPE 16

/* Pseudo-types. For error reporting only. */
#define INTEGER_TYPE 100 /* FIXNUM or BIGNUM */
#define RATIONAL_TYPE 101 /* INTEGER or RATIO */
#define REAL_TYPE 102 /* RATIONAL or FLOAT */
#define NUMBER_TYPE 103 /* COMPLEX or REAL */
#define TEXT_TYPE 104 /* FIXNUM or STRING */

CELL type_of(CELL tagged);
bool typep(CELL type, CELL tagged);

INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

INLINE bool untag_boolean(CELL tagged)
{
	return (tagged == F ? false : true);
}

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,HEADER_TYPE);
}

INLINE CELL untag_header(CELL cell)
{
	CELL type = cell >> TAG_BITS;
	if(TAG(cell) != HEADER_TYPE)
		critical_error("header type check",cell);
	if(type <= HEADER_TYPE && type != WORD_TYPE)
		critical_error("header invariant check",cell);
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
		if(TAG(tagged) != type)
			type_error(type,tagged);
	}
	else if(object_type(tagged) != type)
		type_error(type,tagged);
}

void* allot_object(CELL type, CELL length);
CELL untagged_object_size(CELL pointer);
CELL object_size(CELL pointer);
void primitive_type(void);
void primitive_size(void);
