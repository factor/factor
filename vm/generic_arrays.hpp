namespace factor {

template <typename Array> cell array_capacity(const Array* array) {
  FACTOR_ASSERT(array->type() == Array::type_number);
  return array->capacity >> TAG_BITS;
}

template <typename Array> cell array_size(cell capacity) {
  // Check for potential overflow in multiplication
  if (capacity > ((cell)-1) / Array::element_size) {
    critical_error("Array capacity overflow", capacity);
    return 0; // Will never reach here
  }
  
  return sizeof(Array) + capacity * Array::element_size;
}

template <typename Array> cell array_size(Array* array) {
  return array_size<Array>(array_capacity(array));
}

// Allocates memory
template <typename Array>
Array* factor_vm::allot_uninitialized_array(cell capacity) {
  Array* array = allot<Array>(array_size<Array>(capacity));
  array->capacity = tag_fixnum(capacity);
  return array;
}

template <typename Array>
bool factor_vm::reallot_array_in_place_p(Array* array, cell capacity) {
  return data->nursery->contains_p(array) &&
      capacity <= array_capacity(array);
}

// Allocates memory (sometimes)
template <typename Array>
Array* factor_vm::reallot_array(Array* array_, cell capacity) {
  data_root<Array> array(array_, this);

  if (array_capacity(array.untagged()) == capacity)
    return array.untagged();

  if (reallot_array_in_place_p(array.untagged(), capacity)) {
    array->capacity = tag_fixnum(capacity);
    return array.untagged();
  }
  cell to_copy = array_capacity(array.untagged());
  if (capacity < to_copy)
    to_copy = capacity;

  Array* new_array = allot_uninitialized_array<Array>(capacity);

  memcpy(new_array + 1, array.untagged() + 1, to_copy * Array::element_size);
  memset((char*)(new_array + 1) + to_copy * Array::element_size, 0,
         (capacity - to_copy) * Array::element_size);

  return new_array;
}

}
