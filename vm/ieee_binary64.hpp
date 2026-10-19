#ifndef FACTOR_IEEE_BINARY64_HPP
#define FACTOR_IEEE_BINARY64_HPP

#include <stdint.h>
#include <type_traits>
#include "software_fp_state.hpp"

namespace factor {

// IEEE object/image storage and arithmetic, independent of native C double.
// Native VAX FFI boundaries must explicitly convert with vax_float.hpp.
class ieee_binary64 {
  uint64_t bits_;

  explicit ieee_binary64(fp::binary64 value) : bits_(value.bits) {}
  fp::binary64 value() const { return {bits_}; }

 public:
  ieee_binary64() : bits_(0) {}
  static ieee_binary64 from_bits(uint64_t bits) {
    fp::binary64 value = {bits};
    return ieee_binary64(value);
  }
  static ieee_binary64 from_signed(int64_t value) {
    return ieee_binary64(software_fp_commit(fp::from_integer<fp::binary64>(value, software_fp_rounding)));
  }
  static ieee_binary64 from_unsigned(uint64_t value) {
    return ieee_binary64(software_fp_commit(fp::from_integer<fp::binary64>(value, software_fp_rounding)));
  }
  static ieee_binary64 from_float_bits(uint32_t bits) {
    uint32_t payload = bits & UINT32_C(0x007fffff);
    if ((bits & UINT32_C(0x7f800000)) == UINT32_C(0x7f800000) && payload != 0)
      return from_bits(((uint64_t)(bits & UINT32_C(0x80000000)) << 32) |
                       UINT64_C(0x7ff0000000000000) | ((uint64_t)payload << 29));
    return ieee_binary64(software_fp_commit(fp::convert<fp::binary64>(fp::binary32{bits}, software_fp_rounding)));
  }
  uint64_t bits() const { return bits_; }
  uint32_t float_bits() const {
    if (is_nan()) {
      uint32_t payload = (uint32_t)((bits_ & UINT64_C(0x000fffffffffffff)) >> 29);
      return (uint32_t)((bits_ >> 32) & UINT32_C(0x80000000)) |
             UINT32_C(0x7f800000) | (payload == 0 ? 1 : payload);
    }
    return software_fp_commit(fp::convert<fp::binary32>(value(), software_fp_rounding)).bits;
  }
  int64_t to_signed() const {
    auto converted = software_fp_commit(fp::to_integer<int64_t>(value(), fp::rounding_mode::toward_zero));
    return converted.valid ? converted.value : INT64_MIN;
  }
  bool sign() const { return (bits_ >> 63) != 0; }
  bool is_zero() const { return (bits_ << 1) == 0; }
  bool is_finite() const {
    return (bits_ & UINT64_C(0x7ff0000000000000)) != UINT64_C(0x7ff0000000000000);
  }
  bool is_nan() const {
    return !is_finite() && (bits_ & UINT64_C(0x000fffffffffffff)) != 0;
  }
  bool is_infinite() const { return !is_finite() && !is_nan(); }
  ieee_binary64 sqrt() const {
    return ieee_binary64(software_fp_commit(fp::sqrt(value(), software_fp_rounding)));
  }
  ieee_binary64 abs() const {
    return from_bits(bits_ & UINT64_C(0x7fffffffffffffff));
  }
  ieee_binary64 operator-() const {
    return from_bits(bits_ ^ UINT64_C(0x8000000000000000));
  }
  friend ieee_binary64 operator+(ieee_binary64 a, ieee_binary64 b) {
    return ieee_binary64(software_fp_commit(fp::add(a.value(), b.value(), software_fp_rounding)));
  }
  friend ieee_binary64 operator-(ieee_binary64 a, ieee_binary64 b) {
    return ieee_binary64(software_fp_commit(fp::subtract(a.value(), b.value(), software_fp_rounding)));
  }
  friend ieee_binary64 operator*(ieee_binary64 a, ieee_binary64 b) {
    return ieee_binary64(software_fp_commit(fp::multiply(a.value(), b.value(), software_fp_rounding)));
  }
  friend ieee_binary64 operator/(ieee_binary64 a, ieee_binary64 b) {
    return ieee_binary64(software_fp_commit(fp::divide(a.value(), b.value(), software_fp_rounding)));
  }
  friend bool operator==(ieee_binary64 a, ieee_binary64 b) {
    return software_fp_commit(fp::compare(a.value(), b.value(), fp::comparison_policy::quiet)) == fp::comparison::equal;
  }
  friend bool operator!=(ieee_binary64 a, ieee_binary64 b) { return !(a == b); }
  friend bool operator<(ieee_binary64 a, ieee_binary64 b) {
    return software_fp_commit(fp::compare(a.value(), b.value(), fp::comparison_policy::signaling)) == fp::comparison::less;
  }
  friend bool operator<=(ieee_binary64 a, ieee_binary64 b) {
    auto order = software_fp_commit(fp::compare(a.value(), b.value(), fp::comparison_policy::signaling));
    return order == fp::comparison::less || order == fp::comparison::equal;
  }
  friend bool operator>(ieee_binary64 a, ieee_binary64 b) { return b < a; }
  friend bool operator>=(ieee_binary64 a, ieee_binary64 b) { return b <= a; }
};

static_assert(sizeof(ieee_binary64) == sizeof(uint64_t), "IEEE float image layout");
static_assert(std::is_trivially_copyable<ieee_binary64>::value, "IEEE float image copying");

}

#endif
