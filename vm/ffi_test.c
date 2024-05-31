#include "ffi_test.h"

#include <assert.h>
#include <stdarg.h>
#include <string.h>

void ffi_test_0(void) {}

int ffi_test_1(void) { return 3; }

int ffi_test_2(int x, int y) { return x + y; }

int ffi_test_3(int x, int y, int z, int t) { return x + y + z * t; }

float ffi_test_4(void) { return 1.5; }

double ffi_test_5(void) { return 1.5; }

double ffi_test_6(float x, float y) { return x * y; }

double ffi_test_7(double x, double y) { return x * y; }

double ffi_test_8(double x, float y, double z, float t, int w) {
  return x * y + z * t + w;
}

int ffi_test_9(int a, int b, int c, int d, int e, int f, int g) {
  return a + b + c + d + e + f + g;
}

int ffi_test_10(int a, int b, double c, int d, float e, int f, int g, int h) {
  return (int)(a - b - c - d - e - f - g - h);
}

int ffi_test_11(int a, struct foo b, int c) { return a * b.x + c * b.y; }

int ffi_test_12(int a, int b, struct rect c, int d, int e, int f) {
  return (int)(a + b + c.x + c.y + c.w + c.h + d + e + f);
}

int ffi_test_13(int a, int b, int c, int d, int e, int f, int g, int h, int i,
                int j, int k) {
  return a + b + c + d + e + f + g + h + i + j + k;
}

struct foo ffi_test_14(int x, int y) {
  struct foo r;
  r.x = x;
  r.y = y;
  return r;
}

char* ffi_test_15(char* x, char* y) {
  if (strcmp(x, y))
    return "foo";
  else
    return "bar";
}

struct bar ffi_test_16(long x, long y, long z) {
  struct bar r;
  r.x = x;
  r.y = y;
  r.z = z;
  return r;
}

struct tiny ffi_test_17(int x) {
  struct tiny r;
  r.x = x;
  return r;
}

FACTOR_STDCALL(int) ffi_test_18(int x, int y, int z, int t) {
  return x + y + z * t;
}

FACTOR_STDCALL(struct bar) ffi_test_19(long x, long y, long z) {
  struct bar r;
  r.x = x;
  r.y = y;
  r.z = z;
  return r;
}

void ffi_test_20(double x1, double x2, double x3, double y1, double y2,
                 double y3, double z1, double z2, double z3) {
  (void) x1, (void) x2, (void) x3, (void) y1, (void) y2,
  (void) y3, (void) z1, (void) z2, (void) z3;
}

long long ffi_test_21(long x, long y) { return (long long) x * (long long) y; }

long ffi_test_22(long x, long long y, long long z) { return (long)(x + y / z); }

float ffi_test_23(float x[3], float y[3]) {
  return x[0] * y[0] + x[1] * y[1] + x[2] * y[2];
}

struct test_struct_1 ffi_test_24(void) {
  struct test_struct_1 s;
  s.x = 1;
  return s;
}

struct test_struct_2 ffi_test_25(void) {
  struct test_struct_2 s;
  s.x = 1;
  s.y = 2;
  return s;
}

struct test_struct_3 ffi_test_26(void) {
  struct test_struct_3 s;
  s.x = 1;
  s.y = 2;
  s.z = 3;
  return s;
}

struct test_struct_4 ffi_test_27(void) {
  struct test_struct_4 s;
  s.x = 1;
  s.y = 2;
  s.z = 3;
  s.a = 4;
  return s;
}

struct test_struct_5 ffi_test_28(void) {
  struct test_struct_5 s;
  s.x = 1;
  s.y = 2;
  s.z = 3;
  s.a = 4;
  s.b = 5;
  return s;
}

struct test_struct_6 ffi_test_29(void) {
  struct test_struct_6 s;
  s.x = 1;
  s.y = 2;
  s.z = 3;
  s.a = 4;
  s.b = 5;
  s.c = 6;
  return s;
}

struct test_struct_7 ffi_test_30(void) {
  struct test_struct_7 s;
  s.x = 1;
  s.y = 2;
  s.z = 3;
  s.a = 4;
  s.b = 5;
  s.c = 6;
  s.d = 7;
  return s;
}

int ffi_test_31(int x0, int x1, int x2, int x3, int x4, int x5, int x6, int x7,
                int x8, int x9, int x10, int x11, int x12, int x13, int x14,
                int x15, int x16, int x17, int x18, int x19, int x20, int x21,
                int x22, int x23, int x24, int x25, int x26, int x27, int x28,
                int x29, int x30, int x31, int x32, int x33, int x34, int x35,
                int x36, int x37, int x38, int x39, int x40, int x41) {
  return x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 +
         x13 + x14 + x15 + x16 + x17 + x18 + x19 + x20 + x21 + x22 + x23 + x24 +
         x25 + x26 + x27 + x28 + x29 + x30 + x31 + x32 + x33 + x34 + x35 + x36 +
         x37 + x38 + x39 + x40 + x41;
}

float ffi_test_31_point_5(float x0, float x1, float x2, float x3, float x4,
                          float x5, float x6, float x7, float x8, float x9,
                          float x10, float x11, float x12, float x13, float x14,
                          float x15, float x16, float x17, float x18, float x19,
                          float x20, float x21, float x22, float x23, float x24,
                          float x25, float x26, float x27, float x28, float x29,
                          float x30, float x31, float x32, float x33, float x34,
                          float x35, float x36, float x37, float x38, float x39,
                          float x40, float x41) {
  return x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 +
         x13 + x14 + x15 + x16 + x17 + x18 + x19 + x20 + x21 + x22 + x23 + x24 +
         x25 + x26 + x27 + x28 + x29 + x30 + x31 + x32 + x33 + x34 + x35 + x36 +
         x37 + x38 + x39 + x40 + x41;
}

double ffi_test_32(struct test_struct_8 x, int y) { return (x.x + x.y) * y; }

double ffi_test_33(struct test_struct_9 x, int y) { return (x.x + x.y) * y; }

double ffi_test_34(struct test_struct_10 x, int y) { return (x.x + x.y) * y; }

double ffi_test_35(struct test_struct_11 x, int y) { return (x.x + x.y) * y; }

double ffi_test_36(struct test_struct_12 x) { return x.x; }

static int global_var;

void ffi_test_36_point_5(void) { global_var = 0; }

int ffi_test_37(int (*f)(int, int, int)) {
  global_var = f(global_var, global_var * 2, global_var * 3);
  return global_var;
}

unsigned long long ffi_test_38(unsigned long long x, unsigned long long y) {
  return x * y;
}

int ffi_test_39(long a, long b, struct test_struct_13 s) {
  assert(a == b);
  return (int)(s.x1 + s.x2 + s.x3 + s.x4 + s.x5 + s.x6);
}

struct test_struct_14 ffi_test_40(double x1, double x2) {
  struct test_struct_14 retval;
  retval.x1 = x1;
  retval.x2 = x2;
  return retval;
}

struct test_struct_12 ffi_test_41(int a, double x) {
  struct test_struct_12 retval;
  retval.a = a;
  retval.x = x;
  return retval;
}

struct test_struct_15 ffi_test_42(float x, float y) {
  struct test_struct_15 retval;
  retval.x = x;
  retval.y = y;
  return retval;
}

struct test_struct_16 ffi_test_43(float x, int a) {
  struct test_struct_16 retval;
  retval.x = x;
  retval.a = a;
  return retval;
}

struct test_struct_14 ffi_test_44(void) {
  struct test_struct_14 retval;
  retval.x1 = 1.0;
  retval.x2 = 2.0;
  return retval;
}

/* C99 features */
#ifndef _MSC_VER

_Complex float ffi_test_45(int x) { return x; }

_Complex double ffi_test_46(int x) { return x; }

_Complex float ffi_test_47(_Complex float x, _Complex double y) {
  return x + 2 * y;
}

short ffi_test_48(struct bool_field_test x) { return x.parents; }

#endif

FACTOR_FASTCALL(int) ffi_test_49(int x) { return x + 1; }

FACTOR_FASTCALL(int) ffi_test_50(int x, int y) { return x + y + 1; }

FACTOR_FASTCALL(int) ffi_test_51(int x, int y, int z) { return x + y + z + 1; }

FACTOR_FASTCALL(int) ffi_test_52(int x, float y, int z) {
  return (int)(x + y + z + 1);
}

FACTOR_FASTCALL(int) ffi_test_53(int x, float y, int z, int w) {
  return (int)(x + y + z + w + 1);
}

FACTOR_FASTCALL(int) ffi_test_54(struct test_struct_11 x, int y) {
  return x.x + x.y + y + 1;
}

FACTOR_FASTCALL(int) ffi_test_55(struct test_struct_11 x, int y, int z) {
  return x.x + x.y + y + z + 1;
}

FACTOR_FASTCALL(int) ffi_test_56(struct test_struct_11 x, int y, int z, int w) {
  return x.x + x.y + y + z + w + 1;
}

FACTOR_FASTCALL(struct test_struct_11) ffi_test_57(int x, int y) {
  struct test_struct_11 r = { x + y, x - y };
  return r;
}

FACTOR_FASTCALL(struct test_struct_11) ffi_test_58(int x, int y, int z) {
  struct test_struct_11 r = { x + y, y - z };
  return r;
}

signed long long ffi_test_59(signed long long x) {
  return x;
}

unsigned long long ffi_test_60(unsigned long long x) {
  return x;
}

/* C99 features */
#ifndef _MSC_VER

struct bool_and_ptr ffi_test_61(void) {
  struct bool_and_ptr bap;
  bap.b = true;
  bap.ptr = NULL;
  return bap;
}

#endif

struct uint_pair ffi_test_62(void) {
  struct uint_pair uip;
  uip.a = 0xabcdefab;
  uip.b = 0x12345678;
  return uip;
}

struct ulonglong_pair ffi_test_63(void) {
  struct ulonglong_pair ullp;
  ullp.a = 0xabcdefabcdefabcd;
  ullp.b = 0x1234567891234567;
  return ullp;
}

int ffi_test_64(int n, ...) {
    va_list ap;
    va_start(ap, n);
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += va_arg(ap, int);
    }
    va_end(ap);
    return sum;
}

double ffi_test_65(int n, ...) {
    va_list ap;
    va_start(ap, n);
    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        sum += va_arg(ap, double);
    }
    va_end(ap);
    return sum;
}

unsigned long ffi_test_66(unsigned long a, unsigned long b, unsigned long c,
                          struct test_struct_66 d, struct test_struct_66 e) {
    unsigned long x;
    x = a + b + c + d.mem1 + d.mem2 + e.mem1 + e.mem2;
    return x;
}

unsigned long ffi_test_67(unsigned long a, unsigned long b, unsigned long c,
                          struct test_struct_66 d, struct test_struct_66 e,
                          unsigned long f) {
    unsigned long x;
    x = a + b + c + d.mem1 + d.mem2 + e.mem1 + e.mem2 + f*2;
    return x;
}

unsigned long ffi_test_68(unsigned long a, unsigned long b, unsigned long c,
                          struct test_struct_66 d, struct test_struct_68 e, struct test_struct_66 f) {
    unsigned long x;
    x = a + b + c + d.mem1 + d.mem2 + e.mem1 + e.mem2 + e.mem3 + f.mem1 + f.mem2;
    return x;
}

unsigned long ffi_test_69(unsigned long a, unsigned long b, unsigned long c,
                          struct test_struct_66 d, struct test_struct_69 e, struct test_struct_66 f) {
    unsigned long x;
    x = a + b + c + d.mem1 + d.mem2 + (long)e.mem1 + e.mem2 + e.mem3 + f.mem1 + f.mem2;
    return x;
}

unsigned long ffi_test_70(struct test_struct_68 a, struct test_struct_68 b, struct test_struct_66 c) {
    unsigned long x;
    x = a.mem1 + a.mem2 + a.mem3 + b.mem1 + b.mem2 + b.mem3 + c.mem1 + c.mem2;
    return x;
}


void* bug1021_test_1(void* x, int y) {
  return (void*)(y * y + (size_t)x);
}

int bug1021_test_2(int x, char *y, void *z) {
  (void) x;
  (void) z;
  return y[0];
}

void* bug1021_test_3(int x) {
  return (void*)(size_t)((long)x);
}
