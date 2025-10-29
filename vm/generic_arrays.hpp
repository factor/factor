#include <algorithm>
#include <cstddef>

namespace factor {

template <typename Array> cell array_capacity(const Array* array) {
  FACTOR_ASSERT(array->type() == Array::type_number);
  return array->capacity >> TAG_BITS;
}

template <typename Array> cell array_size(cell capacity) {
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

  auto* src = reinterpret_cast<const std::byte*>(array.untagged() + 1);
  auto* dst = reinterpret_cast<std::byte*>(new_array + 1);
  auto bytes = static_cast<size_t>(to_copy * Array::element_size);
  std::copy_n(src, bytes, dst);
  std::fill(dst + bytes,
            dst + static_cast<size_t>(capacity * Array::element_size),
            std::byte{0});

  return new_array;
}

}
