.text
.align 2
.globl factor_m88k_flush_icache
factor_m88k_flush_icache:
    tb0 0, %r0, 451
    jmp %r1

/* IP=r21 native target, CTX=r16. Linked frame precedes the native call. */
.globl trampoline
trampoline:
    or %r19,%r0,%r31
    subu %r31,%r31,16
    st %r19,%r31,0
    st %r1,%r31,4
    st %r30,%r31,8
    or %r30,%r0,%r31
    st %r31,%r16,0
    jsr %r21
    ld %r1,%r31,4
    ld %r30,%r31,8
    addu %r31,%r31,16
    jmp %r1

/* Native outgoing arguments begin at SP; r25 points to the bridge frame
 * beyond them. Caller allocated argument bytes plus a 16-byte bridge and
 * restores SP after this gate returns. r25+16 is the preceding Factor SP. */
.globl trampoline2
trampoline2:
    addu %r19,%r25,16
    st %r19,%r25,0
    st %r1,%r25,4
    st %r30,%r25,8
    or %r30,%r0,%r25
    st %r25,%r16,0
    jsr %r21
    ld %r1,%r25,4
    ld %r30,%r25,8
    jmp %r1
