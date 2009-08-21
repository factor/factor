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
	/* address of stack_chain var */
	RT_STACK_CHAIN,
	/* untagged fixnum literal */
	RT_UNTAGGED,
	/* address of megamorphic_cache_hits var */
	RT_MEGAMORPHIC_CACHE_HITS,
	/* address of vm object*/
	RT_VM,
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
typedef u32 relocation_entry;

struct factorvm;

typedef void (*relocation_iterator)(relocation_entry rel, cell index, code_block *compiled, factorvm *vm);

// callback functions
void relocate_code_block(code_block *compiled, factorvm *myvm);
void copy_literal_references(code_block *compiled, factorvm *myvm);
void update_word_references(code_block *compiled, factorvm *myvm);
void update_literal_and_word_references(code_block *compiled, factorvm *myvm);

}
