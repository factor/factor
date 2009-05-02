#include <osreldate.h>

extern int getosreldate(void);

#include <sys/sysctl.h>

#ifndef KERN_PROC_PATHNAME
#define KERN_PROC_PATHNAME 12
#endif
