#include <stdint.h>
#include <stdio.h>
static uintptr_t context[4];
static int valid_frames;
unsigned sh_native_answer(unsigned a,unsigned b) {
  uintptr_t* frame=(uintptr_t*)context[0];
  if(frame[0]==0x12345678 && frame[1]) ++valid_frames;
  return a*7+b;
}
unsigned sh_native_six(unsigned a,unsigned b,unsigned c,unsigned d,unsigned e,unsigned f) {
  uintptr_t* frame=(uintptr_t*)context[0];
  if(frame[0]==0x12345678 && frame[1]) ++valid_frames;
  return a+b+c+d+e+f;
}
uint64_t sh_native_pair(unsigned a,unsigned b) {
  return UINT64_C(0x89abcdef01234567) + a + b - 12;
}
extern uint64_t sh_pair_gate_probe(uintptr_t*);
extern unsigned sh_gate_probe(uintptr_t*),sh_stack_gate_probe(uintptr_t*);
int main(void) {
  unsigned direct=sh_gate_probe(context),stack=sh_stack_gate_probe(context);
  uint64_t pair=sh_pair_gate_probe(context);
  printf("SH4 native gates direct=%u stack=%u linked-frames=%d\n",direct,stack,valid_frames);
  printf("SH4 native gate pair=%016llx\n",(unsigned long long)pair);
  return !(pair==UINT64_C(0x89abcdef01234567) && direct==42 && stack==62 && valid_frames==2);
}
