	.cstring
LC0:
	.ascii "ffi_test_0()\0"
	.text
.globl _ffi_test_0
_ffi_test_0:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	L3
"L00000000001$pb":
L3:
	popl	%ebx
	leal	LC0-"L00000000001$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	addl	$20, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC1:
	.ascii "ffi_test_1()\0"
	.text
.globl _ffi_test_1
_ffi_test_1:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	L6
"L00000000002$pb":
L6:
	popl	%ebx
	leal	LC1-"L00000000002$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	movl	$3, %eax
	addl	$20, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC2:
	.ascii "ffi_test_2(%d,%d)\12\0"
	.text
.globl _ffi_test_2
_ffi_test_2:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	L9
"L00000000003$pb":
L9:
	popl	%ebx
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC2-"L00000000003$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	addl	8(%ebp), %eax
	addl	$20, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC3:
	.ascii "ffi_test_3(%d,%d,%d,%d)\12\0"
	.text
.globl _ffi_test_3
_ffi_test_3:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L12
"L00000000004$pb":
L12:
	popl	%ebx
	movl	20(%ebp), %eax
	movl	%eax, 16(%esp)
	movl	16(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC3-"L00000000004$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	movl	8(%ebp), %edx
	addl	%eax, %edx
	movl	16(%ebp), %eax
	imull	20(%ebp), %eax
	leal	(%edx,%eax), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC4:
	.ascii "ffi_test_4()\0"
	.literal4
	.align 2
LC5:
	.long	1069547520
	.text
.globl _ffi_test_4
_ffi_test_4:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L15
"L00000000005$pb":
L15:
	popl	%ebx
	leal	LC4-"L00000000005$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	LC5-"L00000000005$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, -12(%ebp)
	movss	-12(%ebp), %xmm0
	movss	%xmm0, -12(%ebp)
	flds	-12(%ebp)
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC6:
	.ascii "ffi_test_5()\0"
	.literal8
	.align 3
LC7:
	.long	0
	.long	1073217536
	.text
.globl _ffi_test_5
_ffi_test_5:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L18
"L00000000006$pb":
L18:
	popl	%ebx
	leal	LC6-"L00000000006$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	LC7-"L00000000006$pb"(%ebx), %eax
	movsd	(%eax), %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC8:
	.ascii "ffi_test_6(%f,%f)\12\0"
	.text
.globl _ffi_test_6
_ffi_test_6:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$52, %esp
	call	L21
"L00000000007$pb":
L21:
	popl	%ebx
	cvtss2sd	12(%ebp), %xmm0
	cvtss2sd	8(%ebp), %xmm1
	movsd	%xmm0, 12(%esp)
	movsd	%xmm1, 4(%esp)
	leal	LC8-"L00000000007$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movss	8(%ebp), %xmm0
	mulss	12(%ebp), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	addl	$52, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC9:
	.ascii "ffi_test_7(%f,%f)\12\0"
	.text
.globl _ffi_test_7
_ffi_test_7:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$68, %esp
	call	L24
"L00000000008$pb":
L24:
	popl	%ebx
	movl	8(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	12(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -24(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -20(%ebp)
	movsd	-24(%ebp), %xmm0
	movsd	%xmm0, 12(%esp)
	movsd	-16(%ebp), %xmm0
	movsd	%xmm0, 4(%esp)
	leal	LC9-"L00000000008$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movsd	-16(%ebp), %xmm0
	mulsd	-24(%ebp), %xmm0
	movsd	%xmm0, -32(%ebp)
	fldl	-32(%ebp)
	addl	$68, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC10:
	.ascii "ffi_test_8(%f,%f,%f,%f,%d)\12\0"
	.text
.globl _ffi_test_8
_ffi_test_8:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$84, %esp
	call	L27
"L00000000009$pb":
L27:
	popl	%ebx
	movl	8(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	12(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -24(%ebp)
	movl	24(%ebp), %eax
	movl	%eax, -20(%ebp)
	cvtss2sd	28(%ebp), %xmm0
	cvtss2sd	16(%ebp), %xmm1
	movl	32(%ebp), %eax
	movl	%eax, 36(%esp)
	movsd	%xmm0, 28(%esp)
	movsd	-24(%ebp), %xmm0
	movsd	%xmm0, 20(%esp)
	movsd	%xmm1, 12(%esp)
	movsd	-16(%ebp), %xmm0
	movsd	%xmm0, 4(%esp)
	leal	LC10-"L00000000009$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	cvtss2sd	16(%ebp), %xmm0
	movapd	%xmm0, %xmm1
	mulsd	-16(%ebp), %xmm1
	cvtss2sd	28(%ebp), %xmm0
	mulsd	-24(%ebp), %xmm0
	addsd	%xmm0, %xmm1
	cvtsi2sd	32(%ebp), %xmm0
	addsd	%xmm1, %xmm0
	movsd	%xmm0, -32(%ebp)
	fldl	-32(%ebp)
	addl	$84, %esp
	popl	%ebx
	leave
	ret
	.cstring
	.align 2
LC11:
	.ascii "ffi_test_9(%d,%d,%d,%d,%d,%d,%d)\12\0"
	.text
.globl _ffi_test_9
_ffi_test_9:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L30
"L00000000010$pb":
L30:
	popl	%ebx
	movl	32(%ebp), %eax
	movl	%eax, 28(%esp)
	movl	28(%ebp), %eax
	movl	%eax, 24(%esp)
	movl	24(%ebp), %eax
	movl	%eax, 20(%esp)
	movl	20(%ebp), %eax
	movl	%eax, 16(%esp)
	movl	16(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC11-"L00000000010$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	addl	8(%ebp), %eax
	addl	16(%ebp), %eax
	addl	20(%ebp), %eax
	addl	24(%ebp), %eax
	addl	28(%ebp), %eax
	addl	32(%ebp), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
	.align 2
LC12:
	.ascii "ffi_test_10(%d,%d,%f,%d,%f,%d,%d,%d)\12\0"
	.text
.globl _ffi_test_10
_ffi_test_10:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$68, %esp
	call	L33
"L00000000011$pb":
L33:
	popl	%ebx
	movl	16(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -12(%ebp)
	cvtss2sd	28(%ebp), %xmm0
	movl	40(%ebp), %eax
	movl	%eax, 40(%esp)
	movl	36(%ebp), %eax
	movl	%eax, 36(%esp)
	movl	32(%ebp), %eax
	movl	%eax, 32(%esp)
	movsd	%xmm0, 24(%esp)
	movl	24(%ebp), %eax
	movl	%eax, 20(%esp)
	movsd	-16(%ebp), %xmm0
	movsd	%xmm0, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC12-"L00000000011$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %edx
	movl	8(%ebp), %eax
	subl	%edx, %eax
	cvtsi2sd	%eax, %xmm0
	movapd	%xmm0, %xmm1
	subsd	-16(%ebp), %xmm1
	cvtsi2sd	24(%ebp), %xmm0
	subsd	%xmm0, %xmm1
	cvtss2sd	28(%ebp), %xmm0
	subsd	%xmm0, %xmm1
	cvtsi2sd	32(%ebp), %xmm0
	subsd	%xmm0, %xmm1
	cvtsi2sd	36(%ebp), %xmm0
	subsd	%xmm0, %xmm1
	cvtsi2sd	40(%ebp), %xmm0
	movapd	%xmm1, %xmm2
	subsd	%xmm0, %xmm2
	movapd	%xmm2, %xmm0
	cvttsd2si	%xmm0, %eax
	addl	$68, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC13:
	.ascii "ffi_test_11(%d,{%d,%d},%d)\12\0"
	.text
.globl _ffi_test_11
_ffi_test_11:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L36
"L00000000012$pb":
L36:
	popl	%ebx
	movl	16(%ebp), %edx
	movl	12(%ebp), %ecx
	movl	20(%ebp), %eax
	movl	%eax, 16(%esp)
	movl	%edx, 12(%esp)
	movl	%ecx, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC13-"L00000000012$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	movl	%eax, %edx
	imull	8(%ebp), %edx
	movl	16(%ebp), %eax
	imull	20(%ebp), %eax
	leal	(%edx,%eax), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
	.align 2
LC14:
	.ascii "ffi_test_12(%d,%d,{%f,%f,%f,%f},%d,%d,%d)\12\0"
	.text
.globl _ffi_test_12
_ffi_test_12:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$68, %esp
	call	L39
"L00000000013$pb":
L39:
	popl	%ebx
	movss	28(%ebp), %xmm0
	cvtss2sd	%xmm0, %xmm1
	movss	24(%ebp), %xmm0
	cvtss2sd	%xmm0, %xmm2
	movss	20(%ebp), %xmm0
	cvtss2sd	%xmm0, %xmm3
	movss	16(%ebp), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movl	40(%ebp), %eax
	movl	%eax, 52(%esp)
	movl	36(%ebp), %eax
	movl	%eax, 48(%esp)
	movl	32(%ebp), %eax
	movl	%eax, 44(%esp)
	movsd	%xmm1, 36(%esp)
	movsd	%xmm2, 28(%esp)
	movsd	%xmm3, 20(%esp)
	movsd	%xmm0, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC14-"L00000000013$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	addl	8(%ebp), %eax
	cvtsi2ss	%eax, %xmm1
	movss	16(%ebp), %xmm0
	addss	%xmm0, %xmm1
	movss	20(%ebp), %xmm0
	addss	%xmm0, %xmm1
	movss	24(%ebp), %xmm0
	addss	%xmm0, %xmm1
	movss	28(%ebp), %xmm0
	addss	%xmm0, %xmm1
	cvtsi2ss	32(%ebp), %xmm0
	addss	%xmm0, %xmm1
	cvtsi2ss	36(%ebp), %xmm0
	addss	%xmm0, %xmm1
	cvtsi2ss	40(%ebp), %xmm0
	addss	%xmm1, %xmm0
	cvttss2si	%xmm0, %eax
	addl	$68, %esp
	popl	%ebx
	leave
	ret
	.cstring
	.align 2
LC15:
	.ascii "ffi_test_13(%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d)\12\0"
	.text
.globl _ffi_test_13
_ffi_test_13:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$52, %esp
	call	L42
"L00000000014$pb":
L42:
	popl	%ebx
	movl	48(%ebp), %eax
	movl	%eax, 44(%esp)
	movl	44(%ebp), %eax
	movl	%eax, 40(%esp)
	movl	40(%ebp), %eax
	movl	%eax, 36(%esp)
	movl	36(%ebp), %eax
	movl	%eax, 32(%esp)
	movl	32(%ebp), %eax
	movl	%eax, 28(%esp)
	movl	28(%ebp), %eax
	movl	%eax, 24(%esp)
	movl	24(%ebp), %eax
	movl	%eax, 20(%esp)
	movl	20(%ebp), %eax
	movl	%eax, 16(%esp)
	movl	16(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC15-"L00000000014$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	addl	8(%ebp), %eax
	addl	16(%ebp), %eax
	addl	20(%ebp), %eax
	addl	24(%ebp), %eax
	addl	28(%ebp), %eax
	addl	32(%ebp), %eax
	addl	36(%ebp), %eax
	addl	40(%ebp), %eax
	addl	44(%ebp), %eax
	addl	48(%ebp), %eax
	addl	$52, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC16:
	.ascii "ffi_test_14(%d,%d)\12\0"
	.text
.globl _ffi_test_14
_ffi_test_14:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L45
"L00000000015$pb":
L45:
	popl	%ebx
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC16-"L00000000015$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	8(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	12(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-16(%ebp), %eax
	movl	-12(%ebp), %edx
	addl	$36, %esp
	popl	%ebx
	leave
	ret
	.cstring
LC17:
	.ascii "foo\0"
LC18:
	.ascii "bar\0"
	.text
.globl _ffi_test_15
_ffi_test_15:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L51
"L00000000016$pb":
L51:
	popl	%ebx
	movl	12(%ebp), %eax
	movl	%eax, 4(%esp)
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	L_strcmp$stub
	testl	%eax, %eax
	je	L47
	leal	LC17-"L00000000016$pb"(%ebx), %eax
	movl	%eax, -12(%ebp)
	jmp	L49
L47:
	leal	LC18-"L00000000016$pb"(%ebx), %eax
	movl	%eax, -12(%ebp)
L49:
	movl	-12(%ebp), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret
.globl _ffi_test_16
_ffi_test_16:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, -20(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-20(%ebp), %eax
	movl	%eax, (%edx)
	movl	-16(%ebp), %eax
	movl	%eax, 4(%edx)
	movl	-12(%ebp), %eax
	movl	%eax, 8(%edx)
	movl	%edx, %eax
	leave
	ret	$4
.globl _ffi_test_17
_ffi_test_17:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	leave
	ret
	.cstring
LC19:
	.ascii "ffi_test_18(%d,%d,%d,%d)\12\0"
	.text
.globl _ffi_test_18
_ffi_test_18:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$36, %esp
	call	L58
"L00000000017$pb":
L58:
	popl	%ebx
	movl	20(%ebp), %eax
	movl	%eax, 16(%esp)
	movl	16(%ebp), %eax
	movl	%eax, 12(%esp)
	movl	12(%ebp), %eax
	movl	%eax, 8(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC19-"L00000000017$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	12(%ebp), %eax
	movl	8(%ebp), %edx
	addl	%eax, %edx
	movl	16(%ebp), %eax
	imull	20(%ebp), %eax
	leal	(%edx,%eax), %eax
	addl	$36, %esp
	popl	%ebx
	leave
	ret	$16
.globl _ffi_test_19
_ffi_test_19:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	movl	%eax, -20(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-20(%ebp), %eax
	movl	%eax, (%edx)
	movl	-16(%ebp), %eax
	movl	%eax, 4(%edx)
	movl	-12(%ebp), %eax
	movl	%eax, 8(%edx)
	movl	%edx, %eax
	leave
	ret	$16
	.cstring
	.align 2
LC20:
	.ascii "ffi_test_20(%f,%f,%f,%f,%f,%f,%f,%f,%f)\12\0"
	.text
.globl _ffi_test_20
_ffi_test_20:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$164, %esp
	call	L63
"L00000000018$pb":
L63:
	popl	%ebx
	movl	8(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	12(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -24(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -20(%ebp)
	movl	24(%ebp), %eax
	movl	%eax, -32(%ebp)
	movl	28(%ebp), %eax
	movl	%eax, -28(%ebp)
	movl	32(%ebp), %eax
	movl	%eax, -40(%ebp)
	movl	36(%ebp), %eax
	movl	%eax, -36(%ebp)
	movl	40(%ebp), %eax
	movl	%eax, -48(%ebp)
	movl	44(%ebp), %eax
	movl	%eax, -44(%ebp)
	movl	48(%ebp), %eax
	movl	%eax, -56(%ebp)
	movl	52(%ebp), %eax
	movl	%eax, -52(%ebp)
	movl	56(%ebp), %eax
	movl	%eax, -64(%ebp)
	movl	60(%ebp), %eax
	movl	%eax, -60(%ebp)
	movl	64(%ebp), %eax
	movl	%eax, -72(%ebp)
	movl	68(%ebp), %eax
	movl	%eax, -68(%ebp)
	movl	72(%ebp), %eax
	movl	%eax, -80(%ebp)
	movl	76(%ebp), %eax
	movl	%eax, -76(%ebp)
	movsd	-80(%ebp), %xmm0
	movsd	%xmm0, 68(%esp)
	movsd	-72(%ebp), %xmm0
	movsd	%xmm0, 60(%esp)
	movsd	-64(%ebp), %xmm0
	movsd	%xmm0, 52(%esp)
	movsd	-56(%ebp), %xmm0
	movsd	%xmm0, 44(%esp)
	movsd	-48(%ebp), %xmm0
	movsd	%xmm0, 36(%esp)
	movsd	-40(%ebp), %xmm0
	movsd	%xmm0, 28(%esp)
	movsd	-32(%ebp), %xmm0
	movsd	%xmm0, 20(%esp)
	movsd	-24(%ebp), %xmm0
	movsd	%xmm0, 12(%esp)
	movsd	-16(%ebp), %xmm0
	movsd	%xmm0, 4(%esp)
	leal	LC20-"L00000000018$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	addl	$164, %esp
	popl	%ebx
	leave
	ret
.globl _ffi_test_21
_ffi_test_21:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$56, %esp
	movl	8(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	%eax, %edx
	sarl	$31, %edx
	movl	%edx, -12(%ebp)
	movl	12(%ebp), %eax
	movl	%eax, -48(%ebp)
	movl	%eax, %edx
	sarl	$31, %edx
	movl	%edx, -44(%ebp)
	movl	-16(%ebp), %eax
	mull	-48(%ebp)
	movl	%eax, -24(%ebp)
	movl	%edx, -20(%ebp)
	movl	-16(%ebp), %edx
	imull	-44(%ebp), %edx
	movl	%edx, -28(%ebp)
	movl	-20(%ebp), %ecx
	addl	-28(%ebp), %ecx
	movl	-48(%ebp), %eax
	imull	-12(%ebp), %eax
	addl	%eax, %ecx
	movl	%ecx, -20(%ebp)
	movl	-24(%ebp), %eax
	movl	-20(%ebp), %edx
	leave
	ret
	.cstring
LC21:
	.ascii "ffi_test_22(%ld,%lld,%lld)\12\0"
	.text
.globl _ffi_test_22
_ffi_test_22:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$52, %esp
	call	L68
"L00000000019$pb":
L68:
	popl	%ebx
	movl	12(%ebp), %eax
	movl	%eax, -16(%ebp)
	movl	16(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	20(%ebp), %eax
	movl	%eax, -24(%ebp)
	movl	24(%ebp), %eax
	movl	%eax, -20(%ebp)
	movl	-24(%ebp), %eax
	movl	-20(%ebp), %edx
	movl	%eax, 16(%esp)
	movl	%edx, 20(%esp)
	movl	-16(%ebp), %eax
	movl	-12(%ebp), %edx
	movl	%eax, 8(%esp)
	movl	%edx, 12(%esp)
	movl	8(%ebp), %eax
	movl	%eax, 4(%esp)
	leal	LC21-"L00000000019$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	movl	-24(%ebp), %eax
	movl	-20(%ebp), %edx
	movl	%eax, 8(%esp)
	movl	%edx, 12(%esp)
	movl	-16(%ebp), %eax
	movl	-12(%ebp), %edx
	movl	%eax, (%esp)
	movl	%edx, 4(%esp)
	call	L___divdi3$stub
	addl	8(%ebp), %eax
	addl	$52, %esp
	popl	%ebx
	leave
	ret
.globl _ffi_test_23
_ffi_test_23:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movss	(%eax), %xmm1
	movl	12(%ebp), %eax
	movss	(%eax), %xmm0
	movaps	%xmm1, %xmm2
	mulss	%xmm0, %xmm2
	movl	8(%ebp), %eax
	addl	$4, %eax
	movss	(%eax), %xmm1
	movl	12(%ebp), %eax
	addl	$4, %eax
	movss	(%eax), %xmm0
	mulss	%xmm1, %xmm0
	addss	%xmm0, %xmm2
	movl	8(%ebp), %eax
	addl	$8, %eax
	movss	(%eax), %xmm1
	movl	12(%ebp), %eax
	addl	$8, %eax
	movss	(%eax), %xmm0
	mulss	%xmm1, %xmm0
	addss	%xmm2, %xmm0
	movss	%xmm0, -12(%ebp)
	flds	-12(%ebp)
	leave
	ret
.globl _ffi_test_24
_ffi_test_24:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movb	$1, -9(%ebp)
	movzbl	-9(%ebp), %eax
	leave
	ret
.globl _ffi_test_25
_ffi_test_25:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movb	$1, -10(%ebp)
	movb	$2, -9(%ebp)
	movzwl	-10(%ebp), %eax
	leave
	ret
.globl _ffi_test_26
_ffi_test_26:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movb	$1, -11(%ebp)
	movb	$2, -10(%ebp)
	movb	$3, -9(%ebp)
	movzwl	-11(%ebp), %edx
	movw	%dx, (%eax)
	movzbl	-9(%ebp), %edx
	movb	%dl, 2(%eax)
	leave
	ret	$4
.globl _ffi_test_27
_ffi_test_27:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movb	$1, -12(%ebp)
	movb	$2, -11(%ebp)
	movb	$3, -10(%ebp)
	movb	$4, -9(%ebp)
	movl	-12(%ebp), %eax
	leave
	ret
.globl _ffi_test_28
_ffi_test_28:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movb	$1, -13(%ebp)
	movb	$2, -12(%ebp)
	movb	$3, -11(%ebp)
	movb	$4, -10(%ebp)
	movb	$5, -9(%ebp)
	movl	-13(%ebp), %edx
	movl	%edx, (%eax)
	movzbl	-9(%ebp), %edx
	movb	%dl, 4(%eax)
	leave
	ret	$4
.globl _ffi_test_29
_ffi_test_29:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %eax
	movb	$1, -14(%ebp)
	movb	$2, -13(%ebp)
	movb	$3, -12(%ebp)
	movb	$4, -11(%ebp)
	movb	$5, -10(%ebp)
	movb	$6, -9(%ebp)
	movl	-14(%ebp), %edx
	movl	%edx, (%eax)
	movzwl	-10(%ebp), %edx
	movw	%dx, 4(%eax)
	leave
	ret	$4
.globl _ffi_test_30
_ffi_test_30:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %edx
	movb	$1, -15(%ebp)
	movb	$2, -14(%ebp)
	movb	$3, -13(%ebp)
	movb	$4, -12(%ebp)
	movb	$5, -11(%ebp)
	movb	$6, -10(%ebp)
	movb	$7, -9(%ebp)
	movl	-15(%ebp), %eax
	movl	%eax, (%edx)
	movzwl	-11(%ebp), %eax
	movw	%ax, 4(%edx)
	movzbl	-9(%ebp), %eax
	movb	%al, 6(%edx)
	movl	%edx, %eax
	leave
	ret	$4
.globl _ffi_test_31
_ffi_test_31:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	leave
	ret
.globl _ffi_test_32
_ffi_test_32:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movsd	8(%ebp), %xmm1
	movsd	16(%ebp), %xmm0
	addsd	%xmm0, %xmm1
	cvtsi2sd	24(%ebp), %xmm0
	mulsd	%xmm1, %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	leave
	ret
.globl _ffi_test_33
_ffi_test_33:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movss	8(%ebp), %xmm1
	movss	12(%ebp), %xmm0
	addss	%xmm0, %xmm1
	cvtsi2ss	16(%ebp), %xmm0
	mulss	%xmm1, %xmm0
	cvtss2sd	%xmm0, %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	leave
	ret
.globl _ffi_test_34
_ffi_test_34:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movss	8(%ebp), %xmm1
	movl	12(%ebp), %eax
	cvtsi2ss	%eax, %xmm0
	addss	%xmm0, %xmm1
	cvtsi2ss	16(%ebp), %xmm0
	mulss	%xmm1, %xmm0
	cvtss2sd	%xmm0, %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	leave
	ret
.globl _ffi_test_35
_ffi_test_35:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	8(%ebp), %edx
	movl	12(%ebp), %eax
	leal	(%edx,%eax), %eax
	imull	16(%ebp), %eax
	cvtsi2sd	%eax, %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	leave
	ret
.globl _ffi_test_36
_ffi_test_36:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movsd	12(%ebp), %xmm0
	movsd	%xmm0, -16(%ebp)
	fldl	-16(%ebp)
	leave
	ret
.lcomm _global_var.12587,4,2
	.cstring
LC22:
	.ascii "ffi_test_37\0"
LC23:
	.ascii "global_var is %d\12\0"
	.text
.globl _ffi_test_37
_ffi_test_37:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	subl	$20, %esp
	call	L99
"L00000000020$pb":
L99:
	popl	%ebx
	leal	LC22-"L00000000020$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_puts$stub
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	(%eax), %edx
	movl	%edx, %eax
	addl	%eax, %eax
	leal	(%eax,%edx), %ecx
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	(%eax), %eax
	leal	(%eax,%eax), %edx
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%ecx, 8(%esp)
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	movl	8(%ebp), %eax
	call	*%eax
	movl	%eax, %edx
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	%edx, (%eax)
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	(%eax), %eax
	movl	%eax, 4(%esp)
	leal	LC23-"L00000000020$pb"(%ebx), %eax
	movl	%eax, (%esp)
	call	L_printf$stub
	leal	_global_var.12587-"L00000000020$pb"(%ebx), %eax
	movl	(%eax), %eax
	addl	$20, %esp
	popl	%ebx
	leave
	ret
.comm _our_exception_port,4,2
.comm _userenv,256,5
.comm _T,4,2
.comm _stack_chain,4,2
.comm _ds_size,4,2
.comm _rs_size,4,2
.comm _stage2,1,0
.comm _profiling_p,1,0
.comm _signal_number,4,2
.comm _signal_fault_addr,4,2
.comm _signal_callstack_top,4,2
.comm _secure_gc,1,0
.comm _data_heap,4,2
.comm _cards_offset,4,2
.comm _newspace,4,2
.comm _nursery,4,2
.comm _gc_time,8,3
.comm _nursery_collections,4,2
.comm _aging_collections,4,2
.comm _cards_scanned,4,2
.comm _performing_gc,1,0
.comm _collecting_gen,4,2
.comm _collecting_aging_again,1,0
.comm _last_code_heap_scan,4,2
.comm _growing_data_heap,1,0
.comm _old_data_heap,4,2
.comm _gc_jmp,72,5
.comm _heap_scan_ptr,4,2
.comm _gc_off,1,0
.comm _gc_locals_region,4,2
.comm _gc_locals,4,2
.comm _extra_roots_region,4,2
.comm _extra_roots,4,2
.comm _bignum_zero,4,2
.comm _bignum_pos_one,4,2
.comm _bignum_neg_one,4,2
.comm _code_heap,8,2
.comm _data_relocation_base,4,2
.comm _code_relocation_base,4,2
.comm _posix_argc,4,2
.comm _posix_argv,4,2
	.section __IMPORT,__jump_table,symbol_stubs,self_modifying_code+pure_instructions,5
L___divdi3$stub:
	.indirect_symbol ___divdi3
	hlt ; hlt ; hlt ; hlt ; hlt
L_printf$stub:
	.indirect_symbol _printf
	hlt ; hlt ; hlt ; hlt ; hlt
L_puts$stub:
	.indirect_symbol _puts
	hlt ; hlt ; hlt ; hlt ; hlt
L_strcmp$stub:
	.indirect_symbol _strcmp
	hlt ; hlt ; hlt ; hlt ; hlt
	.subsections_via_symbols
