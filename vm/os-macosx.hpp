namespace factor
{

#define VM_C_API extern "C" __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"
#define NULL_DLL "libfactor.dylib"

void init_signals();
void early_init();

const char *vm_executable_path();
const char *default_image_path();

void c_to_factor_toplevel(cell quot);

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_stack.ss_sp)

}
