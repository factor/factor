namespace factor {

// It is up to the caller to fill in the object's fields in a
// meaningful fashion!

// Allocates memory
inline object* factor_vm::allot_large_object(cell type, cell size) {
  // If tenured space does not have enough room, collect and compact
  cell requested_size = size + data->high_water_mark();
  if (!data->tenured->can_allot_p(requested_size)) {
    primitive_compact_gc();

    // If it still won't fit, grow the heap
    if (!data->tenured->can_allot_p(requested_size)) {
      gc(collect_growing_data_heap_op, size);
    }
  }

  object* obj = data->tenured->allot(size);

  // Allows initialization code to store old->new pointers
  // without hitting the write barrier in the common case of
  // a nursery allocation
  write_barrier(obj, size);

  obj->initialize(type);
  return obj;
}

// Allocates memory
inline object* factor_vm::allot_object(cell type, cell size) {
  FACTOR_ASSERT(!current_gc);

  bump_allocator *nursery = data->nursery;

  // If the object is bigger than the nursery, allocate it in tenured space
  if (size >= nursery->size)
    return allot_large_object(type, size);

  // If the object is smaller than the nursery, allocate it in the nursery,
  // after a GC if needed
  if (nursery->here + size > nursery->end)
    primitive_minor_gc();

  object* obj = nursery->allot(size);
  obj->initialize(type);

  return obj;
}

}
