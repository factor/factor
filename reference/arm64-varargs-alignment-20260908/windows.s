	.def	"@feat.00";
	.scl	3;
	.type	0;
	.endef
	.globl	"@feat.00"
"@feat.00" = 0
	.file	"probe.c"
	.def	align_named;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	align_named                     // -- Begin function align_named
	.p2align	2
align_named:                            // @align_named
// %bb.0:
	ldr	x8, [x0]
	//APP
	//NO_APP
	and	x9, x1, #0xf
	add	x8, x8, w2, sxtw
	add	x8, x8, x9
	sub	x0, x8, #2
	ret
                                        // -- End function
	.def	align_return;
	.scl	2;
	.type	32;
	.endef
	.globl	align_return                    // -- Begin function align_return
	.p2align	2
align_return:                           // @align_return
// %bb.0:
	mov	x9, x8
	//APP
	//NO_APP
	ldr	x10, [x0]
	and	x8, x8, #0xf
	stp	xzr, xzr, [x9, #16]
	add	x8, x8, w1, sxtw
	add	x8, x8, x10
	sub	x8, x8, #2
	stp	x8, xzr, [x9]
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
