/* Native compiler control for the staged RV64 FFI library.
 * GCC can compile directly. Clang21 also needs the same packed temporary
 * allocation repair in its emitted caller IR before optimizing. */
#include <assert.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/stat.h>
struct rv_bit_fp { unsigned int bits:3; double number; };
struct __attribute__((packed)) rv_fp_bit { float number; signed int bits:13; };
static double callback(struct rv_bit_fp v,long t) { return v.bits+2*v.number+t; }
static double packed_callback(struct rv_fp_bit v,long t) { return v.bits+2*v.number+t; }
static struct rv_fp_bit packed_return_callback(float n,int b) { struct rv_fp_bit v={n,b}; return v; }
int main(int argc,char**argv) {
 assert(argc==2);void*h=dlopen(argv[1],RTLD_NOW);if(!h){puts(dlerror());return 1;}
 size_t(*n)(void)=dlsym(h,"rv_sizeof_nlink_t"),(*b)(void)=dlsym(h,"rv_sizeof_blksize_t");
 assert(n&&b);assert(n()==sizeof(((struct stat*)0)->st_nlink));assert(b()==sizeof(((struct stat*)0)->st_blksize));
 double(*take)(struct rv_bit_fp,long)=dlsym(h,"rv_take_bit_fp");
 struct rv_bit_fp(*ret)(unsigned,double)=dlsym(h,"rv_return_bit_fp");
 double(*call)(double(*)(struct rv_bit_fp,long))=dlsym(h,"rv_call_bit_fp");
 assert(take&&ret&&call);struct rv_bit_fp v=ret(5,-3.0);assert(v.bits==5&&v.number==-3.0);assert(take(v,11)==10);assert(call(callback)==23);
 double(*packed)(struct rv_fp_bit,long)=dlsym(h,"rv_take_fp_bit");
 struct rv_fp_bit(*pret)(float,int)=dlsym(h,"rv_return_fp_bit");assert(packed&&pret);
 struct rv_fp_bit pv=pret(-3,-4095);printf("packed return number=%g bits=%d sizeof=%zu packed take=%g\n",(double)pv.number,pv.bits,sizeof(pv),packed(pv,11));assert(pv.number==-3&&pv.bits==-4095);assert(packed(pv,11)==-4090);
 double(*pcall)(double(*)(struct rv_fp_bit,long))=dlsym(h,"rv_call_fp_bit");
 double(*prcall)(struct rv_fp_bit(*)(float,int))=dlsym(h,"rv_call_return_fp_bit");assert(pcall&&prcall);
 assert(pcall(packed_callback)==-2031);assert(prcall(packed_return_callback)==-4101);
 printf("native SDK/cross FFI ABI PASS: nlink=%zu blksize=%zu, mixed struct argument/return, callback, packed signed bitfield\n",n(),b());
 return dlclose(h)!=0;
}
