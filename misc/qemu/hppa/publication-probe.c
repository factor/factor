#include <signal.h>
#include <sys/time.h>
#include <stdio.h>
static volatile unsigned word;
static volatile unsigned char byte;
static volatile sig_atomic_t interrupts;
__attribute__((noinline)) unsigned load_word(void) {return __atomic_load_n(&word,__ATOMIC_SEQ_CST);}
__attribute__((noinline)) unsigned char load_byte(void) {return __atomic_load_n(&byte,__ATOMIC_SEQ_CST);}
__attribute__((noinline)) void store_word(unsigned v) {__atomic_store_n(&word,v,__ATOMIC_SEQ_CST);}
__attribute__((noinline)) void store_byte(unsigned char v) {__atomic_store_n(&byte,v,__ATOMIC_SEQ_CST);}
static void handler(int n) {(void)n;store_word(42);store_byte(1);interrupts++;}
int main(void) {
 struct sigaction sa={.sa_handler=handler};sigemptyset(&sa.sa_mask);
 if(sigaction(SIGALRM,&sa,0))return 2;
 struct itimerval t={{0,1000},{0,1000}};if(setitimer(ITIMER_REAL,&t,0))return 3;
 unsigned observed=0;
 for(unsigned i=0;i<10000000;i++)observed+=load_byte()==1&&load_word()==42;
 sigset_t block;sigemptyset(&block);sigaddset(&block,SIGALRM);sigprocmask(SIG_BLOCK,&block,0);
 t=(struct itimerval){{0,0},{0,0}};setitimer(ITIMER_REAL,&t,0);
 printf("pointer=%zu long=%zu lockfreequery_word=%d lockfreequery_byte=%d interrupts=%d observed=%u\n",sizeof(void*),sizeof(long),__atomic_always_lock_free(4,0),__atomic_always_lock_free(1,0),interrupts,observed);
 return !(interrupts>0&&observed>0);
}
