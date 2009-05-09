#include <assert.h>

namespace factor
{

#define FRAME_RETURN_ADDRESS(frame) *(void **)(frame_successor(frame) + 1)

inline static void flush_icache(cell start, cell len) {}

/* In the instruction sequence:

   MOV EBX,...
   JMP blah

   the offset from the immediate operand to MOV to the instruction after
   the jump is a cell for the immediate operand, 4 bytes for the JMP
   destination, and one byte for the JMP opcode. */
static const fixnum xt_tail_pic_offset = sizeof(cell) + 4 + 1;

static const unsigned char call_opcode = 0xe8;
static const unsigned char jmp_opcode = 0xe9;

inline static unsigned char call_site_opcode(cell return_address)
{
	return *(unsigned char *)(return_address - 5);
}

inline static void check_call_site(cell return_address)
{
#ifdef FACTOR_DEBUG
	unsigned char opcode = call_site_opcode(return_address);
	assert(opcode == call_opcode || opcode == jmp_opcode);
#endif
}

inline static void *get_call_target(cell return_address)
{
	check_call_site(return_address);
	return (void *)(*(int *)(return_address - 4) + return_address);
}

inline static void set_call_target(cell return_address, void *target)
{
	check_call_site(return_address);
	*(int *)(return_address - 4) = ((cell)target - return_address);
}

inline static bool tail_call_site_p(cell return_address)
{
	return call_site_opcode(return_address) == jmp_opcode;
}

/* Defined in assembly */
VM_ASM_API void c_to_factor(cell quot);
VM_ASM_API void throw_impl(cell quot, stack_frame *rewind_to);
VM_ASM_API void lazy_jit_compile(cell quot);

VM_C_API void set_callstack(stack_frame *to,
			      stack_frame *from,
			      cell length,
			      void *(*memcpy)(void*,const void*, size_t));

}
