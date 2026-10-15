#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

/* A native entry establishes CALLS state; the generated quotation body uses
   JSB/RSB and must keep its tagged quotation in R4 for lazy compilation. */
extern uint32_t quotation_oracle(uint32_t quotation, void *code);
__asm__(".text\n.align 1\n.globl quotation_oracle\nquotation_oracle:\n"
        ".word 0x0ffc\nmovl 4(%ap),%r4\nmovl 8(%ap),%r5\n"
        "jsb (%r5)\nret\n");

/* The host emitter uses a 12-byte tagged displacement. This fixture
   isolates register preservation; the target seed separately uses 8 bytes. */
struct quotation {
  uint32_t header, array, cached_effect, host_layout_padding, entry_point;
} __attribute__((aligned(16)));

static uint32_t invoke(const char *path, struct quotation *quotation) {
  unsigned char *code = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                            MAP_ANON | MAP_PRIVATE, -1, 0);
  assert(code != MAP_FAILED);
  FILE *input = fopen(path, "rb");
  assert(input);
  size_t length = fread(code, 1, 4095, input);
  assert(!ferror(input) && length == 6);
  fclose(input);
  code[length] = 0x05; /* RSB after the non-tail JSB. */
  uint32_t result = quotation_oracle((uint32_t)quotation | 4, code);
  munmap(code, 4096);
  return result;
}

int main(void) {
  unsigned char *target = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                              MAP_ANON | MAP_PRIVATE, -1, 0);
  assert(target != MAP_FAILED);
  const unsigned char body[] = {0xd0, 0x54, 0x50, 0x05}; /* MOVL R4,R0; RSB */
  memcpy(target, body, sizeof body);
  struct quotation quotation = {16, 1, 1, 0, (uint32_t)target};
  uint32_t tagged = (uint32_t)&quotation | 4;
  assert(invoke("old-call.bin", &quotation) == (uint32_t)target);
  assert(invoke("old-jump.bin", &quotation) == (uint32_t)target);
  assert(invoke("new-call.bin", &quotation) == tagged);
  assert(invoke("new-jump.bin", &quotation) == tagged);
  munmap(target, 4096);
  puts("VAX quotation register: old call/jump clobber; new call/jump preserve tagged R4");
  return 0;
}
