/* Parts of this file were snarfed from SBCL src/runtime/ppc-assem.S, which is
in the public domain. */
#include "asm.h"

#define DS_REG r13

DEF(void,primitive_fixnum_add,(void)):
	lwz r3,0(DS_REG)
	lwz r4,-4(DS_REG)
	subi DS_REG,DS_REG,4
	li r0,0
	mtxer r0
	addo. r5,r3,r4
	bso add_overflow
	stw r5,0(DS_REG)
	blr
add_overflow:
	b MANGLE(overflow_fixnum_add)

DEF(void,primitive_fixnum_subtract,(void)):
	lwz r3,-4(DS_REG)
	lwz r4,0(DS_REG)
	subi DS_REG,DS_REG,4
	li r0,0
	mtxer r0
	subfo. r5,r4,r3
	bso sub_overflow
	stw r5,0(DS_REG)
	blr
sub_overflow:
	b MANGLE(overflow_fixnum_subtract)

DEF(void,primitive_fixnum_multiply,(void)):
	lwz r3,0(DS_REG)
	lwz r4,-4(DS_REG)
	subi DS_REG,DS_REG,4
	srawi r3,r3,3
	mullwo. r5,r3,r4
	bso multiply_overflow
	stw r5,0(DS_REG)
	blr
multiply_overflow:
	srawi r4,r4,3
	b MANGLE(overflow_fixnum_multiply)
	
/* Note that the XT is passed to the quotation in r11 */
#define CALL_OR_JUMP_QUOT \
	lwz r11,12(r3)	   /* load quotation-xt slot */ XX \

#define CALL_QUOT \
	CALL_OR_JUMP_QUOT XX \
	mtlr r11	   /* prepare to call XT with quotation in r3 */ XX \
	blrl		   /* go */

#define JUMP_QUOT \
	CALL_OR_JUMP_QUOT XX \
	mtctr r11	   /* prepare to call XT with quotation in r3 */ XX \
	bctr		   /* go */

#define PARAM_SIZE 32

#define SAVED_INT_REGS_SIZE 96

#define SAVED_FP_REGS_SIZE 144

#define FRAME (RESERVED_SIZE + PARAM_SIZE + SAVED_INT_REGS_SIZE + SAVED_FP_REGS_SIZE + 8)
   
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

#define SAVE_INT(register,offset) stw register,SAVE_AT(offset)(r1)
#define RESTORE_INT(register,offset) lwz register,SAVE_AT(offset)(r1)

#define SAVE_FP(register,offset) stfd register,SAVE_AT(offset)(r1)
#define RESTORE_FP(register,offset) lfd register,SAVE_AT(offset)(r1)

#define PROLOGUE \
	mflr r0 XX	   /* get caller's return address */ \
	stwu r1,-FRAME(r1) XX /* create a stack frame to hold non-volatile registers */ \
	SAVE_LR(r0)

#define EPILOGUE \
	LOAD_LR(r0) XX \
	lwz r1,0(r1) XX	   /* destroy the stack frame */ \
	mtlr r0		   /* get ready to return */

/* We have to save and restore nonvolatile registers because
the Factor compiler treats the entire register file as volatile. */
DEF(void,c_to_factor,(CELL quot)):
	PROLOGUE

	SAVE_INT(r15,0)	   /* save GPRs */
	SAVE_INT(r16,1)
	SAVE_INT(r17,2)
	SAVE_INT(r18,3)
	SAVE_INT(r19,4)
	SAVE_INT(r20,5)
	SAVE_INT(r21,6)
	SAVE_INT(r22,7)
	SAVE_INT(r23,8)
	SAVE_INT(r24,9)
	SAVE_INT(r25,10)
	SAVE_INT(r26,11)
	SAVE_INT(r27,12)
	SAVE_INT(r28,13)
	SAVE_INT(r29,14)
	SAVE_INT(r30,15)
	SAVE_INT(r31,16)

	SAVE_FP(f14,20)	/* save FPRs */
	SAVE_FP(f15,22)
	SAVE_FP(f16,24)
	SAVE_FP(f17,26)
	SAVE_FP(f18,28)
	SAVE_FP(f19,30)
	SAVE_FP(f20,32)
	SAVE_FP(f21,34)
	SAVE_FP(f22,36)
	SAVE_FP(f23,38)
	SAVE_FP(f24,40)
	SAVE_FP(f25,42)
	SAVE_FP(f26,44)
	SAVE_FP(f27,46)
	SAVE_FP(f28,48)
	SAVE_FP(f29,50)
	SAVE_FP(f30,52)
	SAVE_FP(f31,54)

	SAVE_INT(r3,19)	   /* save quotation since we're about to mangle it */

	mr r3,r1	   /* pass call stack pointer as an argument */
	bl MANGLE(save_callstack_bottom)

	RESTORE_INT(r3,19)	 /* restore quotation */
	CALL_QUOT

	RESTORE_FP(f31,54)
	RESTORE_FP(f30,52)
	RESTORE_FP(f29,50)
	RESTORE_FP(f28,48)
	RESTORE_FP(f27,46)
	RESTORE_FP(f26,44)
	RESTORE_FP(f25,42)
	RESTORE_FP(f24,40)
	RESTORE_FP(f23,38)
	RESTORE_FP(f22,36)
	RESTORE_FP(f21,34)
	RESTORE_FP(f20,32)
	RESTORE_FP(f19,30)
	RESTORE_FP(f18,28)
	RESTORE_FP(f17,26)
	RESTORE_FP(f16,24)
	RESTORE_FP(f15,22)
	RESTORE_FP(f14,20)	/* save FPRs */

	RESTORE_INT(r31,16)   /* restore GPRs */
	RESTORE_INT(r30,15)
	RESTORE_INT(r29,14)
	RESTORE_INT(r28,13)
	RESTORE_INT(r27,12)
	RESTORE_INT(r26,11)
	RESTORE_INT(r25,10)
	RESTORE_INT(r24,9)
	RESTORE_INT(r23,8)
	RESTORE_INT(r22,7)
	RESTORE_INT(r21,6)
	RESTORE_INT(r20,5)
	RESTORE_INT(r19,4)
	RESTORE_INT(r18,3)
	RESTORE_INT(r17,2)
	RESTORE_INT(r16,1)
	RESTORE_INT(r15,0)

	EPILOGUE
	blr

/* We pass a function pointer to memcpy in r6 to work around a Mac OS X ABI
limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	sub r1,r3,r5	   /* compute new stack pointer */
	mr r3,r1	   /* start of destination of memcpy() */
	stwu r1,-64(r1)	   /* setup fake stack frame for memcpy() */
	mtlr r6		   /* prepare to call memcpy() */
	blrl		   /* go */
	lwz r1,0(r1)	   /* tear down fake stack frame */
	lwz r0,LR_SAVE(r1) /* we have restored the stack; load return address */
	mtlr r0		   /* prepare to return to restored callstack */
	blr		   /* go */

DEF(void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mr r1,r4	   /* compute new stack pointer */
	lwz r0,LR_SAVE(r1) /* we have rewound the stack; load return address */
	mtlr r0
	JUMP_QUOT	   /* call the quotation */

DEF(void,lazy_jit_compile,(CELL quot)):
	mr r4,r1	   /* save stack pointer */
	PROLOGUE
	bl MANGLE(lazy_jit_compile_impl)
	EPILOGUE
	JUMP_QUOT	   /* call the quotation */

/* Thanks to Joshua Grams for this code.

On PowerPC processors, we must flush the instruction cache manually
after writing to the code heap. */

DEF(void,flush_icache,(void *start, int len)):
	/* compute number of cache lines to flush */
	add r4,r4,r3
	clrrwi r3,r3,5	   /* align addr to next lower cache line boundary */
	sub r4,r4,r3	   /* then n_lines = (len + 0x1f) / 0x20 */
	addi r4,r4,0x1f
	srwi. r4,r4,5	   /* note '.' suffix */
	beqlr		   /* if n_lines == 0, just return. */
	mtctr r4	   /* flush cache lines */
0:	dcbf 0,r3	   /* for each line... */
	sync
	icbi 0,r3
	addi r3,r3,0x20
	bdnz 0b
	sync		   /* finish up */
	isync
	blr

DEF(void,primitive_inline_cache_miss,(void)):
    mflr r6
DEF(void,primitive_inline_cache_miss_tail,(void)):
    PROLOGUE
    mr r3,r6
    bl MANGLE(inline_cache_miss)
    EPILOGUE
    mtctr r3
    bctr
