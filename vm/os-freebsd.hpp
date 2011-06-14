#include <osreldate.h>
#include <sys/sysctl.h>

extern "C" int getosreldate();

#ifndef KERN_PROC_PATHNAME
#define KERN_PROC_PATHNAME 12
#endif

#define UAP_STACK_POINTER_TYPE __register_t

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
