// C imports for the macOS Mach exception handler (src/mach_signal.zig).
// Translated into the "c" Zig module via b.addTranslateC in build.zig.
// Keep these includes in sync with the symbols referenced in mach_signal.zig.
#include <mach/mach.h>
#include <mach/exception_types.h>
#include <pthread.h>
