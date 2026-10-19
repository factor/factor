// Native m68k ABI and executable-code probe; this is not a Factor VM gate.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <sys/mman.h>
#include <unistd.h>
#include <signal.h>
#include <ucontext.h>
#include <vector>
#include "../../master.hpp"
#include "native-abi.h"
extern "C" __attribute__((noinline)) uint32_t integer_ffi(uint32_t a, uint32_t b) { return a * 7 + b; }
extern "C" __attribute__((noinline)) double float_ffi(double a, double b) { return a * 2.0 + b; }
extern "C" uint32_t m68k_probe_bridge(uint32_t(*)(uint32_t, uint32_t), uint32_t, uint32_t);
struct native_layout { char byte; uint32_t cell; double real; };
extern "C" __attribute__((noinline)) int generated_target() { return 73; }
static volatile sig_atomic_t signal_count;
static void illegal_instruction_handler(int signo, siginfo_t* info, void* context) {
 assert(signo == SIGILL);
 assert(info->si_signo == SIGILL);
 ucontext_t* saved = (ucontext_t*)context;
 assert(saved->uc_mcontext.gregs[R_SP] != 0);
 saved->uc_mcontext.gregs[R_PC] += 2;
 ++signal_count;
}
int main() {
 static_assert(sizeof(void*) == 4, "m68k cells are 32 bit");
 static_assert(__atomic_always_lock_free(4, nullptr), "VM cell atomics must be lock free");
 static_assert(__atomic_always_lock_free(1, nullptr), "VM flag atomics must be lock free");
 volatile uint32_t atomic_cell = 1;
 __atomic_store_n(&atomic_cell, 2, __ATOMIC_SEQ_CST);
 assert(__atomic_load_n(&atomic_cell, __ATOMIC_SEQ_CST) == 2);
 assert(__sync_bool_compare_and_swap(&atomic_cell, 2, 3));
 assert(__sync_fetch_and_add(&atomic_cell, 4) == 3);
 assert(__atomic_load_n(&atomic_cell, __ATOMIC_SEQ_CST) == 7);
 static_assert(alignof(uint32_t) == 2, "native m68k cell alignment");
 static_assert(alignof(double) == 2, "native m68k FP alignment");
 uint32_t endian = 0x01020304;
 assert(*(unsigned char*)&endian == 1);
 assert(integer_ffi(5, 7) == 42);
 assert(m68k_probe_bridge(integer_ffi, 5, 7) == 42);
 assert(float_ffi(1.25, 2.5) == 5.0);
 m68k_abi_record record = m68k_abi_roundtrip({2, 35, 2.5});
 assert(record.tag == 3 && record.integer == 42 && record.real == 5.0);
 assert(m68k_abi_follow({2, 35, 2.5}, 7) == 42);
 assert(m68k_abi_u64(UINT64_C(0x100000000)) == UINT64_C(0x223456789));
 assert(m68k_abi_varargs(3, 1.25, 2.5, 3.75) == 7.5);
 assert(m68k_abi_callback(integer_ffi) == 42);
 std::vector<uint32_t> heap(10000);
 for (unsigned i = 0; i < heap.size(); ++i) heap[i] = integer_ffi(i, 1);
 assert(heap[9999] == 69994);
 // moveq #42,d0; rts. m68k instructions need only word alignment.
 const unsigned char program[] = {0x70, 0x2a, 0x4e, 0x75};
 size_t size = (size_t)sysconf(_SC_PAGESIZE);
 void* code = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
 assert(code != MAP_FAILED);
 memcpy(code, program, sizeof(program));
 __builtin___clear_cache((char*)code, (char*)code + sizeof(program));
 assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
 assert(((int(*)())code)() == 42);
 assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
 // jsr absolute-long; rts. Patch at a 2-mod-4 address deliberately.
 const unsigned char call_program[] = {0x4e, 0xb9, 0, 0, 0, 0, 0x4e, 0x75};
 memcpy(code, call_program, sizeof(call_program));
 void* return_address = (char*)code + 6;
 assert(factor::m68k_call_site_p(return_address));
 assert(!factor::m68k_tail_call_site_p(return_address));
 factor::m68k_store_call_target(return_address, (uint32_t)(uintptr_t)&generated_target);
 assert(factor::m68k_call_target(return_address) == (uint32_t)(uintptr_t)&generated_target);
 __builtin___clear_cache((char*)code, (char*)code + sizeof(call_program));
 assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
 assert(((int(*)())code)() == 73);
 struct sigaction action = {};
 action.sa_sigaction = illegal_instruction_handler;
 action.sa_flags = SA_SIGINFO;
 sigemptyset(&action.sa_mask);
 assert(sigaction(SIGILL, &action, nullptr) == 0);
 assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
 // moveq #42,d0; illegal; rts. Resume through the saved Linux ucontext.
 const unsigned char signal_program[] = {0x70, 0x2a, 0x4a, 0xfc, 0x4e, 0x75};
 memcpy(code, signal_program, sizeof(signal_program));
 __builtin___clear_cache((char*)code, (char*)code + sizeof(signal_program));
 assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
 assert(((int(*)())code)() == 42);
 assert(signal_count == 1);
#ifdef __HAVE_68881__
 assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
 // fmove.d 4(sp),fp0; fadd.x fp0,fp0; rts.
 const unsigned char float_program[] = {0xf2, 0x2f, 0x54, 0x00, 0x00, 0x04,
                                         0xf2, 0x00, 0x00, 0x22, 0x4e, 0x75};
 memcpy(code, float_program, sizeof(float_program));
 __builtin___clear_cache((char*)code, (char*)code + sizeof(float_program));
 assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
 assert(((double(*)(double))code)(2.5) == 5.0);
 assert(mprotect(code, size, PROT_READ | PROT_WRITE) == 0);
 // (a+b)-a exposes excess precision if FPCR is left in extended mode.
 const unsigned char rounding_program[] = {0xf2,0x2f,0x54,0x00,0x00,0x04,
   0xf2,0x2f,0x54,0x22,0x00,0x0c, 0xf2,0x2f,0x54,0x28,0x00,0x04, 0x4e,0x75};
 memcpy(code, rounding_program, sizeof(rounding_program));
 __builtin___clear_cache((char*)code, (char*)code + sizeof(rounding_program));
 assert(mprotect(code, size, PROT_READ | PROT_EXEC) == 0);
 uint32_t fpcr;
 asm volatile("fmove.l %%fpcr,%0" : "=d"(fpcr));
 uint32_t double_fpcr = (fpcr & ~0xc0u) | 0x80u;
 asm volatile("fmove.l %0,%%fpcr" : : "d"(double_fpcr));
 double rounded = ((double(*)(double,double))code)(1e16, 1.0);
 asm volatile("fmove.l %0,%%fpcr" : : "d"(fpcr));
 assert(rounded == 0.0);
 uint32_t original_fpsr, status;
 asm volatile("fmove.l %%fpsr,%0" : "=d"(original_fpsr));
 uint32_t cleared_status = 0;
 double numerator = 1.0, denominator = 0.0;
 asm volatile("fmove.l %0,%%fpsr\n\tfmove.d %2,%%fp0\n\tfdiv.d %3,%%fp0\n\tfmove.l %%fpsr,%1"
   : "+d"(cleared_status), "=d"(status) : "m"(numerator), "m"(denominator) : "fp0");
 assert(factor::fpu_status(status) == factor::FP_TRAP_ZERO_DIVIDE);
 numerator = 0.0; cleared_status = 0;
 asm volatile("fmove.l %0,%%fpsr\n\tfmove.d %2,%%fp0\n\tfdiv.d %3,%%fp0\n\tfmove.l %%fpsr,%1"
   : "+d"(cleared_status), "=d"(status) : "m"(numerator), "m"(denominator) : "fp0");
 assert(factor::fpu_status(status) == factor::FP_TRAP_INVALID_OPERATION);
 assert(factor::fpu_status(0x40) == factor::FP_TRAP_OVERFLOW);
 assert(factor::fpu_status(0x20) == factor::FP_TRAP_UNDERFLOW);
 assert(factor::fpu_status(0x08) == factor::FP_TRAP_INEXACT);
 asm volatile("fmove.l %0,%%fpsr" : : "d"(original_fpsr));
#endif
 assert(munmap(code, size) == 0);
 printf("m68k native integer/FP/FFI/allocation/generated-code/signals passed; native align=%zu, struct=%zu\n", alignof(uint32_t), sizeof(native_layout));
}
