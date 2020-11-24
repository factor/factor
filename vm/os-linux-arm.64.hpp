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

// Must match the stack-frame-size constant in
// bootstrap/assembler/x86.64.unix.factor
static const unsigned JIT_FRAME_SIZE = 32;


static const unsigned char call_opcode = 0xe8;
static const unsigned char jmp_opcode = 0xe9;

inline static unsigned char call_site_opcode(cell return_address) {
  return *(unsigned char*)(return_address - 5);
}

inline static void check_call_site(cell return_address) {
  unsigned char opcode = call_site_opcode(return_address);
  FACTOR_ASSERT(opcode == call_opcode || opcode == jmp_opcode);
  (void)opcode; // suppress warning when compiling without assertions
}

inline static void* get_call_target(cell return_address) {
  check_call_site(return_address);
  return (void*)(*(int*)(return_address - 4) + return_address);
}

inline static void set_call_target(cell return_address, cell target) {
  check_call_site(return_address);
  *(int*)(return_address - 4) = (uint32_t)(target - return_address);
}

inline static bool tail_call_site_p(cell return_address) {
  switch (call_site_opcode(return_address)) {
    case jmp_opcode:
      return true;
    case call_opcode:
      return false;
    default:
      abort();
      return false;
  }
}

static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 192;

}
