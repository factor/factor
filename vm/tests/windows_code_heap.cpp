#include "../master.hpp"

// These must fail before reserving memory or truncating the SEH table RVA.
int main(int argc, char** argv) {
#if defined(WINDOWS) && defined(FACTOR_AMD64)
  factor::init_mvm();
  factor::cell size = (factor::cell)1 << 32;
  if (argc > 1 && strcmp(argv[1], "rounded") == 0)
    size--;
  factor::code_heap heap(size);
  fputs("Unrepresentable Windows code heap was accepted\n", stderr);
  return 2;
#else
  (void)argc;
  (void)argv;
  return 77;
#endif
}
