	.def	"@feat.00";
	.scl	3;
	.type	0;
	.endef
	.globl	"@feat.00"
"@feat.00" = 0
	.file	"probe.c"
	.def	ffi_test_small_floats_available;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	ffi_test_small_floats_available // -- Begin function ffi_test_small_floats_available
	.p2align	2
ffi_test_small_floats_available:        // @ffi_test_small_floats_available
// %bb.0:
	mov	w0, #1                          // =0x1
	ret
                                        // -- End function
	.def	half_identity;
	.scl	2;
	.type	32;
	.endef
	.globl	half_identity                   // -- Begin function half_identity
	.p2align	2
half_identity:                          // @half_identity
// %bb.0:
	ret
                                        // -- End function
	.def	half_bits;
	.scl	2;
	.type	32;
	.endef
	.globl	half_bits                       // -- Begin function half_bits
	.p2align	2
half_bits:                              // @half_bits
// %bb.0:
                                        // kill: def $h0 killed $h0 def $s0
	fmov	w0, s0
	ret
                                        // -- End function
	.def	half_from_bits;
	.scl	2;
	.type	32;
	.endef
	.globl	half_from_bits                  // -- Begin function half_from_bits
	.p2align	2
half_from_bits:                         // @half_from_bits
// %bb.0:
	fmov	s0, w0
                                        // kill: def $h0 killed $h0 killed $s0
	ret
                                        // -- End function
	.def	half_convert;
	.scl	2;
	.type	32;
	.endef
	.globl	half_convert                    // -- Begin function half_convert
	.p2align	2
half_convert:                           // @half_convert
// %bb.0:
	fcvt	h0, d0
	ret
                                        // -- End function
	.def	half_callback;
	.scl	2;
	.type	32;
	.endef
	.globl	half_callback                   // -- Begin function half_callback
	.p2align	2
half_callback:                          // @half_callback
// %bb.0:
	br	x0
                                        // -- End function
	.def	half_mixed;
	.scl	2;
	.type	32;
	.endef
	.globl	half_mixed                      // -- Begin function half_mixed
	.p2align	2
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
                                        // -- End function
	.def	half_overflow;
	.scl	2;
	.type	32;
	.endef
	.globl	half_overflow                   // -- Begin function half_overflow
	.p2align	2
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
                                        // -- End function
	.def	half_varargs;
	.scl	2;
	.type	32;
	.endef
	.globl	half_varargs                    // -- Begin function half_varargs
	.p2align	2
half_varargs:                           // @half_varargs
// %bb.0:
	sub	sp, sp, #80
	stp	x1, x2, [sp, #24]
	add	x8, sp, #24
	stp	x3, x4, [sp, #40]
	ldr	h0, [sp, #24]
	stp	x5, x6, [sp, #56]
	str	x7, [sp, #72]
	fcvt	d0, h0
	ldr	h1, [x8, #8]!
	fcvt	d1, h1
	fadd	d0, d0, d1
	scvtf	d1, w3
	fadd	d0, d0, d1
	ldr	d1, [sp, #48]
	fadd	d0, d0, d1
	add	sp, sp, #80
	ret
                                        // -- End function
	.def	half_overflow_callback;
	.scl	2;
	.type	32;
	.endef
	.section	.rdata,"dr"
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
half_overflow_callback:                 // @half_overflow_callback
// %bb.0:
	sub	sp, sp, #32
	adrp	x8, .LCPI9_0
	adrp	x9, .LCPI9_1
	str	x30, [sp, #16]                  // 8-byte Folded Spill
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
	str	h16, [sp]
	blr	x0
	ldr	x30, [sp, #16]                  // 8-byte Folded Reload
	add	sp, sp, #32
	ret
                                        // -- End function
	.def	bfloat_identity;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_identity                 // -- Begin function bfloat_identity
	.p2align	2
bfloat_identity:                        // @bfloat_identity
// %bb.0:
	ret
                                        // -- End function
	.def	bfloat_bits;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_bits                     // -- Begin function bfloat_bits
	.p2align	2
bfloat_bits:                            // @bfloat_bits
// %bb.0:
                                        // kill: def $h0 killed $h0 def $s0
	fmov	w0, s0
	ret
                                        // -- End function
	.def	bfloat_from_bits;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_from_bits                // -- Begin function bfloat_from_bits
	.p2align	2
bfloat_from_bits:                       // @bfloat_from_bits
// %bb.0:
	fmov	s0, w0
                                        // kill: def $h0 killed $h0 killed $s0
	ret
                                        // -- End function
	.def	bfloat_convert;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_convert                  // -- Begin function bfloat_convert
	.p2align	2
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
                                        // -- End function
	.def	bfloat_callback;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_callback                 // -- Begin function bfloat_callback
	.p2align	2
bfloat_callback:                        // @bfloat_callback
// %bb.0:
	br	x0
                                        // -- End function
	.def	bfloat_mixed;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_mixed                    // -- Begin function bfloat_mixed
	.p2align	2
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
                                        // -- End function
	.def	bfloat_overflow;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_overflow                 // -- Begin function bfloat_overflow
	.p2align	2
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
                                        // -- End function
	.def	bfloat_varargs;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_varargs                  // -- Begin function bfloat_varargs
	.p2align	2
bfloat_varargs:                         // @bfloat_varargs
// %bb.0:
	sub	sp, sp, #80
	stp	x1, x2, [sp, #24]
	add	x8, sp, #24
	stp	x3, x4, [sp, #40]
	ldr	h0, [sp, #24]
	stp	x5, x6, [sp, #56]
	str	x7, [sp, #72]
	shll	v0.4s, v0.4h, #16
	ldr	h1, [x8, #8]!
	shll	v1.4s, v1.4h, #16
	fcvt	d0, s0
	fcvt	d1, s1
	fadd	d0, d0, d1
	scvtf	d1, w3
	fadd	d0, d0, d1
	ldr	d1, [sp, #48]
	fadd	d0, d0, d1
	add	sp, sp, #80
	ret
                                        // -- End function
	.def	bfloat_overflow_callback;
	.scl	2;
	.type	32;
	.endef
	.section	.rdata,"dr"
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
bfloat_overflow_callback:               // @bfloat_overflow_callback
// %bb.0:
	sub	sp, sp, #32
	adrp	x8, .LCPI18_0
	adrp	x9, .LCPI18_1
	str	x30, [sp, #16]                  // 8-byte Folded Spill
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
	str	h16, [sp]
	blr	x0
	ldr	x30, [sp, #16]                  // 8-byte Folded Reload
	add	sp, sp, #32
	ret
                                        // -- End function
	.def	half_dirty_result;
	.scl	2;
	.type	32;
	.endef
	.globl	half_dirty_result               // -- Begin function half_dirty_result
	.p2align	2
half_dirty_result:                      // @half_dirty_result
// %bb.0:
	mov	w8, #15360                      // =0x3c00
	movk	w8, #42405, lsl #16
	//APP
	fmov	s0, w8
	//NO_APP
	ret
                                        // -- End function
	.def	bfloat_dirty_result;
	.scl	2;
	.type	32;
	.endef
	.globl	bfloat_dirty_result             // -- Begin function bfloat_dirty_result
	.p2align	2
bfloat_dirty_result:                    // @bfloat_dirty_result
// %bb.0:
	mov	w8, #16256                      // =0x3f80
	movk	w8, #42405, lsl #16
	//APP
	fmov	s0, w8
	//NO_APP
	ret
                                        // -- End function
	.def	mixed_small_sum;
	.scl	2;
	.type	32;
	.endef
	.globl	mixed_small_sum                 // -- Begin function mixed_small_sum
	.p2align	2
mixed_small_sum:                        // @mixed_small_sum
// %bb.0:
                                        // kill: def $h1 killed $h1 def $d1
	fcvt	d0, h0
	shll	v1.4s, v1.4h, #16
	fcvt	d1, s1
	fadd	d0, d0, d1
	ret
                                        // -- End function
	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.word	4                               // Debug section magic
	.word	241
	.word	.Ltmp1-.Ltmp0                   // Subsection size
.Ltmp0:
	.hword	.Ltmp3-.Ltmp2                   // Record length
.Ltmp2:
	.hword	4353                            // Record kind: S_OBJNAME
	.word	0                               // Signature
	.byte	0                               // Object name
	.p2align	2, 0x0
.Ltmp3:
	.hword	.Ltmp5-.Ltmp4                   // Record length
.Ltmp4:
	.hword	4412                            // Record kind: S_COMPILE3
	.word	16384                           // Flags and language
	.hword	246                             // CPUType
	.hword	21                              // Frontend version
	.hword	0
	.hword	0
	.hword	0
	.hword	65535                           // Backend version
	.hword	0
	.hword	0
	.hword	0
	.asciz	"Apple clang version 21.0.0 (clang-2100.1.1.101)" // Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp5:
.Ltmp1:
	.p2align	2, 0x0
	.addrsig
