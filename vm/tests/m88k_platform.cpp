#include <cassert>
#include <stdint.h>
#include <stddef.h>
#include <sys/mman.h>
#define FACTOR_ASSERT assert
namespace factor {
typedef uintptr_t cell;
typedef intptr_t fixnum;
enum { FP_TRAP_INVALID_OPERATION=1,FP_TRAP_ZERO_DIVIDE=2,
       FP_TRAP_UNDERFLOW=4,FP_TRAP_OVERFLOW=8,FP_TRAP_INEXACT=16 };
}
#include "../m88k.hpp"
#include "../os-openbsd-m88k.hpp"
#include "../cpu-m88k.hpp"
int main() {
  assert(factor::xt_tail_pic_offset == 12);
  void* memory=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANON,-1,0);
  assert(memory!=MAP_FAILED);
  uint32_t* words=(uint32_t*)memory;
  words[0]=0x5ea00000;words[1]=0x5ab50000;words[2]=0xf400c815;
  factor::cell end=(factor::cell)(words+3);
  factor::set_call_target(end,0x12345678);
  assert((factor::cell)factor::get_call_target(end)==0x12345678);
  assert(!factor::tail_call_site_p(end));
  words[2]=0xf400c015;
  assert(factor::tail_call_site_p(end));
  struct sigcontext context={};
  struct reg* regs=factor::m88k_signal_registers(&context);
  regs->sxip=0x12345002;regs->r[31]=0xdeadbee0;regs->fpsr=0xffffffff;
  using namespace factor;
  assert(UAP_PROGRAM_COUNTER(&context)==0x12345000);
  assert(UAP_STACK_POINTER(&context)==0xdeadbee0);
  assert(fpu_status(uap_fpu_status(&context))==31);
  uap_clear_fpu_status(&context);
  assert(regs->fpsr==0xffffffe0);
  assert(munmap(memory,4096)==0);
  return 0;
}
