#include <signal.h>
#include <asm/sigcontext.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__gregs[3])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__pc)
inline static uint32_t* uap_fcsr(void* uap) {
  auto* info = (sctx_info*)((ucontext_t*)uap)->uc_mcontext.__extcontext;
  while (info->magic && info->size >= sizeof(sctx_info)) {
    auto* body = (char*)info + sizeof(sctx_info);
    if (info->magic == FPU_CTX_MAGIC) return &((fpu_context*)body)->fcsr;
    if (info->magic == LSX_CTX_MAGIC) return &((lsx_context*)body)->fcsr;
    if (info->magic == LASX_CTX_MAGIC) return &((lasx_context*)body)->fcsr;
    info = (sctx_info*)((char*)info + info->size);
  }
  return nullptr;
}
inline static unsigned int uap_fpu_status(void* uap) {
  uint32_t* fcsr = uap_fcsr(uap);
  return fcsr ? *fcsr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  if (uint32_t* fcsr = uap_fcsr(uap)) *fcsr &= ~0x1f1f0000;
}
inline static unsigned int fpu_status(unsigned int status) {
  status |= status >> 8; // Enabled traps report causes in bits 24..28.
  unsigned int r = 0;
  if (status & 0x100000) r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x080000) r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x040000) r |= FP_TRAP_OVERFLOW;
  if (status & 0x020000) r |= FP_TRAP_UNDERFLOW;
  if (status & 0x010000) r |= FP_TRAP_INEXACT;
  return r;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}

#include "os-linux-fpu.hpp"
