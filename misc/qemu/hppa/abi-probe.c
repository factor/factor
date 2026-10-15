#define _GNU_SOURCE
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <signal.h>
#include <ucontext.h>
#include <stdatomic.h>
struct pair { unsigned a, b; };
static volatile uintptr_t outer_sp, inner_sp;
static volatile sig_atomic_t signals;
static uintptr_t stack_pointer(void) { uintptr_t v; __asm__ volatile("copy %%r30,%0" : "=r"(v)); return v; }
__attribute__((noinline)) static unsigned callee(unsigned n) { volatile unsigned frame[32]; frame[0]=n; __asm__ volatile("" : : "r"(frame) : "memory"); inner_sp=stack_pointer(); return frame[0]+1; }
__attribute__((noinline)) static struct pair aggregate(struct pair v) { v.a+=3; v.b+=5; return v; }
__attribute__((noinline)) static double fp(double a, float b) { return a+b; }
__attribute__((noinline)) static double varargs(unsigned n,...) { va_list a; va_start(a,n); double v=0; while(n--) v+=va_arg(a,double); va_end(a); return v; }
static void signal_handler(int n,siginfo_t *info,void *raw) { (void)n;(void)info; ucontext_t *c=raw; if(c->uc_mcontext.sc_gr[30] && c->uc_mcontext.sc_iaoq[1]==c->uc_mcontext.sc_iaoq[0]+4) signals++; }
int main(void) {
 unsigned (*volatile fn)(unsigned)=callee;
 outer_sp=stack_pointer(); unsigned result=fn(41);
 uintptr_t plabel=(uintptr_t)fn;
 struct pair p=aggregate((struct pair){7,11});
 struct sigaction sa={.sa_sigaction=signal_handler,.sa_flags=SA_SIGINFO}; sigemptyset(&sa.sa_mask); if(sigaction(SIGUSR1,&sa,0)||raise(SIGUSR1)) return 2;
 _Atomic(unsigned) atomic=1; unsigned previous=atomic_fetch_add(&atomic,2);
 unsigned char bytes[4]; uint32_t word=0x12345678; __builtin_memcpy(bytes,&word,4);
 printf("pointer=%zu long=%zu double=%zu endian=%02x%02x%02x%02x stack=%s outer=%lx inner=%lx plabel=%lx tag=%lu callback=%u aggregate=%u,%u fp=%.2f varargs=%.2f signal=%d atomic=%u,%u lockfree=%d ucontext=%zu gr=%zu iaoq=%zu iasq=%zu fr=%zu\n",sizeof(void*),sizeof(long),sizeof(double),bytes[0],bytes[1],bytes[2],bytes[3],inner_sp>outer_sp?"up":"down",(unsigned long)outer_sp,(unsigned long)inner_sp,(unsigned long)plabel,(unsigned long)(plabel&3),result,p.a,p.b,fp(2.5,1.25f),varargs(3,1.25,2.5,4.0),signals,previous,atomic_load(&atomic),atomic_is_lock_free(&atomic),sizeof(ucontext_t),offsetof(ucontext_t,uc_mcontext.sc_gr),offsetof(ucontext_t,uc_mcontext.sc_iaoq),offsetof(ucontext_t,uc_mcontext.sc_iasq),offsetof(ucontext_t,uc_mcontext.sc_fr));
 return !(sizeof(void*)==4 && bytes[0]==0x12 && inner_sp>outer_sp && result==42 && p.a==10 && p.b==16 && fp(2.5,1.25f)==3.75 && varargs(3,1.25,2.5,4.0)==7.75 && signals==1 && previous==1 && atomic==3);
}
