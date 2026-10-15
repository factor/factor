/* Native SuperH regression for syscall-register argument evaluation.
 * old mode intentionally exits 1 with the glibc ordering defect.
 * fixed mode and combined controls must exit 0. */
#define _GNU_SOURCE
#include <pthread.h>
#include <signal.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
static int p[2]; static volatile sig_atomic_t delivered;
static void handler(int sig){(void)sig;delivered++;}
static void *worker(void *arg){char c;(void)arg;while(read(p[0],&c,1)<0){} return 0;}
#define ARGS long a=getpid(); long b=tid; long c=SIGUSR1; register long r4 asm("r4")=a; register long r5 asm("r5")=b; register long r6 asm("r6")=c;
#define CALL asm volatile("trapa #0x13\n\tor r0,r0;or r0,r0;or r0,r0;or r0,r0;or r0,r0" : "=z"(result) : "r"(r3),"r"(r4),"r"(r5),"r"(r6) : "memory","t");return result;
__attribute__((noinline)) static long old_order(long tid){long result;register long r3 asm("r3")=SYS_tgkill;ARGS CALL}
__attribute__((noinline)) static long fixed_order(long tid){long result;ARGS register long r3 asm("r3")=SYS_tgkill;CALL}
__attribute__((noinline)) static long nr_with_call_clobbers(void){asm volatile("mov #0,r4;mov #0,r5;mov #0,r6":::"r4","r5","r6");return SYS_tgkill;}
__attribute__((noinline)) static long interim_ncs(long tid){long result;ARGS register long r3 asm("r3")=nr_with_call_clobbers();CALL}
__attribute__((noinline)) static long fixed_ncs(long tid){long result;long nr=nr_with_call_clobbers();ARGS register long r3 asm("r3")=nr;CALL}
int main(int argc,char **argv){setbuf(stdout,0);struct sigaction s={0};s.sa_handler=handler;sigaction(SIGUSR1,&s,0);pthread_t t;if(pipe(p)||pthread_create(&t,0,worker,0))return 2;usleep(100000);long tid=pthread_gettid_np(t);int old_only=argc>1&&!strcmp(argv[1],"old");int fixed_only=argc>1&&!strcmp(argv[1],"fixed");int ncs_old=argc>1&&!strcmp(argv[1],"ncs-old");int ncs_fixed=argc>1&&!strcmp(argv[1],"ncs-fixed");old_only=old_only||ncs_old;fixed_only=fixed_only||ncs_fixed;long old=fixed_only?0:(ncs_old?interim_ncs(tid):old_order(tid));usleep(100000);int before=delivered;long fixed=old_only?0:(ncs_fixed?fixed_ncs(tid):fixed_order(tid));usleep(100000);int after=delivered;printf("old=%ld delivered=%d fixed=%ld delivered=%d\n",old,before,fixed,after);write(p[1],"X",1);int joined=pthread_join(t,0);printf("join=%d\n",joined);if(old_only)return old!=0||before!=1||joined!=0;return before!=0||fixed!=0||after!=1||joined!=0;}
