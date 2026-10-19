/* Native base-AAPCS transport probe for the generated softfp-emit.factor code.
 * OpenBSD: -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp
 *          -fno-ret-protector -Wl,-z,wxneeded; run on a wxallowed filesystem.
 * Linux armhf: pcs(aapcs) declarations exercise the same core-register ABI.
 */
#include <assert.h>
#include <stdio.h>
#include <sys/mman.h>
static void *load(const char *name) {
 FILE *f=fopen(name,"rb"); assert(f);
 void *p=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(p!=MAP_FAILED);
 size_t n=fread(p,1,4096,f); assert(n); fclose(f); __builtin___clear_cache(p,(char*)p+n); return p;
}
typedef float (*float_fn)(float) __attribute__((pcs("aapcs")));
typedef double (*double_fn)(double) __attribute__((pcs("aapcs")));
int main(void) {
 float_fn uf=(float_fn)load("/tmp/arm32-backend-softfp-float.bin");
 float_fn bf=(float_fn)load("/tmp/arm32-backend-softfp-float-box.bin");
 double_fn ud=(double_fn)load("/tmp/arm32-backend-softfp-double.bin");
 double_fn bd=(double_fn)load("/tmp/arm32-backend-softfp-double-box.bin");
 assert(uf(1.25f)==1.25f && uf(-4.5f)==-4.5f);
 assert(bf(1.25f)==1.25f && bf(-4.5f)==-4.5f);
 assert(ud(1.25)==1.25 && ud(-4.5)==-4.5);
 assert(bd(1.25)==1.25 && bd(-4.5)==-4.5);
 puts("ARM32 generated softfp boxer/unboxer transport passed");
}
