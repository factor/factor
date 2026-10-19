#include "../ieee_decimal.hpp"
#include <assert.h>
#include <iomanip>
#include <sstream>
#include <string.h>

using factor::ieee_binary64;

static std::string format(uint64_t bits, std::ios_base::fmtflags flags,
                          int precision) {
  std::ostringstream stream;
  stream.flags(flags);
  stream.precision(precision);
  stream << ieee_binary64::from_bits(bits);
  return stream.str();
}

class punctuation : public std::numpunct<char> {
  char do_decimal_point() const override { return ','; }
  char do_thousands_sep() const override { return '_'; }
  std::string do_grouping() const override { return "\3"; }
};

int main() {
  assert(format(UINT64_C(1), std::ios_base::scientific, 6) == "4.940656e-324");
  assert(format(UINT64_C(0x7fefffffffffffff), std::ios_base::scientific, 6) ==
         "1.797693e+308");
  assert(format(UINT64_C(0x8000000000000000), std::ios_base::fixed, 3) == "-0.000");
  assert(format(UINT64_C(0x7ff0000000000000), std::ios_base::uppercase, 6) == "INF");
  assert(format(UINT64_C(0x7ff0000000000001), std::ios_base::fmtflags(0), 6) == "nan");
  assert(format(UINT64_C(0x4004000000000000), std::ios_base::fixed, 0) == "2");
  assert(format(UINT64_C(0x400c000000000000), std::ios_base::fixed, 0) == "4");
  std::ostringstream localized;
  localized.imbue(std::locale(std::locale::classic(), new punctuation));
  localized << std::fixed << std::setprecision(2) << std::internal
            << std::setfill('0') << std::setw(14)
            << ieee_binary64::from_bits(UINT64_C(0xc0c81cd000000000));
  assert(localized.str() == "-000012_345,62");
  factor::software_fp_rounding = factor::fp::rounding_mode::upward;
  assert(format(UINT64_C(1), std::ios_base::fixed, 2) == "0.01");
  assert(format(UINT64_C(0x8000000000000001), std::ios_base::fixed, 2) == "-0.00");
  factor::software_fp_rounding = factor::fp::rounding_mode::downward;
  assert(format(UINT64_C(0x8000000000000001), std::ios_base::fixed, 2) == "-0.01");
  factor::software_fp_rounding = factor::fp::rounding_mode::toward_zero;
  assert(format(UINT64_C(0x400c000000000000), std::ios_base::fixed, 0) == "3");
  factor::software_fp_rounding = factor::fp::rounding_mode::nearest_even;
#if !defined(__vax__)
  // Compare the complete format flow with the platform's IEEE stream oracle.
  uint64_t bits = 1;
  const int precisions[] = {0, 1, 2, 6, 17, 30};
  const std::ios_base::fmtflags styles[] = {std::ios_base::fmtflags(0),
                                           std::ios_base::fixed,
                                           std::ios_base::scientific};
  for (unsigned i = 0; i < 256; ++i) {
    bits = bits * UINT64_C(6364136223846793005) + UINT64_C(1442695040888963407);
    double native;
    memcpy(&native, &bits, sizeof(native));
    for (auto style : styles) for (int precision : precisions) {
      for (auto extras : {std::ios_base::fmtflags(0),
                         std::ios_base::showpoint | std::ios_base::uppercase}) {
        std::ostringstream oracle;
        oracle.flags(style | extras);
        oracle.precision(precision);
        oracle << native;
        std::string actual = format(bits, style | extras, precision);
        if (actual != oracle.str()) {
          fprintf(stderr, "%016llx precision=%d flags=%lu expected=%s actual=%s\n",
                  (unsigned long long)bits, precision, (unsigned long)(style | extras),
                  oracle.str().c_str(), actual.c_str());
          return 1;
        }
      }
    }
  }
#endif
  puts("integer IEEE binary64 decimal formatting passed");
}
