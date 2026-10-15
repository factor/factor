#ifndef FACTOR_IEEE_DECIMAL_HPP
#define FACTOR_IEEE_DECIMAL_HPP

#include <algorithm>
#include <climits>
#include <locale>
#include <ostream>
#include <string>
#include "ieee_binary64.hpp"

namespace factor {
namespace ieee_decimal {

// Exact decimal digits of a finite binary64. At most 1074 integer multiplies
// suffice, including values outside the native VAX floating-point range.
inline void multiply(std::string& digits, unsigned factor) {
  unsigned carry = 0;
  for (size_t i = digits.size(); i != 0; --i) {
    unsigned value = (unsigned)(digits[i - 1] - '0') * factor + carry;
    digits[i - 1] = (char)('0' + value % 10);
    carry = value / 10;
  }
  if (carry) digits.insert(digits.begin(), (char)('0' + carry));
}

inline void exact(uint64_t bits, std::string& digits, int& point) {
  unsigned exponent = (unsigned)((bits >> 52) & 0x7ff);
  uint64_t significand = bits & UINT64_C(0x000fffffffffffff);
  int power = -1074;
  if (exponent) {
    significand |= UINT64_C(0x0010000000000000);
    power = (int)exponent - 1075;
  }
  digits = std::to_string(significand);
  if (significand == 0) { point = 1; return; }
  unsigned factor = power < 0 ? 5 : 2;
  for (int i = 0; i < (power < 0 ? -power : power); ++i)
    multiply(digits, factor);
  point = (int)digits.size() + (power < 0 ? power : 0);
}

inline void round(std::string& digits, int& point, int keep, bool negative,
                  fp::rounding_mode mode) {
  if (keep >= (int)digits.size()) return;
  bool up = false;
  if (keep >= 0) {
    char next = digits[(size_t)keep];
    bool tail = digits.find_first_not_of('0', (size_t)keep + 1) != std::string::npos;
    up = next > '5' || (next == '5' &&
                       (tail || (keep > 0 && ((digits[(size_t)keep - 1] - '0') & 1))));
  }
  bool discarded = digits.find_first_not_of('0', (size_t)std::max(keep, 0)) !=
                   std::string::npos;
  switch (mode) {
    case fp::rounding_mode::nearest_even: break;
    case fp::rounding_mode::toward_zero: up = false; break;
    case fp::rounding_mode::downward: up = negative && discarded; break;
    case fp::rounding_mode::upward: up = !negative && discarded; break;
    case fp::rounding_mode::nearest_away:
      up = keep >= 0 && digits[(size_t)keep] >= '5'; break;
  }
  if (keep <= 0) {
    digits = up ? "1" : "0";
    point = up ? point - keep + 1 : 1;
    return;
  }
  digits.resize((size_t)keep);
  if (!up) return;
  size_t i = digits.size();
  while (i && digits[i - 1] == '9') digits[--i] = '0';
  if (i) ++digits[i - 1];
  else { digits.insert(digits.begin(), '1'); ++point; }
}

inline std::string group(std::string whole, const std::numpunct<char>& punctuation) {
  std::string grouping = punctuation.grouping();
  if (grouping.empty()) return whole;
  size_t position = whole.size(), index = 0;
  while (position) {
    unsigned count = (unsigned char)grouping[index];
    if (count == 0 || count == CHAR_MAX || count >= position) break;
    position -= count;
    whole.insert(position, 1, punctuation.thousands_sep());
    if (index + 1 < grouping.size()) ++index;
  }
  return whole;
}

inline std::string fixed(const std::string& digits, int point, int precision,
                         bool showpoint, const std::numpunct<char>& punctuation) {
  std::string whole = point <= 0 ? "0" : digits.substr(0, (size_t)point);
  if (point > (int)whole.size()) whole.append((size_t)point - whole.size(), '0');
  whole = group(whole, punctuation);
  if (precision || showpoint) whole += punctuation.decimal_point();
  std::string fraction;
  if (point < 0) fraction.append((size_t)-point, '0');
  if (point < (int)digits.size()) fraction += digits.substr((size_t)std::max(point, 0));
  fraction.resize((size_t)precision, '0');
  return whole + fraction;
}

inline std::string scientific(std::string digits, int point, int precision,
                              bool showpoint, bool upper, char decimal_point) {
  digits.resize((size_t)precision + 1, '0');
  std::string result(1, digits[0]);
  if (precision || showpoint) result += decimal_point;
  result += digits.substr(1);
  int exponent = point - 1;
  result += upper ? 'E' : 'e';
  result += exponent < 0 ? '-' : '+';
  std::string magnitude = std::to_string(exponent < 0 ? -exponent : exponent);
  if (magnitude.size() < 2) result += '0';
  return result + magnitude;
}

}

inline std::ostream& operator<<(std::ostream& out, ieee_binary64 value) {
  const std::ios_base::fmtflags flags = out.flags();
  const bool upper = (flags & std::ios_base::uppercase) != 0;
  const bool showpoint = (flags & std::ios_base::showpoint) != 0;
  const std::numpunct<char>& punctuation = std::use_facet<std::numpunct<char>>(out.getloc());
  std::string result;
  if (value.is_nan()) result = upper ? "NAN" : "nan";
  else if (value.is_infinite()) result = upper ? "INF" : "inf";
  else {
    std::string digits;
    int point;
    ieee_decimal::exact(value.bits(), digits, point);
    int precision = (int)out.precision();
    if (precision < 0) precision = 6;
    std::ios_base::fmtflags style = flags & std::ios_base::floatfield;
    if (style == std::ios_base::fixed) {
      ieee_decimal::round(digits, point, point + precision, value.sign(), software_fp_rounding);
      result = ieee_decimal::fixed(digits, point, precision, showpoint, punctuation);
    } else if (style == std::ios_base::scientific) {
      ieee_decimal::round(digits, point, precision + 1, value.sign(), software_fp_rounding);
      result = ieee_decimal::scientific(digits, point, precision, showpoint, upper,
                                        punctuation.decimal_point());
    } else {
      if (precision == 0) precision = 1;
      ieee_decimal::round(digits, point, precision, value.sign(), software_fp_rounding);
      if (showpoint) digits.resize((size_t)precision, '0');
      else while (digits.size() > 1 && digits.back() == '0') digits.pop_back();
      if (point - 1 < -4 || point - 1 >= precision)
        result = ieee_decimal::scientific(digits, point, (int)digits.size() - 1,
                                          showpoint, upper, punctuation.decimal_point());
      else
        result = ieee_decimal::fixed(digits, point, std::max(0, (int)digits.size() - point),
                                     showpoint, punctuation);
    }
  }
  if (value.sign()) result.insert(result.begin(), '-');
  else if (flags & std::ios_base::showpos) result.insert(result.begin(), '+');
  std::streamsize width = out.width(0);
  if (width > (std::streamsize)result.size()) {
    size_t padding = (size_t)(width - (std::streamsize)result.size());
    if ((flags & std::ios_base::adjustfield) == std::ios_base::left)
      result.append(padding, out.fill());
    else if ((flags & std::ios_base::adjustfield) == std::ios_base::internal &&
             (result[0] == '-' || result[0] == '+'))
      result.insert(1, padding, out.fill());
    else result.insert(0, padding, out.fill());
  }
  return out.write(result.data(), (std::streamsize)result.size());
}

}
#endif
