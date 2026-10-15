#define _GNU_SOURCE
#include <stdatomic.h>
#include <signal.h>
#include <sys/time.h>
#include <stdio.h>
_Static_assert(__atomic_always_lock_free(4,0), "signal counter must be lock-free");
_Static_assert(__atomic_always_lock_free(1,0), "publication byte must be lock-free");
static _Atomic unsigned counter;
static _Atomic unsigned char published;
static volatile sig_atomic_t interrupts;
static void sample(int signum) {
 (void)signum;
 atomic_fetch_add_explicit(&counter,1,memory_order_relaxed);
 atomic_store_explicit(&published,1,memory_order_release);
 interrupts++;
}
int main(void) {
 struct sigaction action={.sa_handler=sample};sigemptyset(&action.sa_mask);
 if(sigaction(SIGALRM,&action,0))return 2;
 struct itimerval timer={{0,1000},{0,1000}};
 if(setitimer(ITIMER_REAL,&timer,0))return 3;
 const unsigned iterations=200000;
 unsigned observations=0;
 for(unsigned i=0;i<iterations;i++) {
  atomic_fetch_add_explicit(&counter,1,memory_order_relaxed);
  observations+=atomic_load_explicit(&published,memory_order_acquire)!=0;
 }
 sigset_t mask;sigemptyset(&mask);sigaddset(&mask,SIGALRM);
 if(sigprocmask(SIG_BLOCK,&mask,0))return 4;
 timer=(struct itimerval){{0,0},{0,0}};
 if(setitimer(ITIMER_REAL,&timer,0))return 5;
 unsigned actual=atomic_load(&counter),expected=iterations+(unsigned)interrupts;
 printf("HPPA signal atomics: iterations=%u interrupts=%d counter=%u expected=%u byte_observations=%u lockfree_word=%d lockfree_byte=%d\n",iterations,interrupts,actual,expected,observations,atomic_is_lock_free(&counter),atomic_is_lock_free(&published));
 return !(interrupts>0 && observations>0 && actual==expected);
}
