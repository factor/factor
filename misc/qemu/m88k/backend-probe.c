/* Executes actual Factor backend emission on native 88100 OpenBSD. */
#include <assert.h>
#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "backend-generated.h"
extern void m88k_cache_sync(void *, size_t);
extern unsigned backend_cfg_call(void *, unsigned *);
extern unsigned backend_native_call(void *, void *, void *, void *);
extern void trampoline2(void);
static unsigned context_top;
static unsigned weighted(unsigned a,unsigned b,unsigned c,unsigned d,unsigned e,unsigned f,unsigned g,unsigned h,unsigned i,unsigned j) {
 unsigned *frame=(unsigned *)context_top;
 assert(((unsigned)frame&15)==0 && frame[0]>(unsigned)frame && frame[1]!=0);
 return a+2*b+3*c+4*d+5*e+6*f+7*g+8*h+9*i+10*j;
}
extern double backend_call_fp(void *, unsigned, unsigned);
extern unsigned backend_float_cmp(void *, double, double);
extern unsigned backend_call(void *, unsigned, unsigned);
static void *load(const unsigned char *bytes, size_t n) {
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE,-1,0);
 assert(p!=MAP_FAILED); memcpy(p,bytes,n);
 if(bytes==m88k_cfg_float) {
   unsigned i;
   for(i=0;i<sizeof(m88k_cfg_float_fixups)/sizeof(m88k_cfg_float_fixups[0]);i++) {
     uint32_t *end=(uint32_t *)((char *)p+m88k_cfg_float_fixups[i][0]);
     unsigned target=(unsigned)p+m88k_cfg_float_fixups[i][1];
     end[-2]=(end[-2]&0xffff0000u)|(target>>16);
     end[-1]=(end[-1]&0xffff0000u)|(target&0xffffu);
   }
 }
 m88k_cache_sync(p,n); assert(mprotect(p,4096,PROT_READ|PROT_EXEC)==0); return p;
}
#define RUN(name,a,b) backend_call(load(name,sizeof(name)),a,b)
int main(void) {
 unsigned char bytes[]={0,0x89,0xab,0xcd,0xef,0};
 void *pred, *mul_low, *mul_ov; unsigned i, cfg_result=0, seed=0x12345678;
 const int boundary[]={0,1,-1,2,-2,INT_MAX,INT_MIN,32767,32768,-32768,65535,-65536};
 const unsigned lt[]={1,1,0,0,0,1,1,0,0,1,1,1,0,0};
 const unsigned eq[]={0,1,1,0,1,0,1,1,0,0,1,0,1,0};
 const unsigned un[]={0,0,0,0,0,0,0,1,1,1,1,1,1,1};
 double (*f)(double,double);
 assert(RUN(m88k_add,17,25)==42);
 assert(RUN(m88k_add,0xffffffffu,1)==0);
 assert(RUN(m88k_sub,17,25)==(unsigned)-8);
 assert(RUN(m88k_offset,84,0)==42);
 assert(RUN(m88k_negative,0,0)==0xffffffffu);
 assert(RUN(m88k_frame,0,0)==42);
 assert(RUN(m88k_spill,0xdeadbeef,0)==0xdeadbeef);
 assert(RUN(m88k_mul,6,7)==42);
 assert(RUN(m88k_shl,21,33)==42);
 assert(RUN(m88k_shr,0x80000000u,1)==0x40000000u);
 assert(RUN(m88k_sar,0x80000000u,1)==0xc0000000u);
 assert(RUN(m88k_lt,17,25)==1);
 assert(RUN(m88k_lt,25,17)==0);
 assert(RUN(m88k_lt,17,17)==0);
 assert(RUN(m88k_lt,0x80000000u,0x7fffffffu)==1);
 assert(RUN(m88k_unaligned_load,(unsigned)bytes,0)==0x89abcdefu);
 assert(RUN(m88k_unaligned_half,(unsigned)bytes,0)==0xffff89abu);
 assert(RUN(m88k_unaligned_store,(unsigned)bytes,0x12345678u)==0x12345678u);
 assert(bytes[0]==0 && bytes[1]==0x12 && bytes[2]==0x34 && bytes[3]==0x56 && bytes[4]==0x78 && bytes[5]==0);
 assert(backend_call_fp(load(m88k_int_double,sizeof(m88k_int_double)),(unsigned)-42,0)==-42.0);
 assert(((int (*)(double))load(m88k_double_int,sizeof(m88k_double_int)))(-42.75)==-42);
 assert(backend_native_call(load(m88k_native_stack_call,sizeof(m88k_native_stack_call)),(void *)weighted,&context_top,(void *)trampoline2)==385);
 assert(backend_cfg_call(load(m88k_cfg_pressure,sizeof(m88k_cfg_pressure)),&cfg_result)==78 && cfg_result==78);
 assert(backend_cfg_call(load(m88k_cfg_float,sizeof(m88k_cfg_float)),&cfg_result)==21 && cfg_result==21);
 mul_low=load(m88k_mul_low,sizeof(m88k_mul_low)); mul_ov=load(m88k_mul_overflow,sizeof(m88k_mul_overflow));
 for(i=0;i<144+256;i++) {
   int a,b; int64_t exact;
   if(i<144) { a=boundary[i/12]; b=boundary[i%12]; }
   else { seed=seed*1664525u+1013904223u; a=(int)seed; seed=seed*1664525u+1013904223u; b=(int)seed; }
   exact=(int64_t)a*b;
   assert(backend_call(mul_low,a,b)==(unsigned)exact);
   assert(backend_call(mul_ov,a,b)==(unsigned)(exact>INT_MAX || exact<INT_MIN));
 }
 assert(RUN(m88k_add_overflow,INT_MAX,1)==0xffffffffu);
 assert(RUN(m88k_add_overflow,INT_MIN,-1)==0xffffffffu);
 assert(RUN(m88k_add_overflow,17,25)==0);
 assert(RUN(m88k_sub_overflow,INT_MIN,1)==0xffffffffu);
 assert(RUN(m88k_sub_overflow,INT_MAX,-1)==0xffffffffu);
 assert(RUN(m88k_sub_overflow,17,25)==0);
 pred=load(m88k_float_predicates,sizeof(m88k_float_predicates));
 /* Non-complement predicates occupy24bytes, complement predicates28. */
 for(i=0;i<14;i++) {
   unsigned off=i<7?i*24:(i<13?7*24+(i-7)*28:7*24+6*28);
   assert(backend_float_cmp((char *)pred+off,1.25,2.5)==lt[i]);
   assert(backend_float_cmp((char *)pred+off,2.5,2.5)==eq[i]);
   assert(backend_float_cmp((char *)pred+off,NAN,2.5)==un[i]);
 }
 f=(double (*)(double,double))load(m88k_double,sizeof(m88k_double));
 assert(f(1.25,2.5)==3.75);
 puts("m88k Factor optimizing backend native gate PASS: add/sub/mul aliases, masked shifts, signed comparison, negative literals, linked frame, spill, unaligned memory, double conversions and IEEE comparisons, 400 exact overflow vectors, allocated integer/double CFG spills and literal relocations");
 return 0;
}
