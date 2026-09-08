#include <stdio.h>
typedef unsigned long long (*uint_callback)(int,int,int,int,int,int,int,unsigned int);
unsigned long long ffi_uint_callback(uint_callback cb);
#ifndef ABI_CONTROL
unsigned long long ffi_uint_callback(uint_callback cb) {
    return cb(0,0,0,0,0,0,0,3000000000U);
}
#else
static unsigned long long identity(int a,int b,int c,int d,int e,int f,int g,unsigned int x) {
    (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g;
    return x;
}
int main(void) {
    unsigned long long result = ffi_uint_callback(identity);
    printf("uint-callback=%llu\n", result);
    return result != 3000000000ULL;
}
#endif
