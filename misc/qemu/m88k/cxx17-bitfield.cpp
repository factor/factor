extern "C" unsigned long long m88k_extract_low1(unsigned long long x) { return x & 1; }
extern "C" unsigned long long m88k_extract_low32(unsigned long long x) { return x & 0xffffffffull; }
extern "C" unsigned long long m88k_extract_high32(unsigned long long x) { return x >> 32; }
extern "C" unsigned long long m88k_extract_cross(unsigned long long x) { return (x >> 28) & 0xfffull; }
extern "C" long long m88k_extract_signed_cross(unsigned long long x) { return (long long)(x << 24) >> 52; }
extern "C" long long m88k_extract_signed_high(unsigned long long x) { return (long long)x >> 32; }
