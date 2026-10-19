#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

/* Enter raw PIC bytes with the native ABI's saved Factor registers intact. */
extern uint32_t pic_tail_oracle(uint32_t call_site, uint32_t *data, void *code);
__asm__(".text\n.align 1\n.globl pic_tail_oracle\npic_tail_oracle:\n"
        ".word 0x0ffc\nmovl 4(%ap),%r5\nmovl 8(%ap),%r6\n"
        "movl 12(%ap),%r0\njsb (%r0)\nret\n");

static uint32_t invoke(const char *path, uint32_t call_site, void *target) {
  unsigned char *code = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                            MAP_ANON | MAP_PRIVATE, -1, 0);
  assert(code != MAP_FAILED);
  FILE *input = fopen(path, "rb");
  assert(input);
  size_t length = fread(code, 1, 4096, input);
  assert(!ferror(input) && length >= 6 && length < 4096);
  fclose(input);
  /* The last relocation is the absolute JMP to the miss-resume word. */
  assert(code[length - 6] == 0x17 && code[length - 5] == 0x9f);
  uint32_t destination = (uint32_t)target;
  memcpy(code + length - 4, &destination, sizeof destination);
  uint32_t object = 0x12300007; /* A quotation's observed dispatch tag. */
  uint32_t result = pic_tail_oracle(call_site, &object, code);
  munmap(code, 4096);
  return result;
}

int main(void) {
  unsigned char *target = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                              MAP_ANON | MAP_PRIVATE, -1, 0);
  assert(target != MAP_FAILED);
  const unsigned char body[] = {0xd0, 0x55, 0x50, 0x05}; /* MOVL R5,R0; RSB */
  memcpy(target, body, sizeof body);
  uint32_t call_site = 0x709babf7; /* A tail-site value sampled during diagnosis. */
  assert(invoke("old-pic-tail.bin", call_site, target) == 7);
  assert(invoke("new-pic-tail.bin", call_site, target) == call_site);
  munmap(target, 4096);
  puts("VAX tail PIC: old class tag7 replaces call site; new preserves call site");
  return 0;
}
