#include <complex.h>
#include <stdio.h>
_Complex double cd(void) { return 1.0 + 2.0 * I; }
_Complex float cf(void) { return 3.0f + 4.0f * I; }
extern void probe_cd(double*); extern void probe_cf(float*);
struct captured { double d[2]; float f[2]; unsigned after; };
extern void probe_args(struct captured*, _Complex double, _Complex float, unsigned);
int main(void) { double d[2]={0};float f[2]={0};probe_cd(d);probe_cf(f);printf("complex registers double=%g,%g float=%g,%g\n",d[0],d[1],f[0],f[1]);if(!(d[0]==1&&d[1]==2&&f[0]==3&&f[1]==4))return 1;struct captured args={{0},{0},0};probe_args(&args,1.0+2.0*I,3.0f+4.0f*I,0x12345678);if(args.d[0]!=1||args.d[1]!=2||args.f[0]!=3||args.f[1]!=4||args.after!=0x12345678)return 2;puts("PASS PPC32 complex GPR argument and return classification");return 0; }
