#include <signal.h>

namespace factor {

#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.sp)
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.pc)

inline static fpsimd_context* find_fpsimd_context(void* uap) {
  unsigned char* extension_records = (unsigned char*)(((ucontext_t*)uap)->uc_mcontext.__reserved);
  unsigned int magic, size, i = 0;
  while (magic = extension_records[i], size=extension_records[i+4], magic != 0 && size != 0) {
    if (magic == FPSIMD_MAGIC) break;
    i += size;
  }
  if (magic == 0 && size == 0) {
    std::cout << "Couldn't find fpsimd_context: " << uap << std::endl;
    abort();
  }
  return (fpsimd_context*)(extension_records + i);
}

inline static unsigned int uap_fpu_status(void* uap) {
  return find_fpsimd_context(uap)->fpsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  find_fpsimd_context(uap)->fpsr = 0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_INEXACT;

  return r;
}

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
