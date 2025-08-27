#include "master.hpp"
#include <exception>
#include <iostream>

int main(int argc, char** argv) {
  try {
#if defined(__APPLE__) && defined(FACTOR_ARM64)
    pthread_jit_write_protect_np(0);
#endif
    factor::init_mvm();
    factor::start_standalone_factor(argc, argv);
    return 0;
  } catch (const std::bad_alloc& e) {
    std::cerr << "Fatal: Out of memory: " << e.what() << std::endl;
    return 1;
  } catch (const std::exception& e) {
    std::cerr << "Fatal: Unhandled exception: " << e.what() << std::endl;
    return 1;
  } catch (...) {
    std::cerr << "Fatal: Unknown exception" << std::endl;
    return 1;
  }
}
