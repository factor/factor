/* Independent C compiler oracle for overlapping homogeneous union members. */
#ifdef UNION_ORACLE
typedef __builtin_va_list au_va_list;
#define au_va_start __builtin_va_start
#define au_va_arg __builtin_va_arg
#define au_va_end __builtin_va_end
#else
#include <stdarg.h>
typedef va_list au_va_list;
#define au_va_start va_start
#define au_va_arg va_arg
#define au_va_end va_end
#endif
#if defined(_WIN32)
#define UNION_EXPORT __declspec(dllexport)
#define UNION_NOINLINE __declspec(noinline)
#define UNION_ALIGN(n) __declspec(align(n))
#else
#define UNION_EXPORT __attribute__((visibility("default")))
#define UNION_NOINLINE __attribute__((noinline))
#define UNION_ALIGN(n) __attribute__((aligned(n)))
#endif

union au_one { float a; float b; };
struct au_pair { float a, b; };
union au_two { float a; struct au_pair pair; };
struct au_quad { float a, b, c, d; };
union au_four { struct au_quad quad; float a; };
struct au_nested { union au_one first; float second; };
union au_mixed { float a; double b; };
struct au_padded { float a; UNION_ALIGN(8) float b; };
union au_padded_union { struct au_padded padded; float a[4]; };

UNION_EXPORT UNION_NOINLINE double au_take_one(union au_one v, double tail) { return v.a + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_two(union au_two v, double tail) { return v.pair.a + 2*v.pair.b + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_four(union au_four v, double tail) { return v.quad.a + 2*v.quad.b + 3*v.quad.c + 4*v.quad.d + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_nested(struct au_nested v, double tail) { return v.first.a + 2*v.second + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_mixed(union au_mixed v, double tail) { return v.b + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_padded(struct au_padded v, double tail) { return v.a + 2*v.b + tail; }
UNION_EXPORT UNION_NOINLINE double au_take_padded_union(union au_padded_union v, double tail) { return v.padded.a + 2*v.padded.b + tail; }
UNION_EXPORT UNION_NOINLINE union au_one au_return_one(float a) { union au_one v; v.a=a; return v; }
UNION_EXPORT UNION_NOINLINE union au_two au_return_two(float a, float b) { union au_two v; v.pair.a=a; v.pair.b=b; return v; }
UNION_EXPORT UNION_NOINLINE union au_four au_return_four(float a, float b, float c, float d) { union au_four v; v.quad.a=a; v.quad.b=b; v.quad.c=c; v.quad.d=d; return v; }
UNION_EXPORT UNION_NOINLINE double au_call_one(double (*cb)(union au_one,double)) { union au_one v; v.a=1.25f; return cb(v,10); }
UNION_EXPORT UNION_NOINLINE double au_call_two(double (*cb)(union au_two,double)) { union au_two v; v.pair.a=1.25f; v.pair.b=2.5f; return cb(v,10); }
UNION_EXPORT UNION_NOINLINE double au_call_four(double (*cb)(union au_four,double)) { union au_four v; v.quad.a=1; v.quad.b=2; v.quad.c=3; v.quad.d=4; return cb(v,10); }
UNION_EXPORT UNION_NOINLINE double au_variadic(int marker, ...) {
    au_va_list args;
    au_va_start(args, marker);
    union au_two v=au_va_arg(args,union au_two);
    double tail=au_va_arg(args,double);
    au_va_end(args);
    return marker+v.pair.a+2*v.pair.b+tail;
}
UNION_EXPORT UNION_NOINLINE double au_call_variadic(double (*cb)(int,...)) {
    union au_two v; v.pair.a=1.25f; v.pair.b=2.5f;
    return cb(7,v,10.0);
}

#if defined(__clang__) || defined(__GNUC__)
typedef float au_fvec __attribute__((vector_size(16)));
typedef int au_ivec __attribute__((vector_size(16)));
union au_vector { au_fvec a; au_ivec b; };
struct au_fvec_pair { au_fvec a,b; };
struct au_ivec_pair { au_ivec a,b; };
/* GCC 15 can eliminate the va_arg copy for overlapping vector members under
   strict aliasing. This annotation affects alias analysis, not the ABI layout. */
#if defined(__GNUC__) && !defined(__clang__)
#define UNION_VECTOR_ALIAS __attribute__((__may_alias__))
#else
#define UNION_VECTOR_ALIAS
#endif
union au_vector_two { struct au_fvec_pair a; struct au_ivec_pair b; } UNION_VECTOR_ALIAS;
UNION_EXPORT UNION_NOINLINE double au_take_vector_two(union au_vector_two v,double tail) { return v.a.a[0]+v.a.a[1]+v.a.a[2]+v.a.a[3]+v.a.b[0]+v.a.b[1]+v.a.b[2]+v.a.b[3]+tail; }
UNION_EXPORT UNION_NOINLINE union au_vector_two au_return_vector_two(void) { union au_vector_two v; v.a.a=(au_fvec){1,2,3,4}; v.a.b=(au_fvec){5,6,7,8}; return v; }
UNION_EXPORT UNION_NOINLINE double au_call_vector_variadic(double (*cb)(int,...)) { union au_vector_two v=au_return_vector_two(); return cb(7,v,10.0); }
static UNION_NOINLINE double au_vector_variadic_control(int marker,...) {
    au_va_list args;
    au_va_start(args,marker);
    union au_vector_two v=au_va_arg(args,union au_vector_two);
    double tail=au_va_arg(args,double);
    au_va_end(args);
    return marker+au_take_vector_two(v,tail);
}


UNION_EXPORT UNION_NOINLINE double au_take_vector(union au_vector v, double tail) { return v.a[0]+2*v.a[1]+3*v.a[2]+4*v.a[3]+tail; }
UNION_EXPORT UNION_NOINLINE union au_vector au_return_vector(float a,float b,float c,float d) { union au_vector v; v.a=(au_fvec){a,b,c,d}; return v; }
UNION_EXPORT UNION_NOINLINE double au_call_vector(double (*cb)(union au_vector,double)) { union au_vector v; v.a=(au_fvec){1,2,3,4}; return cb(v,10); }
#endif
UNION_EXPORT UNION_NOINLINE struct au_padded au_return_padded(float a,float b) { struct au_padded v; v.a=a; v.b=b; return v; }
UNION_EXPORT UNION_NOINLINE double au_call_padded(double (*cb)(struct au_padded,double)) { struct au_padded v; v.a=1.25f; v.b=2.5f; return cb(v,10); }
UNION_EXPORT UNION_NOINLINE double au_take_spill(double a,double b,double c,double d,double e,double f,union au_two v,double tail) { return a+b+c+d+e+f+v.pair.a+2*v.pair.b+tail; }
UNION_EXPORT UNION_NOINLINE double au_call_spill(double (*cb)(double,double,double,double,double,double,union au_two,double)) { union au_two v; v.pair.a=1.25f; v.pair.b=2.5f; return cb(1,2,3,4,5,6,v,10); }
UNION_EXPORT int au_vector_available(void) {
#if defined(__clang__) || defined(__GNUC__)
    return 1;
#else
    return 0;
#endif
}
#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
UNION_EXPORT int au_small_controls(void);
#endif
UNION_EXPORT int au_c_controls(void) {
    union au_one one; one.a=1.25f;
    union au_two two; two.pair.a=1.25f; two.pair.b=2.5f;
    union au_four four; four.quad.a=1; four.quad.b=2; four.quad.c=3; four.quad.d=4;
    struct au_nested nested; nested.first=one; nested.second=2.5f;
    union au_mixed mixed; mixed.b=3.75;
    struct au_padded padded; padded.a=1.25f; padded.b=2.5f;
    union au_padded_union padded_union; padded_union.padded=padded;
    if (au_take_one(one,10)!=11.25 || au_take_two(two,10)!=16.25 || au_take_four(four,10)!=40 || au_take_nested(nested,10)!=16.25 || au_take_mixed(mixed,10)!=13.75) return 0;
    if (au_return_one(1.25f).a!=1.25f || au_return_two(1.25f,2.5f).pair.b!=2.5f || au_return_four(1,2,3,4).quad.d!=4) return 0;
    if (au_call_one(au_take_one)!=11.25 || au_call_two(au_take_two)!=16.25 || au_call_four(au_take_four)!=40) return 0;
    if (au_variadic(7,two,10.0)!=23.25 || au_call_variadic(au_variadic)!=23.25) return 0;
    if (au_take_padded(padded,10)!=16.25 || au_take_padded_union(padded_union,10)!=16.25 || au_return_padded(1.25f,2.5f).b!=2.5f || au_call_padded(au_take_padded)!=16.25) return 0;
    if (au_take_spill(1,2,3,4,5,6,two,10)!=37.25 || au_call_spill(au_take_spill)!=37.25) return 0;
#if defined(__clang__) || defined(__GNUC__)
    union au_vector vector; vector.a=(au_fvec){1,2,3,4};
    if (au_take_vector_two(au_return_vector_two(),10)!=46 || au_call_vector_variadic(au_vector_variadic_control)!=53) return 0;
    if (au_take_vector(vector,10)!=40 || au_return_vector(1,2,3,4).a[3]!=4 || au_call_vector(au_take_vector)!=40) return 0;
#endif
#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
    if (!au_small_controls()) return 0;
#endif
    return 1;
}
#ifdef UNION_CONTROL_MAIN
#include <stdio.h>
int main(void) {
    int ok=au_c_controls();
    printf("C ARM64 union/padding controls: %s; vector=%d\n",ok ? "PASS" : "FAIL",au_vector_available());
    return !ok;
}
#endif

/* Half and BF16 use one fundamental ABI type, but the register carrier must
   still be a concrete 16-bit representation, not the representation union. */
#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
union au_small { _Float16 a; __bf16 b; };
union au_bsmall { __bf16 a; _Float16 b; };
struct au_small_pair { union au_small first; union au_bsmall second; };
UNION_EXPORT int au_small_available(void) { return 1; }
UNION_EXPORT UNION_NOINLINE double au_take_small(union au_small v,double tail) { return (double)v.a+tail; }
UNION_EXPORT UNION_NOINLINE double au_take_bsmall(union au_bsmall v,double tail) { return (double)v.a+tail; }
UNION_EXPORT UNION_NOINLINE union au_small au_return_small(float v) { union au_small r; r.a=(_Float16)v; return r; }
UNION_EXPORT UNION_NOINLINE union au_bsmall au_return_bsmall(float v) { union au_bsmall r; r.a=(__bf16)v; return r; }
UNION_EXPORT UNION_NOINLINE double au_take_small_pair(struct au_small_pair v,double tail) { return (double)v.first.a+2*(double)v.second.a+tail; }
UNION_EXPORT UNION_NOINLINE double au_call_small_pair(double (*cb)(struct au_small_pair,double)) { struct au_small_pair v; v.first.a=(_Float16)1.25f; v.second.a=(__bf16)2.5f; return cb(v,10); }
UNION_EXPORT UNION_NOINLINE double au_call_small_variadic(double (*cb)(int,...)) { struct au_small_pair v; v.first.a=(_Float16)1.25f; v.second.a=(__bf16)2.5f; return cb(7,v,10.0); }
static UNION_NOINLINE double au_small_variadic_control(int marker,...) {
    au_va_list args;
    au_va_start(args,marker);
    struct au_small_pair v=au_va_arg(args,struct au_small_pair);
    double tail=au_va_arg(args,double);
    au_va_end(args);
    return marker+au_take_small_pair(v,tail);
}
UNION_EXPORT int au_small_controls(void) {
    union au_small h=au_return_small(1.25f);
    union au_bsmall b=au_return_bsmall(2.5f);
    if ((float)h.a!=1.25f || (float)b.a!=2.5f) return 0;
    return au_take_small(h,10)==11.25 && au_take_bsmall(b,10)==12.5 &&
        au_call_small_pair(au_take_small_pair)==16.25 &&
        au_call_small_variadic(au_small_variadic_control)==23.25;
}
#else
UNION_EXPORT int au_small_available(void) { return 0; }
#endif
