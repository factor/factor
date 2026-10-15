#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
extern "C" {
alignas(16) uintptr_t hppa_optimizer_vm[8];
alignas(16) uintptr_t hppa_optimizer_context[8];
alignas(16) uint32_t hppa_optimizer_frames[128];
double hppa_optimizer_enter(void*, uintptr_t, int32_t, int32_t);
}
static volatile double native_bias = 3.25;
__attribute__((noinline)) static double native_double(double a, double b) {
  return 13 * a + 7 * b + native_bias;
}
__attribute__((noinline)) static double native_mixed(int a, double b, int c) {
  return 2.0 * a + 3.0 * b + 5.0 * c + native_bias;
}
static void* load_code(const char* path) {
  FILE* input = fopen(path, "rb"); assert(input);
  char* code = (char*)mmap(0,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code != MAP_FAILED);
  size_t size = fread(code,1,4096,input); assert(size && size < 4096); fclose(input);
  __builtin___clear_cache(code,code+size); return code;
}
int main(int argc, char** argv) {
  assert(argc == 3);
  void* doubles = load_code(argv[1]); void* mixed = load_code(argv[2]);
  const int32_t values[] = {INT32_MIN,-42,-1,0,1,42,INT32_MAX};
  for (int32_t a : values) for (int32_t b : values) {
    assert(hppa_optimizer_enter(doubles,(uintptr_t)&native_double,a,b) == native_double(a,b));
    assert(hppa_optimizer_enter(mixed,(uintptr_t)&native_mixed,a,b) == native_mixed(a,b,a));
  }
  assert(hppa_optimizer_context[0] == (uintptr_t)(hppa_optimizer_frames + 120));
  puts("Factor-emitted GNU floating native calls: 98 double/register/stack/return cases passed");
  return munmap(doubles,4096) != 0 || munmap(mixed,4096) != 0;
}
