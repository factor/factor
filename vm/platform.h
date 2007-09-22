#if defined(__arm__)
	#define FACTOR_ARM
#elif defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
	#define FACTOR_X86
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
	#define FACTOR_PPC
#elif defined(__amd64__) || defined(__x86_64__)
	#define FACTOR_AMD64
#else
	#error "Unsupported architecture"
#endif

#if defined(WINDOWS)
	#if defined(WINCE)
		#include "os-windows-ce.h"
	#elif defined (__i386)
		#include "os-windows-nt.h"
	#else
		#error "Unsupported Windows flavor"
	#endif

	#include "os-windows.h"
#else
	#include "os-unix.h"

	#ifdef __APPLE__
		#include "os-unix-ucontext.h"
		#include "os-macosx.h"
		#include "mach_signal.h"
		
		#ifdef FACTOR_X86
			#include "os-macosx-x86.h"
		#elif defined(FACTOR_PPC)
			#include "os-macosx-ppc.h"
		#else
			#error "Unsupported Mac OS X flavor"
		#endif
	#else
		#include "os-genunix.h"

		#ifdef __FreeBSD__
			#define FACTOR_OS_STRING "freebsd"
			#include "os-freebsd.h"
			#include "os-unix-ucontext.h"
			
			#if defined(FACTOR_X86)
				#include "os-freebsd-x86.h"
			#else
				#error "Unsupported FreeBSD flavor"
			#endif
		#elif defined(__OpenBSD__)
			#define FACTOR_OS_STRING "openbsd"
			#include "os-openbsd.h"

			#if defined(FACTOR_X86)
				#include "os-openbsd-x86.h"
			#elif defined(FACTOR_AMD64)
				#include "os-openbsd-amd64.h"
			#else
				#error "Unsupported OpenBSD flavor"
			#endif
		#elif defined(linux)
			#define FACTOR_OS_STRING "linux"
			#include "os-linux.h"

			#if defined(FACTOR_X86)
				#include "os-unix-ucontext.h"
			#elif defined(FACTOR_PPC)
				#include "os-unix-ucontext.h"
				#include "os-linux-ppc.h"
			#elif defined(FACTOR_ARM)
				#include "os-linux-arm.h"
			#elif defined(FACTOR_AMD64)
				#include "os-unix-ucontext.h"
			#else
				#error "Unsupported Linux flavor"
			#endif
		#elif defined(__SVR4) && defined(sun)
			#define FACTOR_OS_STRING "solaris"
			#include "os-solaris.h"
			#include "os-unix-ucontext.h"
		#else
			#error "Unsupported OS"
		#endif
	#endif
#endif

#if defined(FACTOR_X86)
	#include "cpu-x86.h"
	#include "cpu-x86.32.h"
#elif defined(FACTOR_AMD64)
	#include "cpu-x86.h"
	#include "cpu-x86.64.h"
#elif defined(FACTOR_PPC)
	#include "cpu-ppc.h"
#elif defined(FACTOR_ARM)
	#include "cpu-arm.h"
#else
	#error "Unsupported CPU"
#endif
