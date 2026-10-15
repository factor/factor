extern "C" int m88k_abs(int x) { return __builtin_abs(x); }
extern "C" int m88k_fpclass(double x) { return __builtin_isfinite(x) + 2*__builtin_isnan(x) + 4*!!__builtin_isinf(x); }
extern "C" double m88k_ceil(double x) { return __builtin_ceil(x); }
extern "C" float m88k_ceilf(float x) { return __builtin_ceilf(x); }
