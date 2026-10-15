#include "../ieee_float.hpp"
#include "../ieee_binary64.hpp"
#include <assert.h>
#include <stdio.h>
#include <initializer_list>
using namespace factor::fp;
constexpr rounding_mode rn = rounding_mode::nearest_even;
template<class F> void expect(result<F> r, typename F::storage_type bits, exception_flags flags = 0) {
  assert(r.value.bits == bits); assert(r.raised == flags);
}
template<class F> void cases() {
  using U = typename F::storage_type;
  F zero{0}, nz{F::sign_mask}, one{U(F::bias) << F::fraction_bits};
  F two{U(F::bias + 1) << F::fraction_bits}, inf{F::exponent_mask};
  F max{F::exponent_mask - 1}, tiny{1}, normal{U(1) << F::fraction_bits};
  F q1{F::exponent_mask | F::quiet_mask | 1}, q2{F::exponent_mask | F::quiet_mask | 2};
  F s1{F::exponent_mask | 1}, s2{F::exponent_mask | 2};
  U bad = F::sign_mask | F::exponent_mask | F::quiet_mask;
  for (unsigned m = 0; m < 5; ++m) {
    auto mode = rounding_mode(m);
    expect(add(one, one, mode), two.bits);
    expect(multiply(tiny, two, mode), U(2));
    expect(divide(normal, two, mode), normal.bits / 2);
    expect(add(nz, nz, mode), nz.bits);
    expect(subtract(one, one, mode), mode == rounding_mode::downward ? nz.bits : U(0));
    expect(factor::fp::sqrt(nz, mode), nz.bits);
    expect(factor::fp::sqrt(inf, mode), inf.bits);
    expect(factor::fp::sqrt(negate(one), mode), bad, invalid);
    expect(divide(one, zero, mode), inf.bits, divide_by_zero);
    expect(divide(inf, zero, mode), inf.bits);
    expect(divide(zero, zero, mode), bad, invalid);
    expect(multiply(zero, inf, mode), bad, invalid);
    expect(add(inf, negate(inf), mode), bad, invalid);
    expect(add(q1, s2, mode), q1.bits, invalid);
    expect(add(s2, q1, mode), q1.bits, invalid);
    expect(add(q1, q2, mode), q2.bits);
    expect(add(s1, s2, mode), q2.bits, invalid);
    expect(add(negate(q1), q1, mode), q1.bits);
    expect(subtract(one, negate(q2), mode), negate(q2).bits);
    expect(factor::fp::sqrt(s1, mode), q1.bits, invalid);
    expect(fma(zero, inf, q2, mode), q2.bits, invalid);
    expect(fma(s2, s1, q1, mode), q1.bits, invalid);
    expect(fma(q1, s2, q2, mode), q2.bits, invalid);
    expect(remainder(one, zero, mode), bad, invalid);
    expect(remainder(one, inf, mode), one.bits);
    expect(remainder(nz, two, mode), nz.bits);
    bool overflow_inf = m == 0 || m == 3 || m == 4;
    expect(multiply(max, two, mode), overflow_inf ? inf.bits : max.bits, overflow | inexact);
    bool up = m == 3 || m == 4;
    expect(divide(tiny, two, mode), up ? U(1) : U(0), underflow | inexact);
    F half_gap{U(F::bias - int(F::fraction_bits) - 1) << F::fraction_bits};
    expect(add(one, half_gap, mode), one.bits + U(m == 3 || m == 4), inexact);
    F just_below_one{one.bits - 1};
    // The exact product straddles minimum normal; tininess is AFTER rounding.
    auto boundary = multiply(normal, just_below_one, mode);
    bool rounded_normal = m == 0 || m == 3 || m == 4;
    expect(boundary, normal.bits - U(!rounded_normal), inexact | (rounded_normal ? 0 : underflow));
    // The exact product can overflow before cancellation; FMA must not.
    expect(fma(max, two, negate(max), mode), max.bits);
  }
  auto quiet = compare(q1, one, comparison_policy::quiet);
  assert(quiet.value == comparison::unordered && quiet.raised == 0);
  assert(compare(q1, one, comparison_policy::signaling).raised == invalid);
  assert(compare(s1, one, comparison_policy::quiet).raised == invalid);
  assert(compare(nz, zero, comparison_policy::quiet).value == comparison::equal);
  assert(compare(negate(two), negate(one), comparison_policy::quiet).value == comparison::less);
  F three = from_integer<F>(3, rn).value, five = from_integer<F>(5, rn).value;
  F seven = from_integer<F>(7, rn).value;
  expect(remainder(three, two, rn), negate(one).bits); // quotient 2, even tie
  expect(remainder(five, two, rn), one.bits); // quotient 2, even tie
  expect(remainder(seven, two, rn), negate(one).bits);
}
template<class Int> void integers() {
  for (auto mode : {rounding_mode::nearest_even, rounding_mode::toward_zero, rounding_mode::downward,
                    rounding_mode::upward, rounding_mode::nearest_away}) {
    for (Int value : {Int(0), Int(1), Int(2), std::numeric_limits<Int>::min()}) {
      auto f = from_integer<binary64>(value, mode);
      auto i = to_integer<Int>(f.value, mode);
      assert(i.value.valid && i.value.value == value && !i.raised && !f.raised);
    }
    auto nan = to_integer<Int>(binary64{UINT64_C(0x7ff8000000000001)}, mode);
    assert(!nan.value.valid && nan.value.value == 0 && nan.raised == invalid);
  }
}
int main() {
  cases<binary32>(); cases<binary64>();
  integers<int32_t>(); integers<uint32_t>(); integers<int64_t>(); integers<uint64_t>();
  auto signed_max = to_integer<int64_t>(binary64{UINT64_C(0x43e0000000000000)}, rn);
  assert(!signed_max.value.valid && signed_max.raised == invalid);
  auto signed_min = to_integer<int64_t>(binary64{UINT64_C(0xc3e0000000000000)}, rn);
  assert(signed_min.value.valid && signed_min.value.value == INT64_MIN && signed_min.raised == 0);
  auto unsigned_over = to_integer<uint64_t>(binary64{UINT64_C(0x43f0000000000000)}, rn);
  assert(!unsigned_over.value.valid && unsigned_over.raised == invalid);
  for (unsigned m = 0; m < 5; ++m) {
    auto half = to_integer<int32_t>(binary64{UINT64_C(0xbfe0000000000000)}, rounding_mode(m));
    assert(half.value.valid && half.raised == inexact);
    assert(half.value.value == (m == 2 || m == 4 ? -1 : 0));
  }
  factor::software_fp_set_state(0);
  auto stored = factor::ieee_binary64::from_float_bits(UINT32_C(0xff800001));
  assert(stored.bits() == UINT64_C(0xfff0000020000000));
  assert(stored.float_bits() == UINT32_C(0xff800001));
  assert(factor::software_fp_flags == 0);
  auto numeric = convert<binary64>(binary32{UINT32_C(0xff800001)}, rn);
  expect(numeric, UINT64_C(0xfff8000020000000), invalid);
  factor::ieee_binary64 invalid_int = factor::ieee_binary64::from_bits(UINT64_C(0x7ff0000000000000));
  assert(invalid_int.to_signed() == INT64_MIN && factor::software_fp_flags == invalid);
  puts("Factor IEEE arithmetic, NaN, conversion and representation parity passed");
}
