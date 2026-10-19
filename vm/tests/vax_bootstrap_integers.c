#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
extern uint32_t run_integer(uint32_t *, void *);
__asm__(".text\n.align 1\n.globl run_integer\nrun_integer:\n"
        ".word 0x0ffc\nmovl 4(%ap),%r6\nmovl 8(%ap),%r4\n"
        "jsb (%r4)\nmovl (%r6),%r0\nret\n");
static size_t read_file(const char *path, void *bytes, size_t size) {
  FILE *f=fopen(path,"rb"); assert(f);
  size_t n=fread(bytes,1,size,f); assert(!ferror(f)); fclose(f); return n;
}
static uint32_t tag(int32_t x) { return (uint32_t)x << 4; }
static uint32_t expected(unsigned op,int32_t x,int32_t y) {
  switch(op) {
    case 0:return tag(x+y); case 1:return tag(x-y); case 2:return tag(x*y);
    case 3:return tag(x&y); case 4:return tag(x|y); case 5:return tag(x^y);
    case 6:return tag(x/y); case 7:case 8:return tag(x%y);
    case 9:
      if(y>=32)return 0;
      if(y>=0)return tag(x)<<y;
      if(y<=-32)return x<0?UINT32_C(0xfffffff0):0;
      return ((uint32_t)((int32_t)tag(x)>>-y)) & UINT32_C(0xfffffff0);
  }
  abort();
}
int main(void) {
  static const char *names[]={"fixnum+fast","fixnum-fast","fixnum*fast",
    "fixnum-bitand","fixnum-bitor","fixnum-bitxor","fixnum_i-fast",
    "fixnum-mod","fixnum_mod-fast","fixnum-shift-fast"};
  static const int32_t values[]={-100,-7,-3,-1,1,2,3,7,100};
  static const int32_t shifts[]={-255,-33,-32,-31,-5,-1,0,1,5,31,32,33,255};
  unsigned cases=0;
  for(unsigned op=0;op<10;++op) {
    printf("Testing %s\n",names[op]); fflush(stdout);
    char path[64]; snprintf(path,sizeof path,"%s.bin",names[op]);
    unsigned char *code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_ANON|MAP_PRIVATE,-1,0);
    assert(code!=MAP_FAILED);
    const unsigned char prolog[]={0xc2,12,0x5e}, epilog[]={0xc0,12,0x5e,0x05};
    memcpy(code,prolog,sizeof prolog);
    size_t n=read_file(path,code+sizeof prolog,4000);
    memcpy(code+sizeof prolog+n,epilog,sizeof epilog);
    for(unsigned a=0;a<sizeof values/sizeof *values;++a)
      for(unsigned b=0;b<(op==9?sizeof shifts/sizeof *shifts:sizeof values/sizeof *values);++b) {
        int32_t x=values[a],y=op==9?shifts[b]:values[b];
        uint32_t ds[]={tag(x),tag(y)};
        uint32_t got=run_integer(&ds[1],code),want=expected(op,x,y);
        if(got!=want)fprintf(stderr,"%s x=%d y=%d got=%08x want=%08x\n",names[op],x,y,got,want);
        assert(got==want);
        if(op==8)assert(ds[0]==tag(x/y));
        ++cases;
      }
    assert(munmap(code,4096)==0);
  }
  printf("Generated VAX bootstrap integers: %u native cases passed\n",cases);
  return 0;
}
