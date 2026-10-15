#include "master.hpp"

namespace factor {

void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc,
                                               cell handler, cell limit) {
  // Generated recursion need not save ctx->callstack_top between calls.
  // Recover its live linked frame from the kernel context, not a stale save.
  cell top = code->seg->in_segment_p(*pc) ? *sp : ctx->callstack_top;
  cell start = ctx->callstack_seg->start;
  if (top < start)
    top = *(cell*)top;
  FACTOR_ASSERT(top >= start);
  while (top < ctx->callstack_bottom && top < limit)
    top = *(cell*)top;
  ctx->callstack_top = top;
  // A native callee saves LR and parameter homes in its caller linkage area.
  // Keep those writes below the preserved Factor frame used by error recovery.
  *sp = top - JIT_FRAME_SIZE;
  *(cell*)*sp = top;
  *pc = handler;
}

void factor_vm::dispatch_resumable_signal(cell* sp, cell* pc, cell handler) {
  signal_handler_addr = handler;
  // Construct a linked frame containing the interrupted instruction. The
  // signal subprimitive preserves LR separately from this continuation PC.
  cell previous = *sp;
  *sp -= sizeof(cell) == 8 ? 32 : 16;
  *(cell*)*sp = previous;
  *(cell*)(*sp + FRAME_RETURN_ADDRESS) = *pc;
  *(cell*)(*sp + PPC_SIGNAL_FRAME_METADATA) = PPC_SIGNAL_FRAME_MARKER | ppc_active;
  *pc = untag<word>(special_objects[SIGNAL_HANDLER_WORD])->entry_point;
}

void factor_vm::dispatch_signal_handler(cell* sp, cell* pc, cell handler) {
  cell limit = ctx->callstack_seg->start + stack_reserved;
  signal_resumable = code->seg->in_segment_p(*pc) && *sp >= limit;
  if (signal_resumable)
    dispatch_resumable_signal(sp, pc, handler);
  else
    dispatch_non_resumable_signal(sp, pc, handler, limit);
  data_roots.clear();
  code_roots.clear();
}

// Resolve frame disposition before changing the kernel context. Walkers then
// use explicit continuation metadata, including after capture or compaction.
void factor_vm::dispatch_ppc_signal(cell* sp, cell* pc, cell lr, cell handler) {
  cell previous = *sp;
  cell limit = ctx->callstack_seg->start + stack_reserved;
  ppc_interrupted_frame_state state = ppc_unknown;
  if (code->seg->in_segment_p(*pc) && previous >= limit) {
    if (previous > ctx->callstack_bottom || (previous & 15))
      critical_error("Invalid PowerPC interrupted stack pointer", previous);
    code_block* owner = code->code_block_for_address(*pc);
    // PPC PIC templates never allocate a frame: hits and misses transfer
    // to another word. Their historical header still records JIT_FRAME_SIZE.
    cell frame_size = owner->pic_p() ? 0 : owner->stack_frame_size();
    cell prologue_entry = owner->entry_point();
    cell body_end = (cell)owner->block_gc_info()->gc_info_bitmap();
    // Binary floating/vector literals precede the GC footer. Their rel-here
    // load operands give the first data address without scanning literal bytes.
    auto bound_literal = [&](instruction_operand op) {
      if (op.rel.type() != RT_HERE || op.pointer + 4 > body_end)
        return;
      uint32_t next = ppc_instruction(op.pointer);
      if ((next >> 26) == 48 || (next >> 26) == 50 ||
          (next & 0xfc0007fe) == 0x7c0000ce) {
        cell literal = (cell)op.load_value(op.pointer);
        if (literal >= owner->entry_point() && literal < body_end)
          body_end = literal;
      }
    };
    owner->each_instruction_operand(bound_literal);
    auto locate_prologue = [&](instruction_operand op) {
      cell load_size = sizeof(cell) == 8 ? 20 : 8;
      if (op.rel.type() != RT_THIS || !frame_size ||
          op.pointer < owner->entry_point()+load_size+8 || op.pointer > body_end ||
          (cell)op.load_value(op.pointer) != owner->entry_point()) return;
      cell candidate = op.pointer-load_size-8;
      if (ppc_frame_state_from_prologue(owner->entry_point(), body_end, candidate,
                                       frame_size, candidate) == ppc_pre)
        prologue_entry = candidate;
    };
    owner->each_instruction_operand(locate_prologue);
    state = ppc_frame_state_from_prologue(owner->entry_point(), body_end,
                           *pc, frame_size, prologue_entry);
    // Temporary stack reservations inside subprimitives are not ordinary
    // optimized frames and cannot use the ordinary spill map at this R1.
    if (state == ppc_active &&
        *(cell*)previous - previous != frame_size)
      state = ppc_unknown;
    if (state == ppc_temporary &&
        (ctx->callstack_bottom - previous <= 32 ||
         *(cell*)previous - previous != 32 ||
         *(cell*)(previous + 32) - previous - 32 != frame_size))
      state = ppc_unknown;
    if (state == ppc_temporary_leaf &&
        (ctx->callstack_bottom - previous < 32 ||
         *(cell*)previous - previous != 32))
      state = ppc_unknown;
    if (state == ppc_unknown)
      critical_error("Unsupported PowerPC interrupted frame layout", *pc);
  }
  signal_resumable = state != ppc_unknown;
  if (signal_resumable) {
    dispatch_resumable_signal(sp, pc, handler);
    *(cell*)(*sp + PPC_SIGNAL_FRAME_METADATA) = PPC_SIGNAL_FRAME_MARKER | state;
    if (state == ppc_leaf || state == ppc_pre || state == ppc_temporary_leaf)
      *(cell*)(previous + (state == ppc_temporary_leaf ? 32 : 0) + FRAME_RETURN_ADDRESS) = lr;
  } else {
    dispatch_non_resumable_signal(sp, pc, handler, limit);
  }
  data_roots.clear();
  code_roots.clear();
}

}
