// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#include <cassert>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <cstdint>
#include <initializer_list>
#include <limits>
#include <signal.h>
#include <sys/mman.h>
#include <ucontext.h>
#include <unistd.h>
#include <vector>
// Keep this executable small enough to compile on a 64 MiB R2D guest.
// Exercise the production layout, signal and call-site headers directly.
#include "../../assert.hpp"
#include "../../layouts.hpp"
#include "../../sh.hpp"
#include "../../os-linux-sh.hpp"
#include "../../cpu-sh.hpp"
struct record { unsigned char tag; unsigned integer; double real; };
extern "C" __attribute__((noinline)) unsigned integer_ffi(unsigned a, unsigned b) { return a * 7 + b; }
extern "C" __attribute__((noinline)) unsigned alternate_target(unsigned, unsigned) { return 73; }
extern "C" __attribute__((noinline)) double float_ffi(double a, double b) { return a * b + b; }
extern "C" __attribute__((noinline)) record aggregate_ffi(record r) { r.tag++; r.integer += 7; r.real *= 2; return r; }
struct byte_record { unsigned char bytes[4]; };
struct pair_record { unsigned first, second; };
struct single_record { float value; };
extern "C" __attribute__((noinline)) byte_record byte_record_ffi(byte_record r) { r.bytes[0]++; r.bytes[3] += 7; return r; }
extern "C" __attribute__((noinline)) pair_record pair_record_ffi(pair_record r) { r.first += 7; r.second *= 2; return r; }
extern "C" __attribute__((noinline)) single_record single_record_ffi(single_record r) { r.value *= 2; return r; }
extern "C" byte_record sh_probe_byte_record_bridge(byte_record (*fn)(byte_record), byte_record);
extern "C" pair_record sh_probe_pair_record_bridge(pair_record (*fn)(pair_record), pair_record);
extern "C" single_record sh_probe_single_record_bridge(single_record (*fn)(single_record), single_record);
extern "C" unsigned sh_probe_bridge(unsigned (*fn)(unsigned, unsigned), unsigned, unsigned);
extern "C" __attribute__((noinline)) double varargs_ffi(unsigned count, ...) {
  va_list args; va_start(args, count); double total = 0;
  while (count--) total += va_arg(args, double);
  va_end(args); return total;
}
extern "C" double sh_probe_fp_bridge(double (*fn)(double, double), double, double);
extern "C" record sh_probe_record_bridge(record (*fn)(record), record);
static volatile sig_atomic_t signal_count;
static void illegal_handler(int, siginfo_t*, void* opaque) {
  auto* u = static_cast<ucontext_t*>(opaque);
  assert(u->uc_mcontext.gregs[15] != 0);
  assert(u->uc_mcontext.pr != 0);
  u->uc_mcontext.pc += 2;
  signal_count++;
}
int main() {
  static_assert(sizeof(void*) == 4 && sizeof(long) == 4);
  static_assert(alignof(unsigned) == 4 && alignof(double) == 4);
  static_assert(__atomic_always_lock_free(1, nullptr));
  static_assert(__atomic_always_lock_free(4, nullptr));
  assert(integer_ffi(5, 7) == 42);
  assert(sh_probe_bridge(integer_ffi, 5, 7) == 42);
  auto bytes = sh_probe_byte_record_bridge(byte_record_ffi, {{1, 2, 3, 4}});
  assert(bytes.bytes[0] == 2 && bytes.bytes[1] == 2 && bytes.bytes[2] == 3 && bytes.bytes[3] == 11);
  auto pair = sh_probe_pair_record_bridge(pair_record_ffi, {35, 21});
  assert(pair.first == 42 && pair.second == 42);
  auto single = sh_probe_single_record_bridge(single_record_ffi, {1.25f});
  assert(single.value == 2.5f);
  assert(float_ffi(1.25, 2.5) == 5.625);
  assert(sh_probe_fp_bridge(float_ffi, 1.25, 2.5) == 5.625);
  auto r = aggregate_ffi({2, 35, 2.5});
  assert(r.tag == 3 && r.integer == 42 && r.real == 5);
  r = sh_probe_record_bridge(aggregate_ffi, {2, 35, 2.5});
  assert(r.tag == 3 && r.integer == 42 && r.real == 5);
  assert(varargs_ffi(3, 1.25, 2.5, 3.75) == 7.5);
  // Keep DN disabled: IEEE subnormals must survive. Real Linux SH4 uses
  // the kernel's ieee_fpe_handler for denormal operands unsupported by HW.
  unsigned original_fpscr;
  asm volatile("sts fpscr,%0" : "=r"(original_fpscr));
  assert((original_fpscr & (1u << 18)) == 0);
  volatile double minimum = std::numeric_limits<double>::denorm_min();
  volatile double two = 2.0;
  volatile double ieee_result = minimum * two;
  double ieee_copy = ieee_result;
  uint64_t ieee_bits;
  memcpy(&ieee_bits, &ieee_copy, sizeof(ieee_bits));
  assert(ieee_bits == 2);
  volatile double large = 1e16, one = 1.0;
  ieee_result = (large + one) - large;
  assert(ieee_result == 0.0);
  unsigned cleared_fpscr = original_fpscr & ~0x3f07cu;
  asm volatile("lds %0,fpscr" : : "r"(cleared_fpscr));
  volatile double zero = 0.0;
  ieee_result = one / zero;
  unsigned flags;
  asm volatile("sts fpscr,%0" : "=r"(flags));
  assert(factor::fpu_status(flags) == factor::FP_TRAP_ZERO_DIVIDE);
  asm volatile("lds %0,fpscr" : : "r"(original_fpscr));
  volatile unsigned published = 0;
  __atomic_store_n(&published, 42, __ATOMIC_SEQ_CST);
  assert(__atomic_load_n(&published, __ATOMIC_SEQ_CST) == 42);
  std::vector<unsigned> allocation(10000, 42);
  assert(allocation.back() == 42);
  const size_t size = size_t(sysconf(_SC_PAGESIZE));
  void* code = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  constexpr bool le = __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__;
  // MOV #42,R0; RTS; NOP. RTS has a mandatory delay slot.
  factor::sh_store_instruction(code, 0xe02a, le);
  factor::sh_store_instruction(static_cast<char*>(code) + 2, 0x000b, le);
  factor::sh_store_instruction(static_cast<char*>(code) + 4, 0x0009, le);
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + 6);
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(reinterpret_cast<int(*)()>(code)() == 42);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  // STS.L PR,@-SP; MOV.L literal,R0; JSR @R0; NOP; LDS.L @SP+,PR;
  // RTS; NOP; padding; .long target. Preserve the caller's PR explicitly.
  auto* p = static_cast<char*>(code);
  const uint16_t call_program[] = {0x4f22, 0xd003, 0x400b, 0x0009,
                                  0x4f26, 0x000b, 0x0009, 0x0009};
  for (unsigned i = 0; i < 8; ++i) factor::sh_store_instruction(p + 2 * i, call_program[i], le);
  factor::set_call_target((factor::cell)(p + 8), (factor::cell)&integer_ffi);
  assert(factor::get_call_target((factor::cell)(p + 8)) == (void*)&integer_ffi);
  assert(!factor::tail_call_site_p((factor::cell)(p + 8)));
  factor::flush_icache((factor::cell)code, 20);
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(reinterpret_cast<unsigned(*)(unsigned,unsigned)>(code)(5, 7) == 42);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  factor::set_call_target((factor::cell)(p + 8), (factor::cell)&alternate_target);
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(reinterpret_cast<unsigned(*)(unsigned,unsigned)>(code)(5, 7) == 73);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  // A tail jump leaves the incoming PR intact; the native target returns
  // straight to the original caller after the JMP delay slot executes.
  factor::sh_store_instruction(p, 0xd001, le);
  factor::sh_store_instruction(p + 2, 0x402b, le);
  factor::sh_store_instruction(p + 4, 0x0009, le);
  factor::set_call_target((factor::cell)(p + 6), (factor::cell)&alternate_target);
  assert(factor::tail_call_site_p((factor::cell)(p + 6)));
  factor::flush_icache((factor::cell)code, 12);
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(reinterpret_cast<unsigned(*)(unsigned,unsigned)>(code)(5, 7) == 73);
  ucontext_t saved = {};
  saved.uc_mcontext.fpscr = 0xffffffff;
  factor::uap_clear_fpu_status(&saved);
  assert(saved.uc_mcontext.fpscr == (0xffffffffu & ~0x3f07cu));
  assert(factor::fpu_status(1u << 6) == factor::FP_TRAP_INVALID_OPERATION);
  assert(factor::fpu_status(1u << 5) == factor::FP_TRAP_ZERO_DIVIDE);
  assert(factor::fpu_status(1u << 4) == factor::FP_TRAP_OVERFLOW);
  assert(factor::fpu_status(1u << 3) == factor::FP_TRAP_UNDERFLOW);
  assert(factor::fpu_status(1u << 2) == factor::FP_TRAP_INEXACT);
  struct sigaction action = {};
  action.sa_sigaction = illegal_handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGILL, &action, nullptr) == 0);
  assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
  // Illegal halfword before return, outside any delay slot.
  factor::sh_store_instruction(code, 0xffff, le);
  factor::sh_store_instruction(static_cast<char*>(code) + 2, 0xe02a, le);
  factor::sh_store_instruction(static_cast<char*>(code) + 4, 0x000b, le);
  factor::sh_store_instruction(static_cast<char*>(code) + 6, 0x0009, le);
  __builtin___clear_cache(static_cast<char*>(code), static_cast<char*>(code) + 8);
  assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
  assert(reinterpret_cast<int(*)()>(code)() == 42);
  assert(signal_count == 1);
  assert(munmap(code, size) == 0);
  printf("SH4 native integer/FP/aggregate/varargs/bridge/allocation/atomics/generated-code/ucontext passed; record=%zu\n", sizeof(record));
}
