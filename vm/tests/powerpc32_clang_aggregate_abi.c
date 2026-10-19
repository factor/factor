#include <complex.h>
#include <stdio.h>
_Complex double cd(void) { return 1.0 + 2.0 * I; }
_Complex float cf(void) { return 3.0f + 4.0f * I; }
extern void probe_cd(double*); extern void probe_cf(float*);
struct captured { double d[2]; float f[2]; unsigned after; };
extern void probe_args(struct captured*, _Complex double, _Complex float, unsigned);
struct small { unsigned x; };
struct small small(void) { return (struct small){42}; }
extern void probe_small(unsigned*);
extern void probe_small_arg(unsigned*, struct small, unsigned);
struct bytes3 { unsigned char bytes[3]; };
struct bytes5 { unsigned char bytes[5]; };
struct bytes3 bytes3(void) { return (struct bytes3){{1,2,3}}; }
struct bytes5 bytes5(void) { return (struct bytes5){{1,2,3,4,5}}; }
extern void probe_bytes3(unsigned*); extern void probe_bytes5(unsigned*);
extern void probe_pair(unsigned*, unsigned long long, unsigned);
extern void probe_stack_pair(unsigned*,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned long long);
int main(void) { unsigned pair[3]={0}; probe_pair(pair,0x1122334455667788ULL,0xaabbccdd); if(pair[0]!=0x11223344||pair[1]!=0x55667788||pair[2]!=0xaabbccdd)return 7; probe_stack_pair(pair,1,2,3,4,5,6,7,8,0x1122334455667788ULL); if(pair[0]!=0x11223344||pair[1]!=0x55667788||pair[2]!=8)return 8; unsigned raw[2]={0}; probe_bytes3(raw); if(raw[0]!=0x010203)return 5; probe_bytes5(raw); if(raw[0]!=1||raw[1]!=0x02030405)return 6; unsigned small_out=0; probe_small(&small_out); if(small_out!=42)return 3; small_out=0; probe_small_arg(&small_out,(struct small){41},1); if(small_out!=42)return 4; double d[2]={0};float f[2]={0};probe_cd(d);probe_cf(f);printf("Clang PPC32 complex values double=%g,%g float=%g,%g\n",d[0],d[1],f[0],f[1]);if(!(d[0]==1&&d[1]==2&&f[0]==3&&f[1]==4))return 1;struct captured args={{0},{0},0};probe_args(&args,1.0+2.0*I,3.0f+4.0f*I,0x12345678);if(args.d[0]!=1||args.d[1]!=2||args.f[0]!=3||args.f[1]!=4||args.after!=0x12345678)return 2;puts("PASS Clang PPC32 complex hidden/by-reference ABI");return 0; }
