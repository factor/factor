namespace factor
{

#define VM_C_API extern "C" __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"
#define NULL_DLL "libfactor.dylib"

void init_signals(void);
void early_init(void);

const char *vm_executable_path(void);
const char *default_image_path(void);

inline static void *ucontext_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return ucontext->uc_stack.ss_sp;
}

void c_to_factor_toplevel(cell quot);

}
