// Copyright (C) 2026 Doug Coleman. BSD license.
// Native NetBSD SPARC ABI and generated-code probe, independent of the VM.
#ifdef NDEBUG
#error This probe requires assertions enabled
#endif
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <csignal>
#include <sys/mman.h>
#include <unistd.h>
#define FACTOR_ASSERT assert
#include "../../vm/sparc.hpp"
namespace factor {
using cell = uintptr_t;
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_ZERO_DIVIDE=2,
       FP_TRAP_OVERFLOW=4, FP_TRAP_UNDERFLOW=8, FP_TRAP_INEXACT=16 };
}
#include "../../vm/os-netbsd-sparc.hpp"

struct pair { double x; long y; };
__attribute__((noinline)) static pair aggregate(double x, long y) {
  return { x + 0.5, y + 2 };
}
__attribute__((noinline)) static double callback(double (*f)(double), double x) {
  return f(x);
}
__attribute__((noinline)) static double twice(double x) { return x * 2; }
__attribute__((noinline)) static unsigned long windows(unsigned long x) {
  volatile unsigned long saved = x;
  if (!x) return 0;
  return saved + windows(x - 1);
}
static volatile sig_atomic_t context_ok;
static void signal_context(int sig, siginfo_t*, void* raw) {
  const auto pc = factor::sparc_signal_pc(raw);
  const auto npc = factor::sparc_signal_npc(raw);
  const auto sp = factor::sparc_signal_stack_address(raw);
  context_ok = npc == pc + 4 && (sp & (__SIZEOF_POINTER__ == 8 ? 15 : 7)) == 0;
  if (sig == SIGILL) factor::sparc_redirect_signal(raw, npc);
}
int main() {
  assert(windows(64) == 2080); // More frames than hardware register windows.
  pair p = aggregate(1.25, 40);
  assert(p.x == 1.75 && p.y == 42);
  assert(callback(twice, 2.125) == 4.25);
  const uint32_t endian = 0x01020304;
  assert(*reinterpret_cast<const unsigned char*>(&endian) == 1);
  struct sigaction action{};
  action.sa_sigaction = signal_context;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGUSR1, &action, nullptr) == 0);
  assert(raise(SIGUSR1) == 0);
  assert(context_ok);
  const auto size = static_cast<size_t>(sysconf(_SC_PAGESIZE));
  void* code = mmap(nullptr, size, PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  // add %o0, 7, %o0; retl; nop (explicit return delay slot).
  const unsigned char bytes[] = {
    0x90,0x02,0x20,0x07, 0x81,0xc3,0xe0,0x08, 0x01,0x00,0x00,0x00
  };
  memcpy(code, bytes, sizeof(bytes));
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + sizeof(bytes));
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  auto generated = reinterpret_cast<long (*)(long)>(code);
  assert(generated(35) == 42);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
#if __SIZEOF_POINTER__ == 8
  // Fixed SET64 %o0,%g1 template, followed by retl/nop.
  const unsigned char constant[] = {
    0x03,0x00,0x00,0x00, 0x82,0x10,0x60,0x00,
    0x83,0x28,0x70,0x20, 0x11,0x00,0x00,0x00,
    0x90,0x12,0x20,0x00, 0x90,0x12,0x00,0x01,
    0x81,0xc3,0xe0,0x08, 0x01,0x00,0x00,0x00
  };
  memcpy(code, constant, sizeof(constant));
  constexpr uint64_t value = 0xfedcba9876543210ULL;
  factor::sparc_store_set64(code, value);
  assert(factor::sparc_load_set64(code) == value);
#else
  const unsigned char constant[] = {
    0x11,0x00,0x00,0x00, 0x90,0x12,0x20,0x00,
    0x81,0xc3,0xe0,0x08, 0x01,0x00,0x00,0x00
  };
  memcpy(code, constant, sizeof(constant));
  constexpr uint32_t value = 0xfedcba98U;
  factor::sparc_store_set32(code, value);
  assert(factor::sparc_load_set32(code) == value);
#endif
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + sizeof(constant));
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  auto relocated = reinterpret_cast<unsigned long (*)()>(code);
  assert(relocated() == value);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  // cmp %o0,0; be target; nop; retl; add %o0,7,%o0;
  // target: retl; mov 42,%o0. Patch the branch byte displacement.
  const unsigned char branch[] = {
    0x80,0xa2,0x20,0x00, 0x02,0x80,0x00,0x00,
    0x01,0x00,0x00,0x00, 0x81,0xc3,0xe0,0x08,
    0x90,0x02,0x20,0x07, 0x81,0xc3,0xe0,0x08,
    0x90,0x10,0x20,0x2a
  };
  memcpy(code, branch, sizeof(branch));
  factor::sparc_store_displacement(static_cast<char*>(code) + 4, 16, 22);
  assert(factor::sparc_displacement(static_cast<char*>(code) + 4, 22) == 16);
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + sizeof(branch));
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(generated(0) == 42);
  assert(generated(35) == 42);
  assert(generated(-7) == 0);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
#if __SIZEOF_POINTER__ == 8
  // V9 passes scalar doubles in f0/f2 and returns in f0.
  const unsigned char floating[] = {
    0x81,0xa0,0x08,0x42, 0x81,0xc3,0xe0,0x08, 0x01,0x00,0x00,0x00
  };
#else
  // V8 passes doubles in integer register pairs. A windowed frame stores
  // incoming i0/i1 and i2/i3, loads f0/f2, and returns the sum in f0.
  const unsigned char floating[] = {
    0x9d,0xe3,0xbf,0xa0, 0xf0,0x3b,0xa0,0x40,
    0xc1,0x1b,0xa0,0x40, 0xf4,0x3b,0xa0,0x48,
    0xc5,0x1b,0xa0,0x48, 0x81,0xa0,0x08,0x42,
    0x81,0xc7,0xe0,0x08, 0x81,0xe8,0x00,0x00
  };
#endif
  memcpy(code, floating, sizeof(floating));
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + sizeof(floating));
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  auto generated_fp = reinterpret_cast<double (*)(double, double)>(code);
  assert(generated_fp(1.25, 2.5) == 3.75);
  assert(generated_fp(-1.25, 1.25) == 0.0);
  assert(sigaction(SIGILL, &action, nullptr) == 0);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  // unimp 0 raises SIGILL; handler resumes at retl with NPC set to its
  // mov 42,%o0 delay slot. This checks actual kernel signal restoration.
  const unsigned char resumable[] = {
    0x00,0x00,0x00,0x00, 0x81,0xc3,0xe0,0x08, 0x90,0x10,0x20,0x2a
  };
  memcpy(code, resumable, sizeof(resumable));
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + sizeof(resumable));
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  context_ok = 0;
  assert(generated(0) == 42);
  assert(context_ok);
  assert(munmap(code, size) == 0);
  printf("SPARC%zu: endian, windows, FP callback, aggregate return, PC/NPC, stack alignment/bias, executable bytes and patched constant/branch and signal resume passed\n", sizeof(void*) * 8);
}
