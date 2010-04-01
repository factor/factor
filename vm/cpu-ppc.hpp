namespace factor
{

#define FACTOR_CPU_STRING "ppc"

#define CALLSTACK_BOTTOM(ctx) (stack_frame *)(ctx->callstack_seg->end - 32)

/* In the instruction sequence:

   LOAD32 r3,...
   B blah

   the offset from the immediate operand to LOAD32 to the instruction after
   the branch is one instruction. */
static const fixnum xt_tail_pic_offset = 4;

inline static void check_call_site(cell return_address)
{
	cell insn = *(cell *)return_address;
	/* Check that absolute bit is 0 */
	assert((insn & 0x2) == 0x0);
	/* Check that instruction is branch */
	assert((insn >> 26) == 0x12);
}

static const cell b_mask = 0x3fffffc;

inline static void *get_call_target(cell return_address)
{
	return_address -= sizeof(cell);
	check_call_site(return_address);

	cell insn = *(cell *)return_address;
	cell unsigned_addr = (insn & b_mask);
	fixnum signed_addr = (fixnum)(unsigned_addr << 6) >> 6;
	return (void *)(signed_addr + return_address);
}

inline static void set_call_target(cell return_address, void *target)
{
	return_address -= sizeof(cell);
	check_call_site(return_address);

	cell insn = *(cell *)return_address;

	fixnum relative_address = ((cell)target - return_address);
	insn = ((insn & ~b_mask) | (relative_address & b_mask));
	*(cell *)return_address = insn;

	/* Flush the cache line containing the call we just patched */
	__asm__ __volatile__ ("icbi 0, %0\n" "sync\n"::"r" (return_address):);
}

inline static bool tail_call_site_p(cell return_address)
{
	return_address -= sizeof(cell);
	cell insn = *(cell *)return_address;
	return (insn & 0x1) == 0;
}

inline static unsigned int fpu_status(unsigned int status)
{
	unsigned int r = 0;

	if (status & 0x20000000)
		r |= FP_TRAP_INVALID_OPERATION;
	if (status & 0x10000000)
		r |= FP_TRAP_OVERFLOW;
	if (status & 0x08000000)
		r |= FP_TRAP_UNDERFLOW;
	if (status & 0x04000000)
		r |= FP_TRAP_ZERO_DIVIDE;
	if (status & 0x02000000)
		r |= FP_TRAP_INEXACT;

	return r;
}

/* Defined in assembly */
VM_C_API void flush_icache(cell start, cell len);

}
