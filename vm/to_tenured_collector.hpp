namespace factor {

struct from_tenured_refs_copier : no_fixup {
  tenured_space* tenured;
  std::vector<cell> *mark_stack;

  from_tenured_refs_copier(tenured_space* tenured,
                           std::vector<cell> *mark_stack)
      : tenured(tenured), mark_stack(mark_stack) { }

  object* fixup_data(object* obj) {
    if (tenured->contains_p(obj)) {
      return obj;
    }

    // Is there another forwarding pointer?
    // Adding cycle detection to prevent infinite loops in forwarding pointers
    const unsigned int MAX_FORWARDING_CHAIN = 100;
    unsigned int count = 0;
    
    while (obj->forwarding_pointer_p() && count < MAX_FORWARDING_CHAIN) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
      count++;
    }
    
    // If we hit the limit, there might be a cycle
    if (count >= MAX_FORWARDING_CHAIN) {
      // Break the potential cycle by returning the last object we found
      // This may be wrong, but it's better than an infinite loop
      factor::critical_error("Possible forwarding pointer cycle detected in to_tenured_collector", (cell)obj);
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

    mark_stack->push_back((cell)newpointer);
    return newpointer;
  }
};

}
