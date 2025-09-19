#include "master.hpp"

namespace factor {

// Allocates memory
byte_array* factor_vm::allot_byte_array(cell size) {
  byte_array* array = allot_uninitialized_array<byte_array>(size);
  memset(array + 1, 0, size);
  return array;
}

// Allocates memory
void factor_vm::primitive_byte_array() {
  cell size = unbox_array_size();
  ctx->push(tag<byte_array>(allot_byte_array(size)));
}

// Allocates memory
void factor_vm::primitive_uninitialized_byte_array() {
  cell size = unbox_array_size();
  ctx->push(tag<byte_array>(allot_uninitialized_array<byte_array>(size)));
}

// Allocates memory
void factor_vm::primitive_resize_byte_array() {
  data_root<byte_array> array(ctx->pop(), this);
  check_tagged(array);
  cell capacity = unbox_array_size();
  ctx->push(tag<byte_array>(reallot_array(array.untagged(), capacity)));
}

// Allocates memory
void growable_byte_array::reallot_array(cell new_capacity) {
  byte_array *ba_old = elements.untagged();
  byte_array *ba_new = elements.parent->reallot_array(ba_old, new_capacity);
  elements.set_untagged(ba_new);
}

// Allocates memory
void growable_byte_array::grow_bytes(cell len) {
  count += len;
  if (count >= array_capacity(elements.untagged())) {
    reallot_array(2 * count);
  }
}

// Allocates memory
void growable_byte_array::append_bytes(void* elts, cell len) {
  cell old_count = count;
  grow_bytes(len);
  memcpy(&elements->data<uint8_t>()[old_count], elts, len);
}

// Allocates memory
void growable_byte_array::append_byte_array(cell byte_array_) {
  data_root<byte_array> byte_array(byte_array_, elements.parent);

  cell len = array_capacity(byte_array.untagged());
  cell new_size = count + len;
  if (new_size >= array_capacity(elements.untagged())) {
    reallot_array(2 * new_size);
  }

  memcpy(&elements->data<uint8_t>()[count], byte_array->data<uint8_t>(), len);

  count += len;
}

// Allocates memory
void growable_byte_array::trim() {
  reallot_array(count);
}

}
