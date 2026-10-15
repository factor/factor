#include "master.hpp"

#ifdef __arch64__
// Fixed registers used only by inline assembly need explicit GAS declarations.
__asm__(".register %g2, #scratch\n\t.register %g3, #scratch");
#endif

extern "C" void sparc_restore_window(uintptr_t, uintptr_t);
extern "C" void sparc_signal_enter_window();
extern "C" void sparc_openbsd_enter_interrupted_stack(
    uintptr_t, void (*)(void*), void*, uintptr_t) __attribute__((noreturn));

namespace factor {
static void copy_signal_bytes(void* destination, const void* source, cell size) {
  auto* dst = static_cast<volatile unsigned char*>(destination);
  auto* src = static_cast<const volatile unsigned char*>(source);
  while (size--) *dst++ = *src++;
}

static void enter_signal_handler(void* raw) {
  auto* slot = static_cast<factor_vm::sparc_pending_signal*>(raw);
  auto& saved = slot->saved;
  factor_vm* vm = current_vm_p();
  context* owner = slot->owner;
  owner->callstack_top = slot->frame;
  if (sigaltstack(&saved.successor_stack, &saved.original_stack) ||
      sigprocmask(SIG_SETMASK, &saved.resume_mask, nullptr))
    fatal_error("OpenBSD signal stack transition failed", errno);
  cell ds = owner->datastack, rs = owner->retainstack;
  __asm__ volatile("mov %0, %%g2\n\tmov %1, %%g3\n\t"
                   "mov %2, %%g4\n\tmov %3, %%g5"
                   : : "r"(ds), "r"(rs), "r"(vm), "r"(owner) : "memory");
  sparc_restore_window(slot->frame,
      untag<word>(vm->special_objects[SIGNAL_HANDLER_WORD])->entry_point);
  fatal_error("OpenBSD signal handler returned", 0);
}

void factor_vm::dispatch_sparc_signal(void* raw, cell handler) {
  cell sp = sparc_signal_stack_address(raw), pc = sparc_signal_pc(raw);
  cell limit = ctx->callstack_seg->start + stack_reserved;
  sparc_pending_signal* available = nullptr;
  for (auto& slot : sparc_signal_slots)
    if (!slot.active) { available = &slot; break; }
  stack_t current, successor = {};
  if (sigaltstack(nullptr, &current))
    fatal_error("OpenBSD signal stack query failed", errno);
  if (available) {
    for (auto& slot : sparc_signal_slots) {
      void* region = (void*)slot.region->start;
      bool retained = region == current.ss_sp;
      for (auto& pending : sparc_signal_slots)
        if (pending.active && pending.saved.original_stack.ss_sp == region)
          retained = true;
      if (!retained) {
        successor.ss_sp = region;
        successor.ss_size = slot.region->size;
        break;
      }
    }
  }
  signal_resumable = code->seg->in_segment_p(pc) &&
                     sp >= limit + JIT_FRAME_SIZE + 16 &&
                     available && successor.ss_sp &&
                     (current.ss_flags & SS_ONSTACK) &&
                     current.ss_size <= signal_callstack_seg->size;
  signal_handler_addr = handler;
  data_roots.clear();
  code_roots.clear();
  if (signal_resumable) {
    sigset_t all;
    sigfillset(&all);
    if (sigprocmask(SIG_BLOCK, &all, nullptr))
      fatal_error("OpenBSD signal transition mask failed", errno);
    auto& saved = available->saved;
    available->owner = ctx;
    available->frame = sp - JIT_FRAME_SIZE - 16;
    saved.successor_stack = successor;
    saved.resume_mask = (sigset_t)((struct sigcontext*)raw)->sc_mask;
    factor_sparc_openbsd_capture_signal_roots(&saved.roots, raw);
    auto* window = (cell*)available->frame;
    for (unsigned i = 0; i < 16; ++i)
      window[i] = saved.roots.interrupted_window[i];
    window[14] = sp - SPARC_STACK_BIAS;
    window[15] = pc - 8;
    *(cell*)(available->frame + JIT_FRAME_SIZE) = (cell)saved.bytes;
    available->active = true;
    if (!sigsetjmp(saved.native, 0)) {
      sparc_openbsd_enter_interrupted_stack(available->frame,
          enter_signal_handler, available, pc - 8);
    }
  } else {
    cell raw_sp = sparc_signal_sp(raw);
    dispatch_non_resumable_signal(&raw_sp, &pc, handler, limit);
    auto* sc = (struct sigcontext*)raw;
    sc->sc_sp = raw_sp;
    sc->sc_g1 = handler;
    cell* window = factor_sparc_openbsd_signal_window(raw);
    window[2] = ctx->datastack;
    window[3] = ctx->retainstack;
    window[4] = (cell)this;
    window[5] = (cell)ctx;
    sparc_redirect_signal(raw, (cell)sparc_signal_enter_window);
  }
}

void factor_vm::abandon_sparc_signals(context* owner, cell target) {
  sigset_t all, restore;
  sigfillset(&all);
  if (sigprocmask(SIG_BLOCK, &all, &restore))
    fatal_error("OpenBSD signal unwind mask failed", errno);
  cell oldest = 0;
  for (auto& slot : sparc_signal_slots)
    if (slot.active && slot.owner == owner && (!target || target >= slot.frame)) {
      if (slot.frame >= oldest) {
        oldest = slot.frame;
        restore = slot.saved.resume_mask;
      }
      slot.active = false;
    }
  /* The current alternate region is the unused successor, so discarding
   * retained frames needs no remap and cannot erase another context's frame. */
  if (sigprocmask(SIG_SETMASK, &restore, nullptr))
    fatal_error("OpenBSD signal unwind mask restore failed", errno);
}
}

extern "C" void sparc_rt_sigreturn(uintptr_t token) {
  auto* saved = reinterpret_cast<factor_sparc_signal_storage*>(token);
  factor_sparc_openbsd_restore_signal_roots(&saved->roots);
  factor::copy_signal_bytes(saved->snapshot, saved->original_stack.ss_sp,
                            saved->original_stack.ss_size);
  if (sigaltstack(&saved->original_stack, nullptr))
    factor::fatal_error("OpenBSD retained signal stack restore failed", errno);
  factor::copy_signal_bytes(saved->original_stack.ss_sp, saved->snapshot,
                            saved->original_stack.ss_size);
  siglongjmp(saved->native, 1);
}
