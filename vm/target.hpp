// Compiler target detection. Keep this header usable from C and assembly.
#pragma once

// Detect target CPU type
#if defined(__alpha__)
#define FACTOR_ALPHA
#define FACTOR_64
#elif defined(__hppa__)
#if __SIZEOF_POINTER__ != 4
#error "HPPA64 userspace requires a separately validated Factor ABI"
#endif
#define FACTOR_HPPA
#elif defined(__sh__)
#define FACTOR_SH
#elif defined(__m68k__)
#define FACTOR_M68K
#elif defined(__mips__)
#define FACTOR_MIPS
#if __SIZEOF_POINTER__ == 8
#define FACTOR_MIPS64
#define FACTOR_64
#elif defined(_MIPS_SIM) && _MIPS_SIM == 1
#define FACTOR_MIPS32
#else
#error "MIPS N32 ABI requires a separate validated Factor port"
#endif
#elif defined(__arm__)
#define FACTOR_ARM32
#elif defined(__aarch64__) || defined(_M_ARM64)
#define FACTOR_ARM64
#define FACTOR_64
#elif defined(__sparc__)
#define FACTOR_SPARC
#if defined(__arch64__)
#define FACTOR_SPARC64
#define FACTOR_64
#else
#define FACTOR_SPARC32
#endif
#elif defined(__riscv) && __riscv_xlen == 32
#define FACTOR_RISCV32
#elif defined(__riscv) && __riscv_xlen == 64
#define FACTOR_RISCV64
#define FACTOR_64
#elif defined(__loongarch64)
#define FACTOR_LOONGARCH64
#define FACTOR_64
#elif defined(__m88k__)
#define FACTOR_M88K
#elif defined(__s390x__)
#define FACTOR_S390X
#define FACTOR_64
#elif defined(__amd64__) || defined(__x86_64__) || defined(_M_AMD64)
#define FACTOR_AMD64
#define FACTOR_64
#elif defined(i386) || defined(__i386) || defined(__i386__) || defined(_M_IX86)
#define FACTOR_X86
#elif(defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)) && \
    (defined(__PPC64__) || defined(__64BIT__))
#define FACTOR_PPC64
#define FACTOR_PPC
#define FACTOR_64
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
#define FACTOR_PPC32
#define FACTOR_PPC
#else
#error "Unsupported architecture"
#endif

// PA-RISC and classic hardware-FPU SuperH use the inverse IEEE NaN quiet bit.
#if !defined(FACTOR_INTEGER_ONLY) && \
    (defined(FACTOR_HPPA) || (defined(FACTOR_SH) && defined(__SH_FPU_ANY__)))
#define FACTOR_INVERSE_NAN_ENCODING
#endif

// Live frames store a predecessor at the frame top and a return address at
// FRAME_RETURN_ADDRESS. SPARC register windows use separate traversal rules.
#if defined(FACTOR_HPPA) || defined(FACTOR_ALPHA) || defined(FACTOR_ARM64) || \
    defined(FACTOR_RISCV64) || defined(FACTOR_LOONGARCH64) || \
    defined(FACTOR_RISCV32) || defined(FACTOR_S390X) || defined(FACTOR_MIPS) || \
    defined(FACTOR_ARM32) || defined(FACTOR_PPC) || defined(FACTOR_M88K) || \
    defined(FACTOR_SH)
#define FACTOR_LINKED_FRAMES
#endif

#if defined(_MSC_VER) || defined (__MINGW32__)
#define WINDOWS
#define WINNT
#elif defined(WIN32)
#define WINDOWS
#endif

#if defined(__ANDROID__)
#define FACTOR_ANDROID
#endif
