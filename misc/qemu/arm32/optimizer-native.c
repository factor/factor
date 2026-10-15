/* Execute functions emitted by optimizer-emit.factor on native ARM32. */
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/mman.h>
static void *load(const char *name) {
 FILE *f=fopen(name,"rb"); assert(f); void *p=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0); assert(p!=MAP_FAILED);
 size_t n=fread(p,1,4096,f); assert(n); fclose(f); __builtin___clear_cache(p,(char*)p+n); return p;
}
int main(void) {
 int (*add)(int,int)=load("/tmp/arm32-backend-add.bin");
 double (*fadd)(double,double)=load("/tmp/arm32-backend-fadd.bin");
 assert(add(17,25)==42); assert(add(-123,45)==-78);
 assert(fadd(1.25,2.5)==3.75); assert(fadd(-4.0,0.5)==-3.5);
 double (*mixed)(float,double,float)=load("/tmp/arm32-backend-mixed.bin");
 assert(mixed(1.25f,2.5,3.0f)==6.75);
 assert(mixed(-2.0f,4.0,-1.0f)==1.0);
 int (*schar)(const signed char *)=load("/tmp/arm32-backend-schar.bin");
 int (*to_short)(int)=load("/tmp/arm32-backend-short.bin");
 signed char sc=-123; assert(schar(&sc)==-123); assert(to_short(0xffff8001)==-32767);
 typedef struct {double a,b;} HD; typedef struct {float a,b;} HF;
 double (*hfa_arg)(float,HD)=load("/tmp/arm32-backend-hfa-arg.bin");
 HF (*hfa_ret)(float,float)=load("/tmp/arm32-backend-hfa-ret.bin");
 assert(hfa_arg(100.0f,(HD){1.25,2.5})==3.75); HF hf=hfa_ret(1.25f,2.5f); assert(hf.a==3.75f && hf.b==1.25f);
 int (*fplt)(double,double)=load("/tmp/arm32-backend-fplt.bin");
 int (*fpnotle)(double,double)=load("/tmp/arm32-backend-fpnotle.bin");
 assert(fplt(1.0,2.0)==1 && fplt(2.0,1.0)==0 && fplt(NAN,1.0)==0 && fplt(1.0,NAN)==0);
 assert(fpnotle(1.0,2.0)==0 && fpnotle(2.0,1.0)==1 && fpnotle(NAN,1.0)==1 && fpnotle(1.0,NAN)==1);
 int (*popcount)(unsigned)=load("/tmp/arm32-backend-popcount.bin");
 double (*fminimum)(double,double)=load("/tmp/arm32-backend-fmin.bin");
 assert(popcount(0)==0 && popcount(0xffffffff)==32 && popcount(0x01234567)==12);
 assert(fminimum(2.5,1.25)==1.25 && fminimum(NAN,1.25)==1.25 && fminimum(1.25,NAN)==1.25);
 assert(signbit(fminimum(0.0,-0.0)) && signbit(fminimum(-0.0,0.0)));
 struct { void *pad[4]; void *save; } ctx; union { double align; char bytes[144]; } cb; ctx.save=cb.bytes;
 *(int*)(cb.bytes+112)=-1234; *(double*)(cb.bytes+120)=3.75;
 void *(*cb_stack)(void*)=load("/tmp/arm32-backend-cb-stack.bin");
 int (*cb_int)(void*)=load("/tmp/arm32-backend-cb-int.bin");
 double (*cb_double)(void*)=load("/tmp/arm32-backend-cb-double.bin");
 assert(cb_stack(&ctx)==cb.bytes+112 && cb_int(&ctx)==-1234 && cb_double(&ctx)==3.75);
 double (*varargs)(int,...)=load("/tmp/arm32-backend-varargs.bin");
 double (*varargs_named_float)(float,...)=load("/tmp/arm32-backend-varargs.bin");
 assert(varargs(0,3.75)==3.75 && varargs(0,-4.5)==-4.5);
 assert(varargs_named_float(1.25f,6.5)==6.5);
 typedef struct {int a,b,c,d;} SC; typedef struct {long long x; int y;} SW;
 int (*struct_split)(int,SC)=load("/tmp/arm32-backend-struct-split.bin");
 int (*struct_wide)(int,SW)=load("/tmp/arm32-backend-struct-wide.bin");
 assert(struct_split(10,(SC){20,30,40,50})==150);
 assert(struct_wide(1,(SW){7,9})==17);
 int (*shr0)(int)=load("/tmp/arm32-backend-shr0.bin");
 int (*sar0)(int)=load("/tmp/arm32-backend-sar0.bin");
 assert(shr0(123)==123 && shr0(-123)==-123 && sar0(123)==123 && sar0(-123)==-123);
 puts("ARM32 generated scalar, AAPCS and callback transport probes passed");
}
