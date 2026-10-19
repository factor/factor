// Run actual Factor aggregate component CFG instructions after HPPA codegen.
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
typedef uint32_t (*part_code)(unsigned char*, uint32_t);
static part_code load_code(const char* path) {
  FILE* input = fopen(path, "rb"); assert(input);
  char* code = (char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code != MAP_FAILED);
  size_t size = fread(code,1,4096,input); assert(size && size < 4096); fclose(input);
  __builtin___clear_cache(code, code + size);
  return (part_code)code;
}
int main(int argc, char** argv) {
  assert(argc == 9);
  unsigned cases = 0;
  for (unsigned count = 1; count <= 4; count++) {
    part_code read = load_code(argv[count]);
    part_code write = load_code(argv[count + 4]);
    for (uint32_t seed = 0; seed < 64; seed++) {
      unsigned char memory[16]; memset(memory, 0xa5, sizeof memory);
      uint32_t expected = 0;
      for (unsigned i = 0; i < count; i++) {
        unsigned char byte = seed * 43 + i * 79;
        memory[i + 3] = byte; expected = (expected << 8) | byte;
      }
      assert(read(memory + 3, 0) == expected);
      uint32_t value = seed * 0x87654321u;
      assert(write(memory + 3, value) == value);
      for (unsigned i = 0; i < sizeof memory; i++) {
        unsigned char wanted = i >= 3 && i < 3 + count
          ? (value >> (8 * (count - (i - 3) - 1))) : 0xa5;
        assert(memory[i] == wanted);
      }
      cases += 2;
    }
    assert(munmap((void*)read,4096) == 0 && munmap((void*)write,4096) == 0);
  }
  printf("Factor CFG-emitted aggregate components: %u load/store and bounds cases passed\n", cases);
  return 0;
}
