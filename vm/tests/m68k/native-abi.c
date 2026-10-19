#include "native-abi.h"
#include <stdarg.h>
struct m68k_abi_record m68k_abi_roundtrip(struct m68k_abi_record value) {
    value.tag += 1;
    value.integer += 7;
    value.real *= 2.0;
    return value;
}
uint32_t m68k_abi_follow(struct m68k_abi_record value, uint32_t next) {
    return value.integer + next;
}
uint64_t m68k_abi_u64(uint64_t value) { return value + UINT64_C(0x123456789); }
double m68k_abi_varargs(unsigned count, ...) {
    va_list arguments;
    va_start(arguments, count);
    double sum = 0;
    while (count--) sum += va_arg(arguments, double);
    va_end(arguments);
    return sum;
}
uint32_t m68k_abi_callback(uint32_t (*callback)(uint32_t, uint32_t)) {
    return callback(5, 7);
}
