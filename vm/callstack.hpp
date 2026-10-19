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
  fixnum stack_length = untag_fixnum(stack->length);
  fixnum stack_offset = 0;

#if defined(FACTOR_SPARC)
  while (stack_offset < stack_length) {
    cell frame_top = stack->frame_top_at(stack_offset);
    cell frame_size = *(cell*)(frame_top + SPARC_FRAME_LINK);
    FACTOR_ASSERT(frame_size > 0 && frame_size <= cell(stack_length - stack_offset));
    cell addr = sparc_frame_return_address(frame_top);
    // Image PCs name the producer's heap until startup relocation.
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr) : addr;
    if (!code->seg->in_segment_p(fixed_addr)) {
      if (!callbacks->seg->in_segment_p(addr))
        critical_error("SPARC saved return outside code heaps", addr);
      stack_offset += frame_size;
      continue;
    }
    code_block* owner = code->code_block_for_address(fixed_addr);
    iterator(frame_top, frame_size, owner, fixed_addr);
    stack_offset += frame_size;
  }
#elif defined(FACTOR_HPPA)
  while (stack_offset < stack_length) {
    cell frame_top = stack->frame_top_at(stack_offset);
    cell frame_size = *(cell*)frame_top;
    FACTOR_ASSERT(frame_size > 0 && frame_size <= cell(stack_length - stack_offset));
    cell addr = *(cell*)(frame_top + FRAME_RETURN_ADDRESS);
    // Saved image PCs still name the old heap until startup translation.
    cell fixed_addr = Fixup::translated_code_block_map
                          ? (cell)fixup.translate_code((code_block*)addr) : addr;
    if (!code->seg->in_segment_p(fixed_addr)) {
      if (!callbacks->seg->in_segment_p(addr))
        critical_error("HPPA saved return outside code heaps", addr);
      stack_offset += frame_size;
      continue;
    }
    code_block* owner = code->code_block_for_address(fixed_addr);
    iterator(frame_top, frame_size, owner, fixed_addr);
    stack_offset += frame_size;
  }
#elif defined(FACTOR_LINKED_FRAMES)
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

#ifdef FACTOR_PPC
    cell advance = frame_size;
    if (ppc_signal_frame_p(frame_top, frame_size) &&
        (ppc_signal_frame_state(frame_top) == ppc_active ||
         ppc_signal_frame_state(frame_top) == ppc_temporary))
    {
      cell temporary = ppc_signal_frame_state(frame_top) == ppc_temporary ? 32 : 0;
      cell remaining = stack_length - stack_offset;
      if (remaining <= frame_size + temporary)
        critical_error("Missing interrupted PowerPC frame", remaining);
      cell interrupted_size = *(cell*)(frame_top + frame_size + temporary);
      if (!interrupted_size || interrupted_size > remaining - frame_size - temporary)
        critical_error("Invalid interrupted PowerPC frame size", interrupted_size);
      advance += temporary + interrupted_size;
    }
#endif
#ifdef FACTOR_PPC
    if (ppc_signal_frame_p(frame_top, frame_size) &&
        ppc_signal_frame_state(frame_top) == ppc_temporary_leaf) {
      if (stack_length - stack_offset < frame_size + 32)
        critical_error("Missing PowerPC leaf temporary frame", stack_length - stack_offset);
      advance += 32;
    }
#endif
    iterator(frame_top, frame_size, owner, fixed_addr);
#ifdef FACTOR_PPC
    stack_offset += advance;
#else
    stack_offset += frame_size;
#endif
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

#if defined(FACTOR_SPARC)
  while (top < bottom) {
    cell addr = sparc_frame_return_address(top);
    FACTOR_ASSERT(addr != 0);
    cell next = sparc_frame_predecessor(top);
    FACTOR_ASSERT(next > top && next <= bottom);
    if (code->seg->in_segment_p(addr)) {
      code_block* owner = code->code_block_for_address(addr);
      fixup.translate_code(owner);
      iterator(top, next - top, owner, addr);
    } else if (!callbacks->seg->in_segment_p(addr)) {
      critical_error("SPARC return outside code heaps", addr);
    }
    top = next;
  }
#elif defined(FACTOR_HPPA)
  while (top < bottom) {
    cell addr = *(cell*)(top + FRAME_RETURN_ADDRESS);
    cell next = *(cell*)top;
    FACTOR_ASSERT(next > top && next <= bottom);
    if (code->seg->in_segment_p(addr)) {
      code_block* owner = code->code_block_for_address(addr);
      fixup.translate_code(owner);
      iterator(top, next - top, owner, addr);
    } else if (!callbacks->seg->in_segment_p(addr)) {
      critical_error("HPPA return outside code heaps", addr);
    }
    top = next;
  }
#elif defined(FACTOR_LINKED_FRAMES)
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
#ifdef FACTOR_PPC
    cell next = *(cell*)top;
    if (next <= top || next > bottom || (next & 15))
      critical_error("Invalid PowerPC live frame bounds", next);
    if (ppc_signal_frame_p(top, size) &&
        (ppc_signal_frame_state(top) == ppc_active ||
         ppc_signal_frame_state(top) == ppc_temporary)) {
      if (next >= bottom)
        critical_error("Missing interrupted PowerPC frame", next);
      if (ppc_signal_frame_state(top) == ppc_temporary) {
        cell temporary = next;
        next = *(cell*)next;
        if (next <= temporary || next >= bottom || (next & 15))
          critical_error("Invalid PowerPC temporary frame bounds", next);
      }
      cell interrupted = next;
      next = *(cell*)next;
      if (next <= interrupted || next > bottom || (next & 15))
        critical_error("Invalid interrupted PowerPC frame bounds", next);
    }
#endif
#ifdef FACTOR_PPC
    if (ppc_signal_frame_p(top, size) &&
        ppc_signal_frame_state(top) == ppc_temporary_leaf) {
      if (next >= bottom)
        critical_error("Missing PowerPC temporary leaf frame", next);
      cell temporary = next;
      next = *(cell*)next;
      if (next <= temporary || next > bottom || (next & 15))
        critical_error("Invalid PowerPC temporary leaf frame bounds", next);
    }
#endif
    iterator(top, size, owner, addr);
#ifdef FACTOR_PPC
    top = next;
#else
    top = *(cell*)top;
#endif
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

// Allocates memory
template <typename Iterator>
inline void factor_vm::iterate_callstack(context* ctx, Iterator& iterator) {
  no_fixup none;
  iterate_callstack(ctx, iterator, none);
}

}
