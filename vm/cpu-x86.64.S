#include "asm.h"

DEF(long long,read_timestamp_counter,(void)):
	mov $0,%rax
	rdtsc
	shl $32,%rdx
	or %rdx,%rax
	ret

DEF(void,get_sse_env,(void*)):
	stmxcsr (%rdi)
	ret

DEF(void,set_sse_env,(const void*)):
	ldmxcsr (%rdi)
	ret

DEF(void,get_x87_env,(void*)):
	fnstsw (%rdi)
	fnstcw 2(%rdi)
	ret

DEF(void,set_x87_env,(const void*)):
	fnclex
	fldcw 2(%rdi)
	ret

#define RETURN_REG %rax
	
#include "cpu-x86.S"
