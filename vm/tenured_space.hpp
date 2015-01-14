namespace factor {

struct tenured_space : free_list_allocator<object> {
  object_start_map starts;

  tenured_space(cell size, cell start)
      : free_list_allocator<object>(size, start), starts(size, start) {}

  object* allot(cell size) {
    object* obj = free_list_allocator<object>::allot(size);
    if (obj) {
      starts.record_object_start_offset(obj);
      return obj;
    } else
      return NULL;
  }

  cell first_object() {
    return (cell)next_allocated_block_after((object*)this->start);
  }

  cell next_object_after(cell scan) {
    cell size = ((object*)scan)->size();
    object* next = (object*)(scan + size);
    return (cell)next_allocated_block_after(next);
  }

  void sweep() {
    free_list_allocator<object>::sweep();
    starts.update_for_sweep(&this->state);
  }
};

}
