#include "asm.h"

#define RETURN_REG %eax

DEF(long long,read_timestamp_counter,(void)):
	rdtsc
	ret

DEF(void,get_sse_env,(void*)):
	movl 4(%esp), %eax
	stmxcsr (%eax)
	ret

DEF(void,set_sse_env,(const void*)):
	movl 4(%esp), %eax
	ldmxcsr (%eax)
	ret

DEF(void,get_x87_env,(void*)):
	movl 4(%esp), %eax
	fnstsw (%eax)
	fnstcw 2(%eax)
	ret

DEF(void,set_x87_env,(const void*)):
	movl 4(%esp), %eax
	fnclex
	fldcw 2(%eax)
	ret

#include "cpu-x86.S"

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:read_timestamp_counter"
	.ascii " -export:get_sse_env"
	.ascii " -export:set_sse_env"
	.ascii " -export:get_x87_env"
	.ascii " -export:set_x87_env"
#endif
