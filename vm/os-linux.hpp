#include <sys/syscall.h>

namespace factor
{

int inotify_init();
int inotify_add_watch(int fd, const char *name, u32 mask);
int inotify_rm_watch(int fd, u32 wd);

}
