typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;

#ifdef _WIN64
	typedef long long F_FIXNUM;
	typedef unsigned long long CELL;
#else
	typedef long F_FIXNUM;
	typedef unsigned long CELL;
#endif

#define CELLS ((signed)sizeof(CELL))

/* must always be 16 bits */
#define CHARS ((signed)sizeof(u16))

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

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

typedef struct {
	CELL header;
	/* tagged */
	CELL capacity;
} F_ARRAY;

typedef struct {
	/* always tag_header(VECTOR_TYPE) */
	CELL header;
	/* tagged */
	CELL top;
	/* tagged */
	CELL array;
} F_VECTOR;

typedef struct {
	CELL header;
	/* tagged num of chars */
	CELL length;
	/* tagged */
	CELL hashcode;
} F_STRING;

typedef struct {
	/* always tag_header(SBUF_TYPE) */
	CELL header;
	/* tagged */
	CELL top;
	/* tagged */
	CELL string;
} F_SBUF;

typedef struct {
	/* always tag_header(HASHTABLE_TYPE) */
	CELL header;
	/* tagged */
	CELL count;
        /* tagged */
        CELL deleted;
	/* tagged */
	CELL array;
} F_HASHTABLE;

typedef struct {
	/* TAGGED header */
	CELL header;
	/* TAGGED hashcode */
	CELL hashcode;
	/* TAGGED word name */
	CELL name;
	/* TAGGED word vocabulary */
	CELL vocabulary;
	/* TAGGED on-disk primitive number */
	CELL primitive;
	/* TAGGED parameter to xt; used for colon definitions */
	CELL def;
	/* TAGGED property hash for library code */
	CELL props;
	/* UNTAGGED execution token: jump here to execute word */
	CELL xt;
} F_WORD;

typedef struct {
	CELL header;
	CELL object;
} F_WRAPPER;

typedef struct {
	CELL header;
	CELL numerator;
	CELL denominator;
} F_RATIO;

typedef struct {
/* C sucks. */
	union {
		CELL header;
		long long padding;
	};
	double n;
} F_FLOAT;

typedef struct {
	CELL header;
	CELL real;
	CELL imaginary;
} F_COMPLEX;

typedef struct {
	CELL header;
	CELL alien;
	CELL displacement;
	bool expired;
} ALIEN;

typedef struct {
	CELL header;
	/* tagged string */
	CELL path;
	/* OS-specific handle */
	void* dll;
} DLL;
