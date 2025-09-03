namespace factor {

struct alignas(16) from_tenured_refs_copier : no_fixup {
  tenured_space* tenured;
  std::vector<cell> *mark_stack;

  from_tenured_refs_copier() : tenured(nullptr), mark_stack(nullptr) { }
  
  from_tenured_refs_copier(tenured_space* tenured_param,
                           std::vector<cell> *mark_stack_param)
      : tenured(tenured_param), mark_stack(mark_stack_param) { }
  
  from_tenured_refs_copier(const from_tenured_refs_copier& other)
      : tenured(other.tenured), mark_stack(other.mark_stack) { }
  
  from_tenured_refs_copier& operator=(const from_tenured_refs_copier& other) {
    if (this != &other) {
      tenured = other.tenured;
      mark_stack = other.mark_stack;
    }
    return *this;
  }

  object* fixup_data(object* obj) {
    if (tenured->contains_p(obj)) {
      return obj;
    }

    // Is there another forwarding pointer?
    while (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
    }

    if (tenured->contains_p(obj)) {
      return obj;
    }

    cell size = obj->size();
    object* newpointer = tenured->allot(size);
    if (!newpointer)
      throw must_start_gc_again();

    memcpy(newpointer, obj, size);
    obj->forward_to(newpointer);

    mark_stack->push_back(reinterpret_cast<cell>(newpointer));
    return newpointer;
  }
};

}
