// Independent exhaustive oracle: enumerate a six-bit format's representable
// numbers, then compare integer rational distances (squared for sqrt).
// This oracle does not call the production unpacking, limbs or rounding code.
#include "../ieee_float.hpp"
#include <stdio.h>
#include <stdlib.h>
using namespace factor::fp;
using tiny_float = binary<uint32_t, 2, 3>;
static int units(unsigned bits) {
  unsigned exp = (bits >> 2) & 7, fraction = bits & 3;
  int n = exp ? int(4 + fraction) << (exp - 1) : int(fraction);
  return bits & 32 ? -n : n;
}
struct expected { unsigned bits, flags; };
static expected quantize(int numerator, int denominator, unsigned mode, bool negative_zero, bool root = false) {
  bool negative = numerator < 0;
  if (denominator < 0) { denominator = -denominator; numerator = -numerator; negative = numerator < 0; }
  if (numerator < 0) numerator = -numerator;
  if (!numerator) return {negative_zero ? 32u : 0u, 0};
  unsigned low = 0;
  for (unsigned candidate = 1; candidate <= 27; ++candidate) {
    int n = units(candidate);
    bool fits = root ? n * n <= numerator : n * denominator <= numerator;
    if (!fits) break;
    low = candidate;
  }
  int lo = units(low), hi = low < 27 ? units(low + 1) : 256;
  bool exact = root ? lo * lo == numerator : lo * denominator == numerator;
  unsigned pick = low;
  if (!exact) {
    bool up = false;
    if (mode == 2) up = negative;
    else if (mode == 3) up = !negative;
    else if (mode == 0 || mode == 4) {
      int cmp = root ? 4 * numerator - (lo + hi) * (lo + hi) : 2 * numerator - (lo + hi) * denominator;
      up = cmp > 0 || (cmp == 0 && (mode == 4 || (low & 1)));
    }
    if (up) ++pick;
  }
  bool too_large = root ? numerator >= 256 * 256 : numerator >= 256 * denominator;
  unsigned flags = exact ? 0 : inexact;
  if (too_large || pick == 28) {
    flags = overflow | inexact;
    bool inf = mode == 0 || mode == 4 || (mode == 2 && negative) || (mode == 3 && !negative);
    pick = inf ? 28 : 27;
  } else if (pick < 4 && !exact) flags |= underflow;
  return {pick | (negative ? 32u : 0u), flags};
}
static expected reference(unsigned op, unsigned a, unsigned b, unsigned c, unsigned mode) {
  int x = units(a), y = units(b), z = units(c);
  bool as = a & 32, bs = b & 32, cs = c & 32;
  int n = 0, d = 1;
  bool zs = false;
  switch (op) {
    case 0: n = x + y; zs = as == bs ? as : mode == 2; break;
    case 1: n = x - y; zs = as != bs ? as : mode == 2; break;
    case 2: n = x * y; d = 16; zs = as != bs; break;
    case 3:
      if (!y) return {!x ? 62u : (28u | (as != bs ? 32u : 0u)), !x ? invalid : divide_by_zero};
      n = 16 * x; d = y; zs = as != bs; break;
    case 4:
      if (x < 0) return {62, invalid};
      return quantize(16 * x, 1, mode, as, true);
    case 5: n = x * y + 16 * z; d = 16; zs = (as != bs) == cs ? cs : mode == 2; break;
    default: {
      if (!y) return {62, invalid};
      int ax = x < 0 ? -x : x, ay = y < 0 ? -y : y;
      int q = ax / ay, r = ax % ay;
      if (2 * r > ay || (2 * r == ay && (q & 1))) ++q;
      n = ax - q * ay; if (as) n = -n; zs = as;
    }
  }
  return quantize(n, d, mode, zs);
}
static void check(unsigned op, unsigned a, unsigned b, unsigned c, unsigned mode) {
  tiny_float x{a}, y{b}, z{c}; auto rm = rounding_mode(mode);
  result<tiny_float> actual;
  switch (op) {
    case 0: actual = add(x, y, rm); break;
    case 1: actual = subtract(x, y, rm); break;
    case 2: actual = multiply(x, y, rm); break;
    case 3: actual = divide(x, y, rm); break;
    case 4: actual = factor::fp::sqrt(x, rm); break;
    case 5: actual = fma(x, y, z, rm); break;
    default: actual = remainder(x, y, rm); break;
  }
  auto e = reference(op, a, b, c, mode);
  if (actual.value.bits != e.bits || actual.raised != e.flags) {
    fprintf(stderr, "exact oracle op=%u a=%u b=%u c=%u mode=%u expected=%u/%u actual=%u/%u\n",
            op, a, b, c, mode, e.bits, e.flags, actual.value.bits, actual.raised);
    exit(1);
  }
}
int main() {
  unsigned long count = 0;
  for (unsigned mode = 0; mode < 5; ++mode)
    for (unsigned a = 0; a < 64; ++a) if (((a >> 2) & 7) != 7)
      for (unsigned b = 0; b < 64; ++b) if (((b >> 2) & 7) != 7) {
        for (unsigned op = 0; op < 7; ++op) if (op != 5) { check(op, a, b, 0, mode); ++count; }
        for (unsigned c = 0; c < 64; ++c) if (((c >> 2) & 7) != 7) { check(5, a, b, c, mode); ++count; }
      }
  printf("%lu exhaustive exact rational/square-root comparisons passed\n", count);
}
