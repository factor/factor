#include "master.hpp"

extern "C" __attribute__((weak)) void factor_android_finished(int status);

namespace factor {

static thread_local bool android_embedded_runtime = false;
static const char* android_executable_path = nullptr;

bool android_embedded_runtime_p() { return android_embedded_runtime; }

void set_android_embedded_runtime() { android_embedded_runtime = true; }

void set_android_executable_path(const char* path) {
  if (!path || !*path)
    fatal_error("Android executable path is empty", 0);
  android_executable_path = safe_strdup(path);
}

[[noreturn]] void android_process_exit(int status) {
  if (factor_android_finished)
    factor_android_finished(status);
  fflush(nullptr);
  std::cout.flush();
  std::cerr.flush();
  // primitive_exit runs with an active Factor context deep in generated code,
  // so the VM cannot be destroyed or restarted safely. End the app process
  // without running process-global C++ destructors used by Android callbacks.
  _exit(status);
  __builtin_unreachable();
}

const char* vm_executable_path() {
  if (android_embedded_runtime_p() && android_executable_path)
    return safe_strdup(android_executable_path);

  size_t capacity = 256;
  while (true) {
    char* buffer = new char[capacity + 1];
    ssize_t size = readlink("/proc/self/exe", buffer, capacity);
    if (size < 0) {
      delete[] buffer;
      fatal_error("Cannot read /proc/self/exe", errno);
    }
    if (static_cast<size_t>(size) < capacity) {
      buffer[size] = '\0';
      const char* result = safe_strdup(buffer);
      delete[] buffer;
      return result;
    }
    delete[] buffer;
    capacity *= 2;
  }
}

}
