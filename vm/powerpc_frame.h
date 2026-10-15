// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// Shared by the C++ VM and Zig's native PowerPC signal-context bridge.
// Match emitted sequences without changing their instruction layout.
typedef enum ppc_interrupted_frame_state {
  ppc_unknown, ppc_leaf, ppc_pre, ppc_active, ppc_post, ppc_temporary, ppc_temporary_leaf
} ppc_interrupted_frame_state;

struct ppc_sequence { uintptr_t cursor, end; };

static inline uint32_t ppc_frame_instruction(uintptr_t address) {
  uint32_t value; memcpy(&value, (const void*)address, sizeof(value)); return value;
}

static inline bool ppc_sequence_match(struct ppc_sequence* sequence,
                                     uint32_t expected, uint32_t mask) {
  if (sequence->cursor > sequence->end || sequence->end - sequence->cursor < 4 ||
      (ppc_frame_instruction(sequence->cursor) & mask) != expected)
    return false;
  sequence->cursor += 4;
  return true;
}

static inline bool ppc_sequence_instruction(struct ppc_sequence* sequence,
                                           uint32_t expected) {
  return ppc_sequence_match(sequence, expected, UINT32_MAX);
}

static inline bool ppc_sequence_absolute(struct ppc_sequence* sequence,
                                        unsigned reg) {
  if (!ppc_sequence_match(sequence, 0x3c000000 | (reg << 21), 0xffff0000) ||
      !ppc_sequence_match(sequence, 0x60000000 | (reg << 21) | (reg << 16), 0xffff0000))
    return false;
  if (sizeof(uintptr_t) == 8 &&
      (!ppc_sequence_instruction(sequence, 0x780007c6 | (reg << 21) | (reg << 16)) ||
       !ppc_sequence_match(sequence, 0x64000000 | (reg << 21) | (reg << 16), 0xffff0000) ||
       !ppc_sequence_match(sequence, 0x60000000 | (reg << 21) | (reg << 16), 0xffff0000)))
    return false;
  return true;
}

static inline bool ppc_sequence_immediate(struct ppc_sequence* sequence,
                                         unsigned reg, uintptr_t value) {
  if ((intptr_t)value >= -32768 && (intptr_t)value <= 32767)
    return ppc_sequence_instruction(sequence, 0x38000000 | (reg << 21) | (value & 0xffff));
  uintptr_t start = sequence->cursor;
  if (!ppc_sequence_absolute(sequence, reg)) return false;
  uintptr_t loaded;
  if (sizeof(uintptr_t) == 8) {
    loaded = ((uint64_t)(ppc_frame_instruction(start) & 0xffff) << 48) |
             ((uint64_t)(ppc_frame_instruction(start + 4) & 0xffff) << 32) |
             ((uint64_t)(ppc_frame_instruction(start + 12) & 0xffff) << 16) |
             (ppc_frame_instruction(start + 16) & 0xffff);
  } else {
    loaded = ((uintptr_t)(ppc_frame_instruction(start) & 0xffff) << 16) |
             (ppc_frame_instruction(start + 4) & 0xffff);
  }
  return loaded == value;
}

// get/set-fpu-state reserve exactly 32 bytes while leaving the ordinary
// frame underneath. Match the whole emitted operation, including restoration.
static inline bool ppc_fpscr_reservation(uintptr_t start, uintptr_t end,
                                       uintptr_t pc, bool getter) {
  struct ppc_sequence seq = {start, end};
  if (!ppc_sequence_instruction(&seq, sizeof(uintptr_t) == 8 ? 0xf821ffe1 : 0x9421ffe0))
    return false;
  uintptr_t allocated = seq.cursor;
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
  const uint32_t low = 16, high = 20;
#else
  const uint32_t low = 20, high = 16;
#endif
  if (getter && (!ppc_sequence_instruction(&seq, 0xfc00048e) ||
                 !ppc_sequence_instruction(&seq, 0xd8010010) ||
                 !ppc_sequence_instruction(&seq, 0x80610000 | low))) return false;
  if (!ppc_sequence_immediate(&seq, 4, 0x0007f8ff) ||
      !ppc_sequence_instruction(&seq, 0x7c642038) ||
      !ppc_sequence_instruction(&seq, 0x90810000 | low)) return false;
  if (!getter && (!ppc_sequence_instruction(&seq, 0x38a00000) ||
                  !ppc_sequence_instruction(&seq, 0x90a10000 | high))) return false;
  if (!ppc_sequence_instruction(&seq, 0xc8010010) ||
      !ppc_sequence_instruction(&seq, 0xfdfe058e)) return false;
  uintptr_t restore = seq.cursor;
  return ppc_sequence_instruction(&seq, 0x38210020) && pc >= allocated && pc <= restore;
}

// R1-changing forms emitted by the PPC backend and raw subprimitives.
// A leaf header alone does not describe a temporary or switched stack.
static inline bool ppc_instruction_changes_stack(uint32_t word) {
  unsigned opcode=word>>26, rt=(word>>21)&31, ra=(word>>16)&31;
  switch (opcode) {
    case 14: case 15: case 32: case 34: case 40: case 42:
      return rt==1;
    case 33: case 35: case 41: case 43:
      return rt==1 || ra==1;
    case 37: case 39: case 45: case 49: case 51: case 53: case 55:
      return ra==1;
    case 20: case 21: case 23: case 24: case 25: case 26: case 27:
    case 28: case 29: case 30:
      return ra==1;
    case 58:
      return rt==1 || ((word&3)==1 && ra==1);
    case 62:
      return (word&3)==1 && ra==1;
    case 31: {
      unsigned xo=(word>>1)&1023;
      // CMP/CMPL's RT field is a CR selector, not a destination GPR.
      if (xo==0 || xo==32) return false;
      switch (xo) {
        case 19: case 83: case 339: case 371:
        case 21: case 23: case 87: case 279: case 343:
          return rt==1;
        case 53: case 55: case 119: case 311: case 375:
          return rt==1 || ra==1;
        case 181: case 183: case 247: case 439:
        case 567: case 631: case 695: case 759:
          return ra==1;
        case 24: case 27: case 28: case 60: case 124: case 284:
        case 316: case 412: case 444: case 476: case 536: case 539:
        case 792: case 794: case 824: case 826:
          return ra==1;
      }
      switch (xo&511) {
        case 8: case 9: case 10: case 11: case 40: case 73: case 75:
        case 104: case 136: case 138: case 200: case 202: case 232:
        case 234: case 235: case 266: case 457: case 459: case 489:
        case 491: case 410: case 442: case 474:
          return rt==1;
      }
      return false;
    }
    default: return false;
  }
}

static inline ppc_interrupted_frame_state ppc_frame_state_from_prologue(
    uintptr_t entry, uintptr_t end, uintptr_t pc, uintptr_t frame_size,
    uintptr_t prologue_entry) {
  if (pc < entry || pc >= end || (pc - entry) % 4) return ppc_unknown;
  if (!frame_size) {
    const uintptr_t maximum = (sizeof(uintptr_t) == 8 ? 14 : 11) * 4;
    uintptr_t lower = pc - entry > maximum ? pc - maximum : entry;
    for (uintptr_t start = lower; start < pc; start += 4)
      if (ppc_fpscr_reservation(start, end, pc, true) ||
          ppc_fpscr_reservation(start, end, pc, false)) return ppc_temporary_leaf;
    for (uintptr_t address=entry; address<pc; address+=4) {
      if (!ppc_instruction_changes_stack(ppc_frame_instruction(address))) continue;
      // A completed, exactly matched FPSCR reservation leaves R1 unchanged.
      bool getter=ppc_fpscr_reservation(address,end,address+4,true);
      bool setter=ppc_fpscr_reservation(address,end,address+4,false);
      if (!getter && !setter) return ppc_unknown;
      uintptr_t instructions=(sizeof(uintptr_t)==8 ? 14 : 11)-(getter ? 0 : 1);
      address+=instructions*4-4;
    }
    return ppc_leaf;
  }
  if (prologue_entry < entry || prologue_entry >= end || (prologue_entry-entry)%4)
    return ppc_unknown;
  // A late prologue is located by its RT_THIS operand, not by searching an
  // arbitrary prefix. Reject a preceding instruction which can change R1.
  for (uintptr_t address=entry; address<prologue_entry; address+=4) {
    if (ppc_instruction_changes_stack(ppc_frame_instruction(address)))
      return ppc_unknown;
  }
  struct ppc_sequence prologue = {prologue_entry, end};
  // Optimized code begins with the polling sequence. The quotation compiler
  // emits the same linkage operations directly, using r0 for its metadata.
  unsigned metadata_reg = 0;
  struct ppc_sequence polling = prologue;
  if (ppc_sequence_absolute(&polling, 30) && ppc_sequence_instruction(&polling, 0x93de0000)) {
    prologue = polling;
    metadata_reg = 11;
  } else {
    // Unoptimized quotations poll through r12 before JIT-PROLOG; the
    // optimized backend polls through r30 and uses r11 for frame metadata.
    struct ppc_sequence quotation_poll = prologue;
    if (ppc_sequence_absolute(&quotation_poll, 12) &&
        ppc_sequence_instruction(&quotation_poll, 0x900c0000))
      prologue = quotation_poll;
  }
  uint32_t store = sizeof(uintptr_t) == 8 ? 0xf8000000 : 0x90000000;
  if (!ppc_sequence_instruction(&prologue, 0x7c0802a6) || // mflr r0
      !ppc_sequence_instruction(&prologue, sizeof(uintptr_t) == 8 ? 0xf8010010 : 0x90010004) ||
      !ppc_sequence_absolute(&prologue, metadata_reg) ||
      !ppc_sequence_instruction(&prologue, store | (metadata_reg << 21) | (1 << 16) |
                            ((-2 * sizeof(uintptr_t)) & 0xffff)) ||
      !ppc_sequence_immediate(&prologue, metadata_reg, frame_size) ||
      !ppc_sequence_instruction(&prologue, store | (metadata_reg << 21) | (1 << 16) |
                            ((-sizeof(uintptr_t)) & 0xffff)))
    return ppc_unknown;
  if (frame_size <= 32768) {
    uint32_t allocation = (sizeof(uintptr_t) == 8 ? 0xf8210001 : 0x94210000) |
                          ((-frame_size) & 0xffff);
    if (!ppc_sequence_instruction(&prologue, allocation)) return ppc_unknown;
  } else if (!ppc_sequence_instruction(&prologue, 0x7d6b00d0) ||
             !ppc_sequence_instruction(&prologue, sizeof(uintptr_t) == 8 ? 0x7c21596a : 0x7c21596e))
    return ppc_unknown;
  if (pc < prologue.cursor) return ppc_pre;

  // The maximum getter is allocation + mffs/store/load + five-instruction
  // mask + and/store/load/mtfsf/restore: 14 instructions on PPC64.
  const uintptr_t fpscr_instructions = sizeof(uintptr_t) == 8 ? 14 : 11;
  uintptr_t temporary_lower = pc - prologue.cursor > fpscr_instructions * 4
                           ? pc - fpscr_instructions * 4 : prologue.cursor;
  for (uintptr_t start = temporary_lower; start < pc; start += 4)
    if (ppc_fpscr_reservation(start, end, pc, true) ||
        ppc_fpscr_reservation(start, end, pc, false)) return ppc_temporary;

  // After restoring R1, %epilogue emits the LR load and mtlr, then %return
  // or %jump. The longest %jump is two five-instruction loads plus mtctr/bctr.
  const uintptr_t load_instructions = sizeof(uintptr_t) == 8 ? 5 : 2;
  const uintptr_t tail_instructions = 2 + 2 * load_instructions + 2 +
                                 (frame_size > 32767 ? load_instructions : 0);
  uintptr_t lower = pc - entry > tail_instructions * 4
                   ? pc - tail_instructions * 4 : entry;
  for (uintptr_t restore = lower; restore < pc; restore += 4) {
    struct ppc_sequence epilogue = {restore, end};
    if (frame_size <= 32767) {
      if (!ppc_sequence_instruction(&epilogue, 0x38210000 | frame_size)) continue;
    } else {
      if (!ppc_sequence_immediate(&epilogue, 0, frame_size) ||
          !ppc_sequence_instruction(&epilogue, 0x7c210214)) continue;
    }
    uintptr_t restored = epilogue.cursor;
    if (pc < restored ||
        !ppc_sequence_instruction(&epilogue, sizeof(uintptr_t) == 8 ? 0xe8010010 : 0x80010004) ||
        !ppc_sequence_instruction(&epilogue, 0x7c0803a6)) continue;
    struct ppc_sequence returning = epilogue;
    if (ppc_sequence_instruction(&returning, 0x4e800020) && pc < returning.cursor)
      return ppc_post;
    struct ppc_sequence simple_tail = epilogue;
    if (ppc_sequence_absolute(&simple_tail, 12) && ppc_sequence_instruction(&simple_tail, 0x7d8903a6) &&
        ppc_sequence_instruction(&simple_tail, 0x4e800420) && pc < simple_tail.cursor)
      return ppc_post;
    struct ppc_sequence optimized_tail = epilogue;
    if (ppc_sequence_absolute(&optimized_tail, 6) && ppc_sequence_absolute(&optimized_tail, 12) &&
        ppc_sequence_instruction(&optimized_tail, 0x7d8903a6) &&
        ppc_sequence_instruction(&optimized_tail, 0x4e800420) && pc < optimized_tail.cursor)
      return ppc_post;
    // Inline-cache resume transfers directly through r3. Quotation tails
    // load the entry through r4; computed dispatch uses its index register.
    struct ppc_sequence direct_tail = epilogue;
    if (ppc_sequence_instruction(&direct_tail, 0x7c6903a6) &&
        ppc_sequence_instruction(&direct_tail, 0x4e800420) && pc < direct_tail.cursor)
      return ppc_post;
    for (unsigned reg = 0; reg < 32; ++reg) {
      struct ppc_sequence dispatch = epilogue;
      if (!ppc_sequence_absolute(&dispatch, reg) || dispatch.cursor + 4 > end)
        continue;
      uint32_t load = ppc_frame_instruction(dispatch.cursor);
      uint32_t indexed = sizeof(uintptr_t) == 8 ? 0x7c00002a : 0x7c00002e;
      if ((load & 0xfc0007fe) != indexed ||
          ((load >> 21) & 31) != reg || ((load >> 11) & 31) != reg)
        continue;
      dispatch.cursor += 4;
      if (ppc_sequence_instruction(&dispatch, 0x7c0903a6 | (reg << 21)) &&
          ppc_sequence_instruction(&dispatch, 0x4e800420) && pc < dispatch.cursor)
        return ppc_post;
    }
    struct ppc_sequence quotation_tail = epilogue;
    if (ppc_sequence_match(&quotation_tail, 0x38800000, 0xffff0000) &&
        ppc_sequence_instruction(&quotation_tail, sizeof(uintptr_t) == 8 ? 0x7c83202a : 0x7c83202e) &&
        ppc_sequence_instruction(&quotation_tail, 0x7c8903a6) &&
        ppc_sequence_instruction(&quotation_tail, 0x4e800420) && pc < quotation_tail.cursor)
      return ppc_post;
  }
  return ppc_active;
}

static inline ppc_interrupted_frame_state ppc_frame_state(
    uintptr_t entry, uintptr_t end, uintptr_t pc, uintptr_t frame_size) {
  return ppc_frame_state_from_prologue(entry,end,pc,frame_size,entry);
}
