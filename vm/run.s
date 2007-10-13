	.file	"run.c"
	.text
	.align	0
	.global	reset_datastack
	.def	reset_datastack;	.scl	2;	.type	32;	.endef
reset_datastack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L3
	@ lr needed for prologue
	ldr	r2, [r3, #0]
	ldr	r1, [r2, #24]
	ldr	r3, [r1, #0]
	sub	r5, r3, #4
	mov	pc, lr
.L4:
	.align	0
.L3:
	.word	stack_chain
	.align	0
	.global	reset_retainstack
	.def	reset_retainstack;	.scl	2;	.type	32;	.endef
reset_retainstack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L7
	@ lr needed for prologue
	ldr	r2, [r3, #0]
	ldr	r1, [r2, #28]
	ldr	r3, [r1, #0]
	sub	r6, r3, #4
	mov	pc, lr
.L8:
	.align	0
.L7:
	.word	stack_chain
	.align	0
	.global	save_stacks
	.def	save_stacks;	.scl	2;	.type	32;	.endef
save_stacks:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L11
	@ lr needed for prologue
	ldr	r2, [r3, #0]
	str	r6, [r2, #12]
	str	r5, [r2, #8]
	mov	pc, lr
.L12:
	.align	0
.L11:
	.word	stack_chain
	.align	0
	.global	init_stacks
	.def	init_stacks;	.scl	2;	.type	32;	.endef
init_stacks:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L15
	ldr	r2, .L15+4
	str	r0, [r3, #0]
	ldr	r3, .L15+8
	str	r1, [r2, #0]
	mov	r1, #0
	@ lr needed for prologue
	str	r1, [r3, #0]
	mov	pc, lr
.L16:
	.align	0
.L15:
	.word	ds_size
	.word	rs_size
	.word	stack_chain
	.align	0
	.global	enable_word_profiling
	.def	enable_word_profiling;	.scl	2;	.type	32;	.endef
enable_word_profiling:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L21
	ldr	r2, [r0, #32]
	@ lr needed for prologue
	cmp	r2, r3
	ldreq	r3, .L21+4
	streq	r3, [r0, #32]
	mov	pc, lr
.L22:
	.align	0
.L21:
	.word	docol
	.word	docol_profiling
	.align	0
	.global	disable_word_profiling
	.def	disable_word_profiling;	.scl	2;	.type	32;	.endef
disable_word_profiling:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L27
	ldr	r2, [r0, #32]
	@ lr needed for prologue
	cmp	r2, r3
	ldreq	r3, .L27+4
	streq	r3, [r0, #32]
	mov	pc, lr
.L28:
	.align	0
.L27:
	.word	docol_profiling
	.word	docol
	.align	0
	.global	primitive_3drop
	.def	primitive_3drop;	.scl	2;	.type	32;	.endef
primitive_3drop:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	sub	r5, r5, #12
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_2drop
	.def	primitive_2drop;	.scl	2;	.type	32;	.endef
primitive_2drop:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	sub	r5, r5, #8
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_millis
	.def	primitive_millis;	.scl	2;	.type	32;	.endef
primitive_millis:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	bl	current_millis
	ldr	lr, [sp], #4
	b	box_unsigned_8
	.align	0
	.global	array_to_stack
	.def	array_to_stack;	.scl	2;	.type	32;	.endef
array_to_stack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r7, lr}
	ldr	r4, [r0, #4]
	mov	r7, r1
	mov	r4, r4, lsr #3
	mov	r4, r4, asl #2
	add	r1, r0, #8
	mov	r2, r4
	mov	r0, r7
	bl	memcpy
	add	r4, r4, r7
	sub	r0, r4, #4
	ldmfd	sp!, {r4, r7, pc}
	.align	0
	.global	unnest_stacks
	.def	unnest_stacks;	.scl	2;	.type	32;	.endef
unnest_stacks:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, lr}
	ldr	r4, .L39
	ldr	r3, [r4, #0]
	ldr	r0, [r3, #24]
	bl	dealloc_segment
	ldr	r3, [r4, #0]
	ldr	r0, [r3, #28]
	bl	dealloc_segment
	ldr	r0, [r4, #0]
	ldr	r1, .L39+4
	ldr	r2, [r0, #36]
	ldr	r5, [r0, #16]
	ldr	r6, [r0, #20]
	str	r2, [r1, #8]
	ldr	r3, [r0, #32]
	str	r3, [r1, #4]
	ldr	r2, [r0, #40]
	ldr	r1, [r0, #44]
	ldr	r3, .L39+8
	str	r1, [r4, #0]
	str	r2, [r3, #0]
	ldmfd	sp!, {r4, lr}
	b	free
.L40:
	.align	0
.L39:
	.word	stack_chain
	.word	userenv
	.word	extra_roots
	.align	0
	.global	primitive_drop
	.def	primitive_drop;	.scl	2;	.type	32;	.endef
primitive_drop:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	sub	r5, r5, #4
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_swapd
	.def	primitive_swapd;	.scl	2;	.type	32;	.endef
primitive_swapd:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r1, [r5, #-4]
	ldr	r2, [r5, #-8]
	stmdb	r5, {r1, r2}	@ phole stm
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_swap
	.def	primitive_swap;	.scl	2;	.type	32;	.endef
primitive_swap:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r1, [r5, #0]
	ldr	r2, [r5, #-4]
	stmda	r5, {r1, r2}	@ phole stm
	ldr	pc, [sp], #4
	.align	0
	.global	primitive__rot
	.def	primitive__rot;	.scl	2;	.type	32;	.endef
primitive__rot:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r0, [r5, #0]
	ldmdb	r5, {r1, r2}	@ phole ldm
	stmda	r5, {r0, r1, r2}	@ phole stm
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_rot
	.def	primitive_rot;	.scl	2;	.type	32;	.endef
primitive_rot:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r0, [r5, #0]
	ldr	r2, [r5, #-8]
	ldr	r1, [r5, #-4]
	stmda	r5, {r0, r2}	@ phole stm
	str	r1, [r5, #-8]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_3dup
	.def	primitive_3dup;	.scl	2;	.type	32;	.endef
primitive_3dup:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldmda	r5, {r0, r1, r2}	@ phole ldm
	mov	r3, r5
	add	r5, r5, #12
	str	r2, [r3, #12]
	stmdb	r5, {r0, r1}	@ phole stm
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_2dup
	.def	primitive_2dup;	.scl	2;	.type	32;	.endef
primitive_2dup:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r0, [r5, #0]
	ldr	r2, [r5, #-4]
	add	r1, r5, #8
	mov	r5, r1
	str	r2, [r5, #-4]
	str	r0, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_sleep
	.def	primitive_sleep;	.scl	2;	.type	32;	.endef
primitive_sleep:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r3, r5
	ldr	r0, [r3], #-4
	mov	r5, r3
	bl	to_cell
	ldr	lr, [sp], #4
	b	sleep_millis
	.align	0
	.global	primitive_exit
	.def	primitive_exit;	.scl	2;	.type	32;	.endef
primitive_exit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r3, r5
	ldr	r0, [r3], #-4
	mov	r5, r3
	bl	to_fixnum
	bl	exit
	.align	0
	.global	primitive_to_r
	.def	primitive_to_r;	.scl	2;	.type	32;	.endef
primitive_to_r:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r3, r5
	ldr	r1, [r3], #-4
	add	r2, r6, #4
	mov	r6, r2
	mov	r5, r3
	str	r1, [r6, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_eq
	.def	primitive_eq;	.scl	2;	.type	32;	.endef
primitive_eq:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r0, r5
	ldr	r1, [r5, #-4]
	ldr	r2, [r0], #-4
	mov	r3, #7
	cmp	r2, r1
	ldreq	r3, .L66
	mov	r5, r0
	ldreq	r3, [r3, #0]
	str	r3, [r0, #0]
	ldr	pc, [sp], #4
.L67:
	.align	0
.L66:
	.word	T
	.align	0
	.global	primitive_getenv
	.def	primitive_getenv;	.scl	2;	.type	32;	.endef
primitive_getenv:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r3, [r5, #0]
	ldr	r2, .L70
	mov	r3, r3, asr #3
	ldr	r1, [r2, r3, asl #2]
	str	r1, [r5, #0]
	ldr	pc, [sp], #4
.L71:
	.align	0
.L70:
	.word	userenv
	.align	0
	.global	primitive_2nip
	.def	primitive_2nip;	.scl	2;	.type	32;	.endef
primitive_2nip:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	ldr	r2, [r5, #0]
	mov	r3, r5
	sub	r5, r5, #8
	str	r2, [r3, #-8]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_nip
	.def	primitive_nip;	.scl	2;	.type	32;	.endef
primitive_nip:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r2, r5
	ldr	r1, [r2], #-4
	str	r1, [r5, #-4]
	mov	r5, r2
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_os_env
	.def	primitive_os_env;	.scl	2;	.type	32;	.endef
primitive_os_env:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	bl	unbox_char_string
	bl	getenv
	add	r3, r5, #4
	cmp	r0, #0
	moveq	r5, r3
	moveq	r3, #7
	streq	r3, [r5, #0]
	ldreq	pc, [sp], #4
	ldr	lr, [sp], #4
	b	box_char_string
	.align	0
	.global	stack_to_array
	.def	stack_to_array;	.scl	2;	.type	32;	.endef
stack_to_array:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r7, r8, lr}
	mov	r8, r0
	rsb	r1, r8, r1
	adds	r7, r1, #4
	mov	r0, #8
	mov	r1, r7, asr #2
	mov	r3, #0
	bmi	.L85
	bl	allot_array_internal
	mov	r1, r8
	mov	r4, r0
	mov	r2, r7
	add	r0, r0, #8
	bl	memcpy
	bic	r4, r4, #7
	add	r3, r5, #4
	mov	r5, r3
	orr	r4, r4, #3
	str	r4, [r5, #0]
	mov	r3, #1
.L85:
	mov	r0, r3
	ldmfd	sp!, {r4, r7, r8, pc}
	.align	0
	.global	primitive_from_r
	.def	primitive_from_r;	.scl	2;	.type	32;	.endef
primitive_from_r:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r3, r6
	ldr	r1, [r3], #-4
	add	r2, r5, #4
	mov	r5, r2
	mov	r6, r3
	str	r1, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_pick
	.def	primitive_pick;	.scl	2;	.type	32;	.endef
primitive_pick:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	ldr	r2, [r5, #-8]
	mov	r3, r5
	add	r5, r5, #4
	str	r2, [r3, #4]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_over
	.def	primitive_over;	.scl	2;	.type	32;	.endef
primitive_over:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	ldr	r2, [r5, #-4]
	mov	r3, r5
	add	r5, r5, #4
	str	r2, [r3, #4]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_tuck
	.def	primitive_tuck;	.scl	2;	.type	32;	.endef
primitive_tuck:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r0, [r5, #0]
	ldr	r2, [r5, #-4]
	add	r1, r5, #4
	mov	r3, r5
	mov	r5, r1
	stmda	r3, {r0, r2}	@ phole stm
	str	r0, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_dupd
	.def	primitive_dupd;	.scl	2;	.type	32;	.endef
primitive_dupd:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r0, [r5, #0]
	ldr	r2, [r5, #-4]
	add	r1, r5, #4
	mov	r3, r5
	mov	r5, r1
	str	r2, [r3, #0]
	str	r0, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_dup
	.def	primitive_dup;	.scl	2;	.type	32;	.endef
primitive_dup:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r2, r5
	ldr	r1, [r2], #4
	str	r1, [r5, #4]
	mov	r5, r2
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_set_slot
	.def	primitive_set_slot;	.scl	2;	.type	32;	.endef
primitive_set_slot:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r0, r5
	ldr	r1, [r0], #-4
	ldr	ip, [r5, #-4]
	ldr	lr, [r0, #-4]
	mov	r1, r1, asr #3
	bic	r3, ip, #7
	ldr	r2, .L101
	str	lr, [r3, r1, asl #2]
	ldr	r1, [r2, #0]
	sub	lr, r0, #4
	ldrb	r3, [r1, ip, lsr #6]	@ zero_extendqisi2
	mov	r5, r0
	mvn	r3, r3, asl #26
	mvn	r3, r3, lsr #26
	mov	r5, lr
	sub	r5, lr, #4
	strb	r3, [r1, ip, lsr #6]
	ldr	pc, [sp], #4
.L102:
	.align	0
.L101:
	.word	cards_offset
	.align	0
	.global	primitive_slot
	.def	primitive_slot;	.scl	2;	.type	32;	.endef
primitive_slot:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r1, r5
	ldr	r2, [r1], #-4
	ldr	r3, [r5, #-4]
	mov	r2, r2, asr #3
	bic	r3, r3, #7
	ldr	ip, [r3, r2, asl #2]
	mov	r0, r5
	mov	r5, r1
	sub	r5, r1, #4
	mov	r5, r1
	str	ip, [r0, #-4]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_setenv
	.def	primitive_setenv;	.scl	2;	.type	32;	.endef
primitive_setenv:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	mov	r1, r5
	ldr	r3, [r1], #-4
	ldr	r0, [r5, #-4]
	ldr	r2, .L107
	mov	r3, r3, asr #3
	mov	r5, r1
	sub	r5, r1, #4
	str	r0, [r2, r3, asl #2]
	ldr	pc, [sp], #4
.L108:
	.align	0
.L107:
	.word	userenv
	.align	0
	.global	primitive_class_hash
	.def	primitive_class_hash;	.scl	2;	.type	32;	.endef
primitive_class_hash:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r3, [r5, #0]
	and	r2, r3, #7
	cmp	r2, #2
	bic	r0, r3, #7
	beq	.L116
	cmp	r2, #3
	bic	r3, r3, #7
	ldreq	r3, [r3, #0]
	mov	r0, r2, asl #3
	streq	r3, [r5, #0]
	strne	r0, [r5, #0]
	ldr	pc, [sp], #4
.L116:
	ldr	r3, [r0, #8]
	bic	r3, r3, #7
	ldr	r2, [r3, #4]
	str	r2, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	primitive_tag
	.def	primitive_tag;	.scl	2;	.type	32;	.endef
primitive_tag:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	mov	r0, r1
	bl	save_callstack_top
	ldr	r3, [r5, #0]
	and	r3, r3, #7
	mov	r3, r3, asl #3
	str	r3, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	nest_stacks
	.def	nest_stacks;	.scl	2;	.type	32;	.endef
nest_stacks:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, lr}
	mov	r0, #48
	bl	safe_malloc
	mov	r4, r0
	ldr	r0, .L121
	str	r5, [r4, #16]
	str	r6, [r4, #20]
	ldr	r3, [r0, #8]
	mvn	r2, #0
	str	r3, [r4, #36]
	ldr	r1, [r0, #4]
	ldr	r3, .L121+4
	str	r1, [r4, #32]
	str	r2, [r4, #0]
	str	r2, [r4, #4]
	ldr	r0, [r3, #0]
	bl	alloc_segment
	ldr	r3, .L121+8
	str	r0, [r4, #24]
	ldr	r0, [r3, #0]
	bl	alloc_segment
	ldr	r3, .L121+12
	ldr	ip, [r4, #24]
	ldr	r2, [r3, #0]
	ldr	r1, .L121+16
	str	r2, [r4, #40]
	ldr	lr, [ip, #0]
	ldr	r2, [r0, #0]
	ldr	r3, [r1, #0]
	sub	r5, lr, #4
	sub	r6, r2, #4
	str	r3, [r4, #44]
	str	r0, [r4, #28]
	str	r4, [r1, #0]
	ldmfd	sp!, {r4, pc}
.L122:
	.align	0
.L121:
	.word	userenv
	.word	ds_size
	.word	rs_size
	.word	extra_roots
	.word	stack_chain
	.align	0
	.global	fix_stacks
	.def	fix_stacks;	.scl	2;	.type	32;	.endef
fix_stacks:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	ldr	r2, .L131
	add	r3, r5, #4
	ldr	r2, [r2, #0]
	stmfd	sp!, {r4, lr}
	ldr	r0, [r2, #24]
	add	r4, r6, #256
	ldr	ip, [r0, #0]
	add	lr, r5, #256
	cmp	r3, ip
	add	r1, r6, #4
	bcc	.L124
	ldr	r3, [r0, #8]
	cmp	lr, r3
	bcs	.L124
.L126:
	ldr	r2, [r2, #28]
	ldr	r0, [r2, #0]
	cmp	r1, r0
	bcc	.L127
	ldr	r3, [r2, #8]
	cmp	r4, r3
	ldmccfd	sp!, {r4, pc}
.L127:
	sub	r6, r0, #4
	ldmfd	sp!, {r4, pc}
.L124:
	sub	r5, ip, #4
	b	.L126
.L132:
	.align	0
.L131:
	.word	stack_chain
	.align	0
	.global	primitive_type
	.def	primitive_type;	.scl	2;	.type	32;	.endef
primitive_type:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	str	lr, [sp, #-4]!
	bl	save_callstack_top
	ldr	r3, [r5, #0]
	bic	r1, r3, #7
	and	r3, r3, #7
	cmp	r3, #3
	ldreq	r3, [r1, #0]
	moveq	r3, r3, lsr #3
	mov	r3, r3, asl #3
	str	r3, [r5, #0]
	ldr	pc, [sp], #4
	.align	0
	.global	default_word_xt
	.def	default_word_xt;	.scl	2;	.type	32;	.endef
default_word_xt:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	ldr	r3, .L154
	ldr	r0, [r0, #16]
	ldr	r2, [r3, #0]
	str	lr, [sp, #-4]!
	cmp	r0, r2
	ldreq	r0, .L154+4
	ldreq	pc, [sp], #4
	and	r1, r0, #7
	cmp	r1, #3
	biceq	r3, r0, #7
	ldreq	r2, [r3, #0]
	movne	r2, r1
	moveq	r2, r2, lsr #3
	cmp	r2, #14
	beq	.L153
	cmp	r1, #3
	biceq	r3, r0, #7
	ldreq	r2, [r3, #0]
	moveq	r1, r2, lsr #3
	cmp	r1, #0
	ldrne	r0, .L154+8
	ldrne	pc, [sp], #4
	bl	to_fixnum
	ldr	r3, .L154+12
	ldr	r0, [r3, r0, asl #2]
	ldr	pc, [sp], #4
.L153:
	ldr	r3, .L154+16
	ldr	r2, .L154+20
	ldrb	r1, [r3, #0]	@ zero_extendqisi2
	ldr	r3, .L154+24
	cmp	r1, #0
	moveq	r0, r2
	movne	r0, r3
	ldr	pc, [sp], #4
.L155:
	.align	0
.L154:
	.word	T
	.word	dosym
	.word	undefined
	.word	primitives
	.word	profiling
	.word	docol
	.word	docol_profiling
	.align	0
	.global	primitive_profiling
	.def	primitive_profiling;	.scl	2;	.type	32;	.endef
primitive_profiling:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r7, r8, lr}
	mov	r0, r1
	bl	save_callstack_top
	mov	r3, r5
	ldr	r0, [r3], #-4
	ldr	r4, .L175
	mov	r5, r3
	bl	to_boolean
	strb	r0, [r4, #0]
	bl	begin_scan
	ldr	r8, .L175+4
	ldr	r7, .L175+8
.L173:
	bl	next_object
	cmp	r0, #7
	bic	r2, r0, #7
	and	r3, r0, #7
	beq	.L174
.L158:
	cmp	r3, #3
	ldreq	r3, [r2, #0]
	moveq	r3, r3, lsr #3
	cmp	r3, #17
	bne	.L173
	ldrb	r3, [r4, #0]	@ zero_extendqisi2
	bic	r2, r0, #7
	cmp	r3, #0
	bic	r0, r0, #7
	beq	.L162
	ldr	r3, [r2, #32]
	cmp	r3, r8
	streq	r7, [r2, #32]
	bl	next_object
	cmp	r0, #7
	bic	r2, r0, #7
	and	r3, r0, #7
	bne	.L158
.L174:
	ldr	r3, .L175+12
	mov	r2, #0
	strb	r2, [r3, #0]
	ldmfd	sp!, {r4, r7, r8, pc}
.L162:
	ldr	r3, [r0, #32]
	cmp	r3, r7
	streq	r8, [r0, #32]
	b	.L173
.L176:
	.align	0
.L175:
	.word	profiling
	.word	docol
	.word	docol_profiling
	.word	gc_off
	.align	0
	.global	primitive_set_retainstack
	.def	primitive_set_retainstack;	.scl	2;	.type	32;	.endef
primitive_set_retainstack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	stmfd	sp!, {r4, r7, lr}
	bl	save_callstack_top
	mov	r3, r5
	ldr	r1, [r3], #-4
	mov	r0, #8
	and	r2, r1, #7
	cmp	r2, #3
	bic	r4, r1, #7
	mov	r5, r3
	ldreq	r3, [r4, #0]
	moveq	r2, r3, lsr #3
	cmp	r2, #8
	blne	type_error
.L181:
	ldr	r3, .L184
	ldr	r7, [r4, #4]
	ldr	r2, [r3, #0]
	add	r1, r4, #8
	ldr	r0, [r2, #28]
	mov	r7, r7, lsr #3
	ldr	r4, [r0, #0]
	mov	r7, r7, asl #2
	mov	r0, r4
	mov	r2, r7
	bl	memcpy
	add	r4, r4, r7
	sub	r6, r4, #4
	ldmfd	sp!, {r4, r7, pc}
.L185:
	.align	0
.L184:
	.word	stack_chain
	.align	0
	.global	primitive_set_datastack
	.def	primitive_set_datastack;	.scl	2;	.type	32;	.endef
primitive_set_datastack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	mov	r0, r1
	stmfd	sp!, {r4, r7, lr}
	bl	save_callstack_top
	mov	r3, r5
	ldr	r1, [r3], #-4
	mov	r0, #8
	and	r2, r1, #7
	cmp	r2, #3
	bic	r4, r1, #7
	mov	r5, r3
	ldreq	r3, [r4, #0]
	moveq	r2, r3, lsr #3
	cmp	r2, #8
	blne	type_error
.L190:
	ldr	r3, .L193
	ldr	r7, [r4, #4]
	ldr	r2, [r3, #0]
	add	r1, r4, #8
	ldr	r0, [r2, #24]
	mov	r7, r7, lsr #3
	ldr	r4, [r0, #0]
	mov	r7, r7, asl #2
	mov	r0, r4
	mov	r2, r7
	bl	memcpy
	add	r4, r4, r7
	sub	r5, r4, #4
	ldmfd	sp!, {r4, r7, pc}
.L194:
	.align	0
.L193:
	.word	stack_chain
	.align	0
	.global	primitive_retainstack
	.def	primitive_retainstack;	.scl	2;	.type	32;	.endef
primitive_retainstack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r7, r8, lr}
	mov	r0, r1
	bl	save_callstack_top
	ldr	ip, .L200
	mov	r1, #7
	ldr	lr, [ip, #0]
	mov	r0, #8
	ldr	r4, [lr, #28]
	mov	r2, r1
	ldr	r8, [r4, #0]
	mov	r3, #0
	rsb	ip, r8, r6
	adds	r7, ip, #4
	bmi	.L196
	mov	r1, r7, asr #2
	bl	allot_array_internal
	mov	r1, r8
	mov	r4, r0
	mov	r2, r7
	add	r0, r0, #8
	bl	memcpy
	bic	r4, r4, #7
	add	r3, r5, #4
	mov	r5, r3
	orr	r4, r4, #3
	str	r4, [r5, #0]
	ldmfd	sp!, {r4, r7, r8, pc}
.L196:
	mov	r0, #13
	ldmfd	sp!, {r4, r7, r8, lr}
	b	general_error
.L201:
	.align	0
.L200:
	.word	stack_chain
	.align	0
	.global	primitive_datastack
	.def	primitive_datastack;	.scl	2;	.type	32;	.endef
primitive_datastack:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r7, r8, lr}
	mov	r0, r1
	bl	save_callstack_top
	ldr	ip, .L207
	mov	r1, #7
	ldr	lr, [ip, #0]
	mov	r0, #8
	ldr	r4, [lr, #24]
	mov	r2, r1
	ldr	r8, [r4, #0]
	mov	r3, #0
	rsb	ip, r8, r5
	adds	r7, ip, #4
	bmi	.L203
	mov	r1, r7, asr #2
	bl	allot_array_internal
	mov	r1, r8
	mov	r4, r0
	mov	r2, r7
	add	r0, r0, #8
	bl	memcpy
	bic	r4, r4, #7
	add	r3, r5, #4
	mov	r5, r3
	orr	r4, r4, #3
	str	r4, [r5, #0]
	ldmfd	sp!, {r4, r7, r8, pc}
.L203:
	mov	r0, #11
	ldmfd	sp!, {r4, r7, r8, lr}
	b	general_error
.L208:
	.align	0
.L207:
	.word	stack_chain
	.comm	errno, 4	@ 4
	.comm	profiling, 4	@ 1
	.comm	userenv, 160	@ 160
	.comm	T, 4	@ 4
	.comm	stack_chain, 4	@ 4
	.comm	ds_size, 4	@ 4
	.comm	rs_size, 4	@ 4
	.comm	signal_number, 4	@ 4
	.comm	signal_fault_addr, 4	@ 4
	.comm	signal_callstack_top, 4	@ 4
	.comm	secure_gc, 4	@ 1
	.comm	data_heap, 4	@ 4
	.comm	cards_offset, 4	@ 4
	.comm	newspace, 4	@ 4
	.comm	nursery, 4	@ 4
	.comm	gc_time, 8	@ 8
	.comm	minor_collections, 4	@ 4
	.comm	cards_scanned, 4	@ 4
	.comm	performing_gc, 4	@ 1
	.comm	collecting_gen, 4	@ 4
	.comm	collecting_code, 4	@ 1
	.comm	collecting_aging_again, 4	@ 1
	.comm	last_code_heap_scan, 4	@ 4
	.comm	growing_data_heap, 4	@ 1
	.comm	old_data_heap, 4	@ 4
	.comm	gc_jmp, 44	@ 44
	.comm	heap_scan_ptr, 4	@ 4
	.comm	gc_off, 4	@ 1
	.comm	extra_roots_region, 4	@ 4
	.comm	extra_roots, 4	@ 4
	.comm	bignum_zero, 4	@ 4
	.comm	bignum_pos_one, 4	@ 4
	.comm	bignum_neg_one, 4	@ 4
	.comm	code_heap, 8	@ 8
	.comm	data_relocation_base, 4	@ 4
	.comm	code_relocation_base, 4	@ 4
	.comm	posix_argc, 4	@ 4
	.comm	posix_argv, 4	@ 4
	.def	memcpy;	.scl	2;	.type	32;	.endef
	.def	type_error;	.scl	2;	.type	32;	.endef
	.def	safe_malloc;	.scl	2;	.type	32;	.endef
	.def	alloc_segment;	.scl	2;	.type	32;	.endef
	.def	dealloc_segment;	.scl	2;	.type	32;	.endef
	.def	free;	.scl	2;	.type	32;	.endef
	.def	allot_array_internal;	.scl	2;	.type	32;	.endef
	.def	general_error;	.scl	2;	.type	32;	.endef
	.def	memcpy;	.scl	2;	.type	32;	.endef
	.def	dosym;	.scl	2;	.type	32;	.endef
	.def	undefined;	.scl	2;	.type	32;	.endef
	.def	exit;	.scl	2;	.type	32;	.endef
	.def	to_fixnum;	.scl	2;	.type	32;	.endef
	.def	unbox_char_string;	.scl	2;	.type	32;	.endef
	.def	getenv;	.scl	2;	.type	32;	.endef
	.def	box_char_string;	.scl	2;	.type	32;	.endef
	.def	box_unsigned_8;	.scl	2;	.type	32;	.endef
	.def	current_millis;	.scl	2;	.type	32;	.endef
	.def	sleep_millis;	.scl	2;	.type	32;	.endef
	.def	to_cell;	.scl	2;	.type	32;	.endef
	.def	docol_profiling;	.scl	2;	.type	32;	.endef
	.def	docol;	.scl	2;	.type	32;	.endef
	.def	save_callstack_top;	.scl	2;	.type	32;	.endef
	.def	to_boolean;	.scl	2;	.type	32;	.endef
	.def	begin_scan;	.scl	2;	.type	32;	.endef
	.def	next_object;	.scl	2;	.type	32;	.endef
	.section .drectve
	.ascii " -export:nursery,data"
	.ascii " -export:cards_offset,data"
	.ascii " -export:stack_chain,data"
	.ascii " -export:userenv,data"
	.ascii " -export:profiling,data"
	.ascii " -export:nest_stacks"
	.ascii " -export:unnest_stacks"
	.ascii " -export:save_stacks"
