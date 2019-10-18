#define DLLEXPORT __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macosx"
void init_signals(void);
void early_init(void);
const char *default_image_path(void);
