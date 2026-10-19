#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <type_traits>
#include <utility>
#if UINTPTR_MAX == UINT64_MAX
#define FACTOR_64
#endif
#include "../assert.hpp"
#include "../layouts.hpp"

template <typename T, typename = void> struct supports_add : std::false_type {};
template <typename T> struct supports_add<T, std::void_t<decltype(std::declval<T>() + std::declval<T>())>> : std::true_type {};

int main() {
  factor::boxed_float boxed;
  boxed.initialize(factor::FLOAT_TYPE);
  assert(sizeof(boxed) == 16);
  assert((unsigned char*)&boxed.n - (unsigned char*)&boxed == 8);
  const uint64_t values[] = {UINT64_C(0x3ff0000000000000),
                             UINT64_C(0x8000000000000000),
                             UINT64_C(0x7ff0000000000001), UINT64_C(1)};
  for (unsigned i = 0; i < sizeof(values) / sizeof(values[0]); ++i) {
    memcpy(static_cast<void*>(&boxed.n), &values[i], sizeof(boxed.n));
    unsigned char image[16];
    memcpy(image, &boxed, sizeof(image));
    factor::boxed_float restored;
    memcpy(static_cast<void*>(&restored), image, sizeof(image));
    uint64_t bits;
    memcpy(&bits, &restored.n, sizeof(bits));
    assert(bits == values[i]);
    assert(restored.type() == factor::FLOAT_TYPE);
  }
#if defined(FACTOR_INTEGER_ONLY)
  static_assert(!supports_add<factor::vm_float>::value,
                "integer-only payloads must reject arithmetic at compile time");
  static_assert(!std::is_convertible<factor::vm_float, double>::value,
                "integer-only payloads must reject native floating conversion");
  static_assert(!std::is_floating_point<factor::vm_float>::value,
                "integer-only floats must remain opaque integer payloads");
  assert(factor::vm_float_bits(factor::vm_float_from_bits(values[2])) == values[2]);
#elif defined(__vax__)
  boxed.n = factor::vm_float::from_signed(1);
  assert(boxed.n.bits() == values[0]);
  const double native = 1.0;
  assert(memcmp(&boxed.n, &native, sizeof(native)) != 0);
  assert(factor::vm_float_bits(factor::vm_float_from_signed(-17)) ==
         UINT64_C(0xc031000000000000));
  assert(factor::vm_float_to_signed(factor::vm_float_from_bits(UINT64_C(0x400e000000000000))) == 3);
  assert((factor::vm_float_from_signed(1) / factor::vm_float_from_signed(0)).is_infinite());
  assert(factor::vm_float_bits(factor::vm_float_from_bits(UINT64_C(0x7ff0000000000001))) ==
         UINT64_C(0x7ff0000000000001));
#else
  static_assert(std::is_same<factor::vm_float, double>::value,
                "Existing CPUs retain native double arithmetic");
#endif
  puts("boxed IEEE float storage/image layout passed");
}
