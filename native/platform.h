#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
    #define FACTOR_X86
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
    #define FACTOR_PPC
#endif
