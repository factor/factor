// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#pragma once

namespace factor {

// CPU headers use these helpers before master.hpp includes errors.hpp.
void critical_error(const char* msg, cell tagged);

// Continuation metadata occupies the unused cell in the four-cell frame,
// separate from the backchain and the ABI's LR slot (4 on PPC32, 16 on PPC64).
static const cell PPC_SIGNAL_FRAME_MARKER = (cell)UINT64_C(0x5050435349474e00);
static const cell PPC_SIGNAL_FRAME_METADATA = sizeof(cell) == 8 ? 24 : 8;

inline uint32_t ppc_instruction(cell address) {
  uint32_t value;
  memcpy(&value, (const void*)address, sizeof(value));
  return value;
}

inline void ppc_store_instruction(cell address, uint32_t value) {
  memcpy((void*)address, &value, sizeof(value));
}

// Operands point immediately after the instruction or load sequence.
inline fixnum ppc_load_absolute(cell pointer) {
  uint32_t last = ppc_instruction(pointer - 4);
  if ((last >> 26) != 24)
    return (int16_t)(last & ((last >> 26) >= 58 ? 0xfffc : 0xffff));
  if (sizeof(cell) == 8) {
    uint64_t value = ((uint64_t)(ppc_instruction(pointer - 20) & 0xffff) << 48) |
                     ((uint64_t)(ppc_instruction(pointer - 16) & 0xffff) << 32) |
                     ((uint64_t)(ppc_instruction(pointer - 8) & 0xffff) << 16) |
                     (last & 0xffff);
    return (fixnum)value;
  }
  return (fixnum)((ppc_instruction(pointer - 8) << 16) | (last & 0xffff));
}

inline void ppc_store_absolute(cell pointer, fixnum absolute) {
  cell value = (cell)absolute;
  uint32_t last = ppc_instruction(pointer - 4);
  if ((last >> 26) != 24) {
    bool ds_form = (last >> 26) >= 58;
    if (absolute < -32768 || absolute > 32767 || (ds_form && (absolute & 3)))
      critical_error("PowerPC immediate out of range", (cell)absolute);
    uint32_t mask = ds_form ? 0xfffc : 0xffff;
    ppc_store_instruction(pointer - 4, (last & ~mask) | (value & mask));
    return;
  }
  if (sizeof(cell) == 8) {
    const unsigned offsets[] = {20, 16, 8, 4};
    const unsigned shifts[] = {48, 32, 16, 0};
    for (unsigned i = 0; i < 4; ++i) {
      cell address = pointer - offsets[i];
      ppc_store_instruction(address, (ppc_instruction(address) & 0xffff0000) |
                                    (((uint64_t)value >> shifts[i]) & 0xffff));
    }
  } else {
    ppc_store_instruction(pointer - 8, (ppc_instruction(pointer - 8) & 0xffff0000) |
                                      ((value >> 16) & 0xffff));
    ppc_store_instruction(pointer - 4, (last & 0xffff0000) | (value & 0xffff));
  }
}

inline fixnum ppc_load_relative(cell pointer, cell relative_to) {
  uint32_t insn = ppc_instruction(pointer - 4);
  unsigned opcode = insn >> 26;
  if ((opcode != 16 && opcode != 18) || (insn & 2))
    critical_error("Invalid PowerPC relative branch", insn);
  unsigned width = opcode == 16 ? 16 : 26;
  uint32_t mask = width == 16 ? 0xfffc : 0x03fffffc;
  fixnum displacement = insn & mask;
  if (insn & ((uint32_t)1 << (width - 1)))
    displacement -= (fixnum)1 << width;
  return (fixnum)((cell)displacement + relative_to - 4);
}

inline void ppc_store_relative(cell pointer, fixnum absolute) {
  uint32_t insn = ppc_instruction(pointer - 4);
  unsigned opcode = insn >> 26;
  if ((opcode != 16 && opcode != 18) || (insn & 2))
    critical_error("Invalid PowerPC relative branch", insn);
  uint32_t mask = opcode == 16 ? 0xfffc : 0x03fffffc;
  fixnum displacement = (fixnum)((cell)absolute - pointer + 4);
  if ((displacement & 3) || displacement < -(fixnum)((mask + 4) / 2) ||
      displacement >= (fixnum)((mask + 4) / 2))
    critical_error("PowerPC branch out of range", (cell)displacement);
  ppc_store_instruction(pointer - 4, (insn & ~mask) | ((uint32_t)displacement & mask));
}

inline bool ppc_toc_operand(cell pointer) {
  uint32_t last = ppc_instruction(pointer - 4);
  return (last >> 26) == 24 && ((last >> 21) & 31) == 2;
}

#include "powerpc_frame.h"

inline bool ppc_signal_frame_p(cell frame, cell size) {
  if (size != 4 * sizeof(cell))
    return false;
  cell metadata = *(cell*)(frame + PPC_SIGNAL_FRAME_METADATA);
  return (metadata & ~cell(7)) == PPC_SIGNAL_FRAME_MARKER &&
         (metadata & 7) >= ppc_leaf && (metadata & 7) <= ppc_temporary_leaf;
}

inline ppc_interrupted_frame_state ppc_signal_frame_state(cell frame) {
  return (ppc_interrupted_frame_state)(*(cell*)(frame + PPC_SIGNAL_FRAME_METADATA) & 7);
}

}
