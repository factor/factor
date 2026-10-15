/* Supplemental native GNU assembly controls for both mixed division variants. */
#include <stdint.h>
#include <stdio.h>
static unsigned status(void) { unsigned x;__asm__ volatile("fldcr %0,%%fcr62":"=r"(x));return x; }
static unsigned control(void) { unsigned x;__asm__ volatile("fldcr %0,%%fcr63":"=r"(x));return x; }
static void reset(void) { unsigned s=1,c=0xc000;__asm__ volatile("fstcr %0,%%fcr62\n\tfstcr %1,%%fcr63"::"r"(s),"r"(c)); }
static double dss(float a,float b) { double z;__asm__ volatile("fdiv.dss %0,%1,%2":"=r"(z):"r"(a),"r"(b));return z; }
static double dsd(float a,double b) { double z;__asm__ volatile("fdiv.dsd %0,%1,%2":"=r"(z):"r"(a),"r"(b));return z; }
static int check(const char *name,double z,uint64_t want,unsigned sr) {
 union { double d;uint64_t u; } v;v.d=z;
 int ok=v.u==want && status()==sr && control()==0xc000;
 printf("%s result=%016llx fpsr=%x fpcr=%x %s\n",name,(unsigned long long)v.u,status(),control(),ok?"PASS":"FAIL");return !ok;
}
int main(void) {
 int bad=0;reset();bad+=check("dss-zero",dss(1.0f,0.0f),0x7ff0000000000000ULL,9);
 reset();bad+=check("dsd-zero",dsd(-1.0f,0.0),0xfff0000000000000ULL,9);
 union { float f;uint32_t u; } tiny;tiny.u=1;
 reset();bad+=check("dss-denormal",dss(tiny.f,1.0f),0x36a0000000000000ULL,1);
 reset();bad+=check("dsd-denormal",dsd(tiny.f,1.0),0x36a0000000000000ULL,1);
 unsigned zero=0;__asm__ volatile("fstcr %0,%%fcr62\n\tfstcr %0,%%fcr63"::"r"(zero));
 printf("failures=%d\n",bad);return bad!=0;
}
