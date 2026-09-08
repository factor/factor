	.build_version macos, 26, 0	sdk_version 26, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_abi_narrow                     ; -- Begin function abi_narrow
	.p2align	2
_abi_narrow:                            ; @abi_narrow
	.cfi_startproc
; %bb.0:
	ldrh	w8, [sp, #4]
	ldrsh	w9, [sp, #2]
	ldrb	w10, [sp, #1]
	ldrsb	w11, [sp]
	scvtf	d0, x0
	scvtf	d1, x1
	fadd	d1, d1, d1
	fadd	d0, d1, d0
	scvtf	d1, x2
	fmov	d2, #3.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, x3
	fmov	d2, #4.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, x4
	fmov	d2, #5.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, x5
	fmov	d2, #6.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, x6
	fmov	d2, #7.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, x7
	fmov	d2, #8.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, w11
	fmov	d2, #9.00000000
	fmadd	d0, d1, d2, d0
	ucvtf	d1, w10
	fmov	d2, #10.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, w9
	fmov	d2, #11.00000000
	fmadd	d0, d1, d2, d0
	ucvtf	d1, w8
	fmov	d2, #12.00000000
	fmadd	d0, d1, d2, d0
	ldp	s1, s2, [sp, #8]
	sshll.2d	v1, v1, #0
	scvtf	d1, d1
	fmov	d3, #13.00000000
	fmadd	d0, d1, d3, d0
	ucvtf	d1, d2
	fmov	d2, #14.00000000
	fmadd	d0, d1, d2, d0
	ldr	d1, [sp, #16]
	scvtf	d1, d1
	fmov	d2, #15.00000000
	fmadd	d0, d1, d2, d0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_narrow                    ; -- Begin function call_narrow
	.p2align	2
_call_narrow:                           ; @call_narrow
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	mov	x9, #-52501                     ; =0xffffffffffff32eb
	movk	x9, #63652, lsl #16
	mov	x10, #61072                     ; =0xee90
	movk	x10, #65534, lsl #16
	movk	x10, #24064, lsl #32
	movk	x10, #45776, lsl #48
	mov	w11, #65236                     ; =0xfed4
	movk	w11, #60000, lsl #16
	mov	w12, #64247                     ; =0xfaf7
	stp	x10, x9, [sp, #8]
	stur	w11, [sp, #2]
	strh	w12, [sp]
	mov	w0, #1                          ; =0x1
	mov	w1, #2                          ; =0x2
	mov	w2, #3                          ; =0x3
	mov	w3, #4                          ; =0x4
	mov	w4, #5                          ; =0x5
	mov	w5, #6                          ; =0x6
	mov	w6, #7                          ; =0x7
	mov	w7, #8                          ; =0x8
	blr	x8
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_floats                     ; -- Begin function abi_floats
	.p2align	2
_abi_floats:                            ; @abi_floats
	.cfi_startproc
; %bb.0:
	ldp	s17, s16, [sp, #4]
	ldr	s18, [sp]
	fcvt	d0, s0
	fcvt	d1, s1
	fadd	d1, d1, d1
	fadd	d0, d1, d0
	fcvt	d1, s2
	fmov	d2, #3.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s3
	fmov	d2, #4.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s4
	fmov	d2, #5.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s5
	fmov	d2, #6.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s6
	fmov	d2, #7.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s7
	fmov	d2, #8.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s18
	fmov	d2, #9.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s17
	fmov	d2, #10.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s16
	fmov	d2, #11.00000000
	fmadd	d0, d1, d2, d0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_floats                    ; -- Begin function call_floats
	.p2align	2
_call_floats:                           ; @call_floats
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #1093664768                 ; =0x41300000
	str	w8, [sp, #8]
	mov	x8, #1091567616                 ; =0x41100000
	movk	x8, #16672, lsl #48
	str	x8, [sp]
	fmov	s0, #1.00000000
	fmov	s1, #2.00000000
	fmov	s2, #3.00000000
	fmov	s3, #4.00000000
	fmov	s4, #5.00000000
	fmov	s5, #6.00000000
	fmov	s6, #7.00000000
	fmov	s7, #8.00000000
	blr	x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_mixed                      ; -- Begin function abi_mixed
	.p2align	2
_abi_mixed:                             ; @abi_mixed
	.cfi_startproc
; %bb.0:
	ldr	d16, [sp, #16]
	ldrsh	w8, [sp, #8]
	ldr	s17, [sp, #4]
	scvtf	d18, x0
	scvtf	d19, x1
	fadd	d19, d19, d19
	fadd	d18, d19, d18
	scvtf	d19, x2
	fmov	d20, #3.00000000
	fmadd	d18, d19, d20, d18
	scvtf	d19, x3
	fmov	d20, #4.00000000
	fmadd	d18, d19, d20, d18
	scvtf	d19, x4
	fmov	d20, #5.00000000
	fmadd	d18, d19, d20, d18
	scvtf	d19, x5
	ldrsb	w9, [sp]
	fmov	d20, #6.00000000
	fmadd	d18, d19, d20, d18
	scvtf	d19, x6
	fmov	d20, #7.00000000
	fmadd	d18, d19, d20, d18
	scvtf	d19, x7
	fmov	d20, #8.00000000
	fmadd	d18, d19, d20, d18
	fcvt	d0, s0
	fmov	d19, #9.00000000
	fmadd	d0, d0, d19, d18
	fcvt	d1, s1
	fmov	d18, #10.00000000
	fmadd	d0, d1, d18, d0
	fcvt	d1, s2
	fmov	d2, #11.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s3
	fmov	d2, #12.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s4
	fmov	d2, #13.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s5
	fmov	d2, #14.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s6
	fmov	d2, #15.00000000
	fmadd	d0, d1, d2, d0
	fcvt	d1, s7
	fmov	d2, #16.00000000
	scvtf	d3, w9
	fmadd	d0, d1, d2, d0
	fmov	d1, #17.00000000
	fmadd	d0, d3, d1, d0
	fcvt	d1, s17
	fmov	d2, #18.00000000
	fmadd	d0, d1, d2, d0
	scvtf	d1, w8
	fmov	d2, #19.00000000
	fmadd	d0, d1, d2, d0
	fmov	d1, #20.00000000
	fmadd	d0, d16, d1, d0
	ldr	s1, [sp, #24]
	sshll.2d	v1, v1, #0
	scvtf	d1, d1
	fmov	d2, #21.00000000
	fmadd	d0, d1, d2, d0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_mixed                     ; -- Begin function call_mixed
	.p2align	2
_call_mixed:                            ; @call_mixed
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	mov	w9, #7616                       ; =0x1dc0
	movk	w9, #65534, lsl #16
	str	w9, [sp, #24]
	mov	x9, #140737488355328            ; =0x800000000000
	movk	x9, #16420, lsl #48
	str	x9, [sp, #16]
	mov	w9, #64536                      ; =0xfc18
	strh	w9, [sp, #8]
	mov	w9, #1092091904                 ; =0x41180000
	str	w9, [sp, #4]
	mov	w9, #247                        ; =0xf7
	fmov	s0, #1.00000000
	fmov	s1, #2.00000000
	fmov	s2, #3.00000000
	fmov	s3, #4.00000000
	strb	w9, [sp]
	fmov	s4, #5.00000000
	fmov	s5, #6.00000000
	fmov	s6, #7.00000000
	fmov	s7, #8.00000000
	mov	w0, #1                          ; =0x1
	mov	w1, #2                          ; =0x2
	mov	w2, #3                          ; =0x3
	mov	w3, #4                          ; =0x4
	mov	w4, #5                          ; =0x5
	mov	w5, #6                          ; =0x6
	mov	w6, #7                          ; =0x7
	mov	w7, #8                          ; =0x8
	blr	x8
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_var                        ; -- Begin function abi_var
	.p2align	2
_abi_var:                               ; @abi_var
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	add	x8, sp, #16
	orr	x8, x8, #0x8
	ldr	w9, [sp, #16]
	ldr	d1, [x8], #8
	ldr	x10, [x8], #8
	ldr	w11, [x8], #8
	scvtf	d2, w0
	fmov	d3, #2.00000000
	fmadd	d0, d0, d3, d2
	add	w8, w9, w9, lsl #1
	scvtf	d2, w8
	fadd	d0, d0, d2
	fmov	d2, #4.00000000
	fmadd	d0, d1, d2, d0
	add	x8, x10, x10, lsl #2
	scvtf	d1, x8
	fadd	d0, d0, d1
	add	w8, w11, w11, lsl #1
	lsl	w8, w8, #1
	scvtf	d1, w8
	fadd	d0, d0, d1
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_var_spill                  ; -- Begin function abi_var_spill
	.p2align	2
_abi_var_spill:                         ; @abi_var_spill
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	ldp	w9, w8, [sp, #16]
	add	x10, sp, #24
	add	x10, x10, #8
	ldr	w11, [sp, #24]
	ldr	d0, [x10], #8
	add	w10, w0, w1, lsl #1
	add	w12, w2, w2, lsl #1
	add	w10, w10, w12
	add	w10, w10, w3, lsl #2
	add	w12, w4, w4, lsl #2
	add	w10, w10, w12
	mov	w12, #6                         ; =0x6
	madd	w10, w5, w12, w10
	sub	w10, w10, w6
	add	w10, w10, w6, lsl #3
	add	w10, w10, w7, lsl #3
	add	w9, w9, w9, lsl #3
	add	w9, w10, w9
	mov	w10, #10                        ; =0xa
	madd	w8, w8, w10, w9
	mov	w9, #11                         ; =0xb
	madd	w8, w11, w9, w8
	scvtf	d1, w8
	fmov	d2, #12.00000000
	fmadd	d0, d0, d2, d1
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_var_hfa                    ; -- Begin function abi_var_hfa
	.p2align	2
_abi_var_hfa:                           ; @abi_var_hfa
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	ldp	s2, s3, [sp, #16]
	ldr	w8, [sp, #24]
	fmov	s4, #2.00000000
	fmadd	s0, s1, s4, s0
	fmov	s1, #3.00000000
	fmadd	s0, s2, s1, s0
	fmov	s1, #4.00000000
	fmadd	s0, s3, s1, s0
	add	w8, w8, w8, lsl #2
	scvtf	s1, w8
	fadd	s0, s0, s1
	fcvt	d0, s0
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_struct                     ; -- Begin function abi_struct
	.p2align	2
_abi_struct:                            ; @abi_struct
	.cfi_startproc
; %bb.0:
	ldr	x8, [sp, #8]
	ldrsb	w9, [sp, #16]
	ldrsb	w10, [sp]
	add	x11, x1, x0
	add	x12, x2, x3
	add	x11, x11, x12
	add	x12, x4, x5
	add	x12, x12, x6
	add	x11, x11, x12
	add	x11, x11, x7
	add	x10, x11, w10, sxtw
	add	x10, x10, w8, sxtw
	sbfx	x8, x8, #31, #32
	and	x8, x8, #0xfffffffffffffffe
	add	x9, x10, w9, sxtw
	add	x8, x9, x8
	scvtf	d0, x8
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_struct                    ; -- Begin function call_struct
	.p2align	2
_call_struct:                           ; @call_struct
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	mov	w9, #244                        ; =0xf4
	mov	x10, #10                        ; =0xa
	movk	x10, #11, lsl #32
	strb	w9, [sp, #16]
	mov	w9, #247                        ; =0xf7
	str	x10, [sp, #8]
	strb	w9, [sp]
	mov	w0, #1                          ; =0x1
	mov	w1, #2                          ; =0x2
	mov	w2, #3                          ; =0x3
	mov	w3, #4                          ; =0x4
	mov	w4, #5                          ; =0x5
	mov	w5, #6                          ; =0x6
	mov	w6, #7                          ; =0x7
	mov	w7, #8                          ; =0x8
	blr	x8
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_hfa_boundary               ; -- Begin function abi_hfa_boundary
	.p2align	2
_abi_hfa_boundary:                      ; @abi_hfa_boundary
	.cfi_startproc
; %bb.0:
	ldp	s16, s7, [sp, #4]
	ldr	s17, [sp]
	fadd	s0, s0, s1
	fadd	s0, s0, s2
	fadd	s0, s0, s3
	fadd	s0, s0, s4
	fadd	s0, s0, s5
	fadd	s0, s0, s6
	fadd	s0, s0, s17
	fmov	s1, #2.00000000
	fmadd	s0, s16, s1, s0
	fadd	s0, s7, s0
	fcvt	d0, s0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_hfa_boundary              ; -- Begin function call_hfa_boundary
	.p2align	2
_call_hfa_boundary:                     ; @call_hfa_boundary
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	; InlineAsm Start
	fmov	s7, wzr
	; InlineAsm End
	mov	w8, #1092616192                 ; =0x41200000
	str	w8, [sp, #8]
	mov	x8, #1090519040                 ; =0x41000000
	movk	x8, #16656, lsl #48
	str	x8, [sp]
	fmov	s0, #1.00000000
	fmov	s1, #2.00000000
	fmov	s2, #3.00000000
	fmov	s3, #4.00000000
	fmov	s4, #5.00000000
	fmov	s5, #6.00000000
	fmov	s6, #7.00000000
	blr	x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_array_hfa                  ; -- Begin function abi_array_hfa
	.p2align	2
_abi_array_hfa:                         ; @abi_array_hfa
	.cfi_startproc
; %bb.0:
	fmov	s3, #10.00000000
	fadd	s0, s0, s3
	fmov	s3, #20.00000000
	fadd	s1, s1, s3
	fmov	s3, #30.00000000
	fadd	s2, s2, s3
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_array_hfa                 ; -- Begin function call_array_hfa
	.p2align	2
_call_array_hfa:                        ; @call_array_hfa
	.cfi_startproc
; %bb.0:
	stp	d9, d8, [sp, #-32]!             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset b8, -24
	.cfi_offset b9, -32
	fmov	s8, #2.00000000
	fmov	s9, #3.00000000
	fmov	s0, #1.00000000
	fmov	s1, #2.00000000
	fmov	s2, #3.00000000
	blr	x0
	fmadd	s0, s1, s8, s0
	fmadd	s0, s2, s9, s0
	fcvt	d0, s0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp], #32               ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_var_array                  ; -- Begin function abi_var_array
	.p2align	2
_abi_var_array:                         ; @abi_var_array
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	ldp	s0, s1, [sp, #16]
	ldr	s2, [sp, #24]
	ldr	d3, [sp, #32]
	scvtf	s4, w0
	fadd	s0, s0, s4
	fmov	s4, #2.00000000
	fmadd	s0, s1, s4, s0
	fmov	s1, #3.00000000
	fmadd	s0, s2, s1, s0
	fcvt	d0, s0
	fadd	d0, d3, d0
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_int_boundary               ; -- Begin function abi_int_boundary
	.p2align	2
_abi_int_boundary:                      ; @abi_int_boundary
	.cfi_startproc
; %bb.0:
	ldp	x9, x8, [sp, #8]
	ldr	x10, [sp]
	add	x11, x1, x0
	add	x12, x2, x3
	add	x11, x11, x12
	add	x12, x4, x5
	add	x12, x12, x6
	add	x11, x11, x12
	add	x10, x11, x10
	add	x8, x10, x8
	add	x8, x8, x9, lsl #1
	scvtf	d0, x8
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_call_int_boundary              ; -- Begin function call_int_boundary
	.p2align	2
_call_int_boundary:                     ; @call_int_boundary
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, x0
	; InlineAsm Start
	mov	x7, xzr
	; InlineAsm End
	mov	w9, #10                         ; =0xa
	mov	w10, #9                         ; =0x9
	stp	x10, x9, [sp, #8]
	mov	w9, #8                          ; =0x8
	str	x9, [sp]
	mov	w0, #1                          ; =0x1
	mov	w1, #2                          ; =0x2
	mov	w2, #3                          ; =0x3
	mov	w3, #4                          ; =0x4
	mov	w4, #5                          ; =0x5
	mov	w5, #6                          ; =0x6
	mov	w6, #7                          ; =0x7
	blr	x8
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_abi_hfa_stack                  ; -- Begin function abi_hfa_stack
	.p2align	2
_abi_hfa_stack:                         ; @abi_hfa_stack
	.cfi_startproc
; %bb.0:
	ldp	s17, s16, [sp, #8]
	ldr	s18, [sp, #4]
	add	x8, x1, x0
	add	x9, x2, x3
	add	x8, x8, x9
	add	x9, x4, x5
	add	x9, x9, x6
	add	x8, x8, x9
	add	x8, x8, x7
	scvtf	s19, x8
	ldrsb	w8, [sp]
	fadd	s0, s0, s19
	fadd	s0, s1, s0
	fadd	s0, s2, s0
	fadd	s0, s3, s0
	fadd	s0, s4, s0
	fadd	s0, s5, s0
	fadd	s0, s6, s0
	fadd	s0, s7, s0
	scvtf	s1, w8
	fadd	s0, s0, s1
	fadd	s0, s0, s18
	fmov	s1, #2.00000000
	fmadd	s0, s17, s1, s0
	fadd	s0, s16, s0
	fcvt	d0, s0
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
