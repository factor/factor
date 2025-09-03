#include "master.hpp"

namespace factor {

typedef unsigned char UBYTE;

#ifndef UNW_FLAG_EHANDLER
const UBYTE UNW_FLAG_EHANDLER = 0x1;
#endif

struct UNWIND_INFO {
  UBYTE Version : 3;
  UBYTE Flags : 5;
  UBYTE SizeOfProlog;
  UBYTE CountOfCodes;
  UBYTE FrameRegister : 4;
  UBYTE FrameOffset : 4;
  ULONG ExceptionHandler;
  ULONG ExceptionData[1];
};

struct seh_data {
  UNWIND_INFO unwind_info;
  RUNTIME_FUNCTION func;
  UBYTE handler[32];
};

void factor_vm::c_to_factor_toplevel(cell quot) {
  // The annoying thing about Win64 SEH is that the offsets in
  // function tables are 32-bit integers, and the exception handler
  // itself must reside between the start and end pointers, so
  // we stick everything at the beginning of the code heap and
  // generate a small trampoline that jumps to the real
  // exception handler.

  seh_data* seh_area = (seh_data*)code->seh_area;
  cell base = code->seg->start;

  // Should look at generating this with the Factor assembler

  // mov rax,0
  seh_area->handler[0] = 0x48;
  seh_area->handler[1] = 0xb8;
  seh_area->handler[2] = 0x0;
  seh_area->handler[3] = 0x0;
  seh_area->handler[4] = 0x0;
  seh_area->handler[5] = 0x0;
  seh_area->handler[6] = 0x0;
  seh_area->handler[7] = 0x0;
  seh_area->handler[8] = 0x0;
  seh_area->handler[9] = 0x0;

  // jmp rax
  seh_area->handler[10] = 0x48;
  seh_area->handler[11] = 0xff;
  seh_area->handler[12] = 0xe0;

  // Store address of exception handler in the operand of the 'mov'
  cell handler = (cell)&factor::exception_handler;
  memcpy(&seh_area->handler[2], &handler, sizeof(cell));

  UNWIND_INFO* unwind_info = &seh_area->unwind_info;
  unwind_info->Version = 1;
  unwind_info->Flags = UNW_FLAG_EHANDLER;
  unwind_info->SizeOfProlog = 0;
  unwind_info->CountOfCodes = 0;
  unwind_info->FrameRegister = 0;
  unwind_info->FrameOffset = 0;
  unwind_info->ExceptionHandler = (DWORD)((cell)&seh_area->handler[0] - base);
  unwind_info->ExceptionData[0] = 0;

  RUNTIME_FUNCTION* func = &seh_area->func;
  func->BeginAddress = 0;
  func->EndAddress = (DWORD)(code->seg->end - base);
  func->UnwindData = (DWORD)((cell)&seh_area->unwind_info - base);

  if (!RtlAddFunctionTable(func, 1, base))
    fatal_error("RtlAddFunctionTable() failed", 0);

  c_to_factor(quot);

  if (!RtlDeleteFunctionTable(func))
    fatal_error("RtlDeleteFunctionTable() failed", 0);
}

}
