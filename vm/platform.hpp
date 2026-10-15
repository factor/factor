#include "hppa.hpp"
#include "sh.hpp"
#include "riscv.hpp"
#include "s390x.hpp"
#include "m68k.hpp"
#include "sparc.hpp"
#include "m88k.hpp"
#if defined(WINDOWS)
  #if defined(WINNT)
    #include "os-windows.hpp"
    #if defined(FACTOR_AMD64)
      #include "os-windows-x86.64.hpp"
    #elif defined(FACTOR_X86)
      #include "os-windows-x86.32.hpp"
    #elif defined(FACTOR_ARM64)
      #include "os-windows-arm.64.hpp"
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
      #include "os-macos-arm.64.hpp"
    #else
      #error "Unsupported macOS flavor"
    #endif
  #else
    #include "os-genunix.hpp"
    #if defined(__DragonFly__)
      #define FACTOR_OS_STRING "dragonflybsd"
      #include "os-freebsd.hpp"
      #if defined(FACTOR_AMD64)
        #include "os-dragonfly-x86.64.hpp"
      #else
        #error "Unsupported DragonFly architecture"
      #endif
    #elif defined(__FreeBSD__)
      #define FACTOR_OS_STRING "freebsd"
      #include "os-freebsd.hpp"
      #if defined(FACTOR_X86)
	      #include "os-freebsd-x86.32.hpp"
      #elif defined(FACTOR_AMD64)
	      #include "os-freebsd-x86.64.hpp"
      #elif defined(FACTOR_ARM32)
        #include "os-freebsd-arm.32.hpp"
      #elif defined(FACTOR_ARM64)
          #include "os-freebsd-arm.64.hpp"
      #elif defined(FACTOR_RISCV64)
        #include "os-freebsd-riscv.64.hpp"
      #elif defined(FACTOR_PPC)
        #include "os-freebsd-ppc.hpp"
      #else
        #error "Unsupported FreeBSD flavor"
      #endif
    #elif defined(__NetBSD__)
      #define FACTOR_OS_STRING "netbsd"
      #if defined(FACTOR_ALPHA)
        #include "os-netbsd-alpha.hpp"
      #elif defined(FACTOR_HPPA)
        #include "os-netbsd-hppa.hpp"
      #elif defined(FACTOR_SH)
        #include "os-netbsd-sh.hpp"
      #elif defined(FACTOR_M68K)
        #include "os-netbsd-m68k.hpp"
      #elif defined(FACTOR_MIPS)
        #include "os-netbsd-mips.hpp"
      #elif defined(FACTOR_RISCV64)
        #include "os-netbsd-riscv.64.hpp"
      #elif defined(FACTOR_SPARC)
        #include "os-netbsd-sparc.hpp"
      #elif defined(FACTOR_PPC32)
        #include "os-netbsd-ppc.32.hpp"
      #else
        #include "os-netbsd.hpp"
      #endif
    #elif defined(__OpenBSD__)
      #define FACTOR_OS_STRING "openbsd"
      #include "os-openbsd.hpp"
      #if defined(FACTOR_MIPS64)
        #include "os-openbsd-mips64.hpp"
      #elif defined(FACTOR_ALPHA)
        #include "os-openbsd-alpha.hpp"
      #elif defined(FACTOR_X86)
        #include "os-openbsd-x86.32.hpp"
      #elif defined(FACTOR_AMD64)
        #include "os-openbsd-x86.64.hpp"
      #elif defined(FACTOR_ARM32)
        #include "os-openbsd-arm.32.hpp"
      #elif defined(FACTOR_ARM64)
        #include "os-openbsd-arm.64.hpp"
      #elif defined(FACTOR_RISCV64)
        #include "os-openbsd-riscv.64.hpp"
      #elif defined(FACTOR_HPPA)
        #include "os-openbsd-hppa.hpp"
      #elif defined(FACTOR_M88K)
        #include "os-openbsd-m88k.hpp"
      #elif defined(FACTOR_SPARC64)
        #include "os-openbsd-sparc.hpp"
      #elif defined(FACTOR_PPC32)
        #include "os-openbsd-ppc.32.hpp"
      #elif defined(FACTOR_PPC64)
        #include "os-openbsd-ppc.64.hpp"
      #else
        #error "Unsupported OpenBSD flavor"
      #endif
    #elif defined(__HAIKU__)
      #define FACTOR_OS_STRING "haiku"
      #include "os-haiku.hpp"
      #if defined(FACTOR_AMD64)
        #include "os-haiku-x86.64.hpp"
      #else
        #error "Unsupported Haiku architecture"
      #endif
    #elif defined(__linux__)
      #define FACTOR_OS_STRING "linux"
      #include "os-linux.hpp"
      #if defined(FACTOR_ALPHA)
        #include "os-linux-alpha.hpp"
      #elif defined(FACTOR_HPPA)
        #include "os-linux-hppa.hpp"
      #elif defined(FACTOR_SH)
        #include "os-linux-sh.hpp"
      #elif defined(FACTOR_M68K)
        #include "os-linux-m68k.hpp"
      #elif defined(FACTOR_MIPS)
        #include "os-linux-mips.hpp"
      #elif defined(FACTOR_X86)
        #include "os-linux-x86.32.hpp"
      #elif defined(FACTOR_PPC64)
        #include "os-linux-ppc.64.hpp"
      #elif defined(FACTOR_PPC32)
        #include "os-linux-ppc.32.hpp"
      #elif defined(FACTOR_ARM32)
        #include "os-linux-arm.32.hpp"
      #elif defined(FACTOR_ARM64)
        #include "os-linux-arm.64.hpp"
      #elif defined(FACTOR_SPARC)
        #include "os-linux-sparc.hpp"
      #elif defined(FACTOR_RISCV32)
        #include "os-linux-riscv.32.hpp"
      #elif defined(FACTOR_RISCV64)
        #include "os-linux-riscv.64.hpp"
      #elif defined(FACTOR_LOONGARCH64)
        #include "os-linux-loongarch.64.hpp"
      #elif defined(FACTOR_S390X)
        #include "os-linux-s390x.hpp"
      #elif defined(FACTOR_AMD64)
        #include "os-linux-x86.64.hpp"
      #else
        #error "Unsupported Linux flavor"
      #endif
    #endif
  #endif
#endif

#if defined(FACTOR_ALPHA)
  #include "cpu-alpha.hpp"
#elif defined(FACTOR_HPPA)
  #include "cpu-hppa.hpp"
#elif defined(FACTOR_SH)
  #include "cpu-sh.hpp"
#elif defined(FACTOR_M68K)
  #include "cpu-m68k.hpp"
#elif defined(FACTOR_MIPS)
  #include "cpu-mips.hpp"
#elif defined(FACTOR_X86)
  #include "cpu-x86.32.hpp"
  #include "cpu-x86.hpp"
#elif defined(FACTOR_AMD64)
  #include "cpu-x86.64.hpp"
  #include "cpu-x86.hpp"
#elif defined(FACTOR_PPC)
  #include "cpu-ppc.hpp"
#elif defined(FACTOR_ARM32)
  #include "cpu-arm.32.hpp"
#elif defined(FACTOR_ARM64)
  #include "cpu-arm.64.hpp"
#elif defined(FACTOR_SPARC)
  #include "cpu-sparc.hpp"
#elif defined(FACTOR_RISCV32)
  #include "cpu-riscv.32.hpp"
#elif defined(FACTOR_RISCV64)
  #include "cpu-riscv.64.hpp"
#elif defined(FACTOR_LOONGARCH64)
  #include "cpu-loongarch.64.hpp"
#elif defined(FACTOR_S390X)
  #include "cpu-s390x.hpp"
#elif defined(FACTOR_M88K)
  #include "cpu-m88k.hpp"
#else
  #error "Unsupported CPU"
#endif
