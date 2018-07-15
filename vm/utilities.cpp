#include "master.hpp"

namespace factor {

// Fill in a PPC function descriptor
void* fill_function_descriptor(void* ptr, void* code) {
  void** descriptor = (void**)ptr;
  descriptor[0] = code;
  descriptor[1] = nullptr;
  descriptor[2] = nullptr;
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

}
