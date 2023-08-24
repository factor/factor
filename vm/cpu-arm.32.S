#include "asm.h"

/* Note that the XT is passed to the quotation in r12 */
#define CALL_QUOT \
        ldr r12,[r0, #9]     /* load quotation-xt slot */ ; \
       mov lr,pc ; \
        mov pc,r12

#define JUMP_QUOT \
        ldr r12,[r0, #9]     /* load quotation-xt slot */ ; \
       mov pc,r12

#define SAVED_REGS_SIZE 32

#define FRAME (RESERVED_SIZE + SAVED_REGS_SIZE + 8)

#define LR_SAVE [sp, #-4]
#define RESERVED_SIZE 8

#define SAVE_LR str lr,LR_SAVE

#define LOAD_LR ldr lr,LR_SAVE

#define SAVE_AT(offset) (RESERVED_SIZE + 4 * offset)

#define SAVE(register,offset) str register,[sp, #SAVE_AT(offset)]

#define RESTORE(register,offset) ldr register,[sp, #SAVE_AT(offset)]

#define PROLOGUE \
       SAVE_LR ; \
       sub sp,sp,#FRAME

#define EPILOGUE \
       add sp,sp,#FRAME ; \
       LOAD_LR

DEF(void,c_to_factor,(CELL quot)):
        PROLOGUE

       SAVE(r4,0)           /* save GPRs */
                             /* don't save ds pointer */
                             /* don't save rs pointer */
        SAVE(r7,3)
        SAVE(r8,4)
        SAVE(r9,5)
        SAVE(r10,6)
        SAVE(r11,7)
       SAVE(r0,8)           /* save quotation since we're about to mangle it */

        sub r0,sp,#4         /* pass call stack pointer as an argument */
       bl MANGLE(save_callstack_bottom)

       RESTORE(r0,8)        /* restore quotation */
        CALL_QUOT

        RESTORE(r11,7)       /* restore GPRs */
        RESTORE(r10,6)
        RESTORE(r9,5)
        RESTORE(r8,4)
        RESTORE(r7,3)
                             /* don't restore rs pointer */
                             /* don't restore ds pointer */
        RESTORE(r4,0)

        EPILOGUE
        mov pc,lr

/* The JIT compiles an 'mov r1',sp in front of every primitive call, since a
word which was defined as a primitive will not change its definition for the
lifetime of the image -- adding new primitives requires a bootstrap. However,
an undefined word can certainly become defined,

DEFER: foo
...
: foo ... ;

And calls to non-primitives do not have this one-instruction prologue, so we
set the XT of undefined words to this symbol. */
DEF(void,undefined,(CELL word)):
       sub r1,sp,#4
       b MANGLE(undefined_error)

/* Here we have two entry points. The first one is taken when profiling is
enabled */
DEF(void,docol_profiling,(CELL word)):
        ldr r1,[r0, #25]     /* load profile-count slot */
        add r1,r1,#8         /* increment count */
        str r1,[r0, #25]     /* store profile-count slot */
DEF(void,docol,(CELL word)):
        ldr r0,[r0, #13]     /* load word-def slot */
        JUMP_QUOT

/* We must pass the XT to the quotation in r12. */
DEF(void,primitive_call,(void)):
        ldr r0,[r5], #-4     /* load quotation from data stack */
        JUMP_QUOT

/* We must preserve r1 here in case we're calling a primitive */
DEF(void,primitive_execute,(void)):
        ldr r0,[r5], #-4     /* load word from data stack */
        ldr pc,[r0, #29]     /* jump to word-xt */

@ DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length)):
@         sub sp,r0,r2         /* compute new stack pointer */
@         mov r0,sp            /* start of destination of memcpy() */
@        sub sp,sp,#12        /* alignment */
@         bl MANGLE(memcpy)    /* go */
@        add sp,sp,#16        /* point SP at innermost frame */
@         ldr pc,LR_SAVE       /* return */

DEF(void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
       add sp,r1,#4         /* compute new stack pointer */
       ldr lr,LR_SAVE       /* we have rewound the stack; load return address */
       JUMP_QUOT            /* call the quotation */

DEF(void,lazy_jit_compile,(CELL quot)):
       mov r1,sp            /* save stack pointer */
       PROLOGUE
       bl MANGLE(lazy_jit_compile_impl)
       EPILOGUE
        JUMP_QUOT            /* call the quotation */

#ifdef WINCE
       .section .drectve
       .ascii " -export:c_to_factor"
#endif
