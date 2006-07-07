#define INLINE inline static

#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
	#define FACTOR_X86
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
	#define FACTOR_PPC
#elif defined(__amd64__) || defined(__x86_64__)
	#define FACTOR_AMD64
#endif

#ifdef WINDOWS
	#include "os-windows.h"
#else
	#include "os-unix.h"

	#ifdef __APPLE__
		#include "os-macosx.h"
		#include "mach_signal.h"
		
		#ifdef FACTOR_X86
			#include "os-macosx-x86.h"
		#elif defined(FACTOR_PPC)
			#include "os-macosx-ppc.h"
		#endif
	#else
		#include "os-genunix.h"
		#ifdef __FreeBSD__
			#include "os-freebsd.h"
		#elif defined(linux)
				#include "os-linux.h"
		#elif defined(__sun)
			#include "os-solaris.h"
		#else
			#error "Unsupported OS"
		#endif
	#endif
#endif

#ifdef FACTOR_X86
	#include "cpu-x86.h"
#elif defined(FACTOR_PPC)
	#include "cpu-ppc.h"
#elif defined(FACTOR_AMD64)
	#include "cpu-amd64.h"
#else
	#error "Unsupported CPU"
#endif
