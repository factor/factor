#include "../../master.hpp"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cfenv>
using namespace factor;
#if defined(__sh__)
static uint32_t fpscr(){uint32_t n;asm volatile("sts fpscr,%0":"=r"(n));return n;}
static void fpscr(uint32_t n){asm volatile("lds %0,fpscr"::"r"(n):"memory");}
#else
static uint32_t fpscr(){return std::fetestexcept(FE_INVALID)?0x40:0;}
static void fpscr(uint32_t n){std::feclearexcept(FE_ALL_EXCEPT);if(n&0x40)std::feraiseexcept(FE_INVALID);}
#endif
int main(){
 auto* vm=new factor_vm(pthread_self());
 // Only stack accessors are used: no managed heap or Factor image in this fixture.
 vm->ctx=static_cast<context*>(std::calloc(1,sizeof(context)));
 for(cell& n:vm->special_objects)n=false_object;
 vm->special_objects[OBJ_CANONICAL_TRUE]=tag_fixnum(99);
 alignas(16) boxed_float x,y; x.initialize(FLOAT_TYPE);y.initialize(FLOAT_TYPE);
 cell stack[2];uint32_t original=fpscr();unsigned failures=0;
 const uint64_t inputs[]={UINT64_C(0x3ff0000000000000),UINT64_C(0x7ff8000000000001),UINT64_C(0x7ff0000000000001)};
 for(unsigned i=0;i<3;i++){
  std::memcpy(&x.n,&inputs[i],8);std::memcpy(&y.n,&inputs[i],8);
  stack[0]=tag(&x);stack[1]=tag(&y);vm->ctx->datastack=reinterpret_cast<cell>(&stack[1]);
  fpscr(0x80000);vm->primitive_float_eq();uint32_t flags=fpscr()&0x7c;
  bool ok=(stack[0]!=false_object)==(i==0)&&flags==(i==2?0x40u:0u);
  std::printf("case=%u equal=%d flags=%02x correct=%d\n",i,stack[0]!=false_object,flags,ok);failures+=!ok;
 }
 fpscr(original);std::printf("checks=3 failed=%u restored=%d\n",failures,fpscr()==original);std::fflush(stdout);_exit(failures?1:0);
}
