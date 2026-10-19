#include <ucontext.h>
#include <asm/ptrace.h>

namespace factor {

#define UAP_LINK_REGISTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.gp_regs[PT_LNK])

#define UAP_STACK_POINTER(ucontext) \
  ((ucontext_t*)ucontext)->uc_mcontext.gp_regs[1]
#define UAP_GLOBAL_ENTRY_REGISTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gp_regs[12])
#define UAP_TOC_REGISTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gp_regs[2])
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gp_regs[32])

#if !defined(_CALL_ELF) || _CALL_ELF == 1
#define FACTOR_PPC_TOC 1

#define CODE_TO_FUNCTION_POINTER(code) \
  void* desc[3];                       \
  code = (decltype(code))fill_function_descriptor(desc, (void*)code)

#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code)     \
  code = (decltype(code))fill_function_descriptor(new void* [3], (void*)code); \
  vm->function_descriptors.push_back((void**)code)

#define FUNCTION_CODE_POINTER(ptr) ((cell)function_descriptor_field((void*)ptr, 0))

#define FUNCTION_TOC_POINTER(ptr) ((cell)function_descriptor_field((void*)ptr, 1))
#else
// ELFv2 function pointers address code directly. Callers must place the
// global entry address in r12 so the callee can establish its own TOC.
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
#endif

inline static unsigned int uap_fpu_status(void* uap) {
  union {
    double as_double;
    uint64_t as_uint;
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.fp_regs[32];
  return (unsigned int)tmp.as_uint;
}

inline static void uap_clear_fpu_status(void* uap) {
  union {
    double as_double;
    uint64_t as_uint;
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.fp_regs[32];
  tmp.as_uint &= UINT64_C(0xffffffff0007f8ff);
  ((ucontext_t*)uap)->uc_mcontext.fp_regs[32] = tmp.as_double;
}

}
