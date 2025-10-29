#include "master.hpp"

#if defined(FACTOR_WITH_ADDRESS_SANITIZER)
#include <sanitizer/asan_interface.h>
#endif

#include <cstring>

namespace factor {

// Allocates memory (allot)
callstack* factor_vm::allot_callstack(cell size) {
  callstack* stack = allot<callstack>(callstack_object_size(size));
  stack->length = tag_fixnum(size);
  return stack;
}

// We ignore the two topmost frames, the 'callstack' primitive
// frame itself, and the frame calling the 'callstack' primitive,
// so that set-callstack doesn't get stuck in an infinite loop.

// This means that if 'callstack' is called in tail position, we
// will have popped a necessary frame... however this word is only
// called by continuation implementation, and user code shouldn't
// be calling it at all, so we leave it as it is for now.
cell factor_vm::second_from_top_stack_frame(context* target_ctx) {
  cell frame_top = target_ctx->callstack_top;
  for (cell i = 0; i < 2; ++i) {
    cell pred = code->frame_predecessor(frame_top);
    if (pred >= target_ctx->callstack_bottom)
      return frame_top;
    frame_top = pred;
  }
  return frame_top;
}

// Allocates memory (allot_callstack)
cell factor_vm::capture_callstack(context* target_ctx) {
  cell top = second_from_top_stack_frame(target_ctx);
  cell bottom = target_ctx->callstack_bottom;

  fixnum size = std::max((cell)0, bottom - top);

  callstack* stack = allot_callstack(size);
#if defined(FACTOR_WITH_ADDRESS_SANITIZER)
  if (size > 0)
    __asan_unpoison_memory_region(reinterpret_cast<void*>(top), static_cast<size_t>(size));
#endif
  std::copy_n(reinterpret_cast<const std::byte*>(top), static_cast<size_t>(size),
              reinterpret_cast<std::byte*>(stack->top()));
#ifdef FACTOR_ARM64
  // Convert absolute frame pointers to relative offsets. This allows
  // moving the callstack through memory. They will be converted back
  // in set-callstack.
  cell dst = stack->top();
  while (top < bottom) {
    *reinterpret_cast<cell*>(dst) = *reinterpret_cast<cell*>(top) - top;
    FACTOR_ASSERT(*reinterpret_cast<cell*>(top) > top);
    top = *reinterpret_cast<cell*>(top);
    dst += *reinterpret_cast<cell*>(dst);
  }
#endif
  return tag<callstack>(stack);
}

// Allocates memory (capture_callstack)
void factor_vm::primitive_callstack_for() {
  context* other_ctx = static_cast<context*>(
      static_cast<void*>(pinned_alien_offset(ctx->peek())));
  ctx->replace(capture_callstack(other_ctx));
}

// Allocates memory (frames.trim()), iterate_callstack_object()
void factor_vm::primitive_callstack_to_array() {
  data_root<callstack> callstack(ctx->peek(), this);
  // Allocates memory here.
  growable_array frames(this);

  auto stack_frame_accumulator = [&](cell frame_top,
                                     cell size,
                                     code_block* owner,
                                     cell addr) {
    (void)frame_top;
    (void)size;
    data_root<object> executing_quot(owner->owner_quot(), this);
    data_root<object> executing(owner->owner, this);
    data_root<object> scan(owner->scan(this, addr), this);

    frames.add(executing.value());
    frames.add(executing_quot.value());
    frames.add(scan.value());
  };
  iterate_callstack_object(callstack.untagged(), stack_frame_accumulator);

  frames.trim();

  ctx->replace(frames.elements.value());
}

// Some primitives implementing a limited form of callstack mutation.
// Used by the single stepper.
void factor_vm::primitive_innermost_stack_frame_executing() {
  callstack* stack = untag_check<callstack>(ctx->peek());
  cell frame = stack->top();
  cell addr = *reinterpret_cast<cell*>(frame + FRAME_RETURN_ADDRESS);
  ctx->replace(code->code_block_for_address(addr)->owner_quot());
}

void factor_vm::primitive_innermost_stack_frame_scan() {
  callstack* stack = untag_check<callstack>(ctx->peek());
  cell frame = stack->top();
  cell addr = *reinterpret_cast<cell*>(frame + FRAME_RETURN_ADDRESS);
  ctx->replace(code->code_block_for_address(addr)->scan(this, addr));
}

// Allocates memory (jit_compile_quotation)
void factor_vm::primitive_set_innermost_stack_frame_quotation() {
  data_root<callstack> stack(ctx->pop(), this);
  data_root<quotation> quot(ctx->pop(), this);

  check_tagged(stack);
  check_tagged(quot);

  jit_compile_quotation(quot.value(), true);

  cell inner = stack->top() + FRAME_RETURN_ADDRESS;
  cell addr = *reinterpret_cast<cell*>(inner);
  code_block* block = code->code_block_for_address(addr);
  cell offset = block->offset(addr);
  *reinterpret_cast<cell*>(inner) = quot->entry_point + offset;
}

// Allocates memory (allot_alien)
void factor_vm::primitive_callstack_bounds() {
  ctx->push(allot_alien(ctx->callstack_seg->start));
  ctx->push(allot_alien(ctx->callstack_seg->end));
}

}
