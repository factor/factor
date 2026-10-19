// Fourteen actual Factor-emitted comparison hooks, including quiet NaNs.
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <sys/mman.h>
int main(int argc, char** argv) {
  assert(argc == 2);
  FILE* input = fopen(argv[1], "rb"); assert(input);
  char* code = (char*)mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                           MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  assert(fread(code, 1, 4096, input) == 14 * 28); fclose(input);
  __builtin___clear_cache(code, code + 14 * 28);
  const double values[] = {-INFINITY, -42.0, -0.0, 0.0, 1.0, INFINITY, NAN};
  unsigned count = 0;
  for (unsigned op = 0; op < 14; ++op) for (double a : values) for (double b : values) {
    bool ordered = !isunordered(a, b);
    const bool expected[] = {a < b, a <= b, a > b, a >= b, a == b,
                            ordered && a != b, ordered,
                            !(a < b), !(a <= b), !(a > b), !(a >= b), a != b,
                            !ordered || a == b, !ordered};
    auto function = (unsigned(*)(double, double))(code + op * 28);
    unsigned result = function(a, b);
    if (result != expected[op]) {
      fprintf(stderr, "comparison %u(%g,%g): got %u expected %u\n", op, a, b, result, expected[op]);
      return 1;
    }
    ++count;
  }
  printf("Factor-emitted ordered/unordered floating comparisons: %u native cases passed\n", count);
  return munmap(code, 4096) != 0;
}
