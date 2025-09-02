#include "master.hpp"
#include <time.h>

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) { c_to_factor(quot); }

void factor_vm::init_signals() { unix_init_signals(); }

void early_init() {}

#include <string>

// You must free() the result yourself.
const char* default_image_path() {
  const char* exe = vm_executable_path();
  if (!exe)
    return strdup("factor.image");

  std::string base(exe);
  free(const_cast<char*>(exe));

  std::string with_suffix = base + ".image";
  return strdup(with_suffix.c_str());
}

uint64_t nano_count() {
  struct timespec t;
  int ret = clock_gettime(CLOCK_MONOTONIC, &t);
  if (ret != 0)
    fatal_error("clock_gettime failed", 0);
  return (uint64_t)t.tv_sec * 1000000000 + t.tv_nsec;
}

}
