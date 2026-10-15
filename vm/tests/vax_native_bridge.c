#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

static unsigned char *code;
static size_t cursor;
static uintptr_t anchor, anchor_pc, outer_return;
static void byte(unsigned value) { code[cursor++] = (unsigned char)value; }
static void longword(uint32_t value) {
  for (unsigned n=0;n<4;n++) byte(value >> (8*n));
}
static void immediate(uint32_t value) { byte(0x8f); longword(value); }
static void memory(unsigned reg, int offset) {
  if (!offset) byte(0x60+reg);
  else if (offset>=-128 && offset<=127) {
    byte(0xa0+reg); byte((unsigned)offset);
  } else {
    assert(offset>=-32768 && offset<=32767);
    byte(0xc0+reg); byte((unsigned)offset); byte((unsigned)offset>>8);
  }
}
static uint32_t native_sum(unsigned count, ...) {
  assert(count==300);
  assert(*(uint32_t *)anchor==anchor_pc);
  assert(*(uint32_t *)(anchor+1216)==outer_return);
  va_list args;
  va_start(args,count);
  uint32_t sum=0;
  for (unsigned n=0;n<count;n++) sum+=va_arg(args,unsigned);
  va_end(args);
  return sum;
}
int main(void) {
  code=mmap(0,8192,PROT_READ|PROT_WRITE|PROT_EXEC,
            MAP_PRIVATE|MAP_ANON,-1,0);
  assert(code!=MAP_FAILED);
  // Native CALLS entry invokes a Factor JSB word and returns with RET.
  byte(0); byte(0);
  byte(0x16); byte(0x9f); size_t target=cursor; longword(0);
  outer_return=(uintptr_t)(code+cursor); byte(0x04);
  uintptr_t word=(uintptr_t)(code+cursor);
  memcpy(code+target,&word,4);
  byte(0xc2); immediate(1212); byte(0x5e);
  for (unsigned n=0;n<301;n++) {
    byte(0xd0); immediate(n ? n : 300); memory(14,4*(int)n);
  }
  // Save the synthetic Factor frame before creating the native frame.
  byte(0xc1); immediate((uint32_t)-4); byte(0x5e);
  byte(0x9f); longword((uint32_t)(uintptr_t)&anchor);
  byte(0xdd); byte(0x8f); size_t continuation=cursor; longword(0);
  byte(0xde); memory(14,4); byte(0x54);
  for (unsigned n=301;n>0;n--) {
    byte(0xdd); memory(4,4*((int)n-1));
  }
  byte(0xdd); immediate(301);
  byte(0xfa); byte(0x6e); byte(0x9f);
  longword((uint32_t)(uintptr_t)native_sum);
  anchor_pc=(uintptr_t)(code+cursor);
  memcpy(code+continuation,&anchor_pc,4);
  byte(0xc0); immediate(1208+4); byte(0x5e);
  byte(0xc0); immediate(1212); byte(0x5e); byte(0x05);
  assert(cursor<8192);
  __builtin___clear_cache((char *)code,(char *)code+cursor);
  uint32_t (*invoke)(void)=(void *)code;
  assert(invoke()==45150);
  assert(munmap(code,8192)==0);
  puts("VAX JSB/CALLG bridge: 301 argument words and Factor frame anchor passed");
  return 0;
}
