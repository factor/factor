#pragma once
#include "os-unix-memory.hpp"
namespace factor {

#define VM_C_API extern "C" __attribute__((visibility("default")))
#define FACTOR_OS_STRING "macos"

void early_init();
void reexec_from_app_bundle(char** argv);

const char* vm_executable_path();
const char* default_image_path();

// uc_stack describes the alternate signal stack, not the interrupted SP.
#define UAP_STACK_POINTER(ucontext) MACH_STACK_POINTER(UAP_SS(ucontext))

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

#define ZSTD_LIB "libzstd.dylib"

}

namespace factor::os {
inline segment_mapping map_segment(bool executable) {
#if defined(FACTOR_ARM64)
  (void)executable;
  return {PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE | MAP_JIT, true};
#else
  return default_segment_mapping(executable);
#endif
}
}
