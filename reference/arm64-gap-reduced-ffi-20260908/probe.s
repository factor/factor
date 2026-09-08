	.build_version macos, 11, 0	sdk_version 26, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_ffi_test_small_floats_available ; -- Begin function ffi_test_small_floats_available
	.p2align	2
_ffi_test_small_floats_available:       ; @ffi_test_small_floats_available
	.cfi_startproc
; %bb.0:
	mov	w0, #1                          ; =0x1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_identity                  ; -- Begin function half_identity
	.p2align	2
_half_identity:                         ; @half_identity
	.cfi_startproc
; %bb.0:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_bits                      ; -- Begin function half_bits
	.p2align	2
_half_bits:                             ; @half_bits
	.cfi_startproc
; %bb.0:
                                        ; kill: def $h0 killed $h0 def $s0
	fmov	w8, s0
	and	w0, w8, #0xffff
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_from_bits                 ; -- Begin function half_from_bits
	.p2align	2
_half_from_bits:                        ; @half_from_bits
	.cfi_startproc
; %bb.0:
	fmov	s0, w0
                                        ; kill: def $h0 killed $h0 killed $s0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_convert                   ; -- Begin function half_convert
	.p2align	2
_half_convert:                          ; @half_convert
	.cfi_startproc
; %bb.0:
	fcvt	h0, d0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_callback                  ; -- Begin function half_callback
	.p2align	2
_half_callback:                         ; @half_callback
	.cfi_startproc
; %bb.0:
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_half_mixed                     ; -- Begin function half_mixed
	.p2align	2
_half_mixed:                            ; @half_mixed
	.cfi_startproc
; %bb.0:
	fcvt	d0, h0
	scvtf	d3, w0
	fadd	d0, d3, d0
	fadd	d0, d1, d0
	fcvt	d1, h2
	fadd	d0, d0, d1
	scvtf	d1, w1
	fadd	d0, d0, d1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_overflow                  ; -- Begin function half_overflow
	.p2align	2
_half_overflow:                         ; @half_overflow
	.cfi_startproc
; %bb.0:
	ldr	h16, [sp, #2]
	ldr	h17, [sp]
	fadd	h0, h0, h1
	fadd	h0, h0, h2
	fadd	h0, h0, h3
	fadd	h0, h0, h4
	fadd	h0, h0, h5
	fadd	h0, h0, h6
	fadd	h0, h0, h7
	fadd	h0, h0, h17
	fadd	h0, h0, h16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_varargs                   ; -- Begin function half_varargs
	.p2align	2
_half_varargs:                          ; @half_varargs
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	add	x8, sp, #16
	orr	x8, x8, #0x8
	ldr	d0, [sp, #16]
	ldr	d1, [x8], #8
	ldr	w9, [x8], #8
	ldr	d2, [x8], #8
	fadd	d0, d0, d1
	scvtf	d1, w9
	fadd	d0, d0, d1
	fadd	d0, d2, d0
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_overflow_callback         ; -- Begin function half_overflow_callback
	.p2align	2
_half_overflow_callback:                ; @half_overflow_callback
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #18560                      ; =0x4880
	movk	w8, #18688, lsl #16
	str	w8, [sp]
	fmov	h0, #1.00000000
	fmov	h1, #2.00000000
	fmov	h2, #3.00000000
	fmov	h3, #4.00000000
	fmov	h4, #5.00000000
	fmov	h5, #6.00000000
	fmov	h6, #7.00000000
	fmov	h7, #8.00000000
	blr	x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_identity                ; -- Begin function bfloat_identity
	.p2align	2
_bfloat_identity:                       ; @bfloat_identity
	.cfi_startproc
; %bb.0:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_bits                    ; -- Begin function bfloat_bits
	.p2align	2
_bfloat_bits:                           ; @bfloat_bits
	.cfi_startproc
; %bb.0:
                                        ; kill: def $h0 killed $h0 def $s0
	fmov	w8, s0
	and	w0, w8, #0xffff
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_from_bits               ; -- Begin function bfloat_from_bits
	.p2align	2
_bfloat_from_bits:                      ; @bfloat_from_bits
	.cfi_startproc
; %bb.0:
	fmov	s0, w0
                                        ; kill: def $h0 killed $h0 killed $s0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_convert                 ; -- Begin function bfloat_convert
	.p2align	2
_bfloat_convert:                        ; @bfloat_convert
	.cfi_startproc
; %bb.0:
	fcvtxn	s0, d0
	fmov	w8, s0
	ubfx	w9, w8, #16, #1
	mov	w10, #32767                     ; =0x7fff
	add	w8, w9, w8
	add	w8, w8, w10
	lsr	w8, w8, #16
	fmov	s0, w8
                                        ; kill: def $h0 killed $h0 killed $s0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_callback                ; -- Begin function bfloat_callback
	.p2align	2
_bfloat_callback:                       ; @bfloat_callback
	.cfi_startproc
; %bb.0:
	br	x0
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_mixed                   ; -- Begin function bfloat_mixed
	.p2align	2
_bfloat_mixed:                          ; @bfloat_mixed
	.cfi_startproc
; %bb.0:
                                        ; kill: def $h2 killed $h2 def $d2
                                        ; kill: def $h0 killed $h0 def $d0
	shll.4s	v0, v0, #16
	scvtf	d3, w0
	fcvt	d0, s0
	fadd	d0, d3, d0
	fadd	d0, d1, d0
	shll.4s	v1, v2, #16
	fcvt	d1, s1
	fadd	d0, d0, d1
	scvtf	d1, w1
	fadd	d0, d0, d1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_overflow                ; -- Begin function bfloat_overflow
	.p2align	2
_bfloat_overflow:                       ; @bfloat_overflow
	.cfi_startproc
; %bb.0:
                                        ; kill: def $h7 killed $h7 def $d7
                                        ; kill: def $h6 killed $h6 def $d6
                                        ; kill: def $h5 killed $h5 def $d5
                                        ; kill: def $h4 killed $h4 def $d4
                                        ; kill: def $h3 killed $h3 def $d3
                                        ; kill: def $h2 killed $h2 def $d2
                                        ; kill: def $h1 killed $h1 def $d1
                                        ; kill: def $h0 killed $h0 def $d0
	ldr	h16, [sp, #2]
	ldr	h17, [sp]
	shll.4s	v0, v0, #16
	shll.4s	v1, v1, #16
	fadd	s0, s0, s1
	shll.4s	v1, v2, #16
	fadd	s0, s0, s1
	shll.4s	v1, v3, #16
	fadd	s0, s0, s1
	shll.4s	v1, v4, #16
	fadd	s0, s0, s1
	shll.4s	v1, v5, #16
	fadd	s0, s0, s1
	shll.4s	v1, v6, #16
	fadd	s0, s0, s1
	shll.4s	v1, v7, #16
	fadd	s0, s0, s1
	shll.4s	v1, v17, #16
	fadd	s0, s0, s1
	shll.4s	v1, v16, #16
	fadd	s0, s0, s1
	fmov	w8, s0
	ubfx	w9, w8, #16, #1
	mov	w10, #32767                     ; =0x7fff
	add	w8, w9, w8
	add	w8, w8, w10
	lsr	w8, w8, #16
	fmov	s0, w8
                                        ; kill: def $h0 killed $h0 killed $s0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_varargs                 ; -- Begin function bfloat_varargs
	.p2align	2
_bfloat_varargs:                        ; @bfloat_varargs
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	ldr	d0, [sp, #16]
	fcvtxn	s0, d0
	fmov	w8, s0
	lsr	w8, w8, #16
	fmov	s0, w8
	add	x8, sp, #16
	orr	x8, x8, #0x8
	ldr	d1, [x8], #8
	fcvtxn	s1, d1
	fmov	w9, s1
	lsr	w9, w9, #16
	fmov	s1, w9
	ldr	w9, [x8], #8
	ldr	d2, [x8], #8
	shll.4s	v0, v0, #16
	fcvt	d0, s0
	shll.4s	v1, v1, #16
	fcvt	d1, s1
	fadd	d0, d0, d1
	scvtf	d1, w9
	fadd	d0, d0, d1
	fadd	d0, d2, d0
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_overflow_callback       ; -- Begin function bfloat_overflow_callback
	.p2align	2
_bfloat_overflow_callback:              ; @bfloat_overflow_callback
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #16656                      ; =0x4110
	movk	w8, #16672, lsl #16
	str	w8, [sp]
	mov	w8, #16544                      ; =0x40a0
	fmov	h4, w8
	mov	w8, #16608                      ; =0x40e0
	fmov	h6, w8
	fmov	h0, #1.87500000
	fmov	h1, #2.00000000
	fmov	h2, #2.12500000
	fmov	h3, #2.25000000
	fmov	h5, #2.37500000
	fmov	h7, #2.50000000
	blr	x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_half_dirty_result              ; -- Begin function half_dirty_result
	.p2align	2
_half_dirty_result:                     ; @half_dirty_result
	.cfi_startproc
; %bb.0:
	mov	w8, #15360                      ; =0x3c00
	movk	w8, #42405, lsl #16
	; InlineAsm Start
	fmov	s0, w8
	; InlineAsm End
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_bfloat_dirty_result            ; -- Begin function bfloat_dirty_result
	.p2align	2
_bfloat_dirty_result:                   ; @bfloat_dirty_result
	.cfi_startproc
; %bb.0:
	mov	w8, #16256                      ; =0x3f80
	movk	w8, #42405, lsl #16
	; InlineAsm Start
	fmov	s0, w8
	; InlineAsm End
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_mixed_small_sum                ; -- Begin function mixed_small_sum
	.p2align	2
_mixed_small_sum:                       ; @mixed_small_sum
	.cfi_startproc
; %bb.0:
                                        ; kill: def $h1 killed $h1 def $d1
	fcvt	d0, h0
	shll.4s	v1, v1, #16
	fcvt	d1, s1
	fadd	d0, d0, d1
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
