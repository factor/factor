#include <pthread.h>
#include <assert.h>
#include <stdio.h>
extern unsigned locked_add(unsigned*,unsigned),locked_sub(unsigned*,unsigned);
extern unsigned locked_and(unsigned*,unsigned),locked_or(unsigned*,unsigned);
extern unsigned locked_xor(unsigned*,unsigned),locked_exchange(unsigned*,unsigned);
extern int locked_cas(unsigned*,unsigned*,unsigned);
static unsigned count;
static void *worker(void *arg) {unsigned i; (void)arg; for(i=0;i<10000;i++) locked_add(&count,1); return 0;}
int main(void) {
 unsigned p=10,e; pthread_t t[4]; unsigned i;
 assert(locked_add(&p,3)==10 && p==13);
 assert(locked_sub(&p,5)==13 && p==8);
 assert(locked_or(&p,3)==8 && p==11);
 assert(locked_and(&p,6)==11 && p==2);
 assert(locked_xor(&p,7)==2 && p==5);
 assert(locked_exchange(&p,19)==5 && p==19);
 e=18; assert(!locked_cas(&p,&e,22) && e==19 && p==19);
 assert(locked_cas(&p,&e,22) && p==22);
 for(i=0;i<4;i++) assert(!pthread_create(&t[i],0,worker,0));
 for(i=0;i<4;i++) assert(!pthread_join(t[i],0));
 assert(count==40000);
 puts("m88k ordinary locked RMW PASS: old values, CAS outcomes, four writers 40000 updates; not signal-safe or lock-free"); return 0;
}
