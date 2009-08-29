#include <stdbool.h>

#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
	#define F_STDCALL __attribute__((stdcall))
#else
	#define F_STDCALL
#endif

#if defined(__APPLE__)
	#define F_EXPORT __attribute__((visibility("default")))
#elif defined(WINDOWS)
	#define F_EXPORT __declspec(dllexport)
#else
	#define F_EXPORT
#endif

F_EXPORT void ffi_test_0(void);
F_EXPORT int ffi_test_1(void);
F_EXPORT int ffi_test_2(int x, int y);
F_EXPORT int ffi_test_3(int x, int y, int z, int t);
F_EXPORT float ffi_test_4(void);
F_EXPORT double ffi_test_5(void);
F_EXPORT double ffi_test_6(float x, float y);
F_EXPORT double ffi_test_7(double x, double y);
F_EXPORT double ffi_test_8(double x, float y, double z, float t, int w);
F_EXPORT int ffi_test_9(int a, int b, int c, int d, int e, int f, int g);
F_EXPORT int ffi_test_10(int a, int b, double c, int d, float e, int f, int g, int h);
struct foo { int x, y; };
F_EXPORT int ffi_test_11(int a, struct foo b, int c);
struct rect { float x, y, w, h; };
F_EXPORT int ffi_test_12(int a, int b, struct rect c, int d, int e, int f);
F_EXPORT int ffi_test_13(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k);
F_EXPORT struct foo ffi_test_14(int x, int y);
F_EXPORT char *ffi_test_15(char *x, char *y);
struct bar { long x, y, z; };
F_EXPORT struct bar ffi_test_16(long x, long y, long z);
struct tiny { int x; };
F_EXPORT struct tiny ffi_test_17(int x);
F_EXPORT F_STDCALL int ffi_test_18(int x, int y, int z, int t);
F_EXPORT F_STDCALL struct bar ffi_test_19(long x, long y, long z);
F_EXPORT void ffi_test_20(double x1, double x2, double x3,
	double y1, double y2, double y3,
	double z1, double z2, double z3);
F_EXPORT long long ffi_test_21(long x, long y);
F_EXPORT long ffi_test_22(long x, long long y, long long z);
F_EXPORT float ffi_test_23(float x[3], float y[3]);
struct test_struct_1 { char x; };
F_EXPORT struct test_struct_1 ffi_test_24(void);
struct test_struct_2 { char x, y; };
F_EXPORT struct test_struct_2 ffi_test_25(void);
struct test_struct_3 { char x, y, z; };
F_EXPORT struct test_struct_3 ffi_test_26(void);
struct test_struct_4 { char x, y, z, a; };
F_EXPORT struct test_struct_4 ffi_test_27(void);
struct test_struct_5 { char x, y, z, a, b; };
F_EXPORT struct test_struct_5 ffi_test_28(void);
struct test_struct_6 { char x, y, z, a, b, c; };
F_EXPORT struct test_struct_6 ffi_test_29(void);
struct test_struct_7 { char x, y, z, a, b, c, d; };
F_EXPORT struct test_struct_7 ffi_test_30(void);
F_EXPORT int ffi_test_31(int x0, int x1, int x2, int x3, int x4, int x5, int x6, int x7, int x8, int x9, int x10, int x11, int x12, int x13, int x14, int x15, int x16, int x17, int x18, int x19, int x20, int x21, int x22, int x23, int x24, int x25, int x26, int x27, int x28, int x29, int x30, int x31, int x32, int x33, int x34, int x35, int x36, int x37, int x38, int x39, int x40, int x41);
F_EXPORT float ffi_test_31_point_5(float x0, float x1, float x2, float x3, float x4, float x5, float x6, float x7, float x8, float x9, float x10, float x11, float x12, float x13, float x14, float x15, float x16, float x17, float x18, float x19, float x20, float x21, float x22, float x23, float x24, float x25, float x26, float x27, float x28, float x29, float x30, float x31, float x32, float x33, float x34, float x35, float x36, float x37, float x38, float x39, float x40, float x41);
struct test_struct_8 { double x; double y; };
F_EXPORT double ffi_test_32(struct test_struct_8 x, int y);
struct test_struct_9 { float x; float y; };
F_EXPORT double ffi_test_33(struct test_struct_9 x, int y);
struct test_struct_10 { float x; int y; };
F_EXPORT double ffi_test_34(struct test_struct_10 x, int y);
struct test_struct_11 { int x; int y; };
F_EXPORT double ffi_test_35(struct test_struct_11 x, int y);

struct test_struct_12 { int a; double x; };

F_EXPORT double ffi_test_36(struct test_struct_12 x);

F_EXPORT void ffi_test_36_point_5(void);

F_EXPORT int ffi_test_37(int (*f)(int, int, int));

F_EXPORT unsigned long long ffi_test_38(unsigned long long x, unsigned long long y);

struct test_struct_13 { float x1, x2, x3, x4, x5, x6; };

F_EXPORT int ffi_test_39(long a, long b, struct test_struct_13 s);

struct test_struct_14 { double x1, x2; };

F_EXPORT struct test_struct_14 ffi_test_40(double x1, double x2);

F_EXPORT struct test_struct_12 ffi_test_41(int a, double x);

struct test_struct_15 { float x, y; };

F_EXPORT struct test_struct_15 ffi_test_42(float x, float y);

struct test_struct_16 { float x; int a; };

F_EXPORT struct test_struct_16 ffi_test_43(float x, int a);

F_EXPORT struct test_struct_14 ffi_test_44();

F_EXPORT _Complex float ffi_test_45(int x);

F_EXPORT _Complex double ffi_test_46(int x);

F_EXPORT _Complex float ffi_test_47(_Complex float x, _Complex double y);

struct bool_field_test {
	char *name;
	bool on;
	short parents;
};

F_EXPORT short ffi_test_48(struct bool_field_test x);
