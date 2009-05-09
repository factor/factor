namespace factor
{

#define VM_C_API extern "C"
#define NULL_DLL NULL

void c_to_factor_toplevel(cell quot);
void init_signals();
void early_init();
const char *vm_executable_path();
const char *default_image_path();

}
