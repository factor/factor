#ifndef FACTOR_FFI_TEST_ARM64_H
#define FACTOR_FFI_TEST_ARM64_H
typedef double (*cb_narrow)(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, signed char a8, unsigned char a9, short a10, unsigned short a11, int a12, unsigned int a13, long long a14);
typedef double (*cb_floats)(float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10);
typedef double (*cb_mixed)(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, float a8, float a9, float a10, float a11, float a12, float a13, float a14, float a15, signed char a16, float a17, short a18, double a19, int a20);
struct pair { float x, y; };
struct ints { int x,y; };
typedef double (*struct_cb)(long long,long long,long long,long long,long long,long long,long long,long long,signed char,struct ints,signed char);
typedef double (*hfa_cb)(float,float,float,float,float,float,float,struct pair,float);
struct array_hfa { float values[3]; };
typedef struct array_hfa (*array_cb)(struct array_hfa);
struct longs { long long x,y; };
typedef double (*int_cb)(long long,long long,long long,long long,long long,long long,long long,struct longs,long long);
double abi_narrow(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, signed char a8, unsigned char a9, short a10, unsigned short a11, int a12, unsigned int a13, long long a14);
double call_narrow(cb_narrow f);
double abi_floats(float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10);
double call_floats(cb_floats f);
double abi_mixed(long long a0, long long a1, long long a2, long long a3, long long a4, long long a5, long long a6, long long a7, float a8, float a9, float a10, float a11, float a12, float a13, float a14, float a15, signed char a16, float a17, short a18, double a19, int a20);
double call_mixed(cb_mixed f);
double abi_var(int tag, double named, ...);
double abi_var_spill(int a,int b,int c,int d,int e,int f,int g,int h,int i,int j,...);
double abi_var_hfa(struct pair named, ...);
double abi_struct(long long a,long long b,long long c,long long d,long long e,long long f,long long g,long long h,signed char i,struct ints j,signed char k);
double call_struct(struct_cb f);
double abi_hfa_boundary(float a,float b,float c,float d,float e,float f,float g,struct pair h,float i);
double call_hfa_boundary(hfa_cb f);
struct array_hfa abi_array_hfa(struct array_hfa p);
double call_array_hfa(array_cb f);
double abi_var_array(int named,...);
double abi_int_boundary(long long a,long long b,long long c,long long d,long long e,long long f,long long g,struct longs h,long long i);
double call_int_boundary(int_cb f);
double abi_hfa_stack(long long a,long long b,long long c,long long d,long long e,long long f,long long g,long long h,float a0,float a1,float a2,float a3,float a4,float a5,float a6,float a7,signed char i,struct pair j,float k);
int abi_call_int(int (*cb)(int), int x);
int abi_pointer_gc(void (*cb)(unsigned char *));
#endif
