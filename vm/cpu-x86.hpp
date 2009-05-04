#include <assert.h>

namespace factor
{

#define FRAME_RETURN_ADDRESS(frame) *(void **)(frame_successor(frame) + 1)

inline static void flush_icache(cell start, cell len) {}

inline static void check_call_site(cell return_address)
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

/* Defined in assembly */
VM_ASM_API void c_to_factor(cell quot);
VM_ASM_API void throw_impl(cell quot, stack_frame *rewind_to);
VM_ASM_API void lazy_jit_compile(cell quot);

VM_C_API void set_callstack(stack_frame *to,
			      stack_frame *from,
			      cell length,
			      void *(*memcpy)(void*,const void*, size_t));

}
