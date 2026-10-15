#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <stdint.h>
#include "../os-linux-sparc-context.hpp"
#include "../sparc-linux-signal.h"
static factor_sparc_signal_storage saved_slots[2];
static unsigned level;
#define saved saved_slots[level]
static volatile sig_atomic_t delivered, callback_ran;
static unsigned long readable = 123;
static uintptr_t generated_entry, mock_vm[16], mock_context[8];
static unsigned visited;
static uintptr_t test_window_cookie;
extern "C" unsigned long sparc_delay_fault(double *);
extern "C" uintptr_t sparc_resume_callback();
extern "C" void trampoline();
extern "C" void sparc_original_delay(), sparc_original_target();
extern "C" void sparc_relocated_delay(), sparc_relocated_target();
extern "C" uintptr_t sparc_signal_resume_frame(uintptr_t frame) {
  sigset_t all;
  sigfillset(&all);
  if (!callback_ran || sigprocmask(SIG_BLOCK, &all, 0)) _Exit(15);
  return frame;
}
static void relocate(void*, uintptr_t* raw, unsigned bias) {
  ++visited;
  uintptr_t logical = *raw + bias;
  if (logical == (uintptr_t)sparc_original_delay)
    *raw = (uintptr_t)sparc_relocated_delay - bias;
  else if (logical == (uintptr_t)sparc_original_target)
    *raw = (uintptr_t)sparc_relocated_target - bias;
}
static uint32_t instruction(const unsigned char* p) {
  return (uint32_t(p[0])<<24)|(uint32_t(p[1])<<16)|(uint32_t(p[2])<<8)|p[3];
}
static void store(unsigned char* p, uint32_t n) {
  p[0]=n>>24; p[1]=n>>16; p[2]=n>>8; p[3]=n;
}
static void set32(unsigned char* p, uint32_t n) {
  store(p, (instruction(p)&~0x3fffffu)|(n>>10));
  store(p+4, (instruction(p+4)&~0x3ffu)|(n&0x3ffu));
}
static void load_generated(const char* binary, const char* relocations) {
  unsigned char* code = (unsigned char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  FILE* f=fopen(binary,"rb"); if (!f || code==MAP_FAILED) _Exit(16);
  size_t n=fread(code,1,4096,f); fclose(f);
  f=fopen(relocations,"rb"); if(!f) _Exit(17);
  unsigned char r[24]; size_t size=fread(r,1,sizeof(r),f); fclose(f);
  if(size!=16 && size!=20) _Exit(18);
  unsigned count=size/4;
  for(unsigned i=0;i<count;++i) {
    uint32_t record=instruction(r+i*4);
    unsigned offset=record&0xffffff;
    unsigned call=count==5 ? i-1 : i;
    uintptr_t target = count==5 && i==0 ? (uintptr_t)&test_window_cookie :
      call==0||call==2 ? (uintptr_t)trampoline :
      call==1 ? (uintptr_t)sparc_signal_resume_frame : (uintptr_t)sparc_rt_sigreturn;
#if __SIZEOF_POINTER__ == 8
    unsigned char* p=code+offset-24;
    set32(p,target>>32); set32(p+12,(uint32_t)target);
#else
    set32(code+offset-8,target);
#endif
  }
  __builtin___clear_cache((char*)code,(char*)code+n);
  generated_entry=(uintptr_t)code;
  mock_vm[0]=(uintptr_t)mock_context;
  mock_vm[8]=(uintptr_t)sparc_resume_callback;
}

extern "C" unsigned long sparc_delay_fault(double *);
extern "C" void sparc_test_signal_entry();
static unsigned char alternate_stack[65536];
extern "C" uintptr_t sparc_resume_callback() {
  ++callback_ran;
  if (level == 0) {
    level = 1;
    double nested_fp = 0;
    unsigned long nested = sparc_delay_fault(&nested_fp);
    if (nested != 0x246 || nested_fp != 1.25) _Exit(19);
    level = 0;
  }
  factor_sparc_visit_signal_code(&saved, relocate, 0);
  double changed = 9.5;
  asm volatile("ldd [%0], %%f0" : : "r"(&changed) : "f0", "f1");
  return (uintptr_t)saved.bytes;
}
static void handler(int, siginfo_t*, void* raw) {
  if (++delivered > 2) _Exit(10);
  if (factor::sparc_signal_npc(raw) == factor::sparc_signal_pc(raw) + 4) _Exit(11);
  factor_sparc_prepare_signal(raw, &saved, generated_entry ? generated_entry : (uintptr_t)sparc_test_signal_entry);
  if (generated_entry) {
#if __SIZEOF_POINTER__ == 8
    uintptr_t* regs=(uintptr_t*)((unsigned char*)raw+128);
#else
    uintptr_t* regs=(uintptr_t*)((unsigned char*)raw+16);
#endif
    regs[2]=(uintptr_t)&readable; regs[3]=(uintptr_t)&readable;
    regs[4]=(uintptr_t)mock_vm; regs[5]=(uintptr_t)mock_context;
  }
#if defined(FACTOR_TEST_QEMU_SPARC32PLUS_FPU)
  /* QEMU 10.2 sparc32plus uses the native32 frame and PSR but the
   * sparc64 FPU record. Keep this emulator accommodation in the test;
   * real Linux selects compat32 via PSR_V8PLUS and copies all 280 bytes. */
  uintptr_t original_fpu = *(uintptr_t *)((unsigned char *)raw + 88);
  uintptr_t cloned_fpu = *(uintptr_t *)(saved.bytes + 312);
  factor_sparc_signal_copy((void *)(cloned_fpu + 264),
                          (void *)(original_fpu + 264), 16);
#endif
#if __SIZEOF_POINTER__ == 8
  *(uintptr_t *)(saved.bytes + 320 + sizeof(uintptr_t)) = (uintptr_t)&readable;
#else
  *(uintptr_t *)(saved.bytes + 224 + 16 + sizeof(uintptr_t)) = (uintptr_t)&readable;
#endif

}
int main(int argc, char** argv) {
  if(argc==3) load_generated(argv[1],argv[2]);
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO | SA_ONSTACK;
  stack_t stack = {};
  stack.ss_sp = alternate_stack;
  stack.ss_size = sizeof(alternate_stack);
  if (sigaltstack(&stack, 0)) return 3;
  sigemptyset(&action.sa_mask);
  if (sigaction(SIGSEGV, &action, 0)) return 1;
  double fp = 0;
  unsigned long result = sparc_delay_fault(&fp);
  if (result != 0x246 || fp != 1.25 || delivered != 2 || callback_ran != 2 || visited != 8) return 2;
  sigset_t mask;
  sigprocmask(SIG_SETMASK,0,&mask);
  if(sigismember(&mask,SIGUSR1)) return 4;
  puts("SPARC cloned rt_sigreturn: nonsequential PC/NPC, nested callbacks, separate clone slots, register window, floating point, condition codes passed");
}
