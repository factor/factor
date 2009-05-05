namespace factor
{

enum relocation_type {
	/* arg is a primitive number */
	RT_PRIMITIVE,
	/* arg is a literal table index, holding an array pair (symbol/dll) */
	RT_DLSYM,
	/* a pointer to a compiled word reference */
	RT_DISPATCH,
	/* a word's general entry point XT */
	RT_XT,
	/* a word's direct entry point XT */
	RT_XT_DIRECT,
	/* current offset */
	RT_HERE,
	/* current code block */
	RT_THIS,
	/* immediate literal */
	RT_IMMEDIATE,
	/* address of stack_chain var */
	RT_STACK_CHAIN,
	/* untagged fixnum literal */
	RT_UNTAGGED,
};

enum relocation_class {
	/* absolute address in a 64-bit location */
	RC_ABSOLUTE_CELL,
	/* absolute address in a 32-bit location */
	RC_ABSOLUTE,
	/* relative address in a 32-bit location */
	RC_RELATIVE,
	/* relative address in a PowerPC LIS/ORI sequence */
	RC_ABSOLUTE_PPC_2_2,
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

#define REL_RELATIVE_PPC_2_MASK 0xfffc
#define REL_RELATIVE_PPC_3_MASK 0x3fffffc
#define REL_INDIRECT_ARM_MASK 0xfff
#define REL_RELATIVE_ARM_3_MASK 0xffffff

/* code relocation table consists of a table of entries for each fixup */
typedef u32 relocation_entry;
#define REL_TYPE(r) (relocation_type)(((r) & 0xf0000000) >> 28)
#define REL_CLASS(r) (relocation_class)(((r) & 0x0f000000) >> 24)
#define REL_OFFSET(r) ((r) & 0x00ffffff)

void flush_icache_for(code_block *compiled);

typedef void (*relocation_iterator)(relocation_entry rel, cell index, code_block *compiled);

void iterate_relocations(code_block *compiled, relocation_iterator iter);

void store_address_in_code_block(cell klass, cell offset, fixnum absolute_value);

void relocate_code_block(code_block *compiled);

void update_literal_references(code_block *compiled);

void copy_literal_references(code_block *compiled);

void update_word_references(code_block *compiled);

void update_literal_and_word_references(code_block *compiled);

void mark_code_block(code_block *compiled);

void mark_active_blocks(context *stacks);

void mark_object_code_block(object *scan);

void relocate_code_block(code_block *relocating);

inline static bool stack_traces_p()
{
	return userenv[STACK_TRACES_ENV] != F;
}

code_block *add_code_block(cell type, cell code, cell labels, cell relocation, cell literals);

}
