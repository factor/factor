// Exercise production callback_heap::add with distinguishable templates.
// This checks selection and patching, not Factor callback GC or the full FFI.
#include "../../master.hpp"
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace factor;

template <typename T> static T* fixture_object(cell bytes, cell type) {
  void* memory = nullptr;
  if (posix_memalign(&memory, 16, align(bytes, 16))) std::abort();
  std::memset(memory, 0, align(bytes, 16));
  T* object = static_cast<T*>(memory);
  object->header = type << 2;
  return object;
}

static factor::array* fixture_array(cell capacity) {
  factor::array* result = fixture_object<factor::array>(sizeof(factor::array) + capacity * sizeof(cell), ARRAY_TYPE);
  result->capacity = tag_fixnum(capacity);
  return result;
}

static byte_array* fixture_bytes(const void* data, cell size) {
  byte_array* result = fixture_object<byte_array>(sizeof(byte_array) + size, BYTE_ARRAY_TYPE);
  result->capacity = tag_fixnum(size);
  std::memcpy(result->data<void>(), data, size);
  return result;
}

static factor::array* fixture_template(unsigned char value) {
  relocation_entry relocations[] = {
    relocation_entry(RT_VM, RC_ABSOLUTE_CELL, 12),
    relocation_entry(RT_SAFEPOINT, RC_ABSOLUTE_CELL, 16),
    relocation_entry(RT_ENTRY_POINT, RC_ABSOLUTE_CELL, 20),
    relocation_entry(RT_VM, RC_ABSOLUTE_CELL, 24)
  };
  unsigned char code[24] = {value, 0xe0, 0x0b, 0x00, 0x09, 0x00, 0x09, 0x00};
  factor::array* result = fixture_array(2);
  result->data()[0] = tag(fixture_bytes(relocations, sizeof relocations));
  result->data()[1] = tag(fixture_bytes(code, sizeof code));
  return result;
}

int main() {
  factor_vm* vm = new factor_vm(pthread_self());
  for (cell& special : vm->special_objects) special = false_object;
  vm->code = new code_heap(65536);
  vm->callbacks = new callback_heap(65536, vm);
  factor::array* ordinary = fixture_template(42);
  factor::array* variadic = fixture_template(99);
  factor::array* outer = fixture_array(3);
  outer->data()[0] = ordinary->data()[0];
  outer->data()[1] = ordinary->data()[1];
  outer->data()[2] = tag(variadic);
  vm->special_objects[CALLBACK_STUB] = tag(outer);
  word* owner = fixture_object<word>(sizeof(word), WORD_TYPE);
  owner->entry_point = 0x12345678;
  code_block* normal = vm->callbacks->add(tag(owner), 0);
  code_block* variable = vm->callbacks->add(tag(owner), (cell)-1);
  auto call = [](code_block* block) {
    return reinterpret_cast<int (*)()>(block->entry_point())();
  };
  int normal_result = call(normal), variadic_result = call(variable);
  bool selected = variable->parameters == tag_fixnum(1);
  std::printf("ordinary=%d variadic=%d marker=%u\n",
              normal_result, variadic_result, (unsigned)selected);
  int status = normal_result == 42 && variadic_result == 99 && selected ? 0 : 1;
  std::puts(status ? "SH4-CALLBACK-SELECTOR-FAIL" : "SH4-CALLBACK-SELECTOR-PASS");
  std::fflush(stdout);
  // This isolated fixture has unmanaged template objects and no data heap.
  _exit(status);
}
