namespace factor {

struct aging_space : bump_allocator {
  object_start_map starts;

  aging_space(cell size, cell start)
      : bump_allocator(size, start), starts(size, start) {}

  object* allot(cell dsize) {
    if (here + dsize > end)
      return NULL;

    object* obj = bump_allocator::allot(dsize);
    starts.record_object_start_offset(obj);
    return obj;
  }

  cell next_object_after(cell scan) {
    cell dsize = ((object*)scan)->size();
    if (scan + dsize < here)
      return scan + dsize;
    return 0;
  }

  cell first_object() {
    if (start != here)
      return start;
    return 0;
  }
};

}
