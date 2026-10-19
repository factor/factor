#include <signal.h>
#include <ucontext.h>

namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
// Linux saves 64-bit GPR/PC slots even for O32. Dispatch expects a cell lvalue.
// Select its least significant cell explicitly for big-endian 32-bit targets.
inline static cell& mips_context_cell(void* slot) {
#if __SIZEOF_POINTER__ == 4 && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
  return *((cell*)slot + 1);
#else
  return *(cell*)slot;
#endif
}
#define UAP_STACK_POINTER(uap) factor::mips_context_cell(&((ucontext_t*)(uap))->uc_mcontext.gregs[29])
#define UAP_PROGRAM_COUNTER(uap) factor::mips_context_cell(&((ucontext_t*)(uap))->uc_mcontext.pc)
#define UAP_NATIVE_ENTRY(uap, entry) \
  factor::mips_context_cell(&((ucontext_t*)(uap))->uc_mcontext.gregs[25]) = (entry)
inline static unsigned int mips_live_fcsr() {
  unsigned int status;
  __asm__ volatile("cfc1 %0,$31\n\tnop" : "=r"(status));
  return status;
}
inline static bool mips_active_fpu_fault(unsigned int status) {
  return (((status >> 7) & (status >> 12) & 0x1f) != 0) ||
         ((status & (1u << 17)) != 0);
}
inline static unsigned int uap_fpu_status(void* uap) {
  // QEMU-user can omit FCSR from its Linux signal context. An enabled
  // hardware exception is authoritative; masked sticky flags are not.
  const unsigned int live = mips_live_fcsr();
  return mips_active_fpu_fault(live)
             ? live
             : ((ucontext_t*)uap)->uc_mcontext.fpc_csr;
}
inline static void uap_clear_fpu_status(void* uap) {
  const unsigned int live = mips_live_fcsr();
  unsigned int& saved = ((ucontext_t*)uap)->uc_mcontext.fpc_csr;
  if (mips_active_fpu_fault(live)) saved = live;
  const unsigned int clear = ~((0x1fu << 2) | (0x3fu << 12));
  saved &= clear;
  const unsigned int cleared_live = live & clear;
  __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop"
                   : : "r"(cleared_live) : "memory");
}
inline static unsigned int fpu_status(unsigned int status) {
  const unsigned int bits = ((status >> 2) | (status >> 12)) & 0x1f;
  unsigned int r = 0;
  if (bits & 0x10) r |= FP_TRAP_INVALID_OPERATION;
  if (bits & 0x08) r |= FP_TRAP_ZERO_DIVIDE;
  if (bits & 0x04) r |= FP_TRAP_OVERFLOW;
  if (bits & 0x02) r |= FP_TRAP_UNDERFLOW;
  if (bits & 0x01) r |= FP_TRAP_INEXACT;
  return r;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
