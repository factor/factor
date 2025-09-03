#include <ucontext.h>

namespace factor {

#define UAP_STACK_POINTER(ucontext) \
  ((ucontext_t*)ucontext)->uc_mcontext.gp_regs[1]
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gp_regs[32])

#define FACTOR_PPC_TOC 1

#define CODE_TO_FUNCTION_POINTER(code) \
  void* desc[3];                       \
  code = fill_function_descriptor(desc, code)

#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code)     \
  code = fill_function_descriptor(new void* [3], code); \
  vm->function_descriptors.push_back((void**)code)

#define FUNCTION_CODE_POINTER(ptr) (function_descriptor_field((void*)ptr, 0))

#define FUNCTION_TOC_POINTER(ptr) (function_descriptor_field((void*)ptr, 1))

inline static unsigned int uap_fpu_status(void* uap) {
  union {
    double as_double;
    unsigned int as_uint[2];
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.fp_regs[32];
  return tmp.as_uint[1];
}

inline static void uap_clear_fpu_status(void* uap) {
  union {
    double as_double;
    unsigned int as_uint[2];
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.fp_regs[32];
  tmp.as_uint[1] &= 0x0007f8ff;
  ((ucontext_t*)uap)->uc_mcontext.fp_regs[32] = tmp.as_double;
}

}
