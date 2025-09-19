namespace factor {

typedef intptr_t fixnum;
typedef uintptr_t cell;

inline static cell align(cell a, cell b) { return (a + (b - 1)) & ~(b - 1); }

inline static cell alignment_for(cell a, cell b) { return align(a, b) - a; }

template <typename Ptr>
inline cell cell_from_ptr(Ptr ptr) {
  static_assert(std::is_pointer_v<Ptr>, "pointer required");
  return reinterpret_cast<cell>(ptr);
}

template <typename T>
inline T* ptr_from_cell(cell value) {
  return reinterpret_cast<T*>(value);
}

static const cell data_alignment = 16;

// Must match leaf-stack-frame-size in basis/bootstrap/layouts.factor
#define LEAF_FRAME_SIZE 16

#define WORD_SIZE (signed)(sizeof(cell) * 8)

#define TAG_MASK 15
#define TAG_BITS 4
#define TAG(x) ((cell)(x) & TAG_MASK)
#define UNTAG(x) ((cell)(x) & ~TAG_MASK)
#define RETAG(x, tag) (UNTAG(x) | (tag))

// Type tags, should be kept in sync with:
//   basis/bootstrap/layouts.factor
enum type_tags {
  FIXNUM_TYPE,
  F_TYPE,
  ARRAY_TYPE,
  FLOAT_TYPE,
  QUOTATION_TYPE,
  BIGNUM_TYPE,
  ALIEN_TYPE,
  TUPLE_TYPE,
  WRAPPER_TYPE,
  BYTE_ARRAY_TYPE,
  CALLSTACK_TYPE,
  STRING_TYPE,
  WORD_TYPE,
  DLL_TYPE,

  TYPE_COUNT
};

static inline const char* type_name(cell type) {
  static const char* const type_names[]={
    "fixnum",
    "f",
    "array",
    "float",
    "quotation",
    "bignum",
    "alien",
    "tuple",
    "wrapper",
    "byte-array",
    "callstack",
    "string",
    "word",
    "dll",
  };

  if (type>=TYPE_COUNT) {
      FACTOR_ASSERT(false);
      return "";
  }
  return type_names[type];
}

enum code_block_type {
  CODE_BLOCK_UNOPTIMIZED,
  CODE_BLOCK_OPTIMIZED,
  CODE_BLOCK_PIC
};

// Constants used when floating-point trap exceptions are thrown
enum {
  FP_TRAP_INVALID_OPERATION = 1 << 0,
  FP_TRAP_OVERFLOW = 1 << 1,
  FP_TRAP_UNDERFLOW = 1 << 2,
  FP_TRAP_ZERO_DIVIDE = 1 << 3,
  FP_TRAP_INEXACT = 1 << 4,
};

// What Factor calls 'f'
static const cell false_object = F_TYPE;

inline static bool immediate_p(cell obj) {
  // We assume that fixnums have tag 0 and false_object has tag 1
  return TAG(obj) <= F_TYPE;
}

inline static fixnum untag_fixnum(cell tagged) {
  FACTOR_ASSERT(TAG(tagged) == FIXNUM_TYPE);
  return ((fixnum)tagged) >> TAG_BITS;
}

inline static cell tag_fixnum(fixnum untagged) {
  return ( (cell)untagged << TAG_BITS) | FIXNUM_TYPE;
}

#define NO_TYPE_CHECK static const cell type_number = TYPE_COUNT

struct object {
  NO_TYPE_CHECK;
  // header format (bits indexed with least significant as zero):
  // bit 0      : free?
  // bit 1      : forwarding pointer?
  // if not forwarding:
  //   bit 2..5    : tag
  //   bit 6..end  : hashcode
  // if forwarding:
  //   bit 2..end  : forwarding pointer
  cell header;

  template <typename Fixup> cell base_size(Fixup fixup) const;
  template <typename Fixup> cell size(Fixup fixup) const;
  cell size() const;

  cell slot_count() const;
  template <typename Fixup> cell slot_count(Fixup fixup) const;
  cell* slots() const {
    return const_cast<cell*>(reinterpret_cast<const cell*>(this));
  }

  template <typename Iterator> void each_slot(Iterator& iter);

  // Only valid for objects in tenured space; must cast to free_heap_block
  // to do anything with it if its free
  bool free_p() const { return (header & 1) == 1; }

  cell type() const { return (header >> 2) & TAG_MASK; }

  void initialize(cell type) { header = type << 2; }

  cell hashcode() const { return (header >> 6); }

  void set_hashcode(cell hashcode) {
    header = (header & 0x3f) | (hashcode << 6);
  }

  bool forwarding_pointer_p() const { return (header & 2) == 2; }
  object* forwarding_pointer() const {
    return ptr_from_cell<object>(UNTAG(header));
  }

  void forward_to(object* pointer) {
    header = (cell_from_ptr(pointer) | 2);
  }
};

// Assembly code makes assumptions about the layout of this struct
struct array : public object {
  static const cell type_number = ARRAY_TYPE;
  static const cell element_size = sizeof(cell);
  // tagged
  cell capacity;

  cell* data() const {
    return const_cast<cell*>(reinterpret_cast<const cell*>(this + 1));
  }
};

// These are really just arrays, but certain elements have special
// significance
struct tuple_layout : public array {
  NO_TYPE_CHECK;
  // tagged
  cell klass;
  // tagged fixnum
  cell size;
  // tagged fixnum
  cell echelon;
};

struct bignum : public object {
  static const cell type_number = BIGNUM_TYPE;
  static const cell element_size = sizeof(cell);
  // tagged
  cell capacity;

  cell* data() const {
    return const_cast<cell*>(reinterpret_cast<const cell*>(this + 1));
  }
};

struct byte_array : public object {
  static const cell type_number = BYTE_ARRAY_TYPE;
  static const cell element_size = 1;
  // tagged
  cell capacity;

#ifndef FACTOR_64
  cell padding0;
  cell padding1;
#endif

  template <typename Scalar> Scalar* data() const {
    return (Scalar*)(this + 1);
  }
};

// Assembly code makes assumptions about the layout of this struct
struct string : public object {
  static const cell type_number = STRING_TYPE;
  // tagged num of chars
  cell length;
  // tagged
  cell aux;
  // tagged
  cell hashcode;

  uint8_t* data() const { return (uint8_t*)(this + 1); }
};

struct code_block;

// Assembly code makes assumptions about the layout of this struct:
//   basis/bootstrap/images/images.factor
//   basis/compiler/constants/constants.factor
//   basis/bootstrap/primitives.factor

struct word : public object {
  static const cell type_number = WORD_TYPE;
  // TAGGED hashcode
  cell hashcode;
  // TAGGED word name
  cell name;
  // TAGGED word vocabulary
  cell vocabulary;
  // TAGGED definition
  cell def;
  // TAGGED property assoc for library code
  cell props;
  // TAGGED alternative entry point for direct non-tail calls. Used for inline
  // caching
  cell pic_def;
  // TAGGED alternative entry point for direct tail calls. Used for inline
  // caching
  cell pic_tail_def;
  // TAGGED machine code for sub-primitive
  cell subprimitive;
  // UNTAGGED entry point: jump here to execute word
  cell entry_point;
  // UNTAGGED compiled code block

  // defined in code_blocks.hpp
  code_block* code() const;
};

// Assembly code makes assumptions about the layout of this struct
struct wrapper : public object {
  static const cell type_number = WRAPPER_TYPE;
  // TAGGED
  cell object;
};

// Assembly code makes assumptions about the layout of this struct
struct boxed_float : object {
  static const cell type_number = FLOAT_TYPE;

#ifndef FACTOR_64
  cell padding;
#endif

  double n;
};

// Assembly code makes assumptions about the layout of this struct:
//   basis/bootstrap/images/images.factor
//   basis/compiler/constants/constants.factor
//   core/bootstrap/primitives.factor

struct quotation : public object {
  static const cell type_number = QUOTATION_TYPE;
  // tagged
  cell array;
  // tagged
  cell cached_effect;
  // tagged
  cell cache_counter;
  // UNTAGGED entry point; jump here to call quotation
  cell entry_point;

  // defined in code_blocks.hpp
  code_block* code() const;
};

// Assembly code makes assumptions about the layout of this struct
struct alien : public object {
  static const cell type_number = ALIEN_TYPE;
  // tagged
  cell base;
  // tagged
  cell expired;
  // untagged
  cell displacement;
  // untagged
  cell address;

  void update_address() {
    if (base == false_object)
      address = displacement;
    else
      address = UNTAG(base) + sizeof(byte_array) + displacement;
  }
};

struct dll : public object {
  static const cell type_number = DLL_TYPE;
  // tagged byte array holding a C string
  cell path;
  // OS-specific handle
  void* handle;
};

struct callstack : public object {
  static const cell type_number = CALLSTACK_TYPE;
  // tagged
  cell length;

  cell frame_top_at(cell offset) const {
    return cell_from_ptr(this + 1) + offset;
  }

    cell top() const { return cell_from_ptr(this + 1); }
  cell bottom() const {
    return cell_from_ptr(this + 1) + untag_fixnum(length);
  }
};

struct tuple : public object {
  static const cell type_number = TUPLE_TYPE;
  // tagged layout
  cell layout;

  cell* data() const {
    return const_cast<cell*>(reinterpret_cast<const cell*>(this + 1));
  }
};

inline static cell tuple_capacity(const tuple_layout *layout) {
  return static_cast<cell>(untag_fixnum(layout->size));
}

inline static cell tuple_size(const tuple_layout* layout) {
  return static_cast<cell>(sizeof(tuple) + tuple_capacity(layout) * sizeof(cell));
}

inline static cell string_capacity(const string* str) {
  return static_cast<cell>(untag_fixnum(str->length));
}

inline static cell string_size(cell size) {
  return static_cast<cell>(sizeof(string) + size);
}

}

