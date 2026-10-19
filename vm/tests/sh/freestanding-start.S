.text
.balign 4
.global _start
.type _start,@function
_start:
    mov.l .Lmain,r1
    jsr @r1
    nop
    mov r0,r4
    mov #1,r3
    trapa #0x10
    nop
.balign 4
.Lmain:
    .long sh_freestanding_main
.size _start,.-_start
.global sh_freestanding_leaf
.type sh_freestanding_leaf,@function
sh_freestanding_leaf:
    mov #7,r0
    mul.l r4,r0
    sts macl,r0
    rts
    add r5,r0
.size sh_freestanding_leaf,.-sh_freestanding_leaf
.section .note.GNU-stack,"",@progbits
