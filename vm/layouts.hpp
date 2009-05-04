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

inline static CELL align(CELL a, CELL b)
{
	return (a + (b-1)) & ~(b-1);
}

#define align8(a) align(a,8)
#define align_page(a) align(a,getpagesize())

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

inline static bool immediate_p(CELL obj)
{
	return (obj == F || TAG(obj) == FIXNUM_TYPE);
}

inline static F_FIXNUM untag_fixnum(CELL tagged)
{
#ifdef FACTOR_DEBUG
	assert(TAG(tagged) == FIXNUM_TYPE);
#endif
	return ((F_FIXNUM)tagged) >> TAG_BITS;
}

inline static CELL tag_fixnum(F_FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

inline static CELL tag_for(CELL type)
{
	return type < HEADER_TYPE ? type : OBJECT_TYPE;
}

typedef void *XT;

class F_OBJECT;

struct F_HEADER {
	CELL header;

	F_HEADER(CELL header_) : header(header_ << TAG_BITS) {}

	void check_header() {
#ifdef FACTOR_DEBUG
		assert(TAG(header) == FIXNUM_TYPE && untag_fixnum(header) < TYPE_COUNT);
#endif
	}

	CELL hi_tag() {
		check_header();
		return header >> TAG_BITS;
	}

	void set(CELL header_) {
		header = header_ << TAG_BITS;
	}

	bool forwarding_pointer_p() {
		return TAG(header) == GC_COLLECTED;
	}

	F_OBJECT *forwarding_pointer() {
		return (F_OBJECT *)UNTAG(header);
	}

	void forward_to(F_OBJECT *pointer) {
		header = RETAG(pointer,GC_COLLECTED);
	}
};

#define NO_TYPE_CHECK static const CELL type_number = TYPE_COUNT

struct F_OBJECT {
	NO_TYPE_CHECK;
	F_HEADER header;
	CELL *slots() { return (CELL *)this; }
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_ARRAY : public F_OBJECT {
	static const CELL type_number = ARRAY_TYPE;
	static const CELL element_size = CELLS;
	/* tagged */
	CELL capacity;

	CELL *data() { return (CELL *)(this + 1); }
};

/* These are really just arrays, but certain elements have special
significance */
struct F_TUPLE_LAYOUT : public F_ARRAY {
	NO_TYPE_CHECK;
	/* tagged */
	CELL klass;
	/* tagged fixnum */
	CELL size;
	/* tagged fixnum */
	CELL echelon;
};

struct F_BIGNUM : public F_OBJECT {
	static const CELL type_number = BIGNUM_TYPE;
	static const CELL element_size = CELLS;
	/* tagged */
	CELL capacity;

	CELL *data() { return (CELL *)(this + 1); }
};

struct F_BYTE_ARRAY : public F_OBJECT {
	static const CELL type_number = BYTE_ARRAY_TYPE;
	static const CELL element_size = 1;
	/* tagged */
	CELL capacity;

	template<typename T> T *data() { return (T *)(this + 1); }
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_STRING : public F_OBJECT {
	static const CELL type_number = STRING_TYPE;
	/* tagged num of chars */
	CELL length;
	/* tagged */
	CELL aux;
	/* tagged */
	CELL hashcode;

	u8 *data() { return (u8 *)(this + 1); }
};

/* The compiled code heap is structured into blocks. */
typedef enum
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
} F_BLOCK_STATUS;

struct F_BLOCK
{
	unsigned char status; /* free or allocated? */
	unsigned char type; /* this is WORD_TYPE or QUOTATION_TYPE */
	unsigned char last_scan; /* the youngest generation in which this block's literals may live */
	char needs_fixup; /* is this a new block that needs full fixup? */

	/* In bytes, includes this header */
	CELL size;

	/* Used during compaction */
	F_BLOCK *forwarding;
};

struct F_FREE_BLOCK
{
	F_BLOCK block;

	/* Filled in on image load */
        F_FREE_BLOCK *next_free;
};

struct F_CODE_BLOCK
{
	F_BLOCK block;
	CELL literals; /* # bytes */
	CELL relocation; /* tagged pointer to byte-array or f */
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_WORD : public F_OBJECT {
	static const CELL type_number = WORD_TYPE;
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
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_WRAPPER : public F_OBJECT {
	static const CELL type_number = WRAPPER_TYPE;
	CELL object;
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_FLOAT : F_OBJECT {
	static const CELL type_number = FLOAT_TYPE;

#ifndef FACTOR_64
	CELL padding;
#endif

	double n;
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_QUOTATION : public F_OBJECT {
	static const CELL type_number = QUOTATION_TYPE;
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
};

/* Assembly code makes assumptions about the layout of this struct */
struct F_ALIEN : public F_OBJECT {
	static const CELL type_number = ALIEN_TYPE;
	/* tagged */
	CELL alien;
	/* tagged */
	CELL expired;
	/* untagged */
	CELL displacement;
};

struct F_DLL : public F_OBJECT {
	static const CELL type_number = DLL_TYPE;
	/* tagged byte array holding a C string */
	CELL path;
	/* OS-specific handle */
	void *dll;
};

struct F_CALLSTACK : public F_OBJECT {
	static const CELL type_number = CALLSTACK_TYPE;
	/* tagged */
	CELL length;
};

struct F_STACK_FRAME
{
	XT xt;
	/* Frame size in bytes */
	CELL size;
};

struct F_TUPLE : public F_OBJECT {
	static const CELL type_number = TUPLE_TYPE;
	/* tagged layout */
	CELL layout;

	CELL *data() { return (CELL *)(this + 1); }
};
