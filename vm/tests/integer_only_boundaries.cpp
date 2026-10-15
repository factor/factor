#include "../master.hpp"
#ifndef FACTOR_INTEGER_ONLY
#error "Compile these controls against an integer-only VM"
#endif
#ifndef FACTOR_VM_WRAPPED_GENERAL_ERROR
// GNU ELF Linux x86-64 symbol; override when running another host ABI.
#define FACTOR_VM_WRAPPED_GENERAL_ERROR "__wrap__ZN6factor9factor_vm13general_errorENS_13vm_error_typeEmm"
#endif
#include <cassert>
#include <cstdio>
using namespace factor;
struct rejected { vm_error_type code; };
// Host boundary controls: link the matching libfactor.a with GNU ld --wrap
// for general_error. This observes real primitives and the intended error code;
// it does not test Factor unwinding or establish native no-FPU target support.
extern "C" void observe_error(factor_vm*, vm_error_type code, cell, cell)
  __asm__(FACTOR_VM_WRAPPED_GENERAL_ERROR);
extern "C" void observe_error(factor_vm*, vm_error_type code, cell, cell) {
  throw rejected{code};
}
struct test_vm : factor_vm {
 test_vm():factor_vm(THREADHANDLE()) {
  std::fill(special_objects,special_objects+special_object_count,false_object);
  set_data_heap(new data_heap(&nursery,deck_size,deck_size,16*deck_size));
  ctx=new context(deck_size,deck_size,deck_size); active_contexts.insert(ctx);
 }
 ~test_vm(){ctx=nullptr;}
};
int main() {
 test_vm vm;
 vm.primitive_floating_point_supported();assert(vm.ctx->pop()==false_object);
 uint64_t values[]={0,0x8000000000000000ULL,1,0x7ff0000000000001ULL,0xfff123456789abcdULL};
 for(uint64_t bits:values) {
  vm.ctx->push(vm.from_unsigned_8(bits));vm.primitive_bits_double();
  assert(vm_float_bits(vm.untag_float_check(vm.ctx->peek()))==bits);
  vm.primitive_double_bits();assert(vm.to_unsigned_8(vm.ctx->pop())==bits);
 }
 vm.ctx->push(tag(vm.uint64_to_bignum(0x1000000000000000ULL)));
 vm.ctx->push(tag(vm.uint64_to_bignum(0x2000000000000000ULL)));
 vm.primitive_bignum_add();assert(vm.to_unsigned_8(vm.ctx->pop())==0x3000000000000000ULL);
 unsigned count=0;
 auto check=[&](auto operation){try{operation();assert(false);}catch(rejected error){assert(error.code==ERROR_FLOAT_UNSUPPORTED);++count;}};
 check([&]{vm.primitive_fixnum_to_float();});check([&]{vm.primitive_float_to_fixnum();});
 check([&]{vm.primitive_float_to_bignum();});check([&]{vm.primitive_format_float();});
 check([&]{vm.primitive_float_add();});check([&]{vm.primitive_float_subtract();});
 check([&]{vm.primitive_float_multiply();});check([&]{vm.primitive_float_divfloat();});
 check([&]{vm.primitive_float_eq();});check([&]{vm.primitive_float_less();});
 check([&]{vm.primitive_float_lesseq();});check([&]{vm.primitive_float_greater();});
 check([&]{vm.primitive_float_greatereq();});check([&]{vm.primitive_float_unordered_less();});
 check([&]{vm.primitive_float_unordered_lesseq();});check([&]{vm.primitive_float_unordered_greater();});
 check([&]{vm.primitive_float_unordered_greatereq();});check([&]{vm.to_float(false_object);});
 check([&]{vm.to_double(false_object);});check([&]{vm.allot_float(0.0);});
 uint64_t native=0x7ff0000000000001ULL;
 vm.ctx->push(vm.allot_alien((cell)&native)); vm.ctx->push(tag_fixnum(0));
 primitive_alien_double(&vm);
 assert(vm_float_bits(vm.untag_float_check(vm.ctx->pop()))==native);
 vm.ctx->push(vm.allot_alien((cell)&native)); vm.ctx->push(tag_fixnum(0));
 primitive_alien_float(&vm);
 uint32_t single; memcpy(&single,&native,sizeof(single));
 assert(vm_float_bits(vm.untag_float_check(vm.ctx->pop()))==widen_ieee_bits(single));
 uint64_t stored=0;
 vm.ctx->push(vm.allot_float_bits(native));vm.ctx->push(vm.allot_alien((cell)&stored));vm.ctx->push(tag_fixnum(0));
 primitive_set_alien_double(&vm);assert(stored==native);
 uint32_t single_stored=0;
 vm.ctx->push(vm.allot_float_bits(widen_ieee_bits(0x7f800001)));vm.ctx->push(vm.allot_alien((cell)&single_stored));vm.ctx->push(tag_fixnum(0));
 primitive_set_alien_float(&vm);assert(single_stored==0x7f800001);
 check([&]{vm.allot_float(0.0f);});
 check([&]{vm.double_to_bignum(vm_float_from_bits(0));});
 puts("actual integer VM capability false, raw-bit round trips and bignum addition passed");
 printf("%u real primitive/native-boundary unsupported error controls passed (intercepted error boundary)\n",count);
}
