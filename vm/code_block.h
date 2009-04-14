typedef enum {
	/* arg is a primitive number */
	RT_PRIMITIVE,
	/* arg is a literal table index, holding an array pair (symbol/dll) */
	RT_DLSYM,
	/* a pointer to a compiled word reference */
	RT_DISPATCH,
	/* a compiled word reference */
	RT_XT,
	/* current offset */
	RT_HERE,
	/* current code block */
	RT_THIS,
	/* immediate literal */
	RT_IMMEDIATE,
	/* address of stack_chain var */
	RT_STACK_CHAIN
} F_RELTYPE;

typedef enum {
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
} F_RELCLASS;

#define REL_RELATIVE_PPC_2_MASK 0xfffc
#define REL_RELATIVE_PPC_3_MASK 0x3fffffc
#define REL_INDIRECT_ARM_MASK 0xfff
#define REL_RELATIVE_ARM_3_MASK 0xffffff

/* code relocation table consists of a table of entries for each fixup */
typedef u32 F_REL;
#define REL_TYPE(r)   (((r) & 0xf0000000) >> 28)
#define REL_CLASS(r)  (((r) & 0x0f000000) >> 24)
#define REL_OFFSET(r)  ((r) & 0x00ffffff)

void flush_icache_for(F_CODE_BLOCK *compiled);

typedef void (*RELOCATION_ITERATOR)(F_REL rel, CELL index, F_CODE_BLOCK *compiled);

void iterate_relocations(F_CODE_BLOCK *compiled, RELOCATION_ITERATOR iter);

void store_address_in_code_block(CELL class, CELL offset, F_FIXNUM absolute_value);

void relocate_code_block(F_CODE_BLOCK *compiled);

void update_literal_references(F_CODE_BLOCK *compiled);

void copy_literal_references(F_CODE_BLOCK *compiled);

void update_word_references(F_CODE_BLOCK *compiled);

void mark_code_block(F_CODE_BLOCK *compiled);

void mark_active_blocks(F_CONTEXT *stacks);

void mark_object_code_block(CELL scan);

void relocate_code_block(F_CODE_BLOCK *relocating);

CELL compiled_code_format(void);

INLINE bool stack_traces_p(void)
{
	return userenv[STACK_TRACES_ENV] != F;
}

F_CODE_BLOCK *add_code_block(
	CELL type,
	F_ARRAY *code,
	F_ARRAY *labels,
	CELL relocation,
	CELL literals);
