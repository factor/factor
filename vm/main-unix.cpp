#include "master.hpp"

int main(int argc, char** argv) {
  factor::init_mvm();
  factor::start_standalone_factor(argc, argv);
  return 0;
}
