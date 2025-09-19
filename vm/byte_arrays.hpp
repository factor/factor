#include <algorithm>
#include <span>

namespace factor {

struct growable_byte_array {
  cell count;
  data_root<byte_array> elements;

  // Allocates memory
  growable_byte_array(factor_vm* parent, cell capacity = 40)
      : count(0), elements(parent->allot_byte_array(capacity), parent) {}

  void reallot_array(cell new_capacity);
  void grow_bytes(cell len);
  void append_bytes(std::span<const uint8_t> data);
  void append_byte_array(cell elts);

  void trim();
};

// Allocates memory
template <typename Type>
byte_array* factor_vm::byte_array_from_value(Type* value) {
  byte_array* array_data = allot_uninitialized_array<byte_array>(sizeof(Type));
  std::copy_n(reinterpret_cast<const char*>(value), sizeof(Type), array_data->data<char>());
  return array_data;
}

}
