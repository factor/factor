	.file	"probe.c"
	.text
	.globl	ffi_test_small_floats_available // -- Begin function ffi_test_small_floats_available
	.p2align	2
	.type	ffi_test_small_floats_available,@function
ffi_test_small_floats_available:        // @ffi_test_small_floats_available
// %bb.0:
	mov	w0, #1                          // =0x1
	ret
.Lfunc_end0:
	.size	ffi_test_small_floats_available, .Lfunc_end0-ffi_test_small_floats_available
                                        // -- End function
	.globl	half_identity                   // -- Begin function half_identity
	.p2align	2
	.type	half_identity,@function
half_identity:                          // @half_identity
// %bb.0:
	ret
.Lfunc_end1:
	.size	half_identity, .Lfunc_end1-half_identity
                                        // -- End function
	.globl	half_bits                       // -- Begin function half_bits
	.p2align	2
	.type	half_bits,@function
half_bits:                              // @half_bits
// %bb.0:
                                        // kill: def $h0 killed $h0 def $s0
	fmov	w0, s0
	ret
.Lfunc_end2:
	.size	half_bits, .Lfunc_end2-half_bits
                                        // -- End function
	.globl	half_from_bits                  // -- Begin function half_from_bits
	.p2align	2
	.type	half_from_bits,@function
half_from_bits:                         // @half_from_bits
// %bb.0:
	fmov	s0, w0
                                        // kill: def $h0 killed $h0 killed $s0
	ret
.Lfunc_end3:
	.size	half_from_bits, .Lfunc_end3-half_from_bits
                                        // -- End function
	.globl	half_convert                    // -- Begin function half_convert
	.p2align	2
	.type	half_convert,@function
half_convert:                           // @half_convert
// %bb.0:
	fcvt	h0, d0
	ret
.Lfunc_end4:
	.size	half_convert, .Lfunc_end4-half_convert
                                        // -- End function
	.globl	half_callback                   // -- Begin function half_callback
	.p2align	2
	.type	half_callback,@function
half_callback:                          // @half_callback
// %bb.0:
	br	x0
.Lfunc_end5:
	.size	half_callback, .Lfunc_end5-half_callback
                                        // -- End function
	.globl	half_mixed                      // -- Begin function half_mixed
	.p2align	2
	.type	half_mixed,@function
half_mixed:                             // @half_mixed
// %bb.0:
	scvtf	d3, w0
	fcvt	d0, h0
	fcvt	d2, h2
	fadd	d0, d3, d0
	fadd	d0, d1, d0
	scvtf	d1, w1
	fadd	d0, d0, d2
	fadd	d0, d0, d1
	ret
.Lfunc_end6:
	.size	half_mixed, .Lfunc_end6-half_mixed
                                        // -- End function
	.globl	half_overflow                   // -- Begin function half_overflow
	.p2align	2
	.type	half_overflow,@function
half_overflow:                          // @half_overflow
// %bb.0:
	fcvt	s1, h1
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h2
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h3
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h4
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h5
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h6
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	s1, h7
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	ldr	h1, [sp]
	fcvt	s1, h1
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	ldr	h1, [sp, #8]
	fcvt	s1, h1
	fcvt	h0, s0
	fcvt	s0, h0
	fadd	s0, s0, s1
	fcvt	h0, s0
	ret
.Lfunc_end7:
	.size	half_overflow, .Lfunc_end7-half_overflow
                                        // -- End function
	.globl	half_varargs                    // -- Begin function half_varargs
	.p2align	2
	.type	half_varargs,@function
half_varargs:                           // @half_varargs
// %bb.0:
	sub	sp, sp, #224
	mov	x8, #-56                        // =0xffffffffffffffc8
	mov	x9, sp
	add	x10, sp, #136
	movk	x8, #65408, lsl #32
	add	x9, x9, #128
	stp	x1, x2, [sp, #136]
	stp	x9, x8, [sp, #208]
	lsr	x8, x8, #32
	add	x9, x10, #56
	add	x10, sp, #224
	stp	x3, x4, [sp, #152]
	stp	x10, x9, [sp, #192]
	mov	w9, w8
	stp	x5, x6, [sp, #168]
	str	x7, [sp, #184]
	stp	q0, q1, [sp]
	stp	q2, q3, [sp, #32]
	stp	q4, q5, [sp, #64]
	stp	q6, q7, [sp, #96]
	tbz	w8, #31, .LBB8_4
// %bb.1:
	sxtw	x10, w8
	cmn	w8, #15
	add	x9, x10, #16
	str	w9, [sp, #220]
	b.hs	.LBB8_4
// %bb.2:
	ldr	x11, [sp, #208]
	cmn	w8, #17
	ldr	h0, [x11, x10]
	b.le	.LBB8_14
// %bb.3:
	mov	w8, wzr
	b	.LBB8_5
.LBB8_4:
	ldr	x8, [sp, #192]
	add	x10, x8, #8
	str	x10, [sp, #192]
	ldr	h0, [x8]
	mov	w8, w9
.LBB8_5:
	ldr	x9, [sp, #192]
	add	x10, x9, #8
	str	x10, [sp, #192]
.LBB8_6:
	ldrsw	x10, [sp, #216]
	ldr	h1, [x9]
	tbz	w10, #31, .LBB8_9
// %bb.7:
	add	w9, w10, #8
	cmn	w10, #8
	str	w9, [sp, #216]
	b.hi	.LBB8_9
// %bb.8:
	ldr	x9, [sp, #200]
	add	x9, x9, x10
	ldr	w9, [x9]
	tbz	w8, #31, .LBB8_12
	b	.LBB8_10
.LBB8_9:
	ldr	x9, [sp, #192]
	add	x10, x9, #8
	str	x10, [sp, #192]
	ldr	w9, [x9]
	tbz	w8, #31, .LBB8_12
.LBB8_10:
	add	w10, w8, #16
	cmn	w8, #16
	str	w10, [sp, #220]
	b.hi	.LBB8_12
// %bb.11:
	ldr	x10, [sp, #208]
	add	x8, x10, w8, sxtw
	b	.LBB8_13
.LBB8_12:
	ldr	x8, [sp, #192]
	add	x10, x8, #8
	str	x10, [sp, #192]
.LBB8_13:
	fcvt	d0, h0
	fcvt	d1, h1
	fadd	d0, d0, d1
	scvtf	d1, w9
	fadd	d0, d0, d1
	ldr	d1, [x8]
	fadd	d0, d0, d1
	add	sp, sp, #224
	ret
.LBB8_14:
	add	w8, w8, #32
	cmn	w9, #16
	str	w8, [sp, #220]
	b.hi	.LBB8_5
// %bb.15:
	ldr	x10, [sp, #208]
	add	x9, x10, x9
	b	.LBB8_6
.Lfunc_end8:
	.size	half_varargs, .Lfunc_end8-half_varargs
                                        // -- End function
	.section	.rodata,"a",@progbits
	.p2align	1, 0x0                          // -- Begin function half_overflow_callback
.LCPI9_0:
	.hword	0x4900                          // half 10
.LCPI9_1:
	.hword	0x4880                          // half 9
.LCPI9_2:
	.hword	0x3c00                          // half 1
.LCPI9_3:
	.hword	0x4000                          // half 2
.LCPI9_4:
	.hword	0x4200                          // half 3
.LCPI9_5:
	.hword	0x4400                          // half 4
.LCPI9_6:
	.hword	0x4500                          // half 5
.LCPI9_7:
	.hword	0x4600                          // half 6
.LCPI9_8:
	.hword	0x4700                          // half 7
.LCPI9_9:
	.hword	0x4800                          // half 8
	.text
	.globl	half_overflow_callback
	.p2align	2
	.type	half_overflow_callback,@function
half_overflow_callback:                 // @half_overflow_callback
// %bb.0:
	sub	sp, sp, #32
	adrp	x8, .LCPI9_0
	adrp	x9, .LCPI9_1
	stp	x29, x30, [sp, #16]             // 16-byte Folded Spill
	ldr	h6, [x8, :lo12:.LCPI9_0]
	adrp	x8, .LCPI9_2
	ldr	h16, [x9, :lo12:.LCPI9_1]
	ldr	h0, [x8, :lo12:.LCPI9_2]
	adrp	x8, .LCPI9_3
	adrp	x9, .LCPI9_4
	ldr	h1, [x8, :lo12:.LCPI9_3]
	adrp	x8, .LCPI9_5
	ldr	h2, [x9, :lo12:.LCPI9_4]
	ldr	h3, [x8, :lo12:.LCPI9_5]
	adrp	x8, .LCPI9_6
	adrp	x9, .LCPI9_7
	ldr	h4, [x8, :lo12:.LCPI9_6]
	adrp	x8, .LCPI9_8
	str	h6, [sp, #8]
	ldr	h6, [x8, :lo12:.LCPI9_8]
	adrp	x8, .LCPI9_9
	ldr	h5, [x9, :lo12:.LCPI9_7]
	ldr	h7, [x8, :lo12:.LCPI9_9]
	add	x29, sp, #16
	str	h16, [sp]
	blr	x0
	ldp	x29, x30, [sp, #16]             // 16-byte Folded Reload
	add	sp, sp, #32
	ret
.Lfunc_end9:
	.size	half_overflow_callback, .Lfunc_end9-half_overflow_callback
                                        // -- End function
	.globl	bfloat_identity                 // -- Begin function bfloat_identity
	.p2align	2
	.type	bfloat_identity,@function
bfloat_identity:                        // @bfloat_identity
// %bb.0:
	ret
.Lfunc_end10:
	.size	bfloat_identity, .Lfunc_end10-bfloat_identity
                                        // -- End function
	.globl	bfloat_bits                     // -- Begin function bfloat_bits
	.p2align	2
	.type	bfloat_bits,@function
bfloat_bits:                            // @bfloat_bits
// %bb.0:
                                        // kill: def $h0 killed $h0 def $s0
	fmov	w0, s0
	ret
.Lfunc_end11:
	.size	bfloat_bits, .Lfunc_end11-bfloat_bits
                                        // -- End function
	.globl	bfloat_from_bits                // -- Begin function bfloat_from_bits
	.p2align	2
	.type	bfloat_from_bits,@function
bfloat_from_bits:                       // @bfloat_from_bits
// %bb.0:
	fmov	s0, w0
                                        // kill: def $h0 killed $h0 killed $s0
	ret
.Lfunc_end12:
	.size	bfloat_from_bits, .Lfunc_end12-bfloat_from_bits
                                        // -- End function
	.globl	bfloat_convert                  // -- Begin function bfloat_convert
	.p2align	2
	.type	bfloat_convert,@function
bfloat_convert:                         // @bfloat_convert
// %bb.0:
	fcvtxn	s0, d0
	mov	w8, #32767                      // =0x7fff
	fmov	w9, s0
	ubfx	w10, w9, #16, #1
	add	w8, w9, w8
	add	w8, w10, w8
	lsr	w8, w8, #16
	fmov	s0, w8
                                        // kill: def $h0 killed $h0 killed $s0
	ret
.Lfunc_end13:
	.size	bfloat_convert, .Lfunc_end13-bfloat_convert
                                        // -- End function
	.globl	bfloat_callback                 // -- Begin function bfloat_callback
	.p2align	2
	.type	bfloat_callback,@function
bfloat_callback:                        // @bfloat_callback
// %bb.0:
	br	x0
.Lfunc_end14:
	.size	bfloat_callback, .Lfunc_end14-bfloat_callback
                                        // -- End function
	.globl	bfloat_mixed                    // -- Begin function bfloat_mixed
	.p2align	2
	.type	bfloat_mixed,@function
bfloat_mixed:                           // @bfloat_mixed
// %bb.0:
                                        // kill: def $h0 killed $h0 def $d0
	scvtf	d3, w0
                                        // kill: def $h2 killed $h2 def $d2
	shll	v0.4s, v0.4h, #16
	shll	v2.4s, v2.4h, #16
	fcvt	d0, s0
	fadd	d0, d3, d0
	fadd	d0, d1, d0
	fcvt	d1, s2
	fadd	d0, d0, d1
	scvtf	d1, w1
	fadd	d0, d0, d1
	ret
.Lfunc_end15:
	.size	bfloat_mixed, .Lfunc_end15-bfloat_mixed
                                        // -- End function
	.globl	bfloat_overflow                 // -- Begin function bfloat_overflow
	.p2align	2
	.type	bfloat_overflow,@function
bfloat_overflow:                        // @bfloat_overflow
// %bb.0:
                                        // kill: def $h1 killed $h1 def $d1
                                        // kill: def $h0 killed $h0 def $d0
                                        // kill: def $h2 killed $h2 def $d2
                                        // kill: def $h3 killed $h3 def $d3
                                        // kill: def $h4 killed $h4 def $d4
                                        // kill: def $h5 killed $h5 def $d5
                                        // kill: def $h6 killed $h6 def $d6
                                        // kill: def $h7 killed $h7 def $d7
	mov	w10, #32767                     // =0x7fff
	shll	v0.4s, v0.4h, #16
	shll	v1.4s, v1.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v2.4h, #16
	ldr	h2, [sp]
	fadd	s0, s0, s1
	shll	v1.4s, v3.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v4.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v5.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v6.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v7.4h, #16
	fadd	s0, s0, s1
	shll	v1.4s, v2.4h, #16
	ldr	h2, [sp, #8]
	fadd	s0, s0, s1
	shll	v1.4s, v2.4h, #16
	fadd	s0, s0, s1
	fmov	w8, s0
	ubfx	w9, w8, #16, #1
	add	w8, w8, w10
	add	w8, w9, w8
	lsr	w8, w8, #16
	fmov	s0, w8
                                        // kill: def $h0 killed $h0 killed $s0
	ret
.Lfunc_end16:
	.size	bfloat_overflow, .Lfunc_end16-bfloat_overflow
                                        // -- End function
	.globl	bfloat_varargs                  // -- Begin function bfloat_varargs
	.p2align	2
	.type	bfloat_varargs,@function
bfloat_varargs:                         // @bfloat_varargs
// %bb.0:
	sub	sp, sp, #224
	mov	x8, #-56                        // =0xffffffffffffffc8
	mov	x9, sp
	add	x10, sp, #136
	movk	x8, #65408, lsl #32
	add	x9, x9, #128
	stp	x1, x2, [sp, #136]
	stp	x9, x8, [sp, #208]
	lsr	x8, x8, #32
	add	x9, x10, #56
	add	x10, sp, #224
	stp	x3, x4, [sp, #152]
	stp	x10, x9, [sp, #192]
	mov	w9, w8
	stp	x5, x6, [sp, #168]
	str	x7, [sp, #184]
	stp	q0, q1, [sp]
	stp	q2, q3, [sp, #32]
	stp	q4, q5, [sp, #64]
	stp	q6, q7, [sp, #96]
	tbz	w8, #31, .LBB17_4
// %bb.1:
	sxtw	x10, w8
	cmn	w8, #15
	add	x9, x10, #16
	str	w9, [sp, #220]
	b.hs	.LBB17_4
// %bb.2:
	ldr	x11, [sp, #208]
	cmn	w8, #17
	ldr	h0, [x11, x10]
	b.le	.LBB17_14
// %bb.3:
	mov	w8, wzr
	b	.LBB17_5
.LBB17_4:
	ldr	x8, [sp, #192]
	add	x10, x8, #8
	str	x10, [sp, #192]
	ldr	h0, [x8]
	mov	w8, w9
.LBB17_5:
	ldr	x9, [sp, #192]
	add	x10, x9, #8
	str	x10, [sp, #192]
.LBB17_6:
	ldrsw	x10, [sp, #216]
	ldr	h1, [x9]
	tbz	w10, #31, .LBB17_9
// %bb.7:
	add	w9, w10, #8
	cmn	w10, #8
	str	w9, [sp, #216]
	b.hi	.LBB17_9
// %bb.8:
	ldr	x9, [sp, #200]
	add	x9, x9, x10
	ldr	w9, [x9]
	tbz	w8, #31, .LBB17_12
	b	.LBB17_10
.LBB17_9:
	ldr	x9, [sp, #192]
	add	x10, x9, #8
	str	x10, [sp, #192]
	ldr	w9, [x9]
	tbz	w8, #31, .LBB17_12
.LBB17_10:
	add	w10, w8, #16
	cmn	w8, #16
	str	w10, [sp, #220]
	b.hi	.LBB17_12
// %bb.11:
	ldr	x10, [sp, #208]
	add	x8, x10, w8, sxtw
	b	.LBB17_13
.LBB17_12:
	ldr	x8, [sp, #192]
	add	x10, x8, #8
	str	x10, [sp, #192]
.LBB17_13:
	shll	v0.4s, v0.4h, #16
	shll	v1.4s, v1.4h, #16
	fcvt	d0, s0
	fcvt	d1, s1
	fadd	d0, d0, d1
	scvtf	d1, w9
	fadd	d0, d0, d1
	ldr	d1, [x8]
	fadd	d0, d0, d1
	add	sp, sp, #224
	ret
.LBB17_14:
	add	w8, w8, #32
	cmn	w9, #16
	str	w8, [sp, #220]
	b.hi	.LBB17_5
// %bb.15:
	ldr	x10, [sp, #208]
	add	x9, x10, x9
	b	.LBB17_6
.Lfunc_end17:
	.size	bfloat_varargs, .Lfunc_end17-bfloat_varargs
                                        // -- End function
	.section	.rodata,"a",@progbits
	.p2align	1, 0x0                          // -- Begin function bfloat_overflow_callback
.LCPI18_0:
	.hword	0x4120                          // bfloat 10
.LCPI18_1:
	.hword	0x4110                          // bfloat 9
.LCPI18_2:
	.hword	0x3f80                          // bfloat 1
.LCPI18_3:
	.hword	0x4000                          // bfloat 2
.LCPI18_4:
	.hword	0x4040                          // bfloat 3
.LCPI18_5:
	.hword	0x4080                          // bfloat 4
.LCPI18_6:
	.hword	0x40a0                          // bfloat 5
.LCPI18_7:
	.hword	0x40c0                          // bfloat 6
.LCPI18_8:
	.hword	0x40e0                          // bfloat 7
.LCPI18_9:
	.hword	0x4100                          // bfloat 8
	.text
	.globl	bfloat_overflow_callback
	.p2align	2
	.type	bfloat_overflow_callback,@function
bfloat_overflow_callback:               // @bfloat_overflow_callback
// %bb.0:
	sub	sp, sp, #32
	adrp	x8, .LCPI18_0
	adrp	x9, .LCPI18_1
	stp	x29, x30, [sp, #16]             // 16-byte Folded Spill
	ldr	h6, [x8, :lo12:.LCPI18_0]
	adrp	x8, .LCPI18_2
	ldr	h16, [x9, :lo12:.LCPI18_1]
	ldr	h0, [x8, :lo12:.LCPI18_2]
	adrp	x8, .LCPI18_3
	adrp	x9, .LCPI18_4
	ldr	h1, [x8, :lo12:.LCPI18_3]
	adrp	x8, .LCPI18_5
	ldr	h2, [x9, :lo12:.LCPI18_4]
	ldr	h3, [x8, :lo12:.LCPI18_5]
	adrp	x8, .LCPI18_6
	adrp	x9, .LCPI18_7
	ldr	h4, [x8, :lo12:.LCPI18_6]
	adrp	x8, .LCPI18_8
	str	h6, [sp, #8]
	ldr	h6, [x8, :lo12:.LCPI18_8]
	adrp	x8, .LCPI18_9
	ldr	h5, [x9, :lo12:.LCPI18_7]
	ldr	h7, [x8, :lo12:.LCPI18_9]
	add	x29, sp, #16
	str	h16, [sp]
	blr	x0
	ldp	x29, x30, [sp, #16]             // 16-byte Folded Reload
	add	sp, sp, #32
	ret
.Lfunc_end18:
	.size	bfloat_overflow_callback, .Lfunc_end18-bfloat_overflow_callback
                                        // -- End function
	.globl	half_dirty_result               // -- Begin function half_dirty_result
	.p2align	2
	.type	half_dirty_result,@function
half_dirty_result:                      // @half_dirty_result
// %bb.0:
	mov	w8, #15360                      // =0x3c00
	movk	w8, #42405, lsl #16
	//APP
	fmov	s0, w8
	//NO_APP
	ret
.Lfunc_end19:
	.size	half_dirty_result, .Lfunc_end19-half_dirty_result
                                        // -- End function
	.globl	bfloat_dirty_result             // -- Begin function bfloat_dirty_result
	.p2align	2
	.type	bfloat_dirty_result,@function
bfloat_dirty_result:                    // @bfloat_dirty_result
// %bb.0:
	mov	w8, #16256                      // =0x3f80
	movk	w8, #42405, lsl #16
	//APP
	fmov	s0, w8
	//NO_APP
	ret
.Lfunc_end20:
	.size	bfloat_dirty_result, .Lfunc_end20-bfloat_dirty_result
                                        // -- End function
	.globl	mixed_small_sum                 // -- Begin function mixed_small_sum
	.p2align	2
	.type	mixed_small_sum,@function
mixed_small_sum:                        // @mixed_small_sum
// %bb.0:
                                        // kill: def $h1 killed $h1 def $d1
	fcvt	d0, h0
	shll	v1.4s, v1.4h, #16
	fcvt	d1, s1
	fadd	d0, d0, d1
	ret
.Lfunc_end21:
	.size	mixed_small_sum, .Lfunc_end21-mixed_small_sum
                                        // -- End function
	.ident	"Apple clang version 21.0.0 (clang-2100.1.1.101)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
