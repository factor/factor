// Link with vm/cpu-arm.64-trampoline.obj to check native call boundaries too.
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
typedef intptr_t fixnum;
const cell seh_area_size = 4096;
struct segment { cell start; cell end; };
struct context { segment* callstack_seg; };
struct code_heap { char* seh_area; segment* seg; };
struct factor_vm {
  code_heap* code;
  void c_to_factor_toplevel(cell quot);
  void c_to_factor(cell quot);
};
static unsigned handled_faults;
static LONG exception_handler(PEXCEPTION_RECORD record, void*, PCONTEXT context, void*) {
  if (record->ExceptionCode != EXCEPTION_ACCESS_VIOLATION)
    abort();
  ++handled_faults;
  context->Pc += 4; // Skip the probe's faulting LDR and execute RET.
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
#include "../cpu-arm.64.hpp"
#include "../os-windows-arm.64.cpp"

extern "C" void trampoline();
extern "C" void trampoline2();
extern "C" LONG exception_handler(PEXCEPTION_RECORD record, void* frame,
                                  PCONTEXT context, void* dispatch) {
  return factor::exception_handler(record, frame, context, dispatch);
}

__declspec(noinline) static uintptr_t native_fault(volatile uintptr_t* address) {
  return *address;
}

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
    printf("Checking handler at heap code offset 0x%llx\n",
           (unsigned long long)offset);
    fflush(stdout);
    DWORD64 base = 0;
    PRUNTIME_FUNCTION function = RtlLookupFunctionEntry(start + offset, &base, NULL);
    check(function != NULL, "Missing function entry");
    // A frameless word need not have a readable FP. Handler lookup must
    // not dereference it. The synthetic caller advances SP by one slot
    // solely to ensure exception dispatch progresses when PC equals LR.
    alignas(16) DWORD64 stack[8] = {};
    CONTEXT context = {};
    context.Sp = (DWORD64)&stack[0];
    context.Fp = 0;
    context.Lr = 0xdead0000;
    context.Pc = start + offset;
    PVOID handler_data = NULL;
    DWORD64 establisher_frame = 0;
    PEXCEPTION_ROUTINE handler = RtlVirtualUnwind(
        UNW_FLAG_EHANDLER, base, context.Pc, function, &context,
        &handler_data, &establisher_frame, NULL);
    arm64_seh_data* seh = (arm64_seh_data*)code->seh_area;
    if ((void*)handler != (void*)seh->handler) {
      fprintf(stderr,
              "offset=0x%llx begin_rva=0x%lx unwind_rva=0x%lx "
              "handler=%p expected=%p\n",
              (unsigned long long)offset, (unsigned long)function->BeginAddress,
              (unsigned long)function->UnwindData,
              (void*)handler, (void*)seh->handler);
    }
    check((void*)handler == (void*)seh->handler, "Fragment PC lost exception handler");
    check(context.Sp == (DWORD64)&stack[2], "Incorrect virtual caller SP");
    check(context.Fp == 0, "Handler lookup changed FP");
    check(context.Pc == 0xdead0000, "Incorrect leaf return PC");
  }

  // Exercise actual exception dispatch as well as RtlVirtualUnwind.
  // Include an instruction at a fragment boundary and a return in the next
  // fragment; these boundaries are unrelated to generated word boundaries.
  cell fault_offsets[] = {0, 64, arm64_function_fragment_size - 4,
                          arm64_function_fragment_size};
  for (cell offset : fault_offsets) {
    printf("Checking access violation at heap code offset 0x%llx\n",
           (unsigned long long)offset);
    fflush(stdout);
    DWORD* instructions = (DWORD*)(start + offset);
    instructions[0] = 0xf9400000; // ldr x0, [x0]
    instructions[1] = 0xd65f03c0; // ret
    flush_icache((cell)instructions, 2 * sizeof(DWORD));
    ((void (*)(void*))instructions)(NULL);
  }
  check(handled_faults == 4, "Native access violations did not reach the handler");

  // A returning call leaves LR pointing at the faulting instruction. A
  // zero-sized virtual frame would make Windows reject this as a cycle.
  puts("Checking access violation with PC equal to LR");
  fflush(stdout);
  DWORD return_fault[] = {
    0xa9bf7bfd, // stp fp, lr, [sp, #-16]!
    0x94000004, // bl to the final ret
    0xf9400000, // ldr x0, [x0] (LR == PC here)
    0xa8c17bfd, // ldp fp, lr, [sp], #16
    0xd65f03c0, // ret
    0xd65f03c0  // ret
  };
  memcpy((void*)(start + 128), return_fault, sizeof(return_fault));
  flush_icache(start + 128, sizeof(return_fault));
  ((void (*)(void*))(start + 128))(NULL);
  check(handled_faults == 5, "Fault at return address missed the handler");

  // Both native trampolines must dispatch an exception raised in their
  // callee, then resume it with the original registers and stack intact.
  // The bridge preserves X20, which Factor uses as its context pointer.
  DWORD bridge[] = {
    0xa9bc7bfd, // stp fp, lr, [sp, #-64]!
    0xa90153f3, // stp x19, x20, [sp, #16]
    0x910003fd, // mov fp, sp
    0xaa0003f4, // mov x20, x0
    0xaa0103f0, // mov x16, x1
    0xaa1f03e0, // mov x0, xzr (fault address)
    0x910083f1, // add x17, sp, #32 (trampoline2 frame)
    0xd63f0040, // blr x2
    0xa94153f3, // ldp x19, x20, [sp, #16]
    0xa8c47bfd, // ldp fp, lr, [sp], #64
    0xd65f03c0  // ret
  };
  cell bridge_start = start + 256;
  memcpy((void*)bridge_start, bridge, sizeof(bridge));
  flush_icache(bridge_start, sizeof(bridge));
  typedef void (*bridge_type)(cell*, void*, void (*)());
  for (auto entry : {trampoline, trampoline2}) {
    printf("Checking native fault through %s\n",
           entry == trampoline ? "trampoline" : "trampoline2");
    fflush(stdout);
    DWORD64 base = 0;
    check(RtlLookupFunctionEntry((DWORD64)entry + 12, &base, NULL) != NULL,
          "Native trampoline has no unwind entry");
    cell frame = 0;
    ((bridge_type)bridge_start)(&frame, (void*)native_fault, entry);
    check(frame != 0, "Trampoline did not publish its frame");
  }
  check(handled_faults == 7, "Native trampoline faults did not reach the handler");

  puts("Checking access violation at the callback entry stack pointer");
  fflush(stdout);
  const SIZE_T stack_size = 1024 * 1024;
  void* stack = VirtualAlloc(NULL, stack_size, MEM_RESERVE | MEM_COMMIT,
                             PAGE_READWRITE);
  check(stack != NULL, "VirtualAlloc failed");
  segment callstack_seg = {(cell)stack, (cell)stack + stack_size};
  context entry_ctx = {&callstack_seg};
  context* ctx = &entry_ctx;
  DWORD entry_fault[] = {
    0x910003e9, // mov x9, sp
    0x9100003f, // mov sp, x1
    0xf9400000, // ldr x0, [x0]
    0x9100013f, // mov sp, x9
    0xd65f03c0  // ret
  };
  cell entry_start = start + 512;
  memcpy((void*)entry_start, entry_fault, sizeof(entry_fault));
  flush_icache(entry_start, sizeof(entry_fault));
  NT_TIB* tib = (NT_TIB*)NtCurrentTeb();
  PVOID stack_base = tib->StackBase;
  PVOID stack_limit = tib->StackLimit;
  tib->StackBase = (PVOID)callstack_seg.end;
  tib->StackLimit = (PVOID)callstack_seg.start;
  ((void (*)(void*, cell))entry_start)(NULL, CALLSTACK_BOTTOM(ctx) + 16);
  tib->StackBase = stack_base;
  tib->StackLimit = stack_limit;
  check(handled_faults == 8, "Fault at the callback entry SP missed the handler");
  check(VirtualFree(stack, 0, MEM_RELEASE) != 0, "VirtualFree failed");
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
  puts("ARM64 fragment and trampoline unwind checks passed");
}
#else
int main() { return 77; }
#endif
