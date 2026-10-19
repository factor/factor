#define _GNU_SOURCE
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <ucontext.h>
#if defined(__NetBSD__)
#define PCS_HEAD(c) ((c)->uc_mcontext.__gregs[_REG_PCSQH])
#define PCS_TAIL(c) ((c)->uc_mcontext.__gregs[_REG_PCSQT])
#define NATIVE_SP(c) ((c)->uc_mcontext.__gregs[_REG_SP])
#define PC_HEAD(c) ((c)->uc_mcontext.__gregs[_REG_PCOQH])
#define PC_TAIL(c) ((c)->uc_mcontext.__gregs[_REG_PCOQT])
#else
#define PCS_HEAD(c) ((c)->uc_mcontext.sc_iasq[0])
#define PCS_TAIL(c) ((c)->uc_mcontext.sc_iasq[1])
#define NATIVE_SP(c) ((c)->uc_mcontext.sc_gr[30])
#define PC_HEAD(c) ((c)->uc_mcontext.sc_iaoq[0])
#define PC_TAIL(c) ((c)->uc_mcontext.sc_iaoq[1])
#endif
extern unsigned hppa_fault(void);
extern char hppa_resume[];
static volatile sig_atomic_t redirected;
static uintptr_t saved_space[2], saved_sp;
static void handler(int sig,siginfo_t *info,void *raw) {
 ucontext_t* c=raw;
 if(sig!=SIGSEGV || info->si_addr!=0) _Exit(2);
 saved_space[0]=PCS_HEAD(c); saved_space[1]=PCS_TAIL(c); saved_sp=NATIVE_SP(c);
 // Both queue entries must be redirected, preserving their user privilege bits.
 uintptr_t pc=(uintptr_t)hppa_resume|(PC_HEAD(c)&3);
 PC_HEAD(c)=pc; PC_TAIL(c)=pc+4;
 redirected++;
}
int main(void) {
 struct sigaction sa={.sa_sigaction=handler,.sa_flags=SA_SIGINFO}; sigemptyset(&sa.sa_mask);
 if(sigaction(SIGSEGV,&sa,0)) return 1;
 unsigned result=hppa_fault();
 printf("pointer=%zu long=%zu redirect=%d result=%u native-sp=%lx spaces=%lx,%lx target=%lx\n",sizeof(void*),sizeof(long),redirected,result,(unsigned long)saved_sp,(unsigned long)saved_space[0],(unsigned long)saved_space[1],(unsigned long)(uintptr_t)hppa_resume);
 return !(redirected==1 && result==42 && saved_sp);
}
