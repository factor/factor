// Execute actual byte streams emitted by cpu.hppa on a native GNU HPPA host.
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
int main(int argc, char** argv) {
  assert(argc == 14);
  const int32_t values[] = {INT32_MIN, -42, -1, 0, 1, 42, INT32_MAX};
  for (int op = 0; op < 13; ++op) {
    FILE* input = fopen(argv[op + 1], "rb"); assert(input);
    void* code = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    assert(code != MAP_FAILED);
    size_t length = fread(code, 1, 4096, input); assert(length && length < 4096);
    fclose(input);
    __builtin___clear_cache((char*)code, (char*)code + length);
    auto function = (uint32_t(*)(int32_t, int32_t))code;
    if (op == 7) {
      uint32_t frame[5008];
      uintptr_t before = (uintptr_t)(frame + 5004), after;
      __asm__ volatile("copy %0,%%r18" : : "r"(before) : "r18");
      assert(function(0, 0) == 42);
      __asm__ volatile("copy %%r18,%0" : "=r"(after));
      assert(after == before);
      assert(frame[4] == before);
    } else for (int32_t a : values) for (int32_t b : values) {
      int64_t wide = op == 10 ? int64_t(a) + b : op == 11 ? int64_t(a) - b : int64_t(a) * b;
      uint32_t expected = op >= 10 ? wide < INT32_MIN || wide > INT32_MAX
                          : op == 0 ? uint32_t(a) + uint32_t(b)
                          : op == 1 ? uint32_t(a) - uint32_t(b)
                          : op < 4 ? a < b
                          : op == 9 ? uint32_t(a) * uint32_t(b)
                          : op == 8 ? uint32_t(a)
                          : op == 4 ? uint32_t(a) << (uint32_t(b) & 31)
                          : op == 5 ? uint32_t(a) >> (uint32_t(b) & 31)
                                    : uint32_t(a >> (uint32_t(b) & 31));
      assert(function(a, b) == expected);
    }
    assert(munmap(code, 4096) == 0);
  }
  puts("Factor-emitted scalar arithmetic/comparison/alias/shifts: 588 native scalar/conversion/overflow cases and 20000-byte linked frame passed");
}
