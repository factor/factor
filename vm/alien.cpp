#include "master.hpp"

namespace factor {

// gets the address of an object representing a C pointer, with the
// intention of storing the pointer across code which may potentially GC.
char* factor_vm::pinned_alien_offset(cell obj) {
  switch (TAG(obj)) {
    case ALIEN_TYPE: {
      alien* ptr = untag<alien>(obj);
      if (to_boolean(ptr->expired))
        general_error(ERROR_EXPIRED, obj, false_object);
      if (to_boolean(ptr->base))
        type_error(ALIEN_TYPE, obj);
      return (char*)ptr->address;
    }
    case F_TYPE:
      return NULL;
    default:
      type_error(ALIEN_TYPE, obj);
      return NULL; // can't happen
  }
}

// make an alien
// Allocates memory
cell factor_vm::allot_alien(cell delegate_, cell displacement) {
  if (displacement == 0)
    return delegate_;

  data_root<object> delegate(delegate_, this);
  data_root<alien> new_alien(allot<alien>(sizeof(alien)), this);

  if (TAG(delegate_) == ALIEN_TYPE) {
    tagged<alien> delegate_alien = delegate.as<alien>();
    displacement += delegate_alien->displacement;
    new_alien->base = delegate_alien->base;
    new_alien->expired = delegate_alien->expired;
  } else {
    new_alien->base = delegate.value();
    new_alien->expired = false_object;
  }

  new_alien->displacement = displacement;
  new_alien->update_address();

  return new_alien.value();
}

// Allocates memory
cell factor_vm::allot_alien(cell address) {
  return allot_alien(false_object, address);
}

// make an alien pointing at an offset of another alien
// Allocates memory
void factor_vm::primitive_displaced_alien() {
  cell alien = ctx->pop();
  cell displacement = to_cell(ctx->pop());

  switch (TAG(alien)) {
    case BYTE_ARRAY_TYPE:
    case ALIEN_TYPE:
    case F_TYPE:
      ctx->push(allot_alien(alien, displacement));
      break;
    default:
      type_error(ALIEN_TYPE, alien);
      break;
  }
}

// address of an object representing a C pointer. Explicitly throw an error
// if the object is a byte array, as a sanity check.
// Allocates memory (from_unsigned_cell can allocate)
void factor_vm::primitive_alien_address() {
  ctx->replace(from_unsigned_cell((cell)pinned_alien_offset(ctx->peek())));
}

// pop ( alien n ) from datastack, return alien's address plus n
void* factor_vm::alien_pointer() {
  fixnum offset = to_fixnum(ctx->pop());
  return alien_offset(ctx->pop()) + offset;
}

template <typename T> static T read_unaligned(const void* pointer) {
  T value;
  memcpy(&value, pointer, sizeof(value));
  return value;
}

template <typename T> static void write_unaligned(void* pointer, T value) {
  memcpy(pointer, &value, sizeof(value));
}

// Integer-only memory access copies representations without native FP values.
// VAX MOVF/MOVD fault on reserved operands and normalize dirty zeros. Read
// foreign encodings as integers so the explicit F/D bridge controls both.
template <typename T, typename Boxer>
static cell read_alien_value(factor_vm* parent, const void* pointer,
                             Boxer boxer) {
  (void)parent;
  (void)boxer;
#if defined(FACTOR_INTEGER_ONLY)
  if constexpr (std::is_same<T, float>::value) {
    uint32_t bits = read_unaligned<uint32_t>(pointer);
#if defined(__vax__)
    uint32_t ieee = 0;
    if (vax_f_to_ieee(&bits, ieee) == vax_float_conversion::reserved_operand)
      parent->general_error(ERROR_FFI, false_object, false_object);
    bits = ieee;
#endif
    return parent->allot_float_bits(widen_ieee_bits(bits));
  } else if constexpr (std::is_same<T, double>::value) {
    uint64_t bits = read_unaligned<uint64_t>(pointer);
#if defined(__vax__)
    uint64_t ieee = 0;
    if (vax_d_to_ieee(&bits, ieee) == vax_float_conversion::reserved_operand)
      parent->general_error(ERROR_FFI, false_object, false_object);
    bits = ieee;
#endif
    return parent->allot_float_bits(bits);
  } else
#elif defined(__vax__)
  if constexpr (std::is_same<T, float>::value) {
    uint32_t native = read_unaligned<uint32_t>(pointer), bits = 0;
    if (vax_f_to_ieee(&native, bits) == vax_float_conversion::reserved_operand)
      parent->general_error(ERROR_FFI, false_object, false_object);
    return parent->allot_float(vm_float::from_float_bits(bits));
  } else if constexpr (std::is_same<T, double>::value) {
    uint64_t native = read_unaligned<uint64_t>(pointer), bits = 0;
    if (vax_d_to_ieee(&native, bits) == vax_float_conversion::reserved_operand)
      parent->general_error(ERROR_FFI, false_object, false_object);
    return parent->allot_float_bits(bits);
  } else
#endif
    return boxer(read_unaligned<T>(pointer));
}

template <typename T, typename Unboxer>
static void write_alien_value(factor_vm* parent, void* pointer, cell value,
                              Unboxer unboxer) {
  (void)parent;
  (void)unboxer;
#if defined(FACTOR_INTEGER_ONLY)
  if constexpr (std::is_same<T, float>::value) {
    uint32_t bits = narrow_ieee_bits(vm_float_bits(parent->untag_float_check(value)));
#if defined(__vax__)
    uint32_t native = 0;
    auto status = ieee_to_vax_f(bits, &native);
    if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
      parent->general_error(ERROR_FFI, false_object, false_object);
    bits = native;
#endif
    write_unaligned(pointer, bits);
  } else if constexpr (std::is_same<T, double>::value) {
    uint64_t bits = vm_float_bits(parent->untag_float_check(value));
#if defined(__vax__)
    uint64_t native = 0;
    auto status = ieee_to_vax_d(bits, &native);
    if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
      parent->general_error(ERROR_FFI, false_object, false_object);
    bits = native;
#endif
    write_unaligned(pointer, bits);
  } else
#elif defined(__vax__)
  if constexpr (std::is_same<T, float>::value) {
    uint32_t native = 0;
    vax_float_conversion status =
        ieee_to_vax_f(parent->untag_float_check(value).float_bits(), &native);
    if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
      parent->general_error(ERROR_FFI, false_object, false_object);
    write_unaligned(pointer, native);
  } else if constexpr (std::is_same<T, double>::value) {
    uint64_t native = 0;
    vax_float_conversion status =
        ieee_to_vax_d(parent->untag_float_check(value).bits(), &native);
    if (status != vax_float_conversion::exact && status != vax_float_conversion::rounded)
      parent->general_error(ERROR_FFI, false_object, false_object);
    write_unaligned(pointer, native);
  } else
#endif
    write_unaligned(pointer, (T)unboxer(value));
}

// define words to read/write values at an alien address
#define DEFINE_ALIEN_ACCESSOR(name, type, from, to)                     \
  VM_C_API void primitive_alien_##name(factor_vm * parent) {            \
    void* pointer = parent->alien_pointer();                           \
    parent->ctx->push(read_alien_value<type>(parent, pointer,            \
        [parent](type value) { return parent->from(value); }));          \
  }                                                                     \
  VM_C_API void primitive_set_alien_##name(factor_vm * parent) {        \
    void* pointer = parent->alien_pointer();                            \
    write_alien_value<type>(parent, pointer, parent->ctx->pop(),         \
        [parent](cell value) { return parent->to(value); });            \
  }

EACH_ALIEN_PRIMITIVE(DEFINE_ALIEN_ACCESSOR)

// open a native library and push a handle
// Allocates memory
void factor_vm::primitive_dlopen() {
  data_root<byte_array> path(ctx->pop(), this);
  check_tagged(path);
  data_root<dll> library(allot<dll>(sizeof(dll)), this);
  library->path = path.value();
  ffi_dlopen(library.untagged());
  // A newly opened library can change what a symbol resolves to.
  dlsym_cache.clear();
  ctx->push(library.value());
}

// look up a symbol in a native library
// Allocates memory
void factor_vm::primitive_dlsym() {
  data_root<object> library(ctx->pop(), this);
  data_root<byte_array> name(ctx->peek(), this);
  check_tagged(name);

  symbol_char* sym = name->data<symbol_char>();

  if (to_boolean(library.value())) {
    dll* d = untag_check<dll>(library.value());

    if (d->handle == NULL)
      ctx->replace(false_object);
    else
      ctx->replace(allot_alien(ffi_dlsym(d, sym)));
  } else
    ctx->replace(allot_alien(ffi_dlsym(NULL, sym)));
}

// close a native library handle
void factor_vm::primitive_dlclose() {
  dll* d = untag_check<dll>(ctx->pop());
  if (d->handle != NULL) {
    ffi_dlclose(d);
    // Cached addresses into the closed library are now dangling.
    dlsym_cache.clear();
  }
}

void factor_vm::primitive_dll_validp() {
  cell library = ctx->peek();
  if (to_boolean(library))
    ctx->replace(tag_boolean(untag_check<dll>(library)->handle != NULL));
  else
    ctx->replace(special_objects[OBJ_CANONICAL_TRUE]);
}

// gets the address of an object representing a C pointer
char* factor_vm::alien_offset(cell obj) {
  switch (TAG(obj)) {
    case BYTE_ARRAY_TYPE:
      return untag<byte_array>(obj)->data<char>();
    case ALIEN_TYPE:
      return (char*)untag<alien>(obj)->address;
    case F_TYPE:
      return NULL;
    default:
      type_error(ALIEN_TYPE, obj);
      return NULL; // can't happen
  }
}

}
