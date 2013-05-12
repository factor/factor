namespace factor {

#define VM_C_API extern "C" __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"

void early_init();

const char* vm_executable_path();
const char* default_image_path();

#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_stack.ss_sp)
#define UAP_SET_TOC_POINTER(uap, ptr) (void) 0

#define UAP_STACK_POINTER_TYPE void *

#define CODE_TO_FUNCTION_POINTER(code) (void) 0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void) 0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
