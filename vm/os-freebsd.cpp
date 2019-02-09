#include "master.hpp"

namespace factor {
char *vm_saved_path;

/* 
   FreeBSD needs proc mounted for this function to work.
   "mount -t procfs proc /proc"
*/

const char* vm_executable_path(){
  ssize_t bufsiz = 4096;
  while (true) {
    char* buf = new char [bufsiz + 1];
    ssize_t size = readlink("/proc/curproc/file", buf, bufsiz);
    if (size < 0) {
      fatal_error("Cannot read /proc/curproc/file", errno);
    }
    else {
      if (size < bufsiz) {
        buf[size] = '\0';
	const char* ret = safe_strdup(buf);
	delete[] buf;
	return ret;
      }	else {
	delete[] buf;
	bufsiz *= 2;
      }
    }
  }
}

}
