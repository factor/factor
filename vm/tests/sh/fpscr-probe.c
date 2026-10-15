/* SH4 hardware environment control probe; execute with the target ABI. */
#define _GNU_SOURCE
#include <fenv.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <ucontext.h>
static sigjmp_buf trap_return;
static volatile sig_atomic_t trapped,trap_code;
static volatile unsigned trap_fpscr,trap_pc;
static void trap_handler(int sig,siginfo_t *info,void *context) {
 ucontext_t *uc=(ucontext_t *)context;
 trapped=sig;trap_code=info->si_code;trap_fpscr=uc->uc_mcontext.fpscr;
 trap_pc=uc->uc_mcontext.pc;siglongjmp(trap_return,1);
}
extern void sh4_get_env_probe(unsigned *);
extern void sh4_set_env_probe(const unsigned *);
static unsigned read_fpscr(void) {unsigned v;sh4_get_env_probe(&v);return v;}
static void write_fpscr(unsigned v) {sh4_set_env_probe(&v);}
static uint64_t divide(double a,double b) { volatile double x=a,y=b,z=x/y;uint64_t u;memcpy(&u,(const void *)&z,8);return u; }
static void multiply(double a,double b) {volatile double x=a,y=b,z=x*y;(void)z;}
int main(int argc,char **argv) {
 (void)argv;setbuf(stdout,NULL);
 unsigned original=read_fpscr(),base=(original&~0x7ffffU)|0x80000U,got;int ok=1;
 printf("original=%08x flags=%x rounding=%x/%x sizeof-fenv=%zu\n",original,FE_ALL_EXCEPT,FE_TONEAREST,FE_TOWARDZERO,sizeof(fenv_t));
 write_fpscr(base);uint64_t near=divide(1.,5.);got=read_fpscr();printf("nearest=%016llx fpscr=%08x\n",(unsigned long long)near,got);ok&=near==0x3fc999999999999aULL&&(got&FE_INEXACT);
 write_fpscr(base|1);uint64_t zero=divide(1.,5.);got=read_fpscr();printf("zero=%016llx fpscr=%08x\n",(unsigned long long)zero,got);ok&=zero==0x3fc9999999999999ULL;
 write_fpscr(base);divide(1.,0.);got=read_fpscr();printf("zero-divide-fpscr=%08x\n",got);ok&=(got&FE_DIVBYZERO)!=0;
 write_fpscr(base);divide(0.,0.);got=read_fpscr();printf("invalid-fpscr=%08x\n",got);ok&=(got&FE_INVALID)!=0;
 write_fpscr(base);multiply(1e300,1e300);got=read_fpscr();printf("overflow-fpscr=%08x\n",got);ok&=(got&FE_OVERFLOW)!=0;
 write_fpscr(base);multiply(1e-300,1e-300);got=read_fpscr();printf("underflow-fpscr=%08x\n",got);ok&=(got&FE_UNDERFLOW)!=0;
 write_fpscr(base|0xf80|0x40000|FE_ALL_EXCEPT);got=read_fpscr();printf("control-roundtrip=%08x\n",got);ok&=(got&0xc0ffc)==(base|0xf80|0x40000|FE_ALL_EXCEPT);
 struct sigaction action={0};action.sa_sigaction=trap_handler;action.sa_flags=SA_SIGINFO;sigemptyset(&action.sa_mask);sigaction(SIGFPE,&action,NULL);
 const unsigned enables[]={0x400,0x800,0x80,0x200,0x100};
 const int codes[]={FPE_FLTDIV,FPE_FLTINV,FPE_FLTRES,FPE_FLTOVF,FPE_FLTUND};
 for(unsigned i=0;i<(argc>1?5U:0U);i++) {
  trapped=0;
  if (!sigsetjmp(trap_return,1)) {
   write_fpscr(base|enables[i]);
   switch(i) {case 0:divide(1.,0.);break;case 1:divide(0.,0.);break;
    case 2:divide(1.,3.);break;case 3:multiply(1e300,1e300);break;
    default:multiply(1e-300,1e-300);break;}
  }
  write_fpscr(base);printf("trap-mask=%03x delivered=%d code=%d fpscr=%08x pc=%08x\n",enables[i],trapped==SIGFPE,trap_code,trap_fpscr,trap_pc);ok&=trapped==SIGFPE&&trap_code==codes[i]&&trap_pc&&(trap_fpscr&enables[i]);
 }
 write_fpscr(original);ok&=read_fpscr()==original;printf("restored=%d controls=%d\n",read_fpscr()==original,ok);return !ok;
}
