#include "asm.h"

/* Note that primitive word definitions are compiled with
__attribute__((regparm 2), so the pointer to the word object is passed in EAX,
and the callstack top is passed in EDX */

/* When calling a quotation, we pass the XT in ECX */
#define JUMP_QUOT \
	mov 5(%eax),%ecx ;                 /* Load quot-xt */ \
	jmp *%ecx                          /* Jump to quot-xt */

DEF(void,c_to_factor,(CELL quot)):
	push %ebp                          /* Save non-volatile registers */
	push %ebx

	lea -8(%esp),%eax                  /* Save stack pointer */
	push %eax                          /* This 16-byte aligns the stack */
	call MANGLE(save_callstack_bottom)

	mov 16(%esp),%eax                  /* Pass quot as arg 1 */
	mov 5(%eax),%ecx                   /* Pass quot-xt */
	call *%ecx                         /* Call quot-xt */

	pop %eax                           /* Clobber */
	pop %ebx                           /* Restore non-volatile registers */
	pop %ebp
	ret

DEF(void,undefined,(CELL word)):
	mov %esp,%ecx                      /* Save stack pointer before we mess with it */
	sub $12,%esp                       /* Alignment */
	mov %eax,4(%esp)                   /* Pass word as arg 1 (not fastcall) */
	mov %ecx,8(%esp)                   /* Pass callstack pointer as arg 2 (not fastcall) */
	jmp MANGLE(undefined_error)        /* This throws an error */

DEF(void,dosym,(CELL word)):
	add $4,%esi                        /* Increment stack pointer */
	mov %eax,(%esi)                    /* Store word on stack */
	ret

/* Here we have two entry points. The first one is taken when profiling is
enabled */
DEF(void,docol_profiling,(CELL word)):
	add $8,25(%eax)                    /* Increment profile-count slot */
DEF(void,docol,(CELL word)):
	mov 13(%eax),%eax                  /* Load word-def slot */
	JUMP_QUOT

/* We must pass the XT to the quotation in ECX. */
DEF(void,primitive_call,(void)):
        mov (%esi),%eax                    /* Load quotation from data stack */
	sub $4,%esi                        /* Pop data stack */
	JUMP_QUOT

/* We pass the word in EAX and the XT in ECX. Don't mess up EDX, it's the
callstack top parameter to primitives. */
DEF(void,primitive_execute,(void)):
	mov (%esi),%eax                    /* Load word from data stack */
	sub $4,%esi                        /* Pop data stack */
        mov 29(%eax),%ecx                  /* Load word-xt slot */
	jmp *%ecx                          /* Go */

/* We pass a function pointer to memcpy in 16(%esp) to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	mov 4(%esp),%ebp                   /* to */
	mov 8(%esp),%edx                   /* from */
	mov 12(%esp),%ecx                  /* length */
	mov 16(%esp),%eax                  /* memcpy */
	sub %ecx,%ebp                      /* compute new stack pointer */
	mov %ebp,%esp
	push %ecx                          /* pass length */
	push %edx                          /* pass src */
	push %ebp                          /* pass dst */
	call *%eax                         /* call memcpy */
	add $12,%esp                       /* pop args from the stack */
	ret                                /* return _with new stack_ */

DEF(void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mov 4(%esp),%eax                   /* quot */
	mov 8(%esp),%esp                   /* rewind_to */
	JUMP_QUOT
