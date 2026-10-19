#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
struct context { uint32_t top, bottom, ds, rs, save; };
struct vm { struct context *ctx, *spare; };
static struct vm *expected_vm;
static uint32_t expected_pc;
static unsigned calls;
static void primitive(struct vm *parent) {
  assert(parent == expected_vm);
  assert(*(uint32_t *)parent->ctx->top == expected_pc);
  ++calls;
}
extern void primitive_oracle(struct vm *, void *);
__asm__(".text\n.align 1\n.globl primitive_oracle\nprimitive_oracle:\n"
        ".word 0x0ffc\nmovl 4(%ap),%r8\nmovl 8(%ap),%r4\nmovl (%r8),%r9\n"
        "movl 8(%r9),%r6\nmovl 12(%r9),%r7\njsb (%r4)\nret\n");
static size_t read_file(const char *path, void *bytes, size_t size) {
  FILE *f=fopen(path,"rb"); assert(f);
  size_t n=fread(bytes,1,size,f); assert(!ferror(f)); fclose(f); return n;
}
int main(void) {
  uint32_t ds[16],rs[16],reloc;
  struct context ctx={0,0,(uint32_t)ds,(uint32_t)rs,0};
  struct vm parent={&ctx,0}; expected_vm=&parent;
  unsigned char *code=mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_ANON|MAP_PRIVATE,-1,0);
  assert(code != MAP_FAILED);
  /* JSB's return cell plus twelve reserved argument bytes form the frame. */
  const unsigned char prolog[]={0xc2,12,0x5e};
  const unsigned char epilog[]={0xc0,12,0x5e,0x05};
  memcpy(code,prolog,sizeof prolog);
  size_t n=read_file("primitive.bin",code+sizeof prolog,4000);
  assert(read_file("primitive.relocations",&reloc,4)==4);
  assert((reloc>>24)==0);
  unsigned offset=reloc&0xffffff; assert(offset>=4&&offset<=n);
  uint32_t target=(uint32_t)&primitive;
  memcpy(code+sizeof prolog+offset-4,&target,4);
  memcpy(code+sizeof prolog+n,epilog,sizeof epilog);
  expected_pc=(uint32_t)code+sizeof prolog+offset;
  primitive_oracle(&parent,code);
  assert(calls==1);
  assert(ctx.ds==(uint32_t)ds&&ctx.rs==(uint32_t)rs);
  munmap(code,4096);
  puts("Generated VAX JIT primitive: native CALLG argument and exact PC-relative anchor passed");
  return 0;
}
