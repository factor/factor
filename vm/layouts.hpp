namespace factor
{

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;

#ifdef _WIN64
	typedef long long fixnum;
	typedef unsigned long long cell;
#else
	typedef long fixnum;
	typedef unsigned long cell;
#endif

inline static cell align(cell a, cell b)
{
	return (a + (b-1)) & ~(b-1);
}

inline static cell align8(cell a)
{
	return align(a,8);
}

#define WORD_SIZE (signed)(sizeof(cell)*8)

#define TAG_MASK 7
#define TAG_BITS 3
#define TAG(x) ((cell)(x) & TAG_MASK)
#define UNTAG(x) ((cell)(x) & ~TAG_MASK)
#define RETAG(x,tag) (UNTAG(x) | (tag))

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

/* Not a real type, but code_block's type field can be set to this */
#define PIC_TYPE 69

inline static bool immediate_p(cell obj)
{
	return (obj == F || TAG(obj) == FIXNUM_TYPE);
}

inline static fixnum untag_fixnum(cell tagged)
{
#ifdef FACTOR_DEBUG
	assert(TAG(tagged) == FIXNUM_TYPE);
#endif
	return ((fixnum)tagged) >> TAG_BITS;
}

inline static cell tag_fixnum(fixnum untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

inline static cell tag_for(cell type)
{
	return type < HEADER_TYPE ? type : OBJECT_TYPE;
}

struct object;

struct header {
	cell value;

        /* Default ctor to make gcc 3.x happy */
        header() { abort(); }

	header(cell value_) : value(value_ << TAG_BITS) {}

	void check_header() {
#ifdef FACTOR_DEBUG
		assert(TAG(value) == FIXNUM_TYPE && untag_fixnum(value) < TYPE_COUNT);
#endif
	}

	cell hi_tag() {
		check_header();
		return value >> TAG_BITS;
	}

	bool forwarding_pointer_p() {
		return TAG(value) == GC_COLLECTED;
	}

	object *forwarding_pointer() {
		return (object *)UNTAG(value);
	}

	void forward_to(object *pointer) {
		value = RETAG(pointer,GC_COLLECTED);
	}
};

#define NO_TYPE_CHECK static const cell type_number = TYPE_COUNT

struct object {
	NO_TYPE_CHECK;
	header h;
	cell *slots() { return (cell *)this; }
};

/* Assembly code makes assumptions about the layout of this struct */
struct array : public object {
	static const cell type_number = ARRAY_TYPE;
	static const cell element_size = sizeof(cell);
	/* tagged */
	cell capacity;

	cell *data() { return (cell *)(this + 1); }
};

/* These are really just arrays, but certain elements have special
significance */
struct tuple_layout : public array {
	NO_TYPE_CHECK;
	/* tagged */
	cell klass;
	/* tagged fixnum */
	cell size;
	/* tagged fixnum */
	cell echelon;
};

struct bignum : public object {
	static const cell type_number = BIGNUM_TYPE;
	static const cell element_size = sizeof(cell);
	/* tagged */
	cell capacity;

	cell *data() { return (cell *)(this + 1); }
};

struct byte_array : public object {
	static const cell type_number = BYTE_ARRAY_TYPE;
	static const cell element_size = 1;
	/* tagged */
	cell capacity;

	template<typename T> T *data() { return (T *)(this + 1); }
};

/* Assembly code makes assumptions about the layout of this struct */
struct string : public object {
	static const cell type_number = STRING_TYPE;
	/* tagged num of chars */
	cell length;
	/* tagged */
	cell aux;
	/* tagged */
	cell hashcode;

	u8 *data() { return (u8 *)(this + 1); }
};

/* The compiled code heap is structured into blocks. */
enum block_status
{
	B_FREE,
	B_ALLOCATED,
	B_MARKED
};

struct heap_block
{
	unsigned char status; /* free or allocated? */
	unsigned char type; /* this is WORD_TYPE or QUOTATION_TYPE */
	unsigned char last_scan; /* the youngest generation in which this block's literals may live */
	unsigned char needs_fixup; /* is this a new block that needs full fixup? */

	/* In bytes, includes this header */
	cell size;
};

struct free_heap_block : public heap_block
{
        free_heap_block *next_free;
};

struct code_block : public heap_block
{
	cell literals; /* # bytes */
	cell relocation; /* tagged pointer to byte-array or f */
	
	void *xt() { return (void *)(this + 1); }
};

/* Assembly code makes assumptions about the layout of this struct */
struct word : public object {
	static const cell type_number = WORD_TYPE;
	/* TAGGED hashcode */
	cell hashcode;
	/* TAGGED word name */
	cell name;
	/* TAGGED word vocabulary */
	cell vocabulary;
	/* TAGGED definition */
	cell def;
	/* TAGGED property assoc for library code */
	cell props;
	/* TAGGED alternative entry point for direct non-tail calls. Used for inline caching */
	cell pic_def;
	/* TAGGED alternative entry point for direct tail calls. Used for inline caching */
	cell pic_tail_def;
	/* TAGGED call count for profiling */
	cell counter;
	/* TAGGED machine code for sub-primitive */
	cell subprimitive;
	/* UNTAGGED execution token: jump here to execute word */
	void *xt;
	/* UNTAGGED compiled code block */
	code_block *code;
	/* UNTAGGED profiler stub */
	code_block *profiling;
};

/* Assembly code makes assumptions about the layout of this struct */
struct wrapper : public object {
	static const cell type_number = WRAPPER_TYPE;
	cell object;
};

/* Assembly code makes assumptions about the layout of this struct */
struct boxed_float : object {
	static const cell type_number = FLOAT_TYPE;

#ifndef FACTOR_64
	cell padding;
#endif

	double n;
};

/* Assembly code makes assumptions about the layout of this struct */
struct quotation : public object {
	static const cell type_number = QUOTATION_TYPE;
	/* tagged */
	cell array;
	/* tagged */
	cell cached_effect;
	/* tagged */
	cell cache_counter;
	/* UNTAGGED */
	void *xt;
	/* UNTAGGED compiled code block */
	code_block *code;
};

/* Assembly code makes assumptions about the layout of this struct */
struct alien : public object {
	static const cell type_number = ALIEN_TYPE;
	/* tagged */
	cell alien;
	/* tagged */
	cell expired;
	/* untagged */
	cell displacement;
};

struct dll : public object {
	static const cell type_number = DLL_TYPE;
	/* tagged byte array holding a C string */
	cell path;
	/* OS-specific handle */
	void *dll;
};

struct stack_frame
{
	void *xt;
	/* Frame size in bytes */
	cell size;
};

struct callstack : public object {
	static const cell type_number = CALLSTACK_TYPE;
	/* tagged */
	cell length;
	
	stack_frame *top() { return (stack_frame *)(this + 1); }
	stack_frame *bottom() { return (stack_frame *)((cell)(this + 1) + untag_fixnum(length)); }
};

struct tuple : public object {
	static const cell type_number = TUPLE_TYPE;
	/* tagged layout */
	cell layout;

	cell *data() { return (cell *)(this + 1); }
};

}
