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
#define HEADER_TYPE 4
#define XT_TYPE 5
#define GC_COLLECTED 6 /* See gc.c */

/*** Header types ***/

/* Canonical F object */
#define F_TYPE 6
CELL F;

/* Canonical T object */
#define T_TYPE 7
CELL T;

/* Empty stack marker */
#define EMPTY_TYPE 8
CELL empty;

#define ARRAY_TYPE 9
#define VECTOR_TYPE 10
#define STRING_TYPE 11
#define SBUF_TYPE 12
#define HANDLE_TYPE 13
#define BIGNUM_TYPE 14

bool typep(CELL type, CELL tagged);
CELL type_of(CELL tagged);
void type_check(CELL type, CELL tagged);

INLINE void check_non_empty(CELL cell)
{
	if(cell == empty)
		general_error(ERROR_UNDERFLOW,F);
}

INLINE CELL tag_boolean(CELL untagged)
{
	return (untagged == false ? F : T);
}

INLINE bool untag_boolean(CELL tagged)
{
	check_non_empty(tagged);
	return (tagged == F ? false : true);
}

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,HEADER_TYPE);
}

INLINE CELL untag_header(CELL cell)
{
	if(TAG(cell) != HEADER_TYPE)
		critical_error("header type check",cell);
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

CELL allot_object(CELL type, CELL length);
CELL untagged_object_size(CELL pointer);
CELL object_size(CELL pointer);
