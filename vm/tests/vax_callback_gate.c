#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
struct context { uint32_t top, bottom, ds, rs, save; };
struct vm { struct context *ctx, *spare; };
static uint32_t fp_state = 0x1234;
static uint32_t get_fp(void) { uint32_t old = fp_state; fp_state = 0; return old; }
static void set_fp(uint32_t state) { fp_state = state; }
extern int callback_oracle(void *);
extern void factor_probe(void);
__asm__(
    ".text\n"
    ".align 1\n"
    ".globl callback_oracle\n"
    "callback_oracle:\n"
    ".word 0x0ffc\n"
    "movl 4(%ap),%r0\n"
    "movl $258,%r2\n"
    "movl $259,%r3\n"
    "movl $260,%r4\n"
    "movl $261,%r5\n"
    "movl $262,%r6\n"
    "movl $263,%r7\n"
    "movl $264,%r8\n"
    "movl $265,%r9\n"
    "movl $266,%r10\n"
    "movl $267,%r11\n"
    "movl $0x12345678,%r1\n"
    "pushl $22\n"
    "pushl $11\n"
    "calls $2,(%r0)\n"
    "cmpl %r0,$33\n"
    "bneq 1f\n"
    "cmpl %r1,$99\n"
    "bneq 1f\n"
    "cmpl %r2,$258\n"
    "bneq 1f\n"
    "cmpl %r3,$259\n"
    "bneq 1f\n"
    "cmpl %r4,$260\n"
    "bneq 1f\n"
    "cmpl %r5,$261\n"
    "bneq 1f\n"
    "cmpl %r6,$262\n"
    "bneq 1f\n"
    "cmpl %r7,$263\n"
    "bneq 1f\n"
    "cmpl %r8,$264\n"
    "bneq 1f\n"
    "cmpl %r9,$265\n"
    "bneq 1f\n"
    "cmpl %r10,$266\n"
    "bneq 1f\n"
    "cmpl %r11,$267\n"
    "bneq 1f\n"
    "movl $1,%r0\n"
    "ret\n"
    "1: clrl %r0\n"
    "ret\n"
    ".globl factor_probe\n"
    "factor_probe:\n"
    "movl 16(%r9),%r4\n"
    "cmpl 8(%r4),$0x12345678\n"
    "bneq 2f\n"
    "movl 4(%ap),%r0\n"
    "addl2 8(%ap),%r0\n"
    "movl $99,%r1\n"
    "movl $514,%r2\n"
    "movl $515,%r3\n"
    "movl $516,%r4\n"
    "movl $517,%r5\n"
    "movl $518,%r6\n"
    "movl $519,%r7\n"
    "movl $520,%r8\n"
    "movl $521,%r9\n"
    "movl $522,%r10\n"
    "movl $523,%r11\n"
    "rsb\n"
    "2: clrl %r0\n"
    "rsb\n"
);
static size_t read_file(const char *path, void *bytes, size_t size) {
  FILE *f = fopen(path, "rb"); assert(f);
  size_t count = fread(bytes, 1, size, f); assert(!ferror(f)); fclose(f); return count;
}
int main(void) {
  uint32_t stack[1024], ds[16], rs[16], reloc[16];
  struct context old = {0}, next = {0, (uint32_t)&stack[1020], (uint32_t)ds, (uint32_t)rs, 0};
  struct vm parent = {&old, &next};
  unsigned char *code = mmap(0, 4096, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_ANON|MAP_PRIVATE, -1, 0);
  assert(code != MAP_FAILED);
  size_t size = read_file("callback.bin", code, 4096);
  assert(size > 2 && code[0] == 0xfc && code[1] == 0x0f);
  assert(read_file("callback.relocations", reloc, sizeof(reloc)) == 6 * sizeof(uint32_t));
  uint32_t targets[] = {(uint32_t)&get_fp, (uint32_t)&parent, (uint32_t)&set_fp,
                        (uint32_t)&factor_probe, (uint32_t)&parent, (uint32_t)&set_fp};
  const unsigned types[] = {0, 9, 0, 1, 9, 0};
  for (unsigned i = 0; i < 6; ++i) {
    unsigned offset = reloc[i] & 0xffffff;
    assert((reloc[i] >> 28) == types[i] && ((reloc[i] >> 24) & 15) == 0);
    assert(offset >= 4 && offset <= size);
    memcpy(code + offset - 4, &targets[i], 4);
  }
  assert(callback_oracle(code));
  assert(parent.ctx == &old && fp_state == 0x1234);
  assert(munmap(code, 4096) == 0);
  puts("Generated VAX callback gate: AP args, hidden R1, R2-R11, FP state passed");
  return 0;
}
