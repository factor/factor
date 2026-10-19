// Freestanding language/codegen gate before a modern C++ runtime is available.
// Link with the native guest's C linker; no standard-library ABI is implied.
template<class T> constexpr T scale(T a, T b) {
    if constexpr (sizeof(T) == 4) return a * 7 + b;
    else return a + b;
}
extern "C" unsigned m88k_cxx17_integer(unsigned a, unsigned b) {
    struct pair { unsigned first, second; } values{a, b};
    auto [first, second] = values;
    return scale(first, second);
}
extern "C" double m88k_cxx17_fp(double a, double b) {
    auto operation = [](double x, double y) { return x * 2.0 + y; };
    return operation(a, b);
}
