#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <complex.h>
#include <signal.h>
#define DEFINE(N) \
 typedef struct { unsigned char bytes[N]; } s##N; \
 s##N ret##N(unsigned char x) { s##N s; for(int i=0;i<N;i++)s.bytes[i]=x+i; return s; } \
 unsigned arg##N(s##N s) { unsigned sum=0;for(int i=0;i<N;i++)sum+=s.bytes[i];return sum; }
DEFINE(3)
DEFINE(5)
DEFINE(8)
DEFINE(9)
float complex complex_float(float complex a,float complex b) { return a+b; }
double complex complex_double(double complex a,double complex b) { return a+b; }
static uint64_t fpscr(void) { union { double f; uint64_t u; } v; __asm__ volatile("mffs %0":"=f"(v.f)); return v.u; }
static void setfpscr(uint64_t u) { union { double f; uint64_t u; } v;v.u=u; __asm__ volatile("mtfsf 255,%0"::"f"(v.f)); }
static volatile sig_atomic_t fpe_seen;
static void fpe(int sig) { setfpscr(fpscr() & ~UINT64_C(0xfff80000)); fpe_seen=sig; }
int main(void) {
 unsigned a=arg3(ret3(1)),b=arg5(ret5(1)),c=arg8(ret8(1)),d=arg9(ret9(1));
 float complex f=complex_float(1.25f+2.5f*I,3.5f+4.25f*I);double complex z=complex_double(1.25+2.5*I,3.5+4.25*I);
 printf("aggregates sizes=%zu,%zu,%zu,%zu sums=%u,%u,%u,%u complex_float=%g,%g complex_double=%g,%g\n",sizeof(s3),sizeof(s5),sizeof(s8),sizeof(s9),a,b,c,d,crealf(f),cimagf(f),creal(z),cimag(z));
 uint64_t before=fpscr();setfpscr(0);volatile double zero=0.0,invalid=zero/zero;(void)invalid;uint64_t sticky=fpscr();
 signal(SIGFPE,fpe);raise(SIGFPE);uint64_t cleared=fpscr();setfpscr(before);
 printf("fpscr before=%llx sticky=%llx after_SIGFPE=%llx signal=%d\n",(unsigned long long)before,(unsigned long long)sticky,(unsigned long long)cleared,(int)fpe_seen);
 return a==6&&b==15&&c==36&&d==45&&crealf(f)==4.75f&&cimagf(f)==6.75f&&creal(z)==4.75&&cimag(z)==6.75&&(sticky&UINT64_C(0xfff80000))&&cleared==sticky&&fpe_seen==SIGFPE?0:1;
}
