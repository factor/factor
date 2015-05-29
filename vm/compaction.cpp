#include "master.hpp"

namespace factor {

struct compaction_fixup {
  static const bool translated_code_block_map = false;

  mark_bits* data_forwarding_map;
  mark_bits* code_forwarding_map;
  const object** data_finger;
  const code_block** code_finger;

  compaction_fixup(mark_bits* data_forwarding_map,
                   mark_bits* code_forwarding_map,
                   const object** data_finger,
                   const code_block** code_finger)
      : data_forwarding_map(data_forwarding_map),
        code_forwarding_map(code_forwarding_map),
        data_finger(data_finger),
        code_finger(code_finger) {}

  object* fixup_data(object* obj) {
    return (object*)data_forwarding_map->forward_block((cell)obj);
  }

  code_block* fixup_code(code_block* compiled) {
    return (code_block*)code_forwarding_map->forward_block((cell)compiled);
  }

  object* translate_data(const object* obj) {
    if (obj < *data_finger)
      return fixup_data((object*)obj);
    else
      return (object*)obj;
  }

  code_block* translate_code(const code_block* compiled) {
    if (compiled < *code_finger)
      return fixup_code((code_block*)compiled);
    else
      return (code_block*)compiled;
  }

  cell size(object* obj) {
    if (data_forwarding_map->marked_p((cell)obj))
      return obj->size(*this);
    else
      return data_forwarding_map->unmarked_block_size((cell)obj);
  }

  cell size(code_block* compiled) {
    if (code_forwarding_map->marked_p((cell)compiled))
      return compiled->size(*this);
    else
      return code_forwarding_map->unmarked_block_size((cell)compiled);
  }
};

struct object_compaction_updater {
  factor_vm* parent;
  compaction_fixup fixup;
  object_start_map* starts;

  object_compaction_updater(factor_vm* parent, compaction_fixup fixup)
      : parent(parent),
        fixup(fixup),
        starts(&parent->data->tenured->starts) {}

  void operator()(object* old_address, object* new_address, cell size) {
    slot_visitor<compaction_fixup> forwarder(parent, fixup);
    forwarder.visit_slots(new_address);
    forwarder.visit_object_code_block(new_address);
    starts->record_object_start_offset(new_address);
  }
};

template <typename Fixup> struct code_block_compaction_relocation_visitor {
  factor_vm* parent;
  code_block* old_address;
  Fixup fixup;

  code_block_compaction_relocation_visitor(factor_vm* parent,
                                           code_block* old_address,
                                           Fixup fixup)
      : parent(parent), old_address(old_address), fixup(fixup) {}

  void operator()(instruction_operand op) {
    cell old_offset = op.rel_offset() + old_address->entry_point();

    switch (op.rel_type()) {
      case RT_LITERAL: {
        cell value = op.load_value(old_offset);
        if (immediate_p(value))
          op.store_value(value);
        else
          op.store_value(
              RETAG(fixup.fixup_data(untag<object>(value)), TAG(value)));
        break;
      }
      case RT_ENTRY_POINT:
      case RT_ENTRY_POINT_PIC:
      case RT_ENTRY_POINT_PIC_TAIL:
      case RT_HERE: {
        cell value = op.load_value(old_offset);
        cell offset = TAG(value);
        code_block* compiled = (code_block*)UNTAG(value);
        op.store_value((cell)fixup.fixup_code(compiled) + offset);
        break;
      }
      case RT_THIS:
      case RT_CARDS_OFFSET:
      case RT_DECKS_OFFSET:
        parent->store_external_address(op);
        break;
      default:
        op.store_value(op.load_value(old_offset));
        break;
    }
  }
};

template <typename Fixup> struct code_block_compaction_updater {
  factor_vm* parent;
  Fixup fixup;
  slot_visitor<Fixup> forwarder;

  code_block_compaction_updater(
      factor_vm* parent, Fixup fixup, slot_visitor<Fixup> forwarder)
      : parent(parent),
        fixup(fixup),
        forwarder(forwarder) { }

  void operator()(code_block* old_address, code_block* new_address, cell size) {
    forwarder.visit_code_block_objects(new_address);

    code_block_compaction_relocation_visitor<Fixup> visitor(parent, old_address,
                                                            fixup);
    new_address->each_instruction_operand(visitor);
  }
};

/* After a compaction, invalidate any code heap roots which are not
marked, and also slide the valid roots up so that call sites can be updated
correctly in case an inline cache compilation triggered compaction. */
void factor_vm::update_code_roots_for_compaction() {

  mark_bits* state = &code->allocator->state;

  FACTOR_FOR_EACH(code_roots) {
    code_root* root = *iter;
    cell block = root->value & (~data_alignment + 1);

    /* Offset of return address within 16-byte allocation line */
    cell offset = root->value - block;

    if (root->valid && state->marked_p(block)) {
      block = state->forward_block(block);
      root->value = block + offset;
    } else
      root->valid = false;
  }
}

/* Compact data and code heaps */
void factor_vm::collect_compact_impl() {
  gc_event* event = current_gc->event;

#ifdef FACTOR_DEBUG
  code->verify_all_blocks_set();
#endif

  if (event)
    event->started_compaction();

  tenured_space* tenured = data->tenured;
  mark_bits* data_forwarding_map = &tenured->state;
  mark_bits* code_forwarding_map = &code->allocator->state;

  /* Figure out where blocks are going to go */
  data_forwarding_map->compute_forwarding();
  code_forwarding_map->compute_forwarding();

  const object* data_finger = (object*)tenured->start;
  const code_block* code_finger = (code_block*)code->allocator->start;

  {
    compaction_fixup fixup(data_forwarding_map, code_forwarding_map, &data_finger,
                           &code_finger);

    slot_visitor<compaction_fixup> forwarder(this, fixup);

    forwarder.visit_uninitialized_code_blocks();

    /* Object start offsets get recomputed by the object_compaction_updater */
    data->tenured->starts.clear_object_start_offsets();

    /* Slide everything in tenured space up, and update data and code heap
       pointers inside objects. */
    {
      object_compaction_updater object_updater(this, fixup);
      tenured->compact(object_updater, fixup, &data_finger);
    }

    /* Slide everything in the code heap up, and update data and code heap
       pointers inside code blocks. */
    {
      code_block_compaction_updater<compaction_fixup> code_block_updater(
          this, fixup, forwarder);
      code->allocator->compact(code_block_updater, fixup, &code_finger);
    }

    forwarder.visit_all_roots();
    forwarder.visit_context_code_blocks();
  }

  update_code_roots_for_compaction();
  callbacks->update();

  code->initialize_all_blocks_set();

  if (event)
    event->ended_compaction();
}

struct code_compaction_fixup {
  static const bool translated_code_block_map = false;

  mark_bits* code_forwarding_map;
  const code_block** code_finger;

  code_compaction_fixup(mark_bits* code_forwarding_map,
                        const code_block** code_finger)
      : code_forwarding_map(code_forwarding_map), code_finger(code_finger) {}

  object* fixup_data(object* obj) { return obj; }

  code_block* fixup_code(code_block* compiled) {
    return (code_block*)code_forwarding_map->forward_block((cell)compiled);
  }

  object* translate_data(const object* obj) { return fixup_data((object*)obj); }

  code_block* translate_code(const code_block* compiled) {
    if (compiled < *code_finger)
      return fixup_code((code_block*)compiled);
    else
      return (code_block*)compiled;
  }

  cell size(object* obj) { return obj->size(); }

  cell size(code_block* compiled) {
    if (code_forwarding_map->marked_p((cell)compiled))
      return compiled->size(*this);
    else
      return code_forwarding_map->unmarked_block_size((cell)compiled);
  }
};

struct object_grow_heap_updater {
  slot_visitor<code_compaction_fixup> forwarder;

  explicit object_grow_heap_updater(
      slot_visitor<code_compaction_fixup> forwarder)
      : forwarder(forwarder) {}

  void operator()(object* obj) { forwarder.visit_object_code_block(obj); }
};

/* Compact just the code heap, after growing the data heap */
void factor_vm::collect_compact_code_impl() {
  /* Figure out where blocks are going to go */
  mark_bits* code_forwarding_map = &code->allocator->state;
  code_forwarding_map->compute_forwarding();

  const code_block* code_finger = (code_block*)code->allocator->start;

  code_compaction_fixup fixup(code_forwarding_map, &code_finger);
  slot_visitor<code_compaction_fixup> forwarder(this, fixup);

  forwarder.visit_uninitialized_code_blocks();
  forwarder.visit_context_code_blocks();

  /* Update code heap references in data heap */
  object_grow_heap_updater object_updater(forwarder);
  each_object(object_updater);

  /* Slide everything in the code heap up, and update code heap
	pointers inside code blocks. */
  code_block_compaction_updater<code_compaction_fixup> code_block_updater(
      this, fixup, forwarder);
  code->allocator->compact(code_block_updater, fixup, &code_finger);

  update_code_roots_for_compaction();
  callbacks->update();
  code->initialize_all_blocks_set();
}

void factor_vm::collect_compact() {
  collect_mark_impl();
  collect_compact_impl();

  if (data->high_fragmentation_p()) {
    /* Compaction did not free up enough memory. Grow the heap. */
    set_current_gc_op(collect_growing_heap_op);
    collect_growing_heap(0);
  }

  code->flush_icache();
}

void factor_vm::collect_growing_heap(cell requested_size) {
  /* Grow the data heap and copy all live objects to the new heap. */
  data_heap* old = data;
  set_data_heap(data->grow(&nursery, requested_size));
  collect_mark_impl();
  collect_compact_code_impl();
  code->flush_icache();
  delete old;
}

}
