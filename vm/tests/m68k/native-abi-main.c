#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include "native-abi.h"
static uint32_t cb(uint32_t a,uint32_t b){return a*7+b;}
int main(void){
 assert(sizeof(void*)==4);
#if defined(__NetBSD__)
 _Static_assert(_Alignof(uint32_t)==4 && _Alignof(double)==8, "NetBSD native alignment");
 _Static_assert(sizeof(struct m68k_abi_record)==16, "NetBSD aggregate size");
#else
 _Static_assert(_Alignof(uint32_t)==2 && _Alignof(double)==2, "GNU Linux native alignment");
 _Static_assert(sizeof(struct m68k_abi_record)==14, "GNU Linux aggregate size");
#endif
 struct m68k_abi_record r=m68k_abi_roundtrip((struct m68k_abi_record){2,35,2.5});
 printf("ptr=%zu u32align=%zu doublealign=%zu structsize=%zu offsets=%zu,%zu\n",sizeof(void*),_Alignof(uint32_t),_Alignof(double),sizeof(r),offsetof(struct m68k_abi_record,integer),offsetof(struct m68k_abi_record,real));
 assert(r.tag==3&&r.integer==42&&r.real==5.0);
 assert(m68k_abi_follow((struct m68k_abi_record){2,35,2.5},7)==42);
 assert(m68k_abi_u64(UINT64_C(0x100000000))==UINT64_C(0x223456789));
 assert(m68k_abi_varargs(3,1.25,2.5,3.75)==7.5);
 assert(m68k_abi_callback(cb)==42);
 puts("native aggregate/scalar/varargs/callback ABI passed");
}
