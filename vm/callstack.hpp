namespace factor {

inline static cell callstack_object_size(cell size) {
  return sizeof(callstack) + size;
}

// This is a little tricky. The iterator may allocate memory, so we
// keep the callstack in a GC root and use relative offsets
// Allocates memory
template <typename Iterator, typename Fixup>
inline void factor_vm::iterate_callstack_object(callstack* stack_,
                                                Iterator& iterator,
                                                Fixup& fixup) {
  data_root<callstack> stack(stack_, this);
  fixnum frame_length = untag_fixnum(stack->length);
  fixnum frame_offset = 0;

#ifdef FACTOR_ARM64
  while (frame_offset < frame_length) {
    cell frame_top = stack->frame_top_at(frame_offset);
    fixnum next_frame = *(cell*)frame_top;
    if (frame_offset + next_frame >= frame_length) {
      frame_offset += next_frame;
      break;
    }
    cell addr = *(cell*)(frame_top + FRAME_RETURN_ADDRESS);
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr)
                          : addr;
    code_block* owner = code->code_block_for_address(fixed_addr);

    cell frame_size = owner->stack_frame_size_for_address(fixed_addr);

    iterator(frame_top + next_frame + FRAME_RETURN_ADDRESS, frame_size - FRAME_RETURN_ADDRESS, owner, fixed_addr);
    frame_offset += next_frame;
  }
#else
  while (frame_offset < frame_length) {
    cell frame_top = stack->frame_top_at(frame_offset);
    cell addr = *(cell*)(frame_top + FRAME_RETURN_ADDRESS);
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr)
                          : addr;
    code_block* owner = code->code_block_for_address(fixed_addr);

    cell frame_size = owner->stack_frame_size_for_address(fixed_addr);

    iterator(frame_top + FRAME_RETURN_ADDRESS, frame_size - FRAME_RETURN_ADDRESS, owner, fixed_addr);
    frame_offset += frame_size;
  }
#endif
  FACTOR_ASSERT(frame_offset == frame_length);
}

// Allocates memory
template <typename Iterator>
inline void factor_vm::iterate_callstack_object(callstack* stack,
                                                Iterator& iterator) {
  no_fixup none;
  iterate_callstack_object(stack, iterator, none);
}

// Iterates the callstack from innermost to outermost
// callframe. Allocates memory
template <typename Iterator, typename Fixup>
void factor_vm::iterate_callstack(context* ctx, Iterator& iterator,
                                  Fixup& fixup) {

  cell top = ctx->callstack_top;
  cell bottom = ctx->callstack_bottom;
  // When we are translating the code block maps, all callstacks must
  // be empty.
  FACTOR_ASSERT(!Fixup::translated_code_block_map || top == bottom);

#ifdef FACTOR_ARM64
  while (top < bottom) {
    cell next_frame = *(cell*)top;
    if (*(cell*)next_frame == 0) {
      top = next_frame;
      break;
    }
    cell addr = *(cell*)(top + FRAME_RETURN_ADDRESS);
    FACTOR_ASSERT(addr != 0);

    code_block* owner = code->code_block_for_address(addr);
    code_block* fixed_owner = fixup.translate_code(owner);
    cell delta = addr - (cell)owner - sizeof(code_block);
    cell natural_frame_size = fixed_owner->stack_frame_size();
    cell size = LEAF_FRAME_SIZE;
    if (natural_frame_size > 0 && delta > 0)
      size = natural_frame_size;

    iterator(next_frame + FRAME_RETURN_ADDRESS, size - FRAME_RETURN_ADDRESS, owner, addr);
    top = next_frame;
  }
#else
  while (top < bottom) {
    cell addr = *(cell*)(top + FRAME_RETURN_ADDRESS);
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

    iterator(top + FRAME_RETURN_ADDRESS, size - FRAME_RETURN_ADDRESS, owner, addr);
    top += size;
  }
#endif
  FACTOR_ASSERT(top == bottom);
}

// Allocates memory
template <typename Iterator>
inline void factor_vm::iterate_callstack(context* ctx, Iterator& iterator) {
  no_fixup none;
  iterate_callstack(ctx, iterator, none);
}

}
