#define UNKNOWN_TYPE_P(file) ((file)->d_type == DT_UNKNOWN)
#define DIRECTORY_P(file) ((file)->d_type == DT_DIR)

#ifndef environ
	extern char **environ;
#endif

int inotify_init(void);
int inotify_add_watch(int fd, const char *name, u32 mask);
int inotify_rm_watch(int fd, u32 wd);
