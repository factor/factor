#define DLLEXPORT
#define NULL_DLL NULL

void init_signals(void);
void early_init(void);
const char *vm_executable_path(void);
const char *default_image_path(void);
