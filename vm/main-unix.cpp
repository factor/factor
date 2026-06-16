#include "master.hpp"

int main(int argc, char** argv) {
  // Image load writes the code heap with raw memcpy / free-list setup that does
  // not go through the guarded funnels, so make the thread writable for startup.
  // The first c-to-factor flips it executable (jit_force_executable) before any
  // Factor code runs; the funnel scopes take over from there.
  factor::jit_set_writable();
  factor::init_mvm();
  factor::start_standalone_factor(argc, argv);
  return 0;
}
