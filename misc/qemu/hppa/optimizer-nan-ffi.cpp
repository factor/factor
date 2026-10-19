#include <stdint.h>
#include <string.h>
#include <stdarg.h>
extern "C" {
double hppa_qdouble() { volatile double zero=0.0; return zero/zero; }
double hppa_sdouble() { uint64_t bits=0x7ff8000000001234ULL;double x;memcpy(&x,&bits,8);return x; }
float hppa_qfloat() { volatile float zero=0.0f;return zero/zero; }
float hppa_sfloat() { uint32_t bits=0x7fc01234U;float x;memcpy(&x,&bits,4);return x; }
uint64_t hppa_double_bits(double x) { uint64_t bits;memcpy(&bits,&x,8);return bits; }
uint32_t hppa_float_bits(float x) { uint32_t bits;memcpy(&bits,&x,4);return bits; }
uint64_t hppa_vararg_bits(int ignored,...) { (void)ignored;va_list args;va_start(args,ignored);double x=va_arg(args,double);va_end(args);return hppa_double_bits(x); }
double hppa_callback(double x,double(*callback)(double)) { return callback(x); }
}
