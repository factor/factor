namespace factor {

enum relocation_type {
  // arg is a literal table index, holding a pair (symbol/dll)
  RT_DLSYM,
  // a word or quotation's general entry point
  RT_ENTRY_POINT,
  // a word's PIC entry point
  RT_ENTRY_POINT_PIC,
  // a word's tail-call PIC entry point
  RT_ENTRY_POINT_PIC_TAIL,
  // current offset
  RT_HERE,
  // current code block
  RT_THIS,
  // data heap literal
  RT_LITERAL,
  // untagged fixnum literal
  RT_UNTAGGED,
  // address of megamorphic_cache_hits var
  RT_MEGAMORPHIC_CACHE_HITS,
  // address of vm object
  RT_VM,
  // value of vm->cards_offset
  RT_CARDS_OFFSET,
  // value of vm->decks_offset
  RT_DECKS_OFFSET,
  RT_UNUSED,
  // arg is a literal table index, holding a pair (symbol/dll)
  RT_DLSYM_TOC,
  // address of inline_cache_miss function. This is a separate
  // relocation to reduce compile time and size for PICs.
  RT_INLINE_CACHE_MISS,
  // address of safepoint page in code heap
  RT_SAFEPOINT
};

enum relocation_class {
  // absolute address in a pointer-width location
  RC_ABSOLUTE_CELL,
  // absolute address in a 4 byte location
  RC_ABSOLUTE,
  // relative address in a 4 byte location
  RC_RELATIVE,
  // absolute address in a PowerPC LIS/ORI sequence
  RC_ABSOLUTE_PPC_2_2,
  // absolute address in a PowerPC LWZ instruction
  RC_ABSOLUTE_PPC_2,
  // relative address in a PowerPC LWZ/STW/BC instruction
  RC_RELATIVE_PPC_2_PC,
  // relative address in a PowerPC B/BL instruction
  RC_RELATIVE_PPC_3_PC,
  // relative address in an ARM32 B/BL instruction
  RC_RELATIVE_ARM_3,
  // pointer to address in an ARM32 LDR/STR instruction
  RC_INDIRECT_ARM,
  // pointer to address in an ARM32 LDR/STR instruction offset by 8 bytes
  RC_INDIRECT_ARM_PC,
  // absolute address in a 2 byte location
  RC_ABSOLUTE_2,
  // absolute address in a 1 byte location
  RC_ABSOLUTE_1,
  // absolute address in a PowerPC LIS/ORI/SLDI/ORIS/ORI sequence
  RC_ABSOLUTE_PPC_2_2_2_2,
  // Relative address stored, divided by four, in bits 25:0 of an ARM64 instruction
  RC_RELATIVE_ARM64_BRANCH,
  // Relative address stored, divided by four, in bits 23:5 of an ARM64 instruction
  RC_RELATIVE_ARM64_BCOND,
  // Absolute address stored in bits 20:5 of an ARM64 instruction
  RC_ABSOLUTE_ARM64_MOVZ,
  // relative address in a pointer-width location
  RC_RELATIVE_CELL,
};

static const cell rel_absolute_ppc_2_mask = 0x0000ffff;
static const cell rel_relative_ppc_2_mask = 0x0000fffc;
static const cell rel_relative_ppc_3_mask = 0x03fffffc;
static const cell rel_indirect_arm_mask = 0x00000fff;
static const cell rel_relative_arm_3_mask = 0x00ffffff;
static const cell rel_relative_arm64_branch_mask = 0x03ffffff;
static const cell rel_relative_arm64_bcond_mask = 0x00ffffe0;
static const cell rel_absolute_arm64_movz_mask = 0x001fffe0;

// code relocation table consists of a table of entries for each fixup
struct relocation_entry {
  uint32_t value;

  explicit relocation_entry(uint32_t value) : value(value) {}

  relocation_entry(relocation_type rel_type, relocation_class rel_class,
                   cell offset) {
    value = (uint32_t)((rel_type << 28) | (rel_class << 24) | offset);
  }

  relocation_type type() {
    return (relocation_type)((value & 0xf0000000) >> 28);
  }

  relocation_class klass() {
    return (relocation_class)((value & 0x0f000000) >> 24);
  }

  cell offset() { return (value & 0x00ffffff); }

  int number_of_parameters() {
    switch (type()) {
      case RT_VM:
        return 1;
      case RT_DLSYM:
      case RT_DLSYM_TOC:
        return 2;
      case RT_ENTRY_POINT:
      case RT_ENTRY_POINT_PIC:
      case RT_ENTRY_POINT_PIC_TAIL:
      case RT_LITERAL:
      case RT_HERE:
      case RT_UNTAGGED:
      case RT_THIS:
      case RT_MEGAMORPHIC_CACHE_HITS:
      case RT_CARDS_OFFSET:
      case RT_DECKS_OFFSET:
      case RT_INLINE_CACHE_MISS:
      case RT_SAFEPOINT:
        return 0;
      default:
        critical_error("Bad rel type in number_of_parameters()", type());
        return -1; // Can't happen
    }
  }
};

struct instruction_operand {
  relocation_entry rel;
  code_block* compiled;
  cell index;
  cell pointer;

  instruction_operand(relocation_entry rel, code_block* compiled,
                      cell index);

  fixnum load_value_2_2();
  fixnum load_value_2_2_2_2();
  fixnum load_value_masked(cell mask, cell preshift, cell bits, cell postshift);
  fixnum load_value(cell relative_to);
  code_block* load_code_block();

  void store_value_2_2(fixnum value);
  void store_value_2_2_2_2(fixnum value);
  void store_value_masked(fixnum value, cell mask, cell shift1, cell shift2);
  void store_value(fixnum value);
};

}
