#include "master.hpp"

namespace factor {

#if defined(__APPLE__) && defined(FACTOR_ARM64)
// Current W^X mode of this thread's JIT pages. False = executable (the state
// Factor code runs in), true = writable. See code_heap.hpp.
thread_local bool jit_thread_writable = false;
#endif

code_heap::code_heap(cell size) {
  if (size > ((uint64_t)1 << (sizeof(cell) * 8 - 5)))
    fatal_error("Heap too large", size);
#ifdef FACTOR_ARM64
  if (size > 0x8000000)
    fatal_error("Heap too large", size);
#endif
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
  seg = new segment(align_page(size) + getpagesize(), true);
#else
  seg = new segment(align_page(size), true);
#endif
  if (!seg)
    fatal_error("Out of memory in code_heap constructor", size);

#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
  safepoint_seg = NULL;
  safepoint_page = seg->end - getpagesize();
#else
  safepoint_seg = new segment(align_page(getpagesize()), false);
  if (!safepoint_seg)
    fatal_error("Out of memory in code_heap constructor", size);
  safepoint_page = safepoint_seg->start;
#endif

  cell start = seg->start + seh_area_size;
  cell end = safepoint_seg ? seg->end : safepoint_page;

  allocator = new free_list_allocator<code_block>(end - start, start);

  // See os-windows-*.64.cpp for seh_area usage
  seh_area = (char*)seg->start;
}

code_heap::~code_heap() {
  delete allocator;
  allocator = NULL;
  delete seg;
  seg = NULL;
  if (safepoint_seg) {
    delete safepoint_seg;
    safepoint_seg = NULL;
  }
}

void code_heap::write_barrier(code_block* compiled) {
  points_to_nursery.insert(compiled);
  points_to_aging.insert(compiled);
}

void code_heap::clear_remembered_set() {
  points_to_nursery.clear();
  points_to_aging.clear();
}

bool code_heap::uninitialized_p(code_block* compiled) {
  return uninitialized_blocks.count(compiled) > 0;
}

void code_heap::free(code_block* compiled) {
  FACTOR_ASSERT(!uninitialized_p(compiled));
  points_to_nursery.erase(compiled);
  points_to_aging.erase(compiled);
  all_blocks.erase((cell)compiled);
  // Writes a free-list header into the MAP_JIT code heap.
  jit_writable_scope jit_writable;
  allocator->free(compiled);
}

void code_heap::flush_icache() { factor::flush_icache(seg->start, seg->size); }

void code_heap::set_safepoint_guard(bool locked) {
  if (!set_memory_locked(safepoint_page, getpagesize(), locked)) {
    fatal_error("Cannot (un)protect safepoint guard page", safepoint_page);
  }
}

void code_heap::sweep() {
  auto clear_free_blocks_from_all_blocks = [&](code_block* block, cell size) {
    std::set<cell>::iterator erase_from =
      all_blocks.lower_bound((cell)block);
    std::set<cell>::iterator erase_to =
      all_blocks.lower_bound((cell)block + size);
    all_blocks.erase(erase_from, erase_to);
  };
  allocator->sweep(clear_free_blocks_from_all_blocks);
#ifdef FACTOR_DEBUG
  verify_all_blocks_set();
#endif
}

void code_heap::verify_all_blocks_set() {
  auto all_blocks_set_verifier = [&](code_block* block, cell size) {
    (void)block;
    (void)size;
    FACTOR_ASSERT(all_blocks.find((cell)block) != all_blocks.end());
  };
  allocator->iterate(all_blocks_set_verifier, no_fixup());
}

code_block* code_heap::code_block_for_address(cell address) {
  std::set<cell>::const_iterator blocki = all_blocks.upper_bound(address);
  FACTOR_ASSERT(blocki != all_blocks.begin());
  --blocki;
  code_block* found_block = (code_block*)*blocki;
  FACTOR_ASSERT(found_block->entry_point() <=
                address // XXX this isn't valid during fixup. should store the
                        //     size in the map
                        //    && address - found_block->entry_point() <
                        //       found_block->size()
                );
  return found_block;
}

cell code_heap::frame_predecessor(cell frame_top) {
#ifdef FACTOR_ARM64
  return *(cell*)frame_top;
#else
  cell addr = *(cell*)frame_top;
  FACTOR_ASSERT(seg->in_segment_p(addr));
  code_block* owner = code_block_for_address(addr);
  cell frame_size = owner->stack_frame_size_for_address(addr);
  return frame_top + frame_size;
#endif
}

// Recomputes the all_blocks set of code blocks
void code_heap::initialize_all_blocks_set() {
  all_blocks.clear();
  auto all_blocks_set_inserter = [&](code_block* block, cell size) {
    (void)size;
    all_blocks.insert((cell)block);
  };
  allocator->iterate(all_blocks_set_inserter, no_fixup());
#ifdef FACTOR_DEBUG
  verify_all_blocks_set();
#endif
}

// Update pointers to words referenced from all code blocks.
// Only needed after redefining an existing word.
// If generic words were redefined, inline caches need to be reset.
// When redefined_words is given, only PICs referencing one of those words
// are invalidated instead of every PIC in the code heap.
void factor_vm::update_code_heap_words(bool reset_inline_caches,
                                       const std::set<cell>* redefined_words) {
  // Patches call sites in every existing code block.
  jit_writable_scope jit_writable;

  if (reset_inline_caches && redefined_words) {
    // Free stale PICs before the patch pass so their call sites observe
    // free_p() and get reset to the miss stub, while call sites of
    // surviving PICs are left intact.
    auto pic_freer = [&](code_block* block, cell size) {
      (void)size;
      if (block->pic_p() && !code->uninitialized_p(block) &&
          pic_references_words(block, *redefined_words))
        code->free(block);
    };
    each_code_block(pic_freer);
  }

  auto word_updater = [&](code_block* block, cell size) {
    (void)size;
    update_word_references(block, reset_inline_caches, redefined_words);
  };
  each_code_block(word_updater);
}

// Allocates memory
void factor_vm::primitive_modify_code_heap() {
  bool reset_inline_caches = to_boolean(ctx->pop());
  bool update_existing_words = to_boolean(ctx->pop());
  data_root<array> alist(ctx->pop(), this);

  cell count = array_capacity(alist.untagged());

  if (count == 0)
    return;

  // Compiles and patches many blocks; hold one writable region across the
  // whole unit so the per-block funnel scopes below are flip-free no-ops.
  jit_writable_scope jit_writable;

  for (cell i = 0; i < count; i++) {
    data_root<array> pair(array_nth(alist.untagged(), i), this);

    data_root<word> word(array_nth(pair.untagged(), 0), this);
    data_root<object> data(array_nth(pair.untagged(), 1), this);

    switch (data.type()) {
      case QUOTATION_TYPE:
      case TUPLE_TYPE: // for curry/compose, see issue #2763
        jit_compile_word(word.value(), data.value(), false);
        break;
      case ARRAY_TYPE: {
        array* compiled_data = data.as<array>().untagged();
        cell parameters = array_nth(compiled_data, 0);
        cell literals = array_nth(compiled_data, 1);
        cell relocation = array_nth(compiled_data, 2);
        cell labels = array_nth(compiled_data, 3);
        cell code = array_nth(compiled_data, 4);
        cell frame_size = untag_fixnum(array_nth(compiled_data, 5));

        code_block* compiled =
            add_code_block(CODE_BLOCK_OPTIMIZED, code, labels, word.value(),
                           relocation, parameters, literals, frame_size);

        word->entry_point = compiled->entry_point();
      } break;
      default:
        critical_error("Expected a quotation or an array", data.value());
        break;
    }
  }

  if (update_existing_words) {
    // Collect the words being (re)defined in this compilation unit. Built
    // after the compile loop above since jit_compile_word can trigger GC,
    // which would move the word objects; nothing below allocates.
    std::set<cell> redefined_words;
    for (cell i = 0; i < count; i++) {
      array* pair = untag<array>(array_nth(alist.untagged(), i));
      redefined_words.insert(array_nth(pair, 0));
    }
    update_code_heap_words(reset_inline_caches, &redefined_words);
  } else {
    // Fast path for compilation units that only define new words.
    FACTOR_FOR_EACH(code->uninitialized_blocks) {
      initialize_code_block(iter->first, iter->second);
    }
    code->uninitialized_blocks.clear();
  }
  FACTOR_ASSERT(code->uninitialized_blocks.size() == 0);
}

// Allocates memory
void factor_vm::primitive_code_room() {
  allocator_room room = code->allocator->as_allocator_room();
  ctx->push(tag<byte_array>(byte_array_from_value(&room)));
}

void factor_vm::primitive_strip_stack_traces() {
  jit_writable_scope jit_writable;
  auto stack_trace_stripper = [](code_block* block, cell size) {
    (void)size;
    block->owner = false_object;
  };
  each_code_block(stack_trace_stripper);
}

// Allocates memory
void factor_vm::primitive_code_blocks() {
  // Allocate before capturing any fields. The allocation may collect and
  // compact the code heap, so a malloc-side snapshot of raw entry points can
  // be stale by the time it is copied. If that collection also reclaims code,
  // retry with the new count; the fill pass itself never allocates.
  for (;;) {
    cell block_count = 0;
    auto code_block_counter = [&](code_block* block, cell size) {
      (void)block;
      (void)size;
      block_count++;
    };
    each_code_block(code_block_counter);

    tagged<array> objects(allot_uninitialized_array<array>(block_count * 6));
    cell count = 0;
    bool count_changed = false;
    auto code_block_accumulator = [&](code_block* block, cell size) {
      (void)size;
      if (count + 6 > block_count * 6) {
        count_changed = true;
        return;
      }

      cell* data = objects->data();
      data[count++] = block->owner;
      data[count++] = block->parameters;
      data[count++] = block->relocation;
      data[count++] = tag_fixnum(block->type());
      data[count++] = tag_fixnum(block->size());

      // Entry points are heap-aligned, so library code can treat this cell as
      // a fixnum and shift it back to an address without allocating here.
      cell entry_point = block->entry_point();
      FACTOR_ASSERT((entry_point & (data_alignment - 1)) == 0);
      FACTOR_ASSERT((entry_point & TAG_MASK) == FIXNUM_TYPE);
      data[count++] = entry_point;
    };
    each_code_block(code_block_accumulator);

    if (!count_changed && count == block_count * 6) {
      ctx->push(objects.value());
      return;
    }
  }
}

}
