#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

namespace factor {

void flush_icache(cell start, cell len);

#define UAP_STACK_POINTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.arm_sp)
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.arm_pc)

// sigreturn restores CPSR separately from PC; an odd Thumb entry does not
// select Thumb state by itself. A fresh handler also starts outside any IT block.
inline static void arm32_signal_set_entry(void* uap, cell entry) {
  auto& regs = ((ucontext_t*)uap)->uc_mcontext;
  regs.arm_cpsr = (regs.arm_cpsr & ~0x0600fc20u) | ((entry & 1) << 5);
  regs.arm_pc = entry & ~cell(1);
}

// Linux ARM saves coprocessors as bounded magic/size records in uc_regspace.
// VFP user state contains 32 D registers followed by FPSCR (byte offset 264).
inline static unsigned int* arm32_signal_fpscr(void* uap) {
  auto& space = ((ucontext_t*)uap)->uc_regspace;
  auto p = (unsigned int*)space;
  auto end = (unsigned int*)((char*)space + sizeof(space));
  while (end - p >= 2 && p[0] && p[1]) {
    unsigned int size = p[1];
    if (size < 8 || (size & 7) || size > (unsigned int)(end - p) * 4)
      break;
    if (p[0] == 0x56465001 && size >= 268)
      return p + 66;
    p += size / 4;
  }
  return nullptr;
}
inline static unsigned int uap_fpu_status(void* uap) {
  auto fpscr = arm32_signal_fpscr(uap);
  return fpscr ? *fpscr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto fpscr = arm32_signal_fpscr(uap);
  if (fpscr) *fpscr &= ~0x9fu;
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
