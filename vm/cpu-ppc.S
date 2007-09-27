/* Parts of this file were snarfed from SBCL src/runtime/ppc-assem.S, which is
in the public domain. */
#include "asm.h"

/* Note that the XT is passed to the quotation in r11 */
#define CALL_OR_JUMP_QUOT \
        lwz r11,9(r3)      /* load quotation-xt slot */ XX \

#define CALL_QUOT \
        CALL_OR_JUMP_QUOT XX \
        mtlr r11           /* prepare to call XT with quotation in r3 */ XX \
        blrl               /* go */

#define JUMP_QUOT \
        CALL_OR_JUMP_QUOT XX \
        mtctr r11          /* prepare to call XT with quotation in r3 */ XX \
        bctr               /* go */

#define PARAM_SIZE 32

#define SAVED_REGS_SIZE 96

#define FRAME (RESERVED_SIZE + PARAM_SIZE + SAVED_REGS_SIZE + 8)
   
#if defined( __APPLE__)
        #define LR_SAVE 8
        #define RESERVED_SIZE 24
#else
        #define LR_SAVE 4
        #define RESERVED_SIZE 8
#endif

#define SAVE_LR(reg) stw reg,(LR_SAVE + FRAME)(r1)

#define LOAD_LR(reg) lwz reg,(LR_SAVE + FRAME)(r1)

#define SAVE_AT(offset) (RESERVED_SIZE + PARAM_SIZE + 4 * offset)

#define SAVE(register,offset) stw register,SAVE_AT(offset)(r1)

#define RESTORE(register,offset) lwz register,SAVE_AT(offset)(r1)

#define PROLOGUE \
	mflr r0 XX         /* get caller's return address */ \
        stwu r1,-FRAME(r1) XX /* create a stack frame to hold non-volatile registers */ \
        SAVE_LR(r0)

#define EPILOGUE \
	LOAD_LR(r0) XX \
        lwz r1,0(r1) XX    /* destroy the stack frame */ \
        mtlr r0            /* get ready to return */

DEF(void,c_to_factor,(CELL quot)):
        PROLOGUE

	SAVE(r13,0)        /* save GPRs */
                           /* don't save ds pointer */
                           /* don't save rs pointer */
        SAVE(r16,3)
        SAVE(r17,4)
        SAVE(r18,5)
        SAVE(r19,6)
        SAVE(r20,7)
        SAVE(r21,8)
        SAVE(r22,9)
        SAVE(r23,10)
        SAVE(r24,11)
        SAVE(r25,12)
        SAVE(r26,13)
        SAVE(r27,14)
        SAVE(r28,15)
        SAVE(r29,16)
        SAVE(r30,17)
        SAVE(r31,18)
	SAVE(r3,19)        /* save quotation since we're about to mangle it */

        mr r3,r1           /* pass call stack pointer as an argument */
	bl MANGLE(save_callstack_bottom)

	RESTORE(r3,19)     /* restore quotation */
        CALL_QUOT

        RESTORE(r31,18)    /* restore GPRs */
        RESTORE(r30,17)
        RESTORE(r29,16)
        RESTORE(r28,15)
        RESTORE(r27,14)
        RESTORE(r26,13)
        RESTORE(r25,12)
        RESTORE(r24,11)
        RESTORE(r23,10)
        RESTORE(r22,9)
        RESTORE(r21,8)
        RESTORE(r20,7)
        RESTORE(r19,6)
        RESTORE(r18,5)
        RESTORE(r17,4)
        RESTORE(r16,3)
                           /* don't restore rs pointer */
                           /* don't restore ds pointer */
        RESTORE(r13,0)

        EPILOGUE
        blr

/* The JIT compiles an 'mr r4,r1' in front of every primitive call, since a
word which was defined as a primitive will not change its definition for the
lifetime of the image -- adding new primitives requires a bootstrap. However,
an undefined word can certainly become defined,

DEFER: foo
...
: foo ... ;

And calls to non-primitives do not have this one-instruction prologue, so we
set the XT of undefined words to this symbol. */
DEF(void,undefined,(CELL word)):
	mr r4,r1
	b MANGLE(undefined_error)

DEF(void,dosym,(CELL word)):
	stwu r3,4(r14)     /* push word to stack */
	blr                /* return */

/* Here we have two entry points. The first one is taken when profiling is
enabled */
DEF(void,docol_profiling,(CELL word)):
        lwz r4,25(r3)      /* load profile-count slot */
        addi r4,r4,8       /* increment count */
        stw r4,25(r3)      /* store profile-count slot */
DEF(void,docol,(CELL word)):
        lwz r3,13(r3)      /* load word-def slot */
        JUMP_QUOT

/* We must pass the XT to the quotation in r11. */
DEF(void,primitive_call,(void)):
        lwz r3,0(r14)      /* load quotation from data stack */
        subi r14,r14,4     /* pop quotation from data stack */
        JUMP_QUOT

/* We must preserve r4 here in case we're calling a primitive */
DEF(void,primitive_execute,(void)):
        lwz r3,0(r14)      /* load word from data stack */
        lwz r11,29(r3)     /* load word-xt slot */
        mtctr r11          /* prepare to call XT with word in r3 */
        subi r14,r14,4     /* pop word from data stack */
        bctr               /* go */

#define SCAN_SAVE (RESERVED_SIZE + PARAM_SIZE + 4)

/* We pass a function pointer to memcpy in r6 to work around a Mac OS X ABI
limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
        sub r1,r3,r5       /* compute new stack pointer */
        mr r3,r1           /* start of destination of memcpy() */
	stwu r1,-64(r1)    /* setup fake stack frame for memcpy() */
	mtlr r6            /* prepare to call memcpy() */
        blrl               /* go */
	lwz r1,0(r1)       /* tear down fake stack frame */
        lwz r0,LR_SAVE(r1) /* we have restored the stack; load return address */
	                   /* load quotation scan pointer */
        lwz r5,SCAN_SAVE(r1)
        mtlr r0            /* prepare to return to restored callstack */
        blr                /* go */

DEF(void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mr r1,r4           /* compute new stack pointer */
	lwz r0,LR_SAVE(r1) /* we have rewound the stack; load return address */
	mtlr r0
	JUMP_QUOT          /* call the quotation */

DEF(void,lazy_jit_compile,(CELL quot)):
	mr r4,r1           /* save stack pointer */
	PROLOGUE
	bl MANGLE(jit_compile)
	EPILOGUE
        JUMP_QUOT          /* call the quotation */

/* Thanks to Joshua Grams for this code.

On PowerPC processors, we must flush the instruction cache manually
after writing to the code heap. */

DEF(void,flush_icache,(void *start, int len)):
        /* compute number of cache lines to flush */
        add r4,r4,r3
        clrrwi r3,r3,5     /* align addr to next lower cache line boundary */
        sub r4,r4,r3       /* then n_lines = (len + 0x1f) / 0x20 */
        addi r4,r4,0x1f
        srwi. r4,r4,5      /* note '.' suffix */
        beqlr              /* if n_lines == 0, just return. */
        mtctr r4           /* flush cache lines */
0:      dcbf 0,r3          /* for each line... */
        sync
        icbi 0,r3
        addi r3,r3,0x20
        bdnz 0b
        sync               /* finish up */
        isync
        blr
