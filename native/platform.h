#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
	#define FACTOR_X86
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
	#define FACTOR_PPC
#endif

#ifdef __APPLE__
	/* Horray for Mach-O */
	#define MANGLE(sym) _##sym
#else
	#define MANGLE(sym) sym
#endif

#if defined(FACTOR_X86)
	#define FACTOR_CPU_STRING "x86"
#elif defined(FACTOR_PPC)
	#define FACTOR_CPU_STRING "ppc"
#else
	#define FACTOR_CPU_STRING "unknown"
#endif

#ifdef WIN32
	#define FACTOR_OS_STRING "win32"
#elif defined(__FreeBSD__)
	#define FACTOR_OS_STRING "freebsd"
#elif defined(linux)
	#define FACTOR_OS_STRING "linux"
#elif defined(__APPLE__)
	#define FACTOR_OS_STRING "macosx"
#else
	#define FACTOR_OS_STRING "unix"
#endif

#if defined(WIN32)
	#define DLLEXPORT __declspec(dllexport)
    #define SETJMP setjmp
    #define LONGJMP longjmp
    #define JMP_BUF jmp_buf
#else
	#define DLLEXPORT
    #define SETJMP(jmpbuf) sigsetjmp(jmpbuf,1)
    #define LONGJMP siglongjmp
    #define JMP_BUF sigjmp_buf
#endif

#define INLINE inline static
