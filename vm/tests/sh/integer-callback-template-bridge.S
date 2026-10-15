.text
.p2align 2
.global call_snapshot
.type call_snapshot,@function
call_snapshot:
 sts.l pr,@-r15
 mov.l r8,@-r15
 mov r4,r8
 add #-8,r15
 mov #55,r0
 mov.l r0,@r15
 mov #66,r0
 mov.l r0,@(4,r15)
 mov.l .Lhidden,r2
 mov #11,r4
 mov #22,r5
 mov #33,r6
 mov #44,r7
 jsr @r8
 nop
 add #8,r15
 mov.l @r15+,r8
 lds.l @r15+,pr
 rts
 nop
.p2align 2
.Lhidden: .long 0x76543210
.size call_snapshot,.-call_snapshot
.section .note.GNU-stack,"",@progbits
