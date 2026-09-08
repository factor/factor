/* Portable C ABI oracle; register poisoning is AArch64-only. */
#include <stdarg.h>
#include <stddef.h>
#include "ffi_test_arm64.h"
double abi_narrow(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, signed char a8, unsigned char a9, short a10, unsigned short a11, int a12, unsigned int a13, long long a14) { return (double)a0 * 1 + (double)a1 * 2 + (double)a2 * 3 + (double)a3 * 4 + (double)a4 * 5 + (double)a5 * 6 + (double)a6 * 7 + (double)a7 * 8 + (double)a8 * 9 + (double)a9 * 10 + (double)a10 * 11 + (double)a11 * 12 + (double)a12 * 13 + (double)a13 * 14 + (double)a14 * 15; }
double call_narrow(cb_narrow f) { return f(1, 2, 3, 4, 5, 6, 7, 8, -9, 250, -300, 60000, -70000, 3000000000, -123456789); }
double abi_floats(float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10) { return (double)a0 * 1 + (double)a1 * 2 + (double)a2 * 3 + (double)a3 * 4 + (double)a4 * 5 + (double)a5 * 6 + (double)a6 * 7 + (double)a7 * 8 + (double)a8 * 9 + (double)a9 * 10 + (double)a10 * 11; }
double call_floats(cb_floats f) { return f(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0); }
double abi_mixed(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, float a8, float a9, float a10, float a11, float a12, float a13, float a14, float a15, signed char a16, float a17, short a18, double a19, int a20) { return (double)a0 * 1 + (double)a1 * 2 + (double)a2 * 3 + (double)a3 * 4 + (double)a4 * 5 + (double)a5 * 6 + (double)a6 * 7 + (double)a7 * 8 + (double)a8 * 9 + (double)a9 * 10 + (double)a10 * 11 + (double)a11 * 12 + (double)a12 * 13 + (double)a13 * 14 + (double)a14 * 15 + (double)a15 * 16 + (double)a16 * 17 + (double)a17 * 18 + (double)a18 * 19 + (double)a19 * 20 + (double)a20 * 21; }
double call_mixed(cb_mixed f) { return f(1, 2, 3, 4, 5, 6, 7, 8, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, -9, 9.5, -1000, 10.25, -123456); }
double abi_var(int tag, double named, ...) { va_list ap; va_start(ap,named); int a=va_arg(ap,int); double b=va_arg(ap,double); long long d=va_arg(ap,long long); int e=va_arg(ap,int); va_end(ap); return tag+2*named+3*a+4*b+5*d+6*e; }
double abi_var_spill(int a,int b,int c,int d,int e,int f,int g,int h,int i,int j,...) { va_list ap; va_start(ap,j); int k=va_arg(ap,int); double l=va_arg(ap,double); va_end(ap); return a+2*b+3*c+4*d+5*e+6*f+7*g+8*h+9*i+10*j+11*k+12*l; }
double abi_var_hfa(struct pair named, ...) {
    va_list ap; va_start(ap,named);
    struct pair p=va_arg(ap,struct pair); int i=va_arg(ap,int);
    va_end(ap); return named.x+2*named.y+3*p.x+4*p.y+5*i;
}
double abi_struct(long long a,long long b,long long c,long long d,long long e,long long f,long long g,long long h,signed char i,struct ints j,signed char k) { return a+b+c+d+e+f+g+h+i+j.x+2*j.y+k; }
double call_struct(struct_cb f) { return f(1,2,3,4,5,6,7,8,-9,(struct ints){10,11},-12); }
double abi_hfa_boundary(float a,float b,float c,float d,float e,float f,float g,struct pair h,float i) { return a+b+c+d+e+f+g+h.x+2*h.y+i; }
double call_hfa_boundary(hfa_cb f) {
#if defined(__aarch64__)
    __asm__ volatile("fmov s7, wzr" ::: "v7");
#endif
    return f(1,2,3,4,5,6,7,(struct pair){8,9},10); }
struct array_hfa abi_array_hfa(struct array_hfa p) {
    p.values[0] += 10; p.values[1] += 20; p.values[2] += 30; return p;
}
double call_array_hfa(array_cb f) { struct array_hfa p=f((struct array_hfa){{1,2,3}}); return p.values[0]+2*p.values[1]+3*p.values[2]; }
double abi_var_array(int named,...) { va_list ap; va_start(ap,named); struct array_hfa p=va_arg(ap,struct array_hfa); double d=va_arg(ap,double); va_end(ap); return named+p.values[0]+2*p.values[1]+3*p.values[2]+d; }
double abi_int_boundary(long long a,long long b,long long c,long long d,long long e,long long f,long long g,struct longs h,long long i) { return a+b+c+d+e+f+g+h.x+2*h.y+i; }
double call_int_boundary(int_cb f) {
#if defined(__aarch64__)
    __asm__ volatile("mov x7, xzr" ::: "x7");
#endif
    return f(1,2,3,4,5,6,7,(struct longs){8,9},10);
}
double abi_hfa_stack(long long a,long long b,long long c,long long d,long long e,long long f,long long g,long long h,float a0,float a1,float a2,float a3,float a4,float a5,float a6,float a7,signed char i,struct pair j,float k) { return a+b+c+d+e+f+g+h+a0+a1+a2+a3+a4+a5+a6+a7+i+j.x+2*j.y+k; }

int abi_call_int(int (*cb)(int), int x) { return cb(x); }
int abi_pointer_gc(void (*cb)(unsigned char *)) {
    unsigned char bytes[32];
    for (int i=0; i<32; ++i) bytes[i] = 0x5a;
    cb(bytes);
    if (bytes[0] != 0xa5) return 0;
    for (int i=1; i<32; ++i) if (bytes[i] != 0x5a) return 0;
    return 1;
}
