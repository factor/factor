namespace factor
{

#define FACTOR_CPU_STRING "ppc"
#define VM_ASM_API VM_C_API

register cell ds asm("r13");
register cell rs asm("r14");

inline static void check_call_site(cell return_address)
{
#ifdef FACTOR_DEBUG
	cell insn = *(cell *)return_address;
	assert((insn & 0x3) == 0x1);
	assert((insn >> 26) == 0x12);
#endif
}

#define B_MASK 0x3fffffc

inline static void *get_call_target(cell return_address)
{
	return_address -= sizeof(cell);

	check_call_site(return_address);
	cell insn = *(cell *)return_address;
	cell unsigned_addr = (insn & B_MASK);
	fixnum signed_addr = (fixnum)(unsigned_addr << 6) >> 6;
	return (void *)(signed_addr + return_address);
}

inline static void set_call_target(cell return_address, void *target)
{
	return_address -= sizeof(cell);

#ifdef FACTOR_DEBUG
	assert((return_address & ~B_MASK) == 0);
	check_call_site(return_address);
#endif
	cell insn = *(cell *)return_address;
	insn = ((insn & ~B_MASK) | (((cell)target - return_address) & B_MASK));
	*(cell *)return_address = insn;

	/* Flush the cache line containing the call we just patched */
	__asm__ __volatile__ ("icbi 0, %0\n" "sync\n"::"r" (return_address):);
}

/* Defined in assembly */
VM_ASM_API void c_to_factor(cell quot);
VM_ASM_API void throw_impl(cell quot, stack_frame *rewind);
VM_ASM_API void lazy_jit_compile(cell quot);
VM_ASM_API void flush_icache(cell start, cell len);

VM_ASM_API void set_callstack(stack_frame *to,
			       stack_frame *from,
			       cell length,
			       void *(*memcpy)(void*,const void*, size_t));

}
