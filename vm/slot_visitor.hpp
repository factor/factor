namespace factor {

// Size sans alignment.
template <typename Fixup>
cell object::base_size(Fixup fixup) const {
  switch (type()) {
    case ARRAY_TYPE:
      return array_size(reinterpret_cast<array*>(const_cast<object*>(this)));
    case BIGNUM_TYPE:
      return array_size(reinterpret_cast<bignum*>(const_cast<object*>(this)));
    case BYTE_ARRAY_TYPE:
      return array_size(reinterpret_cast<byte_array*>(const_cast<object*>(this)));
    case STRING_TYPE:
      return string_size(string_capacity(reinterpret_cast<string*>(const_cast<object*>(this))));
    case TUPLE_TYPE: {
      tuple_layout* layout = reinterpret_cast<tuple_layout*>(fixup.translate_data(
          untag<object>((reinterpret_cast<tuple*>(const_cast<object*>(this)))->layout)));
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
      fixnum callstack_length = untag_fixnum((reinterpret_cast<callstack*>(const_cast<object*>(this)))->length);
      return callstack_object_size(static_cast<cell>(callstack_length));
    }
    default:
      critical_error("Invalid header in base_size", reinterpret_cast<cell>(this));
      return 0;
  }
}

// Size of the object pointed to by an untagged pointer
template <typename Fixup>
cell object::size(Fixup fixup) const {
  if (free_p())
    return (reinterpret_cast<const free_heap_block*>(this))->size();
  return align(base_size(fixup), data_alignment);
}

inline cell object::size() const { return size(no_fixup()); }

// The number of slots (cells) in an object which should be scanned by
// the GC. The number can vary in arrays and tuples, in all other
// types the number is a constant.
template <typename Fixup>
inline cell object::slot_count(Fixup fixup) const {
  if (free_p())
    return 0;

  cell t = type();
  if (t == ARRAY_TYPE) {
    // capacity + n slots
    return 1 + array_capacity(reinterpret_cast<array*>(const_cast<object*>(this)));
  } else if (t == TUPLE_TYPE) {
    tuple_layout* layout = reinterpret_cast<tuple_layout*>(fixup.translate_data(
        untag<object>((reinterpret_cast<tuple*>(const_cast<object*>(this)))->layout)));
    // layout + n slots
    return 1 + tuple_capacity(layout);
  } else {
    switch (t) {
      // these objects do not refer to other objects at all
      case FLOAT_TYPE:
      case BIGNUM_TYPE:
      case BYTE_ARRAY_TYPE:
      case CALLSTACK_TYPE: return 0;
      case QUOTATION_TYPE: return 3;
      case ALIEN_TYPE: return 2;
      case WRAPPER_TYPE: return 1;
      case STRING_TYPE: return 3;
      case WORD_TYPE: return 8;
      case DLL_TYPE: return 1;
      default:
        critical_error("Invalid header in slot_count", reinterpret_cast<cell>(this));
        return 0; // can't happen
    }
  }
}

inline cell object::slot_count() const {
  return slot_count(no_fixup());
}

// Slot visitors iterate over the slots of an object, applying a functor to
// each one that is a non-immediate slot. The pointer is untagged first.
// The functor returns a new untagged object pointer. The return value may
// or may not equal the old one, however the new pointer receives the same
// tag before being stored back to the original location.

// Slots storing immediate values are left unchanged and the visitor does
// inspect them.

// This is used by GC's copying, sweep and compact phases, and the
// implementation of the become primitive.

// Iteration is driven by visit_*() methods. Only one of them define GC
// roots:
//  - visit_all_roots()

// Code block visitors iterate over sets of code blocks, applying a functor
// to each one. The functor returns a new code_block pointer, which may or
// may not equal the old one. This is stored back to the original location.

// This is used by GC's sweep and compact phases, and the implementation of
// the modify-code-heap primitive.

// Iteration is driven by visit_*() methods. Some of them define GC roots:
//  - visit_context_code_blocks()
//  - visit_callback_code_blocks()

template <typename Fixup> struct slot_visitor {
  factor_vm* parent;
  Fixup fixup;
  cell cards_scanned;
  cell decks_scanned;

  slot_visitor(factor_vm* parent_vm, const Fixup& fixup_param)
  : parent(parent_vm),
    fixup(fixup_param),
    cards_scanned(0),
    decks_scanned(0) { }

  cell visit_pointer(cell pointer);
  void visit_handle(cell* handle);
  void visit_object_array(cell* start, cell* end);
  void visit_partial_objects(cell start, cell card_start, cell card_end);
  void visit_slots(object* ptr);
  void visit_stack_elements(segment* region, cell* top);
  void visit_all_roots();
  void visit_callstack_object(callstack* stack);
  void visit_callstack(context* ctx);
  void visit_context(context *ctx);
  void visit_object_code_block(object* obj);
  void visit_context_code_blocks();
  void visit_uninitialized_code_blocks();
  void visit_object(object* obj);
  void visit_mark_stack(std::vector<cell>* mark_stack);


  template <typename SourceGeneration>
  cell visit_card(SourceGeneration* gen, cell index, cell start);
  template <typename SourceGeneration>
  void visit_cards(SourceGeneration* gen, card mask, card unmask);


  template <typename TargetGeneration>
  void cheneys_algorithm(TargetGeneration* gen, cell scan);

  // Visits the data pointers in code blocks in the remembered set.
  void visit_code_heap_roots(std::set<code_block*>* remembered_set);

  // Visits pointers embedded in instructions in code blocks.
  void visit_instruction_operands(code_block* block, cell rel_base);
  void visit_embedded_code_pointers(code_block* compiled);
  void visit_embedded_literals(code_block* compiled);

  // Visits data pointers in code blocks.
  void visit_code_block_objects(code_block* compiled);
};

template <typename Fixup>
cell slot_visitor<Fixup>::visit_pointer(cell pointer) {
  object* untagged = fixup.fixup_data(untag<object>(pointer));
  return RETAG(untagged, TAG(pointer));
}

template <typename Fixup> void slot_visitor<Fixup>::visit_handle(cell* handle) {
  if (!immediate_p(*handle)) [[likely]] {
    *handle = visit_pointer(*handle);
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_object_array(cell* start, cell* end) {
  while (start < end)
    visit_handle(start++);
}

template <typename Fixup> void slot_visitor<Fixup>::visit_slots(object* obj) {
  if (obj->type() == CALLSTACK_TYPE) [[unlikely]]
    visit_callstack_object(reinterpret_cast<callstack*>(obj));
  else {
    cell* start = reinterpret_cast<cell*>(obj) + 1;
    cell* end = start + obj->slot_count(fixup);
    visit_object_array(start, end);
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_stack_elements(segment* region, cell* top) {
  visit_object_array(reinterpret_cast<cell*>(region->start), top + 1);
}

template <typename Fixup> void slot_visitor<Fixup>::visit_all_roots() {
  for (auto* root : parent->data_roots) {
    visit_handle(root);
  }

  auto callback_slot_visitor = [&](code_block* stub, cell size) {
	  (void)size;
    visit_handle(&stub->owner);
  };
  parent->callbacks->allocator->iterate(callback_slot_visitor, no_fixup());

  for (auto& entry : parent->code->uninitialized_blocks) {
    entry.second = visit_pointer(entry.second);
  }

  for (auto& sample : parent->samples) {
    visit_handle(&sample.thread);
  }

  visit_object_array(parent->special_objects,
                     parent->special_objects + special_object_count);

  for (const auto& ctx_ptr : parent->active_contexts) {
    visit_context(ctx_ptr.get());
  }
}

// primitive_minor_gc() is invoked by inline GC checks, and it needs to
// visit spill slots which references objects in the heap.

// So for each call frame:
//  - trace roots in spill slots

template <typename Fixup> struct call_frame_slot_visitor {
  slot_visitor<Fixup>* visitor;

  call_frame_slot_visitor(slot_visitor<Fixup>* visitor_param)
      : visitor(visitor_param) {}

  // frame top -> [return address]
  //              [spill area]
  //              ...
  //              [entry_point]
  //              [size]

  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
	  (void)size;
    cell return_address = owner->offset(addr);

    code_block* compiled =
        Fixup::translated_code_block_map ? owner
                                         : visitor->fixup.translate_code(owner);
    gc_info* info = compiled->block_gc_info();

    FACTOR_ASSERT(return_address < compiled->size());
    cell callsite = info->return_address_index(return_address);
    if (callsite == static_cast<cell>(-1))
      return;

#ifdef DEBUG_GC_MAPS
    FACTOR_PRINT("call frame code block " << compiled << " with offset "
                 << return_address);
#endif
    cell* stack_pointer = reinterpret_cast<cell*>(frame_top + FRAME_RETURN_ADDRESS);
    uint8_t* bitmap = info->gc_info_bitmap();

    // Subtract old value of base pointer from every derived pointer.
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != static_cast<uint32_t>(-1)) {
#ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("visiting derived root " << spill_slot
                     << " with base pointer " << base_pointer);
#endif
        stack_pointer[spill_slot] -= stack_pointer[base_pointer];
      }
    }

    // Update all GC roots, including base pointers.
    cell callsite_gc_roots = info->callsite_gc_roots(callsite);

    for (cell spill_slot = 0; spill_slot < info->gc_root_count; spill_slot++) {
      if (bitmap_p(bitmap, callsite_gc_roots + spill_slot)) {
        #ifdef DEBUG_GC_MAPS
        FACTOR_PRINT("visiting GC root " << spill_slot);
        #endif
        visitor->visit_handle(stack_pointer + spill_slot);
      }
    }

    // Add the base pointers to obtain new derived pointer values.
    for (cell spill_slot = 0; spill_slot < info->derived_root_count;
         spill_slot++) {
      uint32_t base_pointer = info->lookup_base_pointer(callsite, spill_slot);
      if (base_pointer != static_cast<uint32_t>(-1))
        stack_pointer[spill_slot] += stack_pointer[base_pointer];
    }
  }
};

template <typename Fixup>
void slot_visitor<Fixup>::visit_callstack_object(callstack* stack) {
  call_frame_slot_visitor<Fixup> call_frame_visitor(this);
  parent->iterate_callstack_object(stack, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_callstack(context* ctx) {
  call_frame_slot_visitor<Fixup> call_frame_visitor(this);
  parent->iterate_callstack(ctx, call_frame_visitor, fixup);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_context(context* ctx) {
  visit_callstack(ctx);

  cell ds_ptr = ctx->datastack;
  cell rs_ptr = ctx->retainstack;
  segment* ds_seg = ctx->datastack_seg.get();
  segment* rs_seg = ctx->retainstack_seg.get();
  visit_stack_elements(ds_seg, reinterpret_cast<cell*>(ds_ptr));
  visit_stack_elements(rs_seg, reinterpret_cast<cell*>(rs_ptr));
  visit_object_array(ctx->context_objects,
                     ctx->context_objects + context_object_count);

  // Clear out the space not visited with a known pattern. That makes
  // it easier to see if uninitialized reads are made.
  ctx->fill_stack_seg(ds_ptr, ds_seg, 0xbaadbadd);
  ctx->fill_stack_seg(rs_ptr, rs_seg, 0xdaabdabb);
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
    if (op.rel.type() == RT_LITERAL) {
      cell value = op.load_value(op.pointer);
      if (!immediate_p(value)) {
        op.store_value(visit_pointer(value));
      }
    }
  };
  compiled->each_instruction_operand(update_literal_refs);
}

template <typename Fixup> struct call_frame_code_block_visitor {
  Fixup fixup;

  call_frame_code_block_visitor(Fixup fixup_param) : fixup(fixup_param) {}

  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
    (void)size;
	  code_block* compiled =
        Fixup::translated_code_block_map ? owner : fixup.fixup_code(owner);
    cell fixed_addr = compiled->address_for_offset(owner->offset(addr));

    *reinterpret_cast<cell*>(frame_top + FRAME_RETURN_ADDRESS) = fixed_addr;
  }
};

template <typename Fixup>
void slot_visitor<Fixup>::visit_object_code_block(object* obj) {
  switch (obj->type()) {
    case WORD_TYPE: {
      word* w = static_cast<word*>(obj);
      if (w->entry_point)
        w->entry_point = fixup.fixup_code(w->code())->entry_point();
      break;
    }
    case QUOTATION_TYPE: {
      quotation* q = static_cast<quotation*>(obj);
      if (q->entry_point)
        q->entry_point = fixup.fixup_code(q->code())->entry_point();
      break;
    }
    case CALLSTACK_TYPE: {
      callstack* stack = static_cast<callstack*>(obj);
      call_frame_code_block_visitor<Fixup> call_frame_visitor(fixup);
      parent->iterate_callstack_object(stack, call_frame_visitor, fixup);
      break;
    }
    default:
      break;
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_context_code_blocks() {
  call_frame_code_block_visitor<Fixup> call_frame_visitor(fixup);
  for (const auto& ctx_ptr : parent->active_contexts) {
    parent->iterate_callstack(ctx_ptr.get(), call_frame_visitor, fixup);
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_uninitialized_code_blocks() {
  std::map<code_block*, cell> new_uninitialized_blocks;
  for (const auto& entry : parent->code->uninitialized_blocks) {
    new_uninitialized_blocks.insert(
        std::make_pair(fixup.fixup_code(entry.first), entry.second));
  }
  parent->code->uninitialized_blocks = new_uninitialized_blocks;
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_embedded_code_pointers(code_block* compiled) {
  if (parent->code->uninitialized_p(compiled))
    return;
  auto update_code_block_refs = [&](instruction_operand op){
    relocation_type type = op.rel.type();
    if (type == RT_ENTRY_POINT ||
        type == RT_ENTRY_POINT_PIC ||
        type == RT_ENTRY_POINT_PIC_TAIL) {
      code_block* block = fixup.fixup_code(op.load_code_block());
      op.store_value(block->entry_point());
    }
  };
  compiled->each_instruction_operand(update_code_block_refs);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_object(object *ptr) {
  visit_slots(ptr);
  if (ptr->type() == ALIEN_TYPE)
    static_cast<alien*>(ptr)->update_address();
}

// Pops items from the mark stack and visits them until the stack is
// empty. Used when doing a full collection and when collecting to
// tenured space.
template <typename Fixup>
void slot_visitor<Fixup>::visit_mark_stack(std::vector<cell>* mark_stack) {
  while (!mark_stack->empty()) {
    cell ptr = mark_stack->back();
    mark_stack->pop_back();

    if (ptr & 1) {
      code_block* compiled = reinterpret_cast<code_block*>(ptr - 1);
      visit_code_block_objects(compiled);
      visit_embedded_literals(compiled);
      visit_embedded_code_pointers(compiled);
    } else {
      object* obj = reinterpret_cast<object*>(ptr);
      visit_object(obj);
      visit_object_code_block(obj);
    }
  }
}

// Visits the instruction operands in a code block. If the operand is
// a pointer to a code block or data object, then the fixup is applied
// to it. Otherwise, if it is an external addess, that address is
// recomputed. If it is an untagged number literal (RT_UNTAGGED) or an
// immediate value, then nothing is done with it.
template <typename Fixup>
void slot_visitor<Fixup>::visit_instruction_operands(code_block* block,
                                                     cell rel_base) {
  auto visit_func = [&](instruction_operand op){
    cell old_offset = rel_base + op.rel.offset();
    cell old_value = op.load_value(old_offset);
    switch (op.rel.type()) {
      case RT_LITERAL: {
        if (!immediate_p(old_value)) {
          op.store_value(visit_pointer(old_value));
        }
        break;
      }
      case RT_ENTRY_POINT:
      case RT_ENTRY_POINT_PIC:
      case RT_ENTRY_POINT_PIC_TAIL:
      case RT_HERE: {
        cell offset = TAG(old_value);
        code_block* compiled = reinterpret_cast<code_block*>(UNTAG(old_value));
        op.store_value(RETAG(fixup.fixup_code(compiled), offset));
        break;
      }
      case RT_UNTAGGED:
        break;
      default:
        op.store_value(parent->compute_external_address(op));
        break;
    }
  };
  if (parent->code->uninitialized_p(block))
    return;
  block->each_instruction_operand(visit_func);
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_partial_objects(cell start,
                                                cell card_start,
                                                cell card_end) {
  cell *scan_start = reinterpret_cast<cell*>(start) + 1;
  cell *scan_end = scan_start + reinterpret_cast<object*>(start)->slot_count();

  scan_start = std::max(scan_start, reinterpret_cast<cell*>(card_start));
  scan_end = std::min(scan_end, reinterpret_cast<cell*>(card_end));

  visit_object_array(scan_start, scan_end);
}

template <typename Fixup>
template <typename SourceGeneration>
cell slot_visitor<Fixup>::visit_card(SourceGeneration* gen,
                                     cell index, cell start) {
  cell heap_base = parent->data->start;
  cell start_addr = heap_base + index * card_size;
  cell end_addr = start_addr + card_size;

  // Forward to the next object whose address is in the card.
  if (!start || (start + reinterpret_cast<object*>(start)->size()) < start_addr) {
    // Optimization because finding the objects in a memory range is
    // expensive. It helps a lot when tracing consecutive cards.
    cell gen_start_card = (gen->start - heap_base) / card_size;
    start = gen->starts
        .find_object_containing_card(index - gen_start_card);
  }

  while (start && start < end_addr) {
    visit_partial_objects(start, start_addr, end_addr);
    if ((start + reinterpret_cast<object*>(start)->size()) >= end_addr) {
      // The object can overlap the card boundary, then the
      // remainder of it will be handled in the next card
      // tracing if that card is marked.
      break;
    }
    start = gen->next_object_after(start);
  }
  return start;
}

template <typename Fixup>
template <typename SourceGeneration>
void slot_visitor<Fixup>::visit_cards(SourceGeneration* gen,
                                      card mask, card unmask) {
  card_deck* decks = parent->data->decks.get();
  card_deck* cards = parent->data->cards.get();
  cell heap_base = parent->data->start;

  cell first_deck = (gen->start - heap_base) / deck_size;
  cell last_deck = (gen->end - heap_base) / deck_size;

  // Address of last traced object.
  cell start = 0;
  for (cell di = first_deck; di < last_deck; di++) {
    if (decks[di] & mask) {
      decks[di] &= ~unmask;
      decks_scanned++;

      cell first_card = cards_per_deck * di;
      cell last_card = first_card + cards_per_deck;

      for (cell ci = first_card; ci < last_card; ci++) {
        if (cards[ci] & mask) {
          cards[ci] &= ~unmask;
          cards_scanned++;

          start = visit_card(gen, ci, start);
          if (!start) {
            // At end of generation, no need to scan more cards.
            return;
          }
        }
      }
    }
  }
}

template <typename Fixup>
void slot_visitor<Fixup>::visit_code_heap_roots(std::set<code_block*>* remembered_set) {
  for (auto* compiled : *remembered_set) {
    visit_code_block_objects(compiled);
    visit_embedded_literals(compiled);
    compiled->flush_icache();
  }
}

template <typename Fixup>
template <typename TargetGeneration>
void slot_visitor<Fixup>::cheneys_algorithm(TargetGeneration* gen, cell scan) {
  while (scan && scan < gen->here) {
    visit_object(reinterpret_cast<object*>(scan));
    scan = gen->next_object_after(scan);
  }
}

}
