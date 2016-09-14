#include "master.hpp"
#include <time.h>

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) { c_to_factor(quot); }

void factor_vm::init_signals() { unix_init_signals(); }

void early_init() {}

// You must free() the result yourself.
const char* default_image_path() {
  const char *name = "/lib/factor/factor-lang.image";
  int pref_len = strlen(INSTALL_PREFIX);
  int name_len = strlen(name);
  char* new_path = (char *)malloc(pref_len + name_len + 1);
  memcpy(new_path, INSTALL_PREFIX, pref_len);
  memcpy(new_path + pref_len, name, name_len+1);
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
