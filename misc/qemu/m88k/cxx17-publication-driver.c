/* Native signal/concurrency proof for the cross-produced load/store routines. */
#include <assert.h>
#include <pthread.h>
#include <sched.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
extern unsigned char m88k_publication_load8(volatile unsigned char *);
extern void m88k_publication_store8(volatile unsigned char *, unsigned char);
extern unsigned m88k_publication_load32(volatile unsigned *);
extern void m88k_publication_store32(volatile unsigned *, unsigned);
static volatile unsigned published;
static volatile unsigned char flag;
static volatile sig_atomic_t signals;
static volatile unsigned payload[2];
static volatile unsigned char ready;
static int valid(unsigned v) { return !v || v==0x55aa55aa || v==0xaa55aa55; }
static void handler(int sig) {
    unsigned v = m88k_publication_load32(&published);
    unsigned char f = m88k_publication_load8(&flag);
    assert(sig==SIGUSR1 && valid(v) && f<=1);
    ++signals;
}
static void *writer(void *arg) {
    unsigned value=(unsigned)(unsigned long)arg;
    unsigned i;
    for(i=0;i<20000;++i) {
        m88k_publication_store32(&published,value);
        m88k_publication_store8(&flag,i&1);
        assert(valid(m88k_publication_load32(&published)));
        assert(m88k_publication_load8(&flag)<=1);
    }
    return NULL;
}
static void *producer(void *arg) {
    unsigned i;
    (void)arg;
    for(i=1;i<=10000;++i) {
        while(m88k_publication_load8(&ready)) sched_yield();
        payload[0]=i; payload[1]=~i;
        m88k_publication_store8(&ready,1);
    }
    return NULL;
}
static void *consumer(void *arg) {
    unsigned i;
    (void)arg;
    for(i=1;i<=10000;++i) {
        while(!m88k_publication_load8(&ready)) sched_yield();
        assert(payload[0]==i && payload[1]==~i);
        m88k_publication_store8(&ready,0);
    }
    return NULL;
}
int main(void) {
    pthread_t threads[4];
    struct sigaction sa;
    unsigned i;
    alarm(60);
    sa.sa_handler=handler; sa.sa_flags=0;
    sigemptyset(&sa.sa_mask);
    assert(sigaction(SIGUSR1,&sa,NULL)==0);
    for(i=0;i<4;++i)
        assert(pthread_create(&threads[i],NULL,writer,
            (void *)(unsigned long)(i&1 ? 0x55aa55aa : 0xaa55aa55))==0);
    for(i=0;i<1000;++i) {
        assert(valid(m88k_publication_load32(&published)));
        assert(raise(SIGUSR1)==0);
    }
    for(i=0;i<4;++i) assert(pthread_join(threads[i],NULL)==0);
    assert(signals==1000);
    assert(pthread_create(&threads[0],NULL,producer,NULL)==0);
    assert(pthread_create(&threads[1],NULL,consumer,NULL)==0);
    assert(pthread_join(threads[0],NULL)==0);
    assert(pthread_join(threads[1],NULL)==0);
    alarm(0);
    puts("m88k publication gate PASS: byte/cell load store four writers signal reads payload handshake; CAS/RMW separate");
    return 0;
}
