template <typename Iterator, typename Fixup>
inline void factor_vm::iterate_callstack_object(callstack* stack_,
                                                Iterator& iterator,
                                                Fixup& fixup) {
  data_root<callstack> stack(stack_, this);
  fixnum stack_length = untag_fixnum(stack->length);
  fixnum stack_offset = 0;

#if defined(FACTOR_LINKED_FRAMES) || defined(FACTOR_ARM64) || defined(FACTOR_RISCV64) || defined(FACTOR_RISCV32) || defined(FACTOR_S390X)
  while (stack_offset < stack_length) {
    cell frame_top = stack->frame_top_at(stack_offset);
    cell frame_size = *(cell*)frame_top;
#ifdef FACTOR_M88K
    if (frame_size < JIT_FRAME_SIZE ||
        frame_size > (cell)(stack_length - stack_offset))
      ::factor::abort();
#endif
    cell addr = *(cell*)(frame_top + FRAME_RETURN_ADDRESS);
#ifdef FACTOR_M88K
    // The final optimized callback frame returns into its pinned stub.
    // Keep its captured bytes, but it has no ordinary-code caller map.
    if (stack_offset + frame_size == stack_length &&
        callbacks->seg->in_segment_p(addr)) {
      stack_offset += frame_size;
      continue;
    }
#endif
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr)
                          : addr;
#ifdef FACTOR_M88K
    if (!code->seg->in_segment_p(fixed_addr))
      ::factor::abort();
#endif
    code_block* owner = code->code_block_for_address(fixed_addr);

    iterator(frame_top, frame_size, owner, fixed_addr);
    stack_offset += frame_size;
  }
#else
  while (stack_offset < stack_length) {
    cell frame_top = stack->frame_top_at(stack_offset);
    cell addr = *(cell*)frame_top;
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr)
                          : addr;
    code_block* owner = code->code_block_for_address(fixed_addr);

    cell frame_size = owner->stack_frame_size_for_address(fixed_addr);

    iterator(frame_top, frame_size, owner, fixed_addr);
    stack_offset += frame_size;
  }
#endif
  FACTOR_ASSERT(stack_offset == stack_length);
}

template <typename Iterator, typename Fixup>
void factor_vm::iterate_callstack(context* ctx, Iterator& iterator,
                                  Fixup& fixup) {

  cell top = ctx->callstack_top;
  cell bottom = ctx->callstack_bottom;
  // When we are translating the code block maps, all callstacks must
  // be empty.
  FACTOR_ASSERT(!Fixup::translated_code_block_map || top == bottom);

#if defined(FACTOR_LINKED_FRAMES) || defined(FACTOR_ARM64) || defined(FACTOR_RISCV64) || defined(FACTOR_RISCV32) || defined(FACTOR_S390X)
  while (top < bottom) {
#ifdef FACTOR_M88K
    cell predecessor = *(cell*)top;
    if (predecessor <= top || predecessor > bottom ||
        predecessor - top < JIT_FRAME_SIZE)
      ::factor::abort();
#endif
    cell addr = *(cell*)(top + FRAME_RETURN_ADDRESS);
    FACTOR_ASSERT(addr != 0);
#ifdef FACTOR_M88K
    // This boundary is specific to an optimized callback's outer frame:
    // its predecessor is exactly bottom and its return PC is a pinned stub.
    if (*(cell*)top == bottom && callbacks->seg->in_segment_p(addr)) {
      top = bottom;
      continue;
    }
    if (!code->seg->in_segment_p(addr))
      ::factor::abort();
#endif

    // Only the address is valid, if the code heap has been compacted,
    // owner might not point to a real code block.
    code_block* owner = code->code_block_for_address(addr);
    fixup.translate_code(owner);

    cell size = *(cell*)top - top;

    iterator(top, size, owner, addr);
    top = *(cell*)top;
  }
#else
  while (top < bottom) {
    cell addr = *(cell*)top;
    FACTOR_ASSERT(addr != 0);

    // Only the address is valid, if the code heap has been compacted,
    // owner might not point to a real code block.
    code_block* owner = code->code_block_for_address(addr);
    code_block* fixed_owner = fixup.translate_code(owner);

    cell delta = addr - (cell)owner - sizeof(code_block);
    cell natural_frame_size = fixed_owner->stack_frame_size();
    cell size = LEAF_FRAME_SIZE;
    if (natural_frame_size > 0 && delta > 0)
      size = natural_frame_size;

    iterator(top, size, owner, addr);
    top += size;
  }
#endif
  FACTOR_ASSERT(top == bottom);
}

