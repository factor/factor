// Compile against the native NetBSD landisk/sh3 headers, not Linux ucontext.
#include <stdint.h>
#include <stddef.h>
namespace factor { using cell = uintptr_t; }
#include "../../os-netbsd-sh.hpp"
static_assert(sizeof(factor::cell) == 4);
static_assert(sizeof(__greg_t) == 4);
static_assert(_REG_SP == 21);
static_assert(_REG_PC == 1);
static_assert(_REG_R14 == 6);
extern "C" void sh_netbsd_context_probe(void* uap) {
  UAP_STACK_POINTER(uap) = 123;
  UAP_PROGRAM_COUNTER(uap) = 456;
  factor::flush_icache(0x1000, 8);
}
