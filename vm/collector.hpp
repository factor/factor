namespace factor {

struct must_start_gc_again {
};

template <typename TargetGeneration, typename Policy>
struct gc_workhorse : no_fixup {
  static const bool translated_code_block_map = false;

  factor_vm* parent;
  TargetGeneration* target;
  Policy policy;
  code_heap* code;

  gc_workhorse(factor_vm* parent, TargetGeneration* target, Policy policy)
      : parent(parent), target(target), policy(policy), code(parent->code) {}

  object* fixup_data(object* obj) {
    FACTOR_ASSERT((parent->current_gc &&
                   parent->current_gc->op == collect_growing_heap_op) ||
                  parent->data->seg->in_segment_p((cell)obj));

    if (!policy.should_copy_p(obj)) {
      policy.visited_object(obj);
      return obj;
    }

    /* is there another forwarding pointer? */
    while (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
    }

    if (!policy.should_copy_p(obj)) {
      policy.visited_object(obj);
      return obj;
    }

    cell size = obj->size();
    object* newpointer = target->allot(size);
    if (!newpointer)
      throw must_start_gc_again();

    memcpy(newpointer, obj, size);
    obj->forward_to(newpointer);

    policy.promoted_object(newpointer);

    return newpointer;
  }

  code_block* fixup_code(code_block* compiled) {
    if (!code->allocator->state.marked_p((cell)compiled)) {
      code->allocator->state.set_marked_p((cell)compiled, compiled->size());
      parent->mark_stack.push_back((cell)compiled + 1);
    }

    return compiled;
  }
};

}
