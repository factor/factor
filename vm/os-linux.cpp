#include "master.hpp"

namespace factor {

const char* vm_executable_path() {
  size_t bufsiz = 4096;

  // readlink is called in a loop with increasing buffer sizes in case
  // someone tries to run Factor from a incredibly deeply nested
  // path.
  while (true) {
    char* buf = new char[bufsiz + 1];
    ssize_t size = readlink("/proc/self/exe", buf, bufsiz);
    if (size < 0) {
      fatal_error("Cannot read /proc/self/exe", errno);
    } else {
      if (size < ((ssize_t) bufsiz)) {
        // Buffer was large enough, return string.
        buf[size] = '\0';
        const char* ret = safe_strdup(buf);
        delete[] buf;
        return ret;
      } else {
        // Buffer wasn't big enough, double it and try again.
        delete[] buf;
        bufsiz *= 2;
      }
    }
  }
}

}
