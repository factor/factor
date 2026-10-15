// Execute the actual Factor-generated bootstrap bytes on Alpha.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <sys/mman.h>
extern "C" uintptr_t* alpha_bootstrap_enter(void*, uintptr_t*);
static uintptr_t* run(const char* file, uintptr_t* top) {
  FILE* stream = fopen(file, "rb");
  assert(stream);
  auto* code = (unsigned char*)mmap(nullptr, 8192, PROT_READ | PROT_WRITE | PROT_EXEC,
                                  MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  size_t length = fread(code, 1, 8192 - 4, stream);
  assert(!ferror(stream) && fclose(stream) == 0);
  for (size_t i = 0; i + 12 <= length; i += 4) {
    uint32_t instruction;
    memcpy(&instruction, code + i, 4);
    if (instruction == 0xc0c00002) {
      uintptr_t true_object = 0x123b;
      memcpy(code + i + 4, &true_object, 8);
    }
  }
  uint32_t ret = 0x6bfa8001;
  memcpy(code + length, &ret, 4);
  __asm__ __volatile__("mb; call_pal 0x86" ::: "memory");
  auto* result = alpha_bootstrap_enter(code, top);
  assert(munmap(code, 8192) == 0);
  return result;
}
int main() {
  uintptr_t stack[16] = {};
  stack[2] = 11 << 4;
  assert(run("alpha-dup.bin", stack + 2) == stack + 3);
  assert(stack[2] == 11 << 4 && stack[3] == 11 << 4);
  stack[3] = 3 << 4;
  assert(run("alpha-swap.bin", stack + 3) == stack + 3);
  assert(stack[2] == 3 << 4 && stack[3] == 11 << 4);
  assert(run("alpha-fixnum+fast.bin", stack + 3) == stack + 2);
  assert(stack[2] == 14 << 4);
  stack[3] = (uintptr_t)-3 << 4;
  assert(run("alpha-fixnum*fast.bin", stack + 3) == stack + 2);
  assert(stack[2] == (uintptr_t)-42 << 4);
  assert(run("alpha-fixnum-bitnot.bin", stack + 2) == stack + 2);
  assert(stack[2] == 41 << 4);
  stack[3] = 15 << 4;
  assert(run("alpha-fixnum-bitand.bin", stack + 3) == stack + 2);
  assert(stack[2] == 9 << 4);
  stack[2] = stack[3] = 3 << 4;
  assert(run("alpha-eq?.bin", stack + 3) == stack + 2 && stack[2] == 0x123b);
  stack[2] = 2 << 4; stack[3] = 3 << 4;
  assert(run("alpha-eq?.bin", stack + 3) == stack + 2 && stack[2] == 1);
  stack[2] = 2 << 4; stack[3] = 3 << 4;
  assert(run("alpha-fixnum<.bin", stack + 3) == stack + 2 && stack[2] == 0x123b);
  stack[2] = 3 << 4; stack[3] = 2 << 4;
  assert(run("alpha-fixnum>.bin", stack + 3) == stack + 2 && stack[2] == 0x123b);
  stack[2] = stack[3] = 3 << 4;
  assert(run("alpha-fixnum>=.bin", stack + 3) == stack + 2 && stack[2] == 0x123b);
  assert(run("alpha-immediate-temp2.bin", stack + 2) == stack + 2 && stack[2] == 0x123456789abcdef0);
  assert(run("alpha-immediate-temp3.bin", stack + 2) == stack + 2 && stack[2] == 0x123456789abcdef0);
  stack[2] = 0x400;
  assert(run("alpha-pic-tag.bin", stack + 2) == stack + 2 && stack[2] == 0);
  stack[2] = 0x123c;
  assert(run("alpha-pic-tag.bin", stack + 2) == stack + 2 && stack[2] == 12);
  puts("Alpha executes actual bootstrap and optimizer stack, arithmetic, comparison and literal bytes");
}
