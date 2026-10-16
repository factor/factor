#include "master.hpp"
#include "ieee_float.hpp"

namespace factor {
static uint32_t openrisc_fpcsr() {
  uint32_t value;
  asm volatile("l.mfspr %0,r0,20" : "=r"(value));
  return value;
}

static void set_openrisc_fpcsr(uint32_t value) {
  asm volatile("l.mtspr r0,%0,20" : : "r"(value));
}

static fp::rounding_mode openrisc_rounding_mode(uint32_t fpcsr) {
  switch ((fpcsr >> 1) & 3) {
    case 1: return fp::rounding_mode::toward_zero;
    case 2: return fp::rounding_mode::upward;
    case 3: return fp::rounding_mode::downward;
    default: return fp::rounding_mode::nearest_even;
  }
}

static uint32_t openrisc_exception_bits(fp::exception_flags flags) {
  uint32_t bits = 0;
  if (flags & fp::inexact) bits |= 0x100;
  if (flags & fp::underflow) bits |= 0x010;
  if (flags & fp::overflow) bits |= 0x008;
  if (flags & fp::divide_by_zero) bits |= 0x800;
  if (flags & fp::invalid) bits |= 0x200;
  return bits;
}

// The integer converter shares the hardware rounding mode and sticky flags.
template <typename To, typename From>
static typename To::storage_type convert_precision(From value) {
  const uint32_t fpcsr = openrisc_fpcsr();
  auto result = fp::convert<To>(value, openrisc_rounding_mode(fpcsr));
  set_openrisc_fpcsr(fpcsr | openrisc_exception_bits(result.raised));
  return result.value.bits;
}

VM_C_API uint64_t openrisc_single_to_double(uint32_t bits) {
  return convert_precision<fp::binary64>(fp::binary32::from_bits(bits));
}

VM_C_API uint32_t openrisc_double_to_single(uint32_t high, uint32_t low) {
  const uint64_t bits = (uint64_t(high) << 32) | low;
  return convert_precision<fp::binary32>(fp::binary64::from_bits(bits));
}

void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc, cell handler, cell limit) {
  cell frame_top = ctx->callstack_top;
  cell seg_start = ctx->callstack_seg->start;
  if (frame_top < seg_start)
    frame_top = *(cell*)frame_top;
  FACTOR_ASSERT(seg_start <= frame_top);
  while (frame_top < ctx->callstack_bottom && frame_top < limit)
    frame_top = *(cell*)frame_top;
  ctx->callstack_top = frame_top;
  *sp = frame_top;
  *pc = handler;
}

void factor_vm::dispatch_resumable_signal(cell* sp, cell* pc, cell handler) {
  signal_handler_addr = handler;
  cell index = SIGNAL_HANDLER_WORD;
  cell delta = 16;
  code_block* block = code->code_block_for_address(*pc);
  tagged<word> leaf_handler(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
  if ((block->stack_frame_size() == 0 || *pc == block->entry_point()) &&
      leaf_handler.type_p() && to_boolean(leaf_handler->subprimitive)) {
    index = LEAF_SIGNAL_HANDLER_WORD;
    delta += LEAF_FRAME_SIZE;
  }
  *sp -= delta;
  *(cell*)(*sp + FRAME_RETURN_ADDRESS) = *pc;
  *pc = untag<word>(special_objects[index])->entry_point;
}

void factor_vm::dispatch_signal_handler(cell* sp, cell* pc, cell handler) {
  bool in_code_seg = code->seg->in_segment_p(*pc);
  cell cs_limit = ctx->callstack_seg->start + stack_reserved;
  signal_resumable = in_code_seg && *sp >= cs_limit;
  if (signal_resumable)
    dispatch_resumable_signal(sp, pc, handler);
  else
    dispatch_non_resumable_signal(sp, pc, handler, cs_limit);
  data_roots.clear();
  code_roots.clear();
}
}
