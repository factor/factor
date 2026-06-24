#include "master.hpp"

namespace factor {

static const DWORD arm64_unwind_code_end = 0xe3e3e3e4;
static const cell arm64_function_fragment_size = ((1 << 18) - 1) * 4;

struct arm64_unwind_info {
  DWORD header;
  DWORD unwind_codes;
  DWORD exception_handler;
};

struct arm64_seh_data {
  RUNTIME_FUNCTION funcs[(0x8000000 / arm64_function_fragment_size) + 2];
  arm64_unwind_info unwind[(0x8000000 / arm64_function_fragment_size) + 2];
  DWORD handler[4];
};

static void arm64_store_handler_trampoline(DWORD* code, cell handler) {
  // ldr x16, #8; br x16; .quad handler
  code[0] = 0x58000050;
  code[1] = 0xd61f0200;
  memcpy(&code[2], &handler, sizeof(cell));
}

void factor_vm::c_to_factor_toplevel(cell quot) {
  arm64_seh_data* seh_area = (arm64_seh_data*)code->seh_area;
  cell base = code->seg->start;
  cell start = base + seh_area_size;
  cell end = code->seg->end;
  DWORD handler_rva = (DWORD)((cell)&seh_area->handler[0] - base);
  DWORD entry_count = 0;

  FACTOR_ASSERT(sizeof(arm64_seh_data) <= seh_area_size);
  arm64_store_handler_trampoline(
      seh_area->handler, (cell)&factor::exception_handler);

  for (cell fragment_start = start; fragment_start < end;
       fragment_start += arm64_function_fragment_size) {
    cell fragment_size = std::min(arm64_function_fragment_size,
                                  end - fragment_start);
    arm64_unwind_info* unwind = &seh_area->unwind[entry_count];
    RUNTIME_FUNCTION* func = &seh_area->funcs[entry_count];

    unwind->header =
      (DWORD)((fragment_size >> 2) | (1 << 20) | (1 << 27));
    unwind->unwind_codes = arm64_unwind_code_end;
    unwind->exception_handler = handler_rva;

    func->BeginAddress = (DWORD)(fragment_start - base);
    func->UnwindData = (DWORD)((cell)unwind - base);

    entry_count++;
  }

  factor::flush_icache((cell)&seh_area->handler[0],
                       sizeof(seh_area->handler));

  if (!RtlAddFunctionTable(seh_area->funcs, entry_count, base))
    fatal_error("RtlAddFunctionTable() failed", 0);

  c_to_factor(quot);

  if (!RtlDeleteFunctionTable(seh_area->funcs))
    fatal_error("RtlDeleteFunctionTable() failed", 0);
}

}
