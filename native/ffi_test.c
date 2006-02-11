/* This file is linked into the runtime for the sole purpose
 * of testing FFI code. */
#include <stdio.h>

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

struct foo { int x, y; };

int ffi_test_11(int a, struct foo b, int c)
{
	printf("ffi_test_11(%d,{%d,%d},%d)\n",a,b.x,b.y,c);
	return a * b.x + c * b.y;
}

struct rect { float x, y, w, h; };

int ffi_test_12(int a, int b, struct rect c, int d, int e, int f)
{
	printf("ffi_test_12(%d,%d,{%f,%f,%f,%f},%d,%d,%d)\n",a,b,c.x,c.y,c.w,c.h,d,e,f);
	return a + b + c.x + c.y + c.w + c.h + d + e + f;
}

void callback_test_1(void (*callback)())
{
	printf("callback_test_1 entry");
	callback();
	printf("callback_test_1 leaving");
}
