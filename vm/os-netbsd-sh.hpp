#include <ucontext.h>
#include <sh3/sysarch.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  sh3_sync_icache((uintptr_t)start, len);
}
#define UAP_STACK_POINTER(uap) _UC_MACHINE_SP((ucontext_t*)uap)
#define UAP_PROGRAM_COUNTER(uap) _UC_MACHINE_PC((ucontext_t*)uap)
// NetBSD's sh3 ABI is soft-float, including physical SH4 landisk/dreamcast.
// Its kernel mcontext explicitly reserves the FPU fields as placeholders.
inline static unsigned int uap_fpu_status(void* uap) {
  (void)uap;
  return 0;
}
inline static void uap_clear_fpu_status(void* uap) { (void)uap; }
inline static unsigned int fpu_status(unsigned int status) {
  (void)status;
  return 0;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
