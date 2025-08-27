#include "master.hpp"

namespace factor {

code_heap::code_heap(cell size) {
  if (size > ((uint64_t)1 << (sizeof(cell) * 8 - 5)))
    fatal_error("Heap too large", size);
  seg = std::make_unique<segment>(align_page(size), true);

  cell start = seg->start + getpagesize() + seh_area_size;

  allocator = std::make_unique<free_list_allocator<code_block>>(seg->end - start, start);

  // See os-windows-x86.64.cpp for seh_area usage
  safepoint_page = seg->start;
  seh_area = (char*)seg->start + getpagesize();
}

code_heap::~code_heap() {
  // unique_ptr automatically handles deletion
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
    auto erase_from = all_blocks.lower_bound(reinterpret_cast<cell>(block));
    auto erase_to = all_blocks.lower_bound(reinterpret_cast<cell>(block) + size);
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
    FACTOR_ASSERT(all_blocks.find(reinterpret_cast<cell>(block)) != all_blocks.end());
  };
  allocator->iterate(all_blocks_set_verifier, no_fixup());
}

code_block* code_heap::code_block_for_address(cell address) {
  auto blocki = all_blocks.upper_bound(address);
  FACTOR_ASSERT(blocki != all_blocks.begin());
  --blocki;
  auto* found_block = reinterpret_cast<code_block*>(*blocki);
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
  cell addr = *(cell*)(frame_top + FRAME_RETURN_ADDRESS);
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
    all_blocks.insert(reinterpret_cast<cell>(block));
  };
  allocator->iterate(all_blocks_set_inserter, no_fixup());
#ifdef FACTOR_DEBUG
  verify_all_blocks_set();
#endif
}

// Update pointers to words referenced from all code blocks.
// Only needed after redefining an existing word.
// If generic words were redefined, inline caches need to be reset.
void factor_vm::update_code_heap_words(bool reset_inline_caches) {
  auto word_updater = [&](code_block* block, cell size) {
    (void)size;
    update_word_references(block, reset_inline_caches);
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

  for (cell i = 0; i < count; i++) {
    data_root<array> pair(array_nth(alist.untagged(), i), this);

    data_root<word> word(array_nth(pair.untagged(), 0), this);
    data_root<object> data_obj(array_nth(pair.untagged(), 1), this);

    switch (data_obj.type()) {
      case QUOTATION_TYPE:
      case TUPLE_TYPE: // for curry/compose, see issue #2763
        jit_compile_word(word.value(), data_obj.value(), false);
        break;
      case ARRAY_TYPE: {
        array* compiled_data = data_obj.as<array>().untagged();
        cell parameters = array_nth(compiled_data, 0);
        cell literals = array_nth(compiled_data, 1);
        cell relocation = array_nth(compiled_data, 2);
        cell labels = array_nth(compiled_data, 3);
        cell code_cell = array_nth(compiled_data, 4);
        cell frame_size = untag_fixnum(array_nth(compiled_data, 5));

        code_block* compiled =
            add_code_block(CODE_BLOCK_OPTIMIZED, code_cell, labels, word.value(),
                           relocation, parameters, literals, frame_size);

        word->entry_point = compiled->entry_point();
      } break;
      default:
        critical_error("Expected a quotation or an array", data_obj.value());
        break;
    }
  }

  if (update_existing_words)
    update_code_heap_words(reset_inline_caches);
  else {
    // Fast path for compilation units that only define new words.
    for (const auto& entry : code->uninitialized_blocks) {
      initialize_code_block(entry.first, entry.second);
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
  auto stack_trace_stripper = [](code_block* block, cell size) {
    (void)size;
    block->owner = false_object;
  };
  each_code_block(stack_trace_stripper);
}

// Allocates memory
void factor_vm::primitive_code_blocks() {
  std::vector<cell> objects;
  auto code_block_accumulator = [&](code_block* block, cell size) {
    (void)size;
    objects.push_back(block->owner);
    objects.push_back(block->parameters);
    objects.push_back(block->relocation);

    objects.push_back(tag_fixnum(block->type()));
    objects.push_back(tag_fixnum(block->size()));

    // Note: the entry point is always a multiple of the heap
    // alignment (16 bytes). We cannot allocate while iterating
    // through the code heap, so it is not possible to call
    // from_unsigned_cell() here. It is OK, however, to add it as
    // if it were a fixnum, and have library code shift it to the
    // left by 4.
    cell entry_point = block->entry_point();
    FACTOR_ASSERT((entry_point & (data_alignment - 1)) == 0);
    FACTOR_ASSERT((entry_point & TAG_MASK) == FIXNUM_TYPE);
    objects.push_back(entry_point);
  };
  each_code_block(code_block_accumulator);
  ctx->push(std_vector_to_array(objects));
}

}
