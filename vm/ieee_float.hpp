#ifndef FACTOR_IEEE_FLOAT_HPP
#define FACTOR_IEEE_FLOAT_HPP

// Factor's integer-only IEEE engine. All arithmetic below is independently
// implemented from exact integer operations followed by a single rounding.
#include <stdint.h>
#include <stddef.h>
#include <limits>
#include <type_traits>
#include <assert.h>

namespace factor { namespace fp {

enum class rounding_mode : uint8_t {
  nearest_even = 0, toward_zero = 1, downward = 2, upward = 3, nearest_away = 4
};
using exception_flags = uint8_t;
enum : exception_flags {
  inexact = 1, underflow = 2, overflow = 4, divide_by_zero = 8, invalid = 16
};
enum class comparison : uint8_t { less, equal, greater, unordered };
enum class comparison_policy : uint8_t { quiet, signaling };
template<class T> struct result { T value; exception_flags raised; };
template<class T> struct integer_value { T value; bool valid; };

template<class UInt, unsigned Fraction, unsigned Exponent> struct binary {
  static_assert(std::is_unsigned<UInt>::value && Fraction >= 2 && Fraction <= 52 &&
                Exponent >= 3 && Exponent <= 11 && Fraction + Exponent < sizeof(UInt) * 8,
                "format must fit the bounded binary64 engine");
  using storage_type = UInt;
  static constexpr unsigned fraction_bits = Fraction, exponent_bits = Exponent;
  static constexpr int bias = (1 << (Exponent - 1)) - 1;
  static constexpr int emin = 1 - bias, emax = bias;
  static constexpr UInt sign_mask = UInt(1) << (Fraction + Exponent);
  static constexpr UInt fraction_mask = (UInt(1) << Fraction) - 1;
  static constexpr UInt exponent_mask = ((UInt(1) << Exponent) - 1) << Fraction;
  static constexpr UInt quiet_mask = UInt(1) << (Fraction - 1);
  UInt bits;
  static constexpr binary from_bits(UInt bits) noexcept { return {bits}; }
  constexpr bool sign() const noexcept { return (bits & sign_mask) != 0; }
  constexpr bool is_zero() const noexcept { return (bits & ~sign_mask) == 0; }
  constexpr bool is_finite() const noexcept { return (bits & exponent_mask) != exponent_mask; }
  constexpr bool is_nan() const noexcept { return !is_finite() && (bits & fraction_mask); }
  constexpr bool is_signaling_nan() const noexcept { return is_nan() && !(bits & quiet_mask); }
  constexpr bool is_infinite() const noexcept { return !is_finite() && !is_nan(); }
};
using binary32 = binary<uint32_t, 23, 8>;
using binary64 = binary<uint64_t, 52, 11>;
static_assert(sizeof(binary32) == 4 && sizeof(binary64) == 8, "IEEE storage size");

template<class F> constexpr F negate(F x) noexcept { return {x.bits ^ F::sign_mask}; }
template<class F> constexpr F abs(F x) noexcept { return {x.bits & ~F::sign_mask}; }
inline constexpr bool valid_mode(rounding_mode m) noexcept { return unsigned(m) <= 4; }

namespace detail {

// The widest exact binary64 FMA spans 4196 bits. 4224 bits also leave
// room for carries. No native wide integer type, allocation or FP is needed.
struct magnitude {
  static constexpr unsigned capacity = 132;
  uint32_t limb[capacity] = {};
  unsigned used = 0;
  explicit magnitude(uint64_t n = 0) noexcept {
    if (n) { limb[0] = uint32_t(n); used = 1; }
    if (n >> 32) { limb[1] = uint32_t(n >> 32); used = 2; }
  }
  void trim() noexcept { while (used && limb[used - 1] == 0) --used; }
  unsigned length() const noexcept {
    if (!used) return 0;
    uint32_t n = limb[used - 1];
    unsigned count = 0;
    while (n) { ++count; n >>= 1; }
    return (used - 1) * 32 + count;
  }
  bool bit(unsigned n) const noexcept { return n / 32 < used && ((limb[n / 32] >> (n % 32)) & 1); }
  bool below(unsigned n) const noexcept {
    unsigned full = n / 32;
    for (unsigned i = 0; i < used && i < full; ++i) if (limb[i]) return true;
    return full < used && n % 32 && (limb[full] & ((uint32_t(1) << (n % 32)) - 1));
  }
  uint64_t low_after(unsigned shift) const noexcept {
    uint64_t n = 0;
    for (unsigned i = 0; i < 64; ++i) if (bit(shift + i)) n |= uint64_t(1) << i;
    return n;
  }
  void shift_left(unsigned n) noexcept {
    if (!used || !n) return;
    unsigned whole = n / 32, part = n % 32, old = used;
    assert(old + whole + (part != 0) <= capacity);
    for (unsigned i = old; i != 0; --i) limb[i - 1 + whole] = limb[i - 1];
    for (unsigned i = 0; i < whole; ++i) limb[i] = 0;
    used += whole;
    if (part) {
      uint32_t carry = 0;
      for (unsigned i = whole; i < used; ++i) {
        uint32_t next = limb[i] >> (32 - part);
        limb[i] = (limb[i] << part) | carry;
        carry = next;
      }
      if (carry) limb[used++] = carry;
    }
  }
  int compare(const magnitude& b) const noexcept {
    if (used != b.used) return used < b.used ? -1 : 1;
    for (unsigned i = used; i != 0; --i)
      if (limb[i - 1] != b.limb[i - 1]) return limb[i - 1] < b.limb[i - 1] ? -1 : 1;
    return 0;
  }
  void add(const magnitude& b) noexcept {
    unsigned count = used > b.used ? used : b.used;
    uint64_t carry = 0;
    for (unsigned i = 0; i < count; ++i) {
      uint64_t n = uint64_t(i < used ? limb[i] : 0) + (i < b.used ? b.limb[i] : 0) + carry;
      limb[i] = uint32_t(n); carry = n >> 32;
    }
    used = count;
    if (carry) { assert(used < capacity); limb[used++] = uint32_t(carry); }
  }
  void subtract(const magnitude& b) noexcept {
    assert(compare(b) >= 0);
    uint64_t borrow = 0;
    for (unsigned i = 0; i < used; ++i) {
      uint64_t sub = uint64_t(i < b.used ? b.limb[i] : 0) + borrow;
      uint32_t old = limb[i]; limb[i] = uint32_t(uint64_t(old) - sub);
      borrow = uint64_t(old) < sub;
    }
    trim();
  }
};

inline magnitude product(uint64_t a, uint64_t b) noexcept {
  magnitude x(a), y(b), z;
  if (!x.used || !y.used) return z;
  z.used = x.used + y.used;
  for (unsigned i = 0; i < x.used; ++i) {
    uint64_t carry = 0;
    for (unsigned j = 0; j < y.used; ++j) {
      uint64_t n = uint64_t(x.limb[i]) * y.limb[j] + z.limb[i + j] + carry;
      z.limb[i + j] = uint32_t(n); carry = n >> 32;
    }
    z.limb[i + y.used] = uint32_t(carry);
  }
  z.trim(); return z;
}

// Long division returns an exact remainder and the low 64 quotient bits.
// Remainder needs only the final quotient bit; division's quotient fits 64.
inline uint64_t divide(const magnitude& a, const magnitude& b, magnitude& rem) noexcept {
  assert(b.used);
  uint64_t quotient = 0;
  for (unsigned i = a.length(); i != 0; --i) {
    rem.shift_left(1);
    if (a.bit(i - 1)) { if (!rem.used) rem.used = 1; rem.limb[0] |= 1; }
    bool take = rem.compare(b) >= 0;
    if (take) rem.subtract(b);
    quotient = (quotient << 1) | uint64_t(take);
  }
  return quotient;
}

template<class F> struct unpacked { uint64_t sig; int power; };
template<class F> inline unpacked<F> unpack(F x) noexcept {
  unsigned exp = unsigned((x.bits & F::exponent_mask) >> F::fraction_bits);
  uint64_t sig = x.bits & F::fraction_mask;
  if (exp) sig |= uint64_t(1) << F::fraction_bits;
  return {sig, (exp ? int(exp) - F::bias : F::emin) - int(F::fraction_bits)};
}
template<class F> inline F zero(bool negative) noexcept { return {negative ? F::sign_mask : 0}; }
template<class F> inline F infinity(bool negative) noexcept {
  return {F::exponent_mask | (negative ? F::sign_mask : 0)};
}
template<class F> inline result<F> invalid_result() noexcept {
  return {{F::sign_mask | F::exponent_mask | F::quiet_mask}, invalid};
}
template<class F> inline result<F> nan(F a, F b) noexcept {
  bool sa = a.is_signaling_nan(), sb = b.is_signaling_nan();
  F chosen = a.is_nan() ? a : b;
  if (a.is_nan() && b.is_nan()) {
    if (sa != sb) chosen = sa ? b : a;
    else {
      auto pa = a.bits & F::fraction_mask, pb = b.bits & F::fraction_mask;
      if (pb > pa || (pa == pb && a.sign() && !b.sign())) chosen = b;
    }
  }
  chosen.bits |= F::quiet_mask;
  return {chosen, exception_flags(sa || sb ? invalid : 0)};
}

inline bool increment(rounding_mode mode, bool negative, uint64_t integer,
                      bool discarded, bool half, bool tail) noexcept {
  switch (mode) {
    case rounding_mode::toward_zero: return false;
    case rounding_mode::downward: return negative && discarded;
    case rounding_mode::upward: return !negative && discarded;
    case rounding_mode::nearest_away: return half;
    case rounding_mode::nearest_even: return half && (tail || (integer & 1));
  }
  return false; // Typed callers must supply a valid mode; the C bridge checks.
}

template<class F> inline result<F> round(const magnitude& exact, int power,
                                         bool negative, rounding_mode mode) noexcept {
  if (!exact.used) return {zero<F>(negative), 0};
  int exponent = power + int(exact.length()) - 1;
  int quantum = (exponent < F::emin ? F::emin : exponent) - int(F::fraction_bits);
  int shift = quantum - power;
  uint64_t significand;
  bool discarded = false;
  if (shift > 0) {
    significand = exact.low_after(unsigned(shift));
    discarded = exact.below(unsigned(shift));
    bool half = exact.bit(unsigned(shift - 1)), tail = exact.below(unsigned(shift - 1));
    if (increment(mode, negative, significand, discarded, half, tail)) ++significand;
  } else significand = exact.low_after(0) << unsigned(-shift);
  const uint64_t hidden = uint64_t(1) << F::fraction_bits;
  int encoded_exponent = exponent < F::emin ? F::emin : exponent;
  if (significand >= hidden * 2) { significand >>= 1; ++encoded_exponent; }
  if (encoded_exponent > F::emax) {
    bool to_inf = mode == rounding_mode::nearest_even || mode == rounding_mode::nearest_away ||
                  (mode == rounding_mode::upward && !negative) ||
                  (mode == rounding_mode::downward && negative);
    F value = to_inf ? infinity<F>(negative) : F{typename F::storage_type(
        (negative ? F::sign_mask : 0) | (F::exponent_mask - hidden) | F::fraction_mask)};
    return {value, exception_flags(overflow | inexact)};
  }
  bool subnormal = significand < hidden;
  typename F::storage_type bits = typename F::storage_type(significand & F::fraction_mask);
  if (!subnormal) bits |= typename F::storage_type(encoded_exponent + F::bias) << F::fraction_bits;
  if (negative) bits |= F::sign_mask;
  return {{bits}, exception_flags(discarded ? inexact | (subnormal ? underflow : 0) : 0)};
}

template<class F> inline result<F> sum(magnitude a, int ap, bool as,
                                      magnitude b, int bp, bool bs, rounding_mode mode) noexcept {
  if (!a.used && !b.used) return {zero<F>(as == bs ? as : mode == rounding_mode::downward), 0};
  if (!a.used) return round<F>(b, bp, bs, mode);
  if (!b.used) return round<F>(a, ap, as, mode);
  int power = ap < bp ? ap : bp;
  a.shift_left(unsigned(ap - power)); b.shift_left(unsigned(bp - power));
  if (as == bs) { a.add(b); return round<F>(a, power, as, mode); }
  int order = a.compare(b);
  if (!order) return {zero<F>(mode == rounding_mode::downward), 0};
  if (order > 0) { a.subtract(b); return round<F>(a, power, as, mode); }
  b.subtract(a); return round<F>(b, power, bs, mode);
}
} // namespace detail

template<class F> inline result<F> add(F a, F b, rounding_mode mode) noexcept {
  if (a.is_nan() || b.is_nan()) return detail::nan(a, b);
  if (a.is_infinite() || b.is_infinite()) {
    if (a.is_infinite() && b.is_infinite() && a.sign() != b.sign()) return detail::invalid_result<F>();
    return {a.is_infinite() ? a : b, 0};
  }
  auto x = detail::unpack(a), y = detail::unpack(b);
  return detail::sum<F>(detail::magnitude(x.sig), x.power, a.sign(),
                        detail::magnitude(y.sig), y.power, b.sign(), mode);
}
template<class F> inline result<F> subtract(F a, F b, rounding_mode mode) noexcept {
  // Select NaN from the original operands, before changing b's sign.
  if (a.is_nan() || b.is_nan()) return detail::nan(a, b);
  return add(a, negate(b), mode);
}
template<class F> inline result<F> multiply(F a, F b, rounding_mode mode) noexcept {
  if (a.is_nan() || b.is_nan()) return detail::nan(a, b);
  bool negative = a.sign() != b.sign();
  if (a.is_infinite() || b.is_infinite()) {
    if (a.is_zero() || b.is_zero()) return detail::invalid_result<F>();
    return {detail::infinity<F>(negative), 0};
  }
  auto x = detail::unpack(a), y = detail::unpack(b);
  return detail::round<F>(detail::product(x.sig, y.sig), x.power + y.power, negative, mode);
}
template<class F> inline result<F> divide(F a, F b, rounding_mode mode) noexcept {
  if (a.is_nan() || b.is_nan()) return detail::nan(a, b);
  bool negative = a.sign() != b.sign();
  if ((a.is_infinite() && b.is_infinite()) || (a.is_zero() && b.is_zero())) return detail::invalid_result<F>();
  if (a.is_infinite()) return {detail::infinity<F>(negative), 0};
  if (b.is_infinite()) return {detail::zero<F>(negative), 0};
  if (b.is_zero()) return {detail::infinity<F>(negative), divide_by_zero};
  if (a.is_zero()) return {detail::zero<F>(negative), 0};
  auto x = detail::unpack(a), y = detail::unpack(b);
  detail::magnitude numerator(x.sig), denominator(y.sig), rem;
  unsigned shift = unsigned(int(F::fraction_bits) + 4 + int(denominator.length()) - int(numerator.length()));
  numerator.shift_left(shift);
  uint64_t quotient = detail::divide(numerator, denominator, rem);
  if (rem.used) quotient |= 1; // This low guard bit represents the entire exact tail.
  return detail::round<F>(detail::magnitude(quotient), x.power - y.power - int(shift), negative, mode);
}
template<class F> inline result<F> sqrt(F a, rounding_mode mode) noexcept {
  if (a.is_nan()) return detail::nan(a, a);
  if (a.is_zero()) return {a, 0};
  if (a.sign()) return detail::invalid_result<F>();
  if (a.is_infinite()) return {a, 0};
  auto x = detail::unpack(a);
  if (x.power % 2 != 0) { x.sig <<= 1; --x.power; }
  detail::magnitude radicand(x.sig);
  unsigned shift = 2 * (F::fraction_bits + 4 - (radicand.length() + 1) / 2);
  radicand.shift_left(shift);
  uint64_t root = 0, rem = 0;
  for (unsigned pair = (radicand.length() + 1) / 2; pair != 0; --pair) {
    unsigned bit = 2 * (pair - 1);
    rem = (rem << 2) | (uint64_t(radicand.bit(bit + 1)) << 1) | uint64_t(radicand.bit(bit));
    uint64_t trial = (root << 2) | 1;
    bool take = rem >= trial;
    if (take) rem -= trial;
    root = (root << 1) | uint64_t(take);
  }
  if (rem) root |= 1;
  return detail::round<F>(detail::magnitude(root), x.power / 2 - int(shift / 2), false, mode);
}
template<class F> inline result<F> remainder(F a, F b, rounding_mode mode) noexcept {
  if (a.is_nan() || b.is_nan()) return detail::nan(a, b);
  if (a.is_infinite() || b.is_zero()) return detail::invalid_result<F>();
  if (b.is_infinite() || a.is_zero()) return {a, 0};
  auto x = detail::unpack(a), y = detail::unpack(b);
  int power = x.power < y.power ? x.power : y.power;
  detail::magnitude numerator(x.sig), denominator(y.sig), rem;
  numerator.shift_left(unsigned(x.power - power)); denominator.shift_left(unsigned(y.power - power));
  uint64_t quotient = detail::divide(numerator, denominator, rem);
  detail::magnitude twice = rem; twice.shift_left(1);
  int cmp = twice.compare(denominator);
  bool flip = cmp > 0 || (cmp == 0 && (quotient & 1));
  if (flip) { denominator.subtract(rem); rem = denominator; }
  return detail::round<F>(rem, power, a.sign() != flip, mode);
}
template<class F> inline result<F> fma(F a, F b, F c, rounding_mode mode) noexcept {
  bool bad_product = (a.is_zero() && b.is_infinite()) || (b.is_zero() && a.is_infinite());
  if (a.is_nan() || b.is_nan() || c.is_nan()) {
    result<F> n = a.is_nan() || b.is_nan() ? detail::nan(a, b) : detail::nan(c, c);
    if (c.is_nan() && (a.is_nan() || b.is_nan())) {
      // Keep original signaling classes for the three-operand selection.
      F selected = a.is_nan() ? a : b;
      if (a.is_nan() && b.is_nan()) {
        selected = n.value;
        if (a.is_signaling_nan() && b.is_signaling_nan()) selected.bits &= ~F::quiet_mask;
      }
      auto merged = detail::nan(selected, c);
      n.value = merged.value; n.raised |= merged.raised;
    }
    if (bad_product || a.is_signaling_nan() || b.is_signaling_nan() || c.is_signaling_nan()) n.raised |= invalid;
    return n;
  }
  if (bad_product) return detail::invalid_result<F>();
  bool sign = a.sign() != b.sign();
  if (a.is_infinite() || b.is_infinite()) {
    if (c.is_infinite() && sign != c.sign()) return detail::invalid_result<F>();
    return {detail::infinity<F>(sign), 0};
  }
  if (c.is_infinite()) return {c, 0};
  auto x = detail::unpack(a), y = detail::unpack(b), z = detail::unpack(c);
  return detail::sum<F>(detail::product(x.sig, y.sig), x.power + y.power, sign,
                        detail::magnitude(z.sig), z.power, c.sign(), mode);
}
template<class F> inline result<comparison> compare(F a, F b, comparison_policy policy) noexcept {
  if (a.is_nan() || b.is_nan()) return {comparison::unordered, exception_flags(
      policy == comparison_policy::signaling || a.is_signaling_nan() || b.is_signaling_nan() ? invalid : 0)};
  if (a.bits == b.bits || (a.is_zero() && b.is_zero())) return {comparison::equal, 0};
  bool less = a.sign() != b.sign() ? a.sign() : a.sign() ? a.bits > b.bits : a.bits < b.bits;
  return {less ? comparison::less : comparison::greater, 0};
}
template<class To, class From> inline result<To> convert(From a, rounding_mode mode) noexcept {
  if (a.is_nan()) {
    uint64_t payload = a.bits & From::fraction_mask;
    if constexpr (From::fraction_bits > To::fraction_bits) payload >>= From::fraction_bits - To::fraction_bits;
    else payload <<= To::fraction_bits - From::fraction_bits;
    return {{typename To::storage_type((a.sign() ? To::sign_mask : 0) | To::exponent_mask |
                                      To::quiet_mask | payload)}, exception_flags(a.is_signaling_nan() ? invalid : 0)};
  }
  if (a.is_infinite()) return {detail::infinity<To>(a.sign()), 0};
  auto x = detail::unpack(a);
  return detail::round<To>(detail::magnitude(x.sig), x.power, a.sign(), mode);
}
template<class F, class Int> inline result<F> from_integer(Int a, rounding_mode mode) noexcept {
  static_assert(std::is_integral<Int>::value && sizeof(Int) <= 8, "fixed-width integer input");
  bool negative = std::is_signed<Int>::value && a < 0;
  uint64_t magnitude = negative ? uint64_t(0) - uint64_t(a) : uint64_t(a);
  return detail::round<F>(detail::magnitude(magnitude), 0, negative, mode);
}
template<class Int, class F> inline result<integer_value<Int>> to_integer(F a, rounding_mode mode) noexcept {
  static_assert(std::is_integral<Int>::value && sizeof(Int) <= 8 && !std::is_same<Int, bool>::value,
                "fixed-width integer output");
  const result<integer_value<Int>> bad = {{0, false}, invalid};
  if (!a.is_finite()) return bad;
  auto x = detail::unpack(a);
  detail::magnitude mag(x.sig);
  bool discarded = false;
  uint64_t n = 0;
  if (x.power >= 0) {
    if (int(mag.length()) + x.power > 64) return bad;
    n = x.sig << unsigned(x.power);
  } else {
    unsigned shift = unsigned(-x.power);
    n = mag.low_after(shift); discarded = mag.below(shift);
    if (detail::increment(mode, a.sign(), n, discarded, mag.bit(shift - 1), mag.below(shift - 1))) {
      if (n == UINT64_MAX) return bad;
      ++n;
    }
  }
  Int value;
  if constexpr (std::is_signed<Int>::value) {
    uint64_t maximum = uint64_t(std::numeric_limits<Int>::max());
    if (n > maximum + uint64_t(a.sign())) return bad;
    if (a.sign()) value = n == maximum + 1 ? std::numeric_limits<Int>::min() : Int(-Int(n));
    else value = Int(n);
  } else {
    if ((a.sign() && n) || n > uint64_t(std::numeric_limits<Int>::max())) return bad;
    value = Int(n);
  }
  return {{value, true}, exception_flags(discarded ? inexact : 0)};
}

}} // namespace factor::fp
#endif
