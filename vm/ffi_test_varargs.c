#include "ffi_test_varargs.h"
#include <stdio.h>
#include <string.h>

/* UCRT defines these functions inline in stdio.h; their addresses still
 * provide real CRT entry points without requiring legacy export symbols. */
typedef int (*va_printf_function)(const char*,...);
typedef int (*va_snprintf_function)(char*,size_t,const char*,...);
typedef int (*va_vsnprintf_function)(char*,size_t,const char*,va_list);
VARARGS_EXPORT va_printf_function va_printf_pointer(void) { return printf; }
VARARGS_EXPORT va_snprintf_function va_snprintf_pointer(void) { return snprintf; }
VARARGS_EXPORT va_vsnprintf_function va_vsnprintf_pointer(void) { return vsnprintf; }

/* Deliberately use ordinary C calls and va_arg, never hand-coded ABI offsets. */
VARARGS_NOINLINE int64_t va_call_ints(va_int_callback cb, int count) {
    if (count == 0) return cb(0);
    return cb(count, -1, 2, -3, 4, -5, 6, -7, 8, -9, 10, -11, 12);
}
VARARGS_NOINLINE double va_call_mixed(va_mixed_callback cb) {
    return cb(17, 0.25, 1, 0.5, 2, 1.5, 3, 2.5, 4, 3.5, 5, 4.5,
              6, 5.5, 7, 6.5, 8, 7.5, 9, 8.5, 10, 9.5);
}
VARARGS_NOINLINE double va_call_named_spill(va_spill_callback cb) {
    return cb(1,2,3,4,5,6,7,8,9,10, -11, 12.5, (int64_t)-13, 14);
}
VARARGS_NOINLINE double va_call_aggregates(va_aggregate_callback cb) {
    struct va_pair p = { 1.25f, -2.5f };
    struct va_ints i = { -3, 4 };
    struct va_big b = { 5, -6, 7 };
    struct va_array a = { { 8.5f, -9.25f, 10.0f } };
    return cb(11, p, i, b, a, (int64_t)-12);
}
typedef double (*va_hfa_spill_callback)(double,double,double,double,double,double,double,int,...);
VARARGS_EXPORT VARARGS_NOINLINE double va_call_hfa_spill(va_hfa_spill_callback cb) {
    struct va_pair p={8,9};
    struct va_array a={{11,12,13}};
    return cb(1,2,3,4,5,6,7,0,p,10.0,a,14);
}
static VARARGS_NOINLINE double va_control_hfa_spill(double a,double b,double c,double d,double e,double f,double g,int tag,...) {
    struct va_pair p;
    struct va_array array;
    double value;
    int integer;
    va_list args;
    va_start(args,tag);
    p=va_arg(args,struct va_pair); value=va_arg(args,double);
    array=va_arg(args,struct va_array); integer=va_arg(args,int);
    va_end(args);
    return a+b+c+d+e+f+g+tag+p.x+2*p.y+3*value+
           4*array.values[0]+5*array.values[1]+6*array.values[2]+7*integer;
}
VARARGS_EXPORT int va_hfa_spill_control(void) {
    return va_call_hfa_spill(va_control_hfa_spill)==364.0;
}
VARARGS_NOINLINE int64_t va_call_big_return(va_big_callback cb) {
    struct va_big b = cb(3, (int64_t)-1234567890123LL, (int64_t)4567890123456LL,
                         (int64_t)-7890123456789LL);
    return b.x + 2*b.y + 3*b.z;
}
VARARGS_NOINLINE double va_call_pair_return(va_pair_callback cb) {
    struct va_pair p = cb(2, 1.25, -2.5);
    return p.x + 2*p.y;
}
int64_t va_sum_list(int count, va_list args) {
    int64_t result = 0;
    int i;
    for (i=0; i<count; ++i) result += (i+1)*(int64_t)va_arg(args,int);
    return result;
}
static int64_t va_dispatch_list(va_list_callback cb, int count, ...) {
    int64_t result;
    va_list args;
    va_start(args,count);
    result = cb(count,args);
    va_end(args);
    return result;
}
VARARGS_NOINLINE int64_t va_call_list(va_list_callback cb, int count) {
    if (count == 0) return va_dispatch_list(cb,0);
    return va_dispatch_list(cb,count,-1,2,-3,4,-5,6,-7,8,-9,10,-11,12);
}
static int va_dispatch_format(va_format_callback cb, const char *format, ...) {
    int result;
    va_list args;
    va_start(args,format);
    result = cb(format,args);
    va_end(args);
    return result;
}
VARARGS_NOINLINE int va_call_format_list(va_format_callback cb) {
    return va_dispatch_format(cb,"%s:%d:%.*f:%lld", "value", -42, 3, 1.25,
                              (long long)-1234567890123LL);
}
static VARARGS_NOINLINE int64_t va_control_ints(int count, ...) {
    int64_t result;
    va_list args;
    va_start(args,count);
    result = va_sum_list(count,args);
    va_end(args);
    return result;
}
static VARARGS_NOINLINE double va_control_mixed(int tag, double named, ...) {
    double result = tag + named;
    int n;
    va_list args;
    va_start(args,named);
    for (n=1;n<=10;++n) {
        result += n*va_arg(args,int);
        result += (n+10)*va_arg(args,double);
    }
    va_end(args);
    return result;
}
static VARARGS_NOINLINE double va_control_spill(int a,int b,int c,int d,int e,int f,int g,int h,int i,int j,...) {
    double result = a+b+c+d+e+f+g+h+i+j;
    va_list args;
    va_start(args,j);
    result += va_arg(args,int);
    result += 2*va_arg(args,double);
    result += 3*va_arg(args,int64_t);
    result += 4*va_arg(args,int);
    va_end(args);
    return result;
}
static VARARGS_NOINLINE double va_control_aggregates(int tag,...) {
    struct va_pair p;
    struct va_ints i;
    struct va_big b;
    struct va_array a;
    int64_t sentinel;
    va_list args;
    va_start(args,tag);
    p=va_arg(args,struct va_pair); i=va_arg(args,struct va_ints);
    b=va_arg(args,struct va_big); a=va_arg(args,struct va_array);
    sentinel=va_arg(args,int64_t);
    va_end(args);
    return tag+p.x+2*p.y+3*i.x+4*i.y+5*b.x+6*b.y+7*b.z+
           8*a.values[0]+9*a.values[1]+10*a.values[2]+11*sentinel;
}
static VARARGS_NOINLINE struct va_big va_control_big(int count,...) {
    struct va_big result;
    va_list args;
    (void)count;
    va_start(args,count);
    result.x=va_arg(args,int64_t); result.y=va_arg(args,int64_t); result.z=va_arg(args,int64_t);
    va_end(args);
    return result;
}
static VARARGS_NOINLINE struct va_pair va_control_pair(int count,...) {
    struct va_pair result;
    va_list args;
    (void)count;
    va_start(args,count);
    result.x=(float)va_arg(args,double); result.y=(float)va_arg(args,double);
    va_end(args);
    return result;
}
static VARARGS_NOINLINE int va_control_format(const char *format, va_list args) {
    char output[128];
    int result=vsnprintf(output,sizeof(output),format,args);
    return result == 30 && strcmp(output,"value:-42:1.250:-1234567890123")==0;
}
unsigned int va_c_controls(void) {
    unsigned int ok=0;
    if (va_call_ints(va_control_ints,0)==0 && va_call_ints(va_control_ints,12)==78) ok|=1;
    if (va_call_mixed(va_control_mixed)==1259.75) ok|=2;
    if (va_call_named_spill(va_control_spill)==86.0) ok|=4;
    if (va_call_aggregates(va_control_aggregates)==5.0) ok|=8;
    if (va_call_big_return(va_control_big)==-15769158013578LL) ok|=16;
    if (va_call_pair_return(va_control_pair)==-3.75) ok|=32;
    if (va_call_list(va_sum_list,12)==78) ok|=64;
    if (va_call_format_list(va_control_format)==1) ok|=128;
    return ok;
}
VARARGS_EXPORT int va_small_available(void);
#if (defined(__aarch64__) || defined(_M_ARM64)) && defined(__clang__) && __clang_major__ >= 18
int va_small_available(void) { return 1; }
typedef double (*va_small_callback)(_Float16,__bf16,int,...);
typedef _Float16 (*va_half_result_callback)(int,...);
VARARGS_EXPORT VARARGS_NOINLINE double va_call_small(va_small_callback cb) {
    return cb((_Float16)1.5,(__bf16)-2.5,3,
              (_Float16)1,(__bf16)2,(_Float16)3,(__bf16)4,(_Float16)5,
              (__bf16)6,(_Float16)7,(__bf16)8,(_Float16)9,(__bf16)10);
}
VARARGS_EXPORT VARARGS_NOINLINE double va_call_small_return(va_half_result_callback cb) {
    return (double)cb(2,(_Float16)1.5,(__bf16)2.25);
}
static VARARGS_NOINLINE double va_control_small(_Float16 h,__bf16 b,int tag,...) {
    double result=(double)h+2*(double)b+tag;
    int i;
    va_list args;
    va_start(args,tag);
    for (i=1;i<=10;i+=2) {
        result += i*(double)va_arg(args,_Float16);
        result += (i+1)*(double)va_arg(args,__bf16);
    }
    va_end(args);
    return result;
}
static VARARGS_NOINLINE _Float16 va_control_small_return(int count,...) {
    _Float16 h;
    __bf16 b;
    va_list args;
    va_start(args,count);
    h=va_arg(args,_Float16); b=va_arg(args,__bf16);
    va_end(args);
    return (_Float16)(h+b);
}
VARARGS_EXPORT int va_small_controls(void) {
    return va_call_small(va_control_small)==384.5 &&
           va_call_small_return(va_control_small_return)==3.75;
}
#else
int va_small_available(void) { return 0; }
#endif
#ifdef FACTOR_VARARGS_CONTROL_MAIN
int main(void) {
    unsigned int mask=va_c_controls();
    if (!va_hfa_spill_control()) { puts("C HFA spill control: FAIL"); return 1; }
    puts("C HFA spill control: PASS");
    printf("C variadic ABI controls: 0x%02x / 0xff\n",mask);
    if (va_small_available()) {
#if (defined(__aarch64__) || defined(_M_ARM64)) && defined(__clang__) && __clang_major__ >= 18
        int small=va_small_controls();
        printf("C half/BF16 variadic controls: %s\n",small ? "PASS" : "FAIL");
        if (!small) return 1;
#endif
    } else printf("C half/BF16 variadic controls: unavailable compiler\n");
    return mask==255 ? 0 : 1;
}
#endif
