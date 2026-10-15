#ifndef FACTOR_M68K_NATIVE_ABI_H
#define FACTOR_M68K_NATIVE_ABI_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
struct m68k_abi_record { uint8_t tag; uint32_t integer; double real; };
struct m68k_abi_record m68k_abi_roundtrip(struct m68k_abi_record value);
uint32_t m68k_abi_follow(struct m68k_abi_record value, uint32_t next);
uint64_t m68k_abi_u64(uint64_t value);
double m68k_abi_varargs(unsigned count, ...);
uint32_t m68k_abi_callback(uint32_t (*callback)(uint32_t, uint32_t));
#ifdef __cplusplus
}
#endif
#endif
