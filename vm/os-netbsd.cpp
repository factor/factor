#include "master.hpp"
#include <sys/sysctl.h>
namespace factor {
const char *vm_executable_path() {
  char path[PATH_MAX + 1];
  size_t size = sizeof(path);
  int mib[] = { CTL_KERN, KERN_PROC_ARGS, -1, KERN_PROC_PATHNAME };
  if (sysctl(mib, 4, path, &size, NULL, 0) != 0) return NULL;
  path[PATH_MAX] = '\0';
  return safe_strdup(path);
}
}
