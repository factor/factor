#include "master.hpp"
namespace factor {
char *vm_saved_path;
const char *vm_executable_path()
{
  char path[PATH_MAX + 1];
  auto size = readlink("/proc/curproc/file", path, sizeof(path) - 1);
  if (size < 0) return NULL;
  path[size] = '\0';
  return safe_strdup(path);
}
}
