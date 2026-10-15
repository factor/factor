#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/wait.h>
#include <unistd.h>
static unsigned read_fpcr(void){unsigned x;__asm__ volatile("fmove.l %%fpcr,%0":"=d"(x));return x;}
static unsigned read_fpsr(void){unsigned x;__asm__ volatile("fmove.l %%fpsr,%0":"=d"(x));return x;}
static void fpcr(unsigned x){__asm__ volatile("fmove.l %0,%%fpcr"::"d"(x));}
static void fpsr(unsigned x){__asm__ volatile("fmove.l %0,%%fpsr"::"d"(x));}
static double operation(double a,double b,int divide){double result;if(divide){__asm__ volatile("fmove.d %1,%%fp0\n\tfmove.d %2,%%fp1\n\tfdiv.x %%fp1,%%fp0\n\tfmove.d %%fp0,%0":"=m"(result):"m"(a),"m"(b):"fp0","fp1");}else{__asm__ volatile("fmove.d %1,%%fp0\n\tfmove.d %2,%%fp1\n\tfmul.x %%fp1,%%fp0\n\tfmove.d %%fp0,%0":"=m"(result):"m"(a),"m"(b):"fp0","fp1");}return result;}
static uint64_t bits(double x){uint64_t u;memcpy(&u,&x,8);return u;}
static unsigned failures;
#define CHECK(c) do{if(!(c)){fprintf(stderr,"line %u: %s\n",__LINE__,#c);failures++;}}while(0)
int main(void){
 unsigned saved_control=read_fpcr(),saved_status=read_fpsr();
 const unsigned traps[]={0xe000,0x1000,0x0800,0x0400,0x0300};
 for(unsigned i=0;i<5;i++){fpcr(0x80|traps[i]);CHECK(read_fpcr()==(0x80|traps[i]));}
 fpcr(0x80);fpsr(0x0a5afff8);fpsr(read_fpsr()&~0xfff8u);CHECK((read_fpsr()&0xfff8)==0);CHECK((read_fpsr()&0xffff0000)==0x0a5a0000);
 const unsigned modes[]={0,0x10,0x20,0x30};
 const uint64_t expected[]={0x3fc999999999999aULL,0x3fc9999999999999ULL,0x3fc9999999999999ULL,0x3fc999999999999aULL};
 for(unsigned i=0;i<4;i++){fpcr(0x80|modes[i]);CHECK(read_fpcr()==(0x80|modes[i]));CHECK(bits(operation(1,5,1))==expected[i]);}
 fpcr(0x80);
 fpsr(0);operation(1,0,1);CHECK(read_fpsr()&0x10);
 fpsr(0);operation(0,0,1);CHECK(read_fpsr()&0x80);
 fpsr(0);operation(0x1.fffffffffffffp1023,2,0);CHECK(read_fpsr()&0x40);
 fpsr(0);operation(0x1p-1074,0.5,0);CHECK((read_fpsr()&0x28)==0x28);
 fpsr(0);operation(1,3,1);CHECK(read_fpsr()&0x08);
 puts("M68k FPCR/FPSR register, flags and rounding checks: PASS");
 /* A child must receive the real hardware exception signal. */
 pid_t child=fork();CHECK(child>=0);
 if(child==0){signal(SIGFPE,SIG_DFL);fpsr(0);fpcr(0x0480);operation(1,0,1);_exit(99);}
 if(child>0){int status=0;CHECK(waitpid(child,&status,0)==child);printf("enabled divide-zero trap: child status=%d\n",status);CHECK(WIFSIGNALED(status)&&WTERMSIG(status)==SIGFPE);}
 fpcr(saved_control);fpsr(saved_status);
 if(failures)return 1;
 puts("M68k FPCR/FPSR flags, rounding and SIGFPE: PASS");return 0;
}
