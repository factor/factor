/* Independent C callers for Factor's ARM64 variadic FFI tests. */
#ifndef FACTOR_FFI_TEST_VARARGS_H
#define FACTOR_FFI_TEST_VARARGS_H
#include <stdarg.h>
#include <stdint.h>
#if defined(_WIN32)
#define VARARGS_EXPORT __declspec(dllexport)
#define VARARGS_NOINLINE __declspec(noinline)
#else
#define VARARGS_EXPORT __attribute__((visibility("default")))
#define VARARGS_NOINLINE __attribute__((noinline))
#endif
struct va_pair { float x, y; };
struct va_ints { int x, y; };
struct va_big { int64_t x, y, z; };
struct va_array { float values[3]; };
typedef int64_t (*va_int_callback)(int, ...);
typedef double (*va_mixed_callback)(int, double, ...);
typedef double (*va_spill_callback)(int,int,int,int,int,int,int,int,int,int,...);
typedef double (*va_aggregate_callback)(int,...);
typedef struct va_big (*va_big_callback)(int,...);
typedef struct va_pair (*va_pair_callback)(int,...);
typedef int64_t (*va_list_callback)(int,va_list);
typedef int (*va_format_callback)(const char*,va_list);
VARARGS_EXPORT int64_t va_call_ints(va_int_callback cb, int count);
VARARGS_EXPORT double va_call_mixed(va_mixed_callback cb);
VARARGS_EXPORT double va_call_named_spill(va_spill_callback cb);
VARARGS_EXPORT double va_call_aggregates(va_aggregate_callback cb);
VARARGS_EXPORT int64_t va_call_big_return(va_big_callback cb);
VARARGS_EXPORT double va_call_pair_return(va_pair_callback cb);
VARARGS_EXPORT int64_t va_call_list(va_list_callback cb, int count);
VARARGS_EXPORT int va_call_format_list(va_format_callback cb);
VARARGS_EXPORT int64_t va_sum_list(int count, va_list args);
VARARGS_EXPORT unsigned int va_c_controls(void);
#endif
