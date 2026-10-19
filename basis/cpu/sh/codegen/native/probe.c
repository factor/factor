// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
extern unsigned char multiply_overflow_probe[],backward_loop_probe[],linked_epilog_probe[];
extern unsigned char shift_source_probe[],shift_scratch_probe[];
extern unsigned char write_barrier_probe[];
static unsigned char barrier_object[32] __attribute__((aligned(16)));
static unsigned char barrier_cards[64],barrier_decks[64];
extern unsigned sh_epilog_probe(void*);
extern unsigned char sh_probe_start[],sh_probe_end[];
extern unsigned char literal_probe[],alias_sub_probe[],shift_probe[],call_probe[],float_probe[],float_load_probe[];
static uint32_t native_answer(void) { return 0x456789ab; }
static uint32_t invoke(unsigned char* code,unsigned char* entry) {
  return ((uint32_t (*)(void))(code+(entry-sh_probe_start)))();
}
int main(void) {
  size_t size=(size_t)(sh_probe_end-sh_probe_start);
  unsigned char* code=mmap(NULL,size,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(code==MAP_FAILED) return 2;
  memcpy(code,sh_probe_start,size);
  unsigned char* call=code+(call_probe-sh_probe_start);
  int patched=0;
  for(unsigned char* p=call;p+16<=code+size;p+=2) {
    if(*(uint16_t*)p==0xd002 && *(uint16_t*)(p+2)==0x400b) {
      *(uint32_t*)(p+12)=(uintptr_t)native_answer;
      patched=1;
      break;
    }
  }
  unsigned char* barrier=code+(write_barrier_probe-sh_probe_start);
  uintptr_t slot=(uintptr_t)barrier_object+16;
  uint32_t offsets[]={(uintptr_t)(barrier_cards+32)-(slot>>8),
                      (uintptr_t)(barrier_decks+32)-(slot>>18)};
  unsigned barriers=0;
  for(unsigned char* p=barrier;p+2<=code+size;p+=2) {
    uint16_t instruction=*(uint16_t*)p;
    if((instruction>>12)!=0xd) continue;
    uint32_t* literal=(void*)(((uintptr_t)p&~3u)+4+(instruction&255)*4);
    if(*literal==0 && barriers<2) *literal=offsets[barriers++];
  }
  if(!patched || barriers!=2 || mprotect(code,size,PROT_READ|PROT_EXEC)) return 3;
  __builtin___clear_cache((char*)code,(char*)code+size);
  uint32_t a=invoke(code,literal_probe),b=invoke(code,alias_sub_probe);
  uint32_t c=invoke(code,shift_probe),d=invoke(code,call_probe);
  printf("SH4 emitted native literal=%08x alias-sub=%u shift=%u call=%08x\n",a,b,c,d);
  double e=((double (*)(double,double))(code+(float_probe-sh_probe_start)))(9.5,2.0);
  double values[]={-3.75,19.0};
  double f=((double (*)(double*))(code+(float_load_probe-sh_probe_start)))(values+1);
  printf("SH4 emitted double alias-sub=%g negative-offset-load=%g\n",e,f);
  unsigned (*multiply_fits)(int32_t,int32_t)=(void*)(code+(multiply_overflow_probe-sh_probe_start));
  unsigned g=multiply_fits(7,3),h=multiply_fits(-2,3);
  unsigned i=multiply_fits(INT32_MAX,2),j=multiply_fits(INT32_MIN,-1);
  printf("SH4 emitted signed multiply fits=%u,%u overflow=%u,%u\n",g,h,i,j);
  unsigned k=invoke(code,backward_loop_probe);
  printf("SH4 emitted backward loop=%u\n",k);
  unsigned l=sh_epilog_probe(code+(linked_epilog_probe-sh_probe_start));
  printf("SH4 emitted epilog selects suspended SP=%u\n",l);
  unsigned m=invoke(code,shift_source_probe),n=invoke(code,shift_scratch_probe);
  printf("SH4 emitted shift source=%u scratch=%u\n",m,n);
  ((void (*)(uintptr_t))barrier)((uintptr_t)barrier_object+7);
  unsigned card=barrier_cards[32],deck=barrier_decks[32];
  printf("SH4 emitted old-object barrier card=%02x deck=%02x\n",card,deck);
  munmap(code,size);
  return !(card==0xc0 && deck==0xc0 && m==0x10e0 && n==3 && l==1 && k==3 && g==1 && h==1 && i==0 && j==0 && a==0x89abcdef && b==4 && c==1 && d==0x456789ab && e==7.5 && f==-3.75);
}
