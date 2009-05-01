#define INLINE inline static

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

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

#define TAG_MASK 7
#define TAG_BITS 3
#define TAG(cell) ((CELL)(cell) & TAG_MASK)
#define UNTAG(cell) ((CELL)(cell) & ~TAG_MASK)
#define RETAG(cell,tag) (UNTAG(cell) | (tag))

/*** Tags ***/
#define FIXNUM_TYPE 0
#define BIGNUM_TYPE 1
#define ARRAY_TYPE 2
#define FLOAT_TYPE 3
#define QUOTATION_TYPE 4
#define F_TYPE 5
#define OBJECT_TYPE 6
#define TUPLE_TYPE 7

#define HI_TAG_OR_TUPLE_P(cell) (((CELL)(cell) & 6) == 6)
#define HI_TAG_HEADER(cell) (((CELL)(cell) & 1) * CELLS + UNTAG(cell))

/* Canonical F object */
#define F F_TYPE

#define HEADER_TYPE 8 /* anything less than this is a tag */

#define GC_COLLECTED 5 /* can be anything other than FIXNUM_TYPE */

/*** Header types ***/
#define WRAPPER_TYPE 8
#define BYTE_ARRAY_TYPE 9
#define CALLSTACK_TYPE 10
#define STRING_TYPE 11
#define WORD_TYPE 12
#define DLL_TYPE 13
#define ALIEN_TYPE 14

#define TYPE_COUNT 15

/* Not a real type, but F_CODE_BLOCK's type field can be set to this */
#define PIC_TYPE 69

INLINE bool immediate_p(CELL obj)
{
	return (obj == F || TAG(obj) == FIXNUM_TYPE);
}

INLINE F_FIXNUM untag_fixnum_fast(CELL tagged)
{
	return ((F_FIXNUM)tagged) >> TAG_BITS;
}

INLINE CELL tag_fixnum(F_FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

INLINE void *untag_object(CELL tagged)
{
	return (void *)UNTAG(tagged);
}

typedef void *XT;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	CELL header;
	/* tagged */
	CELL capacity;
} F_ARRAY;

typedef F_ARRAY F_BYTE_ARRAY;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	CELL header;
	/* tagged num of chars */
	CELL length;
	/* tagged */
	CELL aux;
	/* tagged */
	CELL hashcode;
} F_STRING;

/* The compiled code heap is structured into blocks. */
typedef enum
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
} F_BLOCK_STATUS;

typedef struct _F_BLOCK
{
	char status; /* free or allocated? */
	char type; /* this is WORD_TYPE or QUOTATION_TYPE */
	char last_scan; /* the youngest generation in which this block's literals may live */
	char needs_fixup; /* is this a new block that needs full fixup? */

	/* In bytes, includes this header */
	CELL size;

	/* Used during compaction */
	struct _F_BLOCK *forwarding;
} F_BLOCK;

typedef struct _F_FREE_BLOCK
{
	F_BLOCK block;

	/* Filled in on image load */
	struct _F_FREE_BLOCK *next_free;
} F_FREE_BLOCK;

typedef struct
{
	F_BLOCK block;
	CELL literals; /* # bytes */
	CELL relocation; /* tagged pointer to byte-array or f */
} F_CODE_BLOCK;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	/* TAGGED header */
	CELL header;
	/* TAGGED hashcode */
	CELL hashcode;
	/* TAGGED word name */
	CELL name;
	/* TAGGED word vocabulary */
	CELL vocabulary;
	/* TAGGED definition */
	CELL def;
	/* TAGGED property assoc for library code */
	CELL props;
	/* TAGGED alternative entry point for direct non-tail calls. Used for inline caching */
	CELL direct_entry_def;
	/* TAGGED call count for profiling */
	CELL counter;
	/* TAGGED machine code for sub-primitive */
	CELL subprimitive;
	/* UNTAGGED execution token: jump here to execute word */
	XT xt;
	/* UNTAGGED compiled code block */
	F_CODE_BLOCK *code;
	/* UNTAGGED profiler stub */
	F_CODE_BLOCK *profiling;
} F_WORD;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	CELL header;
	CELL object;
} F_WRAPPER;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
/* We use a union here to force the float value to be aligned on an
8-byte boundary. */
	union {
		CELL header;
		long long padding;
	};
	double n;
} F_FLOAT;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	CELL header;
	/* tagged */
	CELL array;
	/* tagged */
	CELL compiledp;
	/* tagged */
	CELL cached_effect;
	/* tagged */
	CELL cache_counter;
	/* UNTAGGED */
	XT xt;
	/* UNTAGGED compiled code block */
	F_CODE_BLOCK *code;
} F_QUOTATION;

/* Assembly code makes assumptions about the layout of this struct */
typedef struct {
	CELL header;
	/* tagged */
	CELL alien;
	/* tagged */
	CELL expired;
	/* untagged */
	CELL displacement;
} F_ALIEN;

typedef struct {
	CELL header;
	/* tagged byte array holding a C string */
	CELL path;
	/* OS-specific handle */
	void *dll;
} F_DLL;

typedef struct {
	CELL header;
	/* tagged */
	CELL length;
} F_CALLSTACK;

typedef struct
{
	XT xt;
	/* Frame size in bytes */
	CELL size;
} F_STACK_FRAME;

/* These are really just arrays, but certain elements have special
significance */
typedef struct
{
	CELL header;
	/* tagged */
	CELL capacity;
	/* tagged */
	CELL class;
	/* tagged fixnum */
	CELL size;
	/* tagged fixnum */
	CELL echelon;
} F_TUPLE_LAYOUT;

typedef struct
{
	CELL header;
	/* tagged layout */
	CELL layout;
} F_TUPLE;
