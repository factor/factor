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

inline static cell alignment_for(cell a, cell b)
{
	return align(a,b) - a;
}

static const cell data_alignment = 16;

#define WORD_SIZE (signed)(sizeof(cell)*8)

#define TAG_MASK 15
#define TAG_BITS 4
#define TAG(x) ((cell)(x) & TAG_MASK)
#define UNTAG(x) ((cell)(x) & ~TAG_MASK)
#define RETAG(x,tag) (UNTAG(x) | (tag))

/*** Tags ***/
#define FIXNUM_TYPE 0
#define F_TYPE 1
#define ARRAY_TYPE 2
#define FLOAT_TYPE 3
#define QUOTATION_TYPE 4
#define BIGNUM_TYPE 5
#define ALIEN_TYPE 6
#define TUPLE_TYPE 7
#define WRAPPER_TYPE 8
#define BYTE_ARRAY_TYPE 9
#define CALLSTACK_TYPE 10
#define STRING_TYPE 11
#define WORD_TYPE 12
#define DLL_TYPE 13

#define TYPE_COUNT 14

enum code_block_type
{
	code_block_unoptimized,
	code_block_optimized,
	code_block_profiling,
	code_block_pic
};

/* Constants used when floating-point trap exceptions are thrown */
enum
{
	FP_TRAP_INVALID_OPERATION = 1 << 0,
	FP_TRAP_OVERFLOW          = 1 << 1,
	FP_TRAP_UNDERFLOW         = 1 << 2,
	FP_TRAP_ZERO_DIVIDE       = 1 << 3,
	FP_TRAP_INEXACT           = 1 << 4,
};

/* What Factor calls 'f' */
static const cell false_object = F_TYPE;

inline static bool immediate_p(cell obj)
{
	/* We assume that fixnums have tag 0 and false_object has tag 1 */
	return TAG(obj) <= F_TYPE;
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

#define NO_TYPE_CHECK static const cell type_number = TYPE_COUNT

struct object {
	NO_TYPE_CHECK;
	cell header;

	cell size() const;
	template<typename Fixup> cell size(Fixup fixup) const;

	cell binary_payload_start() const;
	template<typename Fixup> cell binary_payload_start(Fixup fixup) const;

	cell *slots() const { return (cell *)this; }

	template<typename Iterator> void each_slot(Iterator &iter);

	/* Only valid for objects in tenured space; must cast to free_heap_block
	to do anything with it if its free */
	bool free_p() const
	{
		return (header & 1) == 1;
	}

	cell type() const
	{
		return (header >> 2) & TAG_MASK;
	}

	void initialize(cell type)
	{
		header = type << 2;
	}

	cell hashcode() const
	{
		return (header >> 6);
	}

	void set_hashcode(cell hashcode)
	{
		header = (header & 0x3f) | (hashcode << 6);
	}

	bool forwarding_pointer_p() const
	{
		return (header & 2) == 2;
	}

	object *forwarding_pointer() const
	{
		return (object *)UNTAG(header);
	}

	void forward_to(object *pointer)
	{
		header = ((cell)pointer | 2);
	}
};

/* Assembly code makes assumptions about the layout of this struct */
struct array : public object {
	static const cell type_number = ARRAY_TYPE;
	static const cell element_size = sizeof(cell);
	/* tagged */
	cell capacity;

	cell *data() const { return (cell *)(this + 1); }
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

	cell *data() const { return (cell *)(this + 1); }
};

struct byte_array : public object {
	static const cell type_number = BYTE_ARRAY_TYPE;
	static const cell element_size = 1;
	/* tagged */
	cell capacity;

#ifndef FACTOR_64
	cell padding0;
	cell padding1;
#endif

	template<typename Scalar> Scalar *data() const { return (Scalar *)(this + 1); }
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

	u8 *data() const { return (u8 *)(this + 1); }
};

struct code_block;

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
	/* UNTAGGED entry point: jump here to execute word */
	void *entry_point;
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
	/* UNTAGGED entry point; jump here to call quotation */
	void *entry_point;
	/* UNTAGGED compiled code block */
	code_block *code;
};

/* Assembly code makes assumptions about the layout of this struct */
struct alien : public object {
	static const cell type_number = ALIEN_TYPE;
	/* tagged */
	cell base;
	/* tagged */
	cell expired;
	/* untagged */
	cell displacement;
	/* untagged */
	cell address;

	void update_address()
	{
		if(base == false_object)
			address = displacement;
		else
			address = UNTAG(base) + sizeof(byte_array) + displacement;
	}
};

struct dll : public object {
	static const cell type_number = DLL_TYPE;
	/* tagged byte array holding a C string */
	cell path;
	/* OS-specific handle */
	void *handle;
};

struct stack_frame {
	/* Updated by procedure prologue with procedure start address */
	void *entry_point;
	/* Frame size in bytes */
	cell size;
};

struct callstack : public object {
	static const cell type_number = CALLSTACK_TYPE;
	/* tagged */
	cell length;
	
	stack_frame *frame_at(cell offset) const
	{
		return (stack_frame *)((char *)(this + 1) + offset);
	}

	stack_frame *top() const { return (stack_frame *)(this + 1); }
	stack_frame *bottom() const { return (stack_frame *)((cell)(this + 1) + untag_fixnum(length)); }
};

struct tuple : public object {
	static const cell type_number = TUPLE_TYPE;
	/* tagged layout */
	cell layout;

	cell *data() const { return (cell *)(this + 1); }
};

struct data_root_range {
	cell *start;
	cell len;

	explicit data_root_range(cell *start_, cell len_) :
		start(start_), len(len_) {}
};

}
