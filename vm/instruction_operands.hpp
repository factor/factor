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
  // Relative address in an ARM B/BL instruction
  RC_RELATIVE_ARM_B,
  // Relative address in an ARM B.cond or LDR (literal) instruction
  RC_RELATIVE_ARM_B_COND_LDR,
  // absolute offset in an ARM LDUR instruction
  RC_ABSOLUTE_ARM_LDUR,
  // absolute value in an ARM CMP instruction
  RC_ABSOLUTE_ARM_CMP,
  // absolute address in a 2 byte location
  RC_ABSOLUTE_2 = 10,
  // absolute address in a 1 byte location
  RC_ABSOLUTE_1
};

static const cell rel_arm_b_mask = 0x03ffffff;
static const cell rel_arm_b_cond_ldr_mask = 0x00ffffe0;
static const cell rel_arm_ldur_mask = 0x001ff000;
static const cell rel_arm_cmp_mask = 0x003ffc00;

// code relocation table consists of a table of entries for each fixup
struct relocation_entry {
  uint32_t value;

  explicit relocation_entry(uint32_t value) : value(value) {}

  relocation_entry(relocation_type rel_type, relocation_class rel_class,
                   cell offset) {
    value = static_cast<uint32_t>((rel_type << 28) | (rel_class << 24) | offset);
  }

  relocation_type type() {
    return static_cast<relocation_type>((value & 0xf0000000) >> 28);
  }

  relocation_class klass() {
    return static_cast<relocation_class>((value & 0x0f000000) >> 24);
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

  fixnum load_value_masked(cell msb, cell lsb, cell scaling);
  fixnum load_value(cell relative_to);
  code_block* load_code_block();

  void store_value_masked(fixnum value, cell mask, cell lsb, cell scaling);
  void store_value(fixnum value);
};

}
