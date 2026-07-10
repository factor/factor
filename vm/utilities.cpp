#include "master.hpp"

namespace factor {

// Fill in a PPC function descriptor
void* fill_function_descriptor(void* ptr, void* code) {
  void** descriptor = (void**)ptr;
  descriptor[0] = code;
  descriptor[1] = NULL;
  descriptor[2] = NULL;
  return descriptor;
}

// Get a field from a PPC function descriptor
void* function_descriptor_field(void* ptr, size_t idx) {
  return ptr ? ((void**)ptr)[idx] : ptr;
}

// If memory allocation fails, bail out
vm_char* safe_strdup(const vm_char* str) {
  vm_char* ptr = STRDUP(str);
  if (!ptr)
    fatal_error("Out of memory in safe_strdup", 0);
  return ptr;
}

cell read_cell_hex() {
  cell cell;
  std::cin >> std::hex >> cell >> std::dec;
  if (!std::cin.good())
    exit(1);
  return cell;
}

// On Windows, memcpy() is in a different DLL and the non-optimizing
// compiler can't find it
VM_C_API void* factor_memcpy(void* dst, void* src, size_t len) {
  return memcpy(dst, src, len);
}

void* factor_raw_memcpy(void* dst, const void* src, size_t len) {
  volatile uint8_t* out = static_cast<volatile uint8_t*>(dst);
  const volatile uint8_t* in = static_cast<const volatile uint8_t*>(src);
  for (size_t i = 0; i < len; ++i)
    out[i] = in[i];
  return dst;
}

cell factor_raw_load_cell(const cell* ptr) { return *ptr; }

void factor_raw_store_cell(cell* ptr, cell value) { *ptr = value; }

}
