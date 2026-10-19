// Independent glibc/architectural oracle for System z FPC control fields.
#define _GNU_SOURCE 1
#include <cassert>
#include <cfenv>
#include <cstdint>
#include <cstdio>
#include <cstring>

static std::uint32_t fpc() {
  std::uint32_t value;
  asm volatile("efpc %0" : "=d"(value));
  return value;
}
static void restore(std::uint32_t value) {
  asm volatile("sfpc %0" : : "d"(value));
}
static bool comparison_invalid(std::uint64_t bits, bool signaling) {
  double value;
  std::memcpy(&value, &bits, sizeof(value));
  const double finite = 1.0;
  feclearexcept(FE_ALL_EXCEPT);
  if (signaling) asm volatile("kdbr %0,%1" : : "f"(value), "f"(finite) : "cc");
  else asm volatile("cdbr %0,%1" : : "f"(value), "f"(finite) : "cc");
  return fetestexcept(FE_INVALID) != 0;
}
int main() {
  const auto original = fpc();
  restore(0);
  const int modes[] = {FE_TONEAREST, FE_TOWARDZERO, FE_UPWARD, FE_DOWNWARD};
  const unsigned architectural[] = {0, 1, 2, 3};
  for (unsigned i = 0; i < 4; ++i) {
    assert(fesetround(modes[i]) == 0);
    assert((fpc() & 3) == architectural[i]);
    assert(fegetround() == modes[i]);
  }
  assert(feraiseexcept(FE_ALL_EXCEPT) == 0);
  assert((fpc() & 0x00f80000u) == unsigned(FE_ALL_EXCEPT) << 16);
  assert(feclearexcept(FE_ALL_EXCEPT) == 0);
  assert((fpc() & 0x00f80000u) == 0);
  assert(feenableexcept(FE_DIVBYZERO) >= 0);
  assert((fpc() & 0xf8000000u) == unsigned(FE_DIVBYZERO) << 24);
  assert(fedisableexcept(FE_ALL_EXCEPT) >= 0);
  assert((fpc() & 0xf8000000u) == 0);
  assert(fesetround(FE_TONEAREST) == 0);
  volatile double tiny = 0x1p-1022;
  const double subnormal = tiny / 2.0;
  std::uint64_t bits;
  std::memcpy(&bits, &subnormal, sizeof(bits));
  assert(bits == UINT64_C(0x0008000000000000));
  assert(comparison_invalid(UINT64_C(0x7ff8000000000001), true));
  assert(!comparison_invalid(UINT64_C(0x7ff8000000000001), false));
  assert(comparison_invalid(UINT64_C(0x7ff0000000000001), true));
  assert(comparison_invalid(UINT64_C(0x7ff0000000000001), false));
  restore(original);
  std::puts("S390X-FPC-LIBC-ORACLE-PASS: rounding flags traps subnormals");
}
