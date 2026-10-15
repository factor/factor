/* Resolve C macros and platform-specific stdio objects through the C ABI. */
#if defined(__NetBSD__) && defined(__clang__)
#ifndef __WCHAR_MIN__
#define __WCHAR_MIN__ (-__WCHAR_MAX__ - 1)
#endif
#ifndef __WINT_MIN__
#ifdef __WINT_UNSIGNED__
#define __WINT_MIN__ 0U
#else
#define __WINT_MIN__ (-__WINT_MAX__ - 1)
#endif
#endif
#endif
#include <stdio.h>

FILE *factor_stdin(void) { return stdin; }
FILE *factor_stdout(void) { return stdout; }
FILE *factor_stderr(void) { return stderr; }

#ifndef _WIN32
#include <math.h>
#include <pthread.h>

/* Factor resolves these symbols through dlsym(NULL). Keep libm loaded even
 * when the VM itself would otherwise use only Zig's math implementations. */
double (*factor_math_pow_anchor)(double, double) = pow;

void factor_stdin_cancel_async(void) {
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
}
#endif

#include "netbsd-riscv-fma.h"
#if defined(__NetBSD__) && defined(__riscv) && __riscv_xlen == 64
void *factor_netbsd_missing_math_symbol(const char *name) {
    return factor_netbsd_math_symbol(name);
}
#endif
