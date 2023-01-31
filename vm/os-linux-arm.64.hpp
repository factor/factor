#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

namespace factor {

#define CALLSTACK_BOTTOM(ctx) \
  (ctx->callstack_seg->end - sizeof(cell) * 5)

static const fixnum xt_tail_pic_offset = 4 + 1;

#define UAP_STACK_POINTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.sp)
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.pc)

// #define CODE_TO_FUNCTION_POINTER(code) (void)0
// #define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
// #define FUNCTION_CODE_POINTER(ptr) ptr
// #define FUNCTION_TOC_POINTER(ptr) ptr

inline static unsigned int uap_fpu_status(void* uap) {
  // ucontext_t* ucontext = (ucontext_t*)uap;
  // return ucontext->uc_mcontext.fpregs->swd |
  //        ucontext->uc_mcontext.fpregs->mxcsr;
  return 0;
}

inline static void uap_clear_fpu_status(void* uap) {
  // ucontext_t* ucontext = (ucontext_t*)uap;
  // ucontext->uc_mcontext.fpregs->swd = 0;
  // ucontext->uc_mcontext.fpregs->mxcsr &= 0xffffffc0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x04)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x08)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x20)
    r |= FP_TRAP_INEXACT;

  return r;
}
  // FP_TRAP_INVALID_OPERATION = 1 << 0,
  // FP_TRAP_OVERFLOW = 1 << 1,
  // FP_TRAP_UNDERFLOW = 1 << 2,
  // FP_TRAP_ZERO_DIVIDE = 1 << 3,
  // FP_TRAP_INEXACT = 1 << 4,


// #define UAP_STACK_POINTER(ucontext) \
//   (((ucontext_t*)ucontext)->uc_mcontext.regs[15])
// #define UAP_PROGRAM_COUNTER(ucontext) \
//   (((ucontext_t*)ucontext)->uc_mcontext.regs[16])

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

// Must match the stack-frame-size constant in bootstrap/assembler/arm.64.factor
static const unsigned JIT_FRAME_SIZE = 64;

// last byte of X9 BR in absolute-call
static const unsigned char call_opcode = 0x14;
// last byte of 12 Br in absolute-jump
static const unsigned char jmp_opcode = 0xd6;

static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 288;

}
