#include "master.hpp"
namespace factor {
static char* executable_path;
void set_vm_executable_path(const char* path) {
  executable_path = realpath(path, nullptr);
  if (!executable_path) executable_path = safe_strdup(path);
}
const char* vm_executable_path() { return safe_strdup(executable_path ? executable_path : "factor"); }
}
