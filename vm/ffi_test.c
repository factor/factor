/* This file is linked into the runtime for the sole purpose
 * of testing FFI code. */
#include <stdio.h>
#include "master.h"
#include "ffi_test.h"

void ffi_test_0(void)
{
	printf("ffi_test_0()\n");
}

int ffi_test_1(void)
{
	printf("ffi_test_1()\n");
	return 3;
}

int ffi_test_2(int x, int y)
{
	printf("ffi_test_2(%d,%d)\n",x,y);
	return x + y;
}

int ffi_test_3(int x, int y, int z, int t)
{
	printf("ffi_test_3(%d,%d,%d,%d)\n",x,y,z,t);
	return x + y + z * t;
}

float ffi_test_4(void)
{
	printf("ffi_test_4()\n");
	return 1.5;
}

double ffi_test_5(void)
{
	printf("ffi_test_5()\n");
	return 1.5;
}

double ffi_test_6(float x, float y)
{
	printf("ffi_test_6(%f,%f)\n",x,y);
	return x * y;
}

double ffi_test_7(double x, double y)
{
	printf("ffi_test_7(%f,%f)\n",x,y);
	return x * y;
}

double ffi_test_8(double x, float y, double z, float t, int w)
{
	printf("ffi_test_8(%f,%f,%f,%f,%d)\n",x,y,z,t,w);
	return x * y + z * t + w;
}

int ffi_test_9(int a, int b, int c, int d, int e, int f, int g)
{
	printf("ffi_test_9(%d,%d,%d,%d,%d,%d,%d)\n",a,b,c,d,e,f,g);
	return a + b + c + d + e + f + g;
}

int ffi_test_10(int a, int b, double c, int d, float e, int f, int g, int h)
{
	printf("ffi_test_10(%d,%d,%f,%d,%f,%d,%d,%d)\n",a,b,c,d,e,f,g,h);
	return a - b - c - d - e - f - g - h;
}

int ffi_test_11(int a, struct foo b, int c)
{
	printf("ffi_test_11(%d,{%d,%d},%d)\n",a,b.x,b.y,c);
	return a * b.x + c * b.y;
}

int ffi_test_12(int a, int b, struct rect c, int d, int e, int f)
{
	printf("ffi_test_12(%d,%d,{%f,%f,%f,%f},%d,%d,%d)\n",a,b,c.x,c.y,c.w,c.h,d,e,f);
	return a + b + c.x + c.y + c.w + c.h + d + e + f;
}

int ffi_test_13(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k)
{
	printf("ffi_test_13(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)\n",a,b,c,d,e,f,g,h,i,j,k);
	return a + b + c + d + e + f + g + h + i + j + k;
}

struct foo ffi_test_14(int x, int y)
{
	struct foo r;
	printf("ffi_test_14(%d,%d)\n",x,y);
	r.x = x; r.y = y;
	return r;
}

char *ffi_test_15(char *x, char *y)
{
	if(strcmp(x,y))
		return "foo";
	else
		return "bar";
}

struct bar ffi_test_16(long x, long y, long z)
{
	struct bar r;
	r.x = x; r.y = y; r.z = z;
	return r;
}

struct tiny ffi_test_17(int x)
{
	struct tiny r;
	r.x = x;
	return r;
}

F_STDCALL int ffi_test_18(int x, int y, int z, int t)
{
	printf("ffi_test_18(%d,%d,%d,%d)\n",x,y,z,t);
	return x + y + z * t;
}

F_STDCALL struct bar ffi_test_19(long x, long y, long z)
{
	struct bar r;
	r.x = x; r.y = y; r.z = z;
	return r;
}

void ffi_test_20(double x1, double x2, double x3,
	double y1, double y2, double y3,
	double z1, double z2, double z3)
{
	printf("ffi_test_20(%f,%f,%f,%f,%f,%f,%f,%f,%f)\n",
		x1, x2, x3, y1, y2, y3, z1, z2, z3);
}

long long ffi_test_21(long x, long y)
{
	return (long long)x * (long long)y;
}

long ffi_test_22(long x, long long y, long long z)
{
	printf("ffi_test_22(%ld,%lld,%lld)\n",x,y,z);
	return x + y / z;
}

float ffi_test_23(float x[3], float y[3])
{
	return x[0] * y[0] + x[1] * y[1] + x[2] * y[2];
}

struct test_struct_1 ffi_test_24(void)
{
	struct test_struct_1 s;
	s.x = 1;
	return s;
}

struct test_struct_2 ffi_test_25(void)
{
	struct test_struct_2 s;
	s.x = 1;
	s.y = 2;
	return s;
}

struct test_struct_3 ffi_test_26(void)
{
	struct test_struct_3 s;
	s.x = 1;
	s.y = 2;
	s.z = 3;
	return s;
}

struct test_struct_4 ffi_test_27(void)
{
	struct test_struct_4 s;
	s.x = 1;
	s.y = 2;
	s.z = 3;
	s.a = 4;
	return s;
}

struct test_struct_5 ffi_test_28(void)
{
	struct test_struct_5 s;
	s.x = 1;
	s.y = 2;
	s.z = 3;
	s.a = 4;
	s.b = 5;
	return s;
}

struct test_struct_6 ffi_test_29(void)
{
	struct test_struct_6 s;
	s.x = 1;
	s.y = 2;
	s.z = 3;
	s.a = 4;
	s.b = 5;
	s.c = 6;
	return s;
}

struct test_struct_7 ffi_test_30(void)
{
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

void ffi_test_31(int x0, int x1, int x2, int x3, int x4, int x5, int x6, int x7, int x8, int x9, int x10, int x11, int x12, int x13, int x14, int x15, int x16, int x17, int x18, int x19, int x20, int x21, int x22, int x23, int x24, int x25, int x26, int x27, int x28, int x29, int x30, int x31, int x32, int x33, int x34, int x35, int x36, int x37, int x38, int x39, int x40, int x41) { }

double ffi_test_32(struct test_struct_8 x, int y)
{
	return (x.x + x.y) * y;
}

double ffi_test_33(struct test_struct_9 x, int y)
{
	return (x.x + x.y) * y;
}

double ffi_test_34(struct test_struct_10 x, int y)
{
	return (x.x + x.y) * y;
}

double ffi_test_35(struct test_struct_11 x, int y)
{
	return (x.x + x.y) * y;
}
