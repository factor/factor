	.text
	.globl	_align_named                     // -- Begin function _align_named
	.p2align	2
_align_named:                            // @_align_named
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
	.globl	_align_return                    // -- Begin function _align_return
	.p2align	2
_align_return:                           // @_align_return
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
