#include "master.hpp"

int main(int argc, char** argv) {
  JIT_WRITABLE
  factor::init_mvm();
  factor::start_standalone_factor(argc, argv);
  return 0;
}
