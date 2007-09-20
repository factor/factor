#include <osreldate.h>

extern int getosreldate(void);

#include <sys/sysctl.h>

#ifndef KERN_PROC_PATHNAME
#define KERN_PROC_PATHNAME 12
#endif

#define UNKNOWN_TYPE_P(file) ((file)->d_type == DT_UNKNOWN)
#define DIRECTORY_P(file) ((file)->d_type == DT_DIR)
