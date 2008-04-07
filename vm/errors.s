	.file	"errors.c"
	.section .rdata,"dr"
LC0:
	.ascii "fatal_error: %s %lx\12\0"
	.text
.globl _fatal_error
	.def	_fatal_error;	.scl	2;	.type	32;	.endef
_fatal_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	___getreent
	movl	%eax, %edx
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	$LC0, 4(%esp)
	movl	12(%edx), %eax
	movl	%eax, (%esp)
	call	_fprintf
	movl	$1, (%esp)
	call	_exit
	.section .rdata,"dr"
	.align 4
LC1:
	.ascii "You have triggered a bug in Factor. Please report.\12\0"
LC2:
	.ascii "critical_error: %s %lx\12\0"
	.text
.globl _critical_error
	.def	_critical_error;	.scl	2;	.type	32;	.endef
_critical_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	call	___getreent
	movl	$LC1, 4(%esp)
	movl	12(%eax), %eax
	movl	%eax, (%esp)
	call	_fprintf
	call	___getreent
	movl	%eax, %edx
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	$LC2, 4(%esp)
	movl	12(%edx), %eax
	movl	%eax, (%esp)
	call	_fprintf
	call	_factorbug
	leave
	ret
	.section .rdata,"dr"
LC3:
	.ascii "early_error: \0"
LC4:
	.ascii "\12\0"
	.text
.globl _throw_error
	.def	_throw_error;	.scl	2;	.type	32;	.endef
_throw_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	cmpl	$7, _userenv+20
	je	L4
	movb	$0, _gc_off
	movl	_gc_locals_region, %eax
	movl	(%eax), %eax
	subl	$4, %eax
	movl	%eax, _gc_locals
	movl	_extra_roots_region, %eax
	movl	(%eax), %eax
	subl	$4, %eax
	movl	%eax, _extra_roots
	call	_fix_stacks
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_dpush
	cmpl	$0, 12(%ebp)
	je	L5
	movl	_stack_chain, %eax
	movl	4(%eax), %eax
	movl	%eax, 4(%esp)
	movl	12(%ebp), %eax
	movl	%eax, (%esp)
	call	_fix_callstack_top
	movl	%eax, 12(%ebp)
	jmp	L6
L5:
	movl	_stack_chain, %eax
	movl	(%eax), %eax
	movl	%eax, 12(%ebp)
L6:
	movl	12(%ebp), %edx
	movl	_userenv+20, %eax
	call	_throw_impl
	jmp	L3
L4:
	call	___getreent
	movl	$LC1, 4(%esp)
	movl	12(%eax), %eax
	movl	%eax, (%esp)
	call	_fprintf
	call	___getreent
	movl	$LC3, 4(%esp)
	movl	12(%eax), %eax
	movl	%eax, (%esp)
	call	_fprintf
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_print_obj
	call	___getreent
	movl	$LC4, 4(%esp)
	movl	12(%eax), %eax
	movl	%eax, (%esp)
	call	_fprintf
	call	_factorbug
L3:
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
.globl _general_error
	.def	_general_error;	.scl	2;	.type	32;	.endef
_general_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_tag_fixnum
	movl	%eax, %edx
	movl	16(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	%edx, 4(%esp)
	movl	_userenv+24, %eax
	movl	%eax, (%esp)
	call	_allot_array_4
	movl	%eax, %edx
	movl	20(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	%edx, (%esp)
	call	_throw_error
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
.globl _type_error
	.def	_type_error;	.scl	2;	.type	32;	.endef
_type_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_tag_fixnum
	movl	%eax, %edx
	movl	$0, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	%edx, 4(%esp)
	movl	$3, (%esp)
	call	_general_error
	leave
	ret
.globl _not_implemented_error
	.def	_not_implemented_error;	.scl	2;	.type	32;	.endef
_not_implemented_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	$0, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$2, (%esp)
	call	_general_error
	leave
	ret
.globl _in_page
	.def	_in_page;	.scl	2;	.type	32;	.endef
_in_page:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_getpagesize
	movl	%eax, -4(%ebp)
	movl	16(%ebp), %edx
	leal	12(%ebp), %eax
	addl	%edx, (%eax)
	movl	20(%ebp), %eax
	movl	%eax, %edx
	imull	-4(%ebp), %edx
	leal	12(%ebp), %eax
	addl	%edx, (%eax)
	movb	$0, -5(%ebp)
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	jb	L15
	movl	-4(%ebp), %eax
	addl	12(%ebp), %eax
	cmpl	8(%ebp), %eax
	jb	L15
	movb	$1, -5(%ebp)
L15:
	movzbl	-5(%ebp), %eax
	leave
	ret
	.section .rdata,"dr"
	.align 4
LC5:
	.ascii "allot_object() missed GC check\0"
LC6:
	.ascii "gc locals underflow\0"
LC7:
	.ascii "gc locals overflow\0"
LC8:
	.ascii "extra roots underflow\0"
LC9:
	.ascii "extra roots overflow\0"
	.text
.globl _memory_protection_error
	.def	_memory_protection_error;	.scl	2;	.type	32;	.endef
_memory_protection_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	$-1, 12(%esp)
	movl	$0, 8(%esp)
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L17
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$11, (%esp)
	call	_general_error
	jmp	L16
L17:
	movl	$0, 12(%esp)
	movl	_ds_size, %eax
	movl	%eax, 8(%esp)
	movl	_stack_chain, %eax
	movl	24(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L19
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$12, (%esp)
	call	_general_error
	jmp	L16
L19:
	movl	$-1, 12(%esp)
	movl	$0, 8(%esp)
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L21
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$13, (%esp)
	call	_general_error
	jmp	L16
L21:
	movl	$0, 12(%esp)
	movl	_rs_size, %eax
	movl	%eax, 8(%esp)
	movl	_stack_chain, %eax
	movl	28(%eax), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L23
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$14, (%esp)
	call	_general_error
	jmp	L16
L23:
	movl	$0, 12(%esp)
	movl	$0, 8(%esp)
	movl	_nursery, %eax
	movl	12(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L25
	movl	$0, 4(%esp)
	movl	$LC5, (%esp)
	call	_critical_error
	jmp	L16
L25:
	movl	$-1, 12(%esp)
	movl	$0, 8(%esp)
	movl	_gc_locals_region, %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L27
	movl	$0, 4(%esp)
	movl	$LC6, (%esp)
	call	_critical_error
	jmp	L16
L27:
	movl	$0, 12(%esp)
	movl	$0, 8(%esp)
	movl	_gc_locals_region, %eax
	movl	8(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L29
	movl	$0, 4(%esp)
	movl	$LC7, (%esp)
	call	_critical_error
	jmp	L16
L29:
	movl	$-1, 12(%esp)
	movl	$0, 8(%esp)
	movl	_extra_roots_region, %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L31
	movl	$0, 4(%esp)
	movl	$LC8, (%esp)
	call	_critical_error
	jmp	L16
L31:
	movl	$0, 12(%esp)
	movl	$0, 8(%esp)
	movl	_extra_roots_region, %eax
	movl	8(%eax), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_in_page
	testb	%al, %al
	je	L33
	movl	$0, 4(%esp)
	movl	$LC9, (%esp)
	call	_critical_error
	jmp	L16
L33:
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_allot_cell
	movl	%eax, %edx
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	%edx, 4(%esp)
	movl	$15, (%esp)
	call	_general_error
L16:
	leave
	ret
	.def	_allot_cell;	.scl	3;	.type	32;	.endef
_allot_cell:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	cmpl	$268435455, 8(%ebp)
	jbe	L36
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_cell_to_bignum
	movl	%eax, (%esp)
	call	_tag_bignum
	movl	%eax, -4(%ebp)
	jmp	L35
L36:
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_tag_fixnum
	movl	%eax, -4(%ebp)
L35:
	movl	-4(%ebp), %eax
	leave
	ret
	.def	_tag_bignum;	.scl	3;	.type	32;	.endef
_tag_bignum:
	pushl	%ebp
	movl	%esp, %ebp
	movl	8(%ebp), %eax
	andl	$-8, %eax
	orl	$1, %eax
	popl	%ebp
	ret
.globl _signal_error
	.def	_signal_error;	.scl	2;	.type	32;	.endef
_signal_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_tag_fixnum
	movl	%eax, %edx
	movl	12(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	%edx, 4(%esp)
	movl	$5, (%esp)
	call	_general_error
	leave
	ret
.globl _divide_by_zero_error
	.def	_divide_by_zero_error;	.scl	2;	.type	32;	.endef
_divide_by_zero_error:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	$7, 8(%esp)
	movl	$7, 4(%esp)
	movl	$4, (%esp)
	call	_general_error
	leave
	ret
.globl _memory_signal_handler_impl
	.def	_memory_signal_handler_impl;	.scl	2;	.type	32;	.endef
_memory_signal_handler_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	_signal_callstack_top, %eax
	movl	%eax, 4(%esp)
	movl	_signal_fault_addr, %eax
	movl	%eax, (%esp)
	call	_memory_protection_error
	leave
	ret
.globl _divide_by_zero_signal_handler_impl
	.def	_divide_by_zero_signal_handler_impl;	.scl	2;	.type	32;	.endef
_divide_by_zero_signal_handler_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	_signal_callstack_top, %eax
	movl	%eax, (%esp)
	call	_divide_by_zero_error
	leave
	ret
.globl _misc_signal_handler_impl
	.def	_misc_signal_handler_impl;	.scl	2;	.type	32;	.endef
_misc_signal_handler_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	_signal_callstack_top, %eax
	movl	%eax, 4(%esp)
	movl	_signal_number, %eax
	movl	%eax, (%esp)
	call	_signal_error
	leave
	ret
.globl _primitive_throw
	.def	_primitive_throw;	.scl	2;	.type	32;	.endef
_primitive_throw:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_throw_impl
	leave
	ret
	.def	_primitive_throw_impl;	.scl	3;	.type	32;	.endef
_primitive_throw_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	call	_dpop
	movl	%eax, %ecx
	movl	_stack_chain, %eax
	movl	(%eax), %edx
	movl	%ecx, %eax
	call	_throw_impl
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
.globl _primitive_call_clear
	.def	_primitive_call_clear;	.scl	2;	.type	32;	.endef
_primitive_call_clear:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_call_clear_impl
	leave
	ret
	.def	_primitive_call_clear_impl;	.scl	3;	.type	32;	.endef
_primitive_call_clear_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_dpop
	movl	_stack_chain, %edx
	movl	4(%edx), %edx
	call	_throw_impl
	leave
	ret
.globl _primitive_unimplemented2
	.def	_primitive_unimplemented2;	.scl	2;	.type	32;	.endef
_primitive_unimplemented2:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	call	_not_implemented_error
	leave
	ret
.globl _primitive_unimplemented
	.def	_primitive_unimplemented;	.scl	2;	.type	32;	.endef
_primitive_unimplemented:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	movl	%eax, -4(%ebp)
	movl	%edx, -8(%ebp)
	movl	-8(%ebp), %eax
	call	_save_callstack_top
	call	_primitive_unimplemented_impl
	leave
	ret
	.def	_primitive_unimplemented_impl;	.scl	3;	.type	32;	.endef
_primitive_unimplemented_impl:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	call	_not_implemented_error
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
	.def	_save_callstack_top;	.scl	3;	.type	32;	.endef
	.def	_getpagesize;	.scl	3;	.type	32;	.endef
	.def	_allot_array_4;	.scl	3;	.type	32;	.endef
	.def	_print_obj;	.scl	3;	.type	32;	.endef
	.def	_throw_impl;	.scl	3;	.type	32;	.endef
	.def	_fix_callstack_top;	.scl	3;	.type	32;	.endef
	.def	_fix_stacks;	.scl	3;	.type	32;	.endef
	.def	_factorbug;	.scl	3;	.type	32;	.endef
	.def	_exit;	.scl	3;	.type	32;	.endef
	.def	___getreent;	.scl	3;	.type	32;	.endef
	.def	_fprintf;	.scl	3;	.type	32;	.endef
	.def	_critical_error;	.scl	3;	.type	32;	.endef
	.def	_type_error;	.scl	3;	.type	32;	.endef
	.section .drectve

	.ascii " -export:nursery,data"
	.ascii " -export:cards_offset,data"
	.ascii " -export:stack_chain,data"
	.ascii " -export:userenv,data"
