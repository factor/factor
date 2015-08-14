namespace factor {

struct aging_space : bump_allocator {
  object_start_map starts;

  aging_space(cell size, cell start)
      : bump_allocator(size, start), starts(size, start) {}

  object* allot(cell size) {
    if (here + size > end)
      return NULL;

    object* obj = bump_allocator::allot(size);
    starts.record_object_start_offset(obj);
    return obj;
  }

  cell next_object_after(cell scan) {
    cell size = ((object*)scan)->size();
    if (scan + size < here)
      return scan + size;
    return 0;
  }

  cell first_object() {
    if (start != here)
      return start;
    return 0;
  }
};

}
