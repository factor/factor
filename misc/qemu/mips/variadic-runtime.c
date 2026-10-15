#include <stdarg.h>

/* Enough mixed arguments to cross the native argument-register boundary. */
double mips_invoke_variadic(double (*callback)(int, ...)) {
    return callback(7, 11, 2.5, 13, 17, 19, 23, 29, 31, 3.5);
}

static double invoke_list(double (*callback)(int, va_list), int tag, ...) {
    va_list args;
    va_start(args, tag);
    double value = callback(tag, args);
    va_end(args);
    return value;
}

double mips_invoke_list(double (*callback)(int, va_list)) {
    return invoke_list(callback, 7, 11, 2.5, 13);
}
