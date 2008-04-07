	.file	"run.c"
	.text
.globl _reset_datastack
	.def	_reset_datastack;	.scl	2;	.type	32;	.endef
_reset_datastack:
	pushl	%ebp
	movl	%esp, %ebp
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	(%eax), %esi
	subl	$4, %esi
	popl	%ebp
	ret
.globl _reset_retainstack
	.def	_reset_retainstack;	.scl	2;	.type	32;	.endef
_reset_retainstack:
	pushl	%ebp
	movl	%esp, %ebp
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	(%eax), %edi
	subl	$4, %edi
	popl	%ebp
	ret
.globl _fix_stacks
	.def	_fix_stacks;	.scl	2;	.type	32;	.endef
_fix_stacks:
	pushl	%ebp
	movl	%esp, %ebp
	leal	4(%esi), %eax
	movl	_stack_chain, %edx
	movl	24(%edx), %edx
	cmpl	(%edx), %eax
	jb	L5
	leal	256(%esi), %eax
	movl	_stack_chain, %edx
	movl	24(%edx), %edx
	cmpl	8(%edx), %eax
	jae	L5
	jmp	L4
L5:
	call	_reset_datastack
L4:
	leal	4(%edi), %eax
	movl	_stack_chain, %edx
	movl	28(%edx), %edx
	cmpl	(%edx), %eax
	jb	L7
	leal	256(%edi), %eax
	movl	_stack_chain, %edx
	movl	28(%edx), %edx
	cmpl	8(%edx), %eax
	jae	L7
	jmp	L3
L7:
	call	_reset_retainstack
L3:
	popl	%ebp
	ret
.globl _save_stacks
	.def	_save_stacks;	.scl	2;	.type	32;	.endef
_save_stacks:
	pushl	%ebp
	movl	%esp, %ebp
	cmpl	$0, _stack_chain
	je	L8
	movl	_stack_chain, %eax
	movl	%esi, 8(%eax)
	movl	_stack_chain, %eax
	movl	%edi, 12(%eax)
L8:
	popl	%ebp
	ret
.globl _nest_stacks
	.def	_nest_stacks;	.scl	2;	.type	32;	.endef
_nest_stacks:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	movl	$44, (%esp)
	call	_safe_malloc
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	movl	$-1, 4(%eax)
	movl	-8(%ebp), %eax
	movl	$-1, (%eax)
	movl	-8(%ebp), %eax
	movl	%esi, 16(%eax)
	movl	-8(%ebp), %eax
	movl	%edi, 20(%eax)
	movl	-8(%ebp), %edx
	movl	_userenv+8, %eax
	movl	%eax, 36(%edx)
	movl	-8(%ebp), %edx
	movl	_userenv+4, %eax
	movl	%eax, 32(%edx)
	movl	-8(%ebp), %ebx
	movl	_ds_size, %eax
	movl	%eax, (%esp)
	call	_alloc_segment
	movl	%eax, 24(%ebx)
	movl	-8(%ebp), %ebx
	movl	_rs_size, %eax
	movl	%eax, (%esp)
	call	_alloc_segment
	movl	%eax, 28(%ebx)
	movl	-8(%ebp), %edx
	movl	_stack_chain, %eax
	movl	%eax, 40(%edx)
	movl	-8(%ebp), %eax
	movl	%eax, _stack_chain
	call	_reset_datastack
	call	_reset_retainstack
	addl	$20, %esp
	popl	%ebx
	popl	%ebp
	ret
.globl _unnest_stacks
	.def	_unnest_stacks;	.scl	2;	.type	32;	.endef
_unnest_stacks:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	%eax, (%esp)
	call	_dealloc_segment
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	%eax, (%esp)
	call	_dealloc_segment
	movl	_stack_chain, %eax
	movl	16(%eax), %esi
	movl	_stack_chain, %eax
	movl	20(%eax), %edi
	movl	_stack_chain, %eax
	movl	36(%eax), %eax
	movl	%eax, _userenv+8
	movl	_stack_chain, %eax
	movl	32(%eax), %eax
	movl	%eax, _userenv+4
	movl	_stack_chain, %eax
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	40(%eax), %eax
	movl	%eax, _stack_chain
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_free
	leave
	ret
.globl _init_stacks
	.def	_init_stacks;	.scl	2;	.type	32;	.endef
_init_stacks:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	%eax, _ds_size
	movl	12(%ebp), %eax
	movl	%eax, _rs_size
	movl	$0, _stack_chain
	popl	%ebp
	ret
.globl _primitive_drop
	.def	_primitive_drop;	.scl	2;	.type	32;	.endef
_primitive_drop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_drop_impl
	leave
	ret
	.def	_primitive_drop_impl;	.scl	3;	.type	32;	.endef
_primitive_drop_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	leave
	ret
	.def	_dpop;	.scl	3;	.type	32;	.endef
_dpop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%esi, (%esp)
	call	_get
	movl	%eax, -4(%ebp)
	subl	$4, %esi
	movl	-4(%ebp), %eax
	leave
	ret
	.def	_get;	.scl	3;	.type	32;	.endef
_get:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	(%eax), %eax
	popl	%ebp
	ret
.globl _primitive_2drop
	.def	_primitive_2drop;	.scl	2;	.type	32;	.endef
_primitive_2drop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_2drop_impl
	leave
	ret
	.def	_primitive_2drop_impl;	.scl	3;	.type	32;	.endef
_primitive_2drop_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esi
	popl	%ebp
	ret
.globl _primitive_3drop
	.def	_primitive_3drop;	.scl	2;	.type	32;	.endef
_primitive_3drop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_3drop_impl
	leave
	ret
	.def	_primitive_3drop_impl;	.scl	3;	.type	32;	.endef
_primitive_3drop_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$12, %esi
	popl	%ebp
	ret
.globl _primitive_dup
	.def	_primitive_dup;	.scl	2;	.type	32;	.endef
_primitive_dup:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_dup_impl
	leave
	ret
	.def	_primitive_dup_impl;	.scl	3;	.type	32;	.endef
_primitive_dup_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpeek
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
	.def	_dpush;	.scl	3;	.type	32;	.endef
_dpush:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	addl	$4, %esi
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	leave
	ret
	.def	_put;	.scl	3;	.type	32;	.endef
_put:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, (%edx)
	popl	%ebp
	ret
	.def	_dpeek;	.scl	3;	.type	32;	.endef
_dpeek:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$4, %esp
	movl	%esi, (%esp)
	call	_get
	leave
	ret
.globl _primitive_2dup
	.def	_primitive_2dup;	.scl	2;	.type	32;	.endef
_primitive_2dup:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_2dup_impl
	leave
	ret
	.def	_primitive_2dup_impl;	.scl	3;	.type	32;	.endef
_primitive_2dup_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	addl	$8, %esi
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	leave
	ret
.globl _primitive_3dup
	.def	_primitive_3dup;	.scl	2;	.type	32;	.endef
_primitive_3dup:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_3dup_impl
	leave
	ret
	.def	_primitive_3dup_impl;	.scl	3;	.type	32;	.endef
_primitive_3dup_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$20, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -12(%ebp)
	addl	$12, %esi
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-12(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	leave
	ret
.globl _primitive_rot
	.def	_primitive_rot;	.scl	2;	.type	32;	.endef
_primitive_rot:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_rot_impl
	leave
	ret
	.def	_primitive_rot_impl;	.scl	3;	.type	32;	.endef
_primitive_rot_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$20, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	leave
	ret
.globl _primitive__rot
	.def	_primitive__rot;	.scl	2;	.type	32;	.endef
_primitive__rot:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive__rot_impl
	leave
	ret
	.def	_primitive__rot_impl;	.scl	3;	.type	32;	.endef
_primitive__rot_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$20, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -12(%ebp)
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-12(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	leave
	ret
.globl _primitive_dupd
	.def	_primitive_dupd;	.scl	2;	.type	32;	.endef
_primitive_dupd:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_dupd_impl
	leave
	ret
	.def	_primitive_dupd_impl;	.scl	3;	.type	32;	.endef
_primitive_dupd_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
.globl _primitive_swapd
	.def	_primitive_swapd;	.scl	2;	.type	32;	.endef
_primitive_swapd:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_swapd_impl
	leave
	ret
	.def	_primitive_swapd_impl;	.scl	3;	.type	32;	.endef
_primitive_swapd_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -4(%ebp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	leave
	ret
.globl _primitive_nip
	.def	_primitive_nip;	.scl	2;	.type	32;	.endef
_primitive_nip:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_nip_impl
	leave
	ret
	.def	_primitive_nip_impl;	.scl	3;	.type	32;	.endef
_primitive_nip_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_drepl
	leave
	ret
	.def	_drepl;	.scl	3;	.type	32;	.endef
_drepl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	leave
	ret
.globl _primitive_2nip
	.def	_primitive_2nip;	.scl	2;	.type	32;	.endef
_primitive_2nip:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_2nip_impl
	leave
	ret
	.def	_primitive_2nip_impl;	.scl	3;	.type	32;	.endef
_primitive_2nip_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	subl	$8, %esi
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_drepl
	leave
	ret
.globl _primitive_tuck
	.def	_primitive_tuck;	.scl	2;	.type	32;	.endef
_primitive_tuck:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_tuck_impl
	leave
	ret
	.def	_primitive_tuck_impl;	.scl	3;	.type	32;	.endef
_primitive_tuck_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
.globl _primitive_over
	.def	_primitive_over;	.scl	2;	.type	32;	.endef
_primitive_over:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_over_impl
	leave
	ret
	.def	_primitive_over_impl;	.scl	3;	.type	32;	.endef
_primitive_over_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
.globl _primitive_pick
	.def	_primitive_pick;	.scl	2;	.type	32;	.endef
_primitive_pick:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_pick_impl
	leave
	ret
	.def	_primitive_pick_impl;	.scl	3;	.type	32;	.endef
_primitive_pick_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	leal	-8(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
.globl _primitive_swap
	.def	_primitive_swap;	.scl	2;	.type	32;	.endef
_primitive_swap:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_swap_impl
	leave
	ret
	.def	_primitive_swap_impl;	.scl	3;	.type	32;	.endef
_primitive_swap_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	call	_dpeek
	movl	%eax, -4(%ebp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%esi, (%esp)
	call	_put
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	-4(%esi), %eax
	movl	%eax, (%esp)
	call	_put
	leave
	ret
.globl _primitive_to_r
	.def	_primitive_to_r;	.scl	2;	.type	32;	.endef
_primitive_to_r:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_to_r_impl
	leave
	ret
	.def	_primitive_to_r_impl;	.scl	3;	.type	32;	.endef
_primitive_to_r_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_rpush
	leave
	ret
	.def	_rpush;	.scl	3;	.type	32;	.endef
_rpush:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	addl	$4, %edi
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%edi, (%esp)
	call	_put
	leave
	ret
.globl _primitive_from_r
	.def	_primitive_from_r;	.scl	2;	.type	32;	.endef
_primitive_from_r:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_from_r_impl
	leave
	ret
	.def	_primitive_from_r_impl;	.scl	3;	.type	32;	.endef
_primitive_from_r_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_rpop
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
	.def	_rpop;	.scl	3;	.type	32;	.endef
_rpop:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%edi, (%esp)
	call	_get
	movl	%eax, -4(%ebp)
	subl	$4, %edi
	movl	-4(%ebp), %eax
	leave
	ret
.globl _stack_to_array
	.def	_stack_to_array;	.scl	2;	.type	32;	.endef
_stack_to_array:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	subl	%edx, %eax
	addl	$4, %eax
	movl	%eax, -4(%ebp)
	cmpl	$0, -4(%ebp)
	jns	L58
	movl	$0, -12(%ebp)
	jmp	L57
L58:
	movl	-4(%ebp), %eax
	movl	%eax, -16(%ebp)
	cmpl	$0, -16(%ebp)
	jns	L60
	addl	$3, -16(%ebp)
L60:
	movl	-16(%ebp), %eax
	sarl	$2, %eax
	movl	%eax, 4(%esp)
	movl	$8, (%esp)
	call	_allot_array_internal
	movl	%eax, -8(%ebp)
	movl	-4(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	-8(%ebp), %eax
	addl	$8, %eax
	movl	%eax, (%esp)
	call	_memcpy
	movl	-8(%ebp), %eax
	movl	%eax, (%esp)
	call	_tag_object
	movl	%eax, (%esp)
	call	_dpush
	movl	$1, -12(%ebp)
L57:
	movl	-12(%ebp), %eax
	leave
	ret
	.def	_tag_object;	.scl	3;	.type	32;	.endef
_tag_object:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	andl	$-8, %eax
	orl	$3, %eax
	popl	%ebp
	ret
.globl _primitive_datastack
	.def	_primitive_datastack;	.scl	2;	.type	32;	.endef
_primitive_datastack:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_datastack_impl
	leave
	ret
	.def	_primitive_datastack_impl;	.scl	3;	.type	32;	.endef
_primitive_datastack_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	%esi, 4(%esp)
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_stack_to_array
	testb	%al, %al
	jne	L63
	movl	$0, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$11, (%esp)
	call	_general_error
L63:
	leave
	ret
.globl _primitive_retainstack
	.def	_primitive_retainstack;	.scl	2;	.type	32;	.endef
_primitive_retainstack:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_retainstack_impl
	leave
	ret
	.def	_primitive_retainstack_impl;	.scl	3;	.type	32;	.endef
_primitive_retainstack_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	%edi, 4(%esp)
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, (%esp)
	call	_stack_to_array
	testb	%al, %al
	jne	L66
	movl	$0, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$13, (%esp)
	call	_general_error
L66:
	leave
	ret
.globl _array_to_stack
	.def	_array_to_stack;	.scl	2;	.type	32;	.endef
_array_to_stack:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_array_capacity
	sall	$2, %eax
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	addl	$8, %eax
	movl	%eax, 4(%esp)
	movl	12(%ebp), %eax
	movl	%eax, (%esp)
	call	_memcpy
	movl	-4(%ebp), %eax
	addl	12(%ebp), %eax
	subl	$4, %eax
	leave
	ret
	.def	_array_capacity;	.scl	3;	.type	32;	.endef
_array_capacity:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	movl	4(%eax), %eax
	shrl	$3, %eax
	popl	%ebp
	ret
.globl _primitive_set_datastack
	.def	_primitive_set_datastack;	.scl	2;	.type	32;	.endef
_primitive_set_datastack:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_set_datastack_impl
	leave
	ret
	.def	_primitive_set_datastack_impl;	.scl	3;	.type	32;	.endef
_primitive_set_datastack_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_untag_array
	movl	%eax, %edx
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	%edx, (%esp)
	call	_array_to_stack
	movl	%eax, %esi
	leave
	ret
	.def	_untag_array;	.scl	3;	.type	32;	.endef
_untag_array:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	$8, (%esp)
	call	_type_check
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_untag_object
	leave
	ret
	.def	_untag_object;	.scl	3;	.type	32;	.endef
_untag_object:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	andl	$-8, %eax
	popl	%ebp
	ret
	.def	_type_check;	.scl	3;	.type	32;	.endef
_type_check:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	12(%ebp), %eax
	movl	%eax, (%esp)
	call	_type_of
	cmpl	8(%ebp), %eax
	je	L74
	movl	12(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_type_error
L74:
	leave
	ret
	.def	_type_of;	.scl	3;	.type	32;	.endef
_type_of:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	andl	$7, %eax
	movl	%eax, -4(%ebp)
	cmpl	$3, -4(%ebp)
	jne	L77
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_object_type
	movl	%eax, -8(%ebp)
	jmp	L76
L77:
	movl	-4(%ebp), %eax
	movl	%eax, -8(%ebp)
L76:
	movl	-8(%ebp), %eax
	leave
	ret
	.def	_object_type;	.scl	3;	.type	32;	.endef
_object_type:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	8(%ebp), %eax
	andl	$-8, %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, (%esp)
	call	_untag_header
	leave
	ret
	.def	_untag_header;	.scl	3;	.type	32;	.endef
_untag_header:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	shrl	$3, %eax
	popl	%ebp
	ret
.globl _primitive_set_retainstack
	.def	_primitive_set_retainstack;	.scl	2;	.type	32;	.endef
_primitive_set_retainstack:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_set_retainstack_impl
	leave
	ret
	.def	_primitive_set_retainstack_impl;	.scl	3;	.type	32;	.endef
_primitive_set_retainstack_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_untag_array
	movl	%eax, %edx
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	%edx, (%esp)
	call	_array_to_stack
	movl	%eax, %edi
	leave
	ret
.globl _primitive_getenv
	.def	_primitive_getenv;	.scl	2;	.type	32;	.endef
_primitive_getenv:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_getenv_impl
	leave
	ret
	.def	_primitive_getenv_impl;	.scl	3;	.type	32;	.endef
_primitive_getenv_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpeek
	movl	%eax, (%esp)
	call	_untag_fixnum_fast
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	_userenv(,%eax,4), %eax
	movl	%eax, (%esp)
	call	_drepl
	leave
	ret
	.def	_untag_fixnum_fast;	.scl	3;	.type	32;	.endef
_untag_fixnum_fast:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	sarl	$3, %eax
	popl	%ebp
	ret
.globl _primitive_setenv
	.def	_primitive_setenv;	.scl	2;	.type	32;	.endef
_primitive_setenv:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_setenv_impl
	leave
	ret
	.def	_primitive_setenv_impl;	.scl	3;	.type	32;	.endef
_primitive_setenv_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_untag_fixnum_fast
	movl	%eax, -4(%ebp)
	call	_dpop
	movl	%eax, -8(%ebp)
	movl	-4(%ebp), %edx
	movl	-8(%ebp), %eax
	movl	%eax, _userenv(,%edx,4)
	leave
	ret
.globl _primitive_exit
	.def	_primitive_exit;	.scl	2;	.type	32;	.endef
_primitive_exit:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_exit_impl
	leave
	ret
	.def	_primitive_exit_impl;	.scl	3;	.type	32;	.endef
_primitive_exit_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_to_fixnum
	movl	%eax, (%esp)
	call	_exit
.globl _primitive_os_env
	.def	_primitive_os_env;	.scl	2;	.type	32;	.endef
_primitive_os_env:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_os_env_impl
	leave
	ret
	.def	_primitive_os_env_impl;	.scl	3;	.type	32;	.endef
_primitive_os_env_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_unbox_char_string
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	%eax, (%esp)
	call	_getenv
	movl	%eax, -8(%ebp)
	cmpl	$0, -8(%ebp)
	jne	L92
	movl	$7, (%esp)
	call	_dpush
	jmp	L91
L92:
	movl	-8(%ebp), %eax
	movl	%eax, (%esp)
	call	_box_char_string
L91:
	leave
	ret
.globl _primitive_eq
	.def	_primitive_eq;	.scl	2;	.type	32;	.endef
_primitive_eq:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_eq_impl
	leave
	ret
	.def	_primitive_eq_impl;	.scl	3;	.type	32;	.endef
_primitive_eq_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpop
	movl	%eax, -4(%ebp)
	call	_dpeek
	movl	%eax, -8(%ebp)
	movl	-4(%ebp), %eax
	cmpl	-8(%ebp), %eax
	jne	L96
	movl	_T, %eax
	movl	%eax, -12(%ebp)
	jmp	L97
L96:
	movl	$7, -12(%ebp)
L97:
	movl	-12(%ebp), %eax
	movl	%eax, (%esp)
	call	_drepl
	leave
	ret
.globl _primitive_millis
	.def	_primitive_millis;	.scl	2;	.type	32;	.endef
_primitive_millis:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_millis_impl
	leave
	ret
	.def	_primitive_millis_impl;	.scl	3;	.type	32;	.endef
_primitive_millis_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_current_millis
	movl	%eax, (%esp)
	movl	%edx, 4(%esp)
	call	_box_unsigned_8
	leave
	ret
.globl _primitive_sleep
	.def	_primitive_sleep;	.scl	2;	.type	32;	.endef
_primitive_sleep:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_sleep_impl
	leave
	ret
	.def	_primitive_sleep_impl;	.scl	3;	.type	32;	.endef
_primitive_sleep_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_to_cell
	movl	%eax, (%esp)
	call	_sleep_millis
	leave
	ret
.globl _primitive_tag
	.def	_primitive_tag;	.scl	2;	.type	32;	.endef
_primitive_tag:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_tag_impl
	leave
	ret
	.def	_primitive_tag_impl;	.scl	3;	.type	32;	.endef
_primitive_tag_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpeek
	andl	$7, %eax
	movl	%eax, (%esp)
	call	_tag_fixnum
	movl	%eax, (%esp)
	call	_drepl
	leave
	ret
	.def	_tag_fixnum;	.scl	3;	.type	32;	.endef
_tag_fixnum:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	sall	$3, %eax
	andl	$-8, %eax
	popl	%ebp
	ret
.globl _primitive_slot
	.def	_primitive_slot;	.scl	2;	.type	32;	.endef
_primitive_slot:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_slot_impl
	leave
	ret
	.def	_primitive_slot_impl;	.scl	3;	.type	32;	.endef
_primitive_slot_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_untag_fixnum_fast
	movl	%eax, -4(%ebp)
	call	_dpop
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %edx
	andl	$-8, %edx
	movl	-4(%ebp), %eax
	sall	$2, %eax
	leal	(%edx,%eax), %eax
	movl	%eax, (%esp)
	call	_get
	movl	%eax, (%esp)
	call	_dpush
	leave
	ret
.globl _primitive_set_slot
	.def	_primitive_set_slot;	.scl	2;	.type	32;	.endef
_primitive_set_slot:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_set_slot_impl
	leave
	ret
	.def	_primitive_set_slot_impl;	.scl	3;	.type	32;	.endef
_primitive_set_slot_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	_dpop
	movl	%eax, (%esp)
	call	_untag_fixnum_fast
	movl	%eax, -4(%ebp)
	call	_dpop
	movl	%eax, -8(%ebp)
	call	_dpop
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	-4(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	-8(%ebp), %eax
	movl	%eax, (%esp)
	call	_set_slot
	leave
	ret
	.def	_set_slot;	.scl	3;	.type	32;	.endef
_set_slot:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	16(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %edx
	andl	$-8, %edx
	movl	12(%ebp), %eax
	sall	$2, %eax
	leal	(%edx,%eax), %eax
	movl	%eax, (%esp)
	call	_put
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_write_barrier
	leave
	ret
	.def	_write_barrier;	.scl	3;	.type	32;	.endef
_write_barrier:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$4, %esp
	movl	8(%ebp), %eax
	shrl	$6, %eax
	addl	_cards_offset, %eax
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %edx
	movl	-4(%ebp), %eax
	movzbl	(%eax), %eax
	orb	$-64, %al
	movb	%al, (%edx)
	leave
	ret
	.comm	_console_open, 16	 # 1
	.comm	_userenv, 256	 # 256
	.comm	_T, 16	 # 4
	.comm	_stack_chain, 16	 # 4
	.comm	_ds_size, 16	 # 4
	.comm	_rs_size, 16	 # 4
	.comm	_stage2, 16	 # 1
	.comm	_profiling_p, 16	 # 1
	.comm	_signal_number, 16	 # 4
	.comm	_signal_fault_addr, 16	 # 4
	.comm	_signal_callstack_top, 16	 # 4
	.comm	_secure_gc, 16	 # 1
	.comm	_data_heap, 16	 # 4
	.comm	_cards_offset, 16	 # 4
	.comm	_newspace, 16	 # 4
	.comm	_nursery, 16	 # 4
	.comm	_gc_time, 16	 # 8
	.comm	_nursery_collections, 16	 # 4
	.comm	_aging_collections, 16	 # 4
	.comm	_cards_scanned, 16	 # 4
	.comm	_performing_gc, 16	 # 1
	.comm	_collecting_gen, 16	 # 4
	.comm	_collecting_aging_again, 16	 # 1
	.comm	_last_code_heap_scan, 16	 # 4
	.comm	_growing_data_heap, 16	 # 1
	.comm	_old_data_heap, 16	 # 4
	.comm	_gc_jmp, 208	 # 208
	.comm	_heap_scan_ptr, 16	 # 4
	.comm	_gc_off, 16	 # 1
	.comm	_gc_locals_region, 16	 # 4
	.comm	_gc_locals, 16	 # 4
	.comm	_extra_roots_region, 16	 # 4
	.comm	_extra_roots, 16	 # 4
	.comm	_bignum_zero, 16	 # 4
	.comm	_bignum_pos_one, 16	 # 4
	.comm	_bignum_neg_one, 16	 # 4
	.comm	_code_heap, 16	 # 8
	.comm	_data_relocation_base, 16	 # 4
	.comm	_code_relocation_base, 16	 # 4
	.comm	_posix_argc, 16	 # 4
	.comm	_posix_argv, 16	 # 4
	.def	_sleep_millis;	.scl	3;	.type	32;	.endef
	.def	_current_millis;	.scl	3;	.type	32;	.endef
	.def	_getenv;	.scl	3;	.type	32;	.endef
	.def	_exit;	.scl	3;	.type	32;	.endef
	.def	_general_error;	.scl	3;	.type	32;	.endef
	.def	_memcpy;	.scl	3;	.type	32;	.endef
	.def	_allot_array_internal;	.scl	3;	.type	32;	.endef
	.def	_save_callstack_top;	.scl	3;	.type	32;	.endef
	.def	_free;	.scl	3;	.type	32;	.endef
	.def	_dealloc_segment;	.scl	3;	.type	32;	.endef
	.def	_alloc_segment;	.scl	3;	.type	32;	.endef
	.def	_safe_malloc;	.scl	3;	.type	32;	.endef
	.def	_type_error;	.scl	3;	.type	32;	.endef
	.section .drectve

	.ascii " -export:nursery,data"
	.ascii " -export:cards_offset,data"
	.ascii " -export:stack_chain,data"
	.ascii " -export:userenv,data"
	.ascii " -export:unnest_stacks"
	.ascii " -export:nest_stacks"
	.ascii " -export:save_stacks"
