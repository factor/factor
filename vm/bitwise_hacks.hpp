namespace factor {

inline cell log2(cell x) {
  cell n;
#if defined(FACTOR_X86)
#if defined(_MSC_VER)
  _BitScanReverse((unsigned long*)&n, x);
#else
  asm("bsr %1, %0;" : "=r"(n) : "r"(x));
#endif

#elif defined(FACTOR_AMD64)
#if defined(_MSC_VER)
  n = 0;
  _BitScanReverse64((unsigned long*)&n, x);
#else
  asm("bsr %1, %0;" : "=r"(n) : "r"(x));
#endif

#elif defined(FACTOR_ARM32)
#if defined(_MSC_VER)
  _BitScanReverse((unsigned long*)&n, x);
#else
  n = (31 - __builtin_clz(x));
#endif

#elif defined(FACTOR_ARM64)
#if defined(_MSC_VER)
  n = 0;
  _BitScanReverse64((unsigned long*)&n, x);
#else
  n = (63 - __builtin_clzll(x));
#endif

#elif defined(FACTOR_PPC32)
#if defined(__GNUC__)
  n = (31 - __builtin_clz(x));
#else
#error Unsupported compiler
#endif

#elif defined(FACTOR_PPC64)
#if defined(__GNUC__)
  n = (63 - __builtin_clzll(x));
#else
#error Unsupported compiler
#endif

#else
#error Unsupported CPU
#endif
  return n;
}

inline cell rightmost_clear_bit(cell x) { return log2(~x & (x + 1)); }

inline cell rightmost_set_bit(cell x) { return log2(x & (~x + 1)); }

inline cell popcount(cell x) {
#if defined(__GNUC__)
#ifdef FACTOR_64
  return __builtin_popcountll(x);
#else
  return __builtin_popcount(x);
#endif
#else
#ifdef FACTOR_64
  uint64_t k1 = 0x5555555555555555ll;
  uint64_t k2 = 0x3333333333333333ll;
  uint64_t k4 = 0x0f0f0f0f0f0f0f0fll;
  uint64_t kf = 0x0101010101010101ll;
  cell ks = 56;
#else
  uint32_t k1 = 0x55555555;
  uint32_t k2 = 0x33333333;
  uint32_t k4 = 0xf0f0f0f;
  uint32_t kf = 0x1010101;
  cell ks = 24;
#endif

  x = x - ((x >> 1) & k1);         // put count of each 2 bits into those 2 bits
  x = (x & k2) + ((x >> 2) & k2);  // put count of each 4 bits into those 4 bits
  x = (x + (x >> 4)) & k4;         // put count of each 8 bits into those 8 bits
  x = (x * kf) >> ks;  // returns 8 most significant bits of x + (x<<8) +
                       // (x<<16) + (x<<24) + ...

  return x;
#endif
}

inline bool bitmap_p(uint8_t* bitmap, cell index) {
  cell byte = index >> 3;
  cell bit = index & 7;
  return (bitmap[byte] & (1 << bit)) != 0;
}

}
