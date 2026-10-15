.text
.globl m88k_sjlj_poison_throw
.align 2
m88k_sjlj_poison_throw:
    or %r14,%r0,99
    or %r15,%r0,99
    or %r16,%r0,99
    or %r17,%r0,99
    or %r18,%r0,99
    or %r19,%r0,99
    or %r20,%r0,99
    or %r21,%r0,99
    or %r22,%r0,99
    or %r23,%r0,99
    or %r24,%r0,99
    or %r25,%r0,99
    br m88k_sjlj_throw_helper
