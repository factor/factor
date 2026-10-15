/* Separate shared object forces the native dynamic ABI boundary. */
double native_fp(double a, double b) { return a * 2.0 + b; }
unsigned native_callback(unsigned (*callback)(unsigned, unsigned)) {
    return callback(5, 7);
}

#include <stdarg.h>
#include "native-ffi.h"
struct native_record native_record_roundtrip(struct native_record value) {
    value.tag += 1;
    value.integer += UINT64_C(0x123456789);
    value.real *= 2.0;
    return value;
}
double native_varargs(unsigned count, ...) {
    va_list args;
    double sum=0.0;
    unsigned i;
    va_start(args,count);
    for (i=0;i<count;++i) sum+=va_arg(args,double);
    va_end(args);
    return sum;
}
