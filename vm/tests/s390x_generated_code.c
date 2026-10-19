#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
static void* load(const char* path) {
  FILE* f=fopen(path,"rb"); assert(f); unsigned char b[4096];
  size_t n=fread(b,1,sizeof b,f); assert(n && n<sizeof b); fclose(f);
  void* p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(p!=MAP_FAILED); __builtin_memcpy(p,b,n);
  assert(!mprotect(p,4096,PROT_READ|PROT_EXEC)); return p;
}
int main(void) {
  assert(sizeof(void*)==8); uint32_t endian=0x12345678; assert(*(unsigned char*)&endian==0x12);
  double (*load_double)(void)=load("optimizer-load-double.bin");
  float (*load_float)(void)=load("optimizer-load-float.bin");
  assert(load_double()==-1.25 && load_float()==3.5f);
  long (*integer)(long,long,long)=load("integer.bin");
  double (*fp)(double,double,double)=load("float.bin");
  long (*optimizer_integer)(long,long,long)=load("optimizer-integer.bin");
  double (*optimizer_fp)(double,double,double)=load("optimizer-float.bin");
  long (*minimum)(long,long)=load("optimizer-min.bin");
  long (*maximum)(long,long)=load("optimizer-max.bin");
  long (*signed_byte)(void*)=load("optimizer-signed-byte.bin");
  long (*unsigned_byte)(void*)=load("optimizer-unsigned-byte.bin");
  long (*slot)(void*,long)=load("optimizer-slot.bin");
  long (*indexed)(void*,long)=load("optimizer-indexed.bin");
  double (*integer_float)(long)=load("optimizer-integer-float.bin");
  long (*float_integer)(double)=load("optimizer-float-integer.bin");
  double (*integer_scalar)(uint64_t)=load("optimizer-integer-scalar.bin");
  uint64_t (*scalar_integer)(double)=load("optimizer-scalar-integer.bin");
  long (*offset_r0)(long)=load("optimizer-offset-r0.bin");
  long (*offset_r1)(long)=load("optimizer-offset-r1.bin");
  void (*barrier)(uintptr_t*,uintptr_t)=load("optimizer-barrier.bin");
  uintptr_t (*allot)(uintptr_t*)=load("optimizer-allot.bin");
  long (*memory)(long*,long)=load("memory.bin");
  long (*branch)(long,long)=load("branch.bin");
  _Alignas(16) unsigned char nursery[128]={0};
  uintptr_t mock_vm[16]={0}; mock_vm[2]=(uintptr_t)nursery; mock_vm[4]=(uintptr_t)nursery+128;
  assert(allot(mock_vm)==(uintptr_t)nursery+9);
  assert(mock_vm[2]==(uintptr_t)nursery+48 && *(uintptr_t*)nursery==(9u<<2));
  assert(allot(mock_vm)==(uintptr_t)nursery+48+9);
  assert(mock_vm[2]==(uintptr_t)nursery+96 && *(uintptr_t*)(nursery+48)==(9u<<2));
  unsigned char cards[8]={0}, decks[8]={0};
  mock_vm[6]=(uintptr_t)cards-((uintptr_t)nursery>>8);
  mock_vm[7]=(uintptr_t)decks-((uintptr_t)nursery>>18);
  barrier(mock_vm,(uintptr_t)nursery);
  assert(cards[0]==0xc0 && decks[0]==0xc0 && cards[1]==0 && decks[1]==0);
  for(long a=-100;a<100;a++) for(long b=-7;b<7;b++) {
    assert(offset_r0(a)==a+19 && offset_r1(a)==a+1048576);
    assert(integer(a,b,3)==(a+b)*3);
    assert(optimizer_integer(a,b,3)==(a+b)*3);
    assert(optimizer_fp(a/4.0,b/8.0,3.0)==(a/4.0+b/8.0)*3.0);
    assert(fp(a/4.0,b/8.0,3.0)==(a/4.0+b/8.0)*3.0);
    assert(minimum(a,b)==(a<b?a:b));
    assert(maximum(a,b)==(a>b?a:b));
    assert(integer_float(a)==(double)a);
    assert(float_integer(a/4.0)==(long)(a/4.0));
    double exact=a/4.0; uint64_t bits; __builtin_memcpy(&bits,&exact,8);
    assert(integer_scalar(bits)==exact && scalar_integer(exact)==bits);
    long pair[2]={a,b};
    assert(slot(pair,0)==a && slot(pair,8)==b);
    assert(indexed(pair,0)==a && indexed(pair,1)==b);
    uint8_t octet=(uint8_t)a;
    assert(signed_byte(&octet)==(int8_t)octet);
    assert(unsigned_byte(&octet)==octet);
    long value=a; assert(memory(&value,b)==a+b); assert(value==a+b);
    assert(branch(a,b)==(a>=b?1:-1));
  }
  puts("Factor-emitted System z assembler/optimizer integer/FP/memory/branch code PASS (64-bit big-endian)");
}
