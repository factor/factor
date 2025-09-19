namespace factor {

struct tenured_space : free_list_allocator<object> {
  object_start_map starts;

  tenured_space(cell space_size, cell space_start)
      : free_list_allocator<object>(space_size, space_start),
        starts(space_size, space_start) {}

  object* allot(cell dsize) {
    object* obj = free_list_allocator<object>::allot(dsize);
    if (obj) {
      starts.record_object_start_offset(obj);
      return obj;
    }
    return nullptr;
  }

  cell next_allocated_object_after(cell scan) {
    while (scan != this->end && ptr_from_cell<object>(scan)->free_p()) {
      free_heap_block* free_block = ptr_from_cell<free_heap_block>(scan);
      scan = cell_from_ptr(free_block) + free_block->size();
    }
    return scan == this->end ? 0 : scan;
  }

  cell first_object() {
    return next_allocated_object_after(this->start);
  }

  cell next_object_after(cell scan) {
    cell data_size = ptr_from_cell<object>(scan)->size();
    return next_allocated_object_after(scan + data_size);
  }

  void sweep() {
    free_list_allocator<object>::sweep();
    starts.update_for_sweep(&this->state);
  }
};

}
