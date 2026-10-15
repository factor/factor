#include <sys/types.h>
#include <signal.h>
#include <machine/frame.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint64_t fpscr(void) { union { double f; uint64_t u; } v; __asm__ volatile("mffs %0":"=f"(v.f));return v.u; }
static void setfpscr(uint64_t u) { union { double f; uint64_t u; } v;v.u=u; __asm__ volatile("mtfsf 255,%0"::"f"(v.f)); }
static volatile sig_atomic_t seen, valid;
static uint64_t expected, saved_before, live_before, live_after;
static void fpe(int sig,siginfo_t* info,void* context) {
 (void)info;
 size_t frame=(16+sizeof(struct fpsig)+15)&~(size_t)15;
 struct fpsig* fp=(void*)((char*)context - offsetof(struct sigframe,sf_sc) - frame + 8);
 memcpy(&saved_before,&fp->fpscr,sizeof(saved_before));live_before=fpscr();
 if(saved_before==expected) {
  uint64_t cleared=saved_before & ~UINT64_C(0xfff80000);
  memcpy(&fp->fpscr,&cleared,sizeof(cleared));valid=1;
 }
 setfpscr(fpscr() & ~UINT64_C(0xfff80000));live_after=fpscr();seen=sig;
}
int main(void) {
 uint64_t before=fpscr();setfpscr(0);volatile double zero=0.0,invalid=zero/zero;(void)invalid;expected=fpscr();
 struct sigaction sa={0};sa.sa_sigaction=fpe;sa.sa_flags=SA_SIGINFO;sigemptyset(&sa.sa_mask);
 if(sigaction(SIGFPE,&sa,0)||raise(SIGFPE))return 2;
 uint64_t after=fpscr();setfpscr(before);
 printf("fpsig_size=%zu sigframe_sc_offset=%zu trampoline_frame=%zu fpscr_context_delta=%ld expected=%llx saved_before=%llx live_before=%llx live_after=%llx restored_after=%llx signal=%d valid=%d\n",sizeof(struct fpsig),offsetof(struct sigframe,sf_sc),(16+sizeof(struct fpsig)+15)&~(size_t)15,(long)(8+offsetof(struct fpsig,fpscr)-offsetof(struct sigframe,sf_sc)-((16+sizeof(struct fpsig)+15)&~(size_t)15)),(unsigned long long)expected,(unsigned long long)saved_before,(unsigned long long)live_before,(unsigned long long)live_after,(unsigned long long)after,(int)seen,(int)valid);
 return valid&&seen==SIGFPE&&(expected&UINT64_C(0xfff80000))&&!(after&UINT64_C(0xfff80000))?0:1;
}
