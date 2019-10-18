#if defined(FACTOR_X86) && !defined(STDCALL)
	#define STDCALL __attribute__((stdcall))
#elif !defined(STDCALL)
	#define STDCALL
#endif

DLLEXPORT void ffi_test_0(void);
DLLEXPORT int ffi_test_1(void);
DLLEXPORT int ffi_test_2(int x, int y);
DLLEXPORT int ffi_test_3(int x, int y, int z, int t);
DLLEXPORT float ffi_test_4(void);
DLLEXPORT double ffi_test_5(void);
DLLEXPORT double ffi_test_6(float x, float y);
DLLEXPORT double ffi_test_7(double x, double y);
DLLEXPORT double ffi_test_8(double x, float y, double z, float t, int w);
DLLEXPORT int ffi_test_9(int a, int b, int c, int d, int e, int f, int g);
DLLEXPORT int ffi_test_10(int a, int b, double c, int d, float e, int f, int g, int h);
struct foo { int x, y; };
DLLEXPORT int ffi_test_11(int a, struct foo b, int c);
struct rect { float x, y, w, h; };
DLLEXPORT int ffi_test_12(int a, int b, struct rect c, int d, int e, int f);
DLLEXPORT int ffi_test_13(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k);
DLLEXPORT struct foo ffi_test_14(int x, int y);
DLLEXPORT char *ffi_test_15(char *x, char *y);
struct bar { long x, y, z; };
DLLEXPORT struct bar ffi_test_16(long x, long y, long z);
struct tiny { int x; };
DLLEXPORT struct tiny ffi_test_17(int x);
DLLEXPORT STDCALL int ffi_test_18(int x, int y, int z, int t);
DLLEXPORT STDCALL struct bar ffi_test_19(long x, long y, long z);
DLLEXPORT void ffi_test_20(double x1, double x2, double x3,
	double y1, double y2, double y3,
	double z1, double z2, double z3);
