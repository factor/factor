extern "C" int runtime_narrow7(unsigned char x) {return (signed char)(x << 1) >> 1;}
extern "C" unsigned runtime_bits(unsigned x) {return (x >> 8) & 15;}
extern "C" int runtime_umulo(unsigned a,unsigned b,unsigned *out) {return __builtin_mul_overflow(a,b,out);}
extern "C" int runtime_smulo(int a,int b,int *out) {return __builtin_mul_overflow(a,b,out);}
