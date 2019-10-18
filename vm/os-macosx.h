#define DLLEXPORT __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"
#define NULL_DLL "libfactor.dylib"
void init_signals(void);
void early_init(void);
const char *vm_executable_path(void);
const char *default_image_path(void);
#define UNKNOWN_TYPE_P(file) ((file)->d_type == DT_UNKNOWN)
#define DIRECTORY_P(file) ((file)->d_type == DT_DIR)
