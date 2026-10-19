.text
.align 2
.globl signal_call
signal_call:
    subu %r31,%r31,32
    st %r1,%r31,28
    st %r21,%r31,24
    st %r3,%r31,8
    jsr %r2
    ld %r21,%r31,24
    ld %r1,%r31,28
    addu %r31,%r31,32
    jmp %r1
