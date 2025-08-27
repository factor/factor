namespace factor {

// It is up to the caller to fill in the object's fields in a
// meaningful fashion!

// Allocates memory
inline code_block* factor_vm::allot_code_block(cell size,
                                               code_block_type type) {
  cell block_size = size + sizeof(code_block);
  code_block* block = code->allocator->allot(block_size);

  if (block == NULL) {
    // If allocation failed, do a full GC and compact the code heap.
    // A full GC that occurs as a result of the data heap filling up does not
    // trigger a compaction. This setup ensures that most GCs do not compact
    // the code heap, but if the code fills up, it probably means it will be
    // fragmented after GC anyway, so its best to compact.
    primitive_compact_gc();
    block = code->allocator->allot(block_size);

    // Insufficient room even after code GC, give up
    if (block == NULL) {
      std::cout << "Code heap used:               " << code->allocator->occupied_space() << "\n";
      std::cout << "Code heap free:               " << code->allocator->free_space << "\n";
      std::cout << "Code heap free_block_count:   " << code->allocator->free_block_count << "\n";
      std::cout << "Code heap largest_free_block: " << code->allocator->largest_free_block() << "\n";
      std::cout << "Request       : " << block_size << "\n";
      fatal_error("Out of memory in allot_code_block", 0);
    }
  }

  // next time we do a minor GC, we have to trace this code block, since
  // the fields of the code_block struct might point into nursery or aging
  this->code->write_barrier(block);

  block->set_type(type);
  return block;
}

// Allocates memory
inline object* factor_vm::allot_large_object(cell type, cell size) {
  // If tenured space does not have enough room, collect and compact
  cell required_free = size + data->high_water_mark();
  if (!data->tenured.get()->can_allot_p(required_free)) {
    primitive_compact_gc();

    // If it still won't fit, grow the heap
    if (!data->tenured.get()->can_allot_p(required_free)) {
      gc(COLLECT_GROWING_DATA_HEAP_OP, size);
    }
  }
  object* obj = data->tenured.get()->allot(size);

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

  bump_allocator *data_nursery = data->nursery;

  // If the object is bigger than the nursery, allocate it in tenured space
  if (size >= data_nursery->size)
    return allot_large_object(type, size);

  // If the object is smaller than the nursery, allocate it in the nursery,
  // after a GC if needed
  if (data_nursery->here + size > data_nursery->end)
    primitive_minor_gc();

  object* obj = data_nursery->allot(size);
  obj->initialize(type);

  return obj;
}

}
