// Standalone native ARM64 probe: cl /EHsc windows_arm64_unwind.cpp
// Include the production table generator with only its small VM interface.
#define NOMINMAX
#include <windows.h>
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#if defined(_M_ARM64) || defined(__aarch64__)
#define __FACTOR_MASTER_H__
#define FACTOR_ASSERT assert
namespace factor {
typedef uintptr_t cell;
const cell seh_area_size = 4096;
struct segment { cell start; cell end; };
struct code_heap { char* seh_area; segment* seg; };
struct factor_vm {
  code_heap* code;
  void c_to_factor_toplevel(cell quot);
  void c_to_factor(cell quot);
};
static LONG exception_handler(PEXCEPTION_RECORD, void*, PCONTEXT, void*) {
  return 0;
}
static void fatal_error(const char* message, cell) {
  fprintf(stderr, "%s\n", message);
  abort();
}
static void flush_icache(cell start, cell size) {
  if (!FlushInstructionCache(GetCurrentProcess(), (void*)start, size))
    abort();
}
}
#include "../os-windows-arm.64.cpp"

static void check(bool condition, const char* message) {
  if (!condition) {
    fprintf(stderr, "%s\n", message);
    exit(1);
  }
}

void factor::factor_vm::c_to_factor(cell) {
  cell start = code->seg->start + seh_area_size;
  cell offsets[] = {0, 4, 8, 64, arm64_function_fragment_size - 4,
                    arm64_function_fragment_size,
                    arm64_function_fragment_size + 4,
                    code->seg->end - start - 4};
  for (cell offset : offsets) {
    DWORD64 base = 0;
    PRUNTIME_FUNCTION function = RtlLookupFunctionEntry(start + offset, &base, NULL);
    check(function != NULL, "Missing function entry");
    // Outgoing argument space below FP must not affect the restored frame.
    alignas(16) DWORD64 stack[8] = {};
    DWORD64* frame = &stack[4];
    frame[0] = 0x12340000;
    frame[1] = 0x56780000;
    CONTEXT context = {};
    context.Sp = (DWORD64)&stack[0];
    context.Fp = (DWORD64)frame;
    context.Lr = 0xdead0000;
    context.Pc = start + offset;
    PVOID handler_data = NULL;
    DWORD64 establisher_frame = 0;
    PEXCEPTION_ROUTINE handler = RtlVirtualUnwind(
        UNW_FLAG_EHANDLER, base, context.Pc, function, &context,
        &handler_data, &establisher_frame, NULL);
    arm64_seh_data* seh = (arm64_seh_data*)code->seh_area;
    check((void*)handler == (void*)seh->handler, "Fragment PC lost exception handler");
    check(context.Sp == (DWORD64)(frame + 2), "Incorrect restored SP");
    check(context.Fp == frame[0], "Incorrect restored FP");
    check(context.Pc == frame[1], "Incorrect restored PC");
  }
}

int main() {
  const SIZE_T size = 2 * 1024 * 1024;
  void* memory = VirtualAlloc(NULL, size, MEM_RESERVE | MEM_COMMIT,
                             PAGE_EXECUTE_READWRITE);
  check(memory != NULL, "VirtualAlloc failed");
  factor::segment segment = {(factor::cell)memory, (factor::cell)memory + size};
  factor::code_heap heap = {(char*)memory, &segment};
  factor::factor_vm vm = {&heap};
  vm.c_to_factor_toplevel(0);
  check(VirtualFree(memory, 0, MEM_RELEASE) != 0, "VirtualFree failed");
  puts("ARM64 fragment unwind checks passed");
}
#else
int main() { return 77; }
#endif
