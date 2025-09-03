#include "master.hpp"
#include <time.h>

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) { c_to_factor(quot); }

void factor_vm::init_signals() { unix_init_signals(); }

void early_init() {}

#define SUFFIX ".image"
#define SUFFIX_LEN 6

// You must free() the result yourself.
const char* default_image_path() {
  const char* path = vm_executable_path();

  if (!path)
    return strdup("factor.image");

  size_t len = strlen(path);
  char* new_path = (char *)malloc(len + SUFFIX_LEN + 1);
  memcpy(new_path, path, len);
  memcpy(new_path + len, SUFFIX, SUFFIX_LEN + 1);
  free(const_cast<char*>(path));
  return new_path;
}

uint64_t nano_count() {
  struct timespec t;
  int ret = clock_gettime(CLOCK_MONOTONIC, &t);
  if (ret != 0)
    fatal_error("clock_gettime failed", 0);
  return (uint64_t)t.tv_sec * 1000000000 + t.tv_nsec;
}

}
