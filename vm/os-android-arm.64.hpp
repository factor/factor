#pragma once
#include <signal.h>
#include <ucontext.h>

namespace factor {

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache(reinterpret_cast<char*>(start),
                          reinterpret_cast<char*>(start + len));
}

#define UAP_STACK_POINTER(uap) \
  (static_cast<ucontext_t*>(uap)->uc_mcontext.sp)
#define UAP_PROGRAM_COUNTER(uap) \
  (static_cast<ucontext_t*>(uap)->uc_mcontext.pc)

inline static fpsimd_context* find_fpsimd_context(void* uap) {
  auto* records = reinterpret_cast<unsigned int*>(
      static_cast<ucontext_t*>(uap)->uc_mcontext.__reserved);
  for (size_t offset = 0;;) {
    unsigned int magic = records[offset];
    unsigned int size = records[offset + 1];
    if (magic == FPSIMD_MAGIC)
      return reinterpret_cast<fpsimd_context*>(records + offset);
    if (magic == 0 || size == 0)
      abort();
    offset += size / sizeof(*records);
  }
}

inline static unsigned int uap_fpu_status(void* uap) {
  return find_fpsimd_context(uap)->fpsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  find_fpsimd_context(uap)->fpsr = 0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 0x01) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04) result |= FP_TRAP_OVERFLOW;
  if (status & 0x08) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x10) result |= FP_TRAP_INEXACT;
  return result;
}

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
