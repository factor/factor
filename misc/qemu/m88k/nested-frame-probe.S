.text
.align 2
.globl nested_call
nested_call:
    subu %r31,%r31,64
    st %r1,%r31,60
    st %r16,%r31,56
    st %r23,%r31,52
    st %r19,%r31,48
    st %r20,%r31,44
    st %r21,%r31,40
    st %r30,%r31,36
    or %r21,%r0,%r2
    or %r2,%r0,%r3
    or %r3,%r0,%r4
    or %r16,%r0,%r5
    or %r23,%r0,%r6
    jsr %r21
    ld %r30,%r31,36
    ld %r21,%r31,40
    ld %r20,%r31,44
    ld %r19,%r31,48
    ld %r23,%r31,52
    ld %r16,%r31,56
    ld %r1,%r31,60
    addu %r31,%r31,64
    jmp %r1
