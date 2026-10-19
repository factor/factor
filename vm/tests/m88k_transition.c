#include <assert.h>
#include <stdint.h>
#include <stdio.h>
struct context { uintptr_t callstack_top; };
extern unsigned m88k_test_gate1(void*,struct context*);
extern unsigned m88k_test_gate2(void*,struct context*);
static struct context ctx;
static void check_bridge(void) {
 uintptr_t *p=(uintptr_t*)ctx.callstack_top;
 assert(((uintptr_t)p&15)==0);
 assert(p[0]>(uintptr_t)p);
 assert(p[1]!=0);
}
static unsigned add(unsigned a,unsigned b) {
 check_bridge();return a+b;
}
static unsigned words(unsigned a,unsigned b,unsigned c,unsigned d,unsigned e,
 unsigned f,unsigned g,unsigned h,unsigned i,unsigned j) {
 check_bridge();return a+2*b+3*c+4*d+5*e+6*f+7*g+8*h+9*i+10*j;
}
int main(void) {
 unsigned i;
 for(i=0;i<100;++i) {
  assert(m88k_test_gate1((void*)add,&ctx)==42);
  assert(m88k_test_gate2((void*)words,&ctx)==385);
 }
 puts("m88k native VM transition gate PASS: native register/stack args linked frames100 iterations");
 return 0;
}
