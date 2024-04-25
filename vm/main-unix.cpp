#include "master.hpp"

int main(int argc, char** argv) {
#if defined(__APPLE__) && defined(FACTOR_ARM64)
  pthread_jit_write_protect_np(0);
#endif
  factor::init_mvm();
  factor::start_standalone_factor(argc, argv);
  return 0;
}
