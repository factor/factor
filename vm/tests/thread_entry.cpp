#include "../master.hpp"

int main(int argc, char** argv) {
  factor::init_mvm();
  auto thread = factor::start_standalone_factor_in_new_thread(argc, argv);
  pthread_join(thread, nullptr);
  // A standalone VM exits the process after executing its script.
  return 1;
}
