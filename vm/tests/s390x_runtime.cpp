#include <cassert>
#include <cstdint>
#include <csetjmp>
#include <cstdio>
#include <cstring>
#include <initializer_list>
#include <cstdarg>
#include <string>
#include <signal.h>
#include <sys/mman.h>
using cell = uintptr_t;
#define FACTOR_ASSERT assert
#include "../s390x.hpp"
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_OVERFLOW=2,
       FP_TRAP_UNDERFLOW=4, FP_TRAP_ZERO_DIVIDE=8, FP_TRAP_INEXACT=16 };
#include "../os-linux-s390x.hpp"
#include "../cpu-s390x.hpp"
extern "C" long s390x_test_native_call(cell*, void*, long, long);
extern "C" long s390x_test_generated_invoke(cell*, void*, long, long);
struct IntegerAggregate { uint32_t value; };
struct FloatAggregate { float value; };
struct NestedFloatAggregate { FloatAggregate member; };
struct alignas(8) PaddedFloatAggregate { float value; };
struct alignas(16) IndirectFloatAggregate { float value; };
struct alignas(16) IndirectDoubleAggregate { double value; };
static long integer_aggregate(IntegerAggregate x) { return x.value ^ UINT32_C(0xfeed1234); }
static long float_aggregate(NestedFloatAggregate x) { return (long)(x.member.value*2); }
static long padded_float_aggregate(PaddedFloatAggregate x) { return (long)(x.value*2); }
static long indirect_float_aggregate(IndirectFloatAggregate x) { return (long)(x.value*2); }
static long indirect_double_aggregate(IndirectDoubleAggregate x) { return (long)(x.value*2); }
static IntegerAggregate aggregate_return(long x) { return {(uint32_t)x}; }
static long variadic_callee(long first,...) {
  va_list args; va_start(args,first);
  struct RawVa { long gp,fp; void* overflow; void* save; };
  static_assert(sizeof(args)==sizeof(RawVa));
  RawVa raw; memcpy(&raw,args,sizeof raw);
  assert(raw.gp==1 && raw.fp==0);
  assert(*(long*)((char*)raw.overflow)==11 && *(long*)((char*)raw.overflow+8)==13);
  assert(*(double*)((char*)raw.overflow+16)==8.0);
  const double fp_expected[]={0.5,-3.25,7.75,4.5};
  for(unsigned i=0;i<4;i++) assert(*(double*)((char*)raw.save+128+8*i)==fp_expected[i]);
  long result=first;
  for(long i=2;i<=7;i++) result+=i*va_arg(args,long);
  for(unsigned i=0;i<5;i++) result+=(long)(4*va_arg(args,double));
  va_end(args); return result;
}
static long stack_callee(long a,long b,long c,long d,long e,long f,long g) { return a+2*b+3*c+4*d+5*e+6*f+7*g; }
static long callback(long a, long b) { return a-b; }
static long callee(long a, long b) {
  // Force a real native call with a register save area and stack locals.
  volatile long values[32];
  for(int i=0;i<32;i++) values[i]=a+i;
  long (*volatile cb)(long,long)=callback;
  return cb(values[31],b);
}
#ifdef S390X_ZIG_BRIDGE
extern "C" unsigned int s390x_zig_fpc_status(unsigned int);
extern "C" void s390x_zig_clear_fpc(void*);
#endif
static sigjmp_buf escape;
static volatile sig_atomic_t trapped;
static void handle_fpe(int, siginfo_t*, void* context) {
  const auto saved = factor::uap_fpu_status(context);
  trapped = factor::fpu_status(saved);
#ifdef S390X_ZIG_BRIDGE
  assert(s390x_zig_fpc_status(saved) == (unsigned int)trapped);
  s390x_zig_clear_fpc(context);
#else
  factor::uap_clear_fpu_status(context);
#endif
  assert((factor::uap_fpu_status(context) & 0x00f8ff00u) == 0);
  assert((factor::uap_fpu_status(context) & 0xff000003u) == (saved & 0xff000003u));
  siglongjmp(escape,1);
}
static void* load_program(const char* name) {
  FILE* file=fopen((std::string(name)+".bin").c_str(),"rb"); assert(file);
  unsigned char bytes[4096]; size_t n=fread(bytes,1,sizeof bytes,file); fclose(file);
  assert(n && n<sizeof bytes);
  void* result=mmap(nullptr,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(result!=MAP_FAILED);
  memcpy(result,bytes,n);
  file=fopen((std::string(name)+".labels").c_str(),"r"); assert(file);
  unsigned klass,offset,target;
  while(fscanf(file,"%u%u%u",&klass,&offset,&target)==3) {
    assert(klass==14 && offset>=6 && offset<=n && target<=n);
    factor::s390x_store_branch((unsigned char*)result+offset-6,(int64_t)target-(int64_t)(offset-6));
  }
  assert(feof(file)); fclose(file); assert(!mprotect(result,4096,PROT_READ|PROT_EXEC)); return result;
}
static void* native_program(const char* name,void* target) {
  auto* result=(unsigned char*)load_program(name); assert(!mprotect(result,4096,PROT_READ|PROT_WRITE));
  size_t offset=0;
  for(size_t i=0;i<256;i+=2) if(result[i]==0xc0 && result[i+1]==0x18 && result[i+6]==0xc0 && result[i+7]==0x19) { assert(!offset); offset=i; }
  assert(offset); factor::s390x_store_immediate(result+offset,(cell)target);
  assert(!mprotect(result,4096,PROT_READ|PROT_EXEC)); return result;
}
int main() {
  unsigned char aligned[16] = {0,0,0xc0,0xe5,0xff,0xff,0xff,0xff};
  const cell ra=(cell)(aligned+8);
  assert(factor::get_call_target(ra)==aligned);
  assert(!factor::tail_call_site_p(ra));
  factor::set_call_target(ra,(cell)(aligned+14));
  assert(factor::get_call_target(ra)==aligned+14);
  aligned[3]=0xf4;
  assert(factor::tail_call_site_p(ra));
  factor::set_call_target(ra,(cell)(aligned+2));
  assert(factor::get_call_target(ra)==aligned+2);
  factor::s390x_store_branch(aligned+2,INT64_C(-4294967296));
  assert(factor::s390x_branch_displacement(aligned+2)==INT64_C(-4294967296));
  factor::s390x_store_branch(aligned+2,INT64_C(4294967294));
  assert(factor::s390x_branch_displacement(aligned+2)==INT64_C(4294967294));
  unsigned char li[12]={0xc0,0x28,0,0,0,0,0xc0,0x29,0,0,0,0};
  factor::s390x_store_immediate(li,UINT64_C(0xfedcba9876543210));
  assert(factor::s390x_load_immediate(li)==UINT64_C(0xfedcba9876543210));
  for (long a=-100;a<100;a++) {
    cell ctx[1]={0};
    assert(s390x_test_native_call(ctx,(void*)callee,a,7)==a+31-7);
    assert(ctx[0]!=0);
  }
  FILE* generated_file=fopen("optimizer-c-invoke.bin","rb"); assert(generated_file);
  unsigned char generated_bytes[4096]; size_t generated_size=fread(generated_bytes,1,sizeof generated_bytes,generated_file); fclose(generated_file);
  assert(generated_size>24 && generated_size<sizeof generated_bytes);
  void* generated=mmap(nullptr,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(generated!=MAP_FAILED);
  memcpy(generated,generated_bytes,generated_size);
  factor::s390x_store_immediate((unsigned char*)generated+12,(cell)callee);
  assert(!mprotect(generated,4096,PROT_READ|PROT_EXEC));
  for(long a=-100;a<100;a++) {
    cell ctx[4]={0,0,0x12340,0x56780};
    assert(s390x_test_generated_invoke(ctx,generated,a,7)==a+31-7);
    assert(ctx[0]!=0 && ctx[2]==0x12340 && ctx[3]==0x56780);
  }
  generated_file=fopen("optimizer-stack-invoke.bin","rb"); assert(generated_file);
  generated_size=fread(generated_bytes,1,sizeof generated_bytes,generated_file); fclose(generated_file);
  void* stack_generated=mmap(nullptr,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(stack_generated!=MAP_FAILED);
  memcpy(stack_generated,generated_bytes,generated_size);
  size_t target_offset=0;
  for(size_t i=0;i+12<=generated_size;i+=2) if(generated_bytes[i]==0xc0 && generated_bytes[i+1]==0x18 && generated_bytes[i+6]==0xc0 && generated_bytes[i+7]==0x19) { assert(!target_offset); target_offset=i; }
  assert(target_offset); factor::s390x_store_immediate((unsigned char*)stack_generated+target_offset,(cell)stack_callee);
  assert(!mprotect(stack_generated,4096,PROT_READ|PROT_EXEC));
  for(long a=-100;a<100;a++) {
    cell ctx[4]={0,0,0x12340,0x56780};
    assert(s390x_test_generated_invoke(ctx,stack_generated,a,7)==a+2*7+3*3+4*5+5*7+6*11+7*13);
    assert(ctx[0]!=0);
  }
  void* variadic_program=native_program("optimizer-variadic-invoke",(void*)variadic_callee);
  for(long a=-100;a<100;a++) {
    cell ctx[4]={0,0,0x12340,0x56780};
    assert(s390x_test_generated_invoke(ctx,variadic_program,a,7)==a+2*7+3*3+4*5+5*7+6*11+7*13+70);
  }
  const char* callback_programs[]={"optimizer-callback-r6.bin","optimizer-callback-stack-input.bin","optimizer-callback-stack.bin"};
  cell callback_save[64]={0}; callback_save[20]=0x45670; callback_save[60]=0x12345;
  cell callback_ctx[5]={0,0,0x11110,0x22220,(cell)callback_save};
  cell callback_expected[]={0x45670,0x12345,(cell)callback_save+320};
  for(unsigned i=0;i<3;i++) {
    generated_file=fopen(callback_programs[i],"rb"); assert(generated_file);
    generated_size=fread(generated_bytes,1,sizeof generated_bytes,generated_file); fclose(generated_file);
    void* callback_program=mmap(nullptr,4096,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(callback_program!=MAP_FAILED);
    memcpy(callback_program,generated_bytes,generated_size); assert(!mprotect(callback_program,4096,PROT_READ|PROT_EXEC));
    assert((cell)s390x_test_generated_invoke(callback_ctx,callback_program,0,0)==callback_expected[i]);
  }
  void* unbox_program=load_program("optimizer-unbox-pointer");
  cell pointer_ctx[4]={0}; alignas(16) cell boxed[5]={6u<<2,1,1,0x12345678,0x12345678};
  alignas(16) unsigned char payload[64]={0};
  assert(s390x_test_generated_invoke(pointer_ctx,unbox_program,1,0)==0);
  assert(s390x_test_generated_invoke(pointer_ctx,unbox_program,(cell)boxed+6,0)==0x12345678);
  assert((cell)s390x_test_generated_invoke(pointer_ctx,unbox_program,(cell)payload+9,0)==(cell)payload+16);
  void* box_program=load_program("optimizer-box-pointer");
  alignas(16) cell alien_nursery[16]={0}; cell mock_vm[16]={0}; mock_vm[2]=(cell)alien_nursery;
  assert(s390x_test_generated_invoke(pointer_ctx,box_program,(cell)mock_vm,0)==1);
  assert(mock_vm[2]==(cell)alien_nursery);
  assert((cell)s390x_test_generated_invoke(pointer_ctx,box_program,(cell)mock_vm,0x98765432)==(cell)alien_nursery+6);
  assert(mock_vm[2]==(cell)alien_nursery+48 && alien_nursery[0]==(6u<<2));
  assert(alien_nursery[1]==1 && alien_nursery[2]==1 && alien_nursery[3]==0x98765432 && alien_nursery[4]==0x98765432);
  boxed[2]=17; // Verify that displacement preserves the original expiration object.
  const char* displaced_names[]={"optimizer-displaced-alien","optimizer-displaced-alien-base-alias"};
  for(const char* name:displaced_names) {
    void* program=load_program(name);
    for(cell base: {(cell)1,(cell)boxed+6,(cell)payload+9}) {
      for(long displacement: {0L,17L,-9L}) {
        alignas(16) cell nursery[16]={0}; mock_vm[2]=(cell)nursery;
        cell arguments[2]={(cell)displacement,base};
        cell result=s390x_test_generated_invoke(pointer_ctx,program,(cell)mock_vm,(cell)arguments);
        if(!displacement) { assert(result==base && mock_vm[2]==(cell)nursery); continue; }
        assert(result==(cell)nursery+6 && nursery[0]==(6u<<2) && mock_vm[2]==(cell)nursery+48);
        if(base==1) assert(nursery[1]==1 && nursery[2]==1 && nursery[3]==(cell)displacement && nursery[4]==(cell)displacement);
        else if(base==(cell)boxed+6) assert(nursery[1]==boxed[1] && nursery[2]==boxed[2] && nursery[3]==boxed[3]+displacement && nursery[4]==boxed[4]+displacement);
        else assert(nursery[1]==base && nursery[2]==1 && nursery[3]==(cell)displacement && nursery[4]==(cell)payload+16+displacement);
      }
    }
  }
  auto tagged_compare=(long(*)(long))load_program("optimizer-compare-tagged");
  auto false_compare=(long(*)(long))load_program("optimizer-compare-false");
  for(long i=-20;i<=20;i++) {
    long tagged=(long)((uint64_t)i*16);
    assert(tagged_compare(tagged)==(i<5));
    assert(false_compare(tagged)==0);
  }
  assert(false_compare(1)==1);
  auto integer_compare=(long(*)(long,long))load_program("optimizer-compare-integer");
  auto float_compare=(long(*)(double,double))load_program("optimizer-compare-float");
  auto unordered_compare=(long(*)(double,double))load_program("optimizer-compare-unordered");
  auto equal_compare=(long(*)(double,double))load_program("optimizer-compare-equal");
  for(long a=-100;a<100;a++) for(long b=-7;b<7;b++) {
    assert(integer_compare(a,b)==(a<b)); assert(float_compare(a/4.0,b/8.0)==(a/4.0<b/8.0));
    assert(!unordered_compare(a/4.0,b/8.0)); assert(equal_compare(a/4.0,b/8.0)==(a/4.0==b/8.0));
  }
  uint64_t nan_bits=UINT64_C(0x7ff8000000000000); double nan; memcpy(&nan,&nan_bits,8);
  assert(!float_compare(nan,1.0) && !float_compare(1.0,nan));
  assert(unordered_compare(nan,1.0) && unordered_compare(1.0,nan));
  assert(!equal_compare(nan,nan));
  const char* checked_names[]={"optimizer-checked-add","optimizer-checked-sub","optimizer-checked-mul"};
  const int64_t checked_values[]={INT64_MIN,INT64_MIN+16,-INT64_C(4294967296),-17,-1,0,1,17,INT64_C(4294967296),INT64_MAX-16,INT64_MAX};
  for(unsigned operation=0;operation<3;operation++) {
    auto checked=(long(*)(long,long,long*))load_program(checked_names[operation]);
    for(auto a:checked_values) for(auto b:checked_values) {
      __int128 exact=operation==0?(__int128)a+b:operation==1?(__int128)a-b:(__int128)a*b;
      bool overflow=exact<INT64_MIN || exact>INT64_MAX;
      long result=0; assert(checked(a,b,&result)==!overflow);
      assert((uint64_t)result==(uint64_t)exact);
    }
  }
  auto integer_log2=(long(*)(uint64_t))load_program("optimizer-log2");
  auto integer_popcount=(long(*)(uint64_t))load_program("optimizer-bit-count");
  uint64_t random_bits=UINT64_C(0x123456789abcdef0);
  for(int i=0;i<1000;i++) {
    random_bits=random_bits*UINT64_C(6364136223846793005)+1;
    assert(integer_popcount(random_bits)==__builtin_popcountll(random_bits));
    assert(integer_log2(random_bits)==63-__builtin_clzll(random_bits));
  }
  for(unsigned bit=0;bit<64;bit++) {
    assert(integer_popcount(UINT64_C(1)<<bit)==1);
    assert(integer_log2(UINT64_C(1)<<bit)==bit);
  }
  assert(integer_popcount(0)==0 && integer_popcount(UINT64_MAX)==64);
  void* aggregate_gp=native_program("optimizer-aggregate-integer",(void*)integer_aggregate);
  void* aggregate_fp=native_program("optimizer-aggregate-float",(void*)float_aggregate);
  void* aggregate_buffer=native_program("optimizer-aggregate-integer",(void*)aggregate_return);
  assert(s390x_test_generated_invoke(pointer_ctx,aggregate_gp,0x11223344,0)==(long)(UINT32_C(0x11223344)^UINT32_C(0xfeed1234)));
  assert(s390x_test_generated_invoke(pointer_ctx,aggregate_fp,0,0)==-7);
  static_assert(sizeof(PaddedFloatAggregate)==8 && sizeof(IndirectFloatAggregate)==16);
  void* padded_fp=native_program("optimizer-aggregate-float",(void*)padded_float_aggregate);
  assert(s390x_test_generated_invoke(pointer_ctx,padded_fp,0,0)==-7);
  IndirectFloatAggregate indirect_float={-3.5f};
  IndirectDoubleAggregate indirect_double={-3.5};
  void* indirect_fp=native_program("optimizer-aggregate-integer",(void*)indirect_float_aggregate);
  void* indirect_dp=native_program("optimizer-aggregate-integer",(void*)indirect_double_aggregate);
  assert(s390x_test_generated_invoke(pointer_ctx,indirect_fp,(long)&indirect_float,0)==-7);
  assert(s390x_test_generated_invoke(pointer_ctx,indirect_dp,(long)&indirect_double,0)==-7);
  uint32_t buffer[3]={0xabcdef01,0,0x12345678};
  s390x_test_generated_invoke(pointer_ctx,aggregate_buffer,(long)&buffer[1],0x789abcde);
  assert(buffer[0]==0xabcdef01 && buffer[1]==0x789abcde && buffer[2]==0x12345678);
  struct sigaction action={}; action.sa_sigaction=handle_fpe;
  action.sa_flags=SA_SIGINFO; sigemptyset(&action.sa_mask);
  assert(sigaction(SIGFPE,&action,nullptr)==0);
  uint32_t previous; asm volatile("stfpc %0":"=Q"(previous));
  if (!sigsetjmp(escape,1)) {
    uint32_t fpc=0x40000000; asm volatile("lfpc %0"::"Q"(fpc));
    volatile double one=1.0, zero=0.0, result;
    result=one/zero; (void)result;
    assert(false && "divide-by-zero trap was not delivered");
  }
  asm volatile("lfpc %0"::"Q"(previous));
  assert(trapped==FP_TRAP_ZERO_DIVIDE);
  puts("s390x call-site patching, native save area/callback, signal FPC PASS");
}
