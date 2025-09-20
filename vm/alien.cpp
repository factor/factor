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
      return reinterpret_cast<char*>(ptr->address);
    }
    case F_TYPE:
      return nullptr;
    default:
      type_error(ALIEN_TYPE, obj);
      return nullptr; // can't happen
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
  } else
    new_alien->base = delegate.value();

  new_alien->displacement = displacement;
  new_alien->expired = false_object;
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
  ctx->replace(from_unsigned_cell(
      cell_from_ptr(pinned_alien_offset(ctx->peek()))));
}

// pop ( alien n ) from datastack, return alien's address plus n
void* factor_vm::alien_pointer() {
  fixnum offset = to_fixnum(ctx->pop());
  return alien_offset(ctx->pop()) + offset;
}

// Helper functions for unaligned memory access that keep the previous crash
// behaviour for nullptr pointers while satisfying sanitizers.
template<typename T>
static inline T unaligned_read(const void* ptr) {
  if (!ptr) {
#if defined(_MSC_VER)
#pragma warning(push)
#pragma warning(disable : 6011)
#endif
    volatile T* null_ptr = nullptr;
    T crash = *null_ptr;
#if defined(_MSC_VER)
#pragma warning(pop)
#endif
    return crash;
  }
  const auto* bytes = reinterpret_cast<const std::byte*>(ptr);
  std::array<std::byte, sizeof(T)> buffer{};
  std::copy_n(bytes, buffer.size(), buffer.data());
  return std::bit_cast<T>(buffer);
}

template<typename T>
static inline void unaligned_write(void* ptr, T value) {
  if (!ptr) {
#if defined(_MSC_VER)
#pragma warning(push)
#pragma warning(disable : 6011)
#endif
    volatile T* null_ptr = nullptr;
    *null_ptr = value;
#if defined(_MSC_VER)
#pragma warning(pop)
#endif
    return;
  }
  auto bytes = std::bit_cast<std::array<std::byte, sizeof(T)>>(value);
  std::copy_n(bytes.data(), bytes.size(), reinterpret_cast<std::byte*>(ptr));
}

// define words to read/write values at an alien address
#define DEFINE_ALIEN_ACCESSOR(name, type, from, to)                    \
  VM_C_API void primitive_alien_##name(factor_vm* parent) {           \
    void* ptr = parent->alien_pointer();                              \
    type value = unaligned_read<type>(ptr);                           \
    parent->ctx->push(parent->from(value));                           \
  }                                                                   \
  VM_C_API void primitive_set_alien_##name(factor_vm* parent) {       \
    void* ptr = parent->alien_pointer();                              \
    type value = (type)parent->to(parent->ctx->pop());                \
    unaligned_write(ptr, value);                                      \
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

    if (d->handle == nullptr)
      ctx->replace(false_object);
    else
      ctx->replace(allot_alien(ffi_dlsym(d, sym).value_or(0)));
  } else
    ctx->replace(allot_alien(ffi_dlsym(nullptr, sym).value_or(0)));
}

// close a native library handle
void factor_vm::primitive_dlclose() {
  dll* d = untag_check<dll>(ctx->pop());
  if (d->handle != nullptr)
    ffi_dlclose(d);
}

void factor_vm::primitive_dll_validp() {
  cell library = ctx->peek();
  if (to_boolean(library))
    ctx->replace(tag_boolean(untag_check<dll>(library)->handle != nullptr));
  else
    ctx->replace(special_objects[OBJ_CANONICAL_TRUE]);
}

// gets the address of an object representing a C pointer
char* factor_vm::alien_offset(cell obj) {
  switch (TAG(obj)) {
    case BYTE_ARRAY_TYPE:
      return untag<byte_array>(obj)->data<char>();
    case ALIEN_TYPE:
      return reinterpret_cast<char*>(untag<alien>(obj)->address);
    case F_TYPE:
      return nullptr;
    default:
      type_error(ALIEN_TYPE, obj);
      return nullptr; // can't happen
  }
}

}
