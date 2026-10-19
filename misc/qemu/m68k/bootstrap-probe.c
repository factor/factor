/* Execute actual Factor bootstrap subprimitive bytes under Linux/m68k. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
extern int factor_probe_run(void *,uint32_t *,int);
extern int factor_probe_mega(void *,uint32_t *,int,int);
static void *load_code(const char *dir,const char *name,size_t *length) {
  char path[4096]; snprintf(path,sizeof path,"%s/%s.bin",dir,name);
  FILE *f=fopen(path,"rb"); if(!f) { perror(path); exit(1); }
  fseek(f,0,SEEK_END); long size=ftell(f); rewind(f);
  void *code=mmap(NULL,size,PROT_READ|PROT_WRITE|PROT_EXEC,
                  MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(code==MAP_FAILED || fread(code,1,size,f)!=(size_t)size) exit(1);
  fclose(f); __builtin___clear_cache(code,(char *)code+size);
  *length=(size_t)size; return code;
}
static void check(const char *dir,const char *name,const uint32_t *in,int n,
                  const uint32_t *out,int m) {
  size_t size; void *code=load_code(dir,name,&size);
  uint32_t stack[32]={0}; memcpy(stack,in,n*4);
  int top=factor_probe_run(code,stack,n-1);
  if(top!=m-1 || memcmp(stack,out,m*4)) {
    fprintf(stderr,"FAIL %s top=%d expected=%d\n",name,top,m-1); exit(1);
  }
  munmap(code,size); printf("PASS %s\n",name);
}
uint32_t factor_probe_callback_snapshot[2];
extern void factor_probe_callback_body(void);
static void check_callback(const char *dir) {
  size_t size,rel_size;
  unsigned char *code=load_code(dir,"callback",&size);
  unsigned char *rel=load_code(dir,"callback-relocations",&rel_size);
  uint32_t callstack[2048],ds[32],rs[32];
  struct context {
    uint32_t top,bottom,ds,rs,save;
  } original={0},spare={0};
  struct { struct context *ctx,*spare; } vm={&original,&spare};
  spare.top=spare.bottom=(uint32_t)(callstack+2048)-20;
  spare.ds=(uint32_t)ds; spare.rs=(uint32_t)rs;
  if(rel_size!=12) { fputs("FAIL callback relocation count\n",stderr); exit(1); }
  for(int i=0;i<3;i++) {
    uint32_t entry; memcpy(&entry,rel+4*i,4);
    uint32_t offset=entry&0xffffff;
    uint32_t value=i==1?(uint32_t)factor_probe_callback_body:(uint32_t)&vm;
    memcpy(code+offset-4,&value,4);
  }
  __builtin___clear_cache(code,(char *)code+size);
  uint32_t input=0x12345678,result,fp2=19,fp2_after;
  __asm__ volatile("fmove.l %0,%%fp2" :: "d"(fp2) : "fp2");
  __asm__ volatile("move.l %1,%%a1; move.l %2,%%a0; jsr (%%a0); move.l %%d0,%0"
                   : "=d"(result) : "d"(input),"a"(code)
                   : "d0","d1","a0","a1","cc","memory");
  __asm__ volatile("fmove.l %%fp2,%0" : "=d"(fp2_after));
  if(result!=42 || fp2_after!=fp2 || factor_probe_callback_snapshot[0]!=input ||
     factor_probe_callback_snapshot[1]!=(uint32_t)code || vm.ctx!=&original) {
    fputs("FAIL callback snapshot/integer result/context restore\n",stderr); exit(1);
  }
  uint32_t *pointer=((uint32_t *(*)(void))code)();
  if(pointer!=factor_probe_callback_snapshot || vm.ctx!=&original) {
    fputs("FAIL callback pointer result/context restore\n",stderr); exit(1);
  }
  munmap(code,size); munmap(rel,rel_size);
  puts("PASS callback native inputs/results/context restore");
}
extern uint32_t factor_probe_unwind(void *,uint32_t);
extern void factor_probe_unwind_body(void);
static void check_unwind(const char *dir) {
  size_t size,rel_size;
  unsigned char *code=load_code(dir,"unwind-native-frames",&size);
  unsigned char *rel=load_code(dir,"unwind-relocations",&rel_size);
  uint32_t ds[4]={0},rs[4]={0},ctx[5]={0};
  uint32_t vm[10]={0},quot[5]={0};
  ctx[2]=(uint32_t)ds; ctx[3]=(uint32_t)rs;
  vm[0]=(uint32_t)ctx; vm[9]=1;
  quot[4]=(uint32_t)factor_probe_unwind_body;
  if(rel_size!=4) { fputs("FAIL unwind relocation count\n",stderr); exit(1); }
  uint32_t entry; memcpy(&entry,rel,4);
  uint32_t address=(uint32_t)vm;
  /* Relocation offset excludes the four-byte generated JIT prolog. */
  memcpy(code+(entry&0xffffff),&address,4);
  __builtin___clear_cache(code,(char *)code+size);
  if(factor_probe_unwind(code,(uint32_t)quot+4)!=42 || vm[9]!=0) {
    fputs("FAIL unwind native arguments/context/fault flag\n",stderr); exit(1);
  }
  munmap(code,size); munmap(rel,rel_size);
  puts("PASS unwind native arguments/context/fault flag");
}
extern uint32_t factor_probe_restore_stack(void *,uint32_t *);
extern void factor_probe_restore_resume(void);
static void check_restore_stack(const char *dir) {
  size_t size; void *code=load_code(dir,"set-callstack",&size);
  uint32_t saved_stack[3]={0,4<<4,(uint32_t)factor_probe_restore_resume};
  uint32_t ds[1]={(uint32_t)saved_stack+10};
  if(factor_probe_restore_stack(code,ds)!=42) {
    fputs("FAIL restore saved return stack\n",stderr); exit(1);
  }
  munmap(code,size);
  puts("PASS restore saved return stack");
}
static void check_mega(const char *dir) {
  size_t size,rel_size;
  unsigned char *code=load_code(dir,"mega",&size);
  unsigned char *rel=load_code(dir,"mega-relocations",&rel_size);
  uint32_t method[10]={0},cache[66]={0},hits=0;
  method[9]=(uint32_t)factor_probe_unwind_body;
  /* Production caches have 32 cells, not 32 class/method pairs. */
  cache[1]=32<<4;
  if(rel_size!=8) { fputs("FAIL mega relocation count\n",stderr); exit(1); }
  for(int i=0;i<2;i++) {
    uint32_t entry;memcpy(&entry,rel+4*i,4);
    uint32_t value=i?(uint32_t)&hits:(uint32_t)cache+2;
    memcpy(code+(entry&0xffffff)-4,&value,4);
  }
  __builtin___clear_cache(code,(char *)code+size);
  for(unsigned tag=0;tag<14;tag++) {
    if(tag==7) continue;
    memset(cache+2,0,64*4);
    unsigned slot=((tag<<4)>>4 &15)*2;
    cache[2+slot]=tag<<4;cache[3+slot]=(uint32_t)method+12;
    uint32_t object[2] __attribute__((aligned(16)))={tag<<2,0};
    uint32_t ds[1]={(uint32_t)object+tag};
    unsigned before=hits;
    if(factor_probe_mega(code,ds,0,0)!=0 || hits!=before+1) {
      fprintf(stderr,"FAIL mega tag=%u hits=%u expected=%u\n",tag,hits,before+1);exit(1);
    }
  }
  /* Set hash bit 4 so a mask sized for 32 pairs reads outside the cache. */
  uint32_t layouts[128] __attribute__((aligned(512)))={0};
  uint32_t *layout=layouts+64;
  uint32_t tuple[2] __attribute__((aligned(16)))={7<<2,(uint32_t)layout+2};
  uint32_t key=tuple[1];
  unsigned slot=((key>>4)&15)*2;
  memset(cache+2,0,64*4);cache[2+slot]=key;cache[3+slot]=(uint32_t)method+12;
  uint32_t ds[1]={(uint32_t)tuple+7};unsigned before=hits;
  if(factor_probe_mega(code,ds,0,0)!=0 || hits!=before+1) {
    fputs("FAIL mega tuple layout hash\n",stderr);exit(1);
  }
  cache[2+slot]=1;before=hits;
  if(factor_probe_mega(code,ds,0,0)!=0 || hits!=before) {
    fputs("FAIL mega cache miss guard\n",stderr);exit(1);
  }
  /* The stack top deliberately has a different class from the receiver. */
  for(unsigned index=1;index<=3;index++) {
    uint32_t stack[4]={(uint32_t)tuple+7,1,1,1};
    cache[2+slot]=key;cache[3+slot]=(uint32_t)method+12;
    before=hits;
    if(factor_probe_mega(code,stack,index,index)!=(int)index || hits!=before+1) {
      fprintf(stderr,"FAIL mega non-top dispatch index=%u\n",index);exit(1);
    }
    cache[2+slot]=1;before=hits;
    if(factor_probe_mega(code,stack,index,index)!=(int)index || hits!=before) {
      fprintf(stderr,"FAIL mega non-top miss index=%u\n",index);exit(1);
    }
  }
  munmap(code,size);munmap(rel,rel_size);
  puts("PASS mega 32-cell cache bounds, scalar/tuple hashes, indexed receivers and miss guard");
}
static void check_fpu_state(const char *dir) {
  size_t get_size,set_size;
  void *get_code=load_code(dir,"fpu-state",&get_size);
  void *set_code=load_code(dir,"set-fpu-state",&set_size);
  uint32_t original,status,control;
  __asm__ volatile("fmove.l %%fpcr,%0" : "=d"(original));
  uint32_t state=0xa0, accrued=0x10;
  __asm__ volatile("fmove.l %0,%%fpcr; fmove.l %1,%%fpsr"
                   :: "d"(state),"d"(accrued));
  uint32_t old=((uint32_t (*)(void))get_code)();
  __asm__ volatile("fmove.l %%fpsr,%0; fmove.l %%fpcr,%1"
                   : "=d"(status),"=d"(control));
  if(old!=state || status!=0 || control!=0x80) {
    fprintf(stderr,"FAIL fpu-state old=%x status=%x control=%x\n",old,status,control);
    exit(1);
  }
  ((void (*)(uint32_t))set_code)(state);
  __asm__ volatile("fmove.l %%fpcr,%0" : "=d"(control));
  if(control!=state) { fputs("FAIL set-fpu-state\n",stderr); exit(1); }
  __asm__ volatile("fmove.l %0,%%fpcr" :: "d"(original));
  munmap(get_code,get_size); munmap(set_code,set_size);
  puts("PASS fpu-state/set-fpu-state");
}
#define UNPAREN(...) __VA_ARGS__
#define TEST(name,inputs,outputs) do { \
  uint32_t in[]=UNPAREN inputs; uint32_t out[]=UNPAREN outputs; \
  check(argv[1],name,in,sizeof(in)/4,out,sizeof(out)/4); } while(0)
int main(int argc,char **argv) {
  if(argc!=2) return 2;
  TEST("dup",({16}),({16,16}));
  TEST("over",({16,32}),({16,32,16}));
  TEST("swap",({16,32}),({32,16}));
  TEST("rot",({16,32,48}),({32,48,16}));
  TEST("-rot",({16,32,48}),({48,16,32}));
  TEST("2dup",({16,32}),({16,32,16,32}));
  TEST("dupd",({16,32}),({16,16,32}));
  TEST("3dup",({16,32,48}),({16,32,48,16,32,48}));
  TEST("4dup",({16,32,48,64}),({16,32,48,64,16,32,48,64}));
  TEST("nip",({16,32}),({32}));
  TEST("2nip",({16,32,48}),({48}));
  TEST("fixnum+fast",({32,48}),({80}));
  TEST("fixnum-fast",({32,48}),({(uint32_t)-16}));
  TEST("fixnum*fast",({32,48}),({96}));
  TEST("fixnum*",({32,48}),({96}));
  TEST("fixnum*",({(uint32_t)-32,48}),({(uint32_t)-96}));
  TEST("fixnum-bitand",({48,80}),({16}));
  TEST("fixnum-bitor",({48,80}),({112}));
  TEST("fixnum-bitxor",({48,80}),({96}));
  TEST("fixnum-bitnot",({32}),({(uint32_t)-48}));
  TEST("fixnum-i-fast",({112,32}),({48}));
  TEST("fixnum-mod",({112,32}),({16}));
  TEST("fixnum-mod-fast",({112,32}),({48,16}));
  TEST("fixnum-shift-fast",({32,32}),({128}));
  TEST("fixnum-shift-fast",({128,(uint32_t)-32}),({32}));
  check_fpu_state(argv[1]);
  check_unwind(argv[1]);
  check_restore_stack(argv[1]);
  check_mega(argv[1]);
  check_callback(argv[1]);
  return 0;
}
