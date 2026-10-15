#include "master.hpp"
#include <cstdio>
extern "C" void sparc_callback_sret_entry();
struct triple { int a,b,sum; };
int main(int argc,char**argv) {
 if(argc!=2) return 2;
 factor::jit_set_writable();
 factor::init_mvm();
 factor::factor_vm* vm=factor::new_factor_vm();
 factor::vm_parameters p;
 p.image_path=factor::safe_strdup(argv[1]);
 p.signals=false;
 vm->init_factor(&p);
 vm->ctx=vm->new_context();
 factor::cell owner=vm->special_objects[factor::C_TO_FACTOR_WORD];
 factor::word* w=factor::untag<factor::word>(owner);
 factor::cell original=w->entry_point;
 w->entry_point=(factor::cell)&sparc_callback_sret_entry;
 factor::code_block* stub=vm->callbacks->add(owner,4);
 auto fn=(triple(*)(int,int))stub->entry_point();
 for(int i=-20;i<=20;i++) for(int j=-20;j<=20;j++) {
  triple got=fn(i,j);
  if(got.a!=i || got.b!=j || got.sum!=i+j) {
   std::fprintf(stderr,"FAIL actual callback allocation %d %d -> %d %d %d\n",i,j,got.a,got.b,got.sum);return 1;
  }
 }
 w->entry_point=original;
 std::puts("PASS actual full C++ VM callback allocation GNU32 SRET 1681 cases; body is explicit ABI assembly fixture");
 return 0;
}
