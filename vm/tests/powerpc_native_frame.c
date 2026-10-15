#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

__attribute__((noinline, optimize("O0"))) static long sum(int count, ...) {
  va_list args;
  va_start(args, count);
  long total = 0;
  while (count--) total += va_arg(args, int);
  va_end(args);
  return total;
}
static uint32_t *cursor;
static void insn(uint32_t value) { *cursor++ = value; }
static void load(unsigned reg, uintptr_t value) {
  insn(0x3c000000 | reg << 21 | (value >> (sizeof(value)==8 ? 48 : 16) & 65535));
  insn(0x60000000 | reg << 21 | reg << 16 | (value >> (sizeof(value)==8 ? 32 : 0) & 65535));
  if (sizeof(value)==8) {
    insn(0x780007c6 | reg << 21 | reg << 16);
    insn(0x64000000 | reg << 21 | reg << 16 | (value >> 16 & 65535));
    insn(0x60000000 | reg << 21 | reg << 16 | (value & 65535));
  }
}
int main(void) {
  unsigned frame, lrslot;
#if __SIZEOF_POINTER__ == 8
# if defined(_CALL_ELF) && _CALL_ELF == 1
  frame=144;
# else
  frame=128;
# endif
  lrslot=16;
#else
  frame=80; lrslot=4;
#endif
  uint32_t *code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(code==MAP_FAILED) return 1;
  cursor=code;
  insn(0x7c0802a6); /* mflr r0 */
  insn((sizeof(uintptr_t)==8 ? 0xf8010000 : 0x90010000) | lrslot);
  insn((sizeof(uintptr_t)==8 ? 0xf8210001 : 0x94210000) | ((unsigned)-frame & 0xfffc));
  for(unsigned r=3;r<=7;++r) insn(0x38000000 | r<<21 | (r==3 ? 4 : r-3));
  uintptr_t target=(uintptr_t)sum;
#if defined(_CALL_ELF) && _CALL_ELF == 1
  load(2,((uintptr_t*)target)[1]); target=((uintptr_t*)target)[0];
#endif
  load(12,target);
  insn(0x7d8903a6); /* mtctr r12 */
  insn(0x4e800421); /* bctrl */
  insn(0x38210000 | frame);
  insn((sizeof(uintptr_t)==8 ? 0xe8010000 : 0x80010000) | lrslot);
  insn(0x7c0803a6); insn(0x4e800020);
  __builtin___clear_cache((char*)code,(char*)cursor);
  char *memory=malloc(131072); if(!memory) return 2;
  uintptr_t *top=(uintptr_t*)(((uintptr_t)memory+65536)&~(uintptr_t)15);
  top[0]=0x12345678;
  register long result __asm__("r3");
  register void *entry __asm__("r12")=code;
  register void *stack __asm__("r11")=top;
  __asm__ volatile("mr 31,1\n\tmr 1,11\n\tmtctr 12\n\tbctrl\n\tmr 1,31"
    : "=r"(result), "+r"(entry), "+r"(stack) :
    : "r0","r4","r5","r6","r7","r8","r9","r10","r31","lr","ctr","cr0","memory");
  if(result!=10 || top[0]!=0x12345678) return 3;
  printf("PASS generated native variadic call frame=%u result=%ld canary=%lx\n",frame,result,(unsigned long)top[0]);
  return 0;
}
