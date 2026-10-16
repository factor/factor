/* Independent C ABI oracles for the OpenRISC Factor backend. */
#if defined(__or1k__)

#include <stdarg.h>
#include <stdint.h>

#define OR1K_NOINLINE __attribute__((noinline))

struct or1k_abi_pair { uint32_t high, low; };
struct or1k_abi_triple { uint32_t first, second, third; };

OR1K_NOINLINE uint64_t or1k_abi_u64(uint32_t tag, uint64_t first,
                                    uint32_t tail, uint64_t second) {
  uint64_t words = ((uint64_t)tag << 32) | tail;
  return first ^ (second + words);
}

/* Only r8 remains when wide is assigned. Both words go on the stack. */
OR1K_NOINLINE uint64_t or1k_abi_stack_u64(
    uint32_t a0, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4,
    uint64_t wide, uint32_t tail) {
  uint32_t sum = a0 + a1 + a2 + a3 + a4;
  return wide ^ ((uint64_t)sum << 32 | tail);
}

/* Doubles use consecutive GPR words, with no even-register alignment. */
OR1K_NOINLINE double or1k_abi_doubles(uint32_t tag, double first,
                                     double second, uint32_t tail) {
  return (double)tag + first * 2.0 + second * 4.0 + (double)tail;
}

/* GCC passes every aggregate by reference, including this two-word value. */
OR1K_NOINLINE uint64_t or1k_abi_take_pair(struct or1k_abi_pair value,
                                         uint32_t tail) {
  return (((uint64_t)value.high << 32) | value.low) ^ tail;
}

/* Aggregate results, including two-word values, use a hidden result pointer. */
OR1K_NOINLINE struct or1k_abi_pair or1k_abi_return_pair(uint32_t high,
                                                       uint32_t low) {
  struct or1k_abi_pair result = { high ^ 0x13579bdfU, low ^ 0x2468ace0U };
  return result;
}

/* Larger results use a hidden result pointer; aggregate arguments are indirect. */
OR1K_NOINLINE struct or1k_abi_triple
or1k_abi_transform_triple(struct or1k_abi_triple value, uint32_t delta) {
  struct or1k_abi_triple result = {
    value.first + delta, value.second ^ delta, value.third - delta
  };
  return result;
}

/* Strict argument naming forces every unnamed argument to the stack. */
OR1K_NOINLINE double or1k_abi_varargs(uint32_t tag, double named, ...) {
  va_list arguments;
  va_start(arguments, named);
  uint32_t tail = va_arg(arguments, uint32_t);
  double floating = va_arg(arguments, double);
  uint64_t wide = va_arg(arguments, uint64_t);
  va_end(arguments);
  return tag + named * 2.0 + tail + floating * 4.0
      + (double)(uint32_t)(wide >> 32) + (double)(uint32_t)wide;
}

typedef uint64_t (*or1k_u64_callback)(uint32_t, uint64_t, uint32_t, uint64_t);
typedef uint64_t (*or1k_pair_callback)(struct or1k_abi_pair, uint32_t);
typedef struct or1k_abi_pair (*or1k_return_pair_callback)(uint32_t, uint32_t);
typedef struct or1k_abi_triple (*or1k_triple_callback)(struct or1k_abi_triple,
                                                       uint32_t);

OR1K_NOINLINE uint64_t or1k_abi_call_u64(or1k_u64_callback callback) {
  return callback(0x10203040U, UINT64_C(0x1122334455667788), 0xa0b0c0d0U,
                  UINT64_C(0xfedcba9876543210));
}

OR1K_NOINLINE uint64_t or1k_abi_call_pair(or1k_pair_callback callback) {
  struct or1k_abi_pair value = { 0x12345678U, 0x9abcdef0U };
  return callback(value, 0x55aa55aaU);
}

OR1K_NOINLINE uint64_t
or1k_abi_call_return_pair(or1k_return_pair_callback callback) {
  struct or1k_abi_pair value = callback(0x12345678U, 0x9abcdef0U);
  return ((uint64_t)value.high << 32) | value.low;
}

OR1K_NOINLINE uint64_t or1k_abi_call_triple(or1k_triple_callback callback) {
  struct or1k_abi_triple input = { 10, 20, 30 };
  struct or1k_abi_triple value = callback(input, 7);
  return ((uint64_t)value.first << 32) ^ ((uint64_t)value.second << 16)
      ^ value.third;
}

#ifdef FACTOR_OPENRISC_ABI_CONTROL_MAIN
int main(void) {
  struct or1k_abi_pair pair = { 0x12345678U, 0x9abcdef0U };
  struct or1k_abi_pair returned = or1k_abi_return_pair(0x12345678U,
                                                       0x9abcdef0U);
  struct or1k_abi_triple triple = { 10, 20, 30 };
  struct or1k_abi_triple transformed = or1k_abi_transform_triple(triple, 7);
  if (or1k_abi_u64(0x10203040U, UINT64_C(0x1122334455667788), 0xa0b0c0d0U,
                   UINT64_C(0xfedcba9876543210)) !=
      UINT64_C(0x1fded99d42628568)) return 1;
  if (or1k_abi_stack_u64(1, 2, 4, 8, 16, UINT64_C(0x89abcdef01234567),
                         0x55aa55aaU) != UINT64_C(0x89abcdf0548910cd)) return 2;
  if (or1k_abi_doubles(3, 1.25, -2.5, 11) != 6.5) return 3;
  if (or1k_abi_take_pair(pair, 0x55aa55aaU) !=
      UINT64_C(0x12345678cf168b5a)) return 4;
  if (returned.high != 0x0163cda7U || returned.low != 0xbed47210U) return 5;
  if (transformed.first != 17 || transformed.second != 19 ||
      transformed.third != 23) return 6;
  if (or1k_abi_varargs(3, 1.25, 11U, -2.5,
                       UINT64_C(0x0000000500000007)) != 18.5) return 7;
  return 0;
}
#endif

#endif
