#include <sys/syscall.h>

namespace factor
{

VM_C_API int inotify_init();
VM_C_API int inotify_add_watch(int fd, const char *name, u32 mask);
VM_C_API int inotify_rm_watch(int fd, u32 wd);

}
