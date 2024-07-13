namespace factor {

#define VM_C_API extern "C"

void early_init();
const char* vm_executable_path();
const char* default_image_path();

#define ZSTD_LIB "libzstd.so"

}
