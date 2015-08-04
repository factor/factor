namespace factor {

/* Size sans alignment. */
template <typename Fixup>
cell object::base_size(Fixup fixup) const {
  switch (type()) {
    case ARRAY_TYPE:
      return array_size((array*)this);
    case BIGNUM_TYPE:
      return array_size((bignum*)this);
    case BYTE_ARRAY_TYPE:
      return array_size((byte_array*)this);
    case STRING_TYPE:
      return string_size(string_capacity((string*)this));
    case TUPLE_TYPE: {
      tuple_layout* layout = (tuple_layout*)fixup.translate_data(
          untag<object>(((tuple*)this)->layout));
      return tuple_size(layout);
    }
    case QUOTATION_TYPE:
      return sizeof(quotation);
    case WORD_TYPE:
      return sizeof(word);
    case FLOAT_TYPE:
      return sizeof(boxed_float);
    case DLL_TYPE:
      return sizeof(dll);
    case ALIEN_TYPE:
      return sizeof(alien);
    case WRAPPER_TYPE:
      return sizeof(wrapper);
    case CALLSTACK_TYPE: {
      cell callstack_length = untag_fixnum(((callstack*)this)->length);
      return callstack_object_size(callstack_length);
    }
    default:
      critical_error("Invalid header in base_size", (cell)this);
      return 0;
  }
}

/* Size of the object pointed to by an untagged pointer */
template <typename Fixup>
cell object::size(Fixup fixup) const {
  if (free_p())
    return ((free_heap_block*)this)->size();
  return align(base_size(fixup), data_alignment);
}

inline cell object::size() const { return size(no_fixup()); }

/* The number of slots (cells) in an object which should be scanned by
   the GC. The number can vary in arrays and tuples, in all other
   types the number is a constant. */
template <typename Fixup>
inline cell object::slot_count(Fixup fixup) const {
  if (free_p())
    return 0;

  cell t = type();
  if (t == ARRAY_TYPE) {
    /* capacity + n slots */
    return 1 + array_capacity((array*)this);
  } else if (t == TUPLE_TYPE) {
    tuple_layout* layout = (tuple_layout*)fixup.translate_data(
        untag<object>(((tuple*)this)->layout));
    /* layout + n slots */
    return 1 + tuple_capacity(layout);
  } else {
    switch (t) {
      /* these objects do not refer to other objects at all */
      case FLOAT_TYPE:
      case BYTE_ARRAY_TYPE:
      case BIGNUM_TYPE:
      case CALLSTACK_TYPE: return 0;
      case WORD_TYPE: return 8;
      case ALIEN_TYPE: return 2;
      case DLL_TYPE: return 1;
      case QUOTATION_TYPE: return 3;
      case STRING_TYPE: return 3;
      case WRAPPER_TYPE: return 1;
      default:
        critical_error("Invalid header in slot_count", (cell)this);
        return 0; /* can't happen */
    }
  }
}

inline cell object::slot_count() const {
  return slot_count(no_fixup());
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

Iteration is driven by visit_*() methods. Only one of them define GC roots:
- visit_all_roots()

Code block visitors iterate over sets of code blocks, applying a functor to
each one. The functor returns a new code_block pointer, which may or may not
equal the old one. This is stored back to the original location.

This is used by GC's sweep and compact phases, and the implementation of the
modify-code-heap primitive.

Iteration is driven by visit_*() methods. Some of them define GC roots:
- visit_context_code_blocks()
- visit_callback_code_blocks() */

template <typename Fixup> struct slot_visitor {
  factor_vm* parent;
  Fixup fixup;

  slot_visitor<Fixup>(factor_vm* parent, Fixup fixup)
      : parent(parent), fixup(fixup) {}

  cell visit_pointer(cell pointer);
  void visit_handle(cell* handle);
  void visit_object_array(cell* start, cell* end);
  void visit_slots(object* ptr);
  void visit_stack_elements(segment* region, cell* top);
  void visit_all_roots();
  void visit_callstack_object(callstack* stack);
  void visit_callstack(context* ctx);
  void visit_context(context *ctx);
  void visit_code_block_objects(code_block* compiled);
  void visit_embedded_literals(code_block* compiled);
  void visit_object_code_block(object* obj);
  void visit_context_code_blocks();
  void visit_uninitialized_code_blocks();
  void visit_embedded_code_pointers(code_block* compiled);
  void visit_object(object* obj);
  void visit_mark_stack(std::vector<cell>* mark_stack);
  void visit_instruction_operands(code_block* block, cell rel_base);
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

template <typename Fixup> void slot_visitor<Fixup>::visit_slots(object* obj) {
  if (obj->type() == CALLSTACK_TYPE)
    visit_callstack_object((callstack*)obj);
  else {
    cell* start = (cell*)obj + 1;
    cell* end = start + obj->slot_count(fixup);
    visit_object_array(start, end);
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_stack_elements(segment* region, cell* top) {
  visit_object_array((cell*)region->start, top + 1);
}

template <typename Fixup> void slot_visitor<Fixup>::visit_all_roots() {
  visit_handle(&parent->true_object);
  visit_handle(&parent->bignum_zero);
  visit_handle(&parent->bignum_pos_one);
  visit_handle(&parent->bignum_neg_one);

  FACTOR_FOR_EACH(parent->data_roots) {
    visit_handle(*iter);
  }

  auto callback_slot_visitor = [&](code_block* stub, cell size) {
    visit_handle(&stub->owner);
  };
  parent->callbacks->allocator->iterate(callback_slot_visitor);

  FACTOR_FOR_EACH(parent->code->uninitialized_blocks) {
    iter->second = visit_pointer(iter->second);
  }

  FACTOR_FOR_EACH(parent->sample_callstacks) {
    visit_handle(&*iter);
  }

  FACTOR_FOR_EACH(parent->samples) {
    visit_handle(&iter->thread);
  }

  visit_object_array(parent->special_objects,
                     parent->special_objects + special_object_count);

  FACTOR_FOR_EACH(parent->active_contexts) {
    visit_context(*iter);
  }
}

/* primitive_minor_gc() is invoked by inline GC checks, and it needs to fill in
   uninitialized stack locations before actually calling the GC. See the
   documentation in compiler.cfg.stacks.vacant for details.

   So for each call frame:

    - scrub some uninitialized locations
    - trace roots in spill slots
*/
template <typename Fixup> struct call_frame_slot_visitor {
  slot_visitor<Fixup>* visitor;
  /* NULL in case we're a visitor for a callstack object. */
  context* ctx;

  void scrub_stack(cell stack, uint8_t* bitmap, cell base, uint32_t count) {
    for (cell loc = 0; loc < count; loc++) {
      if (bitmap_p(bitmap, base + loc)) {
#ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("scrubbing stack location " << loc);
#endif
        *((cell*)stack - loc) = 0;
      }
    }
  }

  call_frame_slot_visitor(slot_visitor<Fixup>* visitor, context* ctx)
      : visitor(visitor), ctx(ctx) {}

  /*
	frame top -> [return address]
	             [spill area]
	             ...
	             [entry_point]
	             [size]
	*/
  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
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
    FACTOR_PRINT("call frame code block " << compiled << " with offset "
                 << return_address);
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
    }

    /* Subtract old value of base pointer from every derived pointer. */
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != (uint32_t)-1) {
#ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("visiting derived root " << spill_slot
                     << " with base pointer " << base_pointer);
#endif
        stack_pointer[spill_slot] -= stack_pointer[base_pointer];
      }
    }

    /* Update all GC roots, including base pointers. */
    cell callsite_gc_roots = info->callsite_gc_roots(callsite);

    for (cell spill_slot = 0; spill_slot < info->gc_root_count; spill_slot++) {
      if (bitmap_p(bitmap, callsite_gc_roots + spill_slot)) {
#ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("visiting GC root " << spill_slot);
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
  call_frame_slot_visitor<Fixup> call_frame_visitor(this, NULL);
  parent->iterate_callstack_object(stack, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_callstack(context* ctx) {
  call_frame_slot_visitor<Fixup> call_frame_visitor(this, ctx);
  parent->iterate_callstack(ctx, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_context(context* ctx) {
  /* Callstack is visited first because it scrubs the data and retain
     stacks. */
  visit_callstack(ctx);

  cell ds_ptr = ctx->datastack;
  cell rs_ptr = ctx->retainstack;
  segment* ds_seg = ctx->datastack_seg;
  segment* rs_seg = ctx->retainstack_seg;
  visit_stack_elements(ds_seg, (cell*)ds_ptr);
  visit_stack_elements(rs_seg, (cell*)rs_ptr);
  visit_object_array(ctx->context_objects,
                     ctx->context_objects + context_object_count);

  /* Clear out the space not visited with a known pattern. That makes
     it easier to see if uninitialized reads are made. */
  ctx->fill_stack_seg(ds_ptr, ds_seg, 0xbaadbadd);
  ctx->fill_stack_seg(rs_ptr, rs_seg, 0xdaabdaab);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_code_block_objects(code_block* compiled) {
  visit_handle(&compiled->owner);
  visit_handle(&compiled->parameters);
  visit_handle(&compiled->relocation);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_embedded_literals(code_block* compiled) {
  if (parent->code->uninitialized_p(compiled))
    return;

  auto update_literal_refs = [&](instruction_operand op) {
    if (op.rel_type() == RT_LITERAL)
      op.store_value(visit_pointer(op.load_value()));
  };
  compiled->each_instruction_operand(update_literal_refs);
}

template <typename Fixup> struct call_frame_code_block_visitor {
  Fixup fixup;

  call_frame_code_block_visitor(Fixup fixup)
      : fixup(fixup) {}

  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
    code_block* compiled =
        Fixup::translated_code_block_map ? owner : fixup.fixup_code(owner);
    cell fixed_addr = compiled->address_for_offset(owner->offset(addr));

    *(cell*)frame_top = fixed_addr;
  }
};

template <typename Fixup>
void slot_visitor<Fixup>::visit_object_code_block(object* obj) {
  switch (obj->type()) {
    case WORD_TYPE: {
      word* w = (word*)obj;
      if (w->entry_point)
        w->entry_point = fixup.fixup_code(w->code())->entry_point();
      break;
    }
    case QUOTATION_TYPE: {
      quotation* q = (quotation*)obj;
      if (q->entry_point)
        q->entry_point = fixup.fixup_code(q->code())->entry_point();
      break;
    }
    case CALLSTACK_TYPE: {
      callstack* stack = (callstack*)obj;
      call_frame_code_block_visitor<Fixup> call_frame_visitor(fixup);
      parent->iterate_callstack_object(stack, call_frame_visitor, fixup);
      break;
    }
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_context_code_blocks() {
  call_frame_code_block_visitor<Fixup> call_frame_visitor(fixup);
  FACTOR_FOR_EACH(parent->active_contexts) {
    parent->iterate_callstack(*iter, call_frame_visitor, fixup);
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_uninitialized_code_blocks() {
  std::map<code_block*, cell> new_uninitialized_blocks;
  FACTOR_FOR_EACH(parent->code->uninitialized_blocks) {
    new_uninitialized_blocks.insert(
        std::make_pair(fixup.fixup_code(iter->first), iter->second));
  }
  parent->code->uninitialized_blocks = new_uninitialized_blocks;
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_embedded_code_pointers(code_block* compiled) {
  if (parent->code->uninitialized_p(compiled))
    return;
  auto update_code_block_refs = [&](instruction_operand op){
    relocation_type type = op.rel_type();
    if (type == RT_ENTRY_POINT ||
        type == RT_ENTRY_POINT_PIC ||
        type == RT_ENTRY_POINT_PIC_TAIL)
      op.store_code_block(fixup.fixup_code(op.load_code_block()));
  };
  compiled->each_instruction_operand(update_code_block_refs);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_object(object *ptr) {
  visit_slots(ptr);
  if (ptr->type() == ALIEN_TYPE)
    ((alien*)ptr)->update_address();
}

/* Pops items from the mark stack and visits them until the stack is
   empty. Used when doing a full collection and when collecting to
   tenured space. */
template <typename Fixup>
void slot_visitor<Fixup>::visit_mark_stack(std::vector<cell>* mark_stack) {
  while (!mark_stack->empty()) {
    cell ptr = mark_stack->back();
    mark_stack->pop_back();

    if (ptr & 1) {
      code_block* compiled = (code_block*)(ptr - 1);
      visit_code_block_objects(compiled);
      visit_embedded_literals(compiled);
      visit_embedded_code_pointers(compiled);
    } else {
      object* obj = (object*)ptr;
      visit_object(obj);
      visit_object_code_block(obj);
    }
  }
}

/* Visits the instruction operands in a code block. If the operand is
   a pointer to a code block or data object, then the fixup is applied
   to it. Otherwise, if it is an external addess, that address is
   recomputed. If it is an untagged number literal (RT_UNTAGGED) or an
   immediate value, then nothing is done with it. */
template <typename Fixup>
void slot_visitor<Fixup>::visit_instruction_operands(code_block* block,
                                                     cell rel_base) {
  auto visit_func = [&](instruction_operand op){
    cell old_offset = rel_base + op.rel_offset();
    cell value = op.load_value(old_offset);
    switch (op.rel_type()) {
      case RT_LITERAL: {
        value = visit_pointer(value);
        break;
      }
      case RT_ENTRY_POINT:
      case RT_ENTRY_POINT_PIC:
      case RT_ENTRY_POINT_PIC_TAIL:
      case RT_HERE: {
        cell offset = TAG(value);
        code_block* compiled = (code_block*)UNTAG(value);
        value = RETAG(fixup.fixup_code(compiled), offset);
        break;
      }
      case RT_UNTAGGED:
        break;
      default:
        value = parent->compute_external_address(op);
        break;
    }
    op.store_value(value);
  };
  block->each_instruction_operand(visit_func);
}

}
