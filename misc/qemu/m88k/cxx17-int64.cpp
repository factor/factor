// A 32-bit VM still needs native 64-bit arithmetic and FFI register pairs.
extern "C" unsigned long long m88k_cxx17_int64(unsigned long long value) {
    return value + 0x123456789ULL;
}
