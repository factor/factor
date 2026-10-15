/* Native NetBSD/HPPA UP RAS: signal interleaving, fork, and refusal proof. */
#include <sys/types.h>
#include <sys/ras.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <stdint.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
asm(".text\n.align 4\n"
    ".globl hppa_ras_add,hppa_ras_add_start,hppa_ras_add_end\n"
    ".hidden hppa_ras_add,hppa_ras_add_start,hppa_ras_add_end\n"
    ".type hppa_ras_add,@function\nhppa_ras_add:\nhppa_ras_add_start:\n"
    "ldw 0(%r26),%r28\nadd %r28,%r25,%r20\nstw %r20,0(%r26)\n"
    "hppa_ras_add_end:\nbv,n %r0(%r2)\n"
    ".globl hppa_ras_cas,hppa_ras_cas_start,hppa_ras_cas_end\n"
    ".hidden hppa_ras_cas,hppa_ras_cas_start,hppa_ras_cas_end\n"
    ".type hppa_ras_cas,@function\nhppa_ras_cas:\nhppa_ras_cas_start:\n"
    "ldw 0(%r26),%r28\ncomb,<>,n %r25,%r28,hppa_ras_cas_end\n"
    "stw %r24,0(%r26)\nhppa_ras_cas_end:\nbv,n %r0(%r2)\n");
extern uint32_t hppa_ras_add(volatile uint32_t*,uint32_t);
extern uint32_t hppa_ras_cas(volatile uint32_t*,uint32_t,uint32_t);
extern char hppa_ras_add_start[],hppa_ras_add_end[];
extern char hppa_ras_cas_start[],hppa_ras_cas_end[];
static volatile uint32_t counter;
static volatile sig_atomic_t signals;
static int supported;
static volatile sig_atomic_t cas_mode;
static int initialize(void) {
 int mib[]={CTL_HW,HW_NCPU},cpus=0;size_t len=sizeof(cpus);
 if(sysctl(mib,2,&cpus,&len,0,0)||cpus!=1)return 0;
 size_t a=hppa_ras_add_end-hppa_ras_add_start,c=hppa_ras_cas_end-hppa_ras_cas_start;
 if(rasctl(hppa_ras_add_start,a,RAS_INSTALL))return 0;
 if(rasctl(hppa_ras_cas_start,c,RAS_INSTALL)){
  rasctl(hppa_ras_add_start,a,RAS_PURGE);return 0;
 }
 return supported=1;
}
static uint32_t add(volatile uint32_t*p,uint32_t n){
 if(!supported)abort();
 return hppa_ras_add(p,n);
}
static void increment(void){
 if(!cas_mode){add(&counter,1);return;}
 uint32_t old;
 do{old=counter;}while(hppa_ras_cas(&counter,old,old+1)!=old);
}
static void handler(int sig){(void)sig;increment();++signals;}
static void require(int value,const char*name){if(!value){perror(name);exit(1);}}
int main(void){
 require(initialize(),"RAS registration");
 require(hppa_ras_cas(&counter,0,7)==0&&counter==7,"CAS success");
 require(hppa_ras_cas(&counter,0,9)==7&&counter==7,"CAS failure");
 struct sigaction sa={0};sa.sa_handler=handler;sigemptyset(&sa.sa_mask);
 require(sigaction(SIGALRM,&sa,0)==0,"sigaction");
 const unsigned n=5000000;unsigned observed=0;
 for(unsigned mode=0;mode<2;++mode){
  sigset_t blocked;sigemptyset(&blocked);sigaddset(&blocked,SIGALRM);
  require(sigprocmask(SIG_BLOCK,&blocked,0)==0,"block timer signal");
  counter=0;signals=0;cas_mode=mode;
  struct itimerval timer={{0,100},{0,100}};
  require(setitimer(ITIMER_REAL,&timer,0)==0,"timer");
  require(sigprocmask(SIG_UNBLOCK,&blocked,0)==0,"unblock timer signal");
  for(unsigned i=0;i<n;++i)increment();
  require(sigprocmask(SIG_BLOCK,&blocked,0)==0,"block finished timer");
  timer.it_interval.tv_usec=timer.it_value.tv_usec=0;setitimer(ITIMER_REAL,&timer,0);
  require(signals>0&&counter==n+(unsigned)signals,"signal interleaving");
  printf("HPPA NetBSD UP RAS %s main=%u signals=%u total=%u passed\n",mode?"CAS loop":"fetch-add",n,(unsigned)signals,(unsigned)counter);
  observed+=signals;
 }
 fflush(stdout);
 pid_t child=fork();require(child>=0,"fork");
 if(child==0){counter=0;for(unsigned i=0;i<100000;++i)increment();_exit(counter==100000?0:1);}
 int status;require(waitpid(child,&status,0)==child&&WIFEXITED(status)&&WEXITSTATUS(status)==0,"fork inheritance");
 child=fork();require(child>=0,"failure fork");
 if(child==0){
  /* Actual overlapping registration must fail, never enabling an unregistered fallback. */
  supported=0;require(!initialize(),"duplicate RAS must fail");add(&counter,1);_exit(1);
 }
 require(waitpid(child,&status,0)==child&&WIFSIGNALED(status)&&WTERMSIG(status)==SIGABRT,"unavailable RMW refusal");
 printf("HPPA NetBSD UP RAS registration/signal/fork/refusal passed main=%u signals=%u total=%u\n",n,observed,(unsigned)counter);
 return 0;
}
