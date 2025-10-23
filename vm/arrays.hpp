namespace factor {

inline cell array_nth(array* array, cell slot) {
  FACTOR_ASSERT(slot < array_capacity(array));
  FACTOR_ASSERT(array->type() == ARRAY_TYPE);
  return array->data()[slot];
}

inline void factor_vm::set_array_nth(array* array, cell slot, cell value) {
  FACTOR_ASSERT(slot < array_capacity(array));
  FACTOR_ASSERT(array->type() == ARRAY_TYPE);
  cell* slot_ptr = &array->data()[slot];
  *slot_ptr = value;
  write_barrier(slot_ptr);
}

struct growable_array {
  cell count;
  data_root<array> elements;

  // Allocates memory
  growable_array(factor_vm* parent, cell capacity = 10)
      : count(0),
        elements(parent->allot_array(capacity, false_object), parent) {}

  void reallot_array(cell new_capacity);
  void add(cell elt);
  void append(array* elts);
  void trim();
};

}
