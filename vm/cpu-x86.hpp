#include <assert.h>

namespace factor
{

#define FRAME_RETURN_ADDRESS(frame) *(XT *)(frame_successor(frame) + 1)

inline static void flush_icache(CELL start, CELL len) {}

inline static void check_call_site(CELL return_address)
{
	/* An x86 CALL instruction looks like so:
	   |e8|..|..|..|..|
	   where the ... are a PC-relative jump address.
	   The return_address points to right after the
	   instruction. */
#ifdef FACTOR_DEBUG
	assert(*(unsigned char *)(return_address - 5) == 0xe8);
#endif
}

inline static CELL get_call_target(CELL return_address)
{
	check_call_site(return_address);
	return *(int *)(return_address - 4) + return_address;
}

inline static void set_call_target(CELL return_address, CELL target)
{
	check_call_site(return_address);
	*(int *)(return_address - 4) = (target - return_address);
}

/* Defined in assembly */
VM_ASM_API void c_to_factor(CELL quot);
VM_ASM_API void throw_impl(CELL quot, F_STACK_FRAME *rewind_to);
VM_ASM_API void lazy_jit_compile(CELL quot);

VM_C_API void set_callstack(F_STACK_FRAME *to,
			      F_STACK_FRAME *from,
			      CELL length,
			      void *(*memcpy)(void*,const void*, size_t));

}
