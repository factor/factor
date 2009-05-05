#if defined(__arm__)
	#define FACTOR_ARM
#elif defined(__amd64__) || defined(__x86_64__)
	#define FACTOR_AMD64
#elif defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
	#define FACTOR_X86
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
	#define FACTOR_PPC
#else
	#error "Unsupported architecture"
#endif

#if defined(WINDOWS)
	#if defined(WINCE)
		#include "os-windows-ce.hpp"
	#else
		#include "os-windows-nt.hpp"
	#endif

	#include "os-windows.hpp"
	#if defined(FACTOR_AMD64)
		#include "os-windows-nt.64.hpp"
	#elif defined(FACTOR_X86)
		#include "os-windows-nt.32.hpp"
	#endif
#else
	#include "os-unix.hpp"

	#ifdef __APPLE__
		#include "os-macosx.hpp"
		#include "mach_signal.hpp"
		
		#ifdef FACTOR_X86
			#include "os-macosx-x86.32.hpp"
		#elif defined(FACTOR_PPC)
			#include "os-macosx-ppc.hpp"
		#elif defined(FACTOR_AMD64)
			#include "os-macosx-x86.64.hpp"
		#else
			#error "Unsupported Mac OS X flavor"
		#endif
	#else
		#include "os-genunix.hpp"

		#ifdef __FreeBSD__
			#define FACTOR_OS_STRING "freebsd"
			#include "os-freebsd.hpp"
			
			#if defined(FACTOR_X86)
				#include "os-freebsd-x86.32.hpp"
			#elif defined(FACTOR_AMD64)
				#include "os-freebsd-x86.64.hpp"
			#else
				#error "Unsupported FreeBSD flavor"
			#endif
		#elif defined(__OpenBSD__)
			#define FACTOR_OS_STRING "openbsd"

			#if defined(FACTOR_X86)
				#include "os-openbsd-x86.32.hpp"
			#elif defined(FACTOR_AMD64)
				#include "os-openbsd-x86.64.hpp"
			#else
				#error "Unsupported OpenBSD flavor"
			#endif
		#elif defined(__NetBSD__)
			#define FACTOR_OS_STRING "netbsd"

			#if defined(FACTOR_X86)
				#include "os-netbsd-x86.32.hpp"
			#elif defined(FACTOR_AMD64)
				#include "os-netbsd-x86.64.hpp"
			#else
				#error "Unsupported NetBSD flavor"
			#endif

			#include "os-netbsd.hpp"
		#elif defined(linux)
			#define FACTOR_OS_STRING "linux"
			#include "os-linux.hpp"

			#if defined(FACTOR_X86)
				#include "os-linux-x86.32.hpp"
			#elif defined(FACTOR_PPC)
				#include "os-linux-ppc.hpp"
			#elif defined(FACTOR_ARM)
				#include "os-linux-arm.hpp"
			#elif defined(FACTOR_AMD64)
				#include "os-linux-x86.64.hpp"
			#else
				#error "Unsupported Linux flavor"
			#endif
		#elif defined(__SVR4) && defined(sun)
			#define FACTOR_OS_STRING "solaris"

			#if defined(FACTOR_X86)
				#include "os-solaris-x86.32.hpp"
			#elif defined(FACTOR_AMD64)
				#include "os-solaris-x86.64.hpp"
			#else
				#error "Unsupported Solaris flavor"
			#endif

		#else
			#error "Unsupported OS"
		#endif
	#endif
#endif

#if defined(FACTOR_X86)
	#include "cpu-x86.32.hpp"
	#include "cpu-x86.hpp"
#elif defined(FACTOR_AMD64)
	#include "cpu-x86.64.hpp"
	#include "cpu-x86.hpp"
#elif defined(FACTOR_PPC)
	#include "cpu-ppc.hpp"
#elif defined(FACTOR_ARM)
	#include "cpu-arm.hpp"
#else
	#error "Unsupported CPU"
#endif
