namespace factor
{

#define VM_C_API extern "C"
#define NULL_DLL NULL

void early_init();
const char *vm_executable_path();
const char *default_image_path();

}
