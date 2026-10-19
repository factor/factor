/* Native GNU MC88100 SIGFPE handler-return and delayed branch regression.
 * Unlike siglongjmp controls, these return through OpenBSD sigreturn.
 */
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <machine/reg.h>
#include <machine/psl.h>
/* OpenBSD 7.7 m88100_fp.c maps FDVZ to FPE_INTDIV. Later kernels use
 * FPE_FLTDIV; select the exact audited kernel policy at compile time. */
#ifndef EXPECTED_FDIV_CODE
#define EXPECTED_FDIV_CODE FPE_FLTDIV
#endif
static volatile sig_atomic_t hits, bad_context, failed[6];
static volatile unsigned captured[8];
static void handler(int signo,siginfo_t *info,void *uap) {
 struct reg *r=(struct reg *)((struct sigcontext *)uap)->sc_regs;
 int wrong[6]={signo!=SIGFPE,info->si_code!=EXPECTED_FDIV_CODE,(r->fpsr&8)!=8,(r->fpcr&8)!=8,!(r->snip&NIP_V),!(r->sfip&FIP_V)};
 if(hits==0) {captured[0]=signo;captured[1]=info->si_code;captured[2]=r->fpsr;captured[3]=r->fpcr;captured[4]=r->sxip;captured[5]=r->snip;captured[6]=r->sfip;captured[7]=r->fpecr;}
 int any=0;for(int i=0;i<6;i++) {if(wrong[i]) {failed[i]++;any=1;}}if(any)bad_context++;
 hits++;
}
static void enable(void) { unsigned s=0,c=8;__asm__ volatile("fstcr %0,%%fcr62\n\tfstcr %1,%%fcr63"::"r"(s),"r"(c)); }
static double division(double a,double b) {volatile double x=a,y=b;return x/y;}
int main(void) {
 struct sigaction act;memset(&act,0,sizeof(act));act.sa_sigaction=handler;act.sa_flags=SA_SIGINFO;sigemptyset(&act.sa_mask);
 if(sigaction(SIGFPE,&act,0))return 2;
 int bad=0;
 for(int i=0;i<64;i++) {
  union {double d;uint64_t u;} z;enable();z.d=division(1.0,0.0);
  if(z.u!=0x7ff0000000000000ULL || hits!=i+1)bad++;
 }
 for(int i=0;i<64;i++) {
  double a=1.0,b=0.0,z;unsigned skipped=0;enable();
  __asm__ volatile("br.n 1f\n\tfdiv.ddd %0,%2,%3\n\tor %1,%%r0,1\n1:" : "=&r"(z),"+r"(skipped):"r"(a),"r"(b));
  union {double d;uint64_t u;} result;result.d=z;
  if(result.u!=0x7ff0000000000000ULL || skipped || hits!=65+i)bad++;
 }
 unsigned zero=0;__asm__ volatile("fstcr %0,%%fcr62\n\tfstcr %0,%%fcr63"::"r"(zero));
 printf("context signo=%x expected=%x code=%x expected=%x fpsr=%x fpcr=%x sxip=%x snip=%x sfip=%x fpecr=%x NIP_V=%x FIP_V=%x\n",captured[0],SIGFPE,captured[1],EXPECTED_FDIV_CODE,captured[2],captured[3],captured[4],captured[5],captured[6],captured[7],NIP_V,FIP_V);
 printf("context_failures signo=%d code=%d fpsr=%d fpcr=%d snip=%d sfip=%d\n",(int)failed[0],(int)failed[1],(int)failed[2],(int)failed[3],(int)failed[4],(int)failed[5]);
 printf("normal_sigreturn=%d delayed_sigreturn=%d hits=%d bad_context=%d failures=%d\n",64,64,(int)hits,(int)bad_context,bad);
 return bad!=0 || bad_context!=0;
}
