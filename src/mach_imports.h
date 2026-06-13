// C imports for the macOS Mach exception handler (src/mach_signal.zig).
// Translated into the "c" Zig module via b.addTranslateC in build.zig.
// Keep these includes in sync with the symbols referenced in mach_signal.zig.
#include <mach/port.h>
#undef xnu_static_assert_struct_size
#define xnu_static_assert_struct_size(name, expected_size)
#undef xnu_static_assert_struct_size_kernel_user
#define xnu_static_assert_struct_size_kernel_user(name, k, u)
#undef xnu_static_assert_struct_size_kernel_user64_user32
#define xnu_static_assert_struct_size_kernel_user64_user32(name, k, u64, u32)
#include <mach/mach.h>
#include <mach/exception_types.h>
#include <pthread.h>
