/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <setjmp.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "../../vm/sparc-openbsd-context.h"
#include "../../vm/sparc-openbsd-signal-roots.h"

static unsigned char altstack[65536] __attribute__((aligned(8192)));
static unsigned char nested_altstack[2][sizeof(altstack)] __attribute__((aligned(8192)));
static unsigned char alternate_snapshot[2][sizeof(altstack)];
static unsigned active_depth;
static void copy_bytes(void* destination, const void* source, size_t size) {
  volatile unsigned char* dst = destination;
  const volatile unsigned char* src = source;
  while (size--) *dst++ = *src++;
}
static volatile sig_atomic_t handled;
static volatile sig_atomic_t stage;
static void fault_handler(int sig, siginfo_t* info, void* raw) {
  struct sigcontext* sc = raw;
  char message[80] = "stage ";
  unsigned used = 6, i, field;
  uintptr_t values[] = {sc->sc_pc, sc->sc_sp, (uintptr_t)info->si_addr};
  message[used++] = '0' + stage;
  for (field = 0; field < 3; ++field) {
    message[used++] = ' ';
    for (i = 0; i < 16; ++i)
      message[used++] = "0123456789abcdef"[(values[field] >> (60 - 4 * i)) & 15];
  }
  message[used++] = '\n';
  write(2, message, used);
  _exit(97);
}

struct continuation {
  unsigned depth;
  sigjmp_buf native;
  struct sigcontext* original;
  uintptr_t cookie;
  sigset_t delivery_mask;
  stack_t alternate_stack;
};
static struct continuation continuations[2];
extern void enter_interrupted_stack(uintptr_t, void (*)(void*), void*, uintptr_t);
__asm__(".text\n.align 4\n.global enter_interrupted_stack\n"
        ".type enter_interrupted_stack,#function\n"
        "enter_interrupted_stack:\n save %sp, -176, %sp\n flushw\n"
        " sub %i0, 2047, %sp\n add %sp, 192, %i6\n mov %i3, %i7\n"
        " mov %i2, %o0\n jmpl %i1, %o7\n nop\n unimp 0\n"
        ".size enter_interrupted_stack,.-enter_interrupted_stack\n");
static volatile sig_atomic_t nested;
static void generated_handler(void* raw) {
  stage = 3;
  struct continuation* state = raw;
  uintptr_t local = (uintptr_t)&state;
  if (local >= (uintptr_t)altstack &&
      local < (uintptr_t)(altstack + sizeof(altstack))) _exit(93);
  if ((uintptr_t)state->original->sc_cookie != state->cookie) _exit(94);
  /* Keep every authenticated frame on a distinct retained region. */
  stack_t successor;
  memset(&successor, 0, sizeof(successor));
  successor.ss_sp = nested_altstack[state->depth];
  successor.ss_size = sizeof(altstack);
  if (sigaltstack(&successor, &state->alternate_stack) ||
      sigprocmask(SIG_SETMASK, &state->delivery_mask, NULL)) _exit(99);
  sigset_t current;
  if (sigprocmask(SIG_SETMASK, NULL, &current) ||
      sigismember(&current, SIGILL) || sigismember(&current, SIGUSR1)) _exit(84);
  double changed = state->depth ? 6.5 : 8.5;
  __asm__ volatile("ldd %0, %%f0\n\tldd %0, %%f62"
                   : : "m"(changed) : "f0", "f1", "f62", "f63");
  if (!state->depth) {
    if (raise(SIGUSR1)) _exit(95);
    uint64_t low, high;
    __asm__ volatile("std %%f0, %0\n\tstd %%f62, %1"
                     : "=m"(low), "=m"(high));
    if (low != UINT64_C(0x4021000000000000) || low != high) _exit(85);
  }
  stage = 4;
  sigset_t all;
  sigfillset(&all);
  if (sigprocmask(SIG_BLOCK, &all, NULL)) _exit(99);
  /* Enabling an OpenBSD altstack remaps it to zeroed MAP_STACK pages.
   * Restore the retained frame at its original authenticated address. */
  unsigned char* snapshot = alternate_snapshot[state->depth];
  copy_bytes(snapshot, state->alternate_stack.ss_sp, sizeof(altstack));
  if (sigaltstack(&state->alternate_stack, NULL)) _exit(99);
  copy_bytes(state->alternate_stack.ss_sp, snapshot, sizeof(altstack));
  siglongjmp(state->native, 1);
}
struct relocation { uintptr_t delta; unsigned count; };
static void relocate_code(void* opaque, uintptr_t* slot, unsigned bias) {
  struct relocation* state = opaque;
  if (bias != 0 && bias != 8) _exit(86);
  *slot += state->delta;
  ++state->count;
}
static void verify_code_roots(void* raw) {
  struct factor_sparc_openbsd_signal_roots roots;
  factor_sparc_openbsd_capture_signal_roots(&roots, raw);
  uintptr_t cookie = factor_sparc_openbsd_window_cookie();
  uintptr_t* window = factor_sparc_openbsd_signal_window(raw);
  uintptr_t pc = roots.original->sc_pc, npc = roots.original->sc_npc;
  uintptr_t o7 = window[15], i7 = roots.interrupted_window[15];
  struct relocation move = {64, 0};
  factor_sparc_openbsd_visit_signal_code(&roots, cookie, relocate_code, &move);
  if (move.count != 4 || roots.original->sc_pc != pc + 64 ||
      roots.original->sc_npc != npc + 64 ||
      factor_sparc_decode_i7(window[15], cookie) !=
          factor_sparc_decode_i7(o7, cookie) + 64 ||
      factor_sparc_decode_i7(roots.interrupted_window[15], cookie) !=
          factor_sparc_decode_i7(i7, cookie) + 64) _exit(87);
  move.delta = (uintptr_t)-64; move.count = 0;
  factor_sparc_openbsd_visit_signal_code(&roots, cookie, relocate_code, &move);
  if (move.count != 4 || roots.original->sc_pc != pc ||
      roots.original->sc_npc != npc || window[15] != o7 ||
      roots.interrupted_window[15] != i7) _exit(88);
  factor_sparc_openbsd_restore_signal_roots(&roots);
}
static void roundtrip_handler(int sig, siginfo_t* info, void* raw) {
  struct sigcontext* sc = raw;
  uintptr_t local = (uintptr_t)&sc;
  if (!info || active_depth >= 2 || (sig != SIGILL && sig != SIGUSR1)) _exit(91);
  struct continuation* state = &continuations[active_depth];
  state->depth = active_depth++;
  unsigned char* region = state->depth ? nested_altstack[0] : altstack;
  if (local < (uintptr_t)region || local >= (uintptr_t)(region + sizeof(altstack))) _exit(91);
  if (!state->depth && (factor_sparc_openbsd_fpu_status(sc) & 0x3ff) != 0x3ff) _exit(90);
  factor_sparc_openbsd_clear_fpu_status(sc);
  factor_sparc_openbsd_signal_window(sc)[5] = 0x123456;
  verify_code_roots(sc);
  state->original = sc;
  state->cookie = sc->sc_cookie;
  stage = 1;
  if (!sigsetjmp(state->native, 0)) {
    stage = 2;
    sigset_t all;
    sigfillset(&all);
    if (sigprocmask(SIG_BLOCK, &all, NULL)) _exit(99);
    state->delivery_mask = (sigset_t)sc->sc_mask;
    enter_interrupted_stack(sc->sc_sp + 2047 - 192,
                            generated_handler, state, sc->sc_pc - 8);
  }
  stage = 5;
  if ((uintptr_t)sc->sc_cookie != state->cookie) _exit(96);
  --active_depth;
  if (sig == SIGUSR1) ++nested;
  else {
    if (nested != 1) _exit(98);
    sc->sc_pc = sc->sc_npc;
    sc->sc_npc += 4;
    handled = 1;
  }
}
int main(void) {
  stack_t ss;
  struct sigaction sa;
  static const uint32_t instructions[] = {0, 0x81c3e008, 0x9010202a};
  size_t size = getpagesize();
  void* code = mmap(NULL, size, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANON, -1, 0);
  if (code == MAP_FAILED) return 1;
  memset(&ss, 0, sizeof(ss));
  ss.ss_sp = altstack;
  ss.ss_size = sizeof(altstack);
  if (sigaltstack(&ss, NULL)) return 2;
  memset(&sa, 0, sizeof(sa));
  sa.sa_sigaction = roundtrip_handler;
  sa.sa_flags = SA_SIGINFO | SA_ONSTACK;
  sigemptyset(&sa.sa_mask);
  if (sigaction(SIGUSR1, &sa, NULL)) return 3;
  sa.sa_sigaction = roundtrip_handler;
  sa.sa_flags = SA_SIGINFO | SA_ONSTACK;
  if (sigaction(SIGILL, &sa, NULL)) return 4;
  sa.sa_sigaction = fault_handler;
  if (sigaction(SIGSEGV, &sa, NULL)) return 4;
  memcpy(code, instructions, sizeof(instructions));
  __asm__ volatile("membar #StoreStore" ::: "memory");
  size_t offset;
  for (offset = 0; offset < sizeof(instructions); offset += 4)
    __asm__ volatile("flush %0" : : "r"((char*)code + offset) : "memory");
  __asm__ volatile("membar #Sync" ::: "memory");
  if (mprotect(code, size, PROT_READ | PROT_EXEC)) return 5;
  double expected = 3.125, low, high;
  uint64_t fsr;
  __asm__ volatile("ldd %0, %%f0\n\tldd %0, %%f62"
                   : : "m"(expected) : "f0", "f1", "f62", "f63");
  __asm__ volatile("stx %%fsr, %0" : "=m"(fsr));
  fsr |= 0x3ff;
  __asm__ volatile("ldx %0, %%fsr" : : "m"(fsr));
  if (((long (*)(void))code)() != 42 || !handled || nested != 1) return 6;
  uintptr_t restored_g5;
  __asm__ volatile("mov %%g5, %0" : "=r"(restored_g5));
  __asm__ volatile("stx %%fsr, %0" : "=m"(fsr));
  if (restored_g5 != 0x123456 || (fsr & 0x3ff)) return 8;
  __asm__ volatile("std %%f0, %0\n\tstd %%f62, %1"
                   : "=m"(low), "=m"(high));
  if (low != expected || high != expected) return 7;
  puts("PASS native OpenBSD two-depth authenticated return, code roots and FP restoration");
  return munmap(code, size) != 0;
}
