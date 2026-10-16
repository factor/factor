#pragma once
#include "os-unix-memory.hpp"

namespace factor::os {
inline segment_mapping map_segment(bool executable) {
  return default_segment_mapping(executable);
}
}

namespace factor {
bool android_embedded_runtime_p();
void set_android_embedded_runtime();
void set_android_executable_path(const char* path);
[[noreturn]] void android_process_exit(int status);
}
