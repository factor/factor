namespace factor {

/* Size of the object pointed to by an untagged pointer */
template <typename Fixup> cell object::size(Fixup fixup) const {
  if (free_p())
    return ((free_heap_block*)this)->size();

  switch (type()) {
    case ARRAY_TYPE:
      return align(array_size((array*)this), data_alignment);
    case BIGNUM_TYPE:
      return align(array_size((bignum*)this), data_alignment);
    case BYTE_ARRAY_TYPE:
      return align(array_size((byte_array*)this), data_alignment);
    case STRING_TYPE:
      return align(string_size(string_capacity((string*)this)), data_alignment);
    case TUPLE_TYPE: {
      tuple_layout* layout = (tuple_layout*)fixup.translate_data(
          untag<object>(((tuple*)this)->layout));
      return align(tuple_size(layout), data_alignment);
    }
    case QUOTATION_TYPE:
      return align(sizeof(quotation), data_alignment);
    case WORD_TYPE:
      return align(sizeof(word), data_alignment);
    case FLOAT_TYPE:
      return align(sizeof(boxed_float), data_alignment);
    case DLL_TYPE:
      return align(sizeof(dll), data_alignment);
    case ALIEN_TYPE:
      return align(sizeof(alien), data_alignment);
    case WRAPPER_TYPE:
      return align(sizeof(wrapper), data_alignment);
    case CALLSTACK_TYPE:
      return align(
          callstack_object_size(untag_fixnum(((callstack*)this)->length)),
          data_alignment);
    default:
      critical_error("Invalid header in size", (cell)this);
      return 0; /* can't happen */
  }
}

inline cell object::size() const { return size(no_fixup()); }

/* The number of cells from the start of the object which should be scanned by
the GC. Some types have a binary payload at the end (string, word, DLL) which
we ignore. */
template <typename Fixup> cell object::binary_payload_start(Fixup fixup) const {
  if (free_p())
    return 0;

  switch (type()) {
    /* these objects do not refer to other objects at all */
    case FLOAT_TYPE:
    case BYTE_ARRAY_TYPE:
    case BIGNUM_TYPE:
    case CALLSTACK_TYPE:
      return 0;
    /* these objects have some binary data at the end */
    case WORD_TYPE:
      return sizeof(word) - sizeof(cell);
    case ALIEN_TYPE:
      return sizeof(cell) * 3;
    case DLL_TYPE:
      return sizeof(cell) * 2;
    case QUOTATION_TYPE:
      return sizeof(quotation) - sizeof(cell);
    case STRING_TYPE:
      return sizeof(string);
    /* everything else consists entirely of pointers */
    case ARRAY_TYPE:
      return array_size<array>(array_capacity((array*)this));
    case TUPLE_TYPE: {
      tuple_layout* layout = (tuple_layout*)fixup.translate_data(
          untag<object>(((tuple*)this)->layout));
      return tuple_size(layout);
    }
    case WRAPPER_TYPE:
      return sizeof(wrapper);
    default:
      critical_error("Invalid header in binary_payload_start", (cell)this);
      return 0; /* can't happen */
  }
}

inline cell object::binary_payload_start() const {
  return binary_payload_start(no_fixup());
}

/* Slot visitors iterate over the slots of an object, applying a functor to
each one that is a non-immediate slot. The pointer is untagged first. The
functor returns a new untagged object pointer. The return value may or may not
equal the old one,
however the new pointer receives the same tag before being stored back to the
original location.

Slots storing immediate values are left unchanged and the visitor does inspect
them.

This is used by GC's copying, sweep and compact phases, and the implementation
of the become primitive.

Iteration is driven by visit_*() methods. Some of them define GC roots:
- visit_roots()
- visit_contexts() */

template <typename Fixup> struct slot_visitor {
  factor_vm* parent;
  Fixup fixup;

  slot_visitor<Fixup>(factor_vm* parent, Fixup fixup)
      : parent(parent), fixup(fixup) {}

  cell visit_pointer(cell pointer);
  void visit_handle(cell* handle);
  void visit_object_array(cell* start, cell* end);
  void visit_slots(object* ptr, cell payload_start);
  void visit_slots(object* ptr);
  void visit_stack_elements(segment* region, cell* top);
  void visit_data_roots();
  void visit_bignum_roots();
  void visit_callback_roots();
  void visit_literal_table_roots();
  void visit_roots();
  void visit_callstack_object(callstack* stack);
  void visit_callstack(context* ctx);
  void visit_context(context *ctx);
  void visit_contexts();
  void visit_code_block_objects(code_block* compiled);
  void visit_embedded_literals(code_block* compiled);
  void visit_sample_callstacks();
  void visit_sample_threads();
};

template <typename Fixup>
cell slot_visitor<Fixup>::visit_pointer(cell pointer) {
  if (immediate_p(pointer))
    return pointer;

  object* untagged = fixup.fixup_data(untag<object>(pointer));
  return RETAG(untagged, TAG(pointer));
}

template <typename Fixup> void slot_visitor<Fixup>::visit_handle(cell* handle) {
  *handle = visit_pointer(*handle);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_object_array(cell* start, cell* end) {
  while (start < end)
    visit_handle(start++);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_slots(object* ptr, cell payload_start) {
  cell* slot = (cell*)ptr;
  cell* end = (cell*)((cell)ptr + payload_start);

  if (slot != end) {
    slot++;
    visit_object_array(slot, end);
  }
}

template <typename Fixup> void slot_visitor<Fixup>::visit_slots(object* obj) {
  if (obj->type() == CALLSTACK_TYPE)
    visit_callstack_object((callstack*)obj);
  else
    visit_slots(obj, obj->binary_payload_start(fixup));
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_stack_elements(segment* region, cell* top) {
  visit_object_array((cell*)region->start, top + 1);
}

template <typename Fixup> void slot_visitor<Fixup>::visit_data_roots() {
  std::vector<cell*>::const_iterator iter =
      parent->data_roots.begin();
  std::vector<cell*>::const_iterator end =
      parent->data_roots.end();

  for (; iter < end; iter++) {
    visit_handle(*iter);
  }
}

template <typename Fixup> void slot_visitor<Fixup>::visit_bignum_roots() {
  std::vector<bignum**>::const_iterator iter =
      parent->bignum_roots.begin();
  std::vector<bignum**>::const_iterator end =
      parent->bignum_roots.end();

  for (; iter < end; iter++) {
    bignum** ref = *iter;
    *ref = (bignum*)fixup.fixup_data(*ref);
  }
}

template <typename Fixup> struct callback_slot_visitor {
  callback_heap* callbacks;
  slot_visitor<Fixup>* visitor;

  callback_slot_visitor(callback_heap* callbacks,
                        slot_visitor<Fixup>* visitor)
      : callbacks(callbacks), visitor(visitor) {}

  void operator()(code_block* stub) { visitor->visit_handle(&stub->owner); }
};

template <typename Fixup> void slot_visitor<Fixup>::visit_callback_roots() {
  callback_slot_visitor<Fixup> callback_visitor(parent->callbacks, this);
  parent->callbacks->each_callback(callback_visitor);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_literal_table_roots() {
  std::map<code_block*, cell>* uninitialized_blocks =
      &parent->code->uninitialized_blocks;
  std::map<code_block*, cell>::const_iterator iter =
      uninitialized_blocks->begin();
  std::map<code_block*, cell>::const_iterator end = uninitialized_blocks->end();

  std::map<code_block*, cell> new_uninitialized_blocks;
  for (; iter != end; iter++) {
    new_uninitialized_blocks.insert(
        std::make_pair(iter->first, visit_pointer(iter->second)));
  }

  parent->code->uninitialized_blocks = new_uninitialized_blocks;
}

template <typename Fixup> void slot_visitor<Fixup>::visit_sample_callstacks() {
  for (std::vector<cell>::iterator iter = parent->sample_callstacks.begin();
       iter != parent->sample_callstacks.end(); ++iter) {
    visit_handle(&*iter);
  }
}

template <typename Fixup> void slot_visitor<Fixup>::visit_sample_threads() {
  for (std::vector<profiling_sample>::iterator iter = parent->samples.begin();
       iter != parent->samples.end(); ++iter) {
    visit_handle(&iter->thread);
  }
}

template <typename Fixup> void slot_visitor<Fixup>::visit_roots() {
  visit_handle(&parent->true_object);
  visit_handle(&parent->bignum_zero);
  visit_handle(&parent->bignum_pos_one);
  visit_handle(&parent->bignum_neg_one);

  visit_data_roots();
  visit_bignum_roots();
  visit_callback_roots();
  visit_literal_table_roots();
  visit_sample_callstacks();
  visit_sample_threads();

  visit_object_array(parent->special_objects,
                     parent->special_objects + special_object_count);
}

/* primitive_minor_gc() is invoked by inline GC checks, and it needs to fill in
   uninitialized stack locations before actually calling the GC. See the
   documentation in compiler.cfg.stacks.vacant for details.

   So for each call frame:

    - scrub some uninitialized locations
    - trace some overinitialized locations
    - trace roots in spill slots
*/
template <typename Fixup> struct call_frame_slot_visitor {
  factor_vm* parent;
  slot_visitor<Fixup>* visitor;
  /* NULL in case we're a visitor for a callstack object. */
  context* ctx;

  void check_stack(cell stack, uint8_t* bitmap, cell base, uint32_t count) {
    for (uint32_t loc = 0; loc < count; loc++) {
      if (bitmap_p(bitmap, base + loc)) {
#ifdef DEBUG_GC_MAPS
        std::cout << "checking stack location " << loc << std::endl;
#endif
        cell* value_ptr = ((cell*)stack + loc + 1);
        visitor->visit_handle(value_ptr);
      }
    }
  }

  void scrub_stack(cell stack, uint8_t* bitmap, cell base, uint32_t count) {
    for (cell loc = 0; loc < count; loc++) {
      if (bitmap_p(bitmap, base + loc)) {
#ifdef DEBUG_GC_MAPS
        std::cout << "scrubbing stack location " << loc << std::endl;
#endif
        *((cell*)stack - loc) = 0;
      }
    }
  }

  call_frame_slot_visitor(factor_vm* parent,
                          slot_visitor<Fixup>* visitor,
                          context* ctx)
      : parent(parent), visitor(visitor), ctx(ctx) {}

  /*
	frame top -> [return address]
	             [spill area]
	             ...
	             [entry_point]
	             [size]
	*/
  void operator()(void* frame_top, cell frame_size, code_block* owner,
                  void* addr) {
    cell return_address = owner->offset(addr);

    code_block* compiled =
        Fixup::translated_code_block_map ? owner
                                         : visitor->fixup.translate_code(owner);
    gc_info* info = compiled->block_gc_info();

    FACTOR_ASSERT(return_address < compiled->size());
    cell callsite = info->return_address_index(return_address);
    if (callsite == (cell)-1)
      return;

#ifdef DEBUG_GC_MAPS
    std::cout << "call frame code block " << compiled << " with offset "
              << return_address << std::endl;
#endif
    cell* stack_pointer = (cell*)frame_top;
    uint8_t* bitmap = info->gc_info_bitmap();

    if (ctx) {
      /* Scrub vacant stack locations. */
      scrub_stack(ctx->datastack,
                  bitmap,
                  info->callsite_scrub_d(callsite),
                  info->scrub_d_count);
      scrub_stack(ctx->retainstack,
                  bitmap,
                  info->callsite_scrub_r(callsite),
                  info->scrub_r_count);

      /* Trace overinitialized stack locations. */
      check_stack(ctx->datastack,
                  bitmap,
                  info->callsite_check_d(callsite),
                  info->check_d_count);
      check_stack(ctx->retainstack,
                  bitmap,
                  info->callsite_check_r(callsite),
                  info->check_r_count);
    }

    /* Subtract old value of base pointer from every derived pointer. */
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != (uint32_t)-1) {
#ifdef DEBUG_GC_MAPS
        std::cout << "visiting derived root " << spill_slot
                  << " with base pointer " << base_pointer << std::endl;
#endif
        stack_pointer[spill_slot] -= stack_pointer[base_pointer];
      }
    }

    /* Update all GC roots, including base pointers. */
    cell callsite_gc_roots = info->callsite_gc_roots(callsite);

    for (cell spill_slot = 0; spill_slot < info->gc_root_count; spill_slot++) {
      if (bitmap_p(bitmap, callsite_gc_roots + spill_slot)) {
#ifdef DEBUG_GC_MAPS
        std::cout << "visiting GC root " << spill_slot << std::endl;
#endif
        visitor->visit_handle(stack_pointer + spill_slot);
      }
    }

    /* Add the base pointers to obtain new derived pointer values. */
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != (uint32_t)-1)
        stack_pointer[spill_slot] += stack_pointer[base_pointer];
    }
  }
};

template <typename Fixup>
void slot_visitor<Fixup>::visit_callstack_object(callstack* stack) {
  call_frame_slot_visitor<Fixup> call_frame_visitor(parent, this, NULL);
  parent->iterate_callstack_object(stack, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_callstack(context* ctx) {
  call_frame_slot_visitor<Fixup> call_frame_visitor(parent, this, ctx);
  parent->iterate_callstack(ctx, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_context(context* ctx) {
  /* Callstack is visited first because it scrubs the data and retain
     stacks. */
  visit_callstack(ctx);

  visit_stack_elements(ctx->datastack_seg, (cell*)ctx->datastack);
  visit_stack_elements(ctx->retainstack_seg, (cell*)ctx->retainstack);
  visit_object_array(ctx->context_objects,
                     ctx->context_objects + context_object_count);

}

template <typename Fixup> void slot_visitor<Fixup>::visit_contexts() {
  std::set<context*>::const_iterator begin = parent->active_contexts.begin();
  std::set<context*>::const_iterator end = parent->active_contexts.end();
  while (begin != end) {
    visit_context(*begin);
    begin++;
  }
}

template <typename Fixup> struct literal_references_visitor {
  slot_visitor<Fixup>* visitor;

  explicit literal_references_visitor(slot_visitor<Fixup>* visitor)
      : visitor(visitor) {}

  void operator()(instruction_operand op) {
    if (op.rel_type() == RT_LITERAL)
      op.store_value(visitor->visit_pointer(op.load_value()));
  }
};

template <typename Fixup>
void slot_visitor<Fixup>::visit_code_block_objects(code_block* compiled) {
  visit_handle(&compiled->owner);
  visit_handle(&compiled->parameters);
  visit_handle(&compiled->relocation);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_embedded_literals(code_block* compiled) {
  if (!parent->code->uninitialized_p(compiled)) {
    literal_references_visitor<Fixup> visitor(this);
    compiled->each_instruction_operand(visitor);
  }
}

}
