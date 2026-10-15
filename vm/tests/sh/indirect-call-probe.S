.text
.p2align 2
.global invoke_indirect
.type invoke_indirect,@function
invoke_indirect:
 mov.l r12,@-r15
 mov.l r14,@-r15
 sts.l pr,@-r15
 mov r4,r0
 mov r5,r4
 mov r6,r5
 mov.l .Lsentinel,r14
 jsr @r0
 nop
 lds.l @r15+,pr
 mov.l @r15+,r14
 mov.l @r15+,r12
 rts
 nop
.p2align 2
.Lsentinel: .long 0x13579bdf
.size invoke_indirect,.-invoke_indirect
.section .note.GNU-stack,"",@progbits
