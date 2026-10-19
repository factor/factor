// Emitted foreign-memory hooks preserve native r6/r7 in their probe wrappers.
#include <assert.h>
#include <initializer_list>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
static void* load(const char* path) {
  FILE* input = fopen(path, "rb"); assert(input);
  char* code = (char*)mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                           MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  size_t size = fread(code, 1, 4096, input); assert(size && size < 4096); fclose(input);
  __builtin___clear_cache(code, code + size); return code;
}
int main(int argc, char** argv) {
  assert(argc == 7);
  void* code[6]; for (unsigned i = 0; i < 6; ++i) code[i] = load(argv[i + 1]);
  unsigned char bytes[16];
  const uint32_t words[] = {0, 1, 0x12345678, 0x7fffffff, 0x80000000, 0xffffffff};
  for (uint32_t value : words) {
    memset(bytes, 0xa5, sizeof(bytes));
    assert(((uint32_t(*)(void*, uint32_t))code[0])(bytes, value) == value);
    for (unsigned i = 0; i < 4; ++i) assert(bytes[i + 1] == ((value >> (24 - 8 * i)) & 255));
    assert(bytes[0] == 0xa5 && bytes[5] == 0xa5);
  }
  for (unsigned value : {0u, 0x7fu, 0x80u, 0xffu}) {
    bytes[1] = value;
    assert(((int32_t(*)(void*))code[1])(bytes) == int8_t(value));
  }
  for (unsigned value : {0u, 0x7fffu, 0x8000u, 0xffffu}) {
    bytes[1] = value >> 8; bytes[2] = value;
    assert(((int32_t(*)(void*))code[2])(bytes) == int16_t(value));
  }
  const double doubles[] = {-INFINITY, -42, -0.0, 0, 1.25, INFINITY, NAN};
  for (double value : doubles) {
    memset(bytes, 0xa5, sizeof(bytes));
    double result = ((double(*)(void*, double))code[3])(bytes, value);
    assert(isnan(value) ? isnan(result) : result == value && signbit(result) == signbit(value));
    assert(memcmp(bytes + 1, &value, 8) == 0 && bytes[0] == 0xa5 && bytes[9] == 0xa5);
  }
  assert(((double(*)())code[4])() == 1.25);
  assert(((float(*)())code[5])() == 1.25f);
  for (void* p : code) assert(munmap(p, 4096) == 0);
  puts("Factor-emitted unaligned integer/FP memory and target-endian constants: 23 native cases passed");
}
