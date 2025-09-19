namespace factor {

struct growable_byte_array {
  cell count;
  data_root<byte_array> elements;

  // Allocates memory
  growable_byte_array(factor_vm* parent, cell capacity = 40)
      : count(0), elements(parent->allot_byte_array(capacity), parent) {}

  void reallot_array(cell new_capacity);
  void grow_bytes(cell len);
  void append_bytes(void* elts, cell len);
  void append_byte_array(cell elts);

  void trim();
};

// Allocates memory
template <typename Type>
byte_array* factor_vm::byte_array_from_value(Type* value) {
  byte_array* array_data = allot_uninitialized_array<byte_array>(sizeof(Type));
  memcpy(array_data->data<char>(), value, sizeof(Type));
  return array_data;
}

}
