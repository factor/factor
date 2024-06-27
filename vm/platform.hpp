#if defined(WINDOWS)
  #if defined(WINNT)
    #include "os-windows.hpp"
    #if defined(FACTOR_AMD64)
      #include "os-windows.64.hpp"
    #elif defined(FACTOR_X86)
      #include "os-windows.32.hpp"
    #else
      #error "Unsupported Windows flavor"
    #endif
  #else
    #error "Unsupported Windows flavor"
  #endif
#else
  #include "os-unix.hpp"

  #ifdef __APPLE__
    #include "os-macos.hpp"
    #include "mach_signal.hpp"

    #ifdef FACTOR_X86
      #include "os-macos-x86.32.hpp"
    #elif defined(FACTOR_AMD64)
      #include "os-macos-x86.64.hpp"
    #elif defined(FACTOR_ARM64)
      #include "os-macos-arm64.hpp"
    #else
      #error "Unsupported Mac OS X flavor"
    #endif
  #else
    #include "os-genunix.hpp"
    #if defined(__FreeBSD__)
	#define FACTOR_OS_STRING "freebsd"
	#include "os-freebsd.hpp"
        #if defined(FACTOR_X86)
	    #include "os-freebsd-x86.32.hpp"
        #elif defined(FACTOR_AMD64)
	    #include "os-freebsd-x86.64.hpp"
        #else
            #error "Unsupported FreeBSD flavor"
        #endif
    #elif defined(__linux__)
      #define FACTOR_OS_STRING "linux"
      #include "os-linux.hpp"
      #if defined(FACTOR_X86)
        #include "os-linux-x86.32.hpp"
      #elif defined(FACTOR_PPC64)
        #include "os-linux-ppc.64.hpp"
      #elif defined(FACTOR_PPC32)
        #include "os-linux-ppc.32.hpp"
      #elif defined(FACTOR_ARM)
        #include "os-linux-arm.hpp"
      #elif defined(FACTOR_ARM64)
        #include "os-linux-arm.64.hpp"
      #elif defined(FACTOR_AMD64)
        #include "os-linux-x86.64.hpp"
      #else
        #error "Unsupported Linux flavor"
      #endif
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
#elif defined(FACTOR_ARM64)
  #include "cpu-arm.64.hpp"
  #include "cpu-arm.hpp"
#else
  #error "Unsupported CPU"
#endif
