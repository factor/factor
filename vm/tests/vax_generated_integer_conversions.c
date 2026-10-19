// Execute the backend byte/word sign and zero extension encodings natively.
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

int main(void) {
  const unsigned char opcodes[] = {0x98, 0x9a, 0x32, 0x3c};
  const uint32_t values[] = {0, 1, 0x7f, 0x80, 0xff, 0x7fff,
                              0x8000, 0xffff, 0x12345678, 0xffffffff};
  void *page = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                   MAP_PRIVATE | MAP_ANON, -1, 0);
  assert(page != MAP_FAILED);
  for (unsigned operation = 0; operation < 4; operation++) {
    unsigned char code[] = {0, 0, 0, 0xac, 4, 0x50, 4};
    code[2] = opcodes[operation];
    memcpy(page, code, sizeof(code));
    __builtin___clear_cache(page, (char *)page + sizeof(code));
    uint32_t (*convert)(uint32_t) = page;
    for (unsigned i = 0; i < sizeof(values) / sizeof(values[0]); i++) {
      uint32_t value = values[i], expected;
      switch (operation) {
      case 0: expected = (uint32_t)(int32_t)(int8_t)value; break;
      case 1: expected = (uint8_t)value; break;
      case 2: expected = (uint32_t)(int32_t)(int16_t)value; break;
      default: expected = (uint16_t)value; break;
      }
      assert(convert(value) == expected);
    }
  }
  assert(munmap(page, 4096) == 0);
  puts("VAX generated narrow integer conversions: 40 native executions passed");
  return 0;
}
