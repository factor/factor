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
#include "atomic-netbsd-hppa.cpp"
static volatile uint32_t counter;
static volatile sig_atomic_t signals;
static int supported;
static volatile sig_atomic_t cas_mode;
static int initialize(void) {return supported=factor::atomic::ras::initialize();}
static uint32_t add(volatile uint32_t*p,uint32_t n){return factor::atomic::ras::fetch_add(p,n);}
static void increment(void){
 if(!cas_mode){add(&counter,1);return;}
 uint32_t old;
 do{old=counter;}while(!factor::atomic::ras::cas(&counter,old,old+1));
}
static void handler(int sig){(void)sig;increment();++signals;}
static void require(int value,const char*name){if(!value){perror(name);exit(1);}}
int main(void){
 pid_t failure=fork();require(failure>=0,"registration failure fork");
 if(failure==0){
  size_t length=factor_ras_add_end-factor_ras_add_start;
  require(rasctl(factor_ras_add_start,length,RAS_INSTALL)==0,"overlap setup");
  require(!initialize()&&!factor::atomic::ras::available(),"registration failure");
  add(&counter,1);_exit(1);
 }
 int failure_status;
 require(waitpid(failure,&failure_status,0)==failure&&WIFSIGNALED(failure_status)&&WTERMSIG(failure_status)==SIGABRT,"unavailable RMW refusal");
 require(initialize()&&initialize()&&factor::atomic::ras::available(),"RAS registration");
 require(factor::atomic::ras::cas(&counter,0,7)&&counter==7,"CAS success");
 require(!factor::atomic::ras::cas(&counter,0,9)&&counter==7,"CAS failure");
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
 printf("HPPA NetBSD UP RAS registration/signal/fork/refusal passed main=%u signals=%u total=%u\n",n,observed,(unsigned)counter);
 return 0;
}
