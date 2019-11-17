namespace factor {

struct aging_space : bump_allocator {
  object_start_map starts;

  aging_space(cell size_, cell start_)
      : bump_allocator(size_, start_), starts(size_, start_) {}

  object* allot(cell dsize) {
    if (here + dsize > end)
      return NULL;

    object* obj = bump_allocator::allot(dsize);
    starts.record_object_start_offset(obj);
    return obj;
  }

  cell next_object_after(cell scan) {
    cell data_size = (reinterpret_cast<object*>(scan))->size();
    if (scan + data_size < here)
      return scan + data_size;
    return 0;
  }

  cell first_object() {
    if (start != here)
      return start;
    return 0;
  }
};

}
