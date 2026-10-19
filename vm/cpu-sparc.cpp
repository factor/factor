#include "master.hpp"

extern "C" void sparc_signal_enter_window();

namespace factor {

void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc,
                                             cell handler, cell limit) {
  // Generated recursion can outgrow the last published native call frame.
  // The kernel SP identifies the current window when the fault is in JIT code.
  cell frame = code->seg->in_segment_p(*pc)
                   ? *sp + SPARC_STACK_BIAS
                   : ctx->callstack_top;
  if (frame < ctx->callstack_seg->start) frame = sparc_frame_predecessor(frame);
  while (frame < ctx->callstack_bottom && frame < limit)
    frame = sparc_frame_predecessor(frame);
  ctx->callstack_top = frame;
  *sp = frame - SPARC_STACK_BIAS;
  *pc = handler;
}

/* The generic two-pointer interface cannot preserve SPARC's NPC or full
 * register windows. Native ports dispatch through dispatch_sparc_signal. */
void factor_vm::dispatch_resumable_signal(cell*, cell*, cell) {
  critical_error("SPARC signal needs a native signal context", 0);
}
void factor_vm::dispatch_signal_handler(cell*, cell*, cell) {
  critical_error("SPARC signal needs a native signal context", 0);
}

#if !defined(__OpenBSD__)
void factor_vm::dispatch_sparc_signal(void* raw, cell handler) {
  cell sp = sparc_signal_stack_address(raw);
  cell pc = sparc_signal_pc(raw);
  cell limit = ctx->callstack_seg->start + stack_reserved;
  sparc_pending_signal* available = nullptr;
  for (auto& slot : sparc_signal_slots) {
    /* Unwinding an error can abandon the generated resume stub. */
    if (slot.active && slot.owner == ctx && sp >= slot.frame)
      slot.active = false;
    if (!slot.active && !available) available = &slot;
  }
  signal_resumable = code->seg->in_segment_p(pc) &&
                     sp >= limit + JIT_FRAME_SIZE + 16 && available;
  signal_handler_addr = handler;
  if (signal_resumable) {
    cell entry = untag<word>(special_objects[SIGNAL_HANDLER_WORD])->entry_point;
    available->owner = ctx;
    available->frame = factor_sparc_prepare_signal(raw, &available->saved, entry);
    available->active = true;
  } else {
    cell raw_sp = sparc_signal_sp(raw);
#if defined(__linux__)
    // Retire interrupted windows before reusing the published Factor frame.
    // Otherwise a later native SAVE can spill the abandoned primitive's
    // inputs over the restored frame during error recovery.
#ifdef FACTOR_64
    __asm__ volatile("flushw" ::: "memory");
#else
    __asm__ volatile("ta 3" ::: "memory");
#endif
    // The flush materializes older windows, but the interrupted live
    // window is in the signal frame. Publish it before walking its i6.
    if (code->seg->in_segment_p(pc) &&
        sp >= ctx->callstack_seg->start &&
        sp + 16 * sizeof(cell) <= ctx->callstack_seg->end) {
      const size_t prefix = sizeof(cell) == 8 ? 192 : 224;
      factor_sparc_signal_copy((void*)sp,
                              (unsigned char*)raw - prefix,
                              16 * sizeof(cell));
    }
#endif
    dispatch_non_resumable_signal(&raw_sp, &pc, handler, limit);
#if defined(__NetBSD__)
    auto* regs = static_cast<ucontext_t*>(raw)->uc_mcontext.__gregs;
    regs[_REG_G1] = handler;
    regs[_REG_G2] = ctx->datastack;
    regs[_REG_G3] = ctx->retainstack;
    regs[_REG_G4] = (cell)this;
    regs[_REG_G5] = (cell)ctx;
    regs[_REG_O6] = raw_sp;
#else
#ifdef FACTOR_64
    cell* regs = (cell*)((unsigned char*)raw + 128);
#else
    cell* regs = (cell*)((unsigned char*)raw + 16);
#endif
    regs[1] = handler;
    regs[2] = ctx->datastack;
    regs[3] = ctx->retainstack;
    regs[4] = (cell)this;
    regs[5] = (cell)ctx;
    regs[14] = raw_sp;
#endif
    sparc_redirect_signal(raw, (cell)sparc_signal_enter_window);
  }
  data_roots.clear();
  code_roots.clear();
}

#endif

/* Called through the native trampoline by the generated resume stub.
 * Block delivery while retiring storage; rt_sigreturn reinstates the exact
 * interrupted mask. This closes the reuse race before the final trap. */
VM_C_API cell sparc_signal_resume_frame(cell frame) {
  factor_vm* vm = current_vm_p();
  sigset_t all;
  sigfillset(&all);
  if (sigprocmask(SIG_BLOCK, &all, nullptr))
    fatal_error("SPARC signal resume mask failed", errno);
  for (auto& slot : vm->sparc_signal_slots)
    if (slot.active && (cell)slot.saved.bytes == frame) {
      slot.active = false;
      return frame;
    }
  critical_error("SPARC signal continuation has no owner", frame);
  return 0;
}
}

#if defined(__NetBSD__)
extern "C" void sparc_rt_sigreturn(uintptr_t frame) {
  factor_sparc_restore_signal_window(frame);
#ifndef FACTOR_64
  factor_sparc_restore_signal_fpu(reinterpret_cast<ucontext_t*>(frame));
#endif
  setcontext(reinterpret_cast<ucontext_t*>(frame));
  factor::fatal_error("SPARC setcontext failed", errno);
  abort();
}
#endif
