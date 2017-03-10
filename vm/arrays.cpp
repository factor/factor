#include "master.hpp"

namespace factor {

// Allocates memory
array* factor_vm::allot_array(cell capacity, cell fill_) {
  data_root<object> fill(fill_, this);
  array* new_array = allot_uninitialized_array<array>(capacity);
  memset_cell(new_array->data(), fill.value(), capacity * sizeof(cell));
  return new_array;
}

// Allocates memory
void factor_vm::primitive_array() {
  cell fill = ctx->pop();
  cell capacity = unbox_array_size();
  array* new_array = allot_array(capacity, fill);
  ctx->push(tag<array>(new_array));
}

// Allocates memory
cell factor_vm::allot_array_4(cell v1_, cell v2_, cell v3_, cell v4_) {
  data_root<object> v1(v1_, this);
  data_root<object> v2(v2_, this);
  data_root<object> v3(v3_, this);
  data_root<object> v4(v4_, this);
  array *a = allot_uninitialized_array<array>(4);
  set_array_nth(a, 0, v1.value());
  set_array_nth(a, 1, v2.value());
  set_array_nth(a, 2, v3.value());
  set_array_nth(a, 3, v4.value());
  return tag<array>(a);
}

// Allocates memory
void factor_vm::primitive_resize_array() {
  data_root<array> a(ctx->pop(), this);
  check_tagged(a);
  cell capacity = unbox_array_size();
  ctx->push(tag<array>(reallot_array(a.untagged(), capacity)));
}

// Allocates memory
cell factor_vm::std_vector_to_array(std::vector<cell>& elements) {

  cell element_count = elements.size();
  cell orig_size = data_roots.size();
  data_roots.reserve(orig_size + element_count);

  for (cell n = 0; n < element_count; n++) {
    data_roots.push_back(&elements[n]);
  }

  tagged<array> objects(allot_uninitialized_array<array>(element_count));
  memcpy(objects->data(), &elements[0], element_count * sizeof(cell));
  data_roots.resize(orig_size);
  return objects.value();
}

// Allocates memory
void growable_array::reallot_array(cell count) {
  array *a_old = elements.untagged();
  array *a_new = elements.parent->reallot_array(a_old, count);
  elements.set_untagged(a_new);
}

// Allocates memory
void growable_array::add(cell elt_) {
  factor_vm* parent = elements.parent;
  data_root<object> elt(elt_, parent);
  if (count == array_capacity(elements.untagged())) {
    reallot_array(2 * count);
  }
  parent->set_array_nth(elements.untagged(), count++, elt.value());
}

// Allocates memory
void growable_array::append(array* elts_) {
  factor_vm* parent = elements.parent;
  data_root<array> elts(elts_, parent);
  cell capacity = array_capacity(elts.untagged());
  if (count + capacity > array_capacity(elements.untagged())) {
    reallot_array(2 * (count + capacity));
  }

  for (cell index = 0; index < capacity; index++)
    parent->set_array_nth(elements.untagged(), count++,
                          array_nth(elts.untagged(), index));
}

// Allocates memory
void growable_array::trim() {
  reallot_array(count);
}

}
