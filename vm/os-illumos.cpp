#include "master.hpp"

#include <stdlib.h>

namespace factor {

const char* vm_executable_path() {
  const char* path = getexecname();
  if (!path) return nullptr;

  char* resolved = realpath(path, nullptr);
  if (resolved) return resolved;
  return safe_strdup(path);
}

}
