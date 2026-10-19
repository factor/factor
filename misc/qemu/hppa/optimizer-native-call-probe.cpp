#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
extern "C" {
alignas(16) uintptr_t hppa_optimizer_vm[8];
alignas(16) uintptr_t hppa_optimizer_context[8];
alignas(16) uint32_t hppa_optimizer_frames[128];
uint32_t hppa_optimizer_enter(void*, uintptr_t, uint32_t, uint32_t);
}
static volatile uint32_t native_bias = 3;
__attribute__((noinline)) static uint32_t native(uint32_t a, uint32_t b) {
  return 13 * a + 7 * b + native_bias;
}
struct small { uint32_t a, b; };
__attribute__((noinline)) static uint32_t native_small(small value) {
  return 13 * value.a + 7 * value.b + native_bias;
}
struct medium { uint32_t a, b, c; };
__attribute__((noinline)) static uint32_t native_aggregate(medium value) {
  return 13 * value.a + 7 * value.b + value.c + native_bias;
}
#define PARTIAL_CASE(N) \
struct part##N { unsigned char bytes[N]; }; \
__attribute__((noinline)) static uint32_t native_part##N(part##N value) { \
  uint32_t result = 0; for (unsigned char byte : value.bytes) result = result * 17 + byte; return result; \
} \
static void check_part##N(void* code, uint32_t seed) { \
  part##N value{}; uint32_t low = 0, high = 0, expected = 0; \
  for (unsigned i = 0; i < N; i++) { \
    unsigned char byte = (seed >> ((i % 4) * 8)) ^ (i * 39); value.bytes[i] = byte; \
    expected = expected * 17 + byte; \
    if (N > 4 && i < N - 4) high = (high << 8) | byte; else low = (low << 8) | byte; \
  } \
  assert(native_part##N(value) == expected); \
  assert(hppa_optimizer_enter(code, (uintptr_t)&native_part##N, low, high) == expected); \
}
PARTIAL_CASE(1) PARTIAL_CASE(2) PARTIAL_CASE(3) PARTIAL_CASE(4)
PARTIAL_CASE(5) PARTIAL_CASE(6) PARTIAL_CASE(7)
int main(int argc, char** argv) {
  assert(argc == 2);
  FILE* input = fopen(argv[1], "rb"); assert(input);
  char* code = (char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code != MAP_FAILED);
  size_t size = fread(code,1,4096,input); assert(size && size < 4096); fclose(input);
  __builtin___clear_cache(code,code+size);
  const uint32_t values[] = {0,1,42,0x7fffffff,0x80000000,0xffffffff};
  for (uint32_t a : values) for (uint32_t b : values)
    assert(hppa_optimizer_enter(code,(uintptr_t)&native,a,b) == native(a,b));
  for (uint32_t a : values) for (uint32_t b : values) {
    small value{a, b};
    assert(hppa_optimizer_enter(code, (uintptr_t)&native_small,
      b, a) == native_small(value));
  }
  for (uint32_t a : values) {
    medium value{a, a ^ 0x87654321, a + 19};
    assert(hppa_optimizer_enter(code, (uintptr_t)&native_aggregate,
      (uintptr_t)&value, 0) == native_aggregate(value));
  }
  for (uint32_t seed : values) {
    check_part1(code, seed); check_part2(code, seed); check_part3(code, seed);
    check_part4(code, seed); check_part5(code, seed); check_part6(code, seed);
    check_part7(code, seed);
  }
  assert(hppa_optimizer_context[0] == (uintptr_t)(hppa_optimizer_frames + 120));
  puts("Factor-emitted indirect GNU native calls: 36 scalar, 78 small aggregate and 6 GNU indirect aggregate cases passed");
  return munmap(code,4096) != 0;
}
