/* Compile with native GNU cc -O0 -fno-fast-math. Inspect / instructions.
 * MC88100 hardware precise traps must reach OpenBSD's software FPU handler.
 */
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>
#include <stdlib.h>
static sigjmp_buf escape;
static volatile sig_atomic_t caught;
static void handler(int sig) { caught = sig; siglongjmp(escape, 1); }
static unsigned fpsr(void) { unsigned v; __asm__ volatile("fldcr %0, %%fcr62":"=r"(v)); return v; }
static unsigned fpcr(void) { unsigned v; __asm__ volatile("fldcr %0, %%fcr63":"=r"(v)); return v; }
static void controls(unsigned status,unsigned control) {
 __asm__ volatile("fstcr %0, %%fcr62\n\tfstcr %1, %%fcr63"::"r"(status),"r"(control));
}
static double ddiv(double a,double b) { volatile double x=a,y=b; return x/y; }
static float sdiv(float a,float b) { volatile float x=a,y=b; return x/y; }
static int checkd(const char *name,uint64_t a,uint64_t b,uint64_t want,unsigned flags,int nan) {
 union { uint64_t u; double d; } x,y,z; x.u=a;y.u=b;
 controls(1,0); z.d=ddiv(x.d,y.d);
 int ok=(nan ? ((z.u & UINT64_C(0x7ff0000000000000)) == UINT64_C(0x7ff0000000000000) && (z.u & UINT64_C(0xfffffffffffff)) != 0 && (z.u & UINT64_C(0x8000000000000))) : z.u==want) && fpsr()==(1|flags) && fpcr()==0;
 printf("double %s result=%016llx fpsr=%x fpcr=%x %s\n",name,(unsigned long long)z.u,fpsr(),fpcr(),ok?"PASS":"FAIL"); return !ok;
}
static int checks(const char *name,uint32_t a,uint32_t b,uint32_t want,unsigned flags,int nan) {
 union { uint32_t u; float f; } x,y,z; x.u=a;y.u=b;
 controls(1,0); z.f=sdiv(x.f,y.f);
 int ok=(nan ? ((z.u & 0x7f800000)==0x7f800000 && (z.u & 0x7fffff)!=0 && (z.u & 0x400000)) : z.u==want) && fpsr()==(1|flags) && fpcr()==0;
 printf("single %s result=%08x fpsr=%x fpcr=%x %s\n",name,z.u,fpsr(),fpcr(),ok?"PASS":"FAIL");return !ok;
}
static int trap(unsigned mask,double a,double b) {
 caught=0; controls(0,mask);
 if(sigsetjmp(escape,1)==0) { volatile double result=ddiv(a,b); (void)result; }
 unsigned status=fpsr(); controls(0,0);
 int ok=caught==SIGFPE && (status&mask)==mask;
 printf("enabled mask=%x signal=%d fpsr=%x %s\n",mask,(int)caught,status,ok?"PASS":"FAIL");return !ok;
}
static int delay_div(void) {
 double a=1.0,b=0.0,z;unsigned skipped=0;
 controls(0,0);
 __asm__ volatile("br.n 1f\n\tfdiv.ddd %0,%2,%3\n\tor %1,%%r0,1\n1:"
    : "=&r"(z),"+r"(skipped):"r"(a),"r"(b));
 union { double d; uint64_t u; } result;result.d=z;
 int ok=result.u==0x7ff0000000000000ULL && skipped==0 && fpsr()==8;
 printf("delay result=%016llx fallthrough=%u fpsr=%x %s\n",(unsigned long long)result.u,skipped,fpsr(),ok?"PASS":"FAIL");return !ok;
}
int main(void) {
 int bad=0;signal(SIGFPE,handler);
 bad+=checkd("finite",0x4018000000000000ULL,0x4008000000000000ULL,0x4000000000000000ULL,0,0);
 bad+=checkd("positive-zero",0x3ff0000000000000ULL,0,0x7ff0000000000000ULL,8,0);
 bad+=checkd("negative-numerator",0xbff0000000000000ULL,0,0xfff0000000000000ULL,8,0);
 bad+=checkd("negative-zero",0x3ff0000000000000ULL,0x8000000000000000ULL,0xfff0000000000000ULL,8,0);
 bad+=checkd("zero-zero",0,0,0,16,1);
 bad+=checks("finite",0x40c00000,0x40400000,0x40000000,0,0);
 bad+=checks("positive-zero",0x3f800000,0,0x7f800000,8,0);
 bad+=checks("negative-zero",0x3f800000,0x80000000,0xff800000,8,0);
 bad+=checks("zero-zero",0,0,0,16,1);
 bad+=checkd("inf-inf",0x7ff0000000000000ULL,0x7ff0000000000000ULL,0,16,1);
 bad+=checkd("quiet-nan",0x7ff8000000000123ULL,0x3ff0000000000000ULL,0,0,1);
 bad+=checkd("denormal",1,0x3ff0000000000000ULL,1,0,0);
 bad+=checks("inf-inf",0x7f800000,0x7f800000,0,16,1);
 bad+=checks("quiet-nan",0x7fc00123,0x3f800000,0,0,1);
 bad+=checks("denormal",1,0x3f800000,1,0,0);
 bad+=delay_div();
 bad+=trap(8,1.0,0.0);bad+=trap(16,0.0,0.0);
 controls(0,0);printf("failures=%d\n",bad);return bad!=0;
}
