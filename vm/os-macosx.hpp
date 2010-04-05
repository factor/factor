namespace factor
{

#define VM_C_API extern "C" __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"

void early_init();

const char *vm_executable_path();
const char *default_image_path();

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_stack.ss_sp)

#define UAP_STACK_POINTER_TYPE void*

}
