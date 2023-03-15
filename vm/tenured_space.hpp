namespace factor {

struct tenured_space : free_list_allocator<object> {
  object_start_map starts;

  tenured_space(cell size, cell start)
      : free_list_allocator<object>(size, start), starts(size, start) {}

  object* allot(cell dsize) {
    object* obj = free_list_allocator<object>::allot(dsize);
    if (obj) {
      starts.record_object_start_offset(obj);
      return obj;
    }
    return NULL;
  }

  cell next_allocated_object_after(cell scan) {
    while (scan != this->end && ((object*)scan)->free_p()) {
      free_heap_block* free_block = (free_heap_block*)scan;
      scan = (cell)free_block + free_block->size();
    }
    return scan == this->end ? 0 : scan;
  }

  cell first_object() {
    return next_allocated_object_after(this->start);
  }

  cell next_object_after(cell scan) {
    cell data_size = ((object*)scan)->size();
    return next_allocated_object_after(scan + data_size);
  }

  void sweep() {
    free_list_allocator<object>::sweep();
    starts.update_for_sweep(&this->state);
  }
};

}
