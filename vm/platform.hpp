#if defined(WINDOWS)
#if defined(WINNT)
#include "os-windows.hpp"

#if defined(FACTOR_AMD64)
#include "os-windows.64.hpp"
#elif defined(FACTOR_X86)
#include "os-windows.32.hpp"
#else
#error "Unsupported Windows flavor"
#endif
#else
#error "Unsupported Windows flavor"
#endif
#else
#include "os-unix.hpp"

#ifdef __APPLE__
#include "os-macosx.hpp"
#include "mach_signal.hpp"

#ifdef FACTOR_X86
#include "os-macosx-x86.32.hpp"
#elif defined(FACTOR_AMD64)
#include "os-macosx-x86.64.hpp"
#else
#error "Unsupported Mac OS X flavor"
#endif
#else
#include "os-genunix.hpp"

#if defined(linux)
#define FACTOR_OS_STRING "linux"
#include "os-linux.hpp"

#if defined(FACTOR_X86)
#include "os-linux-x86.32.hpp"
#elif defined(FACTOR_PPC64)
#include "os-linux-ppc.64.hpp"
#elif defined(FACTOR_PPC32)
#include "os-linux-ppc.32.hpp"
#elif defined(FACTOR_ARM)
#include "os-linux-arm.hpp"
#elif defined(FACTOR_AMD64)
#include "os-linux-x86.64.hpp"
#else
#error "Unsupported Linux flavor"
#endif
#else
#error "Unsupported OS"
#endif
#endif
#endif

#if defined(FACTOR_X86)
#include "cpu-x86.32.hpp"
#include "cpu-x86.hpp"
#elif defined(FACTOR_AMD64)
#include "cpu-x86.64.hpp"
#include "cpu-x86.hpp"
#elif defined(FACTOR_PPC)
#include "cpu-ppc.hpp"
#elif defined(FACTOR_ARM)
#include "cpu-arm.hpp"
#else
#error "Unsupported CPU"
#endif
