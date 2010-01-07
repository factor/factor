/* Parts of this file were snarfed from SBCL src/runtime/ppc-assem.S, which is
in the public domain. */
#if defined(__APPLE__) || (defined(WINDOWS) && !defined(__arm__))
	#define MANGLE(sym) _##sym
#else
	#define MANGLE(sym) sym
#endif

/* Apple's PPC assembler is out of date? */
#if defined(__APPLE__) && defined(__ppc__)
	#define XX @
#else
	#define XX ;
#endif

/* The returns and args are just for documentation */
#define DEF(returns,symbol,args) .globl MANGLE(symbol) XX \
MANGLE(symbol)

#define DS_REG r13
#define RS_REG r14
#define VM_REG r15

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

#define SAVED_V_REGS_SIZE 208

#define FRAME (RESERVED_SIZE + PARAM_SIZE + SAVED_INT_REGS_SIZE + SAVED_FP_REGS_SIZE + SAVED_V_REGS_SIZE + 8)
   
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

#define SAVE_V(register,offset) \
	li r2,SAVE_AT(offset) XX \
	stvxl register,r2,r1

#define RESTORE_V(register,offset) \
	li r2,SAVE_AT(offset) XX \
	lvxl register,r2,r1

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
DEF(void,c_to_factor,(cell quot, void *vm)):
	PROLOGUE

	SAVE_INT(r13,0)
	SAVE_INT(r14,1)
	SAVE_INT(VM_REG,2)
	SAVE_INT(r16,3)
	SAVE_INT(r17,4)
	SAVE_INT(r18,5)
	SAVE_INT(r19,6)
	SAVE_INT(r20,7)
	SAVE_INT(r21,8)
	SAVE_INT(r22,9)
	SAVE_INT(r23,10)
	SAVE_INT(r24,11)
	SAVE_INT(r25,12)
	SAVE_INT(r26,13)
	SAVE_INT(r27,14)
	SAVE_INT(r28,15)
	SAVE_INT(r29,16)
	SAVE_INT(r30,17)
	SAVE_INT(r31,18)

	SAVE_FP(f14,20)
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

	SAVE_V(v20,56)
	SAVE_V(v21,60)
	SAVE_V(v22,64)
	SAVE_V(v23,68)
	SAVE_V(v24,72)
	SAVE_V(v25,76)
	SAVE_V(v26,80)
	SAVE_V(v27,84)
	SAVE_V(v28,88)
	SAVE_V(v29,92)
	SAVE_V(v30,96)
	SAVE_V(v31,100)

	/* r4 vm ptr preserved */
	mfvscr v0
	li r2,SAVE_AT(104)
	stvxl v0,r2,r1
	addi r2,r2,0xc
	lwzx r5,r2,r1
	lis r6,0x1
	andc r5,r5,r6
	stwx r5,r2,r1
	subi r2,r2,0xc
	lvxl v0,r2,r1
	mtvscr v0


	/* Load context */
	mr VM_REG,r4
	lwz r16,0(VM_REG)

	/* Load ctx->datastack */
	lwz DS_REG,8(r16)

	/* Load ctx->retainstack */
	lwz RS_REG,12(r16)

	/* Save ctx->callstack_bottom */
	stw r1,4(r16)

	CALL_QUOT

	/* Load context */
	lwz r16,0(VM_REG)

	/* Save ctx->datastack */
	stw DS_REG,8(r16)

	/* Save ctx->retainstack */
	stw RS_REG,12(r16)

	RESTORE_V(v0,104)
	mtvscr v0

	RESTORE_V(v31,100)
	RESTORE_V(v30,96)
	RESTORE_V(v29,92)
	RESTORE_V(v28,88)
	RESTORE_V(v27,84)
	RESTORE_V(v26,80)
	RESTORE_V(v25,76)
	RESTORE_V(v24,72)
	RESTORE_V(v23,68)
	RESTORE_V(v22,64)
	RESTORE_V(v21,60)
	RESTORE_V(v20,56)

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
	RESTORE_FP(f14,20)

	RESTORE_INT(r31,18)
	RESTORE_INT(r30,17)
	RESTORE_INT(r29,16)
	RESTORE_INT(r28,15)
	RESTORE_INT(r27,14)
	RESTORE_INT(r26,13)
	RESTORE_INT(r25,12)
	RESTORE_INT(r24,11)
	RESTORE_INT(r23,10)
	RESTORE_INT(r22,9)
	RESTORE_INT(r21,8)
	RESTORE_INT(r20,7)
	RESTORE_INT(r19,6)
	RESTORE_INT(r18,5)
	RESTORE_INT(r17,4)
	RESTORE_INT(r16,3)
	RESTORE_INT(VM_REG,2)
	RESTORE_INT(r14,1)
	RESTORE_INT(r13,0)

	EPILOGUE
	blr

DEF(void,set_callstack,(void *vm, stack_frame *to, stack_frame *from, cell length, void *memcpy)):
	/* Save VM pointer in non-volatile register */
	mr VM_REG,r3

    /* Compute new stack pointer */
	sub r1,r4,r6

	/* Call memcpy() */
	mr r3,r1
	mr r4,r5
	mr r5,r6
	stwu r1,-64(r1)
	mtlr r7
	blrl
	lwz r1,0(r1)

	/* Load context */
	lwz r16,0(VM_REG)

	/* Load ctx->datastack */
	lwz DS_REG,8(r16)

	/* Load ctx->retainstack */
	lwz RS_REG,12(r16)

	/* We have changed the stack; load return address again */
	lwz r0,LR_SAVE(r1)
	mtlr r0
	blr

DEF(void,throw_impl,(cell quot, void *new_stack, void *vm)):
	/* compute new stack pointer */
	mr r1,r4

	/* make vm ptr 2nd arg in case quot->xt == lazy_jit_compile */
	mr r4,r5

	/* Load context */
	mr VM_REG,r5
	lwz r16,0(VM_REG)

	/* Load ctx->datastack */
	lwz DS_REG,8(r16)

	/* Load ctx->retainstack */
	lwz RS_REG,12(r16)

	/* We have changed the stack; load return address again */
	lwz r0,LR_SAVE(r1)
	mtlr r0

	/* Call the quotation */
	JUMP_QUOT

DEF(void,lazy_jit_compile_impl,(cell quot, void *vm)):
	/* Load context */
	mr VM_REG,r4
	lwz r16,0(VM_REG)

	/* Save ctx->datastack */
	stw DS_REG,8(r16)

	/* Save ctx->retainstack */
	stw RS_REG,12(r16)

	/* Save ctx->callstack_top */
	stw r1,0(r16)

	/* Compile quotation */
	PROLOGUE
	bl MANGLE(lazy_jit_compile)
	EPILOGUE

	/* Call the quotation */
	JUMP_QUOT

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

DEF(void,get_ppc_fpu_env,(void*)):
	mffs f0
	stfd f0,0(r3)
	blr

DEF(void,set_ppc_fpu_env,(const void*)):
	lfd f0,0(r3)
	mtfsf 0xff,f0
	blr

DEF(void,get_ppc_vmx_env,(void*)):
	mfvscr v0
	subi r4,r1,16
	li r5,0xf
	andc r4,r4,r5
	stvxl v0,0,r4
	li r5,0xc
	lwzx r6,r5,r4
	stw r6,0(r3)
	blr

DEF(void,set_ppc_vmx_env,(const void*)):
	subi r4,r1,16
	li r5,0xf
	andc r4,r4,r5
	li r5,0xc
	lwz r6,0(r3)
	stwx r6,r5,r4
	lvxl v0,0,r4
	mtvscr v0
	blr
