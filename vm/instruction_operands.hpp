namespace factor
{

enum relocation_type {
	/* arg is a primitive number */
	RT_PRIMITIVE,
	/* arg is a literal table index, holding an array pair (symbol/dll) */
	RT_DLSYM,
	/* a pointer to a compiled word reference */
	RT_DISPATCH,
	/* a word or quotation's general entry point */
	RT_XT,
	/* a word's PIC entry point */
	RT_XT_PIC,
	/* a word's tail-call PIC entry point */
	RT_XT_PIC_TAIL,
	/* current offset */
	RT_HERE,
	/* current code block */
	RT_THIS,
	/* immediate literal */
	RT_IMMEDIATE,
	/* address of ctx var */
	RT_CONTEXT,
	/* untagged fixnum literal */
	RT_UNTAGGED,
	/* address of megamorphic_cache_hits var */
	RT_MEGAMORPHIC_CACHE_HITS,
	/* address of vm object */
	RT_VM,
	/* value of vm->cards_offset */
	RT_CARDS_OFFSET,
	/* value of vm->decks_offset */
	RT_DECKS_OFFSET,
};

enum relocation_class {
	/* absolute address in a 64-bit location */
	RC_ABSOLUTE_CELL,
	/* absolute address in a 32-bit location */
	RC_ABSOLUTE,
	/* relative address in a 32-bit location */
	RC_RELATIVE,
	/* absolute address in a PowerPC LIS/ORI sequence */
	RC_ABSOLUTE_PPC_2_2,
	/* absolute address in a PowerPC LWZ instruction */
	RC_ABSOLUTE_PPC_2,
	/* relative address in a PowerPC LWZ/STW/BC instruction */
	RC_RELATIVE_PPC_2,
	/* relative address in a PowerPC B/BL instruction */
	RC_RELATIVE_PPC_3,
	/* relative address in an ARM B/BL instruction */
	RC_RELATIVE_ARM_3,
	/* pointer to address in an ARM LDR/STR instruction */
	RC_INDIRECT_ARM,
	/* pointer to address in an ARM LDR/STR instruction offset by 8 bytes */
	RC_INDIRECT_ARM_PC
};

static const cell rel_absolute_ppc_2_mask = 0xffff;
static const cell rel_relative_ppc_2_mask = 0xfffc;
static const cell rel_relative_ppc_3_mask = 0x3fffffc;
static const cell rel_indirect_arm_mask = 0xfff;
static const cell rel_relative_arm_3_mask = 0xffffff;

/* code relocation table consists of a table of entries for each fixup */
struct relocation_entry {
	u32 value;

	relocation_entry(u32 value_) : value(value_) {}

	relocation_entry(relocation_type rel_type,
		relocation_class rel_class,
		cell offset)
	{
		value = (rel_type << 28) | (rel_class << 24) | offset;
	}

	relocation_type rel_type()
	{
		return (relocation_type)((value & 0xf0000000) >> 28);
	}

	relocation_class rel_class()
	{
		return (relocation_class)((value & 0x0f000000) >> 24);
	}

	cell rel_offset()
	{
		return (value & 0x00ffffff);
	}

	int number_of_parameters()
	{
		switch(rel_type())
		{
		case RT_PRIMITIVE:
		case RT_XT:
		case RT_XT_PIC:
		case RT_XT_PIC_TAIL:
		case RT_IMMEDIATE:
		case RT_HERE:
		case RT_UNTAGGED:
		case RT_VM:
			return 1;
		case RT_DLSYM:
			return 2;
		case RT_THIS:
		case RT_CONTEXT:
		case RT_MEGAMORPHIC_CACHE_HITS:
		case RT_CARDS_OFFSET:
		case RT_DECKS_OFFSET:
			return 0;
		default:
			critical_error("Bad rel type",rel_type());
			return -1; /* Can't happen */
		}
	}
};

struct instruction_operand {
	cell rel_class;
	cell pointer;

	instruction_operand(cell rel_class_, cell pointer_) :
		rel_class(rel_class_), pointer(pointer_) {}

	fixnum load_value_2_2();
	fixnum load_value_masked(cell mask, fixnum shift);
	fixnum load_value(cell relative_to);
	fixnum load_value();
	code_block *load_code_block();

	void store_value_2_2(fixnum value);
	void store_value_masked(fixnum value, cell mask, fixnum shift);
	void store_value(fixnum value);
	void store_code_block(code_block *compiled);
};

}
